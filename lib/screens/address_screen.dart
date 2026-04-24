import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/address_model.dart';
import '../services/address_services.dart';



class AddressScreen extends StatelessWidget {
  AddressScreen({super.key});

  final AddressService _addressService = AddressService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delivery Address")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _addressService.getAddresses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data!.docs;

          if (addresses.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/addAddress'),
                child: const Text("Add Address"),
              ),
            );
          }

          String selectedId = "";

          for (var doc in addresses) {
            var data = doc.data() as Map<String, dynamic>;
            if (data['isSelected'] == true) {
              selectedId = doc.id;
              break;
            }
          }

          if (selectedId.isEmpty) {
            selectedId = addresses.first.id;
            _addressService.selectAddress(selectedId);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/addAddress'),
                    icon: const Icon(Icons.add),
                    label: const Text("Add New Address"),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      var doc = addresses[index];
                      var data =
                      doc.data() as Map<String, dynamic>;

                      return Card(
                        elevation: 0,
                        child: ListTile(
                          leading: Radio<String>(
                            value: doc.id,
                            groupValue: selectedId,
                            onChanged: (value) async {
                              await _addressService
                                  .selectAddress(value!);
                            },
                          ),
                          title:
                          Text("${data['house']}, ${data['area']}"),
                          subtitle: Text(
                              "${data['city']} - ${data['pincode']}"),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              //  EDIT BUTTON
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddAddressScreen(
                                        addressId: doc.id,
                                        existingData: data,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              //  DELETE BUTTON
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Delete Address"),
                                        content: const Text(
                                            "Are you sure you want to delete this address?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Cancel",style: TextStyle(color: Colors.grey),),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await _addressService.deleteAddress(doc.id);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () async {
                            await _addressService
                                .selectAddress(doc.id);
                          },

                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AddAddressScreen extends StatefulWidget {
  final String? addressId;
  final Map<String, dynamic>? existingData;

  const AddAddressScreen({
    super.key,
    this.addressId,
    this.existingData,
  });

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

  @override
  void initState() {
    super.initState();

    // ✏ PREFILL FOR EDIT
    if (widget.existingData != null) {
      nameController.text = widget.existingData!['name'] ?? '';
      phoneController.text = widget.existingData!['phone'] ?? '';
      houseController.text = widget.existingData!['house'] ?? '';
      areaController.text = widget.existingData!['area'] ?? '';
      cityController.text = widget.existingData!['city'] ?? '';
      pincodeController.text = widget.existingData!['pincode'] ?? '';
    }
  }

  void saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final address = AddressModel(
      name: nameController.text,
      phone: phoneController.text,
      house: houseController.text,
      area: areaController.text,
      city: cityController.text,
      pincode: pincodeController.text,
      type: "Home",
    );

    if (widget.addressId == null) {
      //  ADD
      await _addressService.addAddress(address);
    } else {
      // ️ UPDATE
      await _addressService.updateAddress(widget.addressId!, address);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.addressId == null
            ? "Add Address"
            : "Edit Address"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration:
                const InputDecoration(labelText: "Name"),
                validator: (v) =>
                v!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration:
                const InputDecoration(labelText: "Phone"),
                validator: (v) =>
                v!.isEmpty ? "Enter phone" : null,
              ),
              TextFormField(
                controller: houseController,
                decoration:
                const InputDecoration(labelText: "House / Flat"),
                validator: (v) =>
                v!.isEmpty ? "Enter house" : null,
              ),
              TextFormField(
                controller: areaController,
                decoration:
                const InputDecoration(labelText: "Area"),
                validator: (v) =>
                v!.isEmpty ? "Enter area" : null,
              ),
              TextFormField(
                controller: cityController,
                decoration:
                const InputDecoration(labelText: "City"),
                validator: (v) =>
                v!.isEmpty ? "Enter city" : null,
              ),
              TextFormField(
                controller: pincodeController,
                decoration:
                const InputDecoration(labelText: "Pincode"),
                validator: (v) =>
                v!.isEmpty ? "Enter pincode" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveAddress,
                child: Text(widget.addressId == null
                    ? "Save Address"
                    : "Update Address"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}