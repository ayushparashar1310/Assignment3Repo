// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    uint public maxTickets;
    uint public ticketPrice;
    uint public soldTickets;
    address[] public lotteryBuyers;
    enum LotteryState { OPEN, CLOSED, ENDED }
    LotteryState public lotteryState;

    constructor(uint _maxTickets, uint _ticketPrice) {
        owner = msg.sender;
        maxTickets = _maxTickets;
        ticketPrice = _ticketPrice;
        lotteryState = LotteryState.OPEN;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier inState(LotteryState _state) {
        require(lotteryState == _state, "Invalid state");
        _;
    }

    function buyTicket() public payable inState(LotteryState.OPEN) {
        require(msg.value == ticketPrice, "Incorrect ticket price");
        require(soldTickets < maxTickets, "Tickets sold out");
        
        lotteryBuyers.push(msg.sender);
        soldTickets++;

        if (soldTickets == maxTickets) {
            lotteryState = LotteryState.CLOSED;
        }
    }

    function getWinner() public onlyOwner inState(LotteryState.CLOSED) {
        require(lotteryBuyers.length > 0, "No participants");

        uint winnerIndex = random() % lotteryBuyers.length;
        address winner = lotteryBuyers[winnerIndex];

        uint totalAmount = address(this).balance;
        uint winnerPrize = (totalAmount * 80) / 100; // 80% for the winner
        uint ownerPrize = (totalAmount * 20) / 100;  // 20% for the owner

        payable(winner).transfer(winnerPrize);
        payable(owner).transfer(ownerPrize);

        lotteryState = LotteryState.ENDED;
    }

    function endLottery() public onlyOwner inState(LotteryState.CLOSED) {
        lotteryState = LotteryState.ENDED;
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, lotteryBuyers)));

    }

    function getBuyers() public view returns (address[] memory) {
        return lotteryBuyers;
    }
}
