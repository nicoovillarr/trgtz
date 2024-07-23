const app = require('./config/app')

app.listen(process.env.PORT || 3000, () => {
  const NODE_ENV = process.env.NODE_ENV || 'development'
  console.log(`App started in ${NODE_ENV} mode!`)
})
