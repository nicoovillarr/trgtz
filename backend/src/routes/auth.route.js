const express = require('express')
const app = express()

const authController = require('../controllers/auth.controller')

/**
 * Express router for goals.
 * @module routes/auth
 */

/**
 * Route for creating a new user.
 * @name POST /auth/signup
 * @function
 * @memberof module:routes/auth
 * @param {string} path - Express route path
 * @param {function} controller - Controller function for creating a new user
 */

/**
 * @swagger
 * /auth/signup:
 *   post:
 *     summary: Register user
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               firstName:
 *                 type: string
 *                 format: email
 *               email:
 *                 type: string
 *                 format: email
 *               password:
 *                 type: string
 *                 format: password
 *     responses:
 *       200:
 *         description: Success
 *       400:
 *         description: Email already in use
 */
app.post('/signup', authController.signup)

/**
 * Route for creating a new user.
 * @name POST /auth/login
 * @function
 * @memberof module:routes/auth
 * @param {string} path - Express route path
 * @param {function} controller - Controller function for authenticating a user
 */

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Authenticate user
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               password:
 *                 type: string
 *                 format: password
 *     responses:
 *       200:
 *         description: Success
 *       401:
 *         description: Invalid credentials
 */
app.post('/login', authController.login)

module.exports = app
