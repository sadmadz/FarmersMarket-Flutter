class LoginResponse {
  final int id;
  final String name;
  final String token;


  LoginResponse(this.id, this.name, this.token);

  LoginResponse.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        token = json["token"];

}