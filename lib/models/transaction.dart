class TransactionModel {
  final String title;       // Judul transaksi (contoh: "Makan Siang Padang")
  final String category;    // Kategori transaksi (contoh: "Makanan")
  final String date;        // Tanggal transaksi (contoh: "25 Jun 2026")
  final double amount;      // Nominal angka transaksi (contoh: 45000)
  final bool isIncome;      // Status apakah pemasukan (true) atau pengeluaran (false)
  final String initial;     // Huruf inisial untuk ikon lingkaran (contoh: "M")

  TransactionModel({
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.initial,
  });

  // Constructor untuk parsing dari JSON API
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    String title = json['title'] ?? '';
    String category = json['category'] ?? '';
    
    // Handle is_income bisa dari berbagai format
    bool isIncome = false;
    var incomeValue = json['is_income'] ?? json['isIncome'];
    if (incomeValue is bool) {
      isIncome = incomeValue;
    } else if (incomeValue is int) {
      isIncome = incomeValue == 1;
    } else if (incomeValue is String) {
      isIncome = incomeValue.toLowerCase() == 'true' || incomeValue == '1';
    }
    
    return TransactionModel(
      title: title,
      category: category,
      date: json['date'] ?? DateTime.now().toString().split(' ')[0],
      amount: double.parse(json['amount'].toString()),
      isIncome: isIncome,
      initial: title.isNotEmpty ? title[0].toUpperCase() : '?',
    );
  }

  // Helper untuk mendapatkan teks nominal dengan format tanda + atau -
  String get formattedAmount {
    String sign = isIncome ? '+ ' : '- ';
    return '$sign${_formatRupiah(amount)}';
  }

  // Fungsi sederhana untuk memformat double menjadi format Rupiah tanpa package eksternal
  String _formatRupiah(double value) {
    // Mengubah ke ribuan menggunakan regex sederhana agar kode tetap mandiri
    String digits = value.toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp ${digits.replaceAllMapped(reg, (Match match) => '${match[1]}.')}';
  }
}