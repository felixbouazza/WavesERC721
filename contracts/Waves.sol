// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../interfaces/IERC721.sol";

contract Waves {
    struct NFT {
        bytes32 content;
    }

    NFT[] private NFTs;
    mapping(address => uint) private NFTOwned;
    mapping(uint => address) private OwnerByNFT;
    mapping(address => mapping(address => bool)) private ApprovedForAllByAddress;
    mapping(uint => address) private approvedByNFT;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    error InvalidAddressRequested();
    error InvalidOwnership();
    error NotAuthorized();

    constructor (bytes32[] memory nfts) {
        for (uint256 i = 0; i < nfts.length; i++) {
            NFTs.push(
                NFT(
                    nfts[i]
                )
            );
            OwnerByNFT[i] = msg.sender;
            NFTOwned[msg.sender] += 1;
            emit Transfer(address(0), msg.sender, i);
        }
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), InvalidAddressRequested());
        return NFTOwned[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        require(OwnerByNFT[tokenId] != address(0), InvalidOwnership());
        return OwnerByNFT[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) external payable {
        require(
            msg.sender == OwnerByNFT[tokenId] || ApprovedForAllByAddress[from][msg.sender] || approvedByNFT[tokenId] == msg.sender, NotAuthorized()
        );
        OwnerByNFT[tokenId] = to;
        approvedByNFT[tokenId] = address(0);
        NFTOwned[from] -= 1;
        NFTOwned[to] += 1;
        emit Transfer(from, to, tokenId);
    }

    function approve(address approved, uint256 tokenId) external payable {
        require(
            msg.sender == OwnerByNFT[tokenId] || ApprovedForAllByAddress[OwnerByNFT[tokenId]][msg.sender], NotAuthorized()
        );
        approvedByNFT[tokenId] = approved;
        emit Approval(OwnerByNFT[tokenId], approved, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        ApprovedForAllByAddress[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        return approvedByNFT[tokenId];
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return ApprovedForAllByAddress[owner][operator];
    }

}
