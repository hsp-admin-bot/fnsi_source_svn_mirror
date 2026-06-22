/// @mainpage 装置間ソケット通信アプリケーション
/// 本アプリケーションは装置（透析装置、NX装置、共通プロトコル装置）とデバイスエッジの間でソケット通信を行い、@n
/// 装置からモニタ・ステータス・ログデータ等の収集を目的としています。装置は最大200台まで接続する事が出来ます。@n@n
/// プログラム名は「ntss_sock.exe」です。

/**
* @file ntss_sock.c
* @brief 装置間ソケット通信メイン
* @author Y.Takamura
* @date 2020/07/30
* @details 装置間ソケット通信のメイン処理
*/

#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include "ntss_sock.h"
#include "ntss_nkk_comm.h"
#include "ntss_devicecap_conf.h"

int			sv_port;					/// 新通信用接続待受ポート
int			sv_port_nx;					/// NX通信用接続待受ポート
int			req_time_cp;				/// 共通プロトコル通信用リクエスト間隔（秒）

/**
 * @brief 装置制御データ
 */
struct connect_socket con_sock[DEV_MAX];

/**
 * @brief 装置情報マスタ
 */
MachineInfo_t _machineInfoData[DEV_MAX];

/**
 * @brief thread
 */
pthread_t thr_sv[DEV_MAX];

/**
 * @brief 設定情報
 */
ConfigParameter_t configParam;

/// @name signal用フラグ
//@{
/// 終了判定用フラグ
volatile sig_atomic_t endProcessFlag = 0;
/// マスタ更新更新用フラグ
volatile sig_atomic_t updateMasterFlag = 0;
/// 装置情報作成モード用フラグ
volatile sig_atomic_t createMachineFlag = 0;
/// 装置死活監視要求用フラグ
volatile sig_atomic_t requestM_AliveFlag = 0;
//@}

/**
 * @fn void signalHandler(int signum)
 * @brief シグナル受信処理
 * @param[in] signum シグナル番号
 * @details シグナル指示を受け付ける
 */
void signalHandler(int signum) {
    u_char *msg = NULL;
	extern __sighandler_t setSignal();

    switch ( signum ) {
        case SIGINT:    // キーボード割り込み(ctrl+c)
            // 終了処理
            endProcessFlag = 1;
            msg ="SIGINT受信";
            break;

        case SIGTERM:   // 終了指示
            // 処理終了
            endProcessFlag = 1;
            msg ="SIGTERM受信";
            break;

        case SIGKILL:   // 強制終了
            // 処理終了
            endProcessFlag = 1;
            msg ="SIGKILL受信";
            break;

        case SIGHUP:    // ハングアップ
            // 処理終了
            endProcessFlag = 1;
            msg ="SIGHUP受信";
            break;

        case SIGPIPE:
            msg ="SIGPIPE受信";
			// ログ設定（通信切断）
			resetLogInfo();
			if( setSignal() == SIG_ERR ) {
				// シグナル設定エラー
				viewError( "シグナルの再設定ができないので終了します" );
			}
            break;

		case SIG_ALIVE_MONI:	// 装置死活監視要求
            // 装置死活監視要求
            requestM_AliveFlag = 1;
            msg = "装置死活監視要求";
            break;

		case SIG_MST_SYNC:		// マスタ更新指示
            // マスタ更新指示
            updateMasterFlag = 1;
            msg ="マスタ更新指示受信";
            break;

        case SIG_CREATE_MODE:	// 装置情報作成モード移行要求
            // 装置情報作成モード移行要求
			createMachineFlag = 1;
			bCreateMachineInfo = true;
            msg = "装置情報作成モード移行要求";
            break;

        case SIG_NORMAL_MODE:	// 通常モード移行要求
            // 通常モード移行要求
			createMachineFlag = 0;
			bCreateMachineInfo = false;
            msg = "通常モード移行要求";
            break;
    }

    if ( msg != NULL ) {
        // 受け取ったシグナルを記録する
        LogOutputs(NTSS_LOG_INFO, msg, 0, "", "");
    }
}

/**
 * @fn __sighandler_t setSignal()
 * @brief シグナル設定
 * @details シグナル設定を行う
 * @description
 * @return シグナル設定結果
 * @attention 特になし
 */
