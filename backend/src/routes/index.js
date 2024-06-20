const express = require('express')
const app = express()

app.use('/goals', require('./goal.route'))

module.exports = app
