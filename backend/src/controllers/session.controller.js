const sessionService = require('../services/session.service')

const updateFirebaseToken = async (req, res) => {
  try {
    const { firebaseToken } = req.body
    if (!firebaseToken)
      return res.status(400).json({ message: 'Missing firebase token' })

    await sessionService.updateFirebaseToken(req.token, firebaseToken)

    res.status(200).json({ message: 'Firebase token updated' })
  } catch (error) {
    res.status(400).json(error)
    console.error('Error updating firebase token: ', error)
  }
}

module.exports = {
  updateFirebaseToken
}
