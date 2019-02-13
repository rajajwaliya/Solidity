pragma solidity ^0.5.3;

/// @notice Standard interface for `RegulatorService`s
contract RegulatorService {
  function check(address _token, address _spender, address _from, address _to, uint256 _amount) public returns (uint8);
}

contract ERC20Detailed{
    function decimals() public view returns (uint8);
}

// contract TestRegulatorService is RegulatorService  {
//   uint8 constant private SUCCESS = 0;  /* 0 <= AMOUNT < 10 */
//   uint8 constant private ELOCKED = 1;  /* 10 <= AMOUNT < 20 */
//   uint8 constant private EDIVIS = 2;   /* 20 <= AMOUNT < 30 */
//   uint8 constant private ESEND = 3;    /* 30 <= AMOUNT < 40 */
//   uint8 constant private ERECV = 4;    /* 40 <= AMOUNT < 50 */
   
// function check(address _token, address _spender, address _from, address _to, uint256 _amount) public returns (uint8) {
//     if (_amount >= 10 && _amount < 20) return ELOCKED;
    
//     else if (_amount >= 20 && _amount < 30) return EDIVIS;
    
//     else if (_amount >= 30 && _amount < 40) return ESEND;
    
//     else if (_amount >= 40 && _amount < 50) return ERECV;
    
//     return SUCCESS;
//   }
// }

contract Ownable { 
    address public owner;
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }

}

contract TokenRegulatorService is RegulatorService, Ownable {
  /**
  * @dev Throws if called by any account other than the admin
  */
  modifier onlyAdmins() {
    require(msg.sender == admin || msg.sender == owner);
    _;
  }

struct Settings {
    bool locked;
    bool partialTransfers;
}

  // @dev Check success code
  uint8 constant private CHECK_SUCCESS = 0;

  // @dev Check error reason: Token is locked
  uint8 constant private CHECK_ELOCKED = 1;

  // @dev Check error reason: Token can not trade partial amounts.
  uint8 constant private CHECK_EDIVIS = 2;

  // @dev Check error reason: Sender is not allowed to send the token
  uint8 constant private CHECK_ESEND = 3;

  // @dev Check error reason: Receiver is not allowed to receive the token
  uint8 constant private CHECK_ERECV = 4;

  /// @dev Permission bits for allowing a participant to send tokens
  uint8 constant private PERM_SEND = 0x1;

  /// @dev Permission bits for allowing a participant to receive tokens
  uint8 constant private PERM_RECEIVE = 0x2;

  // @dev Address of the administrator
  address public admin;

  /// @notice Permissions that allow/disallow token trades on a per token level
  mapping(address => Settings) public settings;

  mapping(address => mapping(address => uint8)) public participants;

  /// @dev Event raised when a token's locked setting is set
  event LogLockSet(address indexed token, bool locked);

  /// @dev Event raised when a token's partial transfer setting is set
  event LogPartialTransferSet(address indexed token, bool enabled);

  /// @dev Event raised when a participant permissions are set for a token
  event LogPermissionSet(address indexed token, address indexed participant, uint8 permission);

  /// @dev Event raised when the admin address changes
  event LogTransferAdmin(address indexed oldAdmin, address indexed newAdmin);

  constructor() public {
    admin = msg.sender;
  }
  
  function setLocked(address _token, bool _locked) onlyOwner public {
    settings[_token].locked = _locked;

    emit LogLockSet(_token, _locked);
  }


  function setPartialTransfers(address _token, bool _enabled) onlyOwner public {
  settings[_token].partialTransfers = _enabled;
  emit LogPartialTransferSet(_token, _enabled);
  }

  function setPermission(address _token, address _participant, uint8 _permission) onlyAdmins public {
    participants[_token][_participant] = _permission;
    emit LogPermissionSet(_token, _participant, _permission);
  }

  /**
  * @dev Allows the owner to transfer admin controls to newAdmin.
  *
  * @param newAdmin The address to transfer admin rights to.
  */
  function transferAdmin(address newAdmin) onlyOwner public {
    require(newAdmin != address(0));

    address oldAdmin = admin;
    admin = newAdmin;
    emit LogTransferAdmin(oldAdmin, newAdmin);
  }

  function check(address _token, address _spender, address _from, address _to, uint256 _amount) public returns (uint8) {
    if (settings[_token].locked) {
      return CHECK_ELOCKED;
    }

    if (participants[_token][_from] & PERM_SEND == 0) {
      return CHECK_ESEND;
    }

    if (participants[_token][_to] & PERM_RECEIVE == 0) {
      return CHECK_ERECV;
    }

    if (!settings[_token].partialTransfers && _amount % _wholeToken(_token) != 0) {
      return CHECK_EDIVIS;
    }
    return CHECK_SUCCESS;
  }

  function _wholeToken(address _token) view public returns (uint256) {
    return uint256(10)**ERC20Detailed(_token).decimals();
  }
}