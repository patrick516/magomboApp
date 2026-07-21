const preachingService = require("./preaching.service");
const { uploadAudio, getSignedAudioUrl } = require("../../lib/storage");

async function listPreachingsForSermon(req, res, next) {
  try {
    const parts = await preachingService.listPreachingsForSermon(
      req.params.sermonId,
    );
    res.json({ success: true, data: parts });
  } catch (err) {
    next(err);
  }
}

async function createPreaching(req, res, next) {
  try {
    const { dateRecorded, durationSeconds } = req.body;

    if (!dateRecorded || !durationSeconds) {
      return res
        .status(400)
        .json({
          success: false,
          message: "dateRecorded and durationSeconds are required",
        });
    }
    if (!req.file) {
      return res
        .status(400)
        .json({ success: false, message: "audio file is required" });
    }

    // audioUrl field now stores the private object KEY, not a public URL
    const audioKey = await uploadAudio(
      req.file.buffer,
      req.file.originalname,
      req.file.mimetype,
    );

    const preaching = await preachingService.createPreaching({
      sermonId: req.params.sermonId,
      dateRecorded,
      durationSeconds: Number(durationSeconds),
      audioUrl: audioKey,
    });

    res.status(201).json({ success: true, data: preaching });
  } catch (err) {
    next(err);
  }
}

async function getAudio(req, res, next) {
  try {
    const preaching = await preachingService.getPreaching(req.params.id);
    if (!preaching) {
      return res
        .status(404)
        .json({ success: false, message: "Preaching not found" });
    }
    // audioUrl holds the private object key — sign a fresh temporary URL each time
    const signedUrl = await getSignedAudioUrl(preaching.audioUrl);
    res.redirect(signedUrl);
  } catch (err) {
    next(err);
  }
}

async function incrementPlayCount(req, res, next) {
  try {
    const preaching = await preachingService.incrementPlayCount(req.params.id);
    res.json({ success: true, data: preaching });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listPreachingsForSermon,
  createPreaching,
  getAudio,
  incrementPlayCount,
};
