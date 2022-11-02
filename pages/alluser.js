import React, {useState, useEffect, useContext} from 'react'

//INTERNAL IMPORTS
import {UserCard} from "../Components/index"
import Style from "../styles/alluser.module.css";
import { ChatAppContext } from '../Context/ChatAppContext';



const alluser = () => {

  const {userLists, addFriends} = useContext(ChatAppContext)
  return (
    <div>
      <div className={Style.alluser-info}>
        <h1>Find your friends</h1>
      </div>

      <div className={Style.alluser}>
        {userLists.map((el,i)=> (
          <UserCard key={i+1} el={el} i={i} addFriends={addFriends}/>
        ))}
      </div>
    </div>
  )
}

export default alluser