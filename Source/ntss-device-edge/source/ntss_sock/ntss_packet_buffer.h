/**
* @brief NTSSパケットバッファ情報処理ヘッダーファイル
*
* @details NTSSパケットバッファを管理する
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_packet_buffer.h
* @author H.Yonezawa
* @date 2017/10/18
*/

#ifndef NTSS_PACKET_BUFFER_H
#define NTSS_PACKET_BUFFER_H


#include <sys/types.h>
#include <linux/types.h>



/// バッファサイズ
#define NTSS_PACKET_BUFFER_MAX 1024 * 4

///　バッファ用構造体
struct NTSS_BUFFER {
    struct timeval  lastReceiveTime;                    ///< 最終受信日時

    u_int           nBufferSize;                        ///< 現在のバッファサイズ
    u_char          cBuffer[ NTSS_PACKET_BUFFER_MAX ];  ///< バッファ領域
};


/**
* @brief 対象バッファ内で指定キャラクタが先頭になるまで前に詰める
*
* @details 対象バッファの先頭が指定されたキャラクタになるまで前に詰める
*
* @description
* @param[in] *ntssBuffer    バッファ管理情報
* @param[in] *firstChar     先頭キャラクタ配列
* @param[in] nCharCount     先頭キャラクタ件数
* @return 0:正常終了/−１：該当なし(バッファクリア)
* @attention 特になし
*/
extern int
UpdateNTSSPacketInfoBuffer( struct NTSS_BUFFER *ntssBuffer
                          , u_char *firstChar
                          , int nCharCount
                          );

/**
* @brief 対象バッファにデータをセットする
*
* @details 対象バッファにデータをセットする
*
* @description
* @param[in] *ntssBuffer        バッファ情報
* @param[in] lastRecieveTime    最終受信日時
* @param[in] *data              格納データ
* @param[in] dataLength         格納データバイト数
* @return 0:正常終了/−１：格納失敗(バッファクリア)
* @attention 特になし
*/
extern int
UpdateNTSSPacketInfo( struct NTSS_BUFFER *ntssBuffer
                    , struct timeval  lastReceiveTime
                    , u_char *data
                    , int dataLength
                    );

#endif
