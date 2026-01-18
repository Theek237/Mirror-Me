import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mirror_me/features/profile/presentation/screens/profile_screen.dart';
import 'package:mirror_me/features/recommendations/presentation/screens/recommendations_screen.dart';
import 'package:mirror_me/features/tryon/presentation/screens/tryon_screen.dart';
import 'package:mirror_me/features/wardrobe/presentation/screens/wardrobe_screen.dart';
import 'package:mirror_me/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _glowController;
  late PageController _pageController;
  double _dragDistance = 0;

  final List<Widget> _screens = const [
    WardrobeScreen(),
    TryOnScreen(),
    RecommendationsScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.checkroom_outlined,
      activeIcon: Icons.checkroom,
      label: 'Wardrobe',
      color: AppTheme.neonCyan,
    ),
    _NavItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: 'Try-On',
      color: AppTheme.neonPurple,
    ),
    _NavItem(
      icon: Icons.lightbulb_outlined,
      activeIcon: Icons.lightbulb,
      label: 'Ideas',
      color: AppTheme.neonPink,
    ),
    _NavItem(
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: 'Profile',
      color: AppTheme.neonGreen,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
            ),
          ),

          // Main content
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown,
              },
            ),
            child: RawGestureDetector(
              behavior: HitTestBehavior.translucent,
              gestures: {
                HorizontalDragGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                      HorizontalDragGestureRecognizer
                    >(() => HorizontalDragGestureRecognizer(), (recognizer) {
                      recognizer.onStart = (_) {
                        _dragDistance = 0;
                      };
                      recognizer.onUpdate = (details) {
                        _dragDistance += details.delta.dx;
                      };
                      recognizer.onEnd = (_) {
                        if (_dragDistance.abs() < 40) return;
                        final nextIndex = _dragDistance < 0
                            ? (_currentIndex + 1)
                            : (_currentIndex - 1);
                        if (nextIndex < 0 || nextIndex >= _screens.length) {
                          return;
                        }
                        _pageController.animateToPage(
                          nextIndex,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      };
                    }),
              },
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                allowImplicitScrolling: true,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: _screens,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCyberNavBar(),
    );
  }

  Widget _buildCyberNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.glassBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: _navItems[_currentIndex].color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _currentIndex == index;

              return _buildNavItem(item, index, isSelected);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      },
      child:
          AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 20 : 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.color.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(
                          color: item.color.withOpacity(0.5),
                          width: 1.5,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: item.color.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: -3,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? item.color : AppTheme.textMuted,
                          size: 24,
                          shadows: isSelected
                              ? [
                                  Shadow(
                                    color: item.color.withOpacity(
                                      0.5 + 0.3 * _glowController.value,
                                    ),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        );
                      },
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: AppTheme.labelLarge.copyWith(
                          color: item.color,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              )
              .animate(target: isSelected ? 1 : 0)
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                duration: const Duration(milliseconds: 200),
              ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
