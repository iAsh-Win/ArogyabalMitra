import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ChildVaccinationScreen extends StatefulWidget {
  final Map<String, dynamic> childData;

  const ChildVaccinationScreen({super.key, required this.childData});

  @override
  State<ChildVaccinationScreen> createState() => _ChildVaccinationScreenState();
}

class _ChildVaccinationScreenState extends State<ChildVaccinationScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _vaccinations = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadVaccinations();
  }

  void _loadVaccinations() {
    setState(() {
      _vaccinations = List<Map<String, dynamic>>.from(widget.childData['vaccinations']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.childData['name']}\'s Vaccinations'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChildInfo(),
            const SizedBox(height: 24),
            _buildCalendar(),
            const SizedBox(height: 24),
            _buildVaccinationList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVaccinationDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChildInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Child Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Date of Birth: ${widget.childData['dateOfBirth']}'),
            Text('Gender: ${widget.childData['gender']}'),
            Text('Blood Group: ${widget.childData['bloodGroup']}'),
            Text('Parent Contact: ${widget.childData['parentContact']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vaccination Calendar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vaccination History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _vaccinations.length,
              itemBuilder: (context, index) {
                final vaccination = _vaccinations[index];
                return ListTile(
                  leading: Icon(
                    vaccination['status'] == 'Completed'
                        ? Icons.check_circle
                        : Icons.pending_outlined,
                    color: vaccination['status'] == 'Completed'
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                  title: Text(vaccination['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${vaccination['date']}'),
                      if (vaccination['notes'] != null)
                        Text('Notes: ${vaccination['notes']}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _vaccinations[index]['status'] = value;
                      });
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'Completed',
                        child: Text('Mark as Completed'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Pending',
                        child: Text('Mark as Pending'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  final Map<String, List<Map<String, String>>> _vaccinesByAge = {
    '1-1.5 Years': [
      {'name': 'Measles, Mumps, Rubella (MMR) – 1st dose', 'status': 'Pending'},
      {'name': 'Pneumococcal Conjugate Vaccine (PCV) – Booster dose', 'status': 'Pending'},
      {'name': 'Hepatitis A – 1st dose', 'status': 'Pending'},
      {'name': 'Chickenpox (Varicella) – 1st dose', 'status': 'Pending'},
    ],
    '2 Years': [
      {'name': 'DTP Booster-1 (Diphtheria, Tetanus, Pertussis)', 'status': 'Pending'},
      {'name': 'IPV Booster (Polio)', 'status': 'Pending'},
      {'name': 'Hib Booster (Haemophilus influenzae type B)', 'status': 'Pending'},
    ],
    '3 Years': [
      {'name': 'Typhoid Conjugate Vaccine (TCV) Booster', 'status': 'Pending'},
      {'name': 'Annual Influenza (Flu) Vaccine', 'status': 'Pending'},
      {'name': 'Hepatitis A – 2nd Dose', 'status': 'Pending'},
    ],
    '4-5 Years': [
      {'name': 'DTP Booster-2 (Final booster dose for Diphtheria, Tetanus, Pertussis)', 'status': 'Pending'},
      {'name': 'OPV (Oral Polio Vaccine) Booster – Polio drops', 'status': 'Pending'},
      {'name': 'MMR – 2nd dose', 'status': 'Pending'},
    ],
  };

  String _selectedAgeGroup = '1-1.5 Years';
  String? _selectedVaccine;

  void _showAddVaccinationDialog() {
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Vaccination'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAgeGroup,
                decoration: const InputDecoration(
                  labelText: 'Age Group',
                  border: OutlineInputBorder(),
                ),
                items: _vaccinesByAge.keys.map((String ageGroup) {
                  return DropdownMenuItem<String>(
                    value: ageGroup,
                    child: Text(ageGroup),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAgeGroup = newValue!;
                    _selectedVaccine = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedVaccine,
                decoration: const InputDecoration(
                  labelText: 'Vaccine',
                  border: OutlineInputBorder(),
                ),
                items: _vaccinesByAge[_selectedAgeGroup]!.map((vaccine) {
                  return DropdownMenuItem<String>(
                    value: vaccine['name'],
                    child: Text(vaccine['name']!),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVaccine = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Select Due Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_selectedVaccine != null && selectedDate != null) {
                  this.setState(() {
                    _vaccinations.add({
                      'name': _selectedVaccine!,
                      'date': selectedDate!.toIso8601String().split('T')[0],
                      'status': 'Pending',
                      'notes': null,
                    });
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}