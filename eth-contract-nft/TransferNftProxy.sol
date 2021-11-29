// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./IBridge.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract TransferNftProxy is Ownable, IERC721Receiver {

    address public _bridge;

    event EthereumTransferNft(uint160 collection, uint256 tokenId, int8 wid, uint256 addr, string metadata);

    event EthereumReturnNft(uint160 collection, uint256 tokenId, uint160 owner_addr);

    function setBridge(address bridge) public onlyOwner {
        _bridge = bridge;
    }

    function returnNft(bytes memory payload, bytes memory signature) public {

        require(IBridge(_bridge).verifyPayload(payload, signature), "Invalid payload or signature");

        (uint160 collection_addr, uint256 token_id, uint160 owner_addr) = abi.decode(
            payload,
            (uint160, uint256, uint160)
        );

        require(IERC721(address(collection_addr)).ownerOf(token_id) == address(this), "token was not found");

        IERC721(address(collection_addr)).transferFrom(address(this), address(owner_addr), token_id);

        emit EthereumReturnNft(collection_addr, token_id, owner_addr);
    }

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