__sighandler_t setSignal() {
    __sighandler_t ret = SIG_DFL;

    // プログラム終了のためのシグナル設定
    if ( ret != SIG_ERR ) {
        ret = signal(SIGTERM, signalHandler);
    }
    if ( ret != SIG_ERR ) {
        ret = signal(SIGINT, signalHandler);
    }
    if ( ret != SIG_ERR ) {
        ret = signal(SIGHUP, signalHandler);
    }
    if ( ret != SIG_ERR ) {
        ret = signal(SIGPIPE, signalHandler);
    }

    // マスタ同期要求のためのシグナル設定
    if ( ret != SIG_ERR ) {
        ret = signal(SIG_MST_SYNC, signalHandler);
    }
    // 装置死活監視要求のためのシグナル設定
    if ( ret != SIG_ERR ) {
        ret = signal(SIG_ALIVE_MONI, signalHandler);
    }
    // 装置情報作成モード移行要求のためのシグナル設定
    if ( ret != SIG_ERR ) {
        ret = signal(SIG_CREATE_MODE, signalHandler);
    }
    // 通常モード移行要求のためのシグナル設定
    if ( ret != SIG_ERR ) {
        ret = signal(SIG_NORMAL_MODE, signalHandler);
    }

    return ret;    
}

/**
 * @fn bool sock_control()
 * @brief ソケット通信制御
 * @return true 正常終了
 * @return false 異常終了
 */
