import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const AvtoQarzApp());
}

class AvtoQarzApp extends StatelessWidget {
  const AvtoQarzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avto Qarz Kalkulyatori',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const LoanCalculatorPage(),
    );
  }
}

class LoanCalculatorPage extends StatefulWidget {
  const LoanCalculatorPage({super.key});

  @override
  State<LoanCalculatorPage> createState() => _LoanCalculatorPageState();
}

class _LoanCalculatorPageState extends State<LoanCalculatorPage> {
  // Controllers - kirish maydonlari uchun
  final TextEditingController _carPriceController = TextEditingController();
  final TextEditingController _downPaymentController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _loanTermController = TextEditingController();

  // Form key - validatsiya uchun
  final _formKey = GlobalKey<FormState>();

  // Natijalar
  double _monthlyPayment = 0;
  double _totalPayment = 0;
  double _totalInterest = 0;
  List<PaymentSchedule> _paymentSchedule = [];
  bool _showResults = false;

  @override
  void dispose() {
    _carPriceController.dispose();
    _downPaymentController.dispose();
    _interestRateController.dispose();
    _loanTermController.dispose();
    super.dispose();
  }

  /// Raqamlarni formatlash: 1000000 -> "1 000 000"
  String formatNumber(double number) {
    String numStr = number.toStringAsFixed(0);
    String result = '';
    int count = 0;

    for (int i = numStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ' $result';
        count = 0;
      }
      result = numStr[i] + result;
      count++;
    }

