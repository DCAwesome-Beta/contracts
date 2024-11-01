// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {
  CCTPBase,
  CCTPReceiver,
  CCTPSender
} from "wormhole-solidity-sdk/CCTPBase.sol";

import "wormhole-solidity-sdk/interfaces/IERC20.sol";


contract CCTPTransfer is CCTPReceiver, CCTPSender {
    uint256 constant GAS_LIMIT = 250_000;

    constructor(
        address _wormholeRelayer,
        address _wormhole,
        address _circleMessageTransmitter,
        address _circleTokenMessenger,
        address _USDC
    )
        CCTPBase(
            _wormholeRelayer,
            _wormhole,
            _circleMessageTransmitter,
            _circleTokenMessenger,
            _USDC
        )
    {
        setCCTPDomain(10002, 0);
        setCCTPDomain(6, 1);
        setCCTPDomain(10005, 2);
        setCCTPDomain(10003, 3);
        setCCTPDomain(10004, 6);
    }

    function quoteCrossChainDeposit(
        uint16 targetChain
    ) public view returns (uint256 cost) {
        // Cost of delivering token and payload to targetChain
        (cost, ) = wormholeRelayer.quoteEVMDeliveryPrice(
            targetChain,
            0,
            GAS_LIMIT
        );
    }

    function sendCrossChainDeposit(
        uint16 targetChain,
        address targetHelloUSDC,
        address recipient,
        uint256 amount
    ) public payable {
        uint256 cost = quoteCrossChainDeposit(targetChain);
        require(
            msg.value == cost,
            "msg.value must be quoteCrossChainDeposit(targetChain)"
        );

        IERC20(USDC).transferFrom(msg.sender, address(this), amount);

        bytes memory payload = abi.encode(recipient);
        sendUSDCWithPayloadToEvm(
            targetChain,
            targetHelloUSDC, // address (on targetChain) to send token and payload to
            payload,
            0, // receiver value
            GAS_LIMIT,
            amount
        );
    }

    function receivePayloadAndUSDC(
        bytes memory payload,
        uint256 amountUSDCReceived,
        bytes32, // sourceAddress
        uint16, // sourceChain
        bytes32 // deliveryHash
    ) internal override onlyWormholeRelayer {
        address recipient = abi.decode(payload, (address));

        IERC20(USDC).transfer(recipient, amountUSDCReceived);
    }
}
