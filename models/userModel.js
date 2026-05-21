const db = require('../config/db');

const User = {
    findByEmail: async (email) => {
        const [rows] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        return rows[0];
    },

    findById: async (id) => {
        const [rows] = await db.execute(
            'SELECT id, username, email, role, balance, auth_provider FROM users WHERE id = ?',
            [id]
        );
        return rows[0];
    },

    create: async (username, email, hashedPassword) => {
        return await db.execute(
            'INSERT INTO users (username, email, password) VALUES (?, ?, ?)',
            [username, email, hashedPassword]
        );
    },

    updateBalance: async (id, newBalance) => {
        return await db.execute('UPDATE users SET balance = ? WHERE id = ?', [newBalance, id]);
    }
};

module.exports = User;