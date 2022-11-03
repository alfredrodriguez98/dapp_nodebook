//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract ChatApp {
    //user Struct - captures new user data
    struct user {
        string name; //name of user
        friend[] friendList; //contains all the list of all friends of the user in friend array
    }
    //friend struct contains data required to add a new friend
    struct friend {
        address pubkey; //public address of the friend
        string name; //name of that friend
    }
    //message struct contains meta data associated with each message
    struct message {
        address sender; //address of the person who sent message
        uint256 timestamp; //time of message
        string msg; //message content
    }
    //Can add more var to this struct while expanding the dapp
    struct AllUsersStruct {
        string name;
        address accountAddress;
    }
    //storing all users in an array
    AllUsersStruct[] getAllUsers;

    mapping(address => user) userList; //address of all the users registering in our app is stored in mapping
    mapping(bytes32 => message[]) allMessages; //contains all messages between 2 users

    //Check if user exists already / logged in already

    function checkUserExists(address pubkey) public view returns (bool) {
        return bytes(userList[pubkey].name).length > 0; //ensures name is provided to proceed
        //if returned true means user data is already present in smart contract
    }

    //Create a new user account
    //Using calldata saves gas fee
    //making access modifier "external" so that anybody using the app can call it
    function createAccount(string calldata name) external {
        require(checkUserExists(msg.sender) == false, "User already exists");
        require(bytes(name).length > 0, "username cannot be empty");
        //After both the checks, a nwew username is created
        userList[msg.sender].name = name; //updates name data to a var name
        getAllUsers.push(AllUsersStruct(name, msg.sender));
    }

    //Get username - checks if a user has already registered or not
    //Returns name of user as a string, hence specifying it exclusively
    function getUsername(address pubkey) external view returns (string memory) {
        require(checkUserExists(pubkey), "User is not registered");
        return userList[pubkey].name;
    }

    //Add friends - contains few checks and then adds new friend to our list
    function addFriend(address friend_key, string calldata name) external {
        require(checkUserExists(msg.sender), "create an account");
        require(checkUserExists(friend_key), "User is not registered");
        require(
            msg.sender != friend_key,
            "User cannot add themselve as friend"
        );
        require(
            checkAlreadyFriends(msg.sender, friend_key) == false,
            "They are already friends"
        );
        //If all these conditions pass, then we have to add friend

        _addFriend(msg.sender, friend_key, name); //adding to your friend list
        _addFriend(friend_key, msg.sender, userList[msg.sender].name); //letting know your friend that they have been added
    }

    // compares the friend's list and finds if the person is already in friend-list
    function checkAlreadyFriends(address pubkey1, address pubkey2)
        internal
        view
        returns (bool)
    {
        if (
            userList[pubkey1].friendList.length >
            userList[pubkey2].friendList.length
        ) {
            address tmp = pubkey1;
            pubkey1 = pubkey2;
            pubkey2 = tmp;
        }

        for (uint256 i = 0; i < userList[pubkey1].friendList.length; i++) {
            if (userList[pubkey1].friendList[i].pubkey == pubkey2) return true;
        }
        return false;
    }

    // adding a friend to my list. Hence, it contains my address, friend address and friend name
    function _addFriend(
        address me,
        address friend_key,
        string memory name
    ) internal {
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }

    //Get my friends list

    function getMyFriendList() external view returns (friend[] memory) {
        return userList[msg.sender].friendList;
    }

    //get chat code - using keccak256 encryption to secure messages between friends
    function _getChatCode(address pubkey1, address pubkey2)
        internal
        pure
        returns (bytes32)
    {
        if (pubkey1 < pubkey2) {
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        } else return keccak256(abi.encodePacked(pubkey2, pubkey1));
    }

    //Send message
    function sendMessage(address friend_key, string calldata _msg) external {
        require(checkUserExists(msg.sender), "create an account");
        require(checkUserExists(friend_key), "User is not registered");
        require(
            checkAlreadyFriends(msg.sender, friend_key),
            "You are not friend with the given user"
        );

        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);
    }

    //read messages

    function readMessage(address friend_key)
        external
        view
        returns (message[] memory)
    {
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatCode];
    }

    function getAllAppUsers() public view returns (AllUsersStruct[] memory) {
        return getAllUsers;
    }
}
