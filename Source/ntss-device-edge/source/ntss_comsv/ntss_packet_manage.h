/**
* @brief NTSSパケット管理情報処理ヘッダーファイル
*
* @details NTSSパケット情報を管理する
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_packet_manage.h
* @author H.Yonezawa
* @date 2017/10/18
*/

#ifndef NTSS_PACKET_MANAGE_H
#define NTSS_PACKET_MANAGE_H

#include <stdint.h>
#include <stdbool.h>

#include "ntss_packet_buffer.h"

#include "../common/libs/ntss_log_lib.h"


/// 施設用モニタ監視設定ファイル
#define NTSS_FACILITY_MONIDATA_WATCH_CONFIG_FILE "facilityMoniWatchConf.dat"


/// @name 通信方式定義
//@{

/// 通信なし
#define NTSS_COMM_TYPE_NON  '0'
/// 新通信
#define NTSS_COMM_TYPE_NEW  '1'
/// NX通信
#define NTSS_COMM_TYPE_NX   '2'
/// 通信共通
#define NTSS_COMM_TYPE_COMMON   '3'
///// 旧通信
//#define NTSS_COMM_TYPE_OLD  '?'
//@}

/// パケット管理情報最大件数(200台分：一方向分のみ)
#define NTSS_PACKET_INFORMATION_COUNT 200

/// モニタデータ監視項目最大件数
#define NTSS_HOST_WATCH_COUNT   20

// #8731 2023.05.15 del 通信異常ファイルの格納先を設定で持つ TDC片口 start
// // add AWSとDEの通信断からの復旧 高 start
// #define WORK_FAIL_PATH	    "./commFail"	        ///< 作業データ用フォルダ
// #define WORK_FAIL_DATA_PATH	 "./commFailData"	    ///< 作業データ用フォルダ
// // add AWSとDEの通信断からの復旧 高 end

// // add FNSI-バグ 通信サーバ 高(#5618) start
// #define WORK_DEV_FAIL_DATA_PATH "commDevFailData" ///< 作業データ用フォルダ
// // add FNSI-バグ 通信サーバ 高(#5618) end
// #8731 2023.05.15 del 通信異常ファイルの格納先を設定で持つ TDC片口 start

/// ホスト監視設定値用構造体
struct NTSS_HOST_WATCH_CONF {
};

/// ホスト監視用構造体
struct NTSS_HOST_WATCH {
    short moniNo;                           ///< モニタ項目番号[1〜] 
	short upperAlerm;                       ///< 上限値
	short lowerAlerm;                       ///< 下限値

    u_char  cWatchAlarmEnable;              ///< 警報監視有無
    u_char  cWatchMachineState;             ///< 装置警報監視状態
    u_char  cAlarmOccurrenceStatus[2];      ///< 警報発生状態[0：現在/1：前回]
};

/// NTSSパケット管理情報用構造体
struct NTSS_PACKET_INFORMATION {
    __be32  sourceAddr;     ///< 送信元側IPアドレス[※ネットワークバイトオーダー指定]
    __be32  destAddr;       ///< 送信先側IPアドレス[※ネットワークバイトオーダー指定]
    __be16  sourcePortNo;   ///< 送信元側ポートNo[※ネットワークバイトオーダー指定]
    __be16  destPortNo;     ///< 送信先側ポートNo[※ネットワークバイトオーダー指定]

    __be16  sourceOrgPortNo;    ///< 初期送信元側ポートNo(FIN時の初期化用)[※ネットワークバイトオーダー指定]
    __be16  destOrgPortNo;      ///< 初期送信先側ポートNo(FIN時の初期化用)[※ネットワークバイトオーダー指定]

    u_char  cDeviceType[3];     ///< 型式コード[3]
    u_char  cDeviceFormat;      ///< 通信フォーマット[1]
    u_char  cDeviceNo[8];       ///< 製造番号[8]
    u_char  cCommType;          ///< 通信方式[1]('0':通信なし/'1':新通信/'2'：NX通信/'3':通信共通)

    struct NTSS_BUFFER  buffer; ///< バッファ

    u_char  isConnected;        ///< 接続中フラグ(0x00：未接続/0x01：接続中)
    u_short nProcess[2];        ///< 工程コード[0：現在/1：前回]
    u_char  isNeedSendProcess;  ///< 工程通知要求フラグ(0x00:通知不要/0x01：通知必要)

