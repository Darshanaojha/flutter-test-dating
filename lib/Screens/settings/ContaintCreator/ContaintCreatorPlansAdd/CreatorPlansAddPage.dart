import 'package:flutter/material.dart';

class AddSubscriptionFormPage extends StatefulWidget {
  const AddSubscriptionFormPage({super.key});

  @override
  State<AddSubscriptionFormPage> createState() => _AddSubscriptionFormPageState();
}

class _AddSubscriptionFormPageState extends State<AddSubscriptionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final featureController = TextEditingController();

  List<String> features = [];

  void addFeature() {
    final text = featureController.text.trim();
    if (text.isNotEmpty && !features.contains(text)) {
      setState(() {
        features.add(text);
        featureController.clear();
      });
    }
  }

  void removeFeature(int index) {
    setState(() {
      features.removeAt(index);
    });
  }

  void createPlan() {
    if (_formKey.currentState!.validate()) {
      // For now, just print the values
      debugPrint('Plan Created!');
      debugPrint('Name: ${nameController.text}');
      debugPrint('Description: ${descriptionController.text}');
      debugPrint('Price: ${priceController.text}');
      debugPrint('Features: $features');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan created successfully!')),
      );
    }
  }

  Widget _buildStyledInput(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF1694), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _headerBanner() {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://source.unsplash.com/featured/?creative,studio"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.85), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        const Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create Subscription Plan 💼",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Design and submit your package",
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFeatures() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.asMap().entries.map((entry) {
        return Chip(
          label: Text(entry.value, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.white24)),
          onDeleted: () => removeFeature(entry.key),
          deleteIconColor: Colors.redAccent,
        );
      }).toList(),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff870160), Color(0xfff39060)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextButton(
        onPressed: createPlan,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text("Create Plan",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add Subscription'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _headerBanner(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStyledInput("Plan Name", nameController),
                    _buildStyledInput("Description", descriptionController),
                    _buildStyledInput("Monthly Price", priceController,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    const Text("Features",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildFeatures(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: featureController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Add a feature',
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.black,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFFF1694), width: 1.5),
                              ),
                            ),
                            onFieldSubmitted: (_) => addFeature(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: addFeature,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF1694),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          child: const Text("Add"),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildGradientButton(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
