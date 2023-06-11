// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title Voting with delegation.
/// @author Staub
/// @notice We have three types of participants: voters, delegates, and candidates
/// @notice Voters can delegate their vote to a delegate
/// @notice Delegates can vote on behalf of others
/// @notice Candidates are the options in the voting contract

contract Voting {
    /// @notice This the type for a single proposal.
    struct Proposal {
        bytes32 name;
        uint voteCount;
    }
    /// @notice This is a type for a single voter.
    struct Voter {
        uint8 weight; // weight is accumulated by delegation
        bool voted; // if true, that person already voted
        address delegate; // person delegated to
        uint vote; // index of the voted proposal
    }
    /// @notice This is a type for the chairperson of the voting contract.
    /// @notice The chairperson can add and remove voters and candidates.
    /// @notice The chairperson can also end the voting process.
    /// @notice The chairperson is the owner of the voting contract.
    address public chairperson;

    /// @notice This declares a state variable that stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    /// @notice This is a dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    /// @notice This creates a new ballot to choose one of `proposalNames`.
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        /// @notice For each of the provided proposal names, create a new proposal object and add it to the end of the array.
        for (uint i = 0; i < proposalNames.length; i++) {
            /// @notice `Proposal({...})` creates a temporary Proposal object and `proposals.push(...)`
            /// @notice appends it to the end of `proposals`.
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
    } // end constructor

    /// @notice Give `voter` the right to vote on this ballot.
    /// @notice May only be called by `chairperson`.
    function giveRightToVote(address voter) external {
        /// @notice If the first argument of `require` evaluates to `false`, execution terminates and all changes to the state and to
        /// @notice Ether balances are reverted.
        /// @notice This used to consume all gas in old EVM versions, but not anymore.
        /// @notice It is often a good idea to use `require` to check if functions are called correctly.
        /// @notice As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == chairperson, "Only chairperson can give right to vote."); // only chairperson can give right to vote
        require(!voters[voter].voted, "The voter already voted.");  // weight is 0 by default for existing voters
        require(voters[voter].weight == 0); // weight is 0 by default for existing voters
        voters[voter].weight = 1; // weight is 1 by default for new voters (weight is 0 by default for existing voters)
    } // end function giveRightToVote


    /// @notice Delegate your vote to the voter `to`.
    function delegate(address to) external {
        Voter storage sender = voters[msg.sender]; // assigns reference
        require(sender.weight != 0, "Has no right to vote."); // check if sender has right to vote
        require(!sender.voted, "Already voted."); // check if sender already voted

        require (to != msg.sender, "Self-delegation is disallowed."); // check if sender is not delegating to himself        

        while (voters[to].delegate != address(0)) { // check if to is delegating to someone else
            to = voters[to].delegate; // to is now the delegate of the delegate
            require(to != msg.sender, "Found loop in delegation."); // check if there is a loop in delegation
        }

        Voter storage delegate_ = voters[to]; // assigns reference to delegate of sender (to)

        require(delegate_.weight >= 1); // check if delegate has right to vote
        
        sender.voted = true; // sender voted
        sender.delegate = to; // sender delegated to to

        if (delegate_.voted) { // check if delegate already voted
            proposals[delegate_.vote].voteCount += sender.weight; // add weight to proposal
        } else {
            delegate_.weight += sender.weight; // add weight to delegate
        }
    } // end function delegate
    
   }



