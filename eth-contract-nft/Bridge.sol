pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./IBridge.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Bridge is Ownable, IBridge {

    using ECDSA for bytes32;

    address public _relay;
    address public _proxy;


    function setRelay(address relay) public onlyOwner {
        _relay = relay;
    }

    function setProxy(address proxy) public onlyOwner {
        _proxy = proxy;
    }

    function verifyPayload(
        bytes memory payload,
        bytes memory signature
    ) public view override returns(bool) {
        return ECDSA.toEthSignedMessageHash(payload).recover(signature) == _relay;
    }

}