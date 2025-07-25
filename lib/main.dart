import 'package:flutter/material.dart';

void main() {
  runApp(BusTicketApp());
}

class BusTicketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Ticket Booking',
      home: TicketBookingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TicketBookingPage extends StatefulWidget {
  @override
  _TicketBookingPageState createState() => _TicketBookingPageState();
}

class _TicketBookingPageState extends State<TicketBookingPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String source = '';
  String destination = '';
  DateTime? travelDate;
  TimeOfDay? travelTime;
  List<Map<String, dynamic>> bookings = [];

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: travelDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        travelDate = picked;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: travelTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        travelTime = picked;
      });
    }
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Ticket'),
        content: Text(
            'Do you want to confirm the ticket for $name from $source to $destination on ${travelDate!.toLocal().toString().split(' ')[0]} at ${travelTime!.format(context)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finalizeBooking();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _finalizeBooking() {
    final DateTime combinedDateTime = DateTime(
      travelDate!.year,
      travelDate!.month,
      travelDate!.day,
      travelTime!.hour,
      travelTime!.minute,
    );

    setState(() {
      bookings.add({
        'name': name,
        'source': source,
        'destination': destination,
        'date': combinedDateTime,
      });
      name = '';
      source = '';
      destination = '';
      travelDate = null;
      travelTime = null;
      _formKey.currentState!.reset();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ticket confirmed successfully!")),
    );
  }

  void _bookTicket() {
    if (_formKey.currentState!.validate() &&
        travelDate != null &&
        travelTime != null) {
      _formKey.currentState!.save();
      _confirmBooking();
    }
  }

  void _showAllBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllBookingsPage(bookings: bookings),
      ),
    );
  }

  Widget _buildPickupDateTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (travelDate != null)
          Text(
            "📅 Date: ${travelDate!.toLocal().toString().split(' ')[0]}",
            style: TextStyle(fontSize: 16),
          ),
        if (travelTime != null)
          Text(
            "⏰ Time: ${travelTime!.format(context)}",
            style: TextStyle(fontSize: 16),
          ),
        if (travelDate == null && travelTime == null)
          Text(
            "No date/time selected",
            style: TextStyle(color: Color(0xffd51010)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Ticket Booking'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _showAllBookings,
          )
        ],
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffd03fe6), Colors.purple.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  "Fill Passenger Details",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                  onSaved: (val) => name = val!,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'From',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter source' : null,
                  onSaved: (val) => source = val!,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter destination' : null,
                  onSaved: (val) => destination = val!,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text("Pickup Date:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Select Date'),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text("Pickup Time:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: Text('Select Time'),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                _buildPickupDateTime(),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: Icon(Icons.check),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.limeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _bookTicket,
                  label: Text('Book Ticket',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AllBookingsPage extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  AllBookingsPage({required this.bookings});

  Map<String, List<Map<String, dynamic>>> groupBookingsByMonth() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var booking in bookings) {
      final date = booking['date'] as DateTime;
      final monthKey = "${_monthName(date.month)} ${date.year}";
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(booking);
    }
    return grouped;
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final groupedBookings = groupBookingsByMonth();
    return Scaffold(
      appBar: AppBar(
        title: Text('Booked Tickets'),
        backgroundColor: Color(0xffea2525),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.deepOrange.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: bookings.isEmpty
            ? Center(
                child: Text(
                  'No bookings yet',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
            : ListView(
                children: groupedBookings.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                      ...entry.value.map((booking) {
                        final date = booking['date'] as DateTime;
                        final formattedDate =
                            "${date.toLocal().toString().split(' ')[0]}";
                        final formattedTime =
                            "${TimeOfDay.fromDateTime(date).format(context)}";

                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          elevation: 4,
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("👤 Name: ${booking['name']}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text("📍 From: ${booking['source']}",
                                    style: TextStyle(fontSize: 16)),
                                Text("🎯 To: ${booking['destination']}",
                                    style: TextStyle(fontSize: 16)),
                                Text("📅 Date: $formattedDate",
                                    style: TextStyle(fontSize: 16)),
                                Text("⏰ Time: $formattedTime",
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ),
      ),
    );
  }
}
