const authService = require('./auth.service');

async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'email and password are required' });
    }
    const result = await authService.login(email, password);
    if (!result) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }
    res.json({ success: true, data: result });
  } catch (err) { next(err); }
}

module.exports = { login };
