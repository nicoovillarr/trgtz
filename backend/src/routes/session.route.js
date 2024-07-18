const express = require('express')
const app = express()

const sessionController = require('../controllers/session.controller')
const protect = require('../middlewares/auth.middleware')

app.patch('/firebase-token', protect, sessionController.updateFirebaseToken)

module.exports = app
