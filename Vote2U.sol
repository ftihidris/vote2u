// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

contract Vote2U {
    address public immutable owner;
    string public electionName;
    uint256 public electionStartTime;
    uint256 public electionEndTime;
    bool public electionStarted; 
    bool public electionEnded;

    struct Candidate {
        string id; 
        string name; 
        string course; 
        uint voteCount; 
    }

    struct Voter {
        bool authorised; 
        bool voted; 
        bytes32 voteHash; 
    }
   
    mapping(string => Voter) public voters;
    mapping(string => bool) public studentIdExists;
    mapping(string => bool) public candidateIdExists;
    mapping(string => Candidate) public candidates;
    uint public totalVotes;
    uint public numCandidatesToWin;
    uint public maxCandidatesPerVote;
    uint public numCandidates;
    event VoteCast(address voter, string[] candidateIds);
    uint public totalVoters;

    modifier onlyOwner() {
        require(msg.sender == owner, "Testing: Only owner can call this function");
        _;
    }

    modifier onlyBeforeElectionEnd() {
        require(!electionEnded, "Testing: Election has ended");
        _;
    }

    modifier onlyAfterElectionStart() {
        require(electionStarted, "Testing: Election has not started yet");
        _;
    }

    constructor(string memory _electionName, uint _numCandidatesToWin, uint _maxCandidatesPerVote) {
        owner = msg.sender;
        electionName = _electionName;
        numCandidatesToWin = _numCandidatesToWin;
        maxCandidatesPerVote = _maxCandidatesPerVote;
        electionStarted = false; // Election has not started yet
    }

    function addCandidate(string memory _candidateId, string memory _name, string memory _course) public onlyOwner onlyBeforeElectionEnd {
        require(!candidateIdExists[_candidateId], "Testing: Candidate ID already registered");
        candidates[_candidateId] = Candidate(_candidateId, _name, _course, 0);
        candidateIdExists[_candidateId] = true;
        numCandidates += 1;
    }

    function addVoter(string memory _studentId) public onlyOwner onlyBeforeElectionEnd {
        require(!studentIdExists[_studentId], "Testing: Student ID already registered");
        voters[_studentId].authorised = true;
        studentIdExists[_studentId] = true;
        totalVoters += 1;
    }

    function addBulkVoters(string[] memory _studentIds) public onlyOwner onlyBeforeElectionEnd {
        for (uint i = 0; i < _studentIds.length; i++) {
            addVoter(_studentIds[i]);
        }
    }

    function verifyVoter(string memory _studentId) public view returns (bool) {
        return voters[_studentId].authorised && !electionEnded;
    }

    function hasUserVoted(string memory _studentId) public view returns (bool) {
        return voters[_studentId].voted;
    }

    function isEligibleVoter(string memory _studentId) public view returns (bool) {
        return studentIdExists[_studentId];
    }
    
    function getTotalVoters() public view returns (uint) {
        return totalVoters;
    }

    function vote(string memory _studentId, string[] memory _candidateIds) public onlyAfterElectionStart {
        require(voters[_studentId].authorised, "Testing: Not an authorised voter");
        require(!voters[_studentId].voted, "Testing: Already voted");
        require(_candidateIds.length <= maxCandidatesPerVote, "Testing: Exceeded maximum candidates per vote");

        string memory voteData = "";
        for (uint i = 0; i < _candidateIds.length; i++) {
            voteData = string(abi.encodePacked(voteData, _candidateIds[i]));
        }

        bytes32 voteHash = sha256(abi.encodePacked(voteData));

        voters[_studentId].voteHash = voteHash;

        for (uint i = 0; i < _candidateIds.length; i++) {
            string memory _candidateId = _candidateIds[i];
            require(candidateIdExists[_candidateId],  "Testing: Invalid candidate ID");
            candidates[_candidateId].voteCount += 1;
            totalVotes += 1;
        }

        voters[_studentId].voted = true;

        emit VoteCast(msg.sender, _candidateIds);
    }

    function getCandidateVoteCountByStudentId(string memory _studentId) public view returns (uint) {
        require(candidateIdExists[_studentId], "Testing: Candidate not found");
        return candidates[_studentId].voteCount;
    }

    function verifyVote(string memory _studentId, string[] memory _candidateIds) public view returns (bool) {
        string memory voteData = "";
        for (uint i = 0; i < _candidateIds.length; i++) {
            voteData = string(abi.encodePacked(voteData, _candidateIds[i]));
        }

        bytes32 voteHash = sha256(abi.encodePacked(voteData));
        return voteHash == voters[_studentId].voteHash;
    }

    function getNumCandidates() public view returns (uint) {
        return numCandidates;
    }

    function getCandidateInfo(string memory candidateId) public view returns (string memory, string memory, uint) {
        require(candidateIdExists[candidateId], "Testing: Invalid candidate ID");
        return (candidates[candidateId].name, candidates[candidateId].course, candidates[candidateId].voteCount);
    }

    function getCandidateVoteCount(string memory candidateId) public view returns (uint) {
        require(candidateIdExists[candidateId], "Testing: Invalid candidate ID");
        return candidates[candidateId].voteCount;
    }

    function isCandidateRegistered(string memory _candidateId) public view returns (bool) {
        return candidateIdExists[_candidateId];
    }

    function getTotalVotes() public view returns (uint) {
        return totalVotes / maxCandidatesPerVote;
    }

    function getNumCandidatesToWin() public view returns (uint) {
        return numCandidatesToWin;
    }

    function getMaxCandidatesPerVote() public view returns (uint) {
        return maxCandidatesPerVote;
    }

    function getElectionName() public view returns (string memory) {
        return electionName;
    }

    function hasElectionStarted() public view returns (bool) {
        return electionStarted;
    }

    function getElectionStartTime() public view returns (uint256) {
        return electionStartTime;
    }

    function getElectionEndTime() public view returns (uint256) {
        return electionEndTime;
    }

    function getElectionEnded() public view returns (bool) {
        return electionEnded;
    }

    function startElection() public onlyOwner {
        electionStarted = true;
    }

    function endElection() public onlyOwner {
        electionEnded = true;
    }
}
