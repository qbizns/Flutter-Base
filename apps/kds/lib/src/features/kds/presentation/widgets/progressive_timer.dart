/// Progressive Timer Widget
/// Timer with color progression following Odoo KDS patterns
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Progressive Timer Widget
/// Shows elapsed time with color changes based on thresholds
/// Following Odoo KDS urgency indicators
class ProgressiveTimer extends StatefulWidget {
  final DateTime startTime;
  final int normalThreshold; // Minutes - Green to Yellow
  final int warningThreshold; // Minutes - Yellow to Red
  final bool showIcon;
  final bool showWarning;
  final double fontSize;

  const ProgressiveTimer({
    super.key,
    required this.startTime,
    this.normalThreshold = 10,
    this.warningThreshold = 15,
    this.showIcon = true,
    this.showWarning = true,
    this.fontSize = 14,
  });

  @override
  State<ProgressiveTimer> createState() => _ProgressiveTimerState();
}

class _ProgressiveTimerState extends State<ProgressiveTimer>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _elapsedMinutes = 0;
  int _elapsedSeconds = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation for delayed orders
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start timer
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _updateElapsed() {
    final now = DateTime.now();
    final elapsed = now.difference(widget.startTime);

    setState(() {
      _elapsedMinutes = elapsed.inMinutes;
      _elapsedSeconds = elapsed.inSeconds % 60;
    });

    // Start pulse animation if delayed
    if (_elapsedMinutes >= widget.warningThreshold) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  Color _getTimerColor() {
    if (_elapsedMinutes >= widget.warningThreshold) {
      return VodoColors.danger; // Red - Delayed
    } else if (_elapsedMinutes >= widget.normalThreshold) {
      return VodoColors.warning; // Yellow - Warning
    } else {
      return VodoColors.success; // Green - On time
    }
  }

  IconData _getTimerIcon() {
    if (_elapsedMinutes >= widget.warningThreshold) {
      return Icons.warning; // Warning icon for delayed
    } else {
      return Icons.timer; // Normal timer icon
    }
  }

  String _getTimerText() {
    if (_elapsedMinutes < 60) {
      // Show minutes for orders less than 1 hour
      return '${_elapsedMinutes}m';
    } else {
      // Show hours:minutes for orders over 1 hour
      final hours = _elapsedMinutes ~/ 60;
      final minutes = _elapsedMinutes % 60;
      return '${hours}h ${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTimerColor();
    final isDelayed = _elapsedMinutes >= widget.warningThreshold;

    Widget timerWidget = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isDelayed
            ? Colors.white
            : Colors.white.withOpacity(0.2),
        borderRadius: VodoDimensions.borderRadiusSm,
        border: isDelayed ? Border.all(color: color, width: 2) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showWarning && isDelayed) ...[
            Icon(
              Icons.warning,
              size: widget.fontSize + 2,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          if (widget.showIcon) ...[
            Icon(
              _getTimerIcon(),
              size: widget.fontSize + 2,
              color: isDelayed ? color : VodoColors.textOnPrimary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            _getTimerText(),
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w700,
              color: isDelayed ? color : VodoColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );

    // Add pulse animation if delayed
    if (isDelayed) {
      timerWidget = ScaleTransition(
        scale: _pulseAnimation,
        child: timerWidget,
      );
    }

    return timerWidget;
  }
}

/// Target Timer Widget
/// Shows countdown to target completion time
/// Following Odoo KDS preparation time tracking
class TargetTimer extends StatefulWidget {
  final DateTime startTime;
  final int targetMinutes;
  final bool showProgress;

  const TargetTimer({
    super.key,
    required this.startTime,
    required this.targetMinutes,
    this.showProgress = true,
  });

  @override
  State<TargetTimer> createState() => _TargetTimerState();
}

class _TargetTimerState extends State<TargetTimer> {
  Timer? _timer;
  int _remainingSeconds = 0;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final targetTime = widget.startTime.add(
      Duration(minutes: widget.targetMinutes),
    );
    final remaining = targetTime.difference(now);

    setState(() {
      _remainingSeconds = remaining.inSeconds;
      _progress = 1.0 - (remaining.inSeconds / (widget.targetMinutes * 60));

      // Clamp progress between 0 and 1
      _progress = _progress.clamp(0.0, 1.0);
    });
  }

  Color _getProgressColor() {
    if (_remainingSeconds <= 0) {
      return VodoColors.danger; // Overdue
    } else if (_progress > 0.8) {
      return VodoColors.warning; // Running out of time
    } else {
      return VodoColors.success; // On track
    }
  }

  String _getRemainingText() {
    if (_remainingSeconds <= 0) {
      final overdue = -_remainingSeconds;
      final minutes = overdue ~/ 60;
      return '+${minutes}m'; // Show overdue time
    } else {
      final minutes = _remainingSeconds ~/ 60;
      final seconds = _remainingSeconds % 60;
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getProgressColor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer display
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _remainingSeconds <= 0 ? Icons.warning : Icons.timer,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              _getRemainingText(),
              style: VodoTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '/ ${widget.targetMinutes}m',
              style: VodoTextStyles.caption.copyWith(
                color: VodoColors.textSecondary,
              ),
            ),
          ],
        ),

        // Progress bar
        if (widget.showProgress) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: 120,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: VodoColors.backgroundSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Simple elapsed timer display
class SimpleElapsedTimer extends StatefulWidget {
  final DateTime startTime;
  final TextStyle? style;
  final bool showSeconds;

  const SimpleElapsedTimer({
    super.key,
    required this.startTime,
    this.style,
    this.showSeconds = false,
  });

  @override
  State<SimpleElapsedTimer> createState() => _SimpleElapsedTimerState();
}

class _SimpleElapsedTimerState extends State<SimpleElapsedTimer> {
  Timer? _timer;
  String _elapsed = '0m';

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateElapsed() {
    final now = DateTime.now();
    final diff = now.difference(widget.startTime);

    setState(() {
      if (widget.showSeconds && diff.inMinutes < 1) {
        _elapsed = '${diff.inSeconds}s';
      } else if (diff.inMinutes < 60) {
        _elapsed = '${diff.inMinutes}m';
      } else {
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        _elapsed = '${hours}h ${minutes}m';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _elapsed,
      style: widget.style ?? VodoTextStyles.bodyMedium,
    );
  }
}
