import 'package:flutter/material.dart';
import 'package:taskmanagmentapp/login.dart';
import 'package:taskmanagmentapp/mvvm/views/duyuru_ekle_view.dart';
import 'package:taskmanagmentapp/mvvm/views/duyuru_goruntule_view.dart';

import 'ekipgorevekle_view.dart';
import 'ekipgorevgoruntule_view.dart';
import 'gorev_ekle_view.dart';
import 'gorev_goruntule_view.dart';

class AdminAnasayfaView extends StatefulWidget {
  const AdminAnasayfaView({super.key});

  @override
  State<AdminAnasayfaView> createState() => _AdminAnasayfaViewState();
}

class _AdminAnasayfaViewState extends State<AdminAnasayfaView>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  final List<MenuItemData> menuItems = [
    MenuItemData(
      title: 'Görev Ekle',
      icon: Icons.add_task_rounded,
      color: const Color(0xFF6C63FF),
      gradient: const LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: (context) => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => GorevEkleView()),
        (route) => false,
      ),
    ),
    MenuItemData(
      title: 'Görevleri Görüntüle',
      icon: Icons.assignment_outlined,
      color: const Color(0xFF3B82F6),
      gradient: const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: (context) => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => GorevGoruntule()),
        (route) => false,
      ),
    ),
    MenuItemData(
      title: 'Ekip Görevi Ekle',
      icon: Icons.group_add_rounded,
      color: const Color(0xFF10B981),
      gradient: const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: (context) => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ekipGorevEkleView()),
        (route) => false,
      ),
    ),
    MenuItemData(
      title: 'Ekip Görevlerini Görüntüle',
      icon: Icons.groups_rounded,
      color: const Color(0xFFF59E0B),
      gradient: const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: (context) => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => EkipGorevGoruntule()),
        (route) => false,
      ),
    ),
    MenuItemData(
      title: 'Duyuru Ekle',
      icon: Icons.campaign_rounded,
      color: const Color(0xFFEF4444),
      gradient: const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: (context) => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DuyuruEkleView()),
        (route) => false,
      ),
    ),
    MenuItemData(
      title: 'Çıkış Yap',
      icon: Icons.logout_rounded,
      color: const Color(0xFF6B7280),
      gradient: const LinearGradient(
        colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: (context) => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF6366F1),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _animationController != null
              ? AnimatedBuilder(
                  animation: _animationController!,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation!,
                      child: SlideTransition(
                        position: _slideAnimation!,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                margin: const EdgeInsets.only(top: 20, bottom: 40),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.dashboard_rounded,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'YÖNETİM PANELİ',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 3,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Grid Menu
                              Expanded(
                                child: GridView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.0,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: menuItems.length,
                                  itemBuilder: (context, index) {
                                    final item = menuItems[index];
                                    return TweenAnimationBuilder<double>(
                                      duration: Duration(milliseconds: 800 + (index * 100)),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      curve: Curves.elasticOut,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: MenuCard(
                                            item: item,
                                            delay: index * 100,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class MenuCard extends StatefulWidget {
  final MenuItemData item;
  final int delay;

  const MenuCard({
    super.key,
    required this.item,
    required this.delay,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _hoverController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _hoverController!,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 16.0,
    ).animate(CurvedAnimation(
      parent: _hoverController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hoverController == null) {
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: _hoverController!,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation!.value,
          child: GestureDetector(
            onTapDown: (_) => _hoverController!.forward(),
            onTapUp: (_) {
              _hoverController!.reverse();
              Future.delayed(const Duration(milliseconds: 100), () {
                widget.item.onTap(context);
              });
            },
            onTapCancel: () => _hoverController!.reverse(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.item.color.withOpacity(0.3),
                    blurRadius: _elevationAnimation!.value,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.item.gradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Pattern
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              widget.item.icon,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MenuItemData {
  final String title;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;
  final Function(BuildContext) onTap;

  MenuItemData({
    required this.title,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.onTap,
  });
}