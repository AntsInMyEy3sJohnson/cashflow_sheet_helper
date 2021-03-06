import 'package:cashflow_sheet_helper/data/holding.dart';
import 'package:cashflow_sheet_helper/state/player/events/holding_sold.dart';
import 'package:cashflow_sheet_helper/widgets/buttons/confirm_abort_button_bar.dart';
import 'package:cashflow_sheet_helper/widgets/columns/sell_holding_with_absolute_price_dialog_column.dart';
import 'package:cashflow_sheet_helper/widgets/columns/sell_holding_with_percentage_price_dialog_column.dart';
import 'package:cashflow_sheet_helper/widgets/columns/sell_holding_with_price_per_unit_price_dialog_column.dart';
import 'package:cashflow_sheet_helper/widgets/constants/text_size_constants.dart';
import 'package:cashflow_sheet_helper/widgets/paddings/adjustable_padding.dart';
import 'package:cashflow_sheet_helper/widgets/paddings/padding_kind.dart';
import 'package:cashflow_sheet_helper/widgets/textfields/variable_size_text_field.dart';
import 'package:flutter/material.dart';

class SellHoldingDialog extends StatefulWidget {
  final Holding holding;

  const SellHoldingDialog(this.holding);

  @override
  _SellHoldingDialogState createState() => _SellHoldingDialogState();
}

class _SellHoldingDialogState extends State<SellHoldingDialog> {
  static const List<String> _SELL_OPTION_NAMES = <String>[
    "Absolute",
    "Percentage",
    "Price per Unit"
  ];
  static const String _ABSOLUTE_HINT_TEXT = "Original Price + X";
  static const String _PERCENTAGE_HINT_TEXT = "Original Price + X %";
  static const String _PRICE_PER_UNIT_HINT_TEXT = "Price per Unit";

  static final List<bool> _sellOptions = <bool>[true, false, false];

  final _formKey = GlobalKey<FormState>();

  late Widget _absoluteSellModeBody;
  late Widget _percentageSellModeBody;
  late Widget _pricePerUnitSellModeBody;
  late Widget _currentSellModeBody;

  late double _gains;

  @override
  void initState() {
    super.initState();
    _gains = 0.0;
    _absoluteSellModeBody = SellHoldingWithAbsolutePriceDialogColumn(
        _ABSOLUTE_HINT_TEXT,
        widget.holding.buyingCost,
        widget.holding.mortgage,
        _updateGainsCallBack);
    _percentageSellModeBody = SellHoldingWithPercentagePriceDialogColumn(
        _PERCENTAGE_HINT_TEXT,
        widget.holding.buyingCost,
        widget.holding.mortgage,
        _updateGainsCallBack);
    _pricePerUnitSellModeBody = SellHoldingWithPricePerUnitPriceDialogColumn(
        _PRICE_PER_UNIT_HINT_TEXT,
        widget.holding.buyingCost,
        widget.holding.mortgage,
        widget.holding.numUnits,
        _updateGainsCallBack);
    _currentSellModeBody = _absoluteSellModeBody;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const VariableSizeTextField("Sell Real Estate",
                TextSizeConstants.DIALOG_HEADING, TextAlign.center),
            AdjustablePadding(
              paddingKind: PaddingKind.medium,
              child: const VariableSizeTextField(
                  "How much is your buyer willing to pay on top of the original price?",
                  TextSizeConstants.DIALOG_INFO_TEXT,
                  TextAlign.center),
            ),
            ToggleButtons(
              children: List.of(_SELL_OPTION_NAMES.map((e) => Text(e))),
              onPressed: (index) => _processSellOptionChanged(index),
              isSelected: _sellOptions,
            ),
            _currentSellModeBody,
            ConfirmAbortButtonBar(
              () => _processConfirm(widget.holding, _gains),
              _processAbort,
            ),
          ],
        ),
      ),
    );
  }

  void _updateGainsCallBack(double updatedGains) {
    _gains = updatedGains;
  }

  void _processConfirm(Holding holding, double gains) {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, HoldingSold(holding, gains));
    }
  }

  void _processAbort() {
    Navigator.pop(context);
  }

  void _processSellOptionChanged(int selectedIndex) {
    if (!_sellOptions[selectedIndex]) {
      setState(() {
        _setSelectedState(selectedIndex);
        _setSelectedDialogBody();
      });
    }
  }

  void _setSelectedDialogBody() {
    if (_evaluateSellingMode() == SellingMode.absolute) {
      _currentSellModeBody = _absoluteSellModeBody;
    } else if (_evaluateSellingMode() == SellingMode.percentage) {
      _currentSellModeBody = _percentageSellModeBody;
    } else {
      _currentSellModeBody = _pricePerUnitSellModeBody;
    }
  }

  void _setSelectedState(int selectedIndex) {
    _sellOptions[selectedIndex] = true;
    for (int i = 0; i < _sellOptions.length; i++) {
      if (i == selectedIndex) {
        continue;
      }
      _sellOptions[i] = false;
    }
  }

  SellingMode _evaluateSellingMode() {
    final String currentlySelected = _SELL_OPTION_NAMES[_getTrueIndex()];
    switch (currentlySelected) {
      case "Absolute":
        return SellingMode.absolute;
      case "Percentage":
        return SellingMode.percentage;
      case "Price per Unit":
        return SellingMode.pricePerUnit;
      default:
        return SellingMode.absolute;
    }
  }

  int _getTrueIndex() {
    return _sellOptions.indexWhere((element) => element);
  }
}

enum SellingMode {
  absolute,
  percentage,
  pricePerUnit,
}
