import ctypes
import os
import threading
import sys
from time import sleep
import time
import numpy as np
import time
'''
Ctype      C                  C++      python
c_ubyte >> unsigned char >>  BYTE  >> int/long
c_ushort>> unsigned short>>  WORD  >> int/long
c_ulong >> unsigned long >>  DWORD >> int/long

'''
DLLPATH = os.getcwd()+'\\ad7606dll64bit\\ad7606.dll'
AD7606DLL = ctypes.windll.LoadLibrary(DLLPATH)# 函数库
class ADC_CONFIG(ctypes.Structure):
    """ 继承自Structure """
    _fields_ = [
        ("byADCOptions", ctypes.c_ubyte),   # bit5: AD706 采样时间单位 0- US, 1- MS
                                            # bit4: AD7606 电压范围 1-正负 10V, 0-正负 5v                                           
                                            # bit0~2 参考 AD7606 OS 设置
        ("byTrigOptions", ctypes.c_ubyte),  # bit7: AD7606触发状态 1-触发开启,0-触发停止
                                            # bit4: AD706电压比较触发选择   0- large or equal, 1- small or equal
                                            # bit3~2:AD7606 GPIO 触发事件选择，
                                            # 00- 下降沿
                                            # 01- 上升沿
                                            # 10- 上升或下降沿
                                            # bit1~0: AD7606 触发模式
                                            # 00- GPIO 触发，每个 IO 事件产生一轮采样
                                            # 01- 周期触发，每个周期产生一轮采样
                                            # 10- GPIOIO 事件启动，周期采样
                                            # 11- 电压比较事件启动，周期采样
        ("wReserved1", ctypes.c_ushort),  # 未用的
        ("byMainCh", ctypes.c_ubyte),    # 电压比较选择的通道
        ("byCheckCnt", ctypes.c_ubyte),  # 电压比较选择的采样次数，去抖动次数       
        ("wReserved2", ctypes.c_ushort), # 未用的
        ("wPeriod", ctypes.c_ushort),    # 周期采样的设置值
        ("wTrigVol", ctypes.c_ushort),   # 比较电压的设置值 单位:mv
        ("dwCycleCnt", ctypes.c_ulong),   # 当前采样轮数
        ("dwMaxCycles", ctypes.c_ulong)   # 最大采样轮数，如果是 0，则无穷大
        ]


M3F20xm_SetUSBNotify = AD7606DLL.M3F20xm_SetUSBNotify               # 设置一个回调函数给库函数，库函数检测到 USB 插拔后调用此函数,暂时不用！
M3F20xm_GetSerialNo = AD7606DLL.M3F20xm_GetSerialNo                 # 根据设备号取得设备序列号,暂时不用！
M3F20xm_OpenDevice = AD7606DLL.M3F20xm_OpenDevice                   # 1. 查找一个可用的设备，并打开该设备，返回设备号，不会打开已经占用的设备，多次调用可以打开多个设备
M3F20xm_OpenDeviceByNumber = AD7606DLL.M3F20xm_OpenDeviceByNumber   # 2. 根据指定的序列号打开设备，返回设备号，如果已知设备序列号，可以用这个函数打开设备
M3F20xm_GetVersion = AD7606DLL.M3F20xm_GetVersion                   # 3. 取得软件的版本信息
M3F20xm_CloseDevice = AD7606DLL.M3F20xm_CloseDevice                 # 4. 根据设备号关闭指定的设备
M3F20xm_CloseDeviceByNumber = AD7606DLL.M3F20xm_CloseDeviceByNumber # 5. 根据指定的序列号关闭设备，返回设备号
M3F20xm_ADCGetConfig = AD7606DLL.M3F20xm_ADCGetConfig               # 6. 获取指定设备 ADC 配置
M3F20xm_ADCSetConfig = AD7606DLL.M3F20xm_ADCSetConfig               # 7. 设置指定设备 ADC 参数
M3F20xm_ADCRead = AD7606DLL.M3F20xm_ADCRead                         # 8. 执行一轮采样,并读得采样的数据，测试的时候用，正式不用
M3F20xm_ADCStart = AD7606DLL.M3F20xm_ADCStart                       # 9. 启动 AD7606 采样触发
M3F20xm_ADCStop = AD7606DLL.M3F20xm_ADCStop                       # 10. 执行 AD7606 复位
M3F20xm_ADCStandBy = AD7606DLL.M3F20xm_ADCStandBy                   # 11. 迫使 AD7606 进入 standby
M3F20xm_Verify =  AD7606DLL.M3F20xm_Verify                          # 12. 设备授权认证
M3F20xm_InitFIFO =  AD7606DLL.M3F20xm_InitFIFO                      # 13. 初始化 FIFO,清空 FIFO 的所有内容
M3F20xm_ReadFIFO =  AD7606DLL.M3F20xm_ReadFIFO                      # 14. 获取指定长度的 FIFO 未读数据
M3F20xm_GetFIFOLeft =  AD7606DLL.M3F20xm_GetFIFOLeft                # 15. 取得 FIFO 未读数据的长度


