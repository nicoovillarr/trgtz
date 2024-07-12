const User = require('../models/user.model')
const Alert = require('../models/alert.model')

const mongoose = require('mongoose')

const addAlert = async (sent_by, sent_to, type) => {
  const alert = new Alert({
    sent_by,
    sent_to,
    type
  })

  await alert.save()

  const user = await User.findById(sent_to)
  user.alerts.push(alert)
  await user.save()

  return alert
}

module.exports = {
  addAlert
}
