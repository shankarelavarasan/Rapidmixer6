import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_integration_service.dart';
import 'routes/app_routes.dart';
import 'core/utils/glassmorphism_utils.dart';
import 'core/utils/animation_utils.dart';
import 'core/utils/responsive_utils.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RapidMixer - AI-Powered Audio Mixing Platform',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.initial,
      onGenerateRoute: (settings) {
        // Add custom page transitions
        return AnimationUtils.createPageTransition(
          page: AppRoutes.routes[settings.name]!(context),
          type: PageTransitionType.fadeSlide,
          duration: AnimationUtils.normalDuration,
        );
      },
    );
  }
}

class RapidMixerHomePage extends StatefulWidget {
  @override
  _RapidMixerHomePageState createState() => _RapidMixerHomePageState();
}

class _RapidMixerHomePageState extends State<RapidMixerHomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AnimationUtils.slowDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AnimationUtils.normalDuration,
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: AnimationUtils.smoothCurve,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: AnimationUtils.defaultCurve,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    
    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppTheme.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: AnimationUtils.createFadeTransition(
                animation: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    AnimationUtils.createSlideTransition(
                      animation: _slideAnimation,
                      begin: const Offset(0.0, -0.5),
                      child: GlassmorphismUtils.createGlassContainer(
                        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                        blur: 15.0,
                        opacity: 0.2,
                        padding: ResponsiveUtils.getResponsivePadding(context),
                        child: Column(
                          children: [
                            AnimationUtils.createPulseAnimation(
                              animation: _pulseAnimation,
                              child: Icon(
                                Icons.music_note,
                                size: ResponsiveUtils.getResponsiveIconSize(context, 80),
                                color: AppTheme.accentColor,
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                            Text(
                              '🎵 RapidMixer',
                              style: AppTheme.textTheme.headlineLarge?.copyWith(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 32),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                            Text(
                              'AI-Powered Audio Mixing Platform',
                              style: AppTheme.textTheme.titleMedium?.copyWith(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                                color: AppTheme.textMediumEmphasisDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40)),
                  
                     // Features Grid
                     AnimationUtils.createSlideTransition(
                       animation: _slideAnimation,
                       begin: const Offset(0.0, 0.3),
                       child: LayoutBuilder(
                         builder: (context, constraints) {
                           final crossAxisCount = ResponsiveUtils.getResponsiveGridColumns(context);
                           return ResponsiveUtils.responsiveGridView(
                             context: context,
                             crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
                             mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
                             childAspectRatio: ResponsiveUtils.isTablet(context) ? 1.5 : 
                                              ResponsiveUtils.isMobile(context) ? 2.5 : 1.2,
                             children: [
                               _buildFeatureCard(
                                 '🤖 AI Stem Separation',
                                 'Advanced AI algorithms to separate vocals, drums, bass, and instruments',
                                 AppTheme.accentColor,
                               ),
                               _buildFeatureCard(
                                 '🎛️ Multi-Track Editor',
                                 'Professional mixing console with real-time effects and automation',
                                 AppTheme.primaryDark,
                               ),
                               _buildFeatureCard(
                                 '🎼 Beat Library',
                                 'AI-generated beats and comprehensive sound library',
                                 AppTheme.secondaryDark,
                               ),
                               _buildFeatureCard(
                                 '⚡ Real-Time Processing',
                                 'Low-latency audio processing with professional-grade effects',
                                 Colors.green,
                               ),
                             ],
                           );
                         },
                       ),
                     ),
                     SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40)),
                  
                     // Action Buttons
                     AnimationUtils.createSlideTransition(
                       animation: _slideAnimation,
                       begin: const Offset(0.0, 0.5),
                       child: ResponsiveUtils.responsiveRowColumn(
                         context: context,
                         children: [
                           _buildActionButton(
                             'Import Audio',
                             Icons.upload_file,
                             AppTheme.accentColor,
                             () => _navigateWithTransition(context, '/audio-import'),
                           ),
                           _buildActionButton(
                             'Start Mixing',
                             Icons.play_arrow,
                             Colors.green,
                             () => _navigateWithTransition(context, '/track-editor'),
                           ),
                           _buildActionButton(
                             'Test Backend',
                             Icons.cloud,
                             AppTheme.secondaryDark,
                             () => _testBackend(context),
                           ),
                         ],
                       ),
                     ),
                     SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),
                     
                     // Status
                     AnimationUtils.createFadeScaleTransition(
                       animation: _slideAnimation,
                       child: GlassmorphismUtils.createGlassContainer(
                         borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                         blur: 10.0,
                         opacity: 0.15,
                         padding: ResponsiveUtils.getResponsivePadding(context),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Icon(
                               Icons.check_circle,
                               color: Colors.green,
                               size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                             ),
                             SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                             Text(
                               'All Features Implemented & Ready',
                               style: AppTheme.textTheme.bodyMedium?.copyWith(
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                                 fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                               ),
                             ),
                           ],
                         ),
                       ),
                     ),
                     SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40)),
                     
                     // Version Footer
                     AnimationUtils.createFadeTransition(
                       animation: _slideAnimation,
                       child: GlassmorphismUtils.createGlassContainer(
                         borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
                         blur: 8.0,
                         opacity: 0.1,
                         padding: ResponsiveUtils.getResponsivePadding(context),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(
                               Icons.info_outline,
                               color: AppTheme.textLowEmphasisDark,
                               size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                             ),
                             SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                             Text(
                               'Rapid Mixer v6.0.1 • Built ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                               style: AppTheme.textTheme.bodySmall?.copyWith(
                                 color: AppTheme.textLowEmphasisDark,
                                 fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                               ),
                             ),
                           ],
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
         ),
       ),
     );
  }
  
  Widget _buildFeatureCard(String title, String description, Color color) {
    return GlassmorphismUtils.createGlassCard(
      borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
      blur: 12.0,
      opacity: 0.15,
      padding: ResponsiveUtils.getResponsivePadding(context),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.textTheme.titleMedium?.copyWith(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Expanded(
            child: Text(
              description,
              style: AppTheme.textTheme.bodySmall?.copyWith(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                color: AppTheme.textMediumEmphasisDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GlassmorphismUtils.createGlassButton(
      onPressed: onTap,
      borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context) * 2,
      blur: 15.0,
      opacity: 0.2,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
      ),
      glowColor: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: ResponsiveUtils.getResponsiveIconSize(context, 20),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Text(
            label,
            style: AppTheme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateWithTransition(BuildContext context, String route) {
    Navigator.of(context).push(
      AnimationUtils.createPageTransition(
        page: AppRoutes.routes[route]!(context),
        type: PageTransitionType.fadeSlide,
        duration: AnimationUtils.normalDuration,
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

// Remove these problematic lines completely:
// ElevatedButton(
//   onPressed: _testBackend,
//   child: Text('Test Backend'),
// ),
