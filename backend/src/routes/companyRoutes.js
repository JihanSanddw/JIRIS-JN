const express = require("express");
const router = express.Router();

const {
  getCompanies,
  getCompanyById,
  createCompany,
  updateCompany,
  deleteCompany,
} = require("../controllers/companyController");

const {
  authenticate,
  authorize,
} = require("../middleware/authMiddleware");

// Public routes
router.get("/", getCompanies);
router.get("/:id", getCompanyById);

// Admin-only routes
router.post("/", authenticate, authorize("admin"), createCompany);
router.put("/:id", authenticate, authorize("admin"), updateCompany);
router.delete("/:id", authenticate, authorize("admin"), deleteCompany);

module.exports = router;
