import 'package:event_bus/event_bus.dart';

final EventBus eventBus = EventBus();

class SetProgressedEvent {
  final String exerciseName;
  final int setIndex;
  SetProgressedEvent(this.exerciseName, this.setIndex);
}

class SetAdjustedEvent {
  final String exerciseName;
  final int setIndex;
  final double deltaWeight;
  final int deltaReps;
  SetAdjustedEvent(this.exerciseName, this.setIndex, this.deltaWeight, this.deltaReps);
}

class DataClearedEvent {
  final String? exerciseName; // null ise tüm veriler temizlendi
  final bool isGlobalClear;   // true ise tüm veriler, false ise sadece belirli egzersiz
  
  DataClearedEvent({this.exerciseName, this.isGlobalClear = false});
}

class WorkoutCompletedEvent {
  final DateTime date;
  /// Hangi günün (örn. Pazartesi) tamamlandığı; null ise WeekScreen _activeDay kullanır.
  final String? dayName;

  WorkoutCompletedEvent({required this.date, this.dayName});
} 