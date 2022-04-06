pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
  uint256 public constant tokensPerEth = 100;
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  constructor(address tokenAddress) payable {
      yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    require(msg.value > 0, "You must send some ETH");
    require(yourToken.balanceOf(address(this)) > 0, "there are no tokens to sell");
    uint amount = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amount);
    emit BuyTokens(msg.sender, msg.value, amount);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {
        uint amount = address(this).balance;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to send Ether");
    }
  // ToDo: create a sellTokens() function:
  function sellTokens(uint amount) public {
    require(amount > 0, "Amount must be greater than 0");
    require(yourToken.allowance(msg.sender, address(this)) >= amount, "Not enough tokens to sell");
    uint amountOfETH = amount / tokensPerEth;
    yourToken.transferFrom(msg.sender, address(this), amount);
    (bool success, ) = msg.sender.call{value: amountOfETH}("");
    require(success, "Failed to send Ether");
    emit SellTokens(msg.sender, amountOfETH, amount);
  }
}
