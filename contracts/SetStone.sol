// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./ILiveSet.sol";

contract SetStone is ERC721Enumerable {
    struct Stone {
        bytes32 showBytes;
        uint8 order;
        uint16 color; // color
        string crystalization; // personal message
        uint256 paidAmountWei;
    }

    uint256 public numberOfStonesMinted;

    mapping(bytes32 => Stone[]) public stonesBySetId;
    mapping(uint256 => Stone) public stonesByTokenId;


    ILiveSet public liveSet;

    // Mapping from set_id to a boolean array representing available colors
    // TODO: what are the default values for the boolean array?

    constructor(address liveSetAddress) ERC721("SetStone", "STONE") {
        liveSet = ILiveSet(liveSetAddress);
        numberOfStonesMinted = 0;
    }

    function isValidRabbit(
        bytes32 rabbitHash,
        bytes32[] memory rabbitHashes
    ) public pure returns (bool) {
        for (uint i = 0; i < rabbitHashes.length; i++) {
            if (rabbitHashes[i] == rabbitHash) {
                return true;
            }
        }
        return false;
    }

    function getSetId(uint16 artistId, uint64 blockHeight, uint8 order) public pure returns (bytes32) {
        return bytes32(abi.encodePacked(artistId, blockHeight, order));
    }

    function getStonesBySetId(bytes32 setId) public view returns (Stone[] memory) {
        return stonesBySetId[setId];
    }

    function getStonesBySetId(uint16 artistId, uint64 blockHeight, uint8 order) public view returns (Stone[] memory) {
        return stonesBySetId[getSetId(artistId, blockHeight, order)];
    }

    function getStoneByTokenId(uint256 tokenId) public view returns (Stone memory) {
        return stonesByTokenId[tokenId];
    }


    function mintStone(
        address to,
        uint16 artistId,
        uint64 blockHeight,
        uint8 order,
        uint16 _color,
        string memory _crystalization,
        string memory _rabbit_secret
    ) external payable {
        // check that the set exists
        bytes32 showBytes = bytes32(abi.encodePacked(artistId, blockHeight));
        require(liveSet.isValidSet(showBytes, order), "Set does not exist");

        // check that the payed amount is greater or equal to the stone price for the given set
        ILiveSet.Set memory set = liveSet.getSetForShow(artistId, blockHeight, order);

        require(msg.value >= set.stonePriceWei, "Not enough ETH");

        // check that the secretRabbit is a valid secret for a given set
        bytes32 rabbitHash = keccak256(abi.encodePacked(_rabbit_secret));
        require(
            isValidRabbit(rabbitHash, set.rabbitHashes),
            "Invalid secret rabbit"
        );

        // check that the _color is a valid color and isn't yet taken for the given set

        bytes32 setId = getSetId(artistId, blockHeight, order);

        Stone[] memory stonesForSet = stonesBySetId[getSetId(artistId, blockHeight, order)];

        // The color must be less than the number of all mintable stones
        require(_color < set.rabbitHashes.length, "The color must not be greater than the number of all mintable stones");

        // The color must not be already taken for the given set
        // Iterate through all the setStones and check the color
        for (uint i = 0; i < stonesForSet.length; i++) {
            require(stonesForSet[i].color != _color, "Color already taken for this set");
        }

        // create the stone by adding it to the stones array
        stonesBySetId[setId].push(
            Stone({
                showBytes: showBytes,
                order: order,
                color: _color,
                crystalization: _crystalization,
                paidAmountWei: msg.value
            })
        );

        stonesByTokenId[numberOfStonesMinted] = stonesBySetId[setId][stonesBySetId[setId].length - 1];

        // mint the stone
        _mint(to, numberOfStonesMinted);
        numberOfStonesMinted += 1;
    }
}
