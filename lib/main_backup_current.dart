import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'event_bus.dart';
// import 'detail.dart';
// import 'hesapla.dart';
// import 'profile.dart';
// import 'statistics.dart';

// Veri sınıfları
class RoutineEntry {
  final String name;
  final String muscleGroup;
  final List<SetData> sets;
  final String? notes;
  final int setCount;

  RoutineEntry({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    this.notes,
  }) : setCount = sets.length;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'sets': sets.map((set) => set.toJson()).toList(),
      'notes': notes,
    };
  }

  factory RoutineEntry.fromJson(Map<String, dynamic> json) {
    return RoutineEntry(
      name: json['name'],
      muscleGroup: json['muscleGroup'],
      sets: (json['sets'] as List).map((set) => SetData.fromJson(set)).toList(),
      notes: json['notes'],
    );
  }
}

class SetData {
  final int setNumber;
  final double weight;
  final int reps;
  final String? notes;
  final bool isCompleted;
  final double? actualWeight;
  final int? actualReps;

  SetData({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.notes,
    this.isCompleted = false,
    this.actualWeight,
    this.actualReps,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'notes': notes,
      'isCompleted': isCompleted,
      'actualWeight': actualWeight,
      'actualReps': actualReps,
    };
  }

  factory SetData.fromJson(Map<String, dynamic> json) {
    return SetData(
      setNumber: json['setNumber'],
      weight: json['weight'],
      reps: json['reps'],
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
      actualWeight: json['actualWeight'],
      actualReps: json['actualReps'],
    );
  }
}

class ExerciseHistory {
  final String exerciseName;
  final String muscleGroup;
  final DateTime date;
  final List<SetData> sets;
  final String? notes;
  final int setsCount;

  ExerciseHistory({
    required this.exerciseName,
    required this.muscleGroup,
    required this.date,
    required this.sets,
    this.notes,
  }) : setsCount = sets.length;

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'muscleGroup': muscleGroup,
      'date': date.toIso8601String(),
      'sets': sets.map((set) => set.toJson()).toList(),
      'notes': notes,
    };
  }

  factory ExerciseHistory.fromJson(Map<String, dynamic> json) {
    return ExerciseHistory(
      exerciseName: json['exerciseName'],
      muscleGroup: json['muscleGroup'],
      date: DateTime.parse(json['date']),
      sets: (json['sets'] as List).map((set) => SetData.fromJson(set)).toList(),
      notes: json['notes'],
    );
  }
}

class AthleteQuote {
  final String name;
  final String quote;

  AthleteQuote({required this.name, required this.quote});
}

// Sporcu alıntıları
final List<AthleteQuote> athleteQuotes = [
  AthleteQuote(
    name: 'Arnold Schwarzenegger',
    quote: 'The difference between the impossible and the possible lies in determination.',
  ),
  AthleteQuote(
    name: 'Muhammad Ali',
    quote: 'Don\'t count the days, make the days count.',
  ),
  AthleteQuote(
    name: 'Michael Jordan',
    quote: 'I\'ve failed over and over and over again in my life and that is why I succeed.',
  ),
  AthleteQuote(
    name: 'Usain Bolt',
    quote: 'Don\'t think about the start of the race, think about the ending.',
  ),
  AthleteQuote(
    name: 'Serena Williams',
    quote: 'I really think a champion is defined not by their wins but by how they can recover when they fall.',
  ),
  AthleteQuote(
    name: 'Cristiano Ronaldo',
    quote: 'Your love makes me strong, your hate makes me unstoppable.',
  ),
  AthleteQuote(
    name: 'LeBron James',
    quote: 'I like criticism. It makes you strong.',
  ),
  AthleteQuote(
    name: 'Kobe Bryant',
    quote: 'Great things come from hard work and perseverance. No excuses.',
  ),
  AthleteQuote(
    name: 'Lionel Messi',
    quote: 'You have to fight to reach your dream. You have to sacrifice and work hard for it.',
  ),
  AthleteQuote(
    name: 'Roger Federer',
    quote: 'I always believe I can win every match I play.',
  ),
];

