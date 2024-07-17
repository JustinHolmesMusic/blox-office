// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/SetStone.sol";
import "../contracts/LiveSet.sol";

contract SetStoneTests is Test {
    SetStone stone_contract;

    function setUp() public {
        // instantiate the live set contract with 2 shows, 2 sets each
        // than point the stone contract to it

        // first deploy the setlist contract
        LiveSet liveSet = new LiveSet();
        stone_contract = new SetStone(address(liveSet));

        // let's add some test data to the setlist contract

        // Show1, first set
        bytes32[] memory rabbitHashes = new bytes32[](2);
        rabbitHashes[0] = keccak256(abi.encodePacked("rabbit1"));
        rabbitHashes[1] = keccak256(abi.encodePacked("rabbit2"));

        uint16 artist_id = 0;
        uint64 blockheight = 420;

        liveSet.addSet({
            artist_id: artist_id,
            blockheight: blockheight,
            shape: 0,
            order: 0,
            rabbitHashes: rabbitHashes,
            stonePriceWei: 0.5 ether
        });

        // Show1, second set
        bytes32[] memory rabbitHashes2 = new bytes32[](2);
        rabbitHashes2[0] = keccak256(abi.encodePacked("rabbit3"));
        rabbitHashes2[1] = keccak256(abi.encodePacked("rabbit4"));

        liveSet.addSet({
            artist_id: artist_id,
            blockheight: blockheight,
            shape: 1,
            order: 1,
            rabbitHashes: rabbitHashes2,
            stonePriceWei: 0.5 ether
        });


        // Show2, first set
        bytes32[] memory rabbitHashes3 = new bytes32[](2);
        rabbitHashes3[0] = keccak256(abi.encodePacked("rabbit5"));
        rabbitHashes3[1] = keccak256(abi.encodePacked("rabbit6"));

        liveSet.addSet({
            artist_id: artist_id,
            blockheight: blockheight+1,
            shape: 2,
            order: 0,
            rabbitHashes: rabbitHashes3,
            stonePriceWei: 1 ether
        });

        // Show2, first set
        bytes32[] memory rabbitHashes4 = new bytes32[](2);
        rabbitHashes4[0] = keccak256(abi.encodePacked("rabbit5"));
        rabbitHashes4[1] = keccak256(abi.encodePacked("rabbit6"));

        liveSet.addSet({
            artist_id: artist_id,
            blockheight: blockheight+1,
            shape: 3,
            order: 1,
            rabbitHashes: rabbitHashes4,
            stonePriceWei: 1 ether
        });
    }

    function test_nop() public {
        assertTrue(true);
    }

    function test_mint_stone() public {
       uint16 artistId = 0;
       uint64 blockHeight = 420;
       uint8 order = 0;
       uint16 color = 0;
       string memory crystalization = "crystalized";
       string memory rabbit_secret = "rabbit_secret";


    // TODO
    //    stone_contract.mintStone(
    //        //  address to
    //        address(this),
    //        // uint16 artistId,
    //    )
    }
}