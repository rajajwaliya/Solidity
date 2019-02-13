pragma solidity ^0.5.3;

contract Ownable {
    address public owner;

    /**
      * @dev The Ownable constructor sets the original `owner` of the contract to the sender
      * account.
      */
    constructor() public {
        owner = msg.sender;
    }

    /**
      * @dev Throws if called by any account other than the owner.
      */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

/// @notice A service that points to a `RegulatorService`
contract ServiceRegistry is Ownable {
  address public service;

  /**
   * @notice Triggered when service address is replaced
   */
  event ReplaceService(address oldService, address newService);

  /**
   * @dev Validate contract address
   * Credit: https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol#L107-L114
   *
   * @param _addr The address of a smart contract
   */
  modifier withContract(address _addr) {
    uint length;
    assembly { length := extcodesize(_addr) }
    require(length > 0);
    _;
  }

 /**
 * @notice Constructor
 * @param _service The address of the `RegulatorService`
 */
  constructor(address _service) public {
    service = _service;
  }

/**
* @notice Replaces the address pointer to the `RegulatorService`
*
* @dev This method is only callable by the contract's owner
*
* @param _service The address of the new `RegulatorService`
*/
  function replaceService(address _service) onlyOwner withContract(_service) public {
    address oldService = service;
    service = _service;
    emit ReplaceService(oldService, service);
  }
}