/**
* @brief NTSSパケットキャプチャ用コード
*
* @details 特定パケットをファイルに出力
*
* @description ntss packet capture program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_pcap.c
* @author H.Yonezawa
* @date 2017/11/09
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <signal.h>

#include "ntss_devicecap_conf.h"
#include "ntss_packet_manage.h"
#include "ntss_packet_cap.h"

#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_mst_lib.h"
#include "../common/nkklib/nkklib.h"

/// マスタ同期要求
#define NTSS_MASTER_SYNC_SIGNAL 34
/// 装置死活監視要求/通知
#define NTSS_M_ALIVE_SIGNAL 36

/// 装置情報作成モード移行要求
#define NTSS_CREATE_DEVICE_MODE_SIGNAL  40
/// 通常モード移行要求
#define NTSS_NORMAL_MODE_SIGNAL         41

/// @name signal用フラグ
//@{
/// 終了判定用フラグ
volatile sig_atomic_t endProcessFlag = 0;
// マスタ同期要求用フラグ
volatile sig_atomic_t updateMasterFlag = 0;
/// 装置死活監視要求用フラグ
volatile sig_atomic_t requestM_AliveFlag = 0;
//@}


/**
* @brief シグナル受信処理
*
* @details シグナル指示を受け付ける
*
* @description
* @param[in] *signum
* @return なし
* @attention 特になし
*/
void 
signalHandler(int signum)
{
    u_char *msg = NULL;

    switch( signum )
    {

        case SIGTERM:   // 終了指示

            // 処理終了
            endProcessFlag = 1;
            msg ="SIGTERM受信";
            break;

        case SIGINT:    // キーボード割り込み(ctrl+c)

            // 終了処理
            endProcessFlag = 1;
            msg ="SIGINT受信";
            break;

        case SIGKILL:   // 強制終了

            // 処理終了
            endProcessFlag = 1;
            msg ="SIGKILL受信";
            break;

        case SIGPIPE:   // 無効パイプへの書込
            msg ="SIGPIPE受信";
            signal( SIGPIPE,  signalHandler );
            // ログ送信用ソケットをリセット
            resetLogInfo();
            break;

        case NTSS_MASTER_SYNC_SIGNAL:   // マスタ同期機要求

            // マスタ同期要求
            updateMasterFlag = 1;
            msg ="マスタ同期要求";
            break;
        
        case NTSS_M_ALIVE_SIGNAL:   // 装置死活監視要求
            
            // 装置死活監視要求
            requestM_AliveFlag = 1;
            msg = "装置死活監視要求";
            break;
        
        case NTSS_CREATE_DEVICE_MODE_SIGNAL:    // 装置情報作成モード移行要求

            // 装置情報作成モード移行要求
            msg = "装置情報作成モード移行要求";

            // 装置情報作成モードへ移行
            setCreateMachineInfoMode( true, devicecapConf.cMstFolder );
            break;

        case NTSS_NORMAL_MODE_SIGNAL:   // 通常モード移行要求

            // 通常モード移行要求
            msg = "通常モード移行要求";
            // 通常モードへ移行
            setCreateMachineInfoMode( false, devicecapConf.cMstFolder );
            break;
    }

    //
    if( msg != NULL )
    {
        // 画面表示
        printf( "%s\n", msg );

        //// 受け取ったシグナルを記録する
        //LogOutput( NTSS_LOG_INFO, msg );
    }
}
/**
* @brief シグナル設定
*
* @details シグナル設定を行う
*
* @description
* @return シグナル設定結果
* @attention 特になし
*/
__sighandler_t setSignal()
{
    __sighandler_t ret = SIG_DFL;

    // プログラム終了のためのシグナル設定

    if( ret != SIG_ERR )
    {
        ret = signal( SIGTERM, signalHandler );
    }

    if( ret != SIG_ERR )
    {
        ret = signal( SIGINT,  signalHandler );
    }
    if( ret != SIG_ERR )
    {
        ret = signal( SIGPIPE,  signalHandler );
    }

    // マスタ同期要求のためのシグナル設定
    if( ret != SIG_ERR )
    {
        ret = signal( NTSS_MASTER_SYNC_SIGNAL, signalHandler );
    }

    // 装置死活監視要求のためのシグナル設定
    if( ret != SIG_ERR )
    {
        ret = signal( NTSS_M_ALIVE_SIGNAL, signalHandler );
    }

    // 装置情報作成モード移行要求のためのシグナル設定
    if( ret != SIG_ERR )
    {
        ret = signal( NTSS_CREATE_DEVICE_MODE_SIGNAL, signalHandler );
    }

    // 通常モード移行要求のためのシグナル設定
    if( ret != SIG_ERR )
    {
        ret = signal( NTSS_NORMAL_MODE_SIGNAL, signalHandler );
    }

    return ret;    
}


