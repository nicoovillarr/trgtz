const express = require('express')
const app = express()

app.use('/goals', require('./goal.route'))
app.use('/auth', require('./auth.route'))
app.use('/users', require('./user.route'))

module.exports = app
