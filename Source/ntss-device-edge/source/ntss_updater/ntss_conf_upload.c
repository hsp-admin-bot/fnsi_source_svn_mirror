/**
* @brief NTSS設定ファイルのアップロード処理ファイル
*
* @details NTSS設定ファイルをアップロードする
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_conf_upload.c
* @author Y.Kataguchi
* @date 2018/09/11
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <linux/types.h>
#include <arpa/inet.h>
#include <errno.h>
#include <sys/stat.h>

#include "struct_data.h"
#include "ntss_conf_upload.h"
#include "config_read.h"

#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_upload_lib.h"
#include "../common/libs/ntss_log_lib.h"

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
int makeNTSSConfUploadWorkFolder(u_char *cWorkFolder)
{
    int ret = 0;
    u_char cWork[NTSS_STR_MAX_SIZE];
    u_char cWork2[NTSS_STR_MAX_SIZE];

    // 作業用フォルダ存在確認
    if (existFolderFile(cWorkFolder, NULL) == 0)
    {
        // なし

        // 対象フォルダ作成
        if (createFolder(cWorkFolder) != 1)
        {
            // 作成失敗
            return ret;
        }
    }

    // アップロード用フォルダの存在確認
    sprintf(
        cWork, "%s/WORK", cWorkFolder);
    if (existFolderFile(cWork, NULL) == 0)
    {
        // なし

        // 対象フォルダ作成
        if (createFolder(cWork) != 1)
        {
            // 作成失敗
            return ret;
        }
    }

    // 作業用フォルダの末尾に'/'追加
    addFolderSeparator(cWork);

    // 圧縮用フォルダの存在確認
    sprintf(
        cWork2, "%sZIP", cWork);
    if (existFolderFile(cWork2, NULL) == 0)
    {
        // なし

        // 対象フォルダ作成
        if (createFolder(cWork2) != 1)
        {
            // 作成失敗
            return ret;
        }
    }

    // アップロード用フォルダの存在確認
    sprintf(
        cWork2, "%sUP", cWork);
    if (existFolderFile(cWork2, NULL) == 0)
    {
        // なし

        // 対象フォルダ作成
        if (createFolder(cWork2) != 1)
        {
            // 作成失敗
            return ret;
        }
    }

    ret = 1;

    return ret;
}

/**
* @brief confフォルダを作業フォルダに圧縮する
*
* @details confフォルダを作業フォルダに圧縮する
*
* @description
* @param[in] *cWorkFolder   作業用フォルダ名
* @param[in] *cPW           圧縮パスワード
* @param[in] *cFileName     圧縮ファイル名
* @return 1：処理成功/else：処理失敗
* @attention 圧縮に成功した場合は圧縮元のファイルを削除する
*/
int zipNTSSConfFiles(u_char *cWorkFolder, u_char *cPW, u_char *cFileName)
{
    int ret = 1;
    u_char cLog[NTSS_STR_MAX_SIZE];
    u_char cZipFolder[NTSS_STR_MAX_SIZE];
    u_char clist[NTSS_STR_MAX_SIZE];
    u_char cBuf[NTSS_STR_MAX_SIZE];
    u_char cFile[NTSS_STR_MAX_SIZE];
    u_char cZipFile[NTSS_STR_MAX_SIZE];
    FILE *fp;

    // ZIP
    // ZIP格納先フォルダ名作成
    sprintf(
        cZipFolder, "%s/ZIP/", cWorkFolder);

    // ZIP格納先フォルダ存在確認
    if (existFolderFile(cZipFolder, NULL) == 1)
    {
        // 対象フォルダあり

        // 圧縮元作成
        sprintf(cFile, ".");

        // 圧縮ファイル名作成
        sprintf(cZipFile, "%s%s", cZipFolder, cFileName);

        // ファイルを圧縮する
        if (zipNTSSFile(cFile, cZipFile, cPW) == 0)
        {
            // 圧縮成功
            sprintf(cLog, "ファイル圧縮,%s→%s", cFile, cZipFile);
            LogOutput(NTSS_LOG_INFO, cLog);
        }
        else
        {
            // 圧縮失敗
            sprintf(cLog, "ファイル圧縮失敗(%d:%s),%s→%s", errno, strerror(errno), cFile, cZipFile);
            viewError(cLog);

            ret = 0;
        }
    }

    return ret;
}

