const express = require("express");
const router = express.Router();

const {
  getCart,
  addCartItem,
  updateCartItem,
  deleteCartItem,
} = require("../controllers/cartController");

const { authenticate, authorize } = require("../middleware/authMiddleware");

router.use(authenticate);
router.use(authorize("customer"));

router.get("/", getCart);
router.post("/items", addCartItem);
router.put("/items/:id", updateCartItem);
router.delete("/items/:id", deleteCartItem);

module.exports = router;
