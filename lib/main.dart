import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';
import 'dart:convert';

import 'package:template_method/platform_button.dart';
import 'package:template_method/Constants/layout_constants.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: TemplateMethodExample(),
        ),
      ),
    );
  }
}

abstract class StudentsBmiCalculator {
  List<Student> calculateBmiAndReturnStudentList() {
    var studentList = getStudentsData();
    studentList = doStudentsFiltering(studentList);
    _calculateStudentsBmi(studentList);
    return studentList;
  }

  void _calculateStudentsBmi(List<Student> studentList) {
    for (final student in studentList) {
      student.bmi = _calculateBmi(student.height, student.weight);
    }
  }

  double _calculateBmi(double height, int weight) {
    return weight / math.pow(height, 2);
  }

  @protected
  List<Student> doStudentsFiltering(List<Student> studentList) {
    return studentList;
  }

  @protected
  List<Student> getStudentsData();
}

class StudentsJsonBmiCalculator extends StudentsBmiCalculator {
  final JsonStudentsApi _api = JsonStudentsApi();

  @override
  @protected
  List<Student> getStudentsData() {
    final studentsJson = _api.getStudentsJson();
    final studentsMap = json.decode(studentsJson) as Map<String, dynamic>;
    final studentsJsonList = studentsMap['students'] as List;
    final studentsList = studentsJsonList.map((json) {
      final studentJson = json as Map<String, dynamic>;

      return Student(
        fullName: studentJson['fullName'] as String,
        age: studentJson['age'] as int,
        height: studentJson['height'] as double,
        weight: studentJson['weight'] as int
      );
    }).toList();

    return studentsList;
  }
}

class TeenageStudentsJsonBmiCalculator extends StudentsBmiCalculator {
  final JsonStudentsApi _api = JsonStudentsApi();

  @override
  @protected
  List<Student> getStudentsData() {
    final studentsJson = _api.getStudentsJson();
    final studentsMap = json.decode(studentsJson) as Map<String, dynamic>;
    final studentsJsonList = studentsMap['students'] as List;
    final studentsList = studentsJsonList.map((json) {
      final studentJson = json as Map<String, dynamic>;

      return Student(
        fullName: studentJson['fullName'] as String,
        age: studentJson['age'] as int,
        height: studentJson['height'] as double,
        weight: studentJson['weight'] as int,
      );
    }).toList();

    return studentsList;
  }

  @override
  @protected
  List<Student> doStudentsFiltering(List<Student> studentList) {
    return studentList
        .where((student) => student.age > 12 && student.age < 20)
        .toList();
  }
}

class StudentsXmlBmiCalculator extends StudentsBmiCalculator {
  final XmlStudentsApi _api = XmlStudentsApi();

  @override
  @protected
  List<Student> getStudentsData() {
    final studentsXml = _api.getStudentsXml();
    final xmlDocument = XmlDocument.parse(studentsXml);
    final studentsList = <Student>[];

    for (final xmlElement in xmlDocument.findAllElements('student')) {
      final fullName = xmlElement.findElements('fullName').single.text;
      final age = int.parse(xmlElement.findElements('age').single.text);
      final height = double.parse(xmlElement.findElements('height').single.text);
      final weight = int.parse(xmlElement.findElements('weight').single.text);

      studentsList.add(Student(
        fullName: fullName,
        age: age,
        height: height,
        weight: weight,
      ));
    }

    return studentsList;
  }
}

class Student {
  final String fullName;
  final int age;
  final double height;
  final int weight;
  late final double bmi;

  Student({
    required this.fullName,
    required this.age,
    required this.height,
    required this.weight,
  });
}

class JsonStudentsApi {
  final String _studentsJson = '''
  {
    "students": [
      {
        "fullName": "John Doe(JSON)",
        "age": 12,
        "height": 1.62,
        "weight": 53
      },
      {
        "fullName": "Emma Doe(JSON)",
        "age": 15,
        "height": 1.55,
        "weight": 50
      },
      {
        "fullName": "Michael Roe(JSON)",
        "age": 18,
        "height": 1.85,
        "weight": 89
      },
      {
        "fullName": "Emma Roe(JSON)",
        "age": 20,
        "height": 1.66,
        "weight": 79
      }
    ]
  }
  ''';

