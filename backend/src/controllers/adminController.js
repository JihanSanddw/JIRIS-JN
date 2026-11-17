const getDashboard = async (req, res) => {
  return res.status(200).json({
    success: true,
    message: "Selamat datang di Dashboard Admin JIRIS!",
    data: {
      user_id: req.user.id,
      role: req.user.role,
      permissions: [
        "manage_products",
        "manage_categories"
        // "manage_orders",
        // "manage_stock"
      ]
    }
  });
};

module.exports = {
  getDashboard
};