    struct timeval dtMoni;      ///< モニタ受信日時
    u_char  isFirstMoniData;    ///< 初回モニタデータフラグ(0x00：通常(積算処理あり)/0x01：初回(積算処理なし))
    u_char  cMoniData[512];     ///< モニタデータ保持用バッファ
    u_short nMoniDataSize;      ///< モニタデータサイズ
    u_char  isMoniOutput;       ///< モニタ出力フラグ(0x00：未出力/0x01：出力済)
    time_t moniOutputTime;      ///< モニタ出力日時
    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
    time_t realMoniOutputTime;      ///< モニタ出力日時
    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
    u_char  isStopUpMoniData;   ///< モニタ更新フラグ(0x00：更新許可/0x01：更新不許可)

    u_char  cMainteBCD[4][6];   ///< メンテナンス自己診断測定年月日時分[BCD](4種類類分)

    u_char  isDialysis[2];      ///< 透析中フラグ[0：現在/1：前回](0x00：未実施/0x01：透析中)

    time_t dialysisStartTime;   ///< 透析開始日時
    time_t dialysisFinishTime;  ///< 透析終了日時
    u_char isWatch;             ///< ホスト監視状態(0x00：監視していない/0x01：監視中)
    short watchWaitTime;        ///< ホスト監視開始待ち時間
    struct NTSS_HOST_WATCH watch[NTSS_HOST_WATCH_COUNT];    ///< ホスト監視用構造体
    // add 装置のSTATUS状態更新方法の変更 高 start
    u_char  machineState;       ///< 装置のSTATUS状態
    // add 装置のSTATUS状態更新方法の変更 高 end
    // add 強制オフライン 高 start
    short force_flg;            ///< 強制オフラインフラグ（0:無し,1:有り）
    // add 強制オフライン 高 end
    // add FNSI-バグ 通信サーバ 高 start
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long  dial_end_date;        ///< 透析終了日時
    time_t  dial_end_date;        ///< 透析終了日時
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    short device_comm_flg;      ///< device comm error フラグ（0:無し,1:有り）
    long  dev_no;               ///< 装置Ｎｏ
    short conflg;               ///< 装置との接続状態（注１）
    // #8468 del 2023.03.16 通信共通V4での警報/報知発生状態の保持はしないため削除 TDC米沢 start
    //u_char comm_alarm[15];      ///< 共通alarm
    // #8468 del 2023.03.16 通信共通V4での警報/報知発生状態の保持はしないため削除 TDC米沢 end
    // add FNSI-バグ 通信サーバ 高 end
};

/// 装置メンテナンス自己診断測定日時情報用構造体
struct NTSS_MACHINE_MAINTE_DATE_INFORMATION {
    u_char  cMainteBCD[4 * 6];   ///< メンテナンス自己診断測定年月日時分[BCD](4種類類分)
};


/**
* @brief 装置情報作成モードを返す
*
* @details 装置情報作成モードを取得する
*
* @description
* @return true：装置情報作成モード/false：通常モード
* @attention 特になし
*/
extern bool 
getCreateMachineInfoMode();

/**
* @brief 装置情報作成モードを設定する
*
* @details 装置情報作成モードを設定する
*
* @description
* @param[in] bMode 装置情報作成モード[true：装置情報作成モードとする/false：通常モードとする]
* @param[in] *cFolder   マスタファイル格納先フォルダ
* @return なし
* @attention 特になし
*/
extern void
setCreateMachineInfoMode( bool bMode
                        , u_char *cFolder
                        );


/**
* @brief NTSSパケット管理情報の検索で使用するIPアドレスを返す
*
* @details IPアドレス文字列を管理用IPアドレスに変換する
*
* @description
* @param[in] *ipAddr    IPアドレス文字列([.]区切り)
* @return 0：変換失敗/１以上：変換後のIPアドレス
* @attention 特になし
*/
extern __be32
convertNTSSIPAddr( u_char *ipAddr );


/**
* @brief NTSSパケット管理情報設定ファイルを読み込む
*
* @details NTSSパケット管理情報設定ファイルを読み込む
*
* @description
* @param[in] *cFolder       マスタファイル格納先フォルダ
* @return 1：初期化成功/else：初期化失敗
* @attention 特になし
*/
extern int
initNTSSPacketInfo( u_char *cfolder
                  );

