import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmanagmentapp/PersonelSayfalar/personelAyarlar.dart';
import 'package:taskmanagmentapp/model/bireyselGorevler.dart';
import 'package:taskmanagmentapp/model/ekipGorevler.dart';
import 'package:taskmanagmentapp/class/image2.dart';
import 'package:taskmanagmentapp/class/zamanGetir.dart';
import 'package:taskmanagmentapp/login.dart';

class PersonelAnaSayfa extends StatefulWidget {
  const PersonelAnaSayfa({Key? key}) : super(key: key);

  @override
  State<PersonelAnaSayfa> createState() => _PersonelAnaSayfaState();
}

class _PersonelAnaSayfaState extends State<PersonelAnaSayfa>
    with SingleTickerProviderStateMixin {
  
  // Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Zaman _zaman = Zaman();

  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State Variables
  String? _profilResmiUrl;
  Map<String, dynamic>? _kullaniciData;
  int _toplamBireyselGorev = 0;
  int _toplamEkipGorev = 0;
  bool _isLoading = true;
  
  // Task Lists
  List<BireyselGorevler> _bireyselGorevler = [];
  List<EkipGorevler> _ekipGorevler = [];
  
  // UI State
  TaskType _selectedTaskType = TaskType.bireysel;
  int _selectedDayFilter = -1; // -1 = Tümü, 0 = 7 gün, 1 = 15 gün, 2 = 30 gün
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadUserProfile(),
      _loadUserData(),
      _loadTasks(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadUserProfile() async {
    try {
      final ref = _storage
          .ref()
          .child("profilResimleri")
          .child(_auth.currentUser!.uid)
          .child("profilResmi.png");
      
      final url = await ref.getDownloadURL();
      if (mounted) {
        setState(() => _profilResmiUrl = url);
      }
    } catch (e) {
      debugPrint('Profil resmi yüklenirken hata: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await _firestore
          .collection('Kullanicilar')
          .where("kullaniciID", isEqualTo: _auth.currentUser!.uid)
          .get();
      
      if (doc.docs.isNotEmpty && mounted) {
        setState(() => _kullaniciData = doc.docs.first.data());
      }
    } catch (e) {
      debugPrint('Kullanıcı verisi yüklenirken hata: $e');
    }
  }

  Future<void> _loadTasks() async {
    await Future.wait([
      _loadBireyselGorevler(),
      _loadEkipGorevler(),
    ]);
  }

  Future<void> _loadBireyselGorevler() async {
    try {
      final snapshot = await _firestore
          .collection('BireyselGorevler')
          .where('personelMail', isEqualTo: _auth.currentUser!.email)
          .get();

      final gorevler = snapshot.docs.map((doc) {
        final data = doc.data();
        return BireyselGorevler(
          gorevBaslikbireysel: data['gorevBaslikbireysel'] ?? '',
          gorevIcerikbireysel: data['gorevIcerikbireysel'] ?? '',
          sonTarih: data['sonTarih'] ?? '',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _bireyselGorevler = gorevler;
          _toplamBireyselGorev = gorevler.length;
        });
      }
    } catch (e) {
      debugPrint('Bireysel görevler yüklenirken hata: $e');
    }
  }

  Future<void> _loadEkipGorevler() async {
    try {
      final snapshot = await _firestore
          .collection('EkipGorevler')
          .where('personelMail', arrayContains: _auth.currentUser!.email)
          .get();

      final gorevler = snapshot.docs.map((doc) {
        final data = doc.data();
        return EkipGorevler(
          gorevBaslik: data['gorevBaslikEkip'] ?? '',
          gorevIcerik: data['gorevIcerikEkip'] ?? '',
          sonTarih: data['sonTarih'] ?? '',
          personellerMail: List<String>.from(data['personelMail'] ?? []),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _ekipGorevler = gorevler;
          _toplamEkipGorev = gorevler.length;
        });
      }
    } catch (e) {
      debugPrint('Ekip görevleri yüklenirken hata: $e');
    }
  }

  List<dynamic> _getFilteredTasks() {
    List<dynamic> tasks = _selectedTaskType == TaskType.bireysel
        ? _bireyselGorevler
        : _ekipGorevler;

    if (_selectedDayFilter == -1) return tasks;

    _zaman.zamanAyar();
    List<dynamic> dateList;
    
    switch (_selectedDayFilter) {
      case 0:
        dateList = _zaman.list7;
        break;
      case 1:
        dateList = _zaman.list15;
        break;
      case 2:
        dateList = _zaman.list30;
        break;
      default:
        return tasks;
    }

    return tasks.where((task) {
      final taskDate = task is BireyselGorevler 
          ? task.sonTarih 
          : (task as EkipGorevler).sonTarih;
      return dateList.contains(taskDate);
    }).toList();
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF21CBF3),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildTaskTypeSelector(),
                        _buildDateFilter(),
                        const SizedBox(height: 10),
                        Expanded(child: _buildTaskList()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Hero(
            tag: 'profile-image',
            child: CircleAvatar(
              radius: 30,
              backgroundImage: _profilResmiUrl != null
                  ? NetworkImage(_profilResmiUrl!)
                  : null,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: _profilResmiUrl == null
                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _kullaniciData?['Ad'] ?? 'Kullanıcı',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _kullaniciData?['Gorev'] ?? 'Personel',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTypeSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: _buildTaskTypeCard(
              title: 'Benim Görevlerim',
              count: _toplamBireyselGorev,
              icon: Icons.person,
              isSelected: _selectedTaskType == TaskType.bireysel,
              onTap: () => setState(() {
                _selectedTaskType = TaskType.bireysel;
                _selectedDayFilter = -1;
              }),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTaskTypeCard(
              title: 'Ekip Görevleri',
              count: _toplamEkipGorev,
              icon: Icons.groups,
              isSelected: _selectedTaskType == TaskType.ekip,
              onTap: () => setState(() {
                _selectedTaskType = TaskType.ekip;
                _selectedDayFilter = -1;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTypeCard({
    required String title,
    required int count,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
              ? const BorderSide(color: Color(0xFF2196F3), width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isSelected ? const Color(0xFF2196F3) : Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF2196F3) : Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2196F3) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Filtrele: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tümü', -1),
                  _buildFilterChip('7 Gün', 0),
                  _buildFilterChip('15 Gün', 1),
                  _buildFilterChip('30 Gün', 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedDayFilter == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedDayFilter = selected ? index : -1);
        },
        selectedColor: const Color(0xFF2196F3).withOpacity(0.2),
        checkmarkColor: const Color(0xFF2196F3),
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = _getFilteredTasks();
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Henüz görev bulunmuyor',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, index);
      },
    );
  }

  Widget _buildTaskCard(dynamic task, int index) {
    final isTeamTask = task is EkipGorevler;
    final title = isTeamTask ? task.gorevBaslik : task.gorevBaslikbireysel;
    final dueDate = task.sonTarih;
    
    return Hero(
      tag: 'task-$index',
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showTaskDetails(task),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isTeamTask ? Colors.orange : const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Son: $dueDate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  isTeamTask ? Icons.groups : Icons.person,
                  color: isTeamTask ? Colors.orange : const Color(0xFF2196F3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(dynamic task) {
    final isTeamTask = task is EkipGorevler;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isTeamTask ? Icons.groups : Icons.person,
                          color: isTeamTask ? Colors.orange : const Color(0xFF2196F3),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isTeamTask ? task.gorevBaslik : task.gorevBaslikbireysel,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Görev Detayı',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isTeamTask ? task.gorevIcerik : task.gorevIcerikbireysel,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    if (isTeamTask) ...[
                      const Text(
                        'Ekip Üyeleri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: task.personellerMail.map<Widget>((email) {
                          return Chip(
                            label: Text(email),
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Son Teslim: ${task.sonTarih}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum TaskType { bireysel, ekip }