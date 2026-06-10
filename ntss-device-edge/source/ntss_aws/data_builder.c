#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>

#include "../common/libs/master_controller.h"
#include "struct_data.h"
#include "config_read.h"
#include "data_builder.h"

/**
 * @brief 
 * Byteデータ => 16進数文字列 
 * @param bs 
 * @return *   
 */
bool bytesToString(uint8_t *byteStr, const uint8_t byteData)
{
    sprintf(byteStr, "%02x", byteData);

    return true;
}

/**
 * @brief 
 * 
 * 型式コードを取得
 * 
 * @param msg
 * @param devCode3
 * 
 * @return int32_t
 */
int32_t findDeviceCode(uint8_t *devCode, MessageData_t *msg)
{

    int32_t i;
    for (i = 0; i < 3; i++)
    {
        devCode[i] = msg->machineTypeCode[i];
    }
    return i;
}

/**
 * @brief 
 * 
 * 発生日時を取得して返す
 * 
 * @param msg
 * @param popDate7
 * 
 * @return int32_t
 */
int32_t getPopDate(uint8_t *popDate, MessageData_t *msg)
{

    int32_t i = 0;
    if (msg->type == MESSAGE_TYPE_IS_NKK)
    {
        // 日機装通信時はデータ部の4byte目からBCD
        for (i = 0; i < 7; i++)
        {
            popDate[i] = msg->data[i + 3];
        }
    }
    else if (msg->type == MESSAGE_TYPE_IS_NX)
    {
        // NX通信時はデータ部の7byte目からBCD　ただし秒だけ00ss形式
        for (i = 0; i < 6; i++)
        {
            popDate[i] = msg->data[i + 6];
        }
        // 00ssの00を読み飛ばす
        popDate[i] = msg->data[i + 6 + 1];
    }
    return i;
}

/**
 * @brief 
 * 
 * 装置記録コードを取得
 * 
 * @param msg
 * @param catCode2
 * 
 * @return int32_t
 */
int32_t getMsgMachineRecordCode(uint8_t *catCode, MessageData_t *msg)
{

    // 4byte ASCII
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    //uint8_t code1[2] = {0};
    //uint8_t code2[2] = {0};
    uint8_t code1[3] = {0};
    uint8_t code2[3] = {0};
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
    // mod FNSI-バグ 通信サーバ 高 start
    // if (msg->type == MESSAGE_TYPE_IS_NKK)
    if (msg->type == MESSAGE_TYPE_IS_NKK || msg->type == MESSAGE_TYPE_IS_V4)
    // mod FNSI-バグ 通信サーバ 高 end
    {
        // NKK通信の場合はデータ部の先頭に装置記録コード
        bytesToString(code1, msg->data[1]);
        bytesToString(code2, msg->data[2]);
    }
    else if (msg->type == MESSAGE_TYPE_IS_NX)
    {
        // NX通信の場合はデータ部の5,6バイト目に装置記録コード
        bytesToString(code1, msg->data[4]);
        bytesToString(code2, msg->data[5]);
    }

    int32_t i;
    for (i = 0; i < 2; i++)
    {
        catCode[i] = toupper(code1[i]);
        catCode[i + 2] = toupper(code2[i]);
    }
    return i;
}

/**
 * @brief 日機装通信の補助データを取得
 * 
 * @param subData 
 * @param msg 
 * @return int32_t 
 */
int32_t getSubData(uint8_t *subData, MessageData_t *msg)
{

    // 2byte * 4
    int32_t i;
    for (i = 0; i < 8; i++)
    {
        subData[i] = msg->data[i + 12];
    }
    return i;
}

/**
 * @brief 
 * 
 * アップロード対象かどうかをチェックする
 * 
 * @param msg
 * 
 * @return bool
 */
bool isSendTarget(MessageData_t *msg, u_char *rcdFilePath)
{
    bool ret = false;
    FILE *fp;
    uint8_t catCode[5] = {0};
    u_char command[512] = {0}, buf[256] = {0};
    getMsgMachineRecordCode(catCode, msg);

    catCode[4] = 0x00;
    sprintf(command, "grep -xil %s %s", catCode, rcdFilePath);
    if ((fp = popen(command, "r")) != NULL)
    {
        if (fgets(buf, 256, fp) != NULL)
        {
            // 末尾の改行コード削除
            buf[strlen(buf) - 1] = 0;
            if(existFolderFile(buf, NULL ) == 1)
            {
                // grep対象リストをgrepした結果一致するものがあればtrueを返すようにする
                ret = true;
            }
        }
        pclose(fp);
    }

    // 送信対象リストをgrepした結果を返す
    return ret;
}

/**
 * @brief 
 * 
 * アップロード用電文を構築する
 * 
 * @param msg
 * @param sendData
 * 
 * @return int32_t length
 */
int32_t buildSendData(u_char *sendData, MessageData_t *msg, ConfigParameter_t *configParam)
{

    int32_t cnt = 0, diff = 0, length = 0;
    uint16_t blockSize;
    u_char csum = 0x00;

    // 機種 3byte
    blockSize = 3;
    u_char devCode[blockSize];
    memset(devCode, 0, blockSize);
    findDeviceCode(devCode, msg);
    for (cnt = 0; cnt < blockSize; cnt++)
    {
        sendData[cnt] = devCode[cnt];
        length++;
    }
    // 通信フォーマット 1byte
    diff += blockSize;
    blockSize = 1;
    sendData[0 + diff] = msg->fmt[0];
    length++;
    // 製造番号 8byte
    diff += blockSize;
    blockSize = 8;
    for (cnt = 0; cnt < blockSize; cnt++)
    {
        sendData[cnt + diff] = msg->dnd[cnt];
        length++;
    }
    // 施設コード　6byte (ASCII)
    diff += blockSize;
    blockSize = 6;
    for (cnt = 0; cnt < blockSize; cnt++)
    {
        sendData[cnt + diff] = configParam->facilityCode[cnt];
        length++;
    }
    // 発生日時
    diff += blockSize;
    blockSize = 7;
    u_char popDate[blockSize];
    memset(popDate, 0, blockSize);
    getPopDate(popDate, msg);
    for (cnt = 0; cnt < blockSize; cnt++)
    {
        sendData[cnt + diff] = popDate[cnt];
        length++;
    }
    // 装置記録コード
    diff += blockSize;
    blockSize = 4;
    u_char catCode[blockSize];
    memset(catCode, 0, blockSize);
    getMsgMachineRecordCode(catCode, msg);
    for (cnt = 0; cnt < blockSize; cnt++)
    {
        sendData[cnt + diff] = catCode[cnt];
        length++;
    }

    // 装置記録補助データ
    diff += blockSize;
    if (msg->type == MESSAGE_TYPE_IS_NKK)
    {
        // 日機装通信
        blockSize = 8;
        u_char subData[blockSize];
        memset(subData, 0, blockSize);
        getSubData(subData, msg);
        for (cnt = 0; cnt < blockSize; cnt++)
        {
            sendData[cnt + diff] = subData[cnt];
            length++;
        }
    }
    else if (msg->type == MESSAGE_TYPE_IS_V4)
    {
        // TODO:通信共通プロトコル
    }
    else if (msg->type == MESSAGE_TYPE_IS_NX)
    {
        // NX通信
        blockSize = 34;
        for (cnt = 0; cnt < blockSize; cnt++)
        {
            sendData[cnt + diff] = msg->data[cnt + 14];
            length++;
        }
    }

    // チェックサム計算
    for (cnt = 0; cnt < length; cnt++)
    {
        csum += sendData[cnt];
    }
    sendData[length] = csum;
    length++;

    return length;
}