import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';

import '../models/address_model.dart';
import '../services/address_services.dart';

class AddressScreen extends StatelessWidget {
  AddressScreen({super.key});

  final AddressService _addressService = AddressService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "My Addresses",
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.pushNamed(context, '/addAddress');
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Address", style: TextStyle(color: Colors.white)),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _addressService.getAddresses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final addresses = snapshot.data!.docs;

          if (addresses.isEmpty) {
            return _emptyState(context);
          }

          String selectedId = "";

          for (var doc in addresses) {
            final data = doc.data() as Map<String, dynamic>;

            if (data['isSelected'] == true) {
              selectedId = doc.id;
              break;
            }
          }

          if (selectedId.isEmpty) {
            selectedId = addresses.first.id;
            _addressService.selectAddress(selectedId);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final doc = addresses[index];
              final data = doc.data() as Map<String, dynamic>;

              final bool isSelected = doc.id == selectedId;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () async {
                    await _addressService.selectAddress(doc.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                data['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                data['type'] ?? 'Home',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          data['phone'] ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "${data['house']}, ${data['area']}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "${data['city']} - ${data['pincode']}",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text("Edit"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddAddressScreen(
                                        addressId: doc.id,
                                        existingData: data,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  elevation: 0,
                                ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                label: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Text("Delete Address"),
                                      content: const Text(
                                        "Are you sure you want to remove this address?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(context);

                                            await _addressService.deleteAddress(
                                              doc.id,
                                            );
                                          },
                                          child: const Text("Delete"),
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              "No Addresses Added",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Add a delivery address to continue shopping.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/addAddress');
              },
              label: const Text("Add Address"),
            ),
          ],
        ),
      ),
    );
  }
}

class AddAddressScreen extends StatefulWidget {
  final String? addressId;
  final Map<String, dynamic>? existingData;

  const AddAddressScreen({super.key, this.addressId, this.existingData});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final houseController = TextEditingController();
  final areaController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();

  final AddressService _addressService = AddressService();

  String selectedType = "Home";

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      nameController.text = widget.existingData!['name'] ?? '';
      phoneController.text = widget.existingData!['phone'] ?? '';
      houseController.text = widget.existingData!['house'] ?? '';
      areaController.text = widget.existingData!['area'] ?? '';
      cityController.text = widget.existingData!['city'] ?? '';
      pincodeController.text = widget.existingData!['pincode'] ?? '';
      selectedType = widget.existingData!['type'] ?? 'Home';
    }
  }

  Future<void> saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final address = AddressModel(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      house: houseController.text.trim(),
      area: areaController.text.trim(),
      city: cityController.text.trim(),
      pincode: pincodeController.text.trim(),
      type: selectedType,
    );

    if (widget.addressId == null) {
      await _addressService.addAddress(address);
    } else {
      await _addressService.updateAddress(widget.addressId!, address);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  InputDecoration fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget addressTypeChip(String type) {
    final bool selected = selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          type,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.addressId != null;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.background,
        title: Text(
          isEdit ? "Edit Address" : "Add Address",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                isEdit ? "Update Address" : "Save Address",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Contact Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: nameController,
              decoration: fieldDecoration("Full Name", Icons.person_outline),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter your name";
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: fieldDecoration("Phone Number", Icons.phone_outlined),
              validator: (value) {
                if (value == null || value.length != 10) {
                  return "Enter valid phone number";
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "Address Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: houseController,
              decoration: fieldDecoration(
                "House / Flat / Building",
                Icons.home_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter house details";
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: areaController,
              decoration: fieldDecoration(
                "Area / Street",
                Icons.location_on_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter area";
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: cityController,
              decoration: fieldDecoration("City", Icons.location_city_outlined),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter city";
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: pincodeController,
              keyboardType: TextInputType.number,
              decoration: fieldDecoration("Pincode", Icons.pin_drop_outlined),
              validator: (value) {
                if (value == null || value.length != 6) {
                  return "Enter valid pincode";
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "Address Type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: addressTypeChip("Home")),
                const SizedBox(width: 10),
                Expanded(child: addressTypeChip("Work")),
                const SizedBox(width: 10),
                Expanded(child: addressTypeChip("Other")),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
