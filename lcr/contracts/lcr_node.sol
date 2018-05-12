pragma solidity ^0.4.23;

contract lcr_node {
    uint u;
    uint send;
    Status status;
    
    lcr_node private nextProcess;
    
    enum Status { unknown, leader }
    
    event Sent(address indexed _from, address indexed _to, uint val);
    
    event LeaderElected(address indexed _leader);
    
    constructor (uint _u)
    public {
        u = _u;
        send = u;
        status = Status.unknown;
    }
    
    function setNextProcess(address _next) 
    public {
        nextProcess = lcr_node(_next);
    }
    
    function getNextProcess()
    public
    view
    returns (address) {
        return nextProcess;
    }
    
    function msgFunction() 
    public {
        nextProcess.trans(send);
        emit Sent(this, nextProcess, send);
    }
    
    function trans(uint _incoming)
    public {
        //The book says to set send := null here, but because I can't kick off all the processes
        //at once, that won't work for me. Sending the UID of this node repeatedly
        //shouldn't matter, though...
        if (_incoming > u) {
            send = _incoming;
        } if (_incoming == u) {
            status = Status.leader;
            emit LeaderElected(this);
        }
    }
    
    function previewSend()
    public
    view
    returns(uint){
        return send;
    }
    
    function getU() 
    public
    view
    returns(uint){
        return u;
    }
    
    function isLeader()
    public
    view
    returns(bool) {
        if(status == Status.leader) return true;
        else return false;
    }
}