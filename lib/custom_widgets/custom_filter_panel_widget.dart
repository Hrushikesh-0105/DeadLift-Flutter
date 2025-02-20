import 'package:deadlift/database_helper/database_helper.dart';
import 'package:deadlift/style.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CustomFilterPanelWidget extends StatefulWidget {
  final Function(String) filterFunction;
  const CustomFilterPanelWidget({required this.filterFunction, super.key});

  @override
  State<CustomFilterPanelWidget> createState() =>
      _CustomFilterPanelWidgetState();
}

class _CustomFilterPanelWidgetState extends State<CustomFilterPanelWidget> {
  int? _currentIndex;
  List<String> filters = [
    CustomerStatus.active,
    CustomerStatus.expired,
    CustomerStatus.expiredToday,
    CustomerStatus.inactive,
    CustomerStatus.due
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ToggleSwitch(
        minWidth: 90,
        activeBgColors: [
          [activeCustomerColor],
          [expiredCustomerColor],
          const [Color(0xffF2613F)],
          [inactiveCustomerColor],
          const [Color(0xff76ABAE)]
        ],
        activeFgColor: Colors.white,
        inactiveBgColor: Colors.black,
        inactiveFgColor: Colors.grey[700],
        animate: true,
        animationDuration: 250,
        cornerRadius: 12,
        totalSwitches: 5,
        customWidths: const [90, 90, 110, 90, 80],
        fontSize: 12,
        labels: const ['Active', 'Expired', 'Expired Today', 'Inactive', 'Due'],
        initialLabelIndex: _currentIndex,
        doubleTapDisable: true,
        onToggle: (index) {
          setState(() {
            _currentIndex = index;
          });
          widget.filterFunction(
              index != null ? filters[index] : CustomerFilter.all);
        },
      ),
    );
  }
}
