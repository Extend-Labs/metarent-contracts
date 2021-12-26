// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./lib/MetarentHelper.sol";

contract Metarent is ERC721Holder, MetarentHelper {
    address private admin;
    uint256 private feePermille; // fee in permille ‰, like 25‰, 0.025

    constructor(address _admin) {
        checkZeroAddr(_admin);
        admin = _admin;
    }

    // Modifier: only allow admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Metarent::not admin");
        _;
    }

    struct Lending {
        address payable lenderAddress;
        uint256 nftToken;
        uint256 nftTokenId;
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

    /**
     * Mapping for lender and renter to their LendingRenting
     */
    mapping(address => LendingRenting) private lendingRenting;

    // EnumerableMap.UintToAddressMap private lendingRenting;

    // Get lender's NFT tokenIds
    // function getTokenIds(address _owner)
    //     public
    //     view
    //     returns (uint256[] memory)
    // {
    //     uint256[] memory _tokensOfOwner = new uint256[](
    //         ERC721.balanceOf(_owner)
    //     );
    //     uint256 i;

    //     for (i = 0; i < ERC721.balanceOf(_owner); i++) {
    //         _tokensOfOwner[i] = ERC721Enumerable.tokenOfOwnerByIndex(_owner, i);
    //     }
    //     return (_tokensOfOwner);
    // }

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
