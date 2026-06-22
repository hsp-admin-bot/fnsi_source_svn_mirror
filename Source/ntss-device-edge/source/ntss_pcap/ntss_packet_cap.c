/**
* @brief パケットキャプチャ関連処理ファイル
*
* @details キャプチャした特定コマンドをファイルに出力
* (pcap_next_exによる受信処理)
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_packet_cap.c
* @author H.Yonezawa
* @date 2017/10/20
*/


#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

#include <pcap.h>
#include <pcap/pcap.h>
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/in.h>
#include <netinet/udp.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/config_reader.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/nkklib/nkklib.h"

#include "ntss_devicecap_conf.h"
#include "ntss_packet_manage.h"
#include "ntss_nkk_comm.h"
#include "ntss_common_comm.h"
#include "ntss_packet_cap.h"


/// @name キャプチャ関連保持情報
//@{
/// キャプチャデバイスハンドル
pcap_t *hCaptureDevice;
/// エラー文字列格納領域
char errbuf[PCAP_ERRBUF_SIZE];
/// キャプチャステータス
struct pcap_stat old_stat;
//@}


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
                )
{
    u_char clog[ NTSS_STR_MAX_SIZE ];
    int ipsize = 0;
    int iphdrsize = 0;
    struct tcphdr *tcp;
    int tcphdrsize = 0;
    u_char *data;
    int dataLength = 0;
    struct NTSS_PACKET_INFORMATION *pacInfo;
    
    // ipデータ長取得
    ipsize = ntohs(ip->tot_len);
    // ipヘッダー長取得
    iphdrsize = (ip->ihl * 4);    
    
    // tcpヘッダー取得
    tcp = (struct tcphdr *)((char *)ip + iphdrsize);
    // tcpヘッダー長取得
    tcphdrsize = (tcp->doff *4);

    // データ取得
    data = (u_char*)((char *)ip + iphdrsize + tcphdrsize);
    dataLength =  ipsize - iphdrsize - tcphdrsize;

    /* tcpヘッダー表示 */
    // printf("source  = %d\n", ntohs(tcp->source));
    // printf("dest    = %d\n", ntohs(tcp->dest));
    // printf("seq     = %d\n", ntohs(tcp->seq));
    // printf("ack     = %d\n", ntohs(tcp->ack));

    // printf("doff    = %d\n", tcp->doff);
    // printf("res1    = %d\n", tcp->res1);

    // //    printf("cwr     = %d\n", tcp->cwr);
    // //    printf("ece     = %d\n", tcp->ece);
    // printf("urg     = %d\n", tcp->urg);
    // printf("ack     = %d\n", tcp->ack);
    // printf("psh     = %d\n", tcp->psh);
    // printf("rst     = %d\n", tcp->rst);
    // printf("syn     = %d\n", tcp->syn);
    // printf("fin     = %d\n", tcp->fin);

    // printf("window  = %d\n", ntohs(tcp->window));
    // printf("check   = 0x%.4x\n", ntohs(tcp->check));
    // printf("urg_ptr = %d\n", ntohs(tcp->urg_ptr));
    // printf("\n");

    // /* 各データ長表示　*/
    // printf("pkthdrsize = %d\n", header.len);
    // printf("ipsize     = %d\n", ipsize);
    // printf("iphdrsize  = %d\n", iphdrsize);
    // printf("tcphdrsize = %d\n", tcphdrsize);

    // /* データ表示 */
    // printf("datalen = %d bytes\n", dataLength);
    // printf("data = ");
    // int i;
    // for ( i = 0; i < dataLength; i++) 
    // {
    //     printf("%.2x - ", data[i]);
    // }
    // printf("\n\n");   

    // ※受信データ長さが0の場合は出力しない(SYNとFINは出力する)
    int bWrite = 0;
    char cSynFin[] ={0,0,0,0};

    if( dataLength <= 0 )
    {
        // 受信データがない場合

        // TCPの場合
        if(ip->protocol == IPPROTO_TCP )
        {
            // SYNは出力する
            if( tcp->syn == 1 )
            {
                strcat( cSynFin, "SYN" );
                bWrite = 1;
            }

            // FINは出力する
            if( tcp->fin == 1 )
            {
                strcat( cSynFin, "FIN" );
                bWrite = 1;
           }
        }
    }
    else
    {
        // 受信データがある場合はコマンド判定を行う
        bWrite = 1;
    }

    // 送信元情報作成
    unsigned char sourceInfo[23];
    sprintf(sourceInfo, "%s_%d"
        , inet_ntoa(*(struct in_addr *)&(ip->saddr))
        , ntohs(tcp->source)
    );

    // コマンド判定を行う場合
    if( bWrite == 1 )
    {
        // 受信日時
        struct tm now;
        localtime_r( &header.ts.tv_sec, &now );
        char week[][4] = {"日","月","火","水","木","金","土"};
        printf("*** %04d/%02d/%02d/(%s) %02d:%02d:%02d.%06ld ***\n",
        now.tm_year+1900,
        now.tm_mon + 1,
        now.tm_mday,
        week[now.tm_wday],
        now.tm_hour,
        now.tm_min,
        now.tm_sec,
        header.ts.tv_usec
        );
    }

    // FINの場合
    if( tcp->fin == 1 )
    {
        // パケット管理情報を検索
        pacInfo = findNTSSPacketInfo( ip->saddr, ip->daddr, tcp->source, tcp->dest, NULL, FINDNTSSPACKETINFO_NO_UPDATE );
        if( pacInfo != NULL )
        {
            // FIN処理

            sprintf( clog, "FIN %s", sourceInfo );
            outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, pacInfo );
            printf( "%s\n", clog );

            // 対象パケット管理情報でFIN処理実施
            finNTSSPacketInfo( pacInfo );
        }         
        else
        {
            // debug
            printf(" ＊＊ FIN パケット管理情報未登録 ＊＊\n");                
        }
    }

    // 通信SVへの電文かどうか
    if( bWrite == 1 )
    {
        // 送信先がSVとして登録されているかどうか
        if(( bWrite = existFnSVInfo(
              ip->daddr
            , tcp->dest
        )) != 1)
        {
            //　未登録

            printf( "　＊＊ 未登録SV　＊＊\n");
        }
    }

    // 出力判定
    if( bWrite == 1 )
    {
        // 送信先情報作成
        unsigned char destInfo[23];
        sprintf(destInfo, "%s_%d"
            , inet_ntoa(*(struct in_addr *)&(ip->daddr))
            , ntohs(tcp->dest)
        );

        // 画面出力
        // 送信元/送信先情報
        printf("%s -> %s"
            , sourceInfo
            , destInfo
        );
        // データ
        printf(" ( %d byte )", dataLength);
        printf(" %s\n", cSynFin);

        // 受信データがある場合
        if( 0 < dataLength )
        {
            // パケット管理情報検索(送信元/送信先IP、ポート番号のみで検索)
            pacInfo = findNTSSPacketInfo( ip->saddr, ip->daddr, tcp->source, tcp->dest, NULL, FINDNTSSPACKETINFO_NO_UPDATE );
            if( pacInfo == NULL )
            {
                // 情報なし

                u_char cDeviceNo[11];
                cDeviceNo[0] = cDeviceNo[10] = 0;
                if( data[0] == NTSS_NKK_STX )
                {
                    // 通信フォーマット＋製造番号＋通信方式を取得(日機装通信方式の場合のみ)

                    // NX判定
                    if( data[1] == NTSS_NKK_NX_ID )
                    {
                        // NX通信

                        // 送信元装置ID
                        cDeviceNo[0] = data[3];
                        // 製造番号
                        cDeviceNo[1] = data[6];
                        cDeviceNo[2] = data[8];
                        cDeviceNo[3] = data[10];
                        cDeviceNo[4] = data[12];
                        cDeviceNo[5] = data[14];
                        cDeviceNo[6] = data[16];
                        cDeviceNo[7] = data[18];
                        cDeviceNo[8] = data[20];

                        // 製造番号の先頭にスペースがある場合
                        if( cDeviceNo[1] == 0x20 )
                        {
                            //　前に詰める
                            memmove( cDeviceNo + 1, cDeviceNo + 2, 8 );
                            cDeviceNo[8] = 0x20; 
                        }
                        cDeviceNo[9] = NTSS_COMM_TYPE_NX;   // 通信方式(NX通信)
                    }
                    else
                    {
                        // 新通信(NX通信以外)

                        // 通信フォーマット＋製造番号
                        memmove( cDeviceNo, data + 1, 8 );
                        cDeviceNo[8] = 0x20;
                        cDeviceNo[9] = NTSS_COMM_TYPE_NEW;  // 通信方式(新通信)
                    }

                    //
                    sprintf(clog, "装置接続確認:%s-%s", sourceInfo, cDeviceNo );
                    LogOutput( NTSS_LOG_INFO, clog );

                    printf( "%s\n", clog );
                }
                else
                {
                    // STX判定
                    int intlop = 0;
                    for( intlop = 0; intlop < NTSS_COMMON_STX_COUNT; intlop++ )
                    {
                        if( data[0] == NTSS_COMMON_STX[ intlop] )
                        {
                            if( data[1] == '3' )
                            {
                                // 通信共通プロトコルV3

                                cDeviceNo[1] = 'W';
                                cDeviceNo[9] = NTSS_COMM_TYPE_COMMON;  // 通信方式(通信共通)

                                break;
                            }
                            else if( data[1] == '4' )
                            {
                                // 通信共通プロトコルV4

                                cDeviceNo[1] = 'V';
                                cDeviceNo[9] = NTSS_COMM_TYPE_COMMON;  // 通信方式(通信共通)

                                break;
                            }
                        }
                    }
                }

                // パケット管理情報検索(送信元IPアドレス+通信フォーマット(送信元装置ID)＋製造番号＋通信方式、又は送信元IPアドレス+通信方式で検索)
                pacInfo = findNTSSPacketInfo( ip->saddr, ip->daddr, tcp->source, tcp->dest, cDeviceNo, FINDNTSSPACKETINFO_UPDATE );
                if( pacInfo != NULL )
                {
                    //
                    sprintf(clog, "装置マスタに該当情報あり:%s-%s", sourceInfo, cDeviceNo );
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, pacInfo );
                    printf( "%s\n", clog );

                } else if( getCreateMachineInfoMode() == true ) {
                    // 装置情報作成モードである場合
                    sprintf(clog, "装置マスタに新規装置情報を登録:%s-%s", sourceInfo, cDeviceNo );
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, pacInfo );
                    printf( "%s\n", clog );

                    // 新しい装置情報を管理テーブルに追加
                    pacInfo = AddNTSSPacketInfo( ip->saddr, ip->daddr, tcp->source, tcp->dest, "000", cDeviceNo[0], cDeviceNo + 1,  cDeviceNo[9] );

                    // 新しい装置情報の登録用ファイルを作成
                    outputNTSSCreateMachineInfo( devicecapConf.cFacilityCode, devicecapConf.nDeviceEdgeNo, pacInfo, header.ts );
                }
            }

            if( pacInfo == NULL )
            {
                // debug
                printf(" ＊＊ パケット管理情報未登録 ＊＊\n");
            }
            else
            {
                // パケット管理情報が存在する場合

                // debug
                printf(" find packetInfoIndex:%d\n", getNTSSPacketInfoIndex( pacInfo ));

                // 装置情報作成モード判定
                if( getCreateMachineInfoMode() == false ) {
                    // 装置情報作成モードではない場合
                
                    // 接続状態を接続中に更新
                    pacInfo->isConnected = 0x01;

                    // バッファリング処理
                    UpdateNTSSPacketInfo( &pacInfo->buffer, header.ts, data, dataLength );
                
                    // 通信方式判定
                    if( pacInfo->cCommType == NTSS_COMM_TYPE_NEW || pacInfo->cCommType == NTSS_COMM_TYPE_NX )
                    {
                        // 新通信、又はNX通信

                        // 日機装新装置通信方式
                        checkNTSSNKKCommand( pacInfo );
                    }
                    else if( pacInfo->cCommType == NTSS_COMM_TYPE_COMMON )
                    {
                        // 通信共通プロトコル

                        // 通信共通プロトコル方式
                        checkNTSSCommonCommand( pacInfo );
                    }
                }
            }
        }
    }
}

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
                 )
{
    // ipヘッダー取得
    struct iphdr *ip;
    ip = (struct iphdr *)(p + sizeof(struct ether_header));

/*
    // 受信日時
    struct tm *pnow = localtime( &header.ts.tv_sec );
    char week[][4] = {"日","月","火","水","木","金","土"};
    printf("*** %04d/%02d/%02d/(%s) %02d:%02d:%02d.%06ld ***\n",
       pnow->tm_year+1900,
       pnow->tm_mon + 1,
       pnow->tm_mday,
       week[pnow->tm_wday],
       pnow->tm_hour,
       pnow->tm_min,
       pnow->tm_sec,
       header.ts.tv_usec
    );

    // ipヘッダー表示
    printf("version  = 0x%x\n", ip->version);
    printf("ihl      = 0x%x\n", ip->ihl);
    printf("tos      = 0x%.2x\n", ip->tos);
    printf("tot_len  = %d bytes\n", ntohs(ip->tot_len));
    printf("id       = 0x%.4x\n", ntohs(ip->id));
    printf("frag_off = 0x%.4x\n", ntohs(ip->frag_off));
    printf("ttl      = 0x%.2x\n", ip->ttl);
    printf("protocol = 0x%.2x\n", ip->protocol);
    printf("check    = 0x%.4x\n", ntohs(ip->check));
    printf("saddr    = %s\n", inet_ntoa(*(struct in_addr *)&(ip->saddr)));
    printf("daddr    = %s\n", inet_ntoa(*(struct in_addr *)&(ip->daddr)));
    printf("\n");
*/

    // プロトコル判定
    switch(ip->protocol) {
        case IPPROTO_UDP:
            break;

        case IPPROTO_TCP:
            //
            printNTSSTcpData(ip, header);
            break;

        case IPPROTO_ICMP:
            break;

        default:
            break;
    }
}
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
int
initNTSSPacketCapture( u_char *cFolder
                     )
{
    int ret = 0;

    // 統計情報初期化
    memset( &old_stat, 0, sizeof( old_stat ));

    
    // パケット管理情報を登録する
    if( initNTSSPacketInfo(
          cFolder
    ) != 1 )
    {
        //
        viewError( "透析装置情報(mstMachineInfo.dat)が読み込めませんでした" );
    }

    // キャプチャ対象コマンド管理情報を登録する
    if( initNTSSNKKCaptureCommandInfo() == 1 )
    {
        ret = 1;
    }
    else
    {
        //
        viewError( "キャプチャ対象コマンド管理情報(ntss_pcap_command.conf)登録失敗" );
    }

    return ret;
}

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
pcap_t *
openNTSSPcapDevice( u_char *dev 
                  , u_char *errbuf
                  )
{
    pcap_t *handle;
    u_char cmsg[ NTSS_STR_MAX_SIZE ];

/*    
    // 受信用のデバイスを開く
    if ((handle = pcap_open_live(
          dev                           // デバイス名
        , DPCP_BUFFER_SIZE　            // パケットキャプチャーサイズ
        , DPCP_PROMSCS_MODE             // Promiscuousモードの有無[1]
        , DPCP_RCV_TIMEOUT_REALTIME     // 読み出しタイムアウト時間[ミリ秒]
        , errbuf                        // エラー文字列
       )) == NULL)
    {
        fprintf(stderr, "Couldn't open device %s: %s\n", dev, errbuf);
        exit(EXIT_FAILURE);
    }
    else
    {
        // 指定デバイスがイーサネットかどうか判定
        if (pcap_datalink(handle) != DLT_EN10MB)
        {
            handle = NULL;

            fprintf(stderr, "Device not support: %s\n", dev);
            exit(EXIT_FAILURE);
        }    
    }
*/
    // 受信用デバイスを構築する
    if(( handle = pcap_create(
          dev                   // デバイス名
        , errbuf                // エラー文字列
        )) == NULL )
    {
        //
        sprintf(cmsg, "pcap_create失敗 device %s: %s", dev, errbuf);
        viewError( cmsg );
    }

    // パケットキャプチャーサイズを設定する
    if( pcap_set_snaplen(
          handle                // デバイスハンドル
        , DPCP_SNAP_SIZE        // パケットキャプチャーサイズ
        ) != 0 )
    {
        //
        sprintf( cmsg, "pcap_set_snaplen失敗 device %s: %s", dev, pcap_geterr( handle ));
        viewError( cmsg );
    }

    // Promiscuousモードを指定する
    if( pcap_set_promisc(
          handle                // デバイスハンドル
        , DPCP_PROMSCS_MODE     // Promiscuousモードの有無[1]
        ) != 0 )
    {
        //
        sprintf( cmsg, "pcap_set_promisc失敗 device %s: %s", dev, pcap_geterr( handle ));
        viewError( cmsg );
    }

    // 読み出しタイムアウト時間を設定する
    if( pcap_set_timeout(
          handle                // デバイスハンドル
        , DPCP_RCV_TIMEOUT_1000 // 読み出しタイムアウト時間[ミリ秒]
        ) != 0 )
    {
        //
        sprintf( cmsg, "pcap_set_timeout失敗 device %s: %s", dev, pcap_geterr( handle ));
        viewError( cmsg );
    }

    // 即時モードを設定する
    if( pcap_set_immediate_mode(
          handle                // デバイスハンドル
        , DPCP_IMMEDIATE_MODE   // Immediateモードの有無[1]
        ) != 0 )
    {
        //
        sprintf( cmsg, "pcap_set_immediate_mode失敗 device %s: %s", dev, pcap_geterr( handle ));
        viewError( cmsg );
    }

    // // 非ブロッキングモードを設定する
    // if( pcap_setnonblock(
    //       handle                // デバイスハンドル
    //       , DPCP_NONBLOCK_MODE  //
    //       , errbuf
    //     ) != 0 )
    // {
    //     //
    //     sprintf( cmsg, "pcap_setnonblock失敗 device %s: %s", dev, errbuf);
    //     viewError( cmsg );
    // }

    // 受信用バッファサイズを指定する
    if( pcap_set_buffer_size(
          handle                // デバイスハンドル
        , DPCP_BUFFER_SIZE      // 受信バッファサイズ
        ) != 0 )
    {
        //
        sprintf( cmsg, "pcp_set_buffer_size失敗 device %s: %s\n", dev, pcap_geterr( handle ));
        viewError( cmsg );
    }

    // 受信用デバイスを有効にする
    if( pcap_activate(
         handle                 // デバイスハンドル
        ) != 0 )
    {
        //
        sprintf( cmsg, "pcp_activate失敗 device %s: %s", dev, pcap_geterr( handle ));
        viewError( cmsg );        
    }

    // 指定デバイスがイーサネットかどうか判定
    if (pcap_datalink(
        handle                  // デバイスハンドル
        ) != DLT_EN10MB)
    {
        //
        sprintf( cmsg, "pcp_datalink失敗 device %s: %s", dev, pcap_geterr( handle ));
        viewError( cmsg );        
    }    

    return handle;
}

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
int
setNTSSPcapFilter( pcap_t *handle
                 , u_char *filter
                 )
{
    int ret = 0;
    struct pcap_pkthdr header;
    struct bpf_program fp;
    bpf_u_int32 net;
    u_char cmsg[ NTSS_STR_MAX_SIZE ];

    // debug
    //printf("filter:[%s]\n", filter);

    //パケットフィルター設定
    if (( ret = pcap_compile(
          handle    // デバイスハンドル
        , &fp       // フィルタ文字列のコンパイル結果
        , filter    // フィルタ文字列
        , 0         // ？
        , net       // ？
        )) == -1)
    {
        //
        sprintf( cmsg, "Couldn't parse filter: %s", pcap_geterr(handle));
        viewError( cmsg );
    }
    // debug
    //printf("Step1\n");

    if (( ret  = pcap_setfilter(
          handle    // デバイスハンドル
        , &fp       // フィルタ文字列のコンパイル結果
        )) == -1)
    {
        //
        sprintf( cmsg, "Couldn't install filter: %s", pcap_geterr(handle));
        viewError( cmsg );
    }
    // debug
    //printf("Step2\n");
    
    return ret;
}

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
int
checkNTSSPcapData( pcap_t *handle
                 )
{
    int ret;
    struct pcap_pkthdr *header;
    const u_char *packet;

    if(ret = pcap_next_ex(
          handle        // デバイスハンドル
        , &header       // ヘッダーデータ
        , &packet       // パケットデータ
        ) == 1 )
    {

        // イーサネットヘッダーとIPヘッダーの合計サイズに満たなければ無視
        if ( sizeof(struct ether_header) + sizeof(struct iphdr) < header->len)
        {
            // 受信処理
            printNTSSIpHeader(packet, *header);

/*            
            // 統計情報
            struct pcap_stat stat;
            pcap_stats( hCaptureDevice, &stat );
            if( old_stat.ps_drop != stat.ps_drop 
                || old_stat.ps_ifdrop != stat.ps_ifdrop )
            {
                u_char clog[100];
                sprintf(
                    clog
                    , "☆ Packet Informaion Recv:%d / Drop:%d / InterfaceDrop:%d ☆"
                    , stat.ps_recv
                    , stat.ps_drop
                    , stat.ps_ifdrop 
                );

                // ファイル出力
                LogOutput( NTSS_LOG_INFO, clog );
            }
            memmove( &old_stat, &stat, sizeof( stat ));
*/            
        }  
    }

    return ret;
}

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
void
closeNTSSPcap( pcap_t *handle 
             )
{
    // クローズ処理
    pcap_close(handle);        
}
