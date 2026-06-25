import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/utils/stopwatch_manager.dart';

class StopwatchWidget extends StatefulWidget {
  const StopwatchWidget({
    super.key,
    required this.startTime,
    this.textStyle,
  });

  final DateTime startTime;
  final TextStyle? textStyle;

  @override
  State<StopwatchWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  late Duration _elapsedDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _elapsedDuration = StopwatchManager.calculateDuration(widget.startTime);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedDuration = StopwatchManager.calculateDuration(widget.startTime);
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant StopwatchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startTime != widget.startTime) {
      setState(() {
        _elapsedDuration = StopwatchManager.calculateDuration(widget.startTime);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = StopwatchManager.formatDuration(_elapsedDuration);
    return Text(
      formattedTime,
      style: widget.textStyle ??
          AppTextStyles.h1.copyWith(
            fontSize: 48,
            letterSpacing: 2.0,
            color: AppColors.accentBlue,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
    );
  }
}
