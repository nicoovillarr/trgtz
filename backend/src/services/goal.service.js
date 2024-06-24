const Goal = require('../models/goal.model')
const User = require('../models/user.model')

const getGoals = async (userId) => await Goal.find({ user: userId })

const createMultipleGoals = async (user_id, goals) => {
  const createdGoals = []
  for (const goal of goals) {
    const { title, description, year, createdOn } = goal
    createdGoals.push(
      await createGoal(user_id, title, description, year, createdOn)
    )
  }

  const user = await User.findOne({ _id: user_id })
  user.goals.push(...createdGoals.map((goal) => goal._id))
  await user.save()
  return createdGoals
}

const createGoal = async (user_id, title, description, year, createdOn) => {
  const goal = new Goal({
    user: user_id,
    title,
    description,
    year,
    createdOn
  })
  await goal.save()
  return goal
}

const getSingleGoal = async (id, user) => await Goal.findOne({ _id: id, user })

const updateGoal = async (id, user, data) => {
  const goal = await Goal.findOne({ _id: id, user })
  if (goal == null) return null

  const { title, description, year, completedOn } = data
  goal.title = title
  goal.description = description
  goal.year = year
  goal.completedOn = completedOn
  await goal.save()
  return goal
}

const deleteGoal = async (id, user_id) => {
  const goal = await Goal.findOne
  if (goal == null) return null
  await goal.remove()

  const user = await User.findOne({ _id: user_id })
  user.goals = user.goals.filter((goal) => goal._id != id)
  await user.save()

  return goal
}

module.exports = {
  createMultipleGoals,
  createGoal,
  getGoals,
  getSingleGoal,
  updateGoal,
  deleteGoal
}