adcstart = False
byIndex = 255
sample_cycles = 0
max_vol = 10
# 0. M3F20xm_GetSerialNo
M3F20xm_GetSerialNo.argtypes =[ctypes.c_ubyte,ctypes.c_char_p]
M3F20xm_GetSerialNo.restype = ctypes.c_ubyte # 0设备不存在，1未使用，2使用中，实际返回的似乎是设备编号0-10
# 1. M3F20xm_OpenDevice
#M3F20xm_OpenDevice.argtypes = [ctypes.c_voidp]# 无输入参数
M3F20xm_OpenDevice.restype = ctypes.c_ubyte    # 如果是 0xFF，255表示打开设备不成功,否则返回设备号，从0开始
# 2. M3F20xm_OpenDeviceByNumber
M3F20xm_OpenDeviceByNumber.argtypes = [ctypes.c_char_p] # 设备序列号，例如AD001762
M3F20xm_OpenDeviceByNumber.restype = ctypes.c_ubyte     # 0设备不存在，1未使用，2使用中，实际返回的似乎是设备编号0-10
# 3. M3F20xm_GetVersion
M3F20xm_GetVersion.argtypes = [ctypes.c_ubyte,ctypes.c_ubyte,ctypes.c_char_p]# 设备号；软件类型（0-库版本信息，1-驱动版本信息，2-固件版本信息）；保存版本信息的缓存(至少大于50个BYTE)
M3F20xm_GetVersion.restype = ctypes.c_bool
# 4. M3F20xm_CloseDevice
M3F20xm_CloseDevice.argtypes = [ctypes.c_ubyte] # 设备号
M3F20xm_CloseDevice.restype = ctypes.c_bool     # 成功返回True
# 5. M3F20xm_CloseDeviceByNumber
M3F20xm_CloseDeviceByNumber.argtypes = [ctypes.c_char_p]  # 序列号
M3F20xm_CloseDeviceByNumber.restype = ctypes.c_bool       # 成功返回true，否则返回False
# 6. M3F20xm_ADCGetConfig
M3F20xm_ADCGetConfig.argtypes = [ctypes.c_ubyte,ctypes.POINTER(ADC_CONFIG)]  # 设备号；ADC_CONFIG
M3F20xm_ADCGetConfig.restype = ctypes.c_bool                                 # 成功返回true，否则返回False
# 7. M3F20xm_ADCSetConfig 
M3F20xm_ADCSetConfig.argtypes = [ctypes.c_ubyte,ctypes.POINTER(ADC_CONFIG)]  # 设备号；ADC_CONFIG
M3F20xm_ADCSetConfig.restype = ctypes.c_bool                                 # 成功返回true，否则返回False
# 8. 8M3F20xm_ADCRead
M3F20xm_ADCRead.argtypes = [ctypes.c_ubyte, ctypes.POINTER(ctypes.c_ushort)]                  # 设备号;采样数据 buff，必须是 8 个 word 长的指针
M3F20xm_ADCRead.restype = ctypes.c_bool                                      # 成功返回 true,否则返回 false
# 9. M3F20xm_ADCStart
M3F20xm_ADCStart.argtypes = [ctypes.c_ubyte]  # 设备号
M3F20xm_ADCStart.restype = ctypes.c_bool      # 成功返回 true,否则返回 false
# 10. M3F20xm_ADCStop
M3F20xm_ADCStop.argtypes = [ctypes.c_ubyte]  # 设备号
M3F20xm_ADCStop.restype = ctypes.c_bool      # 成功返回 true,否则返回 false
# 11. M3F20xm_ADCStandBy
M3F20xm_ADCStandBy.argtypes = [ctypes.c_ubyte] # 设备号
M3F20xm_ADCStandBy.restype = ctypes.c_bool     # 成功返回 true,否则返回 false
# 12. M3F20xm_Verify
M3F20xm_Verify.argtypes = [ctypes.c_ubyte,ctypes.POINTER(ctypes.c_ubyte)] # 设备号；认证结果（1-验证通过，0-验证不通过）
M3F20xm_Verify.restype = ctypes.c_bool                                    # 成功返回true，否则返回false
# 13. M3F20xm_InitFIFO
M3F20xm_InitFIFO.argtypes = [ctypes.c_ubyte]  # 设备号
M3F20xm_InitFIFO.restype = ctypes.c_bool      # 成功返回 true,否则返回 false
# 14. M3F20xm_ReadFIFO
M3F20xm_ReadFIFO.argtypes = [ctypes.c_ubyte,ctypes.POINTER(ctypes.c_ubyte),ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)] # 设备号;用来保存读取内容的缓存;请求读取的数据长度;实际读入的数据长度的指针
M3F20xm_ReadFIFO.restype = ctypes.c_bool   # 成功返回 true,否则返回 false
# 15. M3F20xm_GetFIFOLeft
M3F20xm_GetFIFOLeft.argtypes = [ctypes.c_ubyte,ctypes.POINTER(ctypes.c_ulong)] # 设备号;FIFO 未读的数据长度的指针
M3F20xm_GetFIFOLeft.restype = ctypes.c_bool  # 成功返回 true,否则返回 false


