const WebSocket = require('ws')
const wss = new WebSocket.Server({ port: 8080 })
const mongoose = require('mongoose')

const sessionService = require('../services/session.service')

const channels = {
  USER: {},
  GOAL: {}
}
const clients = {}

const init = () => {
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
          clients[userId].set(session._id, ws)

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

  const db = mongoose.connection.db

  db.collection('users')
    .watch()
    .on('change', (next) => {
      switch (next.operationType) {
        case 'update':
          sendMessage(
            'USER',
            next.documentKey._id,
            'USER_UPDATE',
            next.updateDescription.updatedFields
          )
          break
      }
    })

  db.collection('goals')
    .watch()
    .on('change', (next) => {
      switch (next.operationType) {
        case 'update':
          sendMessage(
            'GOAL',
            next.documentKey._id,
            'GOAL_UPDATE',
            next.updateDescription.updatedFields
          )
          break
      }
    })
}

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

const buildMessage = (type, data) => JSON.stringify({ type, data })

module.exports = {
  init,
  sendMessage
}
