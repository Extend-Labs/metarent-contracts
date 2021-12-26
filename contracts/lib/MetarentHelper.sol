// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MetarentHelper {
    function checkZeroAddr(address _addr) internal pure {
        require(_addr != address(0), "Metarent::zero address");
    }
}
