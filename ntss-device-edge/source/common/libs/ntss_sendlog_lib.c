#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <signal.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <sys/file.h>
#include <sys/time.h>
#include <sys/fcntl.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "ntss_sendlog_lib.h"
#include "config_reader.h"
#include "../nkklib/nkklib.h"
#include "../libs/ntss_etc_lib.h"

#define	SNDMAX		1024 * 10	// 送信データ最大バイト数
#define	TIMEOUT		60			// タイムアウト値（60秒）

// 設定ファイル
#define CONFIG_FILE 			"./conf/ntss_logger.conf"
#define CONFIG_TAG_COUNT        100
#define TAG_LOGSV_HOST          "LOGSV_HOST"
#define TAG_LOGSV_PORT          "LOGSV_PORT"
#define TAG_LOGSV_TEMP          "LOGSV_TEMP"

// 通信制御文字コード
#define	STX			0x02
#define	ETX			0x03
#define	DLE			0x10
#define	DC2			0x12
#define	DC3			0x13
#define	ENQ			0x05
#define	EOT			0x04
#define	ACK			0x06
#define	NAK			0x15

#define	NTSS_RECOVERY_FILE	"ntss_application.dat"

// ログ送信情報
struct sendlog_info {
	char logsv_addr[20];		// ログサーバーアドレス
	int logsv_port;				// ログサーバーポート
	int connect_sock;			// ソケット
	int connect_sta;			// 接続状態(0:未接続 1:接続中 2:接続完了)
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long connect_time;			// コネクション開始時間
	time_t connect_time;			// コネクション開始時間
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	char logsv_temp[50];		// 作業用フォルダ
    unsigned char prog[256];	// 自プロセス名

} snd_info = { "", 0, 0, 0, 0, "", "" };

/**
* @brief ソケット作成／コネクション処理
*/
extern int sendlog_connect(struct sendlog_info *info);

/**
 * @brief コネクション完了確認
 */
extern int sendlog_connect_chack(struct sendlog_info *info);

/**
* @brief ソケットクローズ処理
*/
extern void sendlog_close(struct sendlog_info *info);

/**
* @brief ログ送信電文変換
*/
extern int sendlog_data_conv(unsigned char *data, unsigned char *sndbuf);

/**
 * @brief 設定ファイルの内容を取得
 */
extern int sendlog_read_config(const char *configFileName, struct sendlog_info *info);

/**
 * @brief 最期に入る改行(\r\n)を取り除く
 */
extern void sendlog_lntrim(char *str);

/**
* @brief ログ送信初期化処理
*
* @details ログサーバに接続を行う
*
* @description
* @return int :接続状態(0:未接続 1:接続中 2:接続完了)
* @attention 設定ファイルからアドレス・ポート番号を取得
*/
int ntss_sendlog_init()
{
	int ret = snd_info.connect_sta;

	if (ret == 0) {
		ret = sendlog_read_config(CONFIG_FILE, &snd_info);

	    // 自プロセス名を取得
		getProcessName( snd_info.prog, sizeof(snd_info.prog), 0x00 );

 		if (ret == 0 && snd_info.logsv_addr[0] && snd_info.logsv_port != 0) {
			// ソケット作成／コネクション処理
			sendlog_connect(&snd_info);
			// コネクション完了確認
			sendlog_connect_chack(&snd_info);
		}
	}
	return ret;
}

/**
* @brief ログ送信初期化処理
*
* @details ログサーバに接続を行う
*
* @description
* @param[in] *addr  ログサーバーアドレス
* @param[in] *port  ログサーバーポート番号
* @return int :接続状態(0:未接続 1:接続中 2:接続完了)
* @attention 特になし
*/
int ntss_sendlog_init_p(char *addr, int port)
{
	int ret = snd_info.connect_sta;

	if (ret == 0) {
	    // 自プロセス名を取得
		getProcessName( snd_info.prog, sizeof(snd_info.prog), 0x00 );
		// ログサーバーアドレス
		strcpy(snd_info.logsv_addr, addr);
		// ログサーバーポート
		snd_info.logsv_port = port;
		// ソケット作成／コネクション処理
		sendlog_connect(&snd_info);
		// コネクション完了確認
		sendlog_connect_chack(&snd_info);
	}
	return ret;
}

