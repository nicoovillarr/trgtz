const express = require('express')
const app = express()

const goalController = require('../controllers/goal.controller')

app.post('/', goalController.createGoal)
app.get('/', goalController.getGoals)
app.get('/:id', goalController.getSingleGoal)

module.exports = app
