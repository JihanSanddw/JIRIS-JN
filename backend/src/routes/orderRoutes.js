const express = require("express");
const router = express.Router();

const {
  checkout,
  getMyOrders,
  getOrderDetail,
  getAllOrders,
  updateOrderStatus
} = require("../controllers/orderController");

const {authenticate, authorize} = require("../middleware/authMiddleware");

router.post("/checkout", authenticate, authorize("customer"), checkout);
router.get("/my-orders", authenticate, authorize("customer"), getMyOrders);
router.get("/my-orders/:id", authenticate, authorize("customer"), getOrderDetail);

router.get("/", authenticate, authorize("admin"), getAllOrders);
router.put("/:id/status", authenticate, authorize("admin"), updateOrderStatus);

module.exports = router;
