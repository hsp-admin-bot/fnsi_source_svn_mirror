/**
* @file comsv_cmd_nx.c
* @brief NX通信コマンド作成
* @author Y.Takamura
* @date 2018/09/14
* @details NX通信装置に送信するコマンド作成
*/

#include <string.h>
#include <sys/time.h>
#include "ntss_comsv.h"

/**
* @fn int comsv_cmd_nx(struct scn_data_fm *sp)
* @brief NX通信コマンド作成
* @param[in,out] sp 装置制御データ
* @return int 送信コマンド長
* @details NX通信装置に送信するコマンド作成
*/
int comsv_cmd_nx(struct scn_data_fm *sp)
{
    int i;
    int sndlen;
	char bcd[10];
	char sdev[10], udev[20];
    unsigned char *bp, *dp, crc;
    unsigned char sbuf[SNDMAX];

	bp = sbuf;
    sp->sno++;
    if ( sp->sno < 0x11 ) {
        sp->sno = 0x11;
    }

    switch ( sp->comflg ) {

        case C_RESPONSE:    // レスポンスデータ送信(ACK)
			memcpy(bp, sp->rcvbuf, 22);
			bp[2] = 0x46;
			bp += 22;
			short_set(bp, 0);
			bp += 2;
			short_set(bp, 0);
			bp += 2;
			sndlen = 26;
            break;

		case C_OPTRD:		// 装置オプション読出
		case C_CLOCK:		// 装置時計設定
			*bp++ = 0x40;
			*bp++ = 0x1a;
			*bp++ = 0x46;
			*bp++ = 0x01;
			memset(sdev, 0, sizeof(sdev));
			memset(udev, 0, sizeof(udev));
			if ( sp->devsw != 'R' ) {
				sdev[0] = 0x20;
				memcpy(sdev+1, sp->devid, 7);
			}
			else {
				memcpy(sdev, sp->devid, sizeof(sp->devid));
			}
			sjistoutf16B(sdev, 16, udev);
			memcpy(bp, udev, 16);
			bp += 16;
			*bp++ = 0x00;
    		*bp++ = sp->sno;
			if ( sp->comflg == C_OPTRD ) {
				short_set(bp, 6);
				bp += 2;
				short_set(bp, 0);
				bp += 2;
				sndlen = 26;
			}
			else {
				short_set(bp, 4);
				bp += 2;
				short_set(bp, 12);
				bp += 2;
				short_set(bp, 1);
				bp += 2;
				memset(bcd, 0, sizeof(bcd));
				i = time_bcd(get_time(), bcd);
				bcd[0] = 0;
				memcpy(bp, bcd, 4);
				bp += 4;
				short_set(bp, i);
				bp += 2;
				memcpy(bp, bcd + 4, 2);
				bp += 2;
				*bp++ = 0x00;
				*bp++ = bcd[6];
				sndlen = 26 + 12;
			}
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

    return(sp->sndlen);
}
