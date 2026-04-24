import 'package:flutter/material.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {

  String? selectedZone;
  String? selectedArea;

  List<String> zones = [
    "Banasree",
    "Gulshan",
    "Uttara",
    "Dhanmondi"
  ];
  List<String> areas = [
    "Block A",
    "Block B",
    "Block C",
    "Block D"
  ];

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_outlined),
        ),
      ),

      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //image
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                "images/location.png",
                fit: BoxFit.scaleDown,
                height: screenHeight * 0.25,
                width: screenWidth * 0.65,
              ),
            ),
             SizedBox(height: 20),
            // Header text
             Text(
              "Select Your Location",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
             SizedBox(height: 10),
            // Sub text
            Text(
              "Switch on your location to stay in tune with\nwhat’s happening in your area",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
             SizedBox(height: 40),
            //Your Zone
             Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Zone",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
             SizedBox(height: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Select Zone"),
                value: selectedZone,
                items: zones.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedZone = value;
                  });
                },
              ),
            ),
             Divider(),
             SizedBox(height: 15),
            // Your Area
             Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Area",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint:  Text("Types of your area"),
                value: selectedArea,
                items: areas.map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedArea = value;
                  });
                },
              ),
            ),
             Divider(),
             SizedBox(height: 50),
            //SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 67,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // Navigator.pushNamed(context,'/logIn');
                },
                child:  Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}