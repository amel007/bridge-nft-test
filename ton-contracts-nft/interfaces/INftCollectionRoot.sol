pragma ton-solidity >= 0.43.0;

interface INftCollectionRoot {
    function deployCollectionCallback(uint128 idCallback) external;
    function transferNft(TvmCell data) external;
    function transferNftCallback(uint128 idCallback) external;

    function getInfo() external view returns (uint256 totalDeployedRoot);

}
