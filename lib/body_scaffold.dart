import 'package:cashflow_sheet_helper/body.dart';
import 'package:cashflow_sheet_helper/pages/assets.dart';
import 'package:cashflow_sheet_helper/pages/expenses.dart';
import 'package:cashflow_sheet_helper/pages/income.dart';
import 'package:cashflow_sheet_helper/pages/liabilities.dart';
import 'package:cashflow_sheet_helper/pages/overview.dart';
import 'package:cashflow_sheet_helper/state/navigation/events/page_switched.dart';
import 'package:cashflow_sheet_helper/state/navigation/page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BodyScaffold extends StatelessWidget {

  const BodyScaffold();

  @override
  Widget build(BuildContext context) {

    final pageBloc = context.watch<PageBloc>();

    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: const Text("Cashflow Sheet Helper"),
            ),
            ListTile(
              title: const Text("Overview"),
              onTap: () {
                pageBloc.add(_pageSwitchedEvent(Overview.ROUTE_ID));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Income"),
              onTap: () {
                pageBloc.add(_pageSwitchedEvent(Income.ROUTE_ID));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Expenses"),
              onTap: () {
                pageBloc.add(_pageSwitchedEvent(Expenses.ROUTE_ID));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Assets"),
              onTap: () {
                pageBloc.add(_pageSwitchedEvent(Assets.ROUTE_ID));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Liabilities"),
              onTap: () {
                pageBloc.add(_pageSwitchedEvent(Liabilities.ROUTE_ID));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: const Body(),
    );
  }

  PageSwitched _pageSwitchedEvent(String targetRoute) => PageSwitched(targetRoute);



}