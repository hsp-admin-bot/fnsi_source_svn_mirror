/**
* @file comsv_cmd_cp.c
* @brief 共通プロトコル通信コマンド作成
* @author Y.Takamura
* @date 2018/09/14
* @details 共通プロトコル通信装置に送信するコマンド作成
*/

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include "ntss_comsv.h"

// add FNSI-バグ 通信サーバ 高 start

/// デリミタ
#define NTSS_COMMON_CR  0x0d
#define NTSS_COMMON_LF  0x0a

/**
* @fn int comsv_cmd_cp(struct scn_data_fm *sp)
* @brief 共通プロトコル通信コマンドの送信コマンド長
* @param[in] sp 装置制御データ
* @return int 送信コマンド長
* @details 共通プロトコル通信装置に送信するコマンドの送信コマンド長
*/
int comsv_cmd_cp_size(struct scn_data_fm *sp)
{
    unsigned char *bp;
    int sndlen = 0;
    int intlop;
    
    bp = sp->sndbuf;
    
    for(intlop = 0; intlop < SNDMAX; intlop++) {
        // LF検索
        if(bp[intlop] == NTSS_COMMON_LF) {
            // CR検索
            if(bp[intlop - 1] == NTSS_COMMON_CR) {
                sndlen = intlop +1 ;
                break;
            }
        }
    }
    
    return sndlen;
}
// add FNSI-バグ 通信サーバ 高 end

