import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';
import 'profile.dart';
import 'hesapla.dart';
import 'statistics.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'event_bus.dart';
import 'dart:async';
import 'detail.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// Uygulama Renk Teması
class AppColorTheme {
  // Ana Renkler
  static const Color primary = Color(0xFF673AB7);        // Deep Purple - Ana tema rengi
  static const Color primaryLight = Color(0xFF9A67EA);   // Light Purple
  static const Color primaryDark = Color(0xFF320B86);    // Dark Purple
  
  // Sekonder Renkler
  static const Color secondary = Color(0xFF2196F3);      // Blue - Vurgu rengi
  static const Color secondaryLight = Color(0xFF64B5F6); // Light Blue
  static const Color secondaryDark = Color(0xFF1976D2);  // Dark Blue
  
  // Başarı ve Uyarı Renkleri
  static const Color success = Color(0xFF4CAF50);        // Green - Başarı
  static const Color successLight = Color(0xFF81C784);   // Light Green
  static const Color warning = Color(0xFFFF9800);        // Orange - Uyarı
  static const Color warningLight = Color(0xFFFFB74D);   // Light Orange
  
  // Hata ve Tehlike Renkleri
  static const Color error = Color(0xFFF44336);          // Red - Hata
  static const Color errorLight = Color(0xFFE57373);     // Light Red
  
  // Nötr Renkler
  static const Color background = Color(0xFFF5F5F5);     // Light Grey - Arka plan
  static const Color surface = Color(0xFFFFFFFF);        // White - Yüzey
  static const Color textPrimary = Color(0xFF212121);    // Dark Grey - Ana metin
  static const Color textSecondary = Color(0xFF757575);  // Medium Grey - İkincil metin
  static const Color textLight = Color(0xFFBDBDBD);      // Light Grey - Açık metin
  
  // Kas Grubu Renkleri
  static const Color chest = Color(0xFFE91E63);          // Pink - Göğüs
  static const Color back = Color(0xFF3F51B5);           // Indigo - Sırt
  static const Color shoulders = Color(0xFF00BCD4);      // Cyan - Omuz
  static const Color arms = Color(0xFFFF5722);           // Deep Orange - Kollar
  static const Color legs = Color(0xFF8BC34A);           // Light Green - Bacaklar
  static const Color core = Color(0xFFFFC107);           // Amber - Core
  static const Color cardio = Color(0xFF9C27B0);         // Purple - Kardiyo
  
  // Gün Renkleri
  static const Map<String, Color> weekDayColors = {
    'Pazartesi': Color(0xFF673AB7),    // Deep Purple
    'Salı': Color(0xFF2196F3),         // Blue
    'Çarşamba': Color(0xFF4CAF50),     // Green
    'Perşembe': Color(0xFFFF9800),     // Orange
    'Cuma': Color(0xFFFF5722),         // Deep Orange
    'Cumartesi': Color(0xFF795548),    // Brown
    'Pazar': Color(0xFF9E9E9E),        // Grey
  };
  
  // Gradient Renkleri
  static const List<Color> primaryGradient = [
    Color(0xFF673AB7),  // Deep Purple
    Color(0xFF9A67EA),  // Light Purple
    Color(0xFF3F51B5),  // Indigo
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF2196F3),  // Blue
    Color(0xFF64B5F6),  // Light Blue
    Color(0xFF1976D2),  // Dark Blue
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF4CAF50),  // Green
    Color(0xFF81C784),  // Light Green
    Color(0xFF2E7D32),  // Dark Green
  ];
  
  // Şeffaflık Değerleri
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Input Alan Renkleri
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputLabel = Color(0xFF757575);
  static const Color inputText = Color(0xFF212121);
  static const Color inputHint = Color(0xFFBDBDBD);
  
  // Buton Renkleri
  static const Color buttonPrimary = Color(0xFF673AB7);
  static const Color buttonSecondary = Color(0xFF2196F3);
  static const Color buttonSuccess = Color(0xFF4CAF50);
  static const Color buttonWarning = Color(0xFFFF9800);
  static const Color buttonError = Color(0xFFF44336);
  
  // Kart Renkleri
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color cardShadow = Color(0x1A000000);
  
  // İstatistik Renkleri
  static const Color chartPrimary = Color(0xFF673AB7);
  static const Color chartSecondary = Color(0xFF2196F3);
  static const Color chartSuccess = Color(0xFF4CAF50);
  static const Color chartWarning = Color(0xFFFF9800);
  static const Color chartError = Color(0xFFF44336);
}

// Veri yönetimi için sınıflar
class DataManager {
  static const String _userNameKey = 'user_name';
  static const String _currentWeightKey = 'current_weight';
  static const String _targetWeightKey = 'target_weight';
  static const String _weightHistoryKey = 'weight_history';
  static const String _weeklyRoutineKey = 'weekly_routine';
  static const String _completedWorkoutsKey = 'completed_workouts';
  static const String _lastCompletedKey = 'last_completed';
  static const String _exerciseHistoryKey = 'exercise_history';
  static const String _languageKey = 'language';
  static const String _userLevelKey = 'user_level';
  static const String _weightReminderEnabledKey = 'weight_reminder_enabled';
  static const String _waterReminderEnabledKey = 'water_reminder_enabled';
  static const String _weightReminderTimeKey = 'weight_reminder_time';
  static const String _waterReminderTimeKey = 'water_reminder_time';
  static const String _weightReminderFrequencyKey = 'weight_reminder_frequency';
  static const String _waterReminderIntervalKey = 'water_reminder_interval';
  static const String _lastCompletedDatesKey = 'last_completed_dates';
  static const String _originalDayNamesKey = 'original_day_names';
  static const String _activeWorkoutKey = 'active_workout';

  // Kullanıcı adını kaydet
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  // Kullanıcı adını al
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? '';
  }

  // Mevcut kiloyu kaydet
  static Future<void> saveCurrentWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_currentWeightKey, weight);
  }

  // Mevcut kiloyu al
  static Future<double?> getCurrentWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_currentWeightKey);
  }

  // Hedef kiloyu kaydet
  static Future<void> saveTargetWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_targetWeightKey, weight);
  }

  // Hedef kiloyu al
  static Future<double?> getTargetWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_targetWeightKey);
  }

  // Tartılma geçmişini kaydet
  static Future<void> saveWeightHistory(List<WeightEntry> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = history.map((entry) => {
      'weight': entry.weight,
      'date': entry.date.toIso8601String(),
      'note': entry.note,
    }).toList();
    await prefs.setString(_weightHistoryKey, jsonEncode(historyJson));
  }

  // Tartılma geçmişini al
  static Future<List<WeightEntry>> getWeightHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_weightHistoryKey);
    if (historyString == null) return [];
    
    final historyJson = jsonDecode(historyString) as List;
    return historyJson.map((json) => WeightEntry(
      weight: json['weight'].toDouble(),
      date: DateTime.parse(json['date']),
      note: json['note'],
    )).toList();
  }

  // Haftalık rutini kaydet
  static Future<void> saveWeeklyRoutine(Map<String, List<RoutineEntry>> routine) async {
    final prefs = await SharedPreferences.getInstance();
    final routineJson = routine.map((day, entries) => MapEntry(day, entries.map((entry) => {
      'exerciseName': entry.exercise.name,
      'mainMuscleGroup': entry.exercise.mainMuscleGroup,
      'muscleGroups': entry.exercise.muscleGroups,
      'setCount': entry.setCount,
      'sets': entry.sets.map((set) => {
        'targetReps': set.targetReps,
        'targetWeight': set.targetWeight,
        'actualReps': set.actualReps,
        'actualWeight': set.actualWeight,
        'isCompleted': set.isCompleted,
      }).toList(),
    }).toList()));
    await prefs.setString(_weeklyRoutineKey, jsonEncode(routineJson));
  }

  // Haftalık rutini al
  static Future<Map<String, List<RoutineEntry>>> getWeeklyRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    final routineString = prefs.getString(_weeklyRoutineKey);
    if (routineString == null) return {};
    try {
      final routineJson = jsonDecode(routineString) as Map;
      return routineJson.map((day, entries) => MapEntry(day.toString(), (entries as List).map((entry) {
        final exerciseName = entry['exerciseName']?.toString() ?? '';
        final mainMuscleGroup = entry['mainMuscleGroup']?.toString();
        final muscleGroups = (entry['muscleGroups'] as List?)?.map((e) => e.toString()).toList();
        Exercise? exercise;
        // Önce tüm tanımlı egzersizler içinde ada göre arama yap
        final allKnown = muscleGroupExercises.values.expand((l) => l).toList() + allExercises;
        try {
          exercise = allKnown.firstWhere((e) => e.name == exerciseName);
        } catch (e) {
          // Ad bulunamazsa, kayıtlı özelliklerle yeni bir Exercise oluştur
          exercise = Exercise(
              name: exerciseName,
              mainMuscleGroup: mainMuscleGroup ?? 'Bilinmeyen',
              muscleGroups: muscleGroups ?? ['Bilinmeyen'],
              muscleGroupRatios: {for (var m in (muscleGroups ?? ['Bilinmeyen'])) m: 1.0},
          );
        }
        return RoutineEntry(
          exercise: exercise!,
          setCount: entry['setCount'] ?? 0,
          sets: (entry['sets'] as List? ?? []).map((set) => SetEntry(
            targetReps: set['targetReps'] ?? 0,
            targetWeight: set['targetWeight'] ?? 0.0,
            actualReps: set['actualReps'] ?? 0,
            actualWeight: set['actualWeight'] ?? 0.0,
            isCompleted: set['isCompleted'] ?? false,
          )).toList(),
        );
      }).toList()));
    } catch (e) {
      print('Error loading weekly routine: $e');
      return {};
    }
  }

  // Tamamlanan antrenmanları kaydet
  static Future<void> saveCompletedWorkouts(Map<String, List<RoutineEntry>> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    final workoutsJson = workouts.map((day, entries) => MapEntry(day, entries.map((entry) => {
      'exerciseName': entry.exercise.name,
      'mainMuscleGroup': entry.exercise.mainMuscleGroup,
      'muscleGroups': entry.exercise.muscleGroups,
      'setCount': entry.setCount,
      'sets': entry.sets.map((set) => {
        'targetReps': set.targetReps,
        'targetWeight': set.targetWeight,
        'actualReps': set.actualReps,
        'actualWeight': set.actualWeight,
        'isCompleted': set.isCompleted,
      }).toList(),
    }).toList()));
    await prefs.setString(_completedWorkoutsKey, jsonEncode(workoutsJson));
  }

  // Tamamlanan antrenmanları al
  static Future<Map<String, List<RoutineEntry>>> getCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutsString = prefs.getString(_completedWorkoutsKey);
    if (workoutsString == null) return {};
    try {
      final workoutsJson = jsonDecode(workoutsString) as Map;
      return workoutsJson.map((day, entries) => MapEntry(day.toString(), (entries as List).map((entry) {
        final exerciseName = entry['exerciseName']?.toString() ?? '';
        final mainMuscleGroup = entry['mainMuscleGroup']?.toString();
        final muscleGroups = (entry['muscleGroups'] as List?)?.map((e) => e.toString()).toList();
        Exercise? exercise;
        final allKnown = muscleGroupExercises.values.expand((l) => l).toList() + allExercises;
        try {
          exercise = allKnown.firstWhere((e) => e.name == exerciseName);
        } catch (e) {
          exercise = Exercise(
              name: exerciseName,
              mainMuscleGroup: mainMuscleGroup ?? 'Bilinmeyen',
              muscleGroups: muscleGroups ?? ['Bilinmeyen'],
              muscleGroupRatios: {for (var m in (muscleGroups ?? ['Bilinmeyen'])) m: 1.0},
          );
        }
        return RoutineEntry(
          exercise: exercise!,
          setCount: entry['setCount'] ?? 0,
          sets: (entry['sets'] as List? ?? []).map((set) => SetEntry(
            targetReps: set['targetReps'] ?? 0,
            targetWeight: set['targetWeight'] ?? 0.0,
            actualReps: set['actualReps'] ?? 0,
            actualWeight: set['actualWeight'] ?? 0.0,
            isCompleted: set['isCompleted'] ?? false,
          )).toList(),
        );
      }).toList()));
    } catch (e) {
      print('Error loading completed workouts: $e');
      return {};
    }
  }

  // Dil ayarını kaydet
  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  // Dil ayarını al
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'English';
  }

  // Egzersiz geçmişini kaydet
  static Future<void> saveExerciseHistory(Map<String, List<ExerciseHistory>> history) async {
    try {
      print('💾 DEBUG: saveExerciseHistory - Fonksiyon başladı');
      print('💾 DEBUG: saveExerciseHistory - Gelen veri: ${history.length} egzersiz');
      
      for (final entry in history.entries) {
        print('💾 DEBUG: saveExerciseHistory - ${entry.key}: ${entry.value.length} kayıt');
      }
      
      // Eğer history boşsa, SharedPreferences'ı temizle
      if (history.isEmpty) {
        print('💾 DEBUG: saveExerciseHistory - History boş, SharedPreferences temizleniyor');
        final prefs = await SharedPreferences.getInstance();
        
        // Temizleme öncesi kontrol
        final beforeData = prefs.getString(_exerciseHistoryKey);
        print('💾 DEBUG: saveExerciseHistory - Temizleme öncesi veri: ${beforeData?.substring(0, beforeData != null && beforeData.length > 100 ? 100 : beforeData?.length)}${beforeData != null && beforeData.length > 100 ? '...' : ''}');
        
        await prefs.remove(_exerciseHistoryKey);
        
        // Temizleme sonrası kontrol
        final afterData = prefs.getString(_exerciseHistoryKey);
        print('💾 DEBUG: saveExerciseHistory - Temizleme sonrası veri: $afterData');
        
        print('💾 DEBUG: saveExerciseHistory - Egzersiz geçmişi temizlendi');
        return;
      }
      
    final normalizedHistory = history.map((exerciseName, entries) => MapEntry(exerciseName.trim().toLowerCase(), entries));
      print('💾 DEBUG: saveExerciseHistory - Normalize edilmiş veriler: ${normalizedHistory.length} egzersiz');
      
      for (final entry in normalizedHistory.entries) {
        print('💾 DEBUG: saveExerciseHistory - Normalize edilmiş: "${entry.key}": ${entry.value.length} kayıt');
      }
      
    final historyJson = normalizedHistory.map((exerciseName, entries) => MapEntry(
      exerciseName,
      entries.map((entry) => entry.toJson()).toList(),
    ));
      
    final jsonString = jsonEncode(historyJson);
      print('💾 DEBUG: saveExerciseHistory - JSON string uzunluğu: ${jsonString.length} karakter');
      print('💾 DEBUG: saveExerciseHistory - JSON string başlangıcı: ${jsonString.substring(0, jsonString.length > 200 ? 200 : jsonString.length)}${jsonString.length > 200 ? '...' : ''}');
      
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_exerciseHistoryKey, jsonString);
      
      // Kaydetme sonrası doğrulama
      final savedData = prefs.getString(_exerciseHistoryKey);
      print('💾 DEBUG: saveExerciseHistory - Kaydedilen veri uzunluğu: ${savedData?.length} karakter');
      print('💾 DEBUG: saveExerciseHistory - Kaydedilen veri başlangıcı: ${savedData?.substring(0, savedData.length > 200 ? 200 : savedData.length)}${savedData != null && savedData.length > 200 ? '...' : ''}');
      
      print('💾 DEBUG: saveExerciseHistory - Veriler başarıyla kaydedildi');
    } catch (e) {
      print('💾 DEBUG: saveExerciseHistory - Hata oluştu: $e');
      print('💾 DEBUG: saveExerciseHistory - Hata stack trace: ${StackTrace.current}');
    }
  }

  // Egzersiz geçmişini al
  static Future<Map<String, List<ExerciseHistory>>> getExerciseHistory() async {
    try {
      print('🔍 DEBUG: getExerciseHistory - Fonksiyon başladı');
      
    final prefs = await SharedPreferences.getInstance();
      print('🔍 DEBUG: getExerciseHistory - SharedPreferences instance alındı');
      
      // Tüm anahtarları kontrol et
      final allKeys = prefs.getKeys();
      print('🔍 DEBUG: getExerciseHistory - Tüm SharedPreferences anahtarları: $allKeys');
      print('🔍 DEBUG: getExerciseHistory - Aranan anahtar: $_exerciseHistoryKey');
      
    final historyString = prefs.getString(_exerciseHistoryKey);
      print('🔍 DEBUG: getExerciseHistory - $_exerciseHistoryKey anahtarından alınan veri: ${historyString?.substring(0, historyString.length > 200 ? 200 : historyString.length)}${historyString != null && historyString.length > 200 ? '...' : ''}');
      
      if (historyString == null || historyString == '{}' || historyString.isEmpty) {
        print('🔍 DEBUG: getExerciseHistory - Veri bulunamadı, boş map döndürülüyor');
        print('🔍 DEBUG: getExerciseHistory - historyString: $historyString');
        return {};
      }
      
      final historyJson = jsonDecode(historyString) as Map;
      print('🔍 DEBUG: getExerciseHistory - JSON decode edildi, ${historyJson.length} egzersiz bulundu');
      print('🔍 DEBUG: getExerciseHistory - Egzersiz anahtarları: ${historyJson.keys.toList()}');
      
    final result = historyJson.map((exerciseName, entries) => MapEntry(
      exerciseName.toString().trim().toLowerCase(),
      (entries as List).map((entry) => ExerciseHistory.fromJson(entry)).toList(),
    ));
      
      print('🔍 DEBUG: getExerciseHistory - Sonuç hazırlandı: ${result.length} egzersiz');
      for (final entry in result.entries) {
        print('🔍 DEBUG: getExerciseHistory - ${entry.key}: ${entry.value.length} kayıt');
        for (int i = 0; i < entry.value.length; i++) {
          final history = entry.value[i];
          print('🔍 DEBUG: getExerciseHistory - Kayıt $i: ${history.exerciseName} - ${history.weight} kg × ${history.reps} tekrar - ${history.date}');
        }
      }
      
      return result;
    } catch (e) {
      print('🔍 DEBUG: getExerciseHistory - Hata oluştu: $e');
      print('🔍 DEBUG: getExerciseHistory - Hata stack trace: ${StackTrace.current}');
      return {};
    }
  }

  // Tüm egzersiz geçmişini temizle
  static Future<void> clearAllExerciseHistory() async {
    try {
      print('🧹 DEBUG: clearAllExerciseHistory - Fonksiyon başladı');
      
      final prefs = await SharedPreferences.getInstance();
      print('🧹 DEBUG: clearAllExerciseHistory - SharedPreferences instance alındı');
      
      // Temizleme öncesi kontrol
      final beforeKeys = prefs.getKeys();
      print('🧹 DEBUG: clearAllExerciseHistory - Temizleme öncesi anahtarlar: $beforeKeys');
      
      final beforeData = prefs.getString(_exerciseHistoryKey);
      print('🧹 DEBUG: clearAllExerciseHistory - Temizleme öncesi $_exerciseHistoryKey verisi: ${beforeData?.substring(0, beforeData.length > 100 ? 100 : beforeData.length)}${beforeData != null && beforeData.length > 100 ? '...' : ''}');
      
      await prefs.remove(_exerciseHistoryKey);
      print('🧹 DEBUG: clearAllExerciseHistory - $_exerciseHistoryKey anahtarı kaldırıldı');
      
      // Temizleme sonrası kontrol
      final afterKeys = prefs.getKeys();
      print('🧹 DEBUG: clearAllExerciseHistory - Temizleme sonrası anahtarlar: $afterKeys');
      
      final afterData = prefs.getString(_exerciseHistoryKey);
      print('🧹 DEBUG: clearAllExerciseHistory - Temizleme sonrası $_exerciseHistoryKey verisi: $afterData');
      
      print('🧹 DEBUG: clearAllExerciseHistory - Tüm egzersiz geçmişi temizlendi');
      
      // Global flag'i aktif et
      globalIsDataCleared = true;
      print('🧹 DEBUG: clearAllExerciseHistory - Global flag aktif edildi: globalIsDataCleared = true');
      
      // EventBus ile tüm ekranlara bildir
      eventBus.fire(DataClearedEvent(isGlobalClear: true));
      print('🧹 DEBUG: clearAllExerciseHistory - DataClearedEvent gönderildi');
      
    } catch (e) {
      print('🧹 DEBUG: clearAllExerciseHistory - Hata oluştu: $e');
      print('🧹 DEBUG: clearAllExerciseHistory - Hata stack trace: ${StackTrace.current}');
    }
  }

  // Belirli bir egzersizin geçmişini temizle
  static Future<void> clearExerciseHistory(String exerciseName) async {
    try {
      final history = await getExerciseHistory();
      final normalizedName = exerciseName.trim().toLowerCase();
      history.remove(normalizedName);
      await saveExerciseHistory(history);
      print('clearExerciseHistory - $exerciseName geçmişi temizlendi');
    } catch (e) {
      print('clearExerciseHistory hatası: $e');
    }
  }

  // Hatırlatıcı ayarlarını kaydet
  static Future<void> saveWeightReminderSettings({
    required bool enabled,
    required TimeOfDay time,
    required String frequency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weightReminderEnabledKey, enabled);
    await prefs.setString(_weightReminderTimeKey, '${time.hour}:${time.minute}');
    await prefs.setString(_weightReminderFrequencyKey, frequency);
  }

  static Future<void> saveWaterReminderSettings({
    required bool enabled,
    required TimeOfDay time,
    required String interval,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_waterReminderEnabledKey, enabled);
    await prefs.setString(_waterReminderTimeKey, '${time.hour}:${time.minute}');
    await prefs.setString(_waterReminderIntervalKey, interval);
  }

  // Hatırlatıcı ayarlarını al
  static Future<Map<String, dynamic>> getWeightReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_weightReminderEnabledKey) ?? false;
    final timeString = prefs.getString(_weightReminderTimeKey) ?? '8:0';
    final frequency = prefs.getString(_weightReminderFrequencyKey) ?? 'Haftalık';
    
    final timeParts = timeString.split(':');
    final time = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 8,
      minute: int.tryParse(timeParts[1]) ?? 0,
    );
    
    return {
      'enabled': enabled,
      'time': time,
      'frequency': frequency,
    };
  }

  static Future<Map<String, dynamic>> getWaterReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_waterReminderEnabledKey) ?? false;
    final timeString = prefs.getString(_waterReminderTimeKey) ?? '9:0';
    final interval = prefs.getString(_waterReminderIntervalKey) ?? '2 saat';
    
    final timeParts = timeString.split(':');
    final time = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 9,
      minute: int.tryParse(timeParts[1]) ?? 0,
    );
    
    return {
      'enabled': enabled,
      'time': time,
      'interval': interval,
    };
  }

  // Son tamamlanma tarihlerini kaydet
  static Future<void> saveLastCompletedDates(Map<String, DateTime> lastCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    final datesJson = lastCompleted.map((day, date) => MapEntry(day, date.toIso8601String()));
    await prefs.setString(_lastCompletedDatesKey, jsonEncode(datesJson));
  }

  // Son tamamlanma tarihlerini al
  static Future<Map<String, DateTime>> getLastCompletedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final datesString = prefs.getString(_lastCompletedDatesKey);
    if (datesString == null) return {};
    
    try {
      final datesJson = jsonDecode(datesString) as Map;
      return datesJson.map((day, dateString) => MapEntry(
        day.toString(),
        DateTime.parse(dateString.toString()),
      ));
    } catch (e) {
      print('Error loading last completed dates: $e');
      return {};
    }
  }

  // Tamamlanan antrenman tarihlerini al
  static Future<List<String>> getCompletedWorkoutDates() async {
    final prefs = await SharedPreferences.getInstance();
    final datesString = prefs.getString('completed_workout_dates');
    if (datesString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(datesString);
        return decoded.cast<String>();
      } catch (e) {
        print('Error parsing completed workout dates: $e');
        return [];
      }
    }
    return [];
  }

  // Egzersiz geçmişinde ilgili seti tamamla
  static Future<void> markSetAsCompleted(String exerciseName, int setIndex) async {
    final history = await getExerciseHistory();
    final key = exerciseName.trim().toLowerCase();
    if (history.containsKey(key) && history[key]!.isNotEmpty) {
      final last = history[key]!.last;
      if (last.sets.length >= setIndex) {
        final sets = List<SetEntry>.from(last.sets);
        sets[setIndex - 1] = sets[setIndex - 1].copyWith(isCompleted: true);
        final updated = ExerciseHistory(
          exerciseName: last.exerciseName,
          date: last.date,
          weight: last.weight,
          reps: last.reps,
          setsCount: sets.length,
          sets: sets,
        );
        history[key]![history[key]!.length - 1] = updated;
        await saveExerciseHistory(history);
        print('Set tamamlandı olarak işaretlendi ve kaydedildi: $exerciseName, set $setIndex');
      }
    }
  }

  // Bildirimden ağırlık/tekrar ayarla
  static Future<void> adjustSetWeightReps(String exerciseName, int setIndex, double deltaWeight, int deltaReps) async {
    final history = await getExerciseHistory();
    final key = exerciseName.trim().toLowerCase();
    if (!history.containsKey(key) || history[key]!.isEmpty) return;
    final last = history[key]!.last;
    if (last.sets.length < setIndex) return;
    final sets = List<SetEntry>.from(last.sets);
    final current = sets[setIndex - 1];
    final newWeight = ((current.actualWeight ?? current.targetWeight ?? 0).toDouble() + deltaWeight).clamp(0.0, 999.0);
    final newReps = ((current.actualReps ?? current.targetReps ?? 1) + deltaReps).clamp(1, 999);
    sets[setIndex - 1] = current.copyWith(
      actualWeight: newWeight,
      actualReps: newReps,
    );
    final updated = ExerciseHistory(
      exerciseName: last.exerciseName,
      date: last.date,
      weight: newWeight,
      reps: newReps,
      setsCount: sets.length,
      sets: sets,
    );
    history[key]![history[key]!.length - 1] = updated;
    await saveExerciseHistory(history);
    print('Set güncellendi: $exerciseName, set $setIndex -> $newWeight kg x $newReps');
  }

  // Orijinal gün isimlerini kaydet
  static Future<void> saveOriginalDayNames(Map<String, String> originalDayNames) async {
    final prefs = await SharedPreferences.getInstance();
    if (originalDayNames.isEmpty) {
      await prefs.remove(_originalDayNamesKey);
    } else {
    await prefs.setString(_originalDayNamesKey, jsonEncode(originalDayNames));
    }
  }

  // Orijinal gün isimlerini al
  static Future<Map<String, String>> getOriginalDayNames() async {
    final prefs = await SharedPreferences.getInstance();
    final namesString = prefs.getString(_originalDayNamesKey);
    if (namesString == null) return {};
    final namesJson = jsonDecode(namesString) as Map;
    return namesJson.map((k, v) => MapEntry(k.toString(), v.toString()));
  }

  static Future<void> saveActiveWorkout({
    required List<RoutineEntry> entries,
    required int exerciseIndex,
    required int setIndex,
    required String exerciseName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = entries.map((entry) => {
      'exerciseName': entry.exercise.name,
      'mainMuscleGroup': entry.exercise.mainMuscleGroup,
      'muscleGroups': entry.exercise.muscleGroups,
      'setCount': entry.setCount,
      'sets': entry.sets.map((set) => {
        'targetReps': set.targetReps,
        'targetWeight': set.targetWeight,
        'actualReps': set.actualReps,
        'actualWeight': set.actualWeight,
        'isCompleted': set.isCompleted,
      }).toList(),
    }).toList();
    final payload = {
      'exerciseIndex': exerciseIndex,
      'setIndex': setIndex,
      'exerciseName': exerciseName,
      'entries': entriesJson,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_activeWorkoutKey, jsonEncode(payload));
  }

  static Future<Map<String, dynamic>?> getActiveWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_activeWorkoutKey);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      final entries = (map['entries'] as List? ?? []).map((entry) {
        final exerciseName = entry['exerciseName']?.toString() ?? '';
        final mainMuscleGroup = entry['mainMuscleGroup']?.toString();
        final muscleGroups = (entry['muscleGroups'] as List?)?.map((e) => e.toString()).toList();
        Exercise exercise;
        try {
          exercise = allExercises.firstWhere((e) => e.name == exerciseName);
        } catch (_) {
          exercise = Exercise(
            name: exerciseName,
            mainMuscleGroup: mainMuscleGroup ?? 'Bilinmeyen',
            muscleGroups: muscleGroups ?? const ['Bilinmeyen'],
            muscleGroupRatios: {for (var m in (muscleGroups ?? ['Bilinmeyen'])) m: 1.0},
          );
        }
        return RoutineEntry(
          exercise: exercise,
          setCount: entry['setCount'] ?? 0,
          sets: (entry['sets'] as List? ?? []).map((set) => SetEntry(
            targetReps: set['targetReps'] ?? 0,
            targetWeight: (set['targetWeight'] as num?)?.toDouble() ?? 0.0,
            actualReps: set['actualReps'] ?? 0,
            actualWeight: (set['actualWeight'] as num?)?.toDouble() ?? 0.0,
            isCompleted: set['isCompleted'] ?? false,
          )).toList(),
        );
      }).toList();
      return {
        'exerciseIndex': map['exerciseIndex'] ?? 0,
        'setIndex': map['setIndex'] ?? 0,
        'exerciseName': map['exerciseName']?.toString() ?? (entries.isNotEmpty ? entries[0].exercise.name : ''),
        'entries': entries,
      };
    } catch (e) {
      print('getActiveWorkout parse error: $e');
      return null;
    }
  }

  static Future<void> clearActiveWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeWorkoutKey);
    // Oturum bayrağını sıfırla ki yeni antrenman için tekrar sorulsun
    globalActiveWorkoutDialogShown = false;
  }
}

