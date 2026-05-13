// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//荷兰拍卖
// 引入 OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// 直接继承就能用
contract DutchAuctionNFT1 is ERC721 ,Ownable{
    uint256 public immutable startPrice;
    uint256 public immutable endPrice;
    uint256 public immutable auctionStart;
    uint256 public immutable auctionDuration;

    uint256 public currentTokenId;
    bool public sold;

    constructor(uint256 _startPrice,uint256 _endPrice,uint256 _duration,uint256 _currentTokenId)  ERC721("DutchAuctionNFT", "DANFT") Ownable(msg.sender){
        startPrice = _startPrice;
        endPrice = _endPrice;
        auctionDuration = _duration;
        auctionStart = block.timestamp;
        sold = false;
        currentTokenId = _currentTokenId;
    }

    function getCurrentPrice()public view returns (uint256) {
        uint256 pastTime = block.timestamp - auctionStart;
        uint256 priceDiff = startPrice - endPrice;
        
    }

}