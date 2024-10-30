# -*- coding: utf-8 -*-
"""
Created on Tue Sep 19 14:34:10 movespeed23

@author: Akun
"""

import ctypes
import os
import sys
import time
from datetime import datetime,timedelta
import threading

dllPath=os.path.join("D:\\Data_Processing\\app_robohand\\","RM_Base.dll")
pDll=ctypes.cdll.LoadLibrary(dllPath)

Movej_Cmd = pDll.Movej_Cmd
Teach_Stop_Cmd = pDll.Teach_Stop_Cmd
RM_API_Init = pDll.RM_API_Init
Arm_Socket_Start = pDll.Arm_Socket_Start
Pos_Teach_Cmd = pDll.Pos_Teach_Cmd
Set_Hand_Speed = pDll.Set_Hand_Speed
Set_Hand_Force = pDll.Set_Hand_Force
Set_Hand_Angle = pDll.Set_Hand_Angle
Arm_Socket_Close = pDll.Arm_Socket_Close
Pos_Step_Cmd = pDll.Pos_Step_Cmd
Get_Joint_Degree = pDll.Get_Joint_Degree
Joint_Teach_Cmd = pDll.Joint_Teach_Cmd
Get_Current_Work_Frame = pDll.Get_Current_Work_Frame
Get_Current_Arm_State = pDll.Get_Current_Arm_State
Get_Given_Work_Frame = pDll.Get_Given_Work_Frame
Movel_Cmd = pDll.Movel_Cmd
Get_All_Work_Frame = pDll.Get_All_Work_Frame



float_joint = ctypes.c_float*6
joint1 = float_joint()
float_pose = ctypes.c_float*6
pose1= float_pose()



class FrameName(ctypes.Structure):
    _fields_ = [("name", ctypes.c_char_p)]
    # def __init__(self, name):
    #     self.name = name[:10]  # Ensure the name is not more than 10 characters

class Pose(ctypes.Structure):
    _fields_ = [("px", ctypes.c_float),
                ("py", ctypes.c_float),
                ("pz", ctypes.c_float),
                ("rx",ctypes.c_float),
                ("ry",ctypes.c_float),
                ("rz",ctypes.c_float)]
    # def __init__(self, px, py, pz, rx, ry, rz):
    #     self.px = px
    #     self.py = py
    #     self.pz = 
    #     self.rx = rx
    #     self.ry = ry
    #     self.rz = rz

class Frame(ctypes.Structure):
    _fields_ = [("frame_name", FrameName),
                ("pose", Pose),
                ("payload", ctypes.c_float),
                ("x",ctypes.c_float),
                ("y",ctypes.c_float),
                ("z",ctypes.c_float)]
                
    # def __init__(self, frame_name, pose, payload, x, y, z):
    #     self.frame_name = frame_name
    #     self.pose = pose
    #     self.payload = payload
    #     self.x = x
    #     self.y = y
    #     self.z = z

def get_socket():
    ret_init = RM_API_Init(65, 0)
    if ret_init != 0:
        print(f"Initialization failed with error code: {ret_init}")
    byteIP = bytes("192.168.1.18","gbk")
    nSocket = Arm_Socket_Start(byteIP,8080,200)
    
    print(nSocket)    
    return nSocket


def start_robohand(nSocket):


    #   初始位置
    global joint1
    joint1[0] = -74.123
    joint1[1] = 55.04
    joint1[2] = 117.03
    joint1[3] = 104.4
    joint1[4] = 89.8
    joint1[5] = 151.8
    Movej_Cmd.argtypes = (ctypes.c_int, ctypes.c_float * 6, ctypes.c_byte, ctypes.c_float, ctypes.c_bool)
    Movej_Cmd.restype = ctypes.c_int
    ret = Movej_Cmd(nSocket, joint1, 10,0,1)
    # global pose1
    # pose1[0]=-0.331
    # pose1[1]=0.022
    # pose1[2]=0.133
    # pose1[3]=1.6
    # pose1[4]=-1.15
    # pose1[5]=-1.627
    hand_angle(nSocket,1000,1000,1000,1000,800,1000)
    # ret = Movel_Cmd(nSocket,pose1,10,0,1)
    if ret != 0 :
        print("设置初始位置失败:" + str(ret))
        sys.exit()
    

