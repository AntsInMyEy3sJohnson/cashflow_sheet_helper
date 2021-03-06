import 'package:cashflow_sheet_helper/state/player/player_bloc.dart';
import 'package:cashflow_sheet_helper/state/player/player_state.dart';
import 'package:cashflow_sheet_helper/widgets/helpers/dimension_helper.dart';
import 'package:cashflow_sheet_helper/widgets/rows/two_text_field_row.dart';
import 'package:cashflow_sheet_helper/widgets/constants/text_size_constants.dart';
import 'package:cashflow_sheet_helper/widgets/textfields/variable_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Income extends StatelessWidget {
  static const String ROUTE_ID = "/income";

  const Income();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(builder: (context, state) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: DimensionHelper.veryLargeVerticalPadding(context)),
            child: const TwoTextFieldRow(
              "Kind",
              "Cashflow",
              TextSizeConstants.TEXT_FIELD_TABLE_HEADING,
            ),
          ),
          TwoTextFieldRow("Salary:", "${state.player.activeIncome}", TextSizeConstants.TEXT_FIELD_ROW_ITEM),
          TwoTextFieldRow("Interests & dividends:", "${state.passiveIncome}", TextSizeConstants.TEXT_FIELD_ROW_ITEM),
          Padding(
            padding: EdgeInsets.only(top: DimensionHelper.veryLargeVerticalPadding(context)),
            child: VariableSizeTextField(
              "Real estate & company holdings:",
              TextSizeConstants.TEXT_FIELD_LIST_HEADING,
              TextAlign.left,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: state.holdings.length,
              itemBuilder: (context, i) {
                final holding = state.holdings[i];
                return ListTile(
                  title: TwoTextFieldRow(
                    "${holding.name}",
                    "${holding.cashflow}",
                    TextSizeConstants.TEXT_FIELD_ROW_ITEM,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
