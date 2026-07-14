import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';

class GradientBalanceCard extends StatelessWidget {
  const GradientBalanceCard({
    super.key,
    required this.allTimeBalance,
    required this.thisMonthBalance,
  });

  final num allTimeBalance;
  final num thisMonthBalance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurfaceHigh : AppColors.lightSurface;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientEnd.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Layer 1: dark base + drifting color blobs
            Positioned.fill(
              child: ColoredBox(
                color: baseColor,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _driftingBlob(
                      size: 180,
                      color: AppColors.seedLight.withValues(alpha: isDark ? 0.55 : 0.35),
                      left: -50,
                      top: -60,
                      duration: 9000,
                      moveX: 30,
                      moveY: 20,
                    ),
                    _driftingBlob(
                      size: 160,
                      color: AppColors.gradientMid.withValues(alpha: isDark ? 0.6 : 0.3),
                      right: -40,
                      top: 10,
                      duration: 11000,
                      moveX: -24,
                      moveY: 26,
                    ),
                    _driftingBlob(
                      size: 150,
                      color: AppColors.blobAccent.withValues(alpha: isDark ? 0.4 : 0.22),
                      left: 40,
                      bottom: -70,
                      duration: 7500,
                      moveX: 20,
                      moveY: -18,
                    ),
                  ],
                ),
              ),
            ),
            // Layer 2: frosted glass
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.35),
                  ),
                ),
              ),
            ),
            // Layer 3: content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All-time Balance',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _AnimatedAmount(amount: allTimeBalance),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'This Month',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                        ),
                        Text(
                          '${thisMonthBalance >= 0 ? '+' : ''}${CurrencyFormatter.format(thisMonthBalance)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color:
                                    thisMonthBalance >= 0 ? AppColors.income : AppColors.expense,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _driftingBlob({
    required double size,
    required Color color,
    required int duration,
    required double moveX,
    required double moveY,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveX(
            begin: -moveX,
            end: moveX,
            duration: Duration(milliseconds: duration),
            curve: Curves.easeInOut,
          )
          .moveY(
            begin: -moveY,
            end: moveY,
            duration: Duration(milliseconds: duration),
            curve: Curves.easeInOut,
          )
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.15, 1.15),
            duration: Duration(milliseconds: duration),
            curve: Curves.easeInOut,
          ),
    );
  }
}

class _AnimatedAmount extends StatelessWidget {
  const _AnimatedAmount({required this.amount});

  final num amount;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          CurrencyFormatter.format(value),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        );
      },
    );
  }
}
