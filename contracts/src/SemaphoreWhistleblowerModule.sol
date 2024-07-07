// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {ISemaphore} from "./ISemaphore.sol";
import {Enum} from "safe-contracts/common/Enum.sol";
import {DAOWhistleblower} from "./DAOWhistleblower.sol";

interface GnosisSafe {
    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) external returns (bool success);

    function checkSignatures(
        bytes32 dataHash,
        bytes memory data,
        bytes memory signatures
    ) external view;
}

contract SemaphoreWhistleblowerModule {
    enum MemberAction {
        AddMember,
        RemoveMember
    }

    GnosisSafe public safe;
    ISemaphore public semaphore;
    uint256 public groupId;
    DAOWhistleblower public whistleblower;

    constructor(address _safe, ISemaphore _semaphore, address _whistleblower) {
        safe = GnosisSafe(_safe);
        semaphore = _semaphore;
        groupId = semaphore.createGroup();
        whistleblower = DAOWhistleblower(_whistleblower);
    }

    function execAnyTx(address to, uint256 value, bytes memory data) internal {
        safe.execTransactionFromModule(to, value, data, Enum.Operation.Call);
    }

    function whistleblow(
        ISemaphore.SemaphoreProof calldata proof,
        string calldata ipfsHash
    ) public {
        semaphore.validateProof(groupId, proof);

        bytes memory data = abi.encodeWithSelector(
            DAOWhistleblower.whistleblow.selector,
            ipfsHash
        );
        execAnyTx(address(whistleblower), 0, data);
    }

    function addRemoveMember(
        MemberAction action,
        bytes32 dataHash,
        bytes memory data,
        bytes memory signatures
    ) external {
        safe.checkSignatures(dataHash, data, signatures);

        if (action == MemberAction.AddMember) {
            uint256 identityCommitment = abi.decode(data, (uint256));
            semaphore.addMember(groupId, identityCommitment);
        } else if (action == MemberAction.RemoveMember) {
            (
                uint256 identityCommitment,
                uint256[] memory merkleProofSiblings
            ) = abi.decode(data, (uint256, uint256[]));

            semaphore.removeMember(
                groupId,
                identityCommitment,
                merkleProofSiblings
            );
        }
    }
}
