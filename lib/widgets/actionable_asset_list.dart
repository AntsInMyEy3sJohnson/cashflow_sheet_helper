import 'package:cashflow_sheet_helper/data/asset.dart';
import 'package:cashflow_sheet_helper/state/player/events/asset_bought.dart';
import 'package:cashflow_sheet_helper/state/player/events/shares_backward_split.dart';
import 'package:cashflow_sheet_helper/state/player/events/shares_sold.dart';
import 'package:cashflow_sheet_helper/state/player/events/shares_split.dart';
import 'package:cashflow_sheet_helper/state/player/player_bloc.dart';
import 'package:cashflow_sheet_helper/state/player/player_state.dart';
import 'package:cashflow_sheet_helper/widgets/constants/color_constants.dart';
import 'package:cashflow_sheet_helper/widgets/constants/icon_constants.dart';
import 'package:cashflow_sheet_helper/widgets/dialogs/buy_shares_dialog.dart';
import 'package:cashflow_sheet_helper/widgets/dialogs/simple_info_dialog.dart';
import 'package:cashflow_sheet_helper/widgets/helpers/dialog_helper.dart';
import 'package:cashflow_sheet_helper/widgets/dialogs/sell_shares_dialog.dart';
import 'package:cashflow_sheet_helper/widgets/dialogs/yes_no_alert_dialog.dart';
import 'package:cashflow_sheet_helper/widgets/reusable_snackbar.dart';
import 'package:cashflow_sheet_helper/widgets/rows/three_text_field_row.dart';
import 'package:cashflow_sheet_helper/widgets/textfields/info_text.dart';
import 'package:cashflow_sheet_helper/widgets/textfields/info_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ActionableAssetList extends StatefulWidget {
  const ActionableAssetList();

  @override
  _ActionableAssetListState createState() => _ActionableAssetListState();
}

class _ActionableAssetListState extends State<ActionableAssetList> {
  late final PlayerBloc _playerBloc;

  @override
  void initState() {
    super.initState();
    _playerBloc = context.read<PlayerBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.assets.length + 1,
          itemBuilder: (context, i) {
            if (i < state.assets.length) {
              final asset = state.assets[i];
              // TODO Add indicator to right edge of item row to signal to user that row can be swiped
              return Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: ListTile(
                  title: ThreeTextFieldRow(
                    "${asset.name}",
                    "${asset.numShares}",
                    "${asset.costPerShare}",
                    18,
                  ),
                ),
                secondaryActions: [
                  IconSlideAction(
                    caption: "Sell",
                    color: ColorConstants.SELL_ITEM,
                    icon: IconConstants.SELL,
                    onTap: () => _showSellSharesDialog(asset),
                  ),
                  IconSlideAction(
                    caption: "Split",
                    color: ColorConstants.SHARES_FORWARD_SPLIT,
                    icon: IconConstants.FORWARD_SPLIT,
                    onTap: () => _showSplitSharesDialog(asset),
                  ),
                  IconSlideAction(
                    caption: "Backward split",
                    color: ColorConstants.SHARES_BACKWARD_SPLIT,
                    icon: IconConstants.BACKWARD_SPLIT,
                    // TODO Disable this button if player holds only one share by this company
                    // Caution: Simply passing null does not change the representation of this
                    // widget
                    onTap: () => asset.numShares > 1
                        ? _showBackwardSplitSharesDialog(asset)
                        : _showBackwardSplitCannotBePerformedDialog(),
                  ),
                ],
              );
            }
            return ElevatedButton(
                onPressed: () async {
                  AssetBought? assetBought = await DialogHelper<AssetBought?>()
                      .displayDialog(context, BuySharesDialog());
                  if (assetBought != null) {
                    _addAsset(context, assetBought);
                  }
                },
                child: const Text("Add"));
          },
        );
      },
    );
  }

  void _showBackwardSplitCannotBePerformedDialog() async {
    await DialogHelper<dynamic?>().displayDialog(
      context,
      SimpleInfoDialog(
          "Info",
          const Text("Backward split cannot be performed "
              "if only one share is held.")),
    );
  }

  void _showBackwardSplitSharesDialog(Asset asset) async {
    final bool? dialogResult = await DialogHelper<bool?>().displayDialog(
        context,
        YesNoAlertDialog(
          "Split Shares (Backward Split)",
          Text(
              "Perform backward split on ${asset.name} shares? This will halve "
              "the number of shares you own by this company."),
        ));
    if (dialogResult ?? false) {
      _playerBloc.add(SharesBackwardSplit(asset));
      ScaffoldMessenger.of(context).showSnackBar(
        ReusableSnackbar.fromChildren(<Widget>[
          InfoText("Performed backward split on ${asset.name} shares."),
          InfoText(
            "Number of ${asset.name} shares: -${(asset.numShares / 2).round()}",
            infoTextKind: InfoTextKind.BAD,
          ),
        ]),
      );
    }
  }

  void _showSplitSharesDialog(Asset asset) async {
    final bool? dialogResult = await DialogHelper<bool?>().displayDialog(
        context,
        YesNoAlertDialog(
          "Split Shares (Forward Split)",
          Text("Perform split for ${asset.name} shares? This will double "
              "the number of shares you hold by this company."),
        ));
    if (dialogResult ?? false) {
      _playerBloc.add(SharesSplit(asset));
      ScaffoldMessenger.of(context).showSnackBar(
        ReusableSnackbar.fromChildren(<Widget>[
          InfoText("Performed split on ${asset.name} shares."),
          InfoText(
            "Number of ${asset.name} shares +${asset.numShares}",
            infoTextKind: InfoTextKind.GOOD,
          ),
        ]),
      );
    }
  }

  void _showSellSharesDialog(Asset asset) async {
    final SharesSold? sharesSold = await DialogHelper<SharesSold?>()
        .displayDialog(context, SellSharesDialog(asset));
    if (sharesSold != null) {
      _playerBloc.add(sharesSold);
      ScaffoldMessenger.of(context).showSnackBar(
        ReusableSnackbar.fromChildren(<Widget>[
          InfoText("${sharesSold.numSold} shares sold."),
          InfoText(
            "Balance +${sharesSold.numSold * sharesSold.price}",
            infoTextKind: InfoTextKind.GOOD,
          ),
        ]),
      );
    }
  }

  void _addAsset(BuildContext context, AssetBought assetBought) {
    _playerBloc.add(assetBought);
    ScaffoldMessenger.of(context)
        .showSnackBar(ReusableSnackbar.fromChildren(<Widget>[
      InfoText("Asset bought."),
      InfoText(
        "Balance -${assetBought.totalCost}",
        infoTextKind: InfoTextKind.BAD,
      ),
    ]));
  }
}
