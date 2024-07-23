// src/config/app.js
const NODE_ENV = process.env.NODE_ENV || 'development'
const path = require('path')
require('dotenv').config({
  path: path.join(__dirname, `../../.env.${NODE_ENV}`)
})

const compression = require('compression')
const express = require('express')
const cors = require('cors')
const info = require('../middlewares/info.middleware')

const app = express()

app.use(compression())
app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: false }))
app.use(info)

app.use('/', require('../routes'))

const admin = require('firebase-admin')
const config = require('./firebase-admin.json')[NODE_ENV]
const serviceAccount = Object.assign(config, {
  private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  client_id: process.env.FIREBASE_CLIENT_ID,
  client_email: process.env.FIREBASE_CLIENT_EMAIL
})

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
})

const db = require('./database')
db.init().then(() => {
  const ws = require('./websocket')
  ws.init()
})

module.exports = app
