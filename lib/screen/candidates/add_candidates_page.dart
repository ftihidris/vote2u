import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vote2u_admin/utils/app_drawer.dart';
import 'package:http/http.dart';
import 'package:vote2u_admin/utils/form_container_widget.dart';
import 'package:vote2u_admin/utils/constants.dart';
import 'package:vote2u_admin/utils/functions.dart';
import 'package:web3dart/web3dart.dart';

class AddCandidates extends StatefulWidget {
  const AddCandidates({super.key});

  @override
  _AddCandidatesState createState() => _AddCandidatesState();
}

class _AddCandidatesState extends State<AddCandidates> {
  late Client httpClient;
  late Web3Client ethClient;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Uint8List? _imageBytes;
  String? _imageName;
  final _formKey = GlobalKey<FormState>();
  final _candidateNameController = TextEditingController();
  final _candidateIDController = TextEditingController();
  final _candidateCourseController = TextEditingController();
  final _imageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(infura_url, httpClient);
  }

  @override
  void dispose() {
    _candidateNameController.dispose();
    _candidateIDController.dispose();
    _candidateCourseController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _uploadCandidateData() async {
    final candidateName = _candidateNameController.text;
    final candidateID = _candidateIDController.text;
    final candidateCourse = _candidateCourseController.text;

    try {
      // Use the original filename
      final imageName = _imageName!;

      // Determine the content type based on the file extension
      final extension =
          imageName.contains('.') ? imageName.split('.').last : 'jpeg';
      final contentType = 'image/$extension';

      // Upload image to Firebase Storage
      final storageRef = _storage.ref().child('images/$imageName');
      final uploadTask = storageRef.putData(
        _imageBytes!,
        SettableMetadata(contentType: contentType),
      );
      await uploadTask.whenComplete(() => null);

      // Add candidate data to Firestore
      final candidateData = {
        'candidatesName': candidateName,
        'candidatesID': candidateID,
        'candidatesCourse': candidateCourse,
        'candidatesPhoto': imageName,
      };
      await _firestore.collection('candidates').add(candidateData);

      // Clear form fields and image selection
      setState(() {
        _candidateNameController.clear();
        _candidateIDController.clear();
        _candidateCourseController.clear();
        _imageController.clear();
        _imageBytes = null;
        _imageName = null;
      });

      // Show success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Candidate added successfully'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading data: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to add candidate. Please try again.'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: darkPurple,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            const Text(
              'Add Candidates',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final mediaInfo = await ImagePickerWeb.getImageInfo();
                    if (mediaInfo != null) {
                      setState(() {
                        _imageBytes = mediaInfo.data as Uint8List;
                        _imageName = mediaInfo.fileName;
                        _imageController.text = mediaInfo.fileName!;
                      });
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: darkPurple, width: 2),
                        ),
                        child: _imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _imageBytes!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.add,
                                size: 60,
                                color: darkPurple,
                              ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _imageBytes != null ? 'Change Image' : 'Add Image',
                        style: const TextStyle(
                          fontSize: 14,
                          color: darkPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormContainerWidget(
                        controller: _candidateNameController,
                        hintText: 'Name',
                        isPasswordField: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the candidate\'s name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      FormContainerWidget(
                        controller: _candidateIDController,
                        hintText: 'Student ID',
                        isPasswordField: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the candidate\'s student ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      FormContainerWidget(
                        controller: _candidateCourseController,
                        hintText: 'Course',
                        isPasswordField: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the candidate\'s course';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate() &&
                        _imageBytes != null) {
                      setState(() {
                        _isLoading = true;
                      });
                      final candidateID = _candidateIDController.text;
                      final candidateName = _candidateNameController.text;
                      final candidateCourse = _candidateCourseController.text;
                      try {
                        await _uploadCandidateData();
                        await addCandidate(
                          candidateID,
                          candidateName,
                          candidateCourse, 
                          ethClient, 
                          owner_private_key);
                          
                      } catch (e) {
                        // Catch any exceptions that occur during the transaction
                        if (kDebugMode) {
                          print('Error adding candidate in Smart Contract: $e');
                        }
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('An error occurred. Please try again.'),
                          duration: Duration(seconds: 2),
                        ));
                      } finally {
                        // Make sure to set _isLoading to false regardless of the outcome
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Please select an image and fill in all fields.'),
                        duration: Duration(seconds: 2),
                      ));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: mediumSizeBox,
                    decoration: BoxDecoration(
                      color: darkPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Add Candidate',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
