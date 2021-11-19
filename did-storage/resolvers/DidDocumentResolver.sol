pragma ton-solidity >= 0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import '../DidDocument.sol';


contract DidDocumentResolver {
    TvmCell _codeDidDocument;

    function resolveCodeHashDidDocument() public view returns (uint256 codeHashDidDocument) {
        return tvm.hash(_buildDidDocumentCode());
    }

    function resolveDidDocument(
        uint256 id
    ) public view returns (address addrDidDocument) {
        TvmCell code = _buildDidDocumentCode();
        TvmCell state = _buildDidDocumentState(code, id);
        uint256 hashState = tvm.hash(state);
        addrDidDocument = address.makeAddrStd(0, hashState);
    }

    function _buildDidDocumentCode() internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(address(this));
        return tvm.setCodeSalt(_codeDidDocument, salt.toCell());
    }

    function _buildDidDocumentState(
        TvmCell code,
        uint256 id
    ) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: DidDocument,
            varInit: {_id: id},
            code: code
        });
    }
}