import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'crypto.dart';
import 'detail.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum SortOrder { none, ascending, descending }

class _MyHomePageState extends State<MyHomePage> {
  String? _errorMessage;

  List<Crypto> _cryptos = [];
  bool _loading = true;
  SortOrder _futureSortOrderAvgPrice = SortOrder.none;
  SortOrder _futureSortOrderChange24h = SortOrder.none;

  final int _cryptoByPage = 10;
  int _currentPage = 1;
  List<Crypto> _cryptoShowed = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState(){
    super.initState();
    _loadCryptos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCryptos() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/assets'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _cryptos = jsonData.asMap().entries.map((entry) {
            final index = entry.key;
            final json = entry.value;
            return Crypto.fromJson({...json, 'rank': index + 1});
          }).toList();

          /*await Future.wait(_cryptos.map((crypto) async {
            final imgResponse = await http.get(Uri.parse(crypto.logoUrl));

            if (imgResponse.statusCode != 200) {
              print('Error for ${crypto.name}');
            } else {
              String svgContent = imgResponse.body;
              final cleanedSvg = svgContent.replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '');

              crypto.logoUrl = cleanedSvg;
            }
          }));*/

          _loading = false;
          _errorMessage = null;
          _currentPage = 1;
          _updateCryptoShowed();
        });
      } else {
        setState(() {
          _loading = false;
          _errorMessage = 'Error : ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Error 500';
      });
    }
  }

  void _updateCryptoShowed() {
    final start = (_currentPage - 1) * _cryptoByPage;
    final end = (_currentPage * _cryptoByPage).clamp(0, _cryptos.length);
    setState(() {
      _cryptoShowed = _cryptos.sublist(start, end);
    });
  }

  void _sortCryptoAvgPrice() {
    setState(() {
      switch(_futureSortOrderAvgPrice){
        case SortOrder.none:
          _futureSortOrderChange24h = SortOrder.none;
          _cryptos.sort((a, b) => a.averagePrice.compareTo(b.averagePrice));
          _futureSortOrderAvgPrice = SortOrder.ascending;
          break;
        case SortOrder.ascending:
          _cryptos.sort((a, b) => b.averagePrice.compareTo(a.averagePrice));
          _futureSortOrderAvgPrice = SortOrder.descending;
          break;
        case SortOrder.descending:
          _futureSortOrderAvgPrice = SortOrder.none;
          _loadCryptos(); 
          return;
      }
      _currentPage = 1;
      _updateCryptoShowed();
    });
    scrollToTheTop();
  }

  void _sortCryptoChange24h() {
    setState(() {
      switch(_futureSortOrderChange24h){
        case SortOrder.none:
          _futureSortOrderAvgPrice = SortOrder.none;
          _cryptos.sort((a, b) => a.change24h.compareTo(b.change24h));
          _futureSortOrderChange24h = SortOrder.ascending;
          break;
        case SortOrder.ascending:
          _cryptos.sort((a, b) => b.change24h.compareTo(a.change24h));
          _futureSortOrderChange24h = SortOrder.descending;
          break;
        case SortOrder.descending:
          _futureSortOrderChange24h = SortOrder.none;
          _loadCryptos(); 
          return;
      }
      _currentPage = 1;
      _updateCryptoShowed();
    });
    scrollToTheTop();
  }

  void _nextPage() {
    if (_currentPage * _cryptoByPage < _cryptos.length) {
      setState(() {
        _currentPage++;
        _updateCryptoShowed();
      });
      scrollToTheTop();
    }
  }

  void scrollToTheTop(){
     _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _updateCryptoShowed();
      });
      scrollToTheTop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
      ? CircularProgressIndicator()
      : _errorMessage != null
          ? Text(
              _errorMessage!,
              style: TextStyle(fontSize: 20, color: Colors.red),
              textAlign: TextAlign.center,
            )
          : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [ 
            SizedBox( // row ne sait pas gérer la hauteur, on doit ajouter une height
              height: 50, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Sort by :"),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _futureSortOrderAvgPrice != SortOrder.none ? Colors.blue : Colors.grey,
                    ),
                    onPressed: _sortCryptoAvgPrice,
                    child: Row(
                      children: [
                        Text("Price"),
                        if (_futureSortOrderAvgPrice != SortOrder.none) ...[
                          Text(
                            _futureSortOrderAvgPrice == SortOrder.descending
                                ? " - ascending"
                                : " - descending"
                          ),
                        ]
                      ],
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _futureSortOrderChange24h != SortOrder.none ? Colors.blue : Colors.grey
                    ),
                    onPressed: _sortCryptoChange24h,
                    child: Row(
                      children: [
                        Text("Variation"),
                        if (_futureSortOrderChange24h != SortOrder.none) ...[
                          Text(
                            _futureSortOrderChange24h == SortOrder.descending
                                ? " - ascending"
                                : " - descending"
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _cryptos.isEmpty ? Text(
              "No crypto was fetched",
            ) :
            Expanded( // au cas ou pr gerer les erreur lié a column
              child: ListTileTheme(
                textColor: Colors.white, // psk le texttheme de myapp se fait overrider par les params du listview 
                iconColor: Colors.white,
                child: Scrollbar(
                  thumbVisibility: true, 
                  controller: _scrollController, 
                  child: ListView.builder(
                    controller: _scrollController, 
                    itemCount: _cryptoShowed.length,
                    itemBuilder: (context, i) {
                      final c = _cryptoShowed[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(crypto: c),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.grey[900],
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              
                              children: [
                                // Rang + Logo
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      child: Text(
                                        '${c.rank}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    SvgPicture.network(
                                      c.logoUrl,
                                      width: 40,
                                      height: 40,
                                      placeholderBuilder: (context) => SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.error, color: Colors.redAccent),
                                    ),
                                  ],
                                ),

                                SizedBox(width: 16),

                                // Nom + Prix
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Price: ${c.averagePrice} USD',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Variation %
                                Text(
                                  '${c.change24h > 0 ? '+' : ''}${c.change24h.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: c.change24h > 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      );
                    }
                  )
                  ),
                )
              )
            ,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _currentPage > 1 ? _previousPage : null,
                  child: Text("Previous"),
                ),
                Text(
                  'Page $_currentPage / ${(_cryptos.length / _cryptoByPage).ceil()}'
                ),
                TextButton(
                  onPressed: (_currentPage * _cryptoByPage) < _cryptos.length ? _nextPage : null,
                  child: Text("Next"),
                ),
              ],
            )
          ],
        ),
    );
  }
}
