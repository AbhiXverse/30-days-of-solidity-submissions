// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./MyFirstToken.sol";

contract PreOrderTokens is MyFirstToken {

    uint256 public tokenPrice;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public totalRaised;
    address public projectOwner;
    bool public finalised = false;
    bool private initialTransferDone = false;

    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalised(uint256 totalRaised, uint256 tokensSold);

    constructor(
    uint256 _initialSupply, 
    uint256 _tokenPrice,
    uint256 _saleDuration,       
    uint256 _minPurchase,
    uint256 _maxPurchase,
    address _projectOwner
    ) MyFirstToken (_initialSupply) {
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = saleStartTime + _saleDuration;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;
       
        _transfer(address(this), msg.sender, _initialSupply);
        initialTransferDone = true;
    }

    function isSaleActive() public view returns(bool) {
        return (!finalised && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    function buyToken() public payable {
        require(isSaleActive(), "Sale is not active now");
        require(msg.value >= minPurchase, "Out of Range");
        require(msg.value <= maxPurchase, "Out of Range");

        uint256 tokenAmount = (msg.value * 10 ** uint256(decimals))/ tokenPrice;

        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens available");
        totalRaised += msg.value;
        _transfer(address(this), msg.sender, tokenAmount);
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    function transfer(address _to, uint256 _value) public override returns (bool) {
        if (!finalised && msg.sender != address(this) && initialTransferDone) {
            require(false, "token are locked until is finalised");
        }
        return super.transfer(_to, _value);
    }

    function transferFrom (address _from, address _to, uint256 _value) public override returns (bool) {
        if (!finalised && _from != address(this)) {
            require(false, "token are locked until is finalised");
        }
        return super.transferFrom(_from, _to, _value);
    }

    function finaliseSale() public payable {
        require (msg.sender == projectOwner, "Only owner can call");
        require(!finalised, "Already finalised");
        require(block.timestamp > saleEndTime, "Sale is not ended");
        finalised = true;

        uint256 tokensSold = totalSupply  - balanceOf[address(this)];
        (bool success, ) = projectOwner.call{value: address(this).balance}(""); 
        require(success, "transfer falied");
        emit SaleFinalised(totalRaised, tokensSold);
   }

    function timeRemaining() public view returns (uint256) {
    if (block.timestamp >= saleEndTime) {
        return 0;
    }  
     return (saleEndTime - block.timestamp);
    }

    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
    }

    receive() external payable {
        buyToken();
    }
}