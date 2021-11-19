pragma ton-solidity >= 0.43.0;

interface IDidDocument {

    struct DIDItem {
        string status;
        uint256 issuerPubKey;
        string didDocument;
    }

    function getDid() external view returns (DIDItem);

    function getInfo() external view returns (
        address addrDidStorage,
        DIDItem didItem
    );
}
