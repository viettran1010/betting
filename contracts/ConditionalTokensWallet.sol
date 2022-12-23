// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './IERC20.sol';
import './IERC1155.sol';
import './IConditionalTokens.sol';

contract ConditionalTokensWallet is IERC1155Receiver {
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

    function redeemTokens(
        bytes32 conditionId,
        uint[] calldata indexSets
    ) external {
        conditionalTokens.redeemPositions(
            dai,
            bytes32(0),
            conditionId,
            indexSets
        );
    }

    function transferDai(address to, uint amount) external {
        require(msg.sender == admin, 'only admin');
        dai.transfer(to, amount);
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked(
            operator,
            from,
            ids,
            values,
            data
        )));
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked(
            operator,
            from,
            id,
            value,
            data
        )));
    }

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        bytes4[2] memory supportedInterfaces = [
            bytes4(keccak256("onERC1155Received()")),
            bytes4(keccak256("onERC1155BatchReceived()"))
        ];

        for (uint i = 0; i < supportedInterfaces.length; i++) {
            if (interfaceId == supportedInterfaces[i]) {
                return true;
            }
        }

        return false;
    }
}