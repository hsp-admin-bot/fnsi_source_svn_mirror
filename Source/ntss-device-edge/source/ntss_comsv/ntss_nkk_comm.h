/**
* @brief NTSS日機装新通信処理ヘッダーファイル
*
* @details NTSSでの日機装新通信処理を行う
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_nkk_comm.h
* @author H.Yonezawa
* @date 2017/10/18
*/

#ifndef NTSS_NKK_COMM_H
#define NTSS_NKK_COMM_H

#include "ntss_packet_manage.h"


/// @name 日機装通信定数定義
//@{

/// STX
#define NTSS_NKK_STX    0x02
/// ETX
#define NTSS_NKK_ETX    0x03
/// DLE
#define NTSS_NKK_DLE    0x10
/// DLE/STX
#define NTSS_NKK_DLE_STX    0x12
/// DLE/ETX
#define NTSS_NKK_DLE_ETX    0x13
/// NX判定識別子
#define NTSS_NKK_NX_ID  0x40

//@}

/// 日機装通信キャプチャ対象コマンド管理情報最大件数
#define NTSS_NKK_CAPTURE_COMMAND_KIND_COUNT 100

/// 日機装通信キャプチャ対象コマンド情報要構造体
struct NTSS_NKK_CAPTURE_COMMAND_INFORMATION {
    u_char  cCommType;          ///< 通信方式('0':通信なし/'1':新通信/'2'：NX通信/'3':通信共通V4)

    u_char  cCommandKind[2];    ///< コマンド種別

    u_char  cCommandId[7];      ///< コマンド識別子[6桁]+[\0]
    u_char  cOutputType;        ///< 電文ファイル出力先(0x00：緊急発報用/0x01：データ収集用)
};

/// キャプチャ対象コマンド管理情報配列
//extern struct NTSS_NKK_CAPTURE_COMMAND_INFORMATION captureCommandList[];


/**
* @brief 日機装通信キャプチャ対象コマンド情報設定ファイルを読み込む
*
* @details 日機装通信キャプチャ対象コマンド情報設定ファイルを読み込む
*
* @description
* @return 1：取得成功/0：取得失敗
* @attention 特になし
*/
extern int
initNTSSNKKCaptureCommandInfo();

/**
* @brief 指定したコマンド番号の日機装通信キャプチャ対象コマンド情報を取得する
*
* @details 指定したコマンド番号の日機装通信キャプチャ対象コマンド情報を取得する
*
* @description
* @param[in] cCommType  通信方式'0':通信なし/'1':旧通信/'2':新通信/'3'：NX通信/'4':通信共通V4)
* @param[in] *cCmdNo    コマンド
* @param[in] nCmdNoSize コマンド長さ
* @return NULL：取該当なし/else：該当した日機装通信キャプチャ対象コマンド情報用構造体ポインタ
* @attention 特になし
*/
extern struct NTSS_NKK_CAPTURE_COMMAND_INFORMATION *
getNTSSNKKCaptureCommandInfo( u_char cCommType
                            , u_char *cCmdNo
                            , int nCmdNoSize
                            );


/**
* @brief 対象パケット管理情報から通信電文を取得する
*
* @details 対象パケット管理情報のバッファから日機装装置の電文を取得する
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @param[out] *cmd          取得したコマンド(STX、ETX、DLE,チェックサム除去済み)
* @param[out] cmdLength     取得したコマンドサイズ
* @return 1：電文取得/0：電文なし/-1：チェックサム異常
* @attention 特になし
*/
extern int
getNTSSNKKCommand( struct NTSS_BUFFER *bufferInfo
                 , u_char *cmd
                 , int *cmdLength
                 );


/**
* @brief 対象パケット管理情報で日機装通信処理を行う
*
* @details 対象パケット管理情報で日機装信通信処理を行う
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @return 1：対象電文あり/0：対象電文なし/-1：チェックサム異常
* @attention 特になし
*/
extern int
checkNTSSNKKCommand( struct NTSS_PACKET_INFORMATION *packetInfo );
#endif
