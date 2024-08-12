import 'dart:math';

import 'package:flutter/material.dart';

class ReactionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String text;
  final Function() onReaction;
  const ReactionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
    required this.onReaction,
  });

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton>
    with TickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();
  final double _maxIconSize = 2;

  late AnimationController _animationController;
  late Animation<Offset> _animationOffset;

  bool _isPanning = false;
  Offset _initialPanPosition = Offset.zero;
  double _panMaxDistance = 0.0;
  double _panDistance = 0.0;

  Offset get _containerPosition {
    RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final centerX = offset.dx + (size.width / 2);
    final centerY = offset.dy + (size.height / 2);
    return Offset(centerX, centerY);
  }

  @override
  void initState() {
    _initAnimations();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _initialPanPosition = details.globalPosition;
          _animationController.forward();
        });
      },
      onPanUpdate: (details) {
        setState(() {
          double delta =
              _calculateDistance(_initialPanPosition, details.globalPosition);
          if (delta > 1 || _isPanning) {
            if (!_isPanning) {
              _isPanning = true;
              _panMaxDistance =
                  _calculateDistance(_initialPanPosition, _containerPosition);
            }

            _panDistance =
                _calculateDistance(_containerPosition, details.globalPosition);
          }
        });
      },
      onPanEnd: (details) {
        setState(() {
          if (_isPanning && _panDistance < _panMaxDistance / 3) {
            widget.onReaction();
          }

          _isPanning = false;
          _panDistance = 0;
          _initialPanPosition = Offset.zero;
          _animationController.reverse();
        });
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: _animationOffset.value,
            child: Transform.scale(
              scale: _isPanning
                  ? _calculateScale(_panDistance, _panMaxDistance)
                  : 1.0,
              child: Container(
                key: _key,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0D000000),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 21.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _animationOffset = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, -100.0),
    ).animate(_animationController);
  }

  double _calculateDistance(Offset posA, Offset posB) {
    final dx = posB.dx - posA.dx;
    final dy = posB.dy - posA.dy;
    return sqrt((dx * dx) + (dy * dy));
  }

  double _calculateScale(double distance, double maxDistance) {
    if (distance < 0) {
      distance = 0;
    } else if (distance > maxDistance) {
      distance = maxDistance;
    }

    return min(_maxIconSize,
        _maxIconSize - ((_maxIconSize - 1) * (distance / maxDistance)));
  }
}
