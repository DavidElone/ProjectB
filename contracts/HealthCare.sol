// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
// import "./PriceConverter.sol";
// import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract HealthCare is Ownable {
        // using PriceConverter for uint256;

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
        address payable accountAddress;
        CONTRACT_TYPE contractType;
        uint256 expirationDate;
        bool inLottery;
    }

    mapping(uint256 => client) public clients; //map id to client
    mapping(address => bool) public doctors;

    function addNewClient(
        uint256 id,
        CONTRACT_TYPE cntType,
        address payable accountAddr
    ) public {
        require(clients[id].accountAddress == address(0));
        clients[id].contractType = cntType;
        clients[id].accountAddress = accountAddr;
        clients[id].expirationDate = block.timestamp + 365 days;
        clientsID.push(id);
    }
    function extendClient(
        uint256 id,
        CONTRACT_TYPE cntType,
        address payable accountAddr
    ) public {
        require(clients[id].accountAddress == msg.sender && clients[id].contractType == cntType);
        if (block.timestamp < clients[id].expirationDate ){
            clients[id].expirationDate += 365 days;
        }else{
            clients[id].expirationDate += block.timestamp + 365 days;
        }
        
       
    }


    function setDoctor(address _address) public onlyOwner {
        require(!doctors[_address]);
        doctors[_address] = true;
    }

    function subscribe(uint256 idHashed) public payable {
        CONTRACT_TYPE contractType;
        if ((msg.value) == SilverPrice )
            contractType = CONTRACT_TYPE.SILVER;
        else if ((msg.value) == GoldPrice)
            contractType = CONTRACT_TYPE.GOLD;
        else if ((msg.value) == PlatiniumPrice) 
            contractType = CONTRACT_TYPE.PLATINIUM;
        else revert();
        if(clients[idHashed].accountAddress == address(0)){
            addNewClient(
                idHashed,
                contractType,
                payable(msg.sender)
            );
        }else if(clients[idHashed].accountAddress == (msg.sender)){
            extendClient(
                idHashed,
                contractType,
                payable(msg.sender)
            );
        }
    }
    function refundClient(uint256 idHashed , uint256 amount ) public payable{
        require(amount >0);
        require(clients[idHashed].accountAddress != address(0));
        clients[idHashed].accountAddress.
        (amount);
    }
    function report(uint256 idHashed ,uint amount , uint256 time ) public  {
        require(doctors[msg.sender]== true);
        require(amount >0);
        require(time < clients[idHashed].expirationDate );
        require(time <= block.timestamp );
        uint256 compensation = 0;
        if (clients[idHashed].contractType == CONTRACT_TYPE.SILVER)
            compensation = uint256(amount * 5 /10);
        else if (clients[idHashed].contractType == CONTRACT_TYPE.GOLD)
            compensation = uint256(amount * 3/4);
        else if (clients[idHashed].contractType == CONTRACT_TYPE.PLATINIUM)
            compensation = uint256(amount * 19/20);
        clients[idHashed].inLottery = false;
        refundClient(idHashed,compensation );

    }

}
