//=====1. import Packages & Files==================================================================
import 'package:flutter/material.dart';
import 'database_helper.dart';

//=====2. Root widget==============================================================================
class BookingPage extends StatefulWidget {
  final int userId; // 👈 accept userId from ColumnPage
  const BookingPage({super.key, required this.userId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

//=====3. Booking widget (Functions)=======================================================
class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPlace;
  String? _selectedTime;
  String? _selectedPax;
  DateTime? _selectedDate;

  final List<String> places = [
    "Study Room 1",
    "Study Room 2",
    "Study Room 3",
    "Badminton Court",
    "Volleyball Court",
    "Pickleball Court",
    "Chemistry Lab",
    "Electrical Lab",
    "Computer Lab",
  ];

  final List<String> timeSlots = [
    "8:30 AM","9:30 AM","10:30 AM","11:30 AM","12:30 PM","1:30 PM","2:30 PM",
    "3:30 PM","4:30 PM","5:30 PM","6:30 PM","7:30 PM","8:30 PM","9:30 PM","10:30 PM"
  ];

  final List<String> paxOptions = ["Single", "Pair", "Group"];

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      final db = DatabaseHelper.instance;

      final dateStr = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";

      await db.insertBooking({
        'userId': widget.userId,
        'date': dateStr,
        'time': _selectedTime,
        'place': _selectedPlace,
        'status': 'Pending',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking submitted successfully!")),
      );

      setState(() {
        _selectedPlace = null;
        _selectedTime = null;
        _selectedPax = null;
        _selectedDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Book a Space",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Place Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedPlace, // ✅ use initialValue
                decoration: _inputDecoration("Select Place", Icons.location_on),
                items: places
                    .map((place) =>
                        DropdownMenuItem(value: place, child: Text(place)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedPlace = value),
                validator: (value) =>
                    value == null ? "Please select a place" : null,
              ),
              const SizedBox(height: 16),

              // Date Picker
              TextFormField(
                readOnly: true,
                decoration: _inputDecoration("Select Date", Icons.date_range),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    if (!mounted) return; // ✅ safe before setState
                    setState(() => _selectedDate = picked);
                  }
                },
                controller: TextEditingController(
                  text: _selectedDate == null
                      ? ""
                      : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                ),
                validator: (value) =>
                    _selectedDate == null ? "Please select a date" : null,
              ),
              const SizedBox(height: 16),

              // Time Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedTime, // ✅ use initialValue
                decoration: _inputDecoration("Select Time", Icons.access_time),
                items: timeSlots
                    .map((slot) =>
                        DropdownMenuItem(value: slot, child: Text(slot)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedTime = value),
                validator: (value) =>
                    value == null ? "Please select a time" : null,
              ),
              const SizedBox(height: 16),

              // Pax Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedPax, // ✅ use initialValue
                decoration: _inputDecoration("Number of Pax", Icons.people),
                items: paxOptions
                    .map((pax) =>
                        DropdownMenuItem(value: pax, child: Text(pax)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedPax = value),
                validator: (value) =>
                    value == null ? "Please select pax" : null,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5E4E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitBooking,
                  child: const Text("Book Now",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2E5E4E)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}