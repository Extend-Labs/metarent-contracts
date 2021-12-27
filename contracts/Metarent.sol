// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

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

    /**
     * Lendable NFT info
     */
    struct Lending {
        address lender;
        uint256 nftToken;
        uint256 nftTokenId;
        uint8 maxRentDuration;
        bool rentable;
        bytes4 dailyRentPrice;
        bytes4 nftPrice;
    }
    Lending[] lendings;
    uint256 userLendingsSize;

    /**
     * Rented NFT info
     */
    struct Renting {
        address renter;
        uint256 nftToken;
        uint256 nftTokenId;
        bytes4 dailyRentPrice;
        bytes4 nftPrice;
        uint8 rentDuration;
        uint256 rentedAt;
    }
    Renting[] rentings;
    uint256 userRentingsSize;

    /**
     * NFT Onwer mark the NFT as rentable
     */
    function setLending(
        uint256 nftToken,
        uint256 nftTokenId,
        uint8 maxRentDuration,
        bytes4 dailyRentPrice,
        bytes4 nftPrice
    ) public {
        address user = msg.sender;

        // Init lending info
        Lending memory lending = Lending({
            lender: msg.sender,
            nftToken: nftToken,
            nftTokenId: nftTokenId,
            maxRentDuration: maxRentDuration,
            dailyRentPrice: dailyRentPrice,
            nftPrice: nftPrice,
            rentable: true
        });

        // Add lending to user lending list
        for (uint256 i = 0; i < lendings.length; i++) {
            Lending storage _lend = lendings[i];
            if (_lend.nftToken == nftToken && _lend.nftTokenId == nftTokenId) {
                require(false, "Already lended");
            }
        }
        userLendingsSize++;
        lendings[userLendingsSize] = lending;
    }

    /**
     * Remove lending from user lending list
     */
    function removeLending(uint256 nftToken, uint256 nftTokenId) public pure {
        require(false, "NOT Implement");
    }

    /**
     * Get user's rentable NFTs
     */
    function getLending(address user) public view returns (Lending[] memory) {
        Lending[] storage _lendings;
        for (uint256 i = 0; i < lendings.length; i++) {
            if (lendings[i].lender == user) {
                _lendings.push(lendings[i]);
            }
        }
        return _lendings;
    }

    /**
     * Rent NFT
     */
    function rent(
        address user,
        uint256 nftToken,
        uint256 nftTokenId,
        uint8 rentDuration
    ) public payable {
        bool success = false;

        // Find the lending
        Lending memory _lending;
        bool found = false;
        for (uint256 i = 0; i < lendings.length; i++) {
            Lending storage _lend = lendings[i];
            if (_lend.nftToken == nftToken && _lend.nftTokenId == nftTokenId) {
                _lending = _lend;
            }
        }
        require(found, "Lending not available");

        Renting memory _rent = Renting({
            renter: msg.sender,
            nftToken: nftToken,
            nftTokenId: nftTokenId,
            dailyRentPrice: _lending.dailyRentPrice,
            nftPrice: _lending.nftPrice,
            rentDuration: rentDuration,
            rentedAt: block.timestamp
        });
        for (uint256 i = 0; i < rentings.length; i++) {
            Renting memory _r = rentings[i];
            if (_r.nftToken == nftToken && _r.nftTokenId == nftTokenId) {
                require(false, "Already rented");
            }
        }

        userRentingsSize++;
        rentings[userRentingsSize] = _rent;
    }

    /**
     * Get user's rented NFTs
     */
    function getRenting(address user) public view returns (Renting[] memory) {
        Renting[] storage _rentings;
        for (uint256 i = 0; i < rentings.length; i++) {
            if (rentings[i].renter == user) {
                _rentings.push(rentings[i]);
            }
        }
        return _rentings;
    }

    /**
     * Change the feePermille
     */
    function setPermille(uint256 _feePermille) public onlyAdmin {
        feePermille = _feePermille;
    }
}
