class Bet {
  final int? id;
  final String time;
  final int amount;
  final String type;
  final String result;
  final int profit;
  final int total;

  Bet({
    this.id,
    required this.time,
    required this.amount,
    required this.type,
    required this.result,
    required this.profit,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time,
        'amount': amount,
        'type': type,
        'result': result,
        'profit': profit,
        'total': total,
      };

  static Bet fromJson(Map<String, dynamic> json) => Bet(
        id: json['id'] as int?,
        time: json['time'] as String,
        amount: json['amount'] as int,
        type: json['type'] as String,
        result: json['result'] as String,
        profit: json['profit'] as int,
        total: (json['amount'] as int) + (json['profit'] as int),
      );
}
