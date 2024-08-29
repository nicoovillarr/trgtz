const Goal = require('../models/goal.model')
const User = require('../models/user.model')
const { viewGoal } = require('../config/views')
const { sendGoalChannelMessage } = require('../config/websocket')

const getGoals = async (userId, year) =>
  await Goal.find({
    user: userId,
    year: year != null ? year : { $ne: null },
    deletedOn: { $eq: null }
  })

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

const createMilestone = async (id, user, milestone) => {
  const goal = await Goal.findOne({ _id: id, user })
  if (goal == null) return null

  goal.milestones.push({
    title: milestone.title,
    createdOn: new Date()
  })

  goal.events.push({
    type: 'milestone_created',
    createdOn: new Date()
  })

  await goal.save()

  const newMilestone = goal.milestones[goal.milestones.length - 1]
  return newMilestone
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

  await goal.save()

  sendGoalChannelMessage(
    id,
    'GOAL_SET_MILESTONES',
    goal.milestones.map((milestone) => milestone.toJSON())
  )

  return goal
}

const getSingleGoal = async (id) => await viewGoal.findOne({ _id: id })

const canCompleteGoal = (goal) =>
  goal.completedOn == null &&
  (goal.milestones.length == 0 ||
    goal.milestones.every((m) => m.completedOn != null))

const updateGoal = async (goal, data) => {
  const eventType =
    Object.keys(data).includes('completedOn') &&
    data.completedOn != null &&
    goal.completedOn == null
      ? 'goal_completed'
      : 'goal_updated'

  const editableFields = ['title', 'description', 'year', 'completedOn']
  for (const key of Object.keys(data).filter((t) =>
    editableFields.includes(t)
  )) {
    goal[key] = data[key]
  }

  goal.events.push({
    type: eventType,
    createdOn: new Date()
  })

  await goal.save()
  sendGoalChannelMessage(
    goal._id,
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
    year,
    events: [{ type: 'goal_created', createdOn: new Date() }]
  })
  await goal.save()
  return goal
}

const getMilestone = async (id, milestoneId) => {
  const goal = await Goal.findOne({ _id: id })
  if (goal == null) return null
  return goal.milestones.id(milestoneId)
}

const reactToGoal = async (id, user, type) => {
  const goal = await Goal.findOne({ _id: id })
  if (goal == null) return null

  const reactionIndex = goal.reactions.findIndex(
    (r) => r.user.toString() == user.toString()
  )

  if (reactionIndex === -1) {
    goal.reactions.push({ user, type })
  } else {
    goal.reactions[reactionIndex].type = type
  }

  await goal.save()

  sendGoalChannelMessage(id, 'GOAL_REACTED', { user, type })

  return goal
}

const deleteReaction = async (id, user) => {
  const goal = await Goal.findOne({ _id: id })
  if (goal == null) return null

  goal.reactions = goal.reactions.filter(
    (reaction) => reaction.user.toString() != user.toString()
  )

  await goal.save()
  return goal
}

const createComment = async (id, user, text) => {
  const goal = await Goal.findOne({ _id: id })
  if (goal == null) return null

  goal.comments.push({
    user,
    text,
    createdOn: new Date()
  })

  await goal.save()
  return goal
}

const setGoalView = async (id, user) => {
  const goal = await Goal.findOne({ _id: id })
  if (goal == null) return false

  const cache = require('../config/cache')
  const key = `goal:${id}:views:${user}`

  if (cache.get(key) != null) return false

  goal.views.push({ user, viewedOn: new Date() })
  await goal.save()

  cache.set(key, true)
  return true
}

module.exports = {
  createMultipleGoals,
  createMilestone,
  setMilestones,
  deleteMilestone,
  updateMilestone,
  getGoals,
  getSingleGoal,
  updateGoal,
  deleteGoal,
  getMilestone,
  reactToGoal,
  deleteReaction,
  createComment,
  setGoalView,
  canCompleteGoal
}