// Responsive tasarım için extension
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // Font boyutları için responsive değerler
  double get responsiveFontSize {
    if (screenWidth < 400) return 12.0; // Küçük ekranlar
    if (screenWidth < 600) return 14.0; // Orta ekranlar
    if (screenWidth < 900) return 16.0; // Büyük ekranlar
    return 18.0; // Çok büyük ekranlar
  }
  
  double get responsiveTitleFontSize {
    if (screenWidth < 400) return 16.0;
    if (screenWidth < 600) return 18.0;
    if (screenWidth < 900) return 20.0;
    return 22.0;
  }
  
  double get responsivePadding {
    if (screenWidth < 400) return 8.0;
    if (screenWidth < 600) return 12.0;
    if (screenWidth < 900) return 16.0;
    return 20.0;
  }
  
  double get responsiveIconSize {
    if (screenWidth < 400) return 16.0;
    if (screenWidth < 600) return 20.0;
    if (screenWidth < 900) return 24.0;
    return 28.0;
  }
}

// Kullanıcı seviyesi için veri yapısı
class UserLevel {
  final String name;
  final String level; // 'Yeni Başlayan', 'Orta Seviye', 'İleri Seviye'
  final int minSets;
  final int maxSets;

  UserLevel({
    required this.name,
    required this.level,
    required this.minSets,
    required this.maxSets,
  });
}

// Global kullanıcı bilgileri
UserLevel? globalUserLevel;

// Global dil değişkeni
String globalLanguage = 'English';

// Global completed workouts
Map<String, List<RoutineEntry>> globalCompletedWorkouts = {};

// Global veri temizleme flag'i
bool globalIsDataCleared = false;

// Oturumda "Devam et" diyaloğu sadece bir kez gösterilsin
bool globalActiveWorkoutDialogShown = false;

// Global state için callback listesi
final List<Function> _languageChangeCallbacks = <Function>[];

void addLanguageChangeCallback(Function callback) {
  _languageChangeCallbacks.add(callback);
}

void removeLanguageChangeCallback(Function callback) {
  _languageChangeCallbacks.remove(callback);
}

void updateGlobalLanguage(String newLanguage) async {
  globalLanguage = newLanguage;
  // Dil ayarını kaydet
  await DataManager.saveLanguage(newLanguage);
  // Tüm callback'leri çağır
  for (var callback in _languageChangeCallbacks) {
    callback();
  }
}

// Kas grubu isimlerini lokalize etmek için fonksiyon
String getLocalizedMuscleGroup(String muscleGroup) {
  if (globalLanguage == 'Türkçe') {
    return muscleGroup;
  } else {
    switch (muscleGroup) {
      case 'Göğüs':
        return 'Chest';
      case 'Omuz':
        return 'Shoulder';
      case 'Bacak':
        return 'Leg';
      case 'Sırt':
        return 'Back';
      case 'Biceps':
        return 'Biceps';
      case 'Triceps':
        return 'Triceps';
      case 'Core':
        return 'Core';
      case 'Kalça':
        return 'Hip';
      default:
        return muscleGroup;
    }
  }
}

String getLocalizedDayName(String dayName) {
  if (globalLanguage == 'Türkçe') {
    return dayName;
  } else {
    switch (dayName) {
      case 'Pazartesi': return 'Monday';
      case 'Salı': return 'Tuesday';
      case 'Çarşamba': return 'Wednesday';
      case 'Perşembe': return 'Thursday';
      case 'Cuma': return 'Friday';
      case 'Cumartesi': return 'Saturday';
      case 'Pazar': return 'Sunday';
      default: return dayName;
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  // Ensure Flutter binding is available in background isolate
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((task, inputData) async {
    if (task == 'waterReminderTask') {
      print('REMINDER_LOG: WorkManager waterReminderTask fired');
        final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_launcher_foreground');
        const DarwinInitializationSettings initializationSettingsIOS =
            DarwinInitializationSettings();
        final InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
        await flutterLocalNotificationsPlugin.initialize(initializationSettings);
        await flutterLocalNotificationsPlugin.show(
          DateTime.now().millisecondsSinceEpoch % 100000,
          'Su İçmeyi Unutma!',
          'Sağlığın için su içmeyi ihmal etme.',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'water_reminder_channel',
              'Su Hatırlatıcı Kanalı',
              channelDescription: 'Periyodik su hatırlatıcıları',
              importance: Importance.max,
              priority: Priority.high,
            icon: '@drawable/ic_launcher_foreground',
            ),
          ),
        );
    } else if (task == 'weightReminderTask') {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_launcher_foreground');
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      final int hour = (inputData != null && inputData['hour'] is int) ? inputData['hour'] as int : 8;
      final int minute = (inputData != null && inputData['minute'] is int) ? inputData['minute'] as int : 0;
      final String frequency = (inputData != null && inputData['frequency'] is String) ? inputData['frequency'] as String : 'Haftalık';
      final String title = (inputData != null && inputData['title'] is String) ? inputData['title'] as String : 'Tartılma Hatırlatıcısı';
      final String body = (inputData != null && inputData['body'] is String) ? inputData['body'] as String : 'Bugün tartılma zamanınız geldi! Kilo takibinizi yapmayı unutmayın.';

      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'weight_reminder_channel',
            'Tartılma Hatırlatıcı Kanalı',
            channelDescription: 'Zamanlanmış tartılma hatırlatıcıları',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );

      // Bir sonrakini yeniden planla
      final now = DateTime.now();
      var next = DateTime(now.year, now.month, now.day, hour, minute);
      if (!next.isAfter(now)) {
        next = next.add(Duration(days: frequency == 'Haftalık' ? 7 : 30));
      } else {
        next = next.add(Duration(days: frequency == 'Haftalık' ? 7 : 30));
      }
      final delay = next.difference(now);
      await Workmanager().registerOneOffTask(
        'weight_reminder',
        'weightReminderTask',
        initialDelay: delay,
        inputData: {
          'title': title,
          'body': body,
          'hour': hour,
          'minute': minute,
          'frequency': frequency,
        },
      );
    }
    return Future.value(true);
  });
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.actionId == 'set_complete' || notificationResponse.actionId == 'save_set' || notificationResponse.actionId == null || notificationResponse.actionId == '') {
    NotificationService.handleAdvanceSetAction(notificationResponse.payload);
  } else if (notificationResponse.actionId == 'weight_plus') {
    NotificationService.handleAdjustFromNotification(notificationResponse.payload, deltaWeight: 2.5);
  } else if (notificationResponse.actionId == 'weight_minus') {
    NotificationService.handleAdjustFromNotification(notificationResponse.payload, deltaWeight: -2.5);
  } else if (notificationResponse.actionId == 'reps_plus') {
    NotificationService.handleAdjustFromNotification(notificationResponse.payload, deltaReps: 1);
  } else if (notificationResponse.actionId == 'reps_minus') {
    NotificationService.handleAdjustFromNotification(notificationResponse.payload, deltaReps: -1);
  } else if (notificationResponse.actionId == 'close_progress') {
    NotificationService.cancelQuickSetProgressNotification();
  }
}

