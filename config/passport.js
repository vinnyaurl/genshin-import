const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const db = require('./db');
require('dotenv').config();

passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: process.env.GOOGLE_CALLBACK_URL,
},
    async (accessToken, refreshToken, profile, done) => {
        try {
            const email = profile.emails[0].value;
            const username = profile.displayName;

            const [rows] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);

            if (rows.length > 0) {
                return done(null, rows[0]);
            }

            await db.execute(
                'INSERT INTO users (username, email, password, role, auth_provider) VALUES (?, ?, ?, ?, ?)',
                [username, email, 'OAUTH_GOOGLE', 'user', 'Google']
            );

            const [newUser] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
            return done(null, newUser[0]);

        } catch (err) {
            return done(err, null);
        }
    }));

passport.serializeUser((user, done) => done(null, user.id));
passport.deserializeUser(async (id, done) => {
    const [rows] = await db.execute('SELECT * FROM users WHERE id = ?', [id]);
    done(null, rows[0]);
});

module.exports = passport;