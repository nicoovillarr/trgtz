const connectDB = require('./config/database')
connectDB()

const express = require('express')
const app = express()
const cors = require('cors')

app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: false }))
app.use(require('./routes'))

module.exports = app
