pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './utils/CellEncoder.sol';
import './libraries/Constants.sol';
import './interfaces/ITransferNftProxy.sol';
import './interfaces/INftCollectionRoot.sol';

contract TransferNftProxy is ITransferNftProxy, CellEncoder {

    address _owner;
    address _addrCollectionRoot;

    event returnNft(uint160 collection_addr, uint256 token_id, uint160 owner_addr);

    constructor(address owner, address addrCollectionRoot) public {
        tvm.accept();
        _owner = owner;
        _addrCollectionRoot = addrCollectionRoot;
    }

    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }

    function transferNft(TvmCell data) public override {
        require(msg.value >= Constants.MIN_FOR_TRANSFER_NFT);

        tvm.rawReserve(address(this).balance - msg.value, 2);
        (
            uint160 collection_addr,
            uint256 token_id,
            int8 wid,
            uint256 owner_addr,
            string metadata
        ) = decodeEthereumEventData(data);

        INftCollectionRoot(_addrCollectionRoot).transferNft{value: 0, flag: 128}(msg.sender, collection_addr, token_id, wid, owner_addr, metadata);
    }

    function returnNftCallback(uint256 idCollection, uint256 idToken, TvmCell payload, address gasTo) public override {

        require(msg.sender == _addrCollectionRoot);

        tvm.rawReserve(address(this).balance - msg.value, 2);

        uint160 collection_addr = payload.toSlice().decode(uint160);

        emit returnNft(uint160(idCollection), idToken, collection_addr);

        gasTo.transfer({value: 0, flag: 128});
    }

}