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

    mapping(address => UserLending) private userLendings;
    mapping(address => UserRenting) private userRentings;

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
     * Single rentable NFT info
     */
    struct Lending {
        address lenderAddress;
        uint256 nftToken;
        uint256 nftTokenId;
        uint8 maxRentDuration;
        bool rentable;
        bytes4 dailyRentPrice;
        bytes4 nftPrice;
    }

    /**
     * All user's rentable NFT infos
     */
    struct UserLending {
        address lender;
        Lending[] lendings;
        bool exists; // flag to check key exists or not
    }

    /**
     * Single rented NFT info
     */
    struct Renting {
        address renter;
        uint8 rentDuration;
        uint256 rentedAt;
    }

    /**
     * All user's rented NFTs
     */
    struct UserRenting {
        address renter;
        Renting[] rentings;
        bool exists;
    }

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
            lenderAddress: msg.sender,
            nftToken: nftToken,
            nftTokenId: nftTokenId,
            maxRentDuration: maxRentDuration,
            dailyRentPrice: dailyRentPrice,
            nftPrice: nftPrice,
            rentable: true
        });

        // Add lending to user lending list
        UserLending memory userLending;
        if (userLendings[user].exists) {
            userLending = userLendings[user];
            userLendings[user].lendings.push(lending);
        } else {
            Lending[] memory emptydLendings;
            userLendings[user] = UserLending({
                lender: user,
                lendings: emptydLendings,
                exists: true
            });
        }
        // Need remove duplicates
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
    function getLending(address user)
        public
        view
        returns (Lending[] memory lendings)
    {
        if (userLendings[user].exists) {
            return userLendings[user].lendings;
        }
        return lendings;
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
        UserLending storage userLending;
        if (userLendings[user].exists) {
            userLending = userLendings[user];
            Lending[] storage lendings = userLending.lendings;
            Lending storage lending;
            for (uint256 i = 0; i <= lendings.length; i++) {
                lending = lendings[i];
                if (
                    lending.nftToken == nftToken &&
                    lending.nftTokenId == nftTokenId
                ) {
                    // Do rent
                    lending.rentable = false;
                    Renting memory renting;
                    renting = Renting({
                        renter: msg.sender,
                        rentDuration: rentDuration,
                        rentedAt: block.timestamp
                    });

                    UserRenting memory userRenting;
                    if (userRentings[user].exists) {
                        userRenting = userRentings[user];
                        userRentings[user].rentings.push(renting);
                    } else {
                        Renting[] memory emptydRenting;
                        userRentings[user] = UserRenting({
                            renter: user,
                            rentings: emptydRenting,
                            exists: true
                        });
                    }
                    success = true;
                }
            }
        }
        require(success, "Failed on rent");
    }

    /**
     * Get rented NFTs
     */
    function getRenting(address user)
        public
        view
        returns (Renting[] memory rentings)
    {
        if (userRentings[user].exists) {
            return userRentings[user].rentings;
        }
        return rentings;
    }

    /**
     * Change the feePermille
     */
    function setPermille(uint256 _feePermille) public onlyAdmin {
        feePermille = _feePermille;
    }
}
