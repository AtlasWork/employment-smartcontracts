pragma solidity ^0.4.7;

/* Author: Patrick Lismore @patricklismore */

// Basic Atlas Employment Contract  
contract AtlasBasicWork{
    /* Define variable owner of the type address*/
    address owner;
    
    /* Define jobidentifer of type string */
    string public jobidentifer;
    
    /* Define client address of type address */
    address public client;
    
    /* Define worker address of type address */
    address public worker;
    
    /* authorised address */
    address public authorised;
    
    /*  State of Smart Contract */
    enum State { Created, InProgress, InDispute, Delivered, NotRecieved, Complete, Inactive }
    
    /* State of contract status */
    State public state;
    
    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier onlyClient() {
        require(
            msg.sender == client,
            "Only client can call this."
        );
        _;
    }

    modifier onlyWorker() {
        require(
            msg.sender == worker,
            "Only worker can call this."
        );
        _;
    }

    modifier inState(State _state) {
        require(
            state == _state,
            "Invalid state."
        );
        _;
    }
    
    event Aborted();
    event JobConfirmed();
    event WorkReceived();
    event WordDelivered();
    event WordNotRecieved();
    
    /* Contract constructor for basic work smart contract */
    constructor(string jobId, address clientAddress, address workerAddress) payable{
        jobidentifer = jobId;
        client = clientAddress;
        worker = workerAddress;
        owner = msg.sender;
    }
    
    /// Abort the purchase and reclaim the WORK.
    /// Can only be called by the seller before
    /// the contract is locked.
    function abort() public onlyClient inState(State.Created)
    {
        emit Aborted();
        state = State.Inactive;
        client.transfer(this.balance);
    }
    
    /// Confirm the job as Worker
    /// The WORK will be locked until confirmWorkReceived
    /// is called.
    function confirmJob() public onlyWorker inState(State.Created) payable
    {
        emit JobConfirmed();
        state = State.InProgress;
    }
    
    /// Confirm that you (the Client) received the work commissioned.
    /// This will release the locked WORK.
    function confirmWorkDelivered() public onlyWorker inState(State.InProgress)
    {
        emit WordDelivered();
        state = State.Delivered;
    }

    /// Confirm that you (the Client) received the work commissioned.
    /// This will release the locked WORK.
    function confirmWorkReceived() public  onlyClient inState(State.Delivered) payable
    {
        emit WorkReceived();
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        state = State.Complete;

        //worker.transfer(value);
        worker.transfer(this.balance);
    }
    
    /* Function called by worker when job has been delivered awaiting client review  */
    function workNotRecieved() public onlyClient inState(State.InProgress)
    {
        emit WordNotRecieved();
        state = State.NotRecieved;
    }
    
    /* Returns the value of WORK locked in contract */
    function contractBalance() constant returns (uint256 amount){ return this.balance; }
    
     /* Function to recover the funds on the contract */
    function KillRecoverDispute() public { if (msg.sender == owner) selfdestruct(owner); }

}
