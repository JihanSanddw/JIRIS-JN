const pool = require("../config/database");

const getProfile = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, name, email, role, created_at
       FROM users
       WHERE id = $1`,
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pengguna tidak ditemukan."
      });
    }

    return res.status(200).json({
      success: true,
      message: "Profil berhasil diambil.",
      data: {
        user: result.rows[0]
      }
    });

  } catch (error) {
    console.error("Profile error:", error.message);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server."
    });
  }
};

module.exports = {
  getProfile
};
