class Image {
  final String idImage;
  final String imagePath;
  const Image({required this.idImage, required this.imagePath});

  factory Image.fromJson(Map<String, dynamic> json) =>
      Image(idImage: json['id_image'], 
      imagePath: json['image_path']);
}
