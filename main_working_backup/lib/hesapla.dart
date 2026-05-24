import 'package:flutter/material.dart';
import 'dart:math';
import 'main.dart';

class HesaplaScreen extends StatefulWidget {
  const HesaplaScreen({super.key});

  @override
  State<HesaplaScreen> createState() => _HesaplaScreenState();
}

class _HesaplaScreenState extends State<HesaplaScreen> {
  String _selectedGender = 'Erkek';
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _neckController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedActivityLevel = 'Hafif Aktif';
  
  double? _bodyFatPercentage;
  String? _bodyFatCategory;
  double? _bmr;
  double? _tdee;
  Map<String, double>? _macros;
  bool _showMacroSection = false;

  void _calculateBodyFat() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final neck = double.tryParse(_neckController.text);
    final waist = double.tryParse(_waistController.text);
    final hip = double.tryParse(_hipController.text);

    if (height == null || weight == null || neck == null || waist == null) {
      return;
    }

    double bodyFatPercentage;
    
    if (_selectedGender == 'Erkek') {
      // Erkek için kalça değeri gerekli değil
      bodyFatPercentage = 495 / (1.0324 - 0.19077 * log((waist - neck).toDouble()) + 0.15456 * log(height)) - 450;
    } else {
      // Kadın için kalça değeri gerekli
      if (hip == null) {
        return;
      }
      bodyFatPercentage = 495 / (1.29579 - 0.35004 * log((waist + hip - neck).toDouble()) + 0.22100 * log(height)) - 450;
    }

