/**
* @file comsv_stream.c
* @brief 新通信用処理関連
* @author Y.Takamura
* @date 2018/10/01
* @details 新通信用の処理を行う
*/

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/time.h>
#include "ntss_comsv.h"
#include "ntss_packet_manage.h"
#include "ntss_nkk_comm.h"
#include "ntss_devicecap_conf.h"

/**
* @fn void *comsv_stream(void *ptr)
* @brief 新通信用スレッド処理
* @param[in,out] ptr 装置制御情報
* @return void* 
*/
void *comsv_stream(void *ptr) {
	struct connect_socket *conSock = (struct connect_socket *) ptr;
	fd_set fd;
	pthread_t thr_rep;
	// #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 start
	pthread_t thr_unregi;
	// #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 end
	// #11629 2025.05.26 add 「/tmp」以外の治療済透析情報を「/tmp」に復元する TDC米沢 start
	pthread_t thr_restore_rep;
	// #11629 2025.05.26 add 「/tmp」以外の治療済透析情報を「/tmp」に復元する TDC米沢 end
	pthread_attr_t thread_attr;
	struct timeval seltime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    struct timespec myTime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	int ret;
	int i, j;
	int val = 1;
	u_char logMsg[256], logSubMsg[64];
	// #8266 2023.03.20 mod バッファサイズを変更 TDC高村 start
	//u_char wrk[RCVMAX*2];
	//u_char buf[RCVMAX*2];
	u_char wrk[RCVMAX];
	u_char buf[RCVMAX];
	// #8266 2023.03.20 mod バッファサイズを変更 TDC高村 end
	struct sockaddr_in serv;
	socklen_t len;
	u_char *ip, ips[32];
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long now = get_time();
	time_t now = get_time();
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	char fpath[64];
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
	//char TimeSet_LastTime[20] = "";	// 前回一斉時刻合わせ日時
	char TimeSet_LastTime[20] = {0};	// 前回一斉時刻合わせ日時
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
	unsigned char ord_str[10];
	// mod AWSとDEの通信断からの復旧 高 start
	struct NTSS_PACKET_INFORMATION *pInfo = NULL;
	int ii;
	// mod AWSとDEの通信断からの復旧 高 end
	// add 強制オフライン 高 start
	int max;
	unsigned char dat[1000];
	// add 強制オフライン 高 end
	extern bool comsv_communication(struct connect_socket *conSock);
	extern void comsv_socket_error(struct connect_socket *conSock);
	extern int check_is_target_device(u_char *commFormat, u_char *deviceCode, u_char *ip, struct scn_data_fm *scn);
	extern bool check_time_setting(char *LastTime);
	// add FNSI-バグ 通信サーバ 高 start
	int matchMst;
	int ordno_state;
	short mon_sta_bak;
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
	//unsigned char tDeviceType[3];   ///< 装置の型式コード
	//unsigned char tDevid[8];		///< 装置の識別番号
	unsigned char tDeviceType[5];   ///< 装置の型式コード
	unsigned char tDevid[10];		///< 装置の識別番号
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
	long tDev_no = 0;			   ///< 装置Ｎｏ
	char str1[512];
	// add FNSI-バグ 通信サーバ 高 end

	conSock->running = true;
	// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知(初期値true) TDC片口 start
	conSock->is_update_comm_fail_from_main = true;
	int lastResultUpdateCommFail = 0;
	// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知(初期値true) TDC片口 end

	// パケット管理情報クリア
	memset(&packetInfoList[conSock->thread_no], 0, sizeof(struct NTSS_PACKET_INFORMATION));

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	sprintf(logMsg, "通信スレッドNEW[%d] : 起動", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	
	// add 強制オフライン 高 start
	conSock->scn.force_offline_wait = _comsvCache._comsvSet.offline_start_time;
	conSock->scn.force_offline_time = 0;
	conSock->scn.force_dial_time = -1;
	
	if ( conSock->scn.mon_sta & 1) {
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

	// 収集対象か否かをチェックする処理
	for ( ; ; usleep(100000) ) {

		if ( conSock->running == false ) {
			break;
		}
		// add FNSI-バグ 通信サーバ 高 start
		if( conSock->scn.conflg == 0 && conSock->scn.force_flg == 1 ) {
			// NTSSパケット管理情報に必要な情報をセットする
			pInfo = &packetInfoList[conSock->thread_no];
			memcpy(pInfo->cDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
			pInfo->cDeviceFormat = conSock->scn.devsw;
			memcpy(pInfo->cDeviceNo, conSock->scn.devid, sizeof(conSock->scn.devid));
			pInfo->cCommType = NTSS_COMM_TYPE_NEW;
			pInfo->sourceAddr = inet_addr(conSock->scn.ip_addr);
			pInfo->isConnected = 0x01;
			pInfo->dev_no = conSock->scn.dev_no;
			pInfo->force_flg = conSock->scn.force_flg;
			pInfo->conflg = conSock->scn.conflg;
			tDev_no = conSock->scn.dev_no;
            // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//memcpy(tDeviceType, conSock->scn.deviceType, sizeof(tDeviceType));
			//memcpy(tDevid, conSock->scn.devid, sizeof(tDevid));
            memcpy(tDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
            memcpy(tDevid, conSock->scn.devid, sizeof(conSock->scn.devid));
            // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
			// 工程通知を依頼（モニタ受信するまで工程を準備回収として扱う）
			// mod FNSI-バグ 通信サーバ 高 start
			if(conSock->scn.mon_sta & 1) {
				pInfo->nProcess[0] = 11;
			}
			else {
			// mod FNSI-バグ 通信サーバ 高 end
				pInfo->nProcess[0] = 7;
			}
			pInfo->isNeedSendProcess = 0x01;
			pInfo->nMoniDataSize = 0;
			
			break;
		}
		// add FNSI-バグ 通信サーバ 高 end
		if ( get_time() > now + _comsvCache._comsvSet.device_timeout ) {
			// タイムアウト
			sprintf(logMsg, "通信スレッドNEW[%d] : 通信タイムアウト 1", conSock->thread_no);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			close(conSock->accept_socket);
			conSock->accept_socket = (-1);
			conSock->running = false;
			break;
		}

		// ノンブロッキングソケットに変更
		ioctl(conSock->accept_socket, FIONBIO, &val);
		// fd_set初期化 
		FD_ZERO(&fd);
		// fd設定
		FD_SET(conSock->accept_socket, &fd);

		// データ受信待ち
		seltime.tv_sec = 2;
		seltime.tv_usec = 0;
		if ( select(conSock->accept_socket + 1, &fd, NULL, NULL, &seltime) <= 0 ) {
			continue;
		}

		// 受信チェック
		if ( FD_ISSET(conSock->accept_socket, &fd) == 0 ) {
			continue;
		}

		now = get_time();

		// 受信データの読み込
		ret = read(conSock->accept_socket, buf, sizeof(buf));
		if ( ret <= 0 ) {
			sprintf(logMsg, "通信スレッドNEW[%d] : データリードエラー ", conSock->thread_no);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			close(conSock->accept_socket);
			conSock->accept_socket = (-1);
			conSock->running = false;
			break;
		}
		len = sizeof(serv);
		if ( getpeername(conSock->accept_socket, (struct sockaddr *)&serv, &len) < 0 ) {
			sprintf(logMsg, "通信スレッドNEW[%d] : getpeernameエラー ", conSock->thread_no);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			close(conSock->accept_socket);
			conSock->accept_socket = (-1);
			conSock->running = false;
			break;
		}

		ip = inet_ntoa(serv.sin_addr);
		strcpy(ips,ip);

		// 電文のエスケープデータを置換
		for ( i = 0, j = 0; i < ret; i++, j++ ) {
			if ( buf[i] == 0x10 && buf[i+1] == 0x12 ) {
				// 1012 -> 02
				wrk[j] = 0x02;
				i++;
			}
			else if ( buf[i] == 0x10 && buf[i+1] == 0x13 ) {
				// 1013 -> 03
				wrk[j] = 0x03;
				i++;
			}
			else if ( buf[i] == 0x10 && buf[i+1] == 0x10 ) {
				// 1010 -> 10
				wrk[j] = buf[i+1];
				i++;
			}
			else {
				wrk[j] = buf[i];
			}
		}

		snprintf(logSubMsg, 9, "%s", &wrk[1]);
		sprintf(logMsg, "通信スレッドNEW[%d] : 装置=[%s] IPアドレス=[%s] cmd=[%02x]", conSock->thread_no, logSubMsg, ips, wrk[10]);
		LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		
		// コマンドコードが 61 から 68 の間
		if ( (wrk[10] & 0xff) >= 0x61 && (wrk[10] & 0xff) <= 0x68 ) {
			
			// 機器マスタとの突き合わせ			
			i = check_is_target_device(&wrk[1], &wrk[2], ips, &(conSock->scn));
			if ( i < 0 ) {
				// 一致するマスタがなかったら閉じる
				sprintf(logMsg, "通信スレッドNEW[%d] : マスタ一致対象装置なし", conSock->thread_no);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				close(conSock->accept_socket);
				conSock->accept_socket = (-1);
				conSock->running = false;
				break;				
			}
			
			// add FNSI-バグ 通信サーバ 高 start
			// 5s
			struct timespec timeReqSleep = {5, 0};
			while (nanosleep(&timeReqSleep, &timeReqSleep) == -1 && errno == EINTR) {}
			// add FNSI-バグ 通信サーバ 高 end
			
			// add FNSI-バグ 通信サーバ 高 start
			matchMst = i;
			j = client_device_key_search(conSock->scn.dev_no, wrk[1], &wrk[2], conSock->scn.deviceType);
			if(j >= 0) {
				if(con_sock[j].scn.conflg == 0 && con_sock[j].scn.force_flg == 1) {
					sprintf(logMsg, "通信スレッドNEW[%d] : 強制オフライン中", con_sock[j].thread_no);
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					con_sock[j].scn.sock_id = conSock->accept_socket;
					con_sock[j].scn.conflg = 2;
					strcpy(con_sock[j].scn.ip_addr, ips);
					con_sock[j].scn.staflg = S_WAIT;
					con_sock[j].scn.err_ltime = 0;
					comsv_rcvset(&(con_sock[j].scn), buf, ret);
					packetInfoList[con_sock[j].thread_no].sourceAddr = inet_addr(con_sock[j].scn.ip_addr);
					conSock->running = false;
					break;
				}
			}
			// add FNSI-バグ 通信サーバ 高 end
			// 対応付け
			conSock->scn.sock_id = conSock->accept_socket;
			conSock->scn.conflg = 2;
			strcpy(conSock->scn.ip_addr, ips);
			conSock->scn.commType = NTSS_COMM_TYPE_NEW;
			conSock->scn.devsw = wrk[1];
			memcpy(conSock->scn.devid, &wrk[2], 7);
			conSock->scn.devid[7] = ' ';
			conSock->scn.staflg = S_WAIT;
			conSock->scn.err_ltime = 0;
			comsv_rcvset(&(conSock->scn), buf, ret);

			if ( conSock->scn.dev_no != 0 ) {
				// 作業データ用装置番号フォルダ作成
				comsv_work_mkdir_dev(conSock->scn.dev_no);

				// 装置状態管理データを取得
				comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
				// modi FNSI-バグ 通信サーバ 高 start
				// i = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
				ii = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
				// modi FNSI-バグ 通信サーバ 高 end
				printf("comsv_rest_get_dev = [%d]\n", ii);
				// #8266 2023.03.24 mod 前回取得データを削除しない修正に伴う対応 TDC高村 start
				//i = comsv_json_dev_state(fpath, 1, &(conSock->scn));
				i = comsv_json_dev_state(fpath, 2, &(conSock->scn));
				// #8266 2023.03.24 mod 前回取得データを削除しない修正に伴う対応 TDC高村 end
				printf("comsv_json_dev_state = [%d]\n", i);
				
				// add FNSI-バグ 通信サーバ 高 start
				conSock->scn.force_flg = 0;
				if( conSock->scn.treatment == 9  && conSock->scn.ord_no != 0 && (conSock->scn.ord_no == conSock->scn.next_ord_no)) {
					conSock->scn.force_flg = 1;
				}
				
				if(conSock->scn.force_flg == 1 && conSock->scn.mon_sta & 1) {
					// 既に運転中
					conSock->scn.force_offline_time = conSock->scn.dial_start_date;
					// 透析時間
					if ( _comsvCache._comsvSet.is_offline_auto_end == '1' ) {
					// 自動終了有り
					conSock->scn.force_dial_time = conSock->scn.dial_time;
					if ( conSock->scn.force_dial_time <= 0 ) conSock->scn.force_dial_time = 240;	// 4時間
						conSock->scn.force_dial_time *= 60; // 分 → 秒
					}
					conSock->scn.force_offline_wait = 0;
				}
				
				if(conSock->scn.force_flg == 0) {

					conSock->scn.mon_sta &= ~0x01;
					// #11925 2025.06.13 del サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 start
					// if( ii == 0) {
					// #11925 2025.06.13 del サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 end
						if(conSock->scn.rcvbuf[10] & 1) {
							if((conSock->scn.dial_start_date != 0 && get_time() > (conSock->scn.dial_start_date + (_comsvCache._comsvSet.treatment_judge_time + conSock->scn.dial_time) * 60))
							 || (conSock->scn.dial_start_date != 0 && conSock->scn.dial_end_date != 0)
							 || (conSock->scn.dial_start_date == 0)) {
								sprintf(str1, "[gs debug] : ord_no = %ld, next_ord_no = %ld, dial_start_date = %ld, dial_end_date = %ld, (treatment_judge_time + dial_time) * 60= %d, get_time()= %ld", 
									conSock->scn.ord_no, conSock->scn.next_ord_no, conSock->scn.dial_start_date, conSock->scn.dial_end_date,
									(_comsvCache._comsvSet.treatment_judge_time + conSock->scn.dial_time) * 60, get_time());
								LogOutputs(NTSS_LOG_INFO, str1, 0, conSock->scn.deviceType, conSock->scn.devid);
								 
								 conSock->scn.mon_sta |= 0x01;
								 
								 if(conSock->scn.ord_no != 0) {
									// 治療状況データを取得
									comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_ORDNO, fpath);
									i = comsv_rest_get_ordno_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.ord_no, fpath);
									printf("comsv_rest_get_ordno_state = [%d]\n", i);
									i = comsv_json_ordno_state(fpath, &ordno_state);
									printf("comsv_json_ordno_state = [%d]\n", i);
									
									if(ordno_state == 1 || ordno_state == 2) {
										comsv_fail_cond_send_cancel(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.ord_no);
									}
								}
								 
								if(conSock->scn.dial_start_date != 0 && conSock->scn.dial_end_date == 0) {
									// current close 
									conSock->scn.dial_end_date = get_time();	  // 透析終了日時
									// 装置状態管理の日付データを更新する
									i = comsv_rest_put_dev_date(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 
																3, 0, conSock->scn.dial_end_date);
									printf("comsv_rest_put_dev_date = [%d]\n", i);
									if(conSock->scn.ord_no != 0) {
										i = comsv_rest_put_ord_date(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 
																	conSock->scn.ord_no, 2, 0, 4, conSock->scn.dial_end_date);
										printf("comsv_rest_put_ord_date = [%d]\n", i);
										comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_MONI, fpath);
										i = comsv_json_ord_make_moni(fpath, packetInfoList[conSock->thread_no].cMoniData+12, packetInfoList[conSock->thread_no].cCommType);
										printf("comsv_json_ord_make_moni = [%d]\n", i);
										i = comsv_rest_post_ord_moni(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.ord_no, fpath);
										printf("comsv_rest_post_ord_moni = [%d]\n", i);
									}
								}
								
								conSock->scn.dial_start_date = get_time();	// 透析開始日時
								// ？？？？患者の場合
								// #10844 2024.07.29 mod DB高負荷状態の時に????患者が複数生成される TDC高村 start
								/*
								conSock->scn.reqflg[C_KANSRD] = 1;			// 警報監視状態読出要求
								conSock->scn.kansrd_flg = 1;				  // 警報監視除隊フラグ（0:装置側から任意,1:運転開始時）
								conSock->scn.reqflg[C_NEXTPAT] = 1;		   // 次患者情報を要求
								conSock->scn.next_pat_send = 0;			   // 次患者送信（0:タイミング,1:イベント）
								conSock->scn.cond_send_flg = 1;
								// ホスト報知監視開始待ち時間の初期化
								comsv_host_watch_init(conSock->thread_no);
								// 治療情報を登録（患者未登録運転）する
								i = comsv_rest_put_unregistered(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 1, 3, conSock->scn.dial_start_date);
								printf("comsv_rest_put_unregistered = [%d]\n", i);
								// 装置状態管理データを取得
								comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
								i = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
								printf("comsv_rest_get_dev = [%d]\n", i);
								i = comsv_json_dev_state(fpath, 1, &(conSock->scn));
								printf("comsv_json_dev_state = [%d]\n", i);
								// ホスト報知定義の取得・設定
								i = comsv_host_watch(conSock->thread_no, &(conSock->scn));
								printf("comsv_host_watch = [%d]\n", i);
								*/
								if ( conSock->scn.thread_unregistered == 0 ) {
                                    // #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start               
                                    if ( checkMachineIsVa(&(conSock->scn)) > 0 ) {
                                        // 画像転送可能な装置の場合
                                        // 画像データ削除を要求
                                        sprintf(logMsg, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（患者未登録運転時）", conSock->thread_no);
                                        LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
                                        conSock->scn.reqflg[C_DELETE] = 1;
                                    }
                                    // #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
									// スレッド属性オブジェクトの初期化
									pthread_attr_init(&thread_attr);
									// スレッド切り離し状態属性の設定
									pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
									// 患者未登録運転スレッド処理
									conSock->scn.thread_unregistered_no = conSock->thread_no;   // スレッド番号
									conSock->scn.thread_unregistered = 1;					   // スレッド処理
									conSock->scn.thread_unregistered_sta = 1;				   // 装置ステータス
									pthread_create(&thr_unregi, &thread_attr, comsv_thread_unregistered, &(conSock->scn));
								}
								else {
									// 既に実行中
									sprintf(logMsg, "患者未登録運転スレッド処理が既に実行中 [%d][%d]", conSock->scn.thread_unregistered, conSock->scn.thread_unregistered_sta);
									LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
								}
								// #10844 2024.07.29 mod DB高負荷状態の時に????患者が複数生成される TDC高村 end
							}
							else {
								if(conSock->scn.dial_start_date != 0 && conSock->scn.dial_end_date == 0) {
									conSock->scn.mon_sta |= 0x01;
								}
							}
						}
						else {
							conSock->scn.mon_sta &= ~0x01;
							// current close 
							// 治療情報の日付データを更新する
							if(conSock->scn.dial_start_date != 0 && conSock->scn.dial_end_date == 0) {
								conSock->scn.dial_end_date = get_time();	  // 透析終了日時
								// 装置状態管理の日付データを更新する
								i = comsv_rest_put_dev_date(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 3, 0, conSock->scn.dial_end_date);
								printf("comsv_rest_put_dev_date = [%d]\n", i);
								if(conSock->scn.ord_no != 0) {
									i = comsv_rest_put_ord_date(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 
																conSock->scn.ord_no, 2, 0, 4, conSock->scn.dial_end_date);
									printf("comsv_rest_put_ord_date = [%d]\n", i);
									comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_MONI, fpath);
									i = comsv_json_ord_make_moni(fpath, packetInfoList[conSock->thread_no].cMoniData+12, packetInfoList[conSock->thread_no].cCommType);
									printf("comsv_json_ord_make_moni = [%d]\n", i);
									i = comsv_rest_post_ord_moni(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.ord_no, fpath);
									printf("comsv_rest_post_ord_moni = [%d]\n", i);
								}
							}
							// 次患者更新を行う
							i = comsv_rest_post_web_api(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 1);
							printf("comsv_rest_post_web_api = [%d]\n", i);
						}
					// #11925 2025.06.13 del サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 start
					// }
					// #11925 2025.06.13 del サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 end
				}
				// add FNSI-バグ 通信サーバ 高 end

				// 初回起動時の装置ステータスをセット
				conSock->scn.first_sta = conSock->scn.mon_sta;

				// 装置オプション読出を要求
				conSock->scn.reqflg[C_OPTRD] = 1;
				// #11520 2025.02.06 mod 次回透析患者情報転送を必ず要求する TDC高村 start
				// if ( conSock->scn.next_ord_no > 0 && !(conSock->scn.mon_sta & 1) ) {
				//	 // 運転中以外なら次患者情報を要求
				//	 conSock->scn.reqflg[C_NEXTPAT] = 1;
				// }
				conSock->scn.reqflg[C_NEXTPAT] = 1;
				// #11520 2025.02.06 mod 次回透析患者情報転送を必ず要求する TDC高村 end
                // #12301 2025.10.28 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
				// if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' ) {
				//     // 100NX以前の装置は処理しない
				//     i = ntss_mst_type_chack(conSock->scn.deviceType);
				//     // #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 start
				//     //if ( i > 0 ) {
				//     if ( i > 0 && getMachineIsVa(conSock->scn.dev_idx) ) {
				//     // #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 end
				//         // FTP画像削除フラグ（1:接続確立）
				//         conSock->scn.ftp_clear_flg = 1;
				//     }
				// }
                // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start               
                // if ( conSock->scn.cond_send_flg == 0 && conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' ) {
                //     // 条件未送信で装置が’I’,’J’以外の場合
				//     // 100NX以前の装置は処理しない
				//     i = ntss_mst_type_chack(conSock->scn.deviceType);
				//     if ( i > 0 && getMachineIsVa(conSock->scn.dev_idx) ) {
	            //         // 画像データ削除を要求
				//         sprintf(logMsg, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（DE-装置接続確立時）", conSock->thread_no);
				//         LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	            //         conSock->scn.reqflg[C_DELETE] = 1;
				//     }
				// }
                // // #12301 2025.10.28 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
                if ( conSock->scn.cond_send_flg == 0 && checkMachineIsVa(&(conSock->scn)) > 0 ) {
                    // 画像転送可能な装置の場合
	                // 画像データ削除を要求
					sprintf(logMsg, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（DE-装置接続確立時）", conSock->thread_no);
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	                conSock->scn.reqflg[C_DELETE] = 1;
                }
                // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
				if ( configParam.lcdDataCash == 1 ) {
					// 仮想端末キャッシュ更新を要求
					conSock->event[9] = 0x01;
				}
				// お知らせ通知の初期化
				conSock->scn.alert_no = 0;
				for ( i = 0; i < ALERT_NUM; i++ ) conSock->scn.alert_time[i] = -1;
			}

			// NTSSパケット管理情報に必要な情報をセットする
			pInfo = &packetInfoList[conSock->thread_no];
			memcpy(pInfo->cDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
			pInfo->cDeviceFormat = conSock->scn.devsw;
			memcpy(pInfo->cDeviceNo, conSock->scn.devid, sizeof(conSock->scn.devid));
			pInfo->cCommType = NTSS_COMM_TYPE_NEW;
			pInfo->sourceAddr = inet_addr(conSock->scn.ip_addr);
			pInfo->isConnected = 0x01;
			// 工程通知を依頼（モニタ受信するまで工程を準備回収として扱う）
			// mod FNSI-バグ 通信サーバ 高 start
			if(conSock->scn.force_flg == 1 && conSock->scn.mon_sta & 1) {
				pInfo->nProcess[0] = 11;
			}
			else {
			// mod FNSI-バグ 通信サーバ 高 end
				pInfo->nProcess[0] = 7;
			}
			pInfo->isNeedSendProcess = 0x01;
			pInfo->nMoniDataSize = 0;
			// 自己診断実施日時をファイルから取得
			getNTSSPacketInfoMainteDate(devicecapConf.cMstFolder, pInfo);
			// ホスト報知監視設定初期化
			initNTSSHostWatchConf(pInfo);
			
			// add FNSI-バグ 通信サーバ 高 start
            // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//memcpy(tDeviceType, conSock->scn.deviceType, sizeof(tDeviceType));
			//memcpy(tDevid, conSock->scn.devid, sizeof(tDevid));
			memcpy(tDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
			memcpy(tDevid, conSock->scn.devid, sizeof(conSock->scn.devid));
            // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
			tDev_no = conSock->scn.dev_no;
			// add FNSI-バグ 通信サーバ 高 end

			// mod FNSI-バグ 通信サーバ 高 start
			// if ( ret == 1 ) {
			if ( matchMst == 1 ) {
			// mod FNSI-バグ 通信サーバ 高 end
				// 装置情報作成モード
                // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
				//gettimeofday(&seltime, NULL);
                clock_gettime(CLOCK_REALTIME, &myTime);
                seltime.tv_sec = myTime.tv_sec;
                seltime.tv_usec = myTime.tv_nsec / 1000;
                // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
				// 新しい装置情報の登録用ファイルを作成
				outputNTSSCreateMachineInfo( devicecapConf.cFacilityCode, devicecapConf.nDeviceEdgeNo, pInfo, seltime );
				if ( conSock->scn.dev_idx == 0 ) {
					// マスタに存在しない場合、ファイル出力しないようにクリア
					pInfo->sourceAddr = 0;
				}
			}

			break;				
		}
	}
	// 接続対象かどうかのチェックと確立を完了

	if ( conSock->running == false ) {
		// 終了
		sprintf(logMsg, "通信スレッドNEW[%d] : 終了 1", conSock->thread_no);
		LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		conSock->using = false;
		// add FNSI-バグ 通信サーバ 高 start
		memset(conSock->event, '\0', sizeof(conSock->event));
		// add FNSI-バグ 通信サーバ 高 end
		pthread_exit((void *)0); // スレッド終了
	}

	// #11629 2025.05.26 add 装置接続時に治療済透析情報を「/tmp」に復元する TDC米沢 start
	// 透析番号チェック
	if( conSock->scn.ord_no > 0 )
	{
		// 透析番号が有効

        // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
        /*
		// 装置型式チェック
		if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' ) {
			// 100NX以前の装置は処理しない

			// 装置型式マスタチェック、画像転送許可チェック
			ret = ntss_mst_type_chack(conSock->scn.deviceType);
			if ( ret > 0 && getMachineIsVa(conSock->scn.dev_idx) ) {
				// 画像転送設定が有効な場合

				// スレッド属性オブジェクトの初期化
				pthread_attr_init(&thread_attr);
				// スレッド切り離し状態属性の設定
				pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
				// 治療済透析情報を復元するスレッド処理
				pthread_create(
					&thr_restore_rep,
					&thread_attr,
					comsv_thread_restoration_treated_dialysis_report_files,
					&(conSock->scn)
				);
			}
		}
        */
        if ( checkMachineIsVa(&(conSock->scn)) > 0 ) {
        	// 画像転送可能な装置の場合
			// スレッド属性オブジェクトの初期化
			pthread_attr_init(&thread_attr);
			// スレッド切り離し状態属性の設定
			pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
			// 治療済透析情報を復元するスレッド処理
			pthread_create(
				&thr_restore_rep,
				&thread_attr,
				comsv_thread_restoration_treated_dialysis_report_files,
				&(conSock->scn)
			);
        }
        // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
	}
	// #11629 2025.05.26 add 装置接続時に治療済透析情報を「/tmp」に復元する TDC米沢 end

	for ( ; ; usleep(100000) ) {

		if ( conSock->running == false ) {
			comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
			strcpy(str1, "[gs debug] : conSock->running == false return error!");
			LogOutputs(NTSS_LOG_INFO, str1, 0, conSock->scn.deviceType, conSock->scn.devid);
			break;
		}

		// マスタ更新チェック
		if ( conSock->mst_reload == true ) {
			sprintf(logMsg, "通信スレッドNEW[%d] : マスタ更新", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			i = conSock->scn.dev_idx;
			if ( check_is_target_device(&(conSock->scn.devsw), &(conSock->scn.devid[0]), conSock->scn.ip_addr, &(conSock->scn)) != 0 ) {
				sprintf(logMsg, "通信スレッドNEW[%d] : マスタ一致対象装置なし", conSock->thread_no);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
				comsv_socket_error(conSock);
				break;
			}
			sprintf(logMsg, "通信スレッドNEW[%d] : マスタ更新完了", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			conSock->mst_reload = false;
			pInfo = &packetInfoList[conSock->thread_no];
			memcpy(pInfo->cDeviceNo, conSock->scn.devid, sizeof(conSock->scn.devid));
			// add FNSI-バグ 通信サーバ 高 start
			memcpy(pInfo->cDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
			memcpy(tDeviceType, conSock->scn.deviceType, sizeof(tDeviceType));
			memcpy(tDevid, conSock->scn.devid, sizeof(tDevid));
			tDev_no = conSock->scn.dev_no;
			// add FNSI-バグ 通信サーバ 高 end
			if ( pInfo->sourceAddr == 0 && conSock->scn.ip_addr ) {
				// 空の場合、再セットする
				pInfo->sourceAddr = inet_addr(conSock->scn.ip_addr);
				if ( i == 0 && conSock->scn.dev_no != 0 ) {
					// 作業データ用装置番号フォルダ作成
					comsv_work_mkdir_dev(conSock->scn.dev_no);
					// 装置状態管理データを取得
					comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
					i = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
					printf("comsv_rest_get_dev = [%d]\n", i);
					i = comsv_json_dev_state(fpath, 1, &(conSock->scn));
					printf("comsv_json_dev_state = [%d]\n", i);
					// 装置オプション読出を要求
					conSock->scn.reqflg[C_OPTRD] = 1;
					// #11520 2025.02.06 mod 次回透析患者情報転送を必ず要求する TDC高村 start
					// if ( conSock->scn.next_ord_no > 0 && !(conSock->scn.mon_sta & 1) ) {
					//	 // 運転中以外なら次患者情報を要求
					//	 conSock->scn.reqflg[C_NEXTPAT] = 1;
					// }
					conSock->scn.reqflg[C_NEXTPAT] = 1;
					// #11520 2025.02.06 mod 次回透析患者情報転送を必ず要求する TDC高村 end
                    // #12301 2025.10.28 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
                    // if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' ) {
                    //     // 100NX以前の装置は処理しない
                    //     i = ntss_mst_type_chack(conSock->scn.deviceType);
                    //     // #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 start
                    //     //if ( i > 0 ) {
                    //     if ( i > 0 && getMachineIsVa(conSock->scn.dev_idx) ) {
                    //     // #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 end
                    //         // FTP画像削除フラグ（1:接続確立）
                    //         conSock->scn.ftp_clear_flg = 1;
                    //     }
                    // }
                    // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
                    // if ( conSock->scn.cond_send_flg == 0 && conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' ) {
                    //     // 条件未送信で装置が’I’,’J’以外の場合
                    //     // 100NX以前の装置は処理しない
                    //     i = ntss_mst_type_chack(conSock->scn.deviceType);
                    //     if ( i > 0 && getMachineIsVa(conSock->scn.dev_idx) ) {
                    //         // 画像データ削除を要求
                    //         sprintf(logMsg, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（DE-装置接続確立時）", conSock->thread_no);
                    //         LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
                    //         conSock->scn.reqflg[C_DELETE] = 1;
                    //     }
                    // }
                    // // #12301 2025.10.28 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
                    if ( conSock->scn.cond_send_flg == 0 && checkMachineIsVa(&(conSock->scn)) > 0 ) {
                        // 画像転送可能な装置の場合
                        // 画像データ削除を要求
                        sprintf(logMsg, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（DE-装置接続確立時）", conSock->thread_no);
                        LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
                        conSock->scn.reqflg[C_DELETE] = 1;
                    }
                    // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
					if ( configParam.lcdDataCash == 1 ) {
						// 仮想端末キャッシュ更新を要求
						conSock->event[9] = 0x01;
					}
					// お知らせ通知の初期化
					conSock->scn.alert_no = 0;
					for ( i = 0; i < ALERT_NUM; i++ ) conSock->scn.alert_time[i] = -1;
				}
			}
		}

		// 一斉時刻合わせチェック
		if ( check_time_setting(TimeSet_LastTime) == true ) {
			printf("通信スレッドNEW[%d] : 一斉時刻合わせ\n", conSock->thread_no);
			// 時計設定を要求
			conSock->scn.reqflg[C_CLOCK] = 1;
		}

		if ( conSock->scn.dev_idx && getCreateMachineInfoMode() == false ) {
			// 条件送信処理完了処理
			if ( conSock->scn.cond_send_complete == 1 ) {
				conSock->scn.cond_send_complete = 0;
				if ( configParam.lcdDataCash == 1 ) {
					// 仮想端末キャッシュ更新を要求
					conSock->event[9] = 0x01;
				}
			} 

			// イベント有無チェック
			for ( i = 0; i < EVENT_MAX; i++ ) {
				if ( conSock->event[i] == 0x01 ) {
					conSock->event[i] = 0x00;
					if ( i == 0 ) {
						// 設定値書込を要求（設定値読込+書込）
						if ( !(conSock->scn.mon_sta & 1) ) {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（条件送信）", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
							
							// add 強制オフライン 高 start
							// 装置状態管理データを取得
							comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
							i = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
							printf("comsv_rest_get_dev = [%d]\n", i);
							// JSON文字列から条件送信データに格納する
							// mod FNSI-バグ 通信サーバ #9917 高 start
							// max = (SET2_NUM * 2);
							if ( conSock->scn.devsw == 'I' || conSock->scn.devsw == 'J' ) {
								max = (SET1_NUM * 2);
							}
							else if ( conSock->scn.devsw == 'M' || conSock->scn.devsw == 'N' ) {
								max = (SET2_NUM * 2);
							}
							else {
								max = (SET3_NUM * 2);
							}
							// mod FNSI-バグ 通信サーバ #9917 高 end
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
								
								if( conSock->scn.conflg != 0) {
									conSock->scn.next_pat_send = 0;	 // 次患者送信（0:タイミング,1:イベント）
									conSock->scn.cond_read_flg = 1;	 // 設定値読出フラグ（1:条件送信時）
									conSock->scn.reqflg[C_NEXTPAT] = 1; // 次患者情報を要求
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
								// add AWSとDEの通信断からの復旧 高 start
								conSock->scn.current_mon_sta[1] = conSock->scn.current_mon_sta[0]; 
								conSock->scn.current_mon_sta[0] = COMM_STA1;
								
								if( conSock->scn.conflg == 0) {
									conSock->scn.cond_send_flg = 1;
									// スレッド属性オブジェクトの初期化
									pthread_attr_init(&thread_attr);
									// スレッド切り離し状態属性の設定
									pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
									// 条件送信完了時の一連スレッド処理
									pthread_create(&thr_rep, &thread_attr, comsv_thread_rest_cond, &(conSock->scn));
								}
								// add AWSとDEの通信断からの復旧 高 end
							}
							else {
							// add 強制オフライン 高 end
								// 透析中は処理しない
								conSock->scn.next_pat_send = 0;		// 次患者送信（0:タイミング,1:イベント）
								conSock->scn.cond_read_flg = 1;		// 設定値読出フラグ（1:条件送信時）
								conSock->scn.reqflg[C_NEXTPAT] = 1;	// 次患者情報を要求
								conSock->scn.reqflg[C_JSETRD] = 1;	// 条件データ読出要求
                                // #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start               
                                if ( checkMachineIsVa(&(conSock->scn)) > 0 ) {
                                    // 画像転送可能な装置の場合
                                    // 画像データ削除を要求
                                    sprintf(logMsg, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（条件送信時）", conSock->thread_no);
                                    LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
                                    conSock->scn.reqflg[C_DELETE] = 1;
                                }
                                // #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
								if ( conSock->scn.dial_start_date && conSock->scn.dial_end_date ) {
									// 次患者条件送信
									// 現患者クリアを行う
									i = comsv_rest_post_web_api(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 0);
									printf("comsv_rest_post_web_api = [%d]\n", i);
									// 状況に応じた装置制御データのクリア
									comsv_clear(4, &(conSock->scn));
									if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' ) {
										// 画像転送ファイル削除
										// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
										// comsv_bmp_remove(conSock->scn.dev_no);
										comsv_bmp_remove(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid);
										// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
									}
								}
								else {
									// 状況に応じた装置制御データのクリア
									comsv_clear(0, &(conSock->scn));
								}
							}
						}
						else {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（条件送信）運転中無効", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						}
					}
					else if ( i == 1 ) {
						// 装置オプション読出を要求
						sprintf(logMsg, "通信スレッドNEW[%d] : イベント（装置オプション読出）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						conSock->scn.reqflg[C_OPTRD] = 1;
					}
					else if ( i == 2 ) {
						// 設定値読出を要求
						sprintf(logMsg, "通信スレッドNEW[%d] : イベント（設定値読出）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						conSock->scn.reqflg[C_JSETRD] = 1;	// 条件データ読出要求
						conSock->scn.cond_read_flg = 0;		// 設定値読出フラグ（0:通常）
					}
					else if ( i == 3 ) {
						// 次患者情報を要求
						// #11520 2025.02.06 mod 次回透析患者情報転送を必ず要求する TDC高村 start
						/*
						if ( !(conSock->scn.mon_sta & 1) ) {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（次患者情報）", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
							// 透析中は処理しない
							conSock->scn.next_pat_send = 1;	// 次患者送信（0:タイミング,1:イベント）
							conSock->scn.reqflg[C_NEXTPAT] = 1;
						}
						else {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（次患者情報）運転中無効", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						}
						*/
						sprintf(logMsg, "通信スレッドNEW[%d] : イベント（次患者情報）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						conSock->scn.next_pat_send = 1;	// 次患者送信（0:タイミング,1:イベント）
						conSock->scn.reqflg[C_NEXTPAT] = 1;
						// #11520 2025.02.06 mod 次回透析患者情報転送を必ず要求する TDC高村 end
					}
					else if ( i == 4 ) {
						// 未登録患者割付の通知
						sprintf(logMsg, "通信スレッドNEW[%d] : イベント（未登録患者割付）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						// 装置状態管理データを取得
						comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
						i = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
						printf("comsv_rest_get_dev = [%d]\n", i);
						i = comsv_json_dev_state(fpath, 1, &(conSock->scn));
						printf("comsv_json_dev_state = [%d]\n", i);
						// add ？？？？患者発生時の次患者情報送信#1437 高 start
						// スレッド属性オブジェクトの初期化
						pthread_attr_init(&thread_attr);
						// スレッド切り離し状態属性の設定
						pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
						// 条件送信完了時の一連スレッド処理
						conSock->scn.unregistered_flg = 1;
						pthread_create(&thr_rep, &thread_attr, comsv_thread_rest_cond, &(conSock->scn));
						// add ？？？？患者発生時の次患者情報送信#1437 高 end
						// 次患者情報を要求
						conSock->scn.reqflg[C_NEXTPAT] = 1;
						conSock->scn.next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
                        // #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start               
                        if ( checkMachineIsVa(&(conSock->scn)) > 0 ) {
                            // 画像転送可能な装置の場合
                            // 画像データ削除を要求
                            sprintf(logMsg, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（未登録患者割付時）", conSock->thread_no);
                            LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
                            conSock->scn.reqflg[C_DELETE] = 1;
                        }
                        // #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
						// add FNSI-バグ 通信サーバ #9353 高 start
						if(conSock->scn.mon_sta & 1) {
							// 仮想端末（投与薬剤）読み込み
							LcddataReq41_t req41;
							sprintf(buf, "%ld", conSock->scn.ord_no);
							comsv_work_fpath(conSock->scn.dev_no, WORK_LCD_REQ41, fpath);
							i = comsv_rest_get_lcd(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 41, buf, fpath);
							printf("comsv_rest_get_lcd 41 = [%d]\n", i);
							i = comsv_json_lcd_req41(fpath, &req41);
							printf("comsv_json_lcd_req41 = [%d]\n", i);
							// お知らせ通知時間のセット
							conSock->scn.alert_no = 0;
							memcpy(conSock->scn.alert_time, req41.alert_time, sizeof(conSock->scn.alert_time));
							comsv_effectFlg_check(&conSock->scn, &req41);
							// add FNSI-バグ 通信サーバ 高 end
							for ( i = 0; i < ALERT_NUM; i++ ) {
								if ( conSock->scn.alert_time[i] < 0 ) continue;
								j = (conSock->scn.alert_time[i] * 60) + _comsvCache._comsvSet.notice_time;
								if ( get_time() >= conSock->scn.dial_start_date + j) {
									conSock->scn.alert_time[i] = -1;
								}
							}
						}
						// add FNSI-バグ 通信サーバ #9353 高 end
					}
					else if ( i == 5 ) {
						// 条件送信キャンセルの通知
						if ( !(conSock->scn.mon_sta & 1) ) {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（条件送信キャンセル）", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
							// 設定値書込を要求（設定値読込+書込）
							// 透析中、100NX以前の装置は処理しない
                            // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start               
							// i = ntss_mst_type_chack( conSock->scn.deviceType );
							// if ( i > 0 ) {  // -> #9110 -> #9922
							//     // 100NX以降の装置
							//     conSock->scn.reqflg[C_JSETRD] = 1;	// 条件データ読出要求
							//     conSock->scn.cond_read_flg = 1;		// 設定値読出フラグ（1:条件送信時）
							//     conSock->scn.cond_send_cancel = 1;	// 条件送信キャンセル（1:有）
                            //     // #12301 2025.10.28 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
        					//     if ( getMachineIsVa(conSock->scn.dev_idx) ) {
					        //         sprintf(logMsg, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（条件送信キャンセル）", conSock->thread_no);
					        //         LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	                        //         // 画像データ削除を要求
	                        //         conSock->scn.reqflg[C_DELETE] = 1;
                            //     }
                            //     // #12301 2025.10.28 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
							// }
                            i = checkMachineIsVa(&(conSock->scn));
                            if ( i >= 0 ) {
								// 100NX以降の装置
								conSock->scn.reqflg[C_JSETRD] = 1;	// 条件データ読出要求
								conSock->scn.cond_read_flg = 1;		// 設定値読出フラグ（1:条件送信時）
								conSock->scn.cond_send_cancel = 1;	// 条件送信キャンセル（1:有）
        						if ( i > 0 ) {
                                    // 画像転送可能な装置の場合
					                sprintf(logMsg, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（条件送信キャンセル）", conSock->thread_no);
					                LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	                                // 画像データ削除を要求
	                                conSock->scn.reqflg[C_DELETE] = 1;
                                }
                            }
                            // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end

							else {
								// 100NX以前の装置
								// 状況に応じた装置制御データのクリア
								comsv_clear(3, &(conSock->scn));
							}
							// 次患者情報を要求
							conSock->scn.reqflg[C_NEXTPAT] = 1;
							
							// add 強制オフライン 高 start
							conSock->scn.force_offline_time = 0;
							conSock->scn.force_dial_time = -1;
							conSock->scn.force_flg = 0;
							conSock->scn.treatment = 0;
							// add 強制オフライン 高 end
						}
						else {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（条件送信キャンセル）運転中無効", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						}
					}
					else if ( i == 6 && (conSock->scn.mon_sta & 1) ) {
						// 投薬指示変更の通知
						sprintf(logMsg, "通信スレッドNEW[%d] : イベント（投薬指示変更）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						// 仮想端末（投与薬剤）読み込み
						LcddataReq41_t req41;
						sprintf(buf, "%ld", conSock->scn.ord_no);
						comsv_work_fpath(conSock->scn.dev_no, WORK_LCD_REQ41, fpath);
						i = comsv_rest_get_lcd(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 41, buf, fpath);
						printf("comsv_rest_get_lcd 41 = [%d]\n", i);
						i = comsv_json_lcd_req41(fpath, &req41);
						printf("comsv_json_lcd_req41 = [%d]\n", i);
						// お知らせ通知時間のセット
						conSock->scn.alert_no = 0;
						memcpy(conSock->scn.alert_time, req41.alert_time, sizeof(conSock->scn.alert_time));
						// add FNSI-バグ 通信サーバ 高 start
						comsv_effectFlg_check(&conSock->scn, &req41);
						// add FNSI-バグ 通信サーバ 高 end
						for ( i = 0; i < ALERT_NUM; i++ ) {
							if ( conSock->scn.alert_time[i] < 0 ) continue;
							j = (conSock->scn.alert_time[i] * 60) + _comsvCache._comsvSet.notice_time;
							if ( get_time() >= conSock->scn.dial_start_date + j) {
								conSock->scn.alert_time[i] = -1;
							}
						}
						conSock->scn.notice_chg_flg = 1;	// お知らせ情報転送（投薬指示変更）
					}
					else if ( i == 7 || i == 8 ) {
						// 後体重測定／治療状況確認の通知
						if ( i == 7 ) {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（後体重測定）", conSock->thread_no);
						}
						else {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（治療状況確認）", conSock->thread_no);
						}
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
                        // #12301 2025.10.28 del 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
                        //// #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 start
						////if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' ) {
						//if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' && getMachineIsVa(conSock->scn.dev_idx) ) {
						//// #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 end
						//	if ( i == 7 ) {
						//		// 後体重測定の通知
						//		// 100NX以前の装置は処理しない
						//		j = ntss_mst_type_chack(conSock->scn.deviceType);
						//		if ( j > 0 ) {
						//			// FTP画像削除フラグ（2:後体重測定）
						//			conSock->scn.ftp_clear_flg = 2;
						//		}
						//	}
						//	else {
						//		// 治療状況確認の通知
						//		// FTP画像削除フラグ
						//		conSock->scn.ftp_clear_flg = 0;
						//		// 画像データ削除
						//		conSock->scn.reqflg[C_DELETE] = 1;
						//	}	
						//}
                        // #12301 2025.10.28 del 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
						if ( (i == 7 && _comsvCache._comsvSet.pat_timing == '0') ||
							(i == 8 && _comsvCache._comsvSet.pat_timing == '1') ) {
							// #10457 2024.06.18 del デバイスエッジへの通知元で現患者クリアを実施 TDC高村 start
							// // 現患者クリアを行う
							// i = comsv_rest_post_web_api(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 0);
							// printf("comsv_rest_post_web_api = [%d]\n", i);
							// #10457 2024.06.18 del デバイスエッジへの通知元で現患者クリアを実施 TDC高村 end
							// 状況に応じた装置制御データのクリア
							comsv_clear(2, &(conSock->scn));
                            // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start               
							// if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' ) {
							//     // 画像転送ファイル削除
							//     // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
							//     // comsv_bmp_remove(conSock->scn.dev_no);
							//     comsv_bmp_remove(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid);
							//     // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
                            //     // #12301 2025.10.28 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
						    //     // 100NX以前の装置は処理しない
						    //     j = ntss_mst_type_chack(conSock->scn.deviceType);
        					//     if ( j > 0 && getMachineIsVa(conSock->scn.dev_idx) ) {
            				//         sprintf(logMsg, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（患者切り替えタイミング）", conSock->thread_no);
				            //         LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	                        //         // 画像データ削除を要求
	                        //         conSock->scn.reqflg[C_DELETE] = 1;
                            //     }
                            //     // #12301 2025.10.28 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
							// }
                            j = checkMachineIsVa(&(conSock->scn));
                            if ( j >= -1 ) {
								// 画像転送ファイル削除
								comsv_bmp_remove(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid);
        						if ( j > 0 ) {
                                    // 画像転送可能な装置の場合
            					    sprintf(logMsg, "通信スレッドNEW[%d] : 画像データ削除コマンド送信（患者切り替えタイミング）", conSock->thread_no);
				                    LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	                                // 画像データ削除を要求
	                                conSock->scn.reqflg[C_DELETE] = 1;
                                }
                            }
                            // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
							//// 次患者情報を要求
							//conSock->scn.reqflg[C_NEXTPAT] = 1;
							//conSock->scn.next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
						}
					}
					else if ( i == 9 && configParam.lcdDataCash == 1 ) {
						// 仮想端末キャッシュ更新
						sprintf(logMsg, "通信スレッドNEW[%d] : イベント（仮想端末キャッシュ更新）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						memset(ord_str, 0, sizeof(ord_str));
						if ( conSock->scn.cond_send_flg == 1 &&	conSock->scn.ord_no && conSock->scn.pat_id ) {
							// 条件送信済み
							sprintf(ord_str, "%ld", conSock->scn.ord_no);
						}
						else if ( conSock->scn.cond_send_flg == 0 && conSock->scn.next_ord_no ) {
							// 条件未送信
							sprintf(ord_str, "%ld", conSock->scn.next_ord_no);
						}
						if ( ord_str[0] ) {
							// 仮想端末データキャッシュを使用する
							sprintf(wrk, "%d\t%s\t%ld", conSock->scn.cond_send_flg, ord_str, conSock->scn.pat_id);
							comsv_work_fpath(conSock->scn.dev_no, WORK_LCD_CASH, fpath);
							// 仮想端末データキャッシュ読み込み
							i = comsv_rest_get_lcd(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 0, wrk, fpath);
							printf("comsv_rest_get_lcd 0 = [%d]\n", i);
							i = comsv_json_lcd_cash(fpath, conSock->scn.dev_no);
							printf("comsv_json_lcd_cash = [%d]\n", i);
						}
					}
					// add 強制オフライン 高 start
					else if ( i == 10 ) {
						// オフライン運転開始の通知
						if ( !(conSock->scn.mon_sta & 1) && conSock->scn.cond_send_flg ) {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（オフライン運転開始）", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
							conSock->scn.force_offline_wait = 0;
							if ( !conSock->scn.force_offline_time ) {
								time(&(conSock->scn.force_offline_time));
							}
						}
						else if ( conSock->scn.mon_sta & 1 ) {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（オフライン運転開始）運転中無効", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						}
						else {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（オフライン運転開始）条件未送信無効", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						}
					}
					else if ( i == 11 ) {
						// オフライン運転終了の通知
						if ( conSock->scn.mon_sta & 1 ) {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（オフライン運転終了）", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
							conSock->scn.force_dial_time = 0;
						}
						else {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（オフライン運転終了）運転中以外無効", conSock->thread_no);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						}
					}
					// add 強制オフライン 高 end
					else if ( i == 12 && conSock->scn.cond_send_flg && conSock->scn.ord_no ) {
                        // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
                        /*
						// #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 start
						// // レポート画像更新
						// 実績確定・削除時装置レポート画像更新
						// #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 end
						// 100NX以前の装置は処理しない
						j = ntss_mst_type_chack(conSock->scn.deviceType);
						// #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 start
						//if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' && j > 0 ) {
						if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' && j > 0 && getMachineIsVa(conSock->scn.dev_idx) ) {
						// #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 end
							// スレッド属性オブジェクトの初期化
							pthread_attr_init(&thread_attr);
							// スレッド切り離し状態属性の設定
							pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
							// レポート画像更新用スレッド処理
							pthread_create(&thr_rep, &thread_attr, comsv_thread_rest_report, &(conSock->scn));
						// #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 start
						// }
						// //else {
						// //	sprintf(logMsg, "通信スレッドNEW[%d] : イベント（レポート画像更新）非対応装置", conSock->thread_no);
						// 	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						// }
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（実績確定・削除時装置レポート画像更新）", conSock->thread_no);
						}
						else {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（実績確定・削除時装置レポート画像更新）非対応装置", conSock->thread_no);
						}
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						// #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 end
                        */
                        if ( checkMachineIsVa(&(conSock->scn)) > 0 ) {
                            // 画像転送可能な装置の場合
							// スレッド属性オブジェクトの初期化
							pthread_attr_init(&thread_attr);
							// スレッド切り離し状態属性の設定
							pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
							// レポート画像更新用スレッド処理
							pthread_create(&thr_rep, &thread_attr, comsv_thread_rest_report, &(conSock->scn));
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（実績確定・削除時装置レポート画像更新）", conSock->thread_no);
						}
						else {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（実績確定・削除時装置レポート画像更新）非対応装置", conSock->thread_no);
						}
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
                        // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
					}
					// add 透析患者さんのレポート画面を差入れする 高 start
					else if ( i == 13 && conSock->scn.cond_send_flg && conSock->scn.ord_no ) {
                        // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
                        /*
                        // #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 start
						// // レポート差入れ指示
						// 実績版確定時装置レポート画像更新
						// #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 end
						// 100NX以前の装置は処理しない
						j = ntss_mst_type_chack(conSock->scn.deviceType);
						// #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 start
						//if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' && j > 0 ) {
						if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' && j > 0 && getMachineIsVa(conSock->scn.dev_idx) ) {
						// #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 end
							// スレッド属性オブジェクトの初期化
							pthread_attr_init(&thread_attr);
							// スレッド切り離し状態属性の設定
							pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
							// レポート画像更新用スレッド処理
							pthread_create(&thr_rep, &thread_attr, comsv_thread_rest_one_report, &(conSock->scn));
						// #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 start
						// }
						// else {
						//     sprintf(logMsg, "通信スレッドNEW[%d] : イベント（レポート差入れ指示）", conSock->thread_no);
						//     LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						// }
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（実績版確定時装置レポート画像更新）", conSock->thread_no);
						}
						else {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（実績版確定時装置レポート画像更新）非対応装置", conSock->thread_no);
						}
   						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
						// #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 end
                        */
                        if ( checkMachineIsVa(&(conSock->scn)) > 0 ) {
                            // 画像転送可能な装置の場合
							// スレッド属性オブジェクトの初期化
							pthread_attr_init(&thread_attr);
							// スレッド切り離し状態属性の設定
							pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
							// レポート画像更新用スレッド処理
							pthread_create(&thr_rep, &thread_attr, comsv_thread_rest_one_report, &(conSock->scn));
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（実績版確定時装置レポート画像更新）", conSock->thread_no);
						}
						else {
							sprintf(logMsg, "通信スレッドNEW[%d] : イベント（実績版確定時装置レポート画像更新）非対応装置", conSock->thread_no);
						}
                        // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
					}
					// add 透析患者さんのレポート画面を差入れする 高 end
					// add FNSI-バグ 通信サーバ 高 start
					else if ( i == 15 ) {
						// ホスト報知定義更新指示の通知
						// ホスト報知定義の取得・設定
						j = comsv_host_watch(conSock->thread_no, &(conSock->scn));
						printf("comsv_host_watch = [%d]\n", j);
						sprintf(logMsg, "通信スレッドNEW[%d] : イベント（ホスト報知定義更新指示）", conSock->thread_no);
						LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					}
					// add FNSI-バグ 通信サーバ 高 end
				}
			}

			// 条件送信タイムアウトチェック
			if ( (conSock->scn.reqflg[C_JSETRD] == 2 || conSock->scn.reqflg[C_JSETRD] == 4) && conSock->scn.cond_send_time ) {
				if ( get_time() > conSock->scn.cond_send_time + TIMEOUT ) {
					// リトライ１、２
					conSock->scn.reqflg[C_JSETRD] += 1;
				}
			}
			else if ( (conSock->scn.reqflg[C_JSET] == 2 || conSock->scn.reqflg[C_JSET] == 4) && conSock->scn.cond_send_time ) {
				if ( get_time() > conSock->scn.cond_send_time + TIMEOUT ) {
					// リトライ１、２
					conSock->scn.reqflg[C_JSET] += 1;
				}
			}
			else if ( (conSock->scn.reqflg[C_JSETRD] == 6 || conSock->scn.reqflg[C_JSET] == 6) && conSock->scn.cond_send_time ) {
				if ( get_time() > conSock->scn.cond_send_time + TIMEOUT ) {
					// タイムアウト
					sprintf(logMsg, "通信スレッドNEW[%d] : 設定値書込破棄（タイムアウト）", conSock->thread_no);
					LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					if ( !conSock->scn.cond_send_cancel && conSock->scn.cond_send_ctrl ) {
						if ( conSock->scn.reqflg[C_JSETRD] == 6 && conSock->scn.cond_read_flg == 1 ) {
							// 体重計測定実績のステータス・メッセージデータを更新する
							comsv_rest_put_scale_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.cond_send_ctrl, 2);
						}
						else if ( conSock->scn.reqflg[C_JSET] == 6 ) {
							// 体重計測定実績のステータス・メッセージデータを更新する
							comsv_rest_put_scale_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.cond_send_ctrl, 7);
						}
					}
					conSock->scn.reqflg[C_JSETRD] = 0;
					conSock->scn.reqflg[C_JSET] = 0;
					conSock->scn.cond_read_flg = 0;
					conSock->scn.cond_send_time = 0;
					conSock->scn.cond_send_cancel = 0;
				}
			}

			// お知らせ情報転送チェック
			comsv_notice_check(&(conSock->scn));
		}

		/**
		 * 新通信処理
		 */
		// add FNSI-バグ 通信サーバ 高 start
		if( !(conSock->scn.conflg == 0 && conSock->scn.force_flg == 1) ) {
		// add FNSI-バグ 通信サーバ 高 end
			if ( comsv_communication(conSock) == false ) {
				// add FNSI-バグ 通信サーバ 高 start
				if(conSock->scn.force_flg != 1) {
				// add FNSI-バグ 通信サーバ 高 end
					strcpy(str1, "[gs debug] : comsv_communication() return error!");
					LogOutputs(NTSS_LOG_INFO, str1, 0, conSock->scn.deviceType, conSock->scn.devid);
					break;
				}
			}
		}
		
		// add 強制オフライン 高 start
		if( conSock->scn.force_flg == 1 ) {
			comsv_mon_offline(conSock->thread_no, &(conSock->scn));
		}
		// add 強制オフライン 高 end

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
				// #8081 2023.03.20 mod 登録用工程番号を取得 TDC高村 start
				//i = comsv_rest_put_ProcessState(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, pInfo->nProcess[0]);
				// 登録用工程番号を取得する
				u_char nprocess[] = "99\0";  
				u_char cVersion[] = "00\0"; // 呼び出し用に宣言（未使用）
				ntss_mst_proc_dbno(
					conSock->scn.devsw	  // 通信フォーマット
					, cVersion			  // 装置バージョン
					, pInfo->nProcess[0]	// 工程番号
					, nprocess			  // DBへ登楼する工程コード
				);
				i = comsv_rest_put_ProcessState(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, atoi(nprocess));
				// #8081 2023.03.20 mod 登録用工程番号を取得 TDC高村 end
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
		// updateCommFailDataFromMain(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 1);
		// // #11282 2025.02.28 add 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 end
		if (conSock->is_update_comm_fail_from_main)
		{
			int resultUpdateCommFail = updateCommFailDataFromMain(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, 1);
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

	// パケット管理情報初期化
	finNTSSPacketInfo(&packetInfoList[conSock->thread_no]);
	
	// add FNSI-バグ 通信サーバ 高 start
	if(packetInfoList[conSock->thread_no].sourceAddr != 0 || conSock->scn.conflg == 0) {
		packetInfoList[conSock->thread_no].sourceAddr = 0;
		if(tDev_no != 0) {
			i = comsv_rest_put_ProcessState(tDev_no, tDeviceType, tDevid, 99);
			printf("comsv_rest_put_ProcessState = [%d]\n", i);
		}
	}
	// add FNSI-バグ 通信サーバ 高 end

	sprintf(logMsg, "通信スレッドNEW[%d] : 終了 2", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	conSock->running = false;
	conSock->using = false;
	// add FNSI-バグ 通信サーバ 高 start
	memset(conSock->event, '\0', sizeof(conSock->event));
	// add FNSI-バグ 通信サーバ 高 end
	pthread_exit((void *)0);	// スレッド終了
}

/**
* @fn bool comsv_communication(struct connect_socket *conSock)
* @brief 新通信用ソケット送受信処理
* @param[in,out] conSock 装置制御情報
* @return true 正常
* @return false エラー
*/
bool comsv_communication(struct connect_socket *conSock) {
	int i, sndlen;
	fd_set fd, fdw;
	uint16_t sel_ret = 0;
	struct timeval seltime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    struct timespec myTime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	int ret;
	unsigned char *dp,*bp,crc;
	unsigned char logMsg[256];
	// #8266 2023.03.20 mod バッファサイズを変更 TDC高村 start
	//u_char buf[RCVMAX*2];
	unsigned char buf[RCVMAX];
	// #8266 2023.03.20 mod バッファサイズを変更 TDC高村 end
	struct NTSS_PACKET_INFORMATION *pInfo;

	extern void comsv_socket_error(struct connect_socket *conSock);

	sel_ret = 0;
	if ( conSock->scn.staflg != S_ETX ) {
		// 新通信装置受信チェック
		if ( conSock->scn.conflg <= 0 ) {
			comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
			comsv_socket_error(conSock);			// ソケットエラー処理
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
			sprintf(logMsg, "通信スレッドNEW[%d] : ソケットREAD 失敗 [%d] [%d][%s]", conSock->thread_no, ret, errno, strerror(errno));
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			// #11490 2025.02.26 add ソケットREAD失敗時、戻り値及びエラー内容をログ出力 end
			comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
			comsv_socket_error(conSock);			// ソケットエラー処理
			return false;
		}
		// 受信データ処理
		comsv_rcvset(&(conSock->scn), buf, ret);
	}
	else {
		// 受信データ無し
		if ( conSock->scn.err_ltime ) {
			if ( get_time() > conSock->scn.err_ltime + _comsvCache._comsvSet.device_timeout ) {
				// タイムアウト
				sprintf(logMsg, "通信スレッドNEW[%d] : 通信タイムアウト 2 [%02x][%d][%d][%d][%ld][%d]",
					conSock->thread_no, conSock->scn.staflg, conSock->scn.rcvlen,
					conSock->scn.remlen, conSock->scn.remp, (get_time() - conSock->scn.err_ltime), ret);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				if ( conSock->scn.staflg == S_STX && conSock->scn.rcvlen > 0 ) {
					// ETXの受信がなかった場合
					sprintf(logMsg, "通信スレッドNEW[%d] : [%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x] - [%02x]",
						conSock->thread_no, conSock->scn.rcvbuf[0], conSock->scn.rcvbuf[1],
						conSock->scn.rcvbuf[2],	conSock->scn.rcvbuf[3],	conSock->scn.rcvbuf[4], conSock->scn.rcvbuf[5],
						conSock->scn.rcvbuf[6],	conSock->scn.rcvbuf[7],	conSock->scn.rcvbuf[8], conSock->scn.rcvbuf[9],
						conSock->scn.rcvbuf[10], conSock->scn.rcvbuf[11], conSock->scn.rcvbuf[conSock->scn.rcvlen - 1]);
					LogOutputs(NTSS_LOG_DEBUG, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				}
				comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
				comsv_socket_error(conSock);			// ソケットエラー処理
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
		conSock->scn.rcvlen--;	// CRC分を除く
		for ( i = 0, crc = 0; i < conSock->scn.rcvlen; i++, dp++ ) {
			crc += (*dp);
		}
		if ( crc != *dp ) {
			ret = E_CRCCHK;
			// #12304 2025.10.24 mod ログ強化（CRCエラー） TDC片口 start
			// #12304 2025.10.21 add ログ強化（CRCエラー） TDC高村 start
			// sprintf(logMsg, "通信スレッドNEW[%d] : CRCエラー [%02x%02x%02x%02x%02x%02x%02x%02x %02x %02x %02x%02x][%02x][%02x]",
			//     conSock->thread_no, conSock->scn.rcvbuf[0], conSock->scn.rcvbuf[1], conSock->scn.rcvbuf[2], conSock->scn.rcvbuf[3],
			//     conSock->scn.rcvbuf[4], conSock->scn.rcvbuf[5], conSock->scn.rcvbuf[6], conSock->scn.rcvbuf[7], conSock->scn.rcvbuf[8],
			//     conSock->scn.rcvbuf[9], conSock->scn.rcvbuf[10], conSock->scn.rcvbuf[11], *dp, crc, conSock->scn.cmd);
			// LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			// #12304 2025.10.21 add ログ強化（CRCエラー） TDC高村 end

			sprintf(logMsg, "通信スレッドNEW[%d] : CRCエラー CRC=[%02x] 計算値=[%02x] 前回CMD=[%02x] データ長=%d",
				conSock->thread_no, *dp, crc, conSock->scn.cmd, conSock->scn.rcvlen + 1);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);

			sprintf(logMsg, "通信スレッドNEW[%d] : 受信データ", conSock->thread_no);
			LogOutputsHexDump(NTSS_LOG_ERROR, logMsg, conSock->scn.rcvbuf, conSock->scn.rcvlen + 1,
								conSock->scn.deviceType, conSock->scn.devid);
			// #12304 2025.10.24 mod ログ強化（CRCエラー） TDC片口 end
		}
		if ( ret == 0 ) {
			if ( conSock->scn.rcvbuf[11] && (conSock->scn.rcvbuf[9] & 0xff) != 0xe5 && conSock->scn.rcvbuf[11] != E_DEVID &&
					conSock->scn.rcvbuf[11] != E_NOTLOG && conSock->scn.rcvbuf[11] != E_DELLOG ) {
				//	終了コードエラー受信処理
				if ( conSock->scn.rcvbuf[11] == E_NOWRITE ) {
					// #10013 2023.11.14 mod 治療中の一斉時刻合わせで発生する終了コードエラー対策 TDC高村 start
					/*
					// add FNSI-バグ 通信サーバ #8478 高 start
					if(conSock->scn.current_mon_sta[0] != COMM_STA2 && !(conSock->scn.pat_id == 0 && conSock->scn.next_pat_id == 0)) {
					// add FNSI-バグ 通信サーバ #8478 高 end
					*/
					// #10180 2024.02.14 mod 条件送信不可なのに条件送信失敗にならない TDC高村 start
					/*
					if ( (conSock->scn.rcvbuf[9] & 0xff) == 0xea &&
						conSock->scn.current_mon_sta[0] != COMM_STA2 && !(conSock->scn.pat_id == 0 && conSock->scn.next_pat_id == 0)) {
					*/
					if ( (conSock->scn.rcvbuf[9] & 0xff) == 0xea && conSock->scn.pat_id != 0 ) {
					// #10180 2024.02.14 mod 条件送信不可なのに条件送信失敗にならない TDC高村 end
					// #10013 2023.11.14 mod 治療中の一斉時刻合わせで発生する終了コードエラー対策 TDC高村 end
						//	書き込み不可（設定値書込）
						sprintf(logMsg, "通信スレッドNEW[%d] : 設定値書込破棄（書込不可）", conSock->thread_no);
						LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);			
						// 体重計測定実績のステータス・メッセージデータを更新する
						comsv_rest_put_scale_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.cond_send_ctrl, 6);
						// 受信コマンドによる要求リセット
						comsv_rcv_reset(&(conSock->scn));
						conSock->scn.staflg = S_WAIT;
						conSock->scn.err_ltime = 0;		
						
						// 残り受信データ処理
						comsv_rcvset(&(conSock->scn), (char*)0, 0);
						return true;
					}
				}
				else {
					sprintf(logMsg, "通信スレッドNEW[%d] : 終了コード異常 [%02x][%02x]",
						conSock->thread_no,	(conSock->scn.rcvbuf[9] & 0xff), (conSock->scn.rcvbuf[11] & 0xff));
					LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					if ( (conSock->scn.rcvbuf[9] & 0xff) == 0xe9 ) {
						// 体重計測定実績のステータス・メッセージデータを更新する
						comsv_rest_put_scale_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.cond_send_ctrl, 2);
					}
					else if ( (conSock->scn.rcvbuf[9] & 0xff) == 0xea ) {
						// 体重計測定実績のステータス・メッセージデータを更新する
						comsv_rest_put_scale_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.cond_send_ctrl, 3);
					}
					// 受信コマンドによる要求リセット
					comsv_rcv_reset(&(conSock->scn));
					conSock->scn.staflg = S_WAIT;
					conSock->scn.err_ltime = 0;		
					
					// 残り受信データ処理
					comsv_rcvset(&(conSock->scn), (char*)0, 0);
					return true;
				}
			}
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

		pInfo = &packetInfoList[conSock->thread_no];
        // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
		//gettimeofday(&pInfo->buffer.lastReceiveTime, NULL);
        clock_gettime(CLOCK_REALTIME, &myTime);
        pInfo->buffer.lastReceiveTime.tv_sec = myTime.tv_sec;
        pInfo->buffer.lastReceiveTime.tv_usec = myTime.tv_nsec / 1000;
        // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
		if ( conSock->scn.dev_idx && getCreateMachineInfoMode() == false ) {
			// 新通信受信データ処理
			comsv_rcv(conSock->thread_no, &(conSock->scn));

			// #8266 2023.03.20 mod ログシーケンシャルＮｏによる重複チェック TDC高村 start
			if ( conSock->scn.rcvlen > 0 ) {
				// 電文ファイル出力
				dp = pInfo->buffer.cBuffer;
				bp = conSock->scn.rcvbuf;
				*dp++ = STX;
				for ( i = 0, sndlen = 1; i <= conSock->scn.rcvlen; i++, bp++ ) {
					if ( *bp == STX )	  { *dp++ = DLE; *dp++ = DC2; sndlen += 2; }
					else if ( *bp == ETX ) { *dp++ = DLE; *dp++ = DC3; sndlen += 2; }
					else if ( *bp == DLE ) { *dp++ = DLE; *dp++ = DLE; sndlen += 2; }
					else				   { *dp++ = (*bp); sndlen++; }
				}
				*dp++ = ETX; sndlen++;
				pInfo->buffer.nBufferSize = sndlen;
				// add 強制オフライン 高 start
				pInfo->force_flg = conSock->scn.force_flg;
				// add 強制オフライン 高 end
				// add FNSI-バグ 通信サーバ 高 start
				pInfo->dial_end_date = conSock->scn.dial_end_date;
				pInfo->dev_no = conSock->scn.dev_no;
				pInfo->conflg = conSock->scn.conflg;
				// add FNSI-バグ 通信サーバ 高 end
				ret = checkNTSSNKKCommand(pInfo);
				if ( ret != 0 ) {
					sprintf(logMsg, "通信スレッドNEW[%d] : 電文ファイル出力[%d]", conSock->thread_no, ret);
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				}
			}
			// #8266 2023.03.20 mod ログシーケンシャルＮｏによる重複チェック TDC高村 end
		}

		if ( (conSock->scn.rcvbuf[9] & 0xff) >= 0x61 && (conSock->scn.rcvbuf[9] & 0xff) <= 0x68 ) {
			// add 装置のSTATUS状態更新方法の変更 高 start
			conSock->scn.machineState[0] = conSock->scn.rcvbuf[10];
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
			
			// 新通信装置からのコマンド受信
			conSock->scn.cmd = (conSock->scn.rcvbuf[9] & 0xff);
			conSock->scn.reqflg[C_RESPONSE] = 1;
		}
		else {
			if ( conSock->scn.comflg ) {
				conSock->scn.reqflg[conSock->scn.comflg] = 0;
			}
		}
		conSock->scn.mon_sta &= 0x7fff;	// 通信異常クリア
		conSock->scn.staflg = S_WAIT;
		conSock->scn.err_ltime = 0;		
	}
	else if ( conSock->scn.conflg > 0 && (conSock->scn.staflg & S_END) ) {	
		sprintf(logMsg, "通信スレッドNEW[%d] : 受信データ異常[%02x]", conSock->thread_no, conSock->scn.staflg);
		LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		if ( (conSock->scn.rcvbuf[9] & 0xff) == 0xe9 && conSock->scn.cond_read_flg == 1 ) {
			// 体重計測定実績のステータス・メッセージデータを更新する
			comsv_rest_put_scale_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.cond_send_ctrl, 2);
		}
		else if ( (conSock->scn.rcvbuf[9] & 0xff) == 0xea ) {
			// 体重計測定実績のステータス・メッセージデータを更新する
			comsv_rest_put_scale_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.cond_send_ctrl, 4);
		}
		comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
		comsv_socket_error(conSock);			// ソケットエラー処理
		return false;
	}

	/* 送信コマンド作成 */
	if ( conSock->scn.staflg == S_WAIT && conSock->scn.conflg > 0 ) {
		if ( conSock->scn.reqflg[C_RESPONSE] ) {
			conSock->scn.reqflg[C_RESPONSE] = 0;
			conSock->scn.comflg = C_RESPONSE;	// レスポンスを優先
		}
		else {
			for ( i = 1, conSock->scn.comflg = C_NOTOPE; i <= C_MONITOR; i++ ) {
				if ( conSock->scn.reqflg[i] == 1 ) {
					conSock->scn.comflg = i;
					if ( (conSock->scn.cond_read_flg == 1 && conSock->scn.comflg == C_JSETRD) || conSock->scn.comflg == C_JSET ) {
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
					if ( (conSock->scn.cond_read_flg == 1 && i == C_JSETRD) || i == C_JSET ) {
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
			comsv_rcvset(&(conSock->scn), (char*)0, 0);
			return true;
		}
		
		ret = comsv_cmd(conSock->thread_no, &(conSock->scn));
		if ( ret>0 ) {
			conSock->scn.staflg = S_SEND;
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
		if ( sel_ret > 0 && FD_ISSET(conSock->scn.sock_id, &fdw) ) {
			// 書き込み
			ret = write(conSock->scn.sock_id, conSock->scn. sndbuf, conSock->scn.sndlen);
		}
		if ( ret <= 0 ) {
			// 失敗
			sprintf(logMsg, "通信スレッドNEW[%d] : 書き込み失敗[%d]", conSock->thread_no, (int)ret);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			if ( (conSock->scn.comflg == C_JSETRD && conSock->scn.cond_read_flg == 1) || conSock->scn.comflg == C_JSET ) {
				// 体重計測定実績のステータス・メッセージデータを更新する
				comsv_rest_put_scale_state(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.cond_send_ctrl, 8);
			}
			comsv_reqflg_reset(&(conSock->scn));	// 要求フラフ全リセット処理
			comsv_socket_error(conSock);			// ソケットエラー処理
			return false;
		}
		else {
            // #12304 2025.10.21 add ログ強化（仮想端末レスポンス） TDC高村 start
            if ( conSock->scn.cmd == 0x67 ) {
                sprintf(logMsg, "通信スレッドNEW[%d] : 透析装置へのLCDデータ要求レスポンス（リクエストコード：%d） [%d][%d][%ld][%ld]",
                    conSock->thread_no, conSock->scn.lcd_request, getCommAliveState(), conSock->scn.cond_send_flg, conSock->scn.pat_id, conSock->scn.ord_no);
                LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
            }
            else if ( conSock->scn.cmd == 0x68 ) {
                sprintf(logMsg, "通信スレッドNEW[%d] : 透析装置へのLCDデータ送信レスポンス（リクエストコード：%d） [%d][%d][%ld][%ld]",
                    conSock->thread_no, conSock->scn.lcd_request, getCommAliveState(), conSock->scn.cond_send_flg, conSock->scn.pat_id, conSock->scn.ord_no);
                LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
            }            
            // #12304 2025.10.21 add ログ強化（仮想端末レスポンス） TDC高村 end
			//ioctl(conSock->scn.sock_id, I_FLUSH, FLUSHRW, &ret);
			conSock->scn.staflg = S_WAIT;
			conSock->scn.err_ltime = 0;
		}
	}

	// 残り受信データ処理
	comsv_rcvset(&(conSock->scn), (char*)0, 0);

	return true;
}

/**
* @fn void comsv_socket_close( struct connect_socket *conSock )
* @brief ソケットクローズ処理（新通信待受用）
* @param[in,out] conSock 装置制御情報
*/
void comsv_socket_close( struct connect_socket *conSock ) {
	u_char logMsg[256];

	if ( conSock->scn.conflg > 0 && conSock->accept_socket ) {
		// シャットダウン(送受信禁止)
		shutdown(conSock->accept_socket, 2);
		// ソケットクローズ
		//sprintf(logMsg, "通信スレッドNEW[%d] : ソケットクローズ", conSock->thread_no);
		//LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		close(conSock->accept_socket);
		conSock->accept_socket = (-1);
		// add FNSI-バグ 通信サーバ 高 start
		if(conSock->scn.force_flg != 1){
		// add FNSI-バグ 通信サーバ 高 end
			conSock->running = false;
		}
	}
	// add FNSI-バグ 通信サーバ 高 start
	conSock->scn.conflg = 0;
	if(conSock->scn.force_flg != 1){
	// add FNSI-バグ 通信サーバ 高 end
		memset(&conSock->scn, 0, sizeof(struct scn_data_fm));  /* 通信制御データクリア */
	}
}

/**
* @fn void comsv_socket_error(struct connect_socket *conSock)
* @brief ソケットエラー処理（新通信待受用）
* @param[in,out] conSock 装置制御情報
*/
void comsv_socket_error(struct connect_socket *conSock) {
	// ソケットクローズ処理（新通信待受用）
	comsv_socket_close(conSock);
}

/**
 * @fn int check_is_target_device(u_char *commFormatCd, u_char *deviceCode, u_char *ipAddr, struct scn_data_fm *scn)
 * @brief マスタとの突き合わせ（新通信用）
 * @param[in] commFormatCd 通信フォーマット 
 * @param[in] deviceCode 製造番号
 * @param[in] ipAddr IPアドレス
 * @param[in,out] scn 装置制御データ
 * @return -1 マスタに存在しない
 * @return 0 突き合わせ成功
 * @return 1 装置情報作成モード
 */
int check_is_target_device(u_char *commFormatCd, u_char *deviceCode, u_char *ipAddr, struct scn_data_fm *scn) {
	int matchMst = -1;
	uint16_t idx;
	char mstIpAddr[16] = {0};
	char mstDevNo[9] = {0};
	char mstOption[5][5];

	for( idx = 0; idx < COUNTOF(_machineInfoData); idx++ ) {
		if ( _machineInfoData[idx].machineFormatCd == '\0' ) {
			// これ以降マスタデータなし
			break;
		}
		// マスタ構造体のIPアドレスは末尾に\0がないため文字列として扱えない
		strncpy(mstIpAddr, _machineInfoData[idx].ipAddress, 15);
		strncpy(mstDevNo, _machineInfoData[idx].machineNo, 8);
		memset(mstOption, 0, sizeof(mstOption));
		strncpy(mstOption[0], _machineInfoData[idx].machineOptine1, 4);
		strncpy(mstOption[1], _machineInfoData[idx].machineOptine2, 4);
		strncpy(mstOption[2], _machineInfoData[idx].machineOptine3, 4);
		strncpy(mstOption[3], _machineInfoData[idx].machineOptine4, 4);
		strncpy(mstOption[4], _machineInfoData[idx].machineOptine5, 4);

		if ( memcmp(commFormatCd, &(_machineInfoData[idx].machineFormatCd), 1) == 0	// 通信フォーマットが一致
			&& memcmp(deviceCode, &(_machineInfoData[idx].machineSerial), 7) == 0	// 製造番号が一致
			&& convertNTSSIPAddr(ipAddr) == convertNTSSIPAddr(mstIpAddr)			// IPアドレス一致
			&& _machineInfoData[idx].machineCommCd == NTSS_COMM_TYPE_NEW) {			// 通信方式が日機装新通信
			// マスタに存在する
			scn->dev_idx = idx + 1;
			// 型式コード
 			memcpy(scn->deviceType, _machineInfoData[idx].machineTypeCd, 3);
			// 装置番号
			sscanf(mstDevNo, "%08lX", &scn->dev_no);
			// 装置オプション
			sscanf(mstOption[0], "%04hX", &scn->option[0]);
			sscanf(mstOption[1], "%04hX", &scn->option[1]);
			sscanf(mstOption[2], "%04hX", &scn->option[2]);
			sscanf(mstOption[3], "%04hX", &scn->option[3]);
			sscanf(mstOption[4], "%04hX", &scn->option[4]);
			// 突き合わせ成功
			matchMst = 0;
			break;
		}
	}

	if ( getCreateMachineInfoMode() == true ) {
		// 装置情報作成モード
		if ( matchMst != 0 ) {
			// マスタに存在しない
			scn->dev_idx = 0;
			// 型式コード
			memcpy(scn->deviceType, "000", 3);
		}
		matchMst = 1;		
	}

	return matchMst;
}

/**
 * @fn void comsv_rcvset(struct scn_data_fm *sp, u_char *buf, int len)
 * @brief 受信データ解析処理（新通信＆NX通信用）
 * @param[in,out] sp 装置制御データ
 * @param[in] buf 受信データ 
 * @param len 受信データ長
 */
void comsv_rcvset(struct scn_data_fm *sp, u_char *buf, int len) {
	int i, n;
	u_char *dp, rc, crc, code;
	u_char *bufp, zbuf[RCVMAX];

	if ( len == 0 ) { /* 残りの受信データの取り込み */
		if ( sp->remlen <= 0 ) {
			return;
		}
		len = sp->remlen;
		memcpy(zbuf, sp->rcvbuf + sp->remp, len);
		bufp = zbuf;
		sp->remlen = 0;
	}
	else {
		bufp=buf;
	}

	dp = sp->rcvbuf + sp->rcvlen;
	for ( i = 0; i < len; i++, bufp++ ) { 
		rc = *bufp; 
		if ( rc == STX ) {
			dp = sp->rcvbuf; 
			sp->rcvlen = 0;
			sp->staflg = S_STX; 
			sp->rcvdle = 0;
			continue;
		}
		if ( sp->staflg != S_STX ) {
			continue;
		}
		if ( rc == ETX ) {
			sp->staflg = S_ETX;
			i++;	/* 残り受信データのセット */
			if ( i < len ) {
				if ( sp->rcvlen + len - i <= RCVMAX ) {
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
		else if ( rc == DLE ) {
			if ( sp->rcvdle == 0 ) {
				 sp->rcvdle = 1; 
				 continue; 
			}
		}
		if ( sp->rcvlen < RCVMAX ) {
			if ( sp->rcvdle ) {
				if ( rc == DLE ) {
					rc = DLE;
				}
				else if ( rc == DC2 ) {
					rc = STX;
				}
				else if ( rc == DC3 ) {
					rc = ETX;
				}
				sp->rcvdle = 0;
			}
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
 * @fn void comsv_clear(int timing, struct scn_data_fm *sp)
 * @brief 状況に応じた装置制御データのクリア
 * @param[in] timing タイミング（0:条件送信,1:透析開始,2:版確定,3:条件キャンセル,4:次患者条件送信）
 * @param[in,out] sp 装置制御データ
 */
void comsv_clear(int timing, struct scn_data_fm *sp) {
	if ( timing < 0 || timing > 4 ) return;

	if ( timing == 0 ) {
		// 条件送信時
		sp->dial_start_date = 0;	// 透析開始日時
		sp->dial_end_date = 0;		// 透析終了日時
	}
	else if ( timing == 1 ) {
		// 透析開始時
		sp->dial_end_date = 0;		// 透析終了日時
	}
	else if ( timing == 2 && sp->dial_start_date && sp->dial_end_date ) { 
		// 版確定（透析開始日時有り ＆ 透析終了日時有り）
		// add AWSとDEの通信断からの復旧 高 start
		if ( getCommAliveState() == 0 )
		{
		// add AWSとDEの通信断からの復旧 高 end
			sp->ord_no = 0;				// オーダ番号
			sp->pat_id = 0;				// 患者ID
		}
		sp->cond_send_ctrl = 0;		// 条件送信管理番号
		sp->cond_send_time = 0;		// 条件送信時刻（コマンド送信時刻）
		sp->cond_send_date = 0;		// 条件送信日時
		sp->cond_set_date = 0; 		// 条件確認日時
		sp->cond_send_flg = 0;		// 条件送信フラグ（0:未送信,1:送信済）
		sp->dial_start_date = 0;	// 透析開始日時
		sp->dial_end_date = 0;		// 透析終了日時
	}
	else if ( timing == 3 && !sp->dial_start_date && !sp->dial_end_date ) { 
		// 条件キャンセル時（透析開始日時無し ＆ 透析終了日時無し）
		// add AWSとDEの通信断からの復旧 高 start
		if ( getCommAliveState() == 0 )
		{
		// add AWSとDEの通信断からの復旧 高 end
			sp->ord_no = 0;				// オーダ番号
		}
		sp->pat_id = 0;				// 患者ID
		sp->cond_send_ctrl = 0;		// 条件送信管理番号
		sp->cond_send_time = 0;		// 条件送信時刻（コマンド送信時刻）
		sp->cond_send_date = 0;		// 条件送信日時
		sp->cond_set_date = 0; 		// 条件確認日時
		sp->cond_send_flg = 0;		// 条件送信フラグ（0:未送信,1:送信済）
		sp->dial_start_date = 0;	// 透析開始日時
		sp->dial_end_date = 0;		// 透析終了日時
	}
	else if ( timing == 4 && sp->dial_start_date && sp->dial_end_date ) { 
		// 次患者条件送信（透析開始日時有り ＆ 透析終了日時有り）
		sp->pat_id = 0;				// 患者ID
		//sp->cond_send_ctrl = 0;	// 条件送信管理番号
		sp->cond_send_time = 0;		// 条件送信時刻（コマンド送信時刻）
		sp->cond_send_date = 0;		// 条件送信日時
		sp->cond_set_date = 0; 		// 条件確認日時
		sp->cond_send_flg = 0;		// 条件送信フラグ（0:未送信,1:送信済）
		sp->dial_start_date = 0;	// 透析開始日時
		sp->dial_end_date = 0;		// 透析終了日時
	}
}

/**
 * @fn void comsv_host_watch_init(int thread_no)
 * @brief ホスト報知監視開始待ち時間の初期化
 * @param[in] thread_no スレッド番号
*/
void comsv_host_watch_init(int thread_no) {
	struct NTSS_PACKET_INFORMATION *pInfo;

	pInfo = &packetInfoList[thread_no];

	// 監視開始待ち時間を初期化
	pInfo->watchWaitTime = -1;
}

/**
 * @fn int comsv_host_watch(int thread_no, struct scn_data_fm *sp)
 * @brief ホスト報知定義の取得・設定（装置共通）
 * @param[in] thread_no スレッド番号
 * @param[in,out] sp 装置制御データ
 * @return 1：設定成功/0：設定不要(設定なし含む)
*/
int comsv_host_watch(int thread_no, struct scn_data_fm *sp) {
	int i, Ret = 0;
	char fpath[64];
	struct NTSS_PACKET_INFORMATION *pInfo;
	HostWatchPat_t host_watch[HOST_WATCH_MAX];

	// ホスト報知設定初期化
	pInfo = &packetInfoList[thread_no];
	initNTSSHostWatchConf(pInfo);
	// 患者ホスト報知定義を取得
	comsv_work_fpath(sp->dev_no, WORK_PAT_HOST, fpath);
	i = comsv_rest_get_host(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, fpath);
	printf("comsv_rest_get_host = [%d]\n", i);
	i = comsv_json_host_pat(fpath, host_watch);
	printf("comsv_json_host_pat = [%d]\n", i);
	if ( i == 0 ) {
		for ( i=0; i<HOST_WATCH_MAX; i++ ) {
			if ( host_watch[i].addr < 0 ) break;
			// パケット管理情報のホスト報知設定を設定
			Ret = setNTSSHostWatchConf(pInfo, host_watch[i].addr, host_watch[i].upper,host_watch[i].lower, host_watch[i].judge);
		}
	}
	pInfo->watchWaitTime = 0;

	return Ret;
}

/**
* @fn int comsv_notice_check(struct scn_data_fm *sp)
* @brief お知らせ情報転送チェック（装置共通）
* @param[in,out] sp 装置制御データ
* @return 1：実施有り/0：実施無し
*/
int comsv_notice_check(struct scn_data_fm *sp) {
	int Ret = 0;
	int i, j;
	char fpath[64];
 	u_char upData[512];

	// お知らせ情報転送チェック
	// mod 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
	// if ( (sp->mon_sta & 1) && sp->reqflg[C_NOTICE] == 0 ) {
	if ( ((sp->mon_sta & 1) || sp->current_mon_sta[0] == COMM_STA4) && sp->reqflg[C_NOTICE] == 0 ) {
	// mod 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end
		for ( i=0; i<ALERT_NUM; i++ ) {
			if ( sp->alert_time[i] == -99 ) {
				sp->alert_no = i + 1;
				break;
			}
			else {
				if ( sp->alert_time[i] < 0 ) continue;
				j = (sp->alert_time[i] * 60) + _comsvCache._comsvSet.notice_time;
				if ( get_time() >= sp->dial_start_date + j) {
					sp->alert_no = i + 1;
					break;
				}
			}
		}
		if ( i < ALERT_NUM ) {
			// お知らせ情報転送
			// del 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
			// LcddataReq41_t req41;
			// comsv_work_fpath(sp->dev_no, WORK_LCD_REQ41, fpath);
			// comsv_json_lcd_req41(fpath, &req41);
			// if ( sp->alert_no > 0 && sp->alert_no <= ALERT_NUM ) {
			// 	i = sp->alert_no - 1;
			// 	// 未投与薬剤データからJSONデータを作成
			// 	j = comsv_json_host_make_medi(upData, req41.no[i], sp);
			// 	printf("comsv_json_host_make_medi = [%d]\n", j);
			// 	// 投薬タイミング通知処理
			// 	j = comsv_rest_post_notice_medi(sp->dev_no, sp->deviceType, sp->devid, upData);
			// 	printf("comsv_rest_post_notice_medi = [%d]\n", j);
			// }
			// del 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end
			if ( sp->devsw == 'F' || sp->devsw == 'V' || sp->devsw == 'W' ) {
				// 新通信以外はクリア
				sp->alert_no = 0;
				sp->alert_time[i] = -1;
				sp->reqflg[C_NOTICE] = 0;
			}
			else {
				sp->reqflg[C_NOTICE] = 1;	// お知らせ情報転送
			}
			Ret = 1;
		}
		else if ( sp->notice_chg_flg ) {
			if ( sp->devsw == 'F' || sp->devsw == 'V' || sp->devsw == 'W' ) {
				// 新通信以外はクリア
				sp->reqflg[C_NOTICE] = 0;
			}
			else {
				sp->reqflg[C_NOTICE] = 1;	// お知らせ情報転送
			}
			Ret = 1;
		}
	}

	return Ret;
}

// add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
/**
* @fn void comsv_medicated_end(void *ptr)
* @brief 治療終了了時の投薬処理
* @param[in,out] ptr 装置制御データ
* @details 治療終了時の投薬実施、投与タイミング通知処理
*/
void *comsv_medicated_end(void *ptr)
{
	int ret;
	int i, j;
	char fpath[64];
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;

	// 仮想端末（投与薬剤）読み込み
	LcddataReq41_t req41;
	comsv_work_fpath(scn->dev_no, WORK_LCD_REQ41, fpath);
	ret = comsv_json_lcd_req41(fpath, &req41);
	printf("comsv_json_lcd_req41 = [%d]\n", ret);
	
	for ( i = 0; i <= req41.count; i++ ) {
		// mod FNSI-バグ 通信サーバ 高 start
		// if ( memcmp(req41.progress[i], "003", 3) == 0 ) {
		if ( memcmp(req41.progress[i], "003", 3) == 0 && req41.alert[i] == '1' ) {
		// mod FNSI-バグ 通信サーバ 高 end
			// 投与タイミングが透析終了＆お知らせ機能あり
			if ( req41.effectFlg[i] != '1' ) {
				// ディレイなしで投与タイミング通知
				scn->alert_time[i] = -99;
			}
		}
	}
	
	for ( i=0; i<ALERT_NUM; i++ ) {
		if ( scn->alert_time[i] == -99 ) continue;
		if ( scn->alert_time[i] < 0 ) continue;
		j = (scn->alert_time[i] * 60) + _comsvCache._comsvSet.notice_time;
		if ( get_time() < scn->dial_start_date + j) {
			scn->alert_time[i] = -99;
		}
	}
}
// add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end

/**
 * @fn void comsv_scn_output(struct scn_data_fm *sp)
 * @brief 装置制御データ（各種状態）のログ出力
 * @param[in,out] sp 装置制御データ
 */
void comsv_scn_output(struct scn_data_fm *sp) {
	u_char logMsg[256];

	sprintf(logMsg, "****** 装置番号[%ld] : 状態 [%02x]", sp->dev_no, sp->mon_sta);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : オーダ番号 [%ld]", sp->dev_no, sp->ord_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 患者ID [%ld]", sp->dev_no, sp->pat_id);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 次回オーダー番号 [%ld]", sp->dev_no, sp->next_ord_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 次患者ID [%ld]", sp->dev_no, sp->next_pat_id);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 条件送信管理番号 [%ld]", sp->dev_no, sp->cond_send_ctrl);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 条件送信時刻（コマンド送信時刻） [%ld]", sp->dev_no, sp->cond_send_time);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 条件送信日時 [%ld]", sp->dev_no, sp->cond_send_date);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 条件確認日時 [%ld]", sp->dev_no, sp->cond_set_date);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 条件送信フラグ（0:未送信,1:送信済） [%x]", sp->dev_no, sp->cond_send_flg);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 透析時間 [%d]", sp->dev_no, sp->dial_time);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 治療時間判定時間 [%d]", sp->dev_no, sp->facility_time);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 透析開始日時 [%ld]", sp->dev_no, sp->dial_start_date);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
	sprintf(logMsg, "****** 装置番号[%ld] : 透析終了日時 [%ld]", sp->dev_no, sp->dial_end_date);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
}

/**
* @fn bool check_time_setting(char *LastTime)
* @brief 一斉時刻合わせチェック（新通信用）
* @param[in,out] LastTime 前回一斉時刻合わせ日時
* @return true 実施対象
* @return false 実施対象外
*/
bool check_time_setting(char *LastTime) {
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

// #9110 2023.08.09 add VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 start
/**
 * @fn int getMachineIsVa(short dev_idx)
 * @brief 装置の画像転送可否を取得
 * @param[in] devIdx 装置マスタINDEX
 * @return 1：画像を転送する/0：画像を転送しない
*/
int getMachineIsVa(short devIdx) {
	int Ret = 0;

	if ( devIdx > 0 && _machineInfoData[devIdx - 1].hasVa == '1' ) Ret = 1;

	return Ret;
}
// #9110 2023.08.09 add VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 end

// #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
/**
 * @fn int checkMachineIsVa(struct scn_data_fm *sp)
 * @brief 装置の画像転送可否チェック
 * @param[in] sp 装置制御データ
 * @return -2:対象外 -1:100NX以前 0:画像転送なし 1：画像転送あり
*/
int checkMachineIsVa(struct scn_data_fm *sp) {
	int ret = -2;

    if ( sp->devsw != 'I' && sp->devsw != 'J' ) {
        // 装置が’I’,’J’以外
        if ( ntss_mst_type_chack(sp->deviceType) > 0 ) { 
            // 100NX以降の装置
            ret = 0;
		    if ( getMachineIsVa(sp->dev_idx) ) {
			    // 画像転送設定が有効
                ret = 1;
            }
        }
    }
    return ret;
}
// #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
