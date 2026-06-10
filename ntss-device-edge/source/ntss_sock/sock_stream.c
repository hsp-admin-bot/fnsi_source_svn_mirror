/**
* @file sock_stream.c
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
#include "ntss_sock.h"
#include "ntss_packet_manage.h"
#include "ntss_nkk_comm.h"
#include "ntss_devicecap_conf.h"

/**
* @fn void *sock_stream(void *ptr)
* @brief 新通信用スレッド処理
* @param[in,out] ptr 装置制御データ
* @return void* 
*/
void *sock_stream(void *ptr) {
	struct connect_socket *conSock = (struct connect_socket *) ptr;
	fd_set fd;
	struct timeval seltime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    struct timespec myTime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	int ret;
	int i, j;
	int val = 1;
	u_char logMsg[256], logSubMsg[64];
	u_char wrk[RCVMAX*2];
	u_char buf[RCVMAX*2];
	struct sockaddr_in serv;
    socklen_t len;
	u_char *ip, ips[32];
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long now = get_time();
	time_t now = get_time();
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	char TimeSet_LastTime[20] = "";	// 前回一斉時刻合わせ日時
	struct NTSS_PACKET_INFORMATION *pInfo;
	extern bool sock_communication(struct connect_socket *conSock);
	extern void sock_socket_error(struct connect_socket *conSock);
	extern int check_is_target_device(u_char *commFormat, u_char *deviceCode, u_char *ip, struct scn_data_fm *scn);
	extern bool check_time_setting(char *LastTime);

	conSock->running = true;

	// パケット管理情報クリア
    memset(&packetInfoList[conSock->thread_no], 0, sizeof(struct NTSS_PACKET_INFORMATION));

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	sprintf(logMsg, "通信スレッドNEW[%d] : 起動", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);

	// 収集対象か否かをチェックする処理
	for ( ; ; usleep(100000) ) {

		if ( conSock->running == false ) {
			break;
		}
		if ( get_time() > now + configParam.deviceTimeout ) {
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

			// 対応付け
			conSock->scn.sock_id = conSock->accept_socket;
			conSock->scn.conflg = 2;
			strcpy(conSock->scn.ip_addr, ips);
			conSock->scn.commType = NTSS_COMM_TYPE_NEW;
			conSock->scn.devsw = wrk[1];
			memcpy(conSock->scn.devid, &wrk[2], 7);
			conSock->scn.devid[7] = ' ';
			conSock->scn.staflg = S_WAIT;
			conSock->scn.err_ztime = 0;
			sock_rcvset(&(conSock->scn), buf, ret);

			// NTSSパケット管理情報に必要な情報をセットする
			pInfo = &packetInfoList[conSock->thread_no];
			memcpy(pInfo->cDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
			pInfo->cDeviceFormat = conSock->scn.devsw;
			memcpy(pInfo->cDeviceNo, conSock->scn.devid, sizeof(conSock->scn.devid));
			pInfo->cCommType = NTSS_COMM_TYPE_NEW;
			pInfo->sourceAddr = inet_addr(conSock->scn.ip_addr);
			pInfo->isConnected = 0x01;
			pInfo->isNeedSendProcess = 0x01;
			pInfo->nMoniDataSize = 0;
			// 工程通知を依頼（モニタ受信するまで工程を準備回収として扱う）
			pInfo->nProcess[0] = 7;
            // 自己診断実施日時をファイルから取得
            getNTSSPacketInfoMainteDate(devicecapConf.cMstFolder, pInfo);
			// ホスト報知監視設定初期化
            initNTSSHostWatchConf(pInfo);

			if ( ret == 1 ) {
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
		pthread_exit((void *)0); // スレッド終了
	}

	for ( ; ; usleep(100000) ) {

		if ( conSock->running == false ) {
			break;
		}

		// マスタ更新チェック
		if ( conSock->mst_reload == true ) {
			sprintf(logMsg, "通信スレッドNEW[%d] : マスタ更新", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			if ( check_is_target_device(&(conSock->scn.devsw), &(conSock->scn.devid[0]), conSock->scn.ip_addr, &(conSock->scn)) != 0 ) {
				sprintf(logMsg, "通信スレッドNEW[%d] : マスタ一致対象装置なし", conSock->thread_no);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				sock_socket_error(conSock);
				break;
			}
			sprintf(logMsg, "通信スレッドNEW[%d] : マスタ更新完了", conSock->thread_no);
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			conSock->mst_reload = false;
			pInfo = &packetInfoList[conSock->thread_no];
			memcpy(pInfo->cDeviceType, conSock->scn.deviceType, sizeof(conSock->scn.deviceType));
			if ( pInfo->sourceAddr == 0 && conSock->scn.ip_addr ) {
				// 空の場合、再セットする
				pInfo->sourceAddr = inet_addr(conSock->scn.ip_addr);
			}
		}

		// 一斉時刻合わせチェック
		if ( check_time_setting(TimeSet_LastTime) == true ) {
			printf("通信スレッドNEW[%d] : 一斉時刻合わせ\n", conSock->thread_no);
			// 時計設定を要求
			conSock->scn.reqflg[C_CLOCK] = 1;
		}

		/**
		 * 新通信処理
		 */
		if ( sock_communication(conSock) == false ) {
			break;
		}
	}

	// パケット管理情報初期化
    finNTSSPacketInfo(&packetInfoList[conSock->thread_no]);

	sprintf(logMsg, "通信スレッドNEW[%d] : 終了 2", conSock->thread_no);
	LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
	conSock->running = false;
	conSock->using = false;
	pthread_exit((void *)0);	// スレッド終了
}

/**
* @fn bool sock_communication(struct connect_socket *conSock)
* @brief 新通信用ソケット送受信処理
* @param[in,out] conSock 装置制御データ
* @return true 正常
* @return false エラー
*/
bool sock_communication(struct connect_socket *conSock) {
	int ret;
	int i, sndlen;
	fd_set fd, fdw;
	uint16_t sel_ret = 0;
	struct timeval seltime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    struct timespec myTime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	u_char *dp,*bp,crc;
	u_char logMsg[256];
	u_char buf[RCVMAX*2];
	struct NTSS_PACKET_INFORMATION *pInfo;

	extern void sock_socket_error(struct connect_socket *conSock);

	sel_ret = 0;
	if ( conSock->scn.staflg != S_ETX ) {
		// 新通信装置受信チェック
		if ( conSock->scn.conflg <= 0 ) {
			sock_socket_error(conSock);			// ソケットエラー処理
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
			sock_socket_error(conSock);			// ソケットエラー処理
			return false;
		}
		// 受信データ処理
		sock_rcvset(&(conSock->scn), buf, ret);
	}
	else {
		// 受信データ無し
		if ( conSock->scn.err_ztime ) {
			if ( get_time() > conSock->scn.err_ztime + configParam.deviceTimeout ) {
				// タイムアウト
				sprintf(logMsg, "通信スレッドNEW[%d] : 通信タイムアウト 2 [%02x][%d][%d][%d][%ld][%d]",
					conSock->thread_no, conSock->scn.staflg, conSock->scn.rcvlen,
					conSock->scn.zanlen, conSock->scn.zanp, (get_time() - conSock->scn.err_ztime), ret);
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
				sock_socket_error(conSock);			// ソケットエラー処理
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
		conSock->scn.rcvlen--;	// CRC分を除く
		for ( i = 0, crc = 0; i < conSock->scn.rcvlen; i++, dp++ ) {
			crc += (*dp);
		}
		if ( crc != *dp ) {
			ret = E_CRCCHK;
		}
		if ( ret == 0 ) {
			if ( conSock->scn.rcvbuf[11] && (conSock->scn.rcvbuf[9] & 0xff) != 0xe5 && conSock->scn.rcvbuf[11] != E_DEVID &&
					conSock->scn.rcvbuf[11] != E_NOTLOG && conSock->scn.rcvbuf[11] != E_DELLOG ) {
				//	終了コードエラー受信処理
				sprintf(logMsg, "通信スレッドNEW[%d] : 終了コード異常 [%02x][%02x]",
					conSock->thread_no,	(conSock->scn.rcvbuf[9] & 0xff), (conSock->scn.rcvbuf[11] & 0xff));
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
				conSock->scn.staflg = S_WAIT;
				conSock->scn.err_ztime = 0;		
				// 残り受信データ処理
				sock_rcvset(&(conSock->scn), (char*)0, 0);
				return true;
			}
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
				if ( *bp == STX )      { *dp++ = DLE; *dp++ = DC2; sndlen += 2; }
				else if ( *bp == ETX ) { *dp++ = DLE; *dp++ = DC3; sndlen += 2; }
				else if ( *bp == DLE ) { *dp++ = DLE; *dp++ = DLE; sndlen += 2; }
				else                   { *dp++ = (*bp); sndlen++; }
			}
			*dp++ = ETX; sndlen++;
			pInfo->buffer.nBufferSize = sndlen;
			ret = checkNTSSNKKCommand(pInfo);
			if ( ret != 0 ) {
				sprintf(logMsg, "通信スレッドNEW[%d] : 電文ファイル出力[%d]", conSock->thread_no, ret);
				LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
			}
		}

		if ( (conSock->scn.rcvbuf[9] & 0xff) >= 0x61 && (conSock->scn.rcvbuf[9] & 0xff) <= 0x68 ) {
			// 新通信装置からのコマンド受信
			conSock->scn.cmd = (conSock->scn.rcvbuf[9] & 0xff);
			conSock->scn.reqflg[C_RESPONSE] = 1;
		}
		else {
			if ( conSock->scn.comflg ) {
				conSock->scn.reqflg[conSock->scn.comflg] = 0;
			}
		}
		conSock->scn.staflg = S_WAIT;
		conSock->scn.err_ztime = 0;		
	}
	else if ( conSock->scn.conflg > 0 && (conSock->scn.staflg & S_END) ) {	
		sprintf(logMsg, "通信スレッドNEW[%d] : 受信データ異常[%02x]", conSock->thread_no, conSock->scn.staflg);
		LogOutputs(NTSS_LOG_ERROR, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		sock_socket_error(conSock);			// ソケットエラー処理
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
				if ( conSock->scn.reqflg[i] ) {
					conSock->scn.comflg = i;
					conSock->scn.reqflg[i] = 0;
					break;
				}
			}
		}
		if ( conSock->scn.comflg == C_NOTOPE ) {
			// 残り受信データ処理
			sock_rcvset(&(conSock->scn), (char*)0, 0);
			return true;
		}
		
		ret = sock_cmd(conSock->thread_no, &(conSock->scn));
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
			sock_socket_error(conSock);			// ソケットエラー処理
			return false;
		}
		else {
			//ioctl(conSock->scn.sock_id, I_FLUSH, FLUSHRW, &ret);
			conSock->scn.staflg = S_WAIT;
			conSock->scn.err_ztime = 0;
		}
	}

	// 残り受信データ処理
	sock_rcvset(&(conSock->scn), (char*)0, 0);

	return true;
}

/**
* @fn void sock_socket_close( struct connect_socket *conSock )
* @brief ソケットクローズ処理（新通信待受用）
* @param[in,out] conSock 装置制御データ
*/
void sock_socket_close( struct connect_socket *conSock ) {
	u_char logMsg[256];

    if ( conSock->scn.conflg > 0 && conSock->accept_socket ) {
		// シャットダウン(送受信禁止)
		shutdown(conSock->accept_socket, 2);
		// ソケットクローズ
		//sprintf(logMsg, "通信スレッドNEW[%d] : ソケットクローズ", conSock->thread_no);
		//LogOutputs(NTSS_LOG_INFO, logMsg, 0, conSock->scn.deviceType, conSock->scn.devid);
		close(conSock->accept_socket);
		conSock->accept_socket = (-1);
		conSock->running = false;
	}
	memset(&conSock->scn, 0, sizeof(struct scn_data_fm));  /* 通信制御データクリア */
}

/**
* @fn void sock_socket_error(struct connect_socket *conSock)
* @brief ソケットエラー処理（新通信待受用）
* @param[in,out] conSock 装置制御データ
*/
void sock_socket_error(struct connect_socket *conSock) {
	// ソケットクローズ処理（新通信待受用）
	sock_socket_close(conSock);
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

	for( idx = 0; idx < COUNTOF(_machineInfoData); idx++ ) {
		if ( _machineInfoData[idx].machineFormatCd == '\0' ) {
			// これ以降マスタデータなし
			break;
		}
		// マスタ構造体のIPアドレスは末尾に\0がないため文字列として扱えない
		strncpy(mstIpAddr, _machineInfoData[idx].ipAddress, 15);

		if ( memcmp(commFormatCd, &(_machineInfoData[idx].machineFormatCd), 1) == 0	// 通信フォーマットが一致
			&& memcmp(deviceCode, &(_machineInfoData[idx].machineSerial), 7) == 0	// 製造番号が一致
			&& convertNTSSIPAddr(ipAddr) == convertNTSSIPAddr(mstIpAddr)			// IPアドレス一致
			&& _machineInfoData[idx].machineCommCd == NTSS_COMM_TYPE_NEW) {			// 通信方式が日機装新通信
			// マスタに存在する
			scn->dev_idx = idx + 1;
			// 型式コード
	 		memcpy(scn->deviceType, _machineInfoData[idx].machineTypeCd, 3);
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
 * @fn void sock_rcvset(struct scn_data_fm *sp, u_char *buf, int len)
 * @brief 受信データ解析処理（新通信＆NX通信用）
 * @param[in,out] sp 装置制御データ
 * @param[in] buf 受信データ 
 * @param len 受信データ長
 */
void sock_rcvset(struct scn_data_fm *sp, u_char *buf, int len) {
	int i, n;
	u_char *dp, rc, crc, code;
	u_char *bufp, zbuf[RCVMAX];

	if ( len == 0 ) { /* 残りの受信データの取り込み */
		if ( sp->zanlen <= 0 ) {
            return;
        }
        len = sp->zanlen;
		memcpy(zbuf, sp->rcvbuf + sp->zanp, len);
		bufp = zbuf;
		sp->zanlen = 0;
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
