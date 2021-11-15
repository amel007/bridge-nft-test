pragma ton-solidity >= 0.43.0;

interface INftRoot {

    function mintNft(uint128 idCallback, address addrOwner, uint256 tokenId) external;

    function mintNftCallback(uint256 id, uint128 idCallback) external;

    function getInfo() external view returns (uint256 totalMinted);

}
