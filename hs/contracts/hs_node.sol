pragma solidity ^0.4.23;
pragma experimental ABIEncoderV2; //so that I can pass structs around

contract hs_node {
    
    enum Direction { Out, In }
    enum Status { Unknown, Leader }
    
    struct Triple {
        uint id;
        Direction flag;
        uint hop_count;
    }
    
    uint u;
    Triple send_plus;
    Triple send_minus;
    Status status;
    uint phase;
    hs_node nextProcess;
    hs_node prevProcess;
    Triple fromPrev;
    Triple fromNext;
    
    constructor(uint _u) 
    public {
        u = _u;
        send_plus = Triple(u, Direction.Out, 1);
        send_minus = Triple(u, Direction.Out, 1);
        status = Status.Unknown;
        phase = 0;
    }
    
    function setNextProcess(address _next)
    public {
        nextProcess = hs_node(_next);
    }
    function getNextProcess()
    public view 
    returns(address) {
        return nextProcess;
    }
    
    function setPrevProcess(address _prev) 
    public {
        prevProcess = hs_node(_prev);
    }
    function getPrevProcess()
    public view 
    returns(address) {
        return prevProcess;
    }
    
    function getU()
    public view
    returns(uint) {
        return u;
    }
    
    function getStatus()
    public view
    returns(Status) {
        return status;
    }
    
    function getOutgoing_toNextProcess()
    public view
    returns(uint, Direction, uint) {
        return (send_plus.id, send_plus.flag, send_plus.hop_count);
    }
    
    function getOutgoing_toPrevProcess()
    public view
    returns(uint, Direction, uint) {
        return (send_minus.id, send_minus.flag, send_minus.hop_count);
    }
    
    function msgFunction()
    public {
        prevProcess.buffMessage(send_minus);
        nextProcess.buffMessage(send_plus);
    }
    
    function buffMessage(Triple _incoming) 
    public {
        if(msg.sender == address(prevProcess)) {
            fromPrev = _incoming;
        } else if(msg.sender == address(nextProcess)) {
            fromNext = _incoming;
        } else {
            require(false); //should have been from one of either prevProcess or nextProcess
        }
    }
    
    function trans()
    public {
        //handle outbound messages
        if(fromPrev.flag == Direction.Out){
            //from the previous node
            if(fromPrev.id > u && fromPrev.hop_count > 1) {
                send_plus = Triple(fromPrev.id, Direction.Out, --fromPrev.hop_count);
            } else if(fromPrev.id > u && fromPrev.hop_count == 1) {
                send_minus = Triple(fromPrev.id, Direction.In, 1);
            } else if(fromPrev.id == u) {
                status = Status.Leader;
            }
        }
        //and from the next node
        if(fromNext.flag == Direction.Out) {
            if(fromNext.id > u && fromNext.hop_count > 1) {
                send_minus = Triple(fromNext.id, Direction.Out, fromNext.hop_count - 1);
            } else if(fromNext.id > u && fromNext.hop_count == 1) {
                send_plus = Triple(fromNext.id, Direction.In, 1);
            } else if(fromNext.id == u) {
                status = Status.Leader;
            }
        }
        //pass along inbound messages
        if(fromPrev.flag == Direction.In && fromPrev.id != u) {
            send_plus = Triple(fromPrev.id, Direction.In, 1);
        }
        if(fromNext.flag == Direction.In && fromNext.id != u) {
            send_minus = Triple(fromNext.id, Direction.In, 1);
        }
        //advance dat phase when appropriate
        if(fromPrev.id == u && fromPrev.flag == Direction.In && fromPrev.hop_count ==1 && fromNext.id ==u && fromNext.flag == Direction.In && fromNext.hop_count ==1) {
            phase = phase + 1;
            send_plus = Triple(u, Direction.Out, 2^phase);
            send_minus = Triple(u, Direction.Out, 2^phase);
        }
    }
}
