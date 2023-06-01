// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title Voting with delegation.
/// @author Staub
/// @notice We have three types of participants: voters, delegates, and candidates
/// @notice Voters can delegate their vote to a delegate
/// @notice Delegates can vote on behalf of others
/// @notice Candidates are the options in the voting contract

contract Voting {
    /// @notice This declares a state variable that stores a `Voter` struct for each possible address.
    struct Proposal {
        bytes32 name;
        uint voteCount;
    }
    /// @notice This is a type for a single voter.
    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }
} // end contract Voting
