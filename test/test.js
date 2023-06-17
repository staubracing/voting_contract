const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("VotingContract", function () {
    let votingContract;

    beforeEach(async function () {

        votingContract = await ethers.getContractFactory("VotingContract");
        votingContract = await votingContract.deploy();
        await votingContract.deployed();
    });

});

        