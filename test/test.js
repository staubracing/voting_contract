const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Voting", function () {
    let voting;
    let voter1, voter2, voter3;
    let chairperson;
    let proposalNames;

    before(async function () {
        voting = await ethers.getContractFactory("Voting");
        voting = await voting.deploy();
        [chairperson, voter1, voter2, voter3] = await ethers.getSigners();
        proposalNames = ["Proposal1", "Proposal2", "Proposal3"];
        console.log("Deployed to:", voting.address);
        await voting.deployed();
    });

    /// @todo test the give right to vote function    

    /// @todo test the delegate function

    /// @todo test the vote function

    /// @todo test the winning proposal function

    /// @todo test the winner name function  

    /// @audit
});

        