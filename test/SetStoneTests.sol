// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
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
            blockheight: blockheight + 1,
            shape: 2,
            order: 0,
            rabbitHashes: rabbitHashes3,
            stonePriceWei: 1 ether
        });

        // Show2, second set
        bytes32[] memory rabbitHashes4 = new bytes32[](2);
        rabbitHashes4[0] = keccak256(abi.encodePacked("rabbit7"));
        rabbitHashes4[1] = keccak256(abi.encodePacked("rabbit8"));

        liveSet.addSet({
            artist_id: artist_id,
            blockheight: blockheight + 1,
            shape: 3,
            order: 1,
            rabbitHashes: rabbitHashes4,
            stonePriceWei: 1 ether
        });
    }

    function test_mint_stones() public {
        uint16 artistId = 0;
        uint64 blockHeight = 420;
        uint8 order = 0;

        vm.deal(address(this), 10 ether);

        // mint 2 stones for the same set
        stone_contract.mintStone{value: 0.5 ether}(
            address(this),
            artistId,
            blockHeight,
            order,
            0, // color
            "crystalized", // crystalization text
            "rabbit1" // rabbit secret
        );

        stone_contract.mintStone{value: 1 ether}(
            address(this),
            artistId,
            blockHeight,
            order,
            1, // color
            "crystalized stone 2",
            "rabbit2"
        );

        // check that the stone has been minted
        // check that the balance of the address is 1.5 ether
        assertEq(address(stone_contract).balance, 1.5 ether);

        // check that the stone has the correct attributes
        SetStone.Stone[] memory stones = stone_contract.getStonesBySetId(
            artistId,
            blockHeight,
            order
        );

        assertEq(stones.length, 2);
        assertEq(
            stones[0].showBytes,
            bytes32(abi.encodePacked(artistId, blockHeight))
        );
        assertEq(stones[0].order, order);
        assertEq(stones[0].color, 0);
        assertEq(stones[0].crystalization, "crystalized");
        assertEq(stones[0].paidAmountWei, 0.5 ether);

        assertEq(
            stones[1].showBytes,
            bytes32(abi.encodePacked(artistId, blockHeight))
        );
        assertEq(stones[1].order, order);
        assertEq(stones[1].color, 1);
        assertEq(stones[1].crystalization, "crystalized stone 2");
        assertEq(stones[1].paidAmountWei, 1 ether);

        // check that the NFT has been properly minted
        assertEq(stone_contract.ownerOf(0), address(this));
        assertEq(stone_contract.ownerOf(1), address(this));

        assertEq(stone_contract.balanceOf(address(this)), 2);
        assertEq(stone_contract.tokenOfOwnerByIndex(address(this), 0), 0);
        assertEq(stone_contract.tokenOfOwnerByIndex(address(this), 1), 1);

        SetStone.Stone memory stoneToken0 = stone_contract.getStoneByTokenId(0);
        SetStone.Stone memory stoneToken1 = stone_contract.getStoneByTokenId(1);

        assertEq(stoneToken0.showBytes, bytes32(abi.encodePacked(artistId, blockHeight)));
        assertEq(stoneToken1.showBytes, bytes32(abi.encodePacked(artistId, blockHeight)));
        assertEq(stoneToken0.order, order);
        assertEq(stoneToken1.order, order);
        assertEq(stoneToken0.color, 0);
        assertEq(stoneToken1.color, 1);

        // check that Stone with non-existing tokenId is an uninitialized Stone struct
        SetStone.Stone memory emptyStone = stone_contract.getStoneByTokenId(2);
        assertEq(emptyStone.showBytes, 0);
        assertEq(emptyStone.order, 0);
        assertEq(emptyStone.color, 0);
        assertEq(emptyStone.crystalization, "");
        assertEq(emptyStone.paidAmountWei, 0);

        // mint one more stone for the second set
        stone_contract.mintStone{value: 1 ether}(
            address(this),
            artistId,
            blockHeight,
            1, // order
            0, // color
            "crystalized", // crystalization text
            "rabbit3" // rabbit secret
        );

        // mint stone for the second show
        stone_contract.mintStone{value: 1 ether}(
            address(this),
            artistId,
            blockHeight + 1,
            0, // order
            0, // color
            "crystalized", // crystalization text
            "rabbit5" // rabbit secret
        );

        assertEq(stone_contract.numberOfStonesMinted(), 4);
        assertEq(stone_contract.balanceOf(address(this)), 4);
    }


    function test_mint_stone_invalid_rabbit() public {
        // check that the minting reverts when given invalid secret rabbit
        vm.expectRevert("Invalid secret rabbit");
        stone_contract.mintStone{value: 1 ether}(
            address(this),
            0,
            420,
            0, // order
            0, // color
            "crystalized", // crystalization text
            "invalid_rabbit" // invalid rabbit secret
        );

        assertEq(stone_contract.numberOfStonesMinted(), 0);
    }



}