/**
* @brief NTSSパケット管理情報設定ファイルの再読み込みを行う
*
* @details NTSSパケット管理情報設定ファイルの再読み込みを行う
*
* @description
* @param[in] *cFolder   マスタファイル格納先フォルダ
* @return 1：初期化成功/else：初期化失敗
* @attention 特になし
*/
extern int
reinitNTSSPacketInfo( u_char *cfolder
                    );

/**
* @brief NTSSパケット情報を追加する
*
* @details 指定したIPアドレス、ポート番号のパケット情報を追加する
*
* @description
* @param[in] sourceAddr         送信元側IPアドレス[※ネットワークバイトオーダー指定]
* @param[in] destAddr           送信先側IPアドレス[※ネットワークバイトオーダー指定]
* @param[in] sourcePortNo       送信元側ポートNo(0指定で動的ポートNo)[※ネットワークバイトオーダー指定]
* @param[in] destPortNo         送信先側ポートNo(0指定で動的ポートNo)[※ネットワークバイトオーダー指定]
* @param[in] *cDeviceNo         製造番号[8桁]
* @param[in] cFormatCd          通信フォーマット[1桁]
* @param[in] *cDeviceType       型式コード[3桁]
* @param[in] cCommType          通信方式[1桁]('0':通信なし/'1':新通信/'2':NX通信/'3'：通信共通)
* @return NULL：追加失敗/else：追加した情報ポインタ
* @attention 特になし
*/
extern struct NTSS_PACKET_INFORMATION *
AddNTSSPacketInfo( __be32 sourceAddr
                 , __be32 destAddr
                 , __be16 sourcePortNo
                 , __be16 destPortNo
                 , u_char *cDeviceNo
                 , u_char cFormatCd
                 , u_char *cDeviceType
                 , u_char cCommType
                 );


/// @name findNTSSPacketInfo更新指定用定義
//@{

/// 更新しない
#define FINDNTSSPACKETINFO_NO_UPDATE    0x00    
/// 更新する
#define FINDNTSSPACKETINFO_UPDATE       0x01    

//@}

/**
* @brief NTSSパケット管理情報のポインタを返す
*
* @details 指定したIPアドレス、ポート番号のNTSSパケット管理情報のポインタを取得する
*
* @description
* @param[in] sourceAddr     送信元側IPアドレス[※ネットワークバイトオーダー指定]
* @param[in] destAddr       送信先側IPアドレス[※ネットワークバイトオーダー指定]
* @param[in] sourcePortNo   送信元側ポートNo[※ネットワークバイトオーダー指定]
* @param[in] destPortNo     送信先側ポートNo[※ネットワークバイトオーダー指定]
* @param[in] *cDeviceNo     通信フォーマット[1]＋製造番号[8]＋通信方式[1](NULL指定時は送信元/送信先IPアドレスとポートNo、から文字の場合は送信元IPアドレスのみを検索対象とする)
* @param[in] cUpdateInfoFlag 管理情報更新フラグ(0x00:更新しない/0x01:更新する[該当した情報の送信先IPアドレス、各ポートNoの更新を行う])
* @return NULL：該当なし/else：該当した情報ポインタ
* @attention 特になし
*/
extern struct NTSS_PACKET_INFORMATION *
findNTSSPacketInfo( __be32 sourceAddr
                  , __be32 destAddr
                  , __be16 sourcePortNo
                  , __be16 destPortNo
                  , u_char *cDeviceNo
                  , u_char cUpdateInfoFlag
                  );

/**
* @brief 対象パケット管理情報のインデックスを取得する
*
* @details 対象パケット管理情報のインデックスを取得する
*
* @description
* @param[in] *ntssPacketInfo    パケット管理情報
* @return −１：該当なし/0以上:インデックス番号
* @attention 特になし
*/
extern int
getNTSSPacketInfoIndex( struct NTSS_PACKET_INFORMATION *ntssPacketInfo    
                      );
/**
* @brief 対象パケット情報のFIN処理を行う
*
* @details 対象パケット管理情報でバッファクリア、送信元ポート番号クリアを行う
*
* @description
* @param[in] *cFolder   ファイル格納先フォルダ
* @return 1：設定成功/0：設定対象なし
* @attention 特になし
*/
extern int
finNTSSPacketInfo( struct NTSS_PACKET_INFORMATION *ntssBuffer
                 );


