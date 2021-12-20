//  SPDX-License-Identifier: GPL-3.0;


pragma solidity ^0.8.4;

contract Escrow{
    // address of the escrow agent
    address agent;

    // gets your current position in queue
    // pls note your queue number. your queue number is queue - 1,
    //  i.e if you see queue 4, then your queue is 3. This is used to track your transaction
    uint queueCount;

    // mapping the deposits by 
    mapping(address=>Deposit[]) public deposits;

    // this is to keep track of the payer's position in the deposits queue
    mapping(address=>uint) public queue;
    

    // event
    event DeliveryComfirmed(address,uint);
    
    // sets the escrow agent to be the deployer of this contract
    constructor(){
    agent = msg.sender;
    }
    // this transfers the ether to the seller
    function transferPayment(address payable seller,address payer) public {

    // this requirement ensures only the agent can call this function
     require(msg.sender == agent);

        // gets the queue fo the payer/ buyer
       uint queue_ =  queue[payer];

    //    checks to comfirm that the delivery has been comfirmed
       require(deposits[payer][queue_].comfirmed);

    //    gets the amount stored in the payers log
        uint256 amount = deposits[payer][queue_].deposit;

        // this sets the payers deposit to 0 before transfer
        // this is done to prevent recall of this function
        deposits[payer][queue_].deposit = 0;

        // transfers the amount to the seller
        seller.transfer(amount);
        
    }

    // this is a brief info of the depositor

    struct Deposit{
        string firstName;
        string lastName;
        uint256 deposit;
        bool comfirmed;
    }

    // this is required to make deposits
    function deposit(string memory first,string memory second) payable public{
        // makes sure payment is made
        require( msg.value != 0);

        // increments the queue count
        queueCount++;

        // sets the sent amount
        uint amount = msg.value;

        // logs the payer into the database
        deposits[msg.sender].push(Deposit({
            firstName:first,
            lastName:second,
            deposit:amount,
            comfirmed:false}));

         // stores the payer's position in the array of deposit
        queue[msg.sender] = queueCount - 1;
    }

    // this is used to comfirm delivery by the buyer
    function comfirmDelivery() public {
        // gets the position of the function caller
       uint _queue = queue[msg.sender] ;

    //    sets the comfirm property to true;
        deposits[msg.sender][_queue].comfirmed = true;

        // notifies anyone subscribed to this function( eg the seller,the agent)
        emit DeliveryComfirmed(msg.sender,queue[msg.sender]);
    }
    
    
}