bool sock_control() {
	int ret;
	uint16_t no, idx;
    socklen_t len, len_nx;
	int maxfd;
	int sock, sock_nx;
	int client_check;
	u_char clog[256];
	char fpath[64];
	char mstFormatCd = 0;
	char mstSerial[9] = {0};
	char mstIpAddr[16] = {0};
	char mstPortNo[6] = {0};
	char NextPat_LastTime[20] = "";	// 前回日付変更時次患者更新日時
	fd_set ready;
	struct sockaddr_in serv, serv_nx;
	struct timeval seltime;
	pthread_t thr_npat;
	pthread_attr_t thread_attr;

	extern int con_sock_search();
	extern int client_device_search(u_char devFormat, u_char *devSerial, u_char *ipAddr, short portNo);
	extern void sock_control_close();
	extern void sock_thread_join();
	extern bool reroad_master();

	sprintf(clog, "ソケット通信制御");
    LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");

	client_check = 1;			/* クライアント確認 */

	// スレッド属性オブジェクトの初期化
	pthread_attr_init(&thread_attr);
	// スレッド切り離し状態属性の設定
	pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);

	/****************************/
	/* 新通信装置(I,J,M,N,P,Q)  */
	/* NX通信装置(A,D,I,J,R)    */
	/* 共通プロトコル装置(V,W)  */
	/****************************/

	// ソケットを作成（新通信装置）
	sock = socket(AF_INET, SOCK_STREAM, 0);
	if ( sock < 0 ) {
		sprintf(clog, "ソケット生成（新通信装置）失敗 [%d][%s]", errno, strerror(errno));
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
  		return false;
	}
	// ソケットを作成（NX通信装置）
	sock_nx = socket(AF_INET, SOCK_STREAM, 0);
	if ( sock_nx < 0 ) {
		sprintf(clog, "ソケット生成（NX通信装置）失敗 [%d][%s]", errno, strerror(errno));
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
		return false;
	}

	// ソケットの設定（新通信装置）
    serv.sin_family = AF_INET;
	serv.sin_addr.s_addr = INADDR_ANY;
	serv.sin_port = htons(sv_port);
	// ソケットの設定（NX通信装置）
    serv_nx.sin_family = AF_INET;
	serv_nx.sin_addr.s_addr = INADDR_ANY;
	serv_nx.sin_port = htons(sv_port_nx);

    // mod FNSI-バグ 通信サーバ 高 start
    // 新通信装置
	for ( ; ; sleep(1) ) {
		if ( endProcessFlag == 1 ) { // 停止処理
			close(sock);
			return true;
		}
		if ( bind(sock, (struct sockaddr *)&serv, sizeof(serv)) < 0 ) {
			sprintf(clog, "bind ERROR [%d][%s]", errno, strerror(errno));
			LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
			continue;
		}
		len = sizeof(serv);
		if ( getsockname(sock, (struct sockaddr *)&serv, &len) < 0 ) {
			sprintf(clog, "getsockname ERROR [%d][%s]", errno, strerror(errno));
			LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
			continue;
		}
        // ソケット名まで取得成功で抜ける
		break;
	}
    
    // NX通信装置
    for ( ; ; sleep(1) ) {
		if ( endProcessFlag == 1 ) { // 停止処理
			close(sock);
			close(sock_nx);
			return true;
		}
		if ( bind(sock_nx, (struct sockaddr *)&serv_nx, sizeof(serv_nx)) < 0 ) {
			sprintf(clog, "bind NX ERROR [%d][%s]", errno, strerror(errno));
			LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
			continue;
		}
		len_nx = sizeof(serv_nx);
		if ( getsockname(sock_nx, (struct sockaddr *)&serv_nx, &len_nx) < 0 ) {
			sprintf(clog, "getsockname NX ERROR [%d][%s]", errno, strerror(errno));
			LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
			continue;
		}
        // ソケット名まで取得成功で抜ける
		break;
	}
    // mod FNSI-バグ 通信サーバ 高 end

    // 待ち受け開始（新通信装置）
	listen(sock, LISTEN_MAX);
    // 待ち受け開始（NX通信装置）
	listen(sock_nx, LISTEN_MAX);

	// 正常動作ログ記録日時
	time_t last_watchdog_time, c_tim;
	time(&last_watchdog_time);

	for ( ; ; usleep(100000) ) {

		if ( endProcessFlag == 1 ) {
            break;	// 停止
        }

		// 現在時間の読み出し
		time(&c_tim);

		// 一定間隔(180秒[3分]間隔)で正常動作していることをログに記録する
		if ((last_watchdog_time + 180) <= c_tim)
		{
			LogOutput( NTSS_LOG_INFO, "正常動作中..." );

			// 記録日時を保持
			last_watchdog_time = c_tim;
		}

		if ( createMachineFlag == 1 ) {
			createMachineFlag = 0;
            // 装置情報作成モードへ移行
			// ソケット通信制御クローズ処理
			sprintf(clog, "ソケット終了処理（装置情報作成モード）");
			LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
			sock_control_close();
			// ソケット通信スレッド終了待ち
			sprintf(clog, "スレッド終了処理（装置情報作成モード）");
			LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
			sock_thread_join();
		    // パケット管理情報初期化
		    memset(packetInfoList, 0, sizeof(packetInfoList));
			// 装置制御データ初期化
		    memset(con_sock, 0, sizeof(con_sock));
        }

		if ( updateMasterFlag == 1 ) {
			updateMasterFlag = 0;
			// マスタ更新
			if ( reroad_master() == false ) {
				// 失敗時に停止
				break;
			}
			client_check = 1;
			// 本体揮発領域の保存処理(非同期)
		    overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);
		}

		if ( getCreateMachineInfoMode() == false ) {
			// 通常モードの場合

			// 装置死活監視要求
			if ( requestM_AliveFlag == 1 ) {
				requestM_AliveFlag = 0;
				// 全装置の死活状態報告を実施
				// すべての装置の接続状態を通知する
				devicecapConf.cSendAllConnectionStatus = 0x01;

				// シグナル再設定
				if ( setSignal() == SIG_ERR ) {
					// シグナル設定エラー
					viewError( "シグナルの再設定ができないので終了します" );
					break;
				}
			}

			// 工程変化時の装置工程情報の出力(nCheckMachineStateInterval)
			if ( checkNTSSPacketInfoMonitorProcess(
				devicecapConf.nCheckMachineStateInterval
				, &devicecapConf.lastCheckMachineStateTime
				, devicecapConf.cSendAllConnectionStatus) == 1 ) {
				// 次回送信は変更分のみとする
				devicecapConf.cSendAllConnectionStatus = 0x00;
			}

			// 透析中モニタデータの出力(nSendDialysisMonitorInterval)
			checkNTSSPacketInfoMonitorData(
				devicecapConf.nSendDialysisMonitorInterval
				, &devicecapConf.lastSendDialysisMonitorTime
				, 0x01
			);

			// 未透析モニタデータの出力(nSendUntreatMonitorInterval)
			checkNTSSPacketInfoMonitorData(
				devicecapConf.nSendUntreatMonitorInterval
				, &devicecapConf.lastSendUntreatMonitorTime
				, 0x00
			);
		}

		if ( client_check ) {
			client_check = 0;
			/******************************************/
			/* 共通プロトコル装置の確認・スレッド作成 */
			/******************************************/
			for ( idx = 0; idx < COUNTOF(_machineInfoData); idx++ ) {
				if( _machineInfoData[idx].machineFormatCd == '\0' ) {
					// これ以降マスタデータなし
					break;
				}
				if ( (_machineInfoData[idx].machineFormatCd != 'V' &&
					  _machineInfoData[idx].machineFormatCd != 'W') ||
					  _machineInfoData[idx].machineCommCd != NTSS_COMM_TYPE_COMMON ) {
					// 共通プロトコル装置以外
					continue;
				}

				// 共通プロトコル通信接続用データ作成
				mstFormatCd = _machineInfoData[idx].machineFormatCd;			// 通信フォーマット
				strncpy(mstSerial, _machineInfoData[idx].machineSerial, 8);		// 製造番号
				strncpy(mstIpAddr, _machineInfoData[idx].ipAddress, 15);		// IPアドレス
				strncpy(mstPortNo, _machineInfoData[idx].strport, 5);			// ポート番号
				if ( client_device_search(mstFormatCd, mstSerial, mstIpAddr, atoi(mstPortNo)) ) {
					// 既に通信制御データに存在
					continue;
				}
				no = con_sock_search();
				if ( no < DEV_MAX ) {
					con_sock[no].using = true;
					con_sock[no].thread_no = no;
					// 通信制御データクリア
					memset(&con_sock[no].scn, 0, sizeof(struct scn_data_fm));
					// 共通プロトコル通信接続用データ作成
					con_sock[no].scn.dev_idx = idx + 1;
					con_sock[no].scn.devsw = mstFormatCd;
					memcpy(con_sock[no].scn.devid,mstSerial,8);
					strcpy(con_sock[no].scn.ip_addr,mstIpAddr);
					con_sock[no].scn.port_no = atoi(mstPortNo);
					memcpy(con_sock[no].scn.deviceType, _machineInfoData[idx].machineTypeCd, 3);	// 型式コード
					con_sock[no].scn.commType = NTSS_COMM_TYPE_COMMON;
					// スレッド作成
					sprintf(clog, "通信スレッドCP[%d] : 生成", no);
					LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
					pthread_create(&(thr_sv[no]), &thread_attr, sock_stream_cp, &(con_sock[no]));
				}
			}
		}

		FD_ZERO(&ready);			// fd_set初期化 
		FD_SET(sock, &ready);		// fd設定（新通信装置）
		FD_SET(sock_nx, &ready);	// fd設定（NX通信装置）

        // データ受信待ち
		seltime.tv_sec = 2;
		seltime.tv_usec = 0;
		if ( sock > sock_nx ) {
			maxfd = sock;
		}
		else {
			maxfd = sock_nx;
		}
		if ( select(maxfd + 1, &ready, NULL, NULL, &seltime) <= 0 ) {
            continue;
        }

        // fd（新通信装置）に読み込みデータがあるならば、ソケットをリストに登録する
		if ( FD_ISSET(sock, &ready) ) {
			no = con_sock_search();
			if ( no < DEV_MAX) {
                // 待受（処理はブロックされる)
				con_sock[no].accept_socket = accept(sock,(struct sockaddr *)&serv,&len);
				if ( con_sock[no].accept_socket < 0 ) {
                    // 失敗
					con_sock[no].accept_socket = (-1);
				}
				else {
					if ( getsockname(sock, (struct sockaddr *)&serv, &len) < 0 ) {
                        // ソケット名の取得に失敗
						con_sock[no].accept_socket = (-1);
						continue;
					}
					// 受信スレッドの起動
					sprintf(clog, "通信スレッドNEW[%d] : 生成", no);
					LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");

					con_sock[no].using = true;
					con_sock[no].thread_no = no;
					// 通信制御データクリア
					memset(&con_sock[no].scn, 0, sizeof(struct scn_data_fm));
					// スレッド作成
					pthread_create(&(thr_sv[no]), &thread_attr, sock_stream, &(con_sock[no]));
				}
			}
		}

        // fd（NX通信装置）に読み込みデータがあるならば、ソケットをリストに登録する
		if ( FD_ISSET(sock_nx, &ready) ) {
			no = con_sock_search();
			if ( no < DEV_MAX ) {
                // 待受（処理はブロックされる)
				con_sock[no].accept_socket = accept(sock_nx, (struct sockaddr *)&serv_nx, &len_nx);
				if ( con_sock[no].accept_socket < 0 ) {
                    // 失敗
					con_sock[no].accept_socket = (-1);
				}
				else {
					if ( getsockname(sock_nx, (struct sockaddr *)&serv_nx, &len_nx) < 0 ) {
                        // ソケット名の取得に失敗
						con_sock[no].accept_socket = (-1);
						continue;
					}
					// 受信スレッドの起動
					sprintf(clog, "通信スレッドNX[%d] : 生成", no);
					LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");

					con_sock[no].using = true;
					con_sock[no].thread_no = no;
					// 通信制御データクリア
					memset(&con_sock[no].scn, 0, sizeof(struct scn_data_fm));
					// スレッド作成
					pthread_create(&(thr_sv[no]), &thread_attr, sock_stream_nx, &(con_sock[no]));
				}
			}
		}
	}

	// ソケット通信制御クローズ処理
	sprintf(clog, "ソケット終了処理");
    LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	sock_control_close();
	close(sock);
	close(sock_nx);

	// ソケット通信スレッド終了待ち
	sprintf(clog, "スレッド終了処理");
    LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	sock_thread_join();

    return true;
}

