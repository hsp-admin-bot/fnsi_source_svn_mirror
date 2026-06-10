/**
* @file sock_cmd.c
* @brief 新通信コマンド作成
* @author Y.Takamura
* @date 2018/09/14
* @details 新通信装置に送信するコマンド作成
*/

#include <stdio.h>
#include <string.h>
#include "ntss_sock.h"

/**
* @fn int sock_cmd(int thread_no, struct scn_data_fm *sp)
* @brief 新通信コマンド作成
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @return int 送信コマンド長
* @details 新通信装置に送信するコマンド作成
*/
int sock_cmd(int thread_no, struct scn_data_fm *sp)
{
    int i;
    int sndlen;
 	u_char logMsg[256];
    unsigned char crc;
    unsigned char *bp, *dp;
    unsigned char sbuf[SNDMAX];

    memset(sbuf, 0, sizeof(sbuf));
    bp = sbuf;
    *bp++ = sp->devsw;
    memcpy(bp, sp->devid, 7);
    bp += 7;
    if ( sp->comflg != C_RESPONSE ) {
        // レスポンスデータ送信以外ならsnoを加算
        sp->sno++;
        if ( sp->sno < 0x11 ) {
            sp->sno = 0x11;
        }
    }
    *bp++ = sp->sno;
    sndlen = 9;

    switch ( sp->comflg ) {

        case C_RESPONSE:    // レスポンスデータ送信
            *bp++ = sp->cmd;
            sndlen++;
            break;

		case C_OPTRD:		// 装置オプション読出
			sprintf(logMsg, "通信スレッドNEW[%d] : 装置オプション読出 [%d]", thread_no, sp->dev_idx);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
			sp->cmd = 0xe5;
			*bp++ = sp->cmd;
			sndlen++;
			break;

        case C_CLOCK:       // 装置時計設定
			sprintf(logMsg, "通信スレッドNEW[%d] : 装置時計設定 [%d]", thread_no, sp->dev_idx);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            sp->cmd = 0xe6;
            *bp++ = sp->cmd;
            sndlen++;
            i = time_bcd(get_time(), bp);
            *bp = i;    // 曜日
            sndlen += 7;
            break;

        default:            // その他
            sndlen = 0;
            break;
    }

    if ( sndlen > 0 ) {
        dp = sp->sndbuf;
        bp = sbuf;
        crc = 0;
        *dp++ = STX;
        for ( i = 0, sp->sndlen = 1; i < sndlen; i++, bp++ ) {
            crc += (*bp);
            if ( *bp == STX )      { *dp++ = DLE; *dp++ = DC2; sp->sndlen += 2; }
            else if ( *bp == ETX ) { *dp++ = DLE; *dp++ = DC3; sp->sndlen += 2; }
            else if ( *bp == DLE ) { *dp++ = DLE; *dp++ = DLE; sp->sndlen += 2; }
            else                   { *dp++ = (*bp); sp->sndlen++; }
        }
        if ( crc == STX )      { *dp++ = DLE; *dp++ = DC2; sp->sndlen += 2; }
        else if ( crc == ETX ) { *dp++ = DLE; *dp++ = DC3; sp->sndlen += 2; }
        else if ( crc == DLE ) { *dp++ = DLE; *dp++ = DLE; sp->sndlen += 2; }
        else                   { *dp++ = crc; sp->sndlen++; }
        *dp++ = ETX;
        sp->sndlen++;
    }
    else {
        sp->sndlen = 0;
    }

    return(sp->sndlen);
}
