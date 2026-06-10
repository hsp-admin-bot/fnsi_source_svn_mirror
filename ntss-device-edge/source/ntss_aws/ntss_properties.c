#include "ntss_properties.h"
#include "config_read.h"

//! 通信内容収集子プロセスのID
int _child_capture_app_pid = 0;

int getChildCaptureAppPid()
{
    return _child_capture_app_pid;
}
void setChildCaptureAppPid(int pid)
{
    _child_capture_app_pid = pid;
}

//! 装置記録マスタリロード必要
bool _is_mst_reload = false;
bool getIsMstReload()
{
    return _is_mst_reload;
}
void setIsMstReload(bool value)
{
    _is_mst_reload = value;
}

//! DE死活送信必要
bool _is_must_alivemoni_send = false;
bool getIsMustAliveMoniSend()
{
    return _is_must_alivemoni_send;
}
void setIsMustAliveMoniSend(bool value)
{
    _is_must_alivemoni_send = value;
}

//! WS死活応答有無フラグ
bool _is_response_ok = false;
bool getIsResponseOk()
{
    return _is_response_ok;
}
void setIsResponseOk(bool value)
{
    _is_response_ok = value;
}

//! 実行状態
RunningParameter_t _runningParameter = {0};

RunningParameter_t getRunningParameter()
{
    return _runningParameter;
}
void setRunningParameter(bool isRunning, bool isRcvSignal, u_char *message)
{
    _runningParameter.isRunning = isRunning;
    _runningParameter.isRcvSignal = isRcvSignal;
    sprintf(_runningParameter.exitMessage, "%s", message);
}

//! 処理中フラグ
bool _is_job_running = false;
bool getIsJobRunning()
{
    int status = 0;
    return _is_job_running;
}
void setIsJobRunning(bool value)
{
    _is_job_running = value;
}

// #8081 mod 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 start
//! クラウド通信不可フラグ
// bool _is_disabled_call_api = true;
// bool getIsDisabledCallApi()
// {
//     return _is_disabled_call_api;
// }
// void setIsDisabledCallApi(bool value)
// {
//     if (_is_disabled_call_api != value)
//     {
//         if (value)
//         {
//             LogOutput(NTSS_LOG_INFO, " 通信不可フラグ: TRUE");
//         }
//         else
//         {
//             LogOutput(NTSS_LOG_INFO, " 通信不可フラグ: FALSE");
//         }
//     }
//     if (_is_disabled_call_api && value == false)
//     {
//         // 装置死活状態取得
//         LogOutput(NTSS_LOG_INFO, " 装置死活状態収集シグナル送信");
//         kill(getChildCaptureAppPid(), SIG_ALIVE_MONI);
//     }
//     _is_disabled_call_api = value;
// }
// add AWSとDEの通信断からの復旧 高 start
// int _comm_alive_state;           /// COMM_ALIVE_STATE: 0---OK, 1---NG

// int getCommAliveState()
// {
//     return _comm_alive_state;
// }

// void setCommAliveState(int value)
// {
//     if (_comm_alive_state != value) {
//         if (value == 0) {
//             LogOutput(NTSS_LOG_INFO, "MAIN 通信State: OK");
//         }
//         else {
//             LogOutput(NTSS_LOG_INFO, "MAIN 通信State: NG");
//             //kill(getChildCaptureAppPid(), SIG_ALIVE_MONI);
//         }
//     }
//     _comm_alive_state = value;
// }
bool getIsDisabledCallApi()
{
    // 通信許可状態を反転
    return !isCommEnableState();
}
// #8730 2023.06.01 add AWSとの通信異常時に蓄積系データをcommFailDataへ移動 TDC米沢 start
// 初回通信許可フラグフラグ
bool isEnabledFirstAWSCommFlag = false;
// #8730 2023.06.01 add AWSとの通信異常時に蓄積系データをcommFailDataへ移動 TDC米沢 end
void setIsDisabledCallApi(bool requestState)
{
    //　通信不可状態取得
    bool nowState = getIsDisabledCallApi();

    // 通信状態判定
    if ( nowState != requestState)
    {
        // 通信状態変更あり
        if (requestState)
        {
            LogOutput(NTSS_LOG_INFO, " AWSとの通信状態：不可検出");
        }
        else
        {
            LogOutput(NTSS_LOG_INFO, " AWSとの通信状態：許可検出");

            // 初回通信許可フラグをセット
            isEnabledFirstAWSCommFlag = true;
        }

        // 通信状態が不可→許可となった場合
        if (nowState && !requestState)
        {
            // 装置死活状態取得
            LogOutput(NTSS_LOG_INFO, " 装置死活状態収集シグナル送信");
            kill(getChildCaptureAppPid(), SIG_ALIVE_MONI);
        }

        // 通信許可状態変更
        changeCommEnabledState(!requestState);
    }
}
int getCommAliveState()
{
    return getIsDisabledCallApi();
}
void setCommAliveState(int value)
{
    //　通信不可状態取得
    bool nowState = getIsDisabledCallApi();
    // 通信状態通知 value=0：許可/1：不許可
    bool mode = (value == 1);   
    if (nowState != mode) {
        if (mode) {
            LogOutput(NTSS_LOG_INFO, "COMSVからの通信不可通知を受信");
        }
        else {
            LogOutput(NTSS_LOG_INFO, "COMSVからの通信許可通知を受信");
        }

        // 通信状態変更
        setIsDisabledCallApi(mode);
    }
}
// #8081 mod 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 end

