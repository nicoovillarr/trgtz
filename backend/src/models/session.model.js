const mongoose = require('mongoose')
const { Schema } = mongoose

const sessionSchema = new Schema(
  {
    userId: {
      type: String,
      required: true
    },
    token: {
      type: String,
      required: true
    },
    lastIPAddress: {
      type: String,
      required: true
    },
    lastAccesedOn: {
      type: Date,
      default: new Date()
    },
    createdOn: {
      type: Date,
      default: new Date()
    },
    expiredOn: {
      type: Date,
      required: false,
      default: null
    },
    device: {
      firebaseToken: {
        type: String,
        required: true
      },
      type: {
        type: String,
        required: true
      },
      version: {
        type: String,
        required: true
      },
      manufacturer: {
        type: String,
        required: true
      },
      model: {
        type: String,
        required: true
      },
      isVirtual: {
        type: Boolean,
        required: true
      },
      serialNumber: {
        type: String,
        required: true
      }
    }
  },
  {
    timestamps: false
  }
)

const Session = mongoose.model('Session', sessionSchema)

module.exports = Session
