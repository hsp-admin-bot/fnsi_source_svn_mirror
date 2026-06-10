/**
* @file comsv_rcv_cp.c
* @brief 共通プロトコル受信データ処理
* @author Y.Takamura
* @date 2019/03/11
* @details 共通プロトコル装置から受信したデータ処理
*/

#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include "ntss_comsv.h"

/**
* @fn void comsv_rcv_cp(int thread_no, struct scn_data_fm *sp)
* @brief 共通プロトコル受信データ処理
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 共通プロトコル装置から受信したデータ処理
*/
void comsv_rcv_cp(int thread_no, struct scn_data_fm *sp) {
	int ret;
	char stx[3];
	char cmd[3];
	char code[2];
	char fpath[64];
	u_char logMsg[256];
	pthread_t thr_cond;
	pthread_attr_t thread_attr;
	extern void comsv_rcv_alarm_cp(int thread_no, struct scn_data_fm *sp);
	//add redmine bug #6335 劉 start
	extern void comsv_rcv_set_cp(int thread_no, struct scn_data_fm *sp);
	//add redmine bug #6335 劉 end
    // add FNSI-バグ 通信サーバ 高 start
    u_char tmpWrk[RCVMAX*2 + 256];
    int tLen, ii;
    u_char * pp, * pp_rcp;
    u_char ppUchar[3];
    // add FNSI-バグ 通信サーバ 高 end

	memcpy(stx, sp->rcvbuf, 2);
	memcpy(cmd, sp->rcvbuf + 17, 2);
    cmd[2] = '\0';
	memcpy(code, sp->rcvbuf + 19, 2);

	// 共通プロトコル受信データ処理
	if ( memcmp(stx, "R3", 2) == 0 ) {
		sprintf(logMsg, "通信スレッドCP[%d] : 設定値書込完了 [%ld][%ld][%ld]", thread_no, sp->dev_no, sp->ord_no, sp->pat_id);
	    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
		//mod redmine bug #6335 劉 start
		comsv_rcv_set_cp(thread_no, sp);
		// sp->comflg = C_JSET;
		// sp->cond_send_flg = 0;				// 条件送信フラグ（0:未送信,1:送信済）
		// sp->cond_send_time = 0;				// 条件送信時刻（コマンド送信時刻）
		// sp->cond_send_date = 0;				// 条件送信日時
		// if ( sp->pat_id ) {
		// 	sp->cond_send_flg = 1;
		// 	sp->cond_send_date = sp->cond_set_date = get_time();
		// 	// ホスト報知定義の取得・設定
		// 	ret = comsv_host_watch(thread_no, sp);
		// 	printf("comsv_host_watch = [%d]\n", ret);
		// 	// スレッド属性オブジェクトの初期化
		// 	pthread_attr_init(&thread_attr);
		// 	// スレッド切り離し状態属性の設定
		// 	pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
        //     // add ？？？？患者発生時の次患者情報送信#1437 高 start
        //     sp->unregistered_flg = 0;
        //     // add ？？？？患者発生時の次患者情報送信#1437 高 end
		// 	// 条件送信完了時の一連スレッド処理
		// 	pthread_create(&thr_cond, &thread_attr, comsv_thread_rest_cond, sp);
        //     // add AWSとDEの通信断からの復旧 高 start
        //     sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
        //     sp->current_mon_sta[0] = COMM_STA1;
        //     // add AWSとDEの通信断からの復旧 高 end
		// }
		//mod redmine bug #6335 劉 end
	}
	else if ( memcmp(stx, "E3", 2) == 0 ) {
		sp->comflg = C_JSET;
		sp->cond_send_time = 0;			// 条件送信時刻（コマンド送信時刻）
		memcpy(code, sp->rcvbuf + 5, 2);
		if ( (code[0] & 0x20) ) {
			//	書き込み不可（設定値書込）
			sprintf(logMsg, "通信スレッドCP[%d] : 設定値書込破棄（書込不可）", thread_no);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, sp->deviceType, sp->devid);
			// 体重計測定実績のステータス・メッセージデータを更新する
			comsv_rest_put_scale_state(sp->dev_no, sp->deviceType, sp->devid, sp->cond_send_ctrl, 6);
		}
		//add redmine bug #6335 劉 start
		else if ( (code[0] & 0x08) )
		{
			//適正範囲外
			sprintf(logMsg, "通信スレッドCP[%d] : データエラー（適正範囲外）", thread_no);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, sp->deviceType, sp->devid);
			comsv_rcv_set_cp(thread_no, sp);
		}
		//add redmine bug #6335 劉 end
		else {
			sprintf(logMsg, "通信スレッドCP[%d] : 終了コード異常 [%02x][%02x]", thread_no, (code[0]&0xff), (code[1]&0xff));
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, sp->deviceType, sp->devid);
			// 体重計測定実績のステータス・メッセージデータを更新する
			comsv_rest_put_scale_state(sp->dev_no, sp->deviceType, sp->devid, sp->cond_send_ctrl, 3);
		}
	}
	else if ( memcmp(stx, "S4", 2) == 0 ) {
		if ( memcmp(cmd, "AL", 2) == 0 ) {
            // add FNSI-バグ 通信サーバ 高 start
            sprintf(tmpWrk, "通信スレッドCP[%d] : AL = [", thread_no);
            pp = &tmpWrk[0];
            pp += strlen(tmpWrk);
            pp_rcp = sp->rcvbuf;
            for(ii = 0; ii < sp->rcvlen; ii++) {
                sprintf(ppUchar, "%c", *(pp_rcp+ii));
                strcat(pp, ppUchar);
            }
            LogOutputs(NTSS_LOG_INFO, tmpWrk, 0, sp->deviceType, sp->devid);
            // add FNSI-バグ 通信サーバ 高 end
            
			// 共通プロトコル受信ステータス処理
			comsv_rcv_alarm_cp(thread_no, sp);
		}
        
        // gs debug  tmp add for #6409 start
        else if ( memcmp(cmd, "MS", 2) == 0 ) {
            sprintf(tmpWrk, "通信スレッドCP[%d] : MS = [", thread_no);
            pp = &tmpWrk[0];
            pp += strlen(tmpWrk);
            pp_rcp = sp->rcvbuf;
            for(ii = 0; ii < sp->rcvlen; ii++) {
                sprintf(ppUchar, "%c", *(pp_rcp+ii));
                strcat(pp, ppUchar);
            }
            LogOutputs(NTSS_LOG_INFO, tmpWrk, 0, sp->deviceType, sp->devid);
        }
        // gs debug  tmp add for #6409 end
        
		// 送信電文
		sp->comflg = C_RESPONSE;
	}
	else if ( memcmp(stx, "R4", 2) == 0 ) {
		// 応答電文（正常応答）
		if ( memcmp(cmd, "TC", 2) == 0 ) {
			sprintf(logMsg, "通信スレッドCP[%d] : 設定値書込完了 [%ld][%ld][%ld]", thread_no, sp->dev_no, sp->ord_no, sp->pat_id);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
			//mod redmine bug #6335 劉 start
			comsv_rcv_set_cp(thread_no, sp);
			// sp->comflg = C_JSET;
			// sp->cond_send_flg = 0;				// 条件送信フラグ（0:未送信,1:送信済）
			// sp->cond_send_time = 0;				// 条件送信時刻（コマンド送信時刻）
			// sp->cond_send_date = 0;				// 条件送信日時
			// sp->dial_start_date = 0;			// 透析開始日時
			// sp->dial_end_date = 0;				// 透析終了日時
			// if ( sp->pat_id ) {
			// 	sp->cond_send_flg = 1;
			// 	sp->cond_send_date = sp->cond_set_date = get_time();
			// 	// 設定値読み込み履歴を更新する
			// 	comsv_work_fpath(sp->dev_no, WORK_DEV_COND, fpath);
			// 	ret = comsv_rest_post_ord_cond(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, sp->cond_send_date, 1, fpath);
			// 	printf("comsv_rest_post_ord_cond = [%d]\n", ret);
			// 	// ホスト報知定義の取得・設定
			// 	ret = comsv_host_watch(thread_no, sp);
			// 	printf("comsv_host_watch = [%d]\n", ret);
			// 	// スレッド属性オブジェクトの初期化
			// 	pthread_attr_init(&thread_attr);
			// 	// スレッド切り離し状態属性の設定
			// 	pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
            //     // add ？？？？患者発生時の次患者情報送信#1437 高 start
            //     sp->unregistered_flg = 0;
            //     // add ？？？？患者発生時の次患者情報送信#1437 高 end
			// 	// 条件送信完了時の一連スレッド処理
			// 	pthread_create(&thr_cond, &thread_attr, comsv_thread_rest_cond, sp);
			// 	// 時計設定を要求
			// 	sp->reqflg[C_CLOCK] = 1;
            //     // add AWSとDEの通信断からの復旧 高 start
            //     sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
            //     sp->current_mon_sta[0] = COMM_STA1;
            //     // add AWSとDEの通信断からの復旧 高 end
			// }
			//mod redmine bug #6335 劉 end
		}
		else if ( memcmp(cmd, "CM", 2) == 0 ) {
			sprintf(logMsg, "通信スレッドCP[%d] : 次回透析患者情報転送完了 [%ld][%ld][%ld]", thread_no, sp->dev_no, sp->next_ord_no, sp->next_pat_id);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
			sp->comflg = C_NEXTPAT;
            // add 強制オフライン 高 start
            // 強制オフライン
            if( sp->force_flg == 1 && sp->force_cond_flg == 1) {
                sp->force_cond_flg = 0;
                sp->cond_send_flg = 1;
           
                // スレッド属性オブジェクトの初期化
                pthread_attr_init(&thread_attr);
                // スレッド切り離し状態属性の設定
                pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
                sp->unregistered_flg = 0;
                // 条件送信完了時の一連スレッド処理
                pthread_create(&thr_cond, &thread_attr, comsv_thread_rest_cond, sp);
            }
            // add 強制オフライン 高 end
		}
		else if ( memcmp(cmd, "DT", 2) == 0 ) {
			sp->comflg = C_CLOCK;
		}
	}
	else if ( memcmp(stx, "E4", 2) == 0 ) {
		// 応答電文（異常応答）
		if ( memcmp(cmd, "TC", 2) == 0 ) {
			sp->comflg = C_JSET;
			sp->cond_send_time = 0;			// 条件送信時刻（コマンド送信時刻）
			if ( (code[0] & 0x20) ) {
				//	書き込み不可（設定値書込）
				sprintf(logMsg, "通信スレッドCP[%d] : [%s]設定値書込破棄（書込不可）", thread_no, cmd);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, sp->deviceType, sp->devid);
				// 体重計測定実績のステータス・メッセージデータを更新する
				comsv_rest_put_scale_state(sp->dev_no, sp->deviceType, sp->devid, sp->cond_send_ctrl, 6);
			}
			//add redmine bug #6335 劉 start
			else if ( (code[0] & 0x08) )
			{
				//適正範囲外
				sprintf(logMsg, "通信スレッドCP[%d] : [%s]データエラー（適正範囲外）", thread_no, cmd);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, sp->deviceType, sp->devid);
				comsv_rcv_set_cp(thread_no, sp);
			}
			//add redmine bug #6335 劉 end
			else {
				sprintf(logMsg, "通信スレッドCP[%d] : [%s]終了コード異常 [%02x][%02x]", thread_no, cmd, (code[0]&0xff), (code[1]&0xff));
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, sp->deviceType, sp->devid);
				// 体重計測定実績のステータス・メッセージデータを更新する
				comsv_rest_put_scale_state(sp->dev_no, sp->deviceType, sp->devid, sp->cond_send_ctrl, 3);
			}
		}
		else {
            // #10013 2023.11.14 mod 治療中の一斉時刻合わせで発生する終了コードエラー対策 TDC高村 start
            /*
			if ( memcmp(cmd, "CM", 2) == 0 ) {
				sprintf(logMsg, "通信スレッドCP[%d] : 次回透析患者情報転送完了 [%ld][%ld][%ld]", thread_no, sp->dev_no, sp->ord_no, sp->pat_id);
			    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
				sp->comflg = C_NEXTPAT;
			}
			else if ( memcmp(cmd, "DT", 2) == 0 ) {
				sp->comflg = C_CLOCK;
			}
			sprintf(logMsg, "通信スレッドCP[%d] : [%s]終了コード異常 [%02x][%02x]", thread_no, cmd, (code[0]&0xff), (code[1]&0xff));
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, sp->deviceType, sp->devid);
            */
			if ( memcmp(cmd, "CM", 2) == 0 ) {
				sprintf(logMsg, "通信スレッドCP[%d] : 次回透析患者情報転送完了 [%ld][%ld][%ld]", thread_no, sp->dev_no, sp->ord_no, sp->pat_id);
			    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
				sp->comflg = C_NEXTPAT;
                sprintf(logMsg, "通信スレッドCP[%d] : [%s]終了コード異常 [%02x][%02x]", thread_no, cmd, (code[0]&0xff), (code[1]&0xff));
                LogOutputs(NTSS_LOG_ERROR, logMsg, 0, sp->deviceType, sp->devid);
			}
			else if ( memcmp(cmd, "DT", 2) == 0 ) {
				sp->comflg = C_CLOCK;
                if ( !(code[0] & 0x10) ) {
                    //	治療中受信不可の場合を除く
                    sprintf(logMsg, "通信スレッドCP[%d] : [%s]終了コード異常 [%02x][%02x]", thread_no, cmd, (code[0]&0xff), (code[1]&0xff));
                    LogOutputs(NTSS_LOG_ERROR, logMsg, 0, sp->deviceType, sp->devid);
                }
			}
            // #10013 2023.11.14 mod 治療中の一斉時刻合わせで発生する終了コードエラー対策 TDC高村 end
		}
	}
	else if ( memcmp(stx, "K3", 2) == 0 ) {
        // add FNSI-バグ 通信サーバ 高 start
        sprintf(tmpWrk, "通信スレッドCP[%d] : W DATA = [", thread_no);
        pp = &tmpWrk[0];
        pp += strlen(tmpWrk);
        pp_rcp = sp->rcvbuf;
        for(ii = 0; ii < sp->rcvlen; ii++) {
            sprintf(ppUchar, "%c", *(pp_rcp+ii));
            strcat(pp, ppUchar);
        }
        LogOutputs(NTSS_LOG_INFO, tmpWrk, 0, sp->deviceType, sp->devid);
        // add FNSI-バグ 通信サーバ 高 end
		// 共通プロトコル受信ステータス処理
		comsv_rcv_alarm_cp(thread_no, sp);
	}
}

