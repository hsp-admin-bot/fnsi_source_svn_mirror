/**
* @file comsv_fail.h
* @brief 通信データ処理（通信障害）
* @author GS
* @date 2021/01/13
* @details DEとAWSの通信障害処理
*/

#ifndef _COMSV_FAIL_H_
#define _COMSV_FAIL_H_

#define COMM_FAIL_MAX_DATASIZE 10240
#define COMM_FAIL_STR_MAX 256
#define COMM_FAIL_LIST	"collect_commfail.list"     // データ収集格納ファイル一覧
#define COMM_FAIL_ORD_NO "ORD_NO"                   // 仮ORD_NO
#define COMM_FAIL_REAL_ORD_NO "REAL_ORD_NO"         // ORD_NO
#define COMM_FAIL_PAT_ID "PAT_ID"                   // PAT_ID
#define COMM_FAIL_DEV_NO "DEV_NO"                   // DEV_NO
#define COMM_FAIL_COND_ORD_NO "COND_ORD_NO"         // COND_ORD_NO
#define COMM_FAIL_CANCEL_SEND_COND "CANCEL_SEND_COND"  // CANCEL_SEND_COND
#define COMM_FAIL_START_TIME "START_TIME"           // 治療開始時間
#define COMM_FAIL_END_TIME "END_TIME"               // 治療終了時間
#define COMM_FAIL_COMM_TYPE_NKK "NKK"               // 新通信
#define COMM_FAIL_COMM_TYPE_V3 "V3"                 // 共通V3
#define COMM_FAIL_COMM_TYPE_V4 "V4"                 // 共通V4
#define COMM_FAIL_COMM_TYPE_NX "NX"                 // NX通信
#define COMM_FAIL_COMM_TYPE_OFF "OFF"               // オフライン通信
#define COMM_FAIL_REPLASE_ORD_NO "{@ORD_NO}"        // ORD_NO置換文字列
#define COMM_FAIL_TMP "tmp"                         // TMP
#define COMM_FAIL_DUMMY_ORD_NO 999900000

struct comsv_fail_scn_data_fm {
    long    dev_no;                         ///< 装置Ｎｏ
    short    dev_idx;                       ///< 装置マスタINDEX
    short    sock_id;                       ///< ソケットＮｏ
    char    ip_addr[16];                    ///< IPアドレス
    short    port_no;                       ///< ポート番号
    unsigned char    facility_cd[8];        ///< 施設コード
    unsigned char    commType;              ///< 通信方式
    unsigned char    deviceType[3+1];       ///< 装置の型式コード
    unsigned char    devsw;                 ///< 通信フォーマット（I,J,M,N,P,Q,A,D,R,V,W）
    unsigned char    devid[8+1];            ///< 装置の識別番号
    unsigned char    comflg;                ///< 通信処理レベル
    unsigned char    staflg;                ///< 通信状態
    unsigned char    rcvbuf[RCVMAX];        ///< 受信データバッファ
    short   mon_sta;                        ///< 状態 (注２）
    long    ord_no;                         ///< オーダー番号
    long    realOrdNo;                      ///< オーダー番号
    long    next_ord_no;                    ///< 次回オーダー番号
    long    pat_id;                         ///< 患者ID
    long    next_pat_id;                    ///< 次患者ID
    long    condOrdNo;                      ///< 条件送信オーダー番号
    short   cancelSendCond;                 ///< 条件送信Cancel
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long    dial_start_date;                ///< 透析開始日時
    //long    dial_end_date;                  ///< 透析終了日時
    time_t    dial_start_date;                ///< 透析開始日時
    time_t    dial_end_date;                  ///< 透析終了日時
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    short current_mon_sta[2];               ///< current状態
    short mon_sta_commfail;                 ///< Fail状態
    long  ord_no_commfail;                  ///< Failオーダー番号
    int   comm_alive_state;                 ///< COMM_ALIVE_STATE
};

extern void comsv_fail_init();
extern int getCommAliveState_old();
extern int getCommAliveState();
extern void setCommAliveState_old(int value);
extern void setCommAliveState(int value);
// #8081 add 2023.05.09 起動後に最初に通信許可となるまでの判定用関数 TDC米沢 start
/**
* @brief 通信許可指示状態取得
*
* @details 通信許可指示状態の取得を行う
*
* @description
* @return 0：許可指示/1：不許可指示
* @attention 特になし
*/
extern int getCommAliveStateOrder();
/**
* @brief 初回通信許可状態取得
*
* @details 初回通信許可状態の取得を行う
*
* @description
* @return true：許可/false：不許可
* @attention 特になし
*/
extern bool isFirstCommEnabled();
// #8081 add 2023.05.09 起動後に最初に通信許可となるまでの判定用関数 TDC米沢 end
extern int comsv_fail_recovery();
extern void comsv_fail_analysis_file_name(char * p_fileName, struct comsv_fail_scn_data_fm *scn);
extern int comsv_fail_current_con_sock(unsigned char *p_facility_cd, unsigned char *p_deviceType, unsigned char *p_devid);
extern void comsv_fail_write_head(struct scn_data_fm *sp, long p_realOrdNo, char * p_fileName);
extern void comsv_fail_cond_send_cancel(long p_devNo, unsigned char *p_devCd, unsigned char *p_devId, long p_ordNo);
extern int comsv_fail_alive_moni(long devNo, unsigned char *devCd, unsigned char *devId);
extern int comsv_fail_alive_moni_main();
extern void comsv_fail_get_time(char * nowStr);
extern void comsv_fail_get_filename(long p_devNo, char * p_fullFileName, char * p_fileName);
extern void comsv_fail_append_data(struct scn_data_fm *sp, unsigned char * p_data, int p_uploadMode, int p_data_type);
extern bool comsv_fail_runDataCollectPacketSend(char *facilitycode, long devNo, unsigned char *devCd, unsigned char *devId, char * p_fname);
extern void comsv_fail_append_data_full(unsigned char *p_facility_cd, unsigned char *p_deviceType, unsigned char *p_devid, 
                            unsigned char * p_data, int p_uploadMode, int p_data_type);
