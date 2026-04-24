import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            SizedBox(height: 10,),
            //header text
            Text("Enter your 4-digit code",style: TextStyle(
              fontSize: 26,
              fontWeight: .w500
            ),
            ),
            SizedBox(height:20,),
            //code field
            MaterialPinField(
              keyboardType: .number,
              length: 4,
              onCompleted: (pin) => print('PIN: $pin'),
              onChanged: (value) => print('Changed: $value'),
              theme: MaterialPinTheme(
                shape: MaterialPinShape.underlined,
                cellSize: Size(40, 30),
                borderColor: Colors.grey,
                focusedBorderColor: Colors.black,
              ),
            ),
            SizedBox(height: 60,),
            //Resend code
            TextButton(
                onPressed: (){
                  print("button pressed");
                },
              style: TextButton.styleFrom(
                alignment: .centerLeft,
                foregroundColor: Colors.green,
                backgroundColor: Colors.transparent,
                overlayColor: Colors.transparent,
              ),
                child: Text("Resend Code",style: TextStyle(
                  fontSize: 18,
                ),
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.pushNamed(context, '/locationScreen');
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
