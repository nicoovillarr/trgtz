const goalService = require('../services/goal.service')

const createGoal = async (req, res) => {
  try {
    const { title, description, year, createdOn } = req.body
    const goal = await goalService.createGoal(
      title,
      description,
      year,
      createdOn
    )
    res.status(201).json(goal)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error creating goal: ', error)
  }
}

const getGoals = async (req, res) => {
  try {
    const goals = await goalService.getGoals()
    res.status(200).json(goals)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error getting goals: ', error)
  }
}

const getSingleGoal = async (req, res) => {
  try {
    const { id } = req.params
    const goal = await goalService.getSingleGoal(id)
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
