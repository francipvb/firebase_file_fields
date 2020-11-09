import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'common.dart';
import 'image_upload_screen.dart';

class FirebaseImageFormField extends FormField<Uri> {
  const FirebaseImageFormField({
    Key key,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    bool enabled = true,
    Uri initialValue,
    FormFieldSetter<Uri> onSaved,
    FormFieldValidator<Uri> validator,
    this.label,
    this.screenTitle,
    @required this.parentReference,
    this.enableCamera,
    this.enableGallery,
  }) : super(
          key: key,
          autovalidateMode: autovalidateMode,
          enabled: enabled,
          initialValue: initialValue,
          validator: validator,
          onSaved: onSaved,
          builder: _imageFieldBuilder,
        );

  static Widget _imageFieldBuilder(FormFieldState<Uri> field) {
    final widget = field.widget as FirebaseImageFormField;
    return Card(
      semanticContainer: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.label ??
              Text(
                'Upload a file',
                style: Theme.of(field.context).textTheme.headline4,
                textAlign: TextAlign.justify,
              ),
          Expanded(
            child: field.value != null
                ? Image.network(field.value.toString())
                : Text('Please choose a file to upload.'),
          ),
          RaisedButton.icon(
            key: firebaseImageFormFieldButton,
            icon: Icon(Icons.photo),
            label: widget.label ?? Text('Choose a photo'),
            onPressed: () => Navigator.push<Uri>(
              field.context,
              MaterialPageRoute(
                builder: (context) {
                  return ImageUploadScreen(
                    reference: widget.parentReference,
                    screenTitle: widget.screenTitle,
                    enableCamera: widget.enableCamera ?? false,
                    enableGallery: widget.enableGallery ?? true,
                    initialUrl: field.value,
                    onUploadComplete: (value) {
                      field.didChange(value);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  final Widget label;
  final Widget screenTitle;
  final Reference parentReference;
  final bool enableCamera;
  final bool enableGallery;
}
