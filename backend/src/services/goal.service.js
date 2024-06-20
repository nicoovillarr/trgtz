const Goal = require('../models/goal.model')
const User = require('../models/user.model')

const getGoals = async (userId) => await Goal.find({ user: userId })

const createGoal = async (user_id, title, description, year, createdOn) => {
  const goal = new Goal({
    user: user_id,
    title,
    description,
    year,
    createdOn
  })
  await goal.save()

  const user = await User.findOne({ _id: user_id })
  user.goals.push(goal)
  await user.save()
}

const getSingleGoal = async (id, user) => await Goal.findOne({ _id: id, user })

module.exports = {
  createGoal,
  getGoals,
  getSingleGoal
}
