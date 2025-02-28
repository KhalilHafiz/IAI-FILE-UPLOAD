import 'package:easy_upload/models/document.dart';
import 'package:easy_upload/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class DownloadDocumentScreen extends StatelessWidget {
  final String candidateId;
  final FirestoreService fservice;

  DownloadDocumentScreen({required this.candidateId, required this.fservice});

  // Function to download a file from Firebase Storage
  Future<void> _downloadFile(String fileUrl, String fileName, BuildContext context) async {
    try {
      // Get the directory for saving the file
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$fileName');

      // Download the file
      final Reference ref = FirebaseStorage.instance.refFromURL(fileUrl);
      await ref.writeToFile(file);

      // Open the downloaded file
      OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Downloaded: $fileName")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download: $e")),
      );
    }
  }

  // Function to show a download confirmation dialog
  void _showDownloadDialog(BuildContext context, String fileName, String fileUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Download Document"),
          content: Text("Do you want to download $fileName?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _downloadFile(fileUrl, fileName, context); // Start the download
              },
              child: Text("Download"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Documents")),
      body: FutureBuilder<List<Document>>(
        future: fservice.getDocuments(candidateId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading documents"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No documents found"));
          } else {
            final documents = snapshot.data!;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return ListTile(
                  title: Text(document.name),
                  subtitle: Text("Uploaded on: ${document.uploadDate.toString()}"),
                  trailing: IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () {
                      _showDownloadDialog(context, document.name, document.filePath!);
                    },
                  ),
                  onTap: () {
                    _showDownloadDialog(context, document.name, document.filePath!);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}