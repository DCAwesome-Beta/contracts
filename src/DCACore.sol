// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/automation/interfaces/KeeperCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract DCACore is KeeperCompatibleInterface {
    struct DCAInStrategy {
        address user;
        address[] inTokens;
        uint256[] inMaxTokenCap;
        address triggerToken;
        uint256 frequency; // Frequency in seconds
        uint256 lastExecuted;
    }

    struct DCAOutStrategy {
        address user;
        address outToken;
        string outChain;
        uint256 triggerPrice;
    }

    mapping(address => DCAInStrategy) public dcaInStrategies;
    mapping(address => DCAOutStrategy) public dcaOutStrategies;

    // Track all users with DCA strategies
    address[] public dcaUsers;

    // Chainlink Price Feed addresses for trigger tokens
    mapping(address => AggregatorV3Interface) public priceFeeds;

    event DCAInTriggered(address indexed user);
    event DCAOutTriggered(address indexed user);

    constructor(
        address ethPriceFeed, 
        address wbtcPriceFeed, 
        address linkPriceFeed, 
        address WETH, 
        address WBTC, 
        address LINK
    ) {
        // Set Chainlink price feeds for tokens
        priceFeeds[WETH] = AggregatorV3Interface(ethPriceFeed);
        priceFeeds[WBTC] = AggregatorV3Interface(wbtcPriceFeed);
        priceFeeds[LINK] = AggregatorV3Interface(linkPriceFeed);
    }

    function setDCAIn(
        address user,
        address[] calldata inTokens,
        uint256[] calldata inMaxTokenCap,
        address triggerToken,
        uint256 frequency
    ) external {
        require(inTokens.length == inMaxTokenCap.length, "Mismatched array lengths");

        if (dcaInStrategies[user].user == address(0)) {
            dcaUsers.push(user); // Add new user to dcaUsers list if not already present
        }

        dcaInStrategies[user] = DCAInStrategy({
            user: user,
            inTokens: inTokens,
            inMaxTokenCap: inMaxTokenCap,
            triggerToken: triggerToken,
            frequency: frequency,
            lastExecuted: block.timestamp
        });
    }

    function setDCAOut(
        address user,
        address outToken,
        string calldata outChain,
        uint256 triggerPrice
    ) external {
        if (dcaOutStrategies[user].user == address(0)) {
            dcaUsers.push(user); // Add new user to dcaUsers list if not already present
        }

        dcaOutStrategies[user] = DCAOutStrategy({
            user: user,
            outToken: outToken,
            outChain: outChain,
            triggerPrice: triggerPrice
        });
    }

    // Chainlink Keeper's checkUpkeep function to determine if action is needed
    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory) {
        for (uint256 i = 0; i < dcaUsers.length; i++) {
            address user = dcaUsers[i];
            
            if (_shouldExecuteDCAIn(user)) {
                return (true, abi.encode(user, "dcaIn"));
            }

            if (_shouldExecuteDCAOut(user)) {
                return (true, abi.encode(user, "dcaOut"));
            }
        }

        upkeepNeeded = false;
    }

    // Chainlink Keeper's performUpkeep function to emit events when actions are required
    function performUpkeep(bytes calldata performData) external override {
        (address user, string memory action) = abi.decode(performData, (address, string));
        
        if (keccak256(abi.encodePacked(action)) == keccak256("dcaIn")) {
            _triggerDCAIn(user);
        } else if (keccak256(abi.encodePacked(action)) == keccak256("dcaOut")) {
            _triggerDCAOut(user);
        }
    }

    function _shouldExecuteDCAIn(address user) internal view returns (bool) {
        DCAInStrategy storage strategy = dcaInStrategies[user];
        return (block.timestamp - strategy.lastExecuted) >= strategy.frequency;
    }

    function _triggerDCAIn(address user) internal {
        dcaInStrategies[user].lastExecuted = block.timestamp;
        emit DCAInTriggered(user);
    }

    function _shouldExecuteDCAOut(address user) internal view returns (bool) {
        DCAOutStrategy storage strategy = dcaOutStrategies[user];
        AggregatorV3Interface priceFeed = priceFeeds[strategy.outToken];
        if (address(priceFeed) == address(0)) return false;

        (, int256 currentPrice, , , ) = priceFeed.latestRoundData();
        return currentPrice >= int256(strategy.triggerPrice);
    }

    function _triggerDCAOut(address user) internal {
        emit DCAOutTriggered(user);
    }

    // Function to retrieve all DCA users
    function getDCAUsers() external view returns (address[] memory) {
        return dcaUsers;
    }
}
