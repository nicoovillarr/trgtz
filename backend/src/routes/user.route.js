const express = require('express')
const app = express()

const userController = require('../controllers/user.controller')
const protect = require('../middlewares/auth.middleware')

/**
 * Express router for users.
 * @module routes/user
 */

/**
 * Route for getting the current user.
 * @name GET /users
 * @function
 * @memberof module:routes/user
 * @param {string} path - Express route path
 * @param {function} middleware - Middleware function for authentication
 * @param {function} controller - Controller function for getting the current user
 */

/**
 * @swagger
 * /users:
 *   get:
 *     summary: Get current user
 *     tags: [Users]
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Success
 *       500:
 *         description: Internal Server Error
 */
app.get('/', protect, userController.getMe)

/**
 * Route for updating a user.
 * @name PATCH /users/:id
 * @function
 * @memberof module:routes/user
 * @param {string} path - Express route path
 * @param {function} controller - Controller function for updating a user
 */

/**
 * @swagger
 * /users/{id}:
 *   patch:
 *     summary: Update a user
 *     tags: [Users]
 *     parameters:
 *       - name: id
 *         in: path
 *         description: User ID
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Success
 *       500:
 *         description: Internal Server Error
 */
app.patch('/:id', userController.patchUser)

module.exports = app
