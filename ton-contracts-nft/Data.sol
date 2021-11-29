pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';

import './interfaces/IData.sol';

import './libraries/Constants.sol';

import './interfaces/INftRoot.sol';


contract Data is IData, IndexResolver {
    address _addrRoot;
    address _addrOwner;
    address _addrAuthor;

    string _metadata;

    uint256 static _id;

    constructor(address addrOwner, TvmCell codeIndex, uint128 idCallback, string metadata) public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (address addrRoot) = optSalt.get().toSlice().decode(address);
        require(msg.sender == addrRoot);
        require(msg.value >= Constants.MIN_FOR_DEPLOY);
        tvm.rawReserve(Constants.MIN_FOR_CONTRACT, 2);
        _addrRoot = addrRoot;
        _addrOwner = addrOwner;
        _addrAuthor = addrOwner;
        _codeIndex = codeIndex;
        _metadata = metadata;

        deployIndex(addrOwner);

        INftRoot(addrRoot).mintNftCallback{value: 0, flag: 128}(_id, idCallback);
    }

    // TODO add destAddr to .destruct() => .destruct(destAddr)
    function destructIndex() private {
        address oldIndexOwner = resolveIndex(_addrRoot, address(this), _addrOwner);
        IIndex(oldIndexOwner).destruct();
        address oldIndexOwnerRoot = resolveIndex(address(0), address(this), _addrOwner);
        IIndex(oldIndexOwnerRoot).destruct();
    }

    function transferOwnership(address addrTo) public override {
        require(msg.sender == _addrOwner);
        require(msg.value >= Constants.MIN_MSG_VALUE + (Constants.MIN_FOR_CONTRACT * 2));

        tvm.rawReserve(Constants.MIN_FOR_CONTRACT, 2);

        destructIndex();

        _addrOwner = addrTo;

        deployIndex(addrTo);

        msg.sender.transfer({value: 0, flag: 128});
    }

    function returnNft(TvmCell payload) public override {
        require(msg.sender == _addrOwner);
        require(msg.value >= Constants.MIN_MSG_VALUE + Constants.MIN_FOR_CONTRACT);

        destructIndex();

        INftRoot(_addrRoot).returnNftCallback{value: 0, flag: 64}(_id, payload, msg.sender);

        selfdestruct(msg.sender);
    }

    // TODO add require(addrData or addrRoot) to constructor Index
    function deployIndex(address owner) private {
        TvmCell codeIndexOwner = _buildIndexCode(_addrRoot, owner);
        TvmCell stateIndexOwner = _buildIndexState(codeIndexOwner, address(this));
        new Index{stateInit: stateIndexOwner, value: Constants.MIN_FOR_CONTRACT}(_addrRoot);

        TvmCell codeIndexOwnerRoot = _buildIndexCode(address(0), owner);
        TvmCell stateIndexOwnerRoot = _buildIndexState(codeIndexOwnerRoot, address(this));
        new Index{stateInit: stateIndexOwnerRoot, value: Constants.MIN_FOR_CONTRACT}(_addrRoot);
    }

    function getInfo() public view override returns (
        address addrRoot,
        address addrOwner,
        address addrData,
        string metadata
    ) {
        addrRoot = _addrRoot;
        addrOwner = _addrOwner;
        addrData = address(this);
        metadata = _metadata;
    }

    function getOwner() public view override returns(address addrOwner) {
        addrOwner = _addrOwner;
    }
}