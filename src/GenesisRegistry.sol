// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract GenesisRegistry {
    struct Gateway {
        address creator;
        bytes32 manifestHash;
        uint256 createdAt;
        bool exists;
    }

    bytes32 public immutable genesisId;
    bytes32 public protocolManifestHash;

    uint256 public gatewayCount;

    mapping(uint256 => Gateway) public gateways;

    event GatewayRegistered(
        uint256 indexed gatewayId,
        address indexed creator,
        bytes32 manifestHash
    );

    event ProtocolManifestUpdated(
        bytes32 indexed previousHash,
        bytes32 indexed newHash
    );

    error InvalidManifestHash();
    error GatewayDoesNotExist();

    constructor(bytes32 initialManifestHash) {
        if (initialManifestHash == bytes32(0)) {
            revert InvalidManifestHash();
        }

        genesisId = keccak256(
            abi.encodePacked("ALVEARIUM_GENESIS_V1")
        );

        protocolManifestHash = initialManifestHash;
    }

    function registerGateway(
        bytes32 manifestHash
    ) external returns (uint256 gatewayId) {
        if (manifestHash == bytes32(0)) {
            revert InvalidManifestHash();
        }

        gatewayId = ++gatewayCount;

        gateways[gatewayId] = Gateway({
            creator: msg.sender,
            manifestHash: manifestHash,
            createdAt: block.timestamp,
            exists: true
        });

        emit GatewayRegistered(
            gatewayId,
            msg.sender,
            manifestHash
        );
    }

    function getGateway(
        uint256 gatewayId
    ) external view returns (Gateway memory) {
        if (!gateways[gatewayId].exists) {
            revert GatewayDoesNotExist();
        }

        return gateways[gatewayId];
    }
}
