pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/DidDocumentResolver.sol';

contract DidStorage is DidDocumentResolver {

    uint256 _totalDid;

    constructor(TvmCell codeDidDocument) public {
        tvm.accept();
        _codeDidDocument = codeDidDocument;
    }

    function addDid(uint256 pubKey, string didDocument) public returns (uint256) {
        TvmCell codeDidDocument = _buildDidDocumentCode();
        TvmCell stateDidDocument = _buildDidDocumentState(codeDidDocument, pubKey);
        new DidDocument{stateInit: stateDidDocument, value: 0.4 ton}(pubKey, didDocument);

        _totalDid++;

        return pubKey;
    }

    function signData(string data) public returns (uint256) {
        tvm.accept();
        return sha256(format("{}{}", data, msg.pubkey()));
    }

    function verifySignature(string data, uint256 signature) public view returns (bool) {
        tvm.accept();
        return sha256(format("{}{}", data, msg.pubkey())) == signature;
    }
}