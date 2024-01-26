import 'package:connect_firebase/door.dart';
import 'package:connect_firebase/services/database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PasswordEntryGuest extends StatefulWidget {
  final String groupId;
  final String email;
  const PasswordEntryGuest({super.key, required this.groupId, required this.email});

  @override
  State<PasswordEntryGuest> createState() => _PasswordEntryGuestState();
}

class _PasswordEntryGuestState extends State<PasswordEntryGuest> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Ingrese la contraseña',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Obtener la contraseña ingresada
                final String password = _passwordController.text.trim();

                // Verificar si la contraseña no está vacía
                if (password.isNotEmpty) {
                  // Enviar la contraseña a la base de datos
                  bool isAGuest = await DatabaseService().sendPassword(widget.groupId, widget.email, password);

                  if (isAGuest == true) {
                    enviarComando("0");
                    print('CONTRA CORRECTA !!!');

                    Navigator.popUntil(context, (route) {
                      return route.settings.name == '/door';
                    });

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contraseña válida'),
                      ),
                    );
                  }

                } else {
                  // Mostrar un mensaje de error si la contraseña está vacía
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ingrese una contraseña válida'),
                    ),
                  );
                }
              },
              child: Text('Enviar Contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}

// Send command to arduino
Future<void> enviarComando(String comando) async {
  final response = await http.get(Uri.parse('http://192.168.0.177/data=$comando'));
  if (response.statusCode == 200) {
    print('Comando enviado con éxito: $comando');
  } else {
    print('Error al enviar el comando: ${response.statusCode}');
  }
}