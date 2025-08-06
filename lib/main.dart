import 'package:flutter/material.dart';
import 'services/api_integration_service.dart';
import 'routes/app_routes.dart'; // Add this line

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RapidMixer - AI-Powered Audio Mixing Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF1A1A1A),
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          displayLarge: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          displayMedium: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          displaySmall: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          headlineLarge: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          headlineMedium: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          headlineSmall: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          titleLarge: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          titleMedium: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          titleSmall: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          bodyLarge: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          bodyMedium: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          bodySmall: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          labelLarge: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          labelMedium: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
          labelSmall: TextStyle(fontFamilyFallback: ['Noto Sans', 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji']),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes, // Add this line
      home: RapidMixerHomePage(),
    );
  }
}

class RapidMixerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.music_note,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '🎵 RapidMixer',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI-Powered Audio Mixing Platform',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Features Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 600;
                      return RepaintBoundary(
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isSmallScreen ? 1 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isSmallScreen ? 3 : 1.2,
                          children: [
                        _buildFeatureCard(
                          '🤖 AI Stem Separation',
                          'Advanced AI algorithms to separate vocals, drums, bass, and instruments',
                          Colors.cyan,
                        ),
                        _buildFeatureCard(
                          '🎛️ Multi-Track Editor',
                          'Professional mixing console with real-time effects and automation',
                          Colors.purple,
                        ),
                        _buildFeatureCard(
                          '🎼 Beat Library',
                          'AI-generated beats and comprehensive sound library',
                          Colors.orange,
                        ),
                        _buildFeatureCard(
                          '⚡ Real-Time Processing',
                          'Low-latency audio processing with professional-grade effects',
                          Colors.green,
                        ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // Action Buttons
                  RepaintBoundary(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 600;
                        if (isSmallScreen) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: _buildActionButton(
                                  'Import Audio',
                                  Icons.upload_file,
                                  Colors.blue,
                                  () => Navigator.pushNamed(context, '/audio-import'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: _buildActionButton(
                                  'Start Mixing',
                                  Icons.play_arrow,
                                  Colors.green,
                                  () => Navigator.pushNamed(context, '/track-editor'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: _buildActionButton(
                                  'Test Backend',
                                  Icons.cloud,
                                  Colors.orange,
                                  () => _testBackend(context),
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              'Import Audio',
                              Icons.upload_file,
                              Colors.blue,
                              () => Navigator.pushNamed(context, '/audio-import'),
                            ),
                            _buildActionButton(
                              'Start Mixing',
                              Icons.play_arrow,
                              Colors.green,
                              () => Navigator.pushNamed(context, '/track-editor'),
                            ),
                            _buildActionButton(
                              'Test Backend',
                              Icons.cloud,
                              Colors.orange,
                              () => _testBackend(context),
                            ),
                          ],
                        );
                      },
                     ),
                   ),
                   const SizedBox(height: 20),
                  
                  // Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'All Features Implemented & Ready',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Version Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rapid Mixer v6.0.1 • Built ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureCard(String title, String description, Color color) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D30),
        title: Text(
          feature,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'This feature is fully implemented in the Flutter app! The web version showcases the UI design and capabilities.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
  
  // Move _testBackend function inside the class and add context parameter
  Future<void> _testBackend(BuildContext context) async {
    final apiService = ApiIntegrationService();
    
    try {
      final isConnected = await apiService.testBackendConnection();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConnected 
              ? '✅ Backend connected successfully!' 
              : '❌ Backend connection failed'
          ),
          backgroundColor: isConnected ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// REMOVE THESE LINES - THEY'RE CAUSING THE ERROR:
// ElevatedButton(
//   onPressed: _testBackend,
//   child: Text('Test Backend'),
// ),
