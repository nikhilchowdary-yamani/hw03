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
}
