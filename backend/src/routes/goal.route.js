const express = require('express')
const app = express()

const goalController = require('../controllers/goal.controller')
const protect = require('../middlewares/auth.middleware')

app.post('/', protect, goalController.createMultipleGoals)
app.get('/', protect, goalController.getGoals)
app.post('/:id/milestones', protect, goalController.createMilestone)
app.put('/:id/milestones', protect, goalController.setMilestones)
app.put('/:id/milestones/:milestoneId', protect, goalController.updateMilestone)
app.delete(
  '/:id/milestones/:milestoneId',
  protect,
  goalController.deleteMilestone
)
app.get('/:id', protect, goalController.getSingleGoal)
app.put('/:id', protect, goalController.updateGoal)
app.delete('/:id', protect, goalController.deleteGoal)

module.exports = app
