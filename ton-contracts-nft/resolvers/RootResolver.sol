pragma ton-solidity >= 0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import '../NftRoot.sol';

contract RootResolver {
    TvmCell _codeRoot;

    function resolveCodeHashRoot() public view returns (uint256 codeHashRoot) {
        return tvm.hash(_buildRootCode(address(this)));
    }

    function resolveRoot(
        address addrCollectionRoot,
        uint256 id
    ) public view returns (address addrRoot) {
        TvmCell code = _buildRootCode(addrCollectionRoot);
        TvmCell state = _buildRootState(code, id);
        uint256 hashState = tvm.hash(state);
        addrRoot = address.makeAddrStd(0, hashState);
    }

    function _buildRootCode(address addrCollectionRoot) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(addrCollectionRoot);
        return tvm.setCodeSalt(_codeRoot, salt.toCell());
    }

    function _buildRootState(
        TvmCell code,
        uint256 id
    ) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: NftRoot,
            varInit: {_id: id},
            code: code
        });
    }
}