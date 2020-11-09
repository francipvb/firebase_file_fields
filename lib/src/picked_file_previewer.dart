import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

import 'common.dart';

class PickedFilePreviewer extends StatefulWidget {
  const PickedFilePreviewer({
    Key key,
    @required this.pickedFile,
  })  : assert(pickedFile != null),
        super(key: key);

  final PickedFile pickedFile;

  @override
  _PickedFilePreviewerState createState() => _PickedFilePreviewerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PickedFile>('pickedFile', pickedFile));
  }
}

class _PickedFilePreviewerState extends State<PickedFilePreviewer> {
  Future<Uint8List> _imageData;

  @override
  void initState() {
    _loadImageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageData,
      builder: (context, snapshot) {
        if (snapshot.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Image.memory(
          snapshot.data,
          alignment: Alignment.center,
        );
      },
    );
  }

  Future<void> _loadImageData() async {
    if (_imageData != null) {
      await _imageData;
    }
    final Completer<Uint8List> dataCompleter = Completer();
    setState(() {
      _imageData = dataCompleter.future;
    });
    final chunkList = await widget.pickedFile.openRead().toList();
    final data = Uint8List(chunkList.fold(0, (v, e) => v + e.length));
    int pos = 0;
    chunkList.forEach((element) {
      List.writeIterable(data, pos, element);
      pos += element.length;
    });
    dataCompleter.complete(data);
  }
}
