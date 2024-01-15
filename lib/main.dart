import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:learn_directory/services/storage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  TextEditingController controller = TextEditingController();
  List<File> fileList = [];

  List<Directory> directoryList = [];

  @override
  void initState(){

    StorageService.getDirectory().then((value) {
      value.listSync().forEach((element) {
        if(element.path.endsWith(".txt")){
          if(element is File){
            log("message");
            log(fileList.toString());
            fileList.add(element);
          }
        }
      });
    });

    isLoading = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: isLoading
          ? Column(
        children: [
          ListView.builder(
            itemCount: fileList.length,
            shrinkWrap: true,
            itemBuilder: (context, index){
              return Card(
                child: ListTile(
                  title: Text(fileList[index].path),
                ),
              );
            },
          )
        ],
      )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Create New File"),
                content: TextField(
                  controller: controller,
                ),
                actions: [
                  IconButton(
                    onPressed: ()async{
                      // File file = await StorageService.createNewFile(controller.text.trim());
                      File file = await StorageService.writeToFile(controller.text.trim(), "");
                      await StorageService.readFromFile(controller.text.trim()).then((value) {
                        isLoading = true;
                      });
                      fileList.add(file);
                      setState(() {});
                      controller.clear();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.done_all),
                  )
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
