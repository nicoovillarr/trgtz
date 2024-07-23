const mongoose = require('mongoose')
const { Schema } = mongoose

const imageSchema = new Schema({
  url: {
    type: String,
    required: true
  },
  user: {
    type: String,
    ref: 'User'
  },
  createdOn: {
    type: Date,
    default: new Date()
  },
  deletedOn: {
    type: Date,
    required: false,
    default: null
  }
})

const Image = mongoose.model('Image', imageSchema)

module.exports = Image
