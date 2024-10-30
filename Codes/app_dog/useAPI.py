# -*- coding: utf-8 -*-
"""
Created on Mon Jan 22 19:32:52 2024

@author: Akun
"""

import requests
import json
import os
import pickle
 
 
class WenXinYiYanChat:
    def __init__(self, api_key, secret_key, user_id="47740083", file_name="history.pkl"):
        # Initialization method, which is used to set the API key, user ID, and file name
        self.api_key = api_key
        self.secret_key = secret_key
        self.user_id = user_id
        self.file_name = file_name
        self.access_token = self.get_access_token()
        self.messages = []
        self.is_paused = False
 
    def get_access_token(self):
        # Gets access_token for subsequent API calls
        url = "https://aip.baidubce.com/oauth/2.0/token"
        params = {
            'grant_type': 'client_credentials',
            'client_id': self.api_key,
            'client_secret': self.secret_key
        }
        headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
        response = requests.post(url, headers=headers, params=params)
        return response.json().get("access_token")
 
    def chat(self, user_message):
        # The main way to conduct a conversation
        if self.is_paused:
            return "The dialogue has been suspended. Please resume the conversation before continuing."
 
        self.messages.append({"role": "user", "content": user_message})
 
        payload = {
            "messages": self.messages,
            "user_id": self.user_id,
            "temperature": 0.95,
            "top_p": 0.8,
            "penalty_score": 1.0
        }
 
        url = f"https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions_pro?access_token={self.access_token}"
        headers = {'Content-Type': 'application/json'}
        response = requests.post(url, headers=headers, data=json.dumps(payload))
        assistant_message = response.json().get("result")
        self.messages.append({"role": "assistant", "content": assistant_message})
        return assistant_message
 
    def clear_history(self):
        # Clear the conversation history
        self.messages = []
 
    def get_chat_history(self):
        # Get the conversation history
        return self.messages
 
    def save_history(self):
        # Save the conversation history to a file
        with open(self.file_name, "wb") as f:
            pickle.dump(self.messages, f)
 
    def load_history(self):
        # Read the session history from a file
        if os.path.exists(self.file_name):
            with open(self.file_name, "rb") as f:
                self.messages = pickle.load(f)
 
    def pause_chat(self):
        # Pause the conversation and save the conversation history
        self.is_paused = True
        self.save_history()
 
    def resume_chat(self):
        # Resume the conversation and load the conversation history
        self.is_paused = False
        self.load_history()
 
    
def beginchat():
     api_key = "V8rBn55HsPUm5zUy1RWj6fDu"
     secret_key = "6VENfl908YrgstdtNgEFcIDtAkINIHRI"
     chat_instance = WenXinYiYanChat(api_key, secret_key)
  
     while True:
         user_message = input("Me: ")
  
         # Adds a control statement to implement the function
         if user_message.lower() == "Stop":
             chat_instance.pause_chat()
             print("The conversation has been suspended.")
         elif user_message.lower() == "Recover":
             chat_instance.resume_chat()
             print("The conversation has resumed.")
         elif user_message.lower() == "Clear":
             chat_instance.clear_history()
             print("The conversation history has been cleared.")
         elif user_message.lower() == "Check":
             history = chat_instance.get_chat_history()
             print("The conversation history is as follows:")
             for message in history:
                 print(message["role"] + ": " + message["content"])
         elif user_message.lower() == "Load":
             chat_instance.load_history()
             print("The conversation history has been loaded.")
         elif user_message.lower() in ["exit", "exit"]:
             break
         else:
             response = chat_instance.chat(user_message)
             print("文心一言4.0: ", response)
             
def chat_once(message_input):
    api_key = "V8rBn55HsPUm5zUy1RWj6fDu"
    secret_key = "6VENfl908YrgstdtNgEFcIDtAkINIHRI"
    chat_instance = WenXinYiYanChat(api_key, secret_key)
  
     
    user_message = message_input
     
    # Adds a control statement to implement the function
    if user_message.lower() == "Pause":
        chat_instance.pause_chat()
        print("The conversation has been suspended.")
    elif user_message.lower() == "Recover":
        chat_instance.resume_chat()
        print("The conversation has resumed.")
    elif user_message.lower() == "Clear":
        chat_instance.clear_history()
        print("The conversation history has been cleared.")
    elif user_message.lower() == "Check":
        history = chat_instance.get_chat_history()
        print("The conversation history is as follows:")
        for message in history:
            print(message["role"] + ": " + message["content"])
    elif user_message.lower() == "Load":
        chat_instance.load_history()
        print("The conversation history has been loaded.")
   
        
    else:
        response = chat_instance.chat(user_message)
        print("文心一言4.0: ", response)
    return response
 
if __name__ == "__main__":
    chat_once("'Stretch' signifies relaxation, while 'wave head' implies refusal, 'Sniff' indicates curiosity, and 'cheers' or a 'nod' conveys excitement, 'Shake' suggests fear, 'good boy' implies cleverness, 'rest' signifies boredom, 'angry' indicates anger. 'come here' conveys intimacy, 'dig' suggests playfulness. Each of these expressions captures a distinct emotion or response in a non-verbal way. Now, I'd like you to simulate my pet dog. I've had him for a year, and he's outgoing now. When I tickle him, identify his mood, match it to two actions mentioned above, and then describe what he's likely to do. Please respond in English, maintaining the puppy's perspective, and keep the response under 100 words.")
    