const express = require("express");
const router = express.Router();

const {
  getProducts,
  getAdminProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
} = require("../controllers/productController");

const { authenticate, authorize } = require("../middleware/authMiddleware");

const uploadSingleImage = require("../middleware/uploadMiddleware");

router.get("/", getProducts);
router.get("/admin", authenticate, authorize("admin"), getAdminProducts);
router.get("/:id", getProductById);

router.post(
  "/",
  authenticate,
  authorize("admin"),
  uploadSingleImage,
  createProduct,
);

router.put(
  "/:id",
  authenticate,
  authorize("admin"),
  uploadSingleImage,
  updateProduct,
);

router.delete("/:id", authenticate, authorize("admin"), deleteProduct);

module.exports = router;