/**
* @brief ログ送信終了処理
*
* @details ログ送信終了処理を行う
*
* @attention 特になし
*/
void ntss_sendlog_exit()
{
	// ソケットクローズ処理
	sendlog_close(&snd_info);
	// ログ送信情報の初期化
	memset(&snd_info, 0, sizeof(snd_info));
}

/**
* @brief ログ送信処理
*
* @details ログサーバに送信を行う
*
* @description
* @param[in] flg 出力フラフ
*            0:通常
*            1:システム情報有り
*            2:ネットワーク状態有り（アンテナレベル含む）
* @param[in] *param  パラメータ（9項目TAB区切り）
* @param[in] *logmsg  ログデータ
* @return int :送信済みデータ長
* @attention param : "1\t2\t3\t4\t"
*            param(1) :型式
*            param(2) :製造番号
*            param(3) :サービス名
*            param(4) :ログ種別
*/
int ntss_sendlog(int flg, char *param, char *logmsg)
{
	int ret = 0;
	int rtn;
	int sndlen;
	int recovery;
	int cnt;
	FILE *fp;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//struct timeval sendtime;
    struct timespec sendtime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	struct tm *time_st;
	char buf[100];
	unsigned char wrkbuf[SNDMAX];
	unsigned char sndbuf[SNDMAX];
	fd_set writefds;
	struct timeval seltime;

	if (snd_info.connect_sock == 0 && snd_info.connect_sta == 0) {
		// ログ送信初期化処理
		ntss_sendlog_init();
	}
	else if (snd_info.connect_sock != 0 && snd_info.connect_sta == 1) {
		// コネクション完了確認
		sendlog_connect_chack(&snd_info);
	}

	memset(wrkbuf, 0, sizeof(wrkbuf));
	// 送信時刻（現在時刻）
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//gettimeofday(&sendtime, NULL);
	//time_st = localtime(&sendtime.tv_sec);
	//sprintf(wrkbuf, "%d\t%04d/%02d/%02d %02d:%02d:%02d.%06ld\t",
	//	flg,
	//	time_st->tm_year + 1900,
	//	time_st->tm_mon + 1,
	//	time_st->tm_mday,
	//	time_st->tm_hour,
	//	time_st->tm_min,
	//	time_st->tm_sec,
	//	sendtime.tv_usec);
    clock_gettime(CLOCK_REALTIME, &sendtime);
	time_st = localtime(&sendtime.tv_sec);
	sprintf(wrkbuf, "%d\t%04d/%02d/%02d %02d:%02d:%02d.%06ld\t",
		flg,
		time_st->tm_year + 1900,
		time_st->tm_mon + 1,
		time_st->tm_mday,
		time_st->tm_hour,
		time_st->tm_min,
		time_st->tm_sec,
		sendtime.tv_nsec / 1000);
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	if ( *param == 0 ) {
		strcat(wrkbuf, "\t\t\t\t\t\t\t\t\t");
	}
	else {
		strcat(wrkbuf, "\t\t");
		get_text(1, param, buf);
		strcat(wrkbuf, buf);
		strcat(wrkbuf, "\t");
		get_text(2, param, buf);
		strcat(wrkbuf, buf);
		strcat(wrkbuf, "\t\t");
		get_text(3, param, buf);
		if ( buf[0] == 0 ) {
			strcpy(buf, snd_info.prog);
		}
		strcat(wrkbuf, buf);
		strcat(wrkbuf, "\t\t\t");
		get_text(4, param, buf);
		strcat(wrkbuf, buf);
		strcat(wrkbuf, "\t");
	}
	// メッセージ内の\tを{TAB}に置換してwrkbufに連結
	for(cnt = 0; cnt < SNDMAX; cnt++) {
		if ( logmsg[cnt] == '\0' ) {
			// \0が来たら連結してTAB置換処理を終了
			strcat(wrkbuf, logmsg);
			break;
		}
		if ( logmsg[cnt] == '\t' ) {
			// tabが来た場合は\0に変換して、そこまで連結
			logmsg[cnt] = '\0';
			strcat(wrkbuf, logmsg);
			// {TAB}を追記
			strcat(wrkbuf, "{TAB}");
			// 先頭ポインタを変更
			logmsg += cnt + 1;
			cnt = 0;
		}
	}

	// ログ送信電文変換
	sndlen = sendlog_data_conv(wrkbuf, sndbuf);
	if ( sndlen <= 0 ) {
		return ret;
	}

	recovery = 0;

	if (snd_info.connect_sock != 0 && snd_info.connect_sta == 2) {
		// ログ送信処理
		FD_ZERO(&writefds);
		FD_SET(snd_info.connect_sock, &writefds);
		seltime.tv_sec = 0;
		seltime.tv_usec = 100000;
		rtn = select(FD_SETSIZE, 0, &writefds, 0, &seltime);
		if (rtn >= 0) {
			ret = read(snd_info.connect_sock, buf, 1);
			// ret:-1 Connection OK :0 Connection NG
			// errno:111 Connection refused（接続は拒否された）
			if ( ret != 0 && errno != 111 ) {
				// 書き込み（送信日付 + param(1)〜(9)）
				ret = write(snd_info.connect_sock, sndbuf, sndlen);
			}
			if ( errno == 111 || ret <= 0 ) {
				// ソケットクローズ処理
				sendlog_close(&snd_info);
				// ソケット作成／コネクション処理
				sendlog_connect(&snd_info);
				// コネクション完了確認
				sendlog_connect_chack(&snd_info);
				recovery = 1;
			}
		}
		else {
			// ソケットクローズ処理
			sendlog_close(&snd_info);
			// ソケット作成／コネクション処理
			sendlog_connect(&snd_info);
			// コネクション完了確認
			sendlog_connect_chack(&snd_info);
			recovery = 1;
		}
	}
	else {
		recovery = 1;
	}

	if ( recovery ) {
		// ログ復旧用出力
		// ファイルオープン
		createFolder( snd_info.logsv_temp );
		sprintf(buf, "%s/recovery_%s", snd_info.logsv_temp, NTSS_RECOVERY_FILE);
		fp = fopen(buf, "ab+");
		if ( fp == NULL ) {
			return ret;
		}
		//ファイルを排他ロック
		flock(fileno(fp),LOCK_EX);
		// ファイルの書き込み
		ret = fwrite(sndbuf, sizeof( unsigned char ), sndlen, fp);
		//ロックの解除
		flock(fileno(fp),LOCK_UN);
		// ファイルクローズ
		fclose(fp);
	}
	
	return ret;
}

