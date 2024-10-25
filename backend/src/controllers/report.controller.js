const User = require('../models/user.model')
const reportService = require('../services/report.service')
const mailService = require('../services/mail.service')

const createReport = async (req, res) => {
  try {
    const user = req.user
    const { entityType, entityId, category, reason } = req.body

    const report = await reportService.createReport(
      user,
      entityType,
      entityId,
      category,
      reason
    )

    if (report == null) {
      return res
        .status(400)
        .json({ message: `Entity with id ${entityId} not found.` })
    }

    const admins = await User.find({ isSuperAdmin: true })
    const emails = admins.map((admin) => admin.email)
    await mailService.sendReportEmail(emails, report)

    res.status(200).json(report)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const resolveReport = async (req, res) => {
  try {
    const userId = req.user
    const { id } = req.params
    const { status, resolution } = req.body

    const user = await User.findById(userId)
    if (user == null || !user.isSuperAdmin) {
      return res.status(403).json({ message: 'Unauthorized' })
    }

    const report = await reportService.resolveReport(
      user,
      id,
      status,
      resolution
    )

    if (report == null)
      return res
        .status(400)
        .json({ message: `Report with id ${id} not found.` })

    res.status(200).json(report)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const getAllReports = async (req, res) => {
  try {
    const userId = req.user
    const user = await User.findById(userId)

    const { showAll } = req.query

    const reports =
      showAll == 'true' && user.isSuperAdmin
        ? await reportService.getAllReports({
            status: { $ne: 'resolved' },
            'user._id': { $ne: userId }
          })
        : await reportService.getAllUserReports(userId)
    res.status(200).json(reports)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const getReport = async (req, res) => {
  try {
    const userId = req.user
    const { id } = req.params

    const user = await User.findById(userId)
    if (user == null) {
      return res.status(403).json({ message: 'Unauthorized' })
    }

    const report = (await reportService.getReport(id)).toJSON()
    if (report == null || (report.user._id != userId && !user.isSuperAdmin))
      res.status(400).json({ message: `Report with id ${id} not found.` })

    res.status(200).json(report)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const getUserReports = async (req, res) => {
  try {
    const user = req.user
    const reports = await reportService.getUserReports(user)
    res.status(200).json(reports)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const getEntityReports = async (req, res) => {
  try {
    const { entity_type, entity_id } = req.params
    const reports = await reportService.getEntityReports(entity_type, entity_id)
    res.status(200).json(reports)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

module.exports = {
  createReport,
  resolveReport,
  getAllReports,
  getReport,
  getUserReports,
  getEntityReports
}
