import 'package:cashflow_sheet_helper/state/player/events/doodad_bought.dart';
import 'package:cashflow_sheet_helper/widgets/buttons/confirm_abort_button_bar.dart';
import 'package:cashflow_sheet_helper/widgets/constants/text_size_constants.dart';
import 'package:cashflow_sheet_helper/widgets/textfields/padded_input_text_field.dart';
import 'package:cashflow_sheet_helper/widgets/textfields/variable_size_text_field.dart';
import 'package:flutter/material.dart';

class BuyDoodadDialog extends StatelessWidget {
  final TextEditingController _amountController;

  const BuyDoodadDialog(this._amountController);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const VariableSizeTextField(
              "Buy Doodad", TextSizeConstants.DIALOG_HEADING, TextAlign.center),
          PaddedInputTextField(
            "Provide amount to deduct from balance",
            _amountController,
            textInputType: TextInputType.number,
          ),
          ConfirmAbortButtonBar(
                () => _processConfirm(context),
                () => _processAbort(context),
          ),
        ],
      ),
    );
  }

  void _processConfirm(BuildContext context) {
    // TODO Add input validation
    Navigator.pop(context, DoodadBought(double.parse(_amountController.text)));
  }

  void _processAbort(BuildContext context) {
    Navigator.pop(context, null);
  }
}
