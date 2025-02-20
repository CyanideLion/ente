import "package:photos/models/ml/face/detection.dart";
import 'package:photos/services/machine_learning/face_ml/face_filtering/face_filtering_constants.dart';
import "package:photos/services/machine_learning/ml_result.dart";

// FileInfo contains the image width and height of the image the face was detected in.
class FileInfo {
  int? imageWidth;
  int? imageHeight;
  FileInfo({
    this.imageWidth,
    this.imageHeight,
  });
}

class Face {
  final String faceID;
  final List<double> embedding;
  Detection detection;
  final double score;
  final double blur;

  ///#region Local DB fields
  // This is not stored on the server, using it for local DB row
  FileInfo? fileInfo;
  final int fileID;

  ///#endregion

  bool get isBlurry => blur < kLaplacianHardThreshold;

  bool get hasHighScore => score > kMinimumQualityFaceScore;

  bool get isHighQuality => (!isBlurry) && hasHighScore;

  Face(
    this.faceID,
    this.fileID,
    this.embedding,
    this.score,
    this.detection,
    this.blur, {
    this.fileInfo,
  });

  factory Face.empty(int fileID, {bool error = false}) {
    return Face(
      "${fileID}_0_0_0_0",
      fileID,
      <double>[],
      error ? -1.0 : 0.0,
      Detection.empty(),
      0.0,
    );
  }

  factory Face.fromJson(Map<String, dynamic> json) {
    final String faceID = json['faceID'] as String;
    final int fileID = getFileIdFromFaceId(faceID);
    return Face(
      faceID,
      fileID,
      parseAsDoubleList(json['embedding'] as List),
      json['score'] as double,
      Detection.fromJson(json['detection'] as Map<String, dynamic>),
      // high value means t
      (json['blur'] ?? kLapacianDefault) as double,
    );
  }

  // Note: Keep the information in toJson minimum. Keep in sync with desktop.
  // Derive fields like fileID from other values whenever possible
  Map<String, dynamic> toJson() => {
        'faceID': faceID,
        'embedding': embedding,
        'detection': detection.toJson(),
        'score': score,
        'blur': blur,
      };
}

List<double> parseAsDoubleList(List<dynamic> inputList) {
  if (inputList.isEmpty) return const [];

  if (inputList is List<double>) return inputList;
  return List<double>.generate(
    inputList.length,
    (index) {
      final value = inputList[index];
      if (value is int) return value.toDouble();
      if (value is double) return value;
      throw FormatException(
        'Invalid type at index $index: ${value.runtimeType}',
      );
    },
    growable: false,
  );
}
