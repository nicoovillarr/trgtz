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

const swaggerUi = require('swagger-ui-express')
const swaggerJsdoc = require('swagger-jsdoc')

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'trgtz',
      version: '1.0.0'
    }
  },
  apis: ['./src/routes/*.js']
}

const openapiSpecification = swaggerJsdoc(options)
app.use('/', swaggerUi.serve)
app.get(
  '/',
  swaggerUi.setup(openapiSpecification, {
    explorer: true,
    customCss: '',
    customCssUrl:
      'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.1.0/swagger-ui.min.css'
  })
)
app.use('/', require('./routes'))

module.exports = app
