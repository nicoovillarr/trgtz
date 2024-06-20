const express = require('express')
const app = express()

const authController = require('../controllers/auth.controller')

app.post('/signup', authController.signup)
app.post('/login', authController.login)

module.exports = app
