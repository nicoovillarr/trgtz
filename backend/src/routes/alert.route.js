const alertController = require('../controllers/alert.controller')

const express = require('express')

const app = express()

app.get('/types', alertController.getAlertTypes)

module.exports = app
