const express = require("express");
const multer = require("multer");
const router = express.Router();
const sermonController = require("./sermon.controller");
const preachingController = require("../preachings/preaching.controller");
const { authenticateAdmin } = require("../../middleware/auth");

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 100 * 1024 * 1024 },
}); // 100MB max

router.get("/", sermonController.listSermons);
router.get(
  "/admin/all",
  authenticateAdmin,
  sermonController.listAllSermonsAdmin,
);
router.delete("/:id", authenticateAdmin, sermonController.deleteSermon);
router.post("/", sermonController.createSermon);
router.get(
  "/:sermonId/preachings",
  preachingController.listPreachingsForSermon,
);
router.post(
  "/:sermonId/preachings",
  upload.single("audio"),
  preachingController.createPreaching,
);

module.exports = router;
