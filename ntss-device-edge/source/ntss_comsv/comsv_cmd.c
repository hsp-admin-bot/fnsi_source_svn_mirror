/**
* @file comsv_cmd.c
* @brief 新通信コマンド作成
* @author Y.Takamura
* @date 2018/09/14
* @details 新通信装置に送信するコマンド作成
*/

#include <stdio.h>
#include <string.h>
#include "ntss_comsv.h"

/**
* @fn int comsv_cmd(int thread_no, struct scn_data_fm *sp)
* @brief 新通信コマンド作成
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @return int 送信コマンド長
* @details 新通信装置に送信するコマンド作成
*/
int comsv_cmd(int thread_no, struct scn_data_fm *sp)
{
    int i, max;
    // #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 start
    int ret;
    // #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 end
    int sndlen;
    char fpath[64];
    char buf[200], wrk[100];
 	u_char logMsg[256];
    unsigned char crc;
    unsigned char *bp, *dp, *dat;
    unsigned char sbuf[SNDMAX];
    // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
    u_char upData[512];
    short t_alert_no;   // お知らせ通知番号
    int j;
    int no[REQ41_MAX];
    // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end

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
            if ( sp->cmd == 0x67 ) {
                // ＬＣＤデータ要求のレスポンス（表示データ送信）
                if ( sp->lcd_request < 0 || sp->lcd_request > 56 ) {
                    // リクエストコード異常の場合
                    short_set(bp, 0);
                    bp += 2; sndlen += 2;
                }
                else {
                    // ＬＣＤ表示用データ作成
                    // #12257 2025.10.01 add DEのログに装置から受信したLCDデータのリクエストコードを出力する TDC高村 start
                    sprintf(logMsg, "通信スレッドNEW[%d] : 透析装置からのLCDデータ要求（リクエストコード：%d）", thread_no, sp->lcd_request);
                    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
                    // #12257 2025.10.01 add DEのログに装置から受信したLCDデータのリクエストコードを出力する TDC高村 end
                    short_set(bp, sp->lcd_request);
                    bp += 2; sndlen += 2;
                    i = comsv_lcd_disp(thread_no, bp, sp);
                    if ( i > 0 ) {
                        sndlen += i;
                    }
                    // #12411 2025.12.22 del 通信サーバが装置のLCD要求56にレスポンスしていない TDC高村 start
                    /*
                    else {
                        if ( sp->lcd_request == 56 ) {
                            // レポート画像転送（透析履歴）の場合はレスポンス無し
                            sndlen = 0;
                        }
                        else {
                            // 不正なデータの場合
                            short_set(bp, 0);
                            bp += 2; sndlen += 2;
                        }
                    }
                    */
                    // #12411 2025.12.22 del 通信サーバが装置のLCD要求56にレスポンスしていない TDC高村 end
                }
            }
            else if ( sp->cmd==0x68 ) {
                // ＬＣＤデータ送信のレスポンス
                if ( sp->lcd_request < 1 || sp->lcd_request > 14 ) {
                    // リクエストコード異常の場合
                    short_set(bp, 0);
                    bp += 2; sndlen += 2;
                }
                else {
                    // リクエストコード正常の場合
                    short_set(bp, sp->lcd_request);
                    bp += 2; sndlen += 2;
                }
            }
            break;

        case C_KANSRD:      // 警報監視状態読出
			sprintf(logMsg, "通信スレッドNEW[%d] : 警報監視状態読出 [%ld]", thread_no, sp->dev_no);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
			sp->cmd = 0xe3;
			*bp++ = sp->cmd;
            short_set(bp, 0);   // ADR
            bp += 2;
            max = MON1_NUM;
            if ( sp->devsw == 'P' || sp->devsw == 'Q' ) {
                max = MON2_NUM;
            }
            short_set(bp, max); // NUM
            bp += 2;
            sndlen += 5;
            break;

		case C_OPTRD:		// 装置オプション読出
			sprintf(logMsg, "通信スレッドNEW[%d] : 装置オプション読出 [%ld]", thread_no, sp->dev_no);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
			sp->cmd = 0xe5;
			*bp++ = sp->cmd;
			sndlen++;
			break;

        case C_CLOCK:       // 装置時計設定
			sprintf(logMsg, "通信スレッドNEW[%d] : 装置時計設定 [%ld]", thread_no, sp->dev_no);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            sp->cmd = 0xe6;
            *bp++ = sp->cmd;
            sndlen++;
            i = time_bcd(get_time(), bp);
            *bp = i;    // 曜日
            sndlen += 7;
            break;

        case C_JSETRD:      // 設定値読出
			sprintf(logMsg, "通信スレッドNEW[%d] : 設定値読出開始 [%ld]", thread_no, sp->dev_no);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            sp->cmd = 0xe9;
            *bp++ = sp->cmd;
            short_set(bp, 0);   // ADR
            bp += 2;
            if ( sp->devsw == 'I' || sp->devsw == 'J' ) {
                short_set(bp, SET1_NUM);    // NUM
            }
            else if ( sp->devsw == 'M' || sp->devsw == 'N' ) {
                short_set(bp, SET2_NUM);    // NUM
            }
            else {
                short_set(bp, SET3_NUM);    // NUM
            }
            bp += 2;
            sndlen += 5;
       		if ( sp->cond_read_flg == 1 ) {
                sp->cond_send_time = get_time(); // 条件送信時刻（コマンド送信時刻）
            }
            break;

        case C_JSET:        // 設定値書込
			sprintf(logMsg, "通信スレッドNEW[%d] : 設定値書込開始 [%ld]", thread_no, sp->dev_no);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            sp->cmd = 0xea;
            *bp++ = sp->cmd;
            short_set(bp, 0);   // ADR
            bp += 2;
            sndlen += 3;
            if ( sp->devsw == 'I' || sp->devsw == 'J' ) {
                max = (SET1_NUM * 2);
            }
            else if ( sp->devsw == 'M' || sp->devsw == 'N' ) {
                max = (SET2_NUM * 2);
            }
            else {
                max = (SET3_NUM * 2);
            }
            // JSON文字列から条件送信データに格納する
            comsv_work_fpath(sp->dev_no, WORK_DEV_COND, fpath);
            i = comsv_json_dev_cond(fpath, 1, sp, bp, max);
			printf("comsv_json_dev_cond = [%d]\n", i);
			// 装置状態管理データを取得
            comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);
            // 直前に次回透析患者情報転送を実行している為、以下のRESTは処理しない
			// i = comsv_rest_get_dev(sp->dev_no, sp->deviceType, sp->devid, fpath);
			// printf("comsv_rest_get_dev = [%d]\n", i);
            if ( !sp->cond_send_cancel ) {
                // 条件送信キャンセル以外の場合
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
            i = comsv_json_dev_cond(fpath, 0, sp, bp, max);
			printf("comsv_json_dev_cond = [%d]\n", i);
            // 条件送信データを対象装置・設定内容に応じて変更する
            comsv_cmd_cond_change(sp, bp);
            // 条件送信データからJSONファイルを作成する
            comsv_work_fpath(sp->dev_no, WORK_DEV_COND, fpath);
            i = comsv_json_dev_make_cond(fpath, bp, max);
            printf("comsv_json_dev_make_cond = [%d]\n", i);
            sp->cond_send_time = get_time(); // 条件送信時刻（コマンド送信時刻）
            if ( sp->cond_send_cancel ) {
                sp->cond_send_cancel = 0;
                // 条件送信キャンセル（空白を設定）
                memset(bp, ' ', 28);
				// 状況に応じた装置制御データのクリア
				comsv_clear(3, sp);
            }
            sndlen += max;
            break;

        case C_NEXTPAT:      // 次回透析患者情報転送
			sprintf(logMsg, "通信スレッドNEW[%d] : 次回透析患者情報転送開始 [%ld]", thread_no, sp->dev_no);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            sp->cmd = 0xeb;
            *bp++ = sp->cmd;
            sndlen++;
            max = 478;
			// 装置状態管理データを取得
            comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);
			i = comsv_rest_get_dev(sp->dev_no, sp->deviceType, sp->devid, fpath);
			printf("comsv_rest_get_dev = [%d]\n", i);
            // オーダ番号、患者IDを取得する（DBとの整合性）
 			i = comsv_json_dev_state(fpath, (0 + sp->next_pat_send), sp);
            sp->next_pat_send = 0;
			printf("comsv_json_dev_state = [%d]\n", i);

            // #11405 2025.01.15 mod 次患者がなし[0]の場合は次患者要求を行わない TDC米沢 start
            // // #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 start
            // for ( j=0; j<2; j++, usleep(50000) ) {
            //     ret = comsv_json_dev_npat1(fpath, 0, sp, bp + 438);
            //     sprintf(logMsg, "通信スレッドNEW[%d] : 次患者情報１ comsv_json_dev_state = [%d] comsv_json_dev_npat1 = [%d], retry (lib) = [%d]", thread_no, i, ret, j + 1);
            //     LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            //     if ( ret == 0 ) break;
            // }
            // if ( ret != 0 ) {
            //     for ( j=0; j<2; j++, usleep(50000) ) {
            //         ret = comsv_json_dev_npat1(fpath, 1, sp, bp + 438);
            //         sprintf(logMsg, "通信スレッドNEW[%d] : 次患者情報１ comsv_json_dev_state = [%d] comsv_json_dev_npat1 = [%d], retry (org) = [%d]", thread_no, i, ret, j + 1);
            //         LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            //         if ( ret == 0 ) break;
            //     }
            // }
			// // 治療状況データを取得
            // comsv_work_fpath(sp->dev_no, WORK_DEV_NPAT, fpath);
            // i = comsv_rest_get_ord(sp->dev_no, sp->deviceType, sp->devid, sp->next_ord_no, fpath);
			// printf("comsv_rest_get_ord = [%d]\n", i);
            // i = comsv_json_ord_npat(fpath, bp);
			// printf("comsv_json_ord_npat = [%d]\n", i);
			// sprintf(logMsg, "通信スレッドNEW[%d] : 次患者情報１ next_ord_no = [%ld] comsv_json_ord_npat = [%d]", thread_no, sp->next_ord_no, i);
		    // LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            i = 0;
            // 次患者有無判定
            // #12456 2026.01.19 mod 未登録運転の場合、治療情報データ取得を行わない TDC高村 start
            //if(0 < sp->next_ord_no ){
            if ( 0 < sp->next_ord_no && 0 < sp->next_pat_id ) {
            // #12456 2026.01.19 mod 未登録運転の場合、治療情報データ取得を行わない TDC高村 end
                // 次患者がある場合のみ処理を行う

                // #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 start
                for ( j=0; j<2; j++, usleep(50000) ) {
                    ret = comsv_json_dev_npat1(fpath, 0, sp, bp + 438);
                    sprintf(logMsg, "通信スレッドNEW[%d] : 次患者情報１ comsv_json_dev_state = [%d] comsv_json_dev_npat1 = [%d], retry (lib) = [%d]", thread_no, i, ret, j + 1);
                    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
                    if ( ret == 0 ) break;
                }
                if ( ret != 0 ) {
                    for ( j=0; j<2; j++, usleep(50000) ) {
                        ret = comsv_json_dev_npat1(fpath, 1, sp, bp + 438);
                        sprintf(logMsg, "通信スレッドNEW[%d] : 次患者情報１ comsv_json_dev_state = [%d] comsv_json_dev_npat1 = [%d], retry (org) = [%d]", thread_no, i, ret, j + 1);
                        LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
                        if ( ret == 0 ) break;
                    }
                }
                // 治療状況データを取得
                comsv_work_fpath(sp->dev_no, WORK_DEV_NPAT, fpath);
                i = comsv_rest_get_ord(sp->dev_no, sp->deviceType, sp->devid, sp->next_ord_no, fpath);
                printf("comsv_rest_get_ord = [%d]\n", i);
                i = comsv_json_ord_npat(fpath, bp);
                printf("comsv_json_ord_npat = [%d]\n", i);
                sprintf(logMsg, "通信スレッドNEW[%d] : 次患者情報１ next_ord_no = [%ld] comsv_json_ord_npat = [%d]", thread_no, sp->next_ord_no, i);
                LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            } else {
                sprintf(logMsg, "通信スレッドNEW[%d] : 次回透析患者なし", thread_no);
                LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            }
            // #11405 2025.01.15 mod 次患者がなし[0]の場合は次患者要求を行わない TDC米沢 end

            if ( i <= 0 ) {
                sp->need_to_send = 0;
                // 空データ送信
                memset(bp, 0x20, 434);
                memcpy(bp + 20, "    /  /  ", 10);
                memset(bp + 434, 0, 4);
                comsv_json_dev_npat1("", 0, sp, bp + 438);
            }
            else {
                sp->need_to_send = 1;
            }
            // #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 end
            sndlen += max;
            break;

        case C_NEXTPAT2:     // 次回透析患者情報２転送
			sprintf(logMsg, "通信スレッドNEW[%d] : 次回透析患者情報２開始 [%ld]", thread_no, sp->dev_no);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            sp->cmd = 0xed;
            *bp++ = sp->cmd;
            sndlen++;
            // #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 start
            if ( sp->need_to_send ) {
                // 装置状態管理データを取得
                comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);
                for ( j=0; j<2; j++, usleep(50000) ) {
                    ret = comsv_json_dev_npat2(fpath, 0, bp);
                    sprintf(logMsg, "通信スレッドNEW[%d] : 次患者情報２ need_to_send = [%d] comsv_json_dev_npat2 = [%d], retry (lib) = [%d]", thread_no, sp->need_to_send, ret, j + 1);
                    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
                    if ( ret == 0 ) break;
                }
                if ( ret != 0 ) {
                    for ( j=0; j<2; j++, usleep(50000) ) {
                        ret = comsv_json_dev_npat2(fpath, 1, bp);
                        sprintf(logMsg, "通信スレッドNEW[%d] : 次患者情報２ need_to_send = [%d] comsv_json_dev_npat2 = [%d], retry (org) = [%d]", thread_no, sp->need_to_send, ret, j + 1);
                        LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
                        if ( ret == 0 ) break;
                    }
                }
            }
            else {
                // 空データ送信
                ret = comsv_json_dev_npat2("", 0, bp);
    			sprintf(logMsg, "通信スレッドNEW[%d] : 次患者情報２ need_to_send = [%d] comsv_json_dev_npat2 = [%d]", thread_no, sp->need_to_send, ret);
    		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
            }
            // #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 end
            sndlen += 102;
            break;

		case C_DELETE:      // 画像データ削除
            // 条件送信キャンセルのタイミングで実施
			sp->cmd = 0xef;
			*bp++ = sp->cmd;
			sndlen++;
			break;

		case C_NOTICE:      // お知らせ情報転送
            // 特定のタイミングで実施
			sp->cmd = 0xf1;
			*bp++ = sp->cmd;
            // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
            t_alert_no = sp->alert_no;
            // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end
            if ( sp->notice_chg_flg ) {
                sp->notice_chg_flg = 0;
                // お知らせ情報転送（投薬指示変更）
                strcpy(buf, "投薬指示の変更が有りました。");
                memset(wrk, 0, sizeof(wrk));
                utf8tosjis(buf, wrk);
				comsv_lcd_memcpy(bp, wrk, 39);
                bp += 39;
    			*bp++ = 0x00;
            }
            else {
                // お知らせ情報転送
    			LcddataReq41_t req41;
                comsv_work_fpath(sp->dev_no, WORK_LCD_REQ41, fpath);
    			comsv_json_lcd_req41(fpath, &req41);
                if ( sp->alert_no > 0 && sp->alert_no <= ALERT_NUM ) {
                    i = sp->alert_no - 1;
                    sp->alert_no = 0;
                    sp->alert_time[i] = -1;
                    str_trim( req41.name[i] );
                    // del お知らせで装置に送信するデータが一定でない。 高 start
                    // str_trim( req41.amount[i] );
                    // del お知らせで装置に送信するデータが一定でない。 高 end
                    str_trim( req41.unit[i] );
                    memset(buf, 0, sizeof(buf));
                    memcpy(buf, req41.name[i], sizeof(req41.name[i]));
                    memcpy(buf + 40, req41.amount[i], sizeof(req41.amount[i]));
                    memcpy(buf + 50, req41.unit[i], sizeof(req41.unit[i]));
                    max = 39 - (1 + strlen(buf + 40) + strlen(buf + 50));
        			comsv_lcd_memcpy(bp, buf, max);
                    bp += max;
            		*bp++ = 0x20;
                    max = strlen(buf + 40);
        			comsv_lcd_memcpy(bp, buf + 40, max);
                    bp += max;
                    max = strlen(buf + 50);
        			comsv_lcd_memcpy(bp, buf + 50, max);
                    bp += max;
            		*bp++ = 0x00;
                }
                else {
                    sndlen = 0;
                    break;
                }
            }
			sndlen += 41;
            // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
            // お知らせ情報転送
            LcddataReq41_t req41_1;
            comsv_work_fpath(sp->dev_no, WORK_LCD_REQ41, fpath);
            comsv_json_lcd_req41(fpath, &req41_1);
            if ( t_alert_no > 0 && t_alert_no <= ALERT_NUM ) {
                i = t_alert_no - 1;
                // 未投与薬剤データからJSONデータを作成
                j = comsv_json_host_make_medi(upData, req41_1.no[i], sp);
                printf("comsv_json_host_make_medi = [%d]\n", j);
                // 投薬タイミング通知処理
                j = comsv_rest_post_notice_medi(sp->dev_no, sp->deviceType, sp->devid, upData);
                printf("comsv_rest_post_notice_medi = [%d]\n", j);
                
            }
            // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end
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

