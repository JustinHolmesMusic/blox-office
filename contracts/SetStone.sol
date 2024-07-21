// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./ILiveSet.sol";

contract SetStone is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {


    struct Stone {
        bytes32 showBytes;
        uint8 order;
        uint16 color; // color
        string crystalization; // personal message
        uint256 paidAmountWei;
        bytes32 rabbitHash;
    }

    uint256 public numberOfStonesMinted;

    mapping(bytes32 => Stone[]) public stonesBySetId;
    mapping(uint256 => Stone) public stonesByTokenId;

    mapping(bytes32 => bytes32[]) public rabbitHashesByShow;
    mapping(bytes32 => uint16) public stonesPossiblePerShow;
    mapping(bytes32 => uint8) public numberOfSetsInShow;
    mapping(bytes32 => uint8[]) public setShapes;
    mapping(bytes32 => uint256) public stonePriceByShow; // Someday, 0 might mean "auction" or "free" or "donation" or "not for sale"

    string public baseURI;

    constructor(address initialOwner, string memory base_uri) ERC721("SetStone", "STONE") Ownable(initialOwner) {
        numberOfStonesMinted = 0;
        baseURI = base_uri;
    }

    function getShowData(uint16 artist_id, uint64 blockheight) public view returns (bytes32, uint16, uint8, uint256) {
        bytes32 showBytes = bytes32(abi.encodePacked(artist_id, blockheight));
        return (showBytes, stonesPossiblePerShow[showBytes], numberOfSetsInShow[showBytes], stonePriceByShow[showBytes]);
    }

    function makeShowAvailableForStoneMinting(uint16 artist_id,
        uint64 blockheight,
        bytes32[] memory rabbitHashes,
        uint8 numberOfSets,
        uint8[] memory shapes,
        uint256 stonePrice) public {

        // Check that number of sets match length of shapes array.
        require(numberOfSets == shapes.length, "Number of sets must match length of shapes array");


        // Authorized by artistID?
        bytes32 showBytes = bytes32(abi.encodePacked(artist_id,
            blockheight));
        rabbitHashesByShow[showBytes] = rabbitHashes;
        stonesPossiblePerShow[showBytes] = uint16(rabbitHashes.length);

        numberOfSetsInShow[showBytes] = numberOfSets;
        setShapes[showBytes] = shapes;
        stonePriceByShow[showBytes] = stonePrice;
    }

    function getRabbitHashesForShow(uint16 artist_id, uint64 blockheight) public view returns (bytes32[] memory) {
        bytes32 showBytes = bytes32(abi.encodePacked(artist_id,
            blockheight));
        return rabbitHashesByShow[showBytes];
    }

    function isValidRabbit(
        bytes32 rabbitHash,
        bytes32 showBytes
    ) public view returns (bool) {
        bytes32[] memory rabbitHashes = rabbitHashesByShow[showBytes];
        for (uint i = 0; i < rabbitHashes.length; i++) {
            if (rabbitHashes[i] == rabbitHash) {
                return true;
            }
        }
        return false;
    }

    function _burnRabbitHash(bytes32 showBytes, bytes32 rabbitHash) internal {
        bytes32[] memory rabbitHashes = rabbitHashesByShow[showBytes];
        for (uint i = 0; i < rabbitHashes.length; i++) {
            if (rabbitHashes[i] == rabbitHash) {
                rabbitHashesByShow[showBytes][i] = rabbitHashes[rabbitHashes.length - 1];
                rabbitHashesByShow[showBytes].pop();
                break;
            }
        }
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
        bytes32 showBytes = bytes32(abi.encodePacked(artistId, blockHeight));

        // check that the set exists and that the order is valid
        require(numberOfSetsInShow[showBytes] > order, "Set does not exist");

        // check that the payed amount is greater or equal to the stone price for the given set
        require(msg.value >= stonePriceByShow[showBytes], "Paid too little ETH for a setstone");
        // check that the secretRabbit is a valid secret for a given set
        bytes32 rabbitHash = keccak256(abi.encodePacked(_rabbit_secret));
        require(
            isValidRabbit(rabbitHash, showBytes),
            "Invalid secret rabbit"
        );

        // --- Color checks ---
        // The color must be less than the number of all mintable stones
        require(_color < stonesPossiblePerShow[showBytes], "The color must not be greater than the number of all mintable stones");

        bytes32 setId = getSetId(artistId, blockHeight, order);
        // The color must not be already taken for the given set
        // Iterate through all the setStones and check the color
        Stone[] memory stonesForSet = stonesBySetId[setId];
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
                paidAmountWei: msg.value,
                rabbitHash: rabbitHash
            })
        );

        stonesByTokenId[numberOfStonesMinted] = stonesBySetId[setId][stonesBySetId[setId].length - 1];

        // compute the tokenURI
        // string memory tokenURI = string.concat(baseURI, "/", Strings.toString(numberOfStonesMinted));
        string memory token_uri = string.concat(
            Strings.toString(artistId), "/",
            Strings.toString(blockHeight), "/",
            Strings.toString(order), "/",
            Strings.toString(_color)
        );

        // mint the stone
        _mint(to, numberOfStonesMinted);
        _setTokenURI(numberOfStonesMinted, token_uri);
        _burnRabbitHash(showBytes, rabbitHash);
        numberOfStonesMinted += 1;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // ------
    // The following functions are overrides required by Solidity, because we are inheriting from multiple ERC721 implementations
    // ------
    function _increaseBalance(address to, uint128 value) internal override (ERC721Enumerable, ERC721) {
        super._increaseBalance(to, value);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721URIStorage, ERC721) returns (string memory) {
        return super.tokenURI(tokenId);
    }


    function _update(address to, uint256 tokenId, address auth) internal override (ERC721Enumerable, ERC721) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC721URIStorage) returns (bool) {
    // TODO: shouldn't we somehow combine the implementations from both ERC721Enumerable and ERC721URIStorage?
    // as I understand it, super.supportsInterface(interfaceId) will select only one implementation
    // so the supported interface will be either that of ERC721Enumerable or ERC721URIStorage
    // but not both at the same time
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view override (ERC721) returns (string memory) {
        return baseURI;
    }
}