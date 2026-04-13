import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../utils/constants.dart';
import '../widgets/cyber_card.dart';

class ExtrasTab extends StatefulWidget {
  const ExtrasTab({super.key});

  @override
  State<ExtrasTab> createState() => _ExtrasTabState();
}

class _ExtrasTabState extends State<ExtrasTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _baseNameController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _playerData;
  String _selectedStyle = 'cool';
  List<String> _generatedNicknames = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _uidController.dispose();
    _baseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildTabBar(),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPlayerSearch(),
              _buildNicknameGenerator(),
              _buildRedeemCodes(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.electricBlue,
        labelColor: AppColors.electricBlue,
        unselectedLabelColor: AppColors.gray,
        tabs: const [
          Tab(icon: Icon(Ionicons.search), text: 'Player'),
          Tab(icon: Icon(Ionicons.text), text: 'Name'),
          Tab(icon: Icon(Ionicons.gift), text: 'Codes'),
        ],
      ),
    );
  }

  Widget _buildPlayerSearch() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SEARCH PLAYER',
                  style: TextStyle(
                    color: AppColors.electricBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _uidController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter Player UID',
                    hintStyle: TextStyle(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.darkGray2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person, color: AppColors.gray),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchPlayer,
                    child: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('SEARCH'),
                  ),
                ),
              ],
            ),
          ),
          if (_playerData != null) _buildPlayerResult(),
        ],
      ),
    );
  }

  Widget _buildPlayerResult() {
    return CyberCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.neonPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Ionicons.person,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _playerData!['nickname'] ?? 'Player',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${_playerData!['level'] ?? 0}',
                      style: const TextStyle(color: AppColors.gray),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Rank', _playerData!['rank'] ?? 'Bronze'),
              _buildStat('BP', '${_playerData!['bp'] ?? 0}'),
              _buildStat('Credit', '${_playerData!['credit'] ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.electricBlue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.gray, fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _searchPlayer() async {
    if (_uidController.text.isEmpty) return;
    setState(() => _isSearching = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSearching = false;
      _playerData = {
        'nickname': 'ProGamer_${_uidController.text.substring(0, 4)}',
        'level': 65,
        'rank': 'Diamond',
        'bp': 12500,
        'credit': 100,
      };
    });
  }

  Widget _buildNicknameGenerator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GENERATE NICKNAME',
                  style: TextStyle(
                    color: AppColors.neonPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _baseNameController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Base Name (optional)',
                    hintStyle: TextStyle(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.darkGray2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Style', style: TextStyle(color: AppColors.gray)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildStyleChip('cool', 'Cool'),
                    _buildStyleChip('elite', 'Elite'),
                    _buildStyleChip('ninja', 'Ninja'),
                    _buildStyleChip('legend', 'Legend'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _generateNicknames,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonPurple,
                    ),
                    child: const Text('GENERATE'),
                  ),
                ),
              ],
            ),
          ),
          if (_generatedNicknames.isNotEmpty)
            ..._generatedNicknames.map((n) => _buildNicknameItem(n)),
        ],
      ),
    );
  }

  Widget _buildStyleChip(String value, String label) {
    final isSelected = _selectedStyle == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStyle = value);
      },
      selectedColor: AppColors.neonPurple,
      backgroundColor: AppColors.darkGray2,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.gray,
      ),
    );
  }

  Widget _buildNicknameItem(String nickname) {
    return CyberCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              nickname,
              style: const TextStyle(color: AppColors.white, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Ionicons.copy, color: AppColors.electricBlue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard!'),
                  backgroundColor: AppColors.neonPurple,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _generateNicknames() {
    final prefixes = ['Cool', 'Elite', 'Ninja', 'Legend', 'Shadow'];
    final words = ['Blaze', 'Phoenix', 'Storm', 'Raptor', 'Titan'];
    final suffixes = ['Pro', 'Master', 'X', 'Z', '777'];
    final symbols = ['⚡', '꧁', '々', '乂'];

    final base = _baseNameController.text.isEmpty
        ? ''
        : _baseNameController.text;

    setState(() {
      _generatedNicknames = List.generate(5, (i) {
        String name = '';
        if (base.isNotEmpty) {
          name = '${prefixes[i % prefixes.length]}$base';
        } else {
          name = '${prefixes[i % prefixes.length]}${words[i % words.length]}';
        }
        name +=
            '${suffixes[i % suffixes.length]}${symbols[i % symbols.length]}';
        return name;
      });
    });
  }

  Widget _buildRedeemCodes() {
    final codes = [
      {'code': 'FFGC2024', 'reward': '100 Diamonds'},
      {'code': 'FFIC2024', 'reward': '50 Knight Coupon'},
      {'code': 'FFREWARD', 'reward': '300 EP'},
      {'code': 'GARENA100', 'reward': '100 Diamonds'},
      {'code': 'FREEFIRE', 'reward': 'Ultimate Bundle'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: codes.length,
      itemBuilder: (context, index) {
        final item = codes[index];
        return CyberCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Ionicons.gift, color: AppColors.electricBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['code']!,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item['reward']!,
                      style: const TextStyle(
                        color: AppColors.gray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Ionicons.copy, color: AppColors.gray),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Ionicons.open, color: AppColors.neonPurple),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
