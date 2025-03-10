class CardModel {
  final String id;
  final String image;
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.id,
    required this.image,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  CardModel copyWith({
    String? id,
    String? image,
    bool? isFaceUp,
    bool? isMatched,
  }) {
    return CardModel(
      id: id ?? this.id,
      image: image ?? this.image,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}