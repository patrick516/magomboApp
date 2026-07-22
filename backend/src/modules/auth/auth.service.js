const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const prisma = require('../../lib/prisma');

async function login(email, password) {
  const admin = await prisma.admin.findUnique({ where: { email } });
  if (!admin) return null;

  const valid = await bcrypt.compare(password, admin.passwordHash);
  if (!valid) return null;

  const token = jwt.sign(
    { adminId: admin.id, email: admin.email },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );

  return { token, admin: { id: admin.id, email: admin.email, name: admin.name } };
}

module.exports = { login };