/**
* @brief 作業用フォルダ内のZIPファイルをアップロード
*
* @details 作業用フォルダ内のZIPファイルをアップロードする
*
* @description
* @param[in] *cWorkFolder           作業用フォルダ名
* @param[in]  nUploadHost           アップロードホスト名
* @param[in]  nUploadAPI            アップロードAPI
* @param[in]  nUploadJoinAPI        アップロードファイル結合API
* @param[in]  *cUploadPath          アップロード先パス名
* @param[in]  nUploadFileMaxSize    アップロードファイル最大サイズ
* @param[in] nUploadRetryCount      アップロードリトライ回数
* @param[in] nUploadRetryWaitTime   アップロードリトライ待ち時間
* @return 1：処理成功/else：処理失敗
* @attention アップロードに成功した場合はZIPファイルを削除する
*/
int uploadNTSSConfFiles(u_char *cWorkFolder, u_char *cUploadHost, u_char *cUploadAPI, u_char *cUploadJoinAPI, u_char *cUploadPath, uint16_t nUploadFileMaxSize, int nUploadRetryCount, int nUploadRetryWaitTime)
{
    int ret = 1;
    u_char cLog[NTSS_STR_MAX_SIZE];
    u_char cZipFolder[NTSS_STR_MAX_SIZE];
    u_char cUploadFolder[NTSS_STR_MAX_SIZE];
    u_char cUploadURI[NTSS_STR_MAX_SIZE];
    u_char cUploadJoinURI[NTSS_STR_MAX_SIZE];
    u_char clist[NTSS_STR_MAX_SIZE];
    u_char cBuf[NTSS_STR_MAX_SIZE];
    u_char cZipFile[NTSS_STR_MAX_SIZE];
    u_char cUploadFile[NTSS_STR_MAX_SIZE];
    FILE *fp;

    // アップロード用URI
    sprintf(
        cUploadURI, "%s%s", cUploadHost, cUploadAPI);
    // アップロードファイル結合用URI
    sprintf(
        cUploadJoinURI, "%s%s", cUploadHost, cUploadJoinAPI);

    // ZIP
    // ZIP格納先フォルダ名作成
    sprintf(cZipFolder, "%s/ZIP/", cWorkFolder);
    // ZIP格納先フォルダ存在確認
    if (existFolderFile(cZipFolder, NULL) == 1)
    {
        // 対象フォルダあり

        // UPLOAD
        // UPLOAD作業用フォルダ名作成
        sprintf(cUploadFolder, "%s/UP/", cWorkFolder);
        // アップロード作業用フォルダ存在確認
        if (existFolderFile(cUploadFolder, NULL) == 1)
        {
            // 対象フォルダあり

            // アップロード対象リストファイル名作成
            sprintf(clist, "%s/UPLOAD_LIST.TXT", cWorkFolder);

            // ファイルの一覧を取得
            if (getFolderList(cZipFolder, clist, NTSS_GETFOLDERLIST_MODE_FILE_ONLY) == 1)
            {
                // リストファイルの存在確認
                if (existFolderFile(clist, NULL) == 1)
                {
                    //
                    // リストファイルを開く
                    if ((fp = fopen(clist, "r")) != NULL)
                    {
                        // 1行取得
                        while (fgets(cBuf, sizeof(cBuf), fp) != NULL)
                        {
                            // 末尾のLFを除去
                            trimEnd(cBuf, '\n');

                            // ZIPファイル名作成
                            sprintf(cZipFile, "%s%s", cZipFolder, cBuf);

                            // アップロードするZIPファイル名作成
                            sprintf(cUploadFile, "%s%s", cUploadFolder, cBuf);

                            // ZIPファイルをアップロードフォルダへコピーする
                            if (copyFile(cZipFile, cUploadFile, NTSS_COPYFILE_MODE_OVERWRITE) == 1)
                            {
                                // コピー成功

                                // ZIPファイルをアップロードする
                                int nCount = 0;
                                if (uploadNTSSFile(cUploadFile, cUploadURI, cUploadPath, nUploadFileMaxSize, &nCount, "", "", nUploadRetryCount, nUploadRetryWaitTime) == 0)
                                {
                                    // 転送成功

                                    //
                                    sprintf(cLog, "ファイル転送成功,%s,(0),分割数,%d", cBuf, nCount);
                                    LogOutput(NTSS_LOG_INFO, cLog);

                                    //
                                    sprintf(cLog, "ファイル転送に成功したので対象のZIPファイルを削除,%s", cZipFile);
                                    LogOutput(NTSS_LOG_INFO, cLog);

                                    // ファイル削除
                                    remove(cZipFile);

                                    // ファイル結合指示を行う
                                    if (uploadNTSSFileJoin(nCount, cZipFile, cUploadJoinURI, cUploadPath, "", "") == 0)
                                    {
                                        // 結合指示成功

                                        //
                                        sprintf(cLog, "ファイル結合指示成功,%s", cBuf);
                                        LogOutput(NTSS_LOG_INFO, cLog);
                                    }
                                    else
                                    {
                                        // 結合指示失敗

                                        //
                                        sprintf(cLog, "ファイル結合指示失敗,%s", cBuf);
                                        viewError(cLog);

                                        ret = 0;
                                    }
                                }
                                else
                                {
                                    // アップロード失敗

                                    //
                                    sprintf(cLog, "ファイルアップロード失敗,%s", cBuf);
                                    viewError(cLog);

                                    ret = -1;
                                }
                            }
                        }

                        fclose(fp);
                    }
                }
            }
            else
            {
                // 一覧取得失敗

                sprintf(cLog, "作業用フォルダ内のZIPファイル一覧取得失敗:%s", cZipFolder);
                viewError(cLog);

                ret = -1;
            }

            // リストファイルを削除する
            remove(clist);

            // アップロードフォルダを空にする
            deleteFolderInFiles(cUploadFolder);
        }
    }

    return ret;
}

