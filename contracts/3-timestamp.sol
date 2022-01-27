// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/*
block.timestamp puede ser manipulado por mineros con las siguientes restricciones

- no se puede sellar con una hora anterior a su padre
- no puede estar muy lejos en el futuro

La ruleta es un juego en el que puedes ganar todo el Ether en el contrato.
si puede enviar una transacción en un momento específico.
Un jugador necesita enviar 10 Ether y gana si el block.timestamp % 15 == 0.
* /

/ *
1. Implemente la ruleta con 10 Ether
2. Eve ejecuta un poderoso minero que puede manipular la marca de tiempo del bloque.
3. Eve establece el block.timestamp en un número en el futuro que es divisible por
    15 y encuentra el hash del bloque de destino.
4. El bloque de Eve se incluye con éxito en la cadena, Eve gana el
    Juego de ruleta.
*/

contract Roulette {
    uint public pastBlockTime;

    constructor() payable {}

    function spin() external payable {
        require(msg.value == 10 ether); // must send 10 ether to play
        require(block.timestamp != pastBlockTime); // only 1 transaction per block

        pastBlockTime = block.timestamp;

        if (block.timestamp % 15 == 0) {
            (bool sent, ) = msg.sender.call{value: address(this).balance}("");
            require(sent, "Failed to send Ether");
        }
    }
}
