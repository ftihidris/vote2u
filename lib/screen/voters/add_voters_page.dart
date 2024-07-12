import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:vote2u_admin/utils/app_drawer.dart';
import 'package:vote2u_admin/utils/constants.dart';
import 'package:vote2u_admin/utils/form_container_widget.dart';
import 'package:vote2u_admin/utils/functions.dart';
import 'package:web3dart/web3dart.dart';
import 'package:excel/excel.dart';
import 'dart:html' as html;

class AddVoters extends StatefulWidget {
  const AddVoters({super.key});

  @override
  _AddVoters createState() => _AddVoters();
}

class _AddVoters extends State<AddVoters> {
  late Client httpClient;
  late Web3Client ethClient;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final _voterIDController = TextEditingController();
  bool _isLoadingAddVoter = false;
  bool _isLoadingImportVoters = false;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(infura_url, httpClient);
  }

  @override
  void dispose() {
    _voterIDController.dispose();
    super.dispose();
  }

  Future<void> _importVotersFromExcel() async {
    try {
      final html.FileUploadInputElement input = html.FileUploadInputElement();
      input.accept = '.xlsx, .xls';
      input.click(); // Simulate click to open file picker dialog

      // Wait for the user to select a file
      await input.onChange.first;

      final files = input.files;
      if (files!.isEmpty) {
        // No file selected
        return;
      }

      final file = files[0];
      final reader = html.FileReader();

      reader.onLoadEnd.listen((e) {
        if (reader.readyState == html.FileReader.DONE) {
          // File contents are in reader.result
          final bytes = reader.result as Uint8List;
          final excel = Excel.decodeBytes(bytes);
          _processExcelData(excel);
        }
      });

      reader.readAsArrayBuffer(file);
    } catch (e) {
      if (kDebugMode) {
        print('Error picking file: $e');
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred: $e'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _processExcelData(Excel excel) {
    final voterIds = <String>[];

    for (var table in excel.tables.values) {
      for (var row in table.rows) {
        final voterId = row[0]?.value?.toString(); // Use toString() safely
        if (voterId != null && voterId.isNotEmpty) {
          voterIds.add(voterId);
        }
      }
    }

    if (voterIds.isNotEmpty) {
      _showConfirmationDialog(voterIds);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No valid voter IDs found in the Excel file.'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _showConfirmationDialog(List<String> voterIds) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Add Voters'),
          content: Text('Are you sure you want to add ${voterIds.length} voters?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                addBulkVoters(voterIds, ethClient, owner_private_key);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${voterIds.length} voters added successfully.'),
                  duration: Duration(seconds: 2),
                ));
              },
            ),
          ],
        );
      },
    );
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
              'Add Voters',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      FormContainerWidget(
                        controller: _voterIDController,
                        hintText: 'Student ID',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the voter\'s student ID';
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
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoadingAddVoter = true;
                      });
                      final studentId = _voterIDController.text;
                      try {
                        final result = await addVoter(
                            studentId, ethClient, owner_private_key);
                        if (result.isNotEmpty) {
                          // Transaction was successful
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Voter added successfully in Smart Contract'),
                            duration: Duration(seconds: 2),
                          ));
                        } else {
                          // Transaction failed
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Failed to add voter in Smart Contract. Please try again.'),
                            duration: Duration(seconds: 2),
                          ));
                        }
                      } catch (e) {
                        // Catch any exceptions that occur during the transaction
                        if (kDebugMode) {
                          print('Error adding voter in Smart Contract: $e');
                        }
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('An error occurred. Please try again.'),
                          duration: Duration(seconds: 2),
                        ));
                      } finally {
                        // Make sure to set _isLoading to false regardless of the outcome
                        setState(() {
                          _isLoadingAddVoter = false;
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Please fill in all fields.'),
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
                      child: _isLoadingAddVoter
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Add Voter',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: softPurple, // Adjust text color as needed
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isLoadingImportVoters = true;
                    });
                    try {
                      await _importVotersFromExcel();
                    } catch (e) {
                      if (kDebugMode) {
                        print('Error importing voters: $e');
                      }
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('An error occurred. Please try again.'),
                        duration: Duration(seconds: 2),
                      ));
                    } finally {
                      setState(() {
                        _isLoadingImportVoters = false;
                      });
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
                      child: _isLoadingImportVoters
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Import Voters From Excel',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
