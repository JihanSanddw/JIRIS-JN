const pool = require("../config/database");

// GET Melihat keranjang pengguna
const getCart = async (req, res) => {
  try {
    const userId = req.user.id;

    // Membuat cart jika belum tersedia
    let cartResult = await pool.query(
      "SELECT id FROM carts WHERE user_id = $1",
      [userId],
    );

    if (cartResult.rows.length === 0) {
      cartResult = await pool.query(
        `INSERT INTO carts (user_id)
          VALUES ($1)
          RETURNING id`,
        [userId],
      );
    }

    const cartId = cartResult.rows[0].id;

    const result = await pool.query(
      `SELECT
          ci.id AS cart_item_id,
          p.id AS product_id,
          p.name,
          p.description,
          p.price,
          p.stock,
          p.image_url,
          ci.quantity,
          (p.price * ci.quantity) AS subtotal
        FROM cart_items ci
        JOIN products p ON ci.product_id = p.id
        WHERE ci.cart_id = $1
        ORDER BY ci.created_at DESC`,
      [cartId],
    );

    const total = result.rows.reduce(
      (sum, item) => sum + Number(item.subtotal),
      0,
    );

    res.status(200).json({
      success: true,
      message: "Keranjang berhasil diambil.",
      data: {
        cart_id: cartId,
        items: result.rows,
        total,
      },
    });
  } catch (error) {
    console.error("Get cart error:", error);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// POST Menambahkan produk ke keranjang
const addCartItem = async (req, res) => {
  try {
    const userId = req.user.id;
    const { product_id, quantity } = req.body;

    if (
      !Number.isInteger(Number(product_id)) ||
      !Number.isInteger(Number(quantity)) ||
      Number(product_id) <= 0 ||
      Number(quantity) <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Product ID dan quantity harus berupa bilangan bulat positif.",
      });
    }

    const productResult = await pool.query(
      "SELECT id, stock FROM products WHERE id = $1",
      [product_id],
    );

    if (productResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Produk tidak ditemukan.",
      });
    }

    const stock = productResult.rows[0].stock;

    let cartResult = await pool.query(
      "SELECT id FROM carts WHERE user_id = $1",
      [userId],
    );

    if (cartResult.rows.length === 0) {
      cartResult = await pool.query(
        `INSERT INTO carts (user_id)
          VALUES ($1)
          RETURNING id`,
        [userId],
      );
    }

    const cartId = cartResult.rows[0].id;

    const existingItem = await pool.query(
      `SELECT id, quantity
        FROM cart_items
        WHERE cart_id = $1 AND product_id = $2`,
      [cartId, product_id],
    );

    const newQuantity =
      Number(quantity) +
      (existingItem.rows.length > 0
        ? Number(existingItem.rows[0].quantity)
        : 0);

    if (newQuantity > stock) {
      return res.status(400).json({
        success: false,
        message: "Jumlah produk melebihi stok yang tersedia.",
      });
    }

    let result;

    if (existingItem.rows.length > 0) {
      result = await pool.query(
        `UPDATE cart_items
          SET quantity = $1, updated_at = CURRENT_TIMESTAMP
          WHERE id = $2
          RETURNING *`,
        [newQuantity, existingItem.rows[0].id],
      );
    } else {
      result = await pool.query(
        `INSERT INTO cart_items (cart_id, product_id, quantity)
          VALUES ($1, $2, $3)
          RETURNING *`,
        [cartId, product_id, Number(quantity)],
      );
    }

    res.status(201).json({
      success: true,
      message: "Produk berhasil ditambahkan ke keranjang.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Add cart item error:", error);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// PUT Mengubah jumlah produk dalam keranjang
const updateCartItem = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;
    const { quantity } = req.body;

    if (!Number.isInteger(Number(quantity)) || Number(quantity) <= 0) {
      return res.status(400).json({
        success: false,
        message: "Quantity harus berupa bilangan bulat positif.",
      });
    }

    const result = await pool.query(
      `UPDATE cart_items ci
        SET quantity = $1, updated_at = CURRENT_TIMESTAMP
        FROM carts c, products p
        WHERE ci.id = $2
          AND ci.cart_id = c.id
          AND ci.product_id = p.id
          AND c.user_id = $3
          AND $1 <= p.stock
        RETURNING ci.*`,
      [Number(quantity), id, userId],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Item tidak ditemukan atau jumlah melebihi stok.",
      });
    }

    res.status(200).json({
      success: true,
      message: "Jumlah produk berhasil diperbarui.",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Update cart item error:", error);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

// DELETE Menghapus produk dari keranjang
const deleteCartItem = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;

    const result = await pool.query(
      `DELETE FROM cart_items ci
        USING carts c
        WHERE ci.id = $1
          AND ci.cart_id = c.id
          AND c.user_id = $2
        RETURNING ci.*`,
      [id, userId],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Item keranjang tidak ditemukan.",
      });
    }

    res.status(200).json({
      success: true,
      message: "Produk berhasil dihapus dari keranjang.",
    });
  } catch (error) {
    console.error("Delete cart item error:", error);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server.",
    });
  }
};

module.exports = {
  getCart,
  addCartItem,
  updateCartItem,
  deleteCartItem,
};