/**
* @fn void comsv_rcv_alarm_cp(int thread_no, struct scn_data_fm *sp)
* @brief 共通プロトコル受信ステータス処理
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 共通プロトコル装置からステータス（警報・報知）をセット
*/
void comsv_rcv_alarm_cp(int thread_no, struct scn_data_fm *sp) {
	int i;
	int sta;
    char *dp;
	char ver3[9][3] = { "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1", "i1" };
    // mod FNSI-バグ 通信サーバ 高 start
    // char ver4[15][4] = { "DB1", "DC1", "DD1", "DE1", "DF1", "DG1", "DH1",
    //                      "DI1", "DJ1", "DK1", "DM1", "DO1", "DP1", "DQ1", "DR1" };
    char ver4[15][3] = { "DB", "DC", "DD", "DE", "DF", "DG", "DH",
                         "DI", "DJ", "DK", "DM", "DO", "DP", "DQ", "DR" };
    char *dp_02;
    // mod FNSI-バグ 通信サーバ 高 end
	unsigned char rcvbuf[RCVMAX];

	memset(rcvbuf, 0, sizeof(rcvbuf));
	memcpy(rcvbuf, sp->rcvbuf, sp->rcvlen - 4);	// SUM,ETX分を除く

	if ( sp->devsw == 'W' ) {
		// Ver3
		sta = 0;
		for ( i = 0; i < 9; i++ ) {
			dp = strstr(rcvbuf, ver3[i]);
			if ( dp != NULL ) {
				sta = 1;
				break;
			}
		}
		if ( sta ) {
			// ステータス（警報ON）
			sp->mon_sta |= 0x08;
		}
		else {
			// ステータス（警報OFF）
			sp->mon_sta &= ~0x08;
		}
	}
	else if ( sp->devsw == 'V' ) {
		// Ver4
		sta = 0;
		for ( i = 0; i < 11; i++ ) {
			dp = strstr(rcvbuf, ver4[i]);
			if ( dp != NULL ) {
                // mod FNSI-バグ 通信サーバ 高 start
                if(*(dp+2) == '1') {
                    sta = 1;
                    break;
                }
                // mod FNSI-バグ 通信サーバ 高 end
			}
		}
		if ( sta ) {
			// ステータス（警報ON）
			sp->mon_sta |= 0x08;
		}
		else {
			// ステータス（警報OFF）
			sp->mon_sta &= ~0x08;
		}
		sta = 0;
        // mod FNSI-バグ 通信サーバ 高 start
        if(dp != NULL) {
            dp_02 = strstr(dp, "02");
            if( dp_02 != NULL ) {
                for ( i = 11; i < 15; i++ ) {
                    dp = strstr(dp_02 + 52, ver4[i]);
                    if ( dp != NULL ) {
                        if(*(dp+2) == '1') {
                            sta = 1;
                            break;
                        }
                    }
                }
            }
        }
        // mod FNSI-バグ 通信サーバ 高 end
		if ( sta ) {
			// ステータス（報知ON）
			sp->mon_sta |= 0x20;
		}
		else {
			// ステータス（報知OFF）
			sp->mon_sta &= ~0x20;
		}
	}
}

