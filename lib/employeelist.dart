import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_1/employeedetail.dart';
import 'package:intl/intl.dart';

class EmployeeListPage extends StatefulWidget {
  @override
  _EmployeeListPageState createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Map<String, bool> _leaveStatus = {};

  @override
  void initState() {
    super.initState();
    _fetchLeaveStatus();
  }

  void _fetchLeaveStatus() async {
    QuerySnapshot leaveSnapshot = await FirebaseFirestore.instance.collection('leaveRequests').get();
    DateTime now = DateTime.now();

    leaveSnapshot.docs.forEach((leaveDoc) {
      DateTime startDate = (leaveDoc['startDate'] as Timestamp).toDate();
      DateTime endDate = (leaveDoc['endDate'] as Timestamp).toDate();

      if (now.isAfter(startDate) && now.isBefore(endDate)) {
        _leaveStatus[leaveDoc['employeeId']] = true;
      } else {
        _leaveStatus[leaveDoc['employeeId']] = false;
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearchDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isNotEqualTo: 'Admin')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;
          final filteredUsers = users.where((user) {
            final name = user['name']?.toLowerCase() ?? '';
            final searchQuery = _searchQuery.toLowerCase();
            return name.contains(searchQuery);
          }).toList();

          final categorizedUsers = _categorizeUsers(filteredUsers);

          return ListView(
            children: categorizedUsers.keys.map((staffType) {
              return ExpansionTile(
                title: Text(staffType),
                children: [
                  _buildCategorySection('Currently On Leave', categorizedUsers[staffType]!['onLeave']!),
                  _buildCategorySection('Not On Leave', categorizedUsers[staffType]!['notOnLeave']!),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Map<String, Map<String, List<QueryDocumentSnapshot>>> _categorizeUsers(List<QueryDocumentSnapshot> users) {
    Map<String, Map<String, List<QueryDocumentSnapshot>>> categorizedUsers = {};

    users.forEach((user) {
      final staffType = user['staffType'];
      final employeeId = user['employeeId'];

      if (!categorizedUsers.containsKey(staffType)) {
        categorizedUsers[staffType] = {'onLeave': [], 'notOnLeave': []};
      }

      if (_leaveStatus[employeeId] == true) {
        categorizedUsers[staffType]!['onLeave']!.add(user);
      } else {
        categorizedUsers[staffType]!['notOnLeave']!.add(user);
      }
    });

    return categorizedUsers;
  }

  Widget _buildCategorySection(String title, List<QueryDocumentSnapshot> users) {
    return ExpansionTile(
      title: Text(title),
      children: users.map((user) {
        return ListTile(
          title: Text(user['name']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Employee ID: ${user['employeeId']}'),
              Text('Position: ${user['position']}'),
            ],
          ),
          trailing: Text(user['role']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeDetailPage(userId: user.id),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Employees'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: 'Enter employee name'),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
