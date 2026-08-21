const express = require("express");
const router = express.Router();
const smallGroupController = require("./small-group.controller");
const { authenticateAdmin } = require("../../middleware/auth");

router.get("/", smallGroupController.listSmallGroups);
router.post("/", authenticateAdmin, smallGroupController.createSmallGroup);
router.delete("/:id", authenticateAdmin, smallGroupController.deleteSmallGroup);

router.get("/:id", smallGroupController.getSmallGroup);
router.post("/:id/join", smallGroupController.joinGroup);
router.post("/:id/leave", smallGroupController.leaveGroup);

router.get("/:id/posts", smallGroupController.listPosts);
router.post("/:id/posts", smallGroupController.createPost);
router.post(
  "/:groupId/posts/:postId/comments",
  smallGroupController.createComment,
);

module.exports = router;
