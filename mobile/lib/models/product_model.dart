class ProductModel {
  final int id;
  final int categoryId;
  final int companyId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? categoryName;
  final String? companyName;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.companyId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.categoryName,
    this.companyName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: int.parse(json['id'].toString()),
      categoryId: int.parse(json['category_id'].toString()),
      companyId: int.parse(json['company_id'].toString()),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'].toString()),
      stock: int.parse(json['stock'].toString()),
      imageUrl: json['image_url'] as String?,
      categoryName: json['category_name'] as String?,
      companyName: json['company_name'] as String?,
    );
  }
}
