import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';
import prisma from '../prisma/client.js';

passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: process.env.GOOGLE_CALLBACK_URL,
    },
    async (_accessToken, _refreshToken, profile, done) => {
      console.log('profile recieved');
      try {
        const email = profile.emails?.[0]?.value;
        if (!email) {
          return done(new Error('No email found in Google profile'));
        }
        const user = await findOrCreateUser(email, profile.displayName);

        return done(null, user);
      } catch (err) {
        console.error('Error in GoogleStrategy:', err);
        return done(err);
      }
    }
  )
);

// user functionality extracted:
async function findOrCreateUser(email, name) {
  let user = await prisma.user.findUnique({
    where: { email: email },
  });
  if (!user) {
    user = await prisma.user.create({
      data: {
        name: name,
        email: email,
      },
    });
  }
  return user;
}

// makes sure we only keep user.id to keep session data small
// runs right after authentication
passport.serializeUser((user, done) => {
  done(null, user.id);
});

// takes id stored in the cooki and looks up user in db
// runs on every authenticated request
// ensures user is req.user for the route
passport.deserializeUser(async (id, done) => {
  try {
    const user = await prisma.user.findUnique({ where: { id } });
    done(null, user);
  } catch (err) {
    console.error('Error in deserializeUser:', err);
    done(err, null);
  }
});

// exports the passport config to the rest of the app
export default passport;