def readadc_data(byIndex):	  
    # print('readadc_timer handle')
    global sample_cycles
    global adcstart
    # global ad7606Config
    MaxCycle = 0
    max_vol = 5
    p_data_Buffer = (ctypes.c_ubyte * 3200000)()   # 用来保存读取内容的缓存，指针,POINTER接收的参数是指针类型，pointer接收的参数是ctypes对象,他们都能创建指针，功能不一样
    dwRealSize = ctypes.c_ulong()                  # 实际读取到的数据长度
    p_dwRealSize = ctypes.pointer(dwRealSize)
    l_fifo = M3F20xm_GetFIFOLeft(byIndex,p_dwRealSize)
    if l_fifo:
        # print('剩余数据长度：',p_dwRealSize[0])
        # print('M3F20xm_ReadFIFO')
        g = M3F20xm_ReadFIFO(ctypes.c_ubyte(byIndex),p_data_Buffer,3200000,p_dwRealSize)
        # print('读取完成：',g)
        
        sample_cycles = sample_cycles + dwRealSize.value / 16        
        # print('cycles：',sample_cycles)
        #print('maxcycle:',ad7606Config.dwMaxCycles)
        # if(MaxCycle and sample_cycles >= MaxCycle) :
        #     adcstart = False    
        #     print('stop') 
    
        real_vol = np.ones((int(p_dwRealSize[0]/2), 1),float)
        for i in range(int(p_dwRealSize[0]/2)):
            temp = p_data_Buffer[2*i]+p_data_Buffer[2*i+1]*256;
            if(temp >= 32768):
           	    real_vol[i] = max_vol * (temp - 65536) / 32768;
       	    else:
           	 	real_vol[i] = max_vol * temp / 32768;
               
        
    else:
        print("没有剩余数据")    
 
    return real_vol       

    

