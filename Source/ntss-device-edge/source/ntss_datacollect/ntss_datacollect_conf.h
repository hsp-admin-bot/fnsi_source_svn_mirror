/**
* @brief NTSSデータ収集アプリケーション用設定情報管理ヘッダーファイル
*
* @details NTSSデータ収集アプリケーションの設定情報を管理する
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_datacollect_conf.h
* @author H.Yonezawa
* @date 2017/11/17
*/

#ifndef NTSS_DATACOLLECT_CONF_H
#define NTSS_DATACOLLECT_CONF_H


#include <stdint.h>
#include <sys/types.h>

#include "../common/libs/ntss_etc_lib.h"

/// 各フォルダ最大定義件数
#define NTSS_FOLDER_DEFINE_MAX_COUNT 3


/// 設定情報用構造体
struct NTSS_DATACOLLECT_CONF {

    // 共通設定

    // 施設コード
    u_char  cFacilityCd[10];
    // マスタファイル参照先フォルダ
    u_char  cMstFolder[ NTSS_STR_MAX_SIZE ];
    // データ収集用ファイル格納先フォルダ([優先順位][バッファ数])
    u_char  cDataCollectFolder[NTSS_FOLDER_DEFINE_MAX_COUNT][NTSS_STR_MAX_SIZE];    


    // 個別設定

    // 作業用ファイル格納先フォルダ([優先順位][バッファ数])
    u_char  cWorkFolder[NTSS_FOLDER_DEFINE_MAX_COUNT][NTSS_STR_MAX_SIZE];
	
    // 装置FTPフォルダ
    u_char cFTP_Folder[NTSS_STR_MAX_SIZE];
	// FTPユーザー名
    u_char cFTP_User[NTSS_STR_MAX_SIZE];
	// FTPパスワード
    u_char cFTP_PW[NTSS_STR_MAX_SIZE];
	// FTPウエイト秒数
    uint16_t nFTP_Wait;
	// FTPリトライ回数
    uint16_t nFTP_Retry;

	// 圧縮パスワード
    u_char cZipPW[NTSS_STR_MAX_SIZE];
    
    // アップロードファイル最大サイズ[MB単位]
    uint16_t nUploadFileMaxSize;
/*
    // IAMユーザーキー
    u_char cAWSIAMUserKey[NTSS_STR_MAX_SIZE];
    // IAMシークレットキー
    u_char cAWSIAMUserSecretKey[NTSS_STR_MAX_SIZE];
    // APIキー
    u_char cAWSAPIKey[NTSS_STR_MAX_SIZE];
    // AWSリージョン
    u_char cAWSRegion[NTSS_STR_MAX_SIZE];
    // AWSサービス名
    u_char cAWSServiceName[NTSS_STR_MAX_SIZE];
    // AWSホスト名
    u_char cAWSHostName[NTSS_STR_MAX_SIZE];
    // AWSアドレス
    u_char cAWSAddress[NTSS_STR_MAX_SIZE];
    // ファイルセキュリティ
    u_char cAWSFileSecurity[NTSS_STR_MAX_SIZE];
*/
    // AWSホスト名
    u_char cAWSHostName[NTSS_STR_MAX_SIZE];
    // AWSアドレス
    u_char cAWSAddress[NTSS_STR_MAX_SIZE];

    // アップロードリトライ回数
    int nUploadRetryCount;
    // アップロードリトライ待ち時間
    int nUploadRetryWaitTime;

    // アップロード先パス名
    u_char cUploadPath[NTSS_STR_MAX_SIZE];
    
    // プロセス番号
    int nOwnerProcessId;
    // シーケンス番号
    u_char cDataCollectSeqNo[20];
    // 装置指定ファイル名
    u_char cMachineListFile[NTSS_STR_MAX_SIZE];

    // 処理開始日時[YYYYMMDDHHNNSS形式]
    u_char cStartDateTime[15];
};
extern struct NTSS_DATACOLLECT_CONF datacollectConf;

/**
* @brief NTSSデータ収集設定ファイルを読み込む
*
* @details NTSSデータ収集アプリケーション用の設置ファイルを読み込む
*
* @description
* @return １：取得成功/else：取得失敗
* @attention 特になし
*/
extern int
getNTSSDataCollectConf();

#endif
