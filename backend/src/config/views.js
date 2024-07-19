const mongoose = require('mongoose')

module.exports = {
  viewUsers: mongoose.model(
    'view_users_2',
    new mongoose.Schema({ _id: String }, { collection: 'view_users_2' })
  ),
  viewFriends: mongoose.model(
    'view_friends',
    new mongoose.Schema(
      {
        _id: String,
        otherUserID: String
      },
      { collection: 'view_friends' }
    )
  )
}