/**
* @fn int comsv_cmd_cp(struct scn_data_fm *sp)
* @brief 共通プロトコル通信コマンド作成
* @param[in,out] sp 装置制御データ
* @return int 送信コマンド長
* @details 共通プロトコル通信装置に送信するコマンド作成
*/
int comsv_cmd_cp(struct scn_data_fm *sp)
{
    int i, max;
    int sndlen;
    short sum, num;
    double dnum;
    char dt[20];
    char tm[10];
    char fpath[64];
	unsigned char *bp;
	unsigned char buf[50];
	unsigned char dat[1000];
	unsigned char memo[512];
// add FNSI-Redmine＃3099/＃3100:（V3/V4）仕様に無い治療モードの場合に正しく変換して送信されない。 高 start
    unsigned char treatmentMode;
// add FNSI-Redmine＃3099/＃3100:（V3/V4）仕様に無い治療モードの場合に正しく変換して送信されない。 高 end
// add FNSI-Redmine＃3103:（V4）コメントデータコマンドにて、コメント内の改行が変換されない。 高 start
    unsigned char tbuf[50];
    // add FNSI-Redmine＃3103:（V4）コメントデータコマンドにて、コメント内の改行が変換されない。 高 end
    // add 通信共通プロトコルV4にて、OHDF時の補液速度が設定値と異なる。 高 start
    short numMax;
    // add 通信共通プロトコルV4にて、OHDF時の補液速度が設定値と異なる。 高 end
    // add FNSI-バグ 通信サーバ 高 start
    int snd_cmd_len;
    char str1[512];
    snd_cmd_len = 0;
    // add FNSI-バグ 通信サーバ 高 end

	bp = sp->sndbuf;
    sp->sno++;
    if ( sp->sno < 0x11 ) {
        sp->sno = 0x11;
    }
    sndlen = 0;

    switch ( sp->comflg ) {

        case C_RESPONSE:    // レスポンスデータ送信
            memcpy(bp, "R4002", 5);
			sndlen = 5;
            sprintf(buf, "%012ld", sp->pat_id);
            memcpy(bp + sndlen, buf, 12);
			sndlen += 12;
            memcpy(bp + sndlen, sp->rcvbuf + 17, 2);
			sndlen += 2;
            for ( i = 0, sum = 0; i < 35; i++ ) sum += bp[i];
            sprintf(buf, "%02x\r\n", (sum & 0xff));
            memcpy(bp + sndlen, buf, 4);
			sndlen += 4;
            break;

        case C_MONITOR:		// リクエストコマンド送信
			bp[0] = 'K';
			bp[1] = 0x0d;
			bp[2] = 0x0a;
			sndlen = 3;
            break;

        case C_JSET:        // 治療条件
        case C_NEXTPAT:     // コメントデータ
        case C_CLOCK:       // 日時設定
            if ( sp->comflg == C_JSET && sp->devsw == 'W' ) {
                // 共通プロトコルV3設定値書込の場合
                memcpy(bp, "S3096", 5);
                sndlen = 5;
                // 装置状態管理データを取得
                comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);
                i = comsv_rest_get_dev(sp->dev_no, sp->deviceType, sp->devid, fpath);
                printf("comsv_rest_get_dev = [%d]\n", i);
                i = comsv_json_dev_state(fpath, (0 + sp->next_pat_send), sp);
                sp->next_pat_send = 0;
                printf("comsv_json_dev_state = [%d]\n", i);
                // mod 通信共通プロトコル（V3/V4）患者IDが異なる 高 start
                // sprintf(buf, "%012ld", sp->next_pat_id);
                memset(tbuf, 0, sizeof(tbuf));
                memcpy(tbuf, sp->hosp_pat_id, 12);
                str_trim(tbuf);
                sprintf(buf, "%12s", tbuf);
                memcpy(bp + sndlen, buf, 12);
                // add FNSI-バグ 通信サーバ 高 start
                if ( sp->cond_send_cancel ) {
                    // 条件送信キャンセル（空白を設定）
                    memset(bp + sndlen, ' ', 12);
                }
                // add FNSI-バグ 通信サーバ 高 end
                sndlen += 12;
                // mod 通信共通プロトコル（V3/V4）患者IDが異なる 高 end
                // add FNSI-バグ 通信サーバ 高 start
                if ( !sp->cond_send_cancel ) {
                // add FNSI-バグ 通信サーバ 高 end
                    // JSON文字列から取得したハッシュ値をチェックする
                    i = comsv_json_dev_hash_check(fpath, sp->ord_no, sp->cond_send_hash);
                    printf("comsv_json_dev_hash_check = [%d]\n", i);
                    if ( i != 0 ) {
                        // ハッシュ値不一致
                        // 体重計測定実績のステータス・メッセージデータを更新する
                        comsv_rest_put_scale_state(sp->dev_no, sp->deviceType, sp->devid, sp->cond_send_ctrl, 3);
                        sp->reqflg[C_JSET] = 0;
                        sndlen = 0;
                        break;
                    }
                }
                // JSON文字列から条件送信データに格納する
                max = (SET2_NUM * 2);
                memset(dat, 0, sizeof(dat));
                i = comsv_json_dev_cond(fpath, 0, sp, dat, max);
                printf("comsv_json_dev_cond = [%d]\n", i);
                // 条件送信データからJSONファイルを作成する
                comsv_work_fpath(sp->dev_no, WORK_DEV_COND, fpath);
                i = comsv_json_dev_make_cond(fpath, dat, max);
                printf("comsv_json_dev_make_cond = [%d]\n", i);
                // 送信データ作成
                // 患者ID
                bp[sndlen] = 0xB1;
    			sndlen++;
                // mod 通信共通プロトコル（V3/V4）患者IDが異なる 高 start
                // sprintf(buf, "%012ld", sp->next_pat_id);
                memset(tbuf, 0, sizeof(tbuf));
                memcpy(tbuf, sp->hosp_pat_id, 12);
                str_trim(tbuf);
                sprintf(buf, "%12s", tbuf);
                // mod 通信共通プロトコル（V3/V4）患者IDが異なる 高 end
                memcpy(bp + sndlen, buf, 12);
                // add FNSI-バグ 通信サーバ 高 start
                if ( sp->cond_send_cancel ) {
                    // 条件送信キャンセル（空白を設定）
                    memset(bp + sndlen, ' ', 12);
                }
                // add FNSI-バグ 通信サーバ 高 end
    			sndlen += 12;
                // 患者名
                bp[sndlen] = 0xB2;
    			sndlen++;
				memcpy(bp + sndlen, dat + 8, 20);
                // add FNSI-バグ 通信サーバ 高 start
                if ( sp->cond_send_cancel ) {
                    // 条件送信キャンセル（空白を設定）
                    memset(bp + sndlen, ' ', 20);
                }
                // add FNSI-バグ 通信サーバ 高 end
    			sndlen += 20;
                // 治療モード
                bp[sndlen] = 0xB3;
    			sndlen++;
                // sprintf(bp + sndlen, "%d", hl_chg(*(short*)(dat + (15 * 2))));
                treatmentMode = hl_chg(*(short*)(dat + (15 * 2)));
                switch( treatmentMode )
                {
                    case 0: // HD
                    case 1: // ECUM
                    case 2: // HDF
                    case 3: // HF
                        break;
                    case 6: // AFBF
                        // HDF
                        treatmentMode = 2;
                        break;
                    case 7: // OHDF
                        // HDF
                        treatmentMode = 2;
                        break;
                    case 8: // OHF
                        // HF
                        treatmentMode = 3;
                        break;
                    default: // これ以外
                        treatmentMode = 0x20;
                        break;
                }
                if(treatmentMode == 0x20) {
                    bp[sndlen] = treatmentMode;
                }
                else {
                    sprintf(bp + sndlen, "%d", treatmentMode);
                }
                // mod FNSI-Redmine＃3099（V3）仕様に無い治療モードの場合に正しく変換して送信されない。 高 end
    			sndlen++;
                // 透析時間
                bp[sndlen] = 0xC1;
    			sndlen++;
                sprintf(bp + sndlen, "%05d", sp->dial_time);
    			sndlen += 5;
                // 除水時間
                bp[sndlen] = 0xC2;
    			sndlen++;
                sprintf(bp + sndlen, "%05d", hl_chg(*(short*)(dat + (14 * 2))));
    			sndlen += 5;
                // 目標除水量
                bp[sndlen] = 0xC3;
    			sndlen++;
                num = hl_chg(*(short*)(dat + (20 * 2)));
                sprintf(bp + sndlen, "%02d.%02d", num / 100, num % 100);
    			sndlen += 5;
                // add 通信共通プロトコルV4にて、OHDF時の補液速度が設定値と異なる。 高 start
                // 除水量制限
                numMax = hl_chg(*(short*)(dat + (43 * 2)));
                // 除水量制限を超えている場合は除水量制限の値にする。
                if( num > numMax ) {
                    num = numMax;
                }
                // add 通信共通プロトコルV4にて、OHDF時の補液速度が設定値と異なる。 高 end
                // 除水速度（目標除水量／透析時間）
                bp[sndlen] = 0xC4;
    			sndlen++;
                if ( hl_chg(*(short*)(dat + (14 * 2))) ) {
                    dnum = (double)hl_chg(*(short*)(dat + (14 * 2)));
                    dnum = (double)(num) / dnum * (double)(60);
                    num = (short)ceil(dnum);
                }
                else {
                    num = 0;
                }
                sprintf(bp + sndlen, "%02d.%02d", num / 100, num % 100);
    			sndlen += 5;
                // 補液時間
                bp[sndlen] = 0xC5;
    			sndlen++;
                sprintf(bp + sndlen, "%05d", hl_chg(*(short*)(dat + (14 * 2))));
    			sndlen += 5;
                // 目標補液量
                bp[sndlen] = 0xC6;
    			sndlen++;
                num = hl_chg(*(short*)(dat + (382 * 2)));
                sprintf(bp + sndlen, "%03d.%d", num / 10, num % 10);
    			sndlen += 5;
                // 補液速度（目標補液量／透析時間）
                bp[sndlen] = 0xC7;
    			sndlen++;
                // #11115 2024.10.13 mod 通信共通プロトコルV3の補液速度の桁が足りない TDC高村 start
                /*
                if ( hl_chg(*(short*)(dat + (14 * 2))) ) {
                    dnum = (double)hl_chg(*(short*)(dat + (14 * 2)));
                    dnum = (double)(num) / dnum * (double)(60);
                    num = (short)ceil(dnum);
                }
                else {
                    num = 0;
                }
                sprintf(bp + sndlen, "%03d.%d", num / 10, num % 10);
                */
                // V3の補液速度は小数点第2位まで
                if ( hl_chg(*(short*)(dat + (14 * 2))) ) {
                    dnum = (double)hl_chg(*(short*)(dat + (14 * 2)));
                    dnum = (double)(num) / dnum * (double)(60) * 10;
                    num = (short)ceil(dnum);
                }
                else {
                    num = 0;
                }
                sprintf(bp + sndlen, "%02d.%02d", num / 100, num % 100);
                // #11115 2024.10.13 mod 通信共通プロトコルV3の補液速度の桁が足りない TDC高村 end
    			sndlen += 5;
                // シリンジポンプ速度
                bp[sndlen] = 0xC8;
    			sndlen++;
                num = hl_chg(*(short*)(dat + (30 * 2)));
                sprintf(bp + sndlen, "%03d.%d", num / 10, num % 10);
    			sndlen += 5;
                // 透析液温度
                bp[sndlen] = 0xC9;
    			sndlen++;
                num = hl_chg(*(short*)(dat + (26 * 2)));
                sprintf(bp + sndlen, "%03d.%d", num / 10, num % 10);
    			sndlen += 5;
                // 補液温度
                bp[sndlen] = 0xCA;
    			sndlen++;
                num = hl_chg(*(short*)(dat + (381 * 2)));
                sprintf(bp + sndlen, "%03d.%d", num / 10, num % 10);
    			sndlen += 5;
                for (i=0, sum=0; i < sndlen; i++) sum += bp[i];
                sprintf(buf, "%02x\r\n", (sum & 0xff));
                memcpy(bp + sndlen, buf, 4);
                sndlen += 4;
                sp->cond_send_time = get_time(); // 条件送信時刻（コマンド送信時刻）
                
                // add FNSI-バグ 通信サーバ 高 start
                if ( sp->cond_send_cancel ) {
                    sp->cond_send_cancel = 0;
                    // 状況に応じた装置制御データのクリア
                    comsv_clear(3, sp);
                }
                // add FNSI-バグ 通信サーバ 高 end
                break;
            }
            memcpy(bp, "S4000", 5);
			sndlen = 5;
            // mod 通信共通プロトコル（V3/V4）患者IDが異なる 高 start
            if ( sp->comflg != C_NEXTPAT ) {
                // sprintf(buf, "%012ld", sp->next_pat_id);
                memset(tbuf, 0, sizeof(tbuf));
                memcpy(tbuf, sp->hosp_pat_id, 12);
                str_trim(tbuf);
                sprintf(buf, "%12s", tbuf);
                memcpy(bp + sndlen, buf, 12);
                // add FNSI-バグ 通信サーバ 高 start
                if ( sp->cond_send_cancel ) {
                    // 条件送信キャンセル（空白を設定）
                    memset(bp + sndlen, ' ', 12);
                }
                // add FNSI-バグ 通信サーバ 高 end
                sndlen += 12;
            }
            // mod 通信共通プロトコル（V3/V4）患者IDが異なる 高 end
            if ( sp->comflg == C_JSET ) {
                // 治療条件
                // 装置状態管理データを取得
                comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);
                // 直前に次回透析患者情報転送を実行している為、以下のRESTは処理しない
                    //i = comsv_rest_get_dev(sp->dev_no, sp->deviceType, sp->devid, fpath);
                    //printf("comsv_rest_get_dev = [%d]\n", i);
                // add FNSI-バグ 通信サーバ 高 start
                if ( !sp->cond_send_cancel ) {
                // add FNSI-バグ 通信サーバ 高 end
                    // JSON文字列から取得したハッシュ値をチェックする
                    i = comsv_json_dev_hash_check(fpath, sp->ord_no, sp->cond_send_hash);
                    printf("comsv_json_dev_hash_check = [%d]\n", i);
                    if ( i != 0 ) {
                        // ハッシュ値不一致
                        // 体重計測定実績のステータス・メッセージデータを更新する
                        comsv_rest_put_scale_state(sp->dev_no, sp->deviceType, sp->devid, sp->cond_send_ctrl, 3);
                        sp->reqflg[C_JSET] = 0;
                        sndlen = 0;
                        break;
                    }
                }
                // JSON文字列から条件送信データに格納する
                max = (SET2_NUM * 2);
                memset(dat, 0, sizeof(dat));
                i = comsv_json_dev_cond(fpath, 0, sp, dat, max);
                printf("comsv_json_dev_cond = [%d]\n", i);
                // 条件送信データからJSONファイルを作成する
                comsv_work_fpath(sp->dev_no, WORK_DEV_COND, fpath);
                i = comsv_json_dev_make_cond(fpath, dat, max);
                printf("comsv_json_dev_make_cond = [%d]\n", i);
                // 送信データ作成
                memcpy(bp + 2, "192", 3);
                memcpy(bp + sndlen, "TC", 2);
    			sndlen += 2;
                // 患者ID
                memcpy(bp + sndlen, "B1", 2);
    			sndlen += 2;
                // mod 通信共通プロトコル（V3/V4）患者IDが異なる 高 start
                // sprintf(buf, "%012ld", sp->next_pat_id);
                memset(tbuf, 0, sizeof(tbuf));
                memcpy(tbuf, sp->hosp_pat_id, 12);
                str_trim(tbuf);
                sprintf(buf, "%12s", tbuf);
                // mod 通信共通プロトコル（V3/V4）患者IDが異なる 高 end
                memcpy(bp + sndlen, buf, 12);
                // add FNSI-バグ 通信サーバ 高 start
                if ( sp->cond_send_cancel ) {
                    // 条件送信キャンセル（空白を設定）
                    memset(bp + sndlen, ' ', 12);
                }
                // add FNSI-バグ 通信サーバ 高 end
    			sndlen += 12;
                // 患者名
                memcpy(bp + sndlen, "B2", 2);
    			sndlen += 2;
				memcpy(bp + sndlen, dat + 8, 20);
                // add FNSI-バグ 通信サーバ 高 start
                if ( sp->cond_send_cancel ) {
                    // 条件送信キャンセル（空白を設定）
                    memset(bp + sndlen, ' ', 20);
                }
                // add FNSI-バグ 通信サーバ 高 end
    			sndlen += 20;
                // 治療モード
                // mod FNSI-Redmine＃3100:（V4）治療モードの定義が新通信と異なる部分について正しく変換されない。 高 start
                // sprintf(bp + sndlen, "B3%d", hl_chg(*(short*)(dat + (15 * 2))));
                treatmentMode = hl_chg(*(short*)(dat + (15 * 2)));
                switch( treatmentMode )
                {
                    case 0: // HD
                    case 1: // ECUM
                    case 2: // HDF
                    case 3: // HF
                        break;
                    case 6: // AFBF
                        // HDF
                        treatmentMode = 2;
                        break;
                    case 7: // OHDF
                        // OHDF
                        treatmentMode = 4;
                        break;
                    case 10: // I-HDF
                        // I‒HDF
                        treatmentMode = 5;
                        break;
                    default: // これ以外
                        treatmentMode = 0x20;
                        break;
                }
                memcpy(bp + sndlen, "B3", 2);
    			sndlen += 2;
                if(treatmentMode == 0x20) {
                    bp[sndlen] = treatmentMode;
                }
                else {
                    sprintf(bp + sndlen, "%d", treatmentMode);
                }
                sndlen += 1;
                // mod FNSI-Redmine＃3100:（V4）治療モードの定義が新通信と異なる部分について正しく変換されない。 高 end
                // 補液選択
                // mod FNSI-Redmine＃3105:（V4）通信共通プロトコルV4　補液選択の定義が異なる。 高 start
                // sprintf(bp + sndlen, "D1%d", hl_chg(*(short*)(dat + (388 * 2))));
                num = hl_chg(*(short*)(dat + (388 * 2)));
                if(num ==  0)
                    num = 1;
                else
                    num = 0;
                sprintf(bp + sndlen, "D1%d", num);
                // mod FNSI-Redmine＃3105:（V4）通信共通プロトコルV4　補液選択の定義が異なる。 高 end
    			sndlen += 3;
                // 前体重
                num = hl_chg(*(short*)(dat + (40 * 2)));
                sprintf(bp + sndlen, "D2%03d.%02d", num / 100, num % 100);
    			sndlen += 8;
                // ＤＷ
                num = hl_chg(*(short*)(dat + (41 * 2)));
                sprintf(bp + sndlen, "D3%03d.%02d", num / 100, num % 100);
    			sndlen += 8;
                // 透析時間
                sprintf(bp + sndlen, "C1%03d", sp->dial_time);
    			sndlen += 5;
                // 除水時間
                sprintf(bp + sndlen, "C2%03d", hl_chg(*(short*)(dat + (14 * 2))));
    			sndlen += 5;
                // 目標除水量
                num = hl_chg(*(short*)(dat + (20 * 2)));
                sprintf(bp + sndlen, "C3%d.%02d", num / 100, num % 100);
    			sndlen += 6;
                // add 通信共通プロトコルV4にて、OHDF時の補液速度が設定値と異なる。 高 start
                // 除水量制限
                numMax = hl_chg(*(short*)(dat + (43 * 2)));
                // 除水量制限を超えている場合は除水量制限の値にする。
                if( num > numMax ) {
                    num = numMax;
                }
                // add 通信共通プロトコルV4にて、OHDF時の補液速度が設定値と異なる。 高 end
                // 除水速度（目標除水量／透析時間）
                if ( hl_chg(*(short*)(dat + (14 * 2))) ) {
                    dnum = (double)hl_chg(*(short*)(dat + (14 * 2)));
                    dnum = (double)(num) / dnum * (double)(60);
                    num = (short)ceil(dnum);
                }
                else {
                    num = 0;
                }
                sprintf(bp + sndlen, "C4%d.%02d", num / 100, num % 100);
    			sndlen += 6;
                // 補液時間
                sprintf(bp + sndlen, "C5%03d", hl_chg(*(short*)(dat + (14 * 2))));
    			sndlen += 5;
                // 目標補液量
                num = hl_chg(*(short*)(dat + (382 * 2)));
                sprintf(bp + sndlen, "C6%02d.%d", num / 10, num % 10);
    			sndlen += 6;
                // 補液速度（目標補液量／透析時間）
                if ( hl_chg(*(short*)(dat + (14 * 2))) ) {
                    dnum = (double)hl_chg(*(short*)(dat + (14 * 2)));
                    dnum = (double)(num) / dnum * (double)(60);
                    num = (short)ceil(dnum);
                }
                else {
                    num = 0;
                }
                sprintf(bp + sndlen, "C7%02d.%d", num / 10, num % 10);
    			sndlen += 6;
                // シリンジポンプワンショット量
                num = hl_chg(*(short*)(dat + (33 * 2)));
                sprintf(bp + sndlen, "D4%02d.%d", num / 10, num % 10);
    			sndlen += 6;
                // シリンジポンプ速度
                num = hl_chg(*(short*)(dat + (30 * 2)));
                sprintf(bp + sndlen, "C8%02d.%d", num / 10, num % 10);
    			sndlen += 6;
                // シリンジポンプ自動停止時間
                sprintf(bp + sndlen, "D5%03d", hl_chg(*(short*)(dat + (37 * 2))));
    			sndlen += 5;
                // 血液流量
                sprintf(bp + sndlen, "D6%03d", hl_chg(*(short*)(dat + (28 * 2))));
    			sndlen += 5;
                // 透析液温度
                num = hl_chg(*(short*)(dat + (26 * 2)));
                sprintf(bp + sndlen, "C9%02d.%d", num / 10, num % 10);
    			sndlen += 6;
                // 補液温度
                num = hl_chg(*(short*)(dat + (381 * 2)));
                // #12547 2026.02.13 mod 補液温度が0の場合は半角空白を送信する TDC米沢 start
                // sprintf(bp + sndlen, "CA%02d.%d", num / 10, num % 10);
    			// sndlen += 6;
                strcpy(bp + sndlen, "CA");
                sndlen += 2;
                if (num == 0) {
                    strcpy(bp + sndlen, "    ");
                } else {
                    sprintf(bp + sndlen, "%02d.%d", num / 10, num % 10);
                }
                sndlen += 4;
                // #12547 2026.02.13 mod 補液温度が0の場合は半角空白を送信する TDC米沢 end
                // 透析液流量
                sprintf(bp + sndlen, "D7%04d", hl_chg(*(short*)(dat + (27 * 2))));
    			sndlen += 6;
                // I-HDF　初回補液時間
                sprintf(bp + sndlen, "D8%03d", hl_chg(*(short*)(dat + (203 * 2))));
    			sndlen += 5;
                // I-HDF　１回補液量
                sprintf(bp + sndlen, "D9%03d", hl_chg(*(short*)(dat + (200 * 2))));
    			sndlen += 5;
                // I-HDF　補液間隔
                sprintf(bp + sndlen, "DA%03d", hl_chg(*(short*)(dat + (202 * 2))));
    			sndlen += 5;
                // I-HDF　補液速度
                sprintf(bp + sndlen, "DB%03d", hl_chg(*(short*)(dat + (201 * 2))));
    			sndlen += 5;
                // 収縮期血圧上限
                sprintf(bp + sndlen, "DC%03d", hl_chg(*(short*)(dat + (211 * 2))));
    			sndlen += 5;
                // 収縮期血圧下限
                sprintf(bp + sndlen, "DD%03d", hl_chg(*(short*)(dat + (212 * 2))));
    			sndlen += 5;
                // 拡張期血圧上限
                sprintf(bp + sndlen, "DE%03d", hl_chg(*(short*)(dat + (213 * 2))));
    			sndlen += 5;
                // 拡張期血圧下限
                sprintf(bp + sndlen, "DF%03d", hl_chg(*(short*)(dat + (214 * 2))));
    			sndlen += 5;
                // 脈拍上限
                sprintf(bp + sndlen, "DG%03d", hl_chg(*(short*)(dat + (217 * 2))));
    			sndlen += 5;
                // 脈拍下限
                sprintf(bp + sndlen, "DH%03d", hl_chg(*(short*)(dat + (218 * 2))));
    			sndlen += 5;
                // 血圧自動測定間隔
                sprintf(bp + sndlen, "DI%03d", hl_chg(*(short*)(dat + (190 * 2))));
    			sndlen += 5;
                sp->cond_send_time = get_time(); // 条件送信時刻（コマンド送信時刻）
                
                // add FNSI-バグ 通信サーバ 高 start
                if ( sp->cond_send_cancel ) {
                    sp->cond_send_cancel = 0;
                    // 状況に応じた装置制御データのクリア
                    comsv_clear(3, sp);
                    
                    // 次患者情報を要求
                    sp->reqflg[C_NEXTPAT] = 1;
                }
                // add FNSI-バグ 通信サーバ 高 end
            }
            else if ( sp->comflg == C_NEXTPAT ) {
                // コメントデータ
                // 装置状態管理データを取得
                comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);
                i = comsv_rest_get_dev(sp->dev_no, sp->deviceType, sp->devid, fpath);
                printf("comsv_rest_get_dev = [%d]\n", i);
                i = comsv_json_dev_state(fpath, (0 + sp->next_pat_send), sp);
                sp->next_pat_send = 0;
                printf("comsv_json_dev_state = [%d]\n", i);
                // mod 通信共通プロトコル（V3/V4）患者IDが異なる 高 start
                memset(tbuf, 0, sizeof(tbuf));
                memcpy(tbuf, sp->hosp_pat_id, 12);
                str_trim(tbuf);
                sprintf(buf, "%12s", tbuf);
                memcpy(bp + sndlen, buf, 12);
                sndlen += 12;
                // mod 通信共通プロトコル（V3/V4）患者IDが異なる 高 end

                // #11405 2025.01.15 mod 次患者がなし[0]の場合は次患者要求を行わない TDC米沢 start
                // // 治療状況データを取得
                // comsv_work_fpath(sp->dev_no, WORK_DEV_NPAT, fpath);
                // i = comsv_rest_get_ord(sp->dev_no, sp->deviceType, sp->devid, sp->next_ord_no, fpath);
                // printf("comsv_rest_get_ord = [%d]\n", i);
                // i = comsv_json_ord_npat(fpath, dat);
    			// printf("comsv_json_ord_npat = [%d]\n", i);
                i = 0;
                // 次患者有無判定
                if(0 < sp->next_ord_no ){
                    // 次患者がある場合のみ処理を行う

                    // 治療状況データを取得
                    comsv_work_fpath(sp->dev_no, WORK_DEV_NPAT, fpath);
                    i = comsv_rest_get_ord(sp->dev_no, sp->deviceType, sp->devid, sp->next_ord_no, fpath);
                    printf("comsv_rest_get_ord = [%d]\n", i);
                    i = comsv_json_ord_npat(fpath, dat);
                    printf("comsv_json_ord_npat = [%d]\n", i);
                } else {
                    LogOutputs(NTSS_LOG_INFO, "次回透析患者なし", 0, sp->deviceType, sp->devid);
                }
                // #11405 2025.01.15 mod 次患者がなし[0]の場合は次患者要求を行わない TDC米沢 end

                if ( i <= 0 ) {
                    sp->need_to_send = 0;
                    // mod FNSI-バグ 通信サーバ 高 start
                    // 空データ送信
                    //sprintf(buf, "%03d", 24);
                    //memcpy(bp + 2, buf, 3);
                    memcpy(bp + sndlen, "CMDA", 4);
                    sndlen += 4;
                    // add FNSI-バグ 通信サーバ 高 start
                    snd_cmd_len += 2;
                    // add FNSI-バグ 通信サーバ 高 end
                    // 患者ID
                    memset(bp + 5, 0x20, 12);
                    // 患者名
                    memset(bp + sndlen, 0x20, 20);
                    sndlen += 20;
                    // add FNSI-バグ 通信サーバ 高 start
                    snd_cmd_len += 20;
                    // add FNSI-バグ 通信サーバ 高 end
                    memcpy(bp + sndlen, "DB", 2);
                    sndlen += 2;
                    // add FNSI-バグ 通信サーバ 高 start
                    snd_cmd_len += 2;
                    // add FNSI-バグ 通信サーバ 高 end
                    memset(bp + sndlen, 0x20, 1);
                    sndlen += 1;
                    // add FNSI-バグ 通信サーバ 高 start
                    snd_cmd_len += 1;
                    sprintf(buf, "%03d", snd_cmd_len);
                    memcpy(bp + 2, buf, 3);
                    // add FNSI-バグ 通信サーバ 高 end
                    // 次患者情報送信キャンセル
                    // sp->reqflg[sp->comflg] = 0;
                    // sndlen = 0;
                    // break;
                    // mod FNSI-バグ 通信サーバ 高 end
                }
                else {
                    sp->need_to_send = 1;
                    printf("comsv_json_ord_npat = [%d]\n", i);
                    memset(memo, 0, sizeof(memo));
                    for ( i = 0; i < 10; i++ ) {
                        memset(buf, 0, sizeof(buf));
                        memcpy(buf, dat + (i * 40) + 34, 40);
                        str_trim(buf);
                        if ( strlen(buf) > 0 ) {
                            // mod FNSI-Redmine＃3103:（V4）コメントデータコマンドにて、コメント内の改行が変換されない。 高 start
                            // strcat(buf, "\n");
                            // 0A→5C6E(\n)
                            tbuf[0] = 0x5C;
                            tbuf[1] = 0x6E;
                            tbuf[2] = '\0';
                            strcat(buf, tbuf);
                            // mod FNSI-Redmine＃3103:（V4）コメントデータコマンドにて、コメント内の改行が変換されない。 高 end
                            strcat(memo, buf);
                        }
                    }
                    i = strlen(memo);
                    sprintf(buf, "%03d", i + 24);
                    memcpy(bp + 2, buf, 3);
                    memcpy(bp + sndlen, "CMDA", 4);
        			sndlen += 4;
                    // add FNSI-バグ 通信サーバ 高 start
                    snd_cmd_len += 2;
                    // add FNSI-バグ 通信サーバ 高 end
                    // 患者名
                    memcpy(bp + sndlen, dat, 20);
        			sndlen += 20;
                    // add FNSI-バグ 通信サーバ 高 start
                    snd_cmd_len += 20;
                    // add FNSI-バグ 通信サーバ 高 end
                    memcpy(bp + sndlen, "DB", 2);
        			sndlen += 2;
                    // add FNSI-バグ 通信サーバ 高 start
                    snd_cmd_len += 2;
                    // add FNSI-バグ 通信サーバ 高 end
                    // メモ
                    if ( i > 0 ) {
                        memcpy(bp + sndlen, memo, i);
            			sndlen += i;
                    }
                    // add FNSI-バグ 通信サーバ 高 start
                    else {
                        memset(bp + sndlen, 0x20, 1);
                        sndlen += 1;
                        // add FNSI-バグ 通信サーバ 高 start
                        snd_cmd_len += 1;
                        sprintf(buf, "%03d", snd_cmd_len);
                        memcpy(bp + 2, buf, 3);
                        // add FNSI-バグ 通信サーバ 高 end
                    }
                    // add FNSI-バグ 通信サーバ 高 end
                }
            }
            else {
                // 日時設定
                memcpy(bp + 2, "016", 3);
                memcpy(bp + sndlen, "DT00", 4);
                sndlen += 4;
                time_str(get_time(), dt, tm, 1);
                dt[4] = dt[7] = tm[2] = tm[5] = 0;
                sprintf(buf, "%s%s%s%s%s%s",
                    dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
                memcpy(bp + sndlen, buf, 14);
                sndlen += 14;
            }
            for ( i = 0, sum = 0; i < sndlen; i++ ) sum += bp[i];
            sprintf(buf, "%02x\r\n", (sum & 0xff));
            memcpy(bp + sndlen, buf, 4);
			sndlen += 4;
            break;

        default:            // その他
            sndlen = 0;
            break;

    }
    // mod FNSI-バグ 通信サーバ 高 start
    // sp->sndlen = sndlen;
    if(sndlen == 0)
        sp->sndlen = sndlen;
    else {
        sp->sndlen = comsv_cmd_cp_size(sp);
        if(sp->sndlen != sndlen) {
            sprintf(str1, "[gs debug] : 送信コマンド長 = %d, 送信コマンド長(関数化) = %d", sndlen, sp->sndlen);
            LogOutputs(NTSS_LOG_INFO, str1, 0, "", "");
        }
    }
    // mod FNSI-バグ 通信サーバ 高 end
    return(sp->sndlen);
}
