import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:vote2u/utils/constants.dart';

// Loads the contract and returns a [DeployedContract] object
Future<DeployedContract> loadContract() async {
  /// Loads the contract's ABI from the 'assets/abi.json' file
  String abi = await rootBundle.loadString('assets/abi.json');

  // Creates an Ethereum address object for the contract using its hexadecimal address
  String contractAddress = contractAddress1;
  final contract = DeployedContract(ContractAbi.fromJson(abi, 'Testing'),
      EthereumAddress.fromHex(contractAddress));
  return contract;
}

// Calls a specific function in the contract and sends a transaction
Future<String> callFunction(String funcname, List<dynamic> args,
    Web3Client ethClient, String privateKey) async {
  EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
  DeployedContract contract = await loadContract();

  // Creates an [EthereumFunction] object for the specified function name
  final ethFunction = contract.function(funcname);

  // Sends the transaction and returns the result
  final result = await ethClient.sendTransaction(
    credentials,
    Transaction.callContract(
      contract: contract,
      function: ethFunction,
      parameters: args,
    ),
    chainId: null,
    fetchChainIdFromNetworkId: true,
  );
  return result;
}

// Authorizes a voter by calling the 'authorizeVoter' function in the contract
Future<bool> authorizeVoter(String address, Web3Client ethClient) async {
  var response = await callFunction(
      'authorizeVoter', [EthereumAddress.fromHex(address)], ethClient, owner_private_key);
  print('Voter Authorized successfully');
  return response == 'Success'; // Check for success message from the contract
}

// Verifies a voter by calling the 'isEligibleVoter' function in the contract
Future<bool> verifyVoter(String studentId, Web3Client ethClient) async {
  try {
    final contract = await loadContract();
    final result = await ethClient.call(
      contract: contract,
      function: contract.function('isEligibleVoter'),
      params: [studentId],
    );


    if (result.isEmpty) {
      print('Error: Empty result received');
      return false;
   }

    bool isVerified = result[0]; // Assuming the result is a boolean indicating verification status
    return isVerified;
  } catch (e) {
    print('Error verifying voter: $e');
    return false; // Return false in case of any error
  }
}

// Gets the number of candidates by calling the 'getNumCandidates' function in the contract
Future<int> getNumCandidates(Web3Client ethClient) async {
  List<dynamic> result = await ask('getNumCandidates', [], ethClient);
  return result[0].toInt();
}

// Gets the total number of votes by calling the 'getTotalVotes' function in the contract
Future<int> getTotalVotes(Web3Client ethClient) async {
  List<dynamic> result = await ask('getTotalVotes', [], ethClient);
  return result[0].toInt();
}

// Gets the total number of voters by calling the 'getTotalVoters' function in the contract
Future<int> getTotalVoters(Web3Client ethClient) async {
  List<dynamic> result = await ask('getTotalVoters', [], ethClient);
  return result[0].toInt();
}

/// Returns information about a candidate by calling the 'getCandidateInfo' function in the contract
Future<List<dynamic>> candidateInfo(
    String candidateId, Web3Client ethClient) async {
  List<dynamic> result =
      await ask('getCandidateInfo', [candidateId], ethClient);
  return result;
}

// Calls a function in the contract and returns the result
Future<List<dynamic>> ask(
    String funcName, List<dynamic> args, Web3Client ethClient) async {
  final contract = await loadContract();
  final ethFunction = contract.function(funcName);
  final result = ethClient.call(
      contract: contract, function: ethFunction, params: args.toList());
  return result;
}

// Votes for a candidate by calling the 'vote' function in the contract
Future<String> vote(String candidateId, Web3Client ethClient) async {
  var response = await callFunction(
      "vote", [candidateId], ethClient, voter_private_key);
  print("Vote counted successfully");
  return response;
}

Future<BigInt> getNumCandidatesToWin(Web3Client ethClient) async {
  final contract = await loadContract();
  final function = contract.function('getNumCandidatesToWin');

  final result = await ethClient.call(
    contract: contract, 
    function: function,
    params: []);
    
  return result.first as BigInt;
}


// Returns a list of candidates by calling the 'getNumCandidates' and 'getCandidateInfo' functions in the contract
Future<List<dynamic>> getCandidates(Web3Client ethClient) async {
  try {
    List<dynamic> candidates = [];
    final contract = await loadContract();
    final numCandidates = await ethClient.call(
      contract: contract,
      function: contract.function('getNumCandidates'),
      params: [],
    );

    for (int i = 0; i < numCandidates[0].toInt(); i++) {
      final candidate = await ethClient.call(
        contract: contract,
        function: contract.function('getCandidateInfo'),
        params: [BigInt.from(i)],
      );
      candidates.add(candidate);
    }
    return candidates;
  } catch (e) {
    print('Error getting candidates: $e');
    return [];
  }
}

Future<bool> getElectionEnded(Web3Client ethClient) async {
  final contract = await loadContract();

  final result = await ethClient.call(
    contract: contract,
    function: contract.function('getElectionEnded'),
    params: [],
  );
  return result[0] as bool;
}
