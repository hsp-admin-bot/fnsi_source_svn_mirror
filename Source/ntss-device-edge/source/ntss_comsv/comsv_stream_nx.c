/**
* @file comsv_stream_nx.c
* @brief NX通信用処理関連
* @author Y.Takamura
* @date 2018/11/07
* @details NX通信用の処理を行う
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
* @fn void *comsv_stream_nx(void *ptr)
* @brief NX通信用スレッド処理
* @param[in,out] ptr 装置制御データ
* @return void* 
*/
void *comsv_stream_nx(void *ptr) {
	struct connect_socket *conSock = (struct connect_socket *) ptr;
	struct connect_socket reqSock;
	fd_set fd;
	short cmd;
	struct timeval seltime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    struct timespec myTime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	int ret;
	int i, j;
	int val = 1;
	// #10114 2023.12.14 add 装置検索登録（装置情報作成モード）でNX通信装置が検出されない TDC高村 start
	int matchMst;
	// #10114 2023.12.14 add 装置検索登録（装置情報作成モード）でNX通信装置が検出されない TDC高村 end
	u_char logMsg[256], logSubMsg[64];
	u_char utf16[32], sjis[16];
	// #8266 2023.03.20 mod バッファサイズを変更 TDC高村 start
	//u_char wrk[RCVMAX*2];
	//u_char buf[RCVMAX*2];
	u_char wrk[RCVMAX];
	u_char buf[RCVMAX];
	// #8266 2023.03.20 mod バッファサイズを変更 TDC高村 end
	struct sockaddr_in serv;
	socklen_t len;
	short port_no;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long connect_tim = 0;
	time_t connect_tim = 0;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	u_char *ip, ips[32];
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long now = get_time();
	time_t now = get_time();
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	char fpath[64];
	char TimeSet_LastTime[20] = "";	// 前回一斉時刻合わせ日時
	struct NTSS_PACKET_INFORMATION *pInfo;

	extern bool comsv_communication_nx(struct connect_socket *conSock);
	extern bool comsv_connect_nx(struct connect_socket *conSock);
	extern bool comsv_connect_check_nx(struct connect_socket *conSock);
	extern void comsv_connect_close_nx(struct connect_socket *conSock);
	extern void comsv_socket_error_nx(struct connect_socket *conSock);
	extern int check_is_target_device_nx(u_char *commFormat, u_char *deviceCode, u_char *ip, short *port, struct scn_data_fm *scn);
	extern bool check_time_setting_nx(char *LastTime);

	bool isTimeSet = false;
	conSock->running = true;
	// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知(初期値true) TDC片口 start
	conSock->is_update_comm_fail_from_main = true;
	int lastResultUpdateCommFail = 0;
	// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知(初期値true) TDC片口 end

	// パケット管理情報クリア
	memset(&packetInfoList[conSock->thread_no], 0, sizeof(struct NTSS_PACKET_INFORMATION));

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	sprintf(logMsg, "通信スレッドNX[%d] : 起動", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);

	// 収集対象か否かをチェックする処理
	for ( ; ; usleep(100000) ) {

		if ( conSock->running == false ) {
			break;
		}
		if ( get_time() > now + _comsvCache._comsvSet.device_timeout ) {
			// タイムアウト
			sprintf(logMsg, "通信スレッドNX[%d] : 通信タイムアウト 1", conSock->thread_no);
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
			sprintf(logMsg, "通信スレッドNX[%d] : データリードエラー ", conSock->thread_no);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			close(conSock->accept_socket);
			conSock->accept_socket = (-1);
			conSock->running = false;
			break;
		}
		len = sizeof(serv);
		if ( getpeername(conSock->accept_socket,(struct sockaddr *)&serv, &len) < 0 ) {
			sprintf(logMsg, "通信スレッドNX[%d] : getpeernameエラー ", conSock->thread_no);
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

		memset(utf16, 0, sizeof(utf16));
		memset(sjis, 0, sizeof(sjis));
		memcpy(utf16, &wrk[5], 16);
		utf16Btosjis(utf16, 16, sjis);
		strcpy(logSubMsg, sjis);
		str_trim(logSubMsg);
		cmd = hl_chg(*(short*)(wrk+23));
		sprintf(logMsg, "通信スレッドNX[%d] : 装置=[%c%s] IPアドレス=[%s] cmd=[%04x]", conSock->thread_no, wrk[3], logSubMsg, ips, cmd);
		LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		
		// A,D,I,J,Rの装置のみ
		if ( wrk[3] == 'A' || wrk[3] == 'D' || wrk[3] == 'I' || wrk[3] == 'J'|| wrk[3] == 'R' ) {
			
			// 機器マスタとの突き合わせ			
			if ( wrk[3] != 'R' ) {
				memmove(sjis, sjis+1, 7);
				sjis[7] = ' ';
				sjis[8] = 0;
			}
			i = check_is_target_device_nx(&wrk[3], sjis, ips, &port_no, &(conSock->scn));
			if ( i < 0 ) {
				// 一致するマスタがなかったら閉じる
				sprintf(logMsg, "通信スレッドNX[%d] : マスタ一致対象装置なし", conSock->thread_no);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				close(conSock->accept_socket);
				conSock->accept_socket = (-1);
				conSock->running = false;
				break;				
			}
			// #10114 2023.12.14 add 装置検索登録（装置情報作成モード）でNX通信装置が検出されない TDC高村 start
			matchMst = i;
			// #10114 2023.12.14 add 装置検索登録（装置情報作成モード）でNX通信装置が検出されない TDC高村 end
			
			// add FNSI-バグ 通信サーバ 高 start
			// 5s
			struct timespec timeReqSleep = {5, 0};
			while (nanosleep(&timeReqSleep, &timeReqSleep) == -1 && errno == EINTR) {}
			// add FNSI-バグ 通信サーバ 高 end

			// 対応付け
			conSock->scn.sock_id = conSock->accept_socket;
			conSock->scn.conflg = 2;
			strcpy(conSock->scn.ip_addr, ips);
			conSock->scn.port_no = 0;	// SVソケットの場合は0
			conSock->scn.commType = NTSS_COMM_TYPE_NX;
			conSock->scn.devsw = wrk[3];
			memcpy(conSock->scn.devid, sjis, 8);
			conSock->scn.staflg = S_WAIT;
			conSock->scn.err_ltime = 0;
			comsv_rcvset(&(conSock->scn),buf, ret);

			if ( conSock->scn.dev_no != 0 ) {
				// 作業データ用装置番号フォルダ作成
				comsv_work_mkdir_dev(conSock->scn.dev_no);

				// 装置状態管理データを取得
				comsv_work_fpath(conSock->scn.dev_no, WORK_DEV_STATE, fpath);
				i = comsv_rest_get_dev(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, fpath);
				printf("comsv_rest_get_dev = [%d]\n", i);
				i = comsv_json_dev_state(fpath, -1, &(conSock->scn));
				printf("comsv_json_dev_state = [%d]\n", i);
				// 初回起動時の装置ステータスをセット
				conSock->scn.first_sta = conSock->scn.mon_sta;
			}

 			// NTSSパケット管理情報に必要な情報をセットする
			pInfo = &packetInfoList[conSock->thread_no];
			memcpy(pInfo->cDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
			pInfo->cDeviceFormat = conSock->scn.devsw;
			memcpy(pInfo->cDeviceNo, conSock->scn.devid, sizeof(conSock->scn.devid));
			pInfo->cCommType = NTSS_COMM_TYPE_NX;
			pInfo->sourceAddr = inet_addr(conSock->scn.ip_addr);
			pInfo->isConnected = 0x01;
			pInfo->isNeedSendProcess = 0x01;
			// add FNSI-バグ 通信サーバ 高 start
			switch(conSock->scn.devsw) {
			case 'A':
				pInfo->nProcess[0] = 9;
				break;
			case 'D':
				pInfo->nProcess[0] = 5;
				break;
			case 'I':
				pInfo->nProcess[0] = 6;
				break;
			case 'J':
				pInfo->nProcess[0] = 9;
				break;
			case 'R':
				pInfo->nProcess[0] = 5;
				break;
			default:
				pInfo->nProcess[0] = 5;
			}
			pInfo->nProcess[1] = 95;
			// add FNSI-バグ 通信サーバ 高 end
			pInfo->nMoniDataSize = 0;
			// ホスト報知監視設定初期化
			initNTSSHostWatchConf(pInfo);

			// #10114 2023.12.14 mod 装置検索登録（装置情報作成モード）でNX通信装置が検出されない TDC高村 start
			//if ( ret == 1 ) {
			if ( matchMst == 1 ) {
			// #10114 2023.12.14 mod 装置検索登録（装置情報作成モード）でNX通信装置が検出されない TDC高村 end
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

			// NX通信接続用データ作成
			memcpy(&reqSock, conSock, sizeof(struct connect_socket));
			memset(&reqSock.scn, 0, sizeof(reqSock.scn));
			strcpy(reqSock.scn.ip_addr, conSock->scn.ip_addr);
			reqSock.scn.port_no = port_no;	// CLソケットの場合はマスタ指定 
			reqSock.scn.devsw = conSock->scn.devsw;
			memcpy(reqSock.scn.devid,conSock->scn.devid, 8);

			break;
		}
	}
	// 接続対象かどうかのチェックと確立を完了

	if ( conSock->running == false ) {
		// 終了
		sprintf(logMsg, "通信スレッドNX[%d] : 終了 1", conSock->thread_no);
		LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		conSock->using = false;
		// add FNSI-バグ 通信サーバ 高 start
		memset(conSock->event, '\0', sizeof(conSock->event));
		// add FNSI-バグ 通信サーバ 高 end
		pthread_exit((void *)0); // スレッド終了
	}

	for ( ; ; ) {

		if ( conSock->running == false ) {
			break;
		}

		// マスタ更新チェック
		if ( conSock->mst_reload == true ) {
			sprintf(logMsg, "通信スレッドNX[%d] : マスタ更新", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			i = conSock->scn.dev_idx;
			if ( check_is_target_device_nx(&(conSock->scn.devsw), &(conSock->scn.devid[0]), conSock->scn.ip_addr, &port_no, &(conSock->scn)) != 0 ) {
				sprintf(logMsg, "通信スレッドNX[%d] : マスタ一致対象装置なし", conSock->thread_no);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				comsv_socket_error_nx(conSock);
				break;
			}
			sprintf(logMsg, "通信スレッドNX[%d] : マスタ更新完了", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			reqSock.scn.port_no = port_no;
			conSock->mst_reload = false;
			pInfo = &packetInfoList[conSock->thread_no];
			memcpy(pInfo->cDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
			if ( pInfo->sourceAddr == 0 && conSock->scn.ip_addr ) {
				// 空の場合、再セットする
				pInfo->sourceAddr = inet_addr(conSock->scn.ip_addr);
				if ( i == 0 && conSock->scn.dev_no != 0 ) {
					// 作業データ用装置番号フォルダ作成
					comsv_work_mkdir_dev(conSock->scn.dev_no);
				}
			}
		}

		if ( get_time() > connect_tim + CONTIME ) {
 			// コネクション処理（NX通信接続用）
			if ( comsv_connect_nx(&reqSock) == true ) {
				printf("通信スレッドNX[%d] : コネクション処理開始\n", reqSock.thread_no);
			}
			connect_tim = get_time();
		}
 		// コネクション完了確認（NX通信接続用）
		if ( comsv_connect_check_nx(&reqSock) == true ) {
			printf("通信スレッドNX[%d] : コネクション処理完了\n", reqSock.thread_no);
			reqSock.scn.err_ltime = 0;
		}

		// 一斉時刻合わせチェック
		if ( check_time_setting_nx(TimeSet_LastTime) == true ) {
			isTimeSet = true;
		}

		// 一斉時刻合わせ要求
		if ( isTimeSet == true && reqSock.scn.staflg == S_WAIT ) {
			printf("通信スレッドNX[%d] : 一斉時刻合わせ\n", reqSock.thread_no);
			isTimeSet = false;
			reqSock.scn.comflg = C_CLOCK;
			// 送信コマンド作成
			ret = comsv_cmd_nx(&(reqSock.scn)); // コマンド作成
			if ( ret > 0 ) {
				reqSock.scn.comflg = C_NOTOPE;
				reqSock.scn.staflg = S_SEND;
			}
		}

		// イベント有無チェック
		for ( i = 0; i < EVENT_MAX; i++ ) {
			if ( conSock->event[i] == 0x01 ) {
				conSock->event[i] = 0x00;
				if ( i == 1 ) {
					// 装置オプション読出を要求
					sprintf(logMsg, "通信スレッドNX[%d] : イベント（装置オプション読出）", conSock->thread_no);
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					reqSock.scn.comflg = C_OPTRD;
					// 送信コマンド作成
					ret = comsv_cmd_nx(&(reqSock.scn)); // コマンド作成
					if ( ret > 0 ) {
						reqSock.scn.comflg = C_NOTOPE;
						reqSock.scn.staflg = S_SEND;
					}
				}
			}
		}

		/**
		 * NX通信処理
		 */
		if ( comsv_communication_nx(conSock) == false ) {
			break;
		}
		if ( reqSock.scn.conflg == 2 ) {
			if ( comsv_communication_nx(&reqSock) == false ) {
				//break;
				// スレッドは終了しない
			}
		}

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

	// ソケットクローズ処理（NX通信接続用）
	comsv_connect_close_nx(&reqSock);

	// パケット管理情報初期化
	if ( conSock->scn.devsw != 'I' && conSock->scn.devsw != 'J' ) {
		finNTSSPacketInfo(&packetInfoList[conSock->thread_no]);
	}

	sprintf(logMsg, "通信スレッドNX[%d] : 終了 2", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	conSock->running = false;
	conSock->using = false;
	// add FNSI-バグ 通信サーバ 高 start
	memset(conSock->event, '\0', sizeof(conSock->event));
	// add FNSI-バグ 通信サーバ 高 end
	pthread_exit((void *)0); // スレッド終了
}

/**
* @fn bool comsv_communication_nx(struct connect_socket *conSock)
* @brief NX通信用ソケット送受信処理
* @param[in,out] conSock 装置制御データ
* @return true 正常
* @return false エラー
*/
bool comsv_communication_nx(struct connect_socket *conSock) {
	int i, sndlen;
	fd_set fd, fdw;
	uint16_t sel_ret = 0;
	struct timeval seltime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    struct timespec myTime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	int ret;
	unsigned char *dp, *bp, crc;
	unsigned char logMsg[256];
	// #8266 2023.03.20 mod バッファサイズを変更 TDC高村 start
	//u_char buf[RCVMAX*2];
	unsigned char buf[RCVMAX];
	// #8266 2023.03.20 mod バッファサイズを変更 TDC高村 end
	struct NTSS_PACKET_INFORMATION *pInfo;

	extern void comsv_socket_error_nx(struct connect_socket *conSock);

	sel_ret = 0;
	if ( conSock->scn.staflg != S_ETX ) {
		// 新通信装置受信チェック
		if ( conSock->scn.conflg <= 0 ) {
			comsv_socket_error_nx(conSock);
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
			sprintf(logMsg, "通信スレッドNX[%d] : ソケットREAD 失敗 [%d] [%d][%s]", conSock->thread_no, ret, errno, strerror(errno));
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			// #11490 2025.02.26 add ソケットREAD失敗時、戻り値及びエラー内容をログ出力 end
			comsv_socket_error_nx(conSock);
			return false;
		}
		// 受信データ処理
		comsv_rcvset(&(conSock->scn), buf, ret);
	}
	else {
		// 受信データ無し
		if ( conSock->scn.err_ltime ) {
			if ( get_time() > conSock->scn.err_ltime + _comsvCache._comsvSet.device_timeout ) {
				if ( conSock->scn.port_no == 0 ) {
					// ソケットクローズ処理（NX通信待受用）
					// タイムアウト
					sprintf(logMsg, "通信スレッドNX[%d] : 通信タイムアウト 3[%d]", conSock->thread_no, conSock->scn.port_no);
					LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					comsv_socket_error_nx(conSock);
					return false;
				}
				else {
					// ソケットクローズ処理（NX通信接続用）
					// タイムアウトしない
					//LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					conSock->scn.err_ltime = 0;
				}
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
		conSock->scn.rcvlen--;	// SUM分を除く
		for ( i=0, crc=0; i < conSock->scn.rcvlen; i++, dp++ ) {
			crc += (*dp);
		}
		if ( crc != *dp ) {
			ret = E_CRCCHK;

			// #12304 2025.10.24 add ログ強化（CRCエラー） TDC片口 start
			sprintf(logMsg, "通信スレッドNX[%d] : CRCエラー CRC=[%02x] 計算値=[%02x] 前回CMD=[%02x] データ長=%d",
				conSock->thread_no, *dp, crc, conSock->scn.cmd, conSock->scn.rcvlen + 1);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);

			sprintf(logMsg, "通信スレッドNX[%d] : 受信データ", conSock->thread_no);
			LogOutputsHexDump(NTSS_LOG_ERROR, logMsg, conSock->scn.rcvbuf, conSock->scn.rcvlen + 1,
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
			
		pInfo = &packetInfoList[conSock->thread_no];
        // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
		//gettimeofday(&pInfo->buffer.lastReceiveTime, NULL);
        clock_gettime(CLOCK_REALTIME, &myTime);
        pInfo->buffer.lastReceiveTime.tv_sec = myTime.tv_sec;
        pInfo->buffer.lastReceiveTime.tv_usec = myTime.tv_nsec / 1000;
        // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
		if ( conSock->scn.dev_idx && getCreateMachineInfoMode() == false ) {
			// 通常モード
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
			*dp++=ETX; sndlen++;
			pInfo->buffer.nBufferSize = sndlen;
			// add 強制オフライン 高 start
			pInfo->force_flg = conSock->scn.force_flg;
			// add 強制オフライン 高 end
			ret = checkNTSSNKKCommand(pInfo);
			if ( ret != 0 ) {
				sprintf(logMsg, "通信スレッドNX[%d] : 電文ファイル出力[%d]", conSock->thread_no, ret);
				LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			}
			// add 装置のSTATUS状態更新方法の変更 高 start
			conSock->scn.machineState[0] = conSock->scn.rcvbuf[26];
			if( conSock->scn.machineState[0] != conSock->scn.machineState[1] ) {
				i = comsv_rest_put_machineState(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid, conSock->scn.machineState[0]);
				printf("comsv_rest_put_machineState = [%d]\n", i);
				
				conSock->scn.machineState[1] = conSock->scn.machineState[0];
			}
			// add 装置のSTATUS状態更新方法の変更 高 end
		}
			
		/* NX通信装置からのコマンド受信 */
		conSock->scn.cmd = hl_chg(*(short*)(conSock->scn.rcvbuf + 22));
		conSock->scn.mon_sta = *(short*)(conSock->scn.rcvbuf + 26);
		if ( conSock->scn.first_sta >= 0 ) {
			// 初回ステータスチェック
			if ( conSock->scn.first_sta != conSock->scn.mon_sta ) {
				// 初回起動時の装置ステータスから変化がある場合
				comsv_json_dev_status(buf, &(conSock->scn));
				// 装置状態管理の装置ステータス更新処理
				ret = comsv_rest_post_all_status(buf);
				printf("comsv_rest_post_all_status = [%d]\n", ret);
			}
			conSock->scn.first_sta = -1;
		}

		if ( conSock->scn.port_no == 0 ) {
 			// NX通信待受用処理
			conSock->scn.comflg = C_RESPONSE;
			/* 送信コマンド作成 */
			ret = comsv_cmd_nx(&(conSock->scn)); /* コマンド作成 */
			if ( ret > 0 ) {
				conSock->scn.comflg = C_NOTOPE;
				conSock->scn.staflg = S_SEND;
			}
		}
		else {
			// NX通信接続用処理
			conSock->scn.staflg = S_WAIT;
			conSock->scn.err_ltime = 0;
		}
	}
	else if ( conSock->scn.conflg > 0 && (conSock->scn.staflg & S_END) ) {	
		sprintf(logMsg, "通信スレッドNX[%d] : 受信データ異常[%02x]", conSock->thread_no, conSock->scn.staflg);
		LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);			
		comsv_socket_error_nx(conSock);	/* エラー受信処理 */
		return false;
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
		if ( sel_ret <= 0 ) {
			if ( conSock->scn.err_ltime ) {
				if ( get_time() > conSock->scn.err_ltime + _comsvCache._comsvSet.device_timeout ) {
					// タイムアウト
					sprintf(logMsg, "通信スレッドNX[%d] : 通信タイムアウト 4", conSock->thread_no);
					LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
					comsv_socket_error_nx(conSock);
					return false;
				}
			}
			else {
				conSock->scn.err_ltime = get_time();
			}
		}
		if ( FD_ISSET(conSock->scn.sock_id, &fdw) ) {
			// 書き込み
			ret = write(conSock->scn.sock_id, conSock->scn. sndbuf, conSock->scn.sndlen);
		}
		if ( ret <= 0 ) {
			// 失敗
			sprintf(logMsg, "通信スレッドNX[%d] : 書き込み失敗[%d]", conSock->thread_no, (int)ret);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			comsv_socket_error_nx(conSock);
			return false;
		} else {
			//ioctl(conSock->scn.sock_id, I_FLUSH, FLUSHRW);
			conSock->scn.staflg = S_WAIT;
			conSock->scn.err_ltime = 0;
		}
	}

	// 残り受信データ処理
	comsv_rcvset(&(conSock->scn), (char*)0, 0);

	return true;
}

/**
* @fn bool comsv_connect_nx(struct connect_socket *conSock)
* @brief コネクション処理（NX通信接続用）
* @param[in,out] conSock 装置制御情報
* @return true 正常
* @return false エラー
*/
bool comsv_connect_nx(struct connect_socket *conSock) {
	bool ret = false;
	int sfd;	// ソケットファイルディスクプリタ
	int val = 1;
	struct sockaddr_in saddr;

	extern void comsv_connect_close_nx(struct connect_socket *conSock);

	if ( conSock->scn.sock_id == 0 && conSock->scn.conflg == 0 ) {
		// ソケットを作成（NX通信接続用）
		sfd = socket(AF_INET, SOCK_STREAM, 0);
		if ( sfd < 0 ) {
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
		// ソケットクローズ処理（NX通信接続用）
		comsv_connect_close_nx(conSock);
	}

	return ret;
}

/**
* @fn bool comsv_connect_check_nx(struct connect_socket *conSock)
* @brief コネクション完了確認（NX通信接続用）
* @param[in,out] conSock 装置制御情報
* @return true コネクション完了
* @return false コネクション中
*/
bool comsv_connect_check_nx(struct connect_socket *conSock) {
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
		if (rtn > 0) {
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
* @fn void comsv_connect_close_nx(struct connect_socket *conSock)
* @brief コネクション切断処理（NX通信接続用）
* @param[in,out] conSock 装置制御情報
*/
void comsv_connect_close_nx(struct connect_socket *conSock) {
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
* @fn void comsv_socket_close_nx(struct connect_socket *conSock)
* @brief ソケットクローズ処理（NX通信待受用）
* @param[in,out] conSock 装置制御情報
*/
void comsv_socket_close_nx(struct connect_socket *conSock) {
	u_char logMsg[256];

	if ( conSock->scn.conflg > 0 && conSock->accept_socket ) {
		// シャットダウン(送受信禁止)
		shutdown(conSock->accept_socket, 2);
		// ソケットクローズ
		//sprintf(logMsg, "通信スレッドNX[%d] : ソケットクローズ", conSock->thread_no);
		//LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		close(conSock->accept_socket);
		conSock->accept_socket = (-1);
		conSock->running = false;
	}
	memset(&conSock->scn, 0, sizeof(struct scn_data_fm));  /* 通信制御データクリア */
}

/**
* @fn void comsv_socket_error_nx(struct connect_socket *conSock)
* @brief ソケットエラー処理（NX通信用）
* @param[in,out] conSock 装置制御情報
*/
void comsv_socket_error_nx(struct connect_socket *conSock) {
	if ( conSock->scn.port_no == 0 ) {
 		// ソケットクローズ処理（NX通信待受用）
		comsv_socket_close_nx(conSock);
	}
	else {
		// ソケットクローズ処理（NX通信接続用）
		comsv_connect_close_nx(conSock);
	}
}

/**
 * @fn int check_is_target_device_nx(u_char *commFormatCd, u_char *deviceCode, u_char *ipAddr, short *port, struct scn_data_fm *scn)
 * @brief マスタとの突き合わせ（NX通信用）
 * @param[in] commFormatCd 通信フォーマット 
 * @param[in] deviceCode 製造番号
 * @param[in] ipAddr IPアドレス
 * @param[out] port ポート番号
 * @param[in,out] scn 装置制御データ
 * @return -1 マスタに存在しない
 * @return 0 突き合わせ成功
 * @return 1 装置情報作成モード
 */
int check_is_target_device_nx(u_char *commFormatCd, u_char *deviceCode, u_char *ipAddr, short *port, struct scn_data_fm *scn) {
	int matchMst = -1;
	uint16_t idx;
	char mstIpAddr[16] = {0};
	char mstPortNo[6] = {0};
	char mstDevNo[9] = {0};
	char mstOption[5] = {0};

	for ( idx = 0; idx < COUNTOF(_machineInfoData); idx++ ) {
		if ( _machineInfoData[idx].machineFormatCd == '\0' ) {
			// これ以降マスタデータなし
			break;
		}
		// マスタ構造体のIPアドレス・ポート番号は末尾に\0がないため文字列として扱えない
		strncpy(mstIpAddr, _machineInfoData[idx].ipAddress, 15);
		strncpy(mstPortNo, _machineInfoData[idx].strport, 5);
		strncpy(mstDevNo, _machineInfoData[idx].machineNo, 8);
		strncpy(mstOption, _machineInfoData[idx].machineOptine1, 4);

		if ( memcmp(commFormatCd, &(_machineInfoData[idx].machineFormatCd), 1) == 0	// 通信フォーマットが一致
			&& memcmp(deviceCode, &(_machineInfoData[idx].machineSerial), 8) == 0	// 製造番号が一致
			&& convertNTSSIPAddr(ipAddr) == convertNTSSIPAddr(mstIpAddr)			// IPアドレス一致
			&& _machineInfoData[idx].machineCommCd == NTSS_COMM_TYPE_NX) {			// 通信方式がNX通信
			// マスタに存在する
			scn->dev_idx = idx + 1;
			// ポート番号
			*port = atoi(mstPortNo);
			// 型式コード
 			memcpy(scn->deviceType, _machineInfoData[idx].machineTypeCd, 3);
			// 装置番号
			sscanf(mstDevNo, "%08lX", &scn->dev_no);
			// 装置オプション
			sscanf(mstOption, "%04hX", &scn->option[0]);
			// 突き合わせ成功
			matchMst = 0;
			break;
		}
	}

	if ( getCreateMachineInfoMode() == true ) {
		// 装置情報作成モード
		if ( matchMst != 0 ) {
			scn->dev_idx = 0;
			// ポート番号
			*port = 1401;
			// 型式コード
			memcpy(scn->deviceType, "000", 3);
		}
		matchMst = 1;		
	}

	return matchMst;
}

/**
* @fn bool check_time_setting_nx(char *LastTime)
* @brief 一斉時刻合わせチェック（NX通信用）
* @param[in,out] LastTime 前回一斉時刻合わせ日時
* @return true 実施対象
* @return false 実施対象外
*/
bool check_time_setting_nx(char *LastTime) {
	bool Ret = false;
	char bufNow[20];
	char bufConf[20];
	char bufDate[20];
	char bufTime[10];

	if ( _comsvCache._comsvSet.timeset_nx_time[0] == 0 ) {
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
	sprintf(bufConf, "%s %.5s   ", bufDate, _comsvCache._comsvSet.timeset_nx_time);

	if ( strcmp(LastTime, bufConf) < 0 && strcmp(bufConf, bufNow) < 0 ) {
		// 前回一斉時刻合わせ日時 < 設定日時 かつ 設定日時 < 現在日時
		// 前回一斉時刻合わせ日時 に 現在日時 をセット
		//printf("一斉時刻合わせ : [%s]<[%s]<[%s]\n",LastTime,bufConf,bufNow);
		strcpy(LastTime, bufNow);
		Ret = true;
	}

	return Ret;
}
