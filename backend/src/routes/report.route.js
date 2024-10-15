const reportController = require('../controllers/report.controller')

const express = require('express')

const app = express()

const { protect } = require('../middlewares/auth.middleware')

app.post('/', protect, reportController.createReport)
app.put('/:id', protect, reportController.resolveReport)
app.get('/', protect, reportController.getAllReports)
app.get('/:id', protect, reportController.getReport)
app.get('/user', protect, reportController.getUserReports)
app.get('/:entity_type/:entity_id', protect, reportController.getEntityReports)

module.exports = app
