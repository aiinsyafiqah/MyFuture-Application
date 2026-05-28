import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class CalendarStrip extends StatefulWidget {
  final DateTime initialDate;
  final int daysBefore;
  final int daysAfter;
  final ValueChanged<DateTime>? onDateSelected;

  CalendarStrip({
    Key? key,
    DateTime? initialDate,
    this.daysBefore = 7,
    this.daysAfter = 21,
    this.onDateSelected,
  })  : initialDate = initialDate ?? DateTime.now(),
        super(key: key);

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  static const double _dayItemExtent = 67;
  late final ScrollController _controller;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _selectedIndex = widget.daysBefore;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(_selectedIndex, animate: false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _totalDays => widget.daysBefore + widget.daysAfter + 1;

  DateTime _dateForIndex(int index) =>
      widget.initialDate.add(Duration(days: index - widget.daysBefore));

  void _onSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onDateSelected?.call(_dateForIndex(index));
    _scrollToIndex(index);
  }

  void _scrollToIndex(int index, {bool animate = true}) {
    if (!_controller.hasClients) return;
    final maxIndex = (_totalDays - 1).toDouble();
    final targetIndex = index.toDouble().clamp(0, maxIndex);
    final targetOffset = targetIndex * _dayItemExtent;
    if (animate) {
      _controller.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _controller.jumpTo(targetOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: _totalDays,
        itemBuilder: (context, index) {
          final date = _dateForIndex(index);
          final isSelected = index == _selectedIndex;
          final dayLabel = DateFormat('E').format(date);
          final dayNumber = DateFormat('d').format(date);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _onSelect(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? primaryColor : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayNumber,
                      style: TextStyle(
                        color: isSelected ? Colors.white : primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