    setState(() {
      _bodyFatPercentage = bodyFatPercentage;
      _bodyFatCategory = _getBodyFatCategory(bodyFatPercentage);
      _showMacroSection = true;
    });
  }

  String _getBodyFatCategory(double percentage) {
    if (_selectedGender == 'Erkek') {
      if (percentage < 6) return globalLanguage == 'Türkçe' ? 'Çok Düşük' : 'Very Low';
      if (percentage < 14) return globalLanguage == 'Türkçe' ? 'Fit' : 'Fit';
      if (percentage < 18) return globalLanguage == 'Türkçe' ? 'Ortalama' : 'Average';
      if (percentage < 25) return globalLanguage == 'Türkçe' ? 'Yüksek' : 'High';
      return globalLanguage == 'Türkçe' ? 'Obez' : 'Obese';
    } else {
      if (percentage < 14) return globalLanguage == 'Türkçe' ? 'Çok Düşük' : 'Very Low';
      if (percentage < 21) return globalLanguage == 'Türkçe' ? 'Fit' : 'Fit';
      if (percentage < 25) return globalLanguage == 'Türkçe' ? 'Ortalama' : 'Average';
      if (percentage < 32) return globalLanguage == 'Türkçe' ? 'Yüksek' : 'High';
      return globalLanguage == 'Türkçe' ? 'Obez' : 'Obese';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Çok Düşük':
        return Colors.red;
      case 'Fit':
        return Colors.green;
      case 'Ortalama':
        return Colors.orange;
      case 'Yüksek':
        return Colors.deepOrange;
      case 'Obez':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _calculateMacros() {
    final age = double.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (age == null || weight == null || height == null || _bodyFatCategory == null) {
      return;
    }

    double bmr;
    if (_selectedGender == 'Erkek') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    double activityMultiplier;
    switch (_selectedActivityLevel) {
      case 'Hareketsiz':
        activityMultiplier = 1.2;
        break;
      case 'Hafif Aktif':
        activityMultiplier = 1.375;
        break;
      case 'Orta Aktif':
        activityMultiplier = 1.55;
        break;
      case 'Çok Aktif':
        activityMultiplier = 1.725;
        break;
      case 'Aşırı Aktif':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.375;
    }

    double tdee = bmr * activityMultiplier;

    double targetCalories;
    switch (_bodyFatCategory) {
      case 'Çok Düşük':
        targetCalories = tdee + 300;
        break;
      case 'Fit':
        targetCalories = tdee;
        break;
      case 'Ortalama':
        targetCalories = tdee - 200;
        break;
      case 'Yüksek':
        targetCalories = tdee - 400;
        break;
      case 'Obez':
        targetCalories = tdee - 500;
        break;
      default:
        targetCalories = tdee;
    }

    double protein, fat, carbs;
    
    switch (_bodyFatCategory) {
      case 'Çok Düşük':
        protein = weight * 1.8;
        fat = targetCalories * 0.25 / 9;
        carbs = (targetCalories - protein * 4 - fat * 9) / 4;
        break;
      case 'Fit':
        protein = weight * 1.6;
        fat = targetCalories * 0.25 / 9;
        carbs = (targetCalories - protein * 4 - fat * 9) / 4;
        break;
      case 'Ortalama':
        protein = weight * 1.4;
        fat = targetCalories * 0.30 / 9;
        carbs = (targetCalories - protein * 4 - fat * 9) / 4;
        break;
      case 'Yüksek':
      case 'Obez':
        protein = weight * 1.2;
        fat = targetCalories * 0.35 / 9;
        carbs = (targetCalories - protein * 4 - fat * 9) / 4;
        break;
      default:
        protein = weight * 1.6;
        fat = targetCalories * 0.25 / 9;
        carbs = (targetCalories - protein * 4 - fat * 9) / 4;
    }

    setState(() {
      _bmr = bmr;
      _tdee = tdee;
      _macros = {
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'calories': targetCalories,
      };
    });
  }

  Widget _buildMacroCard(String title, double value, String unit, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: color.withOpacity(0.8),
                ),
            ),
            const SizedBox(height: 8),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(globalLanguage == 'Türkçe' ? 'Hesaplama Araçları' : 'Calculation Tools'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.withOpacity(0.9),
                    Colors.cyan.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.science, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    globalLanguage == 'Türkçe' ? 'Bilimsel Hesaplama Araçları' : 'Scientific Calculation Tools',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Vücut Yağ Oranı Hesaplama
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          globalLanguage == 'Türkçe' ? 'Vücut Yağ Oranı Hesaplama' : 'Body Fat Percentage Calculation',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Text(globalLanguage == 'Türkçe' ? 'Cinsiyet: ' : 'Gender: '),
                        SizedBox(width: 16),
                        ChoiceChip(
                          label: Text(globalLanguage == 'Türkçe' ? 'Erkek' : 'Male'),
                          selected: _selectedGender == 'Erkek',
                          onSelected: (selected) {
                            setState(() {
                              _selectedGender = 'Erkek';
                            });
                          },
                        ),
                        SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(globalLanguage == 'Türkçe' ? 'Kadın' : 'Female'),
                          selected: _selectedGender == 'Kadın',
                          onSelected: (selected) {
                            setState(() {
                              _selectedGender = 'Kadın';
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _heightController,
                            decoration: InputDecoration(
                              labelText: globalLanguage == 'Türkçe' ? 'Boy (cm)' : 'Height (cm)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: globalLanguage == 'Türkçe' ? 'Kilo (kg)' : 'Weight (kg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _neckController,
                            decoration: InputDecoration(
                              labelText: globalLanguage == 'Türkçe' ? 'Boyun (cm)' : 'Neck (cm)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _waistController,
                            decoration: InputDecoration(
                              labelText: globalLanguage == 'Türkçe' ? 'Bel (cm)' : 'Waist (cm)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedGender == 'Kadın') ...[
                      SizedBox(height: 12),
                      TextField(
                        controller: _hipController,
                                                    decoration: InputDecoration(
                              labelText: globalLanguage == 'Türkçe' ? 'Kalça (cm)' : 'Hip (cm)',
                              border: OutlineInputBorder(),
                            ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculateBodyFat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          globalLanguage == 'Türkçe' ? 'Vücut Yağ Oranını Hesapla' : 'Calculate Body Fat Percentage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    if (_bodyFatPercentage != null) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getCategoryColor(_bodyFatCategory!).withOpacity(0.15),
                              _getCategoryColor(_bodyFatCategory!).withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: _getCategoryColor(_bodyFatCategory!).withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getCategoryColor(_bodyFatCategory!).withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: _getCategoryColor(_bodyFatCategory!),
                              size: 32,
                            ),
                            SizedBox(height: 12),
                            Text(
                              globalLanguage == 'Türkçe' ? 'Vücut Yağ Oranı: ${_bodyFatPercentage!.toStringAsFixed(1)}%' : 'Body Fat Percentage: ${_bodyFatPercentage!.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getCategoryColor(_bodyFatCategory!),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(_bodyFatCategory!),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                globalLanguage == 'Türkçe' ? 'Kategori: $_bodyFatCategory' : 'Category: $_bodyFatCategory',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            if (_showMacroSection) ...[
              SizedBox(height: 24),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant_menu, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            globalLanguage == 'Türkçe' ? 'Makro Besin Hesaplama' : 'Macro Nutrient Calculation',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ageController,
                              decoration: InputDecoration(
                                labelText: globalLanguage == 'Türkçe' ? 'Yaş' : 'Age',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: globalLanguage == 'Türkçe' ? 'Aktivite Seviyesi' : 'Activity Level',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedActivityLevel,
                              items: [
                                DropdownMenuItem(
                                  value: 'Hareketsiz',
                                  child: Text(globalLanguage == 'Türkçe' ? 'Hareketsiz (Aktivite yok)' : 'Inactive (No activity)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Hafif Aktif',
                                  child: Text(globalLanguage == 'Türkçe' ? 'Hafif Aktif (1-3 gün/hafta)' : 'Lightly Active (1-3 days/week)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Orta Aktif',
                                  child: Text(globalLanguage == 'Türkçe' ? 'Orta Aktif (3-5 gün/hafta)' : 'Moderately Active (3-5 days/week)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Çok Aktif',
                                  child: Text(globalLanguage == 'Türkçe' ? 'Çok Aktif (6-7 gün/hafta)' : 'Very Active (6-7 days/week)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Aşırı Aktif',
                                  child: Text(globalLanguage == 'Türkçe' ? 'Aşırı Aktif (2+ kez/gün)' : 'Extremely Active (2+ times/day)'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedActivityLevel = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateMacros,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            globalLanguage == 'Türkçe' ? 'Makro Besinleri Hesapla' : 'Calculate Macro Nutrients',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      if (_macros != null) ...[
                        SizedBox(height: 16),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMacroCard(
                                    'Protein',
                                    _macros!['protein']!,
                                    'g',
                                    Colors.red,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildMacroCard(
                                    globalLanguage == 'Türkçe' ? 'Yağ' : 'Fat',
                                    _macros!['fat']!,
                                    'g',
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMacroCard(
                                    globalLanguage == 'Türkçe' ? 'Karbonhidrat' : 'Carbohydrate',
                                    _macros!['carbs']!,
                                    'g',
                                    Colors.blue,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildMacroCard(
                                    globalLanguage == 'Türkçe' ? 'Kalori' : 'Calorie',
                                    _macros!['calories']!,
                                    'kcal',
                                    Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 