const smallGroupService = require("./small-group.service");

async function listSmallGroups(req, res, next) {
  try {
    const groups = await smallGroupService.listSmallGroups();
    res.json({ success: true, data: groups });
  } catch (err) {
    next(err);
  }
}

async function createSmallGroup(req, res, next) {
  try {
    const { name, description, meetingDay, meetingTime, location, leaderName } =
      req.body;
    if (!name) {
      return res
        .status(400)
        .json({ success: false, message: "name is required" });
    }
    const group = await smallGroupService.createSmallGroup({
      name,
      description,
      meetingDay,
      meetingTime,
      location,
      leaderName,
    });
    res.status(201).json({ success: true, data: group });
  } catch (err) {
    next(err);
  }
}

async function deleteSmallGroup(req, res, next) {
  try {
    await smallGroupService.deleteSmallGroup(req.params.id);
    res.json({ success: true, data: null });
  } catch (err) {
    next(err);
  }
}
async function getSmallGroup(req, res, next) {
  try {
    const group = await smallGroupService.getSmallGroup(req.params.id);
    if (!group)
      return res
        .status(404)
        .json({ success: false, message: "Group not found" });

    const { deviceId } = req.query;
    const memberIn = deviceId
      ? await smallGroupService.isMember(req.params.id, deviceId)
      : false;

    res.json({ success: true, data: { ...group, isMember: memberIn } });
  } catch (err) {
    next(err);
  }
}

async function joinGroup(req, res, next) {
  try {
    const { deviceId, memberName } = req.body;
    if (!deviceId || !memberName) {
      return res
        .status(400)
        .json({
          success: false,
          message: "deviceId and memberName are required",
        });
    }
    const membership = await smallGroupService.joinGroup(req.params.id, {
      deviceId,
      memberName,
    });
    res.status(201).json({ success: true, data: membership });
  } catch (err) {
    next(err);
  }
}

async function leaveGroup(req, res, next) {
  try {
    const { deviceId } = req.body;
    if (!deviceId) {
      return res
        .status(400)
        .json({ success: false, message: "deviceId is required" });
    }
    await smallGroupService.leaveGroup(req.params.id, deviceId);
    res.json({ success: true, data: null });
  } catch (err) {
    next(err);
  }
}

async function listPosts(req, res, next) {
  try {
    const posts = await smallGroupService.listPosts(req.params.id);
    res.json({ success: true, data: posts });
  } catch (err) {
    next(err);
  }
}

async function createPost(req, res, next) {
  try {
    const { deviceId, authorName, message } = req.body;
    if (!deviceId || !authorName || !message) {
      return res
        .status(400)
        .json({
          success: false,
          message: "deviceId, authorName and message are required",
        });
    }
    const post = await smallGroupService.createPost(req.params.id, {
      deviceId,
      authorName,
      message,
    });
    res.status(201).json({ success: true, data: post });
  } catch (err) {
    next(err);
  }
}

async function createComment(req, res, next) {
  try {
    const { deviceId, authorName, message } = req.body;
    if (!deviceId || !authorName || !message) {
      return res
        .status(400)
        .json({
          success: false,
          message: "deviceId, authorName and message are required",
        });
    }
    const comment = await smallGroupService.createComment(req.params.postId, {
      deviceId,
      authorName,
      message,
    });
    res.status(201).json({ success: true, data: comment });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listSmallGroups,
  createSmallGroup,
  deleteSmallGroup,
  getSmallGroup,
  joinGroup,
  leaveGroup,
  listPosts,
  createPost,
  createComment,
};