/**
* @brief 設定ファイルをアップロードする
*
* @details 設定ファイルをアップロードする
*
* @description
* @param[in] configParam    設定情報
* @return 1：処理成功/-1：圧縮失敗 /-2:アップロード失敗
* @attention 当日分以外のログファイルはアップロードに成功した場合は削除される
*/
int uploadNTSSConf(ConfigParameter_t *configParam, int useFolderIdx, u_char *cFileName)
{
    int nRet = 1;

    u_char cWorkFolder[NTSS_STR_MAX_SIZE];
    u_char cWorkFolder2[NTSS_STR_MAX_SIZE];
    u_char cFile[NTSS_STR_MAX_SIZE];

    // フォルダのアップロード先
    u_char cUploadPath[NTSS_STR_MAX_SIZE];
    sprintf(cUploadPath, configParam->uploadConfS3Path, configParam->facilityCode, configParam->deviceNo);

    // 作業パスを設定
    if (useFolderIdx < 0)
    {
        // 作業用フォルダ作成
        makeNTSSConfUploadWorkFolder("../");
        // 作業フォルダ名作成
        sprintf(cWorkFolder, "../WORK");
        // 作業フォルダ内のZIPファイル格納先フォルダ名作成
        sprintf(cWorkFolder2, "../WORK/ZIP");
    }
    else
    {
        // 作業用フォルダ作成
        makeNTSSConfUploadWorkFolder(configParam->dlFolder[useFolderIdx]);
        // 作業フォルダ名作成
        sprintf(cWorkFolder, "%sWORK", configParam->dlFolder[useFolderIdx]);
        // 作業フォルダ内のZIPファイル格納先フォルダ名作成
        sprintf(cWorkFolder2, "%sWORK/ZIP", configParam->dlFolder[useFolderIdx]);
    }

    // ファイル圧縮
    nRet = zipNTSSConfFiles(cWorkFolder, configParam->zipPassword, cFileName);

    if (nRet != 1)
    {
        // 圧縮失敗
        return -1;
    }
    // ファイルアップロード
    nRet = uploadNTSSConfFiles(cWorkFolder, configParam->awsHostUrl, "/ntss-web-api/upload", "/ntss-web-api/fileJoin", cUploadPath, configParam->uploadLimitFileSize, configParam->nUploadRetryCount, configParam->nUploadRetryWaitTime);

    if (nRet != 1)
    {
        // アップロード失敗
        return -2;
    }

    return nRet;
}