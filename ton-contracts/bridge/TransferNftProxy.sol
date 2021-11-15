pragma ton-solidity >= 0.39.0;
pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../utils/ErrorCodes.sol";
import "../utils/cell-encoder/CellEncoder.sol";
import "../utils/TransferUtils.sol";

import "./interfaces/IProxy.sol";
import "./interfaces/IProxyNft.sol";

import './../utils/access/InternalOwner.sol';
import './../utils/CheckPubKey.sol';
import "./../utils/libraries/MsgFlag.sol";


contract TransferNftProxy is
    IProxy,
    IProxyNft,
    CellEncoder,
    InternalOwner,
    TransferUtils,
    CheckPubKey
{

    address public configuration;

    IEthereumEvent.EthereumEventInitData eventData;
    uint callbackCounter = 0;

    modifier onlyEthereumConfiguration() {
        require(configuration == msg.sender, ErrorCodes.NOT_ETHEREUM_CONFIG);
        _;
    }

    constructor(address owner_) public checkPubKey {
        tvm.accept();

        setOwnership(owner_);
    }

    function broxusBridgeCallback(
        IEthereumEvent.EthereumEventInitData _eventData,
        address gasBackAddress
    ) public override onlyEthereumConfiguration cashBackTo(gasBackAddress) {
        callbackCounter++;
        eventData = _eventData;
    }

    function getDetails() public view returns (
        IEthereumEvent.EthereumEventInitData _eventData,
        uint _callbackCounter
    ) {
        return (eventData, callbackCounter);
    }

    function setConfiguration(
        address _configuration,
        address gasBackAddress
    ) override public onlyOwner cashBackTo(gasBackAddress) {
        configuration = _configuration;
    }
}