/**
* @brief ソケット作成／コネクション処理
*/
int sendlog_connect(struct sendlog_info *info)
{
	int sfd;	// ソケットファイルディスクプリタ
	int val = 1;
	struct sockaddr_in saddr;

	// ソケットを作成（NX通信接続用）
	sfd = socket(AF_INET, SOCK_STREAM, 0);
	if (sfd < 0) {
		return -1;
	}
	// ノンブロッキングソケットに変更
	ioctl(sfd, FIONBIO, &val);

	// コネクション
	saddr.sin_family = AF_INET;
	saddr.sin_port = htons(info->logsv_port);
	saddr.sin_addr.s_addr = inet_addr(info->logsv_addr);
	// コネクション
	connect(sfd, (struct sockaddr*)&saddr, sizeof(saddr));
	info->connect_sock = sfd;
	info->connect_sta = 1;
	time(&info->connect_time);

	return 0;
}

/**
 * @brief コネクション完了確認
 */
int sendlog_connect_chack(struct sendlog_info *info)
{
	int ret = 0;
	int rtn;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long gtime;
	time_t gtime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	char buf[2];
	fd_set writefds;
	struct timeval seltime;

	if (info->connect_sock != 0 && info->connect_sta == 1) {
		// タイムアウトチェック
		time(&gtime);
		if (gtime > (info->connect_time + TIMEOUT)) {
			// ソケットクローズ処理
			sendlog_close(&snd_info);
			// ソケット作成／コネクション処理
			sendlog_connect(&snd_info);
		}

		// コネクション状態確認
		FD_ZERO(&writefds);
		FD_SET(info->connect_sock, &writefds);
		seltime.tv_sec = 0;
		seltime.tv_usec = 100000;
		rtn = select(FD_SETSIZE, 0, &writefds, 0, &seltime);
		if (rtn > 0) {
			rtn = read(snd_info.connect_sock, buf, 1);
			if ( rtn < 0 && errno == EAGAIN ) {
				// コネクション完了
				info->connect_sta = 2;
				ret = 1;
			}
		}
	}
	return ret;
}

