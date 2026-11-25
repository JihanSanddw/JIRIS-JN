const pool = require("../config/database");

// GET all companies
const getCompanies = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        co.*,
        COUNT(p.id)::INTEGER AS total_products
      FROM companies co
      LEFT JOIN products p ON p.company_id = co.id
      GROUP BY co.id
      ORDER BY co.id ASC
    `);

    return res.status(200).json({
      success: true,
      message: "Berhasil mengambil data perusahaan.",
      data: result.rows,
    });
  } catch (error) {
    console.error("Get companies error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// GET company detail by ID
const getCompanyById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!/^\d+$/.test(id)) {
      return res.status(400).json({
        success: false,
        message: "ID perusahaan tidak valid.",
      });
    }

    const result = await pool.query(
      `
      SELECT
        co.*,
        COUNT(p.id)::INTEGER AS total_products
      FROM companies co
      LEFT JOIN products p ON p.company_id = co.id
      WHERE co.id = $1
      GROUP BY co.id
    `,
      [id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Perusahaan tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Berhasil mengambil detail perusahaan.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Get company error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// Validation
const validateCompany = (body) => {
  const { name, description, logo_url, website_url, contact_email } = body;

  if (typeof name !== "string" || !name.trim()) {
    return "Nama perusahaan wajib diisi.";
  }

  if (
    description !== undefined &&
    description !== null &&
    typeof description !== "string"
  ) {
    return "Deskripsi harus berupa teks.";
  }

  if (
    logo_url !== undefined &&
    logo_url !== null &&
    typeof logo_url !== "string"
  ) {
    return "URL logo harus berupa teks.";
  }

  if (logo_url && !/^https?:\/\/\S+$/i.test(logo_url)) {
    return "URL logo harus menggunakan HTTP atau HTTPS.";
  }

  if (
    website_url !== undefined &&
    website_url !== null &&
    typeof website_url !== "string"
  ) {
    return "URL website harus berupa teks.";
  }

  if (website_url && !/^https?:\/\/\S+$/i.test(website_url)) {
    return "URL website harus menggunakan HTTP atau HTTPS.";
  }

  if (
    contact_email !== undefined &&
    contact_email !== null &&
    typeof contact_email !== "string"
  ) {
    return "Email kontak harus berupa teks.";
  }

  if (contact_email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(contact_email)) {
    return "Format email kontak tidak valid.";
  }

  return null;
};

// POST create company
const createCompany = async (req, res) => {
  try {
    const validationError = validateCompany(req.body);

    if (validationError) {
      return res.status(400).json({
        success: false,
        message: validationError,
      });
    }

    const { name, description, logo_url, website_url, contact_email } =
      req.body;

    const result = await pool.query(
      `
      INSERT INTO companies
        (name, description, logo_url, website_url, contact_email)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `,
      [
        name.trim(),
        description?.trim() || null,
        logo_url?.trim() || null,
        website_url?.trim() || null,
        contact_email?.trim() || null,
      ],
    );

    return res.status(201).json({
      success: true,
      message: "Perusahaan berhasil ditambahkan.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Create company error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// PUT update company
const updateCompany = async (req, res) => {
  try {
    const { id } = req.params;

    if (!/^\d+$/.test(id)) {
      return res.status(400).json({
        success: false,
        message: "ID perusahaan tidak valid.",
      });
    }

    const validationError = validateCompany(req.body);

    if (validationError) {
      return res.status(400).json({
        success: false,
        message: validationError,
      });
    }

    const { name, description, logo_url, website_url, contact_email } =
      req.body;

    const result = await pool.query(
      `
      UPDATE companies
      SET
        name = $1,
        description = $2,
        logo_url = $3,
        website_url = $4,
        contact_email = $5,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $6
      RETURNING *
    `,
      [
        name.trim(),
        description?.trim() || null,
        logo_url?.trim() || null,
        website_url?.trim() || null,
        contact_email?.trim() || null,
        id,
      ],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Perusahaan tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Perusahaan berhasil diperbarui.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Update company error:", error);

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// DELETE company
const deleteCompany = async (req, res) => {
  try {
    const { id } = req.params;

    if (!/^\d+$/.test(id)) {
      return res.status(400).json({
        success: false,
        message: "ID perusahaan tidak valid.",
      });
    }

    const result = await pool.query(
      "DELETE FROM companies WHERE id = $1 RETURNING *",
      [id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Perusahaan tidak ditemukan.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Perusahaan berhasil dihapus.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Delete company error:", error);

    if (error.code === "23503") {
      return res.status(409).json({
        success: false,
        message: "Perusahaan tidak dapat dihapus karena masih memiliki produk.",
      });
    }

    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

module.exports = {
  getCompanies,
  getCompanyById,
  createCompany,
  updateCompany,
  deleteCompany,
};
