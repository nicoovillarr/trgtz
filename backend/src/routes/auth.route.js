const express = require('express')
const app = express()

const authController = require('../controllers/auth.controller')
const protect = require('../middlewares/auth.middleware')

app.post('/signup', authController.signup)
app.post('/login', authController.login)
app.get('/tick', protect, authController.tick)
app.post('/logout', protect, authController.logout)

module.exports = app