// DataManager sınıfı
class DataManager {
  static Future<Map<String, List<RoutineEntry>>> getWeeklyRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    final routineString = prefs.getString('weekly_routine');
    if (routineString != null && routineString.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = json.decode(routineString);
        return decoded.map((key, value) => MapEntry(
          key,
          (value as List).map((item) => RoutineEntry.fromJson(item)).toList(),
        ));
      } catch (e) {
        print('Error parsing weekly routine: $e');
        return {};
      }
    }
    return {};
  }

  static Future<void> saveWeeklyRoutine(Map<String, List<RoutineEntry>> routine) async {
    final prefs = await SharedPreferences.getInstance();
    final routineString = json.encode(routine.map((key, value) => MapEntry(
      key,
      value.map((item) => item.toJson()).toList(),
    )));
    await prefs.setString('weekly_routine', routineString);
  }

  static Future<Map<String, List<RoutineEntry>>> getCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final completedString = prefs.getString('completed_workouts');
    if (completedString != null) {
      final Map<String, dynamic> decoded = json.decode(completedString);
      return decoded.map((key, value) => MapEntry(
        key,
        (value as List).map((item) => RoutineEntry.fromJson(item)).toList(),
      ));
    }
    return {};
  }

  static Future<void> saveCompletedWorkouts(Map<String, List<RoutineEntry>> completed) async {
    final prefs = await SharedPreferences.getInstance();
    final completedString = json.encode(completed.map((key, value) => MapEntry(
      key,
      value.map((item) => item.toJson()).toList(),
    )));
    await prefs.setString('completed_workouts', completedString);
  }

  static Future<Map<String, List<ExerciseHistory>>> getExerciseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('exercise_history');
    if (historyString != null) {
      final Map<String, dynamic> decoded = json.decode(historyString);
      return decoded.map((key, value) => MapEntry(
        key,
        (value as List).map((item) => ExerciseHistory.fromJson(item)).toList(),
      ));
    }
    return {};
  }

  static Future<void> saveExerciseHistory(Map<String, List<ExerciseHistory>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = json.encode(history.map((key, value) => MapEntry(
      key,
      value.map((item) => item.toJson()).toList(),
    )));
    await prefs.setString('exercise_history', historyString);
  }

  static Future<Map<String, DateTime>> getLastCompletedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final datesString = prefs.getString('last_completed_dates');
    if (datesString != null) {
      final Map<String, dynamic> decoded = json.decode(datesString);
      return decoded.map((key, value) => MapEntry(
        key,
        DateTime.parse(value),
      ));
    }
    return {};
  }

  static Future<void> saveLastCompletedDates(Map<String, DateTime> dates) async {
    final prefs = await SharedPreferences.getInstance();
    final datesString = json.encode(dates.map((key, value) => MapEntry(
      key,
      value.toIso8601String(),
    )));
    await prefs.setString('last_completed_dates', datesString);
  }

  static Future<Map<String, String>> getOriginalDayNames() async {
    final prefs = await SharedPreferences.getInstance();
    final namesString = prefs.getString('original_day_names');
    if (namesString != null) {
      final Map<String, dynamic> decoded = json.decode(namesString);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }

  static Future<void> saveOriginalDayNames(Map<String, String> names) async {
    final prefs = await SharedPreferences.getInstance();
    final namesString = json.encode(names);
    await prefs.setString('original_day_names', namesString);
  }

  static Future<void> clearAllExerciseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exercise_history');
  }

  static Future<Map<String, dynamic>> getWeightReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool('weight_reminder_enabled') ?? false,
      'time': prefs.getString('weight_reminder_time') ?? '08:00',
      'frequency': prefs.getString('weight_reminder_frequency') ?? 'daily',
    };
  }

  static Future<Map<String, dynamic>> getWaterReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool('water_reminder_enabled') ?? false,
      'time': prefs.getString('water_reminder_time') ?? '08:00',
      'interval': prefs.getInt('water_reminder_interval') ?? 60,
    };
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'Türkçe';
  }

  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? '';
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  static Future<double> getCurrentWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('current_weight') ?? 0.0;
  }

  static Future<void> saveCurrentWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('current_weight', weight);
  }

  static Future<double> getTargetWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('target_weight') ?? 0.0;
  }

  static Future<void> saveTargetWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('target_weight', weight);
  }

  static Future<List<Map<String, dynamic>>> getWeightHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('weight_history');
    if (historyString != null) {
      final List<dynamic> decoded = json.decode(historyString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> saveWeightHistory(List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = json.encode(history);
    await prefs.setString('weight_history', historyString);
  }

  static Future<void> saveWeightReminderSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weight_reminder_enabled', settings['enabled'] ?? false);
    await prefs.setString('weight_reminder_time', settings['time'] ?? '08:00');
    await prefs.setString('weight_reminder_frequency', settings['frequency'] ?? 'daily');
  }

  static Future<void> saveWaterReminderSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('water_reminder_enabled', settings['enabled'] ?? false);
    await prefs.setString('water_reminder_time', settings['time'] ?? '08:00');
    await prefs.setInt('water_reminder_interval', settings['interval'] ?? 60);
  }

  static Future<List<String>> getCompletedWorkoutDates() async {
    final prefs = await SharedPreferences.getInstance();
    final datesString = prefs.getString('completed_workout_dates');
    if (datesString != null) {
      final List<dynamic> decoded = json.decode(datesString);
      return decoded.cast<String>();
    }
    return [];
  }
}