/**
* @brief メイン
*
* @details メイン処理
*
* @description
* @param[in] argc    第一引数
* @param[in] *argv[] 第二引数
* @return 終了コード
* @attention 特になし
*/
int
main( int argc
    , char *argv[]
    )
{
    char clog[1100];    
    char *dev, *filter;

    // ログ設定
    setLogInfo();

    // システム起動
    strcpy( clog, "[START],システム起動");
    printf( "%s\n", clog );
    LogOutput( NTSS_LOG_INFO, clog );

   // シグナル設定
    if( setSignal() == SIG_ERR )
    {
        // シグナル設定エラー
        viewError( "シグナルの設定ができないので終了します" );
        exit(EXIT_FAILURE);
    }
    
    // 設定ファイル読み込み
    if( getNTSSDeviceCapConf() != 1 )
    {
        viewError( "設定ファイルの読み込みに失敗しました" );
        exit(EXIT_FAILURE);
    }
    dev    = devicecapConf.cCaptureDevice;
    filter = devicecapConf.cCaptureFilter;

    // マスタファイル参照先フォルダ名作成
    clog[0] = 0;
    strcat( clog, devicecapConf.cMstFolder );
    clog[strlen( clog ) - 1 ] = 0;
	// 工程マスタからデータ取得
	if( ntss_mst_proc_read( clog ) != 0 )
    {
        viewError( "工程マスタファイルの読み込みに失敗しました" );
        exit(EXIT_FAILURE);
    }
	// モニタ項目マスタからデータ取得
	if( ntss_mst_moni_read( clog ) != 0 )
    {
        viewError( "モニタ項目マスタファイルの読み込みに失敗しました" );
        exit(EXIT_FAILURE);
    }
   
    //// 特権開放
    //seteuid(getuid());

    //// root権限付与
    //seteuid(0);


   // デバイス名とフィルタを画面に出力する
   sprintf(
         clog
       , "device:%s / filter:%s"
       , dev
       , filter 
    );
    printf("%s\n", clog);

   // デバイス名とフィルタをファイルに出力する
    LogOutput( NTSS_LOG_INFO, clog );
   
    // 引数から情報取得
    if( 1 < argc )
    {
        // プロセス番号
        devicecapConf.nOwnerProcessId = atoi( argv[1] );

        // 引数を画面に出力する
        sprintf(
                clog
            , "Owner PID:%d"
            , devicecapConf.nOwnerProcessId
        );
        printf("%s\n", clog);

        //引数をファイルに出力する
        LogOutput( NTSS_LOG_INFO, clog );
    }
    else
    {
        viewError( "プロセス番号が引数で指定されていません" );
        exit(EXIT_FAILURE);
    }
    
    // 処理開始日時を設定
    time(&devicecapConf.lastMachineAliveTime);
    // 初回なのですべての装置の接続状態を通知する
    devicecapConf.cSendAllConnectionStatus = 0x01;

    // 前回装置状態判定日時を初期化
    devicecapConf.lastCheckMachineStateTime   = devicecapConf.lastMachineAliveTime;
    // 前回治療中モニタ送信日時を初期化
    devicecapConf.lastSendDialysisMonitorTime = devicecapConf.lastMachineAliveTime;
    // 前回未治療モニタ送信日時を初期化
    devicecapConf.lastSendUntreatMonitorTime  = devicecapConf.lastMachineAliveTime;

    // キャプチャ処理初期化
    if( initNTSSPacketCapture(
          devicecapConf.cMstFolder
    ) != 1 )
    {
        // 透析装置、コマンド登録失敗
        exit(EXIT_FAILURE);
    }

    // キャプチャ用デバイスを開く
    if(( hCaptureDevice = openNTSSPcapDevice(
          dev       // デバイス名
        , errbuf    // エラー文字列
    )) == NULL)
    {
        // オープン失敗
        exit(EXIT_FAILURE);
    }
   
    // パケットフィルター設定
    if( setNTSSPcapFilter(
          hCaptureDevice    // デバイスハンドル
        , filter            // フィルタ文字列
    ) != 0 )
    {
        // 設定失敗
        exit(EXIT_FAILURE);
    }
   
   //// 特権開放
    //seteuid(getuid());

	// 正常動作ログ記録日時
	time_t tnow;
	time_t last_watchdog_time;
	time(&last_watchdog_time);

    //
    int res;
    while( endProcessFlag == 0 )
    {
		// 現在値取得
		time(&tnow);

        // 一定間隔(180秒[3分]間隔)で正常動作していることをログに記録する
        if ((last_watchdog_time + 180) <= tnow)
        {
			LogOutput( NTSS_LOG_INFO, "正常動作中..." );

            // 記録日時を保持
            last_watchdog_time = tnow;
        }

        // 受信処理
        if(( res = checkNTSSPcapData(
              hCaptureDevice        // デバイスハンドル
        )) < 0 )
        {
            // エラー発生
            sprintf(
                  clog
                , "checkNTSSPcapData : %d( %s )\n"
                , res
                , pcap_geterr(hCaptureDevice)
            );
            viewError( clog );
            break;
        }

        // マスタ同期要求
        if( updateMasterFlag == 1 )
        {
            // マスタ更新を実施

            // マスタ更新開始
            strcpy( clog, "マスタ更新開始" );
            LogOutput( NTSS_LOG_INFO, clog );
            // 画面表示
            printf( "%s\n", clog );

            //　透析装置マスタ更新
            if( reinitNTSSPacketInfo(
                  devicecapConf.cMstFolder
            ) != 1)
            {
                // 透析装置更新失敗

                // マスタ更新失敗
                viewError("マスタ更新失敗");
            }

            // マスタ更新終了
            strcpy( clog, "マスタ更新終了" );
            LogOutput( NTSS_LOG_INFO, clog );
            // 画面表示
            printf( "%s\n", clog );

             // シグナル再設定
            updateMasterFlag = 0;
            if( setSignal() == SIG_ERR )
            {
                // シグナル設定エラー
                viewError( "シグナルの再設定ができないので終了します" );
                break;
            }
        }

        // 装置死活監視要求
        if( requestM_AliveFlag == 1 )
        {
            // 全装置の死活状態報告を実施

            // 装置情報作成モード判定
            if( getCreateMachineInfoMode() == false ) {
                // 装置情報作成モードではない場合

                // すべての装置の接続状態を通知する
                devicecapConf.cSendAllConnectionStatus = 0x01;
            }

            // マスタ更新開始
            strcpy( clog, "死活監視要求あり" );
            LogOutput( NTSS_LOG_INFO, clog );
            // 画面表示
            printf( "%s\n", clog );

            // シグナル再設定
            requestM_AliveFlag = 0;
            if( setSignal() == SIG_ERR )
            {
                // シグナル設定エラー
                viewError( "シグナルの再設定ができないので終了します" );
                break;
            }
        }

        // 装置情報作成モード判定
        if( getCreateMachineInfoMode() == false ) {
            // 装置情報作成モードではない場合

            // 死活監視処理(nMachineAliveInterval)
            checkNTSSPacketInfoConnectionStatus( 
                devicecapConf.nMachineAliveInterval
                , &devicecapConf.lastMachineAliveTime
            );

            // 工程変化時の装置工程情報の出力(nCheckMachineStateInterval)
            if( checkNTSSPacketInfoMonitorProcess(
                devicecapConf.nCheckMachineStateInterval
                , &devicecapConf.lastCheckMachineStateTime
                , devicecapConf.cSendAllConnectionStatus
            ) == 1 )
            {
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

        // ログ削除処理
        //deleteLogFile( 0x00 );
    }

    // クローズ処理
    closeNTSSPcap(hCaptureDevice);

    // ログ削除処理
    //deleteLogFile( 0x01 );

    // // 自プロセス名を取得
    // memset( clog, 0, sizeof( clog ));
    // getProcessName( clog, sizeof(clog), 0x00 );   
    // printf( "%sが終了しました\n", clog );
    
    // システム終了
    strcpy( clog, "[STOP],システム終了" );
    printf( "%s\n", clog );
    LogOutput( NTSS_LOG_INFO, clog );

    return 0;
}