  String getStudentsJson() {
    return _studentsJson;
  }
}

class XmlStudentsApi {
  final String _studentsXml = '''
  <?xml version="1.0"?>
  <students>
    <student>
      <fullName>John Doe(XML)</fullName>
      <age>12</age>
      <height>1.62</height>
      <weight>53</weight>
    </student>
    <student>
      <fullName>Emma Doe(XML)</fullName>
      <age>15</age>
      <height>1.55</height>
      <weight>50</weight>
    </student>
    <student>
      <fullName>Michael Roe(XML)</fullName>
      <age>18</age>
      <height>1.85</height>
      <weight>89</weight>
    </student>
    <student>
      <fullName>Emma Roe(XML)</fullName>
      <age>20</age>
      <height>1.66</height>
      <weight>79</weight>
    </student>
  </students>
  ''';

  String getStudentsXml() {
    return _studentsXml;
  }
}

class TemplateMethodExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: LayoutConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StudentsSection(
              bmiCalculator: StudentsXmlBmiCalculator(),
              headerText: 'Students from XML data source:',
            ),
            const SizedBox(height: LayoutConstants.spaceL),
            StudentsSection(
              bmiCalculator: StudentsJsonBmiCalculator(),
              headerText: 'Students from JSON data source:',
            ),
            const SizedBox(height: LayoutConstants.spaceL),
            StudentsSection(
              bmiCalculator: TeenageStudentsJsonBmiCalculator(),
              headerText: 'Students from JSON data source (teenagers only):',
            )
          ],
        ),
      )
    );
  }
}

class StudentsSection extends StatefulWidget {
  final StudentsBmiCalculator bmiCalculator;
  final String headerText;

  const StudentsSection({
    required this.bmiCalculator,
    required this.headerText,
  });

  @override
  _StudentsSectionState createState() => _StudentsSectionState();
}

class _StudentsSectionState extends State<StudentsSection> {
  final List<Student> students = [];

  void _calculateBmiAndGetStudentsData() {
    setState(() {
      students.addAll(widget.bmiCalculator.calculateBmiAndReturnStudentList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.headerText),
        const SizedBox(height: LayoutConstants.spaceM),
        AnimatedSwitcher(
          duration: const Duration(microseconds: 500),
          child: _StudentsSectionContent(
            students: students,
            onPressed: _calculateBmiAndGetStudentsData,
          ),
        )
      ],
    );
  }
}

class _StudentsSectionContent extends StatelessWidget {
  final List<Student> students;
  final VoidCallback onPressed;

  const _StudentsSectionContent({
    required this.students,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return students.isEmpty
      ? PlatformButton(
        materialColor: Colors.black,
        materialTextColor: Colors.white,
        onPressed: onPressed,
        text: "Calculate BMI and get students data",
      )
      : StudentsDataTable(
        students: students,
      );
  }
}

class StudentsDataTable extends StatelessWidget {
  final List<Student> students;

  const StudentsDataTable({
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: LayoutConstants.spaceM,
        horizontalMargin: LayoutConstants.marginM,
        headingRowHeight: LayoutConstants.spaceXL,
        dataRowHeight: LayoutConstants.spaceXL,
        columns: const <DataColumn>[
          DataColumn(
            label: Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),
            )
          ),
          DataColumn(
            label: Text(
              'Age',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              'Height',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              'Weight',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              'BMI',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),
            ),
            numeric: true,
          ),
        ],
        rows: <DataRow>[
          for (var student in students)
            DataRow(
              cells: <DataCell>[
                DataCell(Text(student.fullName)),
                DataCell(Text(student.age.toString())),
                DataCell(Text(student.height.toString())),
                DataCell(Text(student.weight.toString())),
                DataCell(
                  Text(
                    student.bmi.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                )
              ]
            )
        ],
      )
    );
  }
}