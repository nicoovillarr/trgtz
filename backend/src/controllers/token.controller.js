const tokenService = require('../services/token.service')
const userService = require('../services/user.service')

const validateToken = async (req, res) => {
  try {
    const { token } = req.params
    const { type } = req.query

    const tokenDoc = await tokenService.getToken(token, type)
    if (tokenDoc === null) {
      return res
        .status(401)
        .json({ message: 'The token is invalid or has already expired' })
    }

    const userInfo = await userService.getUserInfo(tokenDoc.user)
    const json = userInfo.toJSON()

    res.status(200).json({
      _id: json._id,
      firstName: json.firstName,
      image: json.avatar?.url ?? null
    })
  } catch (error) {
    res.status(500).json(error)
    console.error('Error validating token: ', error)
  }
}

module.exports = {
  validateToken
}
