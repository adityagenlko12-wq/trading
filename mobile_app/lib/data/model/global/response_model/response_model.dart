class ResponseModel {
  final bool isSuccess;
  final String message;
  final int statusCode;
  final String responseJson;

  ResponseModel(this.isSuccess, this.message, this.statusCode, this.responseJson);
}
