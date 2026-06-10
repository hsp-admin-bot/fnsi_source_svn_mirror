/**
* @file comsv_mon_cp.c
* @brief 共通プロトコルの装置状態データ処理
* @author Y.Takamura
* @date 2019/03/22
* @details 共通プロトコル装置から受信したモニタ装置状態データ処理
*/

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>
#include <pthread.h>
#include "ntss_comsv.h"
#include "ntss_devicecap_conf.h"

/**
* @fn void comsv_mon_cp(struct scn_data_fm *sp)
* @brief 共通プロトコルの装置状態データ処理
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 共通プロトコル装置から受信した装置状態データ処理
*/
void comsv_mon_cp(int thread_no, struct scn_data_fm *sp)
{
	int i;
	char *bp;
	char fpath[64];
	unsigned char logMsg[256];
	unsigned char mode;
	unsigned char ord_str[10];
	unsigned char sta, sta_bak;
	HostWatchPat_t host_watch[HOST_WATCH_MAX];
	pthread_t thr_medi;
    // #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 start
	pthread_t thr_unregi;
    // #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 end
	pthread_attr_t thread_attr;
    // add AWSとDEの通信断からの復旧 高 start
    unsigned char cdata[40] = {0};
    // add AWSとDEの通信断からの復旧 高 end
    // add FNSI-バグ 通信サーバ(#5618) 高 start
    int ret;
    unsigned char *folder;
    char s_dir[128];
    char d_dir[256];
    int ordno_state;
    char stx[3];
    char cmd[3];
    char str1[512];
    unsigned char tmpWrk[RCVMAX*2 + 256];
    int ii;
    unsigned char * pp, * pp_rcp;
    unsigned char ppUchar[3];
    unsigned char cdate[15];
    char dt[20], tm[10];
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long l_tim = 0;
    time_t l_tim = 0;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    // add FNSI-バグ 通信サーバ(#5618) 高 end

	if ( sp->devsw == 'W' ) {
		// 共通プロトコルV3		
		// コマンド（モニタデータ）
        // mod FNSI-バグ 通信サーバ 高 start
        memcpy(stx, sp->rcvbuf, 2);
        if ( memcmp(stx, "K3", 2) != 0 ) {
            // #12649 2026.04.15 del 以降のK3コマンド受信のためにフラグを初期化しないようにする TDC米沢 start
            // sp->device_comm_flg = 0;
            // #12649 2026.04.15 del 以降のK3コマンド受信のためにフラグを初期化しないようにする TDC米沢 end
            return;
        }
        // bp = strstr(sp->rcvbuf, "K3");
        // if ( bp == NULL ) return;
        // mod FNSI-バグ 通信サーバ 高 end
		// 治療中フラグ
		bp = strchr(sp->rcvbuf, 'M');
		if ( bp == NULL ) return;
		mode = bp[1];
	}
	else {
		// 共通プロトコルV4
		// コマンド（装置状態データ）
        // mod FNSI-バグ 通信サーバ 高 start
		// bp = strstr(sp->rcvbuf, "MS");
        memcpy(stx, sp->rcvbuf, 2);
        memcpy(cmd, sp->rcvbuf + 17, 2);
        if ( memcmp(stx, "S4", 2) != 0 ) {
            // #12649 2026.04.15 del 以降のS4コマンド受信のためにフラグを初期化しないようにする TDC米沢 start
            // sp->device_comm_flg = 0;
            // #12649 2026.04.15 del 以降のS4コマンド受信のためにフラグを初期化しないようにする TDC米沢 end
            return;
        }
        if ( memcmp(cmd, "MS", 2) != 0 ) return;
        // bp = strstr(sp->rcvbuf + 17, "MS");
        // if ( bp == NULL ) return;
        // mod FNSI-バグ 通信サーバ 高 end
		// 治療中フラグ
        // mod FNSI-バグ 通信サーバ 高 start
		// bp = strstr(sp->rcvbuf, "CM");
        bp = strstr(sp->rcvbuf + 17, "CM");
        // mod FNSI-バグ 通信サーバ 高 end
		if ( bp == NULL ) return;
		mode = bp[2];
	}

    // add FNSI-バグ 通信サーバ(#5618) 高 start
    if(sp->device_comm_flg == 1) {
        // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
        //long t_dial_start_date;
        //long t_dial_end_date;
        time_t t_dial_start_date;
        time_t t_dial_end_date;
        // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
        
        t_dial_start_date = sp->de_comm_start_date;
        t_dial_end_date = sp->de_comm_end_date;
        
        // 装置状態管理データを取得
        comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);
        i = comsv_rest_get_dev(sp->dev_no, sp->deviceType, sp->devid, fpath);
        printf("comsv_rest_get_dev = [%d]\n", i);
        i = comsv_json_dev_state(fpath, 1, sp);
        printf("comsv_json_dev_state = [%d]\n", i);
        
        sp->mon_sta &= ~0x01;
            
        if(mode == '1') {
            if((t_dial_start_date != 0 && get_time() > (t_dial_start_date + (_comsvCache._comsvSet.treatment_judge_time + sp->dial_time) * 60))
            || (t_dial_start_date != 0 && t_dial_end_date != 0)
            || (t_dial_start_date == 0)) {
                sprintf(str1, "[gs debug] : ord_no = %ld, next_ord_no = %ld, t_dial_start_date = %ld, t_dial_end_date = %ld, (treatment_judge_time + dial_time) * 60= %d, get_time()= %ld", 
                    sp->ord_no, sp->next_ord_no, t_dial_start_date, t_dial_end_date,
                    (_comsvCache._comsvSet.treatment_judge_time + sp->dial_time) * 60, get_time());
                LogOutputs(NTSS_LOG_INFO, str1, 0, sp->deviceType, sp->devid);
                
                sp->mon_sta |= 0x01;
                if(sp->ord_no != 0) {
                    // 治療状況データを取得
                    comsv_work_fpath(sp->dev_no, WORK_DEV_ORDNO, fpath);
                    i = comsv_rest_get_ordno_state(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, fpath);
                    printf("comsv_rest_get_ordno_state = [%d]\n", i);
                    i = comsv_json_ordno_state(fpath, &ordno_state);
                    printf("comsv_json_ordno_state = [%d]\n", i);
                    
                    if(ordno_state == 1 || ordno_state == 2) {
                        comsv_fail_cond_send_cancel(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no);
                    }
                }
                
                if(t_dial_start_date != 0 && t_dial_end_date == 0) {
                    // current close 
                    sp->dial_end_date = get_time();      // 透析終了日時
                    // 装置状態管理の日付データを更新する
                    i = comsv_rest_put_dev_date(sp->dev_no, sp->deviceType, sp->devid, 3, 0, sp->dial_end_date);
                    printf("comsv_rest_put_dev_date = [%d]\n", i);
                    if(sp->ord_no != 0) {
                        // 治療情報の日付データを更新する
                        i = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 2, 0, 4, sp->dial_end_date);
                        printf("comsv_rest_put_ord_date = [%d]\n", i);
                        comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
                        i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData, packetInfoList[thread_no].cCommType);
                        printf("comsv_json_ord_make_moni = [%d]\n", i);
                        // 治療情報の実績モニタ値を更新する
                        i = comsv_rest_post_ord_moni(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, fpath);
                    }
                }
                
                sp->dial_start_date = get_time();    // 透析開始日時
                // ？？？？患者の場合
                // #10844 2024.07.29 mod DB高負荷状態の時に????患者が複数生成される TDC高村 start
                /*
                sp->cond_send_flg = 1;
                // ホスト報知監視開始待ち時間の初期化
                comsv_host_watch_init(thread_no);
                // 治療情報を登録（患者未登録運転）する
                i = comsv_rest_put_unregistered(sp->dev_no, sp->deviceType, sp->devid, 1, 3, sp->dial_start_date);
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
      			    // スレッド属性オブジェクトの初期化
       		    	pthread_attr_init(&thread_attr);
       			    // スレッド切り離し状態属性の設定
       			    pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
       			    // 患者未登録運転スレッド処理
                    sp->thread_unregistered_no = thread_no; // スレッド番号
                    sp->thread_unregistered = 3;            // スレッド処理
                    sp->thread_unregistered_sta = 1;        // 装置ステータス
                    pthread_create(&thr_unregi, &thread_attr, comsv_thread_unregistered, sp);
                }
                else {
                    // 既に実行中
                    sprintf(str1, "患者未登録運転スレッド処理が既に実行中 [%d][%d]", sp->thread_unregistered, sp->thread_unregistered_sta);
                    LogOutputs(NTSS_LOG_ERROR, str1, 0, sp->deviceType, sp->devid);
                }
                // #10844 2024.07.29 mod DB高負荷状態の時に????患者が複数生成される TDC高村 start
            }
            else {
                if(t_dial_start_date != 0 && t_dial_end_date == 0) {
                    sp->mon_sta |= 0x01;
                }
            }
        }
        else {
            sp->mon_sta &= ~0x01;
            // current close 
            // 治療情報の日付データを更新する
            if(t_dial_start_date != 0 && t_dial_end_date == 0) {
                sp->dial_end_date = get_time();      // 透析終了日時
                // 装置状態管理の日付データを更新する
                i = comsv_rest_put_dev_date(sp->dev_no, sp->deviceType, sp->devid, 3, 0, sp->dial_end_date);
                printf("comsv_rest_put_dev_date = [%d]\n", i);
                if(sp->ord_no != 0) {
                    i = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 2, 0, 4, sp->dial_end_date);
                    printf("comsv_rest_put_ord_date = [%d]\n", i);
                    comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
                    i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData, packetInfoList[thread_no].cCommType);
                    printf("comsv_json_ord_make_moni = [%d]\n", i);
                    // 治療情報の実績モニタ値を更新する
                    i = comsv_rest_post_ord_moni(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, fpath);
                }
            }
            // 次患者更新を行う
            i = comsv_rest_post_web_api(sp->dev_no, sp->deviceType, sp->devid, 1);
            printf("comsv_rest_post_web_api = [%d]\n", i);
            if ( sp->devsw == 'V' ) {
                // 次患者情報を要求
                sp->reqflg[C_NEXTPAT] = 1;
                sp->next_pat_send = 0;  // 次患者送信（0:タイミング,1:イベント）
            }
        }
        
        sprintf(str1, "[gs debug] 通信スレッドCP[%d] : run mode first = %c, sp->mon_sta = %x", thread_no, mode, sp->mon_sta);
        LogOutputs(NTSS_LOG_INFO, str1, 0, sp->deviceType, sp->devid);

        sp->device_comm_flg = 0;
        ret = 0;

        for( i = 0; i < 3; i++ ) {
            folder = getNTSSDeviceCapDataFolder( NTSS_OUTPUT_FOLDER_DATA_COLLECT, i );
            if( existFolderFile( folder, NULL ) != 1 )
                continue;
            
            ret = 1;
            break;
        }
        
        if(ret == 1) {
            comsv_work_fpath_dev_commfail(sp->dev_no, s_dir);
            strcpy(d_dir, folder);
            if(d_dir[strlen(d_dir) - 1] == '\\' || d_dir[strlen(d_dir) - 1] == '/') {
                d_dir[strlen(d_dir) - 1] = '\0';
            }
             
            copyWorkDir(s_dir, d_dir);
            removeWorkDir(s_dir);
        }
    }
    // add FNSI-バグ 通信サーバ(#5618) 高 end

	sta = sta_bak = sp->mon_sta;	// 状態の前回データ
	if ( mode == '1' ) sta |= 0x01;
	else sta &= ~0x01;

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
                // mod FNSI-バグ 通信サーバ 高 start
                // sp->dial_start_date = get_time();	// 透析開始日時
                if ( sp->devsw == 'W' ) {
                    // 共通プロトコルV3
                    sp->dial_start_date = packetInfoList[thread_no].buffer.lastReceiveTime.tv_sec;
                }
                else {
                    // 共通プロトコルV4
                    sp->dial_start_date = get_time();
                    bp = strstr(sp->rcvbuf + 17, "DB");
                    if(bp != NULL) {
                        memcpy(cdate, bp + 2, 14);
                        cdate[14] = '\0';
                        if(is_valid_date(cdate)) {
                            memset(dt, '\0', sizeof(dt));
                            memset(tm, '\0', sizeof(tm));
                            // 日付
                            memcpy( dt, cdate, 4 );
                            dt[4] = '/';
                            memcpy( dt + 5, cdate + 4, 2 );
                            dt[7] = '/';
                            memcpy( dt + 8, cdate + 6, 2 );
                            
                            // 時刻
                            memcpy( tm, cdate + 8, 2 );
                            tm[2] = ':';
                            memcpy( tm + 3, cdate + 10, 2 );
                            tm[5] = ':';
                            memcpy( tm + 6, cdate + 12, 2 );
                            if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                                sp->dial_start_date = l_tim;
                            }
                        }
                    }
                }
                // mod FNSI-バグ 通信サーバ 高 end
                // #10844 2024.07.29 del DB高負荷状態の時に????患者が複数生成される TDC高村 start
                // // ホスト報知監視開始待ち時間の初期化
    		    // comsv_host_watch_init(thread_no);
                // #10844 2024.07.29 del DB高負荷状態の時に????患者が複数生成される TDC高村 end
                sprintf(str1, "[gs debug] 通信スレッドCP[%d] 透析開始処理 : sp->ord_no = %ld, sp->pat_id = %ld, sp->cond_send_flg = %d, sp->cond_set_date = %ld", 
                        thread_no, sp->ord_no, sp->pat_id, sp->cond_send_flg, sp->cond_set_date);
                LogOutputs(NTSS_LOG_INFO, str1, 0, sp->deviceType, sp->devid);
                sprintf(str1, "[gs debug] 通信スレッドCP[%d] : run mode = %c, sp->mon_sta = %x, sta = %x", thread_no, mode, sp->mon_sta, sta);
                LogOutputs(NTSS_LOG_INFO, str1, 0, sp->deviceType, sp->devid);
        		if ( sp->ord_no == 0 || sp->pat_id == 0 ||
        			sp->cond_send_flg == 0 || sp->cond_set_date == 0 ) {
        			// 未登録の場合
                    // #10844 2024.07.29 mod DB高負荷状態の時に????患者が複数生成される TDC高村 start
                    /*
        			sp->cond_send_flg = 1;
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
        			    // スレッド属性オブジェクトの初期化
        			    pthread_attr_init(&thread_attr);
        			    // スレッド切り離し状態属性の設定
        			    pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
        			    // 患者未登録運転スレッド処理
                        sp->thread_unregistered_no = thread_no; // スレッド番号
                        sp->thread_unregistered = 3;            // スレッド処理
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
                        // 透析開始日時
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
        			if ( sp->pat_id > 0 ) {
        				// 未登録以外の場合
        				// 患者基本情報のステータスを更新する
        				i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 3);
        				printf("comsv_rest_put_pat_related = [%d]\n", i);
        				// 患者基本情報の透析回数を更新する
        				//i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 1, 0, 0);
        				//printf("comsv_rest_put_pat_related = [%d]\n", i);
        			}
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
                sprintf(tmpWrk, "通信スレッドCP[%d] : 透析終了処理 MS = [", thread_no);
                pp = &tmpWrk[0];
                pp += strlen(tmpWrk);
                pp_rcp = sp->rcvbuf;
                for(ii = 0; ii < sp->rcvlen; ii++) {
                    sprintf(ppUchar, "%c", *(pp_rcp+ii));
                    strcat(pp, ppUchar);
                }
                LogOutputs(NTSS_LOG_INFO, tmpWrk, 0, sp->deviceType, sp->devid);
                
                pp = strstr(sp->rcvbuf + 17, "CM");
                if(pp != NULL) {
                    sprintf(tmpWrk, "通信スレッドCP[%d] : 透析終了処理 治療中フラグ = [%c]", thread_no, pp[2]);
                    LogOutputs(NTSS_LOG_INFO, tmpWrk, 0, sp->deviceType, sp->devid);
                }
                
                sprintf(str1, "[gs debug] 通信スレッドCP[%d] 透析終了処理 : run mode = %c, sp->mon_sta = %x, sta = %x", thread_no, mode, sp->mon_sta, sta);
                LogOutputs(NTSS_LOG_INFO, str1, 0, sp->deviceType, sp->devid);
                // mod FNSI-バグ 通信サーバ 高 start
                // sp->dial_end_date = get_time();	// 透析終了日時
                if ( sp->devsw == 'W' ) {
                    // 共通プロトコルV3
                    sp->dial_end_date = packetInfoList[thread_no].buffer.lastReceiveTime.tv_sec;
                }
                else {
                    // 共通プロトコルV4
                    sp->dial_end_date = get_time();
                    bp = strstr(sp->rcvbuf + 17, "DC");
                    if(bp != NULL) {
                        memcpy(cdate, bp + 2, 14);
                        cdate[14] = '\0';
                        if(is_valid_date(cdate)) {
                            memset(dt, '\0', sizeof(dt));
                            memset(tm, '\0', sizeof(tm));
                            // 日付
                            memcpy( dt, cdate, 4 );
                            dt[4] = '/';
                            memcpy( dt + 5, cdate + 4, 2 );
                            dt[7] = '/';
                            memcpy( dt + 8, cdate + 6, 2 );
                            
                            // 時刻
                            memcpy( tm, cdate + 8, 2 );
                            tm[2] = ':';
                            memcpy( tm + 3, cdate + 10, 2 );
                            tm[5] = ':';
                            memcpy( tm + 6, cdate + 12, 2 );
                            if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                                sp->dial_end_date = l_tim;
                            }
                        }
                    }
                }
                // mod FNSI-バグ 通信サーバ 高 end
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
        		// 排液時更新用モニタデータからJSONファイルを作成
        		comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
                // mod FNSI-バグ 通信サーバ 高 start 
           		// i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData+12);
                i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData, packetInfoList[thread_no].cCommType);
                // mod FNSI-バグ 通信サーバ 高 end
        		printf("comsv_json_ord_make_moni = [%d]\n", i);
        		// 治療情報の実績モニタ値を更新する
        		i = comsv_rest_post_ord_moni(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, fpath);
        		printf("comsv_rest_post_ord_moni = [%d]\n", i);
        		// 次患者更新を行う
        		i = comsv_rest_post_web_api(sp->dev_no, sp->deviceType, sp->devid, 1);
        		printf("comsv_rest_post_web_api = [%d]\n", i);
        		if ( sp->devsw == 'V' ) {
        			// 次患者情報を要求
        			sp->reqflg[C_NEXTPAT] = 1;
        			sp->next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
        		}
                // add AWSとDEの通信断からの復旧 高 start
                sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
                sp->current_mon_sta[0] = COMM_STA4;
                // add AWSとDEの通信断からの復旧 高 end
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
        
    	if ( sp->first_sta >= 0 ) {
    		// 初回ステータスチェック
    		if ( sp->devsw == 'V' ) {
    			// V4の場合、警報・報知はOFFにする
    			sp->mon_sta &= ~0x28;
    		}
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
//    				// 患者基本情報のステータスを更新する
//    				i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 4);
//    				printf("comsv_rest_put_pat_related = [%d]\n", i);
//    				// 患者基本情報の透析回数を更新する
//    				//i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 1, 0, 0);
//    				//printf("comsv_rest_put_pat_related = [%d]\n", i);
//    				// 排液時更新用モニタデータからJSONファイルを作成
//    				comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
//                    // mod FNSI-バグ 通信サーバ 高 start 
//    				// i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData+12);
//                    i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData, packetInfoList[thread_no].cCommType);
//                    // mod FNSI-バグ 通信サーバ 高 end 
//    				printf("comsv_json_ord_make_moni = [%d]\n", i);
//    				// 治療情報の実績モニタ値を更新する
//    				i = comsv_rest_post_ord_moni(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, fpath);
//    				printf("comsv_rest_post_ord_moni = [%d]\n", i);
//    				// 次患者更新を行う
//    				i = comsv_rest_post_web_api(sp->dev_no, sp->deviceType, sp->devid, 1);
//    				printf("comsv_rest_post_web_api = [%d]\n", i);
//    				if ( sp->devsw == 'V' ) {
//    					// 次患者情報を要求
//    					sp->reqflg[C_NEXTPAT] = 1;
//    					sp->next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
//    				}
//    				// 未登録運転
//    				comsv_clear(2, sp);		// 前回透析終了状態の場合、装置制御データをクリアして未登録運転へ
//    				sp->dial_start_date = get_time();	// 透析開始日時
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
    				// ホスト報知監視開始待ち時間の初期化
    				comsv_host_watch_init(thread_no);
    				// ホスト報知定義の取得・設定
    				i = comsv_host_watch(thread_no, sp);
    				printf("comsv_host_watch = [%d]\n", i);
    			}
    		}
    		sp->first_sta = -1;
    	}
    }
}

// add 強制オフライン 高 start
/**
* @fn void comsv_mon_cp_offline(int thread_no, struct scn_data_fm *sp)
* @brief 新通信のモニタデータ処理（ステータス／モニタ／ログ）
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 新通信装置から受信したモニタデータ処理（ステータス／モニタ／ログ）
*/
void comsv_mon_cp_offline(int thread_no, struct scn_data_fm *sp) {
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
		// sp->reqflg[C_JSETRD] = 1;			// 条件データ読出要求
		// sp->cond_read_flg = 2;				// 設定値読出フラグ（2:運転開始時）
        
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
		// 状況に応じた装置制御データのクリア
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
        pInfo->nProcess[0] = 7;
        pInfo->isNeedSendProcess = 0x01;
        pInfo->isDialysis[0] = 0x00;
        
		if ( sp->dial_end_date == 0 ) {
			sp->dial_end_date = get_time();	// 透析終了日時
			// 排液時更新用モニタデータからJSONファイルを作成
			comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
			i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData, packetInfoList[thread_no].cCommType);
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
		// 患者基本情報のステータスを更新する
		i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 4);
		printf("comsv_rest_put_pat_related = [%d]\n", i);
		// 患者基本情報の透析回数を更新する
		//i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 1, 0);
		//printf("comsv_rest_put_pat_related = [%d]\n", i);
        // 排液時更新用モニタデータからJSONファイルを作成
		comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
   		i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData, packetInfoList[thread_no].cCommType);
		printf("comsv_json_ord_make_moni = [%d]\n", i);
		// 治療情報の実績モニタ値を更新する
		i = comsv_rest_post_ord_moni(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, fpath);
		printf("comsv_rest_post_ord_moni = [%d]\n", i);
        */
		    // 装置状態管理の日付データを更新する
		    i = comsv_rest_put_dev_date(sp->dev_no, sp->deviceType, sp->devid, 3, sp->mon_sta, sp->dial_end_date);
		    printf("comsv_rest_put_dev_date = [%d]\n", i);
		    // 治療情報の日付データを更新する
		    i = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 2, 0, 4, sp->dial_end_date);
		    printf("comsv_rest_put_ord_date = [%d]\n", i);
		    // 患者基本情報のステータスを更新する
		    i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 4);
		    printf("comsv_rest_put_pat_related = [%d]\n", i);
		    // 患者基本情報の透析回数を更新する
		    //i = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 1, 0);
		    //printf("comsv_rest_put_pat_related = [%d]\n", i);
            // 排液時更新用モニタデータからJSONファイルを作成
		    comsv_work_fpath(sp->dev_no, WORK_DEV_MONI, fpath);
     		i = comsv_json_ord_make_moni(fpath, packetInfoList[thread_no].cMoniData, packetInfoList[thread_no].cCommType);
		    printf("comsv_json_ord_make_moni = [%d]\n", i);
		    // 治療情報の実績モニタ値を更新する
		    i = comsv_rest_post_ord_moni(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, fpath);
		    printf("comsv_rest_post_ord_moni = [%d]\n", i);
 		}
        // #10889 2024.10.28 mod 既に終了時刻が入っている場合、終了処理を行わない TDC高村 end
		// 次患者更新を行う
		i = comsv_rest_post_web_api(sp->dev_no, sp->deviceType, sp->devid, 1);
		printf("comsv_rest_post_web_api = [%d]\n", i);
		if ( sp->devsw == 'V' ) {
			// 次患者情報を要求
			sp->reqflg[C_NEXTPAT] = 1;
			sp->next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
		}
        // 強制オフラインフラグ
        sp->force_flg = 0;
        sp->treatment = 0;
        // add AWSとDEの通信断からの復旧 高 start
        sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
        sp->current_mon_sta[0] = COMM_STA4;
        // add AWSとDEの通信断からの復旧 高 end
	}
}
// add 強制オフライン 高 end
