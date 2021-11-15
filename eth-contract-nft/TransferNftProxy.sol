// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract TransferNftProxy is Ownable, IERC721Receiver {

    event EthereumTransferNft(uint160 collection, uint256 tokenId, int8 wid, uint256 addr, string metadata);

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public virtual override returns (bytes4) {

        operator;
        from;

        address nft_collection = _msgSender();

        // send request to nft, get name, symbol ???
        string memory metadata = IERC721Metadata(nft_collection).tokenURI(tokenId);


        (int8 wid, uint256 addr) = abi.decode(data, (int8, uint256));

        //todo need convert to uint256 or address or bytes (address may be will change to uint256)
        // or return _msgSender() not address, but uint160 or uint256???
        emit EthereumTransferNft(uint160(nft_collection), tokenId, wid, addr, metadata);

        return this.onERC721Received.selector;
    }
}