const cloudinary = require("../config/cloudinary");
const { Readable } = require("stream");

// Upload gambar ke Cloudinary
const uploadImage = async (req, res) => {
  try {
    // Pastikan file gambar tersedia
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Silakan pilih gambar terlebih dahulu.",
      });
    }

    // Membuat stream dari buffer gambar
    const imageStream = Readable.from(req.file.buffer);

    // Mengirim gambar ke Cloudinary
    const result = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        {
          folder: "jiris/products",
          resource_type: "image",
        },
        (error, result) => {
          if (error) {
            reject(error);
          } else {
            resolve(result);
          }
        }
      );

      imageStream.pipe(stream);
    });

    // Mengembalikan URL gambar
    return res.status(201).json({
      success: true,
      message: "Gambar berhasil diunggah ke Cloudinary.",
      data: {
        image_url: result.secure_url,
        public_id: result.public_id,
        format: result.format,
        bytes: result.bytes,
      },
    });
  } catch (error) {
    console.error("Upload image error:", error.message);

    return res.status(500).json({
      success: false,
      message: "Gagal mengunggah gambar ke Cloudinary.",
    });
  }
};

module.exports = {
  uploadImage,
};
