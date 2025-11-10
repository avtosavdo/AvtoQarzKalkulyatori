import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

/// Loan Calculator Page with Bank Credit and Installment (Rassrochka)
///
/// Features:
/// - Bank Credit (Annuity formula)
/// - Installment/Rassrochka (Yearly markup: 1yr=25%, 2yr=50%, 3yr=75%)
/// - Currency selector (UZS/USD)
/// - Comparison view
class LoanCalculatorPage extends StatefulWidget {
  const LoanCalculatorPage({super.key});

  @override
  State<LoanCalculatorPage> createState() => _LoanCalculatorPageState();
}

class _LoanCalculatorPageState extends State<LoanCalculatorPage> {
  // Controllers
  final TextEditingController _carPriceController = TextEditingController();
  final TextEditingController _downPaymentController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _loanTermController = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Credit type selection
  CreditType _selectedCreditType = CreditType.bank;

  // Currency selection
  CurrencyType _selectedCurrency = CurrencyType.uzs;

  // Results
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

  /// Get currency symbol
  String get currencySymbol {
    return _selectedCurrency == CurrencyType.uzs ? 'so\'m' : '\$';
  }

  /// Get currency name
  String get currencyName {
    return _selectedCurrency == CurrencyType.uzs ? 'So\'m' : 'Dollar';
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

  /// RASSROCHKA USTAMA FOIZINI ANIQLASH
  /// 1-12 oy: 25% (1 yil)
  /// 13-24 oy: 50% (2 yil)
  /// 25-36 oy: 75% (3 yil)
  /// 37-48 oy: 100% (4 yil)
  double getInstallmentMarkupRate(int months) {
    if (months <= 12) {
      return 25.0; // 1 yil
    } else if (months <= 24) {
      return 50.0; // 2 yil
    } else if (months <= 36) {
      return 75.0; // 3 yil
    } else if (months <= 48) {
      return 100.0; // 4 yil
    } else {
      // 48+ oy uchun har yil uchun 25% qo'shamiz
      int years = (months / 12).ceil();
      return years * 25.0;
    }
  }

  /// BANK KREDITI - Annuity formula
  void calculateBankLoan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    double carPrice = parseFormattedNumber(_carPriceController.text);
    double downPayment = parseFormattedNumber(_downPaymentController.text);
    double annualRate = double.parse(_interestRateController.text);
    int loanTerm = int.parse(_loanTermController.text);

    double loanAmount = carPrice - downPayment;
    double monthlyRate = annualRate / 12 / 100;

    double monthlyPayment;

    if (monthlyRate == 0) {
      monthlyPayment = loanAmount / loanTerm;
    } else {
      double factor = pow(1 + monthlyRate, loanTerm).toDouble();
      monthlyPayment = loanAmount * (monthlyRate * factor) / (factor - 1);
    }

    double totalPayment = monthlyPayment * loanTerm;
    double totalInterest = totalPayment - loanAmount;

    // To'lov jadvali
    List<PaymentSchedule> schedule = [];
    double remainingBalance = loanAmount;

    for (int month = 1; month <= loanTerm; month++) {
      double interestPayment = remainingBalance * monthlyRate;
      double principalPayment = monthlyPayment - interestPayment;
      remainingBalance -= principalPayment;

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

    _scrollToResults();
  }

  /// RASSROCHKA - Yearly markup calculation
  void calculateInstallment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    double carPrice = parseFormattedNumber(_carPriceController.text);
    double downPayment = parseFormattedNumber(_downPaymentController.text);
    double markupRate = double.parse(_interestRateController.text);
    int loanTerm = int.parse(_loanTermController.text);

    // Kredit summasi
    double loanAmount = carPrice - downPayment;

    // Jami ustama (asosiy summadan)
    double totalMarkup = loanAmount * (markupRate / 100);

    // Jami to'lov
    double totalPayment = loanAmount + totalMarkup;

    // Oylik to'lov (bir xil bo'ladi)
    double monthlyPayment = totalPayment / loanTerm;

    // To'lov jadvali (har oy bir xil)
    List<PaymentSchedule> schedule = [];
    double remainingBalance = totalPayment;

    for (int month = 1; month <= loanTerm; month++) {
      remainingBalance -= monthlyPayment;

      if (month == loanTerm && remainingBalance.abs() < 1) {
        remainingBalance = 0;
      }

      // Rassrochkada principal va interest alohida bo'lmaydi
      // Lekin ko'rsatish uchun approximate qilamiz
      double principalPart = loanAmount / loanTerm;
      double interestPart = totalMarkup / loanTerm;

      schedule.add(PaymentSchedule(
        month: month,
        payment: monthlyPayment,
        principal: principalPart,
        interest: interestPart,
        balance: remainingBalance < 0 ? 0 : remainingBalance,
      ));
    }

    setState(() {
      _monthlyPayment = monthlyPayment;
      _totalPayment = totalPayment;
      _totalInterest = totalMarkup;
      _paymentSchedule = schedule;
      _showResults = true;
    });

    _scrollToResults();
  }