//add redmine bug #6335 劉 start
/**
* @fn void comsv_rcv_set_cp(int thread_no, struct scn_data_fm *sp)
* @brief 共通プロトコル受信ステータス処理
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 設定値書込
*/
void comsv_rcv_set_cp(int thread_no, struct scn_data_fm *sp) {
	int ret;
	char fpath[64];
	pthread_t thr_cond;
	pthread_attr_t thread_attr;
	sp->comflg = C_JSET;
	sp->cond_send_flg = 0;				// 条件送信フラグ（0:未送信,1:送信済）
	sp->cond_send_time = 0;				// 条件送信時刻（コマンド送信時刻）
	sp->cond_send_date = 0;				// 条件送信日時
	if ('V' == sp->devsw)
	{
		sp->dial_start_date = 0;		// 透析開始日時
		sp->dial_end_date = 0;			// 透析終了日時
	}
	if ( sp->pat_id ) {
		sp->cond_send_flg = 1;
		sp->cond_send_date = sp->cond_set_date = get_time();
		if ('V' == sp->devsw)
		{
			// 設定値読み込み履歴を更新する
			comsv_work_fpath(sp->dev_no, WORK_DEV_COND, fpath);
			ret = comsv_rest_post_ord_cond(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, sp->cond_send_date, 1, fpath);
			printf("comsv_rest_post_ord_cond = [%d]\n", ret);
			// 時計設定を要求
			sp->reqflg[C_CLOCK] = 1;
		}
		// ホスト報知定義の取得・設定
		ret = comsv_host_watch(thread_no, sp);
		printf("comsv_host_watch = [%d]\n", ret);
		// スレッド属性オブジェクトの初期化
		pthread_attr_init(&thread_attr);
		// スレッド切り離し状態属性の設定
		pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
		// add ？？？？患者発生時の次患者情報送信#1437 高 start
		sp->unregistered_flg = 0;
		// add ？？？？患者発生時の次患者情報送信#1437 高 end
		// 条件送信完了時の一連スレッド処理
		pthread_create(&thr_cond, &thread_attr, comsv_thread_rest_cond, sp);
		// add AWSとDEの通信断からの復旧 高 start
		sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
		sp->current_mon_sta[0] = COMM_STA1;
		// add AWSとDEの通信断からの復旧 高 end
	}
}
//add redmine bug #6335 劉 end