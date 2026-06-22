/**
* @brief NTSSパケット収集アプリケーション用設定情報管理ヘッダーファイル
*
* @details NTSSパケット収集アプリケーションの設定情報を管理する
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_devicecap_conf.h
* @author H.Yonezawa
* @date 2017/11/01
*/

#ifndef NTSS_DEVICECAP_CONF_H
#define NTSS_DEVICECAP_CONF_H


#include <stdint.h>
#include <sys/types.h>
#include <linux/types.h>

#include "../common/libs/ntss_etc_lib.h"

/// データ出力先：緊急発報用
#define NTSS_OUTPUT_FOLDER_M_NOTICE     0x00
/// データ出力先：データ収集
#define NTSS_OUTPUT_FOLDER_DATA_COLLECT 0x01


/// 各フォルダ最大定義件数
#define NTSS_FOLDER_DEFINE_MAX_COUNT 3


/// 設定情報用構造体
struct NTSS_DEVICECAP_CONF {
    /// 施設コード
    u_char cFacilityCode[7];
    /// デバイスエッジ番号
    short nDeviceEdgeNo;

    /// パケットキャプチャ関連
    /// パケット対象デバイス名
    u_char  cCaptureDevice[10];
    /// フィルタ設定
    u_char  cCaptureFilter[NTSS_STR_MAX_SIZE];
    
    /// 通信サーバー端末情報(xxx.xxx.xxx.xxx:99999形式文字列)
    u_char  cFnSV[NTSS_STR_MAX_SIZE];
    
    /// マスタファイル参照先フォルダ
    u_char  cMstFolder[NTSS_STR_MAX_SIZE];
    
    /// 緊急発報用ファイル格納先フォルダ([優先順位][バッファ数])
    u_char  cM_NoticeFolder[NTSS_FOLDER_DEFINE_MAX_COUNT][NTSS_STR_MAX_SIZE];
    
    /// データ収集用ファイル格納先フォルダ([優先順位][バッファ数])
    u_char  cDataCollectFolder[NTSS_FOLDER_DEFINE_MAX_COUNT][NTSS_STR_MAX_SIZE];

    /// プロセス番号
    int nOwnerProcessId;
    /// 装置死活監視間隔[秒]
    int nMachineAliveInterval;
    /// 前回死活監視日時
    time_t lastMachineAliveTime;

    /// 装置接続状態対象[0x00：変更分のみ/0x01：すべて]
    u_char cSendAllConnectionStatus;    

    /// 装置状態判定間隔[秒]
    int nCheckMachineStateInterval;    
    /// 前回装置状態判定日時
    time_t lastCheckMachineStateTime;

    /// 治療中モニタ送信間隔[秒]
    int nSendDialysisMonitorInterval;
    /// 前回治療中モニタ送信日時
    time_t lastSendDialysisMonitorTime;
    /// 未治療時モニタ送信間隔[秒]
    int nSendUntreatMonitorInterval;
    /// 前回未治療モニタ送信日時
    time_t lastSendUntreatMonitorTime;
};
extern struct NTSS_DEVICECAP_CONF devicecapConf;

/**
* @brief NTSSパケット収集設定ファイルを読み込む
*
* @details NTSSパケット収集アプリケーション用の設置ファイルを読み込む
*
* @description
* @return １：取得成功/else：取得失敗
* @attention 特になし
*/
extern int
getNTSSDeviceCapConf();

/**
* @brief NTSSパケット収集設定からデータ格納先フォルダを取得する
*
* @details NTSSパケット収集設定からデータ格納先フォルダを取得する
*
* @description
* @param[in] cOutputType    データ格納先種類[0x00:緊急発報用/0x01データ収集用:]
* @param[in] nPriority      優先順位(0>1>2)
* @return NULL：未設定/else：データ格納先フォルダ文字列のポインタ取得成功
* @attention 特になし
*/
extern u_char *
getNTSSDeviceCapDataFolder( u_char cOutputType 
                          , int nLevel
                          );

/**
* @brief 指定されたIPアドレス、ポート番号が通信サーバー情報に存在するかチェックする
*
* @details 指定された送信先IPアドレス、ポート番号が通信サーバー情報に存在するかチェックする
*
* @description
* @param[in] destAddr   送信先IPアドレス
* @param[in] destPortNo 送信先ポート番号
* @return 1：該当あり/0：該当なし
* @attention 特になし
*/
extern int
existFnSVInfo( __be32  destAddr
             , __be16  destPortNo
             );

#endif
