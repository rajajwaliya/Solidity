pragma solidity ^0.4.25;
import "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.25.sol";

contract temperature is usingOraclize {

    string public ETHXBT;
    //uint constant CUSTOM_GASLIMIT = 150000;

    event LogConstructorInitiated(string nextStep);
    event newOraclizeQuery(string description);
    event newKrakenPriceTicker(string price);


    constructor() public{
       // oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        emit LogConstructorInitiated("Constructor was initiated. Call 'update()' to send the Oraclize Query.");
    }

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        ETHXBT = result;
        emit newKrakenPriceTicker(ETHXBT);
    }

    function update() payable public {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("WolframAlpha", "geogravity in Ahmedabad");
        }
        //geogravity in Ahmedabad
    }
    
}