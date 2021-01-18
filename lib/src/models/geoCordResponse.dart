
class GeoCordResponse {
  final int id;
  final String name;
  final String value;

  GeoCordResponse({
    this.id,
    this.name,
    this.value,
  });

  factory GeoCordResponse.fromMap(Map<String, dynamic> map) {
    return GeoCordResponse(
      id: map['id'],
      name: map['name'],
      value: map['value'],
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "value": value,
      };
}
