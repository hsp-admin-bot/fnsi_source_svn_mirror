/**
* @briefNTSSログ関連ヘッダーファイル
*
* @details NTSSログ関連
*
* @description ntss program

* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_log_lib.h
* @author H.Yonezawa
* @date 2017/11/29
*/

#ifndef NTSS_LOG_LIB_H
#define NTSS_LOG_LIB_H

#include <sys/types.h>
#include <sys/stat.h>


/// ログ種類
typedef enum NTSS_LOG_TYPE {
    NTSS_LOG_INFO,
    NTSS_LOG_DEBUG,
    NTSS_LOG_ERROR
} NtssLogType;


/**
* @brief ログ設定を行う
*
* @details ログ設定を行う
*
* @description
* @return なし
* @attention 特になし
*/
extern void 
setLogInfo();

/**
* @brief ログ設定（通信切断）を行う
*
* @details ログ設定（通信切断）を行う
*
* @description
* @return なし
* @attention 特になし
*/
void 
resetLogInfo();

/**
* @brief ログを送信する
*
* @details ログを送信する
*
* @description
* @param[in] type               種別コード
* @param[in] *msg               ログメッセージ
* @param[in] flag               出力フラフ（0:通常,1:システム情報有り）
* @param[in] *cMachineType      型式(不要な場合はから文字を指定)
* @param[in] *cMachineSerial    製造番号(不要な場合はから文字を指定)
* @return なし
* @attention 特になし
*/
extern void
LogSend( NtssLogType type
        , u_char *msg 
        , int flag
        , u_char *cMachineType
        , u_char *cMachineSerialNo
        );

/**
* @brief ログ出力を行う
*
* @details ログ出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @return なし
* @attention 特になし
*/
void
LogOutput( NtssLogType type
         , u_char *msg 
         );

// #12304 2025.10.24 add ログ強化（CRCエラー） TDC片口 start
/**
 * @fn void LogOutputBufferHex(NtssLogType type, unsigned char *headerMessage, unsigned char *buffer, int bufferSize, unsigned char *devType, unsigned char *devSerial)
 * @brief ログ出力（バッファ内のHEX出力）を行う
 * @param[in] type 種別コード
 * @param[in] headerMessage ヘッダ部メッセージ
 * @param[in] buffer バッファ
 * @param[in] bufferSize バッファサイズ
 * @param[in] devType 型式(不要な場合は空文字を指定)
 * @param[in] devSerial 製造番号(不要な場合は空文字を指定)
 * @return なし
 * @attention 特になし
 */
extern void LogOutputsHexDump(
    NtssLogType type, unsigned char *headerMessage,
    unsigned char *buffer, short bufferSize,
    unsigned char *devType, unsigned char *devSerial);
// #12304 2025.10.24 add ログ強化（CRCエラー） TDC片口 end

// #8729 2023.05.29 mod RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
/**
 * @fn void LogOutputs(NtssLogType type, u_char *msg, u_char *devType, u_char *devSerial)
 * @brief ログ出力（コンソール＆ファイル）を行う
 * @param[in] type 種別コード
 * @param[in] msg ログメッセージ
 * @param[in] flag 出力フラフ（0:通常,1:システム情報有り）
 * @param[in] devType 型式(不要な場合は空文字を指定)
 * @param[in] devSerial 製造番号(不要な場合は空文字を指定)
 */
extern void LogOutputs(NtssLogType type, u_char *msg, int flg, u_char *devType, u_char *devSerial);
// #8729 2023.05.29 mod RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end

/**
* @brief ログ+リソース出力を行う
*
* @details ログ+リソース出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @return なし
* @attention 特になし
*/
void
LogResourceOutput( NtssLogType type
                 , u_char *msg 
                 );

/**
* @brief ログ+ネットワーク状態出力を行う
*
* @details ログ+ネットワーク状態出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @return なし
* @attention 特になし
*/
void
LogNetworkOutput( NtssLogType type
                 , u_char *msg 
                 );

/**
* @brief エラー表示
*
* @details エラーを表示
*
* @description
* @param[in] *errmsg 表示エラーメッセージ文
* @return なし
* @attention 特になし
*/
extern void
viewError( char *errmsg
         );

/**
* @brief エラー表示+記録(+リソース出力)
*
* @details エラーを表示、記録する
*
* @description
* @param[in] *errmsg            表示エラーメッセージ文
* @param[in] *cMachineType      型式(不要な場合はから文字を指定)
* @param[in] *cMachineSerial    製造番号(不要な場合はから文字を指定)
* @return なし
* @attention 特になし
*/
extern void
viewErrorLogSend( char *errmsg
                , u_char *cMachineType
                , u_char *cMachineSerial
                );

/**
* @brief エラー表示+記録(+ネットワーク状態出力)
*
* @details エラーを表示、記録する
*
* @description
* @param[in] *errmsg            表示エラーメッセージ文
* @param[in] *cMachineType      型式(不要な場合はから文字を指定)
* @param[in] *cMachineSerial    製造番号(不要な場合はから文字を指定)
* @return なし
* @attention 特になし
*/
extern void
viewErrorLogSend2( char *errmsg
                 , u_char *cMachineType
                 , u_char *cMachineSerial
                 );

/**
* @brief ログファイルの削除
*
* @details 日付を超えた場合にログの削除を行う
*
* @description
* @prama[in] Mode   処理方法[0x00：日付が変わった時/0x01：強制実施]
* @return なし
* @attention 特になし
*/
extern void
deleteLogFile( u_char Mode 
             );
#endif
