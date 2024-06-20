const express = require('express')
const app = express()

const goalController = require('../controllers/goal.controller')
const protect = require('../middlewares/auth.middleware')

app.post('/', protect, goalController.createGoal)
app.get('/', protect, goalController.getGoals)
app.get('/:id', protect, goalController.getSingleGoal)

module.exports = app
