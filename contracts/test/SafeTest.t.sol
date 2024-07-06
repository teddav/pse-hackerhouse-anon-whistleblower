// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {console} from "forge-std/Test.sol";
import {Safe} from "safe-contracts/Safe.sol";
import {ModuleManager} from "safe-contracts/base/ModuleManager.sol";

import {Counter} from "../src/Counter.sol";
import {SafeBasicModule} from "../src/SafeBasicModule.sol";
import {TestUtils} from "./utils.sol";

contract SafeTest is TestUtils {
    function test_Deploy() public {
        Safe safe = deployAndSetupSafe();
        assertEq(safe.nonce(), 0);
    }

    function test_ExecuteTx() public {
        Safe safe = deployAndSetupSafe();

        Counter counter = new Counter(address(safe));
        assertEq(counter.number(), 0);
        assertEq(safe.nonce(), 0);

        vm.expectRevert("not admin");
        counter.setNumber(1);

        bytes memory txData = abi.encodeWithSelector(
            Counter.setNumber.selector,
            456
        );
        execTransaction(safe, address(counter), txData);

        assertEq(counter.number(), 456);
        assertEq(safe.nonce(), 1);
    }

    function test_ExecTxFromModule() public {
        Safe safe = deployAndSetupSafe();
        SafeBasicModule module = new SafeBasicModule(address(safe));

        bytes memory txData_enableModule = abi.encodeWithSelector(
            ModuleManager.enableModule.selector,
            address(module)
        );
        execTransaction(safe, address(safe), txData_enableModule);

        Counter counter = new Counter(address(safe));
        assertEq(counter.number(), 0);

        bytes memory txData_execModuleTx = abi.encodeWithSelector(
            Counter.setNumber.selector,
            1234
        );
        module.execAnyTx(address(counter), 0, txData_execModuleTx);

        assertEq(counter.number(), 1234);
    }
}
