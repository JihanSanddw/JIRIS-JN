const pool = require("../config/database");

// GET all categories
const getCategories = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        c.*,
        COUNT(p.id)::INTEGER AS total_products
      FROM categories c
      LEFT JOIN products p ON p.category_id = c.id
      GROUP BY c.id
      ORDER BY c.id ASC
    `);

    return res.status(200).json({
      success: true,
      message: "Berhasil mengambil data kategori.",
      data: result.rows,
    });
  } catch (error) {
    console.error("Get categories error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// GET category detail by ID
const getCategoryById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!/^\d+$/.test(id)) {
      return res.status(400).json({
        success: false,
        message: "ID kategori tidak valid.",
      });
    }

    const result = await pool.query(`
      SELECT
        c.*,
        COUNT(p.id)::INTEGER AS total_products
      FROM categories c
      LEFT JOIN products p ON p.category_id = c.id
      WHERE c.id = $1
      GROUP BY c.id
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Kategori tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Berhasil mengambil detail kategori.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Get category error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

const validateCategory = (body) => {
  const { name, description } = body;

  if (typeof name !== "string" || !name.trim()) {
    return "Nama kategori wajib diisi.";
  }

  if (
    description !== undefined &&
    description !== null &&
    typeof description !== "string"
  ) {
    return "Deskripsi kategori harus berupa teks.";
  }

  return null;
};

// POST create category
const createCategory = async (req, res) => {
  try {
    const validationError = validateCategory(req.body);

    if (validationError) {
      return res.status(400).json({
        success: false,
        message: validationError,
      });
    }

    const { name, description } = req.body;

    const result = await pool.query(`
      INSERT INTO categories (name, description)
      VALUES ($1, $2)
      RETURNING *
    `, [
      name.trim(),
      description?.trim() || null,
    ]);

    return res.status(201).json({
      success: true,
      message: "Kategori berhasil ditambahkan.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Create category error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// PUT update category
const updateCategory = async (req, res) => {
  try {
    const { id } = req.params;

    if (!/^\d+$/.test(id)) {
      return res.status(400).json({
        success: false,
        message: "ID kategori tidak valid.",
      });
    }

    const validationError = validateCategory(req.body);

    if (validationError) {
      return res.status(400).json({
        success: false,
        message: validationError,
      });
    }

    const { name, description } = req.body;

    const result = await pool.query(`
      UPDATE categories
      SET
        name = $1,
        description = $2
      WHERE id = $3
      RETURNING *
    `, [
      name.trim(),
      description?.trim() || null,
      id,
    ]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Kategori tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Kategori berhasil diperbarui.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Update category error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// DELETE category
const deleteCategory = async (req, res) => {
  try {
    const { id } = req.params;

    if (!/^\d+$/.test(id)) {
      return res.status(400).json({
        success: false,
        message: "ID kategori tidak valid.",
      });
    }

    const result = await pool.query(
      "DELETE FROM categories WHERE id = $1 RETURNING *",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Kategori tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Kategori berhasil dihapus.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Delete category error:", error);

    if (error.code === "23503") {
      return res.status(409).json({
        success: false,
        message: "Kategori tidak dapat dihapus karena masih digunakan oleh produk.",
      });
    }

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

module.exports = {
  getCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
};
