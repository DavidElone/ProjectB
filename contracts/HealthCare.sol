// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract HealthCare is VRFConsumerBase, Ownable {
    using PriceConverter for uint256;

    enum CONTRACT_TYPE {
        SILVER, //50% of the bill
        GOLD, //75% of the bill
        PLATINIUM //95% of the bill
    }

    uint256 constant SilverPrice = 30;
    uint256 constant GoldPrice = 50;
    uint256 constant PlatiniumPrice = 60;

    uint256[] public clientsID;
    address payable[] public players;
    address payable public Winner;

    struct client {
        address accountAdress;
        CONTRACT_TYPE contractType;
        uint256 expirationDate;
        bool inLottery;
    }

    mapping(uint256 => client) public clients; //map id to client
    mapping(address => bool) public doctormapping;

    function storeclientData(
        uint256 id,
        CONTRACT_TYPE cntType,
        address accountAdr,
        uint256 expDate
    ) public {
        require(clients[id] == 0);
        clients[id].contractType = cntType;
        clients[id].accountAdress = accountAdr;
        clients[id].expirationDate = expDate;
        clients[id].inLottery = true;
    }

    function setDoctor(address _address) public onlySmartContractOwner {
        require(!doctormapping[_address]);
        doctormapping[_address] = true;
    }

    function subscribe(uint256 idEncrypted) public payable {
        CONTRACT_TYPE contractType;
        if (PriceConverter.getConversionRate(msg.value) == SilverPrice * 12)
            contractType = CONTRACT_TYPE.SILVER;
        else if (PriceConverter.getConversionRate(msg.value) == GoldPrice * 12)
            contractType = CONTRACT_TYPE.GOLD;
        else if (
            PriceConverter.getConversionRate(msg.value) == PlatiniumPrice * 12
        ) contractType = CONTRACT_TYPE.PLATINIUM;
        else revert();

        storeclientData(
            idEncrypted,
            contractType,
            msg.sender,
            block.timestamp + 365 days
        );
    }
}
