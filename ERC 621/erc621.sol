pragma solidity 0.5.1;

library SafeMathlib {
    // function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    //     if (a == 0) {
    //         return 0;
    //     }
    //     uint256 c = a * b;
    //     assert(c / a == b);
    //     return c;
    // }

    // function div(uint256 a, uint256 b) internal pure returns (uint256) {
    //     // assert(b > 0); // Solidity automatically throws when dividing by 0
    //     uint256 c = a / b;
    //     // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    //     return c;
    // }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Owned {
    address public owner;
    // address public newOwner;
    // event OwnershipTransferred(address indexed from, address indexed to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // function transferOwnership(address _newOwner) public onlyOwner {
    //     newOwner = _newOwner;
    // }
    // function acceptOwnership() public {
    //     require(msg.sender == newOwner);
    //     emit OwnershipTransferred(owner, newOwner);
    //     owner = newOwner;
    //     newOwner = address(0);
    // }
}



//Dont use Token keyword while creating the contract otherwise exception will be thrown
contract ERC621 is Owned{
    using  SafeMathlib for uint256;
    
    string public  symbol;
    string public  name;
    uint256 public  decimals;
    uint256 public  totalsupply;
    address public owner;
    mapping (address => uint) public __balanceof;    
    mapping (address => mapping (address => uint256)) public allowed;
    
    event Approval(address indexed owner, address indexed spender, uint _value);
    event Transfer(address indexed from, address indexed to, uint _value);
    
    constructor() public {
        symbol = "erc621";
        name = "My First Token";
        decimals  = 0;
        totalsupply = 10000000000000000000; 
        __balanceof[msg.sender] = totalsupply; 
        owner = msg.sender;
    }
    
    function totalSupply() public view returns (uint256){
        uint256 _totalsupply;
        _totalsupply = totalsupply;
        return _totalsupply;
    }
    
    function balanceOf(address _owner)public view returns (uint256 balance){
      require(_owner == msg.sender);
        return __balanceof[_owner];
    }
    
    function transfer(address to, uint value) public returns(bool success){
        require(value > 0 && value <= balanceOf(msg.sender));
        __balanceof[msg.sender] = __balanceof[msg.sender].sub(value);
         __balanceof[to] = __balanceof[to].add(value);
         return true;
    }
    
     function approve(address spender, uint256 value) public returns (bool success)
    {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender,spender,value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 _value) public returns (bool success){
        require (allowed[from][msg.sender] > 0 
            && _value > 0 
            && allowed[from][msg.sender] >= _value && __balanceof[from] >= _value );
            __balanceof[from] = __balanceof[from].sub(_value);
            __balanceof[to] = __balanceof[to].add(_value);
            allowed[from][msg.sender] =allowed[from][msg.sender].sub(_value);
            return true;
    }
    function allowance(address _owner, address spender) public view returns (uint256 remaining)
    {
        return allowed[_owner][spender];
    }
    
    
    function increaseSupply(uint value) onlyOwner public returns (bool)  {
    totalsupply = totalsupply.add(value);
    __balanceof[owner] = __balanceof[owner].add( value);
    return true;
}


    function decreaseSupply(uint value) onlyOwner public returns (bool)  {
    totalsupply = totalsupply.sub(value);
    __balanceof[owner] = __balanceof[owner].sub( value);
    return true;
}
   
}
