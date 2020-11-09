import 'package:firebase_file_fields/src/common.dart';
import 'package:firebase_file_fields/src/firebase_image_form_field.dart';
import 'package:firebase_file_fields/src/image_upload_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _ReferenceMock extends Mock implements Reference {}

void main() {
  group('Firebase image form field', () {
    testWidgets('Should open the upload screen', (tester) async {
      final reference = _ReferenceMock();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FirebaseImageFormField(
            parentReference: reference,
          ),
        ),
      ));
      expect(find.byKey(firebaseImageFormFieldButton), findsOneWidget);
      await tester.tap(find.byKey(firebaseImageFormFieldButton));
      await tester.pumpAndSettle();
      expect(find.byType(ImageUploadScreen), findsOneWidget);
    });
  });
}
