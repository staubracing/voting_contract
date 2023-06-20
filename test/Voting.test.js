const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting", function () {
  let Voting;
  let voting; 
  let chairperson;
  let voter1;
  let voter2;
  let voter3;
  let proposalNames;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Voting = await ethers.getContractFactory("Voting");
    [chairperson, voter1, voter2, voter3] = await ethers.getSigners();
    proposalNames = ["Proposal 1", "Proposal 2", "Proposal 3"];

    // Deploy the contract
    voting = await Voting.deploy(proposalNames);
    await voting.deployed();

    // Give right to vote to voters
    await voting.connect(chairperson).giveRightToVote(voter1.address);
    await voting.connect(chairperson).giveRightToVote(voter2.address);
    await voting.connect(chairperson).giveRightToVote(voter3.address);
  });

  it("should have correct initial state", async function () {
    expect(await voting.chairperson()).to.equal(chairperson.address);
    expect(await voting.proposals(0)).to.deep.equal({
      name: ethers.utils.formatBytes32String("Proposal 1"),
      voteCount: 0,
    });
    expect(await voting.proposals(1)).to.deep.equal({
      name: ethers.utils.formatBytes32String("Proposal 2"),
      voteCount: 0,
    });
    expect(await voting.proposals(2)).to.deep.equal({
      name: ethers.utils.formatBytes32String("Proposal 3"),
      voteCount: 0,
    });
    expect(await voting.voters(voter1.address)).to.deep.equal({
      weight: 1,
      voted: false,
      delegate: ethers.constants.AddressZero,
      vote: 0,
    });
    expect(await voting.voters(voter2.address)).to.deep.equal({
      weight: 1,
      voted: false,
      delegate: ethers.constants.AddressZero,
      vote: 0,
    });
    expect(await voting.voters(voter3.address)).to.deep.equal({
      weight: 1,
      voted: false,
      delegate: ethers.constants.AddressZero,
      vote: 0,
    });
  });

  it("should allow delegation and voting", async function () {
    // Delegate vote from voter1 to voter2
    await voting.connect(voter1).delegate(voter2.address);
    expect(await voting.voters(voter1.address)).to.deep.equal({
      weight: 0,
      voted: true,
      delegate: voter2.address,
      vote: 0,
    });
    expect(await voting.voters(voter2.address)).to.deep.equal({
      weight: 2,
      voted: false,
      delegate: ethers.constants.AddressZero,
      vote: 0,
    });

    // Voter2 votes for proposal 2
    await voting.connect(voter2).vote(1);
    expect(await voting.proposals(1)).to.deep.equal({
      name: ethers.utils.formatBytes32String("Proposal 2"),
      voteCount: 2,
    });

    // Voter3 votes for proposal 3
    await voting.connect(voter3).vote(2);
    expect(await voting.proposals(2)).to.deep.equal({
      name: ethers.utils.formatBytes32String("Proposal 3"),
      voteCount: 1,
    });

    // Chairperson ends voting and proposal 2 wins
    await voting.connect(chairperson).endVoting();
    expect(await voting.winningProposal()).to.equal(1);
  });
});