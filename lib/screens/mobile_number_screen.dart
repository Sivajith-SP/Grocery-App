import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class MobileNumberScreen extends StatelessWidget {
  const MobileNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              //back button
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios_outlined),
              ),
              //Header Text
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text("Enter your mobile number",style: TextStyle(
                  fontSize: 26,
                  fontWeight: .w500,
                ),),
              ),
              SizedBox(height: 10,),
              //sub text
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text("Mobile Number",style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: .w600,
                ),),
              ),
              //phone field
              Padding(
                padding: .only(left: 24,right: 24),
                child: IntlPhoneField(
                  flagsButtonPadding: .only(right: 10),
                  initialCountryCode: "IN",
                  showDropdownIcon: false,
                  disableLengthCheck: false,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  keyboardType:TextInputType.phone,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 260,),
        
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, '/verificationScreen');
        },
        shape: RoundedRectangleBorder(
            borderRadius: .circular(30)
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(Icons.arrow_forward_ios_rounded),
      ),
    );
  }
}
