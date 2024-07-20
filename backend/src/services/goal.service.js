const Goal = require('../models/goal.model')
const User = require('../models/user.model')
const { sendGoalChannelMessage } = require('../config/websocket')

const getGoals = async (userId) => await Goal.find({ user: userId })

const createMultipleGoals = async (user_id, goals) => {
  const createdGoals = []
  for (const goal of goals) {
    const { title, description, year } = goal
    createdGoals.push(await createGoal(user_id, title, description, year))
  }

  const user = await User.findOne({ _id: user_id })
  user.goals.push(...createdGoals.map((goal) => goal._id))
  await user.save()
  return createdGoals
}

const setMilestones = async (id, user, milestones) => {
  const goal = await Goal.findOne({ _id: id, user })
  if (goal == null) return null

  goal.milestones = []
  for (const milestone of milestones) {
    const { title, completedOn } = milestone
    goal.milestones.push({ title, completedOn })
  }
  if (
    goal.milestones.length > 0 &&
    goal.milestones.filter((milestone) => !milestone.completedOn).length === 0
  ) {
    goal.completedOn = new Date()
  }
  await goal.save()

  sendGoalChannelMessage(
    id,
    'GOAL_SET_MILESTONES',
    goal.milestones.map((milestone) => milestone.toJSON())
  )

  return goal
}

const deleteMilestone = async (id, user, milestoneId) => {
  const goal = await Goal.findOne({ _id: id, user })
  if (goal == null) return null

  const milestone = goal.milestones.id(milestoneId)
  if (milestone == null) return null

  goal.milestones = goal.milestones.filter(
    (milestone) => milestone._id != milestoneId
  )
  await goal.save()

  sendGoalChannelMessage(
    id,
    'GOAL_SET_MILESTONES',
    goal.milestones.map((milestone) => milestone.toJSON())
  )

  return goal
}

const updateMilestone = async (id, user, milestoneId, data) => {
  const goal = await Goal.findOne({ _id: id, user })
  if (goal == null) return null

  const milestone = goal.milestones.id(milestoneId)
  if (milestone == null) return null

  const { title, completedOn } = data
  milestone.title = title
  milestone.completedOn = completedOn

  goal.completedOn =
    goal.milestones.some((milestone) => !milestone.completedOn) === false
      ? new Date()
      : null

  await goal.save()

  sendGoalChannelMessage(
    id,
    'GOAL_SET_MILESTONES',
    goal.milestones.map((milestone) => milestone.toJSON())
  )

  return goal
}

const getSingleGoal = async (id, user) => await Goal.findOne({ _id: id, user })

const updateGoal = async (id, user, data) => {
  const goal = await Goal.findOne({ _id: id, user })
  if (goal == null) return null

  const editableFields = ['title', 'description', 'year', 'completedOn']
  for (const key of Object.keys(data).filter((t) =>
    editableFields.includes(t)
  )) {
    goal[key] = data[key]
  }

  await goal.save()
  sendGoalChannelMessage(
    id,
    'GOAL_UPDATED',
    Object.keys(data)
      .filter((t) => editableFields.includes(t))
      .reduce((acc, curr) => ({ ...acc, [curr]: data[curr] }), {})
  )
  return goal
}

const deleteGoal = async (id, user) => {
  const goal = await Goal.findOne({ _id: id, user })
  if (goal == null) return null
  goal.deletedOn = new Date()
  await goal.save()

  sendGoalChannelMessage(id, 'GOAL_DELETED', null)

  return goal
}

const createGoal = async (user_id, title, description, year) => {
  const goal = new Goal({
    user: user_id,
    title,
    description,
    year
  })
  await goal.save()
  return goal
}

const getMilestone = async (id, milestoneId) => {
  const goal = await Goal.findOne({ _id: id })
  if (goal == null) return null
  return goal.milestones.id(milestoneId)
}

module.exports = {
  createMultipleGoals,
  setMilestones,
  deleteMilestone,
  updateMilestone,
  getGoals,
  getSingleGoal,
  updateGoal,
  deleteGoal,
  getMilestone
}
