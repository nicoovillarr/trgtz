const reportService = require('../services/report.service')

const createReport = async (req, res) => {
  try {
    const user = req.user
    const {
      entityType: entity_type,
      entityId: entity_id,
      category,
      reason
    } = req.body
    const report = await reportService.createReport(
      user,
      entity_type,
      entity_id,
      category,
      reason
    )
    if (report == null) {
      res
        .status(400)
        .json({ message: `Entity with id ${entity_id} not found.` })
      return
    }

    res.status(200).json(report)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const resolveReport = async (req, res) => {
  try {
    const user = req.user
    const { id } = req.params
    const { status, resolution } = req.body
    const report = await reportService.resolveReport(
      user,
      id,
      status,
      resolution
    )
    if (report == null)
      res.status(400).json({ message: `Report with id ${id} not found.` })

    res.status(200).json(report)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const getAllReports = async (req, res) => {
  try {
    const user = req.user
    const reports = await reportService.getAllUserReports(user)
    res.status(200).json(reports)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const getReport = async (req, res) => {
  try {
    const { id } = req.params
    const report = await reportService.getReport(id)
    if (report == null)
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
