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
    ],
    friends: [
      {
        requester: {
          type: Schema.Types.ObjectId,
          ref: 'User'
        },
        recipient: {
          type: Schema.Types.ObjectId,
          ref: 'User'
        },
        status: {
          type: String,
          enum: ['pending', 'accepted', 'rejected'],
          default: 'pending'
        },
        createdOn: {
          type: Date,
          default: new Date()
        },
        updatedOn: {
          type: Date,
          required: false,
          default: null
        },
        deletedOn: {
          type: Date,
          required: false,
          default: null
        }
      }
    ],
    sessions: [
      {
        type: String
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
