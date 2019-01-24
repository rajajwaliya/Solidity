pragma solidity ^0.4.11;
import "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.25.sol";

contract ExampleContract is usingOraclize {

    string public ETHUSD;
    mapping(bytes32=>bool) validIds;
    event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string price);
    event LogNewOraclizeQuery(string description);


    // This example requires funds to be send along with the contract deployment
    // transaction
    function ExampleContract() payable {
        oraclize_setCustomGasPrice(4000000000);
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Oraclize Query.");
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        if (!validIds[myid]) revert();
        if (msg.sender != oraclize_cbAddress()) revert();
        ETHUSD = result;
        LogPriceUpdated(result);
        delete validIds[myid];
        updatePrice();
    }

    function updatePrice() payable {
        if (oraclize_getPrice("URL") > this.balance) {
            LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            bytes32 queryId =
                oraclize_query(60, "URL", "json(https://api.pro.coinbase.com/products/ETH-USD/ticker).price", 500000);
            validIds[queryId] = true;
        }
    }
}