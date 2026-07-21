const preacherService = require("./preacher.service");

async function listPreachers(req, res, next) {
  try {
    const preachers = await preacherService.listPreachers();
    res.json({ success: true, data: preachers });
  } catch (err) {
    next(err);
  }
}

async function listAllPreachers(req, res, next) {
  try {
    const preachers = await preacherService.listAllPreachers();
    res.json({ success: true, data: preachers });
  } catch (err) {
    next(err);
  }
}

async function listPendingPreachers(req, res, next) {
  try {
    const preachers = await preacherService.listPendingPreachers();
    res.json({ success: true, data: preachers });
  } catch (err) {
    next(err);
  }
}

async function registerPreacher(req, res, next) {
  try {
    const { id, deviceId, name, position } = req.body;
    if (!deviceId || !name) {
      return res
        .status(400)
        .json({ success: false, message: "deviceId and name are required" });
    }
    const preacher = await preacherService.registerPreacher({
      id,
      deviceId,
      name,
      position,
    });
    res.status(201).json({ success: true, data: preacher });
  } catch (err) {
    next(err);
  }
}
async function approvePreacher(req, res, next) {
  try {
    const preacher = await preacherService.approvePreacher(req.params.id);
    res.json({ success: true, data: preacher });
  } catch (err) {
    next(err);
  }
}

async function rejectPreacher(req, res, next) {
  try {
    const preacher = await preacherService.rejectPreacher(req.params.id);
    res.json({ success: true, data: preacher });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listPreachers,
  listAllPreachers,
  listPendingPreachers,
  registerPreacher,
  approvePreacher,
  rejectPreacher,
};
