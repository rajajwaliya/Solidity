pragma solidity ^0.5.1;

 /*
 * Contract that is working with ERC223 tokens
 */
 
  import "browser/erc223.sol";
 
  contract ContractReceiver {
     
     address payable owner;
     
     constructor() payable public{
         owner=msg.sender;
     }
     
   
         address public sender;
         uint public value;
         bytes public data;
        // address public addr = address(this);
   
    mapping(address=>uint256) public balanceOf;
    mapping(address=>uint256) public Deposite;
    
    function tokenFallback(address _from, uint _value, bytes memory _data) public {
   
    //that shows last transaction in contract
    sender = _from;
    value = _value;
    data = _data;
     
     balanceOf[address(this)] = balanceOf[address(this)] + _value;
     Deposite[sender] = Deposite[sender] + _value;
     
    }
    
    function sendTokensback (address tckaddress,address accaddress) public payable
    {   
        if(accaddress==msg.sender){
            require(balanceOf[address(this)]>0);
            require(Deposite[accaddress]>0);
        
        
        ERC223 erctcn = ERC223(tckaddress);
        balanceOf[address(this)] = balanceOf[address(this)] - Deposite[accaddress];
        uint amount = Deposite[accaddress];
        Deposite[accaddress]=0;
        erctcn.transfer(accaddress, amount);
       }
    }
 }