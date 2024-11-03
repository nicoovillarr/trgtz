const express = require('express')
const app = express()
const { protect } = require('../middlewares/auth.middleware')

const userController = require('../controllers/user.controller')

app.get('/validate', userController.sendValidationEmail)
app.post('/validate', userController.validateEmail)

app.patch('/', protect, userController.patchUser)
app.post('/profile-image', protect, userController.setProfileImage)
app.patch('/change-password', protect, userController.updatePassword)
app.post('/friend', protect, userController.sendFriendRequest)
app.get('/friend', protect, userController.getFriends)
app.put('/friend', protect, userController.answerFriendRequest)
app.delete('/friend/:otherUser', protect, userController.deleteFriend)
app.get('/friend/pending', protect, userController.getPendingFriends)

app.get('/alerts/types', protect, userController.getUserSubscribedTypes)
app.put('/alerts/subscribe', protect, userController.subscribeToAlert)
app.put('/alerts/unsubscribe', protect, userController.unsubscribeToAlert)

app.get('/:user', protect, userController.getUserProfile)

app.get('/:user/goals', protect, userController.getUserGoals)

app.get('/:user/friends', protect, userController.getUserFriends)

module.exports = app
