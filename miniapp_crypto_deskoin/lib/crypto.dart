class Crypto {
  final String ticker;
  final String name;
  final String logoUrl;
  final double averagePrice; 
  final double change24h;
  final String id;

  Crypto({
      required this.ticker,
      required this.name,
      required this.logoUrl,
      required this.averagePrice,
      required this.change24h,
      required this.id,
    });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      ticker: json['ticker'],
      name: json['name'],
      logoUrl: json['logoUrl'],
      averagePrice: (json['averagePrice'] as num).toDouble(),
      change24h: (json['change24h'] as num).toDouble(),
      id: json['id'],
    );
  }
}