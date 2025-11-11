const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || "smtp.ethereal.email",
  port: Number(process.env.SMTP_PORT) || 587,
  secure: Number(process.env.SMTP_PORT) === 465,
  auth: {
    user: process.env.SMTP_USER || "",
    pass: process.env.SMTP_PASS || ""
  }
});

// sendMail(to, subject, html)
async function sendMail(to, subject, html) {
  // If SMTP not configured, attempt Ethereal test account for dev
  if ((!process.env.SMTP_USER || !process.env.SMTP_PASS) && !process.env.SMTP_DISABLED) {
    try {
      const test = await nodemailer.createTestAccount();
      transporter.options.host = "smtp.ethereal.email";
      transporter.options.port = 587;
      transporter.options.secure = false;
      transporter.options.auth = { user: test.user, pass: test.pass };
    } catch (e) {
      console.error("Could not create ethereal account:", e);
    }
  }

  const info = await transporter.sendMail({
    from: process.env.FROM_EMAIL || "ChronoCare <noreply@chronocare.local>",
    to,
    subject,
    html
  });

  // For dev: return preview URL if using Ethereal
  const preview = nodemailer.getTestMessageUrl(info);
  return { info, preview };
}

module.exports = { sendMail };
