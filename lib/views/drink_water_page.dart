import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/drink_water.dart';
import 'package:flutter_app/view_models/all_drink_waters_vm.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class DrinkWaterPage extends StatefulWidget {
  const DrinkWaterPage({super.key});

  @override
  State<DrinkWaterPage> createState() => _DrinkWaterPageState();
}

class _DrinkWaterPageState extends State<DrinkWaterPage> {
  final _form = GlobalKey<FormState>();

  var _enteredWater = 0;

  @override
  Widget build(BuildContext context) {
    final allDrinkWatersViewModel = Provider.of<AllDrinkWatersViewModel>(context);
    final drinkwaters = allDrinkWatersViewModel.drinkwaters;
    var total = 0;

    for(var water in drinkwaters) {
      total += water.water;
    }

    if(allDrinkWatersViewModel.isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Yourself!')
      ),
      body: Consumer<AllDrinkWatersViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: total/2000,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  Text(
                    '$total mL',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400
                    )
                  )
                ]
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Records',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600
                    )
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 4,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    if(drinkwaters.isEmpty)
                      const Center(child: Text('No records.'))
                    else
                      ListView.builder(
                        itemCount: viewModel.drinkwaters.length,
                        itemBuilder: (context, index) => _buildItem(context, viewModel, index)
                      ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        iconSize: 40,
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () => _showAddDialog(context, viewModel),
                      )
                    )
                  ]
                )
              )
            ]
          );
        }
      )
    );
  }

  Widget _buildItem(BuildContext context, AllDrinkWatersViewModel viewModel, int index) {
    final drinkwater = viewModel.drinkwaters[index];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(drinkwater.toString())
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, AllDrinkWatersViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: _form,
          child: AlertDialog(
            title: const Text('Add Record'),
            content: TextFormField(
              key: const ValueKey('water'),
              decoration: const InputDecoration(hintText: "Type the amount of water in mL:"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onSaved: (value) {
                _enteredWater = int.parse(value!);
              }
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () => _submit(context, viewModel),
              ),
            ],
          )
        );
      },
    );
  }

  Future<void> _submit(BuildContext dialogContext, AllDrinkWatersViewModel viewModel) async {
    _form.currentState!.save();

    final viewModel = Provider.of<AllDrinkWatersViewModel>(context, listen: false);
    final newItem = DrinkWater(
      water: _enteredWater,
    );

    try {
      await viewModel.addDrinkWater(newItem);

      // Check if the widget is still mounted after async gap
      if (context.mounted) {
        Navigator.of(dialogContext).pop();
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Operation timed out: ${e.message}"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}