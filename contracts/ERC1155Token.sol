// contracts/ERC1155Token.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract ERC1155Token is ChainlinkClient, VRFConsumerBaseV2, ERC1155, Ownable {
    using Chainlink for Chainlink.Request;

    uint public mintFee = 0 wei; // Mintfee, 0 by default. only used in mint function, not batch.
    string public baseMetadataURI; // The token metadata URI
    string public name; // The token mame

    uint[] public boxIds; // uint array of boxIds
    string[] public boxNames; // string array of box names

    mapping(string => uint) public boxToId; // box name to id mapping
    mapping(uint => string) public idToBox; // id to box name mapping

    // Start: ====================== VRF Related Chainlink Variables ======================
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId = 2808;

    /** https://docs.chain.link/vrf/v2/subscription/supported-networks */
    /** Polygon (Matic) Mumbai testnet */
    address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    bytes32 keyHash =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    address link_token_contract = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

    event VRFRequestSent(uint256 requestId, uint32 numWords);
    event VRFRequestFulfilled(uint256 requestId, uint256[] randomWords);
    struct VRFRequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
        address account;
        uint _id;
        uint256 amount;
    }
    mapping(uint256 => VRFRequestStatus)
        public vrfRequests; /* requestId -> requestStatus */

    // Past requests Id.
    uint256[] public vrfRequestIds;
    uint256 public vrfLastRequestId;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 2500000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 2;

    // End: ====================== VRF Related Chainlink Variables ======================

    // Start: ====================== APIConsumer Related Chainlink Variables ======================
    uint256 public volume;
    bytes32 private jobId;
    uint256 private fee;

    event RequestVolume(bytes32 indexed requestId, uint256 volume);

    // End: ====================== APIConsumer Related Chainlink Variables ======================

    /*
    constructor is executed when the factory contract calls its own deployERC1155 method
    */
    constructor(
        string memory _contractName,
        string memory _uri,
        string[] memory _boxes,
        uint[] memory _ids
    ) ERC1155(_uri) VRFConsumerBaseV2(vrfCoordinator) {
        // ====================== APIConsumer Chainlink ======================
        /** Polygon (Matic) Mumbai testnet data */
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0x40193c8518BB267228Fc409a613bDbD8eC5a97b3);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = 10 ** 16; // 0.01 LINK

        // ====================== VRF Chainlink ======================
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);

        setURI(_uri);
        name = _contractName;
        baseMetadataURI = _uri;

        boxNames = _boxes;
        boxIds = _ids;
        createMapping();

        transferOwnership(tx.origin);
    }

    /*
    creates a mapping of strings to boxIds (i.e ["one","two"], [1,2] - "one" maps to 1, vice versa.)
    */
    function createMapping() private {
        for (uint id = 0; id < boxIds.length; id++) {
            boxToId[boxNames[id]] = boxIds[id];
            idToBox[boxIds[id]] = boxNames[id];
        }
    }

    /*
    sets our URI and makes the ERC1155 OpenSea compatible
    */
    function uri(
        uint256 _tokenid
    ) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    baseMetadataURI,
                    Strings.toString(_tokenid),
                    ".json"
                )
            );
    }

    function getBoxes() public view returns (string[] memory) {
        return boxNames;
    }

    /*
    used to change metadata, only owner access
    */
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    /*
    set a mint fee. only used for mint, not batch.
    */
    function setFee(uint _fee) public onlyOwner {
        mintFee = _fee;
    }

    function requestMint(
        address account,
        uint _id,
        uint256 amount
    ) public onlyOwner returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        vrfRequests[requestId] = VRFRequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            account: account,
            _id: _id,
            amount: amount
        });
        vrfRequestIds.push(requestId);
        vrfLastRequestId = requestId;
        emit VRFRequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(vrfRequests[_requestId].exists, "request not found");

        vrfRequests[_requestId].fulfilled = true;
        vrfRequests[_requestId].randomWords = _randomWords;
        emit VRFRequestFulfilled(_requestId, _randomWords);

        _mint(
            vrfRequests[_requestId].account,
            vrfRequests[_requestId]._id,
            vrfRequests[_requestId].amount,
            ""
        );
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestAssignedAmoutOfBoxes() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // Set the URL to perform the GET request on
        req.add(
            "get",
            "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD"
        );

        // Set the path to find the desired data in the API response, where the response format is:
        // {"RAW":
        //   {"ETH":
        //    {"USD":
        //     {
        //      "VOLUME24HOUR": xxx.xxx,
        //     }
        //    }
        //   }
        //  }
        // request.add("path", "RAW.ETH.USD.VOLUME24HOUR"); // Chainlink nodes prior to 1.0.0 support this format
        req.add("path", "RAW,ETH,USD,VOLUME24HOUR"); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 10 ** 18;
        req.addInt("times", timesAmount);

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(
        bytes32 _requestId,
        uint256 _volume
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestVolume(_requestId, _volume);
        volume = _volume;
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
