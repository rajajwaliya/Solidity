 pragma solidity 0.4.25;
 
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        //assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
}

contract Owner{
   
    address public owner;
    
    constructor() public{
        owner=msg.sender;
    }
    modifier IsOwner() {
    require(owner==msg.sender);
    _;
  }
  
  
}

contract MyTocken is Owner{
    using SafeMath for uint256; 
   
    string public constant name = "My First Tocken";
    uint public constant decimal = 18;
    string public constant symbol = "Tocken";
    uint public constant finalsupply = 1000000000000000000;
    mapping (address => uint) public finaladdressof;
    mapping (address => mapping(address => uint)) public allowed;
   
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    constructor() public{
        finaladdressof[msg.sender]=finalsupply;
        
    }
    
     function totalSupply()public pure returns (uint theTotalSupply){
         theTotalSupply = finalsupply;
         return theTotalSupply;
     }
    
    function balanceOf(address _owner)public view returns (uint balance){
        return finaladdressof[_owner];
    }
    
    function transfer(address _to, uint _value) public returns (bool success){
        require(_value>0 && _value<=balanceOf(msg.sender));
        
        finaladdressof[msg.sender]=finaladdressof[msg.sender].sub(_value);
        finaladdressof[_to]=finaladdressof[_to].add(_value);
        return true;
    }
    
    
    function approve(address _spender, uint _value)public returns (bool success){
        // require(_value >=0); 
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
   
    }
    
    function transferFrom(address _from, address _to,uint256 _value)public returns (bool success){
     
       require(allowed[_from][msg.sender] > 0 
            && _value > 0 
            && allowed[_from][msg.sender] >= _value 
            && finaladdressof[_from] >= _value);
            finaladdressof[_from]=finaladdressof[_from].sub(_value);
            finaladdressof[_to]=finaladdressof[_to].add(_value);
            
            //  finaladdressof[_from] -= _value;
            //  finaladdressof[_to] += _value;
            // Missed from the video
            allowed[_from][msg.sender] -= _value;
            return true;
    }
    
     
   function allowance(address _owner, address _spender)public view returns (uint remaining){
       return allowed[_owner][_spender];
   }
}