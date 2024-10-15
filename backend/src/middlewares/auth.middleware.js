const jwt = require('jsonwebtoken')
const Session = require('../models/session.model')
const sessionService = require('../services/session.service')

const authenticate = async (req, res, next) => {
  const bearer = req.header('Authorization')
  if (!bearer || !bearer.startsWith('Bearer ')) {
    next()
    return
  }

  const token = bearer.substring(bearer.indexOf(' ') + 1)

  try {
    const decoded = jwt.verify(
      token.substring(token.indexOf(' ') + 1),
      process.env.JWT_SECRET
    )

    const sessionExists = await Session.exists({
      token: token,
      expiredOn: null,
      userId: decoded.id
    })

    if (sessionExists) {
      await sessionService.updateSession(token, req.custom.ip)

      req.user = decoded.id
      req.token = token
    }
  } catch (error) {
    console.error('Error authenticating user: ', error)
  } finally {
    next()
  }
}

const protect = async (req, res, next) => {
  if (!req.user || !req.token) {
    return res.status(401).json({ message: 'Unauthorized' })
  }

  next()
}

module.exports = {
  authenticate,
  protect
}
