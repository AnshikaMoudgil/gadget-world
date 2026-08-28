import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gadget_store/core/theme.dart';

class OTPInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCompleted;
  final String? autofillCode;
  final int shakeTrigger;

  const OTPInput({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.autofillCode,
    this.shakeTrigger = 0,
  });

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput>
    with SingleTickerProviderStateMixin {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeOffset = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -6, end: 5), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 5, end: 0), weight: 1),
      ],
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant OTPInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeTrigger != oldWidget.shakeTrigger) {
      _shakeController.forward(from: 0);
    }
    final code = widget.autofillCode?.replaceAll(RegExp(r'[^0-9]'), '');
    if (code == null ||
        code.length != widget.length ||
        code == oldWidget.autofillCode) {
      return;
    }

    for (var index = 0; index < widget.length; index++) {
      _controllers[index].text = code[index];
    }
    _focusNodes.last.unfocus();
    widget.onChanged(code);
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    _shakeController.dispose();
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
    return AnimatedBuilder(
      animation: _shakeOffset,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeOffset.value, 0),
        child: child,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          widget.length,
          (index) => SizedBox(
            width: 45,
            height: 55,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: const TextInputType.numberWithOptions(),
              textInputAction: index == widget.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofillHints: const [AutofillHints.oneTimeCode],
              textAlign: TextAlign.center,
              maxLength: widget.length,
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
      ),
    );
  }
}
