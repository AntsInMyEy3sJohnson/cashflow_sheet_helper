import 'package:cashflow_sheet_helper/data/asset.dart';
import 'package:cashflow_sheet_helper/data/holding.dart';
import 'package:cashflow_sheet_helper/state/player/events/baby_born.dart';
import 'package:cashflow_sheet_helper/state/player/events/balance_manually_modified.dart';
import 'package:cashflow_sheet_helper/state/player/events/business_boom_occurred.dart';
import 'package:cashflow_sheet_helper/state/player/events/cashflow_reached.dart';
import 'package:cashflow_sheet_helper/state/player/events/coins_bought.dart';
import 'package:cashflow_sheet_helper/state/player/events/coins_sold.dart';
import 'package:cashflow_sheet_helper/state/player/events/doodad_bought.dart';
import 'package:cashflow_sheet_helper/state/player/events/holding_bought.dart';
import 'package:cashflow_sheet_helper/state/player/events/holding_sold.dart';
import 'package:cashflow_sheet_helper/state/player/events/loan_paid_back.dart';
import 'package:cashflow_sheet_helper/state/player/events/loan_taken.dart';
import 'package:cashflow_sheet_helper/state/player/events/money_given_to_charity.dart';
import 'package:cashflow_sheet_helper/state/player/events/player_event.dart';
import 'package:cashflow_sheet_helper/state/player/events/player_state_cleared.dart';
import 'package:cashflow_sheet_helper/state/player/events/profession_initialized.dart';
import 'package:cashflow_sheet_helper/state/player/events/shares_backward_split.dart';
import 'package:cashflow_sheet_helper/state/player/events/shares_sold.dart';
import 'package:cashflow_sheet_helper/state/player/events/shares_split.dart';
import 'package:cashflow_sheet_helper/state/player/events/unemployment_incurred.dart';
import 'package:cashflow_sheet_helper/state/player/player_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'events/asset_bought.dart';

