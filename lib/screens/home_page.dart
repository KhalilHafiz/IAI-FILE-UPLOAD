import 'package:easy_upload/screens/drawer_screen.dart';
import 'package:easy_upload/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'document_upload_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';
class HomePage extends StatefulWidget {
  
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0; 

  // List of screens to display
  final List<Widget> _screens = [
    DashboardScreen(),
    SettingsScreen(),
    DrawerScreen(),
  ];

  // Update the selected index when a bottom navigation item is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${user?.email ?? 'User'}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickAction(Icons.upload_file, "Upload", context, DocumentUploadPage()),
                _quickAction(Icons.check_circle, "Status", context, null),
                _quickAction(Icons.help_outline, "Help", context, null),
              ],
            ),

            SizedBox(height: 30),

            Text("Uploaded Documents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            Expanded(
              child: ListView.builder(
                itemCount: 3, // Example count, replace with real data
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.insert_drive_file, color: Colors.blue),
                    title: Text("Document ${index + 1}"),
                    subtitle: Text("Status: Pending"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Drawer',
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, BuildContext context, Widget? page) {
    return InkWell(
      onTap: page != null ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)) : null,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
