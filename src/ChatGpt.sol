// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IOracle.sol";

struct Message {
    string role;
    string content;
}

struct ChatRun {
    address owner;
    Message[] messages;
    uint messagesCount;
}

contract ChatGpt {
    address private owner;
    address public oracleAddress;

    // コンストラクタの統合
    constructor(address initialOracleAddress) {
        owner = msg.sender;
        oracleAddress = initialOracleAddress;
    }

    // オーナーのみが実行できる修飾子
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    // オラクルのみが実行できる修飾子
    modifier onlyOracle() {
        require(msg.sender == oracleAddress, "Caller is not oracle");
        _;
    }

    // オラクルアドレスが更新されたときのイベント
    event OracleAddressUpdated(address indexed newOracleAddress);

    // オラクルアドレスを設定する関数
    function setOracleAddress(address newOracleAddress) public onlyOwner {
        oracleAddress = newOracleAddress;
        emit OracleAddressUpdated(newOracleAddress);
    }

    // チャットが作成されたときのイベント
    event ChatCreated(address indexed owner, uint indexed chatId);

    mapping(uint => ChatRun) public chatRuns;
    uint private chatRunsCount;

    // チャットを開始する関数
    function startChat(string memory message) public returns (uint) {
        ChatRun storage run = chatRuns[chatRunsCount];

        run.owner = msg.sender;
        Message memory newMessage = Message({role: "user", content: message});
        run.messages.push(newMessage);
        run.messagesCount = 1;

        uint currentId = chatRunsCount;
        chatRunsCount++;

        IOracle(oracleAddress).createLlmCall(currentId);
        emit ChatCreated(msg.sender, currentId);

        return currentId;
    }

    // メッセージを追加する関数
    function addMessage(string memory message, uint runId) public {
        ChatRun storage run = chatRuns[runId];
        require(
            keccak256(
                abi.encodePacked(run.messages[run.messagesCount - 1].role)
            ) == keccak256(abi.encodePacked("assistant")),
            "No response to previous message"
        );
        require(run.owner == msg.sender, "Only chat owner can add messages");

        Message memory newMessage = Message({role: "user", content: message});
        run.messages.push(newMessage);
        run.messagesCount++;
        IOracle(oracleAddress).createLlmCall(runId);
    }

    // メッセージ履歴の内容を取得する関数
    function getMessageHistoryContents(
        uint chatId
    ) public view returns (string[] memory) {
        string[] memory messages = new string[](
            chatRuns[chatId].messages.length
        );
        for (uint i = 0; i < chatRuns[chatId].messages.length; i++) {
            messages[i] = chatRuns[chatId].messages[i].content;
        }
        return messages;
    }

    // メッセージ履歴の役割を取得する関数
    function getMessageHistoryRoles(
        uint chatId
    ) public view returns (string[] memory) {
        string[] memory roles = new string[](chatRuns[chatId].messages.length);
        for (uint i = 0; i < chatRuns[chatId].messages.length; i++) {
            roles[i] = chatRuns[chatId].messages[i].role;
        }
        return roles;
    }

    // オラクルのLLMレスポンスを処理する関数
    function onOracleLlmResponse(
        uint runId,
        string memory response,
        string memory /*errorMessage*/
    ) public onlyOracle {
        ChatRun storage run = chatRuns[runId];
        require(
            keccak256(
                abi.encodePacked(run.messages[run.messagesCount - 1].role)
            ) == keccak256(abi.encodePacked("user")),
            "No message to respond to"
        );

        Message memory newMessage = Message({
            role: "assistant",
            content: response
        });
        run.messages.push(newMessage);
        run.messagesCount++;
    }
}
