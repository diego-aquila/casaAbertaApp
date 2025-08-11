import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final int rating;
  final Function(int) onRatingChanged;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const StarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.maxRating = 5,
    this.size = 40.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1;
            });
            widget.onRatingChanged(_currentRating);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Icon(
              index < _currentRating ? Icons.star : Icons.star_border,
              color: index < _currentRating 
                  ? widget.activeColor 
                  : widget.inactiveColor,
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}