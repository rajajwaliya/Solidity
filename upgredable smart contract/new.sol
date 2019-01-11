pragma solidity ^0.5.1;


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

contract Upgred{
     function transferByLegacy(address from, address to, uint value) public returns (bool success);
    function transferFromByLegacy(address spender, address from, address to, uint value) public returns (bool success);
    function approveByLegacy(address from, address spender, uint value) public returns (bool success);
    function convertByLegacy(address to, uint value) public returns (bool success);
    function balanceOf(address _owner)public view returns(uint balance);
}


contract Token is Upgred{
    
    using SafeMath for uint;

   
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;
    event Transfer(address, address, uint,string);
    event Approval(address,address,uint,string);

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    address owner;


    constructor() public {
        
        name = "new";
        owner=msg.sender;
        decimals=4;
        _totalSupply=1000000 * 10**uint(decimals);
        balances[msg.sender]=_totalSupply;
        symbol="new";
      //  emit Transfer(address(0), msg.sender, _totalSupply);
    
    }


    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    function transferByLegacy(address from, address to, uint value) public returns (bool success) {
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(from, to, value,"contract new's transfer()");
        return true;
    }


    function approveByLegacy(address from, address spender, uint value) public returns (bool success) {
        allowed[from][spender] = value;
        emit Approval(from, spender, value,"contract new's approve()");
        return true;
    }


    function transferFromByLegacy(address spender,address from, address to, uint tokens) public returns (bool success) {
        
        balances[from] = balances[from].sub(tokens);
        allowed[from][spender] = allowed[from][spender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens,"contract new's transferFrom()");
        return true;
        
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function () external payable {
        revert();
    }
    
    function convertByLegacy(address to, uint value) public returns (bool success){
        balances[owner] = balances[owner].sub(value);
        balances[to] = balances[to].add(value);
        return true;
    }

}