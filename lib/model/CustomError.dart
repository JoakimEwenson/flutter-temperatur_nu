class CustomError {
  final String message;

  CustomError(this.message);

  @override
  String toString() => message;

  // USAGE:
  // on SocketException {
  //   throw Failing('message');
  // }
}
