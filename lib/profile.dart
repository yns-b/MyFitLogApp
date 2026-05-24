import 'package:flutter/material.dart';
import 'main.dart';

class WeightEntry {
  final double weight;
  final DateTime date;
  final String? note;

  WeightEntry({
    required this.weight,
    required this.date,
    this.note,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentWeightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  
  String _userName = '';
  double? _currentWeight;
  double? _targetWeight;
  double? _weightDifference;
  String? _goalStatus;
  
  // Hatırlatıcı durumları
  bool _weightReminderEnabled = false;
  bool _waterReminderEnabled = false;
  TimeOfDay _weightReminderTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _waterReminderTime = const TimeOfDay(hour: 9, minute: 0);
  String _weightReminderFrequency = 'Haftalık'; // Haftalık veya Aylık
  String _waterReminderInterval = '2 saat'; // Su içme aralığı
  
  // Tartılma geçmişi
  List<WeightEntry> _weightHistory = [];
  final TextEditingController _newWeightController = TextEditingController();
  
  // Dil ayarları
  String get _selectedLanguage => globalLanguage;

  @override
  void initState() {
    super.initState();
    // Verileri yükle
    _loadData();
    // globalLanguage değiştiğinde UI'ı güncelle
    addLanguageChangeCallback(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadData() async {
    try {
      // SharedPreferences'dan verileri yükle
      final userName = await DataManager.getUserName();
      final currentWeight = await DataManager.getCurrentWeight();
      final targetWeight = await DataManager.getTargetWeight();
      final weightHistory = await DataManager.getWeightHistory();
      
      // Hatırlatıcı ayarlarını yükle
      final weightReminderSettings = await DataManager.getWeightReminderSettings();
      final waterReminderSettings = await DataManager.getWaterReminderSettings();
      
      setState(() {
        _nameController.text = userName.isNotEmpty ? userName : (_selectedLanguage == 'Türkçe' ? 'Kullanıcı' : 'User');
        _currentWeightController.text = currentWeight?.toString() ?? '70';
        _targetWeightController.text = targetWeight?.toString() ?? '65';
        _weightHistory = weightHistory;
        
        // Hatırlatıcı ayarlarını set et
        _weightReminderEnabled = weightReminderSettings['enabled'] ?? false;
        _weightReminderTime = weightReminderSettings['time'] ?? const TimeOfDay(hour: 8, minute: 0);
        _weightReminderFrequency = weightReminderSettings['frequency'] ?? 'Haftalık';
        
        _waterReminderEnabled = waterReminderSettings['enabled'] ?? false;
        _waterReminderTime = waterReminderSettings['time'] ?? const TimeOfDay(hour: 9, minute: 0);
        _waterReminderInterval = waterReminderSettings['interval'] ?? '2 saat';
        
        _updateCalculations();
      });
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _nameController.text = _selectedLanguage == 'Türkçe' ? 'Kullanıcı' : 'User';
        _currentWeightController.text = '70';
        _targetWeightController.text = '65';
        _weightHistory = [];
        _updateCalculations();
      });
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

  void _updateCalculations() {
    final currentWeight = double.tryParse(_currentWeightController.text);
    final targetWeight = double.tryParse(_targetWeightController.text);

    double? weightDifference;
    String? goalStatus;
    
    if (currentWeight != null && targetWeight != null) {
      weightDifference = targetWeight - currentWeight;
      if (weightDifference > 0) {
        goalStatus = 'Kilo Alma Hedefi';
      } else if (weightDifference < 0) {
        goalStatus = 'Kilo Verme Hedefi';
      } else {
        goalStatus = 'Kilo Koruma Hedefi';
      }
    }

    setState(() {
      _userName = _nameController.text;
      _currentWeight = currentWeight;
      _targetWeight = targetWeight;
      _weightDifference = weightDifference;
      _goalStatus = goalStatus;
    });
  }

  Color _getGoalColor() {
    if (_weightDifference == null) return Colors.grey;
    if (_weightDifference! > 0) return Colors.blue; // Kilo alma
    if (_weightDifference! < 0) return Colors.green; // Kilo verme
    return Colors.orange; // Koruma
  }

  void _showAddWeightDialog(BuildContext context) {
    _newWeightController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_selectedLanguage == 'Türkçe' ? 'Yeni Tartılma Kaydı' : 'New Weight Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newWeightController,
                decoration: InputDecoration(
                  labelText: _selectedLanguage == 'Türkçe' ? 'Kilo (kg)' : 'Weight (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_selectedLanguage == 'Türkçe' ? 'İptal' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final weight = double.tryParse(_newWeightController.text);
                if (weight != null && weight > 0) {
                  setState(() {
                    _weightHistory.insert(0, WeightEntry(
                      weight: weight,
                      date: DateTime.now(),
                    ));
                  });
                  // Tartılma geçmişini kaydet
                  await DataManager.saveWeightHistory(_weightHistory);
                  Navigator.of(context).pop();
                }
              },
              child: Text(_selectedLanguage == 'Türkçe' ? 'Kaydet' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteWeightEntry(int index) {
    setState(() {
      _weightHistory.removeAt(index);
    });
  }

  String _getWeightChangeText() {
    if (_weightHistory.length < 2) return '';
    
    final current = _weightHistory[0].weight;
    final previous = _weightHistory[1].weight;
    final difference = current - previous;
    
    if (difference > 0) {
      return '+${difference.toStringAsFixed(1)} kg';
    } else if (difference < 0) {
      return '${difference.toStringAsFixed(1)} kg';
    } else {
      return '0.0 kg';
    }
  }

  Color _getWeightChangeColor() {
    if (_weightHistory.length < 2) return Colors.grey;
    
    final current = _weightHistory[0].weight;
    final previous = _weightHistory[1].weight;
    final difference = current - previous;
    
    if (difference > 0) {
      return Colors.red; // Kilo artışı
    } else if (difference < 0) {
      return Colors.green; // Kilo azalışı
    } else {
      return Colors.grey; // Değişim yok
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedLanguage == 'Türkçe' ? 'Profil' : 'Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil Başlığı
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Arka plan görseli
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/fitness_profile_background.jpg', // Görsel dosya adını buraya yazın
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 140,
                    ),
                  ),
                  // Koyu overlay (metinlerin okunabilirliği için)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                  // İçerik
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _userName.isEmpty ? (_selectedLanguage == 'Türkçe' ? 'Kullanıcı' : 'User') : _userName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(1, 1),
                                              blurRadius: 3,
                                              color: Colors.black.withOpacity(0.7),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.white, size: 20),
                                      onPressed: () => _showNameEditDialog(),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _selectedLanguage == 'Türkçe' ? 'Fitness Takip Uygulaması' : 'Fitness Tracking App',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            

            
            const SizedBox(height: 16),
            
            // Tartılma Takibi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monitor_weight, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          _selectedLanguage == 'Türkçe' ? 'Tartılma Takibi' : 'Weight Tracking',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _currentWeightController,
                            decoration: InputDecoration(
                              labelText: _selectedLanguage == 'Türkçe' ? 'Mevcut Kilo (kg)' : 'Current Weight (kg)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.monitor_weight),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _updateCalculations();
                              // Mevcut kiloyu kaydet
                              final weight = double.tryParse(value);
                              if (weight != null) {
                                DataManager.saveCurrentWeight(weight);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _targetWeightController,
                            decoration: InputDecoration(
                              labelText: _selectedLanguage == 'Türkçe' ? 'Hedef Kilo (kg)' : 'Target Weight (kg)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.flag),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _updateCalculations();
                              // Hedef kiloyu kaydet
                              final weight = double.tryParse(value);
                              if (weight != null) {
                                DataManager.saveTargetWeight(weight);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tartılma Geçmişi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history, color: Color(0xFFFF6B35)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedLanguage == 'Türkçe' ? 'Tartılma Geçmişi' : 'Weight History',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text(_selectedLanguage == 'Türkçe' ? 'Yeni Tartılma' : 'New Weight'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF6B35),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () => _showAddWeightDialog(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (_weightHistory.isEmpty)
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 8),
                            Text(
                              _selectedLanguage == 'Türkçe' ? 'Henüz tartılma kaydı yok' : 'No weight records yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _selectedLanguage == 'Türkçe' 
                                ? 'İlk tartılma kaydınızı eklemek için "Yeni Tartılma" butonuna tıklayın'
                                : 'Click "New Weight" button to add your first weight record',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          // Son tartılma özeti
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF6B35).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFFF6B35).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.trending_up, color: Color(0xFFFF6B35)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedLanguage == 'Türkçe' ? 'Son Tartılma' : 'Last Weight',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${_weightHistory.first.weight.toStringAsFixed(1)} kg',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF6B35),
                                        ),
                                      ),
                                      Text(
                                        '${_weightHistory.first.date.day}/${_weightHistory.first.date.month}/${_weightHistory.first.date.year}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_weightHistory.length > 1) ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _selectedLanguage == 'Türkçe' ? 'Değişim' : 'Change',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        _getWeightChangeText(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _getWeightChangeColor(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          // Geçmiş listesi
                          Container(
                            height: 200,
                            child: ListView.builder(
                              itemCount: _weightHistory.length,
                              itemBuilder: (context, index) {
                                final entry = _weightHistory[index];
                                final isLatest = index == 0;
                                
                                return Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isLatest ? Color(0xFFFF6B35).withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isLatest ? Color(0xFFFF6B35).withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.monitor_weight,
                                        color: isLatest ? Color(0xFFFF6B35) : Colors.grey[600],
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${entry.weight.toStringAsFixed(1)} kg',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isLatest ? Color(0xFFFF6B35) : Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _deleteWeightEntry(index),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            

            
            const SizedBox(height: 16),
            
            // Hatırlatıcılar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          _selectedLanguage == 'Türkçe' ? 'Hatırlatıcılar' : 'Reminders',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                                         // Tartılma Hatırlatıcısı
                     Container(
                       padding: EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: Colors.green.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.green.withOpacity(0.3)),
                       ),
                       child: Column(
                         children: [
                           Row(
                             children: [
                               Icon(Icons.monitor_weight, color: Colors.green),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       _selectedLanguage == 'Türkçe' ? 'Tartılma Hatırlatıcısı' : 'Weight Reminder',
                                       style: TextStyle(
                                         fontWeight: FontWeight.bold,
                                         fontSize: 16,
                                         color: Colors.green[700],
                                       ),
                                     ),
                                     SizedBox(height: 4),
                                     Text(
                                       '${_weightReminderTime.format(context)} - ${_selectedLanguage == 'Türkçe' ? _weightReminderFrequency : (_weightReminderFrequency == 'Haftalık' ? 'Weekly' : 'Monthly')}',
                                       style: TextStyle(
                                         fontSize: 14,
                                         color: Colors.grey[600],
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                               Switch(
                                 value: _weightReminderEnabled,
                                 onChanged: (value) async {
                                   setState(() {
                                     _weightReminderEnabled = value;
                                   });
                                   
                                   // Ayarları kaydet
                                   await DataManager.saveWeightReminderSettings(
                                     enabled: value,
                                     time: _weightReminderTime,
                                     frequency: _weightReminderFrequency,
                                   );
                                   
                                   if (value) {
                                     // Notification izni iste
                                     await NotificationService.requestPermissions();
                                     // Hatırlatıcıyı planla
                                     await NotificationService.scheduleWeightReminder(
                                       time: _weightReminderTime,
                                       frequency: _weightReminderFrequency,
                                     );
                                   } else {
                                     // Hatırlatıcıyı iptal et
                                     await NotificationService.cancelWeightReminder();
                                   }
                                 },
                                 activeColor: Colors.green,
                               ),
                             ],
                           ),
                           SizedBox(height: 12),
                           // Sıklık seçici
                           Row(
                             children: [
                               Text(
                                 _selectedLanguage == 'Türkçe' ? 'Sıklık:' : 'Frequency:',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w500,
                                   color: Colors.grey[700],
                                 ),
                               ),
                               SizedBox(width: 12),
                               ChoiceChip(
                                 label: Text(_selectedLanguage == 'Türkçe' ? 'Haftalık' : 'Weekly'),
                                 selected: _weightReminderFrequency == 'Haftalık',
                                 onSelected: (selected) async {
                                   if (selected) {
                                     setState(() {
                                       _weightReminderFrequency = 'Haftalık';
                                     });
                                     
                                     // Ayarları kaydet ve hatırlatıcıyı güncelle
                                     await DataManager.saveWeightReminderSettings(
                                       enabled: _weightReminderEnabled,
                                       time: _weightReminderTime,
                                       frequency: 'Haftalık',
                                     );
                                     
                                     if (_weightReminderEnabled) {
                                       await NotificationService.scheduleWeightReminder(
                                         time: _weightReminderTime,
                                         frequency: 'Haftalık',
                                       );
                                     }
                                   }
                                 },
                                 selectedColor: Colors.green,
                                 labelStyle: TextStyle(
                                   color: _weightReminderFrequency == 'Haftalık' 
                                     ? Colors.white 
                                     : Colors.grey[700],
                                 ),
                               ),
                               SizedBox(width: 8),
                               ChoiceChip(
                                 label: Text(_selectedLanguage == 'Türkçe' ? 'Aylık' : 'Monthly'),
                                 selected: _weightReminderFrequency == 'Aylık',
                                 onSelected: (selected) async {
                                   if (selected) {
                                     setState(() {
                                       _weightReminderFrequency = 'Aylık';
                                     });
                                     
                                     // Ayarları kaydet ve hatırlatıcıyı güncelle
                                     await DataManager.saveWeightReminderSettings(
                                       enabled: _weightReminderEnabled,
                                       time: _weightReminderTime,
                                       frequency: 'Aylık',
                                     );
                                     
                                     if (_weightReminderEnabled) {
                                       await NotificationService.scheduleWeightReminder(
                                         time: _weightReminderTime,
                                         frequency: 'Aylık',
                                       );
                                     }
                                   }
                                 },
                                 selectedColor: Colors.green,
                                 labelStyle: TextStyle(
                                   color: _weightReminderFrequency == 'Aylık' 
                                     ? Colors.white 
                                     : Colors.grey[700],
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                    
                    const SizedBox(height: 12),
                    
                                         // Su İçme Hatırlatıcısı
                     Container(
                       padding: EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: Colors.blue.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.blue.withOpacity(0.3)),
                       ),
                       child: Column(
                         children: [
                           Row(
                             children: [
                               Icon(Icons.water_drop, color: Colors.blue),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       _selectedLanguage == 'Türkçe' ? 'Su İçme Hatırlatıcısı' : 'Water Drinking Reminder',
                                       style: TextStyle(
                                         fontWeight: FontWeight.bold,
                                         fontSize: 16,
                                         color: Colors.blue[700],
                                       ),
                                     ),
                                     SizedBox(height: 4),
                                     Text(
                                       '${_waterReminderTime.format(context)} - ${_selectedLanguage == 'Türkçe' ? _waterReminderInterval : (_waterReminderInterval == '1 saat' ? '1 hour' : (_waterReminderInterval == '2 saat' ? '2 hours' : '3 hours'))}',
                                       style: TextStyle(
                                         fontSize: 14,
                                         color: Colors.grey[600],
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                               Switch(
                                 value: _waterReminderEnabled,
                                 onChanged: (value) async {
                                   setState(() {
                                     _waterReminderEnabled = value;
                                   });
                                   
                                   // Ayarları kaydet
                                   await DataManager.saveWaterReminderSettings(
                                     enabled: value,
                                     time: _waterReminderTime,
                                     interval: _waterReminderInterval,
                                   );
                                   
                                   if (value) {
                                     // Notification izni iste
                                     await NotificationService.requestPermissions();
                                     // Hatırlatıcıyı planla
                                     await NotificationService.scheduleWaterReminder(
                                       time: _waterReminderTime,
                                       interval: _waterReminderInterval,
                                     );
                                   } else {
                                     // Hatırlatıcıyı iptal et
                                     await NotificationService.cancelWaterReminder();
                                   }
                                 },
                                 activeColor: Colors.blue,
                               ),
                             ],
                           ),
                           SizedBox(height: 12),
                           // Su içme aralığı seçici
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 _selectedLanguage == 'Türkçe' ? 'Aralık:' : 'Interval:',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w500,
                                   color: Colors.grey[700],
                                 ),
                               ),
                               SizedBox(height: 8),
                               Wrap(
                                 spacing: 8,
                                 runSpacing: 4,
                                 children: [
                                   ChoiceChip(
                                     label: Text(_selectedLanguage == 'Türkçe' ? '1 saat' : '1 hour'),
                                     selected: _waterReminderInterval == '1 saat',
                                     onSelected: (selected) async {
                                       if (selected) {
                                         setState(() {
                                           _waterReminderInterval = '1 saat';
                                         });
                                         
                                         // Ayarları kaydet ve hatırlatıcıyı güncelle
                                         await DataManager.saveWaterReminderSettings(
                                           enabled: _waterReminderEnabled,
                                           time: _waterReminderTime,
                                           interval: '1 saat',
                                         );
                                         
                                         if (_waterReminderEnabled) {
                                           await NotificationService.scheduleWaterReminder(
                                             time: _waterReminderTime,
                                             interval: '1 saat',
                                           );
                                         }
                                       }
                                     },
                                     selectedColor: Colors.blue,
                                     labelStyle: TextStyle(
                                       color: _waterReminderInterval == '1 saat' 
                                         ? Colors.white 
                                         : Colors.grey[700],
                                       fontSize: 12,
                                     ),
                                   ),
                                   ChoiceChip(
                                     label: Text(_selectedLanguage == 'Türkçe' ? '2 saat' : '2 hours'),
                                     selected: _waterReminderInterval == '2 saat',
                                     onSelected: (selected) async {
                                       if (selected) {
                                         setState(() {
                                           _waterReminderInterval = '2 saat';
                                         });
                                         
                                         // Ayarları kaydet ve hatırlatıcıyı güncelle
                                         await DataManager.saveWaterReminderSettings(
                                           enabled: _waterReminderEnabled,
                                           time: _waterReminderTime,
                                           interval: '2 saat',
                                         );
                                         
                                         if (_waterReminderEnabled) {
                                           await NotificationService.scheduleWaterReminder(
                                             time: _waterReminderTime,
                                             interval: '2 saat',
                                           );
                                         }
                                       }
                                     },
                                     selectedColor: Colors.blue,
                                     labelStyle: TextStyle(
                                       color: _waterReminderInterval == '2 saat' 
                                         ? Colors.white 
                                         : Colors.grey[700],
                                       fontSize: 12,
                                     ),
                                   ),
                                   ChoiceChip(
                                     label: Text(_selectedLanguage == 'Türkçe' ? '3 saat' : '3 hours'),
                                     selected: _waterReminderInterval == '3 saat',
                                     onSelected: (selected) async {
                                       if (selected) {
                                         setState(() {
                                           _waterReminderInterval = '3 saat';
                                         });
                                         
                                         // Ayarları kaydet ve hatırlatıcıyı güncelle
                                         await DataManager.saveWaterReminderSettings(
                                           enabled: _waterReminderEnabled,
                                           time: _waterReminderTime,
                                           interval: '3 saat',
                                         );
                                         
                                         if (_waterReminderEnabled) {
                                           await NotificationService.scheduleWaterReminder(
                                             time: _waterReminderTime,
                                             interval: '3 saat',
                                           );
                                         }
                                       }
                                     },
                                     selectedColor: Colors.blue,
                                     labelStyle: TextStyle(
                                       color: _waterReminderInterval == '3 saat' 
                                         ? Colors.white 
                                         : Colors.grey[700],
                                       fontSize: 12,
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                    
                    const SizedBox(height: 16),
                    
                    // Hatırlatıcı Ayarları
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.schedule),
                            label: Text(_selectedLanguage == 'Türkçe' ? 'Tartılma Saati' : 'Weight Time'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final TimeOfDay? newTime = await showTimePicker(
                                context: context,
                                initialTime: _weightReminderTime,
                              );
                              if (newTime != null) {
                                setState(() {
                                  _weightReminderTime = newTime;
                                });
                                
                                // Ayarları kaydet ve hatırlatıcıyı güncelle
                                await DataManager.saveWeightReminderSettings(
                                  enabled: _weightReminderEnabled,
                                  time: newTime,
                                  frequency: _weightReminderFrequency,
                                );
                                
                                if (_weightReminderEnabled) {
                                  await NotificationService.scheduleWeightReminder(
                                    time: newTime,
                                    frequency: _weightReminderFrequency,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.water_drop),
                            label: Text(_selectedLanguage == 'Türkçe' ? 'Su Saati' : 'Water Time'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final TimeOfDay? newTime = await showTimePicker(
                                context: context,
                                initialTime: _waterReminderTime,
                              );
                              if (newTime != null) {
                                setState(() {
                                  _waterReminderTime = newTime;
                                });
                                
                                // Ayarları kaydet ve hatırlatıcıyı güncelle
                                await DataManager.saveWaterReminderSettings(
                                  enabled: _waterReminderEnabled,
                                  time: newTime,
                                  interval: _waterReminderInterval,
                                );
                                
                                if (_waterReminderEnabled) {
                                  await NotificationService.scheduleWaterReminder(
                                    time: newTime,
                                    interval: _waterReminderInterval,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Uygulama Ayarları (En Alta Taşındı)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Text(
                          _selectedLanguage == 'Türkçe' ? 'Uygulama Ayarları' : 'App Settings',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Dil Seçimi
                    Row(
                      children: [
                        Icon(Icons.language, color: Colors.indigo, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _selectedLanguage == 'Türkçe' ? 'Dil:' : 'Language:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: Text(_selectedLanguage == 'Türkçe' ? 'Türkçe' : 'Turkish'),
                          selected: _selectedLanguage == 'Türkçe',
                          onSelected: (selected) {
                            if (selected) {
                              updateGlobalLanguage('Türkçe');
                              setState(() {});
                            }
                          },
                          selectedColor: Colors.indigo,
                          labelStyle: TextStyle(
                            color: _selectedLanguage == 'Türkçe' 
                              ? Colors.white 
                              : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(_selectedLanguage == 'Türkçe' ? 'İngilizce' : 'English'),
                          selected: _selectedLanguage == 'English',
                          onSelected: (selected) {
                            if (selected) {
                              updateGlobalLanguage('English');
                              setState(() {});
                            }
                          },
                          selectedColor: Colors.indigo,
                          labelStyle: TextStyle(
                            color: _selectedLanguage == 'English' 
                              ? Colors.white 
                              : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Test butonlarını ve ilgili SizedBox'ları kaldır
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
      ),
    );
  }

  void _showNameEditDialog() {
    final TextEditingController nameController = TextEditingController(text: _userName);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_selectedLanguage == 'Türkçe' ? 'İsim Düzenle' : 'Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: _selectedLanguage == 'Türkçe' ? 'İsim' : 'Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_selectedLanguage == 'Türkçe' ? 'İptal' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  setState(() {
                    _userName = newName;
                  });
                  DataManager.saveUserName(newName);
                  Navigator.of(context).pop();
                }
              },
              child: Text(_selectedLanguage == 'Türkçe' ? 'Kaydet' : 'Save'),
            ),
          ],
        );
      },
    );
  }
} 