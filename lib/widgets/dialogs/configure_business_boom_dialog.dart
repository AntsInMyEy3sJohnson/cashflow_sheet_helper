import 'package:cashflow_sheet_helper/helpers/input_validation/configure_business_boom_input_validation.dart';
import 'package:cashflow_sheet_helper/state/player/events/business_boom_occurred.dart';
import 'package:cashflow_sheet_helper/widgets/buttons/confirm_abort_button_bar.dart';
import 'package:cashflow_sheet_helper/widgets/constants/text_size_constants.dart';
import 'package:cashflow_sheet_helper/widgets/textfields/padded_form_field.dart';
import 'package:cashflow_sheet_helper/widgets/textfields/variable_size_text_field.dart';
import 'package:flutter/material.dart';

class ConfigureBusinessBoomDialog extends StatefulWidget {
  @override
  _ConfigureBusinessBoomDialogState createState() =>
      _ConfigureBusinessBoomDialogState();
}

class _ConfigureBusinessBoomDialogState
    extends State<ConfigureBusinessBoomDialog> {
  final TextEditingController _thresholdController = TextEditingController();
  final TextEditingController _cashflowIncreaseController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _thresholdController.dispose();
    _cashflowIncreaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const VariableSizeTextField("Business Boom",
                TextSizeConstants.DIALOG_HEADING, TextAlign.center),
            PaddedFormField(
              _thresholdController,
              "Cashflow threshold",
              ConfigureBusinessBoomInputValidation.validateThreshold,
              textInputType: TextInputType.number,
            ),
            PaddedFormField(
              _cashflowIncreaseController,
              "Cashflow increase",
              ConfigureBusinessBoomInputValidation.validateCashflowIncrease,
              textInputType: TextInputType.number,
            ),
            ConfirmAbortButtonBar(
              () => _processConfirm(context),
              () => _processAbort(context),
            ),
          ],
        ),
      ),
    );
  }

  void _processConfirm(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final BusinessBoomOccurred businessBoomOccurred = BusinessBoomOccurred(
          double.parse(_thresholdController.text),
          double.parse(_cashflowIncreaseController.text));
      Navigator.pop(context, businessBoomOccurred);
    }
  }

  void _processAbort(BuildContext context) {
    Navigator.pop(context);
  }
}
