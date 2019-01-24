pragma solidity ^0.4.25;
import "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.25.sol";

contract Calculation is usingOraclize {

    string NUMBER_1 = "33";
    string NUMBER_2 = "9";
    string MULTIPLIER = "5";
    string DIVISOR = "2";

    event LogNewOraclizeQuery(string description);
    event calculationResult(uint _result);

    // General Calculation: ((NUMBER_1 + NUMBER_2) * MULTIPLIER) / DIVISOR

    function Calculation() {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS); 
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        require (msg.sender == oraclize_cbAddress());
        calculationResult(parseInt(result));
    }

    function testCalculation() payable {
        sendCalculationQuery(NUMBER_1, NUMBER_2, MULTIPLIER, DIVISOR); // = 105
    }

    function sendCalculationQuery(string _NUMBER1, string _NUMBER2, string _MULTIPLIER, string _DIVISOR) payable {
        if (oraclize.getPrice("computation") > this.balance) {
            LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("computation",["QmZRjkL4U72XFXTY8MVcchpZciHAwnTem51AApSj6Z2byR", 
            _NUMBER1, 
            _NUMBER2, 
            _MULTIPLIER, 
            _DIVISOR]);
        }
    }
}