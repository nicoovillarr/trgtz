const User = require('../models/user.model')
const authService = require('../services/auth.service')
const sessionService = require('../services/session.service')

const signup = async (req, res) => {
  try {
    const { email, firstName, deviceInfo, photoUrl, password, provider } =
      req.body

    if (
      !firstName ||
      !email ||
      !deviceInfo ||
      !provider ||
      (provider === 'email' && !password)
    )
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

    const hash =
      provider === 'email' ? await authService.hashPassword(password) : null
    const user = await authService.signup(
      firstName,
      email,
      hash,
      provider,
      photoUrl
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
      req.custom.ip,
      provider
    )
    res.status(201).json({
      _id: user._id,
      token
    })
  } catch (error) {
    res.status(500).json(error)
    console.error('Error signing up: ', error)
  }
}

const login = async (req, res) => {
  try {
    const { email, deviceInfo, password, provider = 'email' } = req.body

    if (!email || !deviceInfo || (provider === 'email' && !password))
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
        req.custom.ip
      )
      res.status(200).json({
        _id: user._id,
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
    if (req.user === null) res.status(401).json({ message: 'Unauthorized' })
    else res.status(201).json({ message: 'User ticked', _id: req.user })
  } catch (error) {
    res.status(500).json(error)
    console.error('Error ticking goal: ', error)
  }
}

const logout = async (req, res) => {
  try {
    await sessionService.deleteSession(req.token)
    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error logging out: ', error)
  }
}

const googleSignIn = async (req, res) => {
  const { idToken, email, deviceInfo } = req.body

  try {
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

    const payload = await authService.verifyGoogleToken(idToken)
    if (payload.email !== email) {
      return res.status(401).json({ message: 'Token email does not match' })
    }

    if (await authService.checkEmailInUse(email)) {
      const user = await User.findOne({ email })

      const token = await sessionService.createJWT(
        user._id,
        firebaseToken,
        type,
        version,
        manufacturer,
        model,
        isVirtual,
        serialNumber,
        req.custom.ip,
        'google'
      )

      return res.status(200).json({ _id: user._id, token })
    } else {
      const user = await authService.signup(
        payload.given_name,
        email,
        null,
        'google',
        payload.picture
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
        req.custom.ip,
        'google'
      )

      return res.status(201).json({ _id: user._id, token })
    }
  } catch (error) {
    return res.status(401).json({ message: 'Invalid token' })
  }
}

module.exports = {
  signup,
  login,
  tick,
  logout,
  googleSignIn
}
