const Report = require('../models/report.model')
const User = require('../models/user.model')
const Goal = require('../models/goal.model')
const alertService = require('./alert.service')
const pushNotificationService = require('./push-notification.service')
const { viewReports } = require('../config/views')

const mongoose = require('mongoose')

const createReport = async (user, entity_type, entity_id, category, reason) => {
  const entity = await getEntity(entity_type, entity_id)
  if (entity == null) return null

  const report = new Report({
    user,
    entity_type,
    entity_id,
    category,
    reason,
    createdOn: new Date()
  })

  await report.save()

  await alertService.addAlert(user, user, 'report_created')

  // TODO: Send email to user and admins with report details

  return report
}

const getEntity = async (entity_type, entity_id) => {
  switch (entity_type) {
    case 'goal':
      return await Goal.findById(entity_id)

    case 'user':
      return await User.findById(entity_id)

    case 'comment':
      return await Goal.find({
        'comments._id': new mongoose.Types.ObjectId(entity_id)
      })

    default:
      return null
  }
}

const resolveReport = async (user, id, status, resolution) => {
  const report = await Report.findById(id)
  if (report == null) return null

  report.status = status
  report.resolution = resolution
  await report.save()

  await pushNotificationService.sendNotificationToUser(
    user,
    `Report ${status}`,
    `Your report has been ${status}!`
  )

  await alertService.addAlert(user, user, 'report_' + status)

  // TODO: Send email to user with resolution details

  return report
}

const getAllReports = async () => await viewReports.find()

const getReport = async (id) => await viewReports.findById(id)

const getAllUserReports = async (user) => await viewReports.find({ "user._id": user })

const getEntityReports = async (entity_type, entity_id) => {
  return await Report.find({ entity_type, entity_id })
}

module.exports = {
  createReport,
  resolveReport,
  getAllReports,
  getReport,
  getAllUserReports,
  getEntityReports
}
