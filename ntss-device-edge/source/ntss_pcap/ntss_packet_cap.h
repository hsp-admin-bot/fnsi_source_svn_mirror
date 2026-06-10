/**
* @brief パケットキャプチャ関連処理ヘッダーファイル
*
* @details キャプチャした特定コマンドをファイルに出力
* (pcap_next_exによる受信処理)
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_packet_cap.h
* @author H.Yonezawa
* @date 2017/10/20
*/

#ifndef NTSS_PACKET_CAP_H
#define NTSS_PACKET_CAP_H


#include <pcap/pcap.h>

#include <netinet/ip.h>


/// @name pcap_open_liveで使用するパラメータ
//@{
#define DPCP_SNAP_SIZE          1024            ///< キャプチャサイズ
#define DPCP_PROMSCS_MODE       1               ///< Promiscuousモードの有無[1]：あり
#define DPCP_RCV_TIMEOUT_1000   1000            ///< 読み出しタイムアウト時間[ミリ秒]：1秒待ち
#define DPCP_RCV_TIMEOUT_10     10              ///< 読み出しタイムアウト時間[ミリ秒]：10ミリ秒待ち
#define DPCP_IMMEDIATE_MODE     1               ///< Immediateモードの有無[1]：あり
#define DPCP_NONBLOCK_MODE      1               ///< 非ブロッキングモードの有無[1]：あり
#define DPCP_BUFFER_SIZE        1024 * 1024 * 30    ///< 受信バッファサイズ：30MB
//@}



//
extern pcap_t *hCaptureDevice;
extern char errbuf[];    


/**
* @brief tcpデータ表示/ファイル出力
*
* @details tcpデータを表示後、ファイルに出力する
*
* @description
* @param[in] *ip    ipヘッダー
* @param[in] header パケットヘッダー
* @return なし
* @attention 特になし
*/
static void 
printNTSSTcpData( struct iphdr *ip
                , struct pcap_pkthdr header
                );

/**
* @brief ipヘッダー表示/プロトコルデータ表示
*
* @details ipヘッダーを表示後、各プロトコルデータを表示する
*
* @description
* @param[in] *p     受信データ
* @param[in] header パケットヘッダー
* @return なし
* @attention 特になし
*/
static void
printNTSSIpHeader( const char *p
                 , struct pcap_pkthdr header
                 );
//@}



/**
* @brief パケットキャプチャー初期化処理
*
* @details 初期化処理を行う
*
* @description
* @param[in] *cFolder       マスタファイル格納先フォルダ
* @return 1：初期化成功/else：初期化失敗
* @attention 特になし
*/
extern int
initNTSSPacketCapture( u_char *cMstFolder
                     );

/**
* @brief pcapデバイスを開く
*
* @details pcapデバイスを開く
*
* @description
* @param[in] *dev       デバイス文字列
* @param[in] *errbuf    エラー文字列文字列
* @return NULL：失敗/else：成功(デバイスハンドル)
* @attention 特になし
*/
extern pcap_t *
openNTSSPcapDevice( u_char *dev 
                  , u_char *errbuf
                  );

/**
* @brief pcapフィルタ設定
*
* @details pccpフィルタ設定
*
* @description
* @param[in] *handle    デバイスハンドル
* @param[in] *filter    フィルタ文字列
* @return 0：正常終了/else：異常終了
* @attention 特になし
*/
extern int
setNTSSPcapFilter( pcap_t *handel
                 , u_char *filter );

/**
* @brief 受信処理
*
* @details 受信処理
*
* @description
* @param[in] *handle    デバイスハンドル
* @return 1 パケットが滞りなく読み込まれた時
* @return 0 pcap_open_live()で 設定したタイムアウトが経過した時。この場合はpkt_header と pkt_data は有効なパケットを指しません。
* @return -1 エラーが発生した時
* @return -2 オフラインキャプチャからの読み込みがEOFに達した時
* @attention 特になし
*/
extern int
checkNTSSPcapData( pcap_t *handle
                 );

/**
* @brief pcapデバイスを閉じる
*
* @details pcapデバイスを閉じる
*
* @description
* @param[in] *handle    デバイスハンドル
* @return なし
* @attention 特になし
*/
extern void
closeNTSSPcap( pcap_t *handle 
             );

#endif
