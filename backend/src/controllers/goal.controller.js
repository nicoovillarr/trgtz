const goalService = require('../services/goal.service')

const createGoal = async (req, res) => {
  try {
    const { _id: user } = req.user
    const { title, description, year } = req.body
    const goal = await goalService.createGoal(user, title, description, year)
    res.status(201).json(goal)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error creating goal: ', error)
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
  createGoal,
  getGoals,
  getSingleGoal
}
