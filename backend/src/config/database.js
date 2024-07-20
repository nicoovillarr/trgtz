const mongoose = require('mongoose')

const mongoURI = process.env.MONGODB_URI

const init = async () => {
  try {
    await mongoose.connect(mongoURI)
    console.log('Connected to MongoDB')
  } catch (err) {
    console.error('Failed to connect to MongoDB', err)
    process.exit(1)
  }
}

module.exports = {
  init
}
