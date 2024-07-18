require('dotenv').config()

const connectDB = require('./config/database')
connectDB()

const compression = require('compression')
const express = require('express')
const app = express()
const cors = require('cors')
const info = require('./middlewares/info.middleware')

app.use(compression())
app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: false }))
app.use(info)
app.use('/', require('./routes'))

const admin = require('firebase-admin')
const serviceAccount = require('./config/firebase-admin.json')
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
})

module.exports = app
