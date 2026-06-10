/**
* @briefNTSS RESTコール関連ヘッダーファイル
*
* @details NTSS RESTコール関連
*
* @description ntss program

* Copyright (C) 2023, TDC, all right reserved.
*
* @file ntss_restcall_lib.h
* @author Y.Takamura
* @date 2023/05/17
*/

#ifndef NTSS_RESTCALL_LIB_H
#define NTSS_RESTCALL_LIB_H

/**
 * @brief RESTコール再試行回数
 */
extern int _restcall_retry_count;

/**
 * @brief RESTコール再試行待ち時間（秒）
 */
extern int _restcall_wait_time;

/**
* @fn void initRestCall()
* @brief RESTコール処理初期化
*/
extern int initRestCall();

/**
 * @fn void setRestcallRetryCount(int value)
 * @brief RESTコール再試行回数を設定する
 * @param[in] value 再試行回数
 */
extern void setRestcallRetryCount(int value);

/**
 * @fn int getRestcallRetryCount()
 * @brief RESTコール再試行回数を取得する
 * @return 再試行回数
 */
extern int getRestcallRetryCount();

/**
 * @fn void setRestcallWaitTime(int value)
 * @brief RESTコール再試行待ち時間を設定する
 * @param[in] value 再試行待ち時間（秒）
 */
extern void setRestcallWaitTime(int value);

/**
 * @fn int getRestcallWaitTime()
 * @brief RESTコール再試行待ち時間を取得する
 * @return 再試行待ち時間（秒）
 */
extern int getRestcallWaitTime();

/**
 * @fn int ntss_restcall(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix)
 * @brief RESTコールして結果を取得する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @return 0:成功, その他:エラー
 */
extern int ntss_restcall(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix);

// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 start
/**
 * @fn int ntss_restcall_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime)
 * @brief RESTコールして結果を取得する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @param[in] retryCnt 再試行回数
 * @param[in] waitTime 再試行待ち時間
 * @return 0:成功, その他:エラー
 */
extern int ntss_restcall_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime);
// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 end


// #12003 2025.07.25 add 通信不可フラグを参照しないREST API呼び出しを可能とする TDC片口 start
#include <stdbool.h>
/**
 * @fn int ntss_restcall_force_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime)
 * @brief RESTコールして結果を取得する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @param[in] retryCnt 再試行回数
 * @param[in] waitTime 再試行待ち時間
 * @param[in] waitTime 再試行待ち時間
 * @param[in] isCheckCommEnable true: 通信不可フラグの影響を受ける, false: 常にREST呼び出しを試みる
 * @return 0:成功, その他:エラー
 */
extern int ntss_restcall_force_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime, bool isCheckCommEnable);
// #12003 2025.07.25 add 通信不可フラグを参照しないREST API呼び出しを可能とする TDC片口 end

#endif