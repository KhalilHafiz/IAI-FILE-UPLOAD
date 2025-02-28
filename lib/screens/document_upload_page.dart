import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_upload/models/document.dart';
import 'package:easy_upload/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DocumentUploadPage extends StatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

final auth = AuthService();
FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final candidate = auth.getCurrentUser();
  Uint8List? _selectedFileBytes; // To store the file bytes
  String? _selectedFileName;
  bool _isUploading = false;
  final String status = "pending"; // Prefilled status
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _candidateIdController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _uploadDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill candidateId, status, and uploadDate
    _candidateIdController.text = candidate!.uid;
    _nameController.text = _selectedFileName ?? "my file";
    _statusController.text = status;
    _uploadDateController.text = DateTime.now().toIso8601String().split('T')[0];
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // Access the bytes and name of the selected file
      Uint8List? fileBytes = result.files.single.bytes;
      String? fileName = result.files.single.name;
      if (fileBytes != null && fileName != null) {
        setState(() {
          _selectedFileBytes = fileBytes;
          _selectedFileName = fileName;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load file bytes or name!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No file selected!")),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFileBytes == null || _selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No file selected!")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await Future.delayed(Duration(seconds: 5));
      // Generate a unique file name
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          "_" +
          _selectedFileName!;

      // Reference to Firebase Storage
      Reference storageRef =
          FirebaseStorage.instance.ref().child('uploads/$fileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageRef.putData(_selectedFileBytes!);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL of the uploaded file
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Create a Document object
      Document document = Document(
        id: DateTime.now().toString(), // Unique ID for the document
        candidateId: _candidateIdController.text,
        name: _nameController.text,
        filePath: downloadURL, // Store the download URL
        uploadDate: DateTime.now(),
        status: status,
      );

      // Save the document metadata to Firestore
      await _firestore.collection('candidates').doc(candidate!.uid).update({
        'documents': FieldValue.arrayUnion([document.toJson()]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload Successful!")),
      );
    } on TimeoutException {
      // Handle timeout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload Failed: Operation timed out")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload Failed: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Document")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display selected file
              _selectedFileName != null
                  ? Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file,
                              color: Colors.blue, size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_selectedFileName!.split('/').last),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                setState(() => _selectedFileName = null),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.upload_file,
                                size: 50, color: Colors.blue),
                            SizedBox(height: 10),
                            Text("Select a Document"),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.folder_open),
                label: const Text("Choose File"),
                onPressed: _pickFile,
              ),

              const SizedBox(height: 20),

              // Document Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Document Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Enter document name' : null,
              ),
              const SizedBox(height: 20),

              // Candidate ID Field (Read-only)
              TextFormField(
                obscureText: true,
                controller: _candidateIdController,
                readOnly: true, // Make the field read-only
                decoration: const InputDecoration(
                  labelText: "Candidate ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Status Field (Read-only)
              TextFormField(
                controller: _statusController,
                readOnly: true, // Make the field read-only
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Upload Date Field (Read-only)
              TextFormField(
                controller: _uploadDateController,
                readOnly: true, // Make the field read-only
                decoration: const InputDecoration(
                  labelText: "Upload Date",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Upload Button
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: _uploadFile,
                      child: const Text("Upload"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
