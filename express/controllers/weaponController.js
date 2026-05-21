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
        if (!weapon) return res.status(404).json({ message: 'Weapon tidak ditemukan' });
        res.json(weapon);
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
};

exports.createWeapon = async (req, res) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Hanya admin yang bisa menambah weapon' });
    }

    const { name, type, description, stock, image, price } = req.body;

    if (!name || !type || !stock || !price) {
        return res.status(400).json({ message: 'Field name, type, stock, price wajib diisi' });
    }

    try {
        await Weapon.create(name, type, description, stock, image, price);
        res.status(201).json({ message: 'Weapon berhasil ditambahkan' });
    } catch (err) {
        console.log("ERROR DARI DATABASE:", err);
        res.status(500).json({ message: 'Server error', detail: err.message });
    }
};

exports.updateWeapon = async (req, res) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Hanya admin yang bisa update weapon' });
    }

    const { name, type, description, stock, image, price } = req.body;

    try {
        await Weapon.update(req.params.id, name, type, description, stock, image, price);
        res.json({ message: 'Weapon berhasil diupdate' });
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
};

exports.deleteWeapon = async (req, res) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Hanya admin yang bisa hapus weapon' });
    }

    try {
        await Weapon.delete(req.params.id);
        res.json({ message: 'Weapon berhasil dihapus' });
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
};

exports.buyWeapon = async (req, res) => {
    const { quantity } = req.body;

    if (!quantity || quantity <= 0) {
        return res.status(400).json({ message: 'Jumlah beli harus lebih dari 0' });
    }

    try {
        const weapon = await Weapon.getById(req.params.id);
        if (!weapon) return res.status(404).json({ message: 'Weapon tidak ditemukan' });

        if (weapon.stock < quantity) {
            return res.status(400).json({ message: 'Stok tidak mencukupi' });
        }

        const totalPrice = weapon.price * quantity;
        const user = await User.findById(req.user.id);

        if (user.balance < totalPrice) {
            return res.status(400).json({ message: 'Koin (Balance) tidak mencukupi untuk membeli weapon ini' });
        }

        const newBalance = user.balance - totalPrice;
        const newStock = weapon.stock - quantity;

        await User.updateBalance(req.user.id, newBalance);
        await Weapon.updateStock(weapon.id, newStock);

        res.json({
            message: 'Pembelian berhasil',
            weapon_bought: weapon.name,
            total_spent: totalPrice,
            remaining_balance: newBalance
        });
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
};