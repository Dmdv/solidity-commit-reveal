// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    bytes32 public hashedVote;
    address public voter;
    uint public revealDeadline;
    uint public yesVotes;
    uint public noVotes;

    constructor(bytes32 _hashedVote, uint _revealDeadline) {
        hashedVote = _hashedVote;
        voter = msg.sender;
        revealDeadline = _revealDeadline;
    }

    function commit(bytes32 _hash) public {
        require(msg.sender == voter, "Only the voter can commit");
        require(block.timestamp < revealDeadline, "Commit period has ended");
        hashedVote = _hash;
    }

    function reveal(bool _vote) public {
        require(keccak256(abi.encodePacked(_vote)) == hashedVote, "Vote does not match hash");
        require(block.timestamp >= revealDeadline, "Reveal period has not started yet");
        if (_vote) {
            yesVotes++;
        } else {
            noVotes++;
        }
    }
}