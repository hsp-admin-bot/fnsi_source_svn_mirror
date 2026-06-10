/**
* @file comsv_mon.c
* @brief 新通信のモニタデータ処理（ステータス／モニタ／ログ）
* @author Y.Takamura
* @date 2018/09/18
* @details 新通信装置から受信したモニタデータ処理（ステータス／モニタ／ログ）
*/

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>
#include <pthread.h>
#include "ntss_comsv.h"

/**
* @fn void comsv_mon(int sw, int thread_no, struct scn_data_fm *sp)
* @brief 新通信のモニタデータ処理（ステータス／モニタ／ログ）
* @param[in] sw 種別（0:ステータス 1:モニタ 2:ログ）
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 新通信装置から受信したモニタデータ処理（ステータス／モニタ／ログ）
*/
void comsv_mon(int sw, int thread_no, struct scn_data_fm *sp) {
	int i;
	char fpath[64];
	unsigned char *dp;
	unsigned char ord_str[10];
	unsigned char sta, sta_bak;
	pthread_t thr_medi;
    // #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 start
	pthread_t thr_unregi;
    // #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 end
	pthread_attr_t thread_attr;
	HostWatchPat_t host_watch[HOST_WATCH_MAX];
    // add AWSとDEの通信断からの復旧 高 start
    unsigned char cdata[40] = {0};
    // add AWSとDEの通信断からの復旧 高 end
    // add FNSI-バグ 通信サーバ 高 start
    unsigned char cur_sta;
    // add FNSI-バグ 通信サーバ 高 end
    // #11124 2025.07.28 add 酸素飽和度対応 TDC高村 start
    extern void comsv_mon_so2(struct scn_data_fm *sp);
    // #11124 2025.07.28 add 酸素飽和度対応 TDC高村 end
 
    char str1[512];

	sta = sp->rcvbuf[10];
	sta_bak = sp->mon_sta;	// 状態の前回データ
    // add FNSI-バグ 通信サーバ 高 start
    cur_sta = sta;
    // add FNSI-バグ 通信サーバ 高 end

    // add 強制オフライン 高 start
    if( sp->force_flg == 0 ) {
    // add 強制オフライン 高 end
        // add AWSとDEの通信断からの復旧 高 start
        // #11324 2025.01.27 mod 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 start
        // if ( getCommAliveState() != 0 || (getCommAliveState() == 0 && sp->ord_no < COMM_FAIL_DUMMY_ORD_NO) ) {
        bool isCommEnableState = getCommAliveState() == 0;
        if (isCommEnableState == false || (isCommEnableState && sp->ord_no < COMM_FAIL_DUMMY_ORD_NO))
		{
        // #11324 2025.01.27 mod 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 end
        // add AWSとDEの通信断からの復旧 高 end
        	if ( !(sta_bak & 1) && (sta & 1) ) {
        		/****************/
        		/* 透析開始処理 */
        		/****************/
        		comsv_clear(2, sp);		// 前回透析終了状態の場合、装置制御データをクリアして未登録運転へ
        		sp->dial_start_date = get_time();	// 透析開始日時
        		sp->reqflg[C_JSETRD] = 1;			// 条件データ読出要求
        		sp->reqflg[C_KANSRD] = 1;			// 警報監視状態読出要求
        		sp->kansrd_flg = 1;					// 警報監視除隊フラグ（0:装置側から任意,1:運転開始時）
        		sp->cond_read_flg = 2;				// 設定値読出フラグ（2:運転開始時）
                // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
                // 既にデータ取得ファイルがあれば削除
                comsv_work_fpath(sp->dev_no, WORK_LCD_REQ41, fpath);
                remove(fpath);
                sp->alert_no = 0;
                for ( i = 0; i < ALERT_NUM; i++ ) sp->alert_time[i] = -1;
                // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end
                
        		if ( sp->ord_no == 0 || sp->pat_id == 0 ||
        			sp->cond_send_flg == 0 || sp->cond_set_date == 0 ) {
        			// 未登録の場合
                    // #10844 2024.07.29 mod DB高負荷状態の時に????患者が複数生成される TDC高村 start
                    /*
                    // add ？？？？患者発生時の次患者情報送信#1437 高 start
                    sp->reqflg[C_NEXTPAT] = 1;          // 次患者情報を要求
                    sp->next_pat_send = 0;     // 次患者送信（0:タイミング,1:イベント）
                    // add ？？？？患者発生時の次患者情報送信#1437 高 end
        			sp->cond_send_flg = 1;
        			// ホスト報知監視開始待ち時間の初期化
        			comsv_host_watch_init(thread_no);
        			// 治療情報を登録（患者未登録運転）する
        			i = comsv_rest_put_unregistered(sp->dev_no, sp->deviceType, sp->devid, sta, 3, sp->dial_start_date);
        			printf("comsv_rest_put_unregistered = [%d]\n", i);
        			// 装置状態管理データを取得
                    comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);
        			i = comsv_rest_get_dev(sp->dev_no, sp->deviceType, sp->devid, fpath);
        			printf("comsv_rest_get_dev = [%d]\n", i);
        			i = comsv_json_dev_state(fpath, 1, sp);
        			printf("comsv_json_dev_state = [%d]\n", i);
                    // ホスト報知定義の取得・設定
        			i = comsv_host_watch(thread_no, sp);
        			printf("comsv_host_watch = [%d]\n", i);
                    */
                    if ( sp->thread_unregistered == 0 ) {
                        // #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start               
                        if ( checkMachineIsVa(sp) > 0 ) {
                            // 画像転送可能な装置の場合
                            // 画像データ削除を要求
                            sprintf(str1, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（患者未登録運転時）", thread_no);
                            LogOutputs(NTSS_LOG_INFO, str1, 0, sp->deviceType, sp->devid);
                            sp->reqflg[C_DELETE] = 1;
                        }
                        // #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
        			    // スレッド属性オブジェクトの初期化
        			    pthread_attr_init(&thread_attr);
        			    // スレッド切り離し状態属性の設定
        			    pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
        			    // 患者未登録運転スレッド処理
                        sp->thread_unregistered_no = thread_no; // スレッド番号
                        sp->thread_unregistered = 2;            // スレッド処理
                        sp->thread_unregistered_sta = sta;      // 装置ステータス
        			    pthread_create(&thr_unregi, &thread_attr, comsv_thread_unregistered, sp);
                    }
                    else {
                        // 既に実行中
                        sprintf(str1, "患者未登録運転スレッド処理が既に実行中 [%d][%d]", sp->thread_unregistered, sp->thread_unregistered_sta);
                        LogOutputs(NTSS_LOG_ERROR, str1, 0, sp->deviceType, sp->devid);
                    }
                    // #10844 2024.07.29 mod DB高負荷状態の時に????患者が複数生成される TDC高村 end
                    // add AWSとDEの通信断からの復旧 高 start
                    // #11324 2025.01.27 mod 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 start
                    // if ( getCommAliveState() != 0 ) {
                    if (isCommEnableState == false)
                    {
                    // #11324 2025.01.27 mod 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 start
                        sprintf(cdata, "%ld", sp->dial_start_date);
                        comsv_fail_append_data_full(facility_cd, sp->deviceType, sp->devid, cdata, 2, 0);
                    }
                    // add AWSとDEの通信断からの復旧 高 end
        		}
        		else {
        			// 装置状態管理の日付データを更新する
        			i = comsv_rest_put_dev_date(sp->dev_no, sp->deviceType, sp->devid, 2, sta, sp->dial_start_date);
        			printf("comsv_rest_put_dev_date = [%d]\n", i);
        			// 治療情報の日付データを更新する
        			i = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 1, sp->pat_id, 3, sp->dial_start_date);
        			printf("comsv_rest_put_ord_date = [%d]\n", i);
        			// 患者基本情報のステータスを更新する
        			i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 3);
        			printf("comsv_rest_put_pat_related = [%d]\n", i);
        			// 仮想端末（投与薬剤）読み込み
        			LcddataReq41_t req41;
        			sprintf(ord_str, "%ld", sp->ord_no);
                    comsv_work_fpath(sp->dev_no, WORK_LCD_REQ41, fpath);
        			i = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 41, ord_str, fpath);
        			printf("comsv_rest_get_lcd 41 = [%d]\n", i);
        			i = comsv_json_lcd_req41(fpath, &req41);
        			printf("comsv_json_lcd_req41 = [%d]\n", i);
        			sp->alert_no = 0;
        			memcpy(sp->alert_time, req41.alert_time, sizeof(sp->alert_time));
                    // add FNSI-バグ 通信サーバ 高 start
                    comsv_effectFlg_check(sp, &req41);
                    // add FNSI-バグ 通信サーバ 高 end
        			if ( configParam.lcdDataCash == 1 ) {
        				// 仮想端末キャッシュ更新を要求
        				con_sock[thread_no].event[9] = 0x01; 
        			}
        			// スレッド属性オブジェクトの初期化
        			pthread_attr_init(&thread_attr);
        			// スレッド切り離し状態属性の設定
        			pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
        			// 運転開始時の投薬実施、投与タイミング通知スレッド処理
        			pthread_create(&thr_medi, &thread_attr, comsv_thread_medicated, sp);
        		}
                // add AWSとDEの通信断からの復旧 高 start
                if (sp->current_mon_sta[0] == COMM_STA1 || sp->current_mon_sta[0] == COMM_STA2) { 
                    // 治療中
                    sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
                    sp->current_mon_sta[0] = COMM_STA3;
                }
                else {
                    // 条件送信前+治療中
                    sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
                    sp->current_mon_sta[0] = COMM_STA5;
                }
                // add AWSとDEの通信断からの復旧 高 end
        		// 状況に応じた装置制御データのクリア
        		comsv_clear(1, sp);
        	}
        	else if ( (sta_bak & 1) && !(sta & 1) ) {
        		/****************/
        		/* 透析終了処理 */
        		/****************/
        		if ( sp->dial_end_date == 0 ) {
        			sp->dial_end_date = get_time();	// 透析終了日時
        			// 排液時更新用モニタデータからJSONファイルを作成
        			comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
        			i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData+12, packetInfoList[thread_no].cCommType);
        			printf("comsv_json_ord_make_moni = [%d]\n", i);
        		}
        		if ( get_time() >= (sp->dial_end_date + _comsvCache._comsvSet.end_wait_time) ) {
        			sp->dial_end_date = get_time();	// 透析終了日時
        			// 装置状態管理の日付データを更新する
        			i = comsv_rest_put_dev_date(sp->dev_no, sp->deviceType, sp->devid, 3, sta, sp->dial_end_date);
        			printf("comsv_rest_put_dev_date = [%d]\n", i);
        			// 治療情報の日付データを更新する
        			i = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 2, 0, 4, sp->dial_end_date);
        			printf("comsv_rest_put_ord_date = [%d]\n", i);
        			if ( sp->pat_id > 0 ) {
        				// 未登録以外の場合
        				// 患者基本情報のステータスを更新する
        				i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 4);
        				printf("comsv_rest_put_pat_related = [%d]\n", i);
        				// 患者基本情報の透析回数を更新する
        				//i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 1, 0, 0);
        				//printf("comsv_rest_put_pat_related = [%d]\n", i);
        			}
        			// 治療情報の実績モニタ値を更新する
        			comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
        			i = comsv_rest_post_ord_moni(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, fpath);
        			printf("comsv_rest_post_ord_moni = [%d]\n", i);
        			// 次患者更新を行う
        			i = comsv_rest_post_web_api(sp->dev_no, sp->deviceType, sp->devid, 1);
        			printf("comsv_rest_post_web_api = [%d]\n", i);
        			// 次患者情報を要求
        			sp->reqflg[C_NEXTPAT] = 1;
        			sp->next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
                    // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
                    comsv_medicated_end(sp);
                    // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end
                    // add AWSとDEの通信断からの復旧 高 start
                    sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
                    sp->current_mon_sta[0] = COMM_STA4;
                    // add AWSとDEの通信断からの復旧 高 end
        		}
        		else {
        			// 排液判定中
        			sta = sta_bak;
        		}
        	}
        	else if ( (sta_bak & 1) && (sta & 1) ) {
        		if ( sp->dial_end_date ) {
        			// 排液判定中から透析中に復帰した為、クリア
        			sp->dial_end_date = 0; // 透析終了日時
        		}
        	}
        }

        /* ステータスセット */
        sp->mon_sta &= (~0x7f);
        sp->mon_sta |= (sta & 0x7f);

        // #11925 2025.06.13 add サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 start
        bool isStartTreat = !(sta_bak & 1) && (sta & 1);
        bool isEndTreat = (sta_bak & 1) && !(sta & 1);
        if (isStartTreat || isEndTreat)
        {
			comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);
            int ret = comsv_rest_get_dev(sp->dev_no, sp->deviceType, sp->devid, fpath);
            printf("comsv_rest_get_dev = [%d]\n", ret);
            if (ret == 0)
            {
                // 最新のmachine_stateが取得できていたらメモリに展開
                ret = comsv_json_dev_state(fpath, 1, sp);
                printf("comsv_json_dev_state = [%d]\n", ret);
            }
            else
            {
                // DBから取得ができなかったらローカルで更新
                if (isStartTreat)
                {
                    // 透析開始時にローカルのstate.jsonを更新
                    comsv_json_dev_update(1, sp);
                }
                else if (isEndTreat)
                {
                    // 透析終了時にローカルのstate.jsonを更新
                    comsv_json_dev_update(2, sp);
                }
            }
        }
        // #11925 2025.06.13 add サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 end

		if ( sw == 2 ) {
    		/*** ログデータ処理 ***/
            // mod FNSI-バグ 通信サーバ 高 start
    		// if ( sta & 0x80 ) {
            if ( cur_sta & 0x80 ) {
            // mod FNSI-バグ 通信サーバ 高 end
    			dp = sp->rcvbuf + 12;
    			comsv_log(dp, sp);
    		}
    	}
        // #11124 2025.07.28 add 酸素飽和度対応 TDC高村 start
		else if ( sw == 1 && (sp->devsw == 'P' || sp->devsw == 'Q') ) {
            // モニタデータ（ΔSO2制御）
            comsv_mon_so2(sp);
        }
        // #11124 2025.07.28 add 酸素飽和度対応 TDC高村 end

    	if ( sp->first_sta >= 0 ) {
    		// 初回ステータスチェック
    		if ( sp->first_sta != sp->mon_sta ) {
    			// 初回起動時の装置ステータスから変化がある場合
    			comsv_json_dev_status(fpath, sp);
    			// 装置状態管理の装置ステータス更新処理
    			i = comsv_rest_post_all_status(fpath);
    			printf("comsv_rest_post_all_status = [%d]\n", i);
    		}
    		if ( (sp->first_sta & 1) && (sp->mon_sta & 1) ) {
    			i = (sp->dial_time + sp->facility_time) * 60;
    			if ( sp->dial_start_date && (sp->dial_start_date + (long)i) < get_time() ) {
                    // del FNSI-バグ 通信サーバ(#6409) 高 start
//    				// 治療時間を経過している為、透析終了して未登録運転へ
//    				sp->dial_end_date = get_time();	// 透析終了日時
//    				// 装置状態管理の日付データを更新する
//    				i = comsv_rest_put_dev_date(sp->dev_no, sp->deviceType, sp->devid, 3, sta, sp->dial_end_date);
//    				printf("comsv_rest_put_dev_date = [%d]\n", i);
//    				// 治療情報の日付データを更新する
//    				i = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 2, 0, 4, sp->dial_end_date);
//    				printf("comsv_rest_put_ord_date = [%d]\n", i);
//    				if ( sp->pat_id > 0 ) {
//    					// 未登録以外の場合
//    					// 患者基本情報のステータスを更新する
//    					i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 4);
//    					printf("comsv_rest_put_pat_related = [%d]\n", i);
//    					// 患者基本情報の透析回数を更新する
//    					//i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 1, 0, 0);
//    					//printf("comsv_rest_put_pat_related = [%d]\n", i);
//    				}
//
//
//
//    				// 排液時更新用モニタデータからJSONファイルを作成
//    				comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
//    				i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData+12, packetInfoList[thread_no].cCommType);
//    				printf("comsv_json_ord_make_moni = [%d]\n", i);
//    				// 治療情報の実績モニタ値を更新する
//    				i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData+12, packetInfoList[thread_no].cCommType);
//    				printf("comsv_json_ord_make_moni = [%d]\n", i);
//    				i = comsv_rest_post_ord_moni(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, fpath);
//    				printf("comsv_rest_post_ord_moni = [%d]\n", i);
//    				// 次患者更新を行う
//    				i = comsv_rest_post_web_api(sp->dev_no, sp->deviceType, sp->devid, 1);
//    				printf("comsv_rest_post_web_api = [%d]\n", i);
//    				// 次患者情報を要求
//    				sp->reqflg[C_NEXTPAT] = 1;
//    				sp->next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
//    				// 未登録運転
//    				comsv_clear(2, sp);		// 前回透析終了状態の場合、装置制御データをクリアして未登録運転へ
//    				sp->dial_start_date = get_time();	// 透析開始日時
//    				sp->reqflg[C_JSETRD] = 1;			// 条件データ読出要求
//    				sp->reqflg[C_KANSRD] = 1;			// 警報監視状態読出要求
//    				sp->kansrd_flg = 1;					// 警報監視除隊フラグ（0:装置側から任意,1:運転開始時）
//    				sp->cond_read_flg = 2;				// 設定値読出フラグ（2:運転開始時）
//    				sp->cond_send_flg = 1;
//    				// ホスト報知監視開始待ち時間の初期化
//    				comsv_host_watch_init(thread_no);
//    				// 治療情報を登録（患者未登録運転）する
//    				i = comsv_rest_put_unregistered(sp->dev_no, sp->deviceType, sp->devid, sta, 3, sp->dial_start_date);
//    				printf("comsv_rest_put_unregistered = [%d]\n", i);
//    				// 装置状態管理データを取得
//    				comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);
//    				i = comsv_rest_get_dev(sp->dev_no, sp->deviceType, sp->devid, fpath);
//    				printf("comsv_rest_get_dev = [%d]\n", i);
//    				i = comsv_json_dev_state(fpath, 1, sp);
//    				printf("comsv_json_dev_state = [%d]\n", i);
//    				// ホスト報知定義の取得・設定
//    				i = comsv_host_watch(thread_no, sp);
//    				printf("comsv_host_watch = [%d]\n", i);
//    				// 状況に応じた装置制御データのクリア
//    				comsv_clear(1, sp);
                    // del FNSI-バグ 通信サーバ(#6409) 高 end
    			}
    			else {
    				// 初回起動時にホスト報知処理を実行
    				sp->reqflg[C_KANSRD] = 1;			// 警報監視状態読出要求
    				sp->kansrd_flg = 1;					// 警報監視除隊フラグ（0:装置側から任意,1:運転開始時）
    				// ホスト報知監視開始待ち時間の初期化
    				comsv_host_watch_init(thread_no);
    				// ホスト報知定義の取得・設定
    				i = comsv_host_watch(thread_no, sp);
    				printf("comsv_host_watch = [%d]\n", i);
    			}
    		}
    		sp->first_sta = -1;
    	}
    // add 強制オフライン 高 end
    }
}

