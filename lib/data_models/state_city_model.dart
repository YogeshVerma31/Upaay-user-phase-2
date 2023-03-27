class StateCity {
  final String id;
  final String name;

  StateCity({required this.id, required this.name});

  factory StateCity.stateFromJson(Map<String, dynamic> responseData) {
    return StateCity(
      name: responseData['state_title'] ?? '',
      id: responseData['state_id'] ?? '',
    );
  }

  factory StateCity.cityFromJson(Map<String, dynamic> responseData) {
    return StateCity(
      name: responseData['name'] ?? '',
      id: responseData['id'] ?? '',
    );
  }
}