// NotificationService sınıfı
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
  }

  static Future<void> requestPermissions() async {
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  static Future<void> scheduleWeightReminder({
    required String time,
    required String frequency,
  }) async {
    // Implementation for weight reminder
  }

  static Future<void> scheduleWaterReminder({
    required String time,
    required int interval,
  }) async {
    // Implementation for water reminder
  }

  static Future<void> cancelWeightReminder() async {
    // Implementation for canceling weight reminder
  }

  static Future<void> cancelWaterReminder() async {
    // Implementation for canceling water reminder
  }
}

// AppColorTheme sınıfını ekleyelim
class AppColorTheme {
  // Ana Renkler
  static const Color primary = Color(0xFF673AB7);
  static const Color primaryLight = Color(0xFF9A67EA);
  static const Color primaryDark = Color(0xFF320B86);
  
  // Sekonder Renkler
  static const Color secondary = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFF64B5F6);
  static const Color secondaryDark = Color(0xFF1976D2);
  
  // Başarı ve Uyarı Renkleri
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  
  // Hata ve Tehlike Renkleri
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  
  // Nötr Renkler
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  
  // Kas Grubu Renkleri
  static const Color chest = Color(0xFFE91E63);
  static const Color back = Color(0xFF3F51B5);
  static const Color shoulders = Color(0xFF00BCD4);
  static const Color arms = Color(0xFFFF5722);
  static const Color legs = Color(0xFF8BC34A);
  static const Color core = Color(0xFFFFC107);
  static const Color cardio = Color(0xFF9C27B0);
  
  // Gün Renkleri
  static const Map<String, Color> weekDayColors = {
    'Pazartesi': Color(0xFF673AB7),
    'Salı': Color(0xFF2196F3),
    'Çarşamba': Color(0xFF4CAF50),
    'Perşembe': Color(0xFFFF9800),
    'Cuma': Color(0xFFFF5722),
    'Cumartesi': Color(0xFF795548),
    'Pazar': Color(0xFF9E9E9E),
  };
  
  // Gradient Renkleri
  static const List<Color> primaryGradient = [
    Color(0xFF673AB7),
    Color(0xFF9A67EA),
    Color(0xFF3F51B5),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF2196F3),
    Color(0xFF64B5F6),
    Color(0xFF1976D2),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF81C784),
    Color(0xFF2E7D32),
  ];
  
  // Şeffaflık Değerleri
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Input Alan Renkleri
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputLabel = Color(0xFF757575);
}

// CustomPainter sınıfları
class RoutineIconPainter extends CustomPainter {
  final Color color;
  
  RoutineIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Rutin ikonu - iki ok
    final arrowWidth = size.width * 0.3;
    final arrowHeight = size.height * 0.4;
    
