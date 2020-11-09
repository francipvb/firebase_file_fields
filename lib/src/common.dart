import 'package:flutter/widgets.dart';

const _loading = {ConnectionState.waiting, ConnectionState.active};

@visibleForTesting
const firebaseImageFormFieldButton = Key('firebase_image_form_field_button');

extension AsyncSnapshotExtensions<T> on AsyncSnapshot<T> {
  /// Indicaes wether an [AsyncSnapshot<T>] is processing.
  bool get isLoading => _loading.contains(connectionState);

  /// Indicates that the async snapshot is not loading.
  bool get isNotLoading => !this.isLoading;

  /// Indicates if the async snapshot is in the initial state (I.E. the future or stream hasn't been set yet).
  bool get isInitial => connectionState == ConnectionState.none;
}
