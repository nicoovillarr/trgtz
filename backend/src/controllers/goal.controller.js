const goalService = require('../services/goal.service')

const createMultipleGoals = async (req, res) => {
  try {
    const { _id: user } = req.user
    const goals = req.body
    const createdGoals = await goalService.createMultipleGoals(user, goals)
    res.status(201).json(createdGoals)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error creating goals: ', error)
  }
}

const getGoals = async (req, res) => {
  try {
    const { _id } = req.user
    const goals = await goalService.getGoals(_id)
    res.status(200).json(goals)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error getting goals: ', error)
  }
}

const getSingleGoal = async (req, res) => {
  try {
    const { _id: user } = req.user
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

module.exports = {
  createMultipleGoals,
  getGoals,
  getSingleGoal
}
