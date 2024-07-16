// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/ShowSet.sol";

contract SetTest is Test {
    ShowSet set_contract;

    function setUp() public {
        set_contract = new ShowSet();
    }

    function testMakeSet() public {
        bytes32[] memory rabbitHashes = new bytes32[](2);
        rabbitHashes[0] = keccak256(abi.encodePacked("rabbit1"));
        rabbitHashes[1] = keccak256(abi.encodePacked("rabbit2"));

        set_contract.addSet({
            artist_id: 0,
            blockheight: 420,
            shape: 0,
            order: 0,
            rabbitHashes: rabbitHashes
        });
    }

//    function testCommitSet() public {
    // This will take a struct as an argument; implement then.
//        set_contract.commitSet("1:1234", 0, 0, 100, ["rabbit1", "rabbit2"]);
//    }
}