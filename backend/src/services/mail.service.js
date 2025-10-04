const { Resend } = require('resend')

const resend = new Resend(process.env.NO_REPLY_RESEND_API_KEY)

const sendNoReplyEmail = async (to, subject, text, html) => {
  try {
    await resend.emails.send({
      from: `"No Reply" <${process.env.NO_REPLY_EMAIL_ADDRESS}>`,
      to,
      subject,
      text,
      html
    })
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
