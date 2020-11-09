import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

import 'package:firebase_file_fields/src/image_picker_button.dart';

class _ImagePickerMock extends Fake implements ImagePicker {
  final Future<PickedFile> Function() pickedFuture;

  _ImagePickerMock(this.pickedFuture);

  @override
  Future<PickedFile> getImage({
    ImageSource source,
    double maxWidth,
    double maxHeight,
    int imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    return Future.delayed(Duration.zero, pickedFuture);
  }
}

class WrappedInScaffold extends StatelessWidget {
  final Widget child;

  const WrappedInScaffold({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}

void main() {
  group('Image picker button appearance', () {
    testWidgets('Should show the photo gallery icon', (tester) async {
      await tester.pumpWidget(WrappedInScaffold(
        child: ImagePickerButton(
          imagePicker: _ImagePickerMock(() => null),
          imageSource: ImageSource.gallery,
          onFile: (pickedFile) {},
        ),
      ));
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });
    testWidgets('Should show the photo gallery icon', (tester) async {
      await tester.pumpWidget(WrappedInScaffold(
        child: ImagePickerButton(
          imagePicker: _ImagePickerMock(() => null),
          imageSource: ImageSource.camera,
          onFile: (pickedFile) {},
        ),
      ));
      expect(find.byIcon(Icons.photo_camera), findsOneWidget);
    });
    testWidgets('Should show a custom child', (tester) async {
      final customChildKey = Key('custom_child');
      await tester.pumpWidget(WrappedInScaffold(
        child: ImagePickerButton(
          imagePicker: _ImagePickerMock(() => null),
          imageSource: ImageSource.camera,
          onFile: (pickedFile) {},
          child: Text(
            'Custom child',
            key: customChildKey,
          ),
        ),
      ));
      expect(find.byKey(customChildKey), findsOneWidget);
    });
  });
  group('Image picker button behavior', () {
    const photoAccessDenied = 'photo_access_denied';
    const message = 'Message shown to the user';

    testWidgets('Calls `onAccessDenied`', (tester) async {
      bool permissionDeniedCalled = false;
      var imagePickerMock = _ImagePickerMock(
        () => Future.delayed(
          Duration.zero,
          () async => throw PlatformException(
            code: photoAccessDenied,
            message: message,
          ),
        ),
      );
      await tester.pumpWidget(WrappedInScaffold(
        child: ImagePickerButton(
          imagePicker: imagePickerMock,
          imageSource: ImageSource.gallery,
          onFile: (f) {
            print(f);
          },
          onPermissionDenied: (s) {
            expect(s, message);
            permissionDeniedCalled = true;
          },
        ),
      ));
      await tester.tap(find.byKey(imagePickerKey));
      await tester.pump();
      expect(find.byKey(pickingPhotoIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(permissionDeniedCalled, isTrue);
    });
    testWidgets('rethrows the unhandled exception', (tester) async {
      bool onErrorCalled = false;
      final picker = _ImagePickerMock(
        () async => throw Exception('An exception'),
      );
      await tester.pumpWidget(WrappedInScaffold(
        child: ImagePickerButton(
          imagePicker: picker,
          imageSource: ImageSource.gallery,
          onFile: (f) {},
          onError: (err, st) {
            expect(err, isException);
            onErrorCalled = true;
          },
        ),
      ));
      await tester.tap(
        find.byKey(imagePickerKey),
      );
      await tester.pumpAndSettle();
      expect(onErrorCalled, isTrue);
    });
    testWidgets('Passes the picked file to the callback', (tester) async {
      final picked = PickedFile("/picked/path");
      final picker = _ImagePickerMock(() async => picked);
      bool callbackCalled = false;
      await tester.pumpWidget(WrappedInScaffold(
        child: ImagePickerButton(
          imagePicker: picker,
          imageSource: ImageSource.gallery,
          onFile: (f) {
            expect(f, picked);
            callbackCalled = true;
          },
        ),
      ));
      await tester.tap(find.byKey(imagePickerKey));
      await tester.pumpAndSettle();
      expect(callbackCalled, isTrue);
    });
  });
}