// add 強制オフライン 高 start
/**
* @fn void comsv_mon_offline(int thread_no, struct scn_data_fm *sp)
* @brief 新通信のモニタデータ処理（ステータス／モニタ／ログ）
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 新通信装置から受信したモニタデータ処理（ステータス／モニタ／ログ）
*/
void comsv_mon_offline(int thread_no, struct scn_data_fm *sp) {
	int i;
	char fpath[64];
	unsigned char *dp;
	unsigned char ord_str[10];
	pthread_t thr_medi;
	pthread_attr_t thread_attr;
    struct NTSS_PACKET_INFORMATION *pInfo;
    pInfo = &packetInfoList[thread_no];

    if ( !(sp->mon_sta & 1) && sp->force_offline_time && sp->force_offline_wait >= 0 
         && get_time() >= (sp->force_offline_time + sp->force_offline_wait) ) {
		/****************/
		/* 透析開始処理 */
		/****************/
		// comsv_clear(2, sp);		// 前回透析終了状態の場合、装置制御データをクリアして未登録運転へ
        
        sp->force_offline_time = get_time();
        sp->mon_sta |= 0x01;
		sp->dial_start_date = sp->force_offline_time;	// 透析開始日時
		sp->reqflg[C_JSETRD] = 1;			// 条件データ読出要求
		sp->cond_read_flg = 2;				// 設定値読出フラグ（2:運転開始時）
        
        pInfo->nProcess[0] = 11;
        pInfo->isNeedSendProcess = 0x01;
        pInfo->isDialysis[0] = 0x01;
		// 装置状態管理の日付データを更新する
		i = comsv_rest_put_dev_date(sp->dev_no, sp->deviceType, sp->devid, 2, sp->mon_sta, sp->dial_start_date);
		printf("comsv_rest_put_dev_date = [%d]\n", i);
		// 透析時間
        sp->force_dial_time = -1;
		if ( _comsvCache._comsvSet.is_offline_auto_end == '1' ) {
			// 自動終了有り
			sp->force_dial_time = sp->dial_time;
			if ( sp->force_dial_time <= 0 ) sp->force_dial_time = 240;	// 4時間
			sp->force_dial_time *= 60;	// 分 → 秒
		}
		// 治療情報の日付データを更新する
		i = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 1, sp->pat_id, 3, sp->dial_start_date);
		printf("comsv_rest_put_ord_date = [%d]\n", i);
		// 患者基本情報のステータスを更新する
		i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 3);
		printf("comsv_rest_put_pat_related = [%d]\n", i);
		if ( configParam.lcdDataCash == 1 ) {
			// 仮想端末キャッシュ更新を要求
			con_sock[thread_no].event[9] = 0x01; 
		}
        // add FNSI-バグ 通信サーバ 高 start
        // 投与薬剤読み込み
        LcddataReq41_t req41;
        sprintf(ord_str, "%ld", sp->ord_no);
        comsv_work_fpath(sp->dev_no, WORK_LCD_REQ41, fpath);
        i = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 41, ord_str, fpath);
        printf("comsv_rest_get_lcd 41 = [%d]\n", i);
        i = comsv_json_lcd_req41(fpath, &req41);
        printf("comsv_json_lcd_req41 = [%d]\n", i);
        sp->alert_no = 0;
        memcpy(sp->alert_time, req41.alert_time, sizeof(sp->alert_time));
        // スレッド属性オブジェクトの初期化
        pthread_attr_init(&thread_attr);
        // スレッド切り離し状態属性の設定
        pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
        // 運転開始時の投薬実施、投与タイミング通知スレッド処理
        pthread_create(&thr_medi, &thread_attr, comsv_thread_medicated, sp);
        // add FNSI-バグ 通信サーバ 高 end
        // add AWSとDEの通信断からの復旧 高 start
            if (sp->current_mon_sta[0] == COMM_STA1 || sp->current_mon_sta[0] == COMM_STA2) { 
                // 治療中
                sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
                sp->current_mon_sta[0] = COMM_STA3;
            }
            else {
                // 条件送信前+治療中
                sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
                sp->current_mon_sta[0] = COMM_STA5;
            }
            // add AWSとDEの通信断からの復旧 高 end
        
		// 状況に応じた装置制御データのクリア
		comsv_clear( 1, sp);
	}
	else if ( sp->mon_sta & 1 && sp->force_dial_time >= 0 && get_time() >= (sp->force_offline_time + sp->force_dial_time) ) {
		/****************/
		/* 透析終了処理 */
		/****************/
        sp->force_offline_time = 0;
		sp->force_dial_time = -1;
        sp->force_offline_wait = _comsvCache._comsvSet.offline_start_time;
		sp->mon_sta &= ~0x01;
        // add FNSI-バグ 通信サーバ 高 start
        if(sp->conflg != 0) {
        // add FNSI-バグ 通信サーバ 高 start
            pInfo->nProcess[0] = 7;
            pInfo->isNeedSendProcess = 0x01;
        }
        pInfo->isDialysis[0] = 0x00;
        
		if ( sp->dial_end_date == 0 ) {
			sp->dial_end_date = get_time();	// 透析終了日時
			// 排液時更新用モニタデータからJSONファイルを作成
			comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
			i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData+12, packetInfoList[thread_no].cCommType);
			printf("comsv_json_ord_make_moni = [%d]\n", i);
        // #10889 2024.10.28 mod 既に終了時刻が入っている場合、終了処理を行わない TDC高村 start
        /*
		}
		sp->dial_end_date = get_time();	// 透析終了日時
		// 装置状態管理の日付データを更新する
		i = comsv_rest_put_dev_date(sp->dev_no, sp->deviceType, sp->devid, 3, sp->mon_sta, sp->dial_end_date);
		printf("comsv_rest_put_dev_date = [%d]\n", i);
		// 治療情報の日付データを更新する
		i = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 2, 0, 4, sp->dial_end_date);
		printf("comsv_rest_put_ord_date = [%d]\n", i);
		if ( sp->pat_id > 0 ) {
			// 未登録以外の場合
			// 患者基本情報のステータスを更新する
			i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 4);
			printf("comsv_rest_put_pat_related = [%d]\n", i);
			// 患者基本情報の透析回数を更新する
			//i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 1, 0);
			//printf("comsv_rest_put_pat_related = [%d]\n", i);
		}
		// 治療情報の実績モニタ値を更新する
		comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
		i = comsv_rest_post_ord_moni(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, fpath);
		printf("comsv_rest_post_ord_moni = [%d]\n", i);
        */
    		// 装置状態管理の日付データを更新する
    		i = comsv_rest_put_dev_date(sp->dev_no, sp->deviceType, sp->devid, 3, sp->mon_sta, sp->dial_end_date);
    		printf("comsv_rest_put_dev_date = [%d]\n", i);
    		// 治療情報の日付データを更新する
    		i = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 2, 0, 4, sp->dial_end_date);
    		printf("comsv_rest_put_ord_date = [%d]\n", i);
    		if ( sp->pat_id > 0 ) {
    			// 未登録以外の場合
    			// 患者基本情報のステータスを更新する
    			i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 4);
    			printf("comsv_rest_put_pat_related = [%d]\n", i);
    			// 患者基本情報の透析回数を更新する
    			//i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 1, 0);
    			//printf("comsv_rest_put_pat_related = [%d]\n", i);
    		}
    		// 治療情報の実績モニタ値を更新する
    		comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
    		i = comsv_rest_post_ord_moni(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, fpath);
    		printf("comsv_rest_post_ord_moni = [%d]\n", i);
		}
        // #10889 2024.10.28 mod 既に終了時刻が入っている場合、終了処理を行わない TDC高村 end
		// 次患者更新を行う
		i = comsv_rest_post_web_api(sp->dev_no, sp->deviceType, sp->devid, 1);
		printf("comsv_rest_post_web_api = [%d]\n", i);
		// 次患者情報を要求
		sp->reqflg[C_NEXTPAT] = 1;
		sp->next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
        // 強制オフラインフラグ
        sp->force_flg = 0;
        sp->treatment = 0;
        // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
        comsv_medicated_end(sp);
        // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end
        // add AWSとDEの通信断からの復旧 高 start
        sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
        sp->current_mon_sta[0] = COMM_STA4;
        // add AWSとDEの通信断からの復旧 高 end
	}
}
// add 強制オフライン 高 end

