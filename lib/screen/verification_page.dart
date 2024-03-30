import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:vote2u/screen/cast_page.dart';
import 'package:vote2u/utils/constants.dart';
import 'package:vote2u/utils/form_container_widget.dart';

class VerificationPage extends StatefulWidget {
  VerificationPage({super.key});

  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<VerificationPage> {
  Client? httpClient;
  Web3Client? ethClient;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(infura_url, httpClient!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 63, 41, 120),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Text(
              'Verification',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.checkmark_shield,
                    size: 170,
                    color: Color.fromRGBO(131, 121, 205, 100),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FormContainerWidget(
              controller: controller,
              hintText: "Enter Student ID",
              isPasswordField: false,
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 63, 41, 120),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    bool isVerified = await verifyVoter(controller.text);
                    if (isVerified) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CastPage(
                            ethClient: ethClient!,
                            electionName: controller.text,
                          ),
                        ),
                      );
                    } else {
                      // Show error message or dialog indicating verification failed
                    }
                  }
                },
                child: const Center(
                  child: Text(
                    'Verify',
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
    );
  }

  Future<bool> verifyVoter(String studentId) async {
    // Connect to Ethereum contract and verify voter using studentId
    EthereumAddress contractAddress = EthereumAddress.fromHex('CONTRACT_ADDRESS_HERE');
    Credentials credentials = await ethClient!.credentialsFromPrivateKey('YOUR_PRIVATE_KEY_HERE');
    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson('CONTRACT_ABI_JSON_HERE', 'Contract_Name'),
      contractAddress,
    );

    final result = await ethClient!.call(
      contract: contract,
      function: contract.function('verifyVoter'),
      params: [BigInt.from(0)], 
      // Pass any additional parameters needed for verification
      // Replace 'BigInt.from(0)' with actual parameters required by your smart contract
      // Example: [BigInt.from(1234), BigInt.from(5678)]
    );

    // Process the result to determine if the voter is verified
    bool isVerified = result[0]; // Example: result[0] contains the verification status

    return isVerified;
  }
}