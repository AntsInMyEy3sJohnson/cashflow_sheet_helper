import 'package:cashflow_sheet_helper/widgets/paddings/adjustable_padding.dart';
import 'package:cashflow_sheet_helper/widgets/paddings/padding_kind.dart';
import 'package:flutter/material.dart';

class PaddedFormField extends StatelessWidget {

  final TextEditingController _controller;
  final String _hintText;
  final String? Function(String?)? _validationFunction;
  final TextInputType textInputType;

  const PaddedFormField(this._controller, this._hintText, this._validationFunction, {this.textInputType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return AdjustablePadding(
        paddingKind: PaddingKind.small,
      child: TextFormField(
        controller: _controller,
        keyboardType: textInputType,
        decoration: InputDecoration(
          hintText: _hintText,
          border: OutlineInputBorder(),
        ),
        validator: _validationFunction,
      ),
    );
  }

}