// #11124 2025.07.28 add 酸素飽和度対応 TDC高村 start
/**
* @fn void comsv_mon_so2(struct scn_data_fm *sp)
* @brief 新通信のモニタデータ処理（ΔSO2制御）
* @param[in,out] sp 装置制御データ
* @details 新通信装置から受信したモニタデータ処理（ΔSO2制御）
*/
void comsv_mon_so2(struct scn_data_fm *sp) {
	int i;
	unsigned char *dp;
	unsigned char crc;

    // モニタデータ（ΔSO2制御）
    i = 0;
    if ( (sp->option[2] & (1 << 6)) == 0 ) {
        // 装置オプション（ΔSO2使用選択）が「OFF」の場合
        short_set(sp->rcvbuf + 12 + (104 * 2), (short)(0x8000));    // ΔSO2
        short_set(sp->rcvbuf + 12 + (105 * 2), (short)(0x8000));    // 補正ΔSO2
        i++;
    }
    else {
        // ΔSO2（ΔSO2を使用しないときには999）
        if ( hl_chg(*(short*)(sp->rcvbuf + 12 + (104 * 2))) == 999 ) {
            short_set(sp->rcvbuf + 12 + (104 * 2), (short)(0x8000));
            i++;
        }
        // #11124 2026.01.08 del アドレス105は対応不要（削除） TDC高村 start
        // // 補正ΔSO2（補正前は-1）
        // if ( hl_chg(*(short*)(sp->rcvbuf + 12 + (105 * 2))) == -1 ) {
        //     short_set(sp->rcvbuf + 12 + (105 * 2), (short)(0x8000));
        //     i++;
        // }
        // #11124 2026.01.08 del アドレス105は対応不要（削除） TDC高村 end
    }
    if ( i ) {
        // CRC再設定
        dp = sp->rcvbuf;
        for ( i = 0, crc = 0; i < sp->rcvlen; i++, dp++ ) {
            crc += (*dp);
        }
        if ( crc != (*dp) ) {
            (*dp) = crc;
        }
    }
}
// #11124 2025.07.28 add 酸素飽和度対応 TDC高村 end
