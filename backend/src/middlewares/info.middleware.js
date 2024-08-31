const info = async (req, res, next) => {
  const parseIp = (req) =>
    req.headers['x-forwarded-for']?.split(',').shift() ||
    req.socket?.remoteAddress

  req.custom = {}
  req.custom.ip = parseIp(req)
  req.custom.broadcastToken = req.headers['broadcast-token']

  next()
}

module.exports = info
