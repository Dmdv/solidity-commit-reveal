// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    struct Participant {
        bytes32 hashedNumber;
        bool isRevealed;
    }

    mapping(address => Participant) public participants;
    uint256 public revealBlockNumber;
    uint256[] public winningNumbers;

    function commit(bytes32 _hashedNumber, uint256 _revealBlockNumber) public {
        participants[msg.sender] = Participant(_hashedNumber, false);
        revealBlockNumber = _revealBlockNumber;
    }

    function reveal(uint256 _number) public {
        Participant storage participant = participants[msg.sender];
        require(!participant.isRevealed, "Number has already been revealed");
        require(block.number >= revealBlockNumber, "Reveal block number has not been reached yet");
        require(keccak256(abi.encodePacked(_number)) == participant.hashedNumber, "Invalid number");
    }
}