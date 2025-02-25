import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart'; // Para PdfPageFormat
import 'package:pdf/widgets.dart' as pw; // Widgets del PDF con prefijo pw
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'catalog_screen.dart'; // Asumiendo que este archivo existe

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> _prestamos = [];

  @override
  void initState() {
    super.initState();
    _cargarPrestamos();
  }

  Future<void> _cargarPrestamos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? prestamosJson = prefs.getString('prestamos');
    if (prestamosJson != null) {
      setState(() {
        _prestamos =
            List<Map<String, dynamic>>.from(json.decode(prestamosJson));
      });
    } else {
      setState(() {
        _prestamos = [];
      });
    }
  }

  Future<void> _cancelarPrestamo(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final libroCancelado = _prestamos[index];
    setState(() {
      _prestamos.removeAt(index);
    });
    await prefs.setString('prestamos', json.encode(_prestamos));
    BookManager.updateBookState(libroCancelado['titulo'], 'Disponible');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Préstamo cancelado')),
    );
  }

  Future<void> _generarInformePDF() async {
    final pdf = pw.Document();

    // Agrupar préstamos por lector
    Map<String, List<Map<String, dynamic>>> prestamosPorLector = {};
    for (var prestamo in _prestamos) {
      final lector = prestamo['lector'] as String;
      if (!prestamosPorLector.containsKey(lector)) {
        prestamosPorLector[lector] = [];
      }
      prestamosPorLector[lector]!.add(prestamo);
    }

    // Crear las páginas del PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, text: 'Informe de Préstamos'),
            pw.Paragraph(text: 'Fecha: ${DateTime.now().toString()}'),
            pw.SizedBox(height: 20),
            ...prestamosPorLector.entries.map((entry) {
              final lector = entry.key;
              final prestamos = entry.value;
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Lector: $lector',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  // Lista de préstamos con solo el título
                  ...prestamos.map((prestamo) {
                    return pw.Text(
                      prestamo['titulo'],
                      style: pw.TextStyle(fontSize: 14),
                    );
                  }).toList(),
                  pw.SizedBox(height: 20),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    // Guardar el PDF en el directorio de documentos
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/informe_prestamos.pdf');
    await file.writeAsBytes(await pdf.save());

    // Abrir el PDF con manejo de errores
    try {
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el PDF: ${result.message}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe PDF generado y abierto')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _cargarPrestamos(); // Nota: Esto podría optimizarse, ver notas al final

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _prestamos.isEmpty
                ? const Center(child: Text('No hay libros prestados'))
                : ListView.builder(
                    itemCount: _prestamos.length,
                    itemBuilder: (context, index) {
                      final prestamo = _prestamos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: ListTile(
                          title: Text(prestamo['titulo']),
                          subtitle:
                              Text('Reservado por: ${prestamo['lector']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _cancelarPrestamo(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              onPressed: _prestamos.isEmpty ? null : _generarInformePDF,
              child: const Text('Generar Informe de Préstamos'),
            ),
          ),
        ],
      ),
    );
  }
}
