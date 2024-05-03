// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// interface AggregatorV3Interface {
// function latestRoundData() external view returns(uint80 roundId,int answer , uint startedAt,uint updatedAt,uint80 answeredInRound) ;
// }

contract ChainlinkPrice {
    AggregatorV3Interface internal priceFeed;

    constructor() {
        priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    /// @dev - get the latest price
    /// @return int - price fetched
    function getLatestPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price; // The price is already in the correct scale, no need to divide by 1e8
    }
}

//  2988,65000000