extern int comsv_rest_put_ProcessState(long devNo, unsigned char *devCd, unsigned char *devId, unsigned char state);
extern int64_t comsv_fail_getFileSize(unsigned char *file);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
//extern int comsv_fail_put_machine_state(long devNo, unsigned char *devCd, unsigned char *devId, long p_ordNo, long p_pat_id, 
//                                 long p_next_ord_no, long p_next_pad_id, long p_start_time, long p_end_time, short p_sta);
extern int comsv_fail_put_machine_state(long devNo, unsigned char *devCd, unsigned char *devId, long p_ordNo, long p_pat_id, 
                                 long p_next_ord_no, long p_next_pad_id, time_t p_start_time, time_t p_end_time, short p_sta);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
extern int comsv_fail_replace_ordno(char *fname, long p_ordNo, bool errDataFalg);

// #11282 2025.02.28 mod 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 start
// // #8730 2023.06.09 add メインから送られた蓄積系データの取り込み TDC米沢 start
// /**
// * @brief メインから送られた蓄積系データを通信障害データリストファイルに登録する
// *
// * @details メインから送られた蓄積系データを通信障害データリストファイルに登録する
// *
// * @description
// * @return 登録件数
// * @attention 特になし
// */
// extern int
// updateCommFailData();
// // #8730 2023.06.09 add メインから送られた蓄積系データの取り込み TDC米沢 end
/**
 * メインから送られた蓄積系データの登録
 * @param devNo 装置番号
 * @param deviceType 装置型式
 * @param deviceCd 装置シリアル
 * @param dataType 1:日機装装置,NX装置 2:通信共通
 */
extern int
updateCommFailDataFromMain(long devNo, char *deviceType, char *deviceCd, int dataType);
// #11282 2025.02.28 mod 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 end

// #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 start
/**
 * @fn int comsv_fail_ord_no_exists(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo)
 * @brief 治療情報の有無を取得する
 * @param[in] devNo 装置番号
 * @param[in] devType 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @return 1:存在する 0:存在しない, -1:エラー
 */
extern int comsv_fail_ord_no_exists(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo);
// #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 end
// #11156 2024.11.21 add commFailData肥大化対策 TDC片口 start
/**
 * @brief exec実行電文に含まれるcommFailDataフォルダの対象ファイルをcommFail管理ファイルに対応するサブディレクトリに移動する
 *
 * @details exec実行電文に含まれるcommFailDataフォルダの対象ファイルをcommFail管理ファイルに対応するサブディレクトリに移動する
 *
 * @description
 * @return なし
 * @attention 特になし
 */
extern void moveDirRestApiCallParamFile(unsigned char *commFailFilePath, unsigned char *execCommand, unsigned char *fileMovedExecCommand);
/**
 * @brief commFailDataフォルダの対象ファイルをcommFail管理ファイルに対応するサブディレクトリに移動する
 *
 * @details commFailDataフォルダの対象ファイルをcommFail管理ファイルに対応するサブディレクトリに移動する
 *
 * @description
 * @return 1: 移動成功 other: 失敗
 * @attention 特になし
 */
extern int moveDirCommFailDataFile(unsigned char *commFailFilePath, unsigned char *originalCommFailDataPath, unsigned char *movedCommFailDataPath);
/**
 * @brief commFail管理ファイル専用サブディレクトリを生成
 *
 * @details commFail管理ファイル専用サブディレクトリを生成
 *
 * @description
 * @return なし
 * @attention 特になし
 */
extern void getCommFileUseDirName(unsigned char *commFailFilePath, unsigned char *uniqPath);
/**
 * @brief commFail管理ファイル名からサブディレクトリ名を生成
 *
 * @details commFail管理ファイル名からサブディレクトリ名を生成
 *
 * @description
 * @return なし
 * @attention 特になし
 */
extern void buildCommFileUniqDirName(unsigned char *commFailFilePath, unsigned char *commFileDirName);
// #11156 2024.11.21 add commFailData肥大化対策 TDC片口 end
#endif 
