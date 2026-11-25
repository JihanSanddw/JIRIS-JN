const express = require("express");
const router = express.Router();

const {
  getCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
} = require("../controllers/categoryController");

const uploadSingleImage = require("../middleware/uploadMiddleware");

const { authenticate, authorize } = require("../middleware/authMiddleware");

router.get("/", getCategories);
router.get("/:id", getCategoryById);

router.post(
  "/",
  authenticate,
  authorize("admin"),
  uploadSingleImage,
  createCategory,
);

router.put(
  "/:id",
  authenticate,
  authorize("admin"),
  uploadSingleImage,
  updateCategory,
);

router.delete("/:id", authenticate, authorize("admin"), deleteCategory);

module.exports = router;
