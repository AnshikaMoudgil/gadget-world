import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';

class OTPInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCompleted;

  const OTPInput({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
  });

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (value.length > 1) {
        // Handle paste
        String pastedValue = value
            .substring(0, widget.length)
            .replaceAll(RegExp(r'[^0-9]'), '');
        for (int i = 0; i < pastedValue.length; i++) {
          if (index + i < widget.length) {
            _controllers[index + i].text = pastedValue[i];
          }
        }
        if (index + pastedValue.length < widget.length) {
          _focusNodes[index + pastedValue.length].requestFocus();
        } else {
          _focusNodes[widget.length - 1].unfocus();
        }
      } else {
        if (index < widget.length - 1) {
          _focusNodes[index + 1].requestFocus();
        } else {
          _focusNodes[index].unfocus();
        }
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    String currentOtp = _controllers.map((e) => e.text).join();
    widget.onChanged(currentOtp);
    if (currentOtp.length == widget.length && widget.onCompleted != null) {
      widget.onCompleted!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        widget.length,
        (index) => SizedBox(
          width: 45,
          height: 55,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: widget.length, // Allow paste
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.greyText),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.black),
              ),
            ),
            onChanged: (value) => _onChanged(value, index),
          ),
        ),
      ),
    );
  }
}
