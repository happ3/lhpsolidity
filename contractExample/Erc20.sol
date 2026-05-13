// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";


contract FundTokenERC20 is ERC20 {
    FundMe fundMe;
    constructor(address fundMeAddr) ERC20("FundTokenERC20", "FT") {
        fundMe = FundMe(fundMeAddr);
    }

    function mint(uint256 amountToMint) public {
        require(fundMe.balanceOf(msg.sender) >= amountToMint, "You cannot mint this many tokens");
        require(fundMe.fundStatus() == FundMe.FundStatus.going, "The fundme is not completed yet");
        _mint(msg.sender, amountToMint);
        fundMe.setFunderToAmount(msg.sender, fundMe.balanceOf(msg.sender) - amountToMint);
    }

    function claim(uint256 amountToClaim) public {
        // complete cliam
        require(balanceOf(msg.sender) >= amountToClaim, "You dont have enough ERC20 tokens");
        require(fundMe.fundStatus() == FundMe.FundStatus.going, "The fundme is not completed yet");
        /*to add */
        // burn amountToClaim Tokens       
        _burn(msg.sender, amountToClaim);
    }
}