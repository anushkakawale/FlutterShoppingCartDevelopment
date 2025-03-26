class Product {
  final int id;
  final String title;
  final String brand;
  final String description;
  final double price;
  final double discountPercentage;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.brand,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.thumbnail,
    required this.images,
  });

  double get discountedPrice {
    return price - (price * discountPercentage / 100);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      brand: json['brand'],
      description: json['description'],
      price: json['price'].toDouble(),
      discountPercentage: json['discountPercentage'].toDouble(),
      thumbnail: json['thumbnail'],
      images: List<String>.from(json['images']),
    );
  }
}