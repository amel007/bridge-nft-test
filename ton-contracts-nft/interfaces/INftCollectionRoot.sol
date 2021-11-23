pragma ton-solidity >= 0.43.0;

interface INftCollectionRoot {
    function deployCollectionCallback(uint128 idCallback) external;
    function transferNft(
        address gasTo,
        uint160 collection_addr,
        uint256 token_id,
        int8 wid,
        uint256 owner_addr,
        string metadata
    ) external;
    function transferNftCallback(uint128 idCallback) external;
    function lockNftCallback(uint256 idCollection, uint256 idToken, TvmCell payload, address gasTo, address addrTo) external;
    function getInfo() external view returns (uint256 totalDeployedRoot);

}
