/**
* @brief NTSSデータ収集処理対象装置情報処理ヘッダーファイル
*
* @details NTSSデータ収集処理対象装置情報を管理する
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_machine_info.h
* @author H.Yonezawa
* @date 2017/11/21
*/

#ifndef NTSS_MACHINE_INFO_H
#define NTSS_MACHINE_INFO_H


#include <stdbool.h>

#include "../common/libs/master_controller.h"


/// 処理対象装置情報最大件数(200台分)
#define NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT 200

/// データ収集対象装置管理情報用構造体
struct NTSS_DATACOLLECT_MACHINE_INFORMATION {
    u_char  cCommTypeCd;    ///< 通信方式('0':通信なし/'1':新通信/'2'：NX通信/'3':通信共通V4)

    u_char  cDeviceType[3]; ///< 型式コード[3]
    u_char  cDeviceFormat;  ///< 通信フォーマット(機種)[1]
    u_char  cDeviceNo[8];   ///< 製造番号[8]
    u_char  cIPAddr[15];    ///< 装置IPアドレス

    u_char  cIsFTPCollect;  ///< FTP収集対象['0'：収集しない/'1'：収集する]

    u_char  cFNCode;        ///< FN処理結果
    u_char  cFTPCode;       ///< FTP処理結果
    u_char  cStatus;        ///< 処理状態[0x00：未処理/0x01：データ収集開始/0x02：データ収集完了/0x03：ファイル転送開始/0x04：ファイル転送完了]
};


/**
* @brief データ収集対象装置管理情報を作成する
*
* @details データ収集対象装置管理情報を作成する
*
* @description
* @param[in] *cFolder       マスタファイル格納先フォルダ
* @param[in] *cListFileName 装置指定ファイル名
* @return 1：初期化成功/else：初期化失敗
* @attention 特になし
*/
extern int
initNTSSDataCollectMahineInfo( u_char *cFolder
                             , u_char *cListFileName
                             );


/**
* @brief データ収集対象装置管理情報を追加する
*
* @details 指定した装置情報をデータ収集対象装置管理情報に追加する
*
* @description
* @param[in] *deviceInfo    装置マスタ情報
* @return NULL：追加失敗/else：追加した情報ポインタ
* @attention 特になし
*/
extern struct NTSS_DATACOLLECT_MACHINE_INFORMATION *
AddNTSSDataCollectMachineInfo( MachineInfo_t *deviceInfo
                             );


/**
* @brief 指定Indexのデータ収集対象装置管理情報を取得する
*
* @details 指定したIndex位置のデータ収集対象装置管理情報を取得する
*
* @description
* @param[in] nIndex     取得を行うIndex位置
* @return NULL：該当なし/else：該当した情報ポインタ
* @attention 特になし
*/
extern struct NTSS_DATACOLLECT_MACHINE_INFORMATION *
getNTSSDataCollectMachineInfo( int nIndexNo );

#endif
