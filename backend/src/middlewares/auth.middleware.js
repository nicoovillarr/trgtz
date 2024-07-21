const jwt = require('jsonwebtoken')
const Session = require('../models/session.model')
const sessionService = require('../services/session.service')

const protect = async (req, res, next) => {
  const bearer = req.header('Authorization')
  if (!bearer || !bearer.startsWith('Bearer '))
    return res.status(401).json({ message: 'Unauthorized' })
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
    if (!sessionExists) return res.status(401).json({ message: 'Unauthorized' })

    await sessionService.updateSession(token, req.custom.ip)

    req.user = decoded.id
    req.token = token
    next()
  } catch (error) {
    res.status(401).json(error)
    console.error('Error authenticating user: ', error)
  }
}

module.exports = protect
