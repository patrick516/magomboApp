const {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
} = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const s3 = new S3Client({
  endpoint: process.env.B2_ENDPOINT,
  region: process.env.B2_REGION,
  credentials: {
    accessKeyId: process.env.B2_KEY_ID,
    secretAccessKey: process.env.B2_APPLICATION_KEY,
  },
});

/**
 * Uploads audio to the private bucket and returns the object KEY
 * (not a public URL, since the bucket is private).
 */
async function uploadAudio(buffer, fileName, mimeType) {
  const key = `preachings/${Date.now()}-${fileName}`;

  await s3.send(
    new PutObjectCommand({
      Bucket: process.env.B2_BUCKET_NAME,
      Key: key,
      Body: buffer,
      ContentType: mimeType || "audio/m4a",
    }),
  );

  return key;
}

/**
 * Generates a temporary signed URL (default: 1 hour) to stream/download
 * a private file. Must be called fresh each time audio is requested —
 * signed URLs expire and cannot be cached long-term.
 */
async function getSignedAudioUrl(key, expiresInSeconds = 3600) {
  const command = new GetObjectCommand({
    Bucket: process.env.B2_BUCKET_NAME,
    Key: key,
  });
  return getSignedUrl(s3, command, { expiresIn: expiresInSeconds });
}

module.exports = { uploadAudio, getSignedAudioUrl };
