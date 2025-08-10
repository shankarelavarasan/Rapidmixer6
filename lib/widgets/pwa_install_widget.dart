import 'package:flutter/material.dart';
import '../services/pwa_service.dart';
import '../core/utils/glassmorphism_utils.dart';
import '../theme/app_theme.dart';

class PWAInstallWidget extends StatefulWidget {
  final bool showAsFloatingButton;
  final bool showAsCard;
  
  const PWAInstallWidget({
    Key? key,
    this.showAsFloatingButton = false,
    this.showAsCard = true,
  }) : super(key: key);

  @override
  _PWAInstallWidgetState createState() => _PWAInstallWidgetState();
}

class _PWAInstallWidgetState extends State<PWAInstallWidget> {
  bool _isVisible = true;
  
  @override
  void initState() {
    super.initState();
    _checkInstallStatus();
  }
  
  void _checkInstallStatus() {
    final status = PWAService.getStatus();
    setState(() {
      _isVisible = status['canInstall'] && status['isSupported'];
    });
  }
  
  Future<void> _handleInstall() async {
    final success = await PWAService.promptInstall();
    if (success) {
      setState(() {
        _isVisible = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Install prompt shown! Check your browser.'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      _showInstallInstructions();
    }
  }
  
  void _showInstallInstructions() {
    final instructions = PWAService.getInstallInstructions();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.install_mobile, color: AppTheme.accentColor),
            SizedBox(width: 8),
            Text(
              'Install RapidMixer',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Install RapidMixer as a Progressive Web App for the best experience:',
              style: TextStyle(color: AppTheme.textMediumEmphasisDark),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.accentColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                instructions,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '✨ Benefits of installing:',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...[
              '📱 App-like experience',
              '🚀 Faster loading',
              '📴 Offline access',
              '🔔 Push notifications',
              '🏠 Home screen icon',
            ].map((benefit) => Padding(
              padding: EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                benefit,
                style: TextStyle(color: AppTheme.textMediumEmphasisDark),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Maybe Later',
              style: TextStyle(color: AppTheme.textMediumEmphasisDark),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isVisible = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.black,
            ),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }
  
  void _dismiss() {
    setState(() {
      _isVisible = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return SizedBox.shrink();
    
    if (widget.showAsFloatingButton) {
      return FloatingActionButton.extended(
        onPressed: _handleInstall,
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.black,
        icon: Icon(Icons.install_mobile),
        label: Text('Install App'),
      );
    }
    
    if (widget.showAsCard) {
      return Container(
        margin: EdgeInsets.all(16),
        child: GlassmorphismUtils.createGlassContainer(
          borderRadius: 16,
          blur: 15.0,
          opacity: 0.2,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.install_mobile,
                      color: AppTheme.accentColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Install RapidMixer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Get the full app experience',
                          style: TextStyle(
                            color: AppTheme.textMediumEmphasisDark,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _dismiss,
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.textMediumEmphasisDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showInstallInstructions,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.accentColor),
                        foregroundColor: AppTheme.accentColor,
                      ),
                      child: Text('Learn How'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleInstall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.black,
                      ),
                      child: Text('Install'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    
    return SizedBox.shrink();
  }
}