/**
 * @fn int con_sock_search()
 * @brief 装置制御データの空きインデックス検索
 * @return 空きインデックス（DEV_MAX:空きなし） 
 */
int con_sock_search() {
	int dno;

	for ( dno = 0; dno < DEV_MAX; dno++ ) {
		if ( con_sock[dno].using == false ) {
			break;
		}
	}

	return dno;
}

/**
 * @fn int client_device_search(u_char devFormat, u_char *devSerial, u_char *ipAddr, short portNo)
 * @brief 装置制御データの対象装置インデックス検索
 * @param[in] devFormat 通信フォーマット
 * @param[in] devSerial 製造番号
 * @param[in] ipAddr IPアドレス
 * @param[in] portNo ポート番号
 * @return 対象装置インデックス（0:対象なし） 
 */
int client_device_search(u_char devFormat, u_char *devSerial, u_char *ipAddr, short portNo) {
	int dno;
	int idx = 0;

	for ( dno = 0; dno < DEV_MAX; dno++ ) {
		if ( con_sock[dno].using == false ) {
			continue;
		}
		if ( devFormat == con_sock[dno].scn.devsw
			&& memcmp(devSerial, con_sock[dno].scn.devid, 8) == 0
			&& convertNTSSIPAddr(ipAddr) == convertNTSSIPAddr(con_sock[dno].scn.ip_addr)
			&& devFormat == con_sock[dno].scn.devsw ) {
			// 対象装置が既に通信制御データに存在する
			idx = dno + 1;
			break;
		}
	}

	return idx;
}

