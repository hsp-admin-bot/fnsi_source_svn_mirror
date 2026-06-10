#ifndef _NTSS_LOGSV_H_
#define _NTSS_LOGSV_H_
 
#define MAX_STA_TEXT	256
#define MAX_LOG_TEXT	4095
#define UPDATER_NAME	"ntss_updater.exe"

/**
 * @brief 通信関連ヘッダー
 * 
 */

/* システム情報 */
#define	APP_MAX		200				/* 最大接続数 */
#define	LISTEN_MAX	100				/* 接続待ちキュー最大値 */

/* 通信状態 */
#define	S_WAIT		0x00			/* 待ち状態 */
#define	S_SEND		0x01			/* 送信中 */
#define	S_RECV		0x02			/* 受信待ち */
#define	S_STX		0x03			/* STX受信 */
#define	S_ETX		0x04			/* ETX受信 */
#define	S_END		0x80			/* 受信完了(正常終了) */
#define	E_BUFFOV	0x83			/* 受信バッファオーバーフロー */
#define	E_CRCCHK	0x84			/* CRCエラー */

/* 通信制御パラメータ */
#define	RCVMAX		1024 * 10		/* 受信データ最大バイト数 */
#define	READMAX		1000			/* READ最大バイト数 */

/* 通信制御文字コード */
#define	STX			0x02
#define	ETX			0x03
#define	DLE			0x10
#define	DC2			0x12
#define	DC3			0x13
#define	ENQ			0x05
#define	EOT			0x04
#define	ACK			0x06
#define	NAK			0x15

/**
 * @def
 * 配列数を求めるマクロ
 * 
 */
#define COUNTOF(array) (sizeof(array) / sizeof(array[0]))

/**
 * @brief 通信制御データ
 * 
 */
struct connect_socket{
    bool	using;
    bool	running;
    int		thread_no;
    int		accept_socket;
    struct logsv_data_fm *logsv;
};

/**
 * @brief APP制御データ
 * 
 */
struct logsv_data_fm {
	int		sock_id;				/* ソケットＮｏ */
	char	ip_addr[20];			/* IPアドレス */	
	unsigned short	port_no;		/* ポート番号 */
	short	conflg;					/* 装置との接続状態（注１）*/
	unsigned char	staflg;			/* 通信状態 */
	unsigned char	staflg_bak;     /* 通信状態控え */
	short	rcvlen;					/* 受信データバイト数 */
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long	rcvtime;				/* 受信時刻 */
	time_t	rcvtime;				/* 受信時刻 */
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	unsigned char	rcvdle;			/* 受信DLEフラグ */
	unsigned char	rcvbuf[RCVMAX];	/* 受信データバッファ */
	short	zanp;					/* 残り受信データポインタ */
	short	zanlen;					/* 残り受信データバイト数 */
};

/**
 * @brief 現在時刻
 * 
 */
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
//extern long now_time;
extern time_t now_time;
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

/**
 * @brief ログ復旧処理
 * 
 * @param ptr 
 * @return void* 
 */
extern void *logsv_recovery(void *ptr);

/**
 * @brief ログ受信処理
 * 
 * @param ptr 
 * @return void* 
 */
extern void *logsv_stream(void *ptr);

/**
 * @brief ソケットクローズ処理（ログ待受用）
 * @param *conSock 接続中ソケット情報
 */
extern int logsv_socket_close( struct connect_socket *conSock );

/**
 * @brief ログ収集シグナル送信処理
 * 
 */
extern void sendLogGatherSignal(int signo);

#endif // _NTSS_LOGSV_H_
