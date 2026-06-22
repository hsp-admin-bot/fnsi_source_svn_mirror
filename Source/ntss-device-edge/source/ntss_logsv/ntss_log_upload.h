/**
* @brief NTSSログファイルのアップロード処理ヘッダーファイル
*
* @details NTSSログファイルをアップロードする
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_log_upload.c
* @author H.Yonezawa
* @date 2018/07/20
*/

#ifndef NTSS_LOG_UPLOAD_H
#define NTSS_LOG_UPLOAD_H

#include "logsv_config.h"

/**
* @brief NTSSログアップロード作業用フォルダを作成
*
* @details NTSSログアップロード作業用フォルダを作成する
*
* @description
* @param[in] *cWorkFolder 作業用フォルダ名
* @return １：作成成功/else：作成失敗
* @attention 特になし
*/
extern int
makeNTSSLogUploadWorkFolder( u_char *cWorkFolder
                            );

/**
* @brief 移動元フォルダから移動先フォルダに移動元フォルダ内の全ファイルを移動
*
* @details 移動元フォルダから移動先フォルダに移動元フォルダ内の全ファイルを移動する
*
* @description
* @param[in] *cSourceFolder 移動元フォルダ名
* @param[in] *cDestFolder   移動先フォルダ名
* @param[in] nTodayCopy     当日コピーフラグ(ファイル名に当日が含まれている場合にど鵜するかを指定する 0:移動/1:コピー)
* @return 1：移動成功/else：移動失敗(リストファイルなし、移動元フォルダなし、移動先フォルダなし含む)
* @attention 移動先に同名ファイルがあった場合は日付の後ろに2桁の枝番をつける
*/
extern int
moveNTSSLogFiles( u_char *cSourceFolder
                , u_char *cDestFolder
                , int nTodayCopy 
                );

/**
* @brief 作業用フォルダ内のログファイルを日付別に圧縮する
*
* @details 作業用フォルダ内のログファイルを日付別に圧縮する
*
* @description
* @param[in] *cWorkFolder   作業用フォルダ名
* @param[in] *cPW           圧縮パスワード
* @return 1：処理成功/else：処理失敗
* @attention 圧縮に成功した場合は圧縮元のファイルを削除する
*/
extern int
zipNTSSLogFiles( u_char *cWorkFolder
               , u_char *cPW
               );

/**
* @brief 作業用フォルダ内のZIPファイルをアップロード
*
* @details 作業用フォルダ内のZIPファイルをアップロードする
*
* @description
* @param[in] *cWorkFolder           作業用フォルダ名
* @param[in] nUploadHost            アップロードホスト名
* @param[in] nUploadAPI             アップロードAPI
* @param[in] nUploadJoinAPI         アップロードファイル結合API
* @param[in] *cUploadPath           アップロード先パス名
* @param[in] nUploadFileMaxSize     アップロードファイル最大サイズ
* @param[in] nUploadRetryCount      アップロードリトライ回数
* @param[in] nUploadRetryWaitTime   アップロードリトライ待ち時間
* @return 1：処理成功/else：処理失敗
* @attention アップロードに成功した場合はZIPファイルを削除する
*/
extern int
uploadNTSSLogFiles( u_char *cWorkFolder
                  , u_char *cUploadHost
                  , u_char *cUploadAPI
                  , u_char *cUploadJoinAPI
                  , u_char *cUploadPath
                  , uint16_t nUploadFileMaxSize
                  , int nUploadRetryCount
                  , int nUploadRetryWaitTime
                  );

/**
* @brief ログファイルをアップロードする
*
* @details ログファイルをアップロードする
*
* @description
* @param[in] configParam    設定情報
* @attention 当日分以外のログファイルはアップロードに成功した場合は削除される
*/
int uploadNTSSLog( ConfigParameter_t *configParam
                 );

#endif