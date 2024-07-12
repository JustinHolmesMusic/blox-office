// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SetStone is ERC721, Ownable, ERC721Enumerable {
    uint256 public totalSupply;

    struct Stone {
        uint32 set; // mainnet block height of the time of the show
        uint16 color; // color
        string crystalization; // personal message
    }
    
    // TODO: Add a method commitSet, which will accept the set mainnet block height and array of 16 

    Stone[] public stones;

    // Mapping from set_id to a boolean array representing available colors
    // TODO: what are the default values for the boolean array?
    mapping(uint32 => bool[16]) public setColors;


    constructor() ERC721("SetStone", "STONE") {}

    function mintStone(
        address to,
        uint32 _set,
        uint16 _color,
        string memory _crystalization,
        string memory _sticket
    ) external payable {
        // check that _set is a valid set
        // check that the payed amount is greater or equal to the stone price for the given set
        // check that the secretRabbit is a valid secret for a given set
        // check that the _color is a valid color and isn't yet taken for the given set

        // create the stone by adding it to the stones array
        // set the color for the given set to true
        // mint the stone

        stones.push(Stone({
            set: _set,
            color: _color,
            crystalization: _crystalization
        }));

        setColors[_mainnetBlockHeight][_color] = true;

        uint256 tokenId = stones.length - 1;
        _mint(to, tokenId);
        totalSupply++;

    }

    function getStone(uint256 tokenId) public view returns (Stone memory) {
        require(_exists(tokenId), "Token does not exist");
        return stones[tokenId];
    }
}