Future<void> scheduleWaterReminderTask() async {
  final prefs = await SharedPreferences.getInstance();
  final enabled = prefs.getBool(DataManager._waterReminderEnabledKey) ?? false;
  final intervalStr = prefs.getString(DataManager._waterReminderIntervalKey) ?? '2 saat';
  final timeStr = prefs.getString(DataManager._waterReminderTimeKey) ?? '9:0';
  int intervalHours = 2;
  final match = RegExp(r'(\d+)').firstMatch(intervalStr);
  if (match != null) {
    intervalHours = int.tryParse(match.group(1) ?? '2') ?? 2;
  }
  await Workmanager().cancelByUniqueName('water_reminder_task_id');
  if (!enabled) {
    return;
  }
  int startHour = 9;
  int startMinute = 0;
  final parts = timeStr.split(':');
  if (parts.length == 2) {
    startHour = int.tryParse(parts[0]) ?? 9;
    startMinute = int.tryParse(parts[1]) ?? 0;
  }
  final now = DateTime.now();
  DateTime next = DateTime(now.year, now.month, now.day, startHour, startMinute);
  while (!next.isAfter(now)) {
    next = next.add(Duration(hours: intervalHours));
  }
  final initialDelay = next.difference(now);
  await Workmanager().registerPeriodicTask(
    'water_reminder_task_id',
    'waterReminderTask',
    frequency: Duration(hours: intervalHours),
    initialDelay: initialDelay,
    constraints: Constraints(
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // WorkManager for background fallback notifications
  try {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    print('REMINDER_LOG: WorkManager initialized');
  } catch (e) {
    print('REMINDER_LOG: WorkManager init error: $e');
  }
  // Uygulama açılışında kaydedilmiş dili yükle
  try {
    globalLanguage = await DataManager.getLanguage();
  } catch (_) {}
  // Sadece bildirim izni gerekli olduğunda istenecek; ilk açılışta rahatsız etmeyelim
  // WorkManager başlangıcı zorunlu değil; zonedSchedule kullanıyoruz
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await NotificationService._notifications.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.actionId == null || response.actionId == '' || response.actionId == 'set_complete') {
        await NotificationService.handleAdvanceSetAction(response.payload);
      } else if (response.actionId == 'weight_plus') {
        await NotificationService.handleAdjustFromNotification(response.payload, deltaWeight: 2.5);
      } else if (response.actionId == 'weight_minus') {
        await NotificationService.handleAdjustFromNotification(response.payload, deltaWeight: -2.5);
      } else if (response.actionId == 'reps_plus') {
        await NotificationService.handleAdjustFromNotification(response.payload, deltaReps: 1);
      } else if (response.actionId == 'reps_minus') {
        await NotificationService.handleAdjustFromNotification(response.payload, deltaReps: -1);
      } else if (response.actionId == 'save_set') {
        await NotificationService.handleAdvanceSetAction(response.payload);
      } else if (response.actionId == 'close_progress') {
        await NotificationService.cancelQuickSetProgressNotification();
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
  runApp(const WeightTrackerApp());
}

class WeightTrackerApp extends StatelessWidget {
  const WeightTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFitLog',
      theme: ThemeData(
        primarySwatch: MaterialColor(AppColorTheme.primary.value, {
          50: AppColorTheme.primary.withOpacity(0.1),
          100: AppColorTheme.primary.withOpacity(0.2),
          200: AppColorTheme.primary.withOpacity(0.3),
          300: AppColorTheme.primary.withOpacity(0.4),
          400: AppColorTheme.primary.withOpacity(0.5),
          500: AppColorTheme.primary,
          600: AppColorTheme.primary.withOpacity(0.7),
          700: AppColorTheme.primary.withOpacity(0.8),
          800: AppColorTheme.primary.withOpacity(0.9),
          900: AppColorTheme.primary,
        }),
        useMaterial3: false,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          selectedLabelStyle: TextStyle(color: Colors.black),
          unselectedLabelStyle: TextStyle(color: Colors.black),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// --- Egzersiz ve Kas Grubu Modeli ---
class Exercise {
  final String name;
  final List<String> muscleGroups;
  final String mainMuscleGroup;
  final Map<String, double> muscleGroupRatios;
  
  const Exercise({
    required this.name, 
    required this.muscleGroups, 
    required this.mainMuscleGroup,
    this.muscleGroupRatios = const {},
  });
}

const List<Exercise> allExercises = [
  Exercise(
    name: 'Squat', 
    muscleGroups: ['Bacak', 'Kalça'], 
    mainMuscleGroup: 'Bacak',
    muscleGroupRatios: {'Bacak': 1.0, 'Kalça': 0.3},
  ),
  Exercise(
    name: 'Bench Press', 
    muscleGroups: ['Göğüs', 'Triceps'], 
    mainMuscleGroup: 'Göğüs',
    muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.3},
  ),
  Exercise(
    name: 'Barbell Bench Press', 
    muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
    mainMuscleGroup: 'Göğüs',
    muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.5, 'Omuz': 0.4},
  ),
  Exercise(
    name: 'Deadlift', 
    muscleGroups: ['Sırt', 'Bacak', 'Kalça'], 
    mainMuscleGroup: 'Sırt',
    muscleGroupRatios: {'Sırt': 1.0, 'Bacak': 0.3, 'Kalça': 0.2},
  ),
  Exercise(
    name: 'Overhead Press', 
    muscleGroups: ['Omuz', 'Triceps'], 
    mainMuscleGroup: 'Omuz',
    muscleGroupRatios: {'Omuz': 1.0, 'Triceps': 0.3},
  ),
  Exercise(
    name: 'Barbell Row', 
    muscleGroups: ['Sırt', 'Biceps', 'Core'], 
    mainMuscleGroup: 'Sırt',
    muscleGroupRatios: {'Sırt': 0.6, 'Biceps': 0.3, 'Core': 0.1},
  ),
  Exercise(
    name: 'Pull Up', 
    muscleGroups: ['Sırt', 'Biceps'], 
    mainMuscleGroup: 'Sırt',
    muscleGroupRatios: {'Sırt': 0.7, 'Biceps': 0.3},
  ),
  Exercise(
    name: 'Lunge', 
    muscleGroups: ['Bacak', 'Kalça'], 
    mainMuscleGroup: 'Bacak',
    muscleGroupRatios: {'Bacak': 0.7, 'Kalça': 0.3},
  ),
  Exercise(
    name: 'Biceps Curl', 
    muscleGroups: ['Biceps'], 
    mainMuscleGroup: 'Biceps',
    muscleGroupRatios: {'Biceps': 1.0},
  ),
  Exercise(
    name: 'Triceps Extension', 
    muscleGroups: ['Triceps'], 
    mainMuscleGroup: 'Triceps',
    muscleGroupRatios: {'Triceps': 1.0},
  ),
  Exercise(
    name: 'Leg Press', 
    muscleGroups: ['Bacak', 'Kalça'], 
    mainMuscleGroup: 'Bacak',
    muscleGroupRatios: {'Bacak': 0.7, 'Kalça': 0.3},
  ),
];

const List<String> weekDays = [
  'Pazartesi',
  'Salı',
  'Çarşamba',
  'Perşembe',
  'Cuma',
  'Cumartesi',
  'Pazar',
];

const Map<String, String> weekDayShort = {
  'Pazartesi': 'Pzt',
  'Salı': 'Sal',
  'Çarşamba': 'Çrş',
  'Perşembe': 'Prş',
  'Cuma': 'Cum',
  'Cumartesi': 'Cmt',
  'Pazar': 'Paz',
};

// weekDayColors artık AppColorTheme içinde tanımlandı

class SetEntry {
  final int targetReps;
  final double targetWeight;
  int actualReps;
  double actualWeight;
  bool isCompleted;
  
  SetEntry({
    required this.targetReps,
    required this.targetWeight,
    int? actualReps,
    double? actualWeight,
    this.isCompleted = false,
  })  : actualReps = actualReps ?? targetReps,
        actualWeight = actualWeight ?? targetWeight;

  SetEntry copyWith({int? actualReps, double? actualWeight, bool? isCompleted}) {
    return SetEntry(
      targetReps: targetReps,
      targetWeight: targetWeight,
      actualReps: actualReps ?? this.actualReps,
      actualWeight: actualWeight ?? this.actualWeight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'targetReps': targetReps,
    'targetWeight': targetWeight,
    'actualReps': actualReps,
    'actualWeight': actualWeight,
    'isCompleted': isCompleted,
  };

  static SetEntry fromJson(Map<String, dynamic> json) => SetEntry(
    targetReps: json['targetReps'],
    targetWeight: (json['targetWeight'] as num).toDouble(),
    actualReps: json['actualReps'],
    actualWeight: (json['actualWeight'] as num).toDouble(),
    isCompleted: json['isCompleted'] ?? false,
  );
}

class RoutineEntry {
  final Exercise exercise;
  final int setCount;
  final List<SetEntry> sets;
  RoutineEntry({required this.exercise, required this.setCount, required this.sets});
}



class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    const WeekScreen(),
    const HesaplaScreen(),
    StatisticsScreen(selectedTabIndex: _currentIndex),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeReminders();
    // globalLanguage değiştiğinde UI'ı güncelle
    addLanguageChangeCallback(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _initializeReminders() async {
    try {
      // Notification servisini başlat
      await NotificationService.initialize();
      // Bildirim izni gerekirse UI akışında istenecek; burada zorlamıyoruz
      // Hatırlatıcı ayarlarını yükle ve aktif olanları planla
      final weightSettings = await DataManager.getWeightReminderSettings();
      final waterSettings = await DataManager.getWaterReminderSettings();
      
      if (weightSettings['enabled'] == true) {
        print('REMINDER_LOG: weightSettings -> enabled=${weightSettings['enabled']}, time=${weightSettings['time']}, freq=${weightSettings['frequency']}');
        await NotificationService.scheduleWeightReminder(
          time: weightSettings['time'],
          frequency: weightSettings['frequency'],
        );
      }
      
      if (waterSettings['enabled'] == true) {
        print('REMINDER_LOG: waterSettings -> enabled=${waterSettings['enabled']}, time=${waterSettings['time']}, interval=${waterSettings['interval']}');
        await NotificationService.scheduleWaterReminder(
          time: waterSettings['time'],
          interval: waterSettings['interval'],
        );
      } else {
        print('REMINDER_LOG: water reminder is disabled in settings');
      }
    } catch (e) {
      print('Error initializing reminders: $e');
    }
  }

  @override
  void dispose() {
    removeLanguageChangeCallback(() {
      if (mounted) {
        setState(() {});
      }
    });
    super.dispose();
  }

  Widget _buildRoutineIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
        painter: RoutineIconPainter(
            color: _currentIndex == 0 ? Color(0xFFFF6B35) : Color(0xFFB3E0FF),
          ),
          size: Size(32, 32),
        ),
        SizedBox(height: 2),
        Text(
          globalLanguage == 'Türkçe' ? 'Rutin' : 'Routine',
          style: TextStyle(
            color: _currentIndex == 0 ? Color(0xFFFF6B35) : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
        painter: CalculateIconPainter(
            color: _currentIndex == 1 ? Color(0xFFFF6B35) : Color(0xFFB3E0FF),
          ),
          size: Size(32, 32),
        ),
        SizedBox(height: 2),
        Text(
          globalLanguage == 'Türkçe' ? 'Hesapla' : 'Calculate',
          style: TextStyle(
            color: _currentIndex == 1 ? Color(0xFFFF6B35) : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
        painter: StatisticsIconPainter(
            color: _currentIndex == 2 ? Color(0xFFFF6B35) : Color(0xFFB3E0FF),
          ),
          size: Size(32, 32),
        ),
        SizedBox(height: 2),
        Text(
          globalLanguage == 'Türkçe' ? 'İstatistikler' : 'Statistics',
          style: TextStyle(
            color: _currentIndex == 2 ? Color(0xFFFF6B35) : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
        painter: ProfileIconPainter(
            color: _currentIndex == 3 ? Color(0xFFFF6B35) : Color(0xFFB3E0FF),
          ),
          size: Size(32, 32),
        ),
        SizedBox(height: 2),
        Text(
          globalLanguage == 'Türkçe' ? 'Profil' : 'Profile',
          style: TextStyle(
            color: _currentIndex == 3 ? Color(0xFFFF6B35) : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFFF6B35), // Turuncu - aktif sayfa
        unselectedItemColor: Color(0xFFB3E0FF), // Daha açık mavi - pasif sayfalar
        items: [
          BottomNavigationBarItem(
            icon: _buildRoutineIcon(),
            label: '',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: _buildCalculateIcon(),
            label: '',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: _buildStatisticsIcon(),
            label: '',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: _buildProfileIcon(),
            label: '',
            tooltip: '',
          ),
        ],
      ),
    );
  }
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, this.selectedTabIndex = 0});

  final int selectedTabIndex;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, List<RoutineEntry>> _completedWorkouts = {};
  Map<String, List<ExerciseHistory>> _exerciseHistory = {};
  StreamSubscription? _dataClearedSubscription;
  
  // Haftalık rutin ve tamamlanan günler
  Map<String, List<RoutineEntry>> _weeklyRoutine = {};
  Map<String, DateTime> _lastCompleted = {};
  static const int _statisticsTabIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Antrenman tamamlandığında istatistikleri yenile
    eventBus.on<WorkoutCompletedEvent>().listen((event) {
      _loadData();
    });
    
    // Veri temizlendiğinde istatistikleri yenile
    _dataClearedSubscription = eventBus.on<DataClearedEvent>().listen((event) {
      print('DEBUG: StatisticsScreen - DataClearedEvent alındı - isGlobalClear: ${event.isGlobalClear}, exerciseName: ${event.exerciseName}');
      
      if (event.isGlobalClear) {
        // Tüm veriler temizlendi, tüm istatistikleri yenile
        print('DEBUG: StatisticsScreen - Tüm veriler temizlendi, istatistikler yenileniyor');
      _loadData();
      } else if (event.exerciseName != null) {
        // Belirli egzersiz temizlendi, sadece o egzersizi etkileyen istatistikleri yenile
        print('DEBUG: StatisticsScreen - ${event.exerciseName} temizlendi, istatistikler güncelleniyor');
        _loadData(); // Şimdilik tüm veriyi yenile, gelecekte optimize edilebilir
      }
    });
  }

  @override
  void didUpdateWidget(StatisticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // İstatistik sekmesine her geçişte veriyi yenile (güncel tamamlanan antrenmanlar görünsün)
    if (widget.selectedTabIndex == _statisticsTabIndex && oldWidget.selectedTabIndex != _statisticsTabIndex) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      print('Loading statistics data...');
      final weeklyRoutine = await DataManager.getWeeklyRoutine();
      final lastCompleted = await DataManager.getLastCompletedDates();
      final completedWorkouts = await DataManager.getCompletedWorkouts();
      final exerciseHistory = await DataManager.getExerciseHistory();
      
      // NOT: Egzersiz geçmişini asla burada temizleme.
      // Cache boş olabilir; bu durum SharedPreferences'taki geçmişi silmek için bir gerekçe değil.
      print('Loaded weekly routine: ${weeklyRoutine.keys}');
      print('Loaded last completed days: ${lastCompleted.keys}');
      print('Loaded completed workouts: $completedWorkouts');
      print('Loaded exercise history: $exerciseHistory');
      print('Exercise history keys: ${exerciseHistory.keys.toList()}');
      print('Exercise history total entries: ${exerciseHistory.values.fold(0, (sum, list) => sum + list.length)}');
      
      setState(() {
        _weeklyRoutine = weeklyRoutine;
        _lastCompleted = lastCompleted;
        _completedWorkouts = completedWorkouts;
        _exerciseHistory = exerciseHistory;
      });
    } catch (e) {
      print('Error loading statistics data: $e');
      setState(() {
        _weeklyRoutine = {};
        _lastCompleted = {};
        _completedWorkouts = {};
        _exerciseHistory = {};
      });
    }
  }

  Map<String, int> get _weeklyMuscleSets {
    // Son 7 güne göre egzersiz geçmişinden set topla (tekrar oturumlar dahil)
    Map<String, int> muscleSets = {
      'Göğüs': 0,
      'Omuz': 0,
      'Bacak': 0,
      'Sırt': 0,
      'Biceps': 0,
      'Triceps': 0,
      'Core': 0,
      'Kalça': 0,
    };

    // Egzersiz geçmişi boşsa dönüş
    if (_exerciseHistory.isEmpty) {
      print('No exercise history found');
      return muscleSets;
    }

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final allKnown = muscleGroupExercises.values.expand((l) => l).toList() + allExercises;

    // Tüm geçmiş kayıtlarını dolaş ve set başına kas dağılımı uygula
    for (final entry in _exerciseHistory.entries) {
      for (final h in entry.value) {
        if (h.date.isBefore(sevenDaysAgo)) continue;
        // Egzersizi bul (adıyla)
        Exercise? ex;
        try {
          ex = allKnown.firstWhere((e) => e.name.trim().toLowerCase() == h.exerciseName.trim().toLowerCase());
        } catch (_) {
          ex = null;
        }
        if (ex == null) continue;
        final ratios = ex.muscleGroupRatios;
        final int setCount = (h.setsCount > 0 ? h.setsCount : (h.sets.isNotEmpty ? h.sets.length : 1));
        if (ratios.isNotEmpty) {
          for (final muscle in ex.muscleGroups) {
            final ratio = ratios[muscle] ?? 1.0;
            final add = (setCount * ratio).round();
            muscleSets[muscle] = (muscleSets[muscle] ?? 0) + add;
          }
        } else {
          // Geriye uyumluluk: ana kasa tüm setleri, diğerlerine 1 ekle
          for (final muscle in ex.muscleGroups) {
            if (muscle == ex.mainMuscleGroup) {
              muscleSets[muscle] = (muscleSets[muscle] ?? 0) + setCount;
            } else {
              muscleSets[muscle] = (muscleSets[muscle] ?? 0) + 1;
            }
          }
        }
      }
    }

    print('Final muscle sets (from history): $muscleSets');
    return muscleSets;
  }

  List<String> get _undertrainedMuscles {
    // Eğer hiç veri yoksa boş liste döndür
    if (_completedWorkouts.isEmpty) {
      return [];
    }
    return _weeklyMuscleSets.entries
        .where((e) => e.value < 12) // 12'den küçük tüm değerler (0 dahil)
        .map((e) => e.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final muscleSets = _weeklyMuscleSets;
    // Haftalık benzersiz gün sayısını ve egzersiz oturumlarını, geçmişe göre hesapla
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    // Tarih -> (egzersiz adı -> kaydedilen set sayısı)
    final Map<String, Map<String, int>> dayExerciseSetCounts = {};
    for (final e in _exerciseHistory.entries) {
      for (final h in e.value) {
        if (h.date.isBefore(sevenDaysAgo)) continue;
        final dayKey = '${h.date.year}-${h.date.month.toString().padLeft(2, '0')}-${h.date.day.toString().padLeft(2, '0')}';
        final exKey = h.exerciseName.trim().toLowerCase();
        final sets = (h.setsCount > 0 ? h.setsCount : (h.sets.isNotEmpty ? h.sets.length : 1));
        dayExerciseSetCounts.putIfAbsent(dayKey, () => {});
        dayExerciseSetCounts[dayKey]![exKey] = (dayExerciseSetCounts[dayKey]![exKey] ?? 0) + sets;
      }
    }
    final totalDaysWithActivity = dayExerciseSetCounts.keys.length;

    // Egzersiz başına planlanan set sayısı (haftalık rutinlerden çıkarılır, en yüksek değer kullanılır)
    final Map<String, int> plannedSetsByExercise = {};
    for (final entries in _weeklyRoutine.values) {
      for (final r in entries) {
        final key = r.exercise.name.trim().toLowerCase();
        plannedSetsByExercise[key] = (plannedSetsByExercise[key] ?? 0).clamp(0, 999);
        final planned = (r.sets.isNotEmpty ? r.sets.length : r.setCount);
        if (planned > (plannedSetsByExercise[key] ?? 0)) {
          plannedSetsByExercise[key] = planned;
        }
      }
    }

    int totalExerciseSessions = 0;
    for (final day in dayExerciseSetCounts.values) {
      for (final entry in day.entries) {
        final planned = plannedSetsByExercise[entry.key] ?? entry.value; // plan bulunamazsa kaydedilen sete eşit sayarak 1 oturum kabul et
        if (planned <= 0) continue;
        totalExerciseSessions += (entry.value ~/ planned); // tam oturumları say
      }
    }
    final undertrainedMuscles = _undertrainedMuscles;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(globalLanguage == 'Türkçe' ? 'İstatistikler' : 'Statistics'),
        centerTitle: true,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Uyarı bölümü
            if (undertrainedMuscles.isNotEmpty && _completedWorkouts.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorTheme.warningLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColorTheme.warning),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning, color: AppColorTheme.warning),
                        const SizedBox(width: 8),
                        Text(
                          globalLanguage == 'Türkçe' ? 'Dikkat!' : 'Warning!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColorTheme.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      globalLanguage == 'Türkçe' 
                        ? 'Şu kas gruplarını haftada ${globalUserLevel?.minSets ?? 12} setten az çalıştırdın:\n${undertrainedMuscles.map((m) => getLocalizedMuscleGroup(m)).join(', ')}'
                        : 'You worked these muscle groups less than ${globalUserLevel?.minSets ?? 12} sets per week:\n${undertrainedMuscles.map((m) => getLocalizedMuscleGroup(m)).join(', ')}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Haftalık kas grubu set istatistikleri
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      globalLanguage == 'Türkçe' ? 'Haftalık Kas Grubu Set İstatistikleri' : 'Weekly Muscle Group Set Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Basit bar chart (fl_chart olmadan)
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        itemCount: muscleSets.length,
                        itemBuilder: (context, index) {
                          final entry = muscleSets.entries.elementAt(index);
                          Color barColor;
                          if (entry.value == 0) {
                            barColor = Colors.grey;
                          } else if (entry.value >= 12) {
                            barColor = Colors.green;
                          } else {
                            barColor = Colors.red;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    getLocalizedMuscleGroup(entry.key),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 16,
                                    width: (entry.value / 20 * 150).clamp(0, 150),
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${entry.value}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Renk açıklaması
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: AppColorTheme.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              globalLanguage == 'Türkçe' ? '12+ set' : '12+ set',
                              style: TextStyle(fontSize: context.responsiveFontSize - 2),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: AppColorTheme.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              globalLanguage == 'Türkçe' ? '1-11 set' : '1-11 set',
                              style: TextStyle(fontSize: context.responsiveFontSize - 2),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: AppColorTheme.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '0 set',
                              style: TextStyle(fontSize: context.responsiveFontSize - 2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Genel istatistikler
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      globalLanguage == 'Türkçe' ? 'Genel İstatistikler' : 'General Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            globalLanguage == 'Türkçe' ? 'Toplam Gün' : 'Total Days',
                            totalDaysWithActivity.toString(),
                            Icons.calendar_today,
                            AppColorTheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            globalLanguage == 'Türkçe' ? 'Toplam Egzersiz' : 'Total Exercises',
                            totalExerciseSessions.toString(),
                            Icons.fitness_center,
                            AppColorTheme.success,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            globalLanguage == 'Türkçe' ? 'Toplam Set' : 'Total Sets',
                            muscleSets.values.fold(0, (sum, count) => sum + count).toString(),
                            Icons.repeat,
                            AppColorTheme.warning,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            globalLanguage == 'Türkçe' ? 'Ortalama Set/Gün' : 'Average Sets/Day',
                            totalDaysWithActivity > 0
                              ? (muscleSets.values.fold(0, (sum, count) => sum + count) / totalDaysWithActivity).round().toString()
                              : '0',
                            Icons.analytics,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            

          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dataClearedSubscription?.cancel();
    super.dispose();
  }
}

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  StreamSubscription? _workoutCompletedSubscription;
  String? _activeDay;
  // Sadece kullanıcı tarafından eklenen günler
  Map<String, List<RoutineEntry>> _weeklyRoutine = {};
  // Her gün için son tamamlanma tarihi
  Map<String, DateTime> _lastCompleted = {};
  // Sadece tamamlanan antrenmanlar (istatistik için)
  Map<String, List<RoutineEntry>> _completedWorkouts = {};
  
  bool _warningShown = false;
  // Günlerin sırası (görüntüleme sırası)
  List<String> _dayOrder = [];
  // Gün adı değiştirildiğinde orijinal ismi korumak için
  Map<String, String> _originalDayNames = {};
  
  // Dinamik sporcu seçimi için
  late AthleteQuote _currentAthlete;

  // Cache - widget yeniden oluşturulduğunda korunur
  // Map<String, List<RoutineEntry>> _cachedWeeklyRoutine = {};
  // List<String> _cachedDayOrder = [];
  // Map<String, String> _cachedOriginalDayNames = {};
  // Map<String, DateTime> _cachedLastCompleted = {};
  // Map<String, List<RoutineEntry>> _cachedCompletedWorkouts = {};
  Map<String, List<ExerciseHistory>> _cachedExerciseHistory = {};
  
  @override
  void initState() {
    super.initState();
    // Rastgele sporcu seç
    _currentAthlete = athleteQuotes[DateTime.now().millisecondsSinceEpoch % athleteQuotes.length];
    
    // Verileri yükle
    _loadData();

    // Devam pop-up'ını kapat: Yalnızca uygulama yeniden açıldığında devam kararı kullanıcıya bırakılacak.
    // Bu blok devre dışı bırakıldı.

    // Antrenman tamamlandığında sadece o günün son tamamlanma tarihini güncelle
    _workoutCompletedSubscription = eventBus.on<WorkoutCompletedEvent>().listen((event) async {
      final today = DateTime(event.date.year, event.date.month, event.date.day);
      // Hangi gün tamamlandı: event'ten gelen dayName (Detail'dan) veya _activeDay
      final dayName = event.dayName ?? _activeDay;
      if (dayName != null && dayName.isNotEmpty) {
        setState(() {
          _lastCompleted[dayName] = today;
        });
        // Detail ekranı tamamlanan antrenmanı SharedPreferences'a yazdı; güncel listeyi çek
        final updatedCompleted = await DataManager.getCompletedWorkouts();
        setState(() {
          _completedWorkouts = updatedCompleted;
          globalCompletedWorkouts = Map<String, List<RoutineEntry>>.from(_completedWorkouts);
        });
        // Sadece tamamlanan antrenman ve lastCompleted kaydet; egzersiz geçmişine DOKUNMA
        await _saveCompletedWorkoutStateOnly();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      // SharedPreferences'dan verileri yükle
      final savedRoutine = await DataManager.getWeeklyRoutine();
      final savedCompleted = await DataManager.getCompletedWorkouts();
      final savedHistory = await DataManager.getExerciseHistory();
      final savedLastCompleted = await DataManager.getLastCompletedDates();
      final savedOriginalDayNames = await DataManager.getOriginalDayNames();
      
      // Global veri temizleme flag kontrolü
      if (globalIsDataCleared) {
        print('DEBUG: _loadData - Global veri temizleme flag aktif, cache boş bırakılıyor');
        setState(() {
          _weeklyRoutine = savedRoutine;
          _completedWorkouts = savedCompleted;
          _cachedExerciseHistory = {}; // Global flag aktifse boş bırak
          _lastCompleted = savedLastCompleted;
          globalCompletedWorkouts = Map<String, List<RoutineEntry>>.from(_completedWorkouts);
          _dayOrder = _weeklyRoutine.keys.toList();
          if (savedOriginalDayNames.isNotEmpty) {
            _originalDayNames = Map<String, String>.from(savedOriginalDayNames);
          } else {
            _originalDayNames = Map.fromEntries(_dayOrder.map((day) => MapEntry(day, day)));
          }
          if (_dayOrder.isEmpty) {
            _dayOrder = [];
            _originalDayNames = {};
          }
        });
        print('DEBUG: _loadData - Global flag aktif, cache boş bırakıldı');
        return;
      }
      
      // Cache boş olabilir; geçmiş verileri hiçbir koşulda otomatik temizleme.
      if (_cachedExerciseHistory.isEmpty && savedHistory.isNotEmpty) {
        setState(() {
          _weeklyRoutine = savedRoutine;
          _completedWorkouts = savedCompleted;
          _cachedExerciseHistory = savedHistory; // eldeki geçmişi kullan
          _lastCompleted = savedLastCompleted;
          globalCompletedWorkouts = Map<String, List<RoutineEntry>>.from(_completedWorkouts);
          _dayOrder = _weeklyRoutine.keys.toList();
          if (savedOriginalDayNames.isNotEmpty) {
            _originalDayNames = Map<String, String>.from(savedOriginalDayNames);
          } else {
            _originalDayNames = Map.fromEntries(_dayOrder.map((day) => MapEntry(day, day)));
          }
        });
        return;
      }
      
      setState(() {
        _weeklyRoutine = savedRoutine;
        _completedWorkouts = savedCompleted;
        // Egzersiz geçmişini sadece veri varsa yükle, yoksa boş bırak
        _cachedExerciseHistory = savedHistory.isNotEmpty ? savedHistory : {};
        _lastCompleted = savedLastCompleted;
        globalCompletedWorkouts = Map<String, List<RoutineEntry>>.from(_completedWorkouts);
        _dayOrder = _weeklyRoutine.keys.toList();
        // Eğer kaydedilmiş orijinal gün isimleri varsa onları kullan, yoksa gün ismiyle başlat
        if (savedOriginalDayNames.isNotEmpty) {
          _originalDayNames = Map<String, String>.from(savedOriginalDayNames);
        } else {
          _originalDayNames = Map.fromEntries(_dayOrder.map((day) => MapEntry(day, day)));
        }
        if (_dayOrder.isEmpty) {
          _dayOrder = [];
          _originalDayNames = {};
        }
      });
      print('DEBUG: _loadData - Egzersiz geçmişi yüklendi: ${_cachedExerciseHistory.length} egzersiz');
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _weeklyRoutine = {};
        _completedWorkouts = {};
        _cachedExerciseHistory = {};
        _lastCompleted = {};
        _dayOrder = [];
        _originalDayNames = {};
      });
    }
  }

  // Tüm verileri temizle (test için)
  Future<void> _clearAllData() async {
    try {
      print('Veri temizleme başladı...');
      
      // Önce tüm cache'leri temizle
      setState(() {
        _weeklyRoutine = {};
        _completedWorkouts = {};
        _cachedExerciseHistory = {};
        _lastCompleted = {};
        _dayOrder = [];
        _originalDayNames = {};
        globalCompletedWorkouts = {};
      });
      
      // Global değişkenleri temizle
      globalCompletedWorkouts = {};
      
      // Tüm cache'leri manuel olarak sıfırla
      _cachedExerciseHistory.clear();
      _weeklyRoutine.clear();
      _completedWorkouts.clear();
      _lastCompleted.clear();
      _dayOrder.clear();
      _originalDayNames.clear();
      
      // Cache'lerin temizlendiğini doğrula
      print('Cache temizleme kontrolü:');
      print('_weeklyRoutine: ${_weeklyRoutine.length}');
      print('_completedWorkouts: ${_completedWorkouts.length}');
      print('_cachedExerciseHistory: ${_cachedExerciseHistory.length}');
      print('_lastCompleted: ${_lastCompleted.length}');
      print('globalCompletedWorkouts: ${globalCompletedWorkouts.length}');
      
      // SharedPreferences'ı temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // SharedPreferences temizleme sonrası kontrol
      final remainingKeys = prefs.getKeys();
      print('SharedPreferences temizleme sonrası kalan anahtarlar: $remainingKeys');
      
      // Egzersiz geçmişini tamamen temizle
      await DataManager.clearAllExerciseHistory();
      
      // Orijinal gün isimlerini temizle
      await DataManager.saveOriginalDayNames({});
      
      // Tüm anahtarları manuel olarak temizle
      final finalRemainingKeys = prefs.getKeys();
      print('Manuel temizleme öncesi anahtarlar: $finalRemainingKeys');
      
      for (final key in finalRemainingKeys) {
        await prefs.remove(key);
        print('Anahtar temizlendi: $key');
      }
      
      // Son kontrol
      final finalKeys = prefs.getKeys();
      print('Final SharedPreferences anahtarları: $finalKeys');
      
      // Eğer hala anahtar varsa, zorla temizle
      if (finalKeys.isNotEmpty) {
        print('Hala anahtar var, zorla temizleniyor...');
        await prefs.clear();
        final forcedKeys = prefs.getKeys();
        print('Zorla temizleme sonrası anahtarlar: $forcedKeys');
      }
      
      // Global flag'i aktif et
      globalIsDataCleared = true;
      print('DEBUG: _clearAllData - Global veri temizleme flag\'i aktif edildi');
      
      // EventBus ile tüm ekranlara veri temizlendiğini bildir
      eventBus.fire(DataClearedEvent(isGlobalClear: true));
      
      print('Tüm veriler başarıyla temizlendi');
      
      // Kullanıcıya bilgi ver (sessiz)
      // Gereksiz yeşil popup kaldırıldı
      
      // UI'ı yenile
      setState(() {});
      
      // Cache'lerin temizlendiğini tekrar kontrol et
      print('Veri temizleme sonrası cache kontrolü:');
      print('_weeklyRoutine: ${_weeklyRoutine.length}');
      print('_completedWorkouts: ${_completedWorkouts.length}');
      print('_cachedExerciseHistory: ${_cachedExerciseHistory.length}');
      print('_lastCompleted: ${_lastCompleted.length}');
      print('globalCompletedWorkouts: ${globalCompletedWorkouts.length}');
      
      // Global state'i temizle
      globalCompletedWorkouts = {};
      
      // Cache'lerin temizlendiğini son kez kontrol et
      print('Veri temizleme tamamlandı - Final cache kontrolü:');
      print('_cachedExerciseHistory: ${_cachedExerciseHistory.length}');
      print('_weeklyRoutine: ${_weeklyRoutine.length}');
      print('_completedWorkouts: ${_completedWorkouts.length}');
      print('_lastCompleted: ${_lastCompleted.length}');
      
      // Veri temizleme sonrası ek kontroller
      print('Veri temizleme sonrası ek kontroller:');
      
      // SharedPreferences'ı tekrar kontrol et
      final finalCheckPrefs = await SharedPreferences.getInstance();
      final finalCheckKeys = finalCheckPrefs.getKeys();
      print('Final SharedPreferences kontrol: $finalCheckKeys');
      
      // Egzersiz geçmişini tekrar kontrol et
      final finalCheckHistory = await DataManager.getExerciseHistory();
      print('Final egzersiz geçmişi kontrol: ${finalCheckHistory.length} egzersiz');
      
      if (finalCheckHistory.isNotEmpty) {
        print('HATA: Egzersiz geçmişi hala mevcut!');
        for (final entry in finalCheckHistory.entries) {
          print('  ${entry.key}: ${entry.value.length} kayıt');
        }
      } else {
        print('✅ Egzersiz geçmişi başarıyla temizlendi');
      }
      
    } catch (e) {
      print('Veri temizleme hatası: $e');
    }
  }

  @override
  void dispose() {
    _workoutCompletedSubscription?.cancel();
    super.dispose();
  }

  /// WorkoutCompletedEvent (Detail.dart'tan tamamlama) sonrası çağrılır.
  /// Sadece completed_workouts ve last_completed kaydeder; exercise_history'ye dokunmaz.
  Future<void> _saveCompletedWorkoutStateOnly() async {
    try {
      await DataManager.saveCompletedWorkouts(_completedWorkouts);
      await DataManager.saveLastCompletedDates(_lastCompleted);
      globalCompletedWorkouts = Map<String, List<RoutineEntry>>.from(_completedWorkouts);
      print('Tamamlanan antrenman state kaydedildi (egzersiz geçmişi korundu)');
    } catch (e) {
      print('Tamamlanan antrenman state kaydetme hatası: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      await DataManager.saveWeeklyRoutine(_weeklyRoutine);
      await DataManager.saveCompletedWorkouts(_completedWorkouts);
      
      // Sadece cache'deki veriyi kaydet, SharedPreferences'dan eski veri çekme
      if (_cachedExerciseHistory.isNotEmpty) {
        await DataManager.saveExerciseHistory(_cachedExerciseHistory);
        print('_saveData - Cache\'deki egzersiz geçmişi kaydedildi: $_cachedExerciseHistory');
      }
      
      await DataManager.saveLastCompletedDates(_lastCompleted);
      
      // Global değişkeni güncelle
      globalCompletedWorkouts = Map<String, List<RoutineEntry>>.from(_completedWorkouts);
      
      print('Veriler başarıyla kaydedildi');
    } catch (e) {
      print('Veri kaydetme hatası: $e');
    }
  }

  // Egzersiz geçmişini kaydet
  void saveExerciseHistory(String exerciseName, double weight, int reps, int sets) {
    final history = ExerciseHistory(
      exerciseName: exerciseName,
      date: DateTime.now(),
      weight: weight,
      reps: reps,
      setsCount: sets,
      sets: List.generate(sets, (i) => SetEntry(targetReps: reps, targetWeight: weight)),
    );
    
    if (!_cachedExerciseHistory.containsKey(exerciseName)) {
      _cachedExerciseHistory[exerciseName] = [];
    }
    _cachedExerciseHistory[exerciseName]!.add(history);
    
    // Son 10 kaydı tut (eski kayıtları sil)
    if (_cachedExerciseHistory[exerciseName]!.length > 10) {
      _cachedExerciseHistory[exerciseName] = _cachedExerciseHistory[exerciseName]!.skip(
        _cachedExerciseHistory[exerciseName]!.length - 10
      ).toList();
    }
  }

  // Egzersiz geçmişini al
  List<ExerciseHistory> getExerciseHistory(String exerciseName) {
    return _cachedExerciseHistory[exerciseName] ?? [];
  }

  // Haftalık kas grubu toplam setleri (cache'lenmiş)
  Map<String, int>? _cachedMuscleSets;
  Map<String, int> get _weeklyMuscleSets {
    // Cache kontrolü
    if (_cachedMuscleSets != null) {
      return _cachedMuscleSets!;
    }
    final Map<String, int> muscleSets = {
      'Bacak': 0,
      'Kalça': 0,
      'Core': 0,
      'Göğüs': 0,
      'Triceps': 0,
      'Omuz': 0,
      'Sırt': 0,
      'Biceps': 0,
      'Bilinmeyen': 0,
    };
    
    // Debug için print ekleyelim
    print('DEBUG: StatisticsScreen - Hesaplama başlıyor');
    
    for (var entries in _completedWorkouts.values) {
      for (var entry in entries) {
        final ratios = entry.exercise.muscleGroupRatios;
        final int plannedSetCount = entry.sets.isNotEmpty ? entry.sets.length : entry.setCount;
        print('DEBUG: ${entry.exercise.name} - $plannedSetCount set');
        
        if (ratios.isNotEmpty) {
          for (var muscle in entry.exercise.muscleGroups) {
            final ratio = ratios[muscle] ?? 1.0;
            final int setCount = (plannedSetCount * ratio).round();
            print('DEBUG: $muscle için $setCount set eklendi (oran: $ratio)');
            muscleSets[muscle] = (muscleSets[muscle] ?? 0) + setCount;
          }
        } else {
          for (var muscle in entry.exercise.muscleGroups) {
            if (muscle == entry.exercise.mainMuscleGroup) {
              muscleSets[muscle] = (muscleSets[muscle] ?? 0) + plannedSetCount;
            } else {
              muscleSets[muscle] = (muscleSets[muscle] ?? 0) + 1;
            }
          }
        }
      }
    }
    
    print('DEBUG: Final muscle sets: $muscleSets');
    _cachedMuscleSets = muscleSets;
    return muscleSets;
  }

  List<String> get _undertrainedMuscles {
    // Kullanıcı seviyesine göre minimum set sayısını belirle
    int minSets = 12; // Varsayılan değer
    if (globalUserLevel != null) {
      minSets = globalUserLevel!.minSets;
    }
    
    return _weeklyMuscleSets.entries
        .where((e) => e.value < minSets) // Kullanıcı seviyesine göre minimum set
        .map((e) => e.key)
        .toList();
  }

  void _openDayDetail(String day) async {
    _activeDay = day;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => DayDetailScreen(
          day: day,
          entries: List<RoutineEntry>.from(_weeklyRoutine[day]!),
          lastCompleted: _lastCompleted[day],
        ),
      ),
    );
    _activeDay = null;
    if (result != null) {
      final returnedEntries = List<RoutineEntry>.from(result['entries'] as List<RoutineEntry>);
      setState(() {
        if (result['completed'] == true) {
          // Tamamlanan antrenmanı istatistikler için sakla
          _lastCompleted[day] = DateTime.now();
          _completedWorkouts[day] = List<RoutineEntry>.from(returnedEntries);
          // Sonraki oturum için günü sıfırlanmış setlerle hazırla
          final resetEntries = returnedEntries.map((e) => RoutineEntry(
            exercise: e.exercise,
            setCount: e.setCount,
            sets: e.sets.map((s) => s.copyWith(
              actualReps: s.targetReps,
              actualWeight: s.targetWeight,
              isCompleted: false,
            )).toList(),
          )).toList();
          _weeklyRoutine[day] = resetEntries;
          // Global değişkeni güncelle
          globalCompletedWorkouts = Map<String, List<RoutineEntry>>.from(_completedWorkouts);
          // Sadece haftanın son günü antrenmanı bitirildiğinde uyarı göster
          if (_isLastDayOfWeek(day)) {
            _showWarningIfNeeded();
          }
        } else {
          // Normal kaydetme
          _weeklyRoutine[day] = returnedEntries;
        }
      });
      // Her durumda verileri kaydet
      _cachedMuscleSets = null; // Cache'i temizle
      await _saveData();
      // İstatistik ekranının güncel veriyi göstermesi için event ateşle (DayDetailScreen'den tamamlandığında)
      if (result != null && result['completed'] == true) {
        eventBus.fire(WorkoutCompletedEvent(date: DateTime.now(), dayName: day));
      }
    }
  }
  bool _isLastDayOfWeek(String currentDay) {
    // Eklenen günlerin son günü mü kontrol et
    final addedDays = _weeklyRoutine.keys.toList();
    if (addedDays.isEmpty) return false;
    
    // Haftanın günlerini sırala ve son günü bul
    final sortedDays = addedDays.where((day) => weekDays.contains(day)).toList();
    sortedDays.sort((a, b) => weekDays.indexOf(a).compareTo(weekDays.indexOf(b)));
    
    return sortedDays.isNotEmpty && sortedDays.last == currentDay;
  }
  
  void _showWarningIfNeeded() {
    final undertrained = _undertrainedMuscles;
    if (undertrained.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWarningDialog(undertrained);
      });
    }
  }

  // Cache'i temizle (test için)
  void _clearCache() {
    setState(() {
      // _cachedWeeklyRoutine.clear();
      // _cachedDayOrder.clear();
      // _cachedOriginalDayNames.clear();
      // _cachedLastCompleted.clear();
      // _cachedCompletedWorkouts.clear();
      _cachedMuscleSets = null; // Muscle sets cache'ini temizle
      _weeklyRoutine.clear();
      _dayOrder.clear();
      _originalDayNames.clear();
      _lastCompleted.clear();
      _completedWorkouts.clear();
    });
  }



  void _addDay() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(globalLanguage == 'Türkçe' ? 'Gün Ekle' : 'Add Day'),
        children: weekDays
            .where((d) => !_weeklyRoutine.containsKey(d))
            .map((d) => SimpleDialogOption(
                  child: Text(getLocalizedDayName(d)),
                  onPressed: () => Navigator.pop(context, d),
                ))
            .toList(),
      ),
    );
    if (selected != null && !_weeklyRoutine.containsKey(selected)) {
      setState(() {
        _weeklyRoutine[selected] = [];
        _dayOrder.add(selected);
        _originalDayNames[selected] = selected;
      });
      await DataManager.saveOriginalDayNames(_originalDayNames);
      await _saveData();
    }
  }

  void _removeDay(String day) async {
    setState(() {
      _weeklyRoutine.remove(day);
      _dayOrder.remove(day);
      _originalDayNames.remove(day);
    });
    await DataManager.saveOriginalDayNames(_originalDayNames);
    await _saveData();
  }
  void _moveDayUp(int index) {
    if (index > 0) {
      setState(() {
        final day = _dayOrder[index];
        _dayOrder.removeAt(index);
        _dayOrder.insert(index - 1, day);
      });
    }
  }

  void _moveDayDown(int index) {
    if (index < _dayOrder.length - 1) {
      setState(() {
        final day = _dayOrder[index];
        _dayOrder.removeAt(index);
        _dayOrder.insert(index + 1, day);
      });
    }
  }

  void _editDayName(String day) async {
    final TextEditingController controller = TextEditingController(text: day);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(globalLanguage == 'Türkçe' ? 'Gün Adını Düzenle' : 'Edit Day Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: globalLanguage == 'Türkçe' ? 'Gün Adı' : 'Day Name',
            hintText: globalLanguage == 'Türkçe' ? 'Örn: Pazartesi Göğüs' : 'Ex: Monday Chest',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(globalLanguage == 'Türkçe' ? 'İptal' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(globalLanguage == 'Türkçe' ? 'Kaydet' : 'Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        // Gün adını değiştir
        final entries = _weeklyRoutine[day];
        final lastCompleted = _lastCompleted[day];
        final completedWorkouts = _completedWorkouts[day];
        final originalName = _originalDayNames[day];
        final currentIndex = _dayOrder.indexOf(day);
        _weeklyRoutine.remove(day);
        _lastCompleted.remove(day);
        _completedWorkouts.remove(day);
        _originalDayNames.remove(day);
        _weeklyRoutine[result] = entries ?? [];
        if (lastCompleted != null) _lastCompleted[result] = lastCompleted;
        if (completedWorkouts != null) _completedWorkouts[result] = completedWorkouts;
        if (currentIndex >= 0 && currentIndex < _dayOrder.length) {
          _dayOrder[currentIndex] = result;
        }
        _originalDayNames[result] = originalName ?? day;
      });
      await DataManager.saveOriginalDayNames(_originalDayNames);
      await _saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final muscleSets = _weeklyMuscleSets;
    final undertrainedMuscles = _undertrainedMuscles;
    final completedWorkouts = _completedWorkouts;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, color: Colors.black, size: context.responsiveIconSize),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                globalLanguage == 'Türkçe' ? 'Kaslarını değil, planını inşa et!' : 'Build your plan, not just muscles!',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: context.responsiveTitleFontSize - 4,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Tüm verileri temizle butonu
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Verileri Temizle'),
                  content: Text('Tüm veriler silinecek. Devam etmek istiyor musunuz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _clearAllData();
                        Navigator.pop(context);
                        
                        // Kullanıcıya bilgi ver
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              globalLanguage == 'Türkçe' 
                                ? 'Tüm veriler temizlendi. Yeni egzersiz ekleyebilirsiniz.' 
                                : 'All data cleared. You can add new exercises.',
                            ),
                            backgroundColor: AppColorTheme.success,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      child: Text('Temizle'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Tüm Verileri Temizle',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dinamik sporcu banner'ı
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Fitness görseli arka planda
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          // Arka plan görseli
                          Positioned.fill(
                            child: Image.asset(
                              'assets/fitness_background.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Koyu overlay (metinlerin okunabilirliği için)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Metin overlay'i - şeffaf
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 32,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports, color: Colors.white, size: context.responsiveIconSize),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _currentAthlete.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.responsiveTitleFontSize,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _currentAthlete.sport,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.responsiveFontSize - 2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '"${globalLanguage == 'Türkçe' ? _currentAthlete.quoteTurkish : _currentAthlete.quote}"',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.responsiveFontSize - 1,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Başlık ve gün ekle butonu
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF60A5FA).withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF13097A).withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                                            Icon(Icons.calendar_today, color: Color(0xFF60A5FA), size: 20),
                      SizedBox(width: 8),
                                              Text(
                          globalLanguage == 'Türkçe' ? 'Haftalık Rutin' : 'Weekly Routine',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: context.responsiveTitleFontSize,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _addDay,
                      icon: Icon(Icons.add_circle, color: Colors.white),
                      label: Text(globalLanguage == 'Türkçe' ? 'Yeni Gün Ekle' : 'Add New Day'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF60A5FA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                        shadowColor: Color(0xFF60A5FA).withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Günler listesi
            if (_weeklyRoutine.isEmpty)
              Container(
                height: 300,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(32),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF9F871).withOpacity(0.15),
                          Color(0xFFFFB447).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFF60A5FA).withOpacity(0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF13097A).withOpacity(0.08),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 64,
                          color: Color(0xFF60A5FA),
                        ),
                        SizedBox(height: 16),
                        Text(
                          globalLanguage == 'Türkçe' ? 'Henüz gün eklemedin' : 'No days added yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          globalLanguage == 'Türkçe' ? 'Yukarıdaki butona tıklayarak ilk gününü ekle' : 'Click the button above to add your first day',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF60A5FA),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _dayOrder.removeAt(oldIndex);
                    _dayOrder.insert(newIndex, item);
                  });
                },
                children: [
                  for (int i = 0; i < _dayOrder.length; i++)
                    Container(
                      key: ValueKey('day_${_dayOrder[i]}'),
                      margin: EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _openDayDetail(_dayOrder[i]),
                          child: Padding(
                            padding: EdgeInsets.all(context.responsivePadding),
                            child: Row(
                              children: [
                                Container(
                                  width: context.responsiveIconSize * 2.5,
                                  height: context.responsiveIconSize * 2.5,
                                  decoration: BoxDecoration(
                                    color: AppColorTheme.weekDayColors[_originalDayNames[_dayOrder[i]] ?? _dayOrder[i]] ?? AppColorTheme.primary,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (AppColorTheme.weekDayColors[_originalDayNames[_dayOrder[i]] ?? _dayOrder[i]] ?? AppColorTheme.primary).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      weekDayShort[_originalDayNames[_dayOrder[i]] ?? _dayOrder[i]] ?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.responsiveFontSize,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: context.responsivePadding),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              getLocalizedDayName(_dayOrder[i]),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: context.responsiveTitleFontSize,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ),
                                          // Son çalışma tarihi bilgisi
                                          Builder(
                                            builder: (context) {
                                              final lastCompleted = _lastCompleted[_dayOrder[i]];
                                              String? completedText;
                                              if (lastCompleted != null) {
                                                final now = DateTime.now();
                                                final diff = now.difference(lastCompleted).inDays;
                                                completedText = '-${diff}g';
                                              }
                                              return completedText != null
                                                  ? Container(
                                                      margin: EdgeInsets.only(left: 8),
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: Colors.green),
                                                      ),
                                                      child: Text(
                                                        completedText,
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox.shrink();
                                            },
                                          ),
                                          // Gün ismini düzenle butonu
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                                            tooltip: globalLanguage == 'Türkçe' ? 'Gün Adını Düzenle' : 'Edit Day Name',
                                            onPressed: () => _editDayName(_dayOrder[i]),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        (_weeklyRoutine[_dayOrder[i]]?.length ?? 0).toString() +
                                          (globalLanguage == 'Türkçe' ? ' egzersiz' : ' exercises'),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: context.responsiveFontSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.drag_handle, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),           
            const SizedBox(height: 24),
            
            // İstatistik butonu

            
            const SizedBox(height: 32), // Alt boşluk
          ],
        ),
      ),


    );
  }

  

  void _showWarningDialog(List<String> undertrained) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Uyarı'),
        content: Text(
          'Şu kas gruplarını haftada 12 setten az çalıştırdın:\n\n${undertrained.join(', ')}\n\nGenel fitness prensiplerine göre her ana kas grubunu haftada en az 12 set çalıştırmalısın!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

// Kas grubu ikonları (emoji)
const Map<String, String> muscleGroupIcons = {
  'Göğüs': '🏋️‍♂️',
  'Omuz': '💪',
  'Bacak': '🦵',
  'Sırt': '🏋️',
  'Biceps': '💪',
  'Triceps': '🤜',
  'Core': '💪',
  'Kalça': '🍑',
};

String? assetForExercise(String exerciseName) {
  // Normalize to handle Turkish 'İ' → 'i' and remove combining dot
  final name = exerciseName
      .toLowerCase()
      .trim()
      .replaceAll('i̇', 'i')
      .replaceAll('ı', 'i');
  // Common variants
  if (name.contains('incline dumbbell press') || name.contains('incline dumbell press')) {
    // No dedicated asset found; use dumbbell bench press icon as a close match
    return 'assets/dumbellBenchPress.png';
  }
  if ((name.contains('incline') || name.contains('inchline')) && name.contains('bench press')) {
    return 'assets/inchlineBenchPress.png';
  }
  if (name.contains('dumbbell bench press') || name.contains('dumbell bench press')) {
    return 'assets/dumbellBenchPress.png';
  }
  if (name.contains('dips')) return 'assets/dips.png';
  if (name.contains('push-up') || name.contains('push up') || name.contains('pushup')) return 'assets/push-up.png';
  if ((name.contains('lateral raise') || name.contains('side lateral')) && (name.contains('dumbell') || name.contains('dumbbell'))) return 'assets/dumbell-lateral-raise.png';
  if (name.contains('bench fly') || ((name.contains('fly') || name.contains('flies')) && name.contains('bench')) || ((name.contains('dumbell') || name.contains('dumbbell')) && name.contains('fly'))) return 'assets/dumbell-bench-fly.png';
  if (name.contains('squat') || name.contains('back squat') || name.contains('front squat')) return 'assets/squat.png';
  if (name.contains('walking lunge') || name.contains('walking lunges') || name.contains('lunges (walking)')) return 'assets/Walking Lunge.png';
  if (name.contains('step up') || name.contains('step-up')) return 'assets/Step Up.png';
  if (name.contains('lunges static') || name.contains('static lunge') || name.contains('static lunges') || name.contains('lunges (static)')) return 'assets/Lunges static.png';
  if (name.contains('leg press')) return 'assets/legPress.png';
  if (name.contains('deadlift') || name.contains('sumo deadlift') || name.contains('romanian deadlift') || name.contains('trap bar deadlift')) return 'assets/deadlift.png';
  if (name.contains('overhead press') || name.contains('military press') || name.contains('shoulder press') || name.contains('push press') || name.contains('arnold press')) return 'assets/overheadPress.png';
  if (name.contains('barbell biceps curl') || name.contains('biceps curl')) return 'assets/barbell-biceps-curl.png';
  if (name.contains('dumbbell curl') || name.contains('dumbell curl') || name.contains('concentration curl') || name.contains('hammer curl') || name.contains('scott curl') || name.contains('machine curl')) return 'assets/barbell-biceps-curl.png';
  if (name.contains('hip thrust') || name.contains('hip trust')) return 'assets/hipTrust.png';
  if (name.contains('glute bridge') || name.contains('glute bridges')) return 'assets/hipTrust.png';
  if (name.contains('good morning') || name.contains('good-morning')) return 'assets/hipTrust.png';
  if (name.contains('kettlebell swing') || name.contains('kettle bell swing')) return 'assets/hipTrust.png';
  if ((name.contains('reverse') && (name.contains('machine') || name.contains('pec deck') || name.contains('fly'))) || name.contains('rear delt fly')) return 'assets/reverse-machine-flys.png';
  if (name.contains('pull-up') || name.contains('pull up') || name.contains('pullup') || name.contains('chin-up') || name.contains('chin up') || name.contains('chinup')) return 'assets/Pull-up.png';
  if (name.contains('lat pulldown') || name.contains('lat-pulldown') || name.contains('lat pull-down') || name.contains('lat pull down') || name.contains('pulldown')) return 'assets/lat-pulldown.jpg';
  if (name.contains('face pull') || name.contains('facepull')) return 'assets/facepull.png';
  if ((name.contains('overhead') && (name.contains('pulley') || name.contains('cable'))) && name.contains('triceps')) return 'assets/overhead-pulley-triceps.png';
  if ((name.contains('pulley machine') || (name.contains('pulley') && name.contains('machine'))) && name.contains('triceps')) return 'assets/pulley-machine-triceps.png';
  if ((name.contains('single-arm') || name.contains('single arm')) && (name.contains('pulley') || name.contains('cable')) && (name.contains('raise') || name.contains('lateral'))) return 'assets/single-arm-pulley-machine-raise.png';
  if (name.contains('t-bar row') || name.contains('t bar row') || name.contains('tbar row')) return 'assets/t-bar-row.png';
  if (name.contains('pendlay row')) return 'assets/barbell-row.png';
  if (name.contains('machine row')) return 'assets/smith-machine-row.png';
  if (name.contains('barbell row')) return 'assets/barbell-row.png';
  if (name.contains('dumbbell row') || name.contains('dumbell row')) return 'assets/dumbell row.png';
  if (name.contains('smith machine row') || name.contains('smith-machine row') || name.contains('smith row')) return 'assets/smith-machine-row.png';
  if (name.contains('upright row')) return 'assets/barbell-upright-row.png';
  if (name.contains('behind the neck press') || name.contains('behind-the-neck press') || name.contains('btn press') || (name.contains('behind') && name.contains('neck') && name.contains('press'))) return 'assets/behind-the-neck-press.png';
  if (name.contains('plank')) return 'assets/plank.png';
  if (name.contains('bench press')) return 'assets/benchPress.png';
  if (name.contains('close grip bench') || name.contains('close-grip bench')) return 'assets/close-grip-bench-press.jpg';
  if (name.contains('ez-bar french press') || name.contains('ez bar french press') || name.contains('french press')) return 'assets/ez-bar-french-press.jpg';
  if (name.contains('leg raise') || name.contains('leg raises')) return 'assets/leg-raise.jpg';
  if (name.contains('crunches') || name.contains('crunches')) return 'assets/crunches.png';
  if (name.contains("farmer's walk") || name.contains('farmers walk') || name.contains('farmer walk')) return 'assets/crunches.png';
  if (name.contains('bear crawl')) return 'assets/crunches.png';
  if (name.contains('russian twist')) return 'assets/crunches.png';
  if (name.contains('turkish get-up') || name.contains('turkish-get-up') || name.contains('turkish get up')) return 'assets/turkish-get-up.png';
  return null;
}

// Kas grubu ve egzersiz eşlemesi
const Map<String, List<Exercise>> muscleGroupExercises = {
  'Göğüs': [
    Exercise(
      name: 'Barbell Bench Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.5, 'Omuz': 0.4},
    ),
    Exercise(
      name: 'Incline Barbell Bench Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.5, 'Omuz': 0.4},
    ),
    Exercise(
      name: 'Dumbbell Bench Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.4, 'Omuz': 0.4},
    ),
    Exercise(
      name: 'Incline Dumbbell Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.4, 'Omuz': 0.4},
    ),
    Exercise(
      name: 'Close-Grip Bench Press', 
      muscleGroups: ['Triceps', 'Göğüs'], 
      mainMuscleGroup: 'Triceps',
      muscleGroupRatios: {'Göğüs': 0.3},
    ),
    Exercise(
      name: 'Dips (Chest Version)', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.6, 'Omuz': 0.4},
    ),
    Exercise(
      name: 'Push-Up', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz', 'Core'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.4, 'Omuz': 0.4, 'Core': 0.3},
    ),
    Exercise(
      name: 'Smith Machine Bench Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.5, 'Omuz': 0.4},
    ),
    Exercise(
      name: 'Dumbbell Bench Fly', 
      muscleGroups: ['Göğüs'], 
      mainMuscleGroup: 'Göğüs',
    ),
  ],
  'Omuz': [
    Exercise(
      name: 'Overhead Barbell Press (Military Press)', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Dumbbell Shoulder Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Push Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Arnold Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Behind-the-Neck Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Barbell Upright Row', 
      muscleGroups: ['Omuz', 'Sırt'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Sırt': 0.3},
    ),
    Exercise(
      name: 'Dumbbell Lateral Raise', 
      muscleGroups: ['Omuz'], 
      mainMuscleGroup: 'Omuz',
    ),
    Exercise(
      name: 'Facepull', 
      muscleGroups: ['Omuz', 'Sırt'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Sırt': 0.3},
    ),
    Exercise(
      name: 'Machine Shoulder Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Smith Machine Shoulder Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Reverse Machine Flys', 
      muscleGroups: ['Omuz', 'Sırt'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Sırt': 0.3},
    ),
    Exercise(
      name: 'Single Arm Pulley Machine Raise', 
      muscleGroups: ['Omuz'], 
      mainMuscleGroup: 'Omuz',
    ),
  ],
  'Sırt': [
    Exercise(
      name: 'Pull-Up', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.6},
    ),
    Exercise(
      name: 'Chin-Up', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.6},
    ),
    Exercise(
      name: 'Lat Pulldown', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.4},
    ),
    Exercise(
      name: 'Barbell Row', 
      muscleGroups: ['Sırt', 'Biceps', 'Omuz'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.6, 'Omuz': 0.2},
    ),
    Exercise(
      name: 'Dumbbell Row', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.5},
    ),
    Exercise(
      name: 'T-Bar Row', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.5},
    ),
    Exercise(
      name: 'Pendlay Row', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.5},
    ),
    Exercise(
      name: 'Smith Machine Row', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.4},
    ),
    Exercise(
      name: 'Machine Row', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.4},
    ),
  ],
  'Biceps': [
    Exercise(name: 'Barbell Biceps Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Dumbbell Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Concentration Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Dumbbell Hammer Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Machine Biceps Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Scott Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Machine Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
  ],
  'Triceps': [
    Exercise(
      name: 'Dips', 
      muscleGroups: ['Triceps', 'Göğüs', 'Omuz'], 
      mainMuscleGroup: 'Triceps',
      muscleGroupRatios: {'Göğüs': 0.3, 'Omuz': 0.2},
    ),
    Exercise(
      name: 'Close Grip Bench', 
      muscleGroups: ['Triceps', 'Göğüs'], 
      mainMuscleGroup: 'Triceps',
      muscleGroupRatios: {'Göğüs': 0.3},
    ),
    Exercise(
      name: 'Ez-Bar French Press', 
      muscleGroups: ['Triceps'], 
      mainMuscleGroup: 'Triceps',
    ),
    Exercise(
      name: 'Overhead Pulley Triceps', 
      muscleGroups: ['Triceps'], 
      mainMuscleGroup: 'Triceps',
    ),
    Exercise(
      name: 'Pulley Machine Triceps', 
      muscleGroups: ['Triceps'], 
      mainMuscleGroup: 'Triceps',
    ),
  ],
  'Bacak': [
    Exercise(name: 'Barbell Back Squat', muscleGroups: ['Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Front Squat', muscleGroups: ['Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Bulgarian Split Squat', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Lunges (Walking)', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Lunges (Static)', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Step-Up', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Romanian Deadlift', muscleGroups: ['Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Sumo Deadlift', muscleGroups: ['Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Leg Press', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Deadlift', muscleGroups: ['Bacak', 'Sırt', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Trap Bar Deadlift', muscleGroups: ['Bacak', 'Sırt', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Squat', muscleGroups: ['Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
  ],
  'Core': [
    Exercise(name: 'Plank', muscleGroups: ['Core'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Turkish Get-Up', muscleGroups: ['Core', 'Omuz', 'Kalça'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Farmer\'s Walk', muscleGroups: ['Core', 'Omuz', 'Kalça'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Bear Crawl', muscleGroups: ['Core', 'Omuz', 'Kalça'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Side Plank', muscleGroups: ['Core'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Russian Twist', muscleGroups: ['Core'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Crunches', muscleGroups: ['Core'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Leg Raises', muscleGroups: ['Core'], mainMuscleGroup: 'Core'),
  ],
  'Kalça': [
    Exercise(name: 'Hip Thrust', muscleGroups: ['Kalça', 'Bacak'], mainMuscleGroup: 'Kalça'),
    Exercise(name: 'Glute Bridge', muscleGroups: ['Kalça', 'Bacak'], mainMuscleGroup: 'Kalça'),
    Exercise(name: 'Good Morning', muscleGroups: ['Kalça', 'Sırt', 'Core'], mainMuscleGroup: 'Kalça'),
    Exercise(name: 'Kettlebell Swing', muscleGroups: ['Kalça', 'Core', 'Omuz'], mainMuscleGroup: 'Kalça'),
  ],
};
const List<String> mainMuscleGroups = [
  'Göğüs',
  'Omuz',
  'Bacak',
  'Sırt',
  'Biceps',
  'Triceps',
  'Core',
  'Kalça',
];

class DayDetailScreen extends StatefulWidget {
  final String day;
  final List<RoutineEntry> entries;
  final DateTime? lastCompleted;
  const DayDetailScreen({super.key, required this.day, required this.entries, this.lastCompleted});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  late List<RoutineEntry> _entries;
  String? _selectedMuscleGroup;
  Exercise? _selectedExercise;
  late TextEditingController _weightController;
  late TextEditingController _setCountController;
  late TextEditingController _repsController;
  bool _workoutStarted = false;
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  bool _showExerciseForm = false; // Egzersiz ekleme formunu göster/gizle (varsayılan gizli)
  bool _showSaveButton = false; // Kaydet butonunu göster/gizle
  // Antrenman sırasında yapılanlar (günlük)
  Map<String, List<SetEntry>> _workoutSets = {};
  
  // Seçili egzersizin geçmiş verileri
  List<ExerciseHistory> _exerciseHistory = [];
  // EventBus subscriptions
  StreamSubscription? _setProgressSubscription;
  StreamSubscription? _dataClearedSubscription;
  
  // Veri temizleme sonrası kilit mekanizması
  bool _isDataCleared = false;

  // Son yapılan egzersiz bilgisini bul
  RoutineEntry? _findLastEntryForExercise(Exercise exercise) {
    for (var i = _entries.length - 1; i >= 0; i--) {
      if (_entries[i].exercise.name == exercise.name) {
        return _entries[i];
      }
    }
    return null;
  }

  bool _routineExists(Exercise exercise, int setCount) {
    return _entries.any((e) => e.exercise.name == exercise.name && e.setCount == setCount);
  }

  // Antrenman durumunu kontrol et
  bool get _isWorkoutCompleted {
    final result = _entries.every((e) => e.sets.every((s) => s.isCompleted));
    print('_isWorkoutCompleted hesaplandı: $result (${_entries.length} egzersiz)');
    for (var entry in _entries) {
      final completedSets = entry.sets.where((s) => s.isCompleted).length;
      print('  ${entry.exercise.name}: $completedSets/${entry.sets.length} set tamamlandı');
    }
    return result;
  }

  // Bugün bu rutin tamamlandı mı? (WeekScreen'den gelen lastCompleted ile)
  bool get _isCompletedTodayFlag {
    final d = widget.lastCompleted;
    if (d == null) return false;
    final now = DateTime.now();
    return now.year == d.year && now.month == d.month && now.day == d.day;
  }

  // Antrenman durumunu güncelle
  void _updateWorkoutStatus() {
    print('_updateWorkoutStatus çağrıldı: _isWorkoutCompleted=$_isWorkoutCompleted, _workoutStarted=$_workoutStarted');
    if (_isWorkoutCompleted && _workoutStarted) {
      print('Tüm setler tamamlandı, antrenman otomatik olarak bitiriliyor');
      setState(() {
        // Tüm setler tamamlandığında antrenman otomatik olarak biter
        _workoutStarted = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _entries = List<RoutineEntry>.from(widget.entries);
    _weightController = TextEditingController(text: '');
    _setCountController = TextEditingController(text: '');
    _repsController = TextEditingController(text: '8');
    
    // Eğer hiç egzersiz yoksa formu aç
    if (_entries.isEmpty) {
      _showExerciseForm = true;
    }
    
    // Verileri SharedPreferences'dan yükle
    _loadSavedData();
    _setProgressSubscription = eventBus.on<SetProgressedEvent>().listen((event) {
      // Bu gün için herhangi bir egzersizde set ilerlediyse güncelle
      if (_entries.any((e) => e.exercise.name == event.exerciseName)) {
        _loadSavedData();
      }
    });
    
    // Veri temizlendiğinde egzersiz geçmişini yenile
    _dataClearedSubscription = eventBus.on<DataClearedEvent>().listen((event) {
      print('DataClearedEvent alındı - isGlobalClear: ${event.isGlobalClear}, exerciseName: ${event.exerciseName}');
      
      if (event.isGlobalClear) {
        // Tüm veriler temizlendi
      setState(() {
        _exerciseHistory = [];
          _isDataCleared = true;
        });
        print('DEBUG: DayDetailScreen - Tüm veriler temizlendi, _isDataCleared = true');
      } else if (event.exerciseName != null) {
        // Belirli egzersiz temizlendi
        if (_selectedExercise?.name == event.exerciseName) {
          setState(() {
            _exerciseHistory = [];
          });
          print('DEBUG: DayDetailScreen - ${event.exerciseName} egzersizi temizlendi');
        }
      }
    });
  }

  Future<void> _loadSavedData() async {
    try {
      final savedRoutine = await DataManager.getWeeklyRoutine();
      final dayEntries = savedRoutine[widget.day];
      if (dayEntries != null) {
        // Haftalık rutini yükle
        List<RoutineEntry> loaded = List<RoutineEntry>.from(dayEntries);

        // Aktif antrenmandaki ilerlemeyi set tamamlama durumlarına yansıt
        try {
          final active = await DataManager.getActiveWorkout();
          if (active != null && active['entries'] != null) {
            final List<RoutineEntry> activeEntries = List<RoutineEntry>.from(active['entries']);
            final Map<String, RoutineEntry> nameToActive = {
              for (final e in activeEntries) e.exercise.name.trim().toLowerCase(): e
            };
            loaded = loaded.map((e) {
              final key = e.exercise.name.trim().toLowerCase();
              final activeMatch = nameToActive[key];
              if (activeMatch != null) {
                return RoutineEntry(
                  exercise: e.exercise,
                  setCount: e.setCount,
                  sets: List<SetEntry>.from(activeMatch.sets),
                );
              }
              return e;
            }).toList();
          }
        } catch (_) {}

        setState(() {
          _entries = loaded;
          if (_entries.isEmpty) {
            _showExerciseForm = true;
          }
        });
      }
    } catch (e) {
      print('Veri yükleme hatası: $e');
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _setCountController.dispose();
    _repsController.dispose();
    
    // Antrenman bittiğinde notification'ı kapat
    if (_workoutStarted) {
      NotificationService.cancelQuickSetProgressNotification();
    }
    
    _setProgressSubscription?.cancel();
    _dataClearedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _addEntry() async {
    print('DEBUG: _addEntry - Fonksiyon başladı');
    print('DEBUG: _addEntry - Çağrı yığını: ${StackTrace.current}');
    print('DEBUG: _addEntry - _isDataCleared: $_isDataCleared');
    print('DEBUG: _addEntry - globalIsDataCleared: $globalIsDataCleared');
    
    final weight = double.tryParse(_weightController.text);
    final setCount = int.tryParse(_setCountController.text);
    final reps = int.tryParse(_repsController.text);
    
    if (_selectedExercise != null && weight != null && setCount != null && reps != null) {
      if (_routineExists(_selectedExercise!, setCount)) {
        // Aynı egzersiz ve set sayısı ile tekrar eklenmesin
        print('_addEntry - Aynı egzersiz zaten mevcut, eklenmedi');
        return;
      }
      
      // Egzersiz adını sakla çünkü setState içinde null yapılıyor
      final exerciseName = _selectedExercise!.name;
      print('_addEntry - Yeni egzersiz ekleniyor: $exerciseName');
      
      setState(() {
        _entries.add(RoutineEntry(
          exercise: _selectedExercise!,
          setCount: setCount,
          sets: List.generate(setCount, (i) => SetEntry(
            targetReps: reps, 
            targetWeight: weight,
            actualReps: reps,  // Başlangıçta hedef değerle aynı
            actualWeight: weight,  // Başlangıçta hedef değerle aynı
          )),
        ));
        
        // Egzersiz eklendikten sonra formu gizleme satırını kaldır
        _selectedExercise = null;
        _selectedMuscleGroup = null;
        _setCountController.clear();
        _weightController.clear();
        _repsController.text = '8'; // Default tekrar değeri
        _showSaveButton = true; // Kaydet butonunu göster
      });
      
      // Rutini kaydet
      _saveRoutine();
    }
  }

  Future<void> _saveRoutine() async {
    try {
      // WeekScreen'e rutini kaydet
      final weekScreen = context.findAncestorStateOfType<_WeekScreenState>();
      if (weekScreen != null) {
        weekScreen._weeklyRoutine[widget.day] = List<RoutineEntry>.from(_entries);
        
        // Egzersiz geçmişini korumak için WeekScreen._cachedExerciseHistory'yi güncelle
        final currentHistory = await DataManager.getExerciseHistory();
        weekScreen._cachedExerciseHistory = Map<String, List<ExerciseHistory>>.from(currentHistory);
        print('WeekScreen _cachedExerciseHistory güncellendi: $currentHistory');
        
        await weekScreen._saveData();
        print('Rutin kaydedildi: ${widget.day}');
      }
    } catch (e) {
      print('Rutin kaydetme hatası: $e');
    }
  }

  void _removeEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
    // Rutini kaydet
    _saveRoutine();
  }

  void _updateEntryWeight(int entryIndex, int setIndex, double delta) {
    setState(() {
      final entry = _entries[entryIndex];
      final sets = List<SetEntry>.from(entry.sets);
      final set = sets[setIndex];
      sets[setIndex] = set.copyWith(actualWeight: (set.actualWeight + delta).clamp(0, 9999));
      _entries[entryIndex] = RoutineEntry(
        exercise: entry.exercise,
        setCount: entry.setCount,
        sets: sets,
      );
    });
  }

  void _updateEntryReps(int entryIndex, int setIndex, int delta) {
    setState(() {
      final entry = _entries[entryIndex];
      final sets = List<SetEntry>.from(entry.sets);
      final set = sets[setIndex];
      sets[setIndex] = set.copyWith(actualReps: (set.actualReps + delta).clamp(0, 99));
      _entries[entryIndex] = RoutineEntry(
        exercise: entry.exercise,
        setCount: entry.setCount,
        sets: sets,
      );
    });
  }

  void _openSetDetail(int entryIndex) async {
    final entry = _entries[entryIndex];
    final updatedSets = await Navigator.push<List<SetEntry>>(
      context,
      MaterialPageRoute(
        builder: (context) => SetDetailScreen(
          exercise: entry.exercise,
          sets: List<SetEntry>.from(entry.sets),
        ),
      ),
    );
    if (updatedSets != null) {
      setState(() {
        _entries[entryIndex] = RoutineEntry(
          exercise: entry.exercise,
          setCount: entry.setCount,
          sets: updatedSets,
        );
      });
      
      // Antrenman durumunu güncelle
      _updateWorkoutStatus();
    }
  }

  void _onExerciseChanged(Exercise? newExercise) {
    print('DEBUG: onExerciseChanged -> seçilen: \'${newExercise?.name}\'');
    setState(() {
      _selectedExercise = newExercise;
      if (newExercise != null) {
        final last = _findLastEntryForExercise(newExercise);
        if (last != null) {
          _weightController.text = last.sets.first.targetWeight.toStringAsFixed(1);
          _setCountController.text = last.setCount.toString();
          _repsController.text = last.sets.first.targetReps.toString();
        } else {
          // Varsayılan değerler
          _weightController.text = '20';
          _setCountController.text = '3';
          _repsController.text = '8';
        }
        
        // Geçmiş verileri yükle
        _loadExerciseHistory(newExercise);
      }
    });
  }

  Future<void> _loadExerciseHistory(Exercise exercise) async {
    try {
      print('Geçmiş veri yükleniyor: ${exercise.name}');
      final history = await DataManager.getExerciseHistory();
      print('Tüm geçmiş veriler: $history');
      // Anahtarı normalize ederek oku
      final exerciseHistory = history[exercise.name.trim().toLowerCase()] ?? [];
      print('${exercise.name} için geçmiş veriler: $exerciseHistory');
      setState(() {
        _exerciseHistory = exerciseHistory;
      });
    } catch (e) {
      print('Geçmiş veri yükleme hatası: $e');
    }
  }

  Future<void> _saveExerciseHistory(String exerciseName, double weight, int reps, int sets) async {
    try {
      print('DEBUG: _saveExerciseHistory - Fonksiyon başladı: $exerciseName - $weight kg × $reps tekrar');
      print('DEBUG: _saveExerciseHistory - Çağrı yığını: ${StackTrace.current}');
      
      // Mevcut geçmiş verileri al
      final history = await DataManager.getExerciseHistory();
      print('_saveExerciseHistory - Mevcut geçmiş veriler: ${history.length} egzersiz');
      // Temizleme sonrası tamamen sıfırdan başla
      final Map<String, List<ExerciseHistory>> workingHistory = globalIsDataCleared ? <String, List<ExerciseHistory>>{} : Map<String, List<ExerciseHistory>>.from(history);
      
      // Anahtarı normalize ederek kaydet
      final normalizedName = exerciseName.trim().toLowerCase();
      final exerciseHistory = workingHistory[normalizedName] ?? [];
      print('_saveExerciseHistory - $normalizedName için mevcut kayıt sayısı: ${exerciseHistory.length}');
      
      // Aynı gün için mevcut kayıtları temizleme davranışı:
      // - main.dart (gün ana akışı): aynı gün kayıtlarını temizleme (gün başına tek satır)
      // - detail.dart (set ekleme): aynı gün kayıtlarını koru ve yeni satır ekle
      final calledFromDetail = StackTrace.current.toString().contains('detail.dart');
      if (!calledFromDetail) {
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final todayEnd = todayStart.add(Duration(days: 1));
        exerciseHistory.removeWhere((entry) {
          final entryDate = entry.date;
          return entryDate.isAfter(todayStart) && entryDate.isBefore(todayEnd);
        });
      }
      print('_saveExerciseHistory - Gün içi temizleme uygulandı mı: ${!calledFromDetail} | kalan: ${exerciseHistory.length}');
      
      // Yeni egzersiz geçmişi ekle
      exerciseHistory.add(ExerciseHistory(
        exerciseName: exerciseName,
        date: DateTime.now(),
        weight: weight,
        reps: reps,
        setsCount: sets,
        sets: List.generate(sets, (i) => SetEntry(targetReps: reps, targetWeight: weight)),
      ));
      
      // Maksimum 10 kayıt tut
      if (exerciseHistory.length > 10) {
        exerciseHistory.removeRange(0, exerciseHistory.length - 10);
      }
      
      // Güncellenmiş veriyi kaydet
      final updatedHistory = Map<String, List<ExerciseHistory>>.from(workingHistory);
      updatedHistory[normalizedName] = exerciseHistory;
      // İlk başarılı kayıttan sonra global bayrağı sıfırla
      if (globalIsDataCleared) {
        globalIsDataCleared = false;
      }
      
      print('_saveExerciseHistory - Güncellenmiş geçmiş: ${updatedHistory.length} egzersiz');
      
      // SharedPreferences'a kaydet
      await DataManager.saveExerciseHistory(updatedHistory);
      
      // WeekScreen cache'ini güncelle
      final weekScreen = context.findAncestorStateOfType<_WeekScreenState>();
      if (weekScreen != null) {
        weekScreen._cachedExerciseHistory = Map<String, List<ExerciseHistory>>.from(updatedHistory);
        print('WeekScreen _cachedExerciseHistory güncellendi');
      }
      
      setState(() {
        _exerciseHistory = exerciseHistory;
      });
      
      print('Egzersiz geçmişi başarıyla kaydedildi: $exerciseName - $weight kg × $reps tekrar');
    } catch (e) {
      print('Egzersiz geçmişi kaydetme hatası: $e');
    }
  }

  void _changeWeightField(double delta) {
    final current = double.tryParse(_weightController.text) ?? 0;
    final newValue = (current + delta).clamp(0, 9999);
    setState(() {
      _weightController.text = newValue.toStringAsFixed(1);
    });
  }

  void _updateCurrentSetReps(int delta) {
    if (_currentExerciseIndex < _entries.length && _currentSetIndex < _entries[_currentExerciseIndex].sets.length) {
      setState(() {
        final entry = _entries[_currentExerciseIndex];
        final sets = List<SetEntry>.from(entry.sets);
        final set = sets[_currentSetIndex];
        sets[_currentSetIndex] = set.copyWith(actualReps: (set.actualReps + delta).clamp(0, 99));
        _entries[_currentExerciseIndex] = RoutineEntry(
          exercise: entry.exercise,
          setCount: entry.setCount,
          sets: sets,
        );
      });
    }
  }

  // Ağırlık geçmişi dialog'unu göster
  void _showWeightHistoryDialog() {
    if (_selectedExercise == null) {
      // Egzersiz seçilmemişse uyarı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            globalLanguage == 'Türkçe' 
              ? 'Önce bir egzersiz seçin' 
              : 'Please select an exercise first',
          ),
          backgroundColor: AppColorTheme.buttonWarning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.history,
                color: AppColorTheme.primary,
                size: context.responsiveIconSize,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  globalLanguage == 'Türkçe' 
                    ? '${_selectedExercise!.name} - Ağırlık Geçmişi'
                    : '${_selectedExercise!.name} - Weight History',
                  style: TextStyle(
                    fontSize: context.responsiveTitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: _exerciseHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: AppColorTheme.inputHint,
                      ),
                      SizedBox(height: 16),
                      Text(
                        globalLanguage == 'Türkçe'
                          ? 'Bu egzersiz için henüz geçmiş kaydı yok'
                          : 'No history record for this exercise yet',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize,
                          color: AppColorTheme.inputHint,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: List.generate(_exerciseHistory.length, (index) {
                    final history = _exerciseHistory[_exerciseHistory.length - 1 - index];
                    final TextEditingController weightController = TextEditingController(text: history.weight.toStringAsFixed(1));
                    final TextEditingController repsController = TextEditingController(text: history.reps.toString());
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text('${index + 1}.', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            // Ağırlık inputu ve butonlar
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                double val = double.tryParse(weightController.text) ?? history.weight;
                                val = (val - 2.5).clamp(0, 9999);
                                weightController.text = val.toStringAsFixed(1);
                              },
                            ),
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: weightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'Kg'),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () {
                                double val = double.tryParse(weightController.text) ?? history.weight;
                                val = (val + 2.5).clamp(0, 9999);
                                weightController.text = val.toStringAsFixed(1);
                              },
                            ),
                            SizedBox(width: 16),
                            // Tekrar inputu ve butonlar
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                int val = int.tryParse(repsController.text) ?? history.reps;
                                val = (val - 1).clamp(0, 99);
                                repsController.text = val.toString();
                              },
                            ),
                            SizedBox(
                              width: 40,
                              child: TextField(
                                controller: repsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'Tekrar'),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () {
                                int val = int.tryParse(repsController.text) ?? history.reps;
                                val = (val + 1).clamp(0, 99);
                                repsController.text = val.toString();
                              },
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _exerciseHistory[_exerciseHistory.length - 1 - index] = ExerciseHistory(
                                    exerciseName: history.exerciseName,
                                    date: history.date,
                                    weight: double.tryParse(weightController.text) ?? history.weight,
                                    reps: int.tryParse(repsController.text) ?? history.reps,
                                    setsCount: history.setsCount,
                                    sets: List.generate(history.setsCount, (i) => SetEntry.fromJson(history.sets[i].toJson())),
                                  );
                                });
                              },
                              child: Text('Kaydet', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                globalLanguage == 'Türkçe' ? 'Kapat' : 'Close',
                style: TextStyle(
                  color: AppColorTheme.inputLabel,
                  fontSize: context.responsiveFontSize,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateCurrentSetWeight(double delta) {
    if (_currentExerciseIndex < _entries.length && _currentSetIndex < _entries[_currentExerciseIndex].sets.length) {
      setState(() {
        final entry = _entries[_currentExerciseIndex];
        final sets = List<SetEntry>.from(entry.sets);
        final set = sets[_currentSetIndex];
        sets[_currentSetIndex] = set.copyWith(actualWeight: (set.actualWeight + delta).clamp(0, 9999));
        _entries[_currentExerciseIndex] = RoutineEntry(
          exercise: entry.exercise,
          setCount: entry.setCount,
          sets: sets,
        );
      });
    }
  }

  void _completeCurrentSet() async {
    if (_currentExerciseIndex < _entries.length && _currentSetIndex < _entries[_currentExerciseIndex].sets.length) {
      setState(() {
        final entry = _entries[_currentExerciseIndex];
        final sets = List<SetEntry>.from(entry.sets);
        sets[_currentSetIndex] = sets[_currentSetIndex].copyWith(isCompleted: true);
        _entries[_currentExerciseIndex] = RoutineEntry(
          exercise: entry.exercise,
          setCount: entry.setCount,
          sets: sets,
        );

        // Sonraki sete geç
        _currentSetIndex++;
        
        // Eğer bu egzersizin tüm setleri tamamlandıysa, sonraki egzersize geç
        if (_currentSetIndex >= entry.setCount) {
          _currentSetIndex = 0;
          _currentExerciseIndex++;
        }
      });
      
      // Antrenman durumunu güncelle
      _updateWorkoutStatus();
      
      // Notification'ı güncelle
      _updateQuickSetProgressNotification();
      
      // Debug: Mevcut durumu yazdır
      print('_completeCurrentSet: Egzersiz ${_currentExerciseIndex + 1}/${_entries.length}, Set ${_currentSetIndex + 1}/${_entries[_currentExerciseIndex].sets.length}');
      print('Antrenman durumu: _workoutStarted=$_workoutStarted, _isWorkoutCompleted=$_isWorkoutCompleted');
    }
  }

  void _updateQuickSetProgressNotification() async {
    if (_currentExerciseIndex < _entries.length) {
      final entry = _entries[_currentExerciseIndex];
      final currentSet = _currentSetIndex + 1;
      
      await NotificationService.showCustomWorkoutNotification(
        exerciseName: entry.exercise.name,
        currentSet: currentSet,
        totalSets: entry.setCount,
        weight: entry.sets[_currentSetIndex].targetWeight,
        reps: entry.sets[_currentSetIndex].targetReps,
      );
    } else {
      // Tüm egzersizler tamamlandı
      await NotificationService.cancelQuickSetProgressNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    RoutineEntry? lastEntry;
    if (_selectedExercise != null) {
      lastEntry = _findLastEntryForExercise(_selectedExercise!);
    }
    // Seçili kas grubuna göre egzersizler
    final exercises = _selectedMuscleGroup != null ? muscleGroupExercises[_selectedMuscleGroup!] ?? [] : <Exercise>[];
    String? lastCompletedText;
    if (widget.lastCompleted != null) {
      final diff = DateTime.now().difference(widget.lastCompleted!).inDays;
      lastCompletedText = 'Son tamamlanma: -${diff}g';
    }
    
    // Debug: Build sırasında antrenman durumunu yazdır
    print('Build: _workoutStarted=$_workoutStarted, _isWorkoutCompleted=$_isWorkoutCompleted, ${_entries.length} egzersiz');
    return Scaffold(
      appBar: AppBar(
        title: Text(globalLanguage == 'Türkçe' ? '${widget.day} Rutini' : '${getLocalizedDayName(widget.day)} Routine'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, {'entries': _entries, 'completed': false}),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lastCompletedText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(lastCompletedText, style: const TextStyle(color: Colors.green)),
              ),
            Text(globalLanguage == 'Türkçe' ? 'Kas Grubu ve Egzersiz Ekle:' : 'Add Muscle Group and Exercise:', style: TextStyle(fontWeight: FontWeight.bold)),
            // Profesyonel egzersiz seçme bölümü
            // Egzersiz ekleme alanı - koşullu gösterim
            if (_showExerciseForm)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, color: AppColorTheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          globalLanguage == 'Türkçe' ? 'Yeni Egzersiz Ekle' : 'Add New Exercise',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                          onPressed: () {
                            setState(() {
                              _showExerciseForm = false;
                            });
                          },
                          tooltip: 'Formu Kapat',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Kas grubu seçimi
                    Text(globalLanguage == 'Türkçe' ? '1. Kas Grubu Seçin' : '1. Select Muscle Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: globalLanguage == 'Türkçe' ? 'Kas Grubu' : 'Muscle Group',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        hint: Text(
                          globalLanguage == 'Türkçe' ? 'Kas grubunu seçin' : 'Select muscle group',
                          style: TextStyle(fontSize: context.responsiveFontSize),
                          overflow: TextOverflow.ellipsis,
                        ),
                        value: _selectedMuscleGroup,
                        items: mainMuscleGroups.map((g) => DropdownMenuItem(
                          value: g,
                          child: Row(
                            children: [
                              g == 'Göğüs'
                                  ? Image.asset(
                                      'assets/chest.png',
                                      width: 24,
                                      height: 24,
                                      errorBuilder: (context, error, stackTrace) => Text(muscleGroupIcons[g] ?? '🏋️‍♂️'),
                                    )
                                  : g == 'Bacak'
                                      ? Image.asset(
                                          'assets/leg.png',
                                          width: 24,
                                          height: 24,
                                          errorBuilder: (context, error, stackTrace) => Text(muscleGroupIcons[g] ?? '🏋️‍♂️'),
                                        )
                                      : g == 'Omuz'
                                          ? Image.asset(
                                              'assets/shoulder.png',
                                              width: 24,
                                              height: 24,
                                              errorBuilder: (context, error, stackTrace) => Text(muscleGroupIcons[g] ?? '🏋️‍♂️'),
                                            )
                                          : g == 'Core'
                                              ? Image.asset(
                                                  'assets/Core.png',
                                                  width: 24,
                                                  height: 24,
                                                  errorBuilder: (context, error, stackTrace) => Text(muscleGroupIcons[g] ?? '🏋️‍♂️'),
                                                )
                                              : g == 'Sırt'
                                                  ? Image.asset(
                                                      'assets/Sırt.png',
                                                      width: 24,
                                                      height: 24,
                                                      errorBuilder: (context, error, stackTrace) => Text(muscleGroupIcons[g] ?? '🏋️‍♂️'),
                                                    )
                                                  : g == 'Triceps'
                                                      ? Image.asset(
                                                          'assets/triceps.png',
                                                          width: 24,
                                                          height: 24,
                                                          errorBuilder: (context, error, stackTrace) => Text(muscleGroupIcons[g] ?? '🏋️‍♂️'),
                                                        )
                                                      : Text(muscleGroupIcons[g] ?? '🏋️‍♂️'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  getLocalizedMuscleGroup(g),
                                  style: TextStyle(fontSize: context.responsiveFontSize),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedMuscleGroup = v;
                            _selectedExercise = null;
                          });
                        },
                        isExpanded: true, // Tam genişlik kullan
                        menuMaxHeight: 200, // Menü yüksekliğini sınırla
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Egzersiz seçimi
                    if (_selectedMuscleGroup != null)
                      Text(globalLanguage == 'Türkçe' ? '2. Egzersiz Seçin' : '2. Select Exercise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonFormField<Exercise>(
                          decoration: InputDecoration(
                            labelText: globalLanguage == 'Türkçe' ? 'Egzersiz' : 'Exercise',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          hint: Text(
                            globalLanguage == 'Türkçe' ? 'Egzersizi seçin' : 'Select exercise',
                            style: TextStyle(fontSize: context.responsiveFontSize),
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: _selectedExercise,
                          items: exercises.map((e) => DropdownMenuItem(
                            value: e,
                            child: (() {
                              final asset = assetForExercise(e.name);
                              return Row(
                                children: [
                                  if (asset != null)
                                    Image.asset(
                                      asset,
                                      width: 24,
                                      height: 24,
                                      errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
                                    ),
                                  if (asset != null) const SizedBox(width: 8),
                                  Expanded(
                            child: Text(
                              e.name, 
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: context.responsiveFontSize,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                                  ),
                                ],
                              );
                            })(),
                          )).toList(),
                          onChanged: _onExerciseChanged,
                          isExpanded: true, // Tam genişlik kullan
                          menuMaxHeight: 200, // Menü yüksekliğini sınırla
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Set ve kg girişi
                    if (_selectedExercise != null)
                      Text(globalLanguage == 'Türkçe' ? '3. Set ve Ağırlık Belirleyin' : '3. Set Weight and Reps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      // Responsive düzen - küçük ekranlarda dikey, büyük ekranlarda yatay
                      context.screenWidth < 600 
                        ? Column(
                            children: [
                              // Set sayısı
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColorTheme.inputBorder),
                                  color: AppColorTheme.inputBackground,
                                ),
                                child: TextField(
                                  controller: _setCountController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColorTheme.inputText,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: globalLanguage == 'Türkçe' ? 'Set' : 'Sets',
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      color: AppColorTheme.inputLabel,
                                      fontSize: 12,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 14),
                                    hintText: '3',
                                    hintStyle: TextStyle(
                                      color: AppColorTheme.inputHint,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              // Tekrar sayısı
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColorTheme.inputBorder),
                                  color: AppColorTheme.inputBackground,
                                ),
                                child: TextField(
                                  controller: _repsController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColorTheme.inputText,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: globalLanguage == 'Türkçe' ? 'Tekrar' : 'Reps',
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      color: AppColorTheme.inputLabel,
                                      fontSize: 12,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 14),
                                    hintText: '8',
                                    hintStyle: TextStyle(
                                      color: AppColorTheme.inputHint,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              // Ağırlık girişi
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColorTheme.inputBorder),
                                  color: AppColorTheme.inputBackground,
                                ),
                                child: Row(
                                  children: [
                                    // Azalt butonu
                                    Container(
                                      width: 45,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppColorTheme.errorLight.withOpacity(0.3),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.remove, color: AppColorTheme.error, size: 24),
                                        onPressed: () => _changeWeightField(-2.5),
                                        style: IconButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              bottomLeft: Radius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                                                          // KG input alanı
                                    Expanded(
                                      child: Container(
                                        child: TextField(
                                          controller: _weightController,
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColorTheme.inputText,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: globalLanguage == 'Türkçe' ? 'KG' : 'KG',
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                            labelStyle: TextStyle(
                                              color: AppColorTheme.inputLabel,
                                              fontSize: 12,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 14),
                                            hintText: '0',
                                            hintStyle: TextStyle(
                                              color: AppColorTheme.inputHint,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Artır butonu
                                    Container(
                                      width: 45,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppColorTheme.successLight.withOpacity(0.3),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                                                              child: IconButton(
                                          icon: Icon(Icons.add, color: AppColorTheme.success, size: 24),
                                          onPressed: () => _changeWeightField(2.5),
                                        style: IconButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(12),
                                              bottomRight: Radius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              // Set sayısı
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColorTheme.inputBorder),
                                    color: AppColorTheme.inputBackground,
                                  ),
                                  child: TextField(
                                    controller: _setCountController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColorTheme.inputText,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: globalLanguage == 'Türkçe' ? 'Set' : 'Sets',
                                      labelStyle: TextStyle(
                                        color: AppColorTheme.inputLabel,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                                      hintText: '3',
                                      hintStyle: TextStyle(
                                        color: AppColorTheme.inputHint,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              // Tekrar sayısı
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColorTheme.inputBorder),
                                    color: AppColorTheme.inputBackground,
                                  ),
                                  child: TextField(
                                    controller: _repsController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColorTheme.inputText,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: globalLanguage == 'Türkçe' ? 'Tekrar' : 'Reps',
                                      labelStyle: TextStyle(
                                        color: AppColorTheme.inputLabel,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                                      hintText: '8',
                                      hintStyle: TextStyle(
                                        color: AppColorTheme.inputHint,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              // Ağırlık girişi
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColorTheme.inputBorder),
                                    color: AppColorTheme.inputBackground,
                                  ),
                                  child: Row(
                                    children: [
                                      // Azalt butonu
                                      Container(
                                        width: 45,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColorTheme.errorLight.withOpacity(0.3),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12),
                                          ),
                                        ),
                                                                                child: IconButton(
                                          icon: Icon(Icons.remove, color: AppColorTheme.error, size: 24),
                                          onPressed: () => _changeWeightField(-2.5),
                                        style: IconButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                bottomLeft: Radius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // KG input alanı
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                          child: TextField(
                                            controller: _weightController,
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColorTheme.inputText,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: globalLanguage == 'Türkçe' ? 'KG' : 'KG',
                                              labelStyle: TextStyle(
                                                fontSize: 10,
                                                color: AppColorTheme.inputLabel,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.fromLTRB(0, 8, 0, 14),
                                              hintText: '0',
                                              hintStyle: TextStyle(
                                                color: AppColorTheme.inputHint,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Artır butonu
                                      Container(
                                        width: 45,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColorTheme.successLight.withOpacity(0.3),
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.add, color: AppColorTheme.success, size: 24),
                                                                                  onPressed: () => _changeWeightField(2.5),
                                        style: IconButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(12),
                                                bottomRight: Radius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      
                      const SizedBox(height: 16),
                      
                      // Geçmiş veriler
                      if (_exerciseHistory.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.history, color: Colors.blue[700], size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    globalLanguage == 'Türkçe' ? 'Geçmiş Performans' : 'Previous Performance',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ..._exerciseHistory.take(3).map((history) {
                                final date = history.date;
                                final now = DateTime.now();
                                final diff = now.difference(date).inDays;
                                String timeAgo;
                                if (diff == 0) {
                                  timeAgo = globalLanguage == 'Türkçe' ? 'Bugün' : 'Today';
                                } else if (diff == 1) {
                                  timeAgo = globalLanguage == 'Türkçe' ? 'Dün' : 'Yesterday';
                                } else if (diff < 7) {
                                  timeAgo = globalLanguage == 'Türkçe' ? '$diff gün önce' : '$diff days ago';
                                } else {
                                  final weeks = (diff / 7).floor();
                                  timeAgo = globalLanguage == 'Türkçe' ? '$weeks hafta önce' : '$weeks weeks ago';
                                }
                                
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${history.weight} kg × ${history.reps} tekrar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        timeAgo,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                      
                      // Ekle butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isDataCleared ? null : _addEntry, // Veri temizleme sonrası devre dışı
                          icon: const Icon(Icons.add),
                          label: Text(_isDataCleared 
                            ? (globalLanguage == 'Türkçe' ? 'Veri Temizlendi' : 'Data Cleared')
                            : (globalLanguage == 'Türkçe' ? 'Egzersizi Rutine Ekle' : 'Add Exercise to Routine')
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isDataCleared ? Colors.grey : AppColorTheme.buttonPrimary,
                            foregroundColor: AppColorTheme.surface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (lastEntry != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Text(
                  'Son: ${lastEntry.setCount} set, ${lastEntry.sets.first.targetWeight} kg',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(globalLanguage == 'Türkçe' ? 'Günün Rutinleri:' : 'Day\'s Routines:', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                if (!_showExerciseForm)
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.deepPurple, size: 28),
                    onPressed: () {
                      setState(() {
                        _showExerciseForm = true;
                      });
                    },
                    tooltip: globalLanguage == 'Türkçe' ? 'Yeni Egzersiz Ekle' : 'Add New Exercise',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Egzersiz listesi - sürükle bırak ile sıralama
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _entries.removeAt(oldIndex);
                  _entries.insert(newIndex, item);
                });
                // Yeni sıralamayı kaydet
                _saveRoutine();
              },
              children: [
                for (int i = 0; i < _entries.length; i++)
                  ListTile(
                    key: ValueKey('exercise_${_entries[i].exercise.name}_$i'),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (() {
                          final name = _entries[i].exercise.name.toLowerCase();
                          String? asset = assetForExercise(name);
                          if (asset != null) {
                            return Image.asset(
                              asset,
                              width: 28,
                              height: 28,
                              errorBuilder: (context, error, stackTrace) => Text(
                          muscleGroupIcons[_entries[i].exercise.mainMuscleGroup] ?? '🏋️‍♂️',
                          style: const TextStyle(fontSize: 28),
                        ),
                            );
                          }
                          return Text(
                            muscleGroupIcons[_entries[i].exercise.mainMuscleGroup] ?? '🏋️‍♂️',
                            style: const TextStyle(fontSize: 28),
                          );
                        })(),
                        if (_entries[i].sets.every((set) => set.isCompleted)) ...[
                          SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        ],
                      ],
                    ),
                    title: Text(
                      '${_entries[i].exercise.name} - ${_entries[i].setCount} set',
                      style: TextStyle(
                        color: _entries[i].sets.every((set) => set.isCompleted) ? Colors.green : Colors.black,
                        fontWeight: _entries[i].sets.every((set) => set.isCompleted) ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      globalLanguage == 'Türkçe'
                        ? 'Kas grupları: ${_entries[i].exercise.muscleGroups.join(', ')}'
                        : 'Muscle groups: ${_entries[i].exercise.muscleGroups.map((m) => getLocalizedMuscleGroup(m)).join(', ')}',
                      style: TextStyle(
                        color: _entries[i].sets.every((set) => set.isCompleted) ? Colors.green[700] : Colors.grey[600],
                      ),
                    ),
                    tileColor: _entries[i].sets.every((set) => set.isCompleted) ? Colors.green.withOpacity(0.1) : null,
                    onTap: () async {
                      final entry = _entries[i];
                      // Geçmişi uygun şekilde bulmak için örnek bir yapı
                      final List<ExerciseHistory> history = [];
                      // Bu egzersizden akışı başlat (istediğin egzersizden başla)
                      await DataManager.saveActiveWorkout(
                        entries: _entries,
                        exerciseIndex: i,
                        setIndex: 0,
                        exerciseName: entry.exercise.name,
                      );
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseDetailScreen(
                            exerciseName: entry.exercise.name,
                            sets: entry.sets,
                            history: history,
                            workoutFlow: true,
                            exerciseIndex: i,
                            allEntries: _entries,
                            dayName: widget.day,
                          ),
                        ),
                      );
                      // Dönüşte her zaman verileri yenile ki tikler güncellensin
                      await _loadSavedData();
                      setState(() {});
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeEntry(i),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Antrenman başlat butonu - sadece antrenman başlamamışsa ve egzersiz varsa göster
            if (!_workoutStarted && _entries.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: Text(globalLanguage == 'Türkçe' ? 'Antrenmanı Başlat' : 'Start Workout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    // Eğer bugünün rutini daha önce tamamlandıysa veya tüm setler tamamlandıysa
                    // yeni bir oturum için set durumlarını sıfırla.
                    if (_isWorkoutCompleted) {
                      setState(() {
                        _entries = _entries.map((e) => RoutineEntry(
                          exercise: e.exercise,
                          setCount: e.setCount,
                          sets: e.sets.map((s) => s.copyWith(
                            actualReps: s.targetReps,
                            actualWeight: s.targetWeight,
                            isCompleted: false,
                          )).toList(),
                        )).toList();
                      });
                      await _saveRoutine();
                    }
                    // Antrenmanı başlat
                    setState(() {
                      _workoutStarted = true;
                      _currentExerciseIndex = 0;
                      _currentSetIndex = 0;
                    });
                    
                    // İlk egzersizin detayına git
                    final firstIndex = 0;
                    final entry = _entries[firstIndex];
                    await DataManager.saveActiveWorkout(
                      entries: _entries,
                      exerciseIndex: firstIndex,
                      setIndex: 0,
                      exerciseName: entry.exercise.name,
                    );
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailScreen(
                          exerciseName: entry.exercise.name,
                          sets: entry.sets,
                          history: const <ExerciseHistory>[],
                          workoutFlow: true,
                          exerciseIndex: firstIndex,
                          allEntries: _entries,
                          dayName: widget.day,
                        ),
                      ),
                    );
                    // Dönüşte ekranı güncelle
                    await _loadSavedData();
                    setState(() {});
                  },
                ),
              ),
                          // İlerleme paneli kaldırıldı
              // Mevcut egzersiz
              if (false && _currentExerciseIndex < _entries.length) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fitness_center, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            _entries[_currentExerciseIndex].exercise.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Set ilerleme kutucuğu
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  globalLanguage == 'Türkçe' ? 'Set İlerlemesi' : 'Set Progress',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  '${_currentSetIndex + 1}/${_entries[_currentExerciseIndex].setCount}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _entries[_currentExerciseIndex].setCount > 0 
                                ? (_currentSetIndex + 1) / _entries[_currentExerciseIndex].setCount 
                                : 0,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            SizedBox(height: 12),
                            Text(
                              globalLanguage == 'Türkçe' 
                                ? 'Hedef: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].targetReps} tekrar, ${_entries[_currentExerciseIndex].sets[_currentSetIndex].targetWeight.toStringAsFixed(1)} kg'
                                : 'Target: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].targetReps} reps, ${_entries[_currentExerciseIndex].sets[_currentSetIndex].targetWeight.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  globalLanguage == 'Türkçe' ? 'Tekrar: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].actualReps}' : 'Reps: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].actualReps}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  globalLanguage == 'Türkçe' ? 'KG: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].actualWeight.toStringAsFixed(1)}' : 'KG: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].actualWeight.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.remove),
                            label: Text(globalLanguage == 'Türkçe' ? 'Tekrar -' : 'Rep -'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _updateCurrentSetReps(-1),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text(globalLanguage == 'Türkçe' ? 'Tekrar +' : 'Rep +'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _updateCurrentSetReps(1),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.remove),
                            label: Text(globalLanguage == 'Türkçe' ? 'KG -' : 'KG -'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _updateCurrentSetWeight(-2.5),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text(globalLanguage == 'Türkçe' ? 'KG +' : 'KG +'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _updateCurrentSetWeight(2.5),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.check),
                        label: Text(globalLanguage == 'Türkçe' ? 'Seti Tamamla' : 'Complete Set'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorTheme.buttonPrimary,
                          foregroundColor: AppColorTheme.surface,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        onPressed: _completeCurrentSet,
                      ),
                    ],
                  ),
                ),
              ],
              // Antrenmanı bitir butonu - sadece tüm setler tamamlandığında göster
              if (_isWorkoutCompleted)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: Text(globalLanguage == 'Türkçe' ? 'Antrenmanı Bitir' : 'Finish Workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorTheme.buttonError,
                      foregroundColor: AppColorTheme.surface,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      // Antrenmanı bitir
                      setState(() {
                        _workoutStarted = false;
                        _currentExerciseIndex = 0;
                        _currentSetIndex = 0;
                      });
                      
                      // Rutini kaydet
                      await _saveRoutine();
                      await DataManager.clearActiveWorkout();
                      Navigator.pop(context, {'entries': _entries, 'completed': true});
                    },
                  ),
                ),
              // Tüm egzersizler tamamlandığında tebrik mesajı
              if (_isWorkoutCompleted && _entries.isNotEmpty) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorTheme.successLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColorTheme.success),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.celebration, color: AppColorTheme.success, size: context.responsiveIconSize),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          globalLanguage == 'Türkçe' ? 'Tebrikler! Tüm egzersizler tamamlandı! 🎉' : 'Congratulations! All exercises completed! 🎉',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: context.responsiveFontSize,
                            color: AppColorTheme.success,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: _showSaveButton ? FloatingActionButton(
        onPressed: () async {
          setState(() {
            _showSaveButton = false; // Kaydet butonunu gizle
          });
          // Rutini kaydet
          await _saveRoutine();
          Navigator.pop(context, {'entries': _entries, 'completed': false});
        },
        backgroundColor: AppColorTheme.buttonPrimary,
        foregroundColor: AppColorTheme.surface,
        child: const Icon(Icons.save),
      ) : null,

    );
  }
}

// Yeni: Set detay ekranı
class SetDetailScreen extends StatefulWidget {
  final Exercise exercise;
  final List<SetEntry> sets;
  const SetDetailScreen({super.key, required this.exercise, required this.sets});

  @override
  State<SetDetailScreen> createState() => _SetDetailScreenState();
}

class _SetDetailScreenState extends State<SetDetailScreen> with WidgetsBindingObserver {
  late List<SetEntry> _sets;
  List<ExerciseHistory> _history = [];
  int _selectedSetIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sets = List<SetEntry>.from(widget.sets);
    _loadHistory();
    setProgressNotifier.addListener(_onSetProgressChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    setProgressNotifier.removeListener(_onSetProgressChanged);
    super.dispose();
  }

  void _onSetProgressChanged() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final allHistory = await DataManager.getExerciseHistory();
    setState(() {
      _history = allHistory[widget.exercise.name] ?? [];
    });
  }

  void _updateWeight(int i, double delta) {
    setState(() {
      final set = _sets[i];
      _sets[i] = set.copyWith(actualWeight: (set.actualWeight + delta).clamp(0, 9999));
    });
  }

  void _updateReps(int i, int delta) {
    setState(() {
      final set = _sets[i];
      _sets[i] = set.copyWith(actualReps: (set.actualReps + delta).clamp(0, 99));
    });
  }

  void _completeSet(int i) {
    setState(() {
      _sets[i] = _sets[i].copyWith(isCompleted: true);
    });
    
    // Set tamamlandığında gerçek değerleri kaydet
    final set = _sets[i];
    print('Set ${i + 1} tamamlandı: ${set.actualWeight} kg × ${set.actualReps} tekrar');
    
    // Tüm setler tamamlandı mı kontrol et
    final allCompleted = _sets.every((s) => s.isCompleted);
    print('Tüm setler tamamlandı mı: $allCompleted (${_sets.where((s) => s.isCompleted).length}/${_sets.length})');
  }

  Widget _buildSetDetailHistorySection() {
    final history = _history;
    if (history.isEmpty) {
      return Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
            SizedBox(width: 8),
            Text(
              'Bu egzersiz için henüz geçmiş kaydı yok',
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ],
        ),
      );
    }

    final latest = history.last;
    final previous = history.length > 1 ? history[history.length - 2] : null;
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: Colors.green[600], size: 20),
              SizedBox(width: 8),
              Text(
                'Son Antrenman Geçmişi',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Son antrenman
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'En Son:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text('${latest.weight} kg × ${latest.reps} tekrar'),
                      Text('${latest.sets} set'),
                    ],
                  ),
                ),
                Text(
                  '${latest.date.day}/${latest.date.month}',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Önceki antrenman (varsa)
          if (previous != null) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Önceki:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text('${previous.weight} kg × ${previous.reps} tekrar'),
                        Text('${previous.sets} set'),
                      ],
                    ),
                  ),
                  Text(
                    '${previous.date.day}/${previous.date.month}',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: 8),
          Text(
            'Toplam ${history.length} antrenman kaydı',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _sets.where((s) => s.isCompleted).length;
    final totalCount = _sets.length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.deepPurple),
            ),
            child: Text(
              '$completedCount/$totalCount',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Geçmiş bilgileri
            _buildSetDetailHistorySection(),
            

            
            // Tek blok içinde tüm setler
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: Colors.deepPurple[600],
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Set Detayları',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[700],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$completedCount/$totalCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                                    // İlerleme göstergesi
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.deepPurple[600],
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'İlerleme: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.deepPurple[300]!),
                          ),
                          child: Text(
                            '$completedCount/$totalCount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[700],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '(${((completedCount / totalCount) * 100).toInt()}%)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tek satırda tüm setler
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: List.generate(_sets.length, (i) {
                        final set = _sets[i];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: set.isCompleted ? Colors.green[50] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: set.isCompleted ? Colors.green[300]! : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                // Set numarası
                                SizedBox(
                                  width: 50,
                                  child: Text('Set ${i + 1}/${totalCount}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                                // Ağırlık alanı
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 16),
                                      onPressed: set.isCompleted ? null : () => _updateWeight(i, -2.5),
                                      padding: EdgeInsets.zero,
                              ),
                                    Container(
                                      width: 60,
                                      child: Text(
                                        '${set.actualWeight.toStringAsFixed(1)} kg', 
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: Colors.green, size: 16),
                                      onPressed: set.isCompleted ? null : () => _updateWeight(i, 2.5),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8),
                                // Tekrar alanı
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 16),
                                      onPressed: set.isCompleted ? null : () => _updateReps(i, -1),
                                      padding: EdgeInsets.zero,
                              ),
                                    Container(
                                      width: 40,
                                      child: Text(
                                        '${set.actualReps} x', 
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: Colors.green, size: 16),
                                      onPressed: set.isCompleted ? null : () => _updateReps(i, 1),
                                      padding: EdgeInsets.zero,
                              ),
                                  ],
                                ),
                                SizedBox(width: 8),
                                // Onay/Check
                              if (!set.isCompleted)
                                ElevatedButton(
                                  onPressed: () => _completeSet(i),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                      minimumSize: Size(0, 24),
                                  ),
                                    child: Text(globalLanguage == 'Türkçe' ? 'Onayla' : 'Done', style: TextStyle(fontSize: 10)),
                                ),
                              if (set.isCompleted)
                                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                            ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context, _sets),
        child: const Icon(Icons.save),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildSingleSetSelector(BuildContext context) {
    int totalCount = _sets.length;
    int selectedSet = _selectedSetIndex;
    final set = _sets[selectedSet];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: selectedSet > 0 ? () => setState(() => _selectedSetIndex = selectedSet - 1) : null,
            ),
            Text('Set ${selectedSet + 1}/$totalCount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: selectedSet < totalCount - 1 ? () => setState(() => _selectedSetIndex = selectedSet + 1) : null,
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ağırlık', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: set.isCompleted ? null : () => _updateWeight(selectedSet, -2.5),
            ),
            Text('${set.actualWeight.toStringAsFixed(1)} kg', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: set.isCompleted ? null : () => _updateWeight(selectedSet, 2.5),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tekrar', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: set.isCompleted ? null : () => _updateReps(selectedSet, -1),
            ),
            Text('${set.actualReps}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: set.isCompleted ? null : () => _updateReps(selectedSet, 1),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (!set.isCompleted)
          ElevatedButton(
            onPressed: () => _completeSet(selectedSet),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Onayla', style: TextStyle(fontSize: 16)),
          ),
        if (set.isCompleted)
          Icon(Icons.check_circle, color: Colors.green, size: 28),
      ],
    );
  }
}

// Egzersiz geçmişi için veri yapısı
class ExerciseHistory {
  final String exerciseName;
  final DateTime date;
  final double weight;
  final int reps;
  final int setsCount;
  final List<SetEntry> sets;

  ExerciseHistory({
    required this.exerciseName,
    required this.date,
    required this.weight,
    required this.reps,
    required this.setsCount,
    required this.sets,
  });

  Map<String, dynamic> toJson() => {
      'exerciseName': exerciseName,
      'date': date.toIso8601String(),
      'weight': weight,
      'reps': reps,
    'setsCount': setsCount,
    'sets': sets.map((s) => s.toJson()).toList(),
    };

  factory ExerciseHistory.fromJson(Map<String, dynamic> json) {
    final setsRaw = json['sets'];
    List<SetEntry> setsList;
    int setsCount;
    if (setsRaw is int) {
      // Eski format: sadece set sayısı var, dummy SetEntry listesi oluştur
      setsCount = setsRaw;
      setsList = List.generate(setsCount, (i) => SetEntry(targetReps: json['reps'], targetWeight: (json['weight'] as num).toDouble()));
    } else if (setsRaw is List) {
      setsList = setsRaw.map((e) => SetEntry.fromJson(e)).toList();
      setsCount = setsList.length;
    } else {
      setsList = [];
      setsCount = 0;
    }
    return ExerciseHistory(
      exerciseName: json['exerciseName'],
      date: DateTime.parse(json['date']),
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      setsCount: setsCount,
      sets: setsList,
    );
  }
}

extension SetEntryJson on SetEntry {
  Map<String, dynamic> toJson() => {
    'targetReps': targetReps,
    'targetWeight': targetWeight,
    'actualReps': actualReps,
    'actualWeight': actualWeight,
    'isCompleted': isCompleted,
  };
  static SetEntry fromJson(Map<String, dynamic> json) => SetEntry(
    targetReps: json['targetReps'],
    targetWeight: (json['targetWeight'] as num).toDouble(),
    actualReps: json['actualReps'],
    actualWeight: (json['actualWeight'] as num).toDouble(),
    isCompleted: json['isCompleted'] ?? false,
  );
}

// Sporcu verileri
class AthleteQuote {
  final String name;
  final String imageUrl;
  final String quote;
  final String quoteTurkish;
  final String sport;
  final List<Color> gradientColors;

  AthleteQuote({
    required this.name,
    required this.imageUrl,
    required this.quote,
    required this.quoteTurkish,
    required this.sport,
    required this.gradientColors,
  });
}

final List<AthleteQuote> athleteQuotes = [
  AthleteQuote(
    name: 'Muhammad Ali',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'Impossible is just a big word thrown around by small men who find it easier to live in the world they\'ve been given than to explore the power they have to change it.',
    quoteTurkish: 'İmkansız, sadece küçük adamların attığı büyük bir kelimedir. Onlar verilen dünyada yaşamayı, sahip oldukları gücü keşfetmekten daha kolay bulurlar.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Arnold Schwarzenegger',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'The difference between the impossible and the possible lies in determination.',
    quoteTurkish: 'İmkansız ile mümkün arasındaki fark kararlılıkta yatar.',
    sport: 'Bodybuilding',
    gradientColors: [Colors.purple, Colors.deepPurple, Colors.indigo],
  ),
  AthleteQuote(
    name: 'Michael Jordan',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'I\'ve failed over and over and over again in my life and that is why I succeed.',
    quoteTurkish: 'Hayatımda tekrar tekrar başarısız oldum ve işte bu yüzden başarılıyım.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Usain Bolt',
    imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ff2084a31?auto=format&fit=crop&w=800&q=80',
    quote: 'Don\'t think about the start of the race, think about the ending.',
    quoteTurkish: 'Yarışın başlangıcını düşünme, sonunu düşün.',
    sport: 'Athletics',
    gradientColors: [Colors.green, Colors.teal, Colors.cyan],
  ),
  AthleteQuote(
    name: 'Serena Williams',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'I really think a champion is defined not by their wins but by how they can recover when they fall.',
    quoteTurkish: 'Bir şampiyonun tanımı kazanımları değil, düştüğünde nasıl toparlandığıdır.',
    sport: 'Tennis',
    gradientColors: [Colors.pink, Colors.red, Colors.orange],
  ),
  AthleteQuote(
    name: 'Cristiano Ronaldo',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
    quote: 'Your love makes me strong, your hate makes me unstoppable.',
    quoteTurkish: 'Sevgin beni güçlü yapar, nefretin beni durdurulamaz yapar.',
    sport: 'Football',
    gradientColors: [Colors.orange, Colors.red, Colors.pink],
  ),
  AthleteQuote(
    name: 'Conor McGregor',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'There\'s no talent here, this is hard work. This is an obsession.',
    quoteTurkish: 'Burada yetenek yok, bu sıkı çalışma. Bu bir takıntı.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Kobe Bryant',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Great things come from hard work and perseverance. No excuses.',
    quoteTurkish: 'Büyük şeyler sıkı çalışma ve azimden gelir. Bahane yok.',
    sport: 'Basketball',
    gradientColors: [Colors.purple, Colors.deepPurple, Colors.black],
  ),
  AthleteQuote(
    name: 'Bruce Lee',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'The successful warrior is the average man, with laser-like focus.',
    quoteTurkish: 'Başarılı savaşçı, lazer gibi odaklanmış ortalama bir adamdır.',
    sport: 'Martial Arts',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Muhammad Ali',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'I am the greatest, I said that even before I knew I was.',
    quoteTurkish: 'Ben en büyüğüm, bunu bilmeden önce bile söylerdim.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Michael Phelps',
    imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ff2084a31?auto=format&fit=crop&w=800&q=80',
    quote: 'You can\'t put a limit on anything. The more you dream, the farther you get.',
    quoteTurkish: 'Hiçbir şeye sınır koyamazsın. Ne kadar hayal edersen, o kadar ileri gidersin.',
    sport: 'Swimming',
    gradientColors: [Colors.blue, Colors.cyan, Colors.teal],
  ),
  AthleteQuote(
    name: 'Simone Biles',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'I\'m not the next Usain Bolt or Michael Phelps. I\'m the first Simone Biles.',
    quoteTurkish: 'Ben bir sonraki Usain Bolt veya Michael Phelps değilim. Ben ilk Simone Biles\'ım.',
    sport: 'Gymnastics',
    gradientColors: [Colors.pink, Colors.purple, Colors.indigo],
  ),
  AthleteQuote(
    name: 'Muhammed Ali',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'The man who has no imagination has no wings.',
    quoteTurkish: 'Hayal gücü olmayan insanın kanatları da yoktur.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Michael Jordan',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'I\'ve failed over and over and over again in my life. And that is why I succeed.',
    quoteTurkish: 'Başarısız oldum, tekrar tekrar. Bu yüzden başardım.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Cristiano Ronaldo',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
    quote: 'Talent without working hard is nothing.',
    quoteTurkish: 'Yetenek sadece bir başlangıçtır, çalışmak seni zirveye taşır.',
    sport: 'Football',
    gradientColors: [Colors.orange, Colors.red, Colors.pink],
  ),
  AthleteQuote(
    name: 'Serena Williams',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'I really think a champion is defined not by their wins but by how they can recover when they fall.',
    quoteTurkish: 'Zorluklar beni durdurmadı, tam tersine motive etti.',
    sport: 'Tennis',
    gradientColors: [Colors.pink, Colors.red, Colors.orange],
  ),
  AthleteQuote(
    name: 'Usain Bolt',
    imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ff2084a31?auto=format&fit=crop&w=800&q=80',
    quote: 'Winners never quit and quitters never win.',
    quoteTurkish: 'Kazananlar asla vazgeçmez, vazgeçenler asla kazanamaz.',
    sport: 'Athletics',
    gradientColors: [Colors.green, Colors.teal, Colors.cyan],
  ),
  AthleteQuote(
    name: 'Kobe Bryant',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Mamba Mentality is about being the best version of yourself every single day.',
    quoteTurkish: 'Mamba Mentalitesi: Her gün daha iyi olmaya çalışmaktır.',
    sport: 'Basketball',
    gradientColors: [Colors.purple, Colors.deepPurple, Colors.black],
  ),
  AthleteQuote(
    name: 'Roger Federer',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'You have to believe in the long term plan you have but you need the short term goals to motivate and inspire you.',
    quoteTurkish: 'Başarı; tutku, sabır ve kararlılıkla gelir.',
    sport: 'Tennis',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Lionel Messi',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
    quote: 'You have to fight to reach your dream. You have to sacrifice and work hard for it.',
    quoteTurkish: 'Hayal kurmak zorundasın, sonra o hayali gerçeğe çevirmek için çalışmalısın.',
    sport: 'Football',
    gradientColors: [Colors.orange, Colors.red, Colors.pink],
  ),
  AthleteQuote(
    name: 'Ronda Rousey',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'You have two choices: You can sit and dwell on what was wrong, or you can get up and do something about it.',
    quoteTurkish: 'Hayatta ya bir şeyleri beklersin ya da gidip alırsın.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Michael Phelps',
    imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ff2084a31?auto=format&fit=crop&w=800&q=80',
    quote: 'You can\'t put a limit on anything. The more you dream, the farther you get.',
    quoteTurkish: 'Hayal kurun. Büyük düşünün. Sınırlarınızı zorlayın.',
    sport: 'Swimming',
    gradientColors: [Colors.blue, Colors.cyan, Colors.teal],
  ),
  AthleteQuote(
    name: 'LeBron James',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Hard work beats talent when talent fails to work hard.',
    quoteTurkish: 'Çalışmadan başarı gelmez.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Tom Brady',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'You wanna know which ring is my favorite? The next one.',
    quoteTurkish: 'Başarı; fedakarlık, disiplin ve inançla gelir.',
    sport: 'American Football',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Manny Pacquiao',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'All those who are around me are the bridge to my success, so they are all important.',
    quoteTurkish: 'Tanrı bana bir yetenek verdi, ben de onun hakkını vermek zorundayım.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Novak Djokovic',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'Mental strength is just as important as physical strength.',
    quoteTurkish: 'Zihinsel güç, fiziksel gücün önündedir.',
    sport: 'Tennis',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Conor McGregor',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'Doubt is only removed by action. If you\'re not working then that\'s where doubt comes in.',
    quoteTurkish: 'Başarı benim için bir seçenek değil, zorunluluktur.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Stephen Curry',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Be the best version of yourself in anything you do. You don\'t have to live anybody else\'s story.',
    quoteTurkish: 'Kendine inan. Hiç kimse senin yerine o işi yapamaz.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Shaquille O\'Neal',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Excellence is not a singular act, but a habit. You are what you repeatedly do.',
    quoteTurkish: 'Mazeretler başarısızlığın yapıtaşlarıdır.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Zlatan Ibrahimović',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
    quote: 'I can\'t help but laugh at how perfect I am.',
    quoteTurkish: 'Asla sıradan olma. Kendi yolunu çiz.',
    sport: 'Football',
    gradientColors: [Colors.orange, Colors.red, Colors.pink],
  ),
  AthleteQuote(
    name: 'Khabib Nurmagomedov',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'If you give up once, it becomes a habit. Never give up.',
    quoteTurkish: 'Sadece kazanmak yetmez, nasıl kazandığın da önemlidir.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Andy Murray',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'I don\'t play for the applause, I play for the progress.',
    quoteTurkish: 'Başarı; zorlukların üstesinden gelmektir.',
    sport: 'Tennis',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Tyson Fury',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'You don\'t lose if you get knocked down; you lose if you stay down.',
    quoteTurkish: 'En büyük savaşlarımız kendi içimizdekiyle olur.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Neymar Jr.',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
    quote: 'The secret is to believe in your dreams; in your potential that you can be like your star.',
    quoteTurkish: 'Hayal ediyorsan başarabilirsin.',
    sport: 'Football',
    gradientColors: [Colors.orange, Colors.red, Colors.pink],
  ),
  AthleteQuote(
    name: 'Simone Biles',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'I\'d rather regret the risks that didn\'t work out than the chances I didn\'t take at all.',
    quoteTurkish: 'Kendi gücünün farkına vardığında hiçbir şey imkansız değildir.',
    sport: 'Gymnastics',
    gradientColors: [Colors.pink, Colors.purple, Colors.indigo],
  ),
  AthleteQuote(
    name: 'Andy Roddick',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'At one point in your life, you either have the thing you want or the reasons why you don\'t.',
    quoteTurkish: 'Çalışma etiğiniz karakterinizin yansımasıdır.',
    sport: 'Tennis',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Dirk Nowitzki',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Whatever I try, I always try to give my best.',
    quoteTurkish: 'Tutku, başarıdan daha değerlidir.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Valentino Rossi',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'To be a great motorbike racer, the most important thing is passion for the bike.',
    quoteTurkish: 'En büyük hız cesaretten gelir.',
    sport: 'MotoGP',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Anderson Silva',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'The best fighter is not necessarily the greatest winner, but the one who overcomes the most.',
    quoteTurkish: 'Rakibin en büyük silahı korkudur.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'George St-Pierre',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'I\'m not trying to be better than anyone else. I\'m trying to be better than I was yesterday.',
    quoteTurkish: 'Zayıf olduğun yerleri geliştirmek, gerçek başarıdır.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Floyd Mayweather',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'Hard work and dedication. You have to be willing to sacrifice.',
    quoteTurkish: 'Sıkı çalışma ve adanmışlık. Fedakarlık yapmaya hazır olmalısın.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Rafael Nadal',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'The most important thing is to enjoy your life - to be happy - it\'s all that matters.',
    quoteTurkish: 'En önemli şey hayatından zevk almak - mutlu olmak - tek önemli olan bu.',
    sport: 'Tennis',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
];

// Notification servisi
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // Native custom notification channels
  static const MethodChannel _customNotificationChannel = MethodChannel('custom_workout_notification');
  static const MethodChannel _customCallbacksChannel = MethodChannel('custom_workout_notification_callbacks');
  static bool _callbacksBound = false;
  static String? _lastExerciseName;
  static int _lastCurrentSet = 1;
  static int _lastTotalSets = 1;

  static Future<void> initialize({Function? onSetComplete, Function? onNextExercise}) async {
    if (!_initialized) {
      print('REMINDER_LOG: NotificationService.initialize() start');
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      final nowTz = tz.TZDateTime.now(tz.local);
      print('REMINDER_LOG: Timezone set to ${tz.local}, now=$nowTz');
      // ... mevcut initialize kodu ...
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          print('Notification clicked with payload: \\${response.payload}');
          if (response.payload != null) {
            await NotificationService.handleAdvanceSetAction(response.payload);
          }
        },
      );
      // Reminder kanallarını oluştur
      await _createReminderChannels();
      try {
        final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        final enabled = await androidImpl?.areNotificationsEnabled() ?? null;
        print('REMINDER_LOG: areNotificationsEnabled=$enabled');
      } catch (e) {
        print('REMINDER_LOG: areNotificationsEnabled check error: $e');
      }
      _initialized = true;
      print('REMINDER_LOG: NotificationService.initialize() done');
    }
    // ... mevcut initialize kodu ...
    if (!_callbacksBound) {
      _customCallbacksChannel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'weight_plus':
            await handleAdjustFromNotification(jsonEncode({'exerciseName': _lastExerciseName, 'setIndex': _lastCurrentSet}), deltaWeight: 2.5);
            break;
          case 'weight_minus':
            await handleAdjustFromNotification(jsonEncode({'exerciseName': _lastExerciseName, 'setIndex': _lastCurrentSet}), deltaWeight: -2.5);
            break;
          case 'reps_plus':
            await handleAdjustFromNotification(jsonEncode({'exerciseName': _lastExerciseName, 'setIndex': _lastCurrentSet}), deltaReps: 1);
            break;
          case 'reps_minus':
            await handleAdjustFromNotification(jsonEncode({'exerciseName': _lastExerciseName, 'setIndex': _lastCurrentSet}), deltaReps: -1);
            break;
          case 'save_set':
            await handleAdvanceSetAction(jsonEncode({'exerciseName': _lastExerciseName, 'setIndex': _lastCurrentSet}));
            break;
          case 'close':
            await cancelQuickSetProgressNotification();
            break;
        }
      });
      _callbacksBound = true;
    }
  }

  static Future<bool> _isExactAlarmAllowed() async {
    try {
      final status = await Permission.scheduleExactAlarm.status;
      return status.isGranted;
    } catch (_) {
      // On older Android versions this permission doesn't exist; assume exact allowed.
      return true;
    }
  }

  static Future<void> _createQuickSetProgressChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'quick_set_progress',
      'Hızlı Set İlerlemesi',
      description: 'Telefon ana ekranından hızlı set ilerlemesi',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
    }
  }

  static Future<void> _createReminderChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return;
    const AndroidNotificationChannel weightChannel = AndroidNotificationChannel(
      'weight_reminder_channel',
      'Tartılma Hatırlatıcı Kanalı',
      description: 'Zamanlanmış tartılma hatırlatıcıları',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    const AndroidNotificationChannel waterChannel = AndroidNotificationChannel(
      'water_reminder_channel',
      'Su Hatırlatıcı Kanalı',
      description: 'Periyodik su hatırlatıcıları',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    await androidImpl.createNotificationChannel(weightChannel);
    await androidImpl.createNotificationChannel(waterChannel);
  }

  // Debug amaçlı: kısa gecikmeli test bildirimi
  static Future<void> showDebugNotificationIn(Duration delay) async {
    await initialize();
    // Immediate show to validate channel and permission
    await _notifications.show(
      7776,
      'Test Bildirimi',
      'Bu bir test bildirimidir (anlık)',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weight_reminder_channel',
          'Tartılma Hatırlatıcı Kanalı',
          channelDescription: 'Zamanlanmış tartılma hatırlatıcıları',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_launcher_foreground',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    // Also schedule one after a short delay
    final when = tz.TZDateTime.now(tz.local).add(delay);
    await _notifications.zonedSchedule(
      7777,
      'Test Bildirimi',
      'Bu bir test bildirimidir (gecikmeli)',
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weight_reminder_channel',
          'Tartılma Hatırlatıcı Kanalı',
          channelDescription: 'Zamanlanmış tartılma hatırlatıcıları',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_launcher_foreground',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> scheduleWeightReminder({
    required TimeOfDay time,
    required String frequency,
  }) async {
    await initialize();
    final exactAllowed = await _isExactAlarmAllowed();
    final AndroidScheduleMode chosenMode = exactAllowed
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.alarmClock;
    // Cancel any existing WorkManager task to avoid duplicates
    await Workmanager().cancelByUniqueName('weight_reminder');
    final nowTz = tz.TZDateTime.now(tz.local);
    tz.TZDateTime first = tz.TZDateTime(
      tz.local,
      nowTz.year,
      nowTz.month,
      nowTz.day,
      time.hour,
      time.minute,
    );
    if (!first.isAfter(nowTz)) {
      first = first.add(const Duration(days: 1));
    }

    DateTimeComponents? repeatComponents;
    if (frequency.toLowerCase().contains('hafta')) {
      repeatComponents = DateTimeComponents.dayOfWeekAndTime;
    } else if (frequency.toLowerCase().contains('ay')) {
      repeatComponents = DateTimeComponents.dayOfMonthAndTime;
    } else {
      // default: every day at selected time
      repeatComponents = DateTimeComponents.time;
    }
    print('REMINDER_LOG: scheduleWeightReminder first=$first, freq=$frequency, repeat=$repeatComponents');
    await _notifications.zonedSchedule(
      2001,
      'Tartılma Hatırlatıcısı',
      'Bugün tartılma zamanınız geldi! Kilo takibinizi yapmayı unutmayın.',
      first,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'weight_reminder_channel',
          'Tartılma Hatırlatıcı Kanalı',
          channelDescription: 'Zamanlanmış tartılma hatırlatıcıları',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_launcher_foreground',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: chosenMode,
      matchDateTimeComponents: repeatComponents,
    );
    // Background fallback via WorkManager (redundant delivery)
    try {
      final delay = first.difference(nowTz);
      await Workmanager().registerOneOffTask(
        'weight_reminder',
        'weightReminderTask',
        initialDelay: delay,
        inputData: {
          'title': 'Tartılma Hatırlatıcısı',
          'body': 'Bugün tartılma zamanınız geldi! Kilo takibinizi yapmayı unutmayın.',
          'hour': time.hour,
          'minute': time.minute,
          'frequency': (repeatComponents == DateTimeComponents.dayOfWeekAndTime) ? 'Haftalık' : 'Günlük',
        },
      );
      print('REMINDER_LOG: WorkManager one-off weight scheduled with delay=$delay');
    } catch (e) {
      print('REMINDER_LOG: WorkManager weight schedule error: $e');
    }
    try {
      final pending = await _notifications.pendingNotificationRequests();
      print('REMINDER_LOG: pending after weight schedule: count=${pending.length}; ids=${pending.map((e) => e.id).toList()}');
    } catch (e) {
      print('REMINDER_LOG: pending check error (weight): $e');
    }
  }

  static Future<void> scheduleWaterReminder({
    required TimeOfDay time,
    required String interval,
  }) async {
    await initialize();
    final exactAllowed = await _isExactAlarmAllowed();
    final AndroidScheduleMode chosenMode = exactAllowed
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.alarmClock;
    // Cancel periodic WorkManager tasks to avoid duplicates
    await Workmanager().cancelByUniqueName('water_reminder_task_id');
    await Workmanager().cancelByUniqueName('water_reminder');

    // Parse interval hours (e.g., "2 saat")
    int intervalHours = 2;
    final match = RegExp(r'(\d+)').firstMatch(interval);
    if (match != null) {
      intervalHours = int.tryParse(match.group(1) ?? '2') ?? 2;
    }

    // Compute daily times across the day starting from selected time
    final nowTz = tz.TZDateTime.now(tz.local);
    final times = <tz.TZDateTime>[];
    tz.TZDateTime cursor = tz.TZDateTime(tz.local, nowTz.year, nowTz.month, nowTz.day, time.hour, time.minute);
    // Generate occurrences for up to 24 hours window
    for (int i = 0; i < (24 / intervalHours).ceil(); i++) {
      if (!cursor.isBefore(nowTz)) {
        times.add(cursor);
      }
      cursor = cursor.add(Duration(hours: intervalHours));
    }
    print('REMINDER_LOG: scheduleWaterReminder intervalHours=$intervalHours times=${times.join(', ')}');

    // Schedule notifications for computed times (today), and rely on matchDateTimeComponents.time for daily repetition
    int baseId = 3000;
    tz.TZDateTime? firstUpcoming;
    for (final when in times) {
      firstUpcoming ??= when;
      await _notifications.zonedSchedule(
        baseId,
        'Su İçmeyi Unutma!',
        'Sağlığın için su içmeyi ihmal etme.',
        when,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminder_channel',
            'Su Hatırlatıcı Kanalı',
            channelDescription: 'Periyodik su hatırlatıcıları',
            importance: Importance.max,
            priority: Priority.high,
          icon: '@drawable/ic_launcher_foreground',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: chosenMode,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      baseId++;
    }
    // Background periodic fallback via WorkManager
    try {
      await scheduleWaterReminderTask();
      print('REMINDER_LOG: WorkManager periodic water scheduled');
    } catch (e) {
      print('REMINDER_LOG: WorkManager water schedule error: $e');
    }
    // One-off fallback for the first upcoming water time (extra safety)
    try {
      final now = tz.TZDateTime.now(tz.local);
      final upcoming = firstUpcoming ??
          tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute)
              .add(const Duration(minutes: 1));
      final delay = upcoming.difference(now);
      await Workmanager().registerOneOffTask(
        'water_reminder_once',
        'waterReminderTask',
        initialDelay: delay,
      );
      print('REMINDER_LOG: WorkManager one-off water scheduled with delay=$delay');
    } catch (e) {
      print('REMINDER_LOG: WorkManager one-off water schedule error: $e');
    }
    try {
      final pending = await _notifications.pendingNotificationRequests();
      print('REMINDER_LOG: pending after water schedule: count=${pending.length}; ids=${pending.map((e) => e.id).toList()}');
    } catch (e) {
      print('REMINDER_LOG: pending check error (water): $e');
    }
  }

  static Future<void> cancelWeightReminder() async {
    await Workmanager().cancelByUniqueName('weight_reminder');
    await _notifications.cancel(1);
  }

  static Future<void> cancelWaterReminder() async {
    // Cancel possible IDs for water reminder
    for (int id = 3000; id < 3024; id++) {
      await _notifications.cancel(id);
    }
    await Workmanager().cancelByUniqueName('water_reminder_task_id');
    await Workmanager().cancelByUniqueName('water_reminder');
  }

  static Future<void> requestPermissions({bool askExactAlarm = false, bool askIgnoreBatteryOptimizations = false}) async {
    await initialize();
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    // Bildirim izni
    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      if (granted == true) {
        print('Bildirim izinleri verildi');
      } else {
        print('Bildirim izinleri reddedildi');
      }
    }

    // Android 13+ için bildirim izni
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      print('Notification permission status: $status');
    }
    // Bu ikisi kullanıcının açıkça talep ettiği durumda istenir
    if (askExactAlarm && await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      print('Exact alarm permission status: $status');
    }
    if (askIgnoreBatteryOptimizations && await Permission.ignoreBatteryOptimizations.isDenied) {
      final status = await Permission.ignoreBatteryOptimizations.request();
      print('Battery optimization ignore permission status: $status');
    }
  }

  // Hızlı set ilerlemesi için notification göster
  static Future<void> showQuickSetProgressNotification({
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    required double weight,
    required int reps,
  }) async {
    // Eski Flutter bildirimini göstermeyelim; her yerde native custom bildirime yönlendir
    await showCustomWorkoutNotification(
      exerciseName: exerciseName,
      currentSet: currentSet,
      totalSets: totalSets,
      weight: weight,
      reps: reps,
    );
  }

  // Custom RemoteViews bildirimini native taraftan göster
  static Future<void> showCustomWorkoutNotification({
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    required double weight,
    required int reps,
  }) async {
    await initialize();
    _lastExerciseName = exerciseName;
    _lastCurrentSet = currentSet;
    _lastTotalSets = totalSets;
    try {
      print('CustomNotif: invoking native showWorkoutNotification -> $exerciseName $currentSet/$totalSets, $weight kg x $reps');
      await _customNotificationChannel.invokeMethod('showWorkoutNotification', {
        'exerciseName': exerciseName,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'weight': weight,
        'reps': reps,
      });
      print('CustomNotif: native invocation ok');
    } catch (e) {
      print('CustomNotif error -> falling back: $e');
      await showQuickSetProgressNotification(
        exerciseName: exerciseName,
        currentSet: currentSet,
        totalSets: totalSets,
        weight: weight,
        reps: reps,
      );
    }
  }

  // Hızlı set ilerlemesi notification'ını kapat
  static Future<void> cancelQuickSetProgressNotification() async {
    await _notifications.cancel(100);
  }

  static Future<void> showImmediateTestNotification() async {
    await initialize();
    print('showImmediateTestNotification çağrıldı');
    await flutterLocalNotificationsPlugin.show(
      9999,
      'Test Bildirimi',
      'Bu bir test bildirimi!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Kanalı',
          channelDescription: 'Test için anlık bildirim kanalı',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> showZonedTestNotification() async {
    await initialize();
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(const Duration(seconds: 10));
    print('showZonedTestNotification çağrıldı, scheduled: $scheduled');
    await flutterLocalNotificationsPlugin.zonedSchedule(
      8888,
      'Zoned Test Bildirimi',
      'Bu bildirim 10 sn sonra zonedSchedule ile geldi!',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'zoned_test_channel',
          'Zoned Test Kanalı',
          channelDescription: 'Zoned test için kanal',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> handleAdvanceSetAction(String? payload) async {
    print('handleAdvanceSetAction called with payload: $payload');
    if (payload == null) return;
    try {
      final data = jsonDecode(payload);
      final exerciseName = data['exerciseName'];
      final setIndex = data['setIndex'];
      await DataManager.markSetAsCompleted(exerciseName, setIndex);
      eventBus.fire(SetProgressedEvent(exerciseName, setIndex));
      print('Set ilerletildi ve kaydedildi: $exerciseName, set $setIndex');
    } catch (e) {
      print('Set ilerletme action payload parse hatası: $e');
    }
  }

  static Future<void> handleAdjustFromNotification(String? payload, {double deltaWeight = 0, int deltaReps = 0}) async {
    print('handleAdjustFromNotification called with payload: $payload, deltaWeight: $deltaWeight, deltaReps: $deltaReps');
    if (payload == null) return;
    try {
      final data = jsonDecode(payload);
      final exerciseName = data['exerciseName'];
      final setIndex = data['setIndex'];
      await DataManager.adjustSetWeightReps(exerciseName, setIndex, deltaWeight, deltaReps);
      eventBus.fire(SetAdjustedEvent(exerciseName, setIndex, deltaWeight, deltaReps));
            print('Set ağırlığı veya tekrarı ayarlandı: $exerciseName, set $setIndex, deltaWeight: $deltaWeight, deltaReps: $deltaReps');

      // Güncellenmiş değerlerle bildirim metnini tazele
      final history = await DataManager.getExerciseHistory();
      final key = exerciseName.toString().trim().toLowerCase();
      if (history.containsKey(key) && history[key]!.isNotEmpty) {
        final last = history[key]!.last;
        final totalSets = last.sets.length;
        final clampedIndex = (setIndex as int).clamp(1, totalSets);
        final set = last.sets[clampedIndex - 1];
        final weight = (set.actualWeight ?? set.targetWeight ?? 0).toDouble();
        final reps = (set.actualReps ?? set.targetReps ?? 1);
        await NotificationService.showCustomWorkoutNotification(
          exerciseName: exerciseName,
          currentSet: clampedIndex,
          totalSets: totalSets,
          weight: weight,
          reps: reps,
        );
      }
    } catch (e) {
      print('Set ayarlama action payload parse hatası: $e');
    }
  }
}

// Custom painter for the routine icon (dumbbell)
class RoutineIconPainter extends CustomPainter {
  final Color? color;
  
  RoutineIconPainter({this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final iconColor = color ?? Color(0xFF60A5FA); // Varsayılan açık mavi
    
    // Dumbbell weight plates paint - same color as other icons
    final weightPlatePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = iconColor;
    
    // Weight plate highlight paint - lighter version of icon color
    final weightPlateHighlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = iconColor.withOpacity(0.7);
    
    // Connecting bar paint - same color as other icons
    final barPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = iconColor;

    // Draw dumbbell (centered) - bigger size
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final dumbbellSize = size.width * 0.75; // Increased from 0.6 to 0.75
    
    // Left weight plates (2 plates)
    final plateWidth = dumbbellSize * 0.15;
    final plateHeight = dumbbellSize * 0.8;
    final leftPlatesLeft = centerX - dumbbellSize * 0.4;
    final platesTop = centerY - plateHeight * 0.5;
    
    // Left outer plate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(leftPlatesLeft, platesTop, plateWidth, plateHeight),
        Radius.circular(plateWidth * 0.5),
      ),
      weightPlatePaint,
    );
    
    // Left inner plate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(leftPlatesLeft + plateWidth * 0.8, platesTop, plateWidth, plateHeight),
        Radius.circular(plateWidth * 0.5),
      ),
      weightPlatePaint,
    );
    
    // Left plates highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(leftPlatesLeft + plateWidth * 0.6, platesTop, plateWidth * 0.3, plateHeight),
        Radius.circular(plateWidth * 0.5),
      ),
      weightPlateHighlightPaint,
    );
    
    // Right weight plates (2 plates)
    final rightPlatesLeft = centerX + dumbbellSize * 0.25;
    
    // Right outer plate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rightPlatesLeft + plateWidth * 0.8, platesTop, plateWidth, plateHeight),
        Radius.circular(plateWidth * 0.5),
      ),
      weightPlatePaint,
    );
    
    // Right inner plate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rightPlatesLeft, platesTop, plateWidth, plateHeight),
        Radius.circular(plateWidth * 0.5),
      ),
      weightPlatePaint,
    );
    
    // Right plates highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rightPlatesLeft + plateWidth * 0.1, platesTop, plateWidth * 0.3, plateHeight),
        Radius.circular(plateWidth * 0.5),
      ),
      weightPlateHighlightPaint,
    );
    
    // Connecting bar
    final barWidth = dumbbellSize * 0.5;
    final barHeight = dumbbellSize * 0.25;
    final barLeft = centerX - barWidth * 0.5;
    final barTop = centerY - barHeight * 0.5;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, barTop, barWidth, barHeight),
        Radius.circular(barHeight * 0.5),
      ),
      barPaint,
    );
    
    // End caps (small stoppers)
    final capWidth = dumbbellSize * 0.08;
    final capHeight = dumbbellSize * 0.2;
    
    // Left end cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft - capWidth * 0.5, barTop + (barHeight - capHeight) / 2, capWidth, capHeight),
        Radius.circular(capWidth * 0.5),
      ),
      barPaint,
    );
    
    // Right end cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft + barWidth - capWidth * 0.5, barTop + (barHeight - capHeight) / 2, capWidth, capHeight),
        Radius.circular(capWidth * 0.5),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for the calculate icon (calculator + equals sign)
