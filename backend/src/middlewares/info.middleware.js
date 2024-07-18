const info = async (req, res, next) => {
  const parseIp = (req) =>
    req.headers['x-forwarded-for']?.split(',').shift() ||
    req.socket?.remoteAddress

  req.ip = parseIp(req)

  next()
}

module.exports = info
