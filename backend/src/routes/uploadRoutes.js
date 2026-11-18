const express = require("express");
const router = express.Router();

const {
  authenticate,
  authorize,
} = require("../middleware/authMiddleware");

const uploadSingleImage = require("../middleware/uploadMiddleware");

const {
  uploadImage,
} = require("../controllers/uploadController");

router.post(
  "/image",
  authenticate,
  authorize("admin"),
  uploadSingleImage,
  uploadImage
);

module.exports = router;