class PlayerBloc extends HydratedBloc<PlayerEvent, PlayerState> {
  PlayerBloc(PlayerState initialState) : super(initialState);

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    if (event is ProfessionInitialized) {
      yield await _mapProfessionInitializedToPlayerState(event);
    } else if (event is AssetBought) {
      yield await _mapAssetBoughtToPlayerState(event);
    } else if (event is HoldingBought) {
      yield await _mapHoldingBoughtToPlayerState(event);
    } else if (event is CashflowReached) {
      yield await _mapCashflowReachedToPlayerState(state);
    } else if (event is MoneyGivenToCharity) {
      yield await _mapCharityToPlayerState();
    } else if (event is DoodadBought) {
      yield await _mapDoodadBoughtToPlayerState(event);
    } else if (event is BabyBorn) {
      yield await _mapBabyBornToPlayerState(event);
    } else if (event is UnemploymentIncurred) {
      yield await _mapUnemploymentIncurredToPlayerState();
    } else if (event is LoanTaken) {
      yield await _mapLoanTakenToPlayerState(event);
    } else if (event is LoanPaidBack) {
      yield await _mapLoanPaidBackToPlayerState(event);
    } else if (event is SharesSold) {
      yield await _mapSharesSoldToPlayerState(event);
    } else if (event is SharesSplit) {
      yield await _mapShareSplitPerformedToPlayerState(event);
    } else if (event is SharesBackwardSplit) {
      yield await _mapShareBackwardSplitPerformedToPlayerState(event);
    } else if (event is HoldingSold) {
      yield await _mapHoldingSoldToPlayerState(event);
    } else if (event is BalanceManuallyModified) {
      yield await _mapManualBalanceModificationToPlayerState(event);
    } else if (event is BusinessBoomOccurred) {
      yield await _mapBusinessBoomToPlayerState(event);
    } else if (event is CoinsBought) {
      yield await _mapCoinsBoughtToPlayerState(event);
    } else if (event is CoinsSold) {
      yield await _mapCoinsSoldToPlayerState(event);
    } else if (event is PlayerStateCleared) {
      yield await _mapStateClearedToDummyState();
    }
  }

  Future<PlayerState> _mapProfessionInitializedToPlayerState(ProfessionInitialized event) async {
    return PlayerState.fromProfessionData(event.professionData);
  }

  Future<PlayerState> _mapStateClearedToDummyState() async {
    return PlayerState.dummyState();
  }

  Future<PlayerState> _mapCoinsSoldToPlayerState(CoinsSold event) async {
    final newBalance = state.balance + (event.pricePerCoin * event.numSold);
    final newNumGoldCoins = state.numGoldCoins - event.numSold;
    return state.copyWithBalanceAndNumGoldCoins(newBalance, newNumGoldCoins);
  }

  Future<PlayerState> _mapCoinsBoughtToPlayerState(CoinsBought event) async {
    final newBalance = state.balance - event.totalPrice;
    final newNumGoldCoins = state.numGoldCoins + event.numBought;
    return state.copyWithBalanceAndNumGoldCoins(newBalance, newNumGoldCoins);
  }

  Future<PlayerState> _mapBusinessBoomToPlayerState(
      BusinessBoomOccurred event) async {
    final List<Holding> holdings = List.empty(growable: true);
    state.holdings.forEach((holding) {
      if (holding.cashflow < event.affectsBusinessesBelowThreshold) {
        holdings.add(Holding(
            name: holding.name,
            holdingKind: holding.holdingKind,
            numUnits: holding.numUnits,
            downPayment: holding.downPayment,
            buyingCost: holding.buyingCost,
            mortgage: holding.mortgage,
            cashflow: holding.cashflow + event.cashflowIncrease));
      } else {
        holdings.add(holding);
      }
    });
    return state.copyWithHoldings(holdings);
  }

  Future<PlayerState> _mapManualBalanceModificationToPlayerState(
      BalanceManuallyModified event) async {
    double modificationAmount = event.amount * (event.increase ? 1 : -1);
    return state.copyWithBalance(state.balance + modificationAmount);
  }

  Future<PlayerState> _mapHoldingSoldToPlayerState(HoldingSold event) async {
    final List<Holding> holdings = List.from(state.holdings);
    holdings.remove(event.holding);
    final double newBalance = state.balance + event.gains;
    return state.copyWithHoldingsAndBalance(holdings, newBalance);
  }

  Future<PlayerState> _mapShareBackwardSplitPerformedToPlayerState(
      SharesBackwardSplit event) async {
    final List<Asset> assets = List.from(state.assets);
    int index = assets.indexOf(event.asset);
    assets[index] = Asset(
      name: event.asset.name,
      numShares: (event.asset.numShares / 2).round(),
      costPerShare: event.asset.costPerShare,
    );
    return state.copyWithAssets(assets);
  }

  Future<PlayerState> _mapShareSplitPerformedToPlayerState(
      SharesSplit event) async {
    final List<Asset> assets = List.from(state.assets);
    int index = assets.indexOf(event.asset);
    assets[index] = Asset(
      name: event.asset.name,
      numShares: event.asset.numShares * 2,
      costPerShare: event.asset.costPerShare,
    );
    return state.copyWithAssets(assets);
  }

  Future<PlayerState> _mapSharesSoldToPlayerState(SharesSold event) async {
    final List<Asset> assets = List.from(state.assets);
    final Asset matchingAsset =
        assets.singleWhere((element) => element == event.asset);
    if (event.numSold == matchingAsset.numShares) {
      assets.remove(matchingAsset);
    } else {
      int index = assets.indexOf(event.asset);
      assets[index] = Asset(
          name: matchingAsset.name,
          numShares: matchingAsset.numShares - event.numSold,
          costPerShare: matchingAsset.costPerShare);
    }
    final newBalance = state.balance + (event.numSold * event.price);
    return state.copyWithAssetsAndBalance(assets, newBalance);
  }

  Future<PlayerState> _mapLoanPaidBackToPlayerState(LoanPaidBack event) async {
    final newBalance = state.balance - event.amount;
    final newTotalBankLoan = state.bankLoan - event.amount;
    return state.copyWithBalanceAndBankLoan(newBalance, newTotalBankLoan);
  }

  Future<PlayerState> _mapLoanTakenToPlayerState(LoanTaken event) async {
    final newBalance = state.balance + event.amount;
    final newTotalBankLoan = state.bankLoan + event.amount;
    return state.copyWithBalanceAndBankLoan(newBalance, newTotalBankLoan);
  }

  Future<PlayerState> _mapUnemploymentIncurredToPlayerState() async {
    final newBalance = state.balance - state.totalExpenses;
    return state.copyWithBalance(newBalance);
  }

  Future<PlayerState> _mapBabyBornToPlayerState(BabyBorn event) async {
    final newNumChildren = state.numChildren + 1;
    return state.copyWithNumChildren(newNumChildren);
  }

  Future<PlayerState> _mapDoodadBoughtToPlayerState(DoodadBought event) async {
    final newBalance = state.balance - event.amount;
    return state.copyWithBalance(newBalance);
  }

  Future<PlayerState> _mapCharityToPlayerState() async {
    final newCash = state.balance - (state.totalIncome * 0.1);
    return state.copyWithBalance(newCash);
  }

  Future<PlayerState> _mapCashflowReachedToPlayerState(
      PlayerState state) async {
    final newCash = state.balance + state.cashflow;
    return state.copyWithBalance(newCash);
  }

  Future<PlayerState> _mapHoldingBoughtToPlayerState(
      HoldingBought event) async {
    List<Holding> holdings = List.from(state.holdings);
    holdings.add(Holding(
        name: event.name,
        holdingKind: event.holdingKind,
        numUnits: event.numUnits,
        downPayment: event.downPayment,
        buyingCost: event.buyingCost,
        mortgage: event.mortgage,
        cashflow: event.cashflow));
    final newBalance = state.balance - event.downPayment;
    return state.copyWithHoldingsAndBalance(holdings, newBalance);
  }

  Future<PlayerState> _mapAssetBoughtToPlayerState(AssetBought event) async {
    // We need new state containers -- list and enclosing
    // 'PlayerState' -- to cause all listening BlocBuilders
    // to rebuild
    List<Asset> assets = List.from(state.assets);
    assets.add(Asset(
        name: event.name,
        numShares: event.numShares,
        costPerShare: event.costPerShare));
    final newBalance = state.balance - event.totalCost;
    return state.copyWithAssetsAndBalance(assets, newBalance);
  }

  @override
  PlayerState? fromJson(Map<String, dynamic> json) {
    try {
      return PlayerState.fromJson(json);
    } catch (e) {
      print("Unable to load PlayerState object from device.");
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(PlayerState state) {
    try {
      return state.toJson();
    } catch (_) {
      print("Unable to serialize PlayerState object to JSON.");
      return null;
    }
  }
}
