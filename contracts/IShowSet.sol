interface IShowSet {
    struct Set {
        uint8 shape; // 0 = diamond, 1 = triangle, 2 = circle etc.
        uint8 order; // 0 = first, 1 = second, 2 = third etc.
        bytes32[] rabbitHashes; // for each show we have a list of rabbit hashes
    }

    function getSetForShow(uint16 artist_id, uint64 blockheight, uint8 order) external view returns (Set memory);
    function getShowIds() external view returns (bytes32[] memory);

}