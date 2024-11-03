const alertService = require('../services/alert.service');
const { alertTypes } = require('../config/constants');

const getAlertTypes = async (req, res) => {
  res.status(200).json(alertTypes);
}

module.exports = {
  getAlertTypes
}