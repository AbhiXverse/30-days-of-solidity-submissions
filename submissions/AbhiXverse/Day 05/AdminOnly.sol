// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract AdminOnly {

    address public owner;
    uint256 public totaltreasure;

    mapping(address => uint256) public allowed;
    mapping(address => bool) public alreadytaken;

    constructor() {
        owner = msg.sender;
    }

    modifier admin() {
        require(owner == msg.sender, "only owner");
        _;
    }

    function addtreasure() public payable admin {
        totaltreasure += msg.value;
    }

    function allowUser(address user, uint256 amount) public admin {
        require( amount <= address(this).balance, "not enough treasure");
        allowed[user] = amount;
    }

    function gettreasure() public {
        require(allowed[msg.sender] > 0, "Not allowed to get treasure");
        require(!alreadytaken[msg.sender], "already get the treasure");
        uint256 amount = allowed[msg.sender];
        alreadytaken[msg.sender] = true;
        totaltreasure -= amount;
        payable(msg.sender).transfer(amount);
    }

    function checktreasureBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function resertetTreasureStatus(address user) public admin {
        alreadytaken[user] = false;
    }

    function transferOwnership(address newOwner) public admin {
        require (newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
    
}
