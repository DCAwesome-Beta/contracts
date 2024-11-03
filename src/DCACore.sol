// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "./CCTPTransfer.sol";  

import "wormhole-solidity-sdk/interfaces/IERC20.sol";

contract DCACore is AutomationCompatibleInterface {
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

    struct CrossChainTransferTrigger {
        address user;
        uint256 amount;
        uint16 targetChain;
        address triggerToken;
        address targetAddress;
        address recipient;
        uint256 triggerPrice; // 10^8
    }

    mapping(address => CrossChainTransferTrigger) public crossChainTransferTriggers;
    address[] public crossChainUsers;

    mapping(address => DCAInStrategy) public dcaInStrategies;
    mapping(address => DCAOutStrategy) public dcaOutStrategies;

    // Track all users with DCA strategies
    address[] public dcaUsers;

    // Chainlink Price Feed addresses for trigger tokens
    mapping(address => AggregatorV3Interface) public priceFeeds;

    CCTPTransfer public cctpTransferContract;

    address private USDC;

    event DCAInTriggered(address indexed user);
    event DCAOutTriggered(address indexed user);

    constructor(
        address ethPriceFeed, 
        address wbtcPriceFeed, 
        address linkPriceFeed, 
        address WETH, 
        address WBTC, 
        address LINK,
        address _USDC,
        address _cctpTransferAddress

    ) {
        // Set Chainlink price feeds for tokens
        priceFeeds[WETH] = AggregatorV3Interface(ethPriceFeed);
        priceFeeds[WBTC] = AggregatorV3Interface(wbtcPriceFeed);
        priceFeeds[LINK] = AggregatorV3Interface(linkPriceFeed);

        cctpTransferContract = CCTPTransfer(_cctpTransferAddress);
        USDC = _USDC;
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

    function setCrossChainTransferTrigger(
        address user,
        uint16 targetChain,
        address triggerToken,
        address targetAddress,
        address recipient,
        uint256 amount,
        uint256 triggerPrice
    ) external {
        if (crossChainTransferTriggers[user].user == address(0)) {
            crossChainUsers.push(user); // Add new user if not already present
        }

        crossChainTransferTriggers[user] = CrossChainTransferTrigger({
            user: user,
            targetChain: targetChain,
            triggerToken: triggerToken,
            targetAddress: targetAddress,
            recipient: recipient,
            amount: amount,
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
        for (uint256 i = 0; i < crossChainUsers.length; i++) {
            address user = crossChainUsers[i];
            
            if (_shouldTriggerCrossChainTransfer(user)) {
                return (true, abi.encode(user, "crossChainTransfer"));
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
        } else if (keccak256(abi.encodePacked(action)) == keccak256("crossChainTransfer")) {
            _triggerCrossChainTransfer(user);
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

     function _shouldTriggerCrossChainTransfer(address user) internal view returns (bool) {
        CrossChainTransferTrigger storage trigger = crossChainTransferTriggers[user];
        AggregatorV3Interface priceFeed = priceFeeds[trigger.triggerToken];
        
        if (address(priceFeed) == address(0)) return false;

        (, int256 currentPrice, , , ) = priceFeed.latestRoundData();
        return currentPrice >= int256(trigger.triggerPrice);
    }

    function _triggerCrossChainTransfer(address user) internal {
        CrossChainTransferTrigger storage trigger = crossChainTransferTriggers[user];
        uint256 cost = cctpTransferContract.quoteCrossChainDeposit(trigger.targetChain);

        IERC20(USDC).transferFrom(user, address(this), trigger.amount);
        IERC20(USDC).approve(trigger.targetAddress, trigger.amount);

        // Initiate cross-chain transfer using CCTPTransfer contract
        cctpTransferContract.sendCrossChainDeposit{value: cost}(
            trigger.targetChain,
            trigger.targetAddress,
            trigger.recipient,
            trigger.amount  // This could be replaced with a specific USDC amount
        );
    }


    function _triggerDCAOut(address user) internal {
        emit DCAOutTriggered(user);
    }

    // Retrieve all users with cross-chain transfer triggers
    function getCrossChainUsers() external view returns (address[] memory) {
        return crossChainUsers;
    }
    
    // Function to retrieve all DCA users
    function getDCAUsers() external view returns (address[] memory) {
        return dcaUsers;
    }
}