/**
* @brief ソケットクローズ処理
*/
void sendlog_close(struct sendlog_info *info)
{
	if (info->connect_sta != 0) {
		// シャットダウン(送受信禁止)
		shutdown(info->connect_sock, 2);
		// ソケットクローズ
		close(info->connect_sock);
	}
	info->connect_sock = 0;
	info->connect_sta = 0;
	info->connect_time = 0;
}

/**
* @brief ログ送信電文変換
*/
int sendlog_data_conv(unsigned char *data, unsigned char *sndbuf)
{
	int i;
	int sndlen = 0;
	int dlen = strlen(data);
    unsigned char *bp,*dp,crc;

    if ( dlen > 0 ) {
        dp = sndbuf;
		bp = data;
		crc = 0;
        *dp++=STX;
        for ( i=0,sndlen=1; i<dlen; i++,bp++ ) {
            crc+=(*bp);
            if ( *bp==STX )      { *dp++=DLE; *dp++=DC2; sndlen+=2; }
            else if ( *bp==ETX ) { *dp++=DLE; *dp++=DC3; sndlen+=2; }
            else if ( *bp==DLE ) { *dp++=DLE; *dp++=DLE; sndlen+=2; }
            else                 { *dp++=(*bp); sndlen++; }
        }
        if ( crc==STX )      { *dp++=DLE; *dp++=DC2; sndlen+=2; }
        else if ( crc==ETX ) { *dp++=DLE; *dp++=DC3; sndlen+=2; }
        else if ( crc==DLE ) { *dp++=DLE; *dp++=DLE; sndlen+=2; }
        else                 { *dp++=crc; sndlen++; }
        *dp++=ETX;
		sndlen++;
    }
    return(sndlen);
}

/**
 * @brief 設定ファイルの内容を取得
 * 
 * @param configFileName 
 * @param info 
 * @return int32_t 
 */
int sendlog_read_config(const char *configFileName, struct sendlog_info *info)
{   
    ConfigData_t configData[CONFIG_TAG_COUNT];
    memset( configData, 0, sizeof(configData) );

    if (readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0){
        return -1;
    }

    // 設定ファイルの値を構造体にセットする
    char *pVal;
    strcpy(info->logsv_addr, "");
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_LOGSV_HOST);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(info->logsv_addr, pVal, sizeof(info->logsv_addr));
    	sendlog_lntrim(info->logsv_addr);
	}
    info->logsv_port = 0;
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_LOGSV_PORT);
	if ( pVal != NULL && pVal != "" ) {
		sendlog_lntrim(pVal);
        info->logsv_port = atoi(pVal);
	}
    strcpy(info->logsv_temp, "./temp");
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_LOGSV_TEMP);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(info->logsv_temp, pVal, sizeof(info->logsv_temp));
    	sendlog_lntrim(info->logsv_temp);
	}
    return 0;
}

/**
 * @brief 最期に入る改行(\r\n)を取り除く
 * 
 * @param *str 
 */
void sendlog_lntrim(char *str)
{  
	char *p;

	p = strchr(str, '\r');
	if(p != NULL) {
		*p = '\0';
	}
	p = strchr(str, '\n');
	if(p != NULL) {
		*p = '\0';
	}
}
