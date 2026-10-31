class EngineeringAlternative {
  const EngineeringAlternative({
    required this.title,
    required this.category,
    required this.description,
    required this.advantages,
    required this.disadvantages,
    required this.estimatedCost,
    required this.estimatedDuration,
    required this.safetyNotes,
  });

  final String title;
  final String category;
  final String description;
  final List<String> advantages;
  final List<String> disadvantages;
  final String estimatedCost;
  final String estimatedDuration;
  final String safetyNotes;

  factory EngineeringAlternative.fromJson(Map<String, dynamic> json) {
    List<String> readList(Object? value) {
      if (value is List) {
        return value.map((item) => item.toString()).toList(growable: false);
      }
      return const <String>[];
    }

    String readText(String key) => (json[key] ?? '').toString().trim();

    return EngineeringAlternative(
      title: readText('title'),
      category: readText('category'),
      description: readText('description'),
      advantages: readList(json['advantages']),
      disadvantages: readList(json['disadvantages']),
      estimatedCost: readText('estimated_cost'),
      estimatedDuration: readText('estimated_duration'),
      safetyNotes: readText('safety_notes'),
    );
  }
}
