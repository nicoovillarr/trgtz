const express = require('express')
const app = express()
const protect = require('../middlewares/auth.middleware')

const userController = require('../controllers/user.controller')

app.get('/', protect, userController.getMe)
app.patch('/', protect, userController.patchUser)
app.patch('/change-password', protect, userController.updatePassword)
app.put('/friend', protect, userController.answerFriendRequest)
app.delete('/friend/:otherUser', protect, userController.deleteFriend)

module.exports = app
