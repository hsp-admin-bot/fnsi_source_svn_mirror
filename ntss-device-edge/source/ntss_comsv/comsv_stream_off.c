/**
* @file comsv_stream_off.c
* @brief オフライン装置用処理関連
* @author Y.Takamura
* @date 2019/05/07
* @details オフライン装置用の処理を行う
*/

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include "ntss_comsv.h"
#include "ntss_packet_manage.h"
#include "ntss_common_comm.h"
#include "ntss_devicecap_conf.h"

#define	START_WAIT		60		/// オフライン運転開始待ち時間（秒）

/**
* @fn void *comsv_stream_off(void *ptr)
* @brief オフライン装置用スレッド処理
* @param[in,out] ptr 装置制御情報
* @return void* 
*/
void *comsv_stream_off(void *ptr) {
	int ret;
	int i, j;
    // mod FNSI-バグ 通信サーバ 高 start
    // short dial_time;
    int dial_time;
    int k;
    // mod FNSI-バグ 通信サーバ 高 end
	short offline_wait;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long offline_time;
	time_t offline_time;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	char fpath[64];
	unsigned char dat[1000];
	unsigned char ord_str[10];
	unsigned char logMsg[256];
	struct connect_socket *conSock = (struct connect_socket *) ptr;
	struct scn_data_fm *sp;
	pthread_t thr_cond, thr_medi;
	pthread_attr_t thread_attr;
	struct NTSS_PACKET_INFORMATION *pInfo;
    // add AWSとDEの通信断からの復旧 高 start
    short mon_sta_bak;
    // add AWSとDEの通信断からの復旧 高 end
	extern bool check_is_target_device_off(u_char *commFormat, u_char *deviceCode, struct scn_data_fm *scn);

    // #11108 del 2024.10.24 オフライン装置はmnt_machine_stateを取得してから起動する TDC片口 start
	// conSock->running = true;
	// conSock->scn.conflg = 2;
    // #11108 del 2024.10.24 オフライン装置はmnt_machine_stateを取得してから起動する TDC片口 end

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());
	
	// パケット管理情報クリア
    memset(&packetInfoList[conSock->thread_no], 0, sizeof(struct NTSS_PACKET_INFORMATION));

    // #11108 add 2024.10.24 オフライン装置はmnt_machine_stateを取得してから起動する TDC片口 start
	for (;; usleep(2000000))
	{
		if (conSock->using == false)
		{
			break;
		}
		if (getCommAliveState() != 0)
		{
			// 通信断
			continue;
		}
		// 装置状態管理データを取得
		comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
		i = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
		printf("comsv_rest_get_dev = [%d]\n", i);
		if (i != 0)
		{
			continue;
		}
		i = comsv_json_dev_state(fpath, 1, &(conSock->scn));
		printf("comsv_json_dev_state = [%d]\n", i);
		break;
	}
	if (conSock->using == false)
	{
		conSock->running = false;
	}
	else
	{
		conSock->running = true;
		conSock->scn.conflg = 2;
	}
	// #11108 add 2024.10.24 オフライン装置はmnt_machine_stateを取得してから起動する TDC片口 end

	sprintf(logMsg, "通信スレッドOFF[%d] : 起動", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);

	offline_wait = _comsvCache._comsvSet.offline_start_time;
	offline_time = 0;
	dial_time = -1;

	// NTSSパケット管理情報に必要な情報をセットする
	pInfo = &packetInfoList[conSock->thread_no];
	memcpy(pInfo->cDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
	pInfo->cDeviceFormat = conSock->scn.devsw;
	memcpy(pInfo->cDeviceNo, conSock->scn.devid, sizeof(conSock->scn.devid));
	pInfo->cCommType = NTSS_COMM_TYPE_NON;
	pInfo->sourceAddr = inet_addr(conSock->scn.ip_addr);
	pInfo->isConnected = 0x01;
    // mod FNSI-バグ 通信サーバ 高 start
    if( conSock->scn.mon_sta  & 1 ) {
        pInfo->nProcess[0] = 11;
        pInfo->isDialysis[0] = 0x01;
    }
    else {
    // mod FNSI-バグ 通信サーバ 高 end
        pInfo->nProcess[0] = 7;
    }
    
	pInfo->isNeedSendProcess = 0x01;
	pInfo->nMoniDataSize = 0;

	if ( conSock->scn.mon_sta ) {
		// 既に運転中
		offline_time = conSock->scn.dial_start_date;
		// 透析時間
		if ( _comsvCache._comsvSet.is_offline_auto_end == '1' ) {
			// 自動終了有り
			dial_time = conSock->scn.dial_time;
			if ( dial_time <= 0 ) dial_time = 240;	// 4時間
			dial_time *= 60;	// 分 → 秒
		}
	}
	else if ( conSock->scn.cond_send_flg && !conSock->scn.dial_start_date && !conSock->scn.dial_end_date ) {
		// 条件送信済（運転前）
		time(&offline_time);
	}

	for ( ; ; usleep(2000000) ) {

		if ( conSock->running == false ) {
			break;
		}

		// マスタ更新チェック
		if ( conSock->mst_reload == true ) {
			sprintf(logMsg, "通信スレッドOFF[%d] : マスタ更新", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			if( check_is_target_device_off(&(conSock->scn.devsw), &(conSock->scn.devid[0]), &(conSock->scn)) == false ) {
				sprintf(logMsg, "通信スレッドOFF[%d] : マスタ一致対象装置なし", conSock->thread_no);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				conSock->running = false;
				break; 
			}
            // add FNSI-バグ 通信サーバ 高 #9872 start
            memcpy(pInfo->cDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
            // add FNSI-バグ 通信サーバ 高 #9872 end
			sprintf(logMsg, "通信スレッドOFF[%d] : マスタ更新完了", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			conSock->mst_reload = false;
		}

		// イベント有無チェック
		for ( i = 0; i < EVENT_MAX; i++ ) {
			if ( conSock->event[i] == 0x01 ) {
				conSock->event[i] = 0x00;
				if ( conSock->scn.devsw != 'F' ) {
					// オフライン以外は対象外
					continue;
				}
				else if ( i == 0 ) {
					// オフライン装置の条件送信（オフライン透析）
					if ( conSock->scn.mon_sta & 1 ) {
						sprintf(logMsg, "通信スレッドOFF[%d] : イベント（条件送信）オフライン透析中", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						continue;
					}
					// 状況に応じた装置制御データのクリア
					comsv_clear(0, &(conSock->scn));
					// 運転開始前
					offline_wait = _comsvCache._comsvSet.offline_start_time;
					offline_time = 0;
					dial_time = -1;
					time(&offline_time);
					// 条件送信済み処理
					sp = &conSock->scn;
					sp->cond_send_flg = 1;
					sp->cond_send_time = 0;				// 条件送信時刻（コマンド送信時刻）
					sp->cond_send_date = get_time();	// 条件送信日時
					// 装置状態管理データを取得
					comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);
					ret = comsv_rest_get_dev(sp->dev_no, sp->deviceType, sp->devid, fpath);
					printf("comsv_rest_get_dev = [%d]\n", ret);
					// JSON文字列から条件送信データに格納する
					j = (SET2_NUM * 2);
					memset(dat, 0, sizeof(dat));
					ret = comsv_json_dev_cond(fpath, 0, &(conSock->scn), dat, j);
					printf("comsv_json_dev_cond = [%d]\n", ret);
					// 条件送信データからJSONファイルを作成する
					comsv_work_fpath(sp->dev_no, WORK_DEV_COND, fpath);
					ret = comsv_json_dev_make_cond(fpath, dat, j);
					printf("comsv_json_dev_make_cond = [%d]\n", ret);
					// 設定値読み込み履歴を更新する
					ret = comsv_rest_post_ord_cond(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, sp->cond_send_date, 1, fpath);
					printf("comsv_rest_post_ord_cond = [%d]\n", ret);
					// ホスト報知定義の取得・設定
					ret = comsv_host_watch(conSock->thread_no, sp);
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
				else if ( i == 4 ) {
					// 未登録患者割付の通知
					sprintf(logMsg, "通信スレッドOFF[%d] : イベント（未登録患者割付）", conSock->thread_no);
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					// 装置状態管理データを取得
		            comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
					ret = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
					printf("comsv_rest_get_dev = [%d]\n", ret);
					ret = comsv_json_dev_state(fpath, 1, &(conSock->scn));
					printf("comsv_json_dev_state = [%d]\n", ret);
					// 透析時間
					if ( _comsvCache._comsvSet.is_offline_auto_end == '1' ) {
						// 自動終了有り
						dial_time = conSock->scn.dial_time;
						if ( dial_time <= 0 ) dial_time = 240;	// 4時間
						dial_time *= 60;	// 分 → 秒
					}
				}
				else if ( i == 5 ) {
					// 条件送信キャンセルの通知
					if ( !(conSock->scn.mon_sta & 1) ) {
						sprintf(logMsg, "通信スレッドOFF[%d] : イベント（条件送信キャンセル）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						offline_wait = _comsvCache._comsvSet.offline_start_time;
						offline_time = 0;
						dial_time = -1;
						// 状況に応じた装置制御データのクリア
						comsv_clear(3, &(conSock->scn));
					}
					else {
						sprintf(logMsg, "通信スレッドOFF[%d] : イベント（条件送信キャンセル）運転中無効", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					}
				}
				else if ( i == 6 && (conSock->scn.mon_sta & 1) ) {
					// 投薬指示変更の通知
					sprintf(logMsg, "通信スレッドNEW[%d] : イベント（投薬指示変更）", conSock->thread_no);
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					// 仮想端末（投与薬剤）読み込み
					LcddataReq41_t req41;
					sprintf(ord_str, "%ld", conSock->scn.ord_no);
					comsv_work_fpath(conSock->scn.dev_no, WORK_LCD_REQ41, fpath);
					ret = comsv_rest_get_lcd(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 41, ord_str, fpath);
					printf("comsv_rest_get_lcd 41 = [%d]\n", ret);
					ret = comsv_json_lcd_req41(fpath, &req41);
					printf("comsv_json_lcd_req41 = [%d]\n", ret);
					// お知らせ通知時間のセット
					conSock->scn.alert_no = 0;
					memcpy(conSock->scn.alert_time, req41.alert_time, sizeof(conSock->scn.alert_time));
					for ( k = 0; k < ALERT_NUM; k++ ) {
						if ( conSock->scn.alert_time[k] < 0 ) continue;
						j = (conSock->scn.alert_time[k] * 60) + _comsvCache._comsvSet.notice_time;
						if ( get_time() >= conSock->scn.dial_start_date + j) {
							conSock->scn.alert_time[k] = -1;
						}
					}
				}
				else if ( (i == 7 && _comsvCache._comsvSet.pat_timing == '0') ||
						  (i == 8 && _comsvCache._comsvSet.pat_timing == '1') ) {
					// 後体重測定／治療状況確認の通知
					if ( i == 7 ) {
						sprintf(logMsg, "通信スレッドOFF[%d] : イベント（後体重測定）", conSock->thread_no);
					}
					else {
						sprintf(logMsg, "通信スレッドOFF[%d] : イベント（治療状況確認）", conSock->thread_no);
					}
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					// 現患者クリアを行う
					j = comsv_rest_post_web_api(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 0);
					printf("comsv_rest_post_web_api = [%d]\n", j);
					// 状況に応じた装置制御データのクリア
					comsv_clear(2, &(conSock->scn));
				}
				else if ( i == 10 ) {
					// オフライン運転開始の通知
					if ( conSock->scn.mon_sta == 0 && conSock->scn.cond_send_flg ) {
						sprintf(logMsg, "通信スレッドOFF[%d] : イベント（オフライン運転開始）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						offline_wait = 0;
						if ( !offline_time ) {
							time(&offline_time);
						}
					}
					else if ( conSock->scn.mon_sta ) {
						sprintf(logMsg, "通信スレッドOFF[%d] : イベント（オフライン運転開始）運転中無効", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					}
					else {
						sprintf(logMsg, "通信スレッドOFF[%d] : イベント（オフライン運転開始）条件未送信無効", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					}
				}
				else if ( i == 11 ) {
					// オフライン運転終了の通知
					if ( conSock->scn.mon_sta == 1 ) {
						sprintf(logMsg, "通信スレッドOFF[%d] : イベント（オフライン運転終了）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						dial_time = 0;
					}
					else {
						sprintf(logMsg, "通信スレッドOFF[%d] : イベント（オフライン運転終了）運転中以外無効", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					}
				}
                // add FNSI-バグ 通信サーバ 高 start
                else if ( i == 14 ) {
                    // #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 start
                    // // 実績データ変更の通知
                    // オフライン運転タイマー更新の通知
                    // #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 end
                    comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
                    j = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
                    printf("comsv_rest_get_dev = [%d]\n", j);
                    j = comsv_json_dev_state(fpath, 0, &(conSock->scn));
                    printf("comsv_json_dev_state = [%d]\n", j);
                    // 透析時間
                    if ( _comsvCache._comsvSet.is_offline_auto_end == '1' ) {
                        // 自動終了有り
                        if(dial_time > 0 && (conSock->scn.mon_sta & 1)) {
                            dial_time = conSock->scn.dial_time;
                            if ( dial_time <= 0 ) dial_time = 240;  // 4時間
                            dial_time *= 60;	// 分 → 秒
                        }
                    }
                    
                    // #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 start
                    // sprintf(logMsg, "通信スレッドOFF[%d] : イベント（実績データ変更）時間(%d)", conSock->thread_no, dial_time);
                    sprintf(logMsg, "通信スレッドOFF[%d] : イベント（オフライン運転タイマー更新）時間(%d)", conSock->thread_no, dial_time);
                    // #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 end
                    LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
                }
                // add FNSI-バグ 通信サーバ 高 end
			}
		}

		// お知らせ情報転送チェック
		comsv_notice_check(&(conSock->scn));

		// オフライン透析チェック
		if ( conSock->scn.mon_sta == 0 && offline_time && offline_wait >= 0 && get_time() >= (offline_time + offline_wait) ) {
			/****************/
			/* 透析開始処理 */
			/****************/
			offline_time = get_time();
			conSock->scn.mon_sta = 1;
			if ( !conSock->scn.dial_start_date ) {
				conSock->scn.dial_start_date = offline_time;	// 透析開始日時
			}
			pInfo->nProcess[0] = 11;
			pInfo->isNeedSendProcess = 0x01;
			pInfo->isDialysis[0] = 0x01;
			// 装置状態管理の日付データを更新する
			ret = comsv_rest_put_dev_date(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 2, conSock->scn.mon_sta, conSock->scn.dial_start_date);
			printf("comsv_rest_put_dev_date = [%d]\n", ret);
			// 装置状態管理データを取得
            comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
			ret = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
			printf("comsv_rest_get_dev = [%d]\n", ret);
			// JSON文字列から条件送信データに格納する
			j = (SET2_NUM * 2);
			memset(dat, 0, sizeof(dat));
			ret = comsv_json_dev_cond(fpath, 0, &(conSock->scn), dat, j);
			printf("comsv_json_dev_cond = [%d]\n", ret);
			// 透析時間
			dial_time = -1;
			if ( _comsvCache._comsvSet.is_offline_auto_end == '1' ) {
				// 自動終了有り
                // mod FNSI-バグ 通信サーバ 高 start
                // dial_time = conSock->scn.dial_time;
                dial_time = conSock->scn.treat_time;
                // mod FNSI-バグ 通信サーバ 高 end
				if ( dial_time <= 0 ) dial_time = 240;	// 4時間
				dial_time *= 60;	// 分 → 秒
			}
			// 治療情報の日付データを更新する
			ret = comsv_rest_put_ord_date(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.ord_no, 1, conSock->scn.pat_id, 3, conSock->scn.dial_start_date);
			printf("comsv_rest_put_ord_date = [%d]\n", ret);
			// 患者基本情報のステータスを更新する
			ret = comsv_rest_put_pat_related(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.pat_id, 0, conSock->scn.ord_no, 3);
			printf("comsv_rest_put_pat_related = [%d]\n", ret);
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
            // add AWSとDEの通信断からの復旧 高 start
            if (conSock->scn.current_mon_sta[0] == COMM_STA1 || conSock->scn.current_mon_sta[0] == COMM_STA2) { 
                // 治療中
                conSock->scn.current_mon_sta[1] = conSock->scn.current_mon_sta[0]; 
                conSock->scn.current_mon_sta[0] = COMM_STA3;
            }
            else {
                // 条件送信前+治療中
                conSock->scn.current_mon_sta[1] = conSock->scn.current_mon_sta[0];
                conSock->scn.current_mon_sta[0] = COMM_STA5;
            }
            // add AWSとDEの通信断からの復旧 高 end
		}
		else if ( conSock->scn.mon_sta == 1 && dial_time >= 0 && get_time() >= (offline_time + dial_time) ) {
			/****************/
			/* 透析終了処理 */
			/****************/
			offline_wait = _comsvCache._comsvSet.offline_start_time;
			offline_time = 0;
			dial_time = -1;
			conSock->scn.mon_sta = 0;
            // #10889 2024.10.28 mod 既に終了時刻が入っている場合、終了処理を行わない TDC高村 start
            /*
			if ( !conSock->scn.dial_end_date ) {
				conSock->scn.dial_end_date = get_time();	// 透析終了日時
			}
			pInfo->nProcess[0] = 7;
			pInfo->isNeedSendProcess = 0x01;
			pInfo->isDialysis[0] = 0x00;
			// 装置状態管理の日付データを更新する
			ret = comsv_rest_put_dev_date(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 3, conSock->scn.mon_sta, conSock->scn.dial_end_date);
			printf("comsv_rest_put_dev_date = [%d]\n", ret);
			// 治療情報の日付データを更新する
			ret = comsv_rest_put_ord_date(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.ord_no, 2, 0, 4, conSock->scn.dial_end_date);
			printf("comsv_rest_put_ord_date = [%d]\n", ret);
			// 患者基本情報のステータスを更新する
			ret = comsv_rest_put_pat_related(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.pat_id, 0, conSock->scn.ord_no, 4);
			printf("comsv_rest_put_pat_related = [%d]\n", ret);
			// 患者基本情報の透析回数を更新する
			//ret = comsv_rest_put_pat_related(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.pat_id, 1, 0, 0);
			//printf("comsv_rest_put_pat_related = [%d]\n", ret);
            */
			pInfo->nProcess[0] = 7;
			pInfo->isNeedSendProcess = 0x01;
			pInfo->isDialysis[0] = 0x00;
            // #11108 2024.10.30 mod 参照先メモリが誤っていた TDC片口 start
    		// if ( sp->dial_end_date == 0 ) {
    		if ( conSock->scn.dial_end_date == 0 ) {
            // #11108 2024.10.30 mod 参照先メモリが誤っていた TDC片口 start
				conSock->scn.dial_end_date = get_time();	// 透析終了日時
                // 装置状態管理の日付データを更新する
                ret = comsv_rest_put_dev_date(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 3, conSock->scn.mon_sta, conSock->scn.dial_end_date);
                printf("comsv_rest_put_dev_date = [%d]\n", ret);
                // 治療情報の日付データを更新する
                ret = comsv_rest_put_ord_date(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.ord_no, 2, 0, 4, conSock->scn.dial_end_date);
                printf("comsv_rest_put_ord_date = [%d]\n", ret);
                // 患者基本情報のステータスを更新する
                ret = comsv_rest_put_pat_related(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.pat_id, 0, conSock->scn.ord_no, 4);
                printf("comsv_rest_put_pat_related = [%d]\n", ret);
            }           
            // #10889 2024.10.28 mod 既に終了時刻が入っている場合、終了処理を行わない TDC高村 end
			// 次患者更新を行う
			ret = comsv_rest_post_web_api(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 1);
			printf("comsv_rest_post_web_api = [%d]\n", ret);
            // add AWSとDEの通信断からの復旧 高 start
            conSock->scn.current_mon_sta[1] = conSock->scn.current_mon_sta[0];
            conSock->scn.current_mon_sta[0] = COMM_STA4;
            // add AWSとDEの通信断からの復旧 高 end
		}
        
        // add AWSとDEの通信断からの復旧 高 start
        if ( getCommAliveState() == 1 && conSock->scn.comm_alive_state == 0) {
            conSock->scn.comm_alive_state = 1;
            if(conSock->scn.ord_no != 0)
                conSock->scn.ord_no_commfail = conSock->scn.ord_no;
            
        }
        if ( getCommAliveState() == 0  && conSock->scn.comm_alive_state == 1) {
            // COMM OK
            conSock->scn.comm_alive_state = 0;
            
            
            if(conSock->scn.mon_sta & 1) {
                mon_sta_bak = conSock->scn.mon_sta;
                // 装置状態管理データを取得
                comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
                i = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
                printf("comsv_rest_get_dev = [%d]\n", i);
                i = comsv_json_dev_state(fpath, 1, &(conSock->scn));
                printf("comsv_json_dev_state = [%d]\n", i);
                
                conSock->scn.mon_sta = mon_sta_bak;
                
                if((conSock->scn.dial_start_date != 0 && conSock->scn.dial_end_date != 0)
                    || (conSock->scn.dial_start_date == 0)) {
                    // オフライン運転終了
                    dial_time = 0;
                }
                else {
                    // set ProcessState
                    i = comsv_rest_put_ProcessState(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, pInfo->nProcess[0]);
                    printf("comsv_rest_put_ProcessState = [%d]\n", i);
                }
            }
            else {
                if(conSock->scn.dial_start_date == 0 && conSock->scn.dial_end_date == 0) {
                    comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
                    i = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
                    printf("comsv_rest_get_dev = [%d]\n", i);
                    i = comsv_json_dev_state(fpath, 1, &(conSock->scn));
                    printf("comsv_json_dev_state = [%d]\n", i);
                    
                    if ( conSock->scn.mon_sta ) {
                        dial_time = -1;
                        // 既に運転中
                        offline_time = conSock->scn.dial_start_date;
                        // 透析時間
                        if ( _comsvCache._comsvSet.is_offline_auto_end == '1' ) {
                            // 自動終了有り
                            dial_time = conSock->scn.dial_time;
                            if ( dial_time <= 0 ) dial_time = 240;    // 4時間
                            dial_time *= 60;    // 分 → 秒
                        }
                        pInfo->nProcess[0] = 11;
                    }
                }
                // set ProcessState
                i = comsv_rest_put_ProcessState(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, pInfo->nProcess[0]);
                printf("comsv_rest_put_ProcessState = [%d]\n", i);
            }
        }
        // add AWSとDEの通信断からの復旧 高 end
	}

	// パケット管理情報初期化
    finNTSSPacketInfo(&packetInfoList[conSock->thread_no]);

	sprintf(logMsg, "通信スレッドOFF[%d] : 終了", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	conSock->running = false;
	conSock->using = false;
	conSock->scn.conflg = 0;
    // add FNSI-バグ 通信サーバ 高 start
    memset(conSock->event, '\0', sizeof(conSock->event));
    // add FNSI-バグ 通信サーバ 高 end
	pthread_exit((void *)0); // スレッド終了
}

/**
 * @fn bool check_is_target_device_off(u_char *commFormatCd, u_char *deviceCode, struct scn_data_fm *scn)
 * @brief 装置マスタとの突き合わせ（オフライン装置用）
 * @param[in] commFormatCd 通信フォーマット 
 * @param[in] deviceCode 製造番号
 * @param[in,out] scn 装置制御データ
 * @return true 突き合わせ成功
 * @return false マスタに存在しない
 */
bool check_is_target_device_off(u_char *commFormatCd, u_char *deviceCode, struct scn_data_fm *scn) {
	bool matchMst = false;
	uint16_t idx;
	char mstDevNo[9] = {0};

	for( idx = 0; idx < COUNTOF(_machineInfoData); idx++ ) {
		if ( _machineInfoData[idx].machineFormatCd == '\0' ) {
			// これ以降マスタデータなし
			break;
		}

		strncpy(mstDevNo, _machineInfoData[idx].machineNo, 8);
		if ( memcmp(commFormatCd, &(_machineInfoData[idx].machineFormatCd), 1) == 0	// 通信フォーマットが一致
			&& memcmp(deviceCode, &(_machineInfoData[idx].machineSerial), 8) == 0	// 製造番号が一致
			&& _machineInfoData[idx].machineCommCd == NTSS_COMM_TYPE_NON) {			// 通信方式がオフライン装置
			// マスタに存在する
			scn->dev_idx = idx + 1;
			// 型式コード
 			memcpy(scn->deviceType, _machineInfoData[idx].machineTypeCd, 3);
			// 装置番号
			sscanf(mstDevNo, "%08lX", &scn->dev_no);
			// 突き合わせ成功
			matchMst = true;
			break;
		}
	}
	return matchMst;
}