/**
* @brief 指定したNTSSパケット管理情報の自己診断実施日時をファイルから読み込み設定する
*
* @details 指定したNTSSパケット管理情報の自己診断実施日時をファイルから読み込み設定する
*
* @description
* @param[in] *cFolder   ファイル格納先フォルダ
* @param[in] *info      対象とするNTSSパケット管理情報
* @return 1：設定成功/0：設定不要
* @attention 特になし
*/
extern int
getNTSSPacketInfoMainteDate( u_char *cFolder
                           , struct NTSS_PACKET_INFORMATION *info
                           );
/**
* @brief 指定したNTSSパケット管理情報の自己診断実施日時をファイルに出力する
*
* @details 指定したNTSSパケット管理情報の自己診断実施日時をファイルに出力する
*
* @description
* @param[in] *cFolder   ファイル格納先フォルダ
* @param[in] *info      対象とするNTSSパケット管理情報
* @return 1：設定成功/0：設定不要
* @attention 特になし
*/
extern int
outputNTSSPacketInfoMainteDate( u_char *cFolder
                              , struct NTSS_PACKET_INFORMATION *info
                              );


/**
* @brief パケット管理情報の接続状態確認を行う
*
* @details パケット管理情報の接続状態確認を行う
*
* @description
* @param[in]        nInterval    処理間隔
* @param[in/out]    LastDateTime 前回実施日時(処理後に更新される)
* @return 0:接続状態に変化なし/1:接続状態に変化あり
* @attention 特になし
*/
extern int
checkNTSSPacketInfoConnectionStatus( int nInterval
                                   , time_t *LastDateTime
                                   );
/**
* @brief パケット管理情報のモニタデータの工程変化の確認を行う
*
* @details パケット管理情報のモニタデータの工程変化の確認を行う
*
* @description
* @param[in]        nInterval           処理間隔
* @param[in/out]    LastDateTime        前回実施日時(処理後に更新される)
* @param[in]        cOutputSendObject   出力対象[0x00：変更分のみ/0x01：すべて]
* @return 0:接続状態に変化なし/1:接続状態に変化あり
* @attention 特になし
*/
extern int
checkNTSSPacketInfoMonitorProcess( int nInterval
                                 , time_t *LastDateTime 
                                 , u_char cOutputObject
                                 );
/**
* @brief パケット管理情報のモニタデータのファイル出力を行う
*　通信中でモニタデータがあるもののみ対象
*
* @details パケット管理情報のモニタデータのファイル出力を行う
*
* @description
* @param[in]        nInterval           処理間隔
* @param[in/out]    LastDateTime        前回実施日時(処理後に更新される)
* @param[in]        cOutputSendObject   出力対象[0x00：未透析分/0x01：透析中分]
* @param[in]        nRealInterval       リアルタイム処理間隔
* @param[in/out]    RealLastDateTime    リアルタイム前回実施日時(処理後に更新される)
* @return 0:接続状態に変化なし/1:接続状態に変化あり
* @attention 特になし
*/
// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
extern int
// checkNTSSPacketInfoMonitorData( int nInterval
//                               , time_t *LastDateTime 
//                               , u_char cOutputObject
//                               );
checkNTSSPacketInfoMonitorData( int nInterval
                              , time_t *LastDateTime 
                              , u_char cOutputObject
                              , int nRealInterval
                              , time_t *RealLastDateTime
                              );
// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end

/**
* @brief パケット管理情報のログ出力を行う
*
* @details パケット管理情報のログ出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @param[in] flag   出力フラフ（0:通常,1:システム情報有り）
* @param[in] *info  パケット管理情報
* @return なし
* @attention 特になし
*/
extern void
outputNTSSPacketInfoLog( NtssLogType type
                       , u_char *msg 
                       , int flag
                       , struct NTSS_PACKET_INFORMATION *info
                       );

/**
* @brief パケット管理情報のエラーログ出力を行う
*
* @details パケット管理情報のエラーログ出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @param[in] flag   出力フラフ（0:通常,1:システム情報有り）
* @param[in] *info  パケット管理情報
* @return なし
* @attention 特になし
*/
extern void
outputNTSSPacketInfoErrorLog( u_char *msg 
                            , struct NTSS_PACKET_INFORMATION *info
                            );


/**
* @brief パケット管理情報のホスト報知設定の初期化を行う
*
* @details パケット管理情報の
*
* @description
* @param[in] *info  パケット管理情報
* @return なし
* @attention 特になし
*/
extern void
initNTSSHostWatchConf( struct NTSS_PACKET_INFORMATION *info
                         );
