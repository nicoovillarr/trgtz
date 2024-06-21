const express = require('express')
const app = express()

const goalController = require('../controllers/goal.controller')
const protect = require('../middlewares/auth.middleware')

/**
 * Express router for goals.
 * @module routes/goal
 */

/**
 * Route for creating a new goal.
 * @name POST /goals
 * @function
 * @memberof module:routes/goal
 * @param {string} path - Express route path
 * @param {function} middleware - Middleware function for authentication
 * @param {function} controller - Controller function for creating a goal
 */

/**
 * @swagger
 * /goals:
 *   post:
 *     summary: Create a new goal
 *     tags: [Goals]
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 format: text
 *               description:
 *                 type: string
 *                 format: text
 *               year:
 *                 type: number
 *                 format: integer
 *                 default: 2024
 *     responses:
 *       200:
 *         description: Success
 *       500:
 *         description: Internal Server Error
 */
app.post('/', protect, goalController.createGoal)

/**
 * Route for getting all goals.
 * @name GET /goals
 * @function
 * @memberof module:routes/goal
 * @param {string} path - Express route path
 * @param {function} middleware - Middleware function for authentication
 * @param {function} controller - Controller function for getting all goals
 */

/**
 * @swagger
 * /goals:
 *   get:
 *     summary: Get all goals
 *     tags: [Goals]
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Success
 *       500:
 *         description: Internal Server Error
 */
app.get('/', protect, goalController.getGoals)

/**
 * Route for getting a single goal by ID.
 * @name GET /goals/:id
 * @function
 * @memberof module:routes/goal
 * @param {string} path - Express route path
 * @param {function} middleware - Middleware function for authentication
 * @param {function} controller - Controller function for getting a single goal
 */

/**
 * @swagger
 * /goals/{id}:
 *   get:
 *     summary: Get a single goal by ID
 *     tags: [Goals]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the goal
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Success
 *       500:
 *         description: Internal Server Error
 */
app.get('/:id', protect, goalController.getSingleGoal)

module.exports = app
