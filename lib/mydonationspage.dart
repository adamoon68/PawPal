import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
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

  // Payment Variables
  late WebViewController _webController;
  bool isPaymentMode = false;

  @override
  void initState() {
    super.initState();

    // Check if we are in Payment Mode (Pet and Amount provided)
    if (widget.pet != null && widget.amount != null) {
      isPaymentMode = true;
      _initializePayment();
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

  // --- PAYMENT LOGIC ---
  void _initializePayment() {
    String url =
        "${MyConfig.baseUrl}${MyConfig.backend}/submit_donation.php?"
        "user_id=${widget.user.userId}&"
        "pet_id=${widget.pet!.petId}&"
        "type=Money&"
        "amount=${widget.amount}&"
        "email=${widget.user.userEmail}&"
        "phone=${widget.user.userPhone}&"
        "name=${widget.user.userName}";

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (url.contains('submit_donation.php')) {
              if (url.contains('billplz%5Bpaid%5D=true') ||
                  url.contains('paid=true')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Payment Successful!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Payment Failed"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              // Close page after delay
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    // If in Payment Mode, show WebView
    if (isPaymentMode) {
      return Scaffold(
        appBar: AppBar(title: const Text("Payment")),
        body: WebViewWidget(controller: _webController),
      );
    }

    // Otherwise, show Donation History
    return Scaffold(
      appBar: AppBar(title: const Text("My Donations")),
      body: donations.isEmpty
          ? const Center(child: Text("No donations yet"))
          : ListView.builder(
              itemCount: donations.length,
              itemBuilder: (context, index) {
                var d = donations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.favorite, color: Colors.white),
                    ),
                    title: Text("To: ${d['pet_name']}"),
                    subtitle: Text(
                      "Type: ${d['donation_type']} \nDetail: ${d['donation_type'] == 'Money' ? 'RM' + d['amount'] : d['description']}",
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
