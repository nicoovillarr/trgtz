const express = require('express')
const app = express()
const protect = require('../middlewares/auth.middleware')

const userController = require('../controllers/user.controller')

app.get('/', protect, userController.getMe)
app.patch('/:id', protect, userController.patchUser)
app.post('/friend-request', protect, userController.sendFriendRequest)
app.put('/friend-request', protect, userController.answerFriendRequest)

module.exports = app
