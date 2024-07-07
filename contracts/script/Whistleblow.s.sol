// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";

import {ISemaphore} from "../src/ISemaphore.sol";
import {SemaphoreWhistleblowerModule} from "../src/SemaphoreWhistleblowerModule.sol";

contract WhistleblowScript is Script {
    function setUp() public {
        // vm.createSelectFork("http://localhost:8545");
        vm.createSelectFork("sepolia");
    }

    function run() public {
        uint256 deployer = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployer);

        SemaphoreWhistleblowerModule module = SemaphoreWhistleblowerModule(
            0xdF4d6e156455f5967Dde74C33659B63DA4cB62Ea
        );

        ISemaphore.SemaphoreProof memory proof = ISemaphore.SemaphoreProof({
            merkleTreeDepth: 2,
            merkleTreeRoot: 9501249152673732179233955257213499012687906844097516139405623068204843435416,
            nullifier: 3697091674211810098304635734291057149926324081124682295159498484342028454885,
            message: 52647538822861451339668260516226392407866590175225915665138305263444888125440,
            scope: 52647538822861451339668260516226392407866590175225915665138305263444888125440,
            points: [
                5713711413823743279229845867046185416144621799369725536539225201732839643284,
                21535815789209056222158339997641565481116631584383640428196687393483812160902,
                12430824295460674808736218069181125484545031328477546268342564443998585107822,
                13921497434505179605037189142374951018795642557783876983961634077855921435324,
                14459317271151145971243260821544466699309096919938534342009172862761637059192,
                4991682956391446790521944795374700289032286015403351567207528514024119577416,
                17937517733404008969902459324159643415518616785688905778205960945060925107502,
                15917538276372187316960593607447082271322639619333943042746545847303935607700
            ]
        });
        module.whistleblow(
            proof,
            "QmdfGEw7tvYeuL8MpANCkm2HbqrcJ1foKWRV511ftaaV4s"
        );

        vm.stopBroadcast();
    }
}