def openadc(period):      
    # 1-打开设备
    sleep(1)
    byIndex=M3F20xm_OpenDevice()
    print(byIndex)
    print('设备号：',byIndex)
    if(byIndex == 255):
    	print('没有找到AD7606设备')
    	sys.exit(0)
    # SerialString = "AD001762".encode('utf-8')
    # p_SerialString = ctypes.c_char_p(SerialString)
    # sleep(1)
    # state = M3F20xm_OpenDeviceByNumber(p_SerialString)
    # print(state)

    # 1-根据设备号取得设备序列号
    lpBuff = ctypes.c_char_p()
    lpBuff.value = (' '*10).encode('utf-8')
    bb = M3F20xm_GetSerialNo(ctypes.c_ubyte(byIndex),lpBuff)
    print('设备序列号：',lpBuff.value.decode('utf-8'))
    
    # 2-授权设备
    Result = ctypes.c_ubyte()    
    p_Result = ctypes.pointer(Result)
    b = M3F20xm_Verify(ctypes.c_ubyte(byIndex), p_Result)#ctypes.byref也是传递指针
    print('授权结果：',p_Result.contents.value)#1
    if p_Result.contents.value == 0:
        return 255

    # 3-获取软件版本信息
    byType0 = ctypes.c_ubyte(0)
    byType1 = ctypes.c_ubyte(1)
    byType2 = ctypes.c_ubyte(2)
    lpBuffer = ctypes.c_char_p()
    lpBuffer.value = (' '*50).encode('utf-8')
    bb = M3F20xm_GetVersion(ctypes.c_ubyte(byIndex),byType0,lpBuffer)
    print('库版本：',lpBuffer.value.decode('utf-8'))
    bb = M3F20xm_GetVersion(ctypes.c_ubyte(byIndex),byType1,lpBuffer)
    print('驱动版本：',lpBuffer.value.decode('utf-8'))
    bb = M3F20xm_GetVersion(ctypes.c_ubyte(byIndex),byType2,lpBuffer)
    print('固件版本：',lpBuffer.value.decode('utf-8'))

    # 4 获取当前ADC的设置
    ad7606Config = ADC_CONFIG()                               # 生成一个结构体类
    p_ad7606Config = ctypes.pointer(ad7606Config)            # 获取结构体的指针
    d = M3F20xm_ADCGetConfig(ctypes.c_ubyte(byIndex),p_ad7606Config)# 将结构体指针作为参数可以直接传递
    print('ADC设置获取成功：',d)
    print('byADCOptions:',p_ad7606Config.contents.byADCOptions)#结构体指针内容的访问方式
    print('byTrigOptions:',p_ad7606Config.contents.byTrigOptions)  
    print('wPeriod:',p_ad7606Config.contents.wPeriod)
    print('dwCycleCnt:',p_ad7606Config.contents.dwCycleCnt)
    print('dwMaxCycles:',p_ad7606Config.contents.dwMaxCycles)
    # 5 设置ADC   
    ad7606Config.byADCOptions = 0b00000000 
    ad7606Config.byTrigOptions = 0b10001001
    # ad7606Config.wPeriod = 100                            #采样率10K
    # ad7606Config.dwMaxCycles=10000                        #采样轮数,如果连续采样，设置为0
    ad7606Config.wPeriod = int(period)
    ad7606Config.dwMaxCycles=0    
    MaxCycle = ad7606Config.dwMaxCycles
    c = M3F20xm_ADCSetConfig(ctypes.c_ubyte(byIndex),ctypes.byref(ad7606Config))

    print('ADC设置成功：',c)
    print('byADCOptions:',p_ad7606Config.contents.byADCOptions)#结构体指针内容的访问方式
    print('byTrigOptions:',p_ad7606Config.contents.byTrigOptions)  
    print('wPeriod:',p_ad7606Config.contents.wPeriod) 
    print('dwCycleCnt:',p_ad7606Config.contents.dwCycleCnt)
    print('dwMaxCycles:',p_ad7606Config.contents.dwMaxCycles)
    
    
    
    if(ad7606Config.byADCOptions & 0b00010000):
     	print('input rangle -10V ~ 10V')
     	max_vol = 10
    else :
      print('input rangle -5V ~ 5V')
      max_vol = 5
    # 6. 测试下一轮采样
    
    read_Buffer = (ctypes.c_ushort * 8)()
    real_vol = [0.0] * 8
    #p_data_Buffer = ctypes.pointer(read_Buffer)     # 用来保存读取内容的缓存，指针,POINTER接收的参数是指针类型，pointer接收的参数是ctypes对象,他们都能创建指针，功能不一样
    d = M3F20xm_ADCRead(ctypes.c_ubyte(byIndex),read_Buffer)
    print("测试下一轮采样：",d)     
    for i in range(8):
     	if(read_Buffer[i] >= 32268):
    	    real_vol[i] = max_vol * (read_Buffer[i] - 65536) / 32768;
     	else:
    	    real_vol[i] = max_vol * read_Buffer[i] / 32768;
            
    

   
    print("采样值(V):%3.6f ,%3.6f ,%3.6f ,%3.6f ,%3.6f ,%3.6f ,%3.6f ,%3.6f"%(real_vol[0],real_vol[1],real_vol[2],real_vol[3],real_vol[4],real_vol[5],real_vol[6],real_vol[7]))
    # adcstart = False
    # M3F20xm_ADCStop(ctypes.c_ubyte(byIndex))
    # M3F20xm_CloseDevice(ctypes.c_ubyte(byIndex))
    return byIndex;
    


