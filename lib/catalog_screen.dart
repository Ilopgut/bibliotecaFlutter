import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Clase estática para gestionar los libros y sus estados
class BookManager {
  static List<Map<String, dynamic>> libros = [
    {
      'titulo': 'Cien años de soledad',
      'autor': 'Gabriel García Márquez',
      'materia': 'Literatura',
      'estado': 'Disponible',
      'portada': 'assets/Cien-anos-de-Soledad.jpg',
    },
    {
      'titulo': '1984',
      'autor': 'George Orwell',
      'materia': 'Ciencia Ficción',
      'estado': 'Disponible',
      'portada': 'assets/1984.jpg',
    },
    {
      'titulo': 'El gran Gatsby',
      'autor': 'F. Scott Fitzgerald',
      'materia': 'Literatura',
      'estado': 'Disponible',
      'portada': 'assets/gran_gatsby.jpg',
    },
    {
      'titulo': 'Matar a un ruiseñor',
      'autor': 'Harper Lee',
      'materia': 'Literatura',
      'estado': 'Disponible',
      'portada': 'assets/matar-a-un-ruisenor.jpg',
    },
  ];

  static void updateBookState(String titulo, String nuevoEstado) {
    final libro = libros.firstWhere((l) => l['titulo'] == titulo);
    libro['estado'] = nuevoEstado;
  }

  static List<Map<String, dynamic>> getLibros() => libros;
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({Key? key}) : super(key: key); // Constructor corregido

  @override
  _MyCatalogPageState createState() => _MyCatalogPageState();
}

class _MyCatalogPageState extends State<CatalogPage> {
  @override
  void initState() {
    super.initState();
    _cargarEstadoLibros();
  }

  Future<void> _cargarEstadoLibros() async {
    final prefs = await SharedPreferences.getInstance();
    final String? prestamosJson = prefs.getString('prestamos');
    if (prestamosJson != null) {
      final List<dynamic> prestamos = json.decode(prestamosJson);
      setState(() {
        for (var prestamo in prestamos) {
          BookManager.updateBookState(prestamo['titulo'], 'En préstamo');
        }
      });
    }
  }

  Future<void> _guardarPrestamo(String titulo, String lector) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> prestamos = [];
    final String? prestamosJson = prefs.getString('prestamos');
    if (prestamosJson != null) {
      prestamos = List<Map<String, dynamic>>.from(json.decode(prestamosJson));
    }
    prestamos.add({'titulo': titulo, 'lector': lector});
    await prefs.setString('prestamos', json.encode(prestamos));

    setState(() {
      BookManager.updateBookState(titulo, 'En préstamo');
    });
  }

  void _mostrarDialogoPrestamo(BuildContext context, Map<String, dynamic> libro) {
    if (libro['estado'] != 'Disponible') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este libro no está disponible')),
      );
      return;
    }

    final TextEditingController _lectorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reservar ${libro['titulo']}'),
        content: TextField(
          controller: _lectorController,
          decoration: const InputDecoration(labelText: 'Nombre del lector'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_lectorController.text.isNotEmpty) {
                _guardarPrestamo(libro['titulo'], _lectorController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Préstamo registrado')),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    _cargarEstadoLibros();

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: ListView.builder(
        itemCount: BookManager.getLibros().length,
        itemBuilder: (context, index) {
          final libro = BookManager.getLibros()[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: Image.asset(libro['portada'], width: 50, height: 75, fit: BoxFit.cover),
              title: Text(libro['titulo']),
              subtitle: Text('Autor: ${libro['autor']}\nMateria: ${libro['materia']}\nEstado: ${libro['estado']}'),
              isThreeLine: true,
              onTap: () => _mostrarDialogoPrestamo(context, libro),
            ),
          );
        },
      ),
    );
  }
}