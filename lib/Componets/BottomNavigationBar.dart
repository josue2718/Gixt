import 'package:flutter/material.dart';
import 'package:gixt/pages/home.dart';
import 'package:gixt/pages/perfil.dart';
import 'colors.dart'; // Asegúrate de tener colorfondo1, colorWhite y colorfondo

class AppBottomNavigation extends StatefulWidget {
  const AppBottomNavigation({Key? key}) : super(key: key);

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation> {
  int _currentIndex = 1; // Iniciamos en el medio (Home)

  final List<Widget> _pages = const [
    HomePage(),
    Center(child: Text('Buscar', style: TextStyle(fontSize: 24, color: Colors.white))),
    Center(child: Text('Express', style: TextStyle(fontSize: 24, color: Colors.white))),
    Center(child: Text('Agenda', style: TextStyle(fontSize: 24, color: Colors.white))),
    PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen =
    MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: colorfondo,
      body: _pages[_currentIndex],
      // Usamos extendBody para que el contenido se vea detrás de la barra si es translúcida
      extendBody: true, 
      bottomNavigationBar:
      isKeyboardOpen ? const SizedBox.shrink() : _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 25), // Margen para que flote
      height: 70,
      decoration: BoxDecoration(
        color: colorprimario,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
            _buildNavItem(Icons.home_rounded, Icons.home_rounded ,0, "Home"),
            _buildNavItem(Icons.search_rounded, Icons.search, 1, "Buscar"),
            // BOTÓN CENTRAL ESTILO "CHIC"
            _buildMiddleItem(Icons.flash_on, 2),
            _buildNavItem(Icons.calendar_today_rounded, Icons.calendar_today, 3, "Agenda"),
            _buildNavItem(Icons.person_rounded, Icons.person, 4, "Perfil"),
        ],
      ),
    );
  }

  // Item normal para los lados
  Widget _buildNavItem(IconData icon, IconData activeIcon, int index, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? colorWhite : Colors.grey.withOpacity(0.6),
            size: 28,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? colorWhite : Colors.grey.withOpacity(0.6),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // El botón circular "Chic" del centro (como en tu imagen)
  Widget _buildMiddleItem(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          // Si está seleccionado brilla, si no, mantiene un color sólido
          color: isSelected ? colorfondo : colorWhite.withOpacity(0.15),
          shape: BoxShape.circle,
          boxShadow: isSelected ? [
            BoxShadow(
              color: colorWhite..withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ] : [],
        ),
        child: Icon(
          isSelected ? Icons.flash_on : Icons.flash_on,
          color: isSelected ? Colors.white : colorWhite,
          size: 30,
        ),
      ),
    );
  }
}