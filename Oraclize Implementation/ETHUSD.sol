pragma solidity ^0.4.25;
import "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.25.sol";

contract ExampleContract is usingOraclize {

    string public ETHUSD;
    event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string price);
    event LogNewOraclizeQuery(string description);

    constructor() public payable {
       emit LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Oraclize Query.");
    }

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        ETHUSD = result;
        emit LogPriceUpdated(result);
        updatePrice();
    }

    function updatePrice() public payable {
        if (oraclize_getPrice("URL") > this.balance) {
            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query(60, "URL", "json(https://api.pro.coinbase.com/products/ETH-USD/ticker).price");
        }
    }
}