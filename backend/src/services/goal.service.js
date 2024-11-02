const Goal = require('../models/goal.model')
const User = require('../models/user.model')
const userService = require('./user.service')
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

const createMilestone = async (goal, milestone) => {
  goal.milestones.push({
    title: milestone.title,
    createdOn: new Date()
  })

  goal.events.push({
    type: 'milestone_created',
    createdOn: new Date()
  })

  await goal.save()

  sendGoalChannelMessage(
    goal._id,
    'GOAL_CREATE_MILESTONE',
    goal.milestones[goal.milestones.length - 1]
  )
}

const setMilestones = async (goal, milestones) => {
  goal.milestones = milestones.map((milestone) => ({
    title: milestone.title,
    completedOn: milestone.completedOn
  }))

  await goal.save()

  sendGoalChannelMessage(
    goal._id,
    'GOAL_SET_MILESTONES',
    goal.milestones.map((milestone) => milestone.toJSON())
  )
}

const deleteMilestone = async (goal, milestoneId) => {
  goal.milestones = goal.milestones.filter(
    (milestone) => milestone._id != milestoneId
  )

  await goal.save()

  sendGoalChannelMessage(goal._id, 'GOAL_DELETE_MILESTONE', milestoneId)
}

const updateMilestone = async (goal, milestone, data) => {
  const { title, completedOn } = data
  milestone.title = title
  milestone.completedOn = completedOn

  let isMilstoneCompleted = false
  if (milestone.completedOn == null && completedOn != null) {
    goal.events.push({
      type: 'milestone_completed',
      createdOn: new Date()
    })

    isMilstoneCompleted = true
  }

  await goal.save()

  sendGoalChannelMessage(goal._id, 'GOAL_UPDATE_MILESTONE', milestone)

  return isMilstoneCompleted
}

const getSingleGoal = async (id) => await viewGoal.findById(id)

const canCompleteGoal = (goal) =>
  goal.completedOn == null &&
  (goal.milestones.length == 0 ||
    goal.milestones.every((m) => m.completedOn != null))

const updateGoal = async (goal, data) => {
  const fields = Object.keys(data).filter((t) =>
    ['title', 'description', 'year', 'completedOn'].includes(t)
  )

  for (const key of fields) {
    goal[key] = data[key]
  }

  if (
    fields.contains('completedOn') &&
    data.completedOn != null &&
    goal.completedOn == null
  ) {
    if (fields.length > 1) {
      goal.events.push({
        type: 'goal_updated',
        createdOn: new Date()
      })
    }

    goal.events.push({
      type: 'goal_completed',
      createdOn: new Date()
    })
  } else {
    goal.events.push({
      type: 'goal_updated',
      createdOn: new Date()
    })
  }

  await goal.save()

  sendGoalChannelMessage(
    goal._id,
    'GOAL_UPDATED',
    fields.reduce((acc, curr) => ({ ...acc, [curr]: data[curr] }), {})
  )

  sendGoalChannelMessage(
    goal._id,
    'GOAL_EVENT_ADDED',
    goal.events[goal.events.length - 1].toJSON()
  )
}

