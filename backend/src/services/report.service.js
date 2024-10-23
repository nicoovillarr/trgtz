const Report = require('../models/report.model')
const User = require('../models/user.model')
const Goal = require('../models/goal.model')
const alertService = require('./alert.service')
const pushNotificationService = require('./push-notification.service')
const mailService = require('./mail.service')
const { viewReports } = require('../config/views')
const { sendReportChannelMessage } = require('../config/websocket')

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
  report.resolvedOn = new Date()
  await report.save()

  await pushNotificationService.sendNotificationToUser(
    user._id,
    `Report ${status}`,
    `Your report has been ${status}!`
  )

  await alertService.addAlert(user._id, user._id, 'report_' + status, true)

  const userCreator = await User.findById(report.user)

  const subject = `Report ${status}!`
  const text = `Your report has been ${status}!`
  const html = `<p>Your report has been ${status}!</p><ul><li>Category: ${report.category}</li><li>Reason: ${report.reason}</li><li>Resolution: ${report.resolution}</li></ul>`
  await mailService.sendNoReplyEmail(userCreator.email, subject, text, html)

  sendReportChannelMessage(report._id, 'REPORT_UPDATE', {
    status: report.status,
    resolution: report.resolution,
    resolvedOn: report.resolvedOn
  })

  return report
}

const getAllReports = async (filters = {}) => await viewReports.find(filters)

const getReport = async (id) => await viewReports.findById(id)

const getAllUserReports = async (user) =>
  await viewReports.find({ 'user._id': user })

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
