/**
* @file sock_stream_cp.c
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
#include "ntss_sock.h"
#include "ntss_packet_manage.h"
#include "ntss_common_comm.h"
#include "ntss_devicecap_conf.h"

/**
* @fn void *sock_stream_cp(void *ptr)
* @brief 共通プロトコル通信用スレッド処理
* @param[in,out] ptr 装置制御データ
* @return void* 
*/
void *sock_stream_cp(void *ptr) {
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long connect_tim = 0;
	//long req_last_time = 0;
	time_t connect_tim = 0;
	time_t req_last_time = 0;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	struct connect_socket *conSock = (struct connect_socket *) ptr;
	u_char logMsg[256];
	char TimeSet_LastTime[20] = "";	// 前回一斉時刻合わせ日時
	struct NTSS_PACKET_INFORMATION *pInfo;

    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//extern bool sock_communication_cp(struct connect_socket *conSock, long *z_tim);
	extern bool sock_communication_cp(struct connect_socket *conSock, time_t *z_tim);
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	extern bool sock_connect_cp(struct connect_socket *conSock);
	extern bool sock_connect_check_cp(struct connect_socket *conSock);
	extern void sock_connect_close_cp(struct connect_socket *conSock);
	extern void sock_socket_error_cp(struct connect_socket *conSock);
	extern bool check_is_target_device_cp(u_char *commFormat, u_char *deviceCode, u_char *ip, short *port, struct scn_data_fm *scn);
	extern bool check_time_setting_cp(char *LastTime);

	conSock->running = true;
	conSock->scn.staflg = S_WAIT;
	conSock->scn.err_ztime = 0;
	
	// パケット管理情報クリア
    memset(&packetInfoList[conSock->thread_no], 0, sizeof(struct NTSS_PACKET_INFORMATION));

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	sprintf(logMsg, "通信スレッドCP[%d] : 起動", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);

	for ( ; ; usleep(2000000) ) {

		if ( conSock->running == false ) {
			break;
		}

		// マスタ更新チェック
		if ( conSock->mst_reload == true ) {
			sprintf(logMsg, "通信スレッドCP[%d] : マスタ更新", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			if ( check_is_target_device_cp(&(conSock->scn.devsw), &(conSock->scn.devid[0]), conSock->scn.ip_addr, &(conSock->scn.port_no), &(conSock->scn)) == false ) {
				sprintf(logMsg, "通信スレッドCP[%d] : マスタ一致対象装置なし", conSock->thread_no);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				sock_socket_error_cp(conSock);
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
			if ( sock_connect_cp(conSock) == true ) {
				printf("通信スレッドCP[%d] : コネクション処理開始\n", conSock->thread_no);
			}
			connect_tim = get_time();
		}
 		// コネクション完了確認（共通プロトコル通信接続用）
		if ( sock_connect_check_cp(conSock) == true ) {
			printf("通信スレッドCP[%d] : コネクション処理完了\n", conSock->thread_no);

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
			// ホスト報知監視設定初期化
            initNTSSHostWatchConf(pInfo);
		}

		/**
		 * 共通プロトコル通信処理
		 */
		if ( conSock->scn.conflg == 2 ) {
			if ( sock_communication_cp(conSock, &req_last_time) == false ) {
				// パケット管理情報初期化
			    finNTSSPacketInfo(&packetInfoList[conSock->thread_no]);
				//break;
				// スレッドは終了しない
			}
		}
	}

	// ソケットクローズ処理（共通プロトコル通信接続用）
	sock_connect_close_cp(conSock);

	// パケット管理情報初期化
    finNTSSPacketInfo(&packetInfoList[conSock->thread_no]);

	sprintf(logMsg, "通信スレッドCP[%d] : 終了", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	conSock->running = false;
	conSock->using = false;
	pthread_exit((void *)0); // スレッド終了
}

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
//* @fn bool sock_communication_cp(struct connect_socket *conSock, long *z_tim)
//* @brief 共通プロトコルソケット送受信処理
//* @param[in,out] conSock 装置制御データ
//* @param[in,out] z_tim 前回リクエスト時間
//* @return true 正常
//* @return false エラー
//*/
//bool sock_communication_cp(struct connect_socket *conSock, long *z_tim) {
/**
* @fn bool sock_communication_cp(struct connect_socket *conSock, time_t *z_tim)
* @brief 共通プロトコルソケット送受信処理
* @param[in,out] conSock 装置制御データ
* @param[in,out] z_tim 前回リクエスト時間
* @return true 正常
* @return false エラー
*/
bool sock_communication_cp(struct connect_socket *conSock, time_t *z_tim) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	int ret;
	int i, len;
	fd_set fd, fdw;
	uint16_t sel_ret = 0;
	struct timeval seltime;
	u_char *dp,crc;
	u_char sum[10];
	u_char logMsg[256];
	u_char buf[RCVMAX];
	struct NTSS_PACKET_INFORMATION *pInfo;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    struct timespec myTime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

	extern void sock_socket_error_cp(struct connect_socket *conSock);

	sel_ret = 0;
	if ( conSock->scn.staflg != S_ETX ) {
		// 新通信装置受信チェック
		if ( conSock->scn.conflg <= 0 ) {
			sock_socket_error_cp(conSock);			// ソケットエラー処理
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
			sock_socket_error_cp(conSock);			// ソケットエラー処理
			return false;
		}
		// 受信データ処理
		sock_rcvset_cp(&(conSock->scn),buf, ret);
	}
	else {
		// 受信データ無し
		if ( get_time() >= (*z_tim + req_time_cp) && conSock->scn.comflg == C_NOTOPE ) {
			//	リクエストコマンド発行
			conSock->scn.reqflg[C_MONITOR] = 1;
			conSock->scn.staflg = S_WAIT;
			*z_tim = get_time();	// 前回リクエスト送信時間
		}
		else if ( conSock->scn.err_ztime ) {
			if ( get_time() > conSock->scn.err_ztime + configParam.deviceTimeout ) {
				// タイムアウト
				sprintf(logMsg, "通信スレッドCP[%d] : 通信タイムアウト[%02x]", conSock->thread_no, conSock->scn.staflg);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				sock_socket_error_cp(conSock);			// ソケットエラー処理
				return false;
			}
		}
		else {
			conSock->scn.err_ztime = get_time();
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
		}
		if ( ret == 0 ) {
			/* 正常終了 */
			conSock->scn.staflg = S_END; 
			conSock->scn.conflg = 2; 
		}
		else {
			conSock->scn.staflg = ret;
		}
	}

	/* 正常受信データ処理 */
	if ( conSock->scn.staflg == S_END ) {

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
		ret = checkNTSSCommonCommand(pInfo);
		if ( ret != 0 ) {
			sprintf(logMsg, "通信スレッドCP[%d] : 電文ファイル出力[%d]", conSock->thread_no, ret);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		}
		if ( conSock->scn.comflg && conSock->scn.comflg != C_RESPONSE ) {
			conSock->scn.reqflg[conSock->scn.comflg] = 0;
		}
		conSock->scn.staflg = S_WAIT;
		conSock->scn.err_ztime = 0;
	}
	else if ( conSock->scn.conflg >0 && (conSock->scn.staflg & S_END) ) {	
		sprintf(logMsg, "通信スレッドCP[%d] : 受信データ異常[%02x]", conSock->thread_no, conSock->scn.staflg);
		LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		sock_socket_error_cp(conSock);			// ソケットエラー処理
		return false;
	}

	/* 送信コマンド作成 */
	if ( conSock->scn.staflg == S_WAIT && conSock->scn.conflg > 0 ) {
		if ( conSock->scn.comflg != C_RESPONSE ) {
			for ( i = 1, conSock->scn.comflg = C_NOTOPE; i <= C_MONITOR; i++ ) {
				if ( conSock->scn.reqflg[i] ) {
					conSock->scn.comflg = i;
					conSock->scn.reqflg[i] = 0;
					break;
				}
			}
		}
		if ( conSock->scn.comflg == C_NOTOPE ) {
			// 残り受信データ処理
			sock_rcvset_cp(&(conSock->scn),(char*)0, 0);
			return true;
		}
		
		ret = sock_cmd_cp(conSock->thread_no, &(conSock->scn));
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
		if ( sel_ret > 0 && FD_ISSET(conSock->scn.sock_id,&fdw) ) {
			// 書き込み
			ret = write(conSock->scn.sock_id, conSock->scn.sndbuf, conSock->scn.sndlen);
		}
		if ( ret <= 0 ) {
			// 失敗
			sprintf(logMsg, "通信スレッドCP[%d] : 書き込み失敗[%d]", conSock->thread_no, (int)ret);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			sock_socket_error_cp(conSock);			// ソケットエラー処理
			return false;
		} else {
			//ioctl(conSock->scn.sock_id, I_FLUSH, FLUSHRW);
			conSock->scn.staflg = S_WAIT;
			conSock->scn.err_ztime = 0;
		}
	}

	// 残り受信データ処理
	sock_rcvset_cp(&(conSock->scn),(char*)0, 0);

	return true;
}

/**
* @fn bool sock_connect_cp(struct connect_socket *conSock)
* @brief コネクション処理（共通プロトコル通信接続用）
* @param[in,out] conSock 装置制御データ
* @return true 正常
* @return false エラー
*/
bool sock_connect_cp(struct connect_socket *conSock) {
	bool ret = false;
	int sfd;	// ソケットファイルディスクプリタ
	int val = 1;
	struct sockaddr_in saddr;

	extern void sock_connect_close_cp(struct connect_socket *conSock);

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
		sock_connect_close_cp(conSock);
	}

	return ret;
}

/**
* @fn bool sock_connect_check_cp(struct connect_socket *conSock)
* @brief コネクション完了確認（共通プロトコル通信接続用）
* @param[in,out] conSock 装置制御データ
* @return true コネクション完了
* @return false コネクション中
*/
bool sock_connect_check_cp(struct connect_socket *conSock) {
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
* @fn void sock_connect_close_cp(struct connect_socket *conSock)
* @brief コネクション切断処理（共通プロトコル通信接続用）
* @param[in,out] conSock 装置制御データ
*/
void sock_connect_close_cp(struct connect_socket *conSock) {
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
* @fn void sock_socket_close_cp(struct connect_socket *conSock)
* @brief ソケットクローズ処理（共通プロトコル通信接続用）
* @param[in,out] conSock 装置制御データ
*/
void sock_socket_close_cp(struct connect_socket *conSock) {
	sock_connect_close_cp( conSock );

	conSock->running = false;
	/* 通信制御データクリア */
	memset(&conSock->scn, 0, sizeof(struct scn_data_fm));
}

/**
* @fn void sock_socket_error_cp(struct connect_socket *conSock)
* @brief ソケットエラー処理（共通プロトコル通信用）
* @param[in,out] conSock 装置制御データ
*/
void sock_socket_error_cp(struct connect_socket *conSock) {
	// ソケットクローズ処理（共通プロトコル通信接続用）
	sock_connect_close_cp(conSock);
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

	for ( idx = 0; idx < COUNTOF(_machineInfoData); idx++ ) {
		if ( _machineInfoData[idx].machineFormatCd == '\0' ) {
			// これ以降マスタデータなし
			break;
		}
		// マスタ構造体のIPアドレス・ポート番号は末尾に\0がないため文字列として扱えない
		strncpy(mstIpAddr, _machineInfoData[idx].ipAddress, 15);
		strncpy(mstPortNo, _machineInfoData[idx].strport, 5);

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
			// 突き合わせ成功
			matchMst = true;
			break;
		}
	}
	return matchMst;
}

/**
 * @fn void sock_rcvset_cp(struct scn_data_fm *sp, u_char *buf, int len)
 * @brief 受信データ解析処理（共通プロトコル用）
 * @param[in,out] sp 装置制御データ
 * @param[in] buf 受信データ 
 * @param len 受信データ長
 */
void sock_rcvset_cp(struct scn_data_fm *sp, u_char *buf, int len) {
	int i, n;
	u_char *dp, rc;
	u_char *bufp, zbuf[RCVMAX];

	if ( len == 0 ) {	/* 残りの受信データの取り込み */
		if ( sp->zanlen<=0 ) {
            return;
        }
        len = sp->zanlen;
		memcpy(zbuf, sp->rcvbuf + sp->zanp, len);
		bufp = zbuf;
		sp->zanlen = 0;
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
					sp->zanp = sp->rcvlen;
					sp->zanlen = len - i;
					bufp++;
					memcpy(dp, bufp, sp->zanlen);
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

	if ( configParam.timesetTime[0] == 0 ) {
		// 設定なし
		return Ret;
	}

	time_str(get_time(), bufDate, bufTime, 1);
	if ( *LastTime == 0 ) {
		// 初回起動時
		sprintf(LastTime, "%s %s", bufDate, bufTime);
		//printf("初回起動時 : [%s]\n",LastTime);
		//printf("設定日時   : [%s %s   ]\n",bufDate, configParam.timesetTime);
		return Ret;
	}

	// 現在日時
	sprintf(bufNow, "%s %s", bufDate, bufTime);
	// 設定日時
	sprintf(bufConf, "%s %.5s   ", bufDate, configParam.timesetTime);

	if ( strcmp(LastTime, bufConf) < 0 && strcmp(bufConf, bufNow) < 0 ) {
		// 前回一斉時刻合わせ日時 < 設定日時 かつ 設定日時 < 現在日時
		// 前回一斉時刻合わせ日時 に 現在日時 をセット
		//printf("一斉時刻合わせ : [%s]<[%s]<[%s]\n",LastTime,bufConf,bufNow);
		strcpy(LastTime, bufNow);
		Ret = true;
	}

	return Ret;
}