    return result.trim();
  }

  /// Stringni raqamga o'girish: "1 000 000" -> 1000000
  double parseFormattedNumber(String text) {
    return double.tryParse(text.replaceAll(' ', '')) ?? 0;
  }

  /// Kredit to'lovlarini hisoblash - Annuity formula
  void calculateLoan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Kiritilgan qiymatlarni olish
    double carPrice = parseFormattedNumber(_carPriceController.text);
    double downPayment = parseFormattedNumber(_downPaymentController.text);
    double annualRate = double.parse(_interestRateController.text);
    int loanTerm = int.parse(_loanTermController.text);

    // Kredit summasi
    double loanAmount = carPrice - downPayment;

    // Oylik foiz stavka
    double monthlyRate = annualRate / 12 / 100;

    // Annuity formulasi: M = P * (r * (1 + r)^n) / ((1 + r)^n - 1)
    double monthlyPayment;

    if (monthlyRate == 0) {
      // Agar foiz 0 bo'lsa
      monthlyPayment = loanAmount / loanTerm;
    } else {
      double factor = pow(1 + monthlyRate, loanTerm).toDouble();
      monthlyPayment = loanAmount * (monthlyRate * factor) / (factor - 1);
    }

    // Jami to'lov
    double totalPayment = monthlyPayment * loanTerm;

    // Jami foiz
    double totalInterest = totalPayment - loanAmount;

    // To'lov jadvalini hisoblash
    List<PaymentSchedule> schedule = [];
    double remainingBalance = loanAmount;

    for (int month = 1; month <= loanTerm; month++) {
      double interestPayment = remainingBalance * monthlyRate;
      double principalPayment = monthlyPayment - interestPayment;
      remainingBalance -= principalPayment;

      // Oxirgi oyda qoldiqni to'g'rilash
      if (month == loanTerm && remainingBalance.abs() < 1) {
        remainingBalance = 0;
      }

      schedule.add(PaymentSchedule(
        month: month,
        payment: monthlyPayment,
        principal: principalPayment,
        interest: interestPayment,
        balance: remainingBalance < 0 ? 0 : remainingBalance,
      ));
    }

    setState(() {
      _monthlyPayment = monthlyPayment;
      _totalPayment = totalPayment;
      _totalInterest = totalInterest;
      _paymentSchedule = schedule;
      _showResults = true;
    });

    // Natijalar qismiga scroll qilish
    Future.delayed(const Duration(milliseconds: 300), () {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  /// Formani tozalash
  void clearForm() {
    setState(() {
      _carPriceController.clear();
      _downPaymentController.clear();
      _interestRateController.clear();
      _loanTermController.clear();
      _showResults = false;
      _paymentSchedule = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Avto Qarz Kalkulyatori',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kirish maydonlari
                _buildInputSection(),

                const SizedBox(height: 24),

                // Tugmalar
                _buildActionButtons(),

                const SizedBox(height: 24),

                // Natijalar
                if (_showResults) ...[
                  _buildResultsSection(),
                  const SizedBox(height: 24),
                  _buildPaymentSchedule(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kirish maydonlari qismi
  Widget _buildInputSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ma\'lumotlarni kiriting',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),

            // Avtomobil narxi
            _buildNumberInputField(
              controller: _carPriceController,
              label: 'Avtomobil narxi',
              hint: 'Masalan: 200 000 000',
              icon: Icons.directions_car,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Iltimos, avtomobil narxini kiriting';
                }
                double price = parseFormattedNumber(value);
                if (price <= 0) {
                  return 'Narx 0 dan katta bo\'lishi kerak';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Dastlabki to'lov
            _buildNumberInputField(
              controller: _downPaymentController,
              label: 'Dastlabki to\'lov',
              hint: 'Masalan: 50 000 000',
              icon: Icons.payments,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Iltimos, dastlabki to\'lovni kiriting';
                }
                double downPayment = parseFormattedNumber(value);
                double carPrice = parseFormattedNumber(_carPriceController.text);

                if (downPayment < 0) {
                  return 'Dastlabki to\'lov 0 dan kichik bo\'lmasligi kerak';
                }
                if (downPayment >= carPrice) {
                  return 'Dastlabki to\'lov avtomobil narxidan kam bo\'lishi kerak';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Foiz stavka
            TextFormField(
              controller: _interestRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Yillik foiz stavka (%)',
                hintText: 'Masalan: 18',
                prefixIcon: Icon(Icons.percent),
                suffixText: '%',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Iltimos, foiz stavkani kiriting';
                }
                double rate = double.tryParse(value) ?? -1;
                if (rate < 0) {
                  return 'Foiz stavka 0 dan kichik bo\'lmasligi kerak';
                }
                if (rate > 100) {
                  return 'Foiz stavka 100 dan oshmasligi kerak';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Kredit muddati
            TextFormField(
              controller: _loanTermController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Kredit muddati (oy)',
                hintText: 'Masalan: 36',
                prefixIcon: Icon(Icons.calendar_today),
                suffixText: 'oy',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Iltimos, kredit muddatini kiriting';
                }
                int term = int.tryParse(value) ?? 0;
                if (term <= 0) {
                  return 'Muddat 0 dan katta bo\'lishi kerak';
                }
                if (term > 360) {
                  return 'Muddat 360 oydan oshmasligi kerak';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Raqam kiritish maydoni (formatlanadi)
  Widget _buildNumberInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _NumberFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixText: 'so\'m',
      ),
      validator: validator,
    );
  }

  /// Tugmalar qismi
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: calculateLoan,
            icon: const Icon(Icons.calculate),
            label: const Text('Hisoblash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: clearForm,
            icon: const Icon(Icons.clear),
            label: const Text('Tozalash'),
          ),
        ),
      ],
    );
  }

  /// Natijalar qismi
  Widget _buildResultsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hisoblash natijalari',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const Divider(height: 24),

            // Oylik to'lov
            _buildResultItem(
              icon: Icons.calendar_month,
              label: 'Oylik to\'lov',
              value: '${formatNumber(_monthlyPayment)} so\'m',
              color: Colors.blue,
              isMain: true,
            ),

            const SizedBox(height: 12),

            // Jami to'lov
            _buildResultItem(
              icon: Icons.account_balance_wallet,
              label: 'Jami to\'lanadigan summa',
              value: '${formatNumber(_totalPayment)} so\'m',
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            // Jami foiz
            _buildResultItem(
              icon: Icons.trending_up,
              label: 'Jami to\'lanadigan foiz',
              value: '${formatNumber(_totalInterest)} so\'m',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// Natija elementi
  Widget _buildResultItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isMain = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMain ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// To'lov jadvali
  Widget _buildPaymentSchedule() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'To\'lov jadvali',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Jadval sarlavhasi
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTableHeader('Oy', flex: 1),
                  _buildTableHeader('To\'lov', flex: 2),
                  _buildTableHeader('Asosiy', flex: 2),
                  _buildTableHeader('Foiz', flex: 2),
                  _buildTableHeader('Qoldiq', flex: 2),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Jadval qatorlari (faqat birinchi 12 oyni ko'rsatamiz, qolganlari scroll)
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _paymentSchedule.length,
                itemBuilder: (context, index) {
                  PaymentSchedule schedule = _paymentSchedule[index];
                  bool isEven = index % 2 == 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isEven ? Colors.grey[50] : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        _buildTableCell('${schedule.month}', flex: 1),
                        _buildTableCell(formatNumber(schedule.payment), flex: 2, isSmall: true),
                        _buildTableCell(formatNumber(schedule.principal), flex: 2, isSmall: true),
                        _buildTableCell(formatNumber(schedule.interest), flex: 2, isSmall: true),
                        _buildTableCell(formatNumber(schedule.balance), flex: 2, isSmall: true),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text, {int flex = 1, bool isSmall = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: isSmall ? 10 : 12,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// To'lov jadvali modeli
class PaymentSchedule {
  final int month;
  final double payment;
  final double principal;
  final double interest;
  final double balance;

  PaymentSchedule({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });
}

/// Raqamlarni formatlash uchun input formatter
class _NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Faqat raqamlarni olish
    String digitsOnly = newValue.text.replaceAll(' ', '');

    // Formatli qilib yozish (har 3 raqamdan keyin probel)
    String formatted = '';
    int count = 0;

    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = ' $formatted';
        count = 0;
      }
      formatted = digitsOnly[i] + formatted;
      count++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
