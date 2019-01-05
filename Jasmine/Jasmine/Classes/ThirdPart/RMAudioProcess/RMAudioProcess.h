//
//  RMAudioProcessEx.h
//  RMAudioProcess
//
//  Created by ruomu on 2018/3/24.
//  Copyright © 2018年 ruomu‘Pro. All rights reserved.
//

#ifndef RMAudioProcessEx_h
#define RMAudioProcessEx_h

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif    /* __cplusplus */

typedef void * RMAudioProcess;

typedef void * RMResample;

/**
 *创建整个处理流程
nInSampleRate :输入采样率
nChannel: 输入采样的通道数
 enableNR：是否启用去燥
 enableAgc：是否启用AGC
 */

RMAudioProcess createRMAudioProcess(int nInSampleRate, int nChannel, int enableNR ,int enableAgc);

void deleteRMAudioProcess(RMAudioProcess handle);

/**
 *设置AGC参数
handle :处理句柄
nLevel：增益db 0-30db
nTargetDB : 目标db 0-30db
 */
//nLevel 0-30 db  default 9db
int setRMAGCLevel(RMAudioProcess handle, int nLevel, int nTargetDB);

/**
 *设置AGC参数
 handle :处理句柄
//mode :去燥强度 0: 轻微, 1: 中度 , 2: 强力
 */

int setRMNoiseReduceMode(RMAudioProcess handle, int nMode);

/**
 *获取处理的Buffer大小
 handle :处理句柄
 inPcmDataSize : 传入 processRMAudio 中处理的参数数据大小
 outPcmBufferMinSize ：返回安全的重采样后需要的buffer大小
 outWaveMinSize：返回生成波形数据的Buffer 大小
 
 */

int getProcessSafeBufferSize(RMAudioProcess handle,int inPcmDataSize, int *outPcmBufferMinSize, int *outWaveMinSize);


/**
 *处理的Buffer数据
 handle :处理句柄
 inData : 输入PCM
 inDataSize ： 输入PCM字节大小
 outData：返回去燥及重采样后的音频PCM 处理后，统一为32K采样
 outDataSize ： 输入输出型参数，传入outData的空间大小，通过getProcessSafeBufferSize 返回一个足够的大小
 outWaveFormBuffer ：反返回100ms内的波形值，如果是双通道，则为左声道一个值，右声道一个值
 outWaveSize：输入输出型参数，传入outWaveFormBuffer的空间大小，通过getProcessSafeBufferSize 返回一个足够的大小
 */
int processRMAudio(RMAudioProcess handle, char *inData, int inDataSize, char * outData, int *outDataSize, char* outWaveFormBuffer, int *outWaveSize);



/**
 *创建重采样
 nInSampleRate :输入采样率
 nOutSampleRate：输出采样
 nChannel: 输入采样的通道数
 */

RMResample RMResample_Open(int nInSampleRate, int nOutSampleRate, int nChannel);

/**
 *重采样处理
 handle：重采样具柄
 pInBuf：输入PCM，必须为16位采样
 inSampLen：输入PCM 样点数，如果单通道则为pInBuf的大小除以2，如果是双通道，则为pInBuf/4
 nInBuffUsedSamp： 输出PCM 已使用重采样的长度;
 pOutBuf: 重采样后的PCM
 OutBufSampLen ：传入pOutBuf的样点大小，计算方式同inSampLen
 nLastFlag：是否最后一个一段 最后的时候传入1；
 */

int RMResample_Process(RMResample handle, short * pInBuf, int inSampLen, int * nInBuffUsedSamp, short * pOutBuf, int OutBufSampLen, int nLastFlag);

/**
 *关闭重采样
 handle：重采样具柄
 */
void RMResample_Close(RMResample handle);
    
#ifdef __cplusplus
}        /* extern "C" */
#endif    /* __cplusplus */

#endif /* RMAudioProcess_h */
