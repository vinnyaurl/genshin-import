const db = require('../config/db');

const Weapon = {
    getAll: async () => {
        const [rows] = await db.execute('SELECT * FROM weapons');
        return rows;
    },

    getById: async (id) => {
        const [rows] = await db.execute('SELECT * FROM weapons WHERE id = ?', [id]);
        return rows[0];
    },

    create: async (name, type, description, stock, image, price) => {
        return await db.execute(
            'INSERT INTO weapons (name, type, description, stock, image, price) VALUES (?, ?, ?, ?, ?, ?)',
            [name, type, description, stock, image, price]
        );
    },

    update: async (id, name, type, description, stock, image, price) => {
        return await db.execute(
            'UPDATE weapons SET name=?, type=?, description=?, stock=?, image=?, price=? WHERE id=?',
            [name, type, description, stock, image, price, id]
        );
    },

    delete: async (id) => {
        return await db.execute('DELETE FROM weapons WHERE id = ?', [id]);
    },

    updateStock: async (id, newStock) => {
        return await db.execute('UPDATE weapons SET stock = ? WHERE id = ?', [newStock, id]);
    }
};

module.exports = Weapon;