/**
 * @fn void sock_control_close()
 * @brief ソケット通信制御クローズ処理
 */
void sock_control_close() {
	int no;

	for ( no = 0; no < DEV_MAX; no++ ) {
		if ( con_sock[no].using == true ) {
			if ( con_sock[no].scn.commType == NTSS_COMM_TYPE_COMMON ) {
				// ソケットクローズ処理（共通プロトコル通信接続用）
				sock_socket_close_cp(&(con_sock[no]));
			}
			else if ( con_sock[no].scn.commType == NTSS_COMM_TYPE_NX ) {
				// ソケットクローズ処理（NX通信待受用）
				sock_socket_close_nx(&(con_sock[no]));
			}
			else {
				// ソケットクローズ処理（新通信待受用）
				sock_socket_close(&(con_sock[no]));
			}
		}
	}
}

/**
 * @fn void sock_thread_join()
 * @brief ソケット通信スレッド終了待ち
 */
void sock_thread_join() {
	int no;

	while ( 1 ) { 
		usleep(3000000);
		for ( no = 0; no < DEV_MAX; no++ ) {
			if ( con_sock[no].running == true ) {
				break;
			}
		}
		if ( no >= DEV_MAX ) {
			break;
		} 
	}
}

/**
 * @fn bool reroad_master()
 * @brief 装置マスタ更新処理
 */
