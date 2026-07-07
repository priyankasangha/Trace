import appleSigninAuth from 'apple-signin-auth';
import * as userService from '../services/userService.js';

export async function protectWithApple(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Authorization token required' });
    }

    const identityToken = authHeader.split(' ')[1];

    const appleUser = await appleSigninAuth.verifyIdToken(identityToken, {
      audience: 'com.priyankasangha.Trace',
    });

    const user = await userService.findOrCreateAppleUser({
      email: appleUser.email,
      name: appleUser.name
    });

    req.user = user;
    next();
  } catch (error) {
    console.error('Apple Auth Error:', error);
    return res.status(401).json({ error: 'Invalid or expired identity token' });
  }
}