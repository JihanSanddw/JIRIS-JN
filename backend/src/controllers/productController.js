const pool = require("../config/database");

// GET all products

// GET all products with search and filters
const getProducts = async (req, res) => {
  try {
    const {
      search,
      category_id,
      company_id,
      min_price,
      max_price,
      page = "1",
      limit = "10",
    } = req.query;

    // Validate pagination
    if (!/^\d+$/.test(page) || Number(page) < 1) {
      return res.status(400).json({
        success: false,
        message: "Parameter page harus berupa angka minimal 1.",
      });
    }

    if (!/^\d+$/.test(limit) || Number(limit) < 1) {
      return res.status(400).json({
        success: false,
        message: "Parameter limit harus berupa angka minimal 1.",
      });
    }

    if (Number(limit) > 100) {
      return res.status(400).json({
        success: false,
        message: "Parameter limit maksimal 100.",
      });
    }

    const currentPage = Number(page);
    const pageLimit = Number(limit);

    if (!Number.isSafeInteger(currentPage) || !Number.isSafeInteger(pageLimit)) {
      return res.status(400).json({
        success: false,
        message: "Parameter pagination terlalu besar.",
      });
    }

    const offset = (currentPage - 1) * pageLimit;

    if (!Number.isSafeInteger(offset)) {
      return res.status(400).json({
        success: false,
        message: "Parameter pagination terlalu besar.",
      });
    }

    // Build dynamic query
    let query = `
      SELECT
        p.*,
        c.name AS category_name,
        co.name AS company_name
      FROM products p
      JOIN categories c ON p.category_id = c.id
      JOIN companies co ON p.company_id = co.id
      WHERE 1=1
    `;

    const values = [];
    let index = 1;

    // Search product name and description
    if (search && search.trim()) {
      query += `
        AND (
          p.name ILIKE $${index}
          OR p.description ILIKE $${index}
        )
      `;
      values.push(`%${search.trim()}%`);
      index++;
    }

    // Filter by category
    if (category_id !== undefined) {
      if (!/^\d+$/.test(category_id)) {
        return res.status(400).json({
          success: false,
          message: "ID kategori tidak valid.",
        });
      }

      query += ` AND p.category_id = $${index}`;
      values.push(category_id);
      index++;
    }

    // Filter by company
    if (company_id !== undefined) {
      if (!/^\d+$/.test(company_id)) {
        return res.status(400).json({
          success: false,
          message: "ID perusahaan tidak valid.",
        });
      }

      query += ` AND p.company_id = $${index}`;
      values.push(company_id);
      index++;
    }

    // Filter by minimum price
    if (min_price !== undefined) {
      if (
        min_price.trim() === "" ||
        !Number.isFinite(Number(min_price)) ||
        Number(min_price) < 0
      ) {
        return res.status(400).json({
          success: false,
          message: "Harga minimum tidak valid.",
        });
      }

      query += ` AND p.price >= $${index}`;
      values.push(Number(min_price));
      index++;
    }

    // Filter by maximum price
    if (max_price !== undefined) {
      if (
        max_price.trim() === "" ||
        !Number.isFinite(Number(max_price)) ||
        Number(max_price) < 0
      ) {
        return res.status(400).json({
          success: false,
          message: "Harga maksimum tidak valid.",
        });
      }

      query += ` AND p.price <= $${index}`;
      values.push(Number(max_price));
      index++;
    }

    // Validate price range
    if (
      min_price !== undefined &&
      max_price !== undefined &&
      Number(min_price) > Number(max_price)
    ) {
      return res.status(400).json({
        success: false,
        message: "Harga minimum tidak boleh lebih besar dari harga maksimum.",
      });
    }

    // Count total products before pagination
    const countQuery = `
      SELECT COUNT(*) AS total
      FROM (${query}) AS filtered_products
    `;

    const countResult = await pool.query(countQuery, values);

    const totalItems = Number(countResult.rows[0].total);
    const totalPages = Math.ceil(totalItems / pageLimit);

    // Sorting
    const allowedSortColumns = {
      name: "p.name",
      price: "p.price",
      created_at: "p.created_at",
    };

    const sortBy = req.query.sort_by || "created_at";
    const order = (req.query.order || "desc").toLowerCase();

    const sortColumn = allowedSortColumns[sortBy];

    if (!sortColumn) {
      return res.status(400).json({
        success: false,
        message: "Parameter sort_by tidak valid.",
      });
    }

    if (!["asc", "desc"].includes(order)) {
      return res.status(400).json({
        success: false,
        message: "Parameter order harus asc atau desc.",
      });
    }

    query += ` ORDER BY ${sortColumn} ${order.toUpperCase()}, p.id ASC`;

    // Pagination
    query += ` LIMIT $${index} OFFSET $${index + 1}`;

    values.push(pageLimit, offset);

    const result = await pool.query(query, values);

    return res.status(200).json({
      success: true,
      message: "Berhasil mengambil data produk.",

      pagination: {
        current_page: currentPage,
        limit: pageLimit,
        total_items: totalItems,
        total_pages: totalPages,
        has_next_page: currentPage < totalPages,
        has_previous_page: currentPage > 1 && totalPages > 0,
      },

      filters: {
        search: search || null,
        category_id: category_id || null,
        company_id: company_id || null,
        min_price: min_price ?? null,
        max_price: max_price ?? null,
      },

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
        c.name AS category_name,
        co.name AS company_name
      FROM products p
      JOIN categories c ON p.category_id = c.id
      JOIN companies co ON p.company_id = co.id
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
  const {
    category_id,
    company_id,
    name,
    price,
    stock,
    description,
    image_url,
  } = body;

  if (!category_id || !/^\d+$/.test(String(category_id))) {
    return "Kategori produk tidak valid.";
  }

  if (!company_id || !/^\d+$/.test(String(company_id))) {
    return "Perusahaan produk tidak valid.";
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
    stock === "" ||
    !Number.isInteger(Number(stock)) ||
    Number(stock) < 0
  ) {
    return "Stok harus berupa bilangan bulat dan tidak boleh negatif.";
  }

  if (
    description !== undefined &&
    description !== null &&
    typeof description !== "string"
  ) {
    return "Deskripsi harus berupa teks.";
  }

  if (
    image_url !== undefined &&
    image_url !== null &&
    typeof image_url !== "string"
  ) {
    return "URL gambar harus berupa teks.";
  }

  if (image_url && !/^https?:\/\/\S+$/i.test(image_url)) {
    return "URL gambar harus menggunakan alamat HTTP atau HTTPS yang valid.";
  }

  return null;
};

// POST add new product
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
      company_id,
      name,
      description,
      price,
      stock,
      image_url,
    } = req.body;

    const result = await pool.query(`
      INSERT INTO products
        (category_id, company_id, name, description, price, stock, image_url)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `, [
      category_id,
      company_id,
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
        message: "Kategori atau perusahaan yang dipilih tidak ditemukan.",
      });
    }

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// PUT update product
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
      company_id,
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
        company_id = $2,
        name = $3,
        description = $4,
        price = $5,
        stock = $6,
        image_url = $7,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $8
      RETURNING *
    `, [
      category_id,
      company_id,
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
        message: "Kategori atau perusahaan yang dipilih tidak ditemukan.",
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
