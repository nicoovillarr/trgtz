const mongoose = require('mongoose')
const { Schema } = mongoose

const userSchema = new Schema(
  {
    email: {
      type: String,
      required: true
    },
    password: {
      type: String,
      required: true
    },
    firstName: {
      type: String,
      required: true
    },
    goals: [
      {
        type: Schema.Types.ObjectId,
        ref: 'Goal'
      }
    ]
  },
  {
    timestamps: true,
    toJSON: {
      transform(doc, ret) {
        delete ret.password
      }
    }
  }
)

const User = mongoose.model('User', userSchema)

module.exports = User
