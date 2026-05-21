const Weapon = require('../models/weaponModel');
const User = require('../models/userModel');

exports.getAllWeapons = async (req, res) => {
    try {
        const weapons = await Weapon.getAll();
        res.json(weapons);
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getWeaponById = async (req, res) => {
    try {
        const weapon = await Weapon.getById(req.params.id);
        if (!weapon) return res.status(404).json({ message: 'Weapon not found' });
        res.json(weapon);
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
};

exports.createWeapon = async (req, res) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Only admins can add weapons' });
    }

    const { name, type, description, stock, image, price } = req.body;

    if (!name || !type || !stock || !price) {
        return res.status(400).json({ message: 'Name, type, stock, and price fields are required' });
    }

    try {
        await Weapon.create(name, type, description, stock, image, price);
        res.status(201).json({ message: 'Weapon added successfully' });
    } catch (err) {
        console.log("DATABASE ERROR:", err);
        res.status(500).json({ message: 'Server error', detail: err.message });
    }
};

exports.updateWeapon = async (req, res) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Only admins can update weapons' });
    }

    const { name, type, description, stock, image, price } = req.body;

    try {
        await Weapon.update(req.params.id, name, type, description, stock, image, price);
        res.json({ message: 'Weapon updated successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
};

exports.deleteWeapon = async (req, res) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Only admins can delete weapons' });
    }

    try {
        await Weapon.delete(req.params.id);
        res.json({ message: 'Weapon deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
};

exports.buyWeapon = async (req, res) => {
    const { quantity } = req.body;

    if (!quantity || quantity <= 0) {
        return res.status(400).json({ message: 'Purchase quantity must be greater than 0' });
    }

    try {
        const weapon = await Weapon.getById(req.params.id);
        if (!weapon) return res.status(404).json({ message: 'Weapon not found' });

        if (weapon.stock < quantity) {
            return res.status(400).json({ message: 'Insufficient stock' });
        }

        const totalPrice = weapon.price * quantity;
        const user = await User.findById(req.user.id);

        if (user.balance < totalPrice) {
            return res.status(400).json({ message: 'Insufficient balance to buy this weapon' });
        }

        const newBalance = user.balance - totalPrice;
        const newStock = weapon.stock - quantity;

        await User.updateBalance(req.user.id, newBalance);
        await Weapon.updateStock(weapon.id, newStock);

        res.json({
            message: 'Purchase successful',
            weapon_bought: weapon.name,
            total_spent: totalPrice,
            remaining_balance: newBalance
        });
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
};