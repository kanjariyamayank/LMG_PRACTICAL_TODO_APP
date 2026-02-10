import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StoringListLogic(),
    );
  }
}

class StoringListLogic extends StatefulWidget {
  const StoringListLogic({super.key});

  @override
  State<StoringListLogic> createState() => _StoringListLogicState();
}

class _StoringListLogicState extends State<StoringListLogic> {
  final TextEditingController inputController = TextEditingController();
  String output = "";

  void processList() {
    List<String> input = inputController.text.split(',');
    List<int> numbers = [];

    for (int i = 0; i < input.length; i++) {
      int? value = int.tryParse(input[i].trim());
      if (value != null) {
        numbers.add(value);
      }
    }

    if (numbers.isEmpty) {
      setState(() => output = "Enter any number to sort the value");
      return;
    }

    List<int> uniqueList = [];

    for (int i = 0; i < numbers.length; i++) {
      bool isDuplicate = false;

      for (int j = 0; j < uniqueList.length; j++) {
        if (numbers[i] == uniqueList[j]) {
          isDuplicate = true;
          break;
        }
      }

      if (!isDuplicate) {
        uniqueList.add(numbers[i]);
      }
    }
// [1,5,2,4,3] = 1,2,3,4,5
    // 5
    for (int i = 0; i < uniqueList.length; i++) {
      //4
      for (int j = 0; j < uniqueList.length - 1; j++) {
        // 5 > 2
        if (uniqueList[j] > uniqueList[j + 1]) {
          int temp = uniqueList[j];
          uniqueList[j] = uniqueList[j + 1];
          uniqueList[j + 1] = temp;
        }
      }
    }

    setState(() {
      output = uniqueList.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manual List Logic")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: inputController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter numbers like: 9,7,6,5,9,3,4,4,2",
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: processList,
              child: const Text("Process"),
            ),
            const SizedBox(height: 20),
            Text(
              "Output: $output",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
