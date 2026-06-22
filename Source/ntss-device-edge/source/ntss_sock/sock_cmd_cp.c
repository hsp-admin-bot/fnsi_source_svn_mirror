/**
* @file sock_cmd_cp.c
* @brief 共通プロトコル通信コマンド作成
* @author Y.Takamura
* @date 2018/09/14
* @details 共通プロトコル通信装置に送信するコマンド作成
*/

#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include "ntss_sock.h"

/**
* @fn int sock_cmd_cp(int thread_no, struct scn_data_fm *sp)
* @brief 共通プロトコル通信コマンド作成
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @return int 送信コマンド長
* @details 共通プロトコル通信装置に送信するコマンド作成
*/
int sock_cmd_cp(int thread_no, struct scn_data_fm *sp)
{
    int i;
    int sndlen;
    short sum;
    char dt[20];
    char tm[10];
 	u_char logMsg[256];
	unsigned char *bp;
	unsigned char buf[50];

	bp = sp->sndbuf;
    sp->sno++;
    if ( sp->sno < 0x11 ) {
        sp->sno = 0x11;
    }
    sndlen = 0;

    switch ( sp->comflg ) {

        case C_MONITOR:		// リクエストコマンド送信
			bp[0] = 'K';
			bp[1] = 0x0d;
			bp[2] = 0x0a;
			sndlen = 3;
            break;

        case C_CLOCK:       // 日時設定
            if ( sp->devsw == 'W' ) {
                break;
            }
			sprintf(logMsg, "通信スレッドCP[%d] : 日時設定 [%d]", thread_no, sp->dev_idx);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            memcpy(bp, "S4000", 5);
			sndlen = 5;
            sprintf(buf, "%012ld", 0L);
            memcpy(bp + sndlen, buf, 12);
			sndlen += 12;
            memcpy(bp + 2, "016", 3);
            memcpy(bp + sndlen, "DT00", 4);
            sndlen += 4;
            time_str(get_time(), dt, tm, 1);
            dt[4] = dt[7] = tm[2] = tm[5] = 0;
            sprintf(buf, "%s%s%s%s%s%s",
                dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
            memcpy(bp + sndlen, buf, 14);
            sndlen += 14;
            for ( i = 0, sum = 0; i < sndlen; i++ ) sum += bp[i];
            sprintf(buf, "%02x\r\n", (sum & 0xff));
            memcpy(bp + sndlen, buf, 4);
			sndlen += 4;
            break;

        default:            // その他
            sndlen = 0;
            break;

    }

	sp->sndlen = sndlen;
    return(sp->sndlen);
}
