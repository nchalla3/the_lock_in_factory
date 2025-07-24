import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  // Simplified mock data based on wireframe
  final List<Map<String, dynamic>> _activeTasks = [
    {'title': 'Interview practice', 'type': 'Today'},
    {'title': 'Gym', 'type': 'Today'},
  ];

  final List<Map<String, dynamic>> _plannedTasks = [
    {'title': 'Systems architecture', 'type': 'Planned'},
  ];

  final List<Map<String, dynamic>> _onHoldTasks = [
    {'title': 'Marathon practice', 'type': 'On Hold'},
  ];

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        title,
        style: GoogleFonts.oswald(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF8D6E63),
        ),
      ),
    );
  }

  Widget _buildTaskItem(String title, String type) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.oswald(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type,
              style: GoogleFonts.oswald(
                fontSize: 12,
                color: const Color(0xFF8D6E63),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Locked-In',
          style: GoogleFonts.oswald(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF8D6E63),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await _authService.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (user?.displayName?.isNotEmpty == true
                      ? user!.displayName![0]
                      : user?.email?[0] ?? 'U').toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF8D6E63),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New Lock-In Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add new lock-in functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D6E63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'New Lock-In',
                    style: GoogleFonts.oswald(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Active Section
            _buildSectionHeader('Active'),
            ..._activeTasks.map((task) => _buildTaskItem(task['title'], task['type'])),
            
            const SizedBox(height: 24),

            // Planned Section
            _buildSectionHeader('Planned'),
            ..._plannedTasks.map((task) => _buildTaskItem(task['title'], task['type'])),
            
            const SizedBox(height: 24),

            // On Hold Section
            _buildSectionHeader('On Hold'),
            ..._onHoldTasks.map((task) => _buildTaskItem(task['title'], task['type'])),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