/**
 * @fn int comsv_rest_exec_1(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile) 
 * @brief RESTを実行して結果を取得する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @return 0:成功, その他:エラー
 */
int comsv_rest_exec_1(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix) {
    int ret;
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
    /*
    unsigned char logMessage[1024] = {0};
	unsigned char responseCode[256] = {0};

    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(restStr);

    if ( WIFEXITED(ret) ) {
        // 子プロセスが正常に終了した場合
        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS(ret);
    }
    if ( readFileOneLine(responseCode, 50, resFile) == 0 ) {
        snprintf(logMessage, sizeof(logMessage), "%s REST 応答あり, (%s)", logPrefix, responseCode);
    }
    else {
        snprintf(logMessage, sizeof(logMessage), "%s REST 実行システムコール応答, (%d)", logPrefix, ret);
    }
    // LogOutput(NTSS_LOG_INFO, logMessage);

    // 終了コード作成
    if ( 0 < ret ) {
        // 成功系
        if ( 200 == ret || 226 == ret ) {
            ret = 0;
        }
        else if ( 408 == ret ) {
            // コネクションタイムアウトエラー
            ret = -1;
        }
        else {
            // その他エラー
            ret = -2;
        }
    }
    else {
        // 取得失敗エラー
        ret = -3;
    }

    if ( ret < 0 && readFileOneLine(responseCode, 255, errFile) == 0 ) {
        snprintf(logMessage, sizeof(logMessage), "%s REST 失敗応答を取得, (%s)", logPrefix, responseCode);
        //LogOutput(NTSS_LOG_INFO, logMessage);
    }

    // 使用したファイルの消し込み作業
    removeFileFullPath(resFile);
    removeFileFullPath(errFile);
    
    sprintf(logMessage, "comsv_rest_exec ret = %d", ret);
    //LogOutput(NTSS_LOG_INFO, logMessage);
    */
    // RESTコールして結果を取得する
    ret = ntss_restcall(devCd, devId, restStr, resFile, errFile, logPrefix);
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end

    return ret;
}

/**
 * @fn int comsv_fail_alive_moni_main()
 * @brief 死活監視処理
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_fail_alive_moni_main()
{
    int ret;
    char url[200];
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char * resFile = "./tmpFailAliveMainResponseCode1.txt";
    // char * errFile = "./tmpFailAliveMainErrResponseCode1.txt";
    char * resFile = "/tmp/tmpFailAliveMainResponseCode1.txt";
    char * errFile = "/tmp/tmpFailAliveMainErrResponseCode1.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    unsigned char cbuff[512] = {0};
    char str1[512];

    ConfigParameter_t conf = getConfigParameter();

    // シーケンス図
    /// @msc "REST API CALL"
    /// edge [label="COMSV"],ec2 [label="EC2"];
    /// edge=>ec2 [label = "HTTP GET / PARAMETER"];
    /// edge<=ec2 [label = "HTTP STATUS / JSON"];
    /// @endmsc
    sprintf(url, "%s/device_edge/api/response_commfail", conf.awsHostUrl);
    
    // REST用文字列作成
    sprintf(
        cbuff, "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%s\"", url, resFile, errFile);
    
    // RESTをコールする
    ret = comsv_rest_exec_1("", "", cbuff, resFile, errFile, "死活監視処理取得");

    return ret;
}
// add AWSとDEの通信断からの復旧 高 end

// #8730 2023.06.01 add AWSとの通信異常時に蓄積系データをcommFailDataへ移動 TDC米沢 start
/**
 * @fn bool isEnabledFirstAWSComm();
 * @brief 初回通信許可フラグ状態
 * @return true:許可,false：不許可
 */
bool isEnabledFirstAWSComm() {
    return isEnabledFirstAWSCommFlag;
}
// #8730 2023.06.01 add AWSとの通信異常時に蓄積系データをcommFailDataへ移動 TDC米沢 end
