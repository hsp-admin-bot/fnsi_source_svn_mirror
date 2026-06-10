/**
* @brief NTSS通信共通プロトコル処理ヘッダーファイル
*
* @details NTSSでの通信共通プロトコル処理を行う
*
* @description ntss program
* Copyright (C) 2018, TDC, all right reserved.
*
* @file ntss_common_comm.h
* @author H.Yonezawa
* @date 2018/10/15
*/

#ifndef NTSS_COMMON_COMM_H
#define NTSS_COMMON_COMM_H

#include "ntss_packet_manage.h"


/// @name 通信共通プロトコル定数定義
//@{

/// STX
#define NTSS_COMMON_STX1    'K'
#define NTSS_COMMON_STX2    'S'
#define NTSS_COMMON_STX3    'R'
#define NTSS_COMMON_STX4    'E'
#define NTSS_COMMON_STX_COUNT 4

/// デリミタ
#define NTSS_COMMON_CR  0x0d
#define NTSS_COMMON_LF  0x0a

/// STX配列
static u_char NTSS_COMMON_STX[] = { NTSS_COMMON_STX1, NTSS_COMMON_STX2, NTSS_COMMON_STX3, NTSS_COMMON_STX4 };

//@}


/**
* @brief 対象パケット管理情報から通信共通プロトコルの電文を取得する
*
* @details 対象パケット管理情報のバッファから通信共通プロトコルの電文を取得する
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @param[out] *cmd          取得したコマンド(チェックサム、CRLF除去済み)
* @param[out] cmdLength     取得したコマンドサイズ
* @return 1：電文取得/0：電文なし/-1：チェックサム異常
* @attention 特になし
*/
extern int
getNTSSCommonCommand( struct NTSS_BUFFER *bufferInfo
                    , u_char *cmd
                    , int *cmdLength
                    );
/**
* @brief 対象パケット管理情報で通信共通プロトコルのモニタデータ登録処理を行う
*
* @details 対象パケット管理情報で通信共通プロトコルのモニタデータ登録処理を行う
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @param[in] dtNow          パケット受信日時
* @param[in] nAddr          モニタ項目番号
* @param[in] nData          モニタデータ
* @return なし
* @attention 特になし
*/
extern void 
setNTSSCommonMonitorData( struct NTSS_PACKET_INFORMATION *packetInfo 
                        , struct timeval dtNow
                        , short nAddr
                        , short nData
                        );
/**
* @brief 対象パケット管理情報で通信共通プロトコルの血圧測定ファイル出力処理を行う
*
* @details 対象パケット管理情報で通信共通プロトコルの血圧測定ファイル出力処理を行う
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @param[in] dtNow          パケット受信日時
* @param[in] cKind
* @param[in] cCode
* @param[in] nOccurDate
* @param[in] nOccurTime
* @param[in] nMax
* @param[in] nMin
* @param[in] nAve
* @param[in] nBpm
* @return 1：保存成功0：保存不要/−2：フォルダ作成失敗/-3:ファイル作成失敗
* @attention 特になし
*/
extern int 
outputNTSSCommonBloodLog( struct NTSS_PACKET_INFORMATION *packetInfo 
                        , struct timeval dtNow
                        , u_char cKind
                        , u_char cCode
                        , long nOccurDate
                        , long nOccurTime
                        , short nMax
                        , short nMin
                        , short nAve
                        , short nBpm
                        );


/**
* @brief 対象パケット管理情報で通信共通プロトコルの通信処理を行う
*
* @details 対象パケット管理情報で通信共通プロトコルの通信処理を行う
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @return 1：対象電文あり/0：対象電文なし/-1：チェックサム異常
* @attention 特になし
*/
extern int
checkNTSSCommonCommand( struct NTSS_PACKET_INFORMATION *packetInfo );

/**
* @brief 対象パケット管理情報で通信共通プロトコル用のモニタデータファイル名、及びモニタデータを取得する
*
* @details 対象パケット管理情報で通信共通プロトコル用のモニタデータファイル名、及びモニタデータを取得する
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @param[in] *cFileName     出力ファイル名
* @param[in] *cMonitorData  出力モニタデータ
* @return 1：取得成功/0：取得失敗
* @attention 特になし
*/
extern int
getNTSSCommonMonitorDataFile( struct NTSS_PACKET_INFORMATION *packetInfo
                            , u_char *cFileName
                            , u_char *cMonitorData
                            );

#endif
