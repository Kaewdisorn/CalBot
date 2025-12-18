import 'dart:convert';

/// Extended note data stored as JSON in Appointment.notes field
/// This allows storing additional fields that Appointment doesn't support

class NoteDataModel {
  final bool isDone;
  final String? description;
  final List<DateTime> doneOccurrences; // For recurring events - track which occurrences are done

  // Add more fields as needed in the future
  // final String? category;
  // final int? priority;

  const NoteDataModel({this.isDone = false, this.description, this.doneOccurrences = const []});

  /// Parse NoteData from JSON string (stored in Appointment.notes)
  factory NoteDataModel.fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return const NoteDataModel();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);

      // Parse doneOccurrences list
      List<DateTime> occurrences = [];
      if (json['doneOccurrences'] is List) {
        occurrences = (json['doneOccurrences'] as List<dynamic>).map((e) => DateTime.parse(e.toString())).toList();
      }

      return NoteDataModel(isDone: json['isDone'] as bool? ?? false, description: json['description'] as String?, doneOccurrences: occurrences);
    } catch (e) {
      // If parsing fails, treat the whole string as description (backward compatibility)
      return NoteDataModel(description: jsonString);
    }
  }

  /// Convert to JSON string for storing in Appointment.notes
  String toJsonString() {
    return jsonEncode({
      'isDone': isDone,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (doneOccurrences.isNotEmpty) 'doneOccurrences': doneOccurrences.map((d) => d.toIso8601String()).toList(),
    });
  }

  /// Check if there's any meaningful data
  bool get isEmpty => !isDone && (description == null || description!.isEmpty) && doneOccurrences.isEmpty;

  /// Check if a specific occurrence is marked as done (for recurring events)
  bool isOccurrenceDone(DateTime occurrenceDate) {
    // Normalize to just date for comparison (ignore time component)
    final normalizedDate = DateTime(occurrenceDate.year, occurrenceDate.month, occurrenceDate.day);
    return doneOccurrences.any((d) {
      final normalizedDone = DateTime(d.year, d.month, d.day);
      return normalizedDone.isAtSameMomentAs(normalizedDate);
    });
  }

  /// Create a copy with an occurrence added to done list
  NoteDataModel addDoneOccurrence(DateTime occurrenceDate) {
    if (isOccurrenceDone(occurrenceDate)) return this; // Already marked
    return NoteDataModel(isDone: isDone, description: description, doneOccurrences: [...doneOccurrences, occurrenceDate]);
  }

  /// Create a copy with an occurrence removed from done list
  NoteDataModel removeDoneOccurrence(DateTime occurrenceDate) {
    final normalizedDate = DateTime(occurrenceDate.year, occurrenceDate.month, occurrenceDate.day);
    return NoteDataModel(
      isDone: isDone,
      description: description,
      doneOccurrences: doneOccurrences.where((d) {
        final normalizedDone = DateTime(d.year, d.month, d.day);
        return !normalizedDone.isAtSameMomentAs(normalizedDate);
      }).toList(),
    );
  }

  /// Create a copy with updated isDone for occurrence
  NoteDataModel copyWithOccurrenceDone(DateTime occurrenceDate, bool done) {
    if (done) {
      return addDoneOccurrence(occurrenceDate);
    } else {
      return removeDoneOccurrence(occurrenceDate);
    }
  }
}
