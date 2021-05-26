import 'package:cashflow_sheet_helper/widgets/amount_selection_row.dart';
import 'package:cashflow_sheet_helper/widgets/variable_size_text_field.dart';
import 'package:flutter/material.dart';

class SelectAmountDialog extends StatelessWidget {
  final String title;
  final String infoBoxText;
  final TextEditingController amountController;
  final Function callbackAmountIncreased;
  final Function callbackAmountDecreased;
  final Function callbackDialogConfirmed;
  final Function callbackDialogAborted;

  const SelectAmountDialog(
      {required this.title,
      required this.infoBoxText,
      required this.amountController,
      required this.callbackAmountIncreased,
      required this.callbackAmountDecreased,
      required this.callbackDialogConfirmed,
      required this.callbackDialogAborted});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VariableSizeTextField(title, 20, TextAlign.center),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: AmountSelectionRow(
              amountController,
              callbackAmountIncreased,
              callbackAmountDecreased,
            ),
          ),
          Text(infoBoxText),
          ElevatedButton(
              onPressed: () => callbackDialogConfirmed(),
              child: const Text("Confirm")),
          ElevatedButton(
              onPressed: () => callbackDialogAborted(),
              child: const Text("Abort")),
        ],
      ),
    );
  }
}