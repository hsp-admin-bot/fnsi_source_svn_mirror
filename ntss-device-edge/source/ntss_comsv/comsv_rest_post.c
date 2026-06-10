/**
* @file comsv_rest_post.c
* @brief REST API（POST）呼び出し処理
* @author Y.Takamura
* @date 2018/10/12
* @details 通信サーバからREST API（POST）をコールする
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "ntss_comsv.h"

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_post_ord_cond(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, int treat, char *upData)
// * @brief 設定値読み込み履歴を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] date 条件取得日時
// * @param[in] treat 区分（0:条件送信前,1:条件送信,2:運転開始,3:排液検出,4:任意）
// * @param[in] upData アップロードデータ／ファイル（json）
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_post_ord_cond(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, int treat, char *upData) {
/**
 * @fn int comsv_rest_post_ord_cond(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, int treat, char *upData)
 * @brief 設定値読み込み履歴を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] date 条件取得日時
 * @param[in] treat 区分（0:条件送信前,1:条件送信,2:運転開始,3:排液検出,4:任意）
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_ord_cond(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, int treat, char *upData) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    char dt[20], tm[10];
    char cdate[20];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char treatText[20] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    int con;
    struct scn_data_fm *sp;
    char replaceFileName[256] = {0};
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/treat_condition");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    // 日付を対象文字列に変換
    if ( time_str(date, dt, tm, 1) == 0 ) {
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        sprintf(cdate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
    }
    else {
        strcpy(cdate, "null");
    }
    // treat 区分（0:条件送信前,1:条件送信,2:運転開始,3:排液検出,4:任意）
    switch (treat)
    {
    case 0:
        snprintf(treatText, sizeof(treatText), "条件送信前");
        break;
    case 1:
        snprintf(treatText, sizeof(treatText), "条件送信");
        break;
    case 2:
        snprintf(treatText, sizeof(treatText), "運転開始");
        break;
    case 3:
        snprintf(treatText, sizeof(treatText), "排液検出");
        break;
    case 4:
        snprintf(treatText, sizeof(treatText), "任意");
        break;
    default:
        snprintf(treatText, sizeof(treatText), "不明");
        break;
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "設定値読み込み履歴更新(装置番号:%ld オーダー番号:%ld %s)", devNo, ordNo, treatText);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_post.sh \"%s\" \"%ld\" \"%s\" \"%ld\" \"%s\" \"%d\" \"%s\" \"%s\" \"%s\""
        , url
        , ordNo
        , facility_cd
        , devNo
        , cdate
        , treat
        , upData
        , resFile
        , errFile
    );
    
    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "設定値読み込み履歴更新");
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        // 退避ファイル
        ret = -9;
        
        con = comsv_fail_current_con_sock(facility_cd, devCd, devId);
        // find con_sock error
        if(con == -1)
            return -1;
    
        sp = &(con_sock[con].scn);
        
        // replace file name
        comsv_fail_get_filename(devNo, upData, replaceFileName);
        
        // move file
        moveFile(upData, replaceFileName, NTSS_MOVEFILE_MODE_OVERWRITE);
        
        sprintf(
            cbuff
            , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%s\" \"%ld\" \"%s\" \"%d\" \"%s\""
            , url
            , COMM_FAIL_REPLASE_ORD_NO
            , facility_cd
            , devNo
            , cdate
            , treat
            , replaceFileName
        );
        
        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);
        
        // output to file
        comsv_fail_append_data(sp, cbuff, 0, 0);
    }
    else
    {
        // RESTをコールする
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "設定値読み込み履歴更新");

        if (ret != 0)
        {
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
            // ...
            cw = comsv_rest_connection_watch(devCd, devId);
            if (cw != 0)
            {
                setCommAliveState(1);
        
                con = comsv_fail_current_con_sock(facility_cd, devCd, devId);
                // find con_sock error
                if(con == -1)
                    return -1;
            
                sp = &(con_sock[con].scn);
                
                // replace file name
                comsv_fail_get_filename(devNo, upData, replaceFileName);
                
                // move file
                moveFile(upData, replaceFileName, NTSS_MOVEFILE_MODE_OVERWRITE);
                
                sprintf(
                    cbuff
                    , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%s\" \"%ld\" \"%s\" \"%d\" \"%s\""
                    , url
                    , COMM_FAIL_REPLASE_ORD_NO
                    , facility_cd
                    , devNo
                    , cdate
                    , treat
                    , replaceFileName
                );
                
                // output to file
                comsv_fail_append_data(sp, cbuff, 0, 0);
            }
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
        }
    }
    
    // mod AWSとDEの通信断からの復旧 高 end
    return ret;
}

/**
 * @fn int comsv_rest_post_ord_moni(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *upData)
 * @brief 治療情報の実績モニタ値を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_ord_moni(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *upData) {
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    int con;
    struct scn_data_fm *sp;
    char replaceFileName[256] = {0};
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/rst_monitor");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の実績モニタ値更新(オーダー番号:%ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_post.sh \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\""
        , url
        , ordNo
        , upData
        , resFile
        , errFile
    );
    
    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の実績モニタ値更新");
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        // 退避ファイル
        ret = -9;
        
        con = comsv_fail_current_con_sock(facility_cd, devCd, devId);
        // find con_sock error
        if(con == -1)
            return -1;
    
        sp = &(con_sock[con].scn);
        
        // replace file name
        comsv_fail_get_filename(devNo, upData, replaceFileName);
        
        // move file
        moveFile(upData, replaceFileName, NTSS_MOVEFILE_MODE_OVERWRITE);
        
        sprintf(
            cbuff
            , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%s\""
            , url
            , COMM_FAIL_REPLASE_ORD_NO
            , replaceFileName
        );
        
        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);
        
        // output to file
        comsv_fail_append_data(sp, cbuff, 0, 0);
    }
    else
    {
        // RESTをコールする
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の実績モニタ値更新");

        if (ret != 0)
        {
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
            // ...
            cw = comsv_rest_connection_watch(devCd, devId);
            if (cw != 0)
            {
                setCommAliveState(1);
            
                con = comsv_fail_current_con_sock(facility_cd, devCd, devId);
                // find con_sock error
                if(con == -1)
                    return -1;
            
                sp = &(con_sock[con].scn);
                
                // replace file name
                comsv_fail_get_filename(devNo, upData, replaceFileName);
                
                // move file
                moveFile(upData, replaceFileName, NTSS_MOVEFILE_MODE_OVERWRITE);
                
                sprintf(
                    cbuff
                    , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%s\""
                    , url
                    , COMM_FAIL_REPLASE_ORD_NO
                    , replaceFileName
                );
                
                // output to file
                comsv_fail_append_data(sp, cbuff, 0, 0);
            }
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
        }
    }
    // mod AWSとDEの通信断からの復旧 高 end
    return ret;
}

/**
 * @fn int comsv_rest_post_ord_log(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short type, char *upData, u_char *occurDateTime)
 * @brief 治療情報の実績ログ（測定データ）を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] type ログタイプ（0:その他,1:再循環率測定,2:I-HDF引き残し量,3:静的静脈圧,4:IAP retio）
 * @param[in] upData アップロードデータ／ファイル（json）
 * @param[in] occurDateTime 装置からの発生日時
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
// mod 治療完了後、I-HDFの引き残し記録を別途で登録要 高 start
// int comsv_rest_post_ord_log(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short type, char *upData) {
int comsv_rest_post_ord_log(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short type, char *upData, u_char *occurDateTime) {
// mod 治療完了後、I-HDFの引き残し記録を別途で登録要 高 end
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char typeText[30] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    int con;
    struct scn_data_fm *sp;
    char replaceFileName[256] = {0};
    short sdata;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc
    // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 高 start
    char dev_sno[10];
    
    memset(dev_sno, 0, sizeof(dev_sno));
    memcpy(dev_sno, devId, 8);
    str_trim(dev_sno);
    // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 高 end

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/rst_logdata");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);
    // ログタイプ（0:その他,1:再循環率測定,2:I-HDF引き残し量,3:静的静脈圧,4:IAP retio）
    switch (type)
    {
    case 0:
        snprintf(typeText, sizeof(typeText), "その他");
        break;
    case 1:
        snprintf(typeText, sizeof(typeText), "再循環率測定");
        break;
    case 2:
        snprintf(typeText, sizeof(typeText), "I-HDF引き残し量");
        break;
    case 3:
        snprintf(typeText, sizeof(typeText), "静的静脈圧");
        break;
    case 4:
        snprintf(typeText, sizeof(typeText), "IAP retio");
        break;
    default:
        snprintf(typeText, sizeof(typeText), "不明");
        break;
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の実績ログ（測定データ）更新(オーダー番号:%ld %s)", ordNo, typeText);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 高 start
    // sprintf(
    //     cbuff
    //     , "./sh/comsv_rest_post.sh \"%s\" \"%d\" \"%ld\" \"%s\" \"%s\" \"%s\""
    //     , url
    //     , type
    //     , ordNo
    //     , upData
    //     , resFile
    //     , errFile
    // );
    sprintf(
        cbuff
        , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%d\" \"%ld\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , facility_cd
        , devCd
        , dev_sno
        , type
        , ordNo
        , occurDateTime
        , upData
        , resFile
        , errFile
    );
    // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 高 end

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の実績ログ（測定データ）更新");
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        // 退避ファイル
        ret = -9;
        
        con = comsv_fail_current_con_sock(facility_cd, devCd, devId);
        // find con_sock error
        if(con == -1)
            return -1;
    
        sp = &(con_sock[con].scn);
        
        // 血流量データ取得
        sdata = hl_chg(*(short*)(packetInfoList[con_sock[con].thread_no].cMoniData + 12 + 8 * 2));
        
        sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/rst_logdata_commfail");
        
        sprintf(
            cbuff
            , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%d\" \"%s\" \"%s\" \"%d\" \"%s\""
            , url
            , facility_cd
            , devCd
            , dev_sno
            , type
            , COMM_FAIL_REPLASE_ORD_NO
            , occurDateTime
            , sdata
            , upData
        );
        
        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);
        
        // output to file
        comsv_fail_append_data(sp, cbuff, 0, 0);
    }
    else
    {
        // RESTをコールする
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の実績ログ（測定データ）更新");

        if (ret != 0)
        {
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
            // ...
            cw = comsv_rest_connection_watch(devCd, devId);
            if (cw != 0)
            {
                setCommAliveState(1);
        
                con = comsv_fail_current_con_sock(facility_cd, devCd, devId);
                // find con_sock error
                if(con == -1)
                    return -1;
            
                sp = &(con_sock[con].scn);
                
                sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/rst_logdata_commfail");
                
                // 血流量データ取得
                sdata = hl_chg(*(short*)(packetInfoList[con_sock[con].thread_no].cMoniData + 12 + 8 * 2));
            
                sprintf(
                    cbuff
                    , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%d\" \"%s\" \"%s\" \"%d\" \"%s\""
                    , url
                    , facility_cd
                    , devCd
                    , dev_sno
                    , type
                    , COMM_FAIL_REPLASE_ORD_NO
                    , occurDateTime
                    , sdata
                    , upData
                );
                
                // output to file
                comsv_fail_append_data(sp, cbuff, 0, 0);
            }
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
        }
    }
    
    // mod AWSとDEの通信断からの復旧 高 end
    return ret;
}

// #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 start
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_post_ord_comptreat(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData)
// * @brief 治療情報の実績愁訴・愁訴処置情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] date 投与実施日時
// * @param[in] upData アップロードデータ／ファイル（json）
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_post_ord_comptreat(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData) {
/**
 * @fn int comsv_rest_post_ord_comptreat(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData)
 * @brief 治療情報の実績愁訴・愁訴処置情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] date 投与実施日時
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_ord_comptreat(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    char dt[20], tm[10];
    char cdate[20];
    // mod FNSI-バグ 通信サーバ 高 start
    //unsigned char cbuff[512] = {0};
    unsigned char cbuff[3200] = {0};
    // mod FNSI-バグ 通信サーバ 高 end
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/rst_comptreat");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    // 日付を対象文字列に変換
    if ( time_str(date, dt, tm, 1) == 0 ) {
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        sprintf(cdate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
    }
    else {
        return -1;
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の実績愁訴・愁訴処置情報更新(オーダー番号:%ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_post_fast.sh \"%s\" \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , facility_cd
        , ordNo
        , cdate
        , upData
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の実績愁訴・愁訴処置情報更新");
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
        ret = comsv_rest_exec_ex(devCd, devId, cbuff, resFile, errFile, "治療情報の実績愁訴・愁訴処置情報更新", 3, 0);

        if (ret != 0 && ret != 1)
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
// #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_post_ord_medi(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData)
// * @brief 治療情報の実績投与薬剤情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] date 投与実施日時
// * @param[in] upData アップロードデータ／ファイル（json）
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_post_ord_medi(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData) {
/**
 * @fn int comsv_rest_post_ord_medi(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData)
 * @brief 治療情報の実績投与薬剤情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] date 投与実施日時
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_ord_medi(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    char dt[20], tm[10];
    char cdate[20];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/rst_medi");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    // 日付を対象文字列に変換
    if ( time_str(date, dt, tm, 1) == 0 ) {
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        sprintf(cdate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
    }
    else {
        return -1;
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の実績投与薬剤情報更新(オーダー番号: %ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_post.sh \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , ordNo
        , cdate
        , upData
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の実績投与薬剤情報更新");
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
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の実績投与薬剤情報更新");

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

// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 start
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_post_ord_medi_ex(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData)
// * @brief 治療情報の実績投与薬剤情報を更新する（RESTエラー時の応答を早く返す）
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] date 投与実施日時
// * @param[in] upData アップロードデータ／ファイル（json）
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_post_ord_medi_ex(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData) {
/**
 * @fn int comsv_rest_post_ord_medi_ex(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData)
 * @brief 治療情報の実績投与薬剤情報を更新する（RESTエラー時の応答を早く返す）
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] date 投与実施日時
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_ord_medi_ex(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    char dt[20], tm[10];
    char cdate[20];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/rst_medi");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    // 日付を対象文字列に変換
    if ( time_str(date, dt, tm, 1) == 0 ) {
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        sprintf(cdate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
    }
    else {
        return -1;
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の実績投与薬剤情報更新(オーダー番号: %ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_post_fast.sh \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , ordNo
        , cdate
        , upData
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の実績投与薬剤情報更新");
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
        ret = comsv_rest_exec_ex(devCd, devId, cbuff, resFile, errFile, "治療情報の実績投与薬剤情報更新", 3, 0);

        if (ret != 0 && ret != 1)
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
// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 end

// #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 start
/**
 * @fn int comsv_rest_post_ord_check(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short sendFlg, short listCd, char *upData)
 * @brief 治療情報のチェックリスト実績情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] sendFlg 条件送信フラグ
 * @param[in] listCd リストコード
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_ord_check(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short sendFlg, short listCd, char *upData) {
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    // mod FNSI-バグ 通信サーバ 高 start
    //unsigned char cbuff[512] = {0};
    unsigned char cbuff[3200] = {0};
    // mod FNSI-バグ 通信サーバ 高 end
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_checklist/ord/update");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報のチェックリスト実績情報 (オーダー番号:%ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_post_fast.sh \"%s\" \"%d\" \"%ld\" \"%d\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , sendFlg        
        , ordNo
        , listCd
        , facility_cd
        , upData
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報のチェックリスト実績情報");
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
        ret = comsv_rest_exec_ex(devCd, devId, cbuff, resFile, errFile, "治療情報のチェックリスト実績情報", 3, 0);

        if (ret != 0 && ret != 1)
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
// #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 end

/**
 * @fn int comsv_rest_post_web_api(long devNo, unsigned char *devCd, unsigned char *devId, short apiNo)
 * @brief 現患者クリア、次患者更新、条件送信結果処理を行う
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] apiNo API番号（0:現患者クリアAPI,1:次患者更新API,2:条件送信結果処理API）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_web_api(long devNo, unsigned char *devCd, unsigned char *devId, short apiNo) {
    int ret, fd, cw;
    char buf[40];
    char url[200];
    char upData[100];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
    // add FNSI-バグ 通信サーバ(BIT) 高 start
    unsigned char deviceNo[9];
    // add FNSI-バグ 通信サーバ(BIT) 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    if ( apiNo == 0 ) {
    	sprintf(url, "%s%s", rest_web_api_url, "/CurrentPatClear");
        snprintf(logMessage, sizeof(logMessage), "現患者クリアAPI(装置番号: %ld)", devNo);
    }
    else if ( apiNo == 1 ) {
    	sprintf(url, "%s%s", rest_web_api_url, "/SetNextPatInfo");
        snprintf(logMessage, sizeof(logMessage), "次患者更新API(装置番号: %ld)", devNo);
    }
    else {
    	sprintf(url, "%s%s", rest_web_api_url, "/SendCondResult");
        snprintf(logMessage, sizeof(logMessage), "条件送信結果処理API(装置番号: %ld)", devNo);
    }
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    strcpy(upData, "{");
    sprintf(buf, "\\\"facility_cd\\\":\\\"%s\\\"", facility_cd);
    strcat(upData, buf);
    sprintf(buf, ",\\\"machine_type_cd\\\":\\\"%.3s\\\"", devCd);
    strcat(upData, buf);
    // mod FNSI-バグ 通信サーバ(BIT) 高 start
    memset(deviceNo, '\0', sizeof(deviceNo));
    memcpy(deviceNo, devId, 8);
    str_trim(deviceNo);
    // sprintf(buf, ",\\\"machine_serial\\\":\\\"%.7s\\\"", devId);
    sprintf(buf, ",\\\"machine_serial\\\":\\\"%.8s\\\"", deviceNo);
    // mod FNSI-バグ 通信サーバ(BIT) 高 end
    strcat(upData, buf);
    strcat(upData, "}");

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , upData
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);
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
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);

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
 * @fn int comsv_rest_post_reload_npat(char *upData)
 * @brief 一斉次患者更新処理を行う
 * @param[in] upData アップロードデータ（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_reload_npat(char *upData) {
    int ret, fd;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

    comsv_work_fpath(-1, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(-1, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_reload_npat");
    strcpy(cbuff, "一括次患者更新処理");
    snprintf(logMessage, sizeof(logMessage), "%s", cbuff);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%d\" \"%s\" \"%s\" \"%s\""
        , url
        , facility_cd
        , device_edge_no
        , upData
        , resFile
        , errFile
    );

    // RESTをコールする
    ret = comsv_rest_exec("", "", cbuff, resFile, errFile, logMessage);
    return ret;
}

/**
 * @fn int comsv_rest_post_send_cond(char *upData)
 * @brief 条件送信完了時の一連処理を行う
 * @param[in] devNo 装置番号
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_send_cond(struct scn_data_fm *sp) {
    int ret, fd, cw;
    char buf[40];
    char url[200];
    char upData[300];
    char resFile[40];
    char errFile[40];
    char dt[20], tm[10];
    char cdate[20];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    int con;
    char replaceFileName[256] = {0};
    // add AWSとDEの通信断からの復旧 高 end
    // add FNSI-バグ 通信サーバ(BIT) 高 start
    unsigned char deviceNo[9];
    // add FNSI-バグ 通信サーバ(BIT) 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

    comsv_work_fpath(sp->dev_no, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(sp->dev_no, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_send_cond");
    strcpy(cbuff, "条件送信完了時の一連処理");
    snprintf(logMessage, sizeof(logMessage), "%s", cbuff);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // REST用json文字列作成
    if ( time_str(sp->cond_send_date, dt, tm, 1) == 0 ) {
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        sprintf(cdate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
    }
    else {
        strcpy(cdate, "null");
    }
    strcpy(upData, "{");
    sprintf(buf, "\\\"machine_type_cd\\\":\\\"%.3s\\\"", sp->deviceType);
    strcat(upData, buf);
    // mod FNSI-バグ 通信サーバ(BIT) 高 start
    memset(deviceNo, '\0', sizeof(deviceNo));
    memcpy(deviceNo, sp->devid, 8);
    str_trim(deviceNo);
    // sprintf(buf, ",\\\"machine_serial\\\":\\\"%.7s\\\"", sp->devid);
    sprintf(buf, ",\\\"machine_serial\\\":\\\"%.8s\\\"", deviceNo);
    // mod FNSI-バグ 通信サーバ(BIT) 高 end
    strcat(upData, buf);
    sprintf(buf, ",\\\"machine_format\\\":\\\"%c\\\"", sp->devsw);
    strcat(upData, buf);
    sprintf(buf, ",\\\"ord_no\\\":\\\"%ld\\\"", sp->ord_no);
    strcat(upData, buf);
    sprintf(buf, ",\\\"pat_id\\\":\\\"%ld\\\"", sp->pat_id);
    strcat(upData, buf);
    sprintf(buf, ",\\\"machine_status\\\":\\\"%d\\\"", sp->mon_sta);
    strcat(upData, buf);
    sprintf(buf, ",\\\"send_ctrl\\\":\\\"%ld\\\"", sp->cond_send_ctrl);
    strcat(upData, buf);
    sprintf(buf, ",\\\"send_date\\\":\\\"%s\\\"", cdate);
    strcat(upData, buf);
    strcat(upData, "}");

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , facility_cd
        , upData
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec("", "", cbuff, resFile, errFile, logMessage);
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        // 退避ファイル
        ret = -9;
        
        sprintf(url, "%s%s", rest_device_edge_url, "/comsv_send_cond/comm_fail");
        
        sprintf(
            cbuff
            , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%s\""
            , url
            , facility_cd
            , upData
        );
        
        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);
        
        // output to file
        comsv_fail_append_data(sp, cbuff, 0, 0);
    }
    else
    {
        // RESTをコールする
        ret = ret = comsv_rest_exec("", "", cbuff, resFile, errFile, logMessage);

        if (ret != 0)
        {
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
            // ...
            cw = comsv_rest_connection_watch(sp->deviceType, sp->devid);
            if (cw != 0)
            {
                setCommAliveState(1);

                // sprintf(url, "%s%s", rest_device_edge_url, "/comsv_send_cond/comm_fail");
            
                // sprintf(
                //     cbuff
                //     , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%s\""
                //     , url
                //     , facility_cd
                //     , upData
                // );
            
                // output to file
                // comsv_fail_append_data(sp, cbuff, 0, 0);
            }
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
        }
    }
    
    // mod AWSとDEの通信断からの復旧 高 end
    return ret;
}

/**
 * @fn int comsv_rest_post_all_status(char *upData)
 * @brief 装置状態管理の装置ステータス一括更新処理を行う
 * @param[in] upData アップロードデータ（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_all_status(char *upData) {
    int ret, fd;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

    comsv_work_fpath(-1, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(-1, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_state/all_status");
    strcpy(cbuff, "装置ステータス一括更新処理");
    snprintf(logMessage, sizeof(logMessage), "%s", cbuff);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , facility_cd
        , upData
        , resFile
        , errFile
    );

    // RESTをコールする
    ret = comsv_rest_exec("", "", cbuff, resFile, errFile, logMessage);
    return ret;
}

/**
 * @fn int comsv_rest_post_notice_medi(long devNo, unsigned char *devCd, unsigned char *devId, char *upData)
 * @brief 投薬タイミング通知処理を行う
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] upData アップロードデータ（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_notice_medi(long devNo, unsigned char *devCd, unsigned char *devId, char *upData) {
    int ret, fd;
    char url[200];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST / PARAMETER / JSON"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

   	sprintf(url, "%s%s", rest_device_edge_url, "/notification/medicine");
    snprintf(logMessage, sizeof(logMessage), "投薬タイミング通知(装置番号: %ld)", devNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_post.sh \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , upData
        , resFile
        , errFile
    );

    // RESTをコールする
    ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);
    return ret;
}
