pragma ton-solidity >= 0.43.0;

interface ITransferNftProxy {
    function transferNft(TvmCell data) external;
    function returnNftCallback(uint256 idCollection, uint256 idToken, TvmCell payload, address gasTo) external;
}
