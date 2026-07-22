const {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
} = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const AWS_REGION = process.env.AWS_REGION;
const AWS_BUCKET = process.env.AWS_S3_BUCKET;

const s3Client = new S3Client({
  region: AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

/**
 * Uploads audio to S3 and returns the object key.
 */
async function uploadAudio(buffer, fileName, mimeType) {
  if (!buffer || buffer.length === 0) {
    throw new Error("Upload buffer is empty");
  }

  const key = `preachings/${Date.now()}-${fileName}`;

  const command = new PutObjectCommand({
    Bucket: AWS_BUCKET,
    Key: key,
    Body: buffer,
    ContentType: mimeType || "audio/mp4",
  });

  try {
    await s3Client.send(command);
  } catch (err) {
    throw new Error(`S3 upload failed: ${err.message}`);
  }

  return key;
}

/**
 * Generates a temporary signed URL (default: 1 hour).
 */
async function getSignedAudioUrl(key, expiresInSeconds = 3600) {
  const command = new GetObjectCommand({
    Bucket: AWS_BUCKET,
    Key: key,
  });

  const url = await getSignedUrl(s3Client, command, {
    expiresIn: expiresInSeconds,
  });

  return url;
}

module.exports = { uploadAudio, getSignedAudioUrl };
