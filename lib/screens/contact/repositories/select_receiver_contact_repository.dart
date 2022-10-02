import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_chat/models/user.dart' as app;
import '../../../utils/common/widgets/helper_widgets.dart';
import '../../../utils/constants/routes_constants.dart';
import '../../../utils/constants/string_constants.dart';

final selectReceiverContactsRepositoryProvider = Provider(
  (ref) => SelectReceiverContactsRepository(FirebaseFirestore.instance),
);

class SelectReceiverContactsRepository {
  SelectReceiverContactsRepository(FirebaseFirestore firestore)
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// invoke to Get all contacts (fully fetched)
  Future<List<Contact>> getReceiverContacts(BuildContext context) async {
    List<Contact> contactsList = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contactsList = await FlutterContacts.getContacts(
          withPhoto: true,
          withProperties: true,
        );
      }
    } catch (e) {
      showSnackBar(context, content: e.toString());
    }

    return contactsList;
  }

  /// invoke to select specific user if it exists
  Future<void> selectReceiverContact(
    bool mounted,
    BuildContext context, {
    required String number,
  }) async {
    bool isFound = false;
    final userCollection =
        await _firestore.collection(StringsConsts.usersCollection).get();

    for (var document in userCollection.docs) {
      app.User receiverUser = app.User.fromMap(document.data());

      if (number == receiverUser.phoneNumber) {
        isFound = true;

        if (!mounted) return;
        Navigator.pushNamed(
          context,
          AppRoutes.chatScreen,
          arguments: <String, Object>{
            'name': receiverUser.name,
            'receiverUserId': receiverUser.uid,
          },
        );
      }
    }

    if (!isFound) {
      if (!mounted) return;
      showSnackBar(context, content: "User doesn't exist in this app");
    }
  }
}