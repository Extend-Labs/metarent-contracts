// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Metarent is ERC721Holder {
    address private admin;
    uint256 private feePermille; // fee in permille ‰, like 25‰, 0.025

    constructor(address _admin) {
        admin = _admin;
    }

    /// Modifier: only allow admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Metarent::not admin");
        _;
    }

    /// Lendable NFT info
    struct Lending {
        address lender;
        address nftToken;
        uint256 nftTokenId;
        uint256 maxRentDuration;
        uint256 dailyRentPrice;
        uint256 nftPrice;
        bool rentable;
    }
    Lending[] private lendings;
    uint256 private userLendingsSize;

    /// Rented NFT info
    struct Renting {
        address renter;
        address lender;
        address nftToken;
        uint256 nftTokenId;
        uint256 dailyRentPrice;
        uint256 nftPrice;
        uint256 rentDuration;
        uint256 rentedAt;
        bool isReturned;
    }
    Renting[] private rentings;
    uint256 private userRentingsSize;

    /// NFT Onwer mark the NFT as rentable
    function setLending(
        address nftToken,
        uint256 nftTokenId,
        uint256 maxRentDuration,
        uint256 dailyRentPrice,
        uint256 nftPrice
    ) external payable {
        // TODO: check NFT approve
        // TODO: check msg.sender == NFT.owner

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
        userLendingsSize += 1;
        lendings.push(lending);
    }

    /// Remove lending from user lending list
    function removeLending(address nftToken, uint256 nftTokenId) public pure {
        require(false, "NOT Implement");
        nftToken;
        nftTokenId;
    }

    /// Get user's rentable NFTs
    function getLending()
        public
        view
        returns (Lending[] memory filteredLendings)
    {
        Lending[] memory temp = new Lending[](userLendingsSize);
        uint256 count;
        for (uint256 i = 0; i < userLendingsSize; i++) {
            if (lendings[i].rentable == true) {
                temp[count] = lendings[i];
                count += 1;
            }
        }
        filteredLendings = new Lending[](count);
        for (uint256 i = 0; i < count; i++) {
            filteredLendings[i] = temp[i];
        }
        return filteredLendings;
    }

    /// Rent NFT
    function rent(
        address nftToken,
        uint256 nftTokenId,
        uint256 rentDuration
    ) public payable {
        // Find the lending
        Lending memory _lending;
        bool found = false;
        for (uint256 i = 0; i < lendings.length; i++) {
            Lending storage _lend = lendings[i];
            if (_lend.nftToken == nftToken && _lend.nftTokenId == nftTokenId) {
                _lending = _lend;
                found = true;

                // Check lending rentable and mark it as non-renable
                require(_lend.rentable, "Lending not avaliable");
                _lend.rentable = false;
            }
        }
        require(found, "Lending not available");

        // TODO Check eth value

        Renting memory _rent = Renting({
            renter: msg.sender,
            lender: _lending.lender,
            nftToken: nftToken,
            nftTokenId: nftTokenId,
            dailyRentPrice: _lending.dailyRentPrice,
            nftPrice: _lending.nftPrice,
            rentDuration: rentDuration,
            rentedAt: block.timestamp,
            isReturned: false
        });
        for (uint256 i = 0; i < rentings.length; i++) {
            Renting memory _r = rentings[i];
            if (_r.nftToken == nftToken && _r.nftTokenId == nftTokenId) {
                require(false, "Already rented");
            }
        }

        userRentingsSize += 1;
        rentings.push(_rent);

        // Transfer the NFT from lender to renter
        IERC721 nftContract = IERC721(nftToken);
        nftContract.transferFrom(_lending.lender, msg.sender, nftTokenId);
    }

    /// Get user's rented NFTs
    function getRenting(address user)
        public
        view
        returns (Renting[] memory filteredRentings)
    {
        Renting[] memory temp = new Renting[](userRentingsSize);
        uint256 count;
        for (uint256 i = 0; i < userRentingsSize; i++) {
            if (rentings[i].renter == user) {
                temp[count] = rentings[i];
                count += 1;
            }
        }
        filteredRentings = new Renting[](count);
        for (uint256 i = 0; i < count; i++) {
            filteredRentings[i] = temp[i];
        }
        return filteredRentings;
    }

    function returnRent(address nftToken, uint256 nftTokenId) public {
        // TODO: check NFT approve
        // TODO: check msg.sender == NFT.owner

        // 0. Checking
        Renting memory _renting;
        bool found = false;
        for (uint256 i = 0; i < rentings.length; i++) {
            Renting storage _rent = rentings[i];
            if (_rent.nftToken == nftToken && _rent.nftTokenId == nftTokenId) {
                _renting = _rent;
                found = true;
                require(
                    _rent.isReturned == false,
                    "This renting has been returned."
                );
                _rent.isReturned = true; // Mark it as un-rentable
            }
        }
        require(found, "Renting not available");

        // 1. Transfer the NFT from lender to renter
        IERC721 nftContract = IERC721(nftToken);
        nftContract.transferFrom(
            msg.sender,
            _renting.renter,
            _renting.nftTokenId
        );

        // 2. Return the collateral to renter
        payable(msg.sender).transfer(_renting.nftPrice);

        // 3. Pay renting price to lender
        payable(msg.sender).transfer(
            _renting.dailyRentPrice * _renting.rentDuration
        );
    }

    /// Change the feePermille
    function setPermille(uint256 _feePermille) public onlyAdmin {
        feePermille = _feePermille;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
