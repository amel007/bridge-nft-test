pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface IBridge {

    function verifyPayload(
        bytes memory payload,
        bytes memory signature
    ) external view returns(bool);
}