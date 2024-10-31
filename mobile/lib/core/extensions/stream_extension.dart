import 'dart:async';

extension StreamExtension on Stream {
  Future<T> wait<T>() async {
    Completer<T> completer = Completer();
    late StreamSubscription<dynamic> subscription;
    subscription = listen(
      (event) {
        completer.complete(event);
        subscription.cancel();
      },
      onError: (error) {
        completer.completeError(error);
        subscription.cancel();
      },
      cancelOnError: true,
    );
    return await completer.future;
  }
}