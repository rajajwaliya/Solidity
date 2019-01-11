pragma solidity ^0.5.1;
//pragma experimental ABIEncoderV2;


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


contract Upgred {
    
    function transferByLegacy(address from, address to, uint value) public returns (bool success);
    function convertByLegacy(address to, uint value) public returns (bool success);
    function transferFromByLegacy(address spender, address from, address to, uint value) public returns (bool success);
    function approveByLegacy(address from, address spender, uint value) public returns (bool success);
    function balanceOf(address _owner)public view returns(uint balance);
    
}

contract FixedSupplyToken {
    
    using SafeMath for uint;
    address[] holder;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;
    address owner;

    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) balances;
    mapping(address => bool) temp;
    bool public depricated=false;
    
    Upgred upgred;
    event Transfer(address, address ,uint);
    event Approval(address,address,uint);


    constructor() public {
        owner=msg.sender;
        symbol = "FIXED";
        name = "Example Fixed Supply Token";
        decimals = 4;
        _totalSupply = 1000000 * 10**uint(decimals);
        balances[msg.sender] = _totalSupply;
        holder.push(msg.sender);
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    
    // function getHolder(uint index)public returns(address[] memory){
    //     return holder[index];
    // }
    
    function inserholder(address _holder) internal{
        if(balances[_holder]==0){
                holder.push(_holder);
            }
        }
    
    function UpgradContract(address payable _newcontract) public payable{
        upgred=Upgred(_newcontract);
        depricated=true;
    }

    function totalSupply() public view returns (uint) {
        if(depricated){
            revert();
        }
        else{
        return _totalSupply.sub(balances[address(0)]);
        }
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        if(depricated){
            return upgred.balanceOf(tokenOwner);
        }
        else{
            return balances[tokenOwner];
        }
    }

    function transfer(address _to, uint tokens) public returns (bool success) {
        
        
        
          if(depricated){
              upgred.transferByLegacy(msg.sender, _to, tokens);
        }
        
        else{
                balances[msg.sender] = balances[msg.sender].sub(tokens);
                balances[_to] = balances[_to].add(tokens);
                setHolder(_to);
                emit Transfer(msg.sender, _to, tokens);
                return true;
        }
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        
        if(depricated){
            upgred.approveByLegacy(msg.sender,spender,tokens);   
        }
        else{
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
        }
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        
        address(to);
        address(msg.sender);
        address(from);
        
        if(depricated){
            upgred.transferFromByLegacy(msg.sender,from,to,tokens);    
        }
        else{
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
        }
    }

        function getHolder() public view returns (address[] memory) {
            return holder;
        }
        
        function setHolder(address _holername) public{
                bool exixits=false;
                for(uint i=0;i<holder.length;i++){
                    if(_holername==holder[i]){
                        exixits=true;
                    }
                }
                if(exixits){}else{
                    holder.push(_holername);
                }
            }
        
        
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        if(depricated){
            revert();
        }
        else{
            return allowed[tokenOwner][spender];
        }
    }
    
    function convertToNewTockens() public returns (bool) {
        require(msg.sender==owner);
        uint amount=0;
        
        for(uint i=0; i<=holder.length;i++){
            amount = balances[holder[i]];
            upgred.convertByLegacy(holder[i],amount);
            balances[holder[i]]=0;
            return true;
        }
    }

    function () external payable {
        revert();
    }
    
}