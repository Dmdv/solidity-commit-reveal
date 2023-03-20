// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Vote {
        bytes32 hashedVote;
        bool isRevealed;
    }

    mapping(address => Vote) public votes;
    uint256 public revealBlockNumber;
    uint256 public yesVotes;
    uint256 public noVotes;

    function commit(bytes32 _hashedVote, uint256 _revealBlockNumber) public {
        votes[msg.sender] = Vote(_hashedVote, false);
        revealBlockNumber = _revealBlockNumber;
    }

    function reveal(bool _vote) public {
        Vote storage vote = votes[msg.sender];
        require(!vote.isRevealed, "Vote has already been revealed");
        require(block.number >= revealBlockNumber, "Reveal block number has not been reached yet");
        require(keccak256(abi.encodePacked(_vote)) == vote.hashedVote, "Invalid vote");

        vote.isRevealed = true;
        if (_vote) {
            yesVotes++;
        } else {
            noVotes++;
        }
    }
}