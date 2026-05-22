const express = require('express');
const router = express.Router();
const weaponController = require('../controllers/weaponController');
const verifyToken = require('../middleware/auth');

router.get('/', verifyToken, weaponController.getAllWeapons);
router.get('/:id', verifyToken, weaponController.getWeaponById);
router.post('/:id/buy', verifyToken, weaponController.buyWeapon);

router.post('/', verifyToken, weaponController.createWeapon);
router.put('/:id', verifyToken, weaponController.updateWeapon);
router.delete('/:id', verifyToken, weaponController.deleteWeapon);

module.exports = router;