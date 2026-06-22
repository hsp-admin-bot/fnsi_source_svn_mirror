/**
* @brief NTSSパケットバッファ処理ファイル
*
* @details NTSSパケットバッファを管理する
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_packet_buffer.c
* @author H.Yonezawa
* @date 2017/10/18
*/


/* 必要な機能
*   ・見つかったパケット管理情報のバッファにデータを追加する  (UpdateNTSSPacketBuffer)
*       ・バッファを超える場合の処理
*       ・バッファ内の先頭が指定キャラクタでない場合はバッファの内容を前に詰める
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <linux/types.h>
#include <stdbool.h>
#include <arpa/inet.h>


#include "ntss_packet_buffer.h"

#include "../common/libs/ntss_etc_lib.h"

#include "../common/nkklib/nkklib.h"


/**
* @brief 対象パケット管理情報のバッファにデータをセットする
*
* @details 対象パケット管理情報のバッファにデータをセットする
*
* @description
* @param[in] *nyssBuffer        バッファ情報
* @param[in] lastRecieveTime    最終受信日時
* @param[in] *data              格納データ
* @param[in] dataLength         格納データバイト数
* @return 0:正常終了/−１：格納失敗(バッファクリア)
* @attention 特になし
*/
int
UpdateNTSSPacketInfo( struct NTSS_BUFFER *ntssBuffer
                    , struct timeval  lastReceiveTime
                    , u_char *data
                    , int dataLength                      )
{
    int ret = -1;

    // バッファサイズの空きチェック
    if( ( ntssBuffer->nBufferSize + dataLength ) <= NTSS_PACKET_BUFFER_MAX )
    {
        // バッファにデータをセット
        memmove( ntssBuffer->cBuffer + ntssBuffer->nBufferSize, data, dataLength );
        ntssBuffer->nBufferSize += dataLength;

        ret = 0;
    }
    else
    {
        // バッファクリア

        ntssBuffer->nBufferSize = 0;
    }

    // 最終受信日付更新
    ntssBuffer->lastReceiveTime.tv_sec  = lastReceiveTime.tv_sec;
    ntssBuffer->lastReceiveTime.tv_usec = lastReceiveTime.tv_usec;

    return ret;
}

/**
* @brief 対象バッファ内で指定キャラクタが先頭になるまで前に詰める
*
* @details 対象バッファの先頭が指定されたキャラクタになるまで前に詰める
*
* @description
* @param[in] *ntbuffer  バッファ情報
* @param[in] *firstChar     先頭キャラクタ配列
* @param[in] nCharCount     先頭キャラクタ件数
* @return 0:正常終了/−１：該当なし(バッファクリア)
* @attention 特になし
*/
int
UpdateNTSSPacketInfoBuffer( struct NTSS_BUFFER *ntssBuffer
                          , u_char *firstChar
                          , int nCharCount
                          )
{
    int ret = 0;
    int intidx = -1;

    // バッファサイズの先頭から指定キャラクタがあるかどうかチェック
    int intlop;
    for( intlop = 0; intidx == -1 && intlop < ntssBuffer->nBufferSize; intlop ++ )
    {
        // 先頭キャラクタ判定
        int intlop2;
        for( intlop2 = 0; intlop2 < nCharCount; intlop2++ )
        {
            if( ntssBuffer->cBuffer[intlop] == firstChar[intlop2] )
            {
                intidx = intlop;
                break;
            }
        }
    }

    // 指定キャラクタがない場合
    if( intidx == -1 )
    {
        // バッファクリア

        ntssBuffer->nBufferSize = 0;

        ret = -1;
    }
    // 先頭以外が指定キャラクタであった場合
    else if( 0 < intidx)
    {
        // バッファ移動
        memmove( ntssBuffer->cBuffer, ntssBuffer->cBuffer + intidx, ntssBuffer->nBufferSize - intidx );

        // バッファサイズ更新
        ntssBuffer->nBufferSize -= intidx;
    }

    return ret;
}

//@}
