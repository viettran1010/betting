// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './IERC20.sol';
import './IERC1155.sol';
import './IConditionalTokens.sol';

contract Betting {
    IERC20 dai;
    IConditionalTokens conditionalTokens;
    address public oracle;
    mapping(bytes32 => mapping(uint => uint)) public tokenBalance;
    address admin;

    constructor(
        address _dai,
        address _conditionalTokens,
        address _oracle
    ) {
        dai = IERC20(_dai);
        conditionalTokens = IConditionalTokens(_conditionalTokens);
        oracle = _oracle;
        admin = msg.sender;
    }

    function createBet(bytes32 questionId, uint amount) external {
        conditionalTokens.prepareCondition(
            oracle,
            questionId,
            3 // number of outcomes, eg. win/lose/tie
        );

        bytes32 conditionId = conditionalTokens.getConditionId(
            oracle,
            questionId,
            3 // number of outcomes, eg. win/lose/tie
        );

        // A, B, C
        // A, B | C: the second token represents B or C happens

        // B: 010 binary
        // C: 100 binary
        // B|C: 010+100=110 binary => [1,3] for A, B | C

        uint[] memory partition = new uint[](2);
        partition[0] = 1;
        partition[1] = 3;

        dai.approve(address(conditionalTokens), amount);
        conditionalTokens.splitPostion(
            dai,
            bytes32(0),
            conditionId,
            partition,
            amount
        );

        tokenBalance[questionId][0] = amount;
        tokenBalance[questionId][1] = amount;
    }

    function transferTokens(
        bytes32 questionId,
        uint indexSet,
        address to,
        uint amount
    ) external {
        require(msg.sender == admin, 'only admin');
        require(tokenBalance[questionId][indexSet] >= amount, 'not enough tokens');

        bytes32 conditionId = conditionalTokens.getConditionId(
            oracle,
            questionId,
            3
        );

        bytes32 collectionId = conditionalTokens.getCollectionId(
            bytes32(0),
            conditionId,
            indexSet
        );

        uint positionId = conditionalTokens.getPositionId(
            dai,
            collectionId
        );

        conditionalTokens.safeTransferFrom(
            address(this),
            to, // need to implement ERC1155TokenReceiver
            positionId,
            amount,
            ""
        );
    }

    function onERC1155Received(
        // address operator,
        // address from,
        // uint256 id,
        // uint256 value,
        // bytes calldata data
    ) external pure returns (bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        // address operator,
        // address from,
        // uint256[] calldata ids,
        // uint256[] calldata values,
        // bytes calldata data
    ) external pure returns (bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

}