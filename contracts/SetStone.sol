// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract SetStone is ERC721Enumerable {
    struct Stone {
        bytes16 set; // "n:h:s", where n is the ID of the act, h is the blockheight at the beginning of the show, and s is the set number
        uint16 color; // color
        string crystalization; // personal message
    }
    
    // TODO: Add a method commitSet, which will accept the set mainnet block height and array of 16 

    Stone[] public stones;

    // Mapping from set_id to a boolean array representing available colors
    // TODO: what are the default values for the boolean array?
    mapping(bytes16 => bool[16]) public setColors;

    constructor() ERC721("SetStone", "STONE") {}

    function mintStone(
        address to,
        bytes16 set_id,
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
            set: set_id,
            color: _color,
            crystalization: _crystalization
        }));

        setColors[set_id][_color] = true;

        uint256 tokenId = stones.length - 1;
        _mint(to, tokenId);
        totalSupply++;

    }
}