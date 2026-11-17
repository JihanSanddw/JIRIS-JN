const pool = require("../config/database");

// GET all products
const getProducts = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        p.*,
        c.name AS category_name
      FROM products p
      JOIN categories c ON p.category_id = c.id
      ORDER BY p.id ASC
    `);

    return res.status(200).json({
      success: true,
      message: "Berhasil mengambil data produk.",
      data: result.rows,
    });
  } catch (error) {
    console.error("Get products error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// GET detail product by ID
const getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!/^\d+$/.test(id)) {
      return res.status(400).json({
        success: false,
        message: "ID produk tidak valid.",
      });
    }

    const result = await pool.query(`
      SELECT
        p.*,
        c.name AS category_name
      FROM products p
      JOIN categories c ON p.category_id = c.id
      WHERE p.id = $1
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Produk tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Berhasil mengambil detail produk.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Get product error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// Validation
const validateProduct = (body) => {
  const { category_id, name, price, stock, description, image_url } = body;

  if (!category_id || !/^\d+$/.test(String(category_id))) {
    return "Kategori produk tidak valid.";
  }

  if (typeof name !== "string" || !name.trim()) {
    return "Nama produk wajib diisi.";
  }

  if (
    price === undefined ||
    price === null ||
    price === "" ||
    !Number.isFinite(Number(price)) ||
    Number(price) < 0
  ) {
    return "Harga harus berupa angka dan tidak boleh negatif.";
  }

  if (
    stock === undefined ||
    stock === null ||
    !Number.isInteger(Number(stock)) ||
    Number(stock) < 0
  ) {
    return "Stok harus berupa bilangan bulat dan tidak boleh negatif.";
  }

  if (description !== undefined && description !== null &&
      typeof description !== "string") {
    return "Deskripsi harus berupa teks.";
  }

  if (image_url !== undefined && image_url !== null &&
      typeof image_url !== "string") {
    return "URL gambar harus berupa teks.";
  }

  if (image_url && !/^https?:\/\/\S+$/i.test(image_url)) {
    return "URL gambar harus menggunakan alamat HTTP atau HTTPS yang valid.";
  }

  return null;
};

// POST add new orodyc
const createProduct = async (req, res) => {
  try {
    const validationError = validateProduct(req.body);

    if (validationError) {
      return res.status(400).json({
        success: false,
        message: validationError,
      });
    }

    const {
      category_id,
      name,
      description,
      price,
      stock,
      image_url,
    } = req.body;

    const result = await pool.query(`
      INSERT INTO products
        (category_id, name, description, price, stock, image_url)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `, [
      category_id,
      name.trim(),
      description?.trim() || null,
      Number(price),
      Number(stock),
      image_url?.trim() || null,
    ]);

    return res.status(201).json({
      success: true,
      message: "Produk berhasil ditambahkan.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Create product error:", error);

    if (error.code === "23503") {
      return res.status(400).json({
        success: false,
        message: "Kategori yang dipilih tidak ditemukan.",
      });
    }

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// PUT udate podct
const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;

    if (!/^\d+$/.test(id)) {
      return res.status(400).json({
        success: false,
        message: "ID produk tidak valid.",
      });
    }

    const validationError = validateProduct(req.body);

    if (validationError) {
      return res.status(400).json({
        success: false,
        message: validationError,
      });
    }

    const {
      category_id,
      name,
      description,
      price,
      stock,
      image_url,
    } = req.body;

    const result = await pool.query(`
      UPDATE products
      SET
        category_id = $1,
        name = $2,
        description = $3,
        price = $4,
        stock = $5,
        image_url = $6,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $7
      RETURNING *
    `, [
      category_id,
      name.trim(),
      description?.trim() || null,
      Number(price),
      Number(stock),
      image_url?.trim() || null,
      id,
    ]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Produk tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Produk berhasil diperbarui.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Update product error:", error);

    if (error.code === "23503") {
      return res.status(400).json({
        success: false,
        message: "Kategori yang dipilih tidak ditemukan.",
      });
    }

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// DELETE product
const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    if (!/^\d+$/.test(id)) {
      return res.status(400).json({
        success: false,
        message: "ID produk tidak valid.",
      });
    }

    const result = await pool.query(
      "DELETE FROM products WHERE id = $1 RETURNING *",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Produk tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Produk berhasil dihapus.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Delete product error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

module.exports = {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
};
