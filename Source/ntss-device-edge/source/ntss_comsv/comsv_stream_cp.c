/**
* @file comsv_stream_cp.c
* @brief 共通プロトコル用処理関連
* @author Y.Takamura
* @date 2019/01/07
* @details 共通プロトコル用の処理を行う
*/

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/time.h>
#include "comsv_info.h"
#include "ntss_comsv.h"
#include "ntss_packet_manage.h"
#include "ntss_common_comm.h"
#include "ntss_devicecap_conf.h"

/**
* @fn void *comsv_stream_cp(void *ptr)
* @brief 共通プロトコル通信用スレッド処理
* @param[in,out] ptr 装置制御データ
* @return void* 
*/
void *comsv_stream_cp(void *ptr) {
	int ret;
	int i, j;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long connect_tim = 0;
	//long req_last_time = 0;
	time_t connect_tim = 0;
	time_t req_last_time = 0;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	struct connect_socket *conSock = (struct connect_socket *) ptr;
	char fpath[64];
	char TimeSet_LastTime[20] = "";	// 前回一斉時刻合わせ日時
	unsigned char ord_str[10];
	unsigned char logMsg[256];
	// mod AWSとDEの通信断からの復旧 高 start
	struct NTSS_PACKET_INFORMATION *pInfo = NULL;
	int ii;
	short mon_sta_bak;
	// mod AWSとDEの通信断からの復旧 高 end
	// add 強制オフライン 高 start
	pthread_t thr_rep;
	pthread_attr_t thread_attr;
	int max;
	unsigned char dat[1000];
	// add 強制オフライン 高 end

    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//extern bool comsv_communication_cp(struct connect_socket *conSock, long *z_tim);
	extern bool comsv_communication_cp(struct connect_socket *conSock, time_t *z_tim);
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	extern bool comsv_connect_cp(struct connect_socket *conSock);
	extern bool comsv_connect_check_cp(struct connect_socket *conSock);
	extern void comsv_connect_close_cp(struct connect_socket *conSock);
	extern void comsv_socket_error_cp(struct connect_socket *conSock);
	extern bool check_is_target_device_cp(u_char *commFormat, u_char *deviceCode, u_char *ip, short *port, struct scn_data_fm *scn);
	extern bool check_time_setting_cp(char *LastTime);

	conSock->running = true;
	conSock->scn.staflg = S_WAIT;
	conSock->scn.err_ltime = 0;
	// #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 start
	conSock->scn.cmd = 0;
	conSock->scn.comptreat_date = 0;
	// #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 end
	// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知(初期値true) TDC片口 start
	conSock->is_update_comm_fail_from_main = true;
	int lastResultUpdateCommFail = 0;
	// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知(初期値true) TDC片口 end
	
	// パケット管理情報クリア
	memset(&packetInfoList[conSock->thread_no], 0, sizeof(struct NTSS_PACKET_INFORMATION));

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	sprintf(logMsg, "通信スレッドCP[%d] : 起動", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);

	// add 強制オフライン 高 start
	conSock->scn.force_offline_wait = _comsvCache._comsvSet.offline_start_time;
	conSock->scn.force_offline_time = 0;
	conSock->scn.force_dial_time = -1;
	
	if ( conSock->scn.mon_sta & 1 ) {
		// 既に運転中
		conSock->scn.force_offline_time = conSock->scn.dial_start_date;
		// 透析時間
		if ( _comsvCache._comsvSet.is_offline_auto_end == '1' ) {
			// 自動終了有り
			conSock->scn.force_dial_time = conSock->scn.dial_time;
			if ( conSock->scn.force_dial_time <= 0 ) conSock->scn.force_dial_time = 240;	// 4時間
			conSock->scn.force_dial_time *= 60;	// 分 → 秒
		}
	}
	else if ( conSock->scn.cond_send_flg && !conSock->scn.dial_start_date && !conSock->scn.dial_end_date ) {
		// 条件送信済（運転前）
		time(&(conSock->scn.force_offline_time));
	}
	// add 強制オフライン 高 end
	
	for ( ; ; usleep(2000000) ) {

		if ( conSock->running == false ) {
			comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
			break;
		}

		// マスタ更新チェック
		if ( conSock->mst_reload == true ) {
			sprintf(logMsg, "通信スレッドCP[%d] : マスタ更新", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			if( check_is_target_device_cp(&(conSock->scn.devsw), &(conSock->scn.devid[0]), conSock->scn.ip_addr, &(conSock->scn.port_no), &(conSock->scn)) == false ) {
				sprintf(logMsg, "通信スレッドCP[%d] : マスタ一致対象装置なし", conSock->thread_no);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
				// #11115 2024.10.25 mod 共通プロトコルのスレッド終了時にメモリをクリアする TDC高村 start
				//comsv_socket_error_cp(conSock);
				comsv_socket_close_cp(conSock);
				// #11115 2024.10.25 mod 共通プロトコルのスレッド終了時にメモリをクリアする TDC高村 end
				break;
			}
			sprintf(logMsg, "通信スレッドCP[%d] : マスタ更新完了", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			conSock->mst_reload = false;
		}

		// 一斉時刻合わせチェック（共通プロトコルV4のみ対応）
		if ( conSock->scn.devsw == 'V' && check_time_setting_cp(TimeSet_LastTime) == true ) {
			printf("通信スレッドCP[%d] : 一斉時刻合わせ\n", conSock->thread_no);
			// 時計設定を要求
			conSock->scn.reqflg[C_CLOCK] = 1;
		}

		if ( get_time() > connect_tim + CONTIME ) {
 			// コネクション処理（共通プロトコル通信接続用）
			if ( comsv_connect_cp(conSock) == true ) {
				printf("通信スレッドCP[%d] : コネクション処理開始\n", conSock->thread_no);
			}
			connect_tim = get_time();
		}
 		// コネクション完了確認（共通プロトコル通信接続用）
		if ( comsv_connect_check_cp(conSock) == true ) {
			printf("通信スレッドCP[%d] : コネクション処理完了\n", conSock->thread_no);
			
			sprintf(logMsg, "[gs debug] 通信スレッドCP[%d] : コネクション処理完了", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);

 			// NTSSパケット管理情報に必要な情報をセットする
			pInfo = &packetInfoList[conSock->thread_no];
			memcpy(pInfo->cDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
			pInfo->cDeviceFormat = conSock->scn.devsw;
			memcpy(pInfo->cDeviceNo, conSock->scn.devid, sizeof(conSock->scn.devid));
			pInfo->cCommType = NTSS_COMM_TYPE_COMMON;
			pInfo->sourceAddr = inet_addr(conSock->scn.ip_addr);
			pInfo->isConnected = 0x01;
			pInfo->isNeedSendProcess = 0x01;
			pInfo->nMoniDataSize = 0;
			// add FNSI-バグ 通信サーバ(#5618) 高 start
			// 装置状態管理データを取得
			comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
			ii = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
			printf("comsv_rest_get_dev = [%d]\n", ii);
			i = comsv_json_dev_state(fpath, 1, &(conSock->scn));
			// #11925 2025.06.13 del サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 start
			// if( ii == 0) {
			// #11925 2025.06.13 del サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 end
				conSock->scn.device_comm_flg = 1;
				conSock->scn.de_comm_start_date = conSock->scn.dial_start_date;
				conSock->scn.de_comm_end_date = conSock->scn.dial_end_date;
				
				if ( conSock->scn.dev_no != 0 ) {
					comsv_work_mkdir_dev_commfail(conSock->scn.dev_no);
				}
			// #11925 2025.06.13 del サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 start
			// }
			// #11925 2025.06.13 del サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 end
			conSock->scn.reqflg[C_MONITOR] = 1;
			conSock->scn.staflg = S_WAIT;
			// add FNSI-バグ 通信サーバ(#5618) 高 end
			// ホスト報知監視設定初期化
			initNTSSHostWatchConf(pInfo);
		}

		// イベント有無チェック
		for ( i = 0; i < EVENT_MAX; i++ ) {
			if ( conSock->event[i] == 0x01 ) {
				conSock->event[i] = 0x00;
				if ( conSock->scn.devsw != 'V' && conSock->scn.devsw != 'W' ) {
					// 共通プロトコル以外は対象外
					sprintf(logMsg, "通信スレッドCP[%d] : イベント（共通プロトコル以外は対象外）", conSock->thread_no);
					LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					continue;
				}
				if ( i == 0 ) {
					// 設定値書込を要求
					if ( !(conSock->scn.mon_sta & 1) ) {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（条件送信）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						
						// add FNSI-バグ 通信サーバ 高 start
						conSock->scn.cond_send_cancel = 0;	// 条件送信キャンセル（1:有）
						// add FNSI-バグ 通信サーバ 高 end
						
						// add 強制オフライン 高 start
						// 装置状態管理データを取得
						comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
						i = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
						printf("comsv_rest_get_dev = [%d]\n", i);
						// JSON文字列から条件送信データに格納する
						max = (SET2_NUM * 2);
						memset(dat, 0, sizeof(dat));
						i = comsv_json_dev_cond(fpath, 0, &(conSock->scn), dat, max);
						printf("comsv_json_dev_cond = [%d]\n", i);
						conSock->scn.force_dial_time = -1;
						conSock->scn.force_offline_time = 0;
						time(&(conSock->scn.force_offline_time));
						conSock->scn.force_flg = 0;
						if( conSock->scn.treatment == 9 ) {
							conSock->scn.force_flg = 1;
						}
						// 強制オフライン
						if( conSock->scn.force_flg == 1 ) {
							conSock->scn.force_offline_wait = _comsvCache._comsvSet.offline_start_time;
							// 状況に応じた装置制御データのクリア
							comsv_clear(0, &(conSock->scn));
							
							// conSock->scn.cond_read_flg = 1;		// 設定値読出フラグ（1:条件送信時）
							if ( conSock->scn.devsw == 'V' ) {
								conSock->scn.next_pat_send = 0;		// 次患者送信（0:タイミング,1:イベント）
								conSock->scn.reqflg[C_NEXTPAT] = 1;	// 次患者情報を要求
							}
							
							conSock->scn.cond_send_time = 0;			// 条件送信時刻（コマンド送信時刻）
							conSock->scn.cond_send_date = get_time();	// 条件送信日時
							conSock->scn.force_cond_flg = 1;			// 条件送信フラグ（1:条件送信時）
							
							pInfo->nProcess[0] = 7;
							pInfo->isNeedSendProcess = 0x01;
							
							// 条件送信データからJSONファイルを作成する
							comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_COND, fpath);
							i = comsv_json_dev_make_cond(fpath, dat, max);
							printf("comsv_json_dev_make_cond = [%d]\n", i);
							// 設定値読み込み履歴を更新する
							i = comsv_rest_post_ord_cond(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 
															conSock->scn.ord_no, conSock->scn.cond_send_date, 1, fpath);
							printf("comsv_rest_post_ord_cond = [%d]\n", i);
							// add FNSI-バグ 通信サーバ 高 start
							// ホスト報知定義の取得・設定
							ret = comsv_host_watch(conSock->thread_no, &(conSock->scn));
							printf("comsv_host_watch = [%d]\n", ret);
							// add FNSI-バグ 通信サーバ 高 end
							if ( conSock->scn.devsw == 'W' ) {
								conSock->scn.cond_send_flg = 1;

								// スレッド属性オブジェクトの初期化
								pthread_attr_init(&thread_attr);
								// スレッド切り離し状態属性の設定
								pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
								conSock->scn.unregistered_flg = 0;
								// 条件送信完了時の一連スレッド処理
								pthread_create(&thr_rep, &thread_attr, comsv_thread_rest_cond, &(conSock->scn));
							}
							// add AWSとDEの通信断からの復旧 高 start
							conSock->scn.current_mon_sta[1] = conSock->scn.current_mon_sta[0]; 
							conSock->scn.current_mon_sta[0] = COMM_STA1;
							// add AWSとDEの通信断からの復旧 高 end
						}
						else {
						// add 強制オフライン 高 end
							if ( conSock->scn.devsw == 'V' ) {
								// 次患者情報を要求
								conSock->scn.reqflg[C_NEXTPAT] = 1;
								conSock->scn.next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
							}
							conSock->scn.reqflg[C_JSET] = 1;
							if ( conSock->scn.dial_start_date && conSock->scn.dial_end_date ) {
								// 次患者条件送信
								// 現患者クリアを行う
								i = comsv_rest_post_web_api(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 0);
								printf("comsv_rest_post_web_api = [%d]\n", i);
								// 状況に応じた装置制御データのクリア
								comsv_clear(4, &(conSock->scn));
							}
							else {
								// 状況に応じた装置制御データのクリア
								comsv_clear(0, &(conSock->scn));
							}
						}
					}
					else {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（条件送信）運転中無効", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					}
				}
				else if ( i == 3 ) {
					// 次患者情報を要求
					// #9290 2023.10.25 mod 装置が運転中でも次患者送信を行う TDC高村 start
					/*
					if ( !(conSock->scn.mon_sta & 1) ) {
						if ( conSock->scn.devsw == 'V' ) {
							sprintf(logMsg, "通信スレッドCP[%d] : イベント（次患者情報）", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
							conSock->scn.reqflg[C_NEXTPAT] = 1;
							conSock->scn.next_pat_send = 1;	// 次患者送信（0:タイミング,1:イベント）
						}
						else {
							sprintf(logMsg, "通信スレッドCP[%d] : イベント（次患者情報）対象機種外", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						}
					}
					else {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（次患者情報）運転中無効", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					}
					*/
					if ( conSock->scn.devsw == 'V' ) {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（次患者情報）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						conSock->scn.reqflg[C_NEXTPAT] = 1;
						conSock->scn.next_pat_send = 1;	// 次患者送信（0:タイミング,1:イベント）
					}
					else {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（次患者情報）対象機種外", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					}
					// #9290 2023.10.25 mod 装置が運転中でも次患者送信を行う TDC高村 end
				}
				else if ( i == 4 ) {
					// 未登録患者割付の通知
					sprintf(logMsg, "通信スレッドCP[%d] : イベント（未登録患者割付）", conSock->thread_no);
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					// 装置状態管理データを取得
					comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
					i = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
					printf("comsv_rest_get_dev = [%d]\n", i);
					i = comsv_json_dev_state(fpath, 1, &(conSock->scn));
					printf("comsv_json_dev_state = [%d]\n", i);
					if ( conSock->scn.devsw == 'V' ) {
						// 次患者情報を要求
						conSock->scn.reqflg[C_NEXTPAT] = 1;
						conSock->scn.next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
					}
				}
				else if ( i == 5 ) {
					// 条件送信キャンセルの通知
					if ( !(conSock->scn.mon_sta & 1) ) {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（条件送信キャンセル）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						// mod FNSI-バグ 通信サーバ 高 start
						conSock->scn.cond_send_cancel = 1;	// 条件送信キャンセル（1:有）
						conSock->scn.reqflg[C_JSET] = 1;
						// 状況に応じた装置制御データのクリア
						//comsv_clear(3, &(conSock->scn));
						//if ( conSock->scn.devsw == 'V' ) {
							// 次患者情報を要求
						//	conSock->scn.reqflg[C_NEXTPAT] = 1;
						//}
						// mod FNSI-バグ 通信サーバ 高 end
						
						// add 強制オフライン 高 start
						conSock->scn.force_offline_time = 0;
						conSock->scn.force_dial_time = -1;
						conSock->scn.force_flg = 0;
						conSock->scn.treatment = 0;
						// add 強制オフライン 高 end
					}
					else {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（条件送信キャンセル）運転中無効", conSock->thread_no);
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
					i = comsv_rest_get_lcd(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 41, ord_str, fpath);
					printf("comsv_rest_get_lcd 41 = [%d]\n", i);
					i = comsv_json_lcd_req41(fpath, &req41);
					printf("comsv_json_lcd_req41 = [%d]\n", i);
					// お知らせ通知時間のセット
					conSock->scn.alert_no = 0;
					memcpy(conSock->scn.alert_time, req41.alert_time, sizeof(conSock->scn.alert_time));
					for ( i = 0; i < ALERT_NUM; i++ ) {
						if ( conSock->scn.alert_time[i] < 0 ) continue;
						j = (conSock->scn.alert_time[i] * 60) + _comsvCache._comsvSet.notice_time;
						if ( get_time() >= conSock->scn.dial_start_date + j) {
							conSock->scn.alert_time[i] = -1;
						}
					}
				}
				else if ( (i == 7 && _comsvCache._comsvSet.pat_timing == '0') ||
						  (i == 8 && _comsvCache._comsvSet.pat_timing == '1') ) {
					// 後体重測定／治療状況確認の通知
					if ( i == 7 ) {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（後体重測定）", conSock->thread_no);
					}
					else {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（治療状況確認）", conSock->thread_no);
					}
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					// #10457 2024.06.18 del デバイスエッジへの通知元で現患者クリアを実施 TDC高村 start
					// 現患者クリアを行う
					// i = comsv_rest_post_web_api(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 0);
					// printf("comsv_rest_post_web_api = [%d]\n", i);
					// #10457 2024.06.18 del デバイスエッジへの通知元で現患者クリアを実施 TDC高村 end
					// 状況に応じた装置制御データのクリア
					comsv_clear(2, &(conSock->scn));
					//if ( conSock->scn.devsw == 'V' ) {
					//	// 次患者情報を要求
					//	conSock->scn.reqflg[C_NEXTPAT] = 1;
					//	conSock->scn.next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
					//}
				}
				// add 強制オフライン 高 start
				else if ( i == 10 ) {
					// オフライン運転開始の通知
					if ( !(conSock->scn.mon_sta & 1)  && conSock->scn.cond_send_flg ) {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（オフライン運転開始）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						conSock->scn.force_offline_wait = 0;
						if ( !conSock->scn.force_offline_time ) {
							time(&(conSock->scn.force_offline_time));
						}
					}
					else if ( conSock->scn.mon_sta & 1 ) {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（オフライン運転開始）運転中無効", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					}
					else {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（オフライン運転開始）条件未送信無効", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					}
				}
				else if ( i == 11 ) {
					// オフライン運転終了の通知
					if ( conSock->scn.mon_sta & 1 ) {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（オフライン運転終了）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						conSock->scn.force_dial_time = 0;
					}
					else {
						sprintf(logMsg, "通信スレッドCP[%d] : イベント（オフライン運転終了）運転中以外無効", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					}
				}
				// add 強制オフライン 高 end
				// add FNSI-バグ 通信サーバ 高 start
				else if ( i == 15 ) {
					// ホスト報知定義更新指示の通知
					// ホスト報知定義の取得・設定
					j = comsv_host_watch(conSock->thread_no, &(conSock->scn));
					printf("comsv_host_watch = [%d]\n", j);
					sprintf(logMsg, "通信スレッドCP[%d] : イベント（ホスト報知定義更新指示）", conSock->thread_no);
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				}
				// add FNSI-バグ 通信サーバ 高 end
			}
		}

		// 条件送信タイムアウトチェック
		if ( (conSock->scn.reqflg[C_JSET] == 2 || conSock->scn.reqflg[C_JSET] == 4) && conSock->scn.cond_send_time ) {
			if ( get_time() > conSock->scn.cond_send_time + TIMEOUT ) {
				// リトライ１、２
				conSock->scn.reqflg[C_JSET] += 1;
			}
		}
		else if ( conSock->scn.reqflg[C_JSET] == 6 && conSock->scn.cond_send_time ) {
			if ( get_time() > conSock->scn.cond_send_time + TIMEOUT ) {
				// タイムアウト
				sprintf(logMsg, "通信スレッドCP[%d] : 設定値書込破棄（タイムアウト）", conSock->thread_no);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);			
				if ( conSock->scn.cond_send_ctrl ) {
					// 体重計測定実績のステータス・メッセージデータを更新する
					comsv_rest_put_scale_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.cond_send_ctrl, 7);
				}
				conSock->scn.reqflg[C_JSET] = 0;
			}
		}

		// お知らせ情報転送チェック
		comsv_notice_check(&(conSock->scn));

		/**
		 * 共通プロトコル通信処理
		 */
		if ( conSock->scn.conflg == 2 ) {
			if ( comsv_communication_cp(conSock, &req_last_time) == false ) {
				// パケット管理情報初期化
				finNTSSPacketInfo(&packetInfoList[conSock->thread_no]);
				//break;
				// スレッドは終了しない
			}
		}
		
		// add 強制オフライン 高 start
		if( conSock->scn.force_flg == 1 ) {
			comsv_mon_cp_offline(conSock->thread_no, &(conSock->scn));
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
			// set ProcessState
			if(pInfo != NULL) {
				i = comsv_rest_put_ProcessState(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, pInfo->nProcess[0]);
				printf("comsv_rest_put_ProcessState = [%d]\n", i);
			}
			
			// 強制オフライン
			if((conSock->scn.mon_sta & 1) && conSock->scn.force_flg == 1) {
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
					conSock->scn.force_dial_time = 0;
				}
			}
		}
		// add AWSとDEの通信断からの復旧 高 end

		// #11282 2025.03.12 mod 通信不可フォルダへの転送完了のシグナル通知 TDC片口 start
		// // #11282 2025.02.28 add 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 start
		// updateCommFailDataFromMain(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 2);
		// // #11282 2025.02.28 add 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 end
		if (conSock->is_update_comm_fail_from_main)
		{
			int resultUpdateCommFail = updateCommFailDataFromMain(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 2);
			if (resultUpdateCommFail == 0 || resultUpdateCommFail == lastResultUpdateCommFail)
			{
				// 処理件数がゼロまたは前回と同値ならば処理終了（正常終了またはリトライ不可能のため）
				conSock->is_update_comm_fail_from_main = false;
				lastResultUpdateCommFail = 0;
			}
			else
			{
				// 処理件数がゼロ以外ならば前回処理件数として記録
				lastResultUpdateCommFail = resultUpdateCommFail;
			}
		}
		// #11282 2025.03.12 mod 通信不可フォルダへの転送完了のシグナル通知 TDC片口 end
	}

	// ソケットクローズ処理（共通プロトコル通信接続用）
	comsv_connect_close_cp(conSock);

	// パケット管理情報初期化
	finNTSSPacketInfo(&packetInfoList[conSock->thread_no]);
	
	// add FNSI-バグ 通信サーバ 高 start
	if(packetInfoList[conSock->thread_no].sourceAddr != 0) {
		packetInfoList[conSock->thread_no].sourceAddr = 0;
	}
	// add FNSI-バグ 通信サーバ 高 end

	sprintf(logMsg, "通信スレッドCP[%d] : 終了", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	conSock->running = false;
	conSock->using = false;
	// add FNSI-バグ 通信サーバ 高 start
	memset(conSock->event, '\0', sizeof(conSock->event));
	// add FNSI-バグ 通信サーバ 高 end
	pthread_exit((void *)0); // スレッド終了
}

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
//* @fn bool comsv_communication_cp(struct connect_socket *conSock, long *z_tim)
//* @brief 共通プロトコルソケット送受信処理
//* @param[in,out] conSock 装置制御データ
//* @param[in,out] z_tim 前回リクエスト時間
//* @return true 正常
//* @return false エラー
//*/
//bool comsv_communication_cp(struct connect_socket *conSock, long *z_tim) {
/**
* @fn bool comsv_communication_cp(struct connect_socket *conSock, time_t *z_tim)
* @brief 共通プロトコルソケット送受信処理
* @param[in,out] conSock 装置制御データ
* @param[in,out] z_tim 前回リクエスト時間
* @return true 正常
* @return false エラー
*/
bool comsv_communication_cp(struct connect_socket *conSock, time_t *z_tim) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	int i, len;
	fd_set fd, fdw;
	uint16_t sel_ret = 0;
	struct timeval seltime;
	int ret;
	unsigned char *dp, crc;
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
	//unsigned char sum[10], rcvCrc[3];
	unsigned char sum[10], rcvCrc[5];
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
	unsigned char logMsg[256];
	unsigned char buf[RCVMAX];
	struct NTSS_PACKET_INFORMATION *pInfo;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    struct timespec myTime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

	extern void comsv_socket_error_cp(struct connect_socket *conSock);

	sel_ret = 0;
	if ( conSock->scn.staflg != S_ETX ) {
		// 新通信装置受信チェック
		if ( conSock->scn.conflg <= 0 ) {
			comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
			comsv_socket_error_cp(conSock);			// ソケットエラー処理
			return false;
		}
		FD_ZERO(&fd);
		FD_SET(conSock->scn.sock_id, &fd);
		seltime.tv_sec = 1;
		seltime.tv_usec = 0;
		sel_ret = select(conSock->scn.sock_id + 1, &fd, NULL, NULL, &seltime);
	}
	if ( sel_ret > 0 && FD_ISSET(conSock->scn.sock_id, &fd) ) {
		// 受信データ有り
		memset(buf, 0, sizeof(buf));
		ret = read(conSock->scn.sock_id, buf, sizeof(buf));
		if ( ret <= 0 ) {
			// #11490 2025.02.26 add ソケットREAD失敗時、戻り値及びエラー内容をログ出力 start
			sprintf(logMsg, "通信スレッドCP[%d] : ソケットREAD 失敗 [%d] [%d][%s]", conSock->thread_no, ret, errno, strerror(errno));
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			// #11490 2025.02.26 add ソケットREAD失敗時、戻り値及びエラー内容をログ出力 end
			comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
			comsv_socket_error_cp(conSock);			// ソケットエラー処理
			return false;
		}
		// 受信データ処理
		comsv_rcvset_cp(&(conSock->scn),buf, ret);
	}
	else {
		// 受信データ無し
		if ( get_time() >= (*z_tim + req_time_cp) && conSock->scn.comflg == C_NOTOPE ) {
			//	リクエストコマンド発行
			conSock->scn.reqflg[C_MONITOR] = 1;
			conSock->scn.staflg = S_WAIT;
			*z_tim = get_time();	// 前回リクエスト送信時間
		}
		else if ( conSock->scn.err_ltime ) {
			if ( get_time() > conSock->scn.err_ltime + _comsvCache._comsvSet.device_timeout ) {
				// タイムアウト
				sprintf(logMsg, "通信スレッドCP[%d] : 通信タイムアウト[%02x]", conSock->thread_no, conSock->scn.staflg);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
				comsv_socket_error_cp(conSock);			// ソケットエラー処理
				return false;
			}
		}
		else {
			conSock->scn.err_ltime = get_time();
		}
	}

	// 受信データチェック
	if ( conSock->scn.staflg == S_ETX ) {
		ret = 0;
		dp = conSock->scn.rcvbuf;
		len = conSock->scn.rcvlen - 4;	// SUM,ETX分を除く
		for ( i = 0, crc = 0; i < len; i++, dp++ ) {
			crc += (*dp);
		}
		sprintf(sum, "%02x", crc);
		if ( memcmp(dp, sum, 2) ) {
			ret = E_CRCCHK;

			// #12304 2025.10.24 add ログ強化（CRCエラー） TDC片口 start
			snprintf(rcvCrc, 3, "%s", dp);
			sprintf(logMsg, "通信スレッドCP[%d] : CRCエラー CRC=[%s] 計算値=[%s] 前回CMD=[%02x] データ長=%d",
				conSock->thread_no, rcvCrc, sum, conSock->scn.cmd, conSock->scn.rcvlen - 2);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);

			sprintf(logMsg, "通信スレッドCP[%d] : 受信データ", conSock->thread_no);
			LogOutputsHexDump(NTSS_LOG_ERROR, logMsg, conSock->scn.rcvbuf, conSock->scn.rcvlen - 2,
								conSock->scn.deviceType, conSock->scn.devid);
			// #12304 2025.10.24 add ログ強化（CRCエラー） TDC片口 end
		}
		if ( ret == 0 ) {
			/* 正常終了 */
			conSock->scn.staflg = S_END; 
			conSock->scn.conflg = 2; 
		}
		else {
            // #12697 2026.05.21 mod CRCエラー時の通信スレッド再起動をやめる TDC高村 start
            // 電文は破棄、ソケット切断・スレッド再起動を行わず、待ち状態に戻して継続
            // conSock->scn.staflg = ret;
            conSock->scn.staflg   = S_WAIT;
            conSock->scn.rcvlen   = 0;
            conSock->scn.err_ltime = 0;
            // #12697 2026.05.21 mod CRCエラー時の通信スレッド再起動をやめる TDC高村 end
		}
	}

	/* 正常受信データ処理 */
	if ( conSock->scn.staflg == S_END ) {

		// 共通プロトコル受信データ処理
		comsv_rcv_cp(conSock->thread_no, &(conSock->scn));

		// #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 start
		if ( configParam.responseTimeout_CP && conSock->scn.devsw == 'V' &&
			(conSock->scn.comflg == C_NEXTPAT || conSock->scn.comflg == C_JSET || conSock->scn.comflg == C_CLOCK) ) {
			// 次患者情報、条件設定、時計設定の場合は通信処理レベル＆送信日時をクリア
			conSock->scn.cmd = 0;
			conSock->scn.comptreat_date = 0;
		}
		// #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 end

		// 電文ファイル出力
		pInfo = &packetInfoList[conSock->thread_no];
        // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
		//gettimeofday(&pInfo->buffer.lastReceiveTime, NULL);
        clock_gettime(CLOCK_REALTIME, &myTime);
        pInfo->buffer.lastReceiveTime.tv_sec = myTime.tv_sec;
        pInfo->buffer.lastReceiveTime.tv_usec = myTime.tv_nsec / 1000;
        // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	   	memcpy(pInfo->buffer.cBuffer, conSock->scn.rcvbuf, conSock->scn.rcvlen);
		pInfo->buffer.nBufferSize = conSock->scn.rcvlen;
		// add 装置のSTATUS状態更新方法の変更 高 start
		pInfo->machineState = conSock->scn.machineState[0];
		// add 装置のSTATUS状態更新方法の変更 高 end
		// add 強制オフライン 高 start
		pInfo->force_flg = conSock->scn.force_flg;
		// add 強制オフライン 高 end
		// add FNSI-バグ 通信サーバ(#5618) 高 start
		pInfo->device_comm_flg = conSock->scn.device_comm_flg;
		pInfo->dev_no = conSock->scn.dev_no;
		// add FNSI-バグ 通信サーバ(#5618) 高 end
		ret = checkNTSSCommonCommand(pInfo);
		if ( ret != 0 ) {
			sprintf(logMsg, "通信スレッドCP[%d] : 電文ファイル出力[%d]", conSock->thread_no, ret);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		}
		
		// add 装置のSTATUS状態更新方法の変更 高 start
		conSock->scn.machineState[0] = pInfo->machineState;
		if( conSock->scn.machineState[0] != conSock->scn.machineState[1] ) {
			// add FNSI-バグ 通信サーバ 高 start
			if(conSock->scn.force_flg != 1){
			// add FNSI-バグ 通信サーバ 高 end
				i = comsv_rest_put_machineState(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.machineState[0]);
				printf("comsv_rest_put_machineState = [%d]\n", i);
			}
			
			conSock->scn.machineState[1] = conSock->scn.machineState[0];
		}
		// add 装置のSTATUS状態更新方法の変更 高 end

		// 装置状態データ処理
		comsv_mon_cp(conSock->thread_no, &(conSock->scn));

		if ( conSock->scn.comflg && conSock->scn.comflg != C_RESPONSE ) {
			conSock->scn.reqflg[conSock->scn.comflg] = 0;
		}
		conSock->scn.mon_sta &= 0x7fff;	// 通信異常クリア
		conSock->scn.staflg = S_WAIT;
		conSock->scn.err_ltime = 0;
	}
	else if ( conSock->scn.conflg >0 && (conSock->scn.staflg & S_END) ) {	
		sprintf(logMsg, "通信スレッドCP[%d] : 受信データ異常[%02x]", conSock->thread_no, conSock->scn.staflg);
		LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);			
		if ( !memcmp(conSock->scn.rcvbuf, "R3", 2) || !memcmp(conSock->scn.rcvbuf, "E3", 2) ||
			(!memcmp(conSock->scn.rcvbuf, "R4", 2) && !memcpy(conSock->scn.rcvbuf + 17, "TC", 2)) ||
			(!memcmp(conSock->scn.rcvbuf, "E4", 2) && !memcpy(conSock->scn.rcvbuf + 17, "TC", 2)) ) {
			// 体重計測定実績のステータス・メッセージデータを更新する
			comsv_rest_put_scale_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.cond_send_ctrl, 4);
		}
		comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
		comsv_socket_error_cp(conSock);			// ソケットエラー処理
		return false;
	}

	/* 送信コマンド作成 */
	if ( conSock->scn.staflg == S_WAIT && conSock->scn.conflg > 0 ) {
		// #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 start
		if ( conSock->scn.comptreat_date && conSock->scn.devsw == 'V' ) {
			if ( get_time() > (configParam.responseTimeout_CP + conSock->scn.comptreat_date) ) {
				if ( conSock->scn.cmd && conSock->scn.cmd != C_JSET ) {
					// タイムアウトによりコマンド破棄（条件設定は処理を継続）
					conSock->scn.reqflg[conSock->scn.cmd] = 0;
				}
				sprintf(logMsg, "通信スレッドCP[%d] : 医器工V4タイムアウト設定による受信待ち解除[%d]", conSock->thread_no,conSock->scn.cmd);
				LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				conSock->scn.cmd = 0;
				conSock->scn.comptreat_date = 0;
				conSock->scn.comflg = C_NOTOPE;
			}
			else if ( conSock->scn.comflg != C_RESPONSE ) {
				conSock->scn.comflg = C_NOTOPE;
			}
		}
		//if ( conSock->scn.comflg != C_RESPONSE ) {
		if ( conSock->scn.comflg != C_RESPONSE && !conSock->scn.comptreat_date ) {
		// #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 end
			for ( i = 1, conSock->scn.comflg = C_NOTOPE; i <= C_MONITOR; i++ ) {
				if ( conSock->scn.reqflg[i] == 1 ) {
					conSock->scn.comflg = i;
					if ( conSock->scn.comflg == C_JSET ) {
						// 条件送信ならクリアせず、タイムアウトチェックを行う
						conSock->scn.reqflg[i] = 2;
					}
					else {
						conSock->scn.reqflg[i] = 0;
					}
					break;
				}
				else if ( conSock->scn.reqflg[i] == 3 || conSock->scn.reqflg[i] == 5 ) {
					// リトライ１、２
					if ( i == C_JSET ) {
						// 条件送信ならクリアせず、タイムアウトチェックを行う
						conSock->scn.comflg = i;
						conSock->scn.reqflg[i] += 1;
					}
					else {
						conSock->scn.reqflg[i] = 0;
					}
					break;
				}
			}
		}
		if ( conSock->scn.comflg == C_NOTOPE ) {
			// 残り受信データ処理
			comsv_rcvset_cp(&(conSock->scn),(char*)0, 0);
			return true;
		}
		
		ret = comsv_cmd_cp(&(conSock->scn));
		if ( ret>0 ) {
			conSock->scn.staflg = S_SEND;
			// #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 start
			if ( configParam.responseTimeout_CP && conSock->scn.devsw == 'V' &&
				(conSock->scn.comflg == C_NEXTPAT || conSock->scn.comflg == C_JSET || conSock->scn.comflg == C_CLOCK) ) {
				// 次患者情報、条件設定、時計設定の場合は通信処理レベル＆送信日時をセット
				conSock->scn.cmd = conSock->scn.comflg;
				conSock->scn.comptreat_date = get_time();
			}
			// #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 end
		}
		else {
			conSock->scn.staflg = S_WAIT;
		}
		conSock->scn.comflg = C_NOTOPE;
	}

	/* 送信処理 */
	if ( conSock->scn.staflg == S_SEND ) {
		// 送信
		ret = -99;
		FD_ZERO(&fdw);
		FD_SET(conSock->scn.sock_id, &fdw);
		seltime.tv_sec = 1;
		seltime.tv_usec = 0;
		sel_ret = select(conSock->scn.sock_id + 1, NULL, &fdw, NULL, &seltime);
		if ( sel_ret > 0 && FD_ISSET(conSock->scn.sock_id,&fdw) ) {
			// 書き込み
			ret = write(conSock->scn.sock_id, conSock->scn.sndbuf, conSock->scn.sndlen);
		}
		if ( ret <= 0 ) {
			// 失敗
			sprintf(logMsg, "通信スレッドCP[%d] : 書き込み失敗[%d]", conSock->thread_no, (int)ret);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			if ( conSock->scn.comflg == C_JSET ) {
				// 体重計測定実績のステータス・メッセージデータを更新する
				comsv_rest_put_scale_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.cond_send_ctrl, 8);
			}
			comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
			comsv_socket_error_cp(conSock);			// ソケットエラー処理
			return false;
		} else {
			//ioctl(conSock->scn.sock_id, I_FLUSH, FLUSHRW);
			conSock->scn.staflg = S_WAIT;
			// del FNSI-バグ 通信サーバ 高 start
			// conSock->scn.err_ltime = 0;
			// del FNSI-バグ 通信サーバ 高 end
		}
	}

	// 残り受信データ処理
	comsv_rcvset_cp(&(conSock->scn),(char*)0, 0);

	return true;
}

/**
* @fn bool comsv_connect_cp(struct connect_socket *conSock)
* @brief コネクション処理（共通プロトコル通信接続用）
* @param[in,out] conSock 装置制御情報
* @return true 正常
* @return false エラー
*/
bool comsv_connect_cp(struct connect_socket *conSock) {
	bool ret = false;
	int sfd;	// ソケットファイルディスクプリタ
	int val = 1;
	struct sockaddr_in saddr;

	extern void comsv_connect_close_cp(struct connect_socket *conSock);

	if ( conSock->scn.sock_id == 0 && conSock->scn.conflg == 0 ) {
		// ソケットを作成（共通プロトコル通信接続用）
		sfd = socket(AF_INET, SOCK_STREAM, 0);
		if (sfd < 0) {
			return ret;
		}
		// ノンブロッキングソケットに変更
		ioctl(sfd, FIONBIO, &val);

		// コネクション
		saddr.sin_family = AF_INET;
		saddr.sin_port = htons(conSock->scn.port_no);
		saddr.sin_addr.s_addr = inet_addr(conSock->scn.ip_addr);
		// コネクション
		connect(sfd, (struct sockaddr*)&saddr, sizeof(saddr));
		conSock->scn.sock_id = sfd;
		conSock->scn.conflg = 1;
		ret = true;
	}
	else if ( conSock->scn.sock_id != 0 && conSock->scn.conflg == 1 ) {
		// ソケットクローズ処理（共通プロトコル通信接続用）
		comsv_connect_close_cp(conSock);
	}

	return ret;
}

/**
* @fn bool comsv_connect_check_cp(struct connect_socket *conSock)
* @brief コネクション完了確認（共通プロトコル通信接続用）
* @param[in,out] conSock 装置制御データ
* @return true コネクション完了
* @return false コネクション中
*/
bool comsv_connect_check_cp(struct connect_socket *conSock) {
	bool ret = false;
	int rtn;
	char buf[2];
	fd_set writefds;
	struct timeval seltime;

	if ( conSock->scn.sock_id != 0 && conSock->scn.conflg == 1 ) {
		// コネクション状態確認
		FD_ZERO(&writefds);
		FD_SET(conSock->scn.sock_id, &writefds);
		seltime.tv_sec = 0;
		seltime.tv_usec = 100000;
		rtn = select(conSock->scn.sock_id + 1, NULL, &writefds, NULL, &seltime);
		if ( rtn > 0 ) {
			rtn = read(conSock->scn.sock_id, buf, 1);
			if ( rtn < 0 && errno == EAGAIN ) {
				// コネクション完了
				conSock->scn.conflg = 2;
				ret = true;
			}
		}
	}
	return ret;
}

/**
* @fn void comsv_connect_close_cp(struct connect_socket *conSock)
* @brief コネクション切断処理（共通プロトコル通信接続用）
* @param[in,out] conSock 装置制御データ
*/
void comsv_connect_close_cp(struct connect_socket *conSock) {
	if ( conSock->scn.conflg ) {
		// シャットダウン(送受信禁止)
		shutdown(conSock->scn.sock_id, 2);
		// ソケットクローズ
		close(conSock->scn.sock_id);

		conSock->scn.sock_id = 0;
		conSock->scn.conflg = 0;
	}
}

/**
* @fn void comsv_socket_close_cp(struct connect_socket *conSock)
* @brief ソケットクローズ処理（共通プロトコル通信接続用）
* @param[in,out] conSock 装置制御データ
*/
void comsv_socket_close_cp(struct connect_socket *conSock) {
	comsv_connect_close_cp( conSock );

	conSock->running = false;
	/* 通信制御データクリア */
	memset(&conSock->scn, 0, sizeof(struct scn_data_fm));
}

/**
* @fn void comsv_socket_error_cp(struct connect_socket *conSock)
* @brief ソケットエラー処理（共通プロトコル通信用）
* @param[in,out] conSock 装置制御データ
*/
void comsv_socket_error_cp(struct connect_socket *conSock) {
	// ソケットクローズ処理（共通プロトコル通信接続用）
	comsv_connect_close_cp(conSock);
}

/**
 * @fn bool check_is_target_device_cp(u_char *commFormatCd, u_char *deviceCode, u_char *ipAddr, short *port, struct scn_data_fm *scn)
 * @brief マスタとの突き合わせ（共通プロトコル用）
 * @param[in] commFormatCd 通信フォーマット 
 * @param[in] deviceCode 製造番号
 * @param[in] ipAddr IPアドレス
 * @param[out] port ポート番号
 * @param[in,out] scn 装置制御データ
 * @return true 突き合わせ成功
 * @return false マスタに存在しない
 */
bool check_is_target_device_cp(u_char *commFormatCd, u_char *deviceCode, u_char *ipAddr, short *port, struct scn_data_fm *scn) {
	bool matchMst = false;
	uint16_t idx;
	char mstIpAddr[16] = {0};
	char mstPortNo[6] = {0};
	char mstDevNo[9] = {0};

	for ( idx = 0; idx < COUNTOF(_machineInfoData); idx++ ) {
		if ( _machineInfoData[idx].machineFormatCd == '\0' ) {
			// これ以降マスタデータなし
			break;
		}
		// マスタ構造体のIPアドレス・ポート番号は末尾に\0がないため文字列として扱えない
		strncpy(mstIpAddr, _machineInfoData[idx].ipAddress, 15);
		strncpy(mstPortNo, _machineInfoData[idx].strport, 5);
		strncpy(mstDevNo, _machineInfoData[idx].machineNo, 8);

		if (memcmp(commFormatCd, &(_machineInfoData[idx].machineFormatCd), 1) == 0	// 通信フォーマットが一致
			&& memcmp(deviceCode, &(_machineInfoData[idx].machineSerial), 8) == 0	// 製造番号が一致
			&& convertNTSSIPAddr(ipAddr) == convertNTSSIPAddr(mstIpAddr)			// IPアドレス一致
			&& _machineInfoData[idx].machineCommCd == NTSS_COMM_TYPE_COMMON) {		// 通信方式が共通プロトコル通信
			// マスタに存在する
			scn->dev_idx = idx + 1;
			// ポート番号
			*port = atoi(mstPortNo);
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

/**
 * @fn void comsv_rcvset_cp(struct scn_data_fm *sp, u_char *buf, int len)
 * @brief 受信データ解析処理（共通プロトコル用）
 * @param[in,out] sp 装置制御データ
 * @param[in] buf 受信データ 
 * @param len 受信データ長
 */
void comsv_rcvset_cp(struct scn_data_fm *sp, u_char *buf, int len) {
	int i, n;
	u_char *dp, rc;
	u_char *bufp, zbuf[RCVMAX];

	if ( len == 0 ) {	/* 残りの受信データの取り込み */
		if ( sp->remlen<=0 ) {
			return;
		}
		len = sp->remlen;
		memcpy(zbuf, sp->rcvbuf + sp->remp, len);
		bufp = zbuf;
		sp->remlen = 0;
	}
	else {
		bufp = buf;
	}

	dp = sp->rcvbuf + sp->rcvlen;
	for ( i = 0; i < len; i++, bufp++ ) {
		rc = *bufp;
		if ( (rc == 'S' && memcmp(&bufp[i], "S4", 2) == 0) || 
			 (rc == 'K' && memcmp(&bufp[i], "K3", 2) == 0) ||
			 (rc == 'R' && memcmp(&bufp[i], "R3", 2) == 0) ||
			 (rc == 'R' && memcmp(&bufp[i], "R4", 2) == 0) ||
			 (rc == 'E' && memcmp(&bufp[i], "E3", 2) == 0) ||
			 (rc == 'E' && memcmp(&bufp[i], "E4", 2) == 0) ) {
			dp = sp->rcvbuf; 
			sp->rcvlen = 0;
			sp->staflg = S_STX;
			*dp++ = rc; 
			bufp++;
			rc = *bufp; 
			*dp++ = rc;
			i++;
			sp->rcvlen += 2;
			continue;
		}
		if ( sp->staflg != S_STX ) {
			continue;
		}
		if ( rc == '\n' ) {
			sp->staflg = S_ETX;
			*dp++ = rc; 
			sp->rcvlen++;
			i++;	/* 残り受信データのセット */
			if ( i < len ) {
				if ( sp->rcvlen+len-i <= RCVMAX ) {
					sp->remp = sp->rcvlen;
					sp->remlen = len - i;
					bufp++;
					memcpy(dp, bufp, sp->remlen);
				}
				else {
					sp->staflg = E_BUFFOV;
				}
			}
			break;
		}
		if ( sp->rcvlen < RCVMAX ) {
			*dp++ = rc; 
			sp->rcvlen++;
		}
		else {
			sp->staflg = E_BUFFOV; 
			break;
		}
	}
}

/**
* @fn bool check_time_setting_cp(char *LastTime)
* @brief 一斉時刻合わせチェック（共通プロトコル用）
* @param[in,out] LastTime 前回一斉時刻合わせ日時
* @return true 実施対象
* @return false 実施対象外
*/
bool check_time_setting_cp(char *LastTime) {
	bool Ret = false;
	char bufNow[20];
	char bufConf[20];
	char bufDate[20];
	char bufTime[10];

	if ( _comsvCache._comsvSet.timeset_time[0] == 0 ) {
		// 設定なし
		return Ret;
	}

	time_str(get_time(), bufDate, bufTime, 1);
	if ( *LastTime == 0 ) {
		// 初回起動時
		sprintf(LastTime, "%s %s", bufDate, bufTime);
		//printf("初回起動時 : [%s]\n",LastTime);
		//printf("設定日時   : [%s %s   ]\n",bufDate, _comsvCache._comsvSet.timeset_time);
		return Ret;
	}

	// 現在日時
	sprintf(bufNow, "%s %s", bufDate, bufTime);
	// 設定日時
	sprintf(bufConf, "%s %.5s   ", bufDate, _comsvCache._comsvSet.timeset_time);

	if ( strcmp(LastTime, bufConf) < 0 && strcmp(bufConf, bufNow) < 0 ) {
		// 前回一斉時刻合わせ日時 < 設定日時 かつ 設定日時 < 現在日時
		// 前回一斉時刻合わせ日時 に 現在日時 をセット
		//printf("一斉時刻合わせ : [%s]<[%s]<[%s]\n",LastTime,bufConf,bufNow);
		strcpy(LastTime, bufNow);
		Ret = true;
	}

	return Ret;
}
