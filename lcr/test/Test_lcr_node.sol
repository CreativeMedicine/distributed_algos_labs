pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/lcr_node.sol";

/**
 * The Test_lcr_node contract does this and that...
 */
contract Test_lcr_node {

	lcr_node lcr1;
	lcr_node lcr2;
	lcr_node lcr3;

	uint expected1 = 8;
	uint expected2 = 4;
	uint expected3 = 16;

	function beforeAll() public {
		//initialize
		lcr1 = new lcr_node(expected1);
		lcr2 = new lcr_node(expected2);
		lcr3 = new lcr_node(expected3);

		//link up
		lcr1.setNextProcess(lcr2);
		lcr2.setNextProcess(lcr3);
		lcr3.setNextProcess(lcr1);
	}

	function testInitialization() public {
		Assert.equal(lcr1.getU(), expected1, "lcr1 should be initialized with u = expected1");
		Assert.equal(lcr2.getU(), expected2, "lcr2 should be initialized with u = expected2");
		Assert.equal(lcr3.getU(), expected3, "lcr3 should be initialized with u = expected3");
	}

	function testFirstRoundCommunication() public {
		lcr1.msgFunction();
		Assert.equal(lcr2.previewSend(), expected1, "lcr2 should have lcr1 UID queued up after lcr1.msgFunction is called.");
		lcr2.msgFunction();
		Assert.equal(lcr3.previewSend(), expected3, "lcr3 should ignore the incoming message from lcr2.msgFunction.");
		lcr3.msgFunction();
		Assert.equal(lcr1.previewSend(), expected3, "lcr1 should have lrc3 UID queued up after lcr3.msgFunction is called.");
	}

	function testIsLeaderElected() public {
		lcr1.msgFunction();
		lcr2.msgFunction();
		Assert.equal(lcr3.isLeader(), true, "lcr3 should recognize that it is leader when it recieves its UID.");
	}

	function testIsOnlyOneLeaderElected() public {
		Assert.equal(lcr3.isLeader(), true, "lcr3 should recognize that it is leader when it recieves its UID.");
		Assert.equal(lcr1.isLeader(), false, "lcr1 should recognize that it is NOT leader.");
		Assert.equal(lcr2.isLeader(), false, "lcr2 should recognize that it is NOT leader.");
	}
}
