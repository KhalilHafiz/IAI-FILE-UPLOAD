import 'package:easy_upload/models/candidate.dart';
import 'package:easy_upload/services/auth_service.dart';
import 'package:easy_upload/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final auth_service = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _gender;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _passwordVisible = true;
  bool _isLoading = false;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final candidate = Candidate(
        name: _nameController.text.trim(),
        dob: _dobController.text.trim(),
        gender: _genderController.text.trim(),
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
      );
      try {
        final result = await auth_service.signUp(candidate);
        
        if (result != null) {

          String? id = result.uid;
          candidate.id = id;
          // Store user details in Firestore
          await _firestore
              .collection("users")
              .doc(result.uid)
              .set(candidate.toJson());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Signup Successful!")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }

      setState(() => _isLoading = false);
    }
  }

  void pickDate() async {
    String? date = await selectDate(context);

    setState(() => _dobController.text = date!);
  }

  void toggleVisibility() {
    setState(() => _passwordVisible = !_passwordVisible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: "Full Name", suffixIcon: Icon(Icons.person)),
                  validator: (value) =>
                      value!.isEmpty ? "Enter your name" : null),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: "Date of birth",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: pickDate, // Open date picker on icon tap
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your date of birth" : null,
                onTap: pickDate,
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  labelText: "Gender",
                ),
                items: [
                  DropdownMenuItem(
                    value: "male",
                    child: Text("male"),
                  ),
                  DropdownMenuItem(
                    value: "female",
                    child: Text("female"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select a gender" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: "Email", suffixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.contains("@") ? null : "Enter a valid email",
              ),
              TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                      labelText: "Address", suffixIcon: Icon(Icons.place)),
                  validator: (value) =>
                      value!.isEmpty ? "Enter your address" : null),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: _passwordVisible
                        ? Icon(Icons.visibility_off_outlined)
                        : Icon(Icons.visibility_outlined),
                    onPressed: toggleVisibility,
                  ),
                ),
                obscureText: _passwordVisible,
                validator: (value) =>
                    value!.length < 6 ? "At least 6 characters" : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  suffixIcon: IconButton(
                    icon: _passwordVisible
                        ? Icon(Icons.visibility_off_outlined)
                        : Icon(Icons.visibility_outlined),
                    onPressed: toggleVisibility,
                  ),
                ),
                obscureText: _passwordVisible,
                validator: (value) =>
                    value!.length < 6 ? "At least 6 characters" : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signup,
                      child: Text("Sign Up"),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
