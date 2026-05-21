const express = require('express');
const router = express.Router();
const passport = require('passport');
const jwt = require('jsonwebtoken');
const authController = require('../controllers/authController');
const verifyToken = require('../middleware/auth');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/profile', verifyToken, authController.getProfile);

router.get('/google', passport.authenticate('google', { scope: ['profile', 'email'] }));

router.get('/google/callback',
    passport.authenticate('google', { session: false, failureRedirect: '/auth/login' }),
    (req, res) => {
        const token = jwt.sign(
            { id: req.user.id, role: req.user.role },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        res.json({
            message: 'Login via Google berhasil',
            token,
            user: {
                id: req.user.id,
                username: req.user.username,
                role: req.user.role,
                auth_provider: req.user.auth_provider
            }
        });
    }
);

module.exports = router;