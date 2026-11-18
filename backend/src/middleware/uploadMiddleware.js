const multer = require("multer");

// Format gambar yang diperbolehkan
const allowedMimeTypes = [
  "image/jpeg",
  "image/png",
  "image/webp",
];

// Penyimpanan sementara menggunakan memory
const storage = multer.memoryStorage();

// Konfigurasi Multer
const upload = multer({
  storage,

  // Maksimal ukuran gambar 5 MB
  limits: {
    fileSize: 5 * 1024 * 1024,
  },

  // Validasi format gambar
  fileFilter: (req, file, callback) => {
    if (!allowedMimeTypes.includes(file.mimetype)) {
      return callback(
        new Error("Format gambar harus JPG, PNG, atau WEBP.")
      );
    }

    callback(null, true);
  },
});

// Middleware untuk menangani satu gambar
const uploadSingleImage = (req, res, next) => {
  upload.single("image")(req, res, (error) => {
    if (error instanceof multer.MulterError) {
      if (error.code === "LIMIT_FILE_SIZE") {
        return res.status(400).json({
          success: false,
          message: "Ukuran gambar maksimal 5 MB.",
        });
      }

      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    if (error) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    next();
  });
};

module.exports = uploadSingleImage;
