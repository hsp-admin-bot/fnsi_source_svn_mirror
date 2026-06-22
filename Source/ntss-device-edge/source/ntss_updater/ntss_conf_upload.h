/**
* @brief NTSS confフォルダのアップロード処理ヘッダーファイル
*
* @details NTSS confフォルダをアップロードする
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_conf_upload.c
* @author Y.Kataguchi
* @date 2018/09/11
*/

#ifndef NTSS_CONF_UPLOAD_H
#define NTSS_CONF_UPLOAD_H

/**
* @brief NTSS confアップロード作業用フォルダを作成
*
* @details NTSS confアップロード作業用フォルダを作成する
*
* @description
* @param[in] *cWorkFolder 作業用フォルダ名
* @return １：作成成功/else：作成失敗
* @attention 特になし
*/
extern int
makeNTSSConfUploadWorkFolder(u_char *cWorkFolder);

/**
* @brief 作業用フォルダ内のファイルを圧縮する
*
* @details 作業用フォルダ内のファイルを圧縮する
*
* @description
* @param[in] *cWorkFolder   作業用フォルダ名
* @param[in] *cPW           圧縮パスワード
* @param[in] *cFileName     圧縮ファイル名
* @return 1：処理成功/else：処理失敗
* @attention 圧縮に成功した場合は圧縮元のファイルを削除する
*/
extern int
zipNTSSConfFiles(u_char *cWorkFolder, u_char *cPW, u_char *cFileName);

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
uploadNTSSConfFile(u_char *cWorkFolder, u_char *cUploadHost, u_char *cUploadAPI, u_char *cUploadJoinAPI, u_char *cUploadPath, uint16_t nUploadFileMaxSize, int nUploadRetryCount, int nUploadRetryWaitTime);

/**
* @brief Confファイルをアップロードする
*
* @details Confファイルをアップロードする
*
* @description
* @param[in] configParam    設定情報
* @attention 当日分以外のログファイルはアップロードに成功した場合は削除される
*/
int uploadNTSSConf(ConfigParameter_t *configParam, int useFolderIdx, u_char *cFileName);

#endif