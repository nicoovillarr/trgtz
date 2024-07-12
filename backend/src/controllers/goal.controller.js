const goalService = require('../services/goal.service')
const alertService = require('../services/alert.service')

const createMultipleGoals = async (req, res) => {
  try {
    const user = req.user
    const goals = req.body
    const createdGoals = await goalService.createMultipleGoals(user, goals)
    await alertService.sendAlertToFriends(user, 'goal_created')
    res.status(200).json(createdGoals.map((goal) => goal.toJSON()))
  } catch (error) {
    res.status(500).json(error)
    console.error('Error creating goals: ', error)
  }
}

const setMilestones = async (req, res) => {
  try {
    const user = req.user
    const { id } = req.params
    const goal = await goalService.setMilestones(id, user, req.body)
    if (goal == null)
      res.status(400).json({ message: `Goal with id ${id} not found.` })
    else res.status(200).json(goal)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const deleteMilestone = async (req, res) => {
  try {
    const user = req.user
    const { id, milestoneId } = req.params
    const goal = await goalService.deleteMilestone(id, user, milestoneId)
    if (goal == null)
      res.status(400).json({ message: `Goal with id ${id} not found.` })
    else res.status(200).json(goal)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const updateMilestone = async (req, res) => {
  try {
    const user = req.user
    const { id, milestoneId } = req.params
    const wasGoalCompleted =
      (await goalService.getSingleGoal(id, user).completedOn) != null
    const wasMilestoneCompleted =
      (await goalService.getMilestone(id, milestoneId).completedOn) != null
    const goal = await goalService.updateMilestone(
      id,
      user,
      milestoneId,
      req.body
    )
    if (goal == null)
      res.status(400).json({ message: `Goal with id ${id} not found.` })
    else {
      if (
        wasMilestoneCompleted == false &&
        goal.milestones.find((m) => m._id == milestoneId).completedOn != null
      ) {
        await alertService.sendAlertToFriends(user, 'milestone_completed')
      }

      if (wasGoalCompleted == false && goal.completedOn != null) {
        await alertService.sendAlertToFriends(user, 'goal_completed')
      }

      res.status(200).json(goal)
    }
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const getGoals = async (req, res) => {
  try {
    const user = req.user
    const goals = await goalService.getGoals(user)
    res.status(200).json(goals)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error getting goals: ', error)
  }
}

const getSingleGoal = async (req, res) => {
  try {
    const user = req.user
    const { id } = req.params
    const goal = await goalService.getSingleGoal(id, user)
    if (goal == null)
      res.status(400).json({ message: `Goal with id ${id} not found.` })
    else res.status(200).json(goal)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const updateGoal = async (req, res) => {
  try {
    const user = req.user
    const { id } = req.params
    const wasCompleted =
      (await goalService.getSingleGoal(id, user).completedOn) != null
    const goal = await goalService.updateGoal(id, user, req.body)
    if (goal == null)
      res.status(400).json({ message: `Goal with id ${id} not found.` })
    else {
      if (wasCompleted == false && goal.completedOn != null) {
        await alertService.sendAlertToFriends(user, 'goal_completed')
      }
      res.status(200).json(goal)
    }
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const deleteGoal = async (req, res) => {
  try {
    const user = req.user
    const { id } = req.params
    const goal = await goalService.deleteGoal(id, user)
    if (goal == null)
      res.status(400).json({ message: `Goal with id ${id} not found.` })
    else res.status(204).json(goal)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

module.exports = {
  createMultipleGoals,
  setMilestones,
  deleteMilestone,
  updateMilestone,
  getGoals,
  getSingleGoal,
  updateGoal,
  deleteGoal
}
