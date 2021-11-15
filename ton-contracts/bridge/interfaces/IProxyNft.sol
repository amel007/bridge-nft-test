pragma ton-solidity >= 0.39.0;

interface IProxyNft {
    function setConfiguration(
        address _configuration,
        address gasBackAddress
    ) external;
}
