import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() {
  runApp(BirthdayReminderApp());
}

class BirthdayReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birthday Reminder',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: BirthdayReminderHome(),
    );
  }
}

class Birthday {
  String name;
  DateTime date;

  Birthday({required this.name, required this.date});
}

class BirthdayReminderHome extends StatefulWidget {
  @override
  _BirthdayReminderHomeState createState() => _BirthdayReminderHomeState();
}

class _BirthdayReminderHomeState extends State<BirthdayReminderHome> {
  final List<Birthday> _birthdays = [];
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  int? _editingIndex;

  void _addOrUpdateBirthday() {
    if (_nameController.text.isEmpty || _selectedDate == null) return;

    setState(() {
      if (_editingIndex != null) {
        // Update existing
        _birthdays[_editingIndex!] = Birthday(
          name: _nameController.text,
          date: _selectedDate!,
        );
        _editingIndex = null;
      } else {
        // Add new
        _birthdays.add(
          Birthday(name: _nameController.text, date: _selectedDate!),
        );
      }

      _nameController.clear();
      _selectedDate = null;
    });
  }

  void _startEditing(int index) {
    setState(() {
      _editingIndex = index;
      _nameController.text = _birthdays[index].name;
      _selectedDate = _birthdays[index].date;
    });
  }

  void _deleteBirthday(int index) {
    setState(() {
      _birthdays.removeAt(index);
    });
  }

  int _daysUntil(DateTime birthday) {
    final now = DateTime.now();
    DateTime nextBirthday = DateTime(now.year, birthday.month, birthday.day);
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }
    return nextBirthday.difference(now).inDays;
  }

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildBirthdayTile(int index) {
    final b = _birthdays[index];
    return Dismissible(
      key: Key(b.name + b.date.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteBirthday(index);
      },
      child: Card(
        child: ListTile(
          onTap: () => _startEditing(index),
          title: Text(b.name),
          subtitle: Text(
            'Born on ${DateFormat.yMMMd().format(b.date)} • ${_daysUntil(b.date)} days left',
          ),
          leading: CircleAvatar(
            child: Text(b.name[0].toUpperCase()),
            backgroundColor:
                Colors.primaries[Random().nextInt(Colors.primaries.length)],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Birthday Reminder'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Fields
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date chosen'
                        : 'Birthday: ${DateFormat.yMMMd().format(_selectedDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: () => _pickDate(context),
                  child: Text('Choose Date'),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrUpdateBirthday,
              child: Text(_editingIndex == null ? 'Add Birthday' : 'Update'),
            ),
            Divider(height: 30),
            // Birthday List
            Expanded(
              child: _birthdays.isEmpty
                  ? Center(child: Text('No birthdays added.'))
                  : ListView.builder(
                      itemCount: _birthdays.length,
                      itemBuilder: (ctx, i) => _buildBirthdayTile(i),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
