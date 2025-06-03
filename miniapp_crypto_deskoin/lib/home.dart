import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:miniapp_crypto_deskoin/crypto.dart';
import 'package:miniapp_crypto_deskoin/detail.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum SortOrder { none, ascending, descending }

class _MyHomePageState extends State<MyHomePage> {
  List<Crypto> _cryptos = [];
  bool _loading = true;
  SortOrder _futureSortOrderAvgPrice = SortOrder.none;
  SortOrder _futureSortOrderChange24h = SortOrder.none;

  int _cryptoByPage = 10;
  int _currentPage = 1;
  List<Crypto> _cryptoShowed = [];

  @override
  void initState(){
    super.initState();
    _loadCryptos();
  }

  Future<void> _loadCryptos() async {
    final response = await http.get(Uri.parse('http://localhost:3000/assets'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        _cryptos = jsonData.asMap().entries.map((entry) {
          final index = entry.key;
          final json = entry.value;
          return Crypto.fromJson({...json, 'rank': index + 1});
        }).toList();
        _loading = false;
        _currentPage = 1;
        _updateCryptoShowed();
      });
     /* final imageTest = await http.get(Uri.parse(_cryptos[4].logoUrl));
      if (imageTest.statusCode != 200) {
        print('Erreur de chargement de l\'image SVG');
      }else{
        print(imageTest.body);
      }*/
    } else {
      throw Exception('Erreur lors du chargement des utilisateurs');
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
  }

  void _nextPage() {
    if (_currentPage * _cryptoByPage < _cryptos.length) {
      setState(() {
        _currentPage++;
        _updateCryptoShowed();
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _updateCryptoShowed();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1e2328),
      body: _loading ? Center(child: CircularProgressIndicator()): 
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [ 
            SizedBox( // row ne sait pas gérer la hauteur, on doit ajouter une height
              height: 50, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _futureSortOrderAvgPrice != SortOrder.none ? Colors.blue : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onPressed: _sortCryptoAvgPrice,
                    child: Row(
                      children: [
                        Text("Price"),
                        if (_futureSortOrderAvgPrice != SortOrder.none) ...[
                          SizedBox(width: 4),
                          Icon(
                            _futureSortOrderAvgPrice == SortOrder.descending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                            color: Colors.white,
                          ),
                        ]
                      ],
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _futureSortOrderChange24h != SortOrder.none ? Colors.blue : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onPressed: _sortCryptoChange24h,
                    child: Row(
                      children: [
                        Text("Change24h"),
                        if (_futureSortOrderChange24h != SortOrder.none) ...[
                          SizedBox(width: 4),
                          Icon(
                            _futureSortOrderChange24h == SortOrder.descending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                            color: Colors.white,
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _cryptos.isEmpty ? Text(
              "Aucune crypto n'a été récupérée",
              style: TextStyle(color: Colors.white),
            ) :
            Expanded( // au cas ou pr gerer les erreur lié a column
              child: ListTileTheme(
                textColor: Colors.white, // psk le texttheme de myapp se fait overrider par les params du listview 
                iconColor: Colors.white,
                child: ListView.builder(
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
                                        color: Colors.white,
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
                                        color: Colors.white,
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
                ),
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _currentPage > 1 ? _previousPage : null,
                  child: Text("Précédent"),
                ),
                Text(
                  'Page $_currentPage / ${(_cryptos.length / _cryptoByPage).ceil()}',
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: (_currentPage * _cryptoByPage) < _cryptos.length ? _nextPage : null,
                  child: Text("Suivant"),
                ),
              ],
            )
          ],
        ),
    );
  }
}
