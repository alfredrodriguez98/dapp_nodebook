import React, { useState, useEffect } from "react";

import { useRouter } from "next/router";

//Internal Imports
import {
  CheckIfWalletConnected,
  connectWallet,
  connectingWithContract,
} from "../Utils/apiFeature";

export const ChatAppContext = React.createContext();

export const ChatAppProvider = ({ children }) => {
  //USESTATE
  const [account, setAccount] = useState("");
  const [userName, setuserName] = useState("");
  const [friendLists, setfriendLists] = useState([]);
  const [friendMsg, setfriendMsg] = useState([]);
  const [loading, setloading] = useState(false);
  const [userLists, setuserLists] = useState([]);
  const [error, seterror] = useState("");

  //CHAT user data

  const [currentUserName, setcurrentUserName] = useState("");
  const [currentUserAddress, setcurrent] = useState("");

  //Router is used to redirect users to homepage
  const router = useRouter();

  //fetch data time of page load

  const fetchData = async () => {
    try {
      //GET CONTRACT
      const contract = await connectingWithContract();

      //GET ACCOUNT
      const connectAccount = await connectWallet();
      setAccount(connectAccount);

      //GET USER NAME
      const userName = await contract.getUsername(connectAccount); //we'll get name of the user and then we can set it to username
      setUserName(userName);

      //GET MY FRIEND LIST

      const friendLists = await contract.getMyFriendList();
      setfriendLists(friendLists);

      //GET ALL APP USER LIST
      const userList = await contract.getAllAppUsers();
      setuserLists(userList);
    } catch (error) {
      seterror("Please install and connect your metamask wallet");
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  //READ MESSAGE

  const readMessage = async (friendAddress) => {
    try {
      const contract = await connectingWithContract();
      const read = await contract.readMessage(friendAddress);
      setfriendMsg(read);
    } catch (error) {
      seterror("Currently you have no message ");
    }
  };

  //CREATE ACCOUNT
  const createAccount = async ({ name, accountAddress }) => {
    try {
      if (name || accountAddress)
        return seterror("Name and Account cannot be empty");

      const contract = await connectingWithContract();

      const getCreatedUser = await contract.createAccount(name);
      setloading(true); //displays the loader while the transaction is processing

      await getCreatedUser.wait();

      setloading(false);
      window.location.reload();
    } catch (error) {
      seterror("error while creating your account, kindly reload the browser");
    }
  };
  // ADD YOUR FRIENDS

  const addFriends = async ({ name, accountAddress }) => {
    try {
      if (name || accountAddress) return setError("Please provide data");

      const contract = await connectingWithContract();

      const addMyFriend = await contract.addFriend(accountAddress, name);
      setloading(true);
      await addMyFriend.wait();
      setloading(false);
      router.push("/");
      window.location.reload();
    } catch (error) {
      seterror("Something went wrong while adding friends, try again");
    }
  };
  //SEND MESSAGE TO YOUR FRIEND
  const sendMessage = async ({ msg, address }) => {
    try {
      if (msg || address) return seterror("Please type your message");
      const contract = await connectingWithContract();

      const addMessage = await contract.sendMessage(address, msg);
      setloading(true);
      await addMyFriend.wait();
      setloading(false);
      window.location.reload();
    } catch (error) {
      seterror("Please reload and try again");
    }
  };

  //READ USER INFO
  const readUser = async (userAddress) => {
    const contract = await connectingWithContract();
    const userName = await contract.getUsername(userAddress);

    setCurrentUserName(userName);

    setCurrentUserAddress(userAddress);
  };

  return (
    <ChatAppContext.Provider
      value={{
        readMessage,
        createAccount,
        addFriends,
        sendMessage,
        readUser,
        connectWallet,
        CheckIfWalletConnected,
        account,
        userName,
        friendLists,
        friendMsg,
        loading,
        userLists,
        error,
        currentUserName,
        currentUserAddress,
      }}
    >
      {children}
    </ChatAppContext.Provider>
  );
};
