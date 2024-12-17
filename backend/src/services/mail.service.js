const { createTransport } = require('nodemailer')

const transporter = createTransport({
  host: 'smtp.hostinger.com',
  secure: true,
  secureConnection: false,
  tls: {
    ciphers: 'SSLv3'
  },
  requireTLS: true,
  port: 465,
  connectionTimeout: 10000,
  auth: {
    user: process.env.NO_REPLY_EMAIL_ADDRESS,
    pass: process.env.NO_REPLY_EMAIL_PASSWORD
  }
})

const sendNoReplyEmail = async (to, subject, text, html) => {
  const mailOptions = {
    from: `"No Reply" <${process.env.NO_REPLY_EMAIL_ADDRESS}>`,
    to,
    subject,
    text,
    html
  }

  try {
    await transporter.sendMail(mailOptions)
    return true
  } catch (e) {
    console.error(`There was an error sending the email: ${e}`)
    return false
  }
}

const sendReportEmail = async (admins, report) => {
  const subject = `Report ${report.status}`
  const text = `Report ${report.status} for ${report.entity_type} with id ${report.entity_id}`
  const html = `<p>Report ${report.status} for ${report.entity_type} with id ${report.entity_id}</p><p>Category: ${report.category}</p><p>Reason: ${report.reason}</p><p>Report ID: ${report._id}</p>`

  return await sendNoReplyEmail(admins.join(','), subject, text, html)
}

module.exports = {
  sendNoReplyEmail,
  sendReportEmail
}
