const express = require('express')
const app = express()

app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Trgtz!'
  })
})
app.use('/goals', require('./goal.route'))
app.use('/auth', require('./auth.route'))
app.use('/users', require('./user.route'))
app.use('/sessions', require('./session.route'))
app.use('/reports', require('./report.route'))
app.use('/tokens', require('./token.route'))

module.exports = app
