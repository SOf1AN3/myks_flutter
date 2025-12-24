import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/radio_provider.dart';
import '../../services/icecast_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/common_widgets.dart';

/// Admin screen for configuring radio stream
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  bool _isLoading = false;
  bool _isTesting = false;
  bool? _streamOnline;
  String? _testMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    final radioProvider = context.read<RadioProvider>();
    _urlController.text = radioProvider.streamUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Administration', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(isDark).animate().fadeIn(),

                const SizedBox(height: 32),

                // Stream URL section
                _buildStreamUrlSection(isDark)
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 100))
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // Stream status
                if (_streamOnline != null || _testMessage != null)
                  _buildStatusCard(
                    isDark,
                  ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 32),

                // Action buttons
                _buildActionButtons(
                  isDark,
                ).animate().fadeIn(delay: const Duration(milliseconds: 200)),

                const SizedBox(height: 32),

                // Info card
                _buildInfoCard(
                  isDark,
                ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings,
                color: AppColors.primaryLight,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuration',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  Text(
                    'Gérez les paramètres du flux radio',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreamUrlSection(bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                size: 20,
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
              ),
              const SizedBox(width: 8),
              Text(
                'URL du flux Icecast',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'http://stream.example.com:8000/stream',
              prefixIcon: const Icon(Icons.radio),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _urlController.clear(),
              ),
            ),
            keyboardType: TextInputType.url,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une URL';
              }
              if (!value.startsWith('http://') &&
                  !value.startsWith('https://')) {
                return 'L\'URL doit commencer par http:// ou https://';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: _isTesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: Text(_isTesting ? 'Test en cours...' : 'Vérifier le flux'),
              onPressed: _isTesting ? null : _testStream,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    final isOnline = _streamOnline == true;
    final color = isOnline ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.check_circle : Icons.error,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Flux en ligne' : 'Flux hors ligne',
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
                if (_testMessage != null)
                  Text(
                    _testMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: 'Enregistrer',
            icon: Icons.save,
            isLoading: _isLoading,
            onPressed: _saveConfig,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: GradientOutlinedButton(
            text: 'Réinitialiser',
            icon: Icons.refresh,
            onPressed: _resetConfig,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.primaryLight.withOpacity(0.1),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryLight,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Information',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'L\'URL du flux Icecast doit pointer vers un serveur de streaming '
                  'compatible. Les formats MP3, OGG et AAC sont supportés.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkMutedForeground
                        : AppColors.lightMutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testStream() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
      _streamOnline = null;
      _testMessage = null;
    });

    try {
      final icecastService = IcecastService();
      final isOnline = await icecastService.testStreamUrl(_urlController.text);

      setState(() {
        _streamOnline = isOnline;
        _testMessage = isOnline
            ? 'Le flux est accessible et fonctionnel'
            : 'Impossible de se connecter au flux';
      });
    } catch (e) {
      setState(() {
        _streamOnline = false;
        _testMessage = 'Erreur: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final radioProvider = context.read<RadioProvider>();
      await radioProvider.setStreamUrl(_urlController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration enregistrée'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetConfig() {
    setState(() {
      _urlController.text = AppConstants.defaultStreamUrl;
      _streamOnline = null;
      _testMessage = null;
    });
  }
}
