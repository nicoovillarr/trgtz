const authService = require('../services/auth.service')

const signup = async (req, res) => {
  try {
    const { firstName, email, password } = req.body

    if (!firstName || !email || !password)
      return res.status(400).json({ message: 'Missing required fields' })

    if (await authService.checkEmailInUse(email)) {
      return res.status(400).json({ message: 'Email already in use' })
    }

    const user = await authService.signup(
      firstName,
      email,
      await authService.hashPassword(password)
    )

    const token = await authService.createJWT(user._id)
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
    const { email, password } = req.body

    if (!email || !password)
      return res.status(400).json({ message: 'Missing required fields' })

    const user = await authService.login(email, password)
    if (user == null) res.status(400).json({ message: 'Invalid credentials' })
    else {
      const token = await authService.createJWT(user._id)
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
