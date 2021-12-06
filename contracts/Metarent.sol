// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./lib/MetarentHelper.sol";

contract Metarent is ERC721 {
    constructor() public {}

    address private admin;
    uint256 private feePermille; // fee in permille ‰, like 25‰, 0.025

    constructor(address _admin) {
        checkZeroAddr(_resolver);
        admin = _admin;
    }

    // Modifier: only allow admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Metarent::not admin");
        _;
    }

    struct Lending {
        address payable lenderAddress;
        uint8 maxRentDuration;
        bytes4 dailyRentPrice;
        bytes4 nftPrice;
    }

    struct Renting {
        address payable renterAddress;
        uint8 rentDuration;
        uint32 rentedAt;
    }

    struct LendingRenting {
        Lending lending;
        Renting renting;
    }

    mapping(bytes32 => LendingRenting) private lendingRenting;

    /**
     * Rent NFT
     */
    function rent() public payable {}

    /**
     * Allow NFT to be lent
     */
    function lend() public {}

    /**
     * Change the feePermille
     */
    function setPermille(uint256 _feePermille) public onlyAdmin {
        feePermille = _feePermille;
    }
}
