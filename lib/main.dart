import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'catalog_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildMenuItem(
          icon: Icons.person,
          title: 'Mi Cuenta',
          iconColor: Colors.blue,
          context: context,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
        ),
        _buildMenuItem(
          icon: Icons.search,
          title: 'Buscar Catálogo',
          iconColor: Colors.blue,
          context: context,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogPage())),
        ),
        _buildMenuItem(
          icon: Icons.collections,
          title: 'Colecciones Digitales',
          iconColor: Colors.lightBlue,
          context: context,
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: '¿Cómo puedo?',
          iconColor: Colors.deepOrange,
          context: context,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16.0)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPage = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const CatalogPage(),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/biblioteca.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 50,
              child: AppBar(
                backgroundColor: Colors.blue,
                elevation: 0,
                title: const Text('Biblioteca con Flutter', style: TextStyle(color: Colors.white)),
                centerTitle: true,
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _currentPage, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentPage,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}