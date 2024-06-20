const Goal = require('../models/goal.model')

const getGoals = async () => await Goal.find()

const createGoal = async (title, description, year, createdOn) =>
  await Goal.create({
    title,
    description,
    year,
    createdOn
  })

const getSingleGoal = async (id) => await Goal.findById(id)

module.exports = {
  createGoal,
  getGoals,
  getSingleGoal
}
