const Image = require('../models/image.model')

const { S3Client } = require('@aws-sdk/client-s3')
const { Upload } = require('@aws-sdk/lib-storage')
const multer = require('multer')

const s3Client = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  }
})

const storage = multer.memoryStorage()
const upload = multer({ storage: storage }).single('image')

const uploadImage = async (req, res, userId) => {
  return new Promise((resolve, reject) => {
    upload(req, res, async function (err) {
      if (err) {
        return reject(err)
      }

      if (!req.file) {
        return reject(new Error('No file uploaded'))
      }

      const params = {
        Bucket: process.env.AWS_BUCKET_NAME,
        Key: Date.now().toString(),
        Body: req.file.buffer,
        ACL: 'public-read'
      }

      try {
        const upload = new Upload({
          client: s3Client,
          params: params
        })

        const data = await upload.done()

        const image = new Image({
          url: data.Location,
          user: userId,
          createdOn: new Date()
        })
        await image.save()

        resolve(image)
      } catch (err) {
        reject(err)
      }
    })
  })
}

module.exports = {
  uploadImage
}
