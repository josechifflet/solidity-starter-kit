// contracts/ERC1155Token.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract ERC1155Token is VRFConsumerBaseV2, ERC1155, Ownable {
    uint[] public ids; // uint array of ids
    string[] public boxes; // string array of boxes

    mapping(string => uint) public boxToId; // box to id mapping
    mapping(uint => string) public idToBox; // id to box mapping

    uint public mintFee = 0 wei; // mintfee, 0 by default. only used in mint function, not batch.

    string public baseMetadataURI; // the token metadata URI
    string public name; // the token mame

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId = 2808;
    address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    bytes32 keyHash =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    address link_token_contract = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
        address account;
        uint _id;
        uint256 amount;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 200000000000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 2;

    /*
    constructor is executed when the factory contract calls its own deployERC1155 method
    */
    constructor(
        string memory _contractName,
        string memory _uri,
        string[] memory _boxes,
        uint[] memory _ids
    ) ERC1155(_uri) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);

        boxes = _boxes;
        ids = _ids;
        createMapping();
        setURI(_uri);
        baseMetadataURI = _uri;
        name = _contractName;
        transferOwnership(tx.origin);
    }

    /*
    creates a mapping of strings to ids (i.e ["one","two"], [1,2] - "one" maps to 1, vice versa.)
    */
    function createMapping() private {
        for (uint id = 0; id < ids.length; id++) {
            boxToId[boxes[id]] = ids[id];
            idToBox[ids[id]] = boxes[id];
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
        return boxes;
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
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            account: account,
            _id: _id,
            amount: amount
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");

        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);

        _mint(
            s_requests[_requestId].account,
            s_requests[_requestId]._id,
            s_requests[_requestId].amount,
            ""
        );
    }
}