class CalculateIconPainter extends CustomPainter {
  final Color? color;
  
  CalculateIconPainter({this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Color baseBlue = color ?? const Color(0xFF5366FF);
    final Rect fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Shadow/background
    final RRect outer = RRect.fromRectAndRadius(
      fullRect.deflate(size.width * 0.20),
      Radius.circular(size.width * 0.12),
    );
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.save();
    canvas.translate(0, size.height * 0.02);
    canvas.drawRRect(outer, shadowPaint);
    canvas.restore();

    // Calculator body (blue gradient)
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          baseBlue.withOpacity(0.95),
          const Color(0xFF3F51F7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(fullRect);
    final Paint bodyStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..color = Colors.black.withOpacity(0.6);
    canvas.drawRRect(outer, bodyPaint);
    canvas.drawRRect(outer, bodyStroke);

    // Inner padding for grid
    final double pad = size.width * 0.10;
    final Rect gridRect = Rect.fromLTWH(
      outer.left + pad,
      outer.top + pad,
      outer.width - pad * 2,
      outer.height - pad * 2,
    );

    // Grid lines (1 vertical, 1 horizontal)
    final Paint gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..color = Colors.black.withOpacity(0.45)
      ..strokeCap = StrokeCap.round;
    final double midX = gridRect.left + gridRect.width / 2;
    final double midY = gridRect.top + gridRect.height / 2;
    canvas.drawLine(Offset(midX, gridRect.top), Offset(midX, gridRect.bottom), gridPaint);
    canvas.drawLine(Offset(gridRect.left, midY), Offset(gridRect.right, midY), gridPaint);

    // Symbol paint (white with slight shadow)
    final Paint symbolPaint = Paint()..color = Colors.white;
    final Paint symbolShadow = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Helper to draw rounded bar
    void bar(Rect r) {
      final RRect rr = RRect.fromRectAndRadius(r, Radius.circular(r.height / 2));
      canvas.drawRRect(rr.shift(const Offset(0, 1)), symbolShadow);
      canvas.drawRRect(rr, symbolPaint);
    }

    // Cell rects
    final Rect tl = Rect.fromLTWH(gridRect.left, gridRect.top, gridRect.width / 2, gridRect.height / 2);
    final Rect tr = Rect.fromLTWH(midX, gridRect.top, gridRect.width / 2, gridRect.height / 2);
    final Rect bl = Rect.fromLTWH(gridRect.left, midY, gridRect.width / 2, gridRect.height / 2);

    // Plus in top-left
    final double plusW = tl.width * 0.78;
    final double plusH = tl.height * 0.32;
    final double cxTL = tl.center.dx;
    final double cyTL = tl.center.dy;
    bar(Rect.fromCenter(center: Offset(cxTL, cyTL), width: plusW, height: plusH));
    bar(Rect.fromCenter(center: Offset(cxTL, cyTL), width: plusH, height: plusW));

    // Minus in top-right
    final double minusW = tr.width * 0.78;
    final double minusH = tr.height * 0.32;
    bar(Rect.fromCenter(center: tr.center, width: minusW, height: minusH));

    // Multiply in bottom-left (X)
    final double xLen = bl.width * 0.78;
    final double xBar = bl.height * 0.30;
    final Offset cBL = bl.center;
    final Rect xRect = Rect.fromCenter(center: cBL, width: xLen, height: xBar);
    canvas.save();
    canvas.translate(cBL.dx, cBL.dy);
    canvas.rotate(45 * 3.1415926535 / 180);
    bar(Rect.fromCenter(center: Offset(0, 0), width: xLen, height: xBar));
    canvas.rotate(90 * 3.1415926535 / 180);
    bar(Rect.fromCenter(center: Offset(0, 0), width: xLen, height: xBar));
    canvas.restore();

    // Orange equals badge (bottom-right overlap)
    final double badgeSize = size.width * 0.40;
    final Offset badgeCenter = Offset(size.width * 0.60, size.height * 0.73);

    // Badge shadow
    final Paint badgeShadow = Paint()
      ..color = Colors.black.withOpacity(0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(badgeCenter.translate(0, size.height * 0.02), badgeSize * 0.5, badgeShadow);

    // Badge circle
    final Paint badgePaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFFFFB74D), const Color(0xFFFF9800)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: badgeCenter, radius: badgeSize * 0.5));
    final Paint badgeStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..color = Colors.black.withOpacity(0.8);
    canvas.drawCircle(badgeCenter, badgeSize * 0.5, badgePaint);
    canvas.drawCircle(badgeCenter, badgeSize * 0.5, badgeStroke);

    // Equals sign in badge
    final double eqW = badgeSize * 0.48;
    final double eqH = badgeSize * 0.11;
    final double eqGap = badgeSize * 0.16;
    bar(Rect.fromCenter(center: badgeCenter.translate(0, -eqGap / 2), width: eqW, height: eqH));
    bar(Rect.fromCenter(center: badgeCenter.translate(0, eqGap / 2), width: eqW, height: eqH));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for the statistics icon (bar chart)
class StatisticsIconPainter extends CustomPainter {
  final Color? color;
  
  StatisticsIconPainter({this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final iconColor = color ?? Color(0xFF60A5FA); // Varsayılan açık mavi
    
    // Bar chart paint - gradient from light blue to dark blue
    final barPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          iconColor.withOpacity(0.3), // Light tone (top)
          iconColor, // Medium tone (middle)
          iconColor.withOpacity(0.7), // Dark tone (bottom)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Bar chart outline paint - dark blue
    final barOutlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Color(0xFF2563EB); // Dark blue outline
    
    // Base line paint - same gradient as bars
    final baseLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..shader = LinearGradient(
        colors: [
          Color(0xFFDBEAFE), // Light blue (left)
          Color(0xFF60A5FA), // Medium blue (middle)
          Color(0xFF2563EB), // Dark blue (right)
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw base line (horizontal)
    final baseLineY = size.height * 0.8;
    final baseLineWidth = size.width * 0.9;
    final baseLineLeft = (size.width - baseLineWidth) / 2;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(baseLineLeft, baseLineY, baseLineWidth, 3.0),
        Radius.circular(1.5),
      ),
      baseLinePaint,
    );
    
    // Draw three bars with different heights
    final barWidth = size.width * 0.15;
    final barSpacing = size.width * 0.1;
    final barsStartX = (size.width - (barWidth * 3 + barSpacing * 2)) / 2;
    
    // Left bar (medium height)
    final leftBarHeight = size.height * 0.4;
    final leftBarLeft = barsStartX;
    final leftBarTop = baseLineY - leftBarHeight;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(leftBarLeft, leftBarTop, barWidth, leftBarHeight),
        Radius.circular(4.0),
      ),
      barPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(leftBarLeft, leftBarTop, barWidth, leftBarHeight),
        Radius.circular(4.0),
      ),
      barOutlinePaint,
    );
    
    // Middle bar (tallest)
    final middleBarHeight = size.height * 0.6;
    final middleBarLeft = barsStartX + barWidth + barSpacing;
    final middleBarTop = baseLineY - middleBarHeight;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(middleBarLeft, middleBarTop, barWidth, middleBarHeight),
        Radius.circular(4.0),
      ),
      barPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(middleBarLeft, middleBarTop, barWidth, middleBarHeight),
        Radius.circular(4.0),
      ),
      barOutlinePaint,
    );
    
    // Right bar (medium-tall)
    final rightBarHeight = size.height * 0.5;
    final rightBarLeft = barsStartX + (barWidth + barSpacing) * 2;
    final rightBarTop = baseLineY - rightBarHeight;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rightBarLeft, rightBarTop, barWidth, rightBarHeight),
        Radius.circular(4.0),
      ),
      barPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rightBarLeft, rightBarTop, barWidth, rightBarHeight),
        Radius.circular(4.0),
      ),
      barOutlinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for the profile icon (person + menu lines)
