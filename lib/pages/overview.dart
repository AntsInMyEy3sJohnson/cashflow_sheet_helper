import 'package:cashflow_sheet_helper/data/player.dart';
import 'package:cashflow_sheet_helper/state/player/events/baby_born.dart';
import 'package:cashflow_sheet_helper/state/player/events/balance_manually_modified.dart';
import 'package:cashflow_sheet_helper/state/player/events/business_boom_occurred.dart';
import 'package:cashflow_sheet_helper/state/player/events/cashflow_reached.dart';
import 'package:cashflow_sheet_helper/state/player/events/doodad_bought.dart';
import 'package:cashflow_sheet_helper/state/player/events/loan_paid_back.dart';
import 'package:cashflow_sheet_helper/state/player/events/loan_taken.dart';
import 'package:cashflow_sheet_helper/state/player/events/money_given_to_charity.dart';
import 'package:cashflow_sheet_helper/state/player/events/unemployment_incurred.dart';
import 'package:cashflow_sheet_helper/state/player/player_bloc.dart';
import 'package:cashflow_sheet_helper/state/player/player_state.dart';
import 'package:cashflow_sheet_helper/widgets/buttons/action_tile_button.dart';
import 'package:cashflow_sheet_helper/widgets/buttons/style_kind.dart';
import 'package:cashflow_sheet_helper/widgets/constants/text_size_constants.dart';
import 'package:cashflow_sheet_helper/widgets/dialogs/buy_doodad_dialog.dart';
import 'package:cashflow_sheet_helper/widgets/dialogs/configure_business_boom_dialog.dart';
import 'package:cashflow_sheet_helper/widgets/dialogs/modify_balance_dialog.dart';
import 'package:cashflow_sheet_helper/widgets/dialogs/pay_back_loan_dialog.dart';
import 'package:cashflow_sheet_helper/widgets/dialogs/simple_info_dialog.dart';
import 'package:cashflow_sheet_helper/widgets/dialogs/take_up_loan_dialog.dart';
import 'package:cashflow_sheet_helper/widgets/dialogs/yes_no_alert_dialog.dart';
import 'package:cashflow_sheet_helper/widgets/helpers/dialog_helper.dart';
import 'package:cashflow_sheet_helper/widgets/paddings/adjustable_padding.dart';
import 'package:cashflow_sheet_helper/widgets/paddings/padding_kind.dart';
import 'package:cashflow_sheet_helper/widgets/reusable_snackbar.dart';
import 'package:cashflow_sheet_helper/widgets/rows/overview_row.dart';
import 'package:cashflow_sheet_helper/widgets/textfields/info_text.dart';
import 'package:cashflow_sheet_helper/widgets/textfields/info_text_field.dart';
import 'package:cashflow_sheet_helper/widgets/textfields/variable_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Overview extends StatefulWidget {
  static const ROUTE_ID = "/";

  const Overview();

  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
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
        final player = state.player;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01,
                ),
                child: Column(
                  children: [
                    const VariableSizeTextField("Income and balance overview",
                        TextSizeConstants.TEXT_FIELD_HEADING, TextAlign.center),
                    OverviewRow("Income",
                        "${player.activeIncome} + ${state.passiveIncome}"),
                    OverviewRow("Expenses", "${state.totalExpenses}"),
                    OverviewRow("Cashflow", "${state.cashflow}"),
                    OverviewRow("Account balance", "${state.balance}"),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01),
                child: Column(
                  children: [
                    const VariableSizeTextField("Actions",
                        TextSizeConstants.TEXT_FIELD_HEADING, TextAlign.center),
                    ElevatedButton(
                      onPressed: () => _processCashflowDay(state),
                      child: AdjustablePadding(
                        paddingKind: PaddingKind.large,
                        child: const VariableSizeTextField(
                          "Cashflow Day!",
                          TextSizeConstants.BUTTON_LARGE,
                          TextAlign.center,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      childAspectRatio: 2 / 1,
                      crossAxisCount: 2,
                      children: _buildActionButtons(_playerBloc.state),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildActionButtons(PlayerState state) {
    return <Widget>[
      ActionTileButton(
        "Charity",
        TextSizeConstants.BUTTON_MEDIUM,
        () => _processCharity(state),
        StyleKind.ENABLED,
      ),
      ActionTileButton(
        "Doodad",
        TextSizeConstants.BUTTON_MEDIUM,
        () => _processDoodad(_playerBloc.state),
        StyleKind.ENABLED,
      ),
      ActionTileButton(
        "Child (${state.numChildren})",
        TextSizeConstants.BUTTON_MEDIUM,
        () => _processChildBorn(state),
        state.numChildren < 3 ? StyleKind.ENABLED : StyleKind.DISABLED,
      ),
      ActionTileButton(
        "Unemployed",
        TextSizeConstants.BUTTON_MEDIUM,
        () => _processUnemployment(state),
        StyleKind.ENABLED,
      ),
      ActionTileButton(
        "Take Up Loan",
        TextSizeConstants.BUTTON_MEDIUM,
        () => _processLoanTaken(),
        StyleKind.ENABLED,
      ),
      ActionTileButton(
        "Pay Back Loan",
        TextSizeConstants.BUTTON_MEDIUM,
        () => _processLoanPaidBack(state),
        state.bankLoan > 0 ? StyleKind.ENABLED : StyleKind.DISABLED,
      ),
      ActionTileButton(
        "Business Boom",
        TextSizeConstants.BUTTON_MEDIUM,
        () => _processBusinessBoom(state),
        StyleKind.ENABLED,
      ),
      ActionTileButton(
        "Manually Modify Balance",
        TextSizeConstants.BUTTON_MEDIUM,
        () => _processManualAccountBalanceModification(),
        StyleKind.ENABLED,
      ),
    ];
  }

  void _processBusinessBoom(PlayerState state) async {
    if (state.holdings.isEmpty) {
      await DialogHelper<dynamic>().displayDialog(
          context,
          SimpleInfoDialog(
              "Info",
              const Text(
                  "You currently don't own any businesses or real estate that could be subject to a business boom.")));
    } else {
      final BusinessBoomOccurred? businessBoomOccurred =
          await DialogHelper<BusinessBoomOccurred?>()
              .displayDialog(context, ConfigureBusinessBoomDialog());
      if (businessBoomOccurred != null) {
        _playerBloc.add(businessBoomOccurred);
        ScaffoldMessenger.of(context)
            .showSnackBar(ReusableSnackbar.fromChildren(<Widget>[
          InfoText("Business Boom occurred."),
          InfoText(
              "All businesses with cashflow of less than ${businessBoomOccurred.affectsBusinessesBelowThreshold} increased their cashflow by ${businessBoomOccurred.cashflowIncrease}.",
              infoTextKind: InfoTextKind.GOOD)
        ]));
      }
    }
  }

  void _processManualAccountBalanceModification() async {
    final balanceManuallyModified =
        await DialogHelper<BalanceManuallyModified?>()
            .displayDialog(context, ModifyBalanceDialog());
    if (balanceManuallyModified != null) {
      final String sign = balanceManuallyModified.increase ? "+" : "-";
      final InfoTextKind newsKind = balanceManuallyModified.increase
          ? InfoTextKind.GOOD
          : InfoTextKind.BAD;
      _playerBloc.add(balanceManuallyModified);
      ScaffoldMessenger.of(context).showSnackBar(
        ReusableSnackbar.fromChildren(<Widget>[
          InfoText("Account balance adapted"),
          InfoText(
            "Balance $sign${balanceManuallyModified.amount}",
            infoTextKind: newsKind,
          ),
        ]),
      );
    }
  }

  void _processLoanPaidBack(PlayerState state) async {
    if (state.bankLoan == 0) {
      await DialogHelper<dynamic>().displayDialog(
          context,
          SimpleInfoDialog("Info",
              const Text("You currently don't have a loan to be paid back.")));
    } else {
      final loanPaidBack = await DialogHelper<LoanPaidBack?>().displayDialog(
          context,
          BlocProvider<PlayerBloc>.value(
            value: _playerBloc,
            child: PayBackLoanDialog(),
          ));
      if (loanPaidBack != null) {
        _playerBloc.add(loanPaidBack);
        ScaffoldMessenger.of(context)
            .showSnackBar(ReusableSnackbar.fromChildren(<Widget>[
          InfoText("Loan amount reduced."),
          InfoText("Balance -${loanPaidBack.amount}",
              infoTextKind: InfoTextKind.BAD),
          InfoText(
            "Monthly expenses -${loanPaidBack.amount * 0.1}",
            infoTextKind: InfoTextKind.GOOD,
          ),
        ]));
      }
    }
  }

  void _processLoanTaken() async {
    final loanTaken = await DialogHelper<LoanTaken?>()
        .displayDialog(context, TakeUpLoanDialog());
    if (loanTaken != null) {
      _playerBloc.add(loanTaken);
      ScaffoldMessenger.of(context)
          .showSnackBar(ReusableSnackbar.fromChildren(<Widget>[
        InfoText("Loan taken."),
        InfoText(
          "Balance +${loanTaken.amount}",
          infoTextKind: InfoTextKind.GOOD,
        ),
        InfoText(
          "Monthly expenses +${loanTaken.amount * 0.1}",
          infoTextKind: InfoTextKind.BAD,
        ),
      ]));
    }
  }

  void _processUnemployment(PlayerState state) async {
    final dialogResult = await DialogHelper<bool?>().displayDialog(
        context,
        YesNoAlertDialog(
          "Unemployment",
          Text("Enter unemployed state for two rounds? This will deduct "
              "your total expenses (${state.totalExpenses}) from your account once."),
        ));
    if (dialogResult ?? false) {
      _playerBloc.add(const UnemploymentIncurred());
      ScaffoldMessenger.of(context).showSnackBar(
        ReusableSnackbar.fromChildren(<Widget>[
          InfoText("Incurred unemployment."),
          InfoText(
            "Cash -${state.totalExpenses}",
            infoTextKind: InfoTextKind.BAD,
          ),
        ]),
      );
    }
  }

  void _processChildBorn(PlayerState state) async {
    final Player player = state.player;
    if (state.numChildren >= 3) {
      await DialogHelper<dynamic>().displayDialog(
          context,
          SimpleInfoDialog("Info",
              const Text("You've reached the maximum number of children.")));
    } else {
      final currentChildExpenses = state.totalChildExpenses;
      final newChildExpenses =
          currentChildExpenses + player.monthlyChildExpenses;
      final dialogResult = await DialogHelper<bool?>().displayDialog(
          context,
          YesNoAlertDialog(
              "Get Baby",
              Text(
                  "Get a baby? This will increase your monthly child expenses from $currentChildExpenses to $newChildExpenses.")));
      if (dialogResult ?? false) {
        _playerBloc.add(const BabyBorn());
        ScaffoldMessenger.of(context)
            .showSnackBar(ReusableSnackbar.fromChildren(<Widget>[
          InfoText("Child added."),
          InfoText(
            "Monthly expenses +${player.monthlyChildExpenses}",
            infoTextKind: InfoTextKind.BAD,
          ),
        ]));
      }
    }
  }

  void _processCashflowDay(PlayerState state) {
    _playerBloc.add(const CashflowReached());
    ScaffoldMessenger.of(context)
        .showSnackBar(ReusableSnackbar.fromChildren(<Widget>[
      InfoText("Monthly cashflow added to balance."),
      InfoText(
        "Cash +${state.cashflow}",
        infoTextKind: InfoTextKind.GOOD,
      ),
    ]));
  }

  void _processCharity(PlayerState state) async {
    final charityAmount = state.totalIncome * 0.1;
    final dialogResult = await DialogHelper<bool?>().displayDialog(
        context,
        YesNoAlertDialog(
            "Give Money To Charity",
            Text(
                "Give 10 % of your total income ($charityAmount) to charity?")));
    if (dialogResult ?? false) {
      _playerBloc.add(const MoneyGivenToCharity());
      ScaffoldMessenger.of(context)
          .showSnackBar(ReusableSnackbar.fromChildren(<Widget>[
        InfoText("10 % of income given to charity."),
        InfoText(
          "Cash -$charityAmount",
          infoTextKind: InfoTextKind.BAD,
        )
      ]));
    }
  }

  void _processDoodad(PlayerState state) async {
    final doodadBought = await DialogHelper<DoodadBought?>()
        .displayDialog(context, BuyDoodadDialog(state.balance));
    if (doodadBought != null) {
      _playerBloc.add(doodadBought);
      ScaffoldMessenger.of(context)
          .showSnackBar(ReusableSnackbar.fromChildren(<Widget>[
        InfoText("Doodad bought."),
        InfoText(
          "Cash -${doodadBought.amount}",
          infoTextKind: InfoTextKind.BAD,
        ),
      ]));
    }
  }
}
