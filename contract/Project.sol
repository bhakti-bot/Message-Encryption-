Contracts/Project Name.sol“”
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title MESSAGE ENCRYPTION
 * @dev A decentralized message encryption system for secure blockchain communication
 * @author Your Name
 * @notice This contract enables users to send and receive encrypted messages on blockchain
 */
contract Project {
    
    // Struct to represent an encrypted message
    struct EncryptedMessage {
        uint256 id;
        address sender;
        address recipient;
        string encryptedContent;
        bytes32 contentHash;
        uint256 timestamp;
        bool isActive;
    }
    
    // State variables
    mapping(uint256 => EncryptedMessage) private messages;
    mapping(address => uint256[]) private userSentMessages;
    mapping(address => uint256[]) private userReceivedMessages;
    
    uint256 private messageCounter;
    
    // Events
    event MessageSent(
        uint256 indexed messageId,
        address indexed sender,
        address indexed recipient,
        uint256 timestamp
    );
    
    event MessageRetrieved(
        uint256 indexed messageId,
        address indexed accessor,
        uint256 timestamp
    );
    
    // Modifiers
    modifier onlyAuthorized(uint256 _messageId) {
        require(
            msg.sender == messages[_messageId].sender || 
            msg.sender == messages[_messageId].recipient,
            "Unauthorized: Only sender or recipient can access this message"
        );
        require(messages[_messageId].isActive, "Message does not exist or has been deleted");
        _;
    }
    
    /**
     * @dev Core Function 1: Send an encrypted message to a recipient
     * @param _recipient Address of the message recipient
     * @param _encryptedContent Encrypted message content (encrypted off-chain)
     * @param _contentHash Hash of the original message for integrity verification
     * @return messageId The unique ID of the sent message
     */
    function sendMessage(
        address _recipient,
        string memory _encryptedContent,
        bytes32 _contentHash
    ) external returns (uint256) {
        require(_recipient != address(0), "Invalid recipient address");
        require(_recipient != msg.sender, "Cannot send message to yourself");
        require(bytes(_encryptedContent).length > 0, "Message content cannot be empty");
        require(_contentHash != bytes32(0), "Content hash cannot be empty");
        
        uint256 messageId = messageCounter++;
        
        messages[messageId] = EncryptedMessage({
            id: messageId,
            sender: msg.sender,
            recipient: _recipient,
            encryptedContent: _encryptedContent,
            contentHash: _contentHash,
            timestamp: block.timestamp,
            isActive: true
        });
        
        userSentMessages[msg.sender].push(messageId);
        userReceivedMessages[_recipient].push(messageId);
        
        emit MessageSent(messageId, msg.sender, _recipient, block.timestamp);
        
        return messageId;
    }
    
    /**
     * @dev Core Function 2: Retrieve an encrypted message by ID
     * @param _messageId The unique ID of the message to retrieve
     * @return sender Address of the message sender
     * @return recipient Address of the message recipient
     * @return encryptedContent The encrypted message content
     * @return contentHash Hash of the original message
     * @return timestamp When the message was sent
     */
    function getMessage(uint256 _messageId) 
        external 
        onlyAuthorized(_messageId) 
        returns (
            address sender,
            address recipient,
            string memory encryptedContent,
            bytes32 contentHash,
            uint256 timestamp
        ) 
    {
        EncryptedMessage memory message = messages[_messageId];
        
        emit MessageRetrieved(_messageId, msg.sender, block.timestamp);
        
        return (
            message.sender,
            message.recipient,
            message.encryptedContent,
            message.contentHash,
            message.timestamp
        );
    }
    
    /**
     * @dev Core Function 3: Verify message integrity and get user's message history
     * @param _messageId The message ID to verify
     * @param _originalHash Hash of the decrypted message for verification
     * @return isValid True if the message hash matches the original
     * @return sentMessages Array of message IDs sent by the caller
     * @return receivedMessages Array of message IDs received by the caller
     */
    function verifyAndGetHistory(uint256 _messageId, bytes32 _originalHash)
        external
        view
        onlyAuthorized(_messageId)
        returns (
            bool isValid,
            uint256[] memory sentMessages,
            uint256[] memory receivedMessages
        )
    {
        bool hashMatch = messages[_messageId].contentHash == _originalHash;
        
        return (
            hashMatch,
            userSentMessages[msg.sender],
            userReceivedMessages[msg.sender]
        );
    }
    
    /**
     * @dev Get total number of messages in the system
     * @return Total message count
     */
    function getTotalMessages() external view returns (uint256) {
        return messageCounter;
    }
    
    /**
     * @dev Check if a message exists and is active
     * @param _messageId The message ID to check
     * @return True if message exists and is active
     */
    function getMessageExists(uint256 _messageId) external view returns (bool) {
        return messages[_messageId].isActive && _messageId < messageCounter;
    }
}