/**
* @fn int comsv_cmd_fileio(char *fname, int mode, unsigned char *data, int len)
* @brief コマンドデータ読込
* @param[in] fname ファイルパス
* @param[in] mode モード（0:Read.1:Write）
* @param[out] data データ格納用
* @param[in] len 読み込みサイズ
* @return 0:成功, -1:エラー
* @details コマンドデータをファイルから読み込む
*/
int comsv_cmd_fileio(char *fname, int mode, unsigned char *data, int len)
{
    int ret = -1;
    FILE *fp;

    if ( mode == 0 ) {
        // Read モード
        memset(data, 0, len);
        fp = fopen(fname, "rb");
        if (fp != NULL) {
            fread(data, 1, len, fp);
            fclose(fp);
            ret = 0;
        }
    }
    else {
        // Write モード
        fp = fopen(fname, "wb");
        if (fp != NULL) {
            fwrite(data, 1, len, fp);
            fclose(fp);
            ret = 0;
        }
    }
    return ret;
}

/**
* @fn int comsv_cmd_npat2_check(struct scn_data_fm *sp)
* @brief 次患者情報２の送信可否チェック
* @param[in,out] sp 装置制御データ
* @return 0:送信不可, 1:送信可能
* @details 次患者情報２が送信可能かチェックする
*/
int comsv_cmd_npat2_check(struct scn_data_fm *sp)
{
    int ret = 0;

    if ( sp->devsw != 'J' ) {
        // 通信フォーマットが'I','M','N','P','Q'の場合
        if ( sp->option[1] & (1 << 11) ) {
            // 装置オプション：オンライン補充液（透析液）
            ret = 1;
        }
        else if ( sp->option[1] & (1 << 13) ) {
            // 装置オプション：Ｄ−ＦＡＳ
            ret = 1;
        }
    }
    return ret;
}

