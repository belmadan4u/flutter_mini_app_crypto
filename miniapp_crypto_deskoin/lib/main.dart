import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:miniapp_crypto_deskoin/crypto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1e2328)),
      ),
      home: const MyHomePage(title: 'Crypto Market Lite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Crypto> _cryptos = [];
  bool _loading = true;

  void initState(){
    _loadCryptos();
  }

  Future<void> _loadCryptos() async {
    final response = await http.get(Uri.parse('http://localhost:3000/assets'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        _cryptos = jsonData.map((json) => Crypto.fromJson(json)).toList();
        _loading = false;
        print(_cryptos.first.logoUrl);
      });
    } else {
      throw Exception('Erreur lors du chargement des utilisateurs');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Color(0xFF1e2328),
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded( // au cas ou pr gerer les erreur lié a column
              child: ListView.builder(
                itemCount: _cryptos.length,
                itemBuilder: (context, i){
                  final c = _cryptos[i];
                  return ListTile(
                    leading: SvgPicture.network(
                      c.logoUrl,
                      width: 40,
                      height: 40,
                      placeholderBuilder: (context) => CircularProgressIndicator(),
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                    ),
                    title: Text(c.name, 
                    style: TextStyle(
                        color: Colors.white 
                      )),
                    subtitle: Text('Prix : ${c.averagePrice} USD',
                      style: TextStyle(
                        color: Colors.white 
                      )
                      ),
                    trailing: Text(
                      '${c.change24h}%', 
                      style: TextStyle(
                        color: c.change24h > 0 ? Colors.green : Colors.red
                      )
                    ),
                  );
                }
              )
            )
          ],
        ),
      ),
    );
  }
}
