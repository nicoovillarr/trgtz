const express = require('express')
const router = express()

/**
 * @swagger
 * components:
 *   securitySchemes:
 *     BearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 * security:
 *   BearerAuth: []
 */

/**
 * @swagger
 * tags:
 *   name: Goals
 *   description: API endpoints for managing goals
 */

router.use('/goals', require('./goal.route'))

/**
 * @swagger
 * tags:
 *   name: Authentication
 *   description: API endpoints for user authentication
 */

router.use('/auth', require('./auth.route'))

/**
 * @swagger
 * tags:
 *   name: Users
 *   description: API endpoints for managing users
 */

router.use('/users', require('./user.route'))

module.exports = router
