const nodemailer = require('nodemailer')

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.PERSONAL_EMAIL_ADDRESS,
    pass: process.env.PERSONAL_EMAIL_PASSWORD
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

module.exports = {
  sendNoReplyEmail
}