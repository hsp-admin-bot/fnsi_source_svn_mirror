#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "master_controller.h"
#include "ntss_etc_lib.h"

/**
 * @brief 受信電文の内容をファイルに記録する
 * 
 * @param receiveShadowMachineRecords machineRecords設定電文
 * @param dataSize データサイズ
 * @return true 書き込み成功
 * @return false 書き込み失敗
 */
bool writeMachineRecordCd(u_char *receiveShadowMachineRecords, uint16_t dataSize, u_char *filePath){

    outputFile(filePath, receiveShadowMachineRecords, dataSize);
}

/**
 * @brief machineRecordsの内容をファイルから読み込んでGREP用マスタファイルを作成
 * 
 * @param filePath 取得マスタファイルパス
 * @param outFileName 生成ファイルパス
 * @return true 
 * @return false 
 */
bool readMachineRecordCd(u_char *filePath, u_char *outFileName)
{
    int32_t dataLen;
    uint32_t dataNum = 0;
    u_char buff1[1];
    u_char machineRecord[4 + 1];
    u_char v4Msg[50 + 1];
    uint32_t i, j, v4idx = 0;
    u_char logMessage[128];

    // バイナリモードで読込ファイルオープン
    FILE *fpr = fopen(filePath, "rb");
    if(fpr == NULL){
        return false;
    }else{
        outputFile(outFileName, "", 0);
        for(;;)
        {
            for (i = 0; i < 4; i++)
            {
                dataLen = fread(buff1, 1, 1, fpr);
                if (dataLen == 0)
                {
                    // ４桁取得できないと終了
                    v4idx = -1;
                    break;
                }
                else if (buff1[0] == '_')
                {
                    // アンダーバーが出たら次からV4
                    v4idx = 1;
                    break;
                }
                machineRecord[i] = toupper(buff1[0]);
            }
            if (v4idx != 0)
            {
                // 装置記録コード終了
                break;
            }
            machineRecord[4] = '\0';
            dataNum++;
            snprintf(logMessage, 128, "[%d]:%s", dataNum, machineRecord);
            LogOutput(NTSS_LOG_INFO, logMessage);

            // ファイル出力 + 改行
            outputAppendFile(outFileName, machineRecord, strlen(machineRecord));
            outputAppendFile(outFileName, "\n", strlen("\n"));
        }
        if (v4idx > 0)
        {
            for(;;)
            {
                for (i = 0; i < 4; i++)
                {
                    dataLen = fread(buff1, 1, 1, fpr);
                    if (dataLen == 0)
                    {
                        // ４桁取得できないと終了
                        break;
                    }
                    machineRecord[i] = toupper(buff1[0]);
                }
                dataLen = fread(v4Msg, 1, 50, fpr);
                if (dataLen < 50)
                {
                    break;
                }
                machineRecord[4] = '\0';
                v4Msg[50] = '\0';
                dataNum++;
                snprintf(logMessage, 128, "[%d]:%s%s", dataNum, machineRecord, v4Msg);
                LogOutput(NTSS_LOG_INFO, logMessage);
                // ファイル出力 + 改行
                outputAppendFile(outFileName, machineRecord, strlen(machineRecord));
                outputAppendFile(outFileName, v4Msg, strlen(v4Msg));
                outputAppendFile(outFileName, "\n", strlen("\n"));
            }
        }

        fclose(fpr);

        return true;
    }

}

bool writeMachineInfo(MachineInfo_t *machineInfoData, uint16_t dataSize, char *filePath){
    // 構造体出力
    outputFile(filePath, (u_char *)machineInfoData, dataSize);
}

bool readMachineInfo(MachineInfo_t *machineInfoData, uint16_t dataSize, char *filePath){
    // 構造体読込
    // バイナリモードで読込ファイルオープン
    FILE *fpr = fopen(filePath, "rb");
    if(fpr == NULL){
        return false;
    }else{
        // 構造体の配列に読込
        fread(machineInfoData, 1, dataSize, fpr);
        fclose(fpr);

        return true;
    }
}

uint16_t 
setMachineInfo(MachineInfo_t *machineInfoData, const char *receiveShadowMachineInfo, uint16_t maxSize){

    uint16_t oneDataLen =  3 + 1 + 8 + 15 + 5 + 1 + 1;
    uint16_t dataSize = (uint16_t)strlen(receiveShadowMachineInfo) / sizeof(MachineInfo_t);
    uint16_t i, diff;
    for(i = 0; i < maxSize && i < dataSize; i++){
        diff = 0;
        memcpy(machineInfoData[i].machineTypeCd, receiveShadowMachineInfo + (oneDataLen * i + diff), 3);
        diff += 3;
        memcpy(&(machineInfoData[i].machineFormatCd), receiveShadowMachineInfo + (oneDataLen * i + diff), 1);
        diff += 1;
        memcpy(machineInfoData[i].machineSerial, receiveShadowMachineInfo + (oneDataLen * i + diff), 8);
        diff += 8;
        memcpy(machineInfoData[i].ipAddress, receiveShadowMachineInfo + (oneDataLen * i + diff), 15);
        diff += 15;
        memcpy(machineInfoData[i].strport, receiveShadowMachineInfo + (oneDataLen * i + diff), 5);
        diff += 5;
        memcpy(&(machineInfoData[i].hasFtp), receiveShadowMachineInfo + (oneDataLen * i + diff), 1);
        diff += 1;
        memcpy(&(machineInfoData[i].machineCommCd), receiveShadowMachineInfo + (oneDataLen * i + diff), 1);
    }

    return i;
}

