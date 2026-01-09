import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/user.dart';
import 'package:pawpal/pet.dart';

class MyDonationsPage extends StatefulWidget {
  final User user;
  final Pet? pet; // Optional: Only for making a payment
  final String? amount; // Optional: Only for making a payment

  const MyDonationsPage({super.key, required this.user, this.pet, this.amount});

  @override
  State<MyDonationsPage> createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  // History Variables
  List donations = [];
  bool isPaymentMode = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.pet != null && widget.amount != null) {
      isPaymentMode = true;
    } else {
      isPaymentMode = false;
      loadDonations();
    }
  }

  // --- HISTORY LOGIC ---
  Future<void> loadDonations() async {
    final response = await http.get(
      Uri.parse(
        "${MyConfig.baseUrl}${MyConfig.backend}/get_my_donations.php?user_id=${widget.user.userId}",
      ),
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['status'] == 'success') {
        setState(() {
          donations = json['data'];
        });
      }
    }
  }

  // --- DUMMY PAYMENT LOGIC ---
  Future<void> _processDummyPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    try {
      var response = await http.post(
        Uri.parse("${MyConfig.baseUrl}${MyConfig.backend}/submit_donation.php"),
        body: {
          "user_id": widget.user.userId,
          "pet_id": widget.pet!.petId,
          "type": "Money",
          "amount": widget.amount,
          "description": "Donation (Dummy Payment)",
        },
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment Successful! Thank you."),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Failed: ${json['message']}")));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    // 1. PAYMENT SCREEN
    if (isPaymentMode) {
      return Scaffold(
        appBar: AppBar(title: const Text("Secure Payment")),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Payment Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.pets, color: Colors.orange),
                  title: Text("Donation to: ${widget.pet!.petName}"),
                  subtitle: Text("Amount: RM ${widget.amount}"),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Payment Method (Simulated)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PawPal Card",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "**** **** **** 4242",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Holder: ${widget.user.userName}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const Text(
                          "Exp: 12/29",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processDummyPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Pay RM ${widget.amount}",
                          style: const TextStyle(
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

    // 2. DONATION HISTORY LIST 
    return Scaffold(
      appBar: AppBar(title: const Text("My Donations")),
      body: donations.isEmpty
          ? const Center(child: Text("No donations yet"))
          : ListView.builder(
              itemCount: donations.length,
              itemBuilder: (context, index) {
                var d = donations[index];

                
                String? imageUrl;
                if (d['image_paths'] != null &&
                    d['image_paths'] is List &&
                    (d['image_paths'] as List).isNotEmpty) {
                  imageUrl =
                      "${MyConfig.baseUrl}${MyConfig.backend}/uploads/pets/${d['image_paths'][0]}";
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    // UPDATED LEADING WIDGET
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl == null
                          ? const Icon(Icons.favorite, color: Colors.pinkAccent)
                          : null,
                    ),
                    title: Text("To: ${d['pet_name'] ?? 'Unknown Pet'}"),
                    subtitle: Text(
                      "Type: ${d['donation_type']} \nDetail: ${d['donation_type'] == 'Money' ? 'RM ' + d['amount'] : d['description']}",
                    ),
                    trailing: Text(
                      d['date_created'].toString().substring(0, 10),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
