const express = require("express");
const router = express.Router();
const preacherController = require("./preacher.controller");
const adminAuth = require("../../middleware/adminAuth");

// Public
router.get("/", preacherController.listPreachers);
router.post("/", preacherController.registerPreacher);

// Admin only
router.get("/admin/all", adminAuth, preacherController.listAllPreachers);
router.get(
  "/admin/pending",
  adminAuth,
  preacherController.listPendingPreachers,
);
router.post("/:id/approve", adminAuth, preacherController.approvePreacher);
router.post("/:id/reject", adminAuth, preacherController.rejectPreacher);
router.delete("/:id", adminAuth, preacherController.deletePreacher);
module.exports = router;
