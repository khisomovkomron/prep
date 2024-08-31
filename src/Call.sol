// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {
    address otherContract;
    event Response(string response);

    constructor(address _otherContract) {
        otherContract = _otherContract;

    }

    // with call method you can send funcds to other contract from this contract if other contract has receive function
    function callReceive() external payable {
        (bool success, ) = otherContract.call{value: msg.value}("");
        require(success, "cant send fund");

    }

    /**
    * also you can send data to other contract if func have calldata argument. 
    There are two methods of sending data using call:
    1. call(abi.encodeWithSignature("funcName(dataType)", argument))
    2. call(abi.encodeWithSelector(ContractName.funcName.selector), argument)) -> you dont need to specify argument type
     */
    function callSetName(string calldata _name) external {
        (bool success, bytes memory response) = otherContract.call(
            // abi.encodeWithSignature("setName(string), _name);
            abi.encodeWithSelector(AnotherContract.setName.selector, _name)
        );

        require(success, "Cant sent name");

        emit Response(abi.decode(response, (string)));
    }
}

contract AnotherContract{
    string public name;
    mapping(address => uint) public balances;

    /**
    @note: function get data from other contract argument
     */
    function setName(string calldata _name) external returns(string memory){
        name = _name;
        return name;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
    }
}