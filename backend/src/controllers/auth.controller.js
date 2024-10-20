const User = require('../models/user.model')
const authService = require('../services/auth.service')
const sessionService = require('../services/session.service')
const mailService = require('../services/mail.service')
const tokenService = require('../services/token.service')

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

const tick = async (req, res) => {
  try {
    if (req.user === null) res.status(401).json({ message: 'Unauthorized' })
    else {
      const session = await sessionService.getSession(req.token)
      res.status(201).json({ message: 'User ticked', _id: req.user, session })
    }
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
  const { idToken, deviceInfo } = req.body
  if (!idToken || !deviceInfo) {
    return res.status(400).json({ message: 'Missing required fields' })
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
  ) {
    return res
      .status(400)
      .json({ message: 'Missing required fields in device info' })
  }

  try {
    const payload = await authService.verifyGoogleToken(idToken)
    if (payload == null) {
      return res.status(401).json({ message: 'Invalid token' })
    }

    const user = await User.findOne({ email: payload.email })
    if (user != null) {
      if (user.providers.indexOf('google') === -1) {
        return res
          .status(401)
          .json({ message: 'You must log in using your password' })
      }

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
        payload.email,
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

const addProvider = async (req, res) => {
  try {
    const userId = req.user
    const { provider, idToken } = req.body

    if (!provider) {
      return res.status(400).json({ message: 'Missing required fields' })
    }

    const user = await User.findById(userId)
    if (user == null) {
      return res.status(404).json({ message: 'User not found' })
    }

    if (await authService.addProvider(user, provider)) {
      if (idToken != null) {
        const payload = await authService.verifyGoogleToken(idToken)
        if (payload == null) {
          return res.status(401).json({ message: 'Invalid token' })
        }

        await sessionService.updateSessionProvider(req.token, provider)
      }
      res.status(204).end()
    } else {
      res.status(400).json({ message: 'Provider already added' })
    }
  } catch (error) {
    res.status(500).json(error)
    console.error('Error adding provider: ', error)
  }
}

const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body
    if (!email)
      return res.status(400).json({ message: 'Missing required fields' })

    const user = await User.findOne({ email })
    if (user == null) return res.status(204).end()

    const token = await tokenService.createToken('password_reset', user._id)
    if (token == null)
      return res.status(500).json({ message: 'Error creating token' })

    const resetUrl = `${
      process.env.FRONTEND_URL
    }/forgot-password?token=${encodeURIComponent(token)}`
    const subject = 'Reset your password'
    const text = `Click the following link to reset your password: ${resetUrl}`
    const html = `<p>Click the following link to reset your password: <a href="${resetUrl}">${resetUrl}</a></p>`

    const sent = await mailService.sendNoReplyEmail(email, subject, text, html)
    if (!sent) return res.status(500).json({ message: 'Error sending email' })

    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error sending email: ', error)
  }
}

const resetPassword = async (req, res) => {
  try {
    const { token, password } = req.body
    if (!token || !password)
      return res.status(400).json({ message: 'Missing required fields' })

    const userId = await tokenService.consumeToken(
      decodeURIComponent(token),
      'password_reset'
    )
    if (userId == null)
      return res.status(401).json({ message: 'Invalid token' })

    const user = await User.findById(userId)
    if (user == null) return res.status(404).json({ message: 'User not found' })

    const hash = await authService.hashPassword(password)
    await User.findByIdAndUpdate(userId, { password: hash }).exec()

    const subject = 'Password reset successful'
    const text = 'Your password has been successfully reset'
    const html = '<p>Your password has been successfully reset</p>'
    
    const sent = await mailService.sendNoReplyEmail(user.email, subject, text, html)
    if (!sent) return res.status(500).json({ message: 'Error sending email' })

    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error resetting password: ', error)
  }
}

module.exports = {
  signup,
  login,
  tick,
  logout,
  googleSignIn,
  addProvider,
  forgotPassword,
  resetPassword
}
