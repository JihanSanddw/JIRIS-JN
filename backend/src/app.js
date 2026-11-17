const express = require("express");
const cors = require("cors");
require("dotenv").config();

const pool = require("./config/database");

const app = express();

const PORT = process.env.PORT || 3663;

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "Welcome to JIRIS API!"
  });
});

app.get("/db-test", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT NOW() AS server_time, current_database() AS database_name"
    );

    res.status(200).json({
      success: true,
      message: "JIRIS berhasil terhubung ke PostgreSQL Aiven!",
      data: result.rows[0]
    });
  } catch (error) {
    console.error("Database error:", error.message);

    res.status(500).json({
      success: false,
      message: "Koneksi database gagal."
    });
  }
});

const authRoutes = require("./routes/authRoutes");
app.use("/api/auth", authRoutes);

const userRoutes = require("./routes/userRoutes");
app.use("/api/users", userRoutes);

const adminRoutes = require("./routes/adminRoutes");
app.use("/api/admin", adminRoutes);

const categoryRoutes = require("./routes/categoryRoutes");
app.use("/api/categories", categoryRoutes);

const productRoutes = require("./routes/productRoutes");
app.use("/api/products", productRoutes);



app.listen(PORT, () => {
  console.log(`JIRIS API running on port ${PORT}`);
});
