pragma solidity ^0.4.25;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.25.sol";

contract DieselPrice is usingOraclize {

    uint public dieselPriceUSD;

    event LogNewDieselPrice(string price);
    event LogNewOraclizeQuery(string description);

    constructor() public {
        update(); // First check at contract creation...
    }

    function __callback(bytes32 myid, string memory result) public {
        require(msg.sender == oraclize_cbAddress());
        emit LogNewDieselPrice(result);
        dieselPriceUSD = parseInt(result, 2); // Let's save it as cents...
        // Now do something with the USD Diesel price...
    }

    function update() public payable {
        emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
        oraclize_query("URL", "xml(https://www.fueleconomy.gov/ws/rest/fuelprices).fuelPrices.diesel");
    }
}