import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
 
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';



class LeaveAnalytics extends StatelessWidget {
  Future<Map<String, dynamic>> fetchLeaveData() async {
    final leaveRequestsSnapshot = await FirebaseFirestore.instance.collection('leave_requests').get();
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    int totalLeaves = 0;
    int approvedLeaves = 0;
    int rejectedLeaves = 0;
    Map<String, int> leaveTypesCount = {};
    Map<String, int> approvedLeaveTypesCount = {};
    Map<String, int> rejectedLeaveTypesCount = {};

    leaveRequestsSnapshot.docs.forEach((doc) {
      final data = doc.data();
      totalLeaves++;

      final leaveType = data['leaveType'] ?? 'Unknown';

      if (data['status'] == 'approved') {
        approvedLeaves++;
        if (approvedLeaveTypesCount.containsKey(leaveType)) {
          approvedLeaveTypesCount[leaveType] = approvedLeaveTypesCount[leaveType]! + 1;
        } else {
          approvedLeaveTypesCount[leaveType] = 1;
        }
      } else if (data['status'] == 'rejected') {
        rejectedLeaves++;
        if (rejectedLeaveTypesCount.containsKey(leaveType)) {
          rejectedLeaveTypesCount[leaveType] = rejectedLeaveTypesCount[leaveType]! + 1;
        } else {
          rejectedLeaveTypesCount[leaveType] = 1;
        }
      }

      if (leaveTypesCount.containsKey(leaveType)) {
        leaveTypesCount[leaveType] = leaveTypesCount[leaveType]! + 1;
      } else {
        leaveTypesCount[leaveType] = 1;
      }
    });

    return {
      'totalLeaves': totalLeaves,
      'approvedLeaves': approvedLeaves,
      'rejectedLeaves': rejectedLeaves,
      'leaveTypesCount': leaveTypesCount,
      'approvedLeaveTypesCount': approvedLeaveTypesCount,
      'rejectedLeaveTypesCount': rejectedLeaveTypesCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Analytics'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchLeaveData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final leaveTypesCount = data['leaveTypesCount'] as Map<String, int>;
          final approvedLeaveTypesCount = data['approvedLeaveTypesCount'] as Map<String, int>;
          final rejectedLeaveTypesCount = data['rejectedLeaveTypesCount'] as Map<String, int>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: ListTile(
                      title: Text('Total Leave Requests', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${data['totalLeaves']}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Approved Leave Requests', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${data['approvedLeaves']}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Rejected Leave Requests', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${data['rejectedLeaves']}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Detailed Leave Types Count:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ...leaveTypesCount.keys.map((leaveType) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text('$leaveType Leave Requests', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Total: ${leaveTypesCount[leaveType]}', style: TextStyle(fontSize: 16)),
                            ),
                            ListTile(
                              title: Text('Approved $leaveType Leaves', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${approvedLeaveTypesCount[leaveType] ?? 0}', style: TextStyle(fontSize: 16)),
                            ),
                            ListTile(
                              title: Text('Rejected $leaveType Leaves', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${rejectedLeaveTypesCount[leaveType] ?? 0}', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(
                    height: 500,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LeaveAnalyticsPieChart(leaveTypesCount),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final data = await fetchLeaveData();
                      await generateReport(data);
                    },
                    child: Text('Generate PDF Report'),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class LeaveAnalyticsPieChart extends StatelessWidget {
  final Map<String, int> leaveTypesCount;

  LeaveAnalyticsPieChart(this.leaveTypesCount);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: leaveTypesCount.entries.map((entry) {
          final leaveType = entry.key;
          final count = entry.value;
          return PieChartSectionData(
            value: count.toDouble(),
            title: '$leaveType: $count',
            color: Colors.primaries[leaveTypesCount.keys.toList().indexOf(leaveType) % Colors.primaries.length],
            radius: 140, // Increased radius
            titleStyle: TextStyle(
              fontSize: 13, // Increased font size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 4,
        centerSpaceRadius: 90, // Increased center space radius
        borderData: FlBorderData(show: false),
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
              return;
            }
            // Handle touch interactions if needed
          },
        ),
      ),
    );
  }
}





Future<void> generateReport(Map<String, dynamic> data) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Leave Analytics Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Divider(height: 20, thickness: 2),
              pw.SizedBox(height: 10),
              pw.Text('Summary', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Total Leave Requests: ${data['totalLeaves']}'),
              pw.Text('Approved Leave Requests: ${data['approvedLeaves']}'),
              pw.Text('Rejected Leave Requests: ${data['rejectedLeaves']}'),
              pw.SizedBox(height: 20),
              pw.Text('Detailed Leave Types Count', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Leave Type', 'Total', 'Approved', 'Rejected'],
                data: [
                  for (var leaveType in data['leaveTypesCount'].keys)
                    [
                      leaveType,
                      data['leaveTypesCount'][leaveType].toString(),
                      (data['approvedLeaveTypesCount'][leaveType] ?? 0).toString(),
                      (data['rejectedLeaveTypesCount'][leaveType] ?? 0).toString(),
                    ]
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                border: pw.TableBorder.all(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Notes', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text('This report provides an overview of leave requests, including the total number of leave requests, '
                  'as well as a breakdown of approved and rejected leave requests by type.'),
            ],
          ),
        );
      },
    ),
  );

  await Printing.sharePdf(bytes: await pdf.save(), filename: 'leave_analytics_report.pdf');
}
