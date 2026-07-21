const express = require("express");
const multer = require("multer");
const router = express.Router();
const sermonController = require("./sermon.controller");
const preachingController = require("../preachings/preaching.controller");
const adminAuth = require("../../middleware/adminAuth");

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 100 * 1024 * 1024 },
}); // 100MB max

router.get("/", sermonController.listSermons);
router.get("/admin/all", adminAuth, sermonController.listAllSermonsAdmin);
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
