const express = require('express')
const app = express()

const goalController = require('../controllers/goal.controller')
const protect = require('../middlewares/auth.middleware')

app.post('/', protect, goalController.createMultipleGoals)
app.get('/', protect, goalController.getGoals)
app.get('/:id', protect, goalController.getSingleGoal)
app.put('/:id', protect, goalController.updateGoal)
app.delete('/:id', protect, goalController.deleteGoal)

module.exports = app
