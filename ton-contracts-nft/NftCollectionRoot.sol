pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/RootResolver.sol';
import './interfaces/INftCollectionRoot.sol';
import './interfaces/ITransferNftProxy.sol';

contract NftCollectionRoot is RootResolver, INftCollectionRoot {

    address _addrTransferProxy;
    uint128 _idCallback;
    uint256 _totalDeployedRoot;

    TvmCell _codeData;
    TvmCell _codeIndex;

    struct Callback {
        address sender_msg;
        uint160 collection_addr;
        uint256 token_id;
        int8 wid;
        uint256 owner_addr;
        string metadata;
    }

    mapping(uint128 => Callback) transferCallbacks;

    constructor(address addrTransferProxy, TvmCell codeRoot, TvmCell codeIndex, TvmCell codeData) public {
        tvm.accept();
        _addrTransferProxy = addrTransferProxy;
        _codeRoot = codeRoot;
        _codeIndex = codeIndex;
        _codeData = codeData;
    }

    onBounce(TvmSlice slice) external {
        uint32 functionId = slice.decode(uint32);
        if (functionId == tvm.functionId(NftRoot.mintNft)) {
            uint128 idCallback = slice.decode(uint128);
            if (transferCallbacks.exists(idCallback)) {
                tvm.rawReserve(address(this).balance - msg.value, 2);

                Callback data = transferCallbacks[idCallback];

                TvmCell codeRoot = _buildRootCode(address(this));
                TvmCell stateRoot = _buildRootState(codeRoot, data.collection_addr);

                new NftRoot{stateInit: stateRoot, value: 0, flag:128}(_codeIndex, _codeData, idCallback);
            }
        }
    }

    function deployCollectionCallback(uint128 idCallback) public override {
        require(transferCallbacks.exists(idCallback));
        Callback data = transferCallbacks[idCallback];

        address addrRoot = resolveRoot(address(this), uint256(data.collection_addr));

        require(msg.sender == addrRoot);

        tvm.rawReserve(address(this).balance - msg.value, 2);

        _totalDeployedRoot++;

        delete transferCallbacks[idCallback];

        sendMsgRootNft(data);
    }

    function sendMsgRootNft(Callback data) private {
        address addrRoot = resolveRoot(address(this), uint256(data.collection_addr));
        transferCallbacks[_idCallback] = data;

        uint128 sendIdCallbak = _idCallback;
        _idCallback++;

        // todo if (_idCallback > 128bit) _idCallback = 0;

        address addrOwner = address.makeAddrStd(data.wid, data.owner_addr);

        NftRoot(addrRoot).mintNft{value: 0, flag:128}(sendIdCallbak, addrOwner, data.token_id, data.metadata);
    }

    function transferNft(
        address gasTo,
        uint160 collection_addr,
        uint256 token_id,
        int8 wid,
        uint256 owner_addr,
        string metadata
    ) public override {
        require(msg.sender == _addrTransferProxy);

        tvm.rawReserve(address(this).balance - msg.value, 2);

        sendMsgRootNft(Callback(gasTo, collection_addr, token_id, wid, owner_addr, metadata));
    }

    function transferNftCallback(uint128 idCallback) public override {
        require(transferCallbacks.exists(idCallback));
        Callback data = transferCallbacks[idCallback];

        address addrRoot = resolveRoot(address(this), uint256(data.collection_addr));

        require(msg.sender == addrRoot);

        tvm.rawReserve(address(this).balance - msg.value, 2);

        delete transferCallbacks[idCallback];

        data.sender_msg.transfer({value:0, flag:128});
    }

    function returnNftCallback(uint256 idCollection, uint256 idToken, TvmCell payload, address gasTo) public override {
        address addrRoot = resolveRoot(address(this), idCollection);

        require(msg.sender == addrRoot);

        tvm.rawReserve(address(this).balance - msg.value, 2);

        ITransferNftProxy(_addrTransferProxy).returnNftCallback{value: 0, flag: 128}(idCollection, idToken, payload, gasTo);
    }

    function getInfo() public override view returns (uint256 totalDeployedRoot) {
        totalDeployedRoot = _totalDeployedRoot;
    }
}