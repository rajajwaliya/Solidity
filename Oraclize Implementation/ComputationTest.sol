pragma solidity ^0.4.25;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.25.sol";

contract ComputationTest is usingOraclize {

    event LogConstructorInitiated(string nextStep);
    event LogNewOraclizeQuery(string description);
    event LogNewResult(string result);

    function ComputationTest() payable {
        LogConstructorInitiated("Constructor was initiated. Call 'update()' to send the Oraclize Query.");
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) revert();
        LogNewResult(result);

    }

    function update() payable {
        LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("nested", "[computation] ['QmaqMYPnmSHEgoWRMP3WSrUYsPWKjT85C81PgJa2SXBs8u', 'Example of decrypted string', '${[decrypt] BOYnQstP700X10I+WWNUVVNZEmal+rZ0GD1CgcW5P5wUSFKr2QoIwHLvkHfQR5e4Bfakq0CIviJnjkfKFD+ZJzzxcaFUQITDZJxsRLtKuxvAuh6IccUJ+jDF/znTH+8x8EE1Tt9SY7RvqtVao2vxm4CxIWq1vk4=}', 'Hello there!']");
    }
}