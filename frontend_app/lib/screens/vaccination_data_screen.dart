import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'children_registration_screen.dart';
import 'child_vaccination_screen.dart';

class VaccinationDataScreen extends StatefulWidget {
  const VaccinationDataScreen({super.key});

  @override
  State<VaccinationDataScreen> createState() => _VaccinationDataScreenState();
}

class _VaccinationDataScreenState extends State<VaccinationDataScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

final Map<DateTime, List<VaccineSchedule>> _events = {};
  int? _selectedChildId;
  final TextEditingController _searchController = TextEditingController();
  
  // TODO: Replace with actual database query
  Future<List<Map<String, dynamic>>> _fetchRegisteredChildren() async {
    // Simulating database fetch
    return [
      {
        'id': 1,
        'name': 'John Doe',
        'dateOfBirth': '2021-01-01',
        'gender': 'Male',
        'bloodGroup': 'A+',
        'parentContact': '+1234567890',
        'vaccinations': [
          {'name': 'BCG', 'date': '2023-01-01', 'status': 'Completed', 'notes': 'No adverse reactions'},
          {'name': 'Hepatitis B', 'date': '2023-02-01', 'status': 'Completed', 'notes': null},
          {'name': 'DPT', 'date': '2023-06-01', 'status': 'Pending', 'notes': 'Scheduled'},
        ]
      },
      {
        'id': 2,
        'name': 'Jane Smith',
        'dateOfBirth': '2021-06-15',
        'gender': 'Female',
        'bloodGroup': 'O+',
        'parentContact': '+9876543210',
        'vaccinations': [
          {'name': 'BCG', 'date': '2023-03-01', 'status': 'Completed', 'notes': null},
          {'name': 'Hepatitis B', 'date': '2023-04-01', 'status': 'Pending', 'notes': 'Rescheduled'},
        ]
      },
    ];
  }

  List<Map<String, dynamic>> _children = [];
  
  List<Map<String, dynamic>> _filteredChildren = [];
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final children = await _fetchRegisteredChildren();
    setState(() {
      _children = children;
      _loadEvents();
    });
  }

  void _loadEvents() {
    _events.clear();
    if (_selectedChildId != null) {
      try {
        final selectedChild = _children.firstWhere((child) => child['id'] == _selectedChildId);
        final vaccinations = List<Map<String, dynamic>>.from(selectedChild['vaccinations']);
        
        for (var vaccination in vaccinations) {
          final schedule = VaccineSchedule.fromJson(vaccination);
          final date = DateTime(schedule.dueDate.year, schedule.dueDate.month, schedule.dueDate.day);
          if (_events[date] == null) _events[date] = [];
          _events[date]!.add(schedule);
        }
      } catch (e) {
        debugPrint('Error loading events: $e');
      }
    }
    setState(() {}); // Trigger rebuild to update calendar
  }

  List<VaccineSchedule> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  final List<VaccineSchedule> _vaccineSchedules = [
    VaccineSchedule(
      name: 'BCG',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      status: 'Pending',
    ),
    VaccineSchedule(
      name: 'Hepatitis B',
      dueDate: DateTime.now().add(const Duration(days: 14)),
      status: 'Completed',
    ),
    VaccineSchedule(
      name: 'DPT',
      dueDate: DateTime.now().add(const Duration(days: 21)),
      status: 'Pending',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination Data'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search children...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _filteredChildren = _children
                        .where((child) =>
                            child['name'].toString().toLowerCase()
                                .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Registered Children',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChildrenRegistrationScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Register New'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _searchController.text.isEmpty
                          ? _children.length
                          : _filteredChildren.length,
                      itemBuilder: (context, index) {
                        final child = _searchController.text.isEmpty
                            ? _children[index]
                            : _filteredChildren[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(
                              child['name'],
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DoB: ${child['dateOfBirth']}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Gender: ${child['gender']} | Blood Group: ${child['bloodGroup']}',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChildVaccinationScreen(
                                      childData: child,
                                    ),
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChildVaccinationScreen(
                                    childData: child,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  if (_selectedChildId != null) ...[                    
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCalendarCard(),
                            const SizedBox(height: 24),
                            _buildVaccinationList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedChildId == null
          ? null
          : FloatingActionButton(
              onPressed: _showAddVaccinationDialog,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildCalendarCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Vaccinations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TableCalendar<VaccineSchedule>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vaccination Schedule',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _vaccineSchedules.length,
          itemBuilder: (context, index) {
            final schedule = _vaccineSchedules[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  schedule.status == 'Completed'
                      ? Icons.check_circle
                      : Icons.pending_outlined,
                  color: schedule.status == 'Completed'
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.tertiary,
                ),
                title: Text(
                  schedule.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
                subtitle: Text(
                  'Due: ${schedule.dueDate.toString().split(' ')[0]}',
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _vaccineSchedules[index] = VaccineSchedule(
                        name: schedule.name,
                        dueDate: schedule.dueDate,
                        status: value,
                      );
                      _loadEvents();
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
              ),
            );
          },
        ),
      ],
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

  final String _selectedAgeGroup = '1-1.5 Years';
  String? _selectedVaccine;

  void _showAddVaccinationDialog() {
    String vaccineName = '';
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add New Vaccination'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Vaccine Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => vaccineName = value,
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
                  selectedDate = picked;
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
              if (vaccineName.isNotEmpty && selectedDate != null) {
                final newSchedule = VaccineSchedule(
                  name: vaccineName,
                  dueDate: selectedDate!,
                  status: 'Pending',
                );
                setState(() {
                  _vaccineSchedules.add(newSchedule);
                  _loadEvents();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class VaccineSchedule {
  final String name;
  final DateTime dueDate;
  final String status;
  final String? notes;

  VaccineSchedule({
    required this.name,
    required this.dueDate,
    required this.status,
    this.notes,
  });

  factory VaccineSchedule.fromJson(Map<String, dynamic> json) {
    return VaccineSchedule(
      name: json['name'],
      dueDate: DateTime.parse(json['date']),
      status: json['status'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': dueDate.toIso8601String(),
    'status': status,
    'notes': notes,
  };
}