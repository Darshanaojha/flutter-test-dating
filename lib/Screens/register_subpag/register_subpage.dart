import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart'; 


class MultiStepFormPage extends StatefulWidget {
  const MultiStepFormPage({super.key});

  @override
  _MultiStepFormPageState createState() => _MultiStepFormPageState();
}

class _MultiStepFormPageState extends State<MultiStepFormPage> {
  // Variables to hold the selected day, month, and year
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  String name = '';
  String? gender;
  String description = '';  // Variable to hold description text

  int currentPage = 1;
  final PageController _pageController = PageController();  // Create a PageController instance

  @override
  Widget build(BuildContext context) {
    // Get screen size and orientation
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Adjust text sizes, padding, and spacing dynamically based on screen size
    double padding = isPortrait ? 16.0 : 24.0;
    double fontSize = screenWidth < 400 ? 18 : 20;
    double buttonFontSize = screenWidth < 400 ? 16 : 18;
    double buttonHeight = screenHeight < 600 ? 48 : 56;

    return Scaffold(
      appBar: AppBar(
        // title: Text('Multi-Step Form'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "$currentPage of 5", 
                style: TextStyle(
                  fontSize: isPortrait ? fontSize : fontSize + 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        // color: Colors.black,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                // PageView to hold different steps
                Container(
                  height: screenHeight * 0.6,  // Adjust height dynamically
                  child: PageView(
                    controller: _pageController,  // Use the PageController instance
                    onPageChanged: (pageIndex) {
                      setState(() {
                        currentPage = pageIndex + 1;  // Update page number
                      });
                    },
                    children: [
                      _buildBirthdayStep(fontSize),
                      _buildNameStep(fontSize),
                      _buildGenderStep(fontSize),
                      _buildDescribeYourselfStep(fontSize),
                      _buildConfirmationStep(fontSize),
                    ],
                  ),
                ),
                // Next Button
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _nextStep,  // Navigate to the next step
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, buttonHeight), backgroundColor: Colors.blueAccent,  // Full width button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Step 1: Birthday Selection
  Widget _buildBirthdayStep(double fontSize) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "What is your date of birth?",
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "You must be 18+ to use this app.",
              style: TextStyle(fontSize: fontSize - 2, color: Colors.redAccent),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDatePicker("Day", 1, 31, selectedDay, (value) {
                  setState(() {
                    selectedDay = value;
                  });
                }),
                Text("/", style: TextStyle(fontSize: fontSize)),
                _buildDatePicker("Month", 1, 12, selectedMonth, (value) {
                  setState(() {
                    selectedMonth = value;
                  });
                }),
                Text("/", style: TextStyle(fontSize: fontSize)),
                _buildDatePicker("Year", 1900, DateTime.now().year, selectedYear, (value) {
                  setState(() {
                    selectedYear = value;
                  });
                }),
              ],
            ),
            SizedBox(height: 40),
            Text(
              "Selected Date: ${DateFormat('d MMM yyyy').format(DateTime(selectedYear, selectedMonth, selectedDay))}",
              style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the NumberPicker widget
  Widget _buildDatePicker(String label, int minValue, int maxValue, int currentValue, Function(int) onChanged) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18),
        ),
        NumberPicker(
          value: currentValue,
          minValue: minValue,
          maxValue: maxValue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Step 2: Name Input
  Widget _buildNameStep(double fontSize) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "What do we call you?",
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                name = value;
              },
              decoration: InputDecoration(
                labelText: "Your Name",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Gender Selection
  Widget _buildGenderStep(double fontSize) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Select your gender",
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            RadioListTile<String>(
              title: Text('Male'),
              value: 'Male',
              groupValue: gender,
              onChanged: (String? value) {
                setState(() {
                  gender = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Female'),
              value: 'Female',
              groupValue: gender,
              onChanged: (String? value) {
                setState(() {
                  gender = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Non-Binary'),
              value: 'Non-Binary',
              groupValue: gender,
              onChanged: (String? value) {
                setState(() {
                  gender = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Step 4: Describe Yourself (New Step)
  Widget _buildDescribeYourselfStep(double fontSize) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Describe Yourself",
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Feel free to write a short description about yourself. You can mention your hobbies, interests, or anything that helps us get to know you better.",
              style: TextStyle(fontSize: fontSize - 2),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Describe yourself...",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Step 5: Confirmation
  Widget _buildConfirmationStep(double fontSize) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Confirmation",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 20),
        // Card to wrap the confirmation details
        Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildConfirmationRow("Name", name, Icons.person),
                SizedBox(height: 12),
                _buildConfirmationRow(
                    "Birthday", DateFormat.yMMMd().format(DateTime(selectedYear, selectedMonth, selectedDay)), Icons.calendar_today),
                SizedBox(height: 12),
                _buildConfirmationRow("Gender", gender ?? 'Not Selected', Icons.accessibility),
                SizedBox(height: 12),
                _buildConfirmationRow("Description", description.isEmpty ? 'Not Provided' : description, Icons.description),
              ],
            ),
          ),
        ),
        SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle edit action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle form submission
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Form Submitted'),
                    content: Text('Your details have been submitted successfully!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text('Submit'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Helper method for displaying a single row of confirmation data with an icon
Widget _buildConfirmationRow(String label, String value, IconData icon) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(icon, color: Colors.blueAccent, size: 24),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          "$label: $value",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    ],
  );
}


  // Function to move to the next step
  void _nextStep() {
    if (currentPage == 1) {

      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 2) {
      // If on page 2 (name), go to page 3 (gender)
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 3) {
      // If on page 3 (gender), go to page 4 (describe yourself)
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 4) {
      // If on page 4 (describe yourself), go to page 5 (confirmation)
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      // If on page 5 (final page), perform the final action (e.g. submit the form)
      // For now, we will just show a success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Form Submitted'),
          content: Text('Your details have been submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally, navigate to another page
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}


