// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {GenesisRegistry} from "../src/GenesisRegistry.sol";

contract GenesisRegistryTest is Test {
    GenesisRegistry registry;

    bytes32 initialManifest = keccak256("genesis-manifest-v1");
    bytes32 gatewayManifest = keccak256("gateway-manifest-v1");

    address creator = address(0x1234);
    address stranger = address(0x5678);

    function setUp() public {
        registry = new GenesisRegistry(initialManifest);
    }

    function testGenesisIdentifier() public view {
        bytes32 expected = keccak256(
            abi.encodePacked("ALVEARIUM_GENESIS_V1")
        );

        assertEq(registry.genesisId(), expected);
    }

    function testInitialManifestStored() public view {
        assertEq(registry.protocolManifestHash(), initialManifest);
    }

    function testAnyoneCanRegisterGateway() public {
        vm.prank(stranger);

        uint256 gatewayId = registry.registerGateway(gatewayManifest);

        assertEq(gatewayId, 1);
        assertEq(registry.gatewayCount(), 1);
    }

    function testCreatorAndManifestRecorded() public {
        vm.prank(creator);

        uint256 gatewayId = registry.registerGateway(gatewayManifest);

        GenesisRegistry.Gateway memory gateway =
            registry.getGateway(gatewayId);

        assertEq(gateway.creator, creator);
        assertEq(gateway.manifestHash, gatewayManifest);
        assertEq(gateway.createdAt, block.timestamp);
        assertTrue(gateway.exists);
    }

    function testMultipleGatewaysReceiveUniqueIds() public {
        vm.prank(creator);
        uint256 first = registry.registerGateway(gatewayManifest);

        vm.prank(stranger);
        uint256 second = registry.registerGateway(
            keccak256("second-gateway")
        );

        assertEq(first, 1);
        assertEq(second, 2);
        assertEq(registry.gatewayCount(), 2);
    }

    function testRejectZeroGatewayManifest() public {
        vm.expectRevert(GenesisRegistry.InvalidManifestHash.selector);

        registry.registerGateway(bytes32(0));
    }

    function testRejectZeroInitialManifest() public {
        vm.expectRevert(GenesisRegistry.InvalidManifestHash.selector);

        new GenesisRegistry(bytes32(0));
    }

    function testRejectUnknownGateway() public {
        vm.expectRevert(GenesisRegistry.GatewayDoesNotExist.selector);

        registry.getGateway(999);
    }
}
