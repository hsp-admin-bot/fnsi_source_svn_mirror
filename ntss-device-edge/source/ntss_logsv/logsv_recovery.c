#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <stdbool.h>
#include <sys/time.h>
#include <sys/stat.h>

#include "ntss_logsv.h"
#include "logsv_config.h"
#include "logsv_output.h"
#include "../common/nkklib/nkklib.h"
#include "../common/libs/ntss_etc_lib.h"

#define	NTSS_RECOVERY_FILE	"ntss_application.dat"

/**
 * @brief 設定情報
 * 
 */
extern ConfigParameter_t configParam;

/**
 * @brief ログ復旧処理
 * 
 * @param ptr 
 * @return void* 
 */
void *logsv_recovery(void *ptr){

	struct connect_socket *conSock = (struct connect_socket *) ptr;
	int i;
	ssize_t ret;
	FILE *fp;
	char param[12][50];
	struct stat statBuf;
	unsigned char *dp, crc;
	unsigned char head[255];
	unsigned char work[255];
	unsigned char stat[1000];
	unsigned char buff[RCVMAX];
	unsigned char info[RCVMAX];
	unsigned char mesg[RCVMAX];
	char file_org[100];
	char file_new[100];

	extern int logsv_rcvset(struct logsv_data_fm *sp, unsigned char *buf, int len);
	extern void logsv_output(char *logsv);
	extern void GetSystemAnalyzer(char *buf);

	conSock->running = true;

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	conSock->logsv = (struct logsv_data_fm *)malloc(sizeof(struct logsv_data_fm));
	memset(conSock->logsv, 0, sizeof(struct logsv_data_fm));

	LogOutput_logger( NTSS_LOG_INFO, "ログ復旧スレッド : 起動" );

	// 復旧対象の有無をチェックしてログ出力する処理
	for ( ; ; usleep(10000000) ) {	// 10秒

		if(conSock->running == false){
			break;
		}

        // 復旧対象ファイルの存在確認
		//
		sprintf(file_org, "%s/recovery_%s", configParam.logsvTemp, NTSS_RECOVERY_FILE);
		if (existFolderFile(file_org, &statBuf) == 1) {
			//printf("ファイル%sは存在します。\n", file_org);
			// ファイル移動
			sprintf(file_new, "%s/%s", configParam.logsvTemp, NTSS_RECOVERY_FILE);
			if(moveFile(file_org, file_new, NTSS_MOVEFILE_MODE_NO_OVERWRITE) == 1) {
				//printf("%sを%sに移動しました。\n", file_org, file_new);
				// ファイルオープン
				fp = fopen(file_new, "rb");
				if ( fp == NULL ) continue;
			}
			else {
				printf("%sを%sに移動できませんでした。\n", file_org, file_new);
				continue;
			}
		}
		else {
			//printf("ファイル%sは存在しません。\n", file_org);
			continue;
		}

		for ( ; ; usleep(10000) ) {

			if ( conSock->logsv->staflg != S_ETX ) {

				// ファイルの読込
				ret = fread(buff, sizeof( unsigned char ), READMAX, fp);
				if ( ret<=0 ) {
					conSock->logsv->staflg = S_WAIT;
					break;
				}
				logsv_rcvset(conSock->logsv,buff,ret);
			}

			// 読込データチェック
			if ( conSock->logsv->staflg == S_ETX ) {
				conSock->logsv->staflg = S_WAIT;
				dp = conSock->logsv->rcvbuf;
				for ( i=0,crc=0; i<conSock->logsv->rcvlen - 1; i++,dp++ ) {
					crc+=(*dp);
				}
				if ( crc != *dp ) {
					LogOutput_logger( NTSS_LOG_ERROR, "ログ復旧スレッド : 読込データ異常" );
					continue;
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
                                logsv_replace(buff, strlen(work));
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
		// ファイル削除
		if(remove(file_new) == 0) {
			//printf("%sを削除しました。\n", file_new);
		}
		else {
			printf("%sを削除できませんでした。\n", file_new);
		}
		// ファイルクローズ
		fclose(fp);
	}

	free(conSock->logsv);

	LogOutput_logger( NTSS_LOG_INFO, "ログ復旧スレッド : 終了" );
	conSock->running = false;
	conSock->using = false;
	pthread_exit((void *)0); // スレッド終了
}
