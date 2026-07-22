const sermonService = require("./sermon.service");

async function listSermons(req, res, next) {
  try {
    const { preacherId, since } = req.query;
    const sermons = await sermonService.listSermons({ preacherId, since });
    res.json({ success: true, data: sermons });
  } catch (err) {
    next(err);
  }
}

async function createSermon(req, res, next) {
  try {
    const { id, preacherId, theme, series } = req.body;
    if (!preacherId || !theme) {
      return res
        .status(400)
        .json({ success: false, message: "preacherId and theme are required" });
    }
    const sermon = await sermonService.createSermon({
      id,
      preacherId,
      theme,
      series,
    });
    res.status(201).json({ success: true, data: sermon });
  } catch (err) {
    next(err);
  }
}

async function listAllSermonsAdmin(req, res, next) {
  try {
    const sermons = await sermonService.listAllSermonsAdmin();
    res.json({ success: true, data: sermons });
  } catch (err) {
    next(err);
  }
}

async function deleteSermon(req, res, next) {
  try {
    await sermonService.deleteSermon(req.params.id);
    res.json({ success: true, message: "Sermon and its parts deleted" });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listSermons,
  createSermon,
  listAllSermonsAdmin,
  deleteSermon,
};
