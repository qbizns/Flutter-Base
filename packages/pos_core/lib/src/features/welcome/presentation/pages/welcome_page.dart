import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../application/welcome_controller.dart';
import '../../domain/entities/welcome_message.dart';
import '../widgets/welcome_header.dart';
import '../widgets/welcome_cta_section.dart';

/// Welcome page - the main landing screen of the app.
/// Displays a responsive welcome message with call-to-action buttons.
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(welcomeControllerProvider);

    return AppScaffold(
      body: SafeArea(
        child: state.isLoading
            ? const _LoadingView()
            : state.error != null
                ? _ErrorView(error: state.error!)
                : state.message != null
                    ? _ContentView(state: state)
                    : const _LoadingView(),
      ),
    );
  }
}

/// Loading view for welcome page.
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// Error view for welcome page.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Content view for welcome page.
class _ContentView extends ConsumerWidget {
  const _ContentView({required this.state});

  final WelcomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = state.message!;
    final controller = ref.read(welcomeControllerProvider.notifier);

    return ResponsiveLayout(
      mobile: _MobileLayout(
        message: message,
        controller: controller,
      ),
      tablet: _TabletLayout(
        message: message,
        controller: controller,
      ),
      desktop: _DesktopLayout(
        message: message,
        controller: controller,
      ),
    );
  }
}

/// Mobile layout for welcome page.
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.message,
    required this.controller,
  });

  final WelcomeMessage message;
  final WelcomeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsivePadding.getHorizontalPadding(context),
        vertical: ResponsivePadding.getVerticalPadding(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WelcomeHeader(
            title: message.title,
            tagline: message.tagline,
          ),
          const SizedBox(height: 48),
          Text(
            message.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          WelcomeCtaSection(
            primaryButtonText: message.primaryButtonText,
            secondaryButtonText: message.secondaryButtonText,
            onPrimaryPressed: controller.onGetStarted,
            onSecondaryPressed: controller.onLearnMore,
          ),
        ],
      ),
    );
  }
}

/// Tablet layout for welcome page.
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.message,
    required this.controller,
  });

  final WelcomeMessage message;
  final WelcomeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsivePadding.getHorizontalPadding(context),
          vertical: ResponsivePadding.getVerticalPadding(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WelcomeHeader(
              title: message.title,
              tagline: message.tagline,
            ),
            const SizedBox(height: 56),
            Text(
              message.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 56),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: WelcomeCtaSection(
                primaryButtonText: message.primaryButtonText,
                secondaryButtonText: message.secondaryButtonText,
                onPrimaryPressed: controller.onGetStarted,
                onSecondaryPressed: controller.onLearnMore,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop layout for welcome page.
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.message,
    required this.controller,
  });

  final WelcomeMessage message;
  final WelcomeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsivePadding.getContentMaxWidth(context),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsivePadding.getHorizontalPadding(context),
          vertical: ResponsivePadding.getVerticalPadding(context),
        ),
        child: Row(
          children: [
            // Left side: Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeHeader(
                    title: message.title,
                    tagline: message.tagline,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    message.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: WelcomeCtaSection(
                      primaryButtonText: message.primaryButtonText,
                      secondaryButtonText: message.secondaryButtonText,
                      onPrimaryPressed: controller.onGetStarted,
                      onSecondaryPressed: controller.onLearnMore,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 80),

            // Right side: Illustration/Visual
            Expanded(
              child: Center(
                child: _IllustrationPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Illustration panel for desktop layout.
class _IllustrationPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(
          Icons.devices,
          size: 200,
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }
}
