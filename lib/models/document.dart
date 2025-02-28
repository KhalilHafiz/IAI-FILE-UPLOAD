class Document {
  String? id;
  String name;
  String? filePath;
  DateTime uploadDate;
  String status; // e.g., "Pending", "Approved", "Rejected"
  String candidateId; // ID of the candidate who uploaded the document

  Document({
    this.id,
    required this.name,
    this.filePath,
    required this.uploadDate,
    required this.candidateId, // Add candidateId as a required field
    this.status = "Pending",
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'],
      filePath: json['filePath'],
      uploadDate: DateTime.parse(json['uploadDate']),
      candidateId: json['candidateId'], // Parse candidateId from JSON
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filePath': filePath,
      'uploadDate': uploadDate.toIso8601String(),
      'candidateId': candidateId, // Include candidateId in JSON
      'status': status,
    };
  }
}