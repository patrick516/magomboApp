const express = require("express");
const router = express.Router();
const preacherController = require("./preacher.controller");
const { authenticateAdmin } = require("../../middleware/auth");

// Public
router.get("/", preacherController.listPreachers);
router.post("/", preacherController.registerPreacher);

router.get(
  "/admin/all",
  authenticateAdmin,
  preacherController.listAllPreachers,
);
router.get(
  "/admin/pending",
  authenticateAdmin,
  preacherController.listPendingPreachers,
);
router.post(
  "/:id/approve",
  authenticateAdmin,
  preacherController.approvePreacher,
);
router.post(
  "/:id/reject",
  authenticateAdmin,
  preacherController.rejectPreacher,
);
router.delete("/:id", authenticateAdmin, preacherController.deletePreacher);
module.exports = router;
