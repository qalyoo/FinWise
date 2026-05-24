import 'package:flutter/material.dart';
import 'card_screen.dart';
import 'transfer_screen.dart';
import 'pay_bills_screen.dart';
import 'analytics_screen.dart';
import 'add_transaction_screen.dart';
import 'transactions_screen.dart';
import 'goals_screen.dart';
import 'budgets_screen.dart';
import 'deposit_screen.dart';
import 'scheduled_payments_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _balance = 0;
  double _income = 0;
  double _expense = 0;
  List<dynamic> _scheduledPayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final summary = await ApiService.getSummary();
      final scheduled = await ApiService.getScheduledPayments();
      setState(() {
        _balance = (summary['balance'] as num).toDouble();
        _income = (summary['total_income'] as num).toDouble();
        _expense = (summary['total_expense'] as num).toDouble();
        _scheduledPayments = scheduled.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTopBar(context),
                      _buildCard(context),
                      const SizedBox(height: 20),
                      _buildQuickActions(context),
                      const SizedBox(height: 20),
                      _buildServices(context),
                      const SizedBox(height: 20),
                      _buildScheduledPayments(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE0E0E0),
            ),
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const Text(
            'FinWise',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddTransactionScreen()),
              );
              _loadData();
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4B6EF5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4B6EF5).withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CardScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF4B6EF5), Color(0xFF6C8EFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                right: 60,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Загальний баланс',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                              Image.asset(
                                'assets/images/visa.png',
                                width: 40,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.credit_card,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_balance.toStringAsFixed(2)} ₴',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_downward,
                                        color: Colors.greenAccent,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Дохід',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          '${_income.toStringAsFixed(0)} ₴',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_upward,
                                        color: Colors.redAccent,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Витрати',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          '${_expense.toStringAsFixed(0)} ₴',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': 'assets/images/money_transfer.png',
        'label': 'Грошовий\nпереказ',
        'screen': 'transfer',
      },
      {
        'icon': 'assets/images/pay_bills.png',
        'label': 'Оплатити\nрахунки',
        'screen': 'pay_bills',
      },
      {
        'icon': 'assets/images/all_payments.png',
        'label': 'Усі\nплатежі',
        'screen': 'transactions',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Швидкі дії',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: actions.map((action) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (action['screen'] == 'transfer') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransferScreen(),
                        ),
                      );
                    } else if (action['screen'] == 'pay_bills') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PayBillsScreen(),
                        ),
                      );
                    } else if (action['screen'] == 'transactions') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TransactionsScreen()),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: Image.asset(
                            action['icon']!,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.payment,
                              color: Colors.blue,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action['label']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServices(BuildContext context) {
    final services = [
      {
        'icon': 'assets/images/deposit_card.png',
        'label': 'Поповнити\nкартку',
        'screen': 'deposit',
      },
      {
        'icon': 'assets/images/charity.png',
        'label': 'Благодійність',
        'screen': '',
      },
      {'icon': 'assets/images/loan.png', 'label': 'Кредит', 'screen': ''},
      {'icon': 'assets/images/gifts.png', 'label': 'Подарунки', 'screen': ''},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Сервіси',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: services.asMap().entries.map((entry) {
              final i = entry.key;
              final service = entry.value;
              final isActive = i == 3;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (service['screen'] == 'deposit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DepositScreen()),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF4B6EF5) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: Image.asset(
                            service['icon']!,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Icon(
                              Icons.miscellaneous_services,
                              color: isActive ? Colors.white : Colors.grey,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          service['label']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive ? Colors.white : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledPayments(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Заплановані платежі',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScheduledPaymentsScreen(),
                    ),
                  );
                },
                child: Text(
                  'Дивитись всі',
                  style: TextStyle(fontSize: 13, color: Colors.blue[400]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _scheduledPayments.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Немає запланованих платежів',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: _scheduledPayments.asMap().entries.map((entry) {
                      final i = entry.key;
                      final payment = entry.value;
                      final isActive = payment['is_active'] == 1;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(
                                            0xFF4B6EF5,
                                          ).withOpacity(0.15)
                                        : Colors.grey.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.payment,
                                    color: isActive
                                        ? const Color(0xFF4B6EF5)
                                        : Colors.grey,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        payment['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        'Наступна оплата: ${payment['day_of_month']}-го',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${(payment['amount'] as num).toStringAsFixed(2)} ₴',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < _scheduledPayments.length - 1)
                            Divider(
                              height: 1,
                              color: Colors.grey[100],
                              indent: 16,
                              endIndent: 16,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Icon(Icons.home_rounded, color: Color(0xFF4B6EF5), size: 26),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BudgetsScreen()),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Colors.grey,
                size: 26,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TransactionsScreen()),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                color: Colors.grey,
                size: 26,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AnalyticsScreen()),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: Colors.grey,
                size: 26,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GoalsScreen()),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: Colors.grey,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
