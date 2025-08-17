// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        uint256 id;
        string name;
        string party;
        uint256 voteCount;
    }

    mapping(uint256 => Candidate) public candidates;
    mapping(address => bool) public voters;

    uint256 public countCandidates;
    uint256 public votingEnd;
    uint256 public votingStart;
    address public admin;

    // -------------------
    // Events
    // -------------------
    event CandidateAdded(uint256 id, string name, string party);
    event Voted(address voter, uint256 candidateID);
    event DatesSet(uint256 start, uint256 end);

    // -------------------
    // Constructor
    // -------------------
    constructor() {
        admin = msg.sender;
    }

    // -------------------
    // Modifiers
    // -------------------
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    // -------------------
    // Candidate Functions
    // -------------------
    function addCandidate(string memory name, string memory party) public onlyAdmin returns (uint256) {
        countCandidates++;
        candidates[countCandidates] = Candidate(countCandidates, name, party, 0);
        emit CandidateAdded(countCandidates, name, party);
        return countCandidates;
    }

    // -------------------
    // Voting Functions
    // -------------------
    function vote(uint256 candidateID) public {
        require(votingStart != 0 && votingEnd != 0, "Voting dates not set");
        require(block.timestamp >= votingStart && block.timestamp < votingEnd, "Voting not active");
        require(candidateID > 0 && candidateID <= countCandidates, "Invalid candidate");
        require(!voters[msg.sender], "Already voted");

        voters[msg.sender] = true;
        candidates[candidateID].voteCount++;
        emit Voted(msg.sender, candidateID);
    }

    function checkVote() public view returns (bool) {
        return voters[msg.sender];
    }

    // -------------------
    // Candidate Info
    // -------------------
    function getCandidate(uint256 candidateID) public view returns (uint256, string memory, string memory, uint256) {
        Candidate memory c = candidates[candidateID];
        return (c.id, c.name, c.party, c.voteCount);
    }

    // -------------------
    // Voting Dates
    // -------------------
    function setDates(uint256 _startDate, uint256 _endDate) public onlyAdmin {
        require(votingStart == 0 && votingEnd == 0, "Dates already set");
        require(_startDate > block.timestamp, "Start must be in future");
        require(_endDate > _startDate, "End must be after start");

        votingStart = _startDate;
        votingEnd = _endDate;
        emit DatesSet(_startDate, _endDate);
    }

    function getDates() public view returns (uint256, uint256) {
        return (votingStart, votingEnd);
    }

    // -------------------
    // Get Winner (after voting ends)
    // -------------------
    function getWinner() public view returns (uint256, string memory, string memory, uint256) {
        require(block.timestamp > votingEnd && votingEnd != 0, "Voting not ended yet");

        uint256 winningVoteCount = 0;
        uint256 winningCandidateId = 0;

        for (uint256 i = 1; i <= countCandidates; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }

        Candidate memory winner = candidates[winningCandidateId];
        return (winner.id, winner.name, winner.party, winner.voteCount);
    }
}