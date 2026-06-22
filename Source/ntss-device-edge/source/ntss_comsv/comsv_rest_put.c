/**
* @file comsv_rest_put.c
* @brief REST API（PUT）呼び出し処理
* @author Y.Takamura
* @date 2018/10/12
* @details 通信サーバからREST API（PUT）をコールする
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "ntss_comsv.h"

/**
 * @fn int comsv_rest_put_option(long devNo, unsigned char *devCd, unsigned char *devId, unsigned short *option)
 * @brief 装置マスタのオプションデータを更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] option 装置オプション
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_option(long devNo, unsigned char *devCd, unsigned char *devId, unsigned short *option) {
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    char opt_str[30];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s/machines/update_option", rest_device_edge_url);
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);
    sprintf(opt_str, "%04X%04X%04X%04X%04X", option[0], option[1], option[2], option[3], option[4]);

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "装置マスタのオプションデータ更新(装置番号:%ld)", devNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%d\" \"%ld\" \"%s\" \"%s\" \"%s\""
        , url
        , facility_cd
        , device_edge_no
        , devNo
        , opt_str
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "装置マスタのオプションデータ更新");
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
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "装置マスタのオプションデータ更新");

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

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_dev_date(long devNo, unsigned char *devCd, unsigned char *devId, short inpType, short state, long date)
// * @brief 装置状態管理の日付データを更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] inpType 入力種別（0:条件送信日時,1:条件確認日時,2:透析開始日時,3:透析終了日時）
// * @param[in] state 装置ステータス
// * @param[in] date 日付
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_put_dev_date(long devNo, unsigned char *devCd, unsigned char *devId, short inpType, short state, long date) {
/**
 * @fn int comsv_rest_put_dev_date(long devNo, unsigned char *devCd, unsigned char *devId, short inpType, short state, time_t date)
 * @brief 装置状態管理の日付データを更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] inpType 入力種別（0:条件送信日時,1:条件確認日時,2:透析開始日時,3:透析終了日時）
 * @param[in] state 装置ステータス
 * @param[in] date 日付
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_dev_date(long devNo, unsigned char *devCd, unsigned char *devId, short inpType, short state, time_t date) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    char dt[20], tm[10];
    char cdate[20];
    char dev_sno[10];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

    if ( inpType == 0 ) {	    // 条件送信日時
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_state/cond_send");
        strcpy(cbuff, "条件送信日時");
    }
    else if ( inpType == 1 ) {	// 条件確認日時
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_state/cond_set");
        strcpy(cbuff, "条件確認日時");
    }
    else if ( inpType == 2 ) {	// 透析開始日時
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_state/dial_start");
        strcpy(cbuff, "透析開始日時");
    }
    else {                      // 透析終了日時
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_state/dial_end");
        strcpy(cbuff, "透析終了日時");
    }

    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp( resFile );
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp( errFile );
    if ( fd != 0 ) close(fd);
 
    memset(dev_sno, 0, sizeof(dev_sno));
    memcpy(dev_sno, devId, 8);
    str_trim(dev_sno);

    // REST用文字列作成
    if ( time_str(date, dt, tm, 1) == 0 ) {
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        sprintf(cdate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
    }
    else {
        strcpy(cdate, "null");
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "装置状態管理の%s更新 (装置番号:%ld)", cbuff, devNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // RESTをコールする
    sprintf(
        cbuff
        , "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%d\" \"%s\" \"%s\" \"%s\""
        , url
        , facility_cd
        , devCd
        , dev_sno
        , state
        , cdate
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

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_ord_date(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, long patId, short state, long date)
// * @brief 治療情報の日付データを更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] inpYype 入力種別（0:条件送信日時,1:透析開始日時,2:透析終了日時）
// * @param[in] patId 患者ID
// * @param[in] state 治療状況
// * @param[in] date 日付
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_put_ord_date(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, long patId, short state, long date) {
/**
 * @fn int comsv_rest_put_ord_date(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, long patId, short state, time_t date)
 * @brief 治療情報の日付データを更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] inpYype 入力種別（0:条件送信日時,1:透析開始日時,2:透析終了日時）
 * @param[in] patId 患者ID
 * @param[in] state 治療状況
 * @param[in] date 日付
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_ord_date(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, long patId, short state, time_t date) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    char dt[20], tm[10];
    char param[40];
    char cdate[20];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    unsigned char cdata[40] = {0};
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

    if ( inpType == 0 ) {	    // 条件送信日時
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/send_date");
        strcpy(cbuff, "条件送信日時・状況");
    }
    else if ( inpType == 1 ) {	// 透析開始日時
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/start_date");
        strcpy(cbuff, "透析開始日時・状況");
    }
    else {                      // 透析終了日時
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/end_date");
        strcpy(cbuff, "透析終了日時・状況");
    }

    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    if ( state == 3 ) {
        // 治療中（運転開始時の更新）
        sprintf(param, "\"%ld\" \"%ld\"", ordNo, patId);
    }
    else {
        // その他
        sprintf(param, "\"%ld\"", ordNo);
    }

    // 日付を対象文字列に変換
    if ( time_str(date, dt, tm, 1) == 0 ) {
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        sprintf(cdate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
    }
    else {
        strcpy(cdate, "null");
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の%s更新 (オーダー番号:%ld)", cbuff, ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_put.sh \"%s\" %s \"%d\" \"%s\" \"%s\" \"%s\""
        , url
        , param
        , state
        , cdate
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        if ( inpType == 1 ) {	// 透析開始日時
            sprintf(cdata, "%ld", date);
            // output to file
            comsv_fail_append_data_full(facility_cd, devCd, devId, cdata, 2, 0);
        }
        else if ( inpType == 2 )  {  // 透析終了日時
        	sprintf(cdata, "%ld", date);
            // output to file
            comsv_fail_append_data_full(facility_cd, devCd, devId, cdata, 3, 0);
        }
            
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

// #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 start
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_ord_comptreat_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long staff_cd)
// * @brief 治療情報の実績愁訴処置者情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] occur_date 発生日時
// * @param[in] staff_cd 処置者コード
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_put_ord_comptreat_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long staff_cd) {
/**
 * @fn int comsv_rest_put_ord_comptreat_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, long staff_cd)
 * @brief 治療情報の実績愁訴処置者情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] occur_date 発生日時
 * @param[in] staff_cd 処置者コード
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_ord_comptreat_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, long staff_cd) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    char dt[20], tm[10];
    char odate[20];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/comptreat_staff");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    // 日付を対象文字列に変換
    if ( time_str(occur_date, dt, tm, 1) == 0 ) {
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        sprintf(odate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
    }
    else {
        strcpy(odate, "null");
    }
    sprintf(dt, "%ld", staff_cd);

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の実績愁訴処置者情報 (オーダー番号:%ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_put_fast.sh \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , ordNo
        , odate
        , dt
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の実績愁訴処置者情報");
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
        ret = comsv_rest_exec_ex(devCd, devId, cbuff, resFile, errFile, "治療情報の実績愁訴処置者情報", 3, 0);

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
// * @fn int comsv_rest_put_ord_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, short inpNo, long userId, long date)
// * @brief 治療情報の穿刺者／返血者／担当者情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] inpType 入力種別（0:穿刺者,1:返血者,2:担当者）
// * @param[in] inpNo 入力番号（1,2）
// * @param[in] userId 処置者ID
// * @param[in] date 日付
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_put_ord_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, short inpNo, long userId, long date) {
/**
 * @fn int comsv_rest_put_ord_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, short inpNo, long userId, time_t date)
 * @brief 治療情報の穿刺者／返血者／担当者情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] inpType 入力種別（0:穿刺者,1:返血者,2:担当者）
 * @param[in] inpNo 入力番号（1,2）
 * @param[in] userId 処置者ID
 * @param[in] date 日付
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_ord_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, short inpNo, long userId, time_t date) {
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
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

    if ( inpType == 0 ) {	    // 穿刺者
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/puncture_user");
        strcpy(cbuff, "穿刺者");
    }
    else if ( inpType == 1 ) {	// 回収者
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/return_user");
        strcpy(cbuff, "回収者");
    }
    else {                      // 担当者
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/charge_user");
        strcpy(cbuff, "担当者");
    }

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

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の%s%d更新, (オーダー番号:%ld)", cbuff, inpNo, ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_put.sh \"%s\" \"%d\" \"%ld\" \"%ld\" \"%s\" \"%s\" \"%s\""
        , url
        , inpNo
        , ordNo
        , userId
        , cdate
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

// #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 start
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_ord_oxygen(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long start_date, short amount)
// * @brief 治療情報の酸素吸入情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] occur_date 発生日時
// * @param[in] start_date 酸素吸入開始日時
// * @param[in] amount 酸素吸入量
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_put_ord_oxygen(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long start_date, short amount) {
/**
 * @fn int comsv_rest_put_ord_oxygen(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, time_t start_date, short amount)
 * @brief 治療情報の酸素吸入情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] occur_date 発生日時
 * @param[in] start_date 酸素吸入開始日時
 * @param[in] amount 酸素吸入量
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_ord_oxygen(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, time_t start_date, short amount) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    char dt[20], tm[10];
    char odate[20], sdate[20];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/oxygen");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    // 日付を対象文字列に変換
    if ( time_str(occur_date, dt, tm, 1) == 0 ) {
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        sprintf(odate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
    }
    else {
        strcpy(odate, "null");
    }
    if ( start_date ) {
        if ( time_str(start_date, dt, tm, 1) == 0 ) {
            dt[4] = dt[7] = tm[2] = tm[5] = 0;
            sprintf(sdate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
        }
        else {
            strcpy(sdate, "null");
        }
        strcpy(dt, "null");
        strcpy(cbuff, "酸素吸入開始情報");
    }
    else {
        strcpy(sdate, "null");
        sprintf(dt, "%d", amount);
        strcpy(cbuff, "酸素吸入終了情報");
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の%s更新 (オーダー番号:%ld)", cbuff, ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_put_fast.sh \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , ordNo
        , odate
        , sdate
        , dt
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
        ret = comsv_rest_exec_ex(devCd, devId, cbuff, resFile, errFile, logMessage, 3, 0);

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

// #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 start
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_ord_oxygen_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long staff_cd)
// * @brief 治療情報の酸素吸入処置者情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] occur_date 発生日時
// * @param[in] staff_cd 処置者コード
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_put_ord_oxygen_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long staff_cd) {
/**
 * @fn int comsv_rest_put_ord_oxygen_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, long staff_cd)
 * @brief 治療情報の酸素吸入処置者情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] occur_date 発生日時
 * @param[in] staff_cd 処置者コード
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_ord_oxygen_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, long staff_cd) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    int ret, fd, cw;
    char url[200];
    char resFile[40];
    char errFile[40];
    char dt[20], tm[10];
    char odate[20];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/oxygen_staff");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    // 日付を対象文字列に変換
    if ( time_str(occur_date, dt, tm, 1) == 0 ) {
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        sprintf(odate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
    }
    else {
        strcpy(odate, "null");
    }
    sprintf(dt, "%ld", staff_cd);

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の酸素吸入処置者情報更新 (オーダー番号:%ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_put_fast.sh \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , ordNo
        , odate
        , dt
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の酸素吸入処置者情報更新");
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
        ret = comsv_rest_exec_ex(devCd, devId, cbuff, resFile, errFile, "治療情報の酸素吸入処置者情報更新", 3, 0);

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

// #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 start
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_ord_medi_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long user_id, long date)
// * @brief 治療情報の実績投与薬剤実施者を更新を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] user_id 投与実施者コード
// * @param[in] date 投与実施日時
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_put_ord_medi_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long user_id, long date) {
/**
 * @fn int comsv_rest_put_ord_medi_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long user_id, time_t date)
 * @brief 治療情報の実績投与薬剤実施者を更新を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] user_id 投与実施者コード
 * @param[in] date 投与実施日時
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_ord_medi_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long user_id, time_t date) {
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
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/rst_medi_user");
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

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報の実績投与薬剤実施者更新 (オーダー番号:%ld)", ordNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_put_fast.sh \"%s\" \"%ld\" \"%ld\" \"%s\" \"%s\" \"%s\""
        , url
        , ordNo
        , user_id
        , cdate
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報の実績投与薬剤実施者更新");
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
        ret = comsv_rest_exec_ex(devCd, devId, cbuff, resFile, errFile, "治療情報の実績投与薬剤実施者更新", 3, 0);

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
// * @fn int comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, short devSta, short state, long date)
// * @brief 治療情報を登録（患者未登録運転）する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] devSta 装置ステータス
// * @param[in] state 治療状況
// * @param[in] date 日付
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, short devSta, short state, long date) {
/**
 * @fn int comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, short devSta, short state, time_t date)
 * @brief 治療情報を登録（患者未登録運転）する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] devSta 装置ステータス
 * @param[in] state 治療状況
 * @param[in] date 日付
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, short devSta, short state, time_t date) {
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
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/unregistered");
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

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "治療情報登録（患者未登録運転）, (装置番号:%ld)", devNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%ld\" \"%d\" \"%d\" \"%s\" \"%s\" \"%s\""
        , url
        , facility_cd
        , devNo
        , devSta
        , state
        , cdate
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報登録（患者未登録運転)");
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
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "治療情報登録（患者未登録運転)");

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
 * @fn int comsv_rest_put_scale_state(long devNo, unsigned char *devCd, unsigned char *devId, long scaleNo, short msgNo) 
 * @brief 体重計測定実績のステータス・メッセージデータを更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] scaleNo 条件送信管理番号
 * @param[in] msgNo メッセージ番号
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_scale_state(long devNo, unsigned char *devCd, unsigned char *devId, long scaleNo, short msgNo) {
    int ret, fd, cw;
    short state;
    char url[200];
    char resFile[40];
    char errFile[40];
    char message[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char msgText[50] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

    if ( scaleNo <= 0 ) {
        return -1;
    }

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/weight_scale");
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    if ( msgNo == 0 ) {
        state = 3;  // 条件送信成功
        strcpy(message, "null");
        snprintf(msgText, sizeof(msgText), "条件送信成功");
    }
    else {
        state = 4;  // 条件送信失敗
        sprintf(message, "%04X", msgNo);
        snprintf(msgText, sizeof(msgText), "条件送信失敗(%04X)", msgNo);
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "体重計測定実績更新, (条件送信管理番号: %ld/%s)", scaleNo, msgText);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%ld\" \"%d\" \"%s\" \"%s\" \"%s\""
        , url
        , facility_cd
        , scaleNo
        , state
        , message
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "体重計測定実績更新");
    if ( getCommAliveState() != 0 )
    {
        // AWSとDEの通信断
        // 退避ファイル
        ret = -9;
        
        // REST用文字列作成
        sprintf(
            cbuff
            , "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%ld\" \"%d\" \"%s\""
            , url
            , facility_cd
            , scaleNo
            , state
            , message
        );
        
        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);
        
        // output to file
        comsv_fail_append_data_full(facility_cd, devCd, devId, cbuff, 0, 0);
    }
    else
    {
        // RESTをコールする
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "体重計測定実績更新");

        if (ret != 0)
        {
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
            // ...
            cw = comsv_rest_connection_watch(devCd, devId);
            if (cw != 0) {
                setCommAliveState(1);

                // REST用文字列作成
                sprintf(
                    cbuff
                    , "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%ld\" \"%d\" \"%s\""
                    , url
                    , facility_cd
                    , scaleNo
                    , state
                    , message
                );
        
                // output to file
                comsv_fail_append_data_full(facility_cd, devCd, devId, cbuff, 0, 0);
            }
            // #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
        }
    }
    
    // mod AWSとDEの通信断からの復旧 高 end
    return ret;
}

/**
 * @fn int comsv_rest_put_pat_related(long devNo, unsigned char *devCd, unsigned char *devId, long patId, short mode, long ordNo, short status) 
 * @brief 患者基本情報関連（ステータス・透析回数）を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] patId 患者ID
 * @param[in] mode モード（0:ステータス,1:透析回数）
 * @param[in] ordNo オーダー番号（モードが1の場合は使用しない(0)）
 * @param[in] status ステータス（モードが1の場合は使用しない(0)）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_pat_related(long devNo, unsigned char *devCd, unsigned char *devId, long patId, short mode, long ordNo, short status) {
    int ret, fd, cw;
    char url[200];
    char param[40];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char modeText[20] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    // add AWSとDEの通信断からの復旧 高 end
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

    if ( patId <= 0 ) {
        return -1;
    }

    if ( mode == 0 ) {
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_pat/main");
        snprintf(modeText, sizeof(modeText), "ステータス");
    }
    else {
    	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_pat/unique");
        snprintf(modeText, sizeof(modeText), "透析回数");
    }
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);

    if ( mode == 0 ) {
        // ステータス更新
        sprintf(param, "\"%ld\" \"%ld\" \"%d\"", patId, ordNo, status);
    }
    else {
        // 透析回数更新
        sprintf(param, "\"%ld\"", patId);
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "患者基本情報更新 (患者ID: %ld/%s)", patId, modeText);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_rest_put.sh \"%s\" %s \"%s\" \"%s\""
        , url
        , param
        , resFile
        , errFile
    );

    // mod AWSとDEの通信断からの復旧 高 start
    // RESTをコールする
    // ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "患者基本情報更新");
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
        ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "患者基本情報更新");

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

// add 装置のSTATUS状態更新方法の変更 高 start
/**
 * @fn int comsv_rest_put_machineState(long devNo, unsigned char *devCd, unsigned char *devId, unsigned char state)
 * @brief 装置のSTATUS状態更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] state 装置ステータス
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_machineState(long devNo, unsigned char *devCd, unsigned char *devId, unsigned char state) {
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
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

    sprintf(url, "%s/comsv_state/updateMachineState", rest_device_edge_url);

    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp( resFile );
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp( errFile );
    if ( fd != 0 ) close(fd);
 
    memset(dev_sno, 0, sizeof(dev_sno));
    memcpy(dev_sno, devId, 8);
    str_trim(dev_sno);

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "装置のSTATUS状態更新(装置番号:%ld)", devNo);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // RESTをコールする
    sprintf(
        cbuff
        , "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%d\" \"%s\" \"%s\""
        , url
        , facility_cd
        , devCd
        , dev_sno
        , state
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
// add 装置のSTATUS状態更新方法の変更 高 end