def move_add_joint(nSocket,joint_num,movespeed,move_step):   
    global joint1
    Get_Joint_Degree(nSocket,joint1)
    while joint1[joint_num]>-360:
        joint1[joint_num] += move_step
        Movej_Cmd.argtypes = (ctypes.c_int, ctypes.c_float * 6, ctypes.c_byte, ctypes.c_float, ctypes.c_bool)
        Movej_Cmd.restype = ctypes.c_int
        ret = Movej_Cmd(nSocket, joint1, movespeed, 0, 0)
        if ret != 0 :
            print("设置关节角度失败:" + str(ret))
            sys.exit()
            
def move_joint(nSocket,joint_num,dir_type,move_speed):
    ret = Joint_Teach_Cmd(nSocket,joint_num,dir_type,move_speed,0)
    if ret != 0:
        print("关节移动失败：" + str(ret))
        sys.exit()

def move_xyz_step(nSocket,dir_type,move_step,speed_xyz,block):
    ret = Pos_Step_Cmd(nSocket,dir_type,move_step,speed_xyz,block)
    if ret != 0:
        print("位置移动失败：" + str(ret))
        sys.exit()

def move_xyz(nSocket,dir_type,direction,speed_xyz,block):
    ret = Pos_Teach_Cmd(nSocket,dir_type,direction,speed_xyz,block)
    if ret != 0:
        print("位置移动失败：" + str(ret))
        sys.exit()
    return ret
def stop_move_xyz(nSocket):
    Teach_Stop_Cmd.argtypes = (ctypes.c_int, ctypes.c_bool)
    Teach_Stop_Cmd.restype = ctypes.c_int
    ret = Teach_Stop_Cmd(nSocket,1)
    if ret != 0:
        print("停止示教失败：" + str(ret))
        sys.exit()
        
def hand_angle(nSocket,angle1,angle2,angle3,angle4,angle5,angle6):

    float_hand = ctypes.c_int*6
    hand1 = float_hand()
    hand1[0] = angle1
    hand1[1] = angle2
    hand1[2] = angle3
    hand1[3] = angle4
    hand1[4] = angle5
    hand1[5] = angle6
    Set_Hand_Speed(nSocket,200, 1)
    Set_Hand_Force(nSocket,100, 1)
    Set_Hand_Angle(nSocket,hand1,1)
    return hand1
  

  
def hand_catch(nSocket):
    
    hand1 = hand_angle(nSocket,1000,1000,1000,1000,1000,1000)
    
    move_step = 200
    Set_Hand_Speed(nSocket,200, 1); 
    Set_Hand_Force(nSocket,250,1);
    
    while hand1[0]>0:
        
        hand1[0] -= 200
        hand1[1] -= 150
        hand1[2] -= 100
        hand1[3] -= 150
        hand1[4] -= 200
        hand1[5] -= 100
        Set_Hand_Angle(nSocket,hand1,0)

          
        
def stop_robohand(nSocket):
    #   关闭连接
    Arm_Socket_Close(nSocket)
 

 
if __name__ == "__main__":
    nSocket = get_socket()
    # start_robohand(nSocket)
    # print(pose1[2])
      # time.sleep(2)
    hand1 = hand_angle(nSocket,1000,1000,1000,1000,800,1000)
    # time.sleep(2)
    # hand1 = hand_angle(nSocket,0,0,0,0,1000,0)
    # frame_name = FrameName()
    # pose = Pose()
    # frame1 = Frame()
    # Get_Current_Work_Frame(nSocket,frame1)
    # Get_Given_Work_Frame(nSocket,frame1.frame_name,frame1.pose)
    # print(frame1.pose.px)
    # ret1 = move_xyz(nSocket,2,1,10,0)
    # time.sleep(0.5)
    # stop_move_xyz(nSocket)
    # Get_Current_Work_Frame(nSocket,frame1)
    # Get_Given_Work_Frame(nSocket,frame1.frame_name,frame1.pose)
    # print(frame1.pose.pz)
    # Get_Current_Arm_State(nSocket,joint1,pose)
    # print(pose.pz)
    # Get_Given_Work_Frame(nSocket,"world1",pose1)
    # print(pose1[2])
    stop_robohand(nSocket)
    