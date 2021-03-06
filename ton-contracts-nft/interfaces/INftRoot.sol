pragma ton-solidity >= 0.43.0;

interface INftRoot {

    function mintNft(uint128 idCallback, address addrOwner, uint256 tokenId, string metadata) external;

    function mintNftCallback(uint256 id, uint128 idCallback) external;
    function returnNftCallback(uint256 idToken, TvmCell payload, address gasTo) external;
    function getInfo() external view returns (uint256 totalMinted);

}