bool reroad_master() {
	uint16_t no;
	u_char readFilePath[256];
	u_char clog[256];
	MachineInfo_t _machineInfoBack[DEV_MAX];
	
	sprintf(readFilePath, "%s/%s", configParam.mstDir, MST_INFO);
	memcpy(_machineInfoBack, _machineInfoData, sizeof(_machineInfoData));
	memset(_machineInfoData, 0, sizeof(_machineInfoData));
	if ( readMachineInfo(_machineInfoData, sizeof(_machineInfoData), readFilePath) == true ) {
		sprintf(clog, "装置マスタ読み込み完了");
		LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	}
	else {
	    sprintf(clog, "装置マスタ読み込みに失敗しました");
    	LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
		// 読み込み前の状態に戻す
		memcpy(_machineInfoData, _machineInfoBack, sizeof(_machineInfoData));
	}

	for ( no = 0; no < DEV_MAX; no++ ) {
		if ( con_sock[no].using == true && con_sock[no].running == true ) {
			con_sock[no].mst_reload = true;
		}
	}

    // シグナル再設定
    if ( setSignal() == SIG_ERR ) {
        // シグナル設定エラー
        sprintf(clog, "シグナルの再設定ができないので終了します");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
        return false;
    }
	return true;

}

/**
 * @fn int main(int argc, char *argv[])
 * @brief メイン処理
 * @param[in] argc 引数の個数
 * @param[in] argv 引数の配列（引数文字列）
 * @return 終了コード 
 */
