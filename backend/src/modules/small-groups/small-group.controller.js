const smallGroupService = require('./small-group.service');

async function listSmallGroups(req, res, next) {
  try {
    const groups = await smallGroupService.listSmallGroups();
    res.json({ success: true, data: groups });
  } catch (err) { next(err); }
}

async function createSmallGroup(req, res, next) {
  try {
    const { name, description, meetingDay, meetingTime, location, leaderName } = req.body;
    if (!name) {
      return res.status(400).json({ success: false, message: 'name is required' });
    }
    const group = await smallGroupService.createSmallGroup({ name, description, meetingDay, meetingTime, location, leaderName });
    res.status(201).json({ success: true, data: group });
  } catch (err) { next(err); }
}

async function deleteSmallGroup(req, res, next) {
  try {
    await smallGroupService.deleteSmallGroup(req.params.id);
    res.json({ success: true, data: null });
  } catch (err) { next(err); }
}

module.exports = { listSmallGroups, createSmallGroup, deleteSmallGroup };
