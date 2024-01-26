import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  // Find Group by Email (Group (door) > User (email)) and return Group Id
  Future<String?> findGroupByEmail(String userEmail) async {
    try {
      // Referencia a la colección 'Group'
      CollectionReference groupCollection = FirebaseFirestore.instance.collection('group');

      // Obtener todos los documentos de la colección 'Group'
      QuerySnapshot groupQuerySnapshot = await groupCollection.get();

      // Iterar sobre los documentos de 'Group'
      for (QueryDocumentSnapshot groupDoc in groupQuerySnapshot.docs) {
        // Obtener la referencia de la subcolección 'User' dentro de cada documento 'Group'
        CollectionReference userCollection = groupDoc.reference.collection('user');

        // Buscar si el correo electrónico existe en la subcolección 'User'
        QuerySnapshot userQuerySnapshot = await userCollection.where('email', isEqualTo: userEmail).get();

        // Si se encuentra el correo electrónico, devolver el ID del grupo
        if (userQuerySnapshot.docs.isNotEmpty) {
          return groupDoc.id;
        }
      }

      // Si el correo electrónico no se encuentra en ningún grupo
      return null;
    } catch (e) {
      print('Error al buscar el grupo por correo electrónico: $e');
      return null;
    }
  }

  Future<void> updateDoorState(int doorState, String? groupId) async {
    try {
      CollectionReference groupCollection = FirebaseFirestore.instance
          .collection('group');
      DocumentReference documentRef = groupCollection.doc(
          groupId);

      await documentRef.update({'door': doorState});

      print('Campo "door" actualizado correctamente.');
    } catch (e) {
      print('Error al actualizar el campo "door": $e');
    }
  }

  // Método para enviar la contraseña a la base de datos
  Future<bool> sendPassword(String idGroup, String email, String password) async {
    try {
      // Referencia a la colección 'Group'
      DocumentReference groupCollectionId = FirebaseFirestore.instance.collection('group').doc(idGroup);
      // Referecnai a la coleccion guest
      CollectionReference guestsCollection = groupCollectionId.collection('guest');

      // Realizar una consulta para encontrar documentos con el email y la contraseña proporcionados
      QuerySnapshot<Object?> querySnapshot = await guestsCollection
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      // Verificar si se encontraron documentos
      if (querySnapshot.docs.isNotEmpty) {
        // Las credenciales son válidas
        return true;
      }
      return false;
    } catch (e) {
      print('Error al enviar campo contrasena: $e');
      return false;
    }
  }
}