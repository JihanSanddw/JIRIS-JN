const pool = require("../config/database");

// POST Checkout keranjang menjadi pesanan
const checkout = async (req, res) => {
  const client = await pool.connect();

  try {
    const userId = req.user.id;
    const {
      recipient_name,
      recipient_phone,
      shipping_address,
      notes
    } = req.body;

    if (
      !recipient_name?.trim() ||
      !recipient_phone?.trim() ||
      !shipping_address?.trim()
    ) {
      return res.status(400).json({
        success: false,
        message: "Nama penerima, nomor telepon, dan alamat wajib diisi."
      });
    }

    await client.query("BEGIN");

    const cartResult = await client.query(
      "SELECT id FROM carts WHERE user_id = $1 FOR UPDATE",
      [userId]
    );

    if (cartResult.rows.length === 0) {
      await client.query("ROLLBACK");
      return res.status(400).json({
        success: false,
        message: "Keranjang belanja tidak ditemukan."
      });
    }

    const cartId = cartResult.rows[0].id;

    const itemsResult = await client.query(
      `SELECT
        ci.product_id,
        ci.quantity,
        p.name,
        p.image_url,
        p.price,
        p.stock
       FROM cart_items ci
       JOIN products p ON ci.product_id = p.id
       WHERE ci.cart_id = $1
       ORDER BY p.id
       FOR UPDATE OF p`,
      [cartId]
    );

    if (itemsResult.rows.length === 0) {
      await client.query("ROLLBACK");
      return res.status(400).json({
        success: false,
        message: "Keranjang belanja masih kosong."
      });
    }

    for (const item of itemsResult.rows) {
      if (item.quantity > item.stock) {
        await client.query("ROLLBACK");
        return res.status(400).json({
          success: false,
          message: `Stok produk ${item.name} tidak mencukupi.`
        });
      }
    }

    const totalResult = await client.query(
      `SELECT COALESCE(SUM(p.price * ci.quantity), 0) AS total
       FROM cart_items ci
       JOIN products p ON ci.product_id = p.id
       WHERE ci.cart_id = $1`,
      [cartId]
    );

    const totalAmount = totalResult.rows[0].total;

    const orderResult = await client.query(
      `INSERT INTO orders (
        user_id,
        recipient_name,
        recipient_phone,
        shipping_address,
        notes,
        total_amount
      )
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *`,
      [
        userId,
        recipient_name.trim(),
        recipient_phone.trim(),
        shipping_address.trim(),
        notes?.trim() || null,
        totalAmount
      ]
    );

    const order = orderResult.rows[0];

    for (const item of itemsResult.rows) {
      const subtotal =
        Number(item.price) * Number(item.quantity);

      await client.query(
        `INSERT INTO order_items (
          order_id,
          product_id,
          product_name,
          product_image_url,
          quantity,
          unit_price,
          subtotal
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          order.id,
          item.product_id,
          item.name,
          item.image_url,
          item.quantity,
          item.price,
          subtotal
        ]
      );

      await client.query(
        `UPDATE products
         SET stock = stock - $1,
             updated_at = CURRENT_TIMESTAMP
         WHERE id = $2`,
        [item.quantity, item.product_id]
      );
    }

    await client.query(
      "DELETE FROM cart_items WHERE cart_id = $1",
      [cartId]
    );

    await client.query("COMMIT");

    res.status(201).json({
      success: true,
      message: "Checkout berhasil. Pesanan berhasil dibuat.",
      data: order
    });

  } catch (error) {
    await client.query("ROLLBACK");

    console.error("Checkout error:", error);

    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server."
    });
  } finally {
    client.release();
  }
};

// GET Melihat seluruh pesanan milik customer
const getMyOrders = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
        `SELECT
            o.*,
            COUNT(oi.id)::INTEGER AS total_items
        FROM orders o
        LEFT JOIN order_items oi ON o.id = oi.order_id
        WHERE o.user_id = $1
        GROUP BY o.id
        ORDER BY o.created_at DESC`,
        [userId]
    );

    res.status(200).json({
      success: true,
      message: "Riwayat pesanan berhasil diambil.",
      data: result.rows
    });

  } catch (error) {
    console.error("Get my orders error:", error);

    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server."
    });
  }
};

// GET Melihat detail pesanan customer
const getOrderDetail = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;

    // Mengambil informasi pesanan
    const orderResult = await pool.query(
      `SELECT
        o.*,
        COUNT(oi.id)::INTEGER AS total_items
       FROM orders o
       LEFT JOIN order_items oi ON o.id = oi.order_id
       WHERE o.id = $1 AND o.user_id = $2
       GROUP BY o.id`,
      [id, userId]
    );

    if (orderResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pesanan tidak ditemukan."
      });
    }

    // Mengambil detail produk dalam pesanan
    const itemsResult = await pool.query(
      `SELECT
        id,
        product_id,
        product_name,
        product_image_url,
        quantity,
        unit_price,
        subtotal
       FROM order_items
       WHERE order_id = $1
       ORDER BY id`,
      [id]
    );

    res.status(200).json({
      success: true,
      message: "Detail pesanan berhasil diambil.",
      data: {
        ...orderResult.rows[0],
        items: itemsResult.rows
      }
    });

  } catch (error) {
    console.error("Get order detail error:", error);

    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server."
    });
  }
};

// GET Admin melihat seluruh pesanan
const getAllOrders = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
        o.*,
        u.name AS customer_name,
        u.email AS customer_email
       FROM orders o
       JOIN users u ON o.user_id = u.id
       ORDER BY o.created_at DESC`
    );

    res.status(200).json({
      success: true,
      message: "Seluruh pesanan berhasil diambil.",
      data: result.rows
    });

  } catch (error) {
    console.error("Get all orders error:", error);

    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server."
    });
  }
};

// PUT Admin mengubah status pesanan
const updateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const allowedStatuses = [
      "pending",
      "confirmed",
      "processing",
      "shipped",
      "delivered",
      "cancelled"
    ];

    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Status pesanan tidak valid."
      });
    }

    const result = await pool.query(
      `UPDATE orders
       SET status = $1,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $2
       RETURNING *`,
      [status, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pesanan tidak ditemukan."
      });
    }

    res.status(200).json({
      success: true,
      message: "Status pesanan berhasil diperbarui.",
      data: result.rows[0]
    });

  } catch (error) {
    console.error("Update order status error:", error);

    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server."
    });
  }
};

module.exports = {
  checkout,
  getMyOrders,
  getOrderDetail,
  getAllOrders,
  updateOrderStatus
};
