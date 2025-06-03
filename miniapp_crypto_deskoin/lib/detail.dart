import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:miniapp_crypto_deskoin/crypto.dart';

class DetailPage extends StatelessWidget {
  DetailPage({super.key, required this.crypto});
  
  final Crypto crypto;
  final List<FlSpot> data = [];

  Future<List<FlSpot>> fetchChartData() async {
    print(crypto.name);
    final url = Uri.parse('https://api.coingecko.com/api/v3/coins/${crypto.name.toLowerCase()}/market_chart?vs_currency=eur&days=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List prices = data['prices'];

      // Transforme les prix en FlSpot (x: timestamp, y: price)
      return prices.asMap().entries.map((entry) {
        int index = entry.key;
        double price = entry.value[1];
        return FlSpot(index.toDouble(), price);
      }).toList();
    } else {
      throw Exception('Erreur lors de la récupération des données');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(crypto.name),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Color(0xFF1e2328),
      body: FutureBuilder<List<FlSpot>>(
        future: fetchChartData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune donnée disponible', style: TextStyle(color: Colors.white)));
          }

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(show: true),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: false,
                    color: crypto.change24h < 0 ? Colors.red : Colors.green,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}