    // Sol ok
    final leftArrow = Path()
      ..moveTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.1, size.height * 0.3)
      ..lineTo(size.width * 0.1, size.height * 0.7)
      ..close();
    canvas.drawPath(leftArrow, paint);
    
    // Sağ ok
    final rightArrow = Path()
      ..moveTo(size.width * 0.7, size.height * 0.5)
      ..lineTo(size.width * 0.9, size.height * 0.3)
      ..lineTo(size.width * 0.9, size.height * 0.7)
      ..close();
    canvas.drawPath(rightArrow, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CalculateIconPainter extends CustomPainter {
  final Color color;
  
  CalculateIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Hesaplama ikonu - grid
    final cellSize = size.width / 3;
    
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final rect = Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize);
        canvas.drawRect(rect, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StatisticsIconPainter extends CustomPainter {
  final Color color;
  
  StatisticsIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // İstatistik ikonu - bar chart
    final barWidth = size.width * 0.15;
    final maxHeight = size.height * 0.8;
    
    // Bar 1
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.6, barWidth, maxHeight * 0.4),
      paint,
    );
    
    // Bar 2
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.4, barWidth, maxHeight * 0.6),
      paint,
    );
    
    // Bar 3
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.2, barWidth, maxHeight * 0.8),
      paint,
    );
    
    // Bar 4
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.85, size.height * 0.5, barWidth, maxHeight * 0.5),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProfileIconPainter extends CustomPainter {
  final Color color;
  
  ProfileIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Profil ikonu - kişi
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    
    // Kafa
    final headRadius = size.width * 0.25;
    canvas.drawCircle(Offset(centerX, centerY - headRadius * 0.5), headRadius, paint);
    
    // Vücut
    final bodyRect = Rect.fromLTWH(
      centerX - size.width * 0.3,
      centerY + headRadius * 0.5,
      size.width * 0.6,
      size.height * 0.5,
    );
    canvas.drawRect(bodyRect, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Global değişkenler
Map<String, List<RoutineEntry>> globalCompletedWorkouts = {};
bool globalIsDataCleared = false;
String globalLanguage = 'Türkçe';
List<Function> _languageChangeCallbacks = [];

// Dil değişikliği callback'lerini yönet
void addLanguageChangeCallback(Function callback) {
  _languageChangeCallbacks.add(callback);
}

void removeLanguageChangeCallback(Function callback) {
  _languageChangeCallbacks.remove(callback);
}

void updateGlobalLanguage(String newLanguage) async {
  globalLanguage = newLanguage;
  await DataManager.saveLanguage(newLanguage);
  for (var callback in _languageChangeCallbacks) {
    callback();
  }
}

// Global completed workouts yükleme fonksiyonu
Future<void> _loadGlobalCompletedWorkouts() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final completedWorkoutsString = prefs.getString('completed_workouts');
    
    if (completedWorkoutsString != null && completedWorkoutsString.isNotEmpty) {
      final Map<String, dynamic> decoded = json.decode(completedWorkoutsString);
      globalCompletedWorkouts = decoded.map((key, value) => MapEntry(
        key,
        (value as List).map((item) => RoutineEntry.fromJson(item)).toList(),
      ));
    } else {
      globalCompletedWorkouts = {};
    }
  } catch (e) {
    print('Error loading global completed workouts: $e');
    globalCompletedWorkouts = {};
  }
}

