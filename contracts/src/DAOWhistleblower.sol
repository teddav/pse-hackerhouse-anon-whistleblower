// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

contract DAOWhistleblower {
    address admin;
    mapping(address => bool) public allowedDAO;
    mapping(address => string[]) public blows;

    constructor() {
        admin = msg.sender;
    }

    function addDAO(address dao) public {
        require(msg.sender == admin, "not the admin");
        allowedDAO[dao] = true;
    }

    function whistleblow(string calldata ipfsHash) public {
        require(allowedDAO[msg.sender], "dao not allowed");
        blows[msg.sender].push(ipfsHash);
    }
}
