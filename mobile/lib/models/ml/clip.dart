import "dart:convert";

class ClipEmbedding {
  final int fileID;
  final List<double> embedding;
  int version;

  bool get isEmpty => embedding.isEmpty;

  ClipEmbedding({
    required this.fileID,
    required this.embedding,
    required this.version,
  });

  factory ClipEmbedding.empty(int fileID) {
    return ClipEmbedding(
      fileID: fileID,
      embedding: <double>[],
      version: 0,
    );
  }

  static List<double> decodeEmbedding(String embedding) {
    return List<double>.from(jsonDecode(embedding) as List);
  }

  static String encodeEmbedding(List<double> embedding) {
    return jsonEncode(embedding);
  }
}
