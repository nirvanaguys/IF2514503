class ProductCategory {
  final String id;
  final String name;
  final String slug;
  final String? icon;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      if (icon != null) 'icon': icon,
    };
  }
}

