const goalService = require('../services/goal.service')
const alertService = require('../services/alert.service')
const pushNotificationService = require('../services/push-notification.service')

const { alertTypes } = require('../config/constants')
const Goal = require('../models/goal.model')
const User = require('../models/user.model')

const createMultipleGoals = async (req, res) => {
  try {
    const user = req.user

    const createdGoals = await goalService.createMultipleGoals(user, req.body)

    await alertService.sendAlertToFriends(user, alertTypes.goal_created)

    await pushNotificationService.sendNotificationToFriends(
      user,
      alertTypes.goal_created,
      `\$name created ${
        createdGoals.length > 1 ? 'some new goals' : 'a new goal'
      }!`
    )

    await res.status(200).json(createdGoals.map((goal) => goal.toJSON()))
  } catch (error) {
    res.status(500).json(error)
    console.error('Error creating goals: ', error)
  }
}

const createMilestone = async (req, res) => {
  try {
    const { id } = req.params

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(req.user)

    if (goal == null || !(await goalService.hasAccess(goal, user))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    await goalService.createMilestone(goal, req.body)
    res.status(200).json(goal)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const setMilestones = async (req, res) => {
  try {
    const { id } = req.params

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(req.user)

    if (goal == null || !(await goalService.hasAccess(goal, user))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    await goalService.setMilestones(goal, req.body)
    res.status(200).json(goal)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const deleteMilestone = async (req, res) => {
  try {
    const { id, milestoneId } = req.params

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(req.user)

    if (goal == null || !(await goalService.hasAccess(goal, user))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    await goalService.deleteMilestone(goal, milestoneId)
    res.status(200).json(goal)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const updateMilestone = async (req, res) => {
  try {
    const { id, milestoneId } = req.params

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(req.user)

    if (goal == null || !(await goalService.hasAccess(goal, user))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    const milestone = goal.milestones.id(milestoneId)
    if (milestone == null) {
      res
        .status(400)
        .json({ message: `Milestone with id ${milestoneId} not found.` })
      return
    }

    const isMilstoneCompleted = await goalService.updateMilestone(
      goal,
      milestone,
      req.body
    )

    if (isMilstoneCompleted) {
      await alertService.sendAlertToFriends(
        user,
        alertTypes.milestone_completed
      )
      await pushNotificationService.sendNotificationToFriends(
        user,
        alertTypes.milestone_completed,
        '$name completed a milestone!'
      )
    }

    res.status(200).json(goal)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const getGoals = async (req, res) => {
  try {
    const goals = await goalService.getGoals(req.user)
    res.status(200).json(goals)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error getting goals: ', error)
  }
}

const getSingleGoal = async (req, res) => {
  try {
    const userId = req.user
    const { id } = req.params
    const goal = await goalService.getSingleGoal(id)
    if (goal == null) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    const json = goal.toJSON()
    const user = await User.findById(userId)

    if (!(await goalService.hasAccess(json, user, false))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    Object.assign(json, {
      canEdit: json.user._id == userId,
      viewsCount:
        json.viewsCount + ((await goalService.setGoalView(id, userId)) ? 1 : 0)
    })

    res.status(200).json(json)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const updateGoal = async (req, res) => {
  try {
    const userId = req.user
    const { id } = req.params

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(userId)

    if (goal == null || !(await goalService.hasAccess(goal, user))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    if (
      Object.keys(req.body).includes('completedOn') &&
      req.body.completedOn != null &&
      goal.completedOn == null &&
      !goalService.canCompleteGoal(goal)
    ) {
      res.status(400).json({
        message: 'You cannot complete a goal without completing all milestones.'
      })
      return
    }

    const wasCompleted = goal.completedOn != null
    await goalService.updateGoal(goal, req.body)

    if (wasCompleted == false && goal.completedOn != null) {
      await alertService.sendAlertToFriends(userId, alertTypes.goal_completed)
      await pushNotificationService.sendNotificationToFriends(
        userId,
        alertTypes.goal_completed,
        `\$name completed ${goal.title}!`
      )
    }

    res.status(201).end()
  } catch (error) {
    res.status(500).json()
    console.error(error)
  }
}

const deleteGoal = async (req, res) => {
  try {
    const { id } = req.params

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(req.user)

    if (goal == null || !(await goalService.hasAccess(goal, user))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    await goalService.deleteGoal(goal)
    res.status(201).end()
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const reactToGoal = async (req, res) => {
  try {
    const userId = req.user
    const { id } = req.params
    const { reaction } = req.body

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(req.user)

    if (goal == null || !(await goalService.hasAccess(goal, user, false))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    await goalService.reactToGoal(goal, userId, reaction)

    await alertService.addAlert(userId, goal.user, alertTypes.goal_reaction)

    await pushNotificationService.sendNotificationToUser(
      goal.user,
      alertTypes.goal_reaction,
      `\$name reacted to your goal!`
    )

    res.status(201).end()
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const deleteReaction = async (req, res) => {
  try {
    const userId = req.user
    const { id } = req.params

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(req.user)

    if (goal == null || !(await goalService.hasAccess(goal, user, false))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    await goalService.deleteReaction(goal, userId)

    res.status(201).end()
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const createComment = async (req, res) => {
  try {
    const { id } = req.params
    const { text } = req.body

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(req.user)

    if (goal == null || !(await goalService.hasAccess(goal, user, false))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    if (text == null || text == '') {
      res.status(400).json({ message: 'Comment cannot be empty.' })
      return
    }

    const comment = await goalService.createComment(goal, user, text)

    await alertService.addAlert(user._id, goal.user, alertTypes.goal_comment)

    await pushNotificationService.sendNotificationToUser(
      goal.user,
      alertTypes.goal_comment,
      `\$name commented on your goal!`
    )

    res.status(200).json(comment)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const editComment = async (req, res) => {
  try {
    const { id, commentId } = req.params
    const { text } = req.body

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(req.user)

    if (goal == null || !(await goalService.hasAccess(goal, user, false))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    const comment = goal.comments.id(commentId)
    if (comment == null) {
      res
        .status(400)
        .json({ message: `Comment with id ${commentId} not found.` })
      return
    }

    if (text == null || text == '') {
      res.status(400).json({ message: 'Comment cannot be empty.' })
      return
    }

    await goalService.editComment(goal, comment, text)

    res.status(200).end()
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const deleteComment = async (req, res) => {
  try {
    const { id, commentId } = req.params

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(req.user)

    if (goal == null || !(await goalService.hasAccess(goal, user, false))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    const comment = goal.comments.id(commentId)
    if (comment == null) {
      res
        .status(400)
        .json({ message: `Comment with id ${commentId} not found.` })
      return
    }

    await goalService.deleteComment(goal, comment)

    res.status(200).json(comment)
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
}

const reactToComment = async (req, res) => {
  try {
    const { id, commentId } = req.params
    const { reaction } = req.body

    const goal = await Goal.findOne({ _id: id })
    const user = await User.findById(req.user)

    if (goal == null || !(await goalService.hasAccess(goal, user, false))) {
      res.status(400).json({ message: `Goal with id ${id} not found.` })
      return
    }

    const comment = goal.comments.id(commentId)
    if (comment == null) {
      res
        .status(400)
        .json({ message: `Comment with id ${commentId} not found.` })
      return
    }

    await goalService.reactToComment(goal, comment, user, reaction)

    res.status(200).end()
  } catch (error) {
    res.status(500).json(error)
    console.error(error)
  }
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
  editComment,
  deleteComment,
  reactToComment
}