class ProfileIconPainter extends CustomPainter {
  final Color? color;
  
  ProfileIconPainter({this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final iconColor = color ?? Color(0xFF60A5FA); // Varsayılan açık mavi
    
    // Person icon paint - gradient from light blue to dark blue
    final personPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          iconColor.withOpacity(0.3), // Light tone (top)
          iconColor, // Medium tone (middle)
          iconColor.withOpacity(0.7), // Dark tone (bottom)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Person outline paint - dark blue
    final personOutlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Color(0xFF2563EB); // Dark blue outline
    
    // Menu lines paint - same gradient as person
    final menuLinesPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          Color(0xFFDBEAFE), // Light blue (top)
          Color(0xFF60A5FA), // Medium blue (middle)
          Color(0xFF2563EB), // Dark blue (bottom)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw person icon (head + shoulders)
    // Head (circle)
    final headSize = size.width * 0.25;
    final headLeft = size.width * 0.2;
    final headTop = size.height * 0.15;
    
    canvas.drawCircle(
      Offset(headLeft + headSize * 0.5, headTop + headSize * 0.5),
      headSize * 0.5,
      personPaint,
    );
    canvas.drawCircle(
      Offset(headLeft + headSize * 0.5, headTop + headSize * 0.5),
      headSize * 0.5,
      personOutlinePaint,
    );
    
    // Shoulders (curved shape)
    final shouldersWidth = size.width * 0.35;
    final shouldersHeight = size.height * 0.25;
    final shouldersLeft = headLeft - (shouldersWidth - headSize) / 2;
    final shouldersTop = headTop + headSize * 0.8;
    
    final shouldersPath = Path();
    shouldersPath.moveTo(shouldersLeft, shouldersTop + shouldersHeight * 0.3);
    shouldersPath.quadraticBezierTo(
      shouldersLeft + shouldersWidth * 0.5, shouldersTop,
      shouldersLeft + shouldersWidth, shouldersTop + shouldersHeight * 0.3,
    );
    shouldersPath.lineTo(shouldersLeft + shouldersWidth, shouldersTop + shouldersHeight);
    shouldersPath.quadraticBezierTo(
      shouldersLeft + shouldersWidth * 0.5, shouldersTop + shouldersHeight * 0.8,
      shouldersLeft, shouldersTop + shouldersHeight,
    );
    shouldersPath.close();
    
    canvas.drawPath(shouldersPath, personPaint);
    canvas.drawPath(shouldersPath, personOutlinePaint);
    
    // Draw menu lines (three horizontal bars)
    final menuLinesWidth = size.width * 0.4;
    final menuLinesHeight = size.height * 0.08;
    final menuLinesLeft = size.width * 0.55;
    final menuLinesStartY = size.height * 0.25;
    final menuLinesSpacing = size.height * 0.12;
    
    // Top line (longest)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(menuLinesLeft, menuLinesStartY, menuLinesWidth, menuLinesHeight),
        Radius.circular(menuLinesHeight * 0.5),
      ),
      menuLinesPaint,
    );
    
