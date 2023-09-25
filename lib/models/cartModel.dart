class CartModel {
  int? id;
  String? name;
  String? desc;
  String? image;
  int? quantity;
  String? regularprice;
  String? saleprice;
  int? onsale;
  String? rating;
  int? reviewcount;
  String? slug;

  CartModel(
      {this.id,
      this.name,
      this.desc,
      this.image,
      this.quantity,
      this.regularprice,
      this.saleprice,
      this.onsale,
      this.rating,
      this.reviewcount,
      this.slug});

  factory CartModel.fromMap(Map<String, dynamic> json) => CartModel(
        id: json["id"],
        name: json["name"],
        desc: json["desc"],
        image: json["image"],
        quantity: json["quantity"],
        regularprice: json["regularprice"],
        saleprice: json["saleprice"],
        onsale: json["onsale"],
        rating: json["rating"],
        reviewcount: json["reviewcount"],
        slug: json["slug"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "desc": desc,
        "image": image,
        "quantity": quantity,
        "regularprice": regularprice,
        "saleprice": saleprice,
        "onsale": onsale,
        "rating": rating,
        "reviewcount": reviewcount,
        "slug": slug,
      };
}
