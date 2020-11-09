import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'common.dart';

typedef PickedFileCallback = void Function(PickedFile pickedFile);
typedef PermissionDeniedCallback = FutureOr<void> Function(String reason);

const _photoAccessDenied = 'photo_access_denied';

@visibleForTesting
const imagePickerKey = const Key('pick_photo_from_library');

@visibleForTesting
const pickingPhotoIndicator = const Key('picking_photo_indicator');

@visibleForTesting
class ImagePickerButton extends StatefulWidget {
  const ImagePickerButton({
    Key key,
    @required this.imagePicker,
    @required this.imageSource,
    @required this.onFile,
    this.onPermissionDenied,
    this.child,
    this.maxWidth,
    this.maxHeight,
    this.imageQuality,
    this.preferredCamera,
    this.onError,
  })  : assert(imagePicker != null),
        assert(onFile != null),
        assert(imageSource != null),
        super(key: key);

  final ImagePicker imagePicker;
  final ImageSource imageSource;
  final PickedFileCallback onFile;
  final PermissionDeniedCallback onPermissionDenied;
  final Function onError;
  final Widget child;
  final double maxWidth;
  final double maxHeight;
  final int imageQuality;
  final CameraDevice preferredCamera;

  @override
  _ImagePickerButtonState createState() => _ImagePickerButtonState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<ImagePicker>('imagePicker', imagePicker));
    properties.add(ObjectFlagProperty<PickedFileCallback>.has(
      'onFile',
      onFile,
    ));
    properties.add(ObjectFlagProperty<PermissionDeniedCallback>.has(
      'onPermissionDenied',
      onPermissionDenied,
    ));
    properties.add(DiagnosticsProperty<Widget>(
      'child',
      child,
      ifNull: 'default widget',
    ));
    properties.add(DoubleProperty(
      'maxWidth',
      maxWidth,
      ifNull: 'not specified',
    ));
    properties.add(DoubleProperty(
      'maxHeight',
      maxHeight,
      ifNull: 'Not specified',
    ));
    properties.add(IntProperty(
      'imageQuality',
      imageQuality,
      ifNull: 'Not specified',
    ));
    properties.add(EnumProperty<ImageSource>(
      'imageSource',
      imageSource,
      defaultValue: ImageSource.gallery,
    ));
    properties.add(EnumProperty<CameraDevice>(
      'preferredCamera',
      preferredCamera,
      defaultValue: CameraDevice.rear,
    ));
  }
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  Future<PickedFile> _pickedFile;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PickedFile>(
      future: _pickedFile,
      builder: (context, snapshot) => Stack(
        children: [
          FlatButton.icon(
            key: imagePickerKey,
            icon: Icon(
              widget.imageSource == ImageSource.gallery
                  ? Icons.photo_library
                  : Icons.photo_camera,
            ),
            label: widget.child ?? Text('Choose from device'),
            onPressed: snapshot.isNotLoading ? _pickPhoto : null,
          ),
          if (snapshot.isLoading)
            Center(
              child: CircularProgressIndicator(
                key: pickingPhotoIndicator,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    setState(() {
      _pickedFile = widget.imagePicker.getImage(
        source: widget.imageSource ?? ImageSource.gallery,
        imageQuality: widget.imageQuality,
        maxHeight: widget.maxHeight,
        maxWidth: widget.maxWidth,
        preferredCameraDevice: widget.preferredCamera ?? CameraDevice.rear,
      );
    });
    try {
      final pickedFile = await _pickedFile;
      if (pickedFile != null) {
        widget.onFile(pickedFile);
      }
    } on PlatformException catch (error, st) {
      if (error.code == _photoAccessDenied) {
        (widget.onPermissionDenied ?? (String s) {})(error.message);
      } else {
        if (widget.onError != null) {
          widget.onError(error, st);
        }
      }
    } catch (error, st) {
      if (widget.onError != null) {
        widget.onError(error, st);
      }
    }
  }
}
