const WebSocket = require('ws')

const sessionService = require('../services/session.service')

const channels = {
  USER: {},
  ALERTS: {},
  FRIENDS: {},
  GOAL: {},
  REPORT: {}
}

const clients = {}

const init = () => {
  const wss = new WebSocket.Server({ port: process.env.WS_PORT || 8080 })

  wss.on('connection', (ws) => {
    let userId
    ws.on('message', async (message) => {
      try {
        const parsedMessage = JSON.parse(message)
        const { type, data } = parsedMessage

        if (type === 'AUTH') {
          const token = data.token
          const session = await sessionService.getSession(token)
          if (!session) {
            console.log('Invalid session. Closing connection.')
            ws.close()
            return
          }

          userId = session.userId
          if (!clients[userId]) {
            clients[userId] = new Map()
          }

          const uuid = randomUuid()
          clients[userId].set(uuid, ws)

          ws.send(
            JSON.stringify({ type: 'AUTH_SUCCESS', data: uuid }),
            (error) => {
              if (error) {
                console.error('Error sending AUTH_SUCCESS:', error)
              }
            }
          )

          console.log(`${userId} authenticated and connected to websocket...`)
        } else {
          const { channelType, documentId } = data

          switch (type) {
            case 'SUBSCRIBE_CHANNEL':
              if (!channels[channelType]) {
                channels[channelType] = {}
              }
              if (!channels[channelType][documentId]) {
                channels[channelType][documentId] = new Set()
              }
              channels[channelType][documentId].add(userId)

              console.log(`${userId} suscribed to ${channelType}:${documentId}`)
              break

            case 'UNSUBSCRIBE_CHANNEL':
              if (
                channels[channelType] &&
                channels[channelType][documentId] &&
                channels[channelType][documentId].has(userId)
              ) {
                channels[channelType][documentId].delete(userId)
                console.log(
                  `${userId} unsubscribed from ${channelType}:${documentId}`
                )
              }
              break
          }
        }
      } catch (error) {
        console.error('Error handling message:', error)
      }
    })

    ws.on('close', () => {
      for (const userId in clients) {
        if (clients[userId]) {
          clients[userId].forEach((value, key) => {
            if (value === ws) {
              clients[userId].delete(key)
            }
          })
          if (clients[userId].size === 0) {
            delete clients[userId]
          }
        }
      }
      console.log('A client disconnected from websocket...')
    })
  })

  console.log(`Websocket server started`)
}

const randomUuid = () => {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    const r = (Math.random() * 16) | 0,
      v = c === 'x' ? r : (r & 0x3) | 0x8
    return v.toString(16)
  })
}

const sendUserChannelMessage = (userId, type, data) =>
  sendMessage('USER', userId, type, data)

const sendAlertsChannelMessage = (userId, type, data) =>
  sendMessage('ALERTS', userId, type, data)

const sendFriendsChannelMessage = (userId, type, data) =>
  sendMessage('FRIENDS', userId, type, data)

const sendGoalChannelMessage = (goalId, type, data) =>
  sendMessage('GOAL', goalId, type, data)

const sendReportChannelMessage = (reportId, type, data) =>
  sendMessage('REPORT', reportId, type, data)

const sendMessage = (channelType, documentId, type, data) => {
  if (
    channels[channelType] == null ||
    channels[channelType][documentId] == null
  ) {
    return
  }

  const message = JSON.stringify({
    type,
    channelType,
    documentId,
    data
  })

  for (const userId of channels[channelType][documentId]) {
    if (clients[userId] == null) {
      continue
    }

    for (const ws of clients[userId].values()) {
      ws.send(message)
    }
  }

  console.log(`Broadcast message to ${channelType}:${documentId}: ${message}`)
}

module.exports = {
  init,
  sendUserChannelMessage,
  sendAlertsChannelMessage,
  sendFriendsChannelMessage,
  sendGoalChannelMessage,
  sendReportChannelMessage
}
