const connectDB = require('./config/database')
connectDB()

const compression = require('compression')
const express = require('express')
const app = express()
const cors = require('cors')

app.use(compression())
app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: false }))
app.use('/v1', require('./routes'))

module.exports = app
