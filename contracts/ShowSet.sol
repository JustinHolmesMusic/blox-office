pragma solidity ^0.8.0;

contract ShowSet {
    bytes32[] public show_ids;
    mapping(bytes32 => mapping(uint8 => Set)) public sets; // for each show we have a list of sets

    struct Set {
        uint8 shape; // 0 = diamond, 1 = triangle, 2 = circle etc.
        uint8 order; // 0 = first, 1 = second, 2 = third etc.
        bytes32[] rabbitHashes; // for each show we have a list of rabbit hashes
    }

    function addSet(
        uint16 artist_id,
        uint64 blockheight,
        uint8 shape,
        uint8 order,
        bytes32[] memory rabbitHashes) public {
        Set memory newSet = Set(shape, order, rabbitHashes);

        // Parse the show bytes into band ID and blockheight
        bytes32 showBytes =  bytes32(abi.encodePacked(artist_id,
            blockheight));

        show_ids.push(showBytes);
        sets[showBytes][newSet.order] = newSet;

    }

    function getSetForShow(uint16 artist_id, uint64 blockheight, uint8 order) public view returns (Set memory) {
        bytes32 showBytes = bytes32(abi.encodePacked(artist_id,
            blockheight));
        return sets[showBytes][order];
    }

    function getSetForShowByShowBytes(bytes32 showBytes, uint8 order) public view returns (Set memory) {
        return sets[showBytes][order];
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

}