/**
* @brief パケット管理情報のホスト報知設定を設定する
*
* @details パケット管理情報のホスト報知設定を設定する
*
* @description
* @param[in] *info      パケット管理情報
* @param[in] nMoniNo    モニタ項目番号[0〜]
* @param[in] upper      下限値
* @param[in] lower      上限値
* @param[in] cEnable    監視有効/無効[0x00：無効/0x01有効]
* @return 1：設定成功/0：設定不要(設定なし含む)
* @attention 特になし
*/
extern int
setNTSSHostWatchConf( struct NTSS_PACKET_INFORMATION *info 
                        , int nMoniNo
                        , short upper
                        , short lower
                        , u_char cEnable
                        );

/**
* @brief パケット管理情報のホスト報知設定の装置警報監視状態を設定する
*
* @details パケット管理情報のホスト報知設定の装置警報監視状態を設定する
*
* @description
* @param[in] *info          パケット管理情報
* @param[in] nMoniNo        モニタ項目番号[0〜]
* @param[in] cMachineState  装置警報監視状態[0x00：監視しない/0x01：固定監視/0x02：自動監視-ホスト報知可]
* @return 1：設定成功/0：設定不要(設定なし含む)
* @attention 特になし
*/
extern int
setNTSSHostWatchMachineState( struct NTSS_PACKET_INFORMATION *info 
                            , int nMoniNo
                            , u_char cMachineState
                            );

/**
* @brief パケット管理情報でホスト報知一覧から指定したモニタ項目の配列番号を取得する
* @details パケット管理情報でホスト報知一覧から指定したモニタ項目の配列番号を取得する
*
* @description
* @param[in] *info      パケット管理情報
* @param[in] nMoniNo    モニタ項目番号[0〜]
* @return -1：合致なし/0〜：ホスト報知配列番号
* @attention 特になし
*/
extern int
findNTSSHostWatchInfoIndex( struct NTSS_PACKET_INFORMATION *info
                          , int nMoniNo
                          );

/**
* @brief パケット管理情報で指定した配列番号のホスト報知判定を行うかどうか
*
* @details パケット管理情報で指定した配列番号のホスト報知判定を行うかどうか
*
* @description
* @param[in] *info      パケット管理情報
* @param[in] nIdx       ホスト報知配列番号
* @return 0：未実施/1：実施
* @attention 特になし
*/
extern int
isWatchNTSSHostWatchInfo(struct NTSS_PACKET_INFORMATION *info
                        , int nIdx
                        );
/**
* @brief パケット管理情報で警報/注意の発生中チェックを行う
*
* @details パケット管理情報で警報/注意の発生中チェックを行う
*
* @description
* @param[in] *info      パケット管理情報
* @param[in] now        ファイル格納先フォルダ(末尾パスあり)
* @param[in] nAddr      モニタデータ監視項目番号[0〜149]
* @param[in] nowData    今回値
* @return 1：発生中あり/0：発生中なし(設定なし含む)
* @attention 特になし
*/
extern int
checkNTSSHostWatchInfo( struct NTSS_PACKET_INFORMATION *info
                       , struct timeval now
                       , int nMoniNo
                       , short nowData
                       );

/**
* @brief パケット管理情報で警報/注意の発生中ファイルを出力する
*
* @details パケット管理情報で警報/注意の発生中チェックを行う
*
* @description
* @param[in] *info      パケット管理情報
* @param[in] now        チェック実施日時
* @return なし
* @attention 特になし
*/
extern void
outputNTSSHostWatchInfo( struct NTSS_PACKET_INFORMATION *info
                       , struct timeval now
                       );

/**
* @brief パケット管理情報で登録用装置情報ファイルを出力する
*
* @details パケット管理情報で登録用装置情報ファイルを出力する
*
* @description
* @param[in] *cFacilityCode 施設コード
* @param[in] nDeviceEdgeNo  デバイスエッジ番号
* @param[in] *info          パケット管理情報
* @param[in] now            受信日時
* @return なし
* @attention 特になし
*/
extern void
outputNTSSCreateMachineInfo( u_char *cFacilityCode
                           , short nDeviceEdgeNo
                           , struct NTSS_PACKET_INFORMATION *info
                           , struct timeval now
                           );

#endif