const deleteGoal = async (goal) => {
  goal.deletedOn = new Date()
  await goal.save()

  sendGoalChannelMessage(goal._id, 'GOAL_DELETED', goal._id)
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

const reactToGoal = async (goal, userId, type) => {
  const reactionIndex = goal.reactions.findIndex(
    (r) => r.user.toString() == userId.toString()
  )

  let reactionToDelete = null
  if (reactionIndex !== -1) {
    reactionToDelete = goal.reactions[reactionIndex]
    goal.reactions = goal.reactions.filter(
      (r) => r.user.toString() != userId.toString()
    )
  }

  if (reactionToDelete == null || reactionToDelete.type != type) {
    goal.reactions.push({ user: userId, type, createdOn: new Date() })
  }

  await goal.save()

  if (reactionToDelete != null) {
    sendGoalChannelMessage(goal._id, 'GOAL_REACT_DELETED', userId)
    if (reactionToDelete.type == type) {
      return goal
    }
  }

  const { firstName, email, createdAt, avatar } = (
    await userService.getUserInfo(userId)
  ).toJSON()
  const reaction = Object.assign(
    {},
    goal.reactions.find((r) => r.user.toString() == userId.toString()).toJSON(),
    {
      user: {
        _id: userId,
        firstName,
        email,
        createdAt,
        avatar
      }
    }
  )
  sendGoalChannelMessage(goal._id, 'GOAL_REACTED', reaction)
}

const deleteReaction = async (goal, userId) => {
  goal.reactions = goal.reactions.filter(
    (reaction) => reaction.user.toString() != userId.toString()
  )

  await goal.save()

  sendGoalChannelMessage(goal._id, 'GOAL_REACT_DELETED', userId)
}

const createComment = async (goal, user, text) => {
  goal.comments.push({
    user: user._id,
    text,
    createdOn: new Date()
  })

  await goal.save()

  const comment = Object.assign(
    {},
    goal.comments[goal.comments.length - 1].toJSON(),
    {
      user: (
        await User.aggregate([
          { $match: { _id: user._id } },
          {
            $lookup: {
              from: 'images',
              localField: 'avatar',
              foreignField: '_id',
              as: 'avatar'
            }
          },
          {
            $unwind: {
              path: '$avatar',
              preserveNullAndEmptyArrays: true
            }
          },
          {
            $project: {
              _id: 1,
              firstName: 1,
              email: 1,
              createdAt: 1,
              avatar: {
                _id: 1,
                url: 1,
                createdOn: 1
              }
            }
          }
        ])
      )[0]
    }
  )
  sendGoalChannelMessage(goal._id, 'GOAL_COMMENT_CREATED', comment)

  return comment
}

const setGoalView = async (goalId, user) => {
  const goal = await Goal.findById(goalId)
  if (goal == null) return false

  const cache = require('../config/cache')
  const key = `goal:${goal._id}:views:${user}`

  if (cache.get(key) != null) return false

  goal.views.push({ user, viewedOn: new Date() })
  await goal.save()

  cache.set(key, true)
  return true
}

const editComment = async (goal, comment, text) => {
  comment.editions.push({
    oldText: comment.text,
    editedOn: new Date()
  })
  comment.text = text
  await goal.save()

  sendGoalChannelMessage(goal._id, 'GOAL_COMMENT_UPDATED', {
    _id: comment._id,
    text
  })
}

const deleteComment = async (goal, comment) => {
  comment.deletedOn = new Date()

  await goal.save()

  sendGoalChannelMessage(goal._id, 'GOAL_COMMENT_DELETED', comment._id)
}

const reactToComment = async (goal, comment, user, type) => {
  const reactionIndex = comment.reactions.findIndex((r) => r.user == user._id)

  let reactionToDelete = null
  if (reactionIndex !== -1) {
    reactionToDelete = comment.reactions[reactionIndex]
    comment.reactions = comment.reactions.filter(
      (r) => r.user != user._id
    )
  }

  if (reactionToDelete == null || reactionToDelete.type != type) {
    comment.reactions.push({ user: user._id, type, createdOn: new Date() })
  }

  await goal.save()

  if (reactionToDelete != null) {
    sendGoalChannelMessage(goal._id, 'GOAL_COMMENT_REACT_DELETED', {
      commentId: comment._id,
      user: user._id
    })
    if (reactionToDelete.type == type) {
      return
    }
  }

  const { firstName, email, createdAt, avatar } = (
    await userService.getUserInfo(user._id)
  ).toJSON()
  const reaction = Object.assign(
    {},
    {
      commentId: comment._id
    },
    comment.reactions.find((r) => r.user == user._id).toJSON(),
    {
      user: {
        _id: user._id,
        firstName,
        email,
        createdAt,
        avatar
      }
    }
  )

  sendGoalChannelMessage(goal._id, 'GOAL_COMMENT_REACTED', reaction)
}

const hasAccess = async (goal, me, ownerOnly = true) => {
  const goalCreator = typeof goal.user === 'object' ? goal.user._id : goal.user
  return (
    goalCreator != null &&
    (goalCreator == me._id ||
      (!ownerOnly && (await userService.hasAccess(me._id, goalCreator))))
  )
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
  reactToGoal,
  deleteReaction,
  createComment,
  setGoalView,
  canCompleteGoal,
  editComment,
  deleteComment,
  reactToComment,
  hasAccess
}