bool writeMachineInfo2(MachineInfo2_t *machineInfoData, uint16_t dataSize, char *filePath){
    // 構造体出力
    outputFile(filePath, (u_char *)machineInfoData, dataSize);
}

bool readMachineInfo2(MachineInfo2_t *machineInfoData, uint16_t dataSize, char *filePath){
    // 構造体読込
    // バイナリモードで読込ファイルオープン
    FILE *fpr = fopen(filePath, "rb");
    if(fpr == NULL){
        return false;
    }else{
        // 構造体の配列に読込
        fread(machineInfoData, 1, dataSize, fpr);
        fclose(fpr);

        return true;
    }
}

uint16_t 
setMachineInfo2(MachineInfo2_t *machineInfoData, const char *receiveShadowMachineInfo, uint16_t maxSize){

    uint16_t oneDataLen =  8 + 3 + 1 + 8 + 15 + 5 + 1 + 1 + 1 + 4 + 4 + 4 + 4 + 4;
    uint16_t dataSize = (uint16_t)strlen(receiveShadowMachineInfo) / sizeof(MachineInfo_t);
    uint16_t i, diff;
    for(i = 0; i < maxSize && i < dataSize; i++){
        diff = 0;
        memcpy(machineInfoData[i].machineNo, receiveShadowMachineInfo + (oneDataLen * i + diff), 8);
        diff += 8;
        memcpy(machineInfoData[i].machineTypeCd, receiveShadowMachineInfo + (oneDataLen * i + diff), 3);
        diff += 3;
        memcpy(&(machineInfoData[i].machineFormatCd), receiveShadowMachineInfo + (oneDataLen * i + diff), 1);
        diff += 1;
        memcpy(machineInfoData[i].machineSerial, receiveShadowMachineInfo + (oneDataLen * i + diff), 8);
        diff += 8;
        memcpy(machineInfoData[i].ipAddress, receiveShadowMachineInfo + (oneDataLen * i + diff), 15);
        diff += 15;
        memcpy(machineInfoData[i].strport, receiveShadowMachineInfo + (oneDataLen * i + diff), 5);
        diff += 5;
        memcpy(&(machineInfoData[i].machineCommCd), receiveShadowMachineInfo + (oneDataLen * i + diff), 1);
        diff += 1;
        memcpy(&(machineInfoData[i].hasFtp), receiveShadowMachineInfo + (oneDataLen * i + diff), 1);
        diff += 1;
        memcpy(&(machineInfoData[i].hasVa), receiveShadowMachineInfo + (oneDataLen * i + diff), 1);
        diff += 1;
        memcpy(&(machineInfoData[i].machineOptine1), receiveShadowMachineInfo + (oneDataLen * i + diff), 4);
        diff += 4;
        memcpy(&(machineInfoData[i].machineOptine2), receiveShadowMachineInfo + (oneDataLen * i + diff), 4);
        diff += 4;
        memcpy(&(machineInfoData[i].machineOptine3), receiveShadowMachineInfo + (oneDataLen * i + diff), 4);
        diff += 4;
        memcpy(&(machineInfoData[i].machineOptine4), receiveShadowMachineInfo + (oneDataLen * i + diff), 4);
        diff += 4;
        memcpy(&(machineInfoData[i].machineOptine5), receiveShadowMachineInfo + (oneDataLen * i + diff), 4);
    }

    return i;
}


/**
 * @brief 本体揮発領域の保存処理(非同期)
 * 
 * @param kind 保存先区分
 */
void overlayDataSave(NtssEdgeOverlayKind kind){

    // #8167 del 2023.3.2 overlay処理を廃止 Y.Takamura start
    /*
    switch( kind )
    {
        case NTSS_EDGE_OVERLAY_KIND_NONE:
        break;
        case NTSS_EDGE_OVERLAY_KIND_ETC:
			system("overlaycfg -s etc -u &");
        break;
        case NTSS_EDGE_OVERLAY_KIND_HOME:
			system("overlaycfg -s home -u &");
        break;
        case NTSS_EDGE_OVERLAY_KIND_LOG:
			system("overlaycfg -s log -u &");
        break;
        case NTSS_EDGE_OVERLAY_KIND_OTHER:
			system("overlaycfg -s other -u &");
        break;
    }
    */
    // #8167 del 2023.3.2 overlay処理を廃止 Y.Takamura end
}