const app = require('./config/app')
const websocket = require('./config/websocket')
const db = require('./config/database')

app.listen(process.env.PORT || 3000, async () => {
  await db.init()
  websocket.init(app)

  const NODE_ENV = process.env.NODE_ENV || 'development'
  console.log(`App started in ${NODE_ENV} mode!`)
})
