import 'package:deadlift/database_helper/database_helper.dart';
import 'package:flutter/material.dart';

class PaymentModeSelector extends StatefulWidget {
  final Function(String) onModeSelected;
  final String initialMode;

  const PaymentModeSelector({
    Key? key,
    required this.onModeSelected,
    this.initialMode = PaymentMode.cash,
  }) : super(key: key);

  @override
  State<PaymentModeSelector> createState() => _PaymentModeSelectorState();
}

class _PaymentModeSelectorState extends State<PaymentModeSelector> {
  late String selectedMode;

  @override
  void initState() {
    super.initState();
    selectedMode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Fixed compact height
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPaymentOption(
            PaymentMode.cash,
            'Cash',
            Icons.money_rounded,
            Colors.green,
          ),
          const SizedBox(width: 4),
          _buildPaymentOption(
            PaymentMode.card,
            'Card',
            Icons.credit_card_rounded,
            Colors.blue,
          ),
          const SizedBox(width: 4),
          _buildPaymentOption(
            PaymentMode.phonePe,
            'PhonePe',
            Icons.phone_android_rounded,
            Colors.indigo,
          ),
          const SizedBox(width: 4),
          _buildPaymentOption(
            PaymentMode.gpay,
            'GPay',
            Icons.g_mobiledata_rounded,
            Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      String mode, String label, IconData icon, Color color) {
    bool isSelected = selectedMode == mode;

    return InkWell(
      onTap: () {
        setState(() {
          selectedMode = mode;
        });
        widget.onModeSelected(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : const Color(0xFF353535),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
