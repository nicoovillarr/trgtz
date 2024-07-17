const authService = require('../services/auth.service')
const sessionService = require('../services/session.service')

const signup = async (req, res) => {
  try {
    const { firstName, email, password, deviceInfo } = req.body

    if (!firstName || !email || !password || !deviceInfo)
      return res.status(400).json({ message: 'Missing required fields' })

    if (await authService.checkEmailInUse(email)) {
      return res.status(400).json({ message: 'Email already in use' })
    }

    const {
      firebaseToken,
      type,
      version,
      manufacturer,
      model,
      isVirtual,
      serialNumber
    } = deviceInfo
    if (
      !firebaseToken ||
      !type ||
      !version ||
      !manufacturer ||
      !model ||
      isVirtual == null ||
      !serialNumber
    )
      return res
        .status(400)
        .json({ message: 'Missing required fields in device info' })

    const user = await authService.signup(
      firstName,
      email,
      await authService.hashPassword(password),
      firebaseToken,
      type,
      version,
      manufacturer,
      model,
      isVirtual,
      serialNumber
    )

    const token = await sessionService.createJWT(
      user._id,
      firebaseToken,
      type,
      version,
      manufacturer,
      model,
      isVirtual,
      serialNumber,
      req.ip
    )
    res.status(201).json({
      token
    })
  } catch (error) {
    res.status(500).json(error)
    console.error('Error signing up: ', error)
  }
}

const login = async (req, res) => {
  try {
    const { email, password, deviceInfo } = req.body

    if (!email || !password || !deviceInfo)
      return res.status(400).json({ message: 'Missing required fields' })

    const {
      firebaseToken,
      type,
      version,
      manufacturer,
      model,
      isVirtual,
      serialNumber
    } = deviceInfo
    if (
      !firebaseToken ||
      !type ||
      !version ||
      !manufacturer ||
      !model ||
      isVirtual == null ||
      !serialNumber
    )
      return res
        .status(400)
        .json({ message: 'Missing required fields in device info' })

    const user = await authService.login(email, password)
    if (user == null) res.status(400).json({ message: 'Invalid credentials' })
    else {
      const token = await sessionService.createJWT(
        user._id,
        firebaseToken,
        type,
        version,
        manufacturer,
        model,
        isVirtual,
        serialNumber,
        req.ip
      )
      res.status(200).json({
        token
      })
    }
  } catch (error) {
    res.status(500).json(error)
    console.error('Error logging in: ', error)
  }
}

const tick = (req, res) => {
  try {
    res.status(req.user === null ? 401 : 201).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error ticking goal: ', error)
  }
}

module.exports = {
  signup,
  login,
  tick
}
