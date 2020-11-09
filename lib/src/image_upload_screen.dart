import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_file_fields/src/image_picker_button.dart';

import 'common.dart';
import 'picked_file_previewer.dart';

@visibleForTesting
const uploadButtonKey = const Key('upload_image');

@visibleForTesting
class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({
    Key key,
    @required this.reference,
    this.screenTitle,
    this.enableCamera,
    this.enableGallery,
    this.defaultCamera,
    this.onUploadComplete,
    this.initialUrl,
  })  : assert(
          reference != null,
          "A firebase storage reference must be provided in order to upload a file.",
        ),
        assert(
          (enableGallery ?? true) || (enableCamera ?? false),
          'At least one of the two options (camera or gallery) must be enabled.',
        ),
        super(key: key);

  final Reference reference;
  final Widget screenTitle;
  final bool enableCamera;
  final bool enableGallery;
  final CameraDevice defaultCamera;
  final ValueSetter<Uri> onUploadComplete;
  final Uri initialUrl;

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Reference>('reference', reference));
    properties.add(ObjectFlagProperty<ValueSetter<Uri>>.has(
        'onUploadComplete', onUploadComplete));
    properties.add(DiagnosticsProperty<Widget>('screenTitle', screenTitle));
    properties.add(DiagnosticsProperty<bool>(
      'enableCamera',
      enableCamera,
      defaultValue: false,
    ));
    properties.add(DiagnosticsProperty<bool>(
      'enableGallery',
      enableGallery,
      defaultValue: true,
    ));
    properties.add(EnumProperty<CameraDevice>('defaultCamera', defaultCamera));
    properties.add(DiagnosticsProperty<Uri>('initialUrl', initialUrl));
  }
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  Stream<TaskSnapshot> _uploadEvents;
  ImagePicker _imagePicker;
  PickedFile _pickedFile;

  @override
  void initState() {
    _imagePicker = ImagePicker();
    _loadLostData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget previewArea;
    if (_pickedFile != null) {
      previewArea = PickedFilePreviewer(pickedFile: _pickedFile);
    } else {
      if (widget.initialUrl == null)
        previewArea = Text(
          'Please choose an image to be uploaded.',
          textAlign: TextAlign.justify,
        );
      else
        previewArea = Image.network(widget.initialUrl.toString());
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: widget.screenTitle ?? Text('Upload an image'),
        actions: [
          StreamBuilder<TaskSnapshot>(
            stream: _uploadEvents,
            builder: (context, snapshot) => IconButton(
              key: uploadButtonKey,
              icon: Icon(Icons.upload_file),
              tooltip: 'Upload',
              onPressed: snapshot.isNotLoading && _pickedFile != null
                  ? _uploadFile
                  : null,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: previewArea,
          ),
          Divider(),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.enableGallery)
                ImagePickerButton(
                  imagePicker: _imagePicker,
                  imageSource: ImageSource.gallery,
                  onFile: _previewFile,
                  child: Text('Pick from gallery'),
                ),
              if (widget.enableCamera)
                ImagePickerButton(
                  imagePicker: _imagePicker,
                  imageSource: ImageSource.camera,
                  onFile: _previewFile,
                  child: Text('Pick from camera'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadLostData() async {
    final lostData = await _imagePicker.getLostData();
    if (!lostData.isEmpty && lostData.type == RetrieveType.image) {
      _pickedFile = lostData.file;
      if (mounted) setState(() {});
    }
  }

  void _previewFile(PickedFile pickedFile) {
    setState(() {
      _pickedFile = pickedFile;
    });
  }

  Future<void> _uploadFile() async {
    final file = File(_pickedFile.path);
    final path =
        file.uri.pathSegments.lastWhere((element) => element.isNotEmpty);
    final uploadedReference = widget.reference.child(path);
    final task = uploadedReference.putFile(file);
    setState(() {
      _uploadEvents = task.snapshotEvents;
    });
    await task;
    widget.onUploadComplete(await uploadedReference
        .getDownloadURL()
        .then((value) => Uri.parse(value)));
    Navigator.pop(context);
  }
}
