
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';


// class SubscriptionEditScreen extends StatefulWidget {
//   final SubscriptionModel subscription;
//   final int index;

//   const SubscriptionEditScreen({
//     super.key,
//     required this.subscription,
//     required this.index,
//   });

//   @override
//   State<SubscriptionEditScreen> createState() => _SubscriptionEditScreenState();
// }

// class _SubscriptionEditScreenState extends State<SubscriptionEditScreen> {
//   late TextEditingController nameController;
//   late TextEditingController descriptionController;
//   late TextEditingController priceController;
//   late TextEditingController newFeatureController;
//   late List<String> features;

//   final _formKey = GlobalKey<FormState>();
//   final _controller = Get.find<ManageSubscriptionController>();

//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.subscription.name);
//     descriptionController = TextEditingController(text: widget.subscription.description);
//     priceController = TextEditingController(text: widget.subscription.price.toString());
//     newFeatureController = TextEditingController();
//     features = List.from(widget.subscription.features);
//   }

//   void saveChanges() {
//     if (_formKey.currentState!.validate()) {
//       final updated = SubscriptionModel(
//         name: nameController.text,
//         type: widget.subscription.type,
//         description: descriptionController.text,
//         features: features,
//         price: double.tryParse(priceController.text) ?? widget.subscription.price,
//         isActive: widget.subscription.isActive,
//       );

//       _controller.subscriptions[widget.index] = updated;
//       _controller.subscriptions.refresh();
//       Get.back();
//     }
//   }

//   void addFeature(String feature) {
//     if (feature.isNotEmpty && !features.contains(feature)) {
//       setState(() {
//         features.add(feature);
//         newFeatureController.clear();
//       });
//     }
//   }

//   void removeFeature(int index) {
//     setState(() {
//       features.removeAt(index);
//     });
//   }

//   Widget _buildStyledField(String label, TextEditingController controller,
//       {TextInputType keyboardType = TextInputType.text}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         style: const TextStyle(color: Colors.white),
//         validator: (value) {
//           if (value == null || value.trim().isEmpty) {
//             return 'Please enter $label';
//           }
//           return null;
//         },
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.white70),
//           filled: true,
//           fillColor: Colors.black,
//           contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.white),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.white),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFFFF1694), width: 1.5),
//           ),
//         ),
//       ),
//     );
//   }





//   Widget _buildGradientButton(String text, VoidCallback onPressed)
//   {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [
//             Color(0xff1f005c),
//             Color(0xff5b0060),
//             Color(0xff870160),
//             Color(0xffac255e),
//             Color(0xffca485c),
//             Color(0xffe16b5c),
//             Color(0xfff39060),
//             Color(0xfffffb56b),
//           ],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.circular(50),
//       ),
//       child: TextButton(
//         onPressed: onPressed,
//         child: const Padding(
//           padding: EdgeInsets.symmetric(vertical: 14),
//           child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Edit Subscription'),
//         backgroundColor: Colors.black,
//         iconTheme: const IconThemeData(color: Colors.white),
//         titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildStyledField("Name", nameController),
//               _buildStyledField("Description", descriptionController),
//               _buildStyledField("Price", priceController, keyboardType: TextInputType.number),

//               const SizedBox(height: 20),
//               const Text("Features", style: TextStyle(color: Colors.white70, fontSize: 16)),
//               const SizedBox(height: 10),

//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: features.asMap().entries.map((entry) {
//                   return Chip(
//                     label: Text(entry.value),
//                     onDeleted: () => removeFeature(entry.key),
//                     deleteIconColor: Colors.redAccent,
//                     backgroundColor: Colors.white10,
//                     labelStyle: const TextStyle(color: Colors.black),
//                   );
//                 }).toList(),
//               ),

//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: newFeatureController,
//                       style: const TextStyle(color: Colors.white),
//                       decoration: InputDecoration(
//                         hintText: 'Add new feature',
//                         hintStyle: const TextStyle(color: Colors.white54),
//                         filled: true,
//                         fillColor: Colors.black,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Colors.white),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Color(0xFFFF1694), width: 1.5),
//                         ),
//                       ),
//                       onFieldSubmitted: addFeature,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   // ElevatedButton
//                   //   (
//                   //   onPressed: () => addFeature(newFeatureController.text),
//                   //   style: ElevatedButton.styleFrom(
//                   //     backgroundColor: const Color(0xFFFF1694),
//                   //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   //   ),
//                   //   child: const Text("Add"),
//                   // ),

//                   OutlinedButton(
//                     onPressed: () => addFeature(newFeatureController.text),
//                     style: OutlinedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       side: const BorderSide(color: Colors.white, width: 1),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                     ).copyWith(
//                       side: MaterialStateProperty.resolveWith<BorderSide>((states) {
//                         if (states.contains(MaterialState.pressed) || states.contains(MaterialState.focused)) {
//                           return const BorderSide(color: Color(0xFFFF1694), width: 1.5);
//                         }
//                         return const BorderSide(color: Colors.white, width: 1);
//                       }),
//                     ),
//                     child: const Text(
//                       "Add",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 30),
//               _buildGradientButton("Save Changes", saveChanges),
//               const SizedBox(height: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