// Ana uygulama
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadGlobalCompletedWorkouts();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weight Tracker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
} 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const WeekScreen(),
    const PlaceholderScreen(title: 'Hesapla'),
    const PlaceholderScreen(title: 'İstatistik'),
    const PlaceholderScreen(title: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _initializeReminders();
    addLanguageChangeCallback(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _initializeReminders() async {
    try {
      await NotificationService.initialize();
      await NotificationService.requestPermissions();
      final weightSettings = await DataManager.getWeightReminderSettings();
      final waterSettings = await DataManager.getWaterReminderSettings();
      
      if (weightSettings['enabled'] == true) {
        await NotificationService.scheduleWeightReminder(
          time: weightSettings['time'],
          frequency: weightSettings['frequency'],
        );
      }
      
      if (waterSettings['enabled'] == true) {
        await NotificationService.scheduleWaterReminder(
          time: waterSettings['time'],
          interval: waterSettings['interval'],
        );
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
          globalLanguage == 'Türkçe' ? 'İstatistik' : 'Statistics',
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFFF6B35),
          unselectedItemColor: Color(0xFFB3E0FF),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: _buildRoutineIcon(),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildCalculateIcon(),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildStatisticsIcon(),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildProfileIcon(),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
} 

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  Map<String, List<RoutineEntry>> _weeklyRoutine = {};
  Map<String, DateTime> _lastCompleted = {};
  Map<String, List<RoutineEntry>> _completedWorkouts = {};
  bool _warningShown = false;
  List<String> _dayOrder = [];
  Map<String, String> _originalDayNames = {};
  late AthleteQuote _currentAthlete;
  Map<String, List<ExerciseHistory>> _cachedExerciseHistory = {};
  
  @override
  void initState() {
    super.initState();
    _currentAthlete = athleteQuotes[DateTime.now().millisecondsSinceEpoch % athleteQuotes.length];
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final savedRoutine = await DataManager.getWeeklyRoutine();
      final savedCompleted = await DataManager.getCompletedWorkouts();
      final savedHistory = await DataManager.getExerciseHistory();
      final savedLastCompleted = await DataManager.getLastCompletedDates();
      final savedOriginalDayNames = await DataManager.getOriginalDayNames();
      
      if (globalIsDataCleared) {
        setState(() {
          _weeklyRoutine = savedRoutine;
          _completedWorkouts = savedCompleted;
          _cachedExerciseHistory = {};
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
        return;
      }
      
      if (_cachedExerciseHistory.isEmpty && savedHistory.isNotEmpty) {
        await DataManager.clearAllExerciseHistory();
        setState(() {
          _weeklyRoutine = savedRoutine;
          _completedWorkouts = savedCompleted;
          _cachedExerciseHistory = {};
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
        return;
      }
      
      setState(() {
        _weeklyRoutine = savedRoutine;
        _completedWorkouts = savedCompleted;
        _cachedExerciseHistory = savedHistory.isNotEmpty ? savedHistory : {};
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

  // Antrenman durumunu kontrol et - DÜZELTİLDİ!
  bool _isWorkoutCompleted(String day) {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    if (globalCompletedWorkouts.containsKey(todayString)) {
      print('_isWorkoutCompleted: Bugün için antrenman zaten tamamlandı');
      return true;
    }
    
    if (_lastCompleted.containsKey(day)) {
      final lastCompletedDate = _lastCompleted[day]!;
      final lastCompletedString = '${lastCompletedDate.year}-${lastCompletedDate.month.toString().padLeft(2, '0')}-${lastCompletedDate.day.toString().padLeft(2, '0')}';
      
      if (lastCompletedString == todayString) {
        print('_isWorkoutCompleted: Bugün için antrenman tamamlandı');
        return true;
      }
    }
    
    print('_isWorkoutCompleted: Bugün için antrenman tamamlanmadı');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kaslarını değil, planını inşa et!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Color(0xFFFF6B35),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.fullscreen, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fitness_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.9),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage('assets/fitness_background.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.9),
                    BlendMode.srcOver,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Tom Brady',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'American Football',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Başarı fedakarlık, disiplin ve inançla gelir',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Color(0xFFFF6B35)),
                      SizedBox(width: 8),
                      Text(
                        'Haftalık Rutin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDayDialog(),
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Yeni Gün Ekle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'Hafif Gün',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.fitness_center, color: Color(0xFFFF6B35)),
                            SizedBox(width: 4),
                            Text(
                              '5 egzersiz',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.orange),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _dayOrder.isEmpty
                  ? _buildEmptyState()
                  : _buildDaysList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDayDialog(),
        backgroundColor: Color(0xFFFF6B35),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            globalLanguage == 'Türkçe' ? 'Henüz rutin eklenmemiş' : 'No routine added yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            globalLanguage == 'Türkçe' ? 'İlk gününü ekleyerek başla!' : 'Start by adding your first day!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddDayDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B35),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: Text(
              globalLanguage == 'Türkçe' ? 'Gün Ekle' : 'Add Day',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _dayOrder.length,
      itemBuilder: (context, index) {
        final day = _dayOrder[index];
        final originalName = _originalDayNames[day] ?? day;
        final routine = _weeklyRoutine[day] ?? [];
        final isCompleted = _isWorkoutCompleted(day);
        
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    originalName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                ),
                if (isCompleted)
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  '${routine.length} ${globalLanguage == 'Türkçe' ? 'egzersiz' : 'exercises'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (routine.isNotEmpty) ...[
                  SizedBox(height: 8),
                  ...routine.take(3).map((exercise) => Text(
                    '• ${exercise.name}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  )),
                  if (routine.length > 3)
                    Text(
                      '... ve ${routine.length - 3} ${globalLanguage == 'Türkçe' ? 'daha' : 'more'}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                ],
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DayDetailScreen(
                    day: day,
                    originalName: originalName,
                    routine: routine,
                    onRoutineUpdated: (updatedRoutine) {
                      setState(() {
                        _weeklyRoutine[day] = updatedRoutine;
                      });
                      _saveData();
                    },
                    onDayDeleted: () => _deleteDay(day),
                    onDayRenamed: (newName) => _renameDay(day, newName),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddDayDialog() {
    String newDayName = '';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(globalLanguage == 'Türkçe' ? 'Yeni Gün Ekle' : 'Add New Day'),
          content: TextField(
            decoration: InputDecoration(
              labelText: globalLanguage == 'Türkçe' ? 'Gün Adı' : 'Day Name',
              hintText: globalLanguage == 'Türkçe' ? 'Örn: Pazartesi' : 'e.g. Monday',
            ),
            onChanged: (value) => newDayName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(globalLanguage == 'Türkçe' ? 'İptal' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newDayName.trim().isNotEmpty) {
                  _addDay(newDayName.trim());
                  Navigator.of(context).pop();
                }
              },
              child: Text(globalLanguage == 'Türkçe' ? 'Ekle' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _addDay(String dayName) {
    setState(() {
      _weeklyRoutine[dayName] = [];
      _dayOrder.add(dayName);
      _originalDayNames[dayName] = dayName;
    });
    _saveData();
  }

  void _deleteDay(String day) {
    setState(() {
      _weeklyRoutine.remove(day);
      _dayOrder.remove(day);
      _originalDayNames.remove(day);
      _lastCompleted.remove(day);
    });
    _saveData();
  }

  void _renameDay(String oldName, String newName) {
    setState(() {
      _weeklyRoutine[newName] = _weeklyRoutine[oldName] ?? [];
      _weeklyRoutine.remove(oldName);
      
      final index = _dayOrder.indexOf(oldName);
      if (index != -1) {
        _dayOrder[index] = newName;
      }
      
      _originalDayNames[newName] = newName;
      _originalDayNames.remove(oldName);
      
      if (_lastCompleted.containsKey(oldName)) {
        _lastCompleted[newName] = _lastCompleted[oldName]!;
        _lastCompleted.remove(oldName);
      }
    });
    _saveData();
  }

  Future<void> _saveData() async {
    try {
      await DataManager.saveWeeklyRoutine(_weeklyRoutine);
      await DataManager.saveCompletedWorkouts(_completedWorkouts);
      await DataManager.saveLastCompletedDates(_lastCompleted);
      await DataManager.saveOriginalDayNames(_originalDayNames);
      
      globalCompletedWorkouts = Map<String, List<RoutineEntry>>.from(_completedWorkouts);
      print('Veriler kaydedildi');
    } catch (e) {
      print('Error saving data: $e');
    }
  }
} 

// Placeholder ekran
class PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFFF6B35),
      ),
      body: Center(
        child: Text(
          '$title Ekranı - Geliştiriliyor',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class DayDetailScreen extends StatelessWidget {
  final String day;
  final String originalName;
  final List<RoutineEntry> routine;
  final Function(List<RoutineEntry>) onRoutineUpdated;
  final VoidCallback onDayDeleted;
  final Function(String) onDayRenamed;

  const DayDetailScreen({
    super.key,
    required this.day,
    required this.originalName,
    required this.routine,
    required this.onRoutineUpdated,
    required this.onDayDeleted,
    required this.onDayRenamed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(originalName),
        backgroundColor: Color(0xFFFF6B35),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () => _showRenameDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$originalName Detay Ekranı',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '${routine.length} egzersiz bulundu',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => onDayDeleted(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Günü Sil', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    String newName = originalName;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gün Adını Değiştir'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Yeni Ad'),
            controller: TextEditingController(text: newName),
            onChanged: (value) => newName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newName.trim().isNotEmpty) {
                  onDayRenamed(newName.trim());
                  Navigator.of(context).pop();
                }
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Günü Sil', style: TextStyle(color: Colors.red)),
          content: Text('Bu günü silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDayDeleted();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Sil', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
} 