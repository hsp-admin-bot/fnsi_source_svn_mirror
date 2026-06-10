/**
* @brief NTSSデータ収集アプリケーション用汎用処理ヘッダーファイル
*
* @details NTSSデータ収集アプリケーションの汎用処理
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_datacollect_etc.h
* @author H.Yonezawa
* @date 2017/11/22
*/

#ifndef NTSS_DATACOLLECT_ETC_H
#define NTSS_DATACOLLECT_ETC_H


#include "ntss_machine_info.h"

#include "../common/libs/ntss_log_lib.h"


/// NTSSファイル移動処理モード
typedef enum NTSS_MOVENTSSFILES_MODE {
    /// FN通信データモード(末尾に追記する)
    NTSS_MOVENTSSFILES_MODE_FN,
    /// FTP収集データモード(日付の新しい方を残す)
    NTSS_MOVENTSSFILES_MODE_FTP
} NtssMoveNtssFilesMode;


/**
* @brief NTSSデータ収集作業用フォルダ、並びに指定装置作業用フォルダを作成
*
* @details NTSSデータ収集作業用フォルダとその中に装置作業用フォルダを作成する
*
* @description
* @param[in] *cWorkFolder       作業用フォルダ名
* @param[in] *cMachineName      装置名
* @param[out] *cMachineFolder   装置作業用フォルダ名
* @return １：作成成功/else：作成失敗
* @attention 特になし
*/
extern int
makeNTSSDataCollectWorkFolder( u_char *cWorkFolder
                             , u_char *cMachineName
                             , u_char *cMachineFolder
                             );

/**
* @brief 移動元フォルダから移動先フォルダに指定リストファイル内のファイルを移動する
*
* @details 移動元フォルダから移動先フォルダに指定リストファイル内のファイルを移動する
*
* @description
* @param[in] *cSourceFolder 移動元フォルダ名
* @param[in] *cDestFolder   移動先フォルダ名
* @param[in] *cListFileName 処理対象ファイルが記載されたファイル名
* @param[in] mode           移動先に同じファイル名がすでに存在している場合の処理[NTSS_MOVENTSSFILES_MODE_FN：FN通信データモード(末尾に追記する)/NTSS_MOVENTSSFILES_MODE_FTP：FTP収集データモード(日付の新しい方を残す)]
* @param[in] *info          データ収集管理情報
* @return 1：移動成功/else：移動失敗(リストファイルなし、移動元フォルダなし、移動先フォルダなし含む)
* @attention 特になし
*/
extern int
moveNTSSFiles( u_char *cSourceFolder
             , u_char *cDestFolder
             , u_char *cListFileName 
             , NtssMoveNtssFilesMode mode
             , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
             );

/**
* @brief 移動元作業用フォルダから移動先作業フォルダにFTP収集データ、FN通信データを移動する
*
* @details 移動元作業用フォルダから移動先作業フォルダにFTP収集データ、FN通信データを移動する
*
* @description
* @param[in] *cSourceWorkFolder 移動元作業用フォルダ名
* @param[in] *cDestFolder       移動先作業用フォルダ名(装置作業用フォルダ)
* @param[in] *cMachineName      装置名
* @param[in] *info              データ収集管理情報
* @return 1：移動成功/else：移動失敗
* @attention 特になし
*/
extern int
moveNTSSDataCollectWorkFolderFile( u_char *cSourceFolder
                                 , u_char *cDestFolder
                                 , u_char *cMachineName
                                 , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
                                 );

/**
* @brief 移動元フォルダから移動先フォルダに指定装置のFN通信データを移動する
*
* @details 移動元フォルダから移動先フォルダに指定装置のFN通信データを移動する
*
* @description
* @param[in] *cSourceWorkFolder 移動元フォルダ名
* @param[in] *cDestFolder       移動先フォルダ名(装置作業用フォルダ)
* @param[in] *cGrepPattern      装置抽出用パターン文字列
* @param[in] *cWorkFolder       作業用フォルダ
* @param[in] *info              データ収集管理情報
* @return 1：移動成功(対象フォルダやファイルがない場合含む)/else：移動失敗
* @attention 特になし
*/
extern int
moveNTSSDataCollectFNFile( u_char *cSourceFolder
                          , u_char *cDestFolder
                          , u_char *cGrepPattern
                          , u_char *cWorkFolder
                          , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
                          );
/**
* @brief 指定条件でFTPデータ収集を行う
*
* @details 指定条件でFTPデータ収集を行う
*
* @description
* @param[in] *cURL          FTP接続先情報
* @param[in] *cUSER         ユーザID
* @param[in] *cPW           パスワード
* @param[in] *cLogFolder    ログ格納先フォルダ
* @param[in] *cDataFolder   データ格納先フォルダ
* @param[in] nWaitSecond    ファイル一覧を再取得するときの待ち時間
* @param[in] nRetryCount    リトライ回数
* @param[in] *info          データ収集管理情報
* @return 0：作成成功/else：作成失敗
* @attention 特になし
*/
extern int
getNTSSFTP( u_char *cURL
          , u_char *cUSER
          , u_char *cPW
          , u_char *cLogFolder
          , u_char *cDataFolder
          , int nWaitSecond
          , int nRetryCount
          , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
          );


/**
* @brief データ収集管理情報のログ出力を行う
*
* @details データ収集管理情報のログ出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @param[in] flag   出力フラフ（0:通常,1:システム情報有り）
* @param[in] *info  データ収集管理情報
* @return なし
* @attention 特になし
*/
extern void
outputNTSSDataCollectMachineInfoLog( NtssLogType type
                                   , u_char *msg 
                                   , int flag
                                   , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
                                   );

/**
* @brief データ収集管理情報のエラーログ出力を行う
*
* @details データ収集管理情報のエラーログ出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @param[in] flag   出力フラフ（0:通常,1:システム情報有り）
* @param[in] *info  データ収集管理情報
* @return なし
* @attention 特になし
*/
extern void
outputNTSSDataCollectMachineInfoErrorLog( u_char *msg 
                                        , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
                                        );

#endif