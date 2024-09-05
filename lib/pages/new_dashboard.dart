import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewDash extends StatelessWidget {
  late int parquesEstrutura;
  late int parquesSuperficie;

  NewDash(
      {super.key,
      required this.parquesEstrutura,
      required this.parquesSuperficie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Dashboard'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Mini Dashboard',
                style: TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('E:$parquesEstrutura',
                      style: const TextStyle(fontSize: 30)),
                ],
              ),
              const Expanded(
                  child: Center(
                    child: Text('dashboard',
                        style: TextStyle(color: Colors.blue, fontSize: 30)),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('S:$parquesSuperficie',
                      style: const TextStyle(fontSize: 30)),
                ],
              )
            ],
          ),
        ));
  }
}
