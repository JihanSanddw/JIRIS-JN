const express = require("express");
const router = express.Router();

const {
  getProfile,
  updateProfile,
  updateProfileImage,
  updateProfileBanner,
  removeProfileImage,
} = require("../controllers/userController");

const { authenticate } = require("../middleware/authMiddleware");
const uploadSingleImage = require("../middleware/uploadMiddleware");

router.get("/profile", authenticate, getProfile);

router.put("/profile", authenticate, updateProfile);

router.put(
  "/profile/image",
  authenticate,
  uploadSingleImage,
  updateProfileImage,
);

router.put(
  "/profile/banner",
  authenticate,
  uploadSingleImage,
  updateProfileBanner,
);

router.delete("/profile/image", authenticate, removeProfileImage);

module.exports = router;
