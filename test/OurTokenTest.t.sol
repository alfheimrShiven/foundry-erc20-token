// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    DeployOurToken public deployer;
    OurToken public ourToken;
    uint256 public STARTING_BALANCE = 100 ether;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() external {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testTokenReceived() public view {
        assert(ourToken.balanceOf(bob) == STARTING_BALANCE);
    }

    function testAllowancesWork() public {
        uint256 initialAllowance = 1000;
        uint256 initialAllowanceTransfer = 500;
        // Bob will approve Alice for the allowance
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        // Alice will request the transfer of allowance approved to her
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, initialAllowanceTransfer);

        assert(
            ourToken.balanceOf(bob) ==
                (STARTING_BALANCE - initialAllowanceTransfer)
        );
        assert(ourToken.balanceOf(alice) == initialAllowanceTransfer);
    }

    function testAllowanceCanBeIncreased() public {
        uint256 initialAllowance = 1000;
        uint256 increasedAllowance = 2000;

        // Bob will approve Alice for the allowance
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        // Bob will increase the allowance approved to Alice
        vm.prank(bob);
        ourToken.approve(alice, increasedAllowance);

        assert(ourToken.allowance(bob, alice) == increasedAllowance);
    }

    function testAllowanceCanBeDecreased() public {
        uint256 initialAllowance = 1000;
        uint256 decreasedAllowance = 500;

        // Bob will approve Alice for the allowance
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        // Bob will decrease the allowance approved to Alice
        vm.prank(bob);
        ourToken.approve(alice, decreasedAllowance);

        assert(ourToken.allowance(bob, alice) == decreasedAllowance);
    }

    function testTransferFailsIfAllowanceIsInsufficient() public {
        uint256 initialAllowance = 500;
        uint256 transferAmount = 1000;

        // Bob will approve Alice for the allowance
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        // Alice will try to transfer more tokens than the allowance
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, transferAmount);
    }
}
