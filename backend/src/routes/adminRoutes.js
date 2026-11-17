const express = require("express");
const router = express.Router();

const { getDashboard } = require("../controllers/adminController");

const {
  authenticate,
  authorize
} = require("../middleware/authMiddleware");

router.get(
  "/dashboard",
  authenticate,
  authorize("admin"),
  getDashboard
);

module.exports = router;