int main(int argc, char *argv[]) {
    u_char clog[256];   
	u_char readFilePath[256];
    extern void readConfig(ConfigParameter_t *configParam);

    // ログ設定
    setLogInfo();

    // システム起動
    sprintf(clog, "[START],システム起動");
    LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");

	// シグナル設定
    if ( setSignal() == SIG_ERR ) {
        // シグナル設定エラー
		viewError( "シグナルの設定ができないので終了します" );
        exit(EXIT_FAILURE);
    }

	// 引数から情報取得
	if ( 1 < argc ) {
		// プロセス番号
		devicecapConf.nOwnerProcessId = atoi(argv[1]);

		// 引数を画面に出力する
		sprintf(
			clog
			, "Owner PID:%d"
			, devicecapConf.nOwnerProcessId
		);
		// 引数をファイルに出力する
		LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	}
    else {
		viewError("プロセス番号が引数で指定されていません");
		exit(EXIT_FAILURE);
	}

	// 設定ファイルの読み込み
	memset(&configParam, 0, sizeof(configParam));
	readConfig(&configParam);
    sv_port = configParam.receivePort;
    sv_port_nx = configParam.receivePort_NX;
	req_time_cp = configParam.requestTime_CP;

	// マスタファイル参照先フォルダ
    sprintf(devicecapConf.cMstFolder, "./mst/");

	// NTSSパケット収集アプリケーション用の設定ファイルを読み込む
	if ( getNTSSDeviceCapConf() != 1 ) {
	    sprintf(clog, "パケット収集アプリケーション設置ファイルの読み込みに失敗しました");
    	LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	// 日機装通信キャプチャ対象コマンド情報設定ファイルを読み込む
	if ( initNTSSNKKCaptureCommandInfo() != 1 ) {
	    sprintf(clog, "キャプチャ対象コマンド情報設定ファイルの読み込みに失敗しました");
    	LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}

	// 装置マスタからデータ取得
	sprintf(readFilePath, "%s/%s", configParam.mstDir, MST_INFO);
	memset(_machineInfoData, 0, sizeof(_machineInfoData));
	if ( readMachineInfo(_machineInfoData, sizeof(_machineInfoData), readFilePath) == false ) {
	    sprintf(clog, "装置マスタ読み込みに失敗しました");
    	LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}

	// 工程マスタからデータ取得
	if ( ntss_mst_proc_read( configParam.mstDir ) != 0 ) {
		sprintf(clog, "工程マスタファイルの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
        exit(EXIT_FAILURE);
    }
	// モニタ項目マスタからデータ取得
	if ( ntss_mst_moni_read( configParam.mstDir ) != 0 ) {
		sprintf(clog, "モニタ項目マスタファイルの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
        exit(EXIT_FAILURE);
    }

	sprintf(clog, "device_timeout : %d", configParam.deviceTimeout);
    LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	sprintf(clog, "treat_moni_interval : %d", devicecapConf.nSendDialysisMonitorInterval);
    LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	sprintf(clog, "other_moni_interval : %d", devicecapConf.nSendUntreatMonitorInterval);
    LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");

  	// 本体揮発領域の保存処理(非同期)
   	overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);

    // 処理開始日時を設定
    time(&devicecapConf.lastMachineAliveTime);
    // 初回なのですべての装置の接続状態を通知する
    devicecapConf.cSendAllConnectionStatus = 0x01;

    // 前回装置状態判定日時を初期化
    devicecapConf.lastCheckMachineStateTime = devicecapConf.lastMachineAliveTime;
    // 前回治療中モニタ送信日時を初期化
    devicecapConf.lastSendDialysisMonitorTime = devicecapConf.lastMachineAliveTime;
    // 前回未治療モニタ送信日時を初期化
    devicecapConf.lastSendUntreatMonitorTime = devicecapConf.lastMachineAliveTime;

    // パケット管理情報初期化
    memset(packetInfoList, 0, sizeof(packetInfoList));

	// 装置制御データ初期化
    memset(con_sock, 0, sizeof(con_sock));

    // ソケット通信制御
    sock_control();

    // パケット管理情報初期化（valgrind still reachable）
    memset(packetInfoList, 0, sizeof(packetInfoList));

	// 装置制御データ初期化（valgrind still reachable）
    memset(con_sock, 0, sizeof(con_sock));

    // システム終了
    sprintf(clog, "システム終了");
    LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");

    return 0;
}

/**
 * @fn void readConfig(ConfigParameter_t *configParam)
 * @brief 設定ファイルの読み込みと反映
 * @param[out] configParam コンフィグパラメータ
 */
void readConfig(ConfigParameter_t *configParam) {
    u_char clog[256];    

	snprintf(clog, sizeof(clog), "read : %s", CONFIG_FILE);
    LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	if ( readConfigFile(CONFIG_FILE, configParam) < 0 ) {
		snprintf(clog, sizeof(clog), "%s OPEN ERROR", CONFIG_FILE);
    	LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
		return;
	}
	snprintf(clog, sizeof(clog), "read : %s", CONFIG_COMMON_FILE);
    LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	if ( readConfigCommonFile(CONFIG_COMMON_FILE, configParam) < 0 ) {
		snprintf(clog, sizeof(clog), "%s OPEN ERROR", CONFIG_COMMON_FILE);
    	LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
		return;
	}
}

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn void get_time()
// * @brief 現在時刻を取得
// * @return long 現在時刻
// */
//long get_time()
//{
//	long gtime;
//
//	time(&gtime);
//
//	return gtime;
//}
/**
 * @fn time_t get_time()
 * @brief 現在時刻を取得
 * @return long 現在時刻
 */
time_t get_time()
{
	time_t gtime;

	time(&gtime);

	return gtime;
}
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
/**
 * @fn void LogOutputs(NtssLogType type, u_char *msg, u_char *devType, u_char *devSerial)
 * @brief ログ出力（コンソール＆ファイル）を行う
 * @param[in] type 種別コード
 * @param[in] msg ログメッセージ
 * @param[in] flag 出力フラフ（0:通常,1:システム情報有り）
 * @param[in] devType 型式(不要な場合は空文字を指定)
 * @param[in] devSerial 製造番号(不要な場合は空文字を指定)
 */
/*
void LogOutputs(NtssLogType type, u_char *msg, int flg, u_char *devType, u_char *devSerial)
{
	unsigned char cType[5]; 
	unsigned char cSerial[10]; 

	// コンソール出力
	printf("%s\n", msg);
	// ファイル出力
	memset(cType, 0, sizeof(cType));
	memset(cSerial, 0, sizeof(cSerial));
	memcpy(cType, devType, 3);
	memcpy(cSerial, devSerial, 8);
	LogSend(type, msg, 0, cType, cSerial);
}
*/
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
