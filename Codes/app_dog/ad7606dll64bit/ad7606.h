
#ifndef		M3F20xm_MP_H
#define		M3F20xm_MP_H
#define DllExport extern "C"__declspec(dllimport)


typedef struct
 {
		/*
	  byADCOptions:

	  bit5     for AD706 period unit            0- US, 1- MS
	  bit4     for AD7606 range:                1- in +10V ~ -10V,    0- in +5v ~ -5v
	  bit0~2   for AD7606 OS;
	*/
	BYTE  byADCOptions;
	/*
	  byTrigOptions:

	  bit7     for AD7606 samping:                1- in sampling,    0- stop
	  bit4     for AD706 trig vol selection       0- large or equal, 1- small or equal
	  bit2~3   for AD7606 IO selection:           00- falling, 01- Raising , 10- raising and falling
	  bit0~1   for AD7606 trig mode;              00- GPIO trig, 01- period trig, 10- GPIO + period，11- trigVol + period
	*/

	BYTE  byTrigOptions;
	WORD  wReserved1;
	BYTE  byMainCh;
	BYTE  byCheckCnt;
	WORD  wReserved2;
  /* wPeriod: Timer trig period, unit byADCOptions bit 5~6 */
	WORD  wPeriod;
	WORD  wTrigVol; //unit mv
 /* dwTrigCnt: current trig counter */
	DWORD dwCycleCnt;
  /* dwMaxCnt: Max Enabled trig number , trig will exit if dwTrigCnt is equal to dwMaxCnt */
	DWORD dwMaxCycles;
 }ADC_CONFIG;


/* the callback function define for USB hotplug */
 typedef	 VOID (CALLBACK* USB_DLL_CALLBACK )(BYTE iDevIndex, DWORD iDevStatus);


/** \ingroup desc
 * Retrieve a software information from the specified device 
 *
 * \param byIndex:  device index
 * \param byType:   software type; 0- lib, 1- sys, 2- MCU
 * \param lpBuffer: a char pointer to save software information
 * \returns true if call successful or false if call failed
 */
DllExport bool M3F20xm_GetVersion(BYTE byIndex,BYTE byType,char* lpBuffer);


/** \ingroup desc
 * Retrieve the number of devices run a PC in parallel 
 *
 * \param void
 * \returns number of devices
 */
DllExport BYTE M3F20xm_GetMaxNumofDev(void);


/** \ingroup desc
 * Retrieve the serial No.from the specified device 
 *
 * \param byIndex:  device index
 * \param lpBuff: char pointer to save serial No.
 * \returns true if call successful or false if call failed
 */
DllExport BYTE M3F20xm_GetSerialNo(BYTE byIndex, char* lpBuff);


/** \ingroup desc
 * Set a usb hotplug callback function pointer and log switch 
 *
 * \param bLog:  true for log on , false for log off
 * \param pUSB_CallBack: a callback function pointer for usb hotplug
 * \returns true if call successful or false if call failed
 */
DllExport bool  M3F20xm_SetUSBNotify(bool bLog,USB_DLL_CALLBACK pUSB_CallBack);
						   

/** \ingroup desc
 * Retrieve a device index from the specified serial N0. 
 *
 * \param pSerialString: char pointer to save serial No.
 * \returns the device index. if is 0xFF, the device index is invalid
 */
DllExport BYTE M3F20xm_OpenDeviceByNumber(char* pSerialString );


/** \ingroup desc
 * Open a device and get the device index. 
 *
 * \param void
 * \returns the device index. if is 0xFF, the device index is invalid
 */
DllExport  BYTE M3F20xm_OpenDevice(void);


/** \ingroup desc
 * Verify a specified device if registed or not 
 *
 * \param byIndex:   device index
 * \param pResult:   a unsigned char pointer to save the verified result
 * \returns the device index. if is 0xFF, the device index is invalid
 */
DllExport bool M3F20xm_Verify(BYTE byIndex,BYTE* pResult);


/** \ingroup desc
 * force the specified device enter DFU mode
 *
 * \param byIndex:   device index
 * \returns the device index. if is 0xFF, the device index is invalid
 */
DllExport bool M3F20xm_DFUMode(BYTE byIndex);


/** \ingroup desc
 * Close specified device by device index. 
 *
 * \param byIndex:  device index
 * \returns true if call successful or false if call failed
 */
DllExport bool M3F20xm_CloseDevice(BYTE byIndex);


/** \ingroup desc
 * Close specified device by device serial No. 
 *
 * \param pSerialString:  char pointer to save serial No.
 * \returns true if call successful or false if call failed
 */
DllExport bool M3F20xm_CloseDeviceByNumber (char* pSerialString);

/** \ingroup desc
 * Get Trig Config
 *
 * \param byIndex:  device index
 * \param pCfg:    A pointer to save the ADC Config
 * \returns true if call successful or false if call failed
 */ 
DllExport bool M3F20xm_ADCGetConfig(BYTE byIndex,ADC_CONFIG* pCfg);


/** \ingroup desc
 * Set Trig Config
 *
 * \param byIndex:  device index
 * \param pCfg:    A pointer to save the ADC Config
 * \returns true if call successful or false if call failed
 */ 

DllExport bool M3F20xm_ADCSetConfig(BYTE byIndex,ADC_CONFIG* pCfg);

/** \ingroup desc
 * Initialize FIFO
 *
 * \param byIndex:  device index
 * \returns true if call successful or false if call failed
 */ 
DllExport bool M3F20xm_InitFIFO(BYTE byIndex);


/** \ingroup desc
 * Retrieve a un-read data length of FIFO
 *
 * \param byIndex:      device index
 * \param pdwBuffsize:  a unsigned int pointer to save the un-read data length of FIFO
 * \returns true if call successful or false if call failed
 */
DllExport bool M3F20xm_GetFIFOLeft(BYTE byIndex,DWORD* pdwBuffsize);
DllExport bool M3F20xm_ReadFIFO(BYTE byIndex,BYTE* lpBuffer,DWORD dwBuffSize,DWORD* pdwRealSize);
                              
/** \ingroup desc
 * Write data to SPI buff
 * Note:
 * 1. wAddr must be less than 0xC00
 * 2. wAddr +  wBuffSize must be less than 0xC00
 * \param byIndex:     device index
 * \param wAddr:       buff offset
 * \param lpBuffer:    A pointer to save the write data to SPI buff
 * \param wBuffSize:   the data length requested for writting 
 * \param dwTimeout:   the timeout for write buff
 * \returns true if call successful or false if call failed
 */
DllExport bool M3F20xm_ADCRead(BYTE byIndex,WORD* pwValue);
DllExport bool M3F20xm_ADCStart(BYTE byIndex);
DllExport bool M3F20xm_ADCStop(BYTE byIndex);
DllExport bool M3F20xm_ADCReset(BYTE byIndex);
DllExport bool M3F20xm_ADCStandBy(BYTE byIndex);
DllExport bool M3F20xm_DFUPinGet(BYTE byIndex,BYTE* plevel);
DllExport bool M3F20xm_DFUPinSet(BYTE byIndex,BYTE level);
//#ifdef __cplusplus
//}
//#endif

#endif