def adc_startread(byIndex):
    # 清空fifo缓存数据
    e = M3F20xm_InitFIFO(ctypes.c_ubyte(byIndex))
    print("清空FIFO缓存：",e)
    # 8. 启动AD采样
    f = M3F20xm_ADCStart(ctypes.c_ubyte(byIndex))
    print('AD启动成功',f)
    adcstart = True


    
    
def adc_close(byIndex):
    adcstart = False
    f = M3F20xm_ADCStop(ctypes.c_ubyte(byIndex))
    print('AD停止成功',f)
    
def close_device(byIndex):
    f = M3F20xm_ADCStop(ctypes.c_ubyte(byIndex))
    print('AD停止成功',f)
    M3F20xm_CloseDevice(ctypes.c_ubyte(byIndex))
    
def readadc_timer():
    # MaxCycle = 0
    # max_vol = 10
    # p_data_Buffer = (ctypes.c_ubyte * 3200000)()   # 用来保存读取内容的缓存，指针,POINTER接收的参数是指针类型，pointer接收的参数是ctypes对象,他们都能创建指针，功能不一样
    # dwRealSize = ctypes.c_ulong()                  # 实际读取到的数据长度
    # p_dwRealSize = ctypes.pointer(dwRealSize)
    # l_fifo = M3F20xm_GetFIFOLeft(byIndex,p_dwRealSize)
    # print(p_dwRealSize[0])
    # close_device(byIndex);
    readadc_data(0)
    close_device(0);

    
    


# if __name__ == "__main__":
#     byIndex = openadc()
#     if(byIndex != 255):
        
#         adc_startread(byIndex)
#         t = threading.Timer(1,function = readadc_timer)
#         t.start()
#     # [realsize,real_data]=readadc_data(byIndex)
#     # print(real_data)
#     # close_device(byIndex);




    


