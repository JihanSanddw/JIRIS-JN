const pool = require("../config/database");

const {
  uploadToCloudinary,
  deleteFromCloudinary,
} = require("../services/cloudinaryService");

// GET user profile
const getProfile = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
        id,
        name,
        email,
        role,
        profile_image,
        banner_image,
        created_at
       FROM users
       WHERE id = $1`,
      [req.user.id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pengguna tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Profil berhasil diambil.",
      data: {
        user: result.rows[0],
      },
    });
  } catch (error) {
    console.error("Get profile error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// PUT update profile information
const updateProfile = async (req, res) => {
  try {
    const { name } = req.body;

    if (typeof name !== "string" || !name.trim()) {
      return res.status(400).json({
        success: false,
        message: "Nama pengguna wajib diisi.",
      });
    }

    const result = await pool.query(
      `UPDATE users
       SET name = $1
       WHERE id = $2
       RETURNING
         id,
         name,
         email,
         role,
         profile_image,
         banner_image,
         created_at`,
      [name.trim(), req.user.id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pengguna tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Profil berhasil diperbarui.",
      data: {
        user: result.rows[0],
      },
    });
  } catch (error) {
    console.error("Update profile error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// Helper untuk memperbarui gambar profil pengguna
const updateUserImage = async (req, res, column, folder, message) => {
  let uploadedImage = null;

  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "File gambar wajib diunggah.",
      });
    }

    uploadedImage = await uploadToCloudinary(req.file, folder);

    const result = await pool.query(
      `
        UPDATE users
        SET ${column} = $1
        WHERE id = $2
        RETURNING
          id,
          name,
          email,
          role,
          profile_image,
          banner_image,
          created_at
      `,
      [uploadedImage.image_url, req.user.id],
    );

    if (result.rows.length === 0) {
      await deleteFromCloudinary(uploadedImage.public_id);

      return res.status(404).json({
        success: false,
        message: "Pengguna tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message,
      data: {
        user: result.rows[0],
      },
    });
  } catch (error) {
    console.error("Update user image error:", error);

    // Hapus gambar baru jika proses database gagal
    if (uploadedImage?.public_id) {
      try {
        await deleteFromCloudinary(uploadedImage.public_id);
      } catch (deleteError) {
        console.error("Cloudinary cleanup error:", deleteError.message);
      }
    }

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan saat memperbarui gambar.",
    });
  }
};

const updateProfileImage = async (req, res) => {
  return updateUserImage(
    req,
    res,
    "profile_image",
    "jiris/users/profile",
    "Foto profil berhasil diperbarui.",
  );
};

const updateProfileBanner = async (req, res) => {
  return updateUserImage(
    req,
    res,
    "banner_image",
    "jiris/users/banners",
    "Banner profil berhasil diperbarui.",
  );
};

const removeProfileImage = async (req, res) => {
  try {
    const result = await pool.query(
      `
        UPDATE users
        SET profile_image = NULL
        WHERE id = $1
        RETURNING
          id,
          name,
          email,
          role,
          profile_image,
          banner_image,
          created_at
      `,
      [req.user.id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pengguna tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Foto profil berhasil dihapus.",
      data: {
        user: result.rows[0],
      },
    });
  } catch (error) {
    console.error("Remove profile image error:", error);

    return res.status(500).json({
      success: false,
      message: "Gagal menghapus foto profil.",
    });
  }
};

module.exports = {
  getProfile,
  updateProfile,
  updateProfileImage,
  updateProfileBanner,
  removeProfileImage,
};
