pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './interfaces/IDidDocument.sol';

import './libraries/Constants.sol';


contract DidDocument is IDidDocument {

    DIDItem _didItem;
    address _addrDidStorage;

    uint256 static _id;

    constructor(uint256 pubKey, string didDocument) public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (address addrDidStorage) = optSalt.get().toSlice().decode(address);
        require(msg.sender == addrDidStorage);
        require(msg.value >= Constants.MIN_FOR_DEPLOY);
        tvm.accept();
        _addrDidStorage = addrDidStorage;

        DIDItem newItem;
        newItem.status = "active";
        newItem.didDocument = didDocument;
        newItem.issuerPubKey = pubKey;

        _didItem = newItem;
    }

    function getDid() public view override returns (DIDItem) {
        return _didItem;
    }

    function getInfo() public view override returns (
        address addrDidStorage,
        DIDItem didItem
    ) {
        addrDidStorage = _addrDidStorage;
        didItem = _didItem;
    }
}