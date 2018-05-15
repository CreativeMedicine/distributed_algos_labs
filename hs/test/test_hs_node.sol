pragma solidity ^0.4.23;
pragma experimental ABIEncoderV2; //so that I can pass structs around

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/hs_node.sol";

/**
 * The test_hs_node contract does this and that...
 */
contract test_hs_node {
	hs_node hs1;
	hs_node hs2;
	hs_node hs3;
	hs_node hs4;
	hs_node hs5;

	uint u1 = 5;
	uint u2 = 17;
	uint u3 = 4;
	uint u4 = 9;
	uint u5 = 12;
	
	function beforeAll() {
		//initialize the nodes with UIDs...
		hs1 = new hs_node(u1);
		hs2 = new hs_node(u2);
		hs3 = new hs_node(u3);
		hs4 = new hs_node(u4);
		hs5 = new hs_node(u5);
		//connect these things into a ring network...
		hs1.setNextProcess(hs2);
		hs2.setPrevProcess(hs1); //hs1 <--> hs2
		hs2.setNextProcess(hs3);
		hs3.setPrevProcess(hs2); //hs2 <--> hs3
		hs3.setNextProcess(hs4);
		hs4.setPrevProcess(hs3); //hs3 <--> hs4
		hs4.setNextProcess(hs5);
		hs5.setPrevProcess(hs4); //hs4 <--> hs5
		hs5.setNextProcess(hs1);
		hs1.setPrevProcess(hs5); //hs5 <--> hs1
	}

	function testInitialization() public {
		Assert.equal(hs1.getU(), u1, "The UID of hs1 should = u1");
		Assert.equal(hs2.getU(), u2, "The UID of hs2 should = u2");
		Assert.equal(hs3.getU(), u3, "The UID of hs3 should = u3");
		Assert.equal(hs4.getU(), u4, "The UID of hs4 should = u4");
		Assert.equal(hs5.getU(), u5, "The UID of hs5 should = u5");
		Assert.equal(hs1.getNextProcess(), hs2, "The next should match our ring network shape expectations.");
		Assert.equal(hs2.getPrevProcess(), hs1, "The previous should match our ring network shape expectations."); //hs1 <--> hs2
		Assert.equal(hs2.getNextProcess(), hs3, "The next should match our ring network shape expectations.");
		Assert.equal(hs3.getPrevProcess(), hs2, "The previous should match our ring network shape expectations."); //hs2 <--> hs3
		Assert.equal(hs3.getNextProcess(), hs4, "The next should match our ring network shape expectations.");
		Assert.equal(hs4.getPrevProcess(), hs3, "The previous should match our ring network shape expectations."); //hs3 <--> hs4
		Assert.equal(hs4.getNextProcess(), hs5, "The next should match our ring network shape expectations.");
		Assert.equal(hs5.getPrevProcess(), hs4, "The previous should match our ring network shape expectations."); //hs4 <--> hs5
		Assert.equal(hs5.getNextProcess(), hs1, "The next should match our ring network shape expectations.");
		Assert.equal(hs1.getPrevProcess(), hs5, "The previous should match our ring network shape expectations."); //hs5 <--> hs1
	}

	function step() private {
		hs_node[5] memory nodes = [hs1, hs2, hs3, hs4, hs5];
		//send all the messages for round x
		for(uint i = 0; i < nodes.length; i++) {
			nodes[i].msgFunction();
		}
		//transition all of the nodes for round x
		for(i = 0; i < nodes.length; i++) {
			nodes[i].trans();
		}
	}

	function checkNode(hs_node curr, uint expected_id, hs_node.Direction expected_direction, uint expected_hopCount) private {
		uint id;
		hs_node.Direction direction; //dat inheritance doh...
		uint hopCount;
		(id, direction, hopCount) = curr.getOutgoing_toPrevProcess(); //this is how you work with multiple return values

		Assert.equal(id, expected_id, "An incorrect ID was discovered outgoing to previous process.");
		Assert.equal(uint(direction), uint(expected_direction), "An incorrect direction was discovered outgoing to previous process.");
		Assert.equal(hopCount, expected_hopCount, "An incorrect hop cound was discovered outgoing to previous process.");
	}

	function testComparisonRound1() public {
		step();
		checkNode(hs5, 0, hs_node.Direction.Out, 0);
	}

	// function testMessageBuffering() public {
	// 	hs1.msgFunction();
	// 	Assert.equal(hs2.getFromPrev().id, u1, "hs2 should have u1 buffered in fromPrev.");
	// 	Assert.equal(hs5.getFromNext().id, u1, "hs5 should have u1 buffered in fromNext.");
	// }

	function testValidity() public {

	}

	function testTermination() public {

	}
}