  /// Kredit hisoblash (type ga qarab)
  void calculateLoan() {
    if (_selectedCreditType == CreditType.bank) {
      calculateBankLoan();
    } else {
      calculateInstallment();
    }
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

  /// Natijalar qismiga scroll
  void _scrollToResults() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
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
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                // Currency selector
                _buildCurrencySelector(),

                const SizedBox(height: 16),

                // Credit type selector
                _buildCreditTypeSelector(),

                const SizedBox(height: 16),

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

  /// Currency selector
  Widget _buildCurrencySelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valyuta turini tanlang',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCurrencyOption(
                    type: CurrencyType.uzs,
                    icon: Icons.currency_exchange,
                    title: 'O\'zbek so\'mi',
                    subtitle: 'UZS',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCurrencyOption(
                    type: CurrencyType.usd,
                    icon: Icons.attach_money,
                    title: 'AQSH dollari',
                    subtitle: 'USD',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Currency option widget
  Widget _buildCurrencyOption({
    required CurrencyType type,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedCurrency == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCurrency = type;
          _showResults = false; // Natijalarni yashirish
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Credit type selector
  Widget _buildCreditTypeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kredit turini tanlang',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCreditTypeOption(
                    type: CreditType.bank,
                    icon: Icons.account_balance,
                    title: 'Bank krediti',
                    subtitle: 'Annuity formula',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCreditTypeOption(
                    type: CreditType.installment,
                    icon: Icons.shopping_cart,
                    title: 'Rassrochka',
                    subtitle: 'Qora bozor',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Credit type option widget
  Widget _buildCreditTypeOption({
    required CreditType type,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedCreditType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCreditType = type;
          _showResults = false; // Natijalarni yashirish
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
              hint: _selectedCurrency == CurrencyType.uzs
                  ? 'Masalan: 200 000 000'
                  : 'Masalan: 15 000',
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
              hint: _selectedCurrency == CurrencyType.uzs
                  ? 'Masalan: 50 000 000'
                  : 'Masalan: 5 000',
              icon: Icons.payments,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Iltimos, dastlabki to\'lovni kiriting';
                }
                double downPayment = parseFormattedNumber(value);
                double carPrice =
                    parseFormattedNumber(_carPriceController.text);

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

            // Foiz/Ustama stavka
            TextFormField(
              controller: _interestRateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: _selectedCreditType == CreditType.bank
                    ? 'Yillik foiz stavka (%)'
                    : 'Ustama foiz (%)',
                hintText: _selectedCreditType == CreditType.bank
                    ? 'Masalan: 18'
                    : 'Masalan: 25',
                prefixIcon: const Icon(Icons.percent),
                suffixText: '%',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _selectedCreditType == CreditType.bank
                      ? 'Iltimos, foiz stavkani kiriting'
                      : 'Iltimos, ustama foizni kiriting';
                }
                double rate = double.tryParse(value) ?? -1;
                if (rate < 0) {
                  return 'Foiz 0 dan kichik bo\'lmasligi kerak';
                }
                if (rate > 100) {
                  return 'Foiz 100 dan oshmasligi kerak';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Kredit muddati.
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

  /// Raqam kiritish maydoni
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
        suffixText: currencySymbol,
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
            Row(
              children: [
                Icon(
                  _selectedCreditType == CreditType.bank
                      ? Icons.account_balance
                      : Icons.shopping_cart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedCreditType == CreditType.bank
                        ? 'Bank krediti natijalari'
                        : 'Rassrochka natijalari',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Oylik to'lov
            _buildResultItem(
              icon: Icons.calendar_month,
              label: 'Oylik to\'lov',
              value: '${formatNumber(_monthlyPayment)} $currencySymbol',
              color: Colors.blue,
              isMain: true,
            ),

            const SizedBox(height: 12),

            // Jami to'lov
            _buildResultItem(
              icon: Icons.account_balance_wallet,
              label: 'Jami to\'lanadigan summa',
              value: '${formatNumber(_totalPayment)} $currencySymbol',
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            // Jami foiz/ustama
            _buildResultItem(
              icon: Icons.trending_up,
              label: _selectedCreditType == CreditType.bank
                  ? 'Jami to\'lanadigan foiz'
                  : 'Jami ustama',
              value: '${formatNumber(_totalInterest)} $currencySymbol',
              color: Colors.orange,
            ),

            // Rassrochka uchun qo'shimcha info
            if (_selectedCreditType == CreditType.installment) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.purple[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ustama foiz: ${_interestRateController.text}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
                Icon(Icons.table_chart,
                    color: Theme.of(context).colorScheme.primary),
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
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTableHeader('Oy', flex: 1),
                  _buildTableHeader('To\'lov', flex: 2),
                  _buildTableHeader('Asosiy', flex: 2),
                  _buildTableHeader(
                    _selectedCreditType == CreditType.bank ? 'Foiz' : 'Ustama',
                    flex: 2,
                  ),
                  _buildTableHeader('Qoldiq', flex: 2),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Jadval qatorlari
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _paymentSchedule.length,
                itemBuilder: (context, index) {
                  PaymentSchedule schedule = _paymentSchedule[index];
                  bool isEven = index % 2 == 0;

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isEven ? Colors.grey[50] : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        _buildTableCell('${schedule.month}', flex: 1),
                        _buildTableCell(formatNumber(schedule.payment),
                            flex: 2, isSmall: true),
                        _buildTableCell(formatNumber(schedule.principal),
                            flex: 2, isSmall: true),
                        _buildTableCell(formatNumber(schedule.interest),
                            flex: 2, isSmall: true),
                        _buildTableCell(formatNumber(schedule.balance),
                            flex: 2, isSmall: true),
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

/// Credit type enum
enum CreditType {
  bank, // Bank krediti (Annuity)
  installment, // Rassrochka (Simple markup)
}

/// Currency type enum
enum CurrencyType {
  uzs, // O'zbek so'mi
  usd, // AQSH dollari
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

    String digitsOnly = newValue.text.replaceAll(' ', '');
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
