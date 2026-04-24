import 'package:flutter/material.dart';
import 'package:grocery_app/services/auth_services.dart';

import '../../core/theme/app_colors.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

final AuthServices _authServices = AuthServices();

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Customers")),

      body: StreamBuilder(
        stream: _authServices.getUsers(),
        builder: (context, snapshot) {
          /// LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// EMPTY
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Users Found"));
          }

          final users = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 30,
                    headingRowHeight: 55,
                    dataRowHeight: 60,
                    headingRowColor: MaterialStateProperty.all(
                      AppColors.primary.withOpacity(0.2),
                    ),

                    columns: const [
                      DataColumn(
                        label: Text(
                          "Username",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Email",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Role",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "UID",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],

                    rows: users.map((user) {
                      return DataRow(
                        cells: [
                          /// USERNAME
                          DataCell(
                            Text(
                              user.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          /// EMAIL
                          DataCell(
                            SizedBox(
                              width: 180,
                              child: Text(
                                user.email,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          /// ROLE
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: user.role == "admin"
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user.role.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: user.role == "admin"
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          /// UID (short)
                          DataCell(
                            Text(
                              user.id,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
