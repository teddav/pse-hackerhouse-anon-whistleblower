// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {Safe} from "safe-contracts/Safe.sol";
import {Enum} from "safe-contracts/common/Enum.sol";
import {SafeProxy} from "safe-contracts/proxies/SafeProxy.sol";
import {ModuleManager} from "safe-contracts/base/ModuleManager.sol";

import {ISemaphore} from "../src/ISemaphore.sol";
import {SemaphoreWhistleblowerModule} from "../src/SemaphoreWhistleblowerModule.sol";
import {DAOWhistleblower} from "../src/DAOWhistleblower.sol";

contract WhistleblowScript is Script {
    uint256[3] pks = [
        0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a,
        0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba,
        0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e
    ];

    ISemaphore semaphore;

    function setUp() public {
        // vm.createSelectFork("http://localhost:8545");
        vm.createSelectFork("sepolia");
        semaphore = ISemaphore(0x42C0e6780B60E18E44B3AB031B216B6360009baB);
    }

    function run() public {
        uint256 deployer = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployer);

        Safe safe = deployAndSetupSafe();

        DAOWhistleblower daoWhistleblower = new DAOWhistleblower();
        console.log("daoWhistleblower", address(daoWhistleblower));
        daoWhistleblower.addDAO(address(safe));

        SemaphoreWhistleblowerModule module = new SemaphoreWhistleblowerModule(
            address(safe),
            semaphore,
            address(daoWhistleblower)
        );

        bytes memory txData_enableModule = abi.encodeWithSelector(
            ModuleManager.enableModule.selector,
            address(module)
        );
        execTransaction(safe, address(safe), txData_enableModule);

        addMember(
            1772263923816844738218801185744046056658685953373862850595384902837154819354,
            module
        );
        addMember(
            18332492625122532256147860717901555793783137999081466661877342842509167197884,
            module
        );
        addMember(
            14666505891533126344042109479207383749941956403874345698933763060880398309605,
            module
        );

        ISemaphore.SemaphoreProof memory proof = ISemaphore.SemaphoreProof({
            merkleTreeDepth: 2,
            merkleTreeRoot: 9501249152673732179233955257213499012687906844097516139405623068204843435416,
            nullifier: 9582533315389292433808407312629026681536829446312722967027066035428001646761,
            message: 36332153287359289781742935609659520540924409436221419799390416009619027525632,
            scope: 9501249152673732179233955257213499012687906844097516139405623068204843435416,
            points: [
                13504106088367953781604963563987587027469856834046331228995898565276441900763,
                9538091058451839374362153704969367712163748232958884049601332080550122694057,
                6167619542225389860509212861680310789224732869891513874406801253401783784761,
                9389272477833690422541778824688297876871470823561265357883882576255407395953,
                16517544862146279754969066637696246251718610465695913626384999004310955340324,
                18173687589363579660610346411676345051420629554804083665064216237231472721500,
                14640749443004303952234141233225095527694183027407160130221847118343393882350,
                19524350354535312984668718375649007836982467466514816100906179912849875807124
            ]
        });
        module.whistleblow(
            proof,
            "QmeLXBWnjGqqMfutfoSxUp36iziahPf3HhZQLsyVaKwpZ4"
        );

        vm.stopBroadcast();
    }

    function addMember(
        uint256 commitment,
        SemaphoreWhistleblowerModule module
    ) internal {
        bytes memory data = abi.encode(commitment);
        bytes32 dataHash = keccak256(data);
        bytes memory signatures = getSignature(dataHash);

        module.addRemoveMember(
            SemaphoreWhistleblowerModule.MemberAction.AddMember,
            dataHash,
            data,
            signatures
        );
        require(semaphore.hasMember(module.groupId(), commitment));
    }

    function deployAndSetupSafe() internal returns (Safe) {
        address singleton = address(new Safe());
        Safe safe = Safe(payable(address(new SafeProxy(singleton))));

        address[] memory owners = new address[](3);
        owners[0] = vm.addr(pks[0]);
        owners[1] = vm.addr(pks[1]);
        owners[2] = vm.addr(pks[2]);

        safe.setup(
            owners,
            2,
            address(0),
            bytes(""),
            address(0),
            address(0),
            0,
            payable(address(0))
        );

        return safe;
    }

    function getSignature(bytes32 toSign) internal view returns (bytes memory) {
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(pks[0], toSign);
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(pks[1], toSign);
        bytes memory sig1 = abi.encodePacked(r1, s1, v1);
        bytes memory sig2 = abi.encodePacked(r2, s2, v2);
        bytes memory signatures = abi.encodePacked(sig1, sig2);
        return signatures;
    }

    function execTransaction(Safe safe, address to, bytes memory data) public {
        bytes32 toSign = safe.getTransactionHash(
            to,
            0,
            data,
            Enum.Operation(0),
            0,
            0,
            0,
            address(0),
            address(0),
            0
        );

        bytes memory signatures = getSignature(toSign);

        safe.execTransaction(
            to,
            0,
            data,
            Enum.Operation(0),
            0,
            0,
            0,
            address(0),
            payable(address(0)),
            signatures
        );
    }
}
