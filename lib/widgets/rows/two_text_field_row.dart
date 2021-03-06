import 'package:cashflow_sheet_helper/widgets/textfields/variable_size_text_field.dart';
import 'package:flutter/material.dart';

class TwoTextFieldRow extends StatelessWidget {
  final String leftTextFieldText;
  final String rightTextFieldText;
  final double fontSize;

  const TwoTextFieldRow(this.leftTextFieldText, this.rightTextFieldText, this.fontSize);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child:
              VariableSizeTextField(leftTextFieldText, fontSize, TextAlign.left),
        ),
        Expanded(
          child: VariableSizeTextField(
              rightTextFieldText, fontSize, TextAlign.right),
        ),
      ],
    );
  }
}
