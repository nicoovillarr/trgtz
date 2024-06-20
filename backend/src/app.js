const connectDB = require('./config/database')
connectDB()

const express = require('express')
const app = express()

app.use(express.json())
app.use(express.urlencoded({ extended: false }))
app.use(require('./routes'))

app.listen(process.env.PORT || 3000, () =>
  console.log('App running on port 3000!')
)
