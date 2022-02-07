// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Escrow {
    using SafeERC20 for IERC20;

  address public buyer;
  address public seller;
  bool public buyerApproval;
  bool public sellerApproval;
  EscrowData public buyerData;
  EscrowData public sellerData;

  struct EscrowData {
    IERC20 token;
    uint256 amount;
  }

  constructor(address _buyer, address _seller) {
    buyer = _buyer;
    seller = _seller;
  }

function deposit(IERC20 _token, uint256 _amount) external {
    require(msg.sender == buyer || msg.sender == seller, "Unauthorized user");

    if (msg.sender == buyer) {
      require(buyerData.amount == 0, "Already deposited");
      _token.safeTransferFrom(msg.sender, address(this), _amount);
      buyerData = EscrowData({ token: _token, amount: _amount });
    } else {
      require(sellerData.amount == 0, "Already deposited");
      _token.safeTransferFrom(msg.sender, address(this), _amount);
      sellerData = EscrowData({ token: _token, amount: _amount });
    }
  }

  function approve() external {
    require(msg.sender == buyer || msg.sender == seller, "Unauthorized user");
    require(
      buyerData.amount != 0 && sellerData.amount != 0,
      "Tokens not deposited"
    );

    if (msg.sender == buyer) {
      buyerApproval = true;
    } else {
      sellerApproval = true;
    }

    if (buyerApproval == true && sellerApproval == true) {
      _completeContract();
    }
  }

  function _completeContract() internal {
    buyerData.token.safeTransfer(seller, buyerData.amount);
    sellerData.token.safeTransfer(buyer, sellerData.amount);

    selfdestruct(payable(msg.sender));
  }
}