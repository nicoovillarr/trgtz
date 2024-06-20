const express = require('express')
const app = express()

app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to the Goals API'
  })
})
app.use('/goals', require('./goal.route'))
app.use('/auth', require('./auth.route'))
app.use('/users', require('./user.route'))

module.exports = app
