import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view.dart';
import 'sun.dart'; // Sunflower page

class Plant extends StatefulWidget {
  const Plant({super.key});

  @override
  State<Plant> createState() => _PlantState();
}

class _PlantState extends State<Plant> {
  final List<Map<String, String>> plants = [
    {'name': 'Sun Flower🌻', 'image': 'assets/shappy.jpg'},
    {'name': 'Cactus', 'image': 'assets/happy.jpg'},
  ];

  Future<void> saveSelectedPlant(String name, String image, Widget page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plantName', name);
    await prefs.setString('plantImage', image);
    await prefs.setString('plantStartDate', DateTime.now().toIso8601String());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You chose $name 🌱")),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildPlantBox(int index) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            saveSelectedPlant(plants[index]['name']!, plants[index]['image']!, const SunFlowerPage());
            break;
          case 1:
            saveSelectedPlant(plants[index]['name']!, plants[index]['image']!, const ViewPlant());
            break;
          default:
            saveSelectedPlant(plants[index]['name']!, plants[index]['image']!, const ViewPlant());
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  plants[index]['image']!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              child: Text(
                plants[index]['name']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "WaterMe 🌻",
          style: TextStyle(color: Colors.white,),
        ),centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 500,
                height: 300,
                child: _buildPlantBox(0),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 500,
                height: 300,
                child: _buildPlantBox(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
