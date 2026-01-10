import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/pet.dart';
import 'package:pawpal/user.dart';
import 'package:pawpal/mydonationspage.dart';

class PetDetailsPage extends StatefulWidget {
  final User user;
  final Pet pet;
  const PetDetailsPage({super.key, required this.user, required this.pet});

  @override
  State<PetDetailsPage> createState() => _PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> {
  // Adoption Logic
  void showAdoptDialog() {
    TextEditingController motivationCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Request to Adopt"),
        content: TextField(
          controller: motivationCtrl,
          decoration: const InputDecoration(
            labelText: "Why do you want to adopt?",
            hintText: "Tell us about your home and experience...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // VALIDATION CHECK
              String text = motivationCtrl.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please fill in your reason for adoption."),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              submitAdoption(text);
              Navigator.pop(context);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<void> submitAdoption(String motivation) async {
    await http.post(
      Uri.parse("${MyConfig.baseUrl}${MyConfig.backend}/submit_adoption.php"),
      body: {
        "user_id": widget.user.userId,
        "pet_id": widget.pet.petId,
        "motivation": motivation,
      },
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Request sent!")));
  }

  // Donation Dialog
  void showDonateDialog() {
    String type = "Money";
    TextEditingController amountCtrl = TextEditingController();
    TextEditingController descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Donate"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: type,
                    isExpanded: true,
                    items: ["Money", "Food", "Medical"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => type = val!),
                  ),
                  const SizedBox(height: 10),
                  if (type == "Money")
                    TextField(
                      controller: amountCtrl,
                      decoration: const InputDecoration(
                        labelText: "Amount (RM)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  if (type != "Money")
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: "Description (e.g. 1 Bag of Cat Food)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // --- VALIDATION START ---
                    if (type == "Money") {
                      String amt = amountCtrl.text.trim();
                      if (amt.isEmpty ||
                          double.tryParse(amt) == null ||
                          double.parse(amt) <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please enter a valid amount greater than 0",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Proceed to Payment Page
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyDonationsPage(
                            user: widget.user,
                            pet: widget.pet,
                            amount: amt,
                          ),
                        ),
                      );
                    } else {
                      // Validate Description for Food/Medical
                      String desc = descCtrl.text.trim();
                      if (desc.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please describe what you are donating",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Submit Standard Donation
                      submitDonation(type, "0", desc);
                      Navigator.pop(context);
                    }
                    // --- VALIDATION END ---
                  },
                  child: const Text("Donate"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> submitDonation(String type, String amount, String desc) async {
    await http.post(
      Uri.parse("${MyConfig.baseUrl}${MyConfig.backend}/submit_donation.php"),
      body: {
        "user_id": widget.user.userId,
        "pet_id": widget.pet.petId,
        "type": type,
        "amount": amount,
        "description": desc,
      },
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Donation successful!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet.petName ?? "Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SLIDER
            if (widget.pet.imagePaths != null &&
                widget.pet.imagePaths!.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: widget.pet.imagePaths!.length,
                  itemBuilder: (ctx, i) => Image.network(
                    "${MyConfig.baseUrl}${MyConfig.backend}/uploads/pets/${widget.pet.imagePaths![i]}",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 15),

            // PET NAME
            Text(
              widget.pet.petName ?? "",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            // ADDED: POSTED BY
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  "Posted by: ${widget.pet.ownerName ?? 'Unknown'}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // DETAILS: AGE, GENDER, TYPE
            Row(
              children: [
                Chip(label: Text("Age: ${widget.pet.petAge ?? 'N/A'}")),
                const SizedBox(width: 5),
                Chip(label: Text(widget.pet.petGender ?? 'N/A')),
                const SizedBox(width: 5),
                Chip(label: Text(widget.pet.petType ?? "")),
              ],
            ),

            // CATEGORY
            const SizedBox(height: 10),
            Text(
              "Category: ${widget.pet.category}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Health: ${widget.pet.petHealth ?? 'Not specified'}",
              style: const TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
            const SizedBox(height: 10),
            const Divider(),
            Text(
              "Description",
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.pet.description ?? "",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            if (widget.pet.category == "Adoption")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: showAdoptDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text(
                    "Request to Adopt",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

            if (widget.pet.category == "Donation Request" ||
                widget.pet.category == "Help / Rescue")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: showDonateDialog,
                  child: const Text(
                    "Donate Now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