    // Middle line (medium)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(menuLinesLeft, menuLinesStartY + menuLinesSpacing, menuLinesWidth * 0.85, menuLinesHeight),
        Radius.circular(menuLinesHeight * 0.5),
      ),
      menuLinesPaint,
    );
    
    // Bottom line (shortest)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(menuLinesLeft, menuLinesStartY + menuLinesSpacing * 2, menuLinesWidth * 0.7, menuLinesHeight),
        Radius.circular(menuLinesHeight * 0.5),
      ),
      menuLinesPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Test için bir buton ile 1 dakika sonrasına arka planda bildirim planla
class WorkManagerTestButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        print('WorkManager ile 1 dk sonra arka planda bildirim planlanıyor...');
        await Workmanager().registerOneOffTask(
          "uniqueName",
          "reminderTask",
          initialDelay: Duration(minutes: 1),
        );
      },
      child: Text('WorkManager: 1 dk Sonra Bildirim'),
    );
  }
}

// Global ValueNotifier
final ValueNotifier<int> setProgressNotifier = ValueNotifier<int>(0);

// GÜNÜN TÜM EGZERSİZLERİ VE SETLERİ KAYDEDİLDİ Mİ?
bool _isWorkoutCompletedForDay(String dayName, Map<String, List<RoutineEntry>> weeklyRoutine, Map<String, List<ExerciseHistory>> exerciseHistory) {
  final entries = weeklyRoutine[dayName] ?? [];
  for (final entry in entries) {
    final historyList = exerciseHistory[entry.exercise.name.toLowerCase()] ?? [];
    // O günün egzersizinin toplam set sayısı
    final totalSets = entry.sets.length;
    // O egzersiz için geçmişteki kayıt sayısı
    final completedSets = historyList.length;
    if (completedSets < totalSets) {
      return false;
    }
  }
  return true;
}


