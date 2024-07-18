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
const privateKey = process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
const serviceAccount = Object.assign(require('./config/firebase-admin.json'), {
  private_key: privateKey
})

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
})

module.exports = app
