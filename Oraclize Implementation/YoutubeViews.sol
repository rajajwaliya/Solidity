pragma solidity ^0.4.25;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.25.sol";

contract YoutubeViews is usingOraclize {

    string public viewsCount;

    event LogYoutubeViewCount(string views);
    event LogNewOraclizeQuery(string description);

    constructor() public {
        update(); // Update views on contract creation...
    }

    function __callback(bytes32 myid, string memory result) public {
        require(msg.sender == oraclize_cbAddress());
        viewsCount = result;
        emit LogYoutubeViewCount(viewsCount);
        // Do something with viewsCount, like tipping the author if viewsCount > X?
    }

    function update() public payable {
        emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
        //RQ4QVQ-U3LPL2YGPR
        oraclize_query("URL","http://api.wolframalpha.com/v2/query?appid=RQ4QVQ-U3LPL2YGPR&input=france&format=image,imagema");
    }
}