/**
* @file comsv_rest_get.c
* @brief REST API（GET）呼び出し処理
* @author Y.Takamura
* @date 2018/10/12
* @details 通信サーバからREST API（GET）をコールする
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "ntss_comsv.h"

/**
 * @fn int comsv_rest_get_mst(short mstType, char *datFile)
 * @brief マスタデータ（通信サーバ設定、装置、チェックリスト、検査項目）を取得する
 * @param[in] mstType マスタタイプ（0:通信サーバ設定 1:装置 2:チェクリスト 3:検査項目）
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_get_mst(short mstType, char *datFile)
{
    int ret, fd;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char cparams[100];
    unsigned char logMessage[512] = {0};
    unsigned char tempFileName[128] = {0};
    // シーケンス図
    /// @msc "REST API CALL"
    /// edge [label="COMSV"],ec2 [label="EC2"];
    /// edge=>ec2 [label = "HTTP GET / PARAMETER"];
    /// edge<=ec2 [label = "HTTP STATUS / JSON"];
    /// @endmsc

    // 一時ファイル名作成
    snprintf(tempFileName, 128, "%s_temp", datFile);
    if (existFolderFile(datFile, NULL) == 1)
    {
        // 元からファイルありならば、一時的に退避
        moveFile(datFile, tempFileName, NTSS_MOVEFILE_MODE_OVERWRITE);
    }

    if (mstType == 0)
    {
        sprintf(url, "%s%s", rest_device_edge_url, "/comsv");
        strcpy(cbuff, "通信サーバ設定取得");
    }
    else if (mstType == 1)
    {
        sprintf(url, "%s%s", rest_device_edge_url, "/machines");
        strcpy(cbuff, "装置マスタ取得");
    }
    else if (mstType == 2)
    {
        sprintf(url, "%s%s", rest_device_edge_url, "/comsv_checklist/mst");
        strcpy(cbuff, "チェックリストマスタ取得");
    }
    else
    {
        sprintf(url, "%s%s", rest_device_edge_url, "/comsv_exam/mst");
        strcpy(cbuff, "検査項目マスタ取得");
    }
    comsv_work_fpath(-1, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if (fd != 0)
    {
        close(fd);
    }
    comsv_work_fpath(-1, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if (fd != 0)
    {
        close(fd);
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "%s", cbuff);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (mstType < 2)
    {
        sprintf(cparams, "\"%s\" \"%d\"", facility_cd, device_edge_no);
    }
    else
    {
        sprintf(cparams, "\"%s\"", facility_cd);
    }

    // REST用文字列作成
    sprintf(
        cbuff, "./sh/comsv_rest_get.sh \"%s\" %s \"%s\" \"%s\" \"%s\"", url, cparams, resFile, errFile, datFile);

    // RESTをコールする
    ret = comsv_rest_exec("", "", cbuff, resFile, errFile, logMessage);

    if (ret == 0)
    {
        // 取得成功
        if (existFolderFile(tempFileName, NULL) == 1)
        {
            // 退避ファイルありならば、削除
            remove(tempFileName);
        }
    }
    else
    {
        // 取得失敗
        if (existFolderFile(tempFileName, NULL) == 1)
        {
            // 退避ファイルありならば、復元する
            moveFile(tempFileName, datFile, NTSS_MOVEFILE_MODE_OVERWRITE);
        }
    }
    return ret;
}

/**
 * @fn int comsv_rest_get_dev(long devNo, unsigned char *devCd, unsigned char *devId, char *datFile)
 * @brief 装置状態管理データを取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_get_dev(long devNo, unsigned char *devCd, unsigned char *devId, char *datFile)
{
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    char dev_sno[10];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
    // シーケンス図
    /// @msc "REST API CALL"
    /// edge [label="COMSV"],ec2 [label="EC2"];
    /// edge=>ec2 [label = "HTTP GET / PARAMETER"];
    /// edge<=ec2 [label = "HTTP STATUS / JSON"];
    /// @endmsc

    // #8266 2023.03.20 del 前回取得データを削除しない TDC高村 start
    // 既にデータ取得ファイルがあれば削除
    //remove(datFile);
    // #8266 2023.03.20 del 前回取得データを削除しない TDC高村 end

    if (devCd[0] == 0 || devId[0] == 0)
    {
        return -1;
    }

    sprintf(url, "%s%s", rest_device_edge_url, "/comsv_state");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if (fd != 0)
    {
        close(fd);
    }
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if (fd != 0)
    {
        close(fd);
    }

    memset(dev_sno, 0, sizeof(dev_sno));
    memcpy(dev_sno, devId, 8);
    str_trim(dev_sno);

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "装置状態管理取得(装置番号: %ld)", devNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff, "./sh/comsv_rest_get.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%s\" \"%s\" \"%s\"", url, facility_cd, devCd, dev_sno, resFile, errFile, datFile);

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "装置状態管理取得");
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        // 退避ファイル
        ret = -9;
        
        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);
    }
    else
    {
        // RESTをコールする
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "装置状態管理取得");

        if (ret != 0)
        {
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
            // ...
            cw = comsv_rest_connection_watch(devCd, devId);
            if (cw != 0)
            {
                setCommAliveState(1);
            }
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
        }
    }
    
    // mod AWSとDEの通信断からの復旧 高 end
    return ret;
}

/**
 * @fn int comsv_rest_get_ord(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
 * @brief 治療情報データを取得する
 * @param[in] devNo 装置番号
 * @param[in] devType 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_get_ord(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
{
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
    // シーケンス図
    /// @msc "REST API CALL"
    /// edge [label="COMSV"],ec2 [label="EC2"];
    /// edge=>ec2 [label = "HTTP GET / PARAMETER"];
    /// edge<=ec2 [label = "HTTP STATUS / JSON"];
    /// @endmsc

    // 既にデータ取得ファイルがあれば削除
    remove(datFile);

    sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/next_pat");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if (fd != 0)
    {
        close(fd);
    }
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if (fd != 0)
    {
        close(fd);
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報データ取得(オーダー番号: %ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    // #11693 2025.04.10 mod 治療情報取得REST処理の見直し TDC高村 start
    //sprintf(
    //    cbuff, "./sh/comsv_rest_get.sh \"%s\" \"%ld\" \"%d\" \"%s\" \"%s\" \"%s\"", url, ordNo, device_edge_no, resFile, errFile, datFile);
    sprintf(
        cbuff, "./sh/comsv_rest_get_fast.sh \"%s\" \"%ld\" \"%d\" \"%s\" \"%s\" \"%s\"", url, ordNo, device_edge_no, resFile, errFile, datFile);
    // #11693 2025.04.10 mod 治療情報取得REST処理の見直し TDC高村 end
    
    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報データ取得");
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        // 退避ファイル
        ret = -9;
        
        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);
    }
    else
    {
        // RESTをコールする
        // #11693 2025.04.10 mod 治療情報取得REST処理の見直し TDC高村 start
        //ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報データ取得");
        // #11810 2025.05.30 mod 仮想端末の表示が送れることがある TDC高村 start
        //ret = comsv_rest_exec_ex(devCd, devId, cbuff, resFile, errFile, "治療情報データ取得", 1, 0);
        ret = comsv_rest_exec_ex(devCd, devId, cbuff, resFile, errFile, "治療情報データ取得", 2, 0);
        // #11810 2025.05.30 mod 仮想端末の表示が送れることがある TDC高村 end
        // #11693 2025.04.10 mod 治療情報取得REST処理の見直し TDC高村 end

        if (ret != 0)
        {
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
            // ...
            cw = comsv_rest_connection_watch(devCd, devId);
            if (cw != 0)
            {
                setCommAliveState(1);
            }
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
        }
    }
    
    // mod AWSとDEの通信断からの復旧 高 end
    return ret;
}

// #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 start
/**
 * @fn int comsv_rest_get_lcd(long devNo, unsigned char *devCd, unsigned char *devId, short reqCd, unsigned char *param, char *datFile)
 * @brief LCD表示データを取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] reqCd LCDリクエストコード
 * @param[in] param データ取得キー（TAB区切りで最大5つまで）
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_get_lcd(long devNo, unsigned char *devCd, unsigned char *devId, short reqCd, unsigned char *param, char *datFile)
{
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char ckey[5][64];
    unsigned char cparams[320];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char tempFileName[128] = {0};
    // シーケンス図
    /// @msc "REST API CALL"
    /// edge [label="COMSV"],ec2 [label="EC2"];
    /// edge=>ec2 [label = "HTTP GET / PARAMETER"];
    /// edge<=ec2 [label = "HTTP STATUS / JSON"];
    /// @endmsc

    // 一時ファイル名作成
    snprintf(tempFileName, 128, "%s_temp", datFile);
    if (devNo < 0)
    {
        // 共通設定ファイル
        if (existFolderFile(datFile, NULL) == 1)
        {
            // 元からファイルありならば、一時的に退避
            moveFile(datFile, tempFileName, NTSS_MOVEFILE_MODE_OVERWRITE);
        }
    }
    else
    {
        // 装置別ファイル
        // 既にデータ取得ファイルがあれば削除
        remove(datFile);
    }

    if (reqCd == 0)
    {
        // LCDキャッシュデータ
        sprintf(url, "%s/lcdcash", rest_device_edge_url);
    }
    else if (reqCd == 54)
    {
        // チェックリスト
        sprintf(url, "%s/comsv_checklist/ord", rest_device_edge_url);
    }
    else
    {
        // その他
        sprintf(url, "%s/lcdreq%d", rest_device_edge_url, reqCd);
    }
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if (fd != 0)
    {
        close(fd);
    }
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if (fd != 0)
    {
        close(fd);
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "LCDデータ要求(LCDリクエストコード: %d)", reqCd);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    memset(cparams, 0, sizeof(cparams));
    memset(ckey, 0, sizeof(ckey));
    if (reqCd == 0)
    {
        get_text(1, param, ckey[0]);
        get_text(2, param, ckey[1]);
        get_text(3, param, ckey[2]);
        sprintf(cparams, "\"%s\" \"%d\" \"%s\" \"%s\" \"%s\"", facility_cd, device_edge_no, ckey[0], ckey[1], ckey[2]);
    }
    else if (reqCd == 29 || reqCd == 40)
    {
        sprintf(cparams, "\"%s\" \"%d\"", param, device_edge_no);
    }
    else if (reqCd == 36)
    {
        get_text(1, param, ckey[0]);
        get_text(2, param, ckey[1]);
        get_text(3, param, ckey[2]);
        get_text(4, param, ckey[3]);
        get_text(5, param, ckey[4]);
        sprintf(cparams, "\"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\"", facility_cd, ckey[0], ckey[1], ckey[2], ckey[3], ckey[4]);
    }
    else if (reqCd == 46 || reqCd == 47)
    {
        get_text(1, param, ckey[0]);
        get_text(2, param, ckey[1]);
        sprintf(cparams, "\"%s\" \"%s\"", ckey[0], ckey[1]);
    }
    else if (reqCd == 50)
    {
        sprintf(cparams, "\"%s\"", param);
    }
    else if (reqCd == 54)
    {
        get_text(1, param, ckey[0]);
        get_text(2, param, ckey[1]);
        get_text(3, param, ckey[2]);
        sprintf(cparams, "\"%s\" \"%s\" \"%s\" \"%s\"", ckey[0], ckey[1], ckey[2], facility_cd);
    }
    else
    {
        sprintf(cparams, "\"%s\"", param);
    }

    // REST用文字列作成
    sprintf(
        cbuff, "./sh/comsv_rest_get_fast.sh \"%s\" %s \"%s\" \"%s\" \"%s\"", url, cparams, resFile, errFile, datFile);

    // mod AWSとDEの通信断からの復旧 高 start
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        // 退避ファイル
        ret = -9;
        
        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);
    }
    else
    {
        // RESTをコールする
        // #11810 2025.05.30 mod 仮想端末の表示が送れることがある TDC高村 start
        //ret = comsv_rest_exec_ex(devCd, devId, cbuff, resFile, errFile, "LCDデータ要求", 1, 0);
        ret = comsv_rest_exec_ex(devCd, devId, cbuff, resFile, errFile, "LCDデータ要求", 2, 0);
        // #11810 2025.05.30 mod 仮想端末の表示が送れることがある TDC高村 end
    }
    
    if (ret == 0)
    {
        // 取得成功
        if (devNo < 0)
        {
            if (existFolderFile(tempFileName, NULL) == 1)
            {
                // 退避ファイルありならば、削除
                remove(tempFileName);
            }
        }
    }
    else
    {
        // 取得失敗
        if (devNo < 0)
        {
            if (existFolderFile(tempFileName, NULL) == 1)
            {
                // 退避ファイルありならば、復元する
                moveFile(tempFileName, datFile, NTSS_MOVEFILE_MODE_OVERWRITE);
            }
        }
        
    }
    return ret;
}
// #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 end

/**
 * @fn int comsv_rest_get_past(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
 * @brief 指定オーダ番号から直近・同一曜日で過去３回分のオーダ情報を取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_get_past(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
{
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
    // シーケンス図
    /// @msc "REST API CALL"
    /// edge [label="COMSV"],ec2 [label="EC2"];
    /// edge=>ec2 [label = "HTTP GET / PARAMETER"];
    /// edge<=ec2 [label = "HTTP STATUS / JSON"];
    /// @endmsc

    // 既にデータ取得ファイルがあれば削除
    remove(datFile);

    sprintf(url, "%s%s", rest_device_edge_url, "/past_ordinfo");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if (fd != 0)
    {
        close(fd);
    }
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if (fd != 0)
    {
        close(fd);
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "直近・同一曜日で過去３回分オーダ取得(オーダー番号: %ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff, "./sh/comsv_rest_get.sh \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\"", url, ordNo, resFile, errFile, datFile);

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "直近・同一曜日で過去３回分オーダ取得");
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        // 退避ファイル
        ret = -9;
        
        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);
    }
    else
    {
        // RESTをコールする
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "直近・同一曜日で過去３回分オーダ取得");

        if (ret != 0)
        {
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
            // ...
            cw = comsv_rest_connection_watch(devCd, devId);
            if (cw != 0)
            {
                setCommAliveState(1);
            }
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
        }
    }
    
    // mod AWSとDEの通信断からの復旧 高 end
    return ret;
}

/**
 * @fn int comsv_rest_get_host(ong devNo, unsigned char *devCd, unsigned char *devId, long patId, char *datFile)
 * @brief 患者ホスト報知定義を取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] patId 患者ID
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_get_host(long devNo, unsigned char *devCd, unsigned char *devId, long patId, char *datFile)
{
    int ret, fd;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char cparams[100];
    unsigned char logMessage[512] = {0};
    unsigned char tempFileName[128] = {0};
    // シーケンス図
    /// @msc "REST API CALL"
    /// edge [label="COMSV"],ec2 [label="EC2"];
    /// edge=>ec2 [label = "HTTP GET / PARAMETER"];
    /// edge<=ec2 [label = "HTTP STATUS / JSON"];
    /// @endmsc

    // 一時ファイル名作成
    snprintf(tempFileName, 128, "%s_temp", datFile);
    if (existFolderFile(datFile, NULL) == 1)
    {
        // 元からファイルありならば、一時的に退避
        moveFile(datFile, tempFileName, NTSS_MOVEFILE_MODE_OVERWRITE);
    }

    sprintf(url, "%s%s", rest_device_edge_url, "/notification/setting");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if (fd != 0)
    {
        close(fd);
    }
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if (fd != 0)
    {
        close(fd);
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "患者ホスト報知定義取得(患者ID: %ld)", patId);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    if (patId > 0L)
    {
        sprintf(cparams, "\"%s\" \"%d\" \"%ld\"", facility_cd, device_edge_no, patId);
    }
    else
    {
        sprintf(cparams, "\"%s\" \"%d\"", facility_cd, device_edge_no);
    }

    // REST用文字列作成
    sprintf(
        cbuff, "./sh/comsv_rest_get.sh \"%s\" %s \"%s\" \"%s\" \"%s\"", url, cparams, resFile, errFile, datFile);

    // RESTをコールする
    ret = comsv_rest_exec("", "", cbuff, resFile, errFile, logMessage);

    if (ret == 0)
    {
        // 取得成功
        if (existFolderFile(tempFileName, NULL) == 1)
        {
            // 退避ファイルありならば、削除
            remove(tempFileName);
        }
    }
    else
    {
        // 取得失敗
        if (existFolderFile(tempFileName, NULL) == 1)
        {
            // 退避ファイルありならば、復元する
            moveFile(tempFileName, datFile, NTSS_MOVEFILE_MODE_OVERWRITE);
        }
    }
    return ret;
}

// add FNSI-バグ 通信サーバ 高 start
/**
 * @fn int comsv_rest_get_ordno_state(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
 * @brief 治療情報データを取得する
 * @param[in] devNo 装置番号
 * @param[in] devType 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_get_ordno_state(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
{
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
    // シーケンス図
    /// @msc "REST API CALL"
    /// edge [label="COMSV"],ec2 [label="EC2"];
    /// edge=>ec2 [label = "HTTP GET / PARAMETER"];
    /// edge<=ec2 [label = "HTTP STATUS / JSON"];
    /// @endmsc

    // 既にデータ取得ファイルがあれば削除
    remove(datFile);

    sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/dialysis_state");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if (fd != 0)
    {
        close(fd);
    }
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if (fd != 0)
    {
        close(fd);
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報データ取得(オーダー番号: %ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff, "./sh/comsv_rest_get.sh \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\"", url, ordNo, resFile, errFile, datFile);
    
    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報データ取得");
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        // 退避ファイル
        ret = -9;
        
        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);
    }
    else
    {
        // RESTをコールする
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報データ取得");

        if (ret != 0)
        {
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
            // ...
            cw = comsv_rest_connection_watch(devCd, devId);
            if (cw != 0)
            {
                setCommAliveState(1);
            }
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
        }
    }
    
    // mod AWSとDEの通信断からの復旧 高 end
    return ret;
}
// add FNSI-バグ 通信サーバ 高 end


// #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 start
/**
 * @fn int comsv_rest_get_exists_ord(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
 * @brief 治療情報の有無を取得する
 * @param[in] devNo 装置番号
 * @param[in] devType 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_get_exists_ord(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
{
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    int ii = 0;
    // シーケンス図
    /// @msc "REST API CALL"
    /// edge [label="COMSV"],ec2 [label="EC2"];
    /// edge=>ec2 [label = "HTTP GET / PARAMETER"];
    /// edge<=ec2 [label = "HTTP STATUS / JSON"];
    /// @endmsc

    // 既にデータ取得ファイルがあれば削除
    remove(datFile);

    sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/exists");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if (fd != 0)
    {
        close(fd);
    }
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if (fd != 0)
    {
        close(fd);
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の有無取得(オーダー番号: %ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff, "./sh/comsv_rest_get.sh \"%s\" \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\"", url, facility_cd, ordNo, resFile, errFile, datFile);
    
    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        // 退避ファイル
        ret = -9;
        
        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);
    }
    else
    {
        // RESTをコールする
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の有無取得");

        if (ret != 0)
        {
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
            // ...
            cw = comsv_rest_connection_watch(devCd, devId);
            if (cw != 0)
            {
                setCommAliveState(1);
            }
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
        }
    }
    
    // mod AWSとDEの通信断からの復旧 高 end
    return ret;
}
// #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 end

// #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 start
/**
 * @fn int comsv_npat_getbuffer(char *jfile, type type, char *buffer)
 * @brief JSON文字列から次患者情報データ部を取得する
 * @param[in] jfile JSONファイル名
 * @param[in] type 次患者情報タイプ（1,2）
 * @param[in] buffer 取得文字列
 * @return 0:成功, -1:エラー
 */
int comsv_npat_getbuffer(char *jfile, short type, char *buffer)
{
    int ret = -1;
    int i, len;
    FILE *fp;
    char *p;
    char atime[30];
    char mtime[30];
    char ctime[30];
    char buff[10240];        
    char work[10240];        

    fp = fopen(jfile, "r");  // ファイルを読み取りモードで開く
    if ( fp != NULL ) {
        memset(buff, 0, sizeof(buff));
        if ( fgets(buff, sizeof(buff), fp) != NULL) {
            // 次患者情報文字列取得
            memset(work, 0, sizeof(work));
            if ( type == 1 ) {
                // 次患者情報１
                p = strstr(buff, "\"pat1\":");                
            }
            else {
                // 次患者情報２
                p = strstr(buff, "\"pat2\":");
            }
            if ( p != NULL ) {
                strcpy(work, p);
            }
            for ( i=0; i<strlen(work); i++ ) {
                if ( work[i] == '}' ) {
                    work[i+1] = 0;
                    break;
                }
            }
            if ( strlen(work) > 0 ) {
                strcpy(buffer, work);
                ret = 0;
            }
        }
        fclose(fp);  // ファイルを閉じる
    }
    return ret;
}
// #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 end