/**
* @fn void comsv_cmd_cond_change(struct scn_data_fm *sp, unsigned char *data)
* @brief 条件送信データを対象装置・設定内容に応じて変更
* @param[in] sp 装置制御データ
* @param[out] data 設定値データ
* @details 条件送信データ（設定値）を対象装置・設定内容に応じて変更する
*/
void comsv_cmd_cond_change(struct scn_data_fm *sp,  unsigned char *data)
{
    int addr;
    short val;
    short chg;

    // 透析量プログラム制御（オプション状態で透析量プログラム選択を変更）
    if ( sp->devsw != 'J' && (sp->option[1] & (1 << 12)) == 0 ) {
        // 装置が’J’以外かつ装置オプション（透析量プログラム）が「OFF」の場合
        // 強制的に透析量プログラム選択を「しない」に設定
        short_set(data + (282 * 2), 0);
    }

    // #11124 2025.07.28 add 酸素飽和度対応 TDC高村 start
    // ΔSO2制御（オプション状態でΔSO2低下報知点を変更）
    if ( (sp->devsw == 'P' || sp->devsw == 'Q') && (sp->option[2] & (1 << 6)) == 0 ) {
        // 装置が'P'又は'Q'かつ装置オプション（ΔSO2使用選択）が「OFF」の場合
        // 強制的にΔSO2低下報知点を「0」に設定
        short_set(data + (476 * 2), 0);
    }
    // #11124 2025.07.28 add 酸素飽和度対応 TDC高村 end

    // 特定条件時の設定値内容調整(AFBFで濃度PG・SNをOFF、濃度PGがONでNaPGをOFF) 
    if ( hl_chg(*(short*)(data + (15 * 2))) == 6 ) {
        // 治療モードが「AFBF」の場合
        // 強制的にシングルニードル電源SWを「0:OFF」に設定
        short_set(data + (23 * 2), 0);
        // 強制的に濃度プログラム電源SWを「0:OFF」に設定
        short_set(data + (340 * 2), 0);
        // add 通信共通プロトコルV4にて、OHDF時の補液速度が設定値と異なる。 高 start
        // 強制的にNa注入プログラム電源SWをOFFに設定
        short_set(data + (315 * 2), 0);
        // TMP監視モードが「TMP自動追従」の場合、「TMP自動設定」に変更
        if ( hl_chg(*(short*)(data + (240 * 2))) == 0 ) {
            short_set(data + (240 * 2), 1);
        }
        // add 通信共通プロトコルV4にて、OHDF時の補液速度が設定値と異なる。 高 end
    }
    else if ( hl_chg(*(short*)(data + (340 * 2))) != 0 ) {
        // 濃度プログラム電源SWが「ON」の場合
        // 強制的にNa注入プログラム電源SWを「0:OFF」に設定
        short_set(data + (315 * 2), 0);
    }

    // 治療モード「プログラム補液」追加
    if ( hl_chg(*(short*)(data + (15 * 2))) == 10 ) {
        // 治療モードが「10：I-HDF(旧[プログラム補液])」の場合
        // 除水計算優先項目選択を強制的に「0」に設定
        short_set(data + (22 * 2), 0);
        // 除水開始遅延時間を強制的に「0」に設定
        short_set(data + (39 * 2), 0);
        // UFRプログラム電源SWを強制的に「0」に設定
        short_set(data + (290 * 2), 0);
    }

    // 設定値調整(UFRプロ電源SWがコースの場合、UFRプロ最終位置を「10」)
    if ( hl_chg(*(short*)(data + (290 * 2))) == 2 ) {
        // UFRプログラム電源SWが「2:コース」だった場合
        // 強制的にUFRプログラム最終位置を「10」に設定
        short_set(data + (311 * 2), 10);
    }

    // 最高血圧上限などの血圧関連設定値における値調整
    val = hl_chg(*(short*)(data + (191 * 2)));
    if ( hl_chg(*(short*)(data + (190 * 2))) == 0 ) {
        // 血圧自動測定間隔を強制的に「30」に設定
        short_set(data + (190 * 2), 30);
    }
    if ( hl_chg(*(short*)(data + (211 * 2))) == 0 ) {
        // 最高血圧上限
        chg = (short)(0 == val ? 250 : 120);
        short_set(data + (211 * 2), chg);
    }
    if ( hl_chg(*(short*)(data + (213 * 2))) == 0 ) {
        // 最低血圧上限
        chg = (short)(0 == val ? 200 : 90);
        short_set(data + (213 * 2), chg);
    }
    if ( hl_chg(*(short*)(data + (217 * 2))) == 0 ) {
        // 脈拍数上限
        chg = (short)(0 == val ? 200 : 240);
        short_set(data + (217 * 2), chg);
    }
    
    // add 通信共通プロトコルV4にて、OHDF時の補液速度が設定値と異なる。 高 start
    // シングルニードル電源ＳＷが「ON」の場合
    if ( hl_chg(*(short*)(data + (23 * 2))) == 1 ) {
        if ( hl_chg(*(short*)(data + (258 * 2))) == 1 ) {
            // 「アクセス再循環測定使用選択(アドレス258)」が「1:使用する」の場合
            // 「アクセス再循環測定使用選択(アドレス258)」を「1:使用する」に変更
            short_set(data + (258 * 2), 1);
            // 「自動測定2～5(アドレス263～266)」を強制的に「0」に変更
            for ( addr = 263; addr <= 266; addr++ ) {
                short_set(data + (addr * 2), 0);
            }
            // 「自動測定1(アドレス259」を強制的に「0」に変更
            short_set(data + (259 * 2), 0);
        }
        if ( hl_chg(*(short*)(data + (267 * 2))) == 1 ) {
            // 「ブラッドボリューム計使用選択」が使用するの場合
            // 「ブラッドボリューム計使用選択」を使用しないに強制変更
            short_set(data + (267 * 2), 0);
        }
    }
    // add 通信共通プロトコルV4にて、OHDF時の補液速度が設定値と異なる。 高 end

	if ( ntss_mst_type_chack( sp->deviceType ) > 0 ) {
		// 100NX以降の装置
        if ( hl_chg(*(short*)(data + (258 * 2))) == 0 ) {
            // 「アクセス再循環測定使用選択(アドレス258)」が「0:使用しない」
            // 「自動測定1(アドレス259)」を強制的に「0」に変更
            short_set(data + (259 * 2), 0);
            // 「自動測定2～5(アドレス263～266)」を強制的に「-1」に変更
            for ( addr = 263; addr <= 266; addr++ ) {
                short_set(data + (addr * 2), -1);
            }
        }
        else {
            // 「アクセス再循環測定使用選択(アドレス258)」が「1:使用する」
            // 「自動測定1(アドレス259)」はそのままでOK
            for ( addr = 263; addr <= 266; addr++ ) {
                val = hl_chg(*(short*)(data + (addr * 2)));
                // 「自動測定2～5(アドレス263～266)」が「0」なら強制的に「-1」に変更
                if ( val == 0 ) {
                    short_set(data + (addr * 2), -1);
                }
            }
        }
    }
    else {
		// 100NX以前の装置
        // 「自動測定2～5(アドレス263～266)」を強制的に「0」に変更
        for ( addr = 263; addr <= 266; addr++ ) {
            short_set(data + (addr * 2), -1);
        }
        if ( hl_chg(*(short*)(data + (258 * 2))) == 0 ) {
            // 「アクセス再循環測定使用選択(アドレス258)」が「0:使用しない」
            // 「自動測定1(アドレス259)」を強制的に「0」に変更
            short_set(data + (259 * 2), 0);
        }
        else {
            // 「アクセス再循環測定使用選択(アドレス258)」が「1:使用する」
            // 「自動測定1(アドレス259)」が「120」より大きい場合は「120」に変更
            val = hl_chg(*(short*)(data + (259 * 2)));
            if ( val > 120 ) {
                short_set(data + (259 * 2), 120);
            }
        }
    }
}
