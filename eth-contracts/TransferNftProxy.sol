// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./utils/RedButton.sol";

contract TransferNftProxy is RedButton {

    struct EventData {
        uint128 amount;
        int8 wid;
        uint256 addr;
    }

    EventData public lastEvent;

    event EthereumTransferNft(uint128 amount, int8 wid, uint256 addr);

    constructor(address _admin) public {
        _setAdmin(_admin);
    }

    function transferNft(
        EventData memory _eventData
    ) public onlyAdmin {

        lastEvent = _eventData;

        emit EthereumTransferNft(amount, wid, addr);
    }
}