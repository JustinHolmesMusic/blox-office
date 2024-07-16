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
        ShowSet.Set({
            show: "1:1234",
            shape: 0,
            order: 0
        });
    }

    function testCommitSet() public {
        set_contract.commitSet("1:1234", 0, 0, 100, ["rabbit1", "rabbit2"]);
    }
}