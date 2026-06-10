#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <stdint.h>
#include <stdbool.h>
#include <arpa/inet.h>
#include <sys/fcntl.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/time.h>

#include "ntss_logsv.h"
#include "logsv_config.h"
#include "logsv_output.h"
#include "../common/nkklib/nkklib.h"
#include "../common/libs/ntss_etc_lib.h"

/**
 * @brief 設定情報
 * 
 */
extern ConfigParameter_t configParam;

/**
 * @brief ログ受信処理
 * 
 * @param ptr 
 * @return void* 
 */
void *logsv_stream(void *ptr){

	struct connect_socket *conSock = (struct connect_socket *) ptr;
	fd_set fd;
	struct timeval seltime;
	int i;
	uint16_t pno;
	ssize_t ret;
	char param[12][50];
	unsigned char *dp, crc;
	unsigned char head[255];
	unsigned char work[255];
	unsigned char stat[1000];
	unsigned char buff[RCVMAX];
	unsigned char info[RCVMAX];
	unsigned char mesg[RCVMAX];
	struct sockaddr_in serv;
    socklen_t len;
	unsigned char *ip;

	extern void logsv_socket_error(struct connect_socket *conSock);
	extern int logsv_rcvset(struct logsv_data_fm *sp, unsigned char *buf, int len);
	extern void logsv_output(char *logsv);
	extern void GetSystemAnalyzer(char *buf);

	conSock->running = true;

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	conSock->logsv = (struct logsv_data_fm *)malloc(sizeof(struct logsv_data_fm));
	memset(conSock->logsv, 0, sizeof(struct logsv_data_fm));

	len = sizeof(serv);
	if ( getpeername(conSock->accept_socket,(struct sockaddr *)&serv, &len)<0 ) {
		sprintf(work, "スレッド[%d] : getpeernameエラー ", conSock->thread_no);
		LogOutput_logger( NTSS_LOG_ERROR, work );
		shutdown(conSock->accept_socket, 2);
		close(conSock->accept_socket);
		conSock->accept_socket = (-1);
		conSock->running = false;
	}
	else {
		conSock->logsv->sock_id = conSock->accept_socket;
		conSock->logsv->conflg = 2;
		ip = inet_ntoa(serv.sin_addr);
		strcpy(conSock->logsv->ip_addr,ip);
		conSock->logsv->port_no = ntohs(serv.sin_port);
		conSock->logsv->port_no = (short)ntohs(serv.sin_port);
        time(&now_time);
		conSock->logsv->rcvtime = now_time;
	}

	// クライアント側から接続
	sprintf(work, "スレッド[%d] : CLIENT（%s:%u）から接続", 
		conSock->thread_no,	conSock->logsv->ip_addr, conSock->logsv->port_no);
	LogOutput_logger( NTSS_LOG_INFO, work );

	// 収集対象か否かをチェックする処理
	for ( ; ; usleep(100000) ) {

        // 現在時間の読み出し
        time(&now_time);

		if(conSock->running == false){
			break;
		}
		if(configParam.logsvTimeout > 0 && now_time > conSock->logsv->rcvtime + configParam.logsvTimeout){
			// タイムアウト
			sprintf(work, "スレッド[%d] : 無通信タイムアウト", conSock->thread_no);
			LogOutput_logger( NTSS_LOG_ERROR, work );
			shutdown(conSock->accept_socket, 2);
			close(conSock->accept_socket);
			conSock->accept_socket = (-1);
			conSock->running = false;
			break;
		}

		if ( conSock->logsv->staflg != S_ETX ) {

			// fd_set初期化 
			FD_ZERO(&fd);        		
			// fd設定
			FD_SET(conSock->accept_socket, &fd);

			// データ受信待ち
			seltime.tv_sec=5;
			seltime.tv_usec=0;
			if ( select(FD_SETSIZE, &fd, 0, 0, &seltime)<=0 ) {
				continue;
			}

			// 受信チェック
			if ( FD_ISSET(conSock->accept_socket, &fd)==0 ) {
				continue;
			}

			// 受信データの読み込み
			ret = read(conSock->accept_socket, buff, READMAX);
			if ( ret<=0 ) {
				if ( ret == 0 ) {
					// クライアント側から切断した場合の検知
					sprintf(work, "スレッド[%d] : CLIENT（%s:%u）から切断", 
						conSock->thread_no,	conSock->logsv->ip_addr, conSock->logsv->port_no);
					LogOutput_logger( NTSS_LOG_INFO, work );
				}
				else {
					// エラー発生
					sprintf(work, "スレッド[%d] : データリードエラー", conSock->thread_no);
					LogOutput_logger( NTSS_LOG_ERROR, work );
				}
				shutdown(conSock->accept_socket, 2);
				close(conSock->accept_socket);
				conSock->accept_socket = (-1);
				conSock->running = false;
				break;
			}

			conSock->logsv->rcvtime = now_time;
			logsv_rcvset(conSock->logsv,buff,ret);
		}

		// 受信データチェック
		if ( conSock->logsv->staflg == S_ETX ) {
			conSock->logsv->staflg = S_WAIT;
			dp = conSock->logsv->rcvbuf;
			for ( i=0,crc=0; i<conSock->logsv->rcvlen - 1; i++,dp++ ) {
				crc+=(*dp);
			}
			if ( crc != *dp ) {				
				sprintf(work, "スレッド[%d] : 受信データ異常", conSock->thread_no);
				LogOutput_logger( NTSS_LOG_ERROR, work );
				shutdown(conSock->accept_socket, 2);
				close(conSock->accept_socket);
				conSock->accept_socket = (-1);
				conSock->running = false;
				break;
			}
			else {
				conSock->logsv->rcvbuf[conSock->logsv->rcvlen-1] = 0;
				// rcvbuf（11項目TAB区切り）
				//  1 :システム情報出力フラグ（'0':無し,'1':有り）
				//  2 :送信日時
				//  3 :ユーザーID
				//  4 :セッションID
				//  5 :型式
				//  6 :製造番号
				//  7 :EC2識別
				//  8 :サービス名
				//  9 :画面コード
				// 10 :SQL名
				// 11 :ログ種別
				// 12 :ログ内容
				memset(mesg, 0, sizeof(mesg));
				memset(param, 0, sizeof(param));
				for ( i=0; i<11; i++ ) {
					get_text(i+1, (char *)conSock->logsv->rcvbuf, param[i]);
				}
                // add FNSI-バグ 通信サーバ 高 start
                param[1][0] = '\0';
                // add FNSI-バグ 通信サーバ 高 end
				sprintf(mesg, "%s,%s,%s,%d,%s,%s,%s,%s,%s,%s,%s,%s,",
					configParam.facilityCd, param[2], param[3], configParam.deviceNo, configParam.serialNo,
					param[4], param[5], param[6], param[7], param[8], param[9], param[10]);
				memset(buff, 0, sizeof(buff));
				get_text(12, (char *)conSock->logsv->rcvbuf, buff);
                // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
                logsv_replace(buff, strlen(buff));
                // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end
				if (param[0][0] != '0') {
					// システム情報出力
					memset(head, 0, sizeof(head));
					sprintf(head, "%s,%s,%s,%d,%s,%s,%s,%s,%s,%s,%s,[DEBUG],",
						configParam.facilityCd, param[2], param[3], configParam.deviceNo, configParam.serialNo,
						param[4], param[5], param[6], param[7], param[8], param[9]);
					// CPU Usage, Memory Usage, Disk Usage
					memset(info, 0, sizeof(info));
					strcat(info, head);
					if (param[0][0] == '1') {
						memset(work, 0, sizeof(work));
						GetSystemAnalyzer(work);
                        // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
                        logsv_replace(work, strlen(work));
                        // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end
						strcat(info, work);
						LogsvOutput(param[1], info);
						// Filesystem LOGSV_FOLDER1
						memset(work, 0, sizeof(work));
						if ( !Filesystem_Info(configParam.logsvFolder1, work) ) {
                            // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
                            logsv_replace(work, strlen(work));
                            // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end
							memset(info, 0, sizeof(info));
							strcat(info, head);
							strcat(info, work);
							LogsvOutput(param[1], info);
						}
						// Filesystem LOGSV_FOLDER2
						memset(work, 0, sizeof(work));
						if ( !Filesystem_Info(configParam.logsvFolder2, work) ) {
                            // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
                            logsv_replace(work, strlen(work));
                            // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end
							memset(info, 0, sizeof(info));
							strcat(info, head);
							strcat(info, work);
							LogsvOutput(param[1], info);
						}
						// Filesystem LOGSV_FOLDER3
						memset(work, 0, sizeof(work));
						if ( !Filesystem_Info(configParam.logsvFolder3, work) ) {
                            // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
                            logsv_replace(work, strlen(work));
                            // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end
							memset(info, 0, sizeof(info));
							strcat(info, head);
							strcat(info, work);
							LogsvOutput(param[1], info);
						}
					}
					else if (param[0][0] == '2') {
						// ネットワーク状態出力
						memset(stat, 0, sizeof(stat));
						dp = getNetworkStat("ppp0");
						if ( *dp == 0 ) {
							strcpy(stat, "Device ppp0 does not exist.");
						}
						else {
							strcpy(stat, dp);
							dp = getAntenna();
							memset(work, 0, sizeof(work));
							sprintf(work, "    アンテナレベル : %s", dp);
							strcat(stat, work);
						}
                        // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
                        logsv_replace(stat, strlen(stat));
                        // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end
						strcat(info, stat);
						LogsvOutput(param[1], info);
					}
				}
				strcat(mesg, buff);
				LogsvOutput(param[1], mesg);
			}
		}

		logsv_rcvset(conSock->logsv,(char *)0,0);
	}

	free(conSock->logsv);

	sprintf(work, "スレッド[%d] : 終了", conSock->thread_no);
	LogOutput_logger( NTSS_LOG_INFO, work);
	conSock->running = false;
	conSock->using = false;
	pthread_exit((void *)0); // スレッド終了
}

/**
 * @brief ソケットクローズ処理（ログ待受用）
 * 
 */
int logsv_socket_close( struct connect_socket *conSock )
{
	unsigned char work[255];

    if ( conSock->logsv->conflg>0 && conSock->logsv->sock_id ) {
		/* ソケットクローズ */
		sprintf(work, "スレッド[%d] : ソケットクローズ", conSock->thread_no);
		LogOutput_logger( NTSS_LOG_INFO, work);
		shutdown(conSock->accept_socket, 2);
		close(conSock->accept_socket);
		conSock->accept_socket = (-1);
		conSock->running = false;
	}

	return 0;
}

/**
 * @brief ソケットエラー処理（ログ待受用）
 * 
 */
void logsv_socket_error(struct connect_socket *conSock)
{
	// ソケットクローズ処理（ログ待受用）
	logsv_socket_close(conSock);
}

/**
 * @brief 受信データの解析セット
 * 
 * @param sp 
 * @param char 
 * @param len 
 * @return int 
 */
int	logsv_rcvset(struct logsv_data_fm *sp, unsigned char *buf, int len)
{
	int i,n;
	unsigned char *dp,rc,crc,code;
	unsigned char *bufp,zbuf[RCVMAX];

	if ( len==0 ) { /* 残りの受信データの取り込み */
		if ( sp->zanlen<=0 ) {
            return(0);
        }
        len = sp->zanlen;
		memcpy(zbuf,sp->rcvbuf + sp->zanp,len);
		bufp=zbuf;
		sp->zanlen=0;
	}
	else {
        bufp=buf;
    }

	dp = sp->rcvbuf + sp->rcvlen;
	for ( i=0; i<len; i++,bufp++ ) { 
		rc = *bufp; 
		if ( rc==STX ) {
			sp->staflg_bak = sp->staflg; /* 通信状態の控え */
			dp = sp->rcvbuf; 
            sp->rcvlen=0;
			sp->staflg=S_STX; 
            sp->rcvdle=0;
			continue;
		}
		if ( sp->staflg!=S_STX ) {
            continue;
		}
        if ( rc==ETX ) {
			sp->staflg = S_ETX;
			i++;	/* 残り受信データのセット */
			if ( i<len ) {
				if ( sp->rcvlen+len-i <= RCVMAX ) {
					sp->zanp = sp->rcvlen;
					sp->zanlen = len-i;
					bufp++;
					memcpy(dp,bufp,sp->zanlen);
				}
				else {
                    sp->staflg = E_BUFFOV;
                }
			}
			break;
		}
		else if ( rc==DLE ) {
			if ( sp->rcvdle==0 ) {
                 sp->rcvdle=1; 
                 continue; 
            }
		}
		if ( sp->rcvlen<RCVMAX ) {
			if ( sp->rcvdle ) {
				if ( rc==DLE ) {
                    rc=DLE;
                }
				else if ( rc==DC2 ) {
                    rc=STX;
                }
				else if ( rc==DC3 ) {
                    rc=ETX;
                }
				sp->rcvdle = 0;
			}
			*dp++=rc; 
            sp->rcvlen++;
		}
		else {
			sp->staflg = E_BUFFOV; 
            break;
		}
	}
	return(0);
}
