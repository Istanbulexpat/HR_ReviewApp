import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class PostSubmissionScreen extends StatefulWidget {
  @override
  _PostSubmissionScreenState createState() => _PostSubmissionScreenState();
}

class _PostSubmissionScreenState extends State<PostSubmissionScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  bool _ghostedAfterInterview = false;
  bool _ghostedAfterEmail = false;
  bool _interviewNoShow = false;
  bool _rudeBehavior = false;
  bool _glowingInterview = false;
  bool _lied = false;

  Future<Map<String, String>> fetchProfileData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);

        final String? name = document
            .querySelector('meta[property="og:title"]')
            ?.attributes['content'];
        final String? headline = document
            .querySelector('meta[property="og:description"]')
            ?.attributes['content'];
        final String? image = document
            .querySelector('meta[property="og:image"]')
            ?.attributes['content'];

        return {
          'name': name ?? 'Unknown',
          'headline': headline ?? 'No headline available',
          'image': image ?? '',
          'url': url,
        };
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<void> submitProfile() async {
    final String url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a LinkedIn profile URL')),
      );
      return;
    }

    try {
      final profileData = await fetchProfileData(url);
      final submissionData = {
        ...profileData,
        'company': _companyController.text.trim(),
        'job': _jobController.text.trim(),
        'ghostedAfterInterview': _ghostedAfterInterview,
        'ghostedAfterEmail': _ghostedAfterEmail,
        'interviewNoShow': _interviewNoShow,
        'rudeBehavior': _rudeBehavior,
        'glowingInterview': _glowingInterview,
        'lied': _lied,
        'comment': _commentController.text.trim(),
        'timestamp': DateTime.now(),
      };

      await FirebaseFirestore.instance.collection('submissions').add(submissionData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission successful!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Feedback'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'LinkedIn Profile URL',
                hintText: 'https://www.linkedin.com/in/johndoe/',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _companyController,
              decoration: InputDecoration(
                labelText: 'Company',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _jobController,
              decoration: InputDecoration(
                labelText: 'Job Interviewed For',
              ),
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text('Ghosted After Interview'),
              value: _ghostedAfterInterview,
              onChanged: (value) {
                setState(() {
                  _ghostedAfterInterview = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Ghosted After Email'),
              value: _ghostedAfterEmail,
              onChanged: (value) {
                setState(() {
                  _ghostedAfterEmail = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Interview No Show'),
              value: _interviewNoShow,
              onChanged: (value) {
                setState(() {
                  _interviewNoShow = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Rude Behavior'),
              value: _rudeBehavior,
              onChanged: (value) {
                setState(() {
                  _rudeBehavior = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Glowing Interview - Gave False Hope'),
              value: _glowingInterview,
              onChanged: (value) {
                setState(() {
                  _glowingInterview = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Lied'),
              value: _lied,
              onChanged: (value) {
                setState(() {
                  _lied = value!;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comments',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitProfile,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
