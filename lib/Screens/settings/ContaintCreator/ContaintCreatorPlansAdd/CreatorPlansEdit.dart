import 'package:flutter/material.dart';

import '../../../../constants.dart';
import 'CreatorPlansPage.dart';

class SubscriptionEditScreen extends StatefulWidget {
  final SubscriptionModel subscription;

  const SubscriptionEditScreen({super.key, required this.subscription});

  @override
  State<SubscriptionEditScreen> createState() => _SubscriptionEditScreenState();
}

class _SubscriptionEditScreenState extends State<SubscriptionEditScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController featureController;
  late List<String> features;

  final _formKey = GlobalKey<FormState>();
double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.subscription.name);
    descriptionController = TextEditingController(text: widget.subscription.description);
    priceController = TextEditingController(text: widget.subscription.price.toString());
    featureController = TextEditingController();
    features = List.from(widget.subscription.features);
  }

  void addFeature(String feature) {
    if (feature.trim().isNotEmpty && !features.contains(feature.trim())) {
      setState(() {
        features.add(feature.trim());
        featureController.clear();
      });
    }
  }

  void removeFeature(int index) {
    setState(() {
      features.removeAt(index);
    });
  }

  void saveSubscription() {
    if (_formKey.currentState!.validate()) {
      final updated = SubscriptionModel(
        name: nameController.text,
        description: descriptionController.text,
        price: double.tryParse(priceController.text) ?? widget.subscription.price,
        features: features,
      );

      Navigator.pop(context, updated);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator: (value) => value == null || value.trim().isEmpty ? 'Enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF1694), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features
          .asMap()
          .entries
          .map(
            (entry) => Chip(
              label: Text(entry.value, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.white10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white30),
              ),
              deleteIconColor: Colors.redAccent,
              onDeleted: () => removeFeature(entry.key),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFeatureInputRow() {
    return Row(
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
                borderSide: const BorderSide(color: Color(0xFFFF1694), width: 1.5),
              ),
            ),
            onFieldSubmitted: addFeature,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => addFeature(featureController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF1694),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Add",style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          )),
        )
      ],
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
        onPressed: saveSubscription,
        child:  Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text("Save Changes",
              style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
      //  final screenWidth = MediaQuery.of(context).size.width * 0.02;
    final screenHeight = MediaQuery.of(context).size.height * 0.02;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:  Text('Edit Subscription',style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          )),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Plan Name", nameController),
              _buildTextField("Description", descriptionController),
              _buildTextField("Monthly Price", priceController, keyboardType: TextInputType.number),
SizedBox(height: screenHeight* 0.01),
              const Text("Features",
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
SizedBox(height: screenHeight* 0.01),
              _buildFeaturesList(),
             SizedBox(height: screenHeight* 0.01),
              _buildFeatureInputRow(),
              SizedBox(height: screenHeight* 0.01),
              _buildGradientButton(),
              SizedBox(height: screenHeight* 0.01),
            ],
          ),
        ),
      ),
    );
  }
}
