/// Idle Screen Widget
/// Shows marketing content when no active order
/// Following Odoo POS customer display patterns
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

import '../../../../data/models/customer_display_models.dart';

/// Idle Screen
/// Displays marketing content when display is idle
class IdleScreen extends StatefulWidget {
  final MarketingContent? content;

  const IdleScreen({
    super.key,
    this.content,
  });

  @override
  State<IdleScreen> createState() => _IdleScreenState();
}

class _IdleScreenState extends State<IdleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for welcome text
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content ?? MarketingContent.welcome();

    return Container(
      color: VodoColors.backgroundPrimary,
      child: Center(
        child: _buildContent(context, content),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MarketingContent content) {
    switch (content.type) {
      case MarketingContentType.welcome:
        return _buildWelcomeContent(context, content);

      case MarketingContentType.promotion:
        return _buildPromotionContent(context, content);

      case MarketingContentType.storeInfo:
        return _buildStoreInfoContent(context, content);

      case MarketingContentType.video:
        return _buildVideoContent(context, content);
    }
  }

  Widget _buildWelcomeContent(
      BuildContext context, MarketingContent content) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated icon
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: VodoColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.waving_hand,
              size: 120,
              color: VodoColors.primary,
            ),
          ),
        ),

        const SizedBox(height: 48),

        // Welcome title
        ScaleTransition(
          scale: _pulseAnimation,
          child: Text(
            content.title ?? 'Welcome!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w900,
              color: VodoColors.primary,
              letterSpacing: 4,
              height: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Subtitle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          decoration: BoxDecoration(
            color: VodoColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            content.subtitle ?? 'Your order will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              color: VodoColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(height: 64),

        // Additional info
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeatureBadge(
              icon: Icons.flash_on,
              label: 'Fast Service',
            ),
            const SizedBox(width: 32),
            _buildFeatureBadge(
              icon: Icons.restaurant_menu,
              label: 'Quality Food',
            ),
            const SizedBox(width: 32),
            _buildFeatureBadge(
              icon: Icons.favorite,
              label: 'Made with Love',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPromotionContent(
      BuildContext context, MarketingContent content) {
    return Container(
      padding: const EdgeInsets.all(64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Promo badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: VodoColors.danger,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              'SPECIAL OFFER',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: VodoColors.textOnPrimary,
                letterSpacing: 3,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Promotion image (if available)
          if (content.imageUrl != null) ...[
            Container(
              height: 300,
              width: 500,
              decoration: BoxDecoration(
                color: VodoColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: NetworkImage(content.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],

          // Title
          Text(
            content.title ?? 'Special Offer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: VodoColors.primary,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 24),

          // Subtitle/details
          if (content.subtitle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              decoration: BoxDecoration(
                color: VodoColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                content.subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  color: VodoColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreInfoContent(
      BuildContext context, MarketingContent content) {
    return Container(
      padding: const EdgeInsets.all(64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            content.title ?? 'About Us',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: VodoColors.primary,
            ),
          ),

          const SizedBox(height: 48),

          // Info cards
          ...content.bulletPoints.map((point) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: VodoColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: VodoColors.border,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 32,
                      color: VodoColors.success,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      point,
                      style: TextStyle(
                        fontSize: 28,
                        color: VodoColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVideoContent(BuildContext context, MarketingContent content) {
    // Placeholder for video content
    return Container(
      padding: const EdgeInsets.all(64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 400,
            width: 600,
            decoration: BoxDecoration(
              color: VodoColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 120,
                color: VodoColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (content.title != null)
            Text(
              content.title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: VodoColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: VodoColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: VodoColors.border,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: VodoColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: VodoColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
