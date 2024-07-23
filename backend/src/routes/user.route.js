const express = require('express')
const app = express()
const protect = require('../middlewares/auth.middleware')

const userController = require('../controllers/user.controller')

app.get('/', protect, userController.getMe)
app.patch('/', protect, userController.patchUser)
app.post('/profile-image', protect, userController.setProfileImage)
app.patch('/change-password', protect, userController.updatePassword)
app.post('/friend', protect, userController.sendFriendRequest)
app.get('/friend', protect, userController.getFriends)
app.put('/friend', protect, userController.answerFriendRequest)
app.delete('/friend/:otherUser', protect, userController.deleteFriend)
app.get('/friend/pending', protect, userController.getPendingFriends)

module.exports = app
