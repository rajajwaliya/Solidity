pragma solidity 0.4.25;

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
contract erc20 is Owned{
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
        symbol = "MFT";
        name = "My First Token";
        decimals  = 18;
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
    
    
     function increaseApproval(address spender, uint256 value) public returns (bool success)
    {   if(allowed[msg.sender][spender]<=0) revert("first aprove the spender");
        allowed[msg.sender][spender] = allowed[msg.sender][spender] + value;
        emit Approval(msg.sender,spender,value);
        return true;
    }
    
     function decreaseApproval(address spender, uint256 value) public returns (bool success)
    {
        if(allowed[msg.sender][spender]<=0) revert("first aprove the spender");
        if(allowed[msg.sender][spender] - value < 0) revert("not have sufficent balance");
        allowed[msg.sender][spender] = allowed[msg.sender][spender] - value;
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
   
}


contract erc827 is erc20{

 function approveAndCall(
    address _spender,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool)
  {
    require(_spender != address(this));

    super.approve(_spender, _value);

    // solium-disable-next-line security/no-call-value
    require(_spender.call.value(msg.value)(_data));

    return true;
  }

  /**
   * @dev Addition to ERC20 token methods. Transfer tokens to a specified
   * address and execute a call with the sent data on the same transaction
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   * @param _data ABI-encoded contract call to call `_to` address.
   * @return true if the call function was executed successfully
   */
  function transferAndCall(
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool)
  {
    require(_to != address(this));

    super.transfer(_to, _value);

    // solium-disable-next-line security/no-call-value
    require(_to.call.value(msg.value)(_data));
    return true;
  }

  /**
   * @dev Addition to ERC20 token methods. Transfer tokens from one address to
   * another and make a contract call on the same transaction
   * @param _from The address which you want to send tokens from
   * @param _to The address which you want to transfer to
   * @param _value The amout of tokens to be transferred
   * @param _data ABI-encoded contract call to call `_to` address.
   * @return true if the call function was executed successfully
   */
  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    public payable returns (bool)
  {
    require(_to != address(this));

    super.transferFrom(_from, _to, _value);

    // solium-disable-next-line security/no-call-value
    require(_to.call.value(msg.value)(_data));
    return true;
  }

 
 /**
   * @dev Addition to StandardToken methods. Increase the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function increaseApprovalAndCall(
    address _spender,
    uint _addedValue,
    bytes _data
  )
    public
    payable
    returns (bool)
  {
    require(_spender != address(this));

    super.increaseApproval(_spender, _addedValue);

    // solium-disable-next-line security/no-call-value
    require(_spender.call.value(msg.value)(_data));

    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Decrease the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function decreaseApprovalAndCall(
    address _spender,
    uint _subtractedValue,
    bytes _data
  )
    public
    payable
    returns (bool)
  {
    require(_spender != address(this));

    super.decreaseApproval(_spender, _subtractedValue);

    // solium-disable-next-line security/no-call-value
    require(_spender.call.value(msg.value)(_data));

    return true;
  }

}