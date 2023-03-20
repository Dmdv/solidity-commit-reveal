// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// The contract includes four functions:

// - `commit`: Judges commit to their score by sending a hash of their score and a random secret value. The commitment is saved in the evaluation struct along with the judge's address.
// - `reveal`: Once both judges have committed, they reveal their scores by sending the actual score and the secret value they used to commit. The revealed score is saved in the evaluation struct.
// - `tally`: After both judges have revealed their scores, the contract tallies the scores and computes the final score if both judges gave the same score. The final score is saved in the evaluation struct.
// - `dispute`: If the judges gave different scores, they can use this function to retrieve each other's scores by sending the secret value they used to commit.

// Note that the contract assumes that each event is evaluated by exactly two judges, and there is no way to add more judges or change the judges once the evaluation has started.

// Interface for the CommitRevealVoting contract
interface CommitRevealVotingInterfaceI {
    function commit(bytes32 eventID, bytes32 commitment) external;
    function reveal(bytes32 eventID, uint8 score, bytes32 secret) external;
    function tally(bytes32 eventID) external;
}

// CommitRevealVoting contract
contract CommitRevealVoting is CommitRevealVotingInterfaceI {

    struct Vote {
        bytes32 commitment;
        uint8 score;
        bool revealed;
    }

    struct Evaluation {
        address judge1;
        address judge2;
        bytes32 eventID;
        Vote judge1Vote;
        Vote judge2Vote;
        uint8 finalScore;
        bool finalScoreObtained;
    }

    mapping(bytes32 => Evaluation) public evaluations;

    function commit(bytes32 eventID, bytes32 commitment) public {
        Evaluation storage evaluation = evaluations[eventID];
        require(evaluation.judge2 == address(0), "Evaluation already exists");
        if (evaluation.judge1 == address(0)) {
            evaluation.judge1 = msg.sender;
        } else {
            require(msg.sender != evaluation.judge1, "You are already a judge");
            evaluation.judge2 = msg.sender;
            require(commitment != evaluation.judge1Vote.commitment, "Your commitment is the same as the other judge");
        }
        if (msg.sender == evaluation.judge1) {
            evaluation.judge1Vote.commitment = commitment;
        } else {
            evaluation.judge2Vote.commitment = commitment;
        }
    }

    function reveal(bytes32 eventID, uint8 score, bytes32 secret) public {
        Evaluation storage evaluation = evaluations[eventID];
        require(evaluation.judge2 != address(0), "Evaluation not started yet");
        require(!evaluation.finalScoreObtained, "Final score already obtained");
        if (msg.sender == evaluation.judge1) {
            require(keccak256(abi.encodePacked(score, secret)) == evaluation.judge1Vote.commitment, "Invalid secret and score");
            evaluation.judge1Vote.score = score;
            evaluation.judge1Vote.revealed = true;
        } else {
            require(keccak256(abi.encodePacked(score, secret)) == evaluation.judge2Vote.commitment, "Invalid secret and score");
            evaluation.judge2Vote.score = score;
            evaluation.judge2Vote.revealed = true;
        }
    }

    function tally(bytes32 eventID) public {
        Evaluation storage evaluation = evaluations[eventID];
        require(evaluation.judge2 != address(0), "Evaluation not started yet");
        require(!evaluation.finalScoreObtained, "Final score already obtained");
        if (evaluation.judge1Vote.revealed && evaluation.judge2Vote.revealed) {
            if (evaluation.judge1Vote.score == evaluation.judge2Vote.score) {
                evaluation.finalScore = evaluation.judge1Vote.score;
                evaluation.finalScoreObtained = true;
            }
        }
    }

    function dispute(bytes32 eventID, bytes32 secret) public view returns (uint8) {
        Evaluation storage evaluation = evaluations[eventID];
        require(evaluation.judge2 != address(0), "Evaluation not started yet");
        require(evaluation.finalScoreObtained == false, "Final score already obtained");
        if (keccak256(abi.encodePacked(secret)) == evaluation.judge1Vote.commitment) {
            return evaluation.judge1Vote.score;
        } else if (keccak256(abi.encodePacked(secret)) == evaluation.judge2Vote.commitment) {
            return evaluation.judge2Vote.score;
        } else {
            revert("Invalid secret");
        }
    }
}
