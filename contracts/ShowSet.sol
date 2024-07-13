pragma solidity ^0.8.0;

contract ShowSet {

    mapping (uint32 => Set[]) public sets; // for each show we have a list of sets

    struct Set {
        uint32 show; // blockheight of the show
        uint8 shape; // 0 = square, 1 = triangle, 2 = circle etc. 
        uint8 order; // 0 = first, 1 = second, 2 = third etc.
        bytes32[] rabbitHashes; // for each show we have a list of rabbit hashes
    }
    
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function commitSet(
        uint32 _show,
        uint8 _shape,
        uint8 _order,
        bytes32[] memory _rabbitHashes
    ) public onlyOwner {

        Set memory newSet = Set({
            show: _show,
            shape: _shape,
            order: _order,
            rabbitHashes: _rabbitHashes
        });

        sets[_show].push(newSet);
    }


}