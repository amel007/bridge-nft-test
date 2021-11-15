pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';
import './resolvers/DataResolver.sol';
import './interfaces/INftCollectionRoot.sol';
import './interfaces/INftRoot.sol';

contract NftRoot is DataResolver, IndexResolver, INftRoot {

    uint256 _totalMinted;
    address _addrCollectionRoot;

    uint256 static _id;

    constructor(TvmCell codeIndex, TvmCell codeData, uint128 idCallback) public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (address addrCollectionRoot) = optSalt.get().toSlice().decode(address);
        require(msg.sender == addrCollectionRoot);
        tvm.rawReserve(Constants.MIN_FOR_CONTRACT, 2);
        _addrCollectionRoot = addrCollectionRoot;
        _codeIndex = codeIndex;
        _codeData = codeData;

        INftCollectionRoot(_addrCollectionRoot).deployCollectionCallback{value: 0, flag: 128}(idCallback);
    }

    function mintNft(uint128 idCallback, address addrOwner, uint256 tokenId) public override {
        require(msg.sender == _addrCollectionRoot);

        require(msg.value >= Constants.MIN_FOR_DEPLOY + Constants.MIN_MSG_VALUE);

        tvm.rawReserve(Constants.MIN_FOR_CONTRACT, 2);

        TvmCell codeData = _buildDataCode(address(this));
        TvmCell stateData = _buildDataState(codeData, tokenId);
        new Data{stateInit: stateData, value: 0, flag: 128}(addrOwner, _codeIndex, idCallback);
    }

    function mintNftCallback(uint256 id, uint128 idCallback) public override {
        address addrData = resolveData(address(this), id);
        require(msg.sender == addrData);

        tvm.rawReserve(Constants.MIN_FOR_CONTRACT, 2);

        _totalMinted++;

        INftCollectionRoot(_addrCollectionRoot).transferNftCallback{value: 0, flag: 128}(idCallback);
    }

    function getInfo() public override view returns (uint256 totalMinted) {
        totalMinted = _totalMinted;
    }
}