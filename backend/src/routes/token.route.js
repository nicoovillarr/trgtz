const express = require('express')
const app = express()

const tokenController = require('../controllers/token.controller')

app.get('/validate-token/:token', tokenController.validateToken)

module.exports = app
