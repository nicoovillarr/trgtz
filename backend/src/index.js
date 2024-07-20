const app = require('./config/app')
const websocket = require('./config/websocket')
const db = require('./config/database')

app.listen(process.env.PORT || 3000, async () => {
  await db.init()
  websocket.init(app)
  console.log('App running on port 3000!')
})
