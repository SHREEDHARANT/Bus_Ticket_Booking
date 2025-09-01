import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const BusTicketApp());
}

class BusTicketApp extends StatelessWidget {
  const BusTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Bus Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const TicketBookingPage(),
    );
  }
}

class TicketBookingPage extends StatefulWidget {
  const TicketBookingPage({super.key});

  @override
  State<TicketBookingPage> createState() => _TicketBookingPageState();
}

class _TicketBookingPageState extends State<TicketBookingPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String source = '';
  String destination = '';
  DateTime? travelDate;
  TimeOfDay? travelTime;
  int ticketQty = 1;
  String? selectedBus;

  final List<String> buses = [
    "National",
    "Alagan",
    "Chakra",
    "PSS",
    "Friends",
    "Mettur",
    "Vinagar",
    "Essar",
    "Galaxy",
    "Shakti",
    "Royal",
    "Express",
    "Velan",
    "Sundaram",
    "Sakthi",
    "GreenLine",
    "BlueStar",
    "RedLine",
    "Delta",
    "FastTrack",
    "CityLink",
    "MegaBus",
    "SuperFast",
    "Elite",
    "Victory"
  ];

  late final Map<String, int> busRates;

  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    busRates = {for (var bus in buses) bus: 500 + Random().nextInt(2001)};
  }

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: travelDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => travelDate = picked);
  }

  void _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: travelTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => travelTime = picked);
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Ticket - $selectedBus'),
        content: Text(
            'Confirm $ticketQty ticket(s) for $name from $source to $destination on ${travelDate!.day}-${travelDate!.month}-${travelDate!.year} at ${travelTime!.format(context)}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _finalizeBooking();
              },
              child: const Text('Confirm')),
        ],
      ),
    );
  }

  void _finalizeBooking() {
    final combinedDateTime = DateTime(travelDate!.year, travelDate!.month,
        travelDate!.day, travelTime!.hour, travelTime!.minute);

    final totalPrice = busRates[selectedBus]! * ticketQty;

    setState(() {
      bookings.add({
        'name': name,
        'from': source,
        'to': destination,
        'bus': selectedBus,
        'date': combinedDateTime,
        'qty': ticketQty,
        'totalPrice': totalPrice,
      });
      name = '';
      source = '';
      destination = '';
      travelDate = null;
      travelTime = null;
      ticketQty = 1;
      selectedBus = null;
      _formKey.currentState!.reset();
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ticket booked successfully!")));
  }

  void _bookTicket() {
    if (_formKey.currentState!.validate() &&
        travelDate != null &&
        travelTime != null &&
        selectedBus != null) {
      _formKey.currentState!.save();
      if (ticketQty > 5) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Cannot book more than 5 tickets per person")));
        return;
      }
      _confirmBooking();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill all fields including bus selection")));
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
              "📅 Date: ${travelDate!.day}-${travelDate!.month}-${travelDate!.year}"),
        if (travelTime != null) Text("⏰ Time: ${travelTime!.format(context)}"),
        if (travelDate == null && travelTime == null)
          const Text("No date/time selected",
              style: TextStyle(color: Colors.red)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Ticket Booking'),
        actions: [
          IconButton(icon: const Icon(Icons.list), onPressed: _showAllBookings)
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.red.shade100, Colors.red.shade300],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Your Name', filled: true),
                  validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                  onSaved: (val) => name = val!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'From', filled: true),
                  validator: (val) =>
                      val!.isEmpty ? 'Enter starting place' : null,
                  onSaved: (val) => source = val!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'To', filled: true),
                  validator: (val) => val!.isEmpty ? 'Enter destination' : null,
                  onSaved: (val) => destination = val!,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'Select Bus', filled: true),
                  value: selectedBus,
                  items: buses
                      .map((bus) => DropdownMenuItem(
                          value: bus, child: Text("$bus - ₹${busRates[bus]}")))
                      .toList(),
                  onChanged: (val) => setState(() => selectedBus = val),
                  validator: (val) =>
                      val == null ? 'Please select a bus' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Pickup Date:"),
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Select Date')),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text("Pickup Time:"),
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () => _selectTime(context),
                        child: const Text('Select Time')),
                  ],
                ),
                const SizedBox(height: 10),
                _buildPickupDateTime(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Tickets Qty:"),
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          if (ticketQty > 1) setState(() => ticketQty--);
                        },
                        icon: const Icon(Icons.remove)),
                    Text("$ticketQty"),
                    IconButton(
                        onPressed: () {
                          if (ticketQty < 5) setState(() => ticketQty++);
                        },
                        icon: const Icon(Icons.add)),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: _bookTicket,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15)),
                    child: const Text("Book Ticket",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AllBookingsPage extends StatefulWidget {
  final List<Map<String, dynamic>> bookings;
  const AllBookingsPage({super.key, required this.bookings});

  @override
  State<AllBookingsPage> createState() => _AllBookingsPageState();
}

class _AllBookingsPageState extends State<AllBookingsPage> {
  void _cancelTicket(int index) {
    final ticket = widget.bookings[index];
    final refund = (ticket['totalPrice'] as int) * 0.5;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Refunded ₹$refund (50%)")));
    setState(() {
      widget.bookings.removeAt(index);
    });
  }

  void _changeDate(int index) async {
    final ticket = widget.bookings[index];
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: ticket['date'],
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      TimeOfDay time = TimeOfDay.fromDateTime(ticket['date']);
      setState(() {
        widget.bookings[index]['date'] = DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute);
      });
    }
  }

  Map<String, List<Map<String, dynamic>>> groupByMonth() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var ticket in widget.bookings) {
      final dt = ticket['date'] as DateTime;
      final key = "${dt.month}-${dt.year}";
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(ticket);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupByMonth();
    return Scaffold(
      appBar: AppBar(
          title: const Text("Booked Tickets"), backgroundColor: Colors.red),
      body: grouped.isEmpty
          ? const Center(child: Text("No bookings yet"))
          : ListView(
              children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text("Month: ${entry.key}",
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                  ...entry.value.map((ticket) {
                    final dt = ticket['date'] as DateTime;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title:
                            Text("${ticket['bus']} - ₹${ticket['totalPrice']}"),
                        subtitle: Text(
                            "${ticket['name']} | ${ticket['from']} → ${ticket['to']}\nDate: ${dt.day}-${dt.month}-${dt.year} | Time: ${TimeOfDay.fromDateTime(dt).format(context)}\nQty: ${ticket['qty']}"),
                        trailing: Column(
                          children: [
                            ElevatedButton(
                                onPressed: () => _cancelTicket(
                                    widget.bookings.indexOf(ticket)),
                                child: const Text("Cancel")),
                            const SizedBox(height: 4),
                            ElevatedButton(
                                onPressed: () => _changeDate(
                                    widget.bookings.indexOf(ticket)),
                                child: const Text("Change Date")),
                          ],
                        ),
                      ),
                    );
                  }).toList()
                ],
              );
            }).toList()),
    );
  }
}
