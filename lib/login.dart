import 'package:connect_firebase/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connect_firebase/services/auth.dart';
import 'package:connect_firebase/door.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
        automaticallyImplyLeading: false, // Deshabilita el botón de retroceso predeterminado
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Iniciar sesión
                User? user = await AuthService().signInWithEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                );

                if (user != null) {
                  // Encontrar Id Grupo basado en email
                  String? groupId = await DatabaseService().findGroupByEmail(_emailController.text);

                  // Navegar a la pantalla donde se puede modificar el estado de la puerta del grupo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoorStateWidget(groupId: groupId, email: _emailController.text),
                    ),
                  );
                } else {
                  // Mostrar mensaje de error
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Inicio de sesión fallido'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Iniciar Sesión'),
            ),
            ElevatedButton(
                onPressed: () => enviarComando('1'),
                child: Text('I/O Test')
            )
          ],
        ),
      ),
    );
  }
}

Future<void> enviarComando(String comando) async {
  final response = await http.get(Uri.parse('http://192.168.0.177/data=$comando'));
  if (response.statusCode == 200) {
    print('Comando enviado con éxito: $comando');
  } else {
    print('Error al enviar el comando: ${response.statusCode}');
  }
}
