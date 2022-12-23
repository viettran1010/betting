// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './IERC20.sol';
import './IERC1155.sol';

abstract contract IConditionalTokens is IERC165 {
    function prepareCondition(address oracle, bytes32 questionId, uint outcome) external virtual;

    function reportPayouts(bytes32 questionId, uint[] calldata payouts) external virtual;

    function splitPostion(
        IERC20 collateralToken,
        bytes32 parentCollectionId,
        bytes32 conditionId,
        uint[] calldata partition,
        uint amount
    ) external virtual;

    function mergePositions(
        IERC20 collateralToken,
        bytes32 parentCollectionId,
        bytes32 conditionId,
        uint[] calldata partition,
        uint amount
    ) external virtual;

    function redeemPositions(
        IERC20 collateralToken,
        bytes32 parentCollectionId,
        bytes32 conditionId,
        uint[] calldata indexSets
    ) external virtual;

    function getOutcomeSlotCount(
        bytes32 conditionId
    ) external virtual view returns (uint);

    function getConditionId(
        address oracle,
        bytes32 questionId,
        uint getOutcomeSlotCount
    ) external virtual pure returns (bytes32);

    function getCollectionId(
        bytes32 parentCollectionId,
        bytes32 conditionId,
        uint indexSet
    ) external virtual view returns (bytes32);

    function getPositionId(
        IERC20 collateralToken,
        bytes32 collectionId
    ) external virtual pure returns (uint);
}