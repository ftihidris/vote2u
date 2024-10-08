import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:vote2u/utils/constants.dart';

// Function to get contract address from Firestore
Future<String> getContractAddressFromFirestore() async {
  firestore.FirebaseFirestore firestoreInstance = firestore.FirebaseFirestore.instance;
  firestore.DocumentSnapshot doc = await firestoreInstance.collection('election').doc('TdpVaSNP0u9LSxmujuGD').get();
  return doc.get('contractAddress');
}

// Loads the contract and returns a [DeployedContract] object
Future<DeployedContract> loadContract() async {
  String contractAddress = await getContractAddressFromFirestore();

  // Loads the contract's ABI from the 'assets/abi.json' file
  String abi = await rootBundle.loadString('assets/abi.json');

  // Creates an Ethereum address object for the contract using its hexadecimal address
  final contract = DeployedContract(
    ContractAbi.fromJson(abi, 'Vote2U'),
    EthereumAddress.fromHex(contractAddress),
  );
  return contract;
}

// Calls a function in the contract and returns the result
Future<List<dynamic>> ask(
    String funcName, List<dynamic> args, Web3Client ethClient) async {
  final contract = await loadContract();
  final ethFunction = contract.function(funcName);
  final result = await ethClient.call(
      contract: contract, function: ethFunction, params: args);
  return result;
}


// Calls a specific function in the contract and sends a transaction
Future<String> callFunction(String funcName, List<dynamic> args,
    Web3Client ethClient, String privateKey) async {
  final credentials = EthPrivateKey.fromHex(privateKey);
  final contract = await loadContract();

  // Creates an [EthereumFunction] object for the specified function name
  final ethFunction = contract.function(funcName);

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

// Gets the election name
Future<String> getElectionName(Web3Client ethClient) async {
  final result = await ask('getElectionName', [], ethClient);
  return result[0] as String;
}

// Authorizes a voter by calling the 'authorizeVoter' function in the contract
Future<bool> authorizeVoter(String address, Web3Client ethClient) async {
  var response = await callFunction(
      'authorizeVoter', [EthereumAddress.fromHex(address)], ethClient, owner_private_key);
  if (kDebugMode) {
    print('Voter Authorized successfully');
  }
  return response == 'Success'; // Check for success message from the contract
}

// Verifies a voter by calling the 'isEligibleVoter' function in the contract
Future<bool> verifyVoter(String studentId, Web3Client ethClient) async {
  try {
    final contract = await loadContract();
    final result = await ethClient.call(
      contract: contract,
      function: contract.function('verifyVoter'),
      params: [studentId],
    );
    if (result.isEmpty) {
      if (kDebugMode) {
        print('Error: Empty result received');
      }
      return false;
    }
    bool isVerified = result[0];
    return isVerified;
  } catch (e) {
    if (kDebugMode) {
      print('Error verifying voter: $e');
    }
    return false; // Return false in case of any error
  }
}

Future<bool> hasUserVoted(String studentId, Web3Client ethClient) async {
  try {
    final contract = await loadContract();
    final function = contract.function('hasUserVoted');
    
    final result = await ethClient.call(
      contract: contract,
      function: function,
      params: [studentId],
    );
    
    return result.first as bool;
  } catch (e) {
    if (kDebugMode) {
      print('Error checking if user has voted: $e');
    }
    return false;
  }
}


// Gets the number of candidates by calling the 'getNumCandidates' function in the contract
Future<int> getNumCandidates(Web3Client ethClient) async {
  final result = await ask('getNumCandidates', [], ethClient);
  return result[0].toInt();
}

// Gets the total number of votes by calling the 'getTotalVotes' function in the contract
Future<int> getTotalVotes(Web3Client ethClient) async {
  final result = await ask('getTotalVotes', [], ethClient);
  return result[0].toInt();
}

// Gets the total number of voters by calling the 'getTotalVoters' function in the contract
Future<int> getTotalVoters(Web3Client ethClient) async {
  final result = await ask('getTotalVoters', [], ethClient);
  return result[0].toInt();
}

// Returns information about a candidate by calling the 'getCandidateInfo' function in the contract
Future<List<dynamic>> candidateInfo(
    String candidateId, Web3Client ethClient) async {
  final result =
      await ask('getCandidateInfo', [candidateId], ethClient);
  return result;
}

// Votes for a candidate by calling the 'vote' function in the contract

Future<String> vote(String studentId, List<String> candidateIds, Web3Client ethClient) async {
  try {
    final contract = await loadContract();
    final function = contract.function('vote');

    // Call the 'vote' function on the contract
    final result = await ethClient.sendTransaction(
      EthPrivateKey.fromHex(voter_private_key),
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [studentId, candidateIds],
      ),
      chainId: null,
      fetchChainIdFromNetworkId: true,
    );

    if (kDebugMode) {
      print('Vote counted successfully');
    }
    return result;
  } catch (e, s) {
    if (kDebugMode) {
      print('Error voting: $e');
      print('Student ID: $studentId');
      print('Candidate IDs: $candidateIds');
      print('Stack trace: $s');
    }
    return 'Error: $e';
  }
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

Future<BigInt> getMaxCandidatesPerVote(Web3Client ethClient) async {
  final contract = await loadContract();
  final function = contract.function('getMaxCandidatesPerVote');

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
    if (kDebugMode) {
      print('Error getting candidates: $e');
    }
    return [];
  }
}
 // Checks if the election has started
Future<bool> getElectionStarted(Web3Client ethClient) async {
  try {
    final contract = await loadContract();

    final result = await ethClient.call(
      contract: contract,
      function: contract.function('hasElectionStarted'),
      params: [],
    );

    return result[0] as bool;
  } catch (e) {
    if (kDebugMode) {
      print('Error checking if election has started: $e');
    }
    return false;
  }
}
 // Checks if the election has ended
Future<bool> getElectionEnded(Web3Client ethClient) async {
  final contract = await loadContract();

  final result = await ethClient.call(
    contract: contract,
    function: contract.function('getElectionEnded'),
    params: [],
  );
  return result[0] as bool;
}



Future<bool> isCandidateRegistered(Web3Client ethClient, String candidateId) async {
  if (candidateId.isEmpty) {
    if (kDebugMode) {
      print('Error: Candidate ID is empty');
    }
    return false;
  }

  try {
    final contract = await loadContract();

    final result = await ethClient.call(
      contract: contract,
      function: contract.function('isCandidateRegistered'),
      params: [candidateId],
    );

    bool isRegistered = result[0] as bool;
    return isRegistered;
  } catch (e) {
    if (kDebugMode) {
      print('Error checking candidate registration: $e');
    }
    return false;
  }
}

// Returns the vote count for a candidate by calling the 'getCandidateVoteCount' function in the contract
Future<int> getCandidateVoteCount(String candidateId, Web3Client ethClient) async {
  try {
    final contract = await loadContract();

    final result = await ethClient.call(
      contract: contract,
      function: contract.function('getCandidateVoteCount'),
      params: [candidateId],
      
    );

    return result[0].toInt();
  } catch (e) {
    if (kDebugMode) {
      print('Error getting candidate vote count: $e');
    }
    return 0;
  }
}


