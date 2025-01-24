// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "./interfaces/IERC721.sol";

contract Waves is ERC721 {
    struct Token {
        bytes32 content;
    }

    Token[] private tokens;
    mapping(address => uint) private balances;
    mapping(uint => address) private owners;
    mapping(address => mapping(address => bool)) private operators;
    mapping(uint => address) private approvers;

    error AddressZero();
    error InvalidTokenID();
    error InvalidOwner();
    error NotAuthorized();

    constructor (bytes32[] memory tokenParams) {
        for (uint256 i = 0; i < tokenParams.length; i++) {
            tokens.push(
                Token(
                    tokenParams[i]
                )
            );
            owners[i] = msg.sender;
            balances[msg.sender] += 1;
            emit Transfer(address(0), msg.sender, i);
        }
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), AddressZero());
        return balances[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        require(owners[tokenId] != address(0), AddressZero());
        return owners[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) external payable {
        require(tokenId < tokens.length, InvalidTokenID());
        require(
            msg.sender == owners[tokenId] || operators[from][msg.sender] || approvers[tokenId] == msg.sender, NotAuthorized()
        );
        require(owners[tokenId] == from, InvalidOwner());
        require(to != address(0), AddressZero());
        owners[tokenId] = to;
        approvers[tokenId] = address(0);
        balances[from] -= 1;
        balances[to] += 1;
        emit Transfer(from, to, tokenId);
    }

    function approve(address approved, uint256 tokenId) external payable {
        require(
            msg.sender == owners[tokenId] || operators[owners[tokenId]][msg.sender], NotAuthorized()
        );
        approvers[tokenId] = approved;
        emit Approval(owners[tokenId], approved, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        operators[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        require(tokenId < tokens.length, InvalidTokenID());
        return approvers[tokenId];
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return operators[owner][operator];
    }

}
