/**
* @file comsv_fail.c
* @brief 通信データ処理（通信障害）
* @author GS
* @date 2021/01/13
* @details DEとAWSの通信障害処理
*/

#include <stdio.h>
#include <string.h>
#include <sys/file.h>
#include <sys/time.h>
#include "ntss_comsv.h"
#include "comsv_json_num.h"
#include "comsv_fail.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 end
// #8730 2023.06.09 add メインから送られた蓄積系データの取り込み TDC米沢 start
#include "ntss_devicecap_conf.h"
// #8730 2023.06.09 add メインから送られた蓄積系データの取り込み TDC米沢 end

// #8081 del 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 start
//int _comm_alive_state;		   /// COMM_ALIVE_STATE: 0---OK, 1---NG
/// 通信状態指示フラグ[-1：初期値/0：許可/1：不許可]
int _comm_alive_state = -1;
/// 初回通信許可フラグ
bool _first_comm_enabled = false;
// #8081 del 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 end
int _comm_alive_state_old;	   /// COMM_ALIVE_STATE: 0---OK, 1---NG
long _ord_no_dummy;			  /// dummy ordNo
struct comsv_fail_scn_data_fm comsv_fail_scn;   /// scn_data_fm
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
unsigned char _comm_fail_directory[128];
unsigned char _comm_fail_data_directory[128];
unsigned char _comm_fail_dev_data_directory[128];
unsigned char _comm_fail_list_file[128];
bool _is_comm_fail_initialized = false;
/**
* @fn void initCommFailDirectories()
* @brief 通信障害時データ保存先設定 init 処理
* @return nothing
* @details 通信障害時データ保存先設定 init 処理
*/
void initCommFailDirectories(unsigned char *dirPath)
{
	addFolderSeparator(dirPath);
	sprintf(_comm_fail_directory, "%s%s", dirPath, WORK_FAIL_PATH);
	sprintf(_comm_fail_data_directory, "%s%s", dirPath, WORK_FAIL_DATA_PATH);
	sprintf(_comm_fail_dev_data_directory, "%s%s", dirPath, WORK_DEV_FAIL_DATA_PATH);
	sprintf(_comm_fail_list_file, "%s%s", "/tmp/", COMM_FAIL_LIST);
	_is_comm_fail_initialized = true;
}
/**
* @fn int getcommFailDirectory()
* @brief 通信障害ファイル保存先取得
* @return 0: 成功 -1: 失敗
* @details 通信障害ファイル保存先取得
*/
int getCommFailDirectory(unsigned char *returnDirPath)
{
	if (!_is_comm_fail_initialized) {
		return -1;
	}
	sprintf(returnDirPath, _comm_fail_directory);
	return 0;
}
/**
* @fn int getCommFailDataDirectory()
* @brief 通信障害データファイル保存先取得
* @return 0: 成功 -1: 失敗
* @details 通信障害データファイル保存先取得
*/
int getCommFailDataDirectory(unsigned char *returnDirPath)
{
	if (!_is_comm_fail_initialized) {
		return -1;
	}
	sprintf(returnDirPath, _comm_fail_data_directory);
	return 0;
}
/**
* @fn int getCommDevFailDataDirectory()
* @brief 装置通信障害データファイル保存先取得
* @return 0: 成功 -1: 失敗
* @details 装置通信障害データファイル保存先取得
*/
int getCommDevFailDataDirectory(unsigned char *returnDirPath)
{
	if (!_is_comm_fail_initialized) {
		return -1;
	}
	sprintf(returnDirPath, _comm_fail_dev_data_directory);
	return 0;
}
/**
* @fn int getCommFailListFile()
* @brief 装置通信障害復旧用リストファイル保存先取得
* @return 0: 成功 -1: 失敗
* @details 装置通信障害復旧用リストファイル保存先取得
*/
int getCommFailListFile(unsigned char *returnFilePath)
{
	if (!_is_comm_fail_initialized) {
		return -1;
	}
	// #11627 2025.03.07 mod 検索結果ファイルを毎回異なる名称で作成する TDC片口 start
	// sprintf(returnFilePath, _comm_fail_list_file);
	snprintf(returnFilePath, 128, "%s.XXXXXX", _comm_fail_list_file);
	int fd = mkstemp(returnFilePath);
	if (fd != 0)
	{
		close(fd);
	}
	// #11627 2025.03.07 mod 検索結果ファイルを毎回異なる名称で作成する TDC片口 end
	return 0;
}
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end

/**
* @fn void comsv_fail_init()
* @brief 通信データ init 処理（通信障害）
* @return nothing
* @details 通信データ init 処理（通信障害）
*/
void comsv_fail_init()
{
	FILE *fp1;
	char fpath[128];
	char name[128];
	char t_name[128];
    // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 start
	//long startTime;
	//long endTime;
	time_t startTime;
	time_t endTime;
    // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 end
	long ordNo = 0;
	long realOrdNo = 0;
	long pat_id = 0;
	long dev_no = 0;
	long condOrdNo = 0;
	short cancelSendCond = 0;
	char pathes[512] = {0};
	unsigned char logMsg[256] = {0};
	char command[512] = {0};
	int res = -1;
	long max_ordNo = 0;
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	char commFailListFile[128] = {0};
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
	
	// 作業データ用フォルダを作成する
	res = comsv_work_mkdir_commfail();
	if(res != 0)
		return;
	
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	//sprintf(pathes, "%s", WORK_FAIL_PATH);
	getCommFailDirectory(pathes);
	getCommFailListFile(commFailListFile);
	
	// 昇順で格納ファイル一覧作成
	// sprintf( command, "find %s -maxdepth 1 -type f -name \"*.txt\" | xargs --no-run-if-empty ls -rt1 > %s", pathes, COMM_FAIL_LIST );
	sprintf( command, "find %s -maxdepth 1 -type f -name \"*.txt\" | xargs --no-run-if-empty ls -rt1 > %s", pathes, commFailListFile );
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
	res = system(command);
	
	if ( WIFEXITED(res) ) {
		// 正常終了
		if ( 0 == WEXITSTATUS(res) ) {
			// ファイル一覧オープン
			// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
			// fp1 = fopen( COMM_FAIL_LIST, "r" );
			fp1 = fopen( commFailListFile, "r" );
			// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
			if ( fp1 != NULL ) {
				while( !feof(fp1) ) {
					memset( name, 0, sizeof(name) );
					if ( fgets( name, sizeof(name), fp1 ) == NULL ) {
						break;
					}
					
					// cut \n
					name[strlen(name) - 1] = 0;
					
					memset(&comsv_fail_scn, 0, sizeof(comsv_fail_scn));
					strcpy(t_name, basename(name));
					comsv_fail_analysis_file_name(t_name, &comsv_fail_scn);
					
					// #11168 2024.10.15 add ログ追加 TDC片口 start
					snprintf(logMsg, sizeof(logMsg), "comsv_fail_init 処理開始 ファイル：%s", name);
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
					// #11168 2024.10.15 add ログ追加 TDC片口 end
					
					// get file head information
					ordNo = 0;
					realOrdNo = 0;
					pat_id = 0;
					dev_no = 0;
					condOrdNo = 0;
					cancelSendCond = 0;
					startTime = 0;
					endTime = 0;
					
					// get head information
					comsv_fail_get_head(name, &ordNo, &realOrdNo, &pat_id, &dev_no, &condOrdNo, &cancelSendCond, &startTime, &endTime);
					
					// get max ordno
					if(ordNo > max_ordNo && ordNo > COMM_FAIL_DUMMY_ORD_NO)
						max_ordNo = ordNo;
				}
				
				fclose( fp1 );
			}
		}
	}
	// #11627 2025.03.07 add 検索結果ファイルを毎回異なる名称で作成する TDC片口 start
	// 検索結果ファイルを削除
	remove(commFailListFile);
	// #11627 2025.03.07 add 検索結果ファイルを毎回異なる名称で作成する TDC片口 end
	
	if(max_ordNo == 0)
		setOrdNoDummy(COMM_FAIL_DUMMY_ORD_NO);
	else
		setOrdNoDummy(max_ordNo);
	return;
}

/**
* @fn void comsv_fail_cond_send_cancel()
* @brief cond send cancle
 * @param[in] p_devNo 装置番号
 * @param[in] p_devCd 型式コード
 * @param[in] p_devId 製造番号
 * @param[in] p_ordNo ordNo
* @details cond send cancle
*/
void comsv_fail_cond_send_cancel(long p_devNo, unsigned char *p_devCd, unsigned char *p_devId, long p_ordNo)
{
	// 条件送信の取消を実施する。
	comsv_rest_put_cancelSendCond(p_devNo, p_devCd, p_devId, p_ordNo);
	
}

/**
 * @brief 
 * 
 * key=value形式の文字列から、valueを取得する
 * 
 * @param str key=value形式の文字列
 * @param param value格納先
 * @return int32_t 
 */
int32_t comsv_fail_getParam(const char *str, char *keyStr, char *val)
{
	int32_t cnt = 0;
	int32_t idx = 0;
	int32_t ret = 0;

    // #12507 2026.03.10 add FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    if ( (str == NULL) || (str[0] == '\0') ) {
		return ret;
    }
    // #12507 2026.03.10 add FW7に伴うバッファーオーバーフロー対応 TDC高村 end
	if( strchr( str, '=' ) != 0 )
	{
		ret = 1;
		while ( str[cnt] != '=' && str[cnt] != '\n' && str[cnt] != '\r' && str[cnt] != '\0' ) {
			keyStr[idx++] = str[cnt++];
		}
		keyStr[idx] = '\0';
		cnt++;
		idx=0;

		while ( str[cnt] != '\n' && str[cnt] != '\r' && str[cnt] != '\0' ) {
			val[idx++] = str[cnt++];
		}
		val[idx] = '\0';
	}
	return ret;
}

/**
* @fn void comsv_fail_recovery()
* @brief revovery data処理
* @return int 0:成功 -1:失敗
* @details revovery data処理
*/
int comsv_fail_recovery()
{
	FILE *fp1;
	char fname[192];
	char name[192];
	char t_name[192];
	char outFileName[512];
	long ordNo = 0;
	long realOrdNo = 0;
	long pat_id = 0;
	long dev_no;
	long condOrdNo = 0;
	short cancelSendCond = 0;
	char command[512] = {0};
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	// char pathes[512] = {0};
	char pathes[256] = {0};
	char failDataPath[256] = {0};
	char commFailListFile[192] = {0};
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
	unsigned char logMsg[512] = {0};
	unsigned char val[COMM_FAIL_MAX_DATASIZE];
	unsigned char processed;
	unsigned char data_type;
	long pos;
	int con;
    // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 start
	//long startTime;
	//long endTime;
	time_t startTime;
	time_t endTime;
    // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 end
	int res = -1;
	struct scn_data_fm *sp;
	// #11168 2024.10.15 add 対象オーダーの有無確認 TDC片口 start
	unsigned char is_ord_deleted;
	// #11168 2024.10.15 add 対象オーダーの有無確認 TDC片口 end
	
	// only rescovery ordno to ord_main
	res = comsv_fail_recovery_ordNo();
	if(res != 0)
	{
		// #11168 2024.11.06 add ログ追加 TDC片口 start
		snprintf(logMsg, sizeof(logMsg), "comsv_fail_recovery_ordNo 失敗 res:%d", res);
		LogOutputs(NTSS_LOG_INFO, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
		// #11168 2024.11.06 add ログ追加 TDC片口 end
		return -1;
	}
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	//sprintf(pathes, "%s", WORK_FAIL_PATH);
	getCommFailDirectory(pathes);
	getCommFailDataDirectory(failDataPath);
	getCommFailListFile(commFailListFile);
	//sprintf(fname, "%s_%.3s_%.7s", facility_cd, sp->deviceType, sp->devid);
	
	// 昇順で格納ファイル一覧作成
	// sprintf( command, "find %s -maxdepth 1 -type f -name \"*.txt\" | xargs --no-run-if-empty ls -rt1 > %s", pathes, COMM_FAIL_LIST );
	sprintf( command, "find %s -maxdepth 1 -type f -name \"*.txt\" | xargs --no-run-if-empty ls -rt1 > %s", pathes, commFailListFile );
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
	res = system(command);
	
	if ( WIFEXITED(res) ) {
		// 正常終了
		if ( 0 == WEXITSTATUS(res) ) {
			// コマンド正常終了
			//sprintf( logMsg, "COMM FAILファイル一覧取得成功 (%d) %s > %s", res, pathes, COMM_FAIL_LIST );
			//LogOutputs( NTSS_LOG_INFO, logMsg, 0, "", "" );
			
			// ファイル一覧オープン
			// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
			// fp1 = fopen( COMM_FAIL_LIST, "r" );
			fp1 = fopen( commFailListFile, "r" );
			// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
			if ( fp1 != NULL ) {
				while( !feof(fp1) ) {
					memset( name, 0, sizeof(name) );
					if ( fgets( name, sizeof(name), fp1 ) == NULL ) {
						break;
					}
					name[strlen(name) - 1] = 0;
					
					memset(&comsv_fail_scn, 0, sizeof(comsv_fail_scn));
					strcpy(t_name, basename(name));
					comsv_fail_analysis_file_name(t_name, &comsv_fail_scn);
					
					// #11168 2024.10.15 add ログ追加 TDC片口 start
					snprintf(logMsg, sizeof(logMsg), "comsv_fail_recovery 処理開始 ファイル：%s", name);
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
					// #11168 2024.10.15 add ログ追加 TDC片口 end
					
					// get file head information
					ordNo = 0;
					realOrdNo = 0;
					pat_id = 0;
					dev_no = 0;
					condOrdNo = 0;
					cancelSendCond = 0;
					startTime = 0;
					endTime = 0;
					comsv_fail_get_head(name, &ordNo, &realOrdNo, &pat_id, &dev_no, &condOrdNo, &cancelSendCond, &startTime, &endTime);
					
					comsv_fail_scn.ord_no = ordNo;
					comsv_fail_scn.next_ord_no = ordNo;
					comsv_fail_scn.realOrdNo = realOrdNo;
					comsv_fail_scn.pat_id = pat_id;
					comsv_fail_scn.next_pat_id = pat_id;
					comsv_fail_scn.dev_no = dev_no;
					comsv_fail_scn.condOrdNo = condOrdNo;
					comsv_fail_scn.cancelSendCond = cancelSendCond;
					comsv_fail_scn.dial_start_date = startTime;
					comsv_fail_scn.dial_end_date = endTime;
					
					// 新規OrdNo、pad_id、記録した治療開始時間をtmp_comm_failure_recoveryに反映する（ord_no, pad_id, next_ord_no, next_pad_id, start_date）
					res = comsv_fail_put_tmp_machine_state(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, comsv_fail_scn.realOrdNo, comsv_fail_scn.pat_id, 
														comsv_fail_scn.realOrdNo, comsv_fail_scn.pat_id, comsv_fail_scn.dial_start_date, comsv_fail_scn.dial_end_date);
					if(res != 0) {
						// #11168 2024.11.06 add ログ追加 TDC片口 start
						snprintf(logMsg, sizeof(logMsg), "comsv_fail_put_tmp_machine_state 失敗 res:%d", res);
						LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
						// #11168 2024.11.06 add ログ追加 TDC片口 end
						break;
					}
					// #11168 2024.10.15 add 対象オーダーの有無確認 TDC片口 start
					// REAL_ORD_NO が既にDBから削除されている可能性を確認
					is_ord_deleted = '0';
					if (comsv_fail_scn.realOrdNo > 0) {
						// real_ord_no > 0 （ord_noがいちど登録済み）の場合のみ存在をチェックする
						res = comsv_fail_ord_no_exists(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, comsv_fail_scn.realOrdNo);
						if (res < 0)
						{
							// #11168 2024.11.06 add ログ追加 TDC片口 start
							snprintf(logMsg, sizeof(logMsg), "comsv_fail_ord_no_exists 失敗 res:%d", res);
							LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
							// #11168 2024.11.06 add ログ追加 TDC片口 end
							break;
						}
						else if (res == 0)
						{
							is_ord_deleted = '1';
						}
					}
					// #11168 2024.10.15 add 対象オーダーの有無確認 TDC片口 end

					// #11156 2024.11.25 add commFailData肥大化対策 TDC片口 start
					// commFailDataフォルダのパス作成
					getCommFileUseDirName(name, failDataPath);
					// #11156 2024.11.25 add commFailData肥大化対策 TDC片口 end
					
					res = 0;
					while(1) {
						pos= 0;
						// get next data
						res = comsv_fail_find_next(&comsv_fail_scn, name, val, &processed, &data_type, &pos);
						if(res == 1)
						{
							// file over
							// #11168 2024.11.06 add ログ追加 TDC片口 start
							snprintf(logMsg, sizeof(logMsg), "comsv_fail_find_next ファイル最終行まで確認：%s", name);
							LogOutputs(NTSS_LOG_INFO, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
							// #11168 2024.11.06 add ログ追加 TDC片口 end
							// remove file
							remove(name);
							// delete tmp_comm_failure_recovery
							comsv_fail_del_tmp_machine_state(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid);

							// #11156 2024.11.25 add commFailData肥大化対策 TDC片口 start
							// ディレクトリ内にファイルがある場合は削除
							deleteFolderInFiles(failDataPath);
							// ディレクトリが空っぽになったら削除
							sprintf(command, "find %s -type d -empty -delete", failDataPath);
							system(command);
							// #11156 2024.11.25 add commFailData肥大化対策 TDC片口 end
							
							break;
						}
						
						// error
						if(res != 0)
						{
							// #11168 2024.11.06 add ログ追加 TDC片口 start
							snprintf(logMsg, sizeof(logMsg), "comsv_fail_find_next 失敗：%d", res);
							LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
							// #11168 2024.11.06 add ログ追加 TDC片口 end
							break;
						}

						memset(outFileName, '\0', sizeof(outFileName));
						if(data_type == '0') {
							// direct call
							// #11168 2024.10.15 mod 対象オーダーの有無確認 TDC片口 start
							// res = comsv_fail_comsv_rest_exec(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, val);
							if (is_ord_deleted == '1')
							{
								// ord_noが既にDBから削除されている場合はord_mainに紐づける治療情報の登録はすべてスキップする
								snprintf(logMsg, sizeof(logMsg), "skip: %s", val);
								LogOutputs(NTSS_LOG_INFO, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
							}
							else
							{
								res = comsv_fail_comsv_rest_exec(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, val);
							
								// #11168 2024.11.06 add ログ追加 and MOVE TDC片口 start
								if(res != 0)
								{
									snprintf(logMsg, sizeof(logMsg), "comsv_fail_comsv_rest_exec 失敗：%d", res);
									LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
									break;
								}
								// #11168 2024.11.06 add ログ追加 and MOVE TDC片口 end
							}
							// #11168 2024.10.15 mod 対象オーダーの有無確認 TDC片口 end
						}
						// #11283 2026.04.27 mod 処理ファイルがない場合はログを記録して処理をスキップ TDC米沢 start
						// else if(data_type == '1') {
						// 	// bin file
						// 	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
						// 	// res = comsv_fail_mst_make_collect( facility_cd, device_edge_no, val, WORK_FAIL_DATA_PATH, outFileName );
						// 	res = comsv_fail_mst_make_collect( facility_cd, device_edge_no, val, failDataPath, outFileName );
						// 	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
							
						// 	if(res <= 0)
						// 	{
						// 		// #11168 2024.11.06 add ログ追加 TDC片口 start
						// 		snprintf(logMsg, sizeof(logMsg), "comsv_fail_mst_make_collect 失敗：%d", res);
						// 		LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
						// 		// #11168 2024.11.06 add ログ追加 TDC片口 end
						// 		break;
						// 	}

						// 	res = 0;
						// 	comsv_fail_runDataCollectPacketSend(facility_cd, comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, outFileName);
						// }
						// else if(data_type == '2') {
						// 	// monitor data .txt
						// 	comsv_fail_runDataCollectPacketSend(facility_cd, comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, val);
						// }
						else {
							// 処理ファイルの有無確認
							if(existFolderFile(val, NULL) != 1) {
								// 処理ファイルなし

								// ログ記録
								snprintf(
									logMsg
									, sizeof(logMsg)
									, "処理種別:%c のファイル:%s が存在しないため、comm_fail_recovery処理をスキップしました (仮オーダー番号:%ld, オーダー番号:%ld, 患者ID:%ld)"
									, data_type
									, val
									, comsv_fail_scn.ord_no_commfail
									, comsv_fail_scn.ord_no
									, comsv_fail_scn.pat_id
								);
								LogOutputs(NTSS_LOG_INFO, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
							} else {
								// 処理ファイルあり

								// 処理ファイル種別判定
								if(data_type == '1') {
									// bin file
									res = comsv_fail_mst_make_collect( facility_cd, device_edge_no, val, failDataPath, outFileName );
									
									if(res <= 0)
									{
										// bin → text変換失敗
										snprintf(logMsg, sizeof(logMsg), "comsv_fail_mst_make_collect 失敗：%d", res);
										LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
										break;
									}

									res = 0;
									comsv_fail_runDataCollectPacketSend(facility_cd, comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, outFileName);
								}
								else if(data_type == '2') {
									// monitor data .txt
									comsv_fail_runDataCollectPacketSend(facility_cd, comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, val);
								}
							}
						}
						// #11283 2026.04.27 mod 処理ファイルがない場合はログを記録して処理をスキップ TDC米沢 end
						// #11168 2024.11.06 del already res == 0 TDC片口 start
						// if(res != 0)
						//	 break;
						// #11168 2024.11.06 del already res == 0 TDC片口 start

						// set record processed stat
						res = comsv_fail_set_recState(&comsv_fail_scn, name, pos);
						if(res != 0)
						{
							// #11168 2024.11.06 add ログ追加 TDC片口 start
							snprintf(logMsg, sizeof(logMsg), "comsv_fail_set_recState 失敗：%d", res);
							LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
							// #11168 2024.11.06 add ログ追加 TDC片口 end
							break;
						}
					}
				}
				fclose(fp1);

				// #11627 2025.03.07 mod 検索結果ファイルを毎回異なる名称で作成する TDC片口 start
				// // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
				// // if(comsv_fail_getFileSize(COMM_FAIL_LIST) == 0) {
				// //	 // フォルダ内にファイルがある場合は削除
				// //	 deleteFolderInFiles(WORK_FAIL_DATA_PATH);
				// //	 //deleteFolderInFiles(WORK_FAIL_PATH);

				// //	 remove(COMM_FAIL_LIST);
				// // }
				// if(comsv_fail_getFileSize(commFailListFile) == 0) {
				//	 // #11156 2024.11.25 del commFailData肥大化対策 TDC片口 start
				//	 // // フォルダ内にファイルがある場合は削除
				//	 // deleteFolderInFiles(failDataPath);
				//	 // #11156 2024.11.25 del commFailData肥大化対策 TDC片口 end
				//	 remove(commFailListFile);
				// }
				// // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
				// #11627 2025.03.07 mod 検索結果ファイルを毎回異なる名称で作成する TDC片口 end
			}
		}
	}
	// #11627 2025.03.07 add 検索結果ファイルを毎回異なる名称で作成する TDC片口 start
	// 検索結果ファイルを削除
	remove(commFailListFile);
	// #11627 2025.03.07 add 検索結果ファイルを毎回異なる名称で作成する TDC片口 end
	return res;
}

/**
* @fn void comsv_fail_recovery_ordNo()
* @brief only revovery ordno to ord_main処理
* @return int 0:成功 -1:失敗
* @details only revovery ordno to ord_main処理
*/
int comsv_fail_recovery_ordNo()
{
	FILE *fp1;
	char fname[128];
	char fpath[128];
	char t_str[128];
	char name[128];
	char t_name[128];
    // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 start
	//long startTime;
	//long endTime;
	time_t startTime;
	time_t endTime;
    // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 end
	long ordNo = 0;
	long newOrdNo = 0;
	long realOrdNo = 0;
	long pat_id = 0;
	long dev_no = 0;
	long condOrdNo = 0;
	short cancelSendCond = 0;
	char command[512] = {0};
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	// char pathes[512] = {0};
	char pathes[128] = {0};
	char commFailListFile[128] = {0};
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
	unsigned char logMsg[256] = {0};
	int res = -1;
	// #11168 2024.11.01 add 対象オーダーの有無確認 TDC片口 start
	int res2 = -1;
	// #11168 2024.11.01 add 対象オーダーの有無確認 TDC片口 end
	int con;
	struct scn_data_fm *sp;
	bool newOrdFlag;
	bool errDataFlag = false;
	short mon_sta_bak;
	
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	//sprintf(pathes, "%s", WORK_FAIL_PATH);
	getCommFailDirectory(pathes);
	getCommFailListFile(commFailListFile);
	
	// 昇順で格納ファイル一覧作成
	// sprintf( command, "find %s -maxdepth 1 -type f -name \"*.txt\" | xargs --no-run-if-empty ls -rt1 > %s", pathes, COMM_FAIL_LIST );
	sprintf( command, "find %s -maxdepth 1 -type f -name \"*.txt\" | xargs --no-run-if-empty ls -rt1 > %s", pathes, commFailListFile );
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
	res = system(command);
	
	if ( WIFEXITED(res) ) {
		// 正常終了
		if ( 0 == WEXITSTATUS(res) ) {
			// コマンド正常終了
			//sprintf( logMsg, " comsv_fail_recovery_ordNo() COMM FAILファイル一覧取得成功 (%d) %s > %s", res, pathes, COMM_FAIL_LIST );
			//LogOutputs( NTSS_LOG_INFO, logMsg, 0, "", "" );
			
			// ファイル一覧オープン
			// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
			// fp1 = fopen( COMM_FAIL_LIST, "r" );
			fp1 = fopen( commFailListFile, "r" );
			// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
			if ( fp1 != NULL ) {
				while( !feof(fp1) ) {
					memset( name, 0, sizeof(name) );
					if ( fgets( name, sizeof(name), fp1 ) == NULL ) {
						break;
					}
					
					errDataFlag = false;
					
					// cut \n
					name[strlen(name) - 1] = 0;
					
					memset(&comsv_fail_scn, 0, sizeof(comsv_fail_scn));
					strcpy(t_name, basename(name));
					comsv_fail_analysis_file_name(t_name, &comsv_fail_scn);
					
					// #11168 2024.10.15 add ログ追加 TDC片口 start
					snprintf(logMsg, sizeof(logMsg), "comsv_fail_recovery_ordNo() 処理開始 ファイル：%s", name);
					LogOutputs(NTSS_LOG_INFO, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
					// #11168 2024.10.15 add ログ追加 TDC片口 end
					
					// get file head information
					ordNo = 0;
					realOrdNo = 0;
					pat_id = 0;
					dev_no = 0;
					condOrdNo = 0;
					cancelSendCond = 0;
					startTime = 0;
					endTime = 0;
					comsv_fail_get_head(name, &ordNo, &realOrdNo, &pat_id, &dev_no, &condOrdNo, &cancelSendCond, &startTime, &endTime);
					
					// 作業データ用装置番号フォルダ作成
					if(dev_no >= 0)
						comsv_work_mkdir_dev(dev_no);
					
					comsv_fail_scn.ord_no = ordNo;
					comsv_fail_scn.next_ord_no = ordNo;
					comsv_fail_scn.realOrdNo = realOrdNo;
					comsv_fail_scn.pat_id = pat_id;
					comsv_fail_scn.next_pat_id = pat_id;
					comsv_fail_scn.dev_no = dev_no;
					comsv_fail_scn.condOrdNo = condOrdNo;
					comsv_fail_scn.cancelSendCond = cancelSendCond;
					comsv_fail_scn.dial_start_date = startTime;
					comsv_fail_scn.dial_end_date = endTime;
					
					con = comsv_fail_current_con_sock(comsv_fail_scn.facility_cd, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
					// find con_sock OK
					if(con != -1)
						sp = &(con_sock[con].scn);
					
					// cancel condition send
					if(cancelSendCond == 1 && condOrdNo > 0) {
						comsv_fail_cond_send_cancel(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, condOrdNo);
					}
					
					// 新規OrdNo取得処理はもう済みました
					newOrdFlag = false;

					if(comsv_fail_scn.realOrdNo == 0 && comsv_fail_scn.dial_start_date != 0) {
						// 新規OrdNoを取得
						res = comsv_fail_comsv_rest_put_unregistered(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, 
																	comsv_fail_scn.pat_id, comsv_fail_scn.dial_start_date);
						if(res != 0) {
							// #11168 2024.11.06 add ログ追加 TDC片口 start
							snprintf(logMsg, sizeof(logMsg), "comsv_fail_comsv_rest_put_unregistered 失敗 res:%d", res);
							LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
							// #11168 2024.11.06 add ログ追加 TDC片口 end
							break;
						}
						
						// 装置状態管理データを取得
						sprintf(t_str, "%s_%s", COMM_FAIL_TMP, WORK_DEV_STATE);
						comsv_work_fpath(comsv_fail_scn.dev_no, t_str, fpath);
						res = comsv_fail_comsv_rest_get_dev(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, fpath);
						if(res != 0) {
							// #11168 2024.11.06 add ログ追加 TDC片口 start
							snprintf(logMsg, sizeof(logMsg), "comsv_fail_comsv_rest_get_dev 失敗 res:%d", res);
							LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
							// #11168 2024.11.06 add ログ追加 TDC片口 end
							break;
						}
						
						res = comsv_fail_comsv_json_dev_state(fpath, &comsv_fail_scn);
						if(res != 0) {
							// #11168 2024.11.06 add ログ追加 TDC片口 start
							snprintf(logMsg, sizeof(logMsg), "comsv_fail_comsv_json_dev_state 失敗 res:%d", res);
							LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
							// #11168 2024.11.06 add ログ追加 TDC片口 end
							break;
						}
   
						// replace ordNo
						newOrdNo =  comsv_fail_scn.ord_no;
						res = comsv_fail_replace_ordno(name, newOrdNo, false);
						if(res != 0) {
							// #11168 2024.11.06 add ログ追加 TDC片口 start
							snprintf(logMsg, sizeof(logMsg), "comsv_fail_replace_ordno 失敗 res:%d", res);
							LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
							// #11168 2024.11.06 add ログ追加 TDC片口 end
							break;
						}
						comsv_fail_scn.realOrdNo = newOrdNo;
					}
					else if(comsv_fail_scn.realOrdNo == 0 && comsv_fail_scn.dial_start_date == 0 && comsv_fail_scn.dial_end_date != 0){
						res = comsv_fail_replace_ordno(name, 0, true);
						errDataFlag = true;
					}
					else {
						if(condOrdNo < COMM_FAIL_DUMMY_ORD_NO) {
							res = comsv_fail_replace_ordno(name, condOrdNo, false);
						}
					}
					
					if(errDataFlag == true) {
						res = 0;
						continue;
					}
					
					// 通信障害開始時の治療OrdNoと現在治療中OrdNoが一致するかどうかのチェック
					if(ordNo != 0 && con != -1 && ordNo == sp->ord_no) {
						// 新規OrdNoで、記録した治療開始時間をrst_start_dateに反映する（ord_main）
						if(comsv_fail_scn.dial_start_date != 0) {
							comsv_rest_put_ord_date(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, comsv_fail_scn.realOrdNo, 1, comsv_fail_scn.pat_id, 3, comsv_fail_scn.dial_start_date);
						}
						
						// 記録した治療終了時間をrst_end_dateに反映して、rst_dialysis_stateに「4」に更新する（ord_main）
						if(comsv_fail_scn.dial_end_date != 0) {
							comsv_rest_put_ord_date(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, comsv_fail_scn.realOrdNo, 2, comsv_fail_scn.pat_id, 4, comsv_fail_scn.dial_end_date);
						}
						
						if(sp->ord_no < COMM_FAIL_DUMMY_ORD_NO){
							if(comsv_fail_scn.dial_start_date != 0) {
								// 装置状態管理の日付データを更新する
								comsv_rest_put_dev_date(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, 2, 1, comsv_fail_scn.dial_start_date);
							}
							if(comsv_fail_scn.dial_end_date != 0) {
								// 装置状態管理の日付データを更新する
								comsv_rest_put_dev_date(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, 3, 0, comsv_fail_scn.dial_end_date);
							}
						}
						else{
						
							// 通信状態:条件送信済/条件送信確認済み
							if ( sp->current_mon_sta[0] != COMM_STA1 && sp->current_mon_sta[0] != COMM_STA2 ) {
								// 新規OrdNo、pad_id、記録した治療開始時間をMNT_MACHINE_STATに反映する（ord_no, pad_id, next_ord_no, next_pad_id, start_date）
								res = comsv_fail_put_machine_state(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, comsv_fail_scn.realOrdNo, comsv_fail_scn.pat_id, 
																	comsv_fail_scn.realOrdNo, comsv_fail_scn.pat_id, comsv_fail_scn.dial_start_date, comsv_fail_scn.dial_end_date, sp->mon_sta);
								if(res != 0) {
									// #11168 2024.11.06 add ログ追加 TDC片口 start
									snprintf(logMsg, sizeof(logMsg), "comsv_fail_put_machine_state 失敗 res:%d", res);
									LogOutputs(NTSS_LOG_ERROR, logMsg, 0, comsv_fail_scn.deviceType, comsv_fail_scn.devid);
									// #11168 2024.11.06 add ログ追加 TDC片口 end
									break;
								}
							}
						}
						
						mon_sta_bak = sp->mon_sta;
						// 装置状態管理データを取得
						comsv_work_fpath(comsv_fail_scn.dev_no, WORK_DEV_STATE, fpath);
						res = comsv_rest_get_dev(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, fpath);
						res = comsv_json_dev_state(fpath, 1, sp);
						sp->mon_sta = mon_sta_bak;
					}
					else {
						// #11168 2024.10.15 mod 対象オーダーの有無確認 TDC片口 start
						// // 新規OrdNoで、記録した治療開始時間をrst_start_dateに反映する（ord_main）
						// if(comsv_fail_scn.dial_start_date != 0) {
						//	 comsv_rest_put_ord_date(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, comsv_fail_scn.realOrdNo, 1, comsv_fail_scn.pat_id, 3, comsv_fail_scn.dial_start_date);
						// }
						
						// // 記録した治療終了時間をrst_end_dateに反映して、rst_dialysis_stateに「4」に更新する（ord_main）
						// if(comsv_fail_scn.dial_end_date != 0) {
						//	 comsv_rest_put_ord_date(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, comsv_fail_scn.realOrdNo, 2, comsv_fail_scn.pat_id, 4, comsv_fail_scn.dial_end_date);
						// }

						// REAL_ORD_NO が既にDBから削除されている可能性を確認
						if (comsv_fail_scn.realOrdNo > 0) {
							res2 = comsv_fail_ord_no_exists(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, comsv_fail_scn.realOrdNo);
							if (res2 > 0) {
								// ord_no がDBに存在する場合のみ治療開始・終了時間をDBに書き込む
								// 対象OrdNoで、記録した治療開始時間をrst_start_dateに反映する（ord_main）
								if(comsv_fail_scn.dial_start_date != 0) {
									comsv_rest_put_ord_date(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, comsv_fail_scn.realOrdNo, 1, comsv_fail_scn.pat_id, 3, comsv_fail_scn.dial_start_date);
								}
								
								// 記録した治療終了時間をrst_end_dateに反映して、rst_dialysis_stateに「4」に更新する（ord_main）
								if(comsv_fail_scn.dial_end_date != 0) {
									comsv_rest_put_ord_date(comsv_fail_scn.dev_no, comsv_fail_scn.deviceType, comsv_fail_scn.devid, comsv_fail_scn.realOrdNo, 2, comsv_fail_scn.pat_id, 4, comsv_fail_scn.dial_end_date);
								}
							}
						}
						// #11168 2024.10.15 mod 対象オーダーの有無確認 TDC片口 start
					}
				}
				fclose( fp1 );
			}
		}
	}
	// #11627 2025.03.07 add 検索結果ファイルを毎回異なる名称で作成する TDC片口 start
	// 検索結果ファイルを削除
	remove(commFailListFile);
	// #11627 2025.03.07 add 検索結果ファイルを毎回異なる名称で作成する TDC片口 end
	return res;
}

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
int comsv_fail_ord_no_exists(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo)
{
	FILE *fp;
	char fpath[128];
	char t_str[128];
	unsigned char logMsg[256] = {0};
	char responseValue[10] = {0};
	int returnValue = 0;
	int res = -1;

	sprintf(t_str, "tmp_exists_response.dat");
	comsv_work_fpath(devNo, t_str, fpath);
	res = comsv_rest_get_exists_ord(devNo, devCd, devId, ordNo, fpath);
	if(res != 0) {
		// 応答ファイルを削除
		removeFileFullPath(fpath);
		return -1;
	}
	// 応答ファイルを開く
	if ((fp = fopen(fpath, "r")) != NULL)
	{
		// 1行取得
		if (fgets(responseValue, sizeof(responseValue), fp) != NULL)
		{
			// 末尾のLFを除去
			trimEnd(responseValue, '\n' );
			if (strlen(responseValue) == 0)
			{
				// 取得したコードが空行ならばエラー
				removeFileFullPath(fpath);
				return -1;
			}
			// 応答内容が 1 ならばオーダーあり
			if (responseValue[0] == '1')
			{
				returnValue = 1;
				sprintf(logMsg, "ord_no[%ld] : DBに存在あり", ordNo);
			} else {
				returnValue = 0;
				sprintf(logMsg, "ord_no[%ld] : DBに存在なし", ordNo);
			}
			LogOutputs(NTSS_LOG_INFO, logMsg, 0, devCd, devId);
		}
		fclose(fp);
	}
	// 応答ファイルを削除
	removeFileFullPath(fpath);

	return returnValue;
}
// #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 end

/**
* @fn void comsv_fail_get_head()
* @brief 通信障害データリストファイル GET HEAD処理
* @param[in] p_file_name
* @param[out] p_ordNo
* @param[out] p_realOrdNo
* @param[out] p_pat_id
* @param[out] p_dev_no
* @param[out] p_condOrdNo
* @param[out] p_cancelSendCond
* @param[out] p_startTime
* @param[out] p_endTime
* @return int 0:成功 -1:失敗
* @details 通信障害データリストファイル GET HEAD処理
*/
// #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 start
//int comsv_fail_get_head(char *p_file_name, long *p_ordNo, long * p_realOrdNo, long * p_pat_id, long * p_dev_no, 
//						long * p_condOrdNo, short * p_cancelSendCond, long * p_startTime, long * p_endTime)
int comsv_fail_get_head(char *p_file_name, long *p_ordNo, long * p_realOrdNo, long * p_pat_id, long * p_dev_no, 
						long * p_condOrdNo, short * p_cancelSendCond, time_t * p_startTime, time_t * p_endTime)
// #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 end
{
	FILE *fin;
	unsigned char logMsg[256] = {0};
	unsigned char buff[COMM_FAIL_MAX_DATASIZE] = {0};
	unsigned char keyStr[128], val[COMM_FAIL_MAX_DATASIZE];
	int res = -1;
	int nKeySize = 0;
    // #12553 2026.03.10 add FW7に伴う2038年問題対応 TDC高村 start
    char *end;
    // #12553 2026.03.10 add FW7に伴う2038年問題対応 TDC高村 end

	if ( ( fin = fopen(p_file_name, "r") ) == NULL ) {
		sprintf( logMsg, "ファイルを開けません:[%s]", p_file_name );
		LogOutputs( NTSS_LOG_INFO, logMsg, 0, "", "" );
		return res;
	}
	
	while( !feof(fin) ) {
		if ( fgets( buff, COMM_FAIL_MAX_DATASIZE, fin ) == NULL ) {
			/* EOF */
			break;
		}
		
		if( strncmp( buff, ";", 1 ) == 0 ){
			// コメント行
			continue;
		}
		
		if( comsv_fail_getParam( buff, keyStr, val ) == 1 ) {
			nKeySize = strlen( keyStr );
			
			if( nKeySize <= 0 )
				continue;
			
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//if( memcmp( COMM_FAIL_ORD_NO, keyStr, nKeySize) == 0 ) {
			if( strcmp( COMM_FAIL_ORD_NO, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// 仮ORD_NO
				str_trim( val );
				*p_ordNo = atol( val );
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_REAL_ORD_NO, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_REAL_ORD_NO, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// ORD_NO
				str_trim( val );
				*p_realOrdNo = atol( val );
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_PAT_ID, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_PAT_ID, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// PAT_ID
				str_trim( val );
				*p_pat_id =  atol( val );
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_DEV_NO, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_DEV_NO, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// DEV_NO
				str_trim( val );
				*p_dev_no =  atol( val );
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_COND_ORD_NO, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_COND_ORD_NO, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// COND_ORD_NO
				str_trim( val );
				*p_condOrdNo =  atol( val );
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_CANCEL_SEND_COND, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_CANCEL_SEND_COND, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// COMM_FAIL_CANCEL_SEND_COND
				str_trim( val );
				*p_cancelSendCond =  atoi( val );
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_START_TIME, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_START_TIME, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// 治療開始時間
                // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 start
				//*p_startTime =  atol( val );
 				*p_startTime = (time_t)strtoll(val, &end, 10);
                // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 end
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_END_TIME, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_END_TIME, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// 治療終了時間
                // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 start
				//*p_endTime =  atol( val );
                *p_endTime = (time_t)strtoll(val, &end, 10);
                // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 end
				break;
			}
		}
	}
	fclose( fin );
	res = 0;

	return res;
}

/**
* @fn void comsv_fail_find_head()
* @brief 通信障害データリストファイル HEAD処理
* @param[in,out] sp 装置制御データ
* @param[out] find_name file name of find
* @param[out] p_ordNo
* @param[out] p_realOrdNo
* @param[out] p_pat_id
* @param[out] p_dev_no
* @param[out] p_condOrdNo
* @param[out] p_cancelSendCond
* @param[out] p_startTime
* @param[out] p_endTime
* @return int 0:成功 -1:失敗
* @details 通信障害データリストファイル HEAD処理
*/
// #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 start
//int comsv_fail_find_head(struct scn_data_fm *sp, char *find_name, long *p_ordNo, long * p_realOrdNo, long * p_pat_id, 
//						long * p_dev_no, long *p_condOrdNo, short *p_cancelSendCond, long * p_startTime, long * p_endTime)
int comsv_fail_find_head(struct scn_data_fm *sp, char *find_name, long *p_ordNo, long * p_realOrdNo, long * p_pat_id, 
						long * p_dev_no, long *p_condOrdNo, short *p_cancelSendCond, time_t * p_startTime, time_t * p_endTime)
// #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 end
{
	FILE *fp1;
	FILE *fin;
	char fname[128];
	char name[128];
	long ordNo = 0;
	long realOrdNo = 0;
	long pat_id = 0;
	long dev_no = 0;
	long condOrdNo = 0;
	short cancelSendCond = 0;
	char command[512] = {0};
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	// char pathes[512] = {0};
	char pathes[128] = {0};
	char commFailListFile[128] = {0};
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
	unsigned char logMsg[256] = {0};
	unsigned char buff[COMM_FAIL_MAX_DATASIZE] = {0};
	unsigned char keyStr[128], val[COMM_FAIL_MAX_DATASIZE];
	int res = -1;
	int nKeySize = 0;
	bool bSucess = false;
	// add FNSI-バグ 通信サーバ(BIT) 高 start
	unsigned char deviceNo[9];
	// add FNSI-バグ 通信サーバ(BIT) 高 end
    // #12553 2026.03.10 add FW7に伴う2038年問題対応 TDC高村 start
    char *end;
    // #12553 2026.03.10 add FW7に伴う2038年問題対応 TDC高村 end
	
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	//sprintf(pathes, "%s", WORK_FAIL_PATH);
	getCommFailDirectory(pathes);
	getCommFailListFile(commFailListFile);
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
	// mod FNSI-バグ 通信サーバ(BIT) 高 start
	memset(deviceNo, '\0', sizeof(deviceNo));
	memcpy(deviceNo, sp->devid, 8);
	str_trim(deviceNo);
	// sprintf(fname, "%s_%.3s_%.7s", facility_cd, sp->deviceType, sp->devid);
	sprintf(fname, "%s_%.3s_%.8s", facility_cd, sp->deviceType, deviceNo);
	// mod FNSI-バグ 通信サーバ(BIT) 高 end
	
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	// 昇順で格納ファイル一覧作成
	// sprintf( command, "find %s -maxdepth 1 -type f -name \"%s*.txt\" | xargs --no-run-if-empty ls -rt1 > %s", pathes, fname, COMM_FAIL_LIST );
	sprintf( command, "find %s -maxdepth 1 -type f -name \"%s*.txt\" | xargs --no-run-if-empty ls -rt1 > %s", pathes, fname, commFailListFile );
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
	res = system(command);
	
	if ( WIFEXITED(res) ) {
		// 正常終了
		if ( 0 == WEXITSTATUS(res) ) {
			// コマンド正常終了
			//sprintf( logMsg, "COMM FAILファイル一覧取得成功 (%d) %s/%s > %s", res, pathes, fname, COMM_FAIL_LIST );
			//LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
			
			// ファイル一覧オープン
			// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
			// fp1 = fopen( COMM_FAIL_LIST, "r" );
			fp1 = fopen( commFailListFile, "r" );
			// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
			if ( fp1 != NULL ) {
				while( !feof(fp1) ) {
					memset( name, 0, sizeof(name) );
					if ( fgets( name, sizeof(name), fp1 ) == NULL ) {
						break;
					}
					name[strlen(name) - 1] = 0;

					if ( ( fin = fopen(name, "r") ) == NULL ) {
						sprintf( logMsg, "ファイルを開けません:[%s]", name );
						LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
						break;
					}
					
					*p_startTime = 0;
					*p_endTime = 0;
					
					while( !feof(fin) ) {
						if ( fgets( buff, COMM_FAIL_MAX_DATASIZE, fin ) == NULL ) {
							/* EOF */
							break;
						}
						
						if( strncmp( buff, ";", 1 ) == 0 ){
							// コメント行
							continue;
						}
						
						if( comsv_fail_getParam( buff, keyStr, val ) == 1 ) {
							nKeySize = strlen( keyStr );
							
							if( nKeySize <= 0 )
								continue;
							
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
							//if( memcmp( COMM_FAIL_ORD_NO, keyStr, nKeySize) == 0 ) {
							if( strcmp( COMM_FAIL_ORD_NO, keyStr ) == 0 ) {
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
								// 仮ORD_NO
								str_trim( val );
								ordNo = atol( val );
								continue;
							}
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
							//else if( memcmp( COMM_FAIL_REAL_ORD_NO, keyStr, nKeySize) == 0 ) {
							else if( strcmp( COMM_FAIL_REAL_ORD_NO, keyStr ) == 0 ) {
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
								// ORD_NO
								str_trim( val );
								realOrdNo = atol( val );
								continue;
							}
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
							//else if( memcmp( COMM_FAIL_PAT_ID, keyStr, nKeySize) == 0 ) {
							else if( strcmp( COMM_FAIL_PAT_ID, keyStr ) == 0 ) {
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
								// PAT_ID
								str_trim( val );
								pat_id =  atol( val );
								continue;
							}
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
							//else if( memcmp( COMM_FAIL_DEV_NO, keyStr, nKeySize) == 0 ) {
							else if( strcmp( COMM_FAIL_DEV_NO, keyStr ) == 0 ) {
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
								// DEV_NO
								str_trim( val );
								dev_no =  atol( val );
								continue;
							}
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
							//if( memcmp( COMM_FAIL_COND_ORD_NO, keyStr, nKeySize) == 0 ) {
							if( strcmp( COMM_FAIL_COND_ORD_NO, keyStr ) == 0 ) {
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
								// COND_ORD_NO
								str_trim( val );
								condOrdNo = atol( val );
								continue;
							}
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
							//if( memcmp( COMM_FAIL_CANCEL_SEND_COND, keyStr, nKeySize) == 0 ) {
							if( strcmp( COMM_FAIL_CANCEL_SEND_COND, keyStr ) == 0 ) {
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
								// CANCEL_SEND_COND
								str_trim( val );
								cancelSendCond = atoi( val );
								continue;
							}
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
							//else if( memcmp( COMM_FAIL_START_TIME, keyStr, nKeySize) == 0 ) {
							else if( strcmp( COMM_FAIL_START_TIME, keyStr ) == 0 ) {
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
								// 治療開始時間
                                // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 start
				                //*p_startTime =  atol( val );
                                *p_startTime = (time_t)strtoll(val, &end, 10);
                                // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 end
								continue;
							}
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
							//else if( memcmp( COMM_FAIL_END_TIME, keyStr, nKeySize) == 0 ) {
							else if( strcmp( COMM_FAIL_END_TIME, keyStr ) == 0 ) {
                            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
								// 治療終了時間
                                // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 start
			                	//*p_endTime =  atol( val );
                                *p_endTime = (time_t)strtoll(val, &end, 10);
                                // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 end
								break;
							}
						}
					}
					fclose( fin );
					
					// 仮ORD_NO
					if( ordNo != 0 && ordNo == sp->ord_no ) {
						strcpy( find_name, name );
						*p_ordNo = ordNo;
						*p_realOrdNo = realOrdNo;
						*p_pat_id = pat_id;
						*p_dev_no = dev_no;
						*p_condOrdNo = condOrdNo;
						*p_cancelSendCond = cancelSendCond;
						res = 0;
						bSucess = true;
						break;
					}
				}
				fclose( fp1 );
			}
		}
	}
	
	// #11627 2025.03.07 add 検索結果ファイルを毎回異なる名称で作成する TDC片口 start
	// 検索結果ファイルを削除
	remove(commFailListFile);
	// #11627 2025.03.07 add 検索結果ファイルを毎回異なる名称で作成する TDC片口 end
	
	if(bSucess == true)
		res = 0;
	else
		res = -1;

	return res;
}

/**
* @fn void comsv_fail_find_next()
* @brief 通信障害データリストファイル next record処理
* @param[in] sp 装置制御データ
* @param[in] fname file name
* @param[out] p_data
* @param[out] p_processed
* @param[out] p_data_type
* @param[out] p_pos
* @return int 0:成功 -1:失敗, 1:file over
* @details 通信障害データリストファイル next record処理
*/
int comsv_fail_find_next(struct comsv_fail_scn_data_fm *sp, char *fname, unsigned char *p_data, unsigned char * p_processed, unsigned char * p_data_type, long * p_pos)
{
	FILE *fin;
	unsigned char logMsg[256] = {0};
	unsigned char buff[COMM_FAIL_MAX_DATASIZE] = {0};
	unsigned char keyStr[128], val[COMM_FAIL_MAX_DATASIZE];
	int res = -1;
	int nKeySize = 0;
			
	// ファイルオープン
	if ( ( fin = fopen(fname, "r") ) == NULL ) {
		sprintf( logMsg, "ファイルを開けません:[%s]", fname );
		LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
		return res;
	}
					
	while( !feof(fin) ) {
		*p_pos = ftell(fin);
		if ( fgets( buff, COMM_FAIL_MAX_DATASIZE, fin ) == NULL ) {
			/* EOF */
			res = 1;
			break;
		}
		
		if( strncmp( buff, ";", 1 ) == 0 ){
			// コメント行
			continue;
		}
		
		if( comsv_fail_getParam( buff, keyStr, val ) == 1 ) {
			nKeySize = strlen( keyStr );
			
			if( nKeySize <= 0 )
				continue;
			
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//if( memcmp( COMM_FAIL_ORD_NO, keyStr, nKeySize) == 0 ) {
			if( strcmp( COMM_FAIL_ORD_NO, keyStr) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// 仮ORD_NO
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_REAL_ORD_NO, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_REAL_ORD_NO, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// ORD_NO
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_PAT_ID, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_PAT_ID, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// PAT_ID
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_DEV_NO, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_DEV_NO, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// DEV_NO
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_COND_ORD_NO, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_COND_ORD_NO, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// COND_ORD_NO
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_START_TIME, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_START_TIME, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// 治療開始時間
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_END_TIME, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_END_TIME, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// 治療終了時間
				continue;
			}
			
			if(keyStr[0] == '1')  // 1:processed
				continue;
			
			strcpy(p_data, val);
			*p_processed = keyStr[1];
			*p_data_type = keyStr[2];
			res = 0;

			break;
		}
	}
	fclose( fin );
	
	return res;
}

/**
* @fn void comsv_fail_get_time()
* @brief get current time
* @param[out] nowStr
* @details get current time
*/
void comsv_fail_get_time(char * nowStr)
{
	time_t nowTim;
	struct tm *local;
	
	/* 現在時刻を取得 */
	nowTim = time(NULL);
	local = localtime(&nowTim); /* 地方時に変換 */
	// 日付フォルダ名作成
	sprintf(nowStr, "%4d%02d%02d%02d%02d%02d",
			local->tm_year + 1900, local->tm_mon + 1, local->tm_mday,
			local->tm_hour, local->tm_min, local->tm_sec);
}

/**
* @fn void comsv_fail_split_filename()
* @brief split file name and ext
* @param[in] p_fullFileName
* @param[out] p_fileName
* @param[out] p_ext
* @details split file name and ext
*/
void comsv_fail_split_filename(char * p_fullFileName, char * p_fileName, char * p_ext)
{
	char * bp;
	char name[512];
	
	if(p_fullFileName[0] == '\0')
		return;
	
	strcpy(name, p_fullFileName);
	bp = strrchr(name, '.');
	if(bp == NULL)
		return;
	
	strcpy(p_ext, bp);
	name[strlen(name) - strlen(bp)] = '\0';
	strcpy(p_fileName, name);
}

/**
* @fn void comsv_fail_get_filename()
* @brief get file name of data directory
* @param[in] p_devNo
* @param[in] p_fullFileName
* @param[out] p_fileName
* @details get file name of data directory
*/
void comsv_fail_get_filename(long p_devNo, char * p_fullFileName, char * p_fileName)
{
	char * bp;
	char name[128];
	char ext[128];
	char nowStr[20];
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	char failDataPath[128] = {0};
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
	
	if(p_fullFileName[0] == '\0')
		return;
	
	memset(name, '\0', sizeof(name));
	memset(ext, '\0', sizeof(ext));
	
	/* 現在時刻を取得 */
	comsv_fail_get_time(nowStr);
	
	bp = basename(p_fullFileName);
	comsv_fail_split_filename(bp, name, ext);
	
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	// sprintf(p_fileName, "%s/%s_%ld_%s%s", WORK_FAIL_DATA_PATH, name, p_devNo, nowStr, ext);
	getCommFailDataDirectory(failDataPath);
	sprintf(p_fileName, "%s/%s_%ld_%s%s", failDataPath, name, p_devNo, nowStr, ext);
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
}

/**
* @fn void comsv_fail_replace_ordno()
* @brief 通信障害データリストファイル replace ordNo of record 処理
* @param[in] fname file name
* @param[in] p_ordNo  replaced ordNo
* @param[in] errDataFalg  error data flag, no process
* @return int 0:成功 -1:失敗
* @details 通信障害データリストファイル replace ordNo of record 処理
*/
int comsv_fail_replace_ordno(char *fname, long p_ordNo, bool errDataFalg)
{
	FILE *fin, *fout;
	char nowStr[20];
	char name[256];
	char temp_name[256];
	unsigned char logMsg[256] = {0};
	unsigned char cData[256] = {0};
	unsigned char tData[128] = {0};
	unsigned char buff[COMM_FAIL_MAX_DATASIZE] = {0};
	unsigned char keyStr[128], val[COMM_FAIL_MAX_DATASIZE], content[COMM_FAIL_MAX_DATASIZE];
	int res = -1;
	int nKeySize = 0;
	
	/* 現在時刻を取得 */
	comsv_fail_get_time(nowStr);
	
	// 拡張子除去
	strcpy(name, fname);
	name[strlen(name) - 4] = '\0';
	
	sprintf(temp_name, "%s_%s", name, nowStr);
			
	// ファイルオープン
	if ( ( fin = fopen(fname, "r") ) == NULL ) {
		sprintf( logMsg, "ファイルを開けません:[%s]", fname );
		LogOutputs( NTSS_LOG_INFO, logMsg, 0, "", "" );
		return res;
	}
	
	if ( ( fout = fopen(temp_name, "w") ) == NULL ) {
		sprintf( logMsg, "ファイルを開けません:[%s]", temp_name );
		LogOutputs( NTSS_LOG_INFO, logMsg, 0, "", "" );
		
		fclose( fin );
		return res;
	}
					
	while( !feof(fin) ) {
		if ( fgets( buff, COMM_FAIL_MAX_DATASIZE, fin ) == NULL ) {
			/* EOF */
			break;
		}
		
		if( strncmp( buff, ";", 1 ) == 0 ){
			// コメント行
			fputs(buff, fout);
			continue;
		}
		
		if( comsv_fail_getParam( buff, keyStr, val ) == 1 ) {
			nKeySize = strlen( keyStr );
			
			if( nKeySize <= 0 ){
				fputs(buff, fout);
				continue;
			}
			
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//if( memcmp( COMM_FAIL_ORD_NO, keyStr, nKeySize) == 0 ) {
			if( strcmp( COMM_FAIL_ORD_NO, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// 仮ORD_NO
				fputs(buff, fout);
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_REAL_ORD_NO, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_REAL_ORD_NO, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// ORD_NO
				if(p_ordNo != 0 && errDataFalg == false) {
					// ????の場合
					strcpy(cData, "REAL_ORD_NO=");
					sprintf(tData, "%ld\n", p_ordNo);
					strcat(cData, tData);
					fputs(cData, fout);
				}
				else{
					// condition sendの場合
					fputs(buff, fout);
				}
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_PAT_ID, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_PAT_ID, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// PAT_ID
				fputs(buff, fout);
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_DEV_NO, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_DEV_NO, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// DEV_NO
				fputs(buff, fout);
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_COND_ORD_NO, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_COND_ORD_NO, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// COND_ORD_NO
				fputs(buff, fout);
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_START_TIME, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_START_TIME, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// 治療開始時間
				fputs(buff, fout);
				continue;
			}
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
			//else if( memcmp( COMM_FAIL_END_TIME, keyStr, nKeySize) == 0 ) {
			else if( strcmp( COMM_FAIL_END_TIME, keyStr ) == 0 ) {
            // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
				// 治療終了時間
				fputs(buff, fout);
				continue;
			}
			
			if(keyStr[0] == '1') {  // 1:processed
				fputs(buff, fout);
				continue;
			}
			
			if(keyStr[2] == '0') {  // 0:directory output, 1: file name(.bin/.txt)
				strcpy(content, val);
				if(strstr(content, COMM_FAIL_REPLASE_ORD_NO) != NULL) {
					// error data or condition sendの場合
					if(errDataFalg == true || p_ordNo == 0) {
						if(errDataFalg == true)
							keyStr[0] = '1';
						sprintf(cData, "%s=", keyStr);
						fputs(cData, fout);
						fputs(content, fout);
						fputs("\n", fout);
						continue;
					}
					
					if(p_ordNo != 0) {
						// ????の場合
						sprintf(cData, "%s=", keyStr);
						fputs(cData, fout);

						sprintf(tData, "%ld", p_ordNo);
						strReplace( content, sizeof( content ), COMM_FAIL_REPLASE_ORD_NO, tData );
						fputs(content, fout);
						fputs("\n", fout);
					}
				}
				else {
					fputs(buff, fout);
					continue;
				}
			}
			else {
				fputs(buff, fout);
			}
		}
	}
	
	res = 0;
	
	fclose( fin );
	fclose( fout );
	
	moveFile(temp_name, fname, NTSS_MOVEFILE_MODE_OVERWRITE);
					
	return res;
}

/**
* @fn void comsv_fail_set_recState()
* @brief 通信障害データリストファイル set record processed state処理
* @param[in] sp 装置制御データ
* @param[in] fname file name
* @param[in] p_pos
* @return int 0:成功 -1:失敗
* @details 通信障害データリストファイル set record processed state処理
*/
int comsv_fail_set_recState(struct comsv_fail_scn_data_fm *sp, char *fname, long p_pos)
{
	FILE *fin;
	unsigned char logMsg[256] = {0};
	int res = -1;
			
	// ファイルオープン
	if ( ( fin = fopen(fname, "rb+") ) == NULL ) {
		sprintf( logMsg, "ファイルを開けません:[%s]", fname );
		LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
		return res;
	}
	
	if (!fseek(fin, p_pos, SEEK_SET)) {
		// 排他ロックを適用
		if (flock(fileno(fin), LOCK_EX) == 0) {
			// データ書き込み
			fwrite("1", 1, 1, fin);
			res = 0;
			
			// ロックを解除
			flock(fileno(fin), LOCK_UN);
		}
	}
	
	fflush( fin );				
	fclose( fin );
					
	return res;
}

/**
* @fn void comsv_fail_write_head()
* @brief 通信障害データリストファイル HEAD処理
* @param[in] sp 装置制御データ
* @param[in] p_realOrdNo
* @param[out] p_fileName
* @details 通信障害データリストファイル HEAD処理
*/
void comsv_fail_write_head(struct scn_data_fm *sp, long p_realOrdNo, char * p_fileName)
{
	char nowStr[20];
	char ftype[10] = {0};
	unsigned char cData[256] = {0};
	unsigned char tData[128] = {0};
	char pathes[512] = {0};
	unsigned char logMsg[256] = {0};
	int res;
	// add FNSI-バグ 通信サーバ(BIT) 高 start
	unsigned char deviceNo[9];
	// add FNSI-バグ 通信サーバ(BIT) 高 end
	
	if(sp->commType == NTSS_COMM_TYPE_NEW)		 // 新通信
		strcpy(ftype, COMM_FAIL_COMM_TYPE_NKK);
	else if(sp->commType == NTSS_COMM_TYPE_NX)	// NX通信
		strcpy(ftype, COMM_FAIL_COMM_TYPE_NX);
	else if(sp->commType == NTSS_COMM_TYPE_COMMON  && sp->devsw == 'W')   // 共通V3
		strcpy(ftype, COMM_FAIL_COMM_TYPE_V3);
	else if(sp->commType == NTSS_COMM_TYPE_COMMON  && sp->devsw == 'V')   // 共通V4
		strcpy(ftype, COMM_FAIL_COMM_TYPE_V4);
	else
		strcpy(ftype, COMM_FAIL_COMM_TYPE_OFF);   // オフライン通信

	/* 現在時刻を取得 */
	comsv_fail_get_time(nowStr);
	
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
	//sprintf(pathes, "%s", WORK_FAIL_PATH);
	getCommFailDirectory(pathes);
	// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
	// mod FNSI-バグ 通信サーバ(BIT) 高 start
	memset(deviceNo, '\0', sizeof(deviceNo));
	memcpy(deviceNo, sp->devid, 8);
	str_trim(deviceNo);
	// sprintf(p_fileName, "%s/%s_%.3s_%.7s_%s_recovery_task_list_%s.txt", pathes, facility_cd, sp->deviceType, sp->devid, ftype, nowStr);
	sprintf(p_fileName, "%s/%s_%.3s_%.8s_%s_recovery_task_list_%s.txt", pathes, facility_cd, sp->deviceType, deviceNo, ftype, nowStr);
	// mod FNSI-バグ 通信サーバ(BIT) 高 end
	
	// 仮ORD_NO設定
	strcpy(cData, "ORD_NO=");
	sprintf(tData, "%ld\n", sp->ord_no);
	strcat(cData, tData);
	
	// REAL_ORD_NO設定
	strcat(cData, "REAL_ORD_NO=");
	sprintf(tData, "%ld\n", p_realOrdNo);
	strcat(cData, tData);
	
	// PAT_ID設定
	strcat(cData, "PAT_ID=");
	sprintf(tData, "%ld\n", sp->pat_id);
	strcat(cData, tData);
	
	// DEV_NO設定
	strcat(cData, "DEV_NO=");
	sprintf(tData, "%ld\n", sp->dev_no);
	strcat(cData, tData);
	
	// ファイル出力
	if(( res = outputFile(
		  p_fileName			 // 作成するファイル名
		, cData			 // 記録するデータ
		, strlen( cData)	// 記録するデータ長
		)) == 1 ) {
		// ファイル作成成功
		// #11156 2025.02.14 add ログ追加 TDC片口 start
		snprintf(logMsg, sizeof(logMsg), "COMM FAILファイル作成成功(%s) ord_no=(%ld) real_ord_no=(%ld)", p_fileName, sp->ord_no, p_realOrdNo);
		LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
		// #11156 2025.02.14 add ログ追加 TDC片口 end
	}
	else {
		// ファイル作成失敗
		sprintf( logMsg, "COMM FAILファイル作成失敗(%s)", p_fileName );
		LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
	}
}

/**
* @fn void comsv_fail_append_data_full()
* @brief append data to file
* @param[in] p_facility_cd
* @param[in] p_deviceType 型式コード
* @param[in] p_devid 製造番号
* @param[in] p_data outputデータ
* @param[in] p_uploadMode 0:comsv_rest_execをコールする, 1:otherをコールする, 2:startTime, 3:endTime
* @param[in] p_data_type 0:directory output, 1: file name(.bin), 2:monidata txt
* @details 通信障害データリストファイル HEAD処理
*/
void comsv_fail_append_data_full(unsigned char *p_facility_cd, unsigned char *p_deviceType, unsigned char *p_devid, 
							unsigned char * p_data, int p_uploadMode, int p_data_type)
{
	int con;
	struct scn_data_fm *sp;
	unsigned char cDeviceType[4];
	unsigned char cDeviceNo[9];
	unsigned char logMsg[256] = {0};
	
	memmove( cDeviceType, p_deviceType, 3 );
	cDeviceType[3] = 0;

	// 製造番号
	memmove( cDeviceNo, p_devid, 8 );
	cDeviceNo[8] = 0;
	// 末尾の空白を除去
	trimEnd( cDeviceNo, ' ' );
	
	con = comsv_fail_current_con_sock(p_facility_cd, cDeviceType, cDeviceNo);
	// find con_sock error
	if(con == -1)
	{
		// #11156 2025.02.14 add ログ追加 TDC片口 start
		snprintf(logMsg, sizeof(logMsg), "comsv_fail_append_data_full 装置特定エラー");
		LogOutputs( NTSS_LOG_ERROR, logMsg, 0, cDeviceType, cDeviceNo );
		// #11156 2025.02.14 add ログ追加 TDC片口 end
		return;
	}
	
	sp = &(con_sock[con].scn);
	// output to file
	comsv_fail_append_data(sp, p_data, p_uploadMode, p_data_type);
}

/**
* @fn void comsv_fail_append_data()
* @brief 通信障害データリストファイル HEAD処理
* @param[in] sp 装置制御データ
* @param[in] p_data outputデータ
* @param[in] p_uploadMode 0:comsv_rest_execをコールする, 1:otherをコールする, 2:startTime, 3:endTime
* @param[in] p_data_type 0:directory output, 1: file name(.bin), 2:monidata txt
* @details 通信障害データリストファイル HEAD処理
*/
void comsv_fail_append_data(struct scn_data_fm *sp, unsigned char * p_data, int p_uploadMode, int p_data_type)
{
	char fname[128];
	unsigned char cData[COMM_FAIL_MAX_DATASIZE] = {0};
	unsigned char uData[COMM_FAIL_MAX_DATASIZE] = {0};
	unsigned char logMsg[256] = {0};
	unsigned char tData[512] = {0};
	long ordNo = 0;
	long realOrdNo = 0;
	long pat_id = 0;
	long dev_no = 0;
	long condOrdNo = 0;
	short cancelSendCond = 0;
	bool condOrdNo_Flag = false;
	int res;
    // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 start
	//long startTime = 0;
	//long endTime = 0;
	time_t startTime = 0;
	time_t endTime = 0;
    // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 end
	
	strcpy(uData, p_data);
	
	// #11156 2025.02.14 add ログ追加 TDC片口 start
	snprintf(logMsg, sizeof(logMsg), "COMM FAILファイル出力(追記)処理開始 ord_no=(%ld) p_uploadMode=(%d) p_data_type=(%d)", sp->ord_no, p_uploadMode, p_data_type);
	LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
	// #11156 2025.02.14 add ログ追加 TDC片口 end

	while(1) {
		// find exist 障害格納ファイル
		if(sp->ord_no != 0) {
			res = comsv_fail_find_head(sp, fname, &ordNo, &realOrdNo, &pat_id, &dev_no, &condOrdNo, &cancelSendCond, &startTime, &endTime);
			
			if(res == 0) {
				if(sp->ord_no < COMM_FAIL_DUMMY_ORD_NO && startTime == 0 && endTime == 0 && p_uploadMode == 2) {
					// create dummy ordNo
					setOrdNoDummy(getOrdNoDummy() + 1);
					sp->ord_no = getOrdNoDummy();
					sp->pat_id = 0;
					realOrdNo = 0;
				}
				else if(endTime != 0 && p_uploadMode == 2) {
					// create dummy ordNo
					setOrdNoDummy(getOrdNoDummy() + 1);
					sp->ord_no = getOrdNoDummy();
					sp->pat_id = 0;
					realOrdNo = 0;
				}
				else {
					break;
				}
			}
			else {
				if (sp->current_mon_sta[0] == COMM_STA1 || sp->current_mon_sta[0] == COMM_STA2 || p_uploadMode == 2) {
					// ？？？？ 患者として扱う
					sp->pat_id = 0;
					
					if(sp->current_mon_sta[0] == COMM_STA1 || sp->current_mon_sta[0] == COMM_STA2) {
						if(sp->ord_no > 0 && sp->ord_no < COMM_FAIL_DUMMY_ORD_NO) {
							condOrdNo = sp->ord_no;
							condOrdNo_Flag = true;
						}
					}
					
					// create dummy ordNo
					setOrdNoDummy(getOrdNoDummy() + 1);
					sp->ord_no = getOrdNoDummy();
					realOrdNo = 0;
				}
				else {
					// set ordNo of real
					if(sp->ord_no < COMM_FAIL_DUMMY_ORD_NO)
						realOrdNo = sp->ord_no;
				}
			}
		}
		else {
			// create dummy ordNo
			setOrdNoDummy(getOrdNoDummy() + 1);
			sp->ord_no = getOrdNoDummy();
			sp->pat_id = 0;
			realOrdNo = 0;
		}
		
		// create head file
		comsv_fail_write_head(sp, realOrdNo, fname);
		
		// #11925 2025.06.13 add サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 start
		// 仮オーダー番号発番時はローカルのmnt_machine_stateレコードキャッシュを更新
		if(sp->ord_no >= COMM_FAIL_DUMMY_ORD_NO)
		{
			comsv_json_dev_update(0, sp);
		}
		// #11925 2025.06.13 add サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC片口 end
		break;
	}
	
	// append start time alreadly exist and end time not exist , do nothing
	if(p_uploadMode == 2 && startTime != 0 && endTime == 0)
	{
		// #11168 2024.11.06 add ログ追加 TDC片口 start
		snprintf( logMsg, sizeof(logMsg), "COMM FAILファイル出力(追記)なし[append start time alreadly exist and end time not exist](%s)", fname );
		LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
		// #11168 2024.11.06 add ログ追加 TDC片口 end
		return;
	}
	// append end time and time alreadly exist, do nothing
	if(p_uploadMode == 3 && endTime != 0)
	{
		// #11168 2024.11.06 add ログ追加 TDC片口 start
		snprintf( logMsg, sizeof(logMsg),  "COMM FAILファイル出力(追記)なし[append end time and time alreadly exist](%s)", fname );
		LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
		// #11168 2024.11.06 add ログ追加 TDC片口 end
		return;
	}
	
	// process flag, 0: not process, 1:processed
	if(p_uploadMode == 0 || p_uploadMode == 1) {
		sprintf(cData, "0%d%d=", p_uploadMode, p_data_type);
		if(realOrdNo > 0) {
			// use real ordno
			sprintf(tData, "%ld", realOrdNo);
			strReplace( p_data, strlen(p_data), COMM_FAIL_REPLASE_ORD_NO, tData );
		}
		// #11156 2024.11.21 add commFailData肥大化対策 TDC片口 start
		if (p_data_type == 1 || p_data_type == 2)
		{
			snprintf(tData, sizeof(tData), "%s", p_data);
			moveDirCommFailDataFile(fname, tData, p_data);
		}
		else
		{
			snprintf(tData, sizeof(tData), "%s", p_data);
			moveDirRestApiCallParamFile(fname, tData, p_data);
		}
		// #11156 2024.11.21 add commFailData肥大化対策 TDC片口 end
		strcat(cData, p_data);
		strcat(cData, "\n");
	}
	else if(p_uploadMode == 2) {
		// start time
		sprintf(cData, "%s=", COMM_FAIL_START_TIME);
		strcat(cData, p_data);
		strcat(cData, "\n");
	}
	else {
		// end time
		sprintf(cData, "%s=", COMM_FAIL_END_TIME);
		strcat(cData, p_data);
		strcat(cData, "\n");
	}
	
	if(p_data_type == 0 || (p_data_type != 0 && strcmp(sp->collect_file_name, uData) != 0)){
		// ファイル出力(追記)
		if(( res = outputAppendFile(
			  fname			 // 作成するファイル名
			, cData			 // 記録するデータ
			, strlen( cData)	// 記録するデータ長
			)) == 1 ) {
			// ファイル作成成功
			// #11156 2025.02.14 add ログ追加 TDC片口 start
			snprintf(logMsg, sizeof(logMsg), "COMM FAILファイル出力(追記)成功(%s)", fname);
			LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
			// #11156 2025.02.14 add ログ追加 TDC片口 end
		}
		else {
			// ファイル作成失敗
			sprintf( logMsg, "COMM FAILファイル出力(追記)失敗(%s)", fname );
			LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
		}
	}
	if(p_data_type != 0)
		strcpy(sp->collect_file_name, uData);
	
	if(condOrdNo_Flag == true) {
		// 条件送信オーダー番号
		sprintf(tData, "%ld", condOrdNo);
		sprintf(cData, "%s=", COMM_FAIL_COND_ORD_NO);
		strcat(cData, tData);
		strcat(cData, "\n");
		
		// ファイル出力(追記)
		if(( res = outputAppendFile(
			  fname			 // 作成するファイル名
			, cData			 // 記録するデータ
			, strlen( cData)	// 記録するデータ長
			)) == 1 ) {
			// ファイル作成成功
			// #11156 2025.02.14 add ログ追加 TDC片口 start
			sprintf( logMsg, "COMM FAILファイル[COND_ORD_NO=%ld]出力(追記)成功(%s)", condOrdNo, fname);
			LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
			// #11156 2025.02.14 add ログ追加 TDC片口 end
		}
		else {
			// ファイル作成失敗
			sprintf( logMsg, "COMM FAILファイル出力(追記)失敗(%s)", fname );
			LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
		}
	}
	
	// cancel condition send
	if(p_uploadMode == 2 && condOrdNo > 0 && cancelSendCond == 0) {
		sprintf(cData, "%s=", COMM_FAIL_CANCEL_SEND_COND);
		strcat(cData, "1");
		strcat(cData, "\n");
		
		// ファイル出力(追記)
		if(( res = outputAppendFile(
			  fname			 // 作成するファイル名
			, cData			 // 記録するデータ
			, strlen( cData)	// 記録するデータ長
			)) == 1 ) {
			// ファイル作成成功
			// #11156 2025.02.14 add ログ追加 TDC片口 start
			sprintf( logMsg, "COMM FAILファイル[CANCEL_SEND_COND]出力(追記)成功(%s)", fname );
			LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
			// #11156 2025.02.14 add ログ追加 TDC片口 end
		}
		else {
			// ファイル作成失敗
			sprintf( logMsg, "COMM FAILファイル出力(追記)失敗(%s)", fname );
			LogOutputs( NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid );
		}
	}
}

int getCommAliveState()
{
	// #8081 mod 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 start
	//return _comm_alive_state;
	// 通信許可状態取得
	bool state = isCommEnableState();
	// 初回通信許可フラグが false で 通信許可状態となった場合
	if (!_first_comm_enabled && state) {
		// 初回通信許可フラグをtrue
		_first_comm_enabled = true;
	}
	// 通信許可状態を反転して返す(true→0[通信許可]/false→1[通信不可])
	return !state;
	// #8081 del 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 end
}
// #8081 add 2023.05.11 通信不可状態をファイルの有無により決定 TDC米沢 start
int getCommAliveStateOrder()
{
	return _comm_alive_state;
}
// #8081 add 2023.05.11 通信不可状態をファイルの有無により決定 TDC米沢 end
void setCommAliveState(int value)
{
	if (_comm_alive_state != value) {
		if (value == 0) {
			// #8081 mod 2023.05.11 ログ内容修正 TDC米沢 start
			//LogOutput(NTSS_LOG_INFO, "COMSV 通信State: OK");
			LogOutput(NTSS_LOG_INFO, " AWSとの通信状態：許可検出");
			// #8081 mod 2023.05.11 ログ内容修正 TDC米沢 end
		}
		if (value == 1) {
			// #8081 mod 2023.05.11 ログ内容修正 TDC米沢 start
			LogOutput(NTSS_LOG_INFO, " AWSとの通信状態：不可検出");
			//LogOutput(NTSS_LOG_INFO, "COMSV 通信State: NG");
			// #8081 mod 2023.05.11 ログ内容修正 TDC米沢 start
		}
	}
	_comm_alive_state = value;
}

int getCommAliveState_old()
{
	return _comm_alive_state_old;
}

void setCommAliveState_old(int value)
{
	if (_comm_alive_state_old != value) {
		if (value == 0) {
			// #8081 mod 2023.05.09 ログ内容修正 TDC米沢 start
			//LogOutput(NTSS_LOG_INFO, "COMSV OLD 通信State: OK");
			LogOutput(NTSS_LOG_INFO, " AWSとの通信状態保持：許可検出");
			// #8081 mod 2023.05.09 ログ内容修正 TDC米沢 end
		}
		else {
			// #8081 mod 2023.05.09 ログ内容修正 TDC米沢 start
			//LogOutput(NTSS_LOG_INFO, "COMSV OLD 通信State: NG");
			LogOutput(NTSS_LOG_INFO, " AWSとの通信状態保持：不可検出");
			// #8081 mod 2023.05.09 ログ内容修正 TDC米沢 end
		}
	}
	_comm_alive_state_old = value;
}

// #8081 add 2023.05.09 起動後に最初に通信許可となるまでの判定用関数 TDC米沢 start

bool isFirstCommEnabled() {
	return _first_comm_enabled;
}
// #8081 add 2023.05.09 起動後に最初に通信許可となるまでの判定用関数 TDC米沢 end

// get dummy ordno
long getOrdNoDummy()
{
	return _ord_no_dummy;
}

// set dummy ordno
void setOrdNoDummy(long value)
{
	_ord_no_dummy = value;
}

/**
 * @fn int comsv_fail_comsv_rest_get_dev(long devNo, unsigned char *devCd, unsigned char *devId, char *datFile)
 * @brief 装置状態管理データを取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_fail_comsv_rest_get_dev(long devNo, unsigned char *devCd, unsigned char *devId, char *datFile)
{
	int ret, fd;
	char url[200];
	char resFile[40];
	char errFile[40];
	char dev_sno[10];
	unsigned char cbuff[512] = {0};
	unsigned char logMessage[512] = {0};
	int ii = 0;
	int ret_comm = 0;
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP GET / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS / JSON"];
	/// @endmsc

	// 既にデータ取得ファイルがあれば削除
	remove(datFile);

	if (devCd[0] == 0 || devId[0] == 0)
	{
		return -1;
	}

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_state/getComsvState_commfail");
	comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
	fd = mkstemp(resFile);
	if (fd != 0)
	{
		close(fd);
	}
	comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
	fd = mkstemp(errFile);
	if (fd != 0)
	{
		close(fd);
	}

	memset(dev_sno, 0, sizeof(dev_sno));
	memcpy(dev_sno, devId, 8);
	str_trim(dev_sno);

	// ペイロードの内容をログ出力
	snprintf(logMessage, sizeof(logMessage), "通信障害装置状態管理取得(装置番号: %ld)", devNo);
	LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

	// REST用文字列作成
	sprintf(
		cbuff, "./sh/comsv_rest_get.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%s\" \"%s\" \"%s\"", url, facility_cd, devCd, dev_sno, resFile, errFile, datFile);

	if ( getCommAliveState() != 0 )
	{
		// AWSとDEの通信断
		// 退避ファイル
		ret = -9;
		
		// 使用したファイルの消し込み作業
		removeFileFullPath(resFile);
		removeFileFullPath(errFile);
	}
	else
	{
		// RESTをコールする
		ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "通信障害装置状態管理取得");

		if (ret != 0)
		{
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
			// ...
			ret_comm = comsv_rest_connection_watch(devCd, devId);
			if (ret_comm != 0)
			{
				setCommAliveState(1);
			}
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
		}
	}

	return ret;
}

// #11157 2024.11.01 del 重複する関数の削除 TDC片口 start
// /**
//  * @fn int comsv_rest_exec_1(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile) 
//  * @brief RESTを実行して結果を取得する
//  * @param[in] devCd 型式コード
//  * @param[in] devId 製造番号
//  * @param[in] restStr REST実行文字列
//  * @param[in] resFile レスポンスファイル名
//  * @param[in] errFile エラーファイル名
//  * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
//  * @return 0:成功, その他:エラー
//  */
// int comsv_rest_exec_1(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix) {
//	 int ret;
//	 // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
//	 /*
//	 unsigned char logMessage[1024] = {0};
//	 unsigned char responseCode[256] = {0};

//	 // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
//	 ret = system(restStr);

//	 if ( WIFEXITED(ret) ) {
//		 // 子プロセスが正常に終了した場合
//		 // 子プロセスの終了ステータスを取得
//		 ret = WEXITSTATUS(ret);
//	 }
//	 if ( readFileOneLine(responseCode, 50, resFile) == 0 ) {
//		 snprintf(logMessage, sizeof(logMessage), "%s REST 応答あり, (%s)", logPrefix, responseCode);
//	 }
//	 else {
//		 snprintf(logMessage, sizeof(logMessage), "%s REST 実行システムコール応答, (%d)", logPrefix, ret);
//	 }
//	 // LogOutput(NTSS_LOG_INFO, logMessage);

//	 // 終了コード作成
//	 if ( 0 < ret ) {
//		 // 成功系
//		 if ( 200 == ret || 226 == ret ) {
//			 ret = 0;
//		 }
//		 else if ( 408 == ret ) {
//			 // コネクションタイムアウトエラー
//			 ret = -1;
//		 }
//		 else {
//			 // その他エラー
//			 ret = -2;
//		 }
//	 }
//	 else {
//		 // 取得失敗エラー
//		 ret = -3;
//	 }

//	 if ( ret < 0 && readFileOneLine(responseCode, 255, errFile) == 0 ) {
//		 snprintf(logMessage, sizeof(logMessage), "%s REST 失敗応答を取得, (%s)", logPrefix, responseCode);
//		 //LogOutput(NTSS_LOG_INFO, logMessage);
//	 }

//	 // 使用したファイルの消し込み作業
//	 removeFileFullPath(resFile);
//	 removeFileFullPath(errFile);
	
//	 sprintf(logMessage, "comsv_rest_exec ret = %d", ret);
//	 //LogOutput(NTSS_LOG_INFO, logMessage);
//	 */
//	 // RESTコールして結果を取得する
//	 ret = ntss_restcall(devCd, devId, restStr, resFile, errFile, logPrefix);
//	 // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
//	 return ret;
// }
// #11157 2024.11.01 del 重複する関数の削除 TDC片口 end

/**
 * @fn int comsv_fail_alive_moni_main()
 * @brief 死活監視処理
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_fail_alive_moni_main()
{
	int ret;
	char url[200];
	// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
	// char * resFile = "./tmpFailAliveMainResponseCode1.txt";
	// char * errFile = "./tmpFailAliveMainErrResponseCode1.txt";
	char * resFile = "/tmp/tmpFailAliveMainResponseCode1.txt";
	char * errFile = "/tmp/tmpFailAliveMainErrResponseCode1.txt";
	// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
	unsigned char cbuff[512] = {0};
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP GET / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS / JSON"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/response_commfail");
	
	// REST用文字列作成
	sprintf(
		cbuff, "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%s\"", url, resFile, errFile);

	// RESTをコールする
	// #11157 2024.11.01 mod RESTを1回だけ実行して結果を取得する(リトライやNG時保存などなし) TDC片口 start
	// ret = comsv_rest_exec_1("", "", cbuff, resFile, errFile, "死活監視処理取得");
	ret = comsv_rest_exec_simple("", "", cbuff, resFile, errFile, "死活監視処理取得");
	// #11157 2024.11.01 mod RESTを1回だけ実行して結果を取得する(リトライやNG時保存などなし) TDC片口 end

	return ret;
}

/**
 * @fn int comsv_fail_alive_moni()
 * @brief 死活監視処理
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_fail_alive_moni(long devNo, unsigned char *devCd, unsigned char *devId)
{
	int ret, fd;
	char url[200];
	char resFile[40];
	char errFile[40];
	unsigned char cbuff[512] = {0};
	unsigned char logMessage[512] = {0};
	int ii = 0;
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP GET / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS / JSON"];
	/// @endmsc


	sprintf(url, "%s%s", rest_device_edge_url, "/response_commfail");
	comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
	fd = mkstemp(resFile);
	if (fd != 0)
	{
		close(fd);
	}
	comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
	fd = mkstemp(errFile);
	if (fd != 0)
	{
		close(fd);
	}

	// ペイロードの内容をログ出力
	snprintf(logMessage, sizeof(logMessage), "死活監視取得(装置番号: %ld)", devNo);
	LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

	// REST用文字列作成
	sprintf(
		cbuff, "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%s\"", url, resFile, errFile);

	// RESTをコールする
	// #11157 2024.11.01 mod RESTを1回だけ実行して結果を取得する(リトライやNG時保存などなし) TDC片口 start
	// ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "死活監視処理取得");
	ret = comsv_rest_exec_simple(devCd, devId, cbuff, resFile, errFile, "死活監視処理取得");
	// #11157 2024.11.01 mod RESTを1回だけ実行して結果を取得する(リトライやNG時保存などなし) TDC片口 end

	return ret;
}

/**
 * @fn int comsv_fail_comsv_json_dev_state(char *jfile, struct comsv_fail_scn_data_fm *scn)
 * @brief JSON文字列から装置状態管理を構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] scn 装置制御データ構造体
 * @return 0:成功, -1:エラー
 */
int comsv_fail_comsv_json_dev_state(char *jfile, struct comsv_fail_scn_data_fm *scn)
{
	int flg;
    // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 start
	//long l_tim;
	time_t l_tim;
    // #12553 2026.03.10 mod FW7に伴う2038年問題対応 TDC高村 end
	double dval;
	char *bp;
	char dt[20], tm[10];
	char key[40], num[20];
	char buf[255], sjis[255];
	JSON_Value *root_value;
	JSON_Object *root;

	if ( jfile == "" ) return -1;
	root_value = json_parse_file(jfile);
	if ( root_value == NULL ) return -1;
	root = json_object(root_value);
	if ( root == NULL ) {
		json_value_free(root_value);
		return -1;
	}

	// オーダ番号
	scn->ord_no = comsv_json_dotget_long(root, "ordNo");
	// 患者ID
	scn->pat_id = comsv_json_dotget_long(root, "patId");

	// 次回オーダ番号
	scn->next_ord_no = comsv_json_dotget_long(root, "nextOrdNo");
	// 次患者ID
	scn->next_pat_id = comsv_json_dotget_long(root, "nextPatid");

	// 透析開始日時
	bp = (char*)json_object_dotget_string(root, "startDate");
	if ( bp != NULL && bp[0] != 0 ) {
		strncpy(buf, bp, sizeof(buf));
		sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
		sprintf(tm, "%.8s", buf + 11);
		if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
			scn->dial_start_date = l_tim;
		}
	}
	// 透析終了日時
	bp = (char*)json_object_dotget_string(root, "endDate");
	if ( bp != NULL && bp[0] != 0 ) {
		strncpy(buf, bp, sizeof(buf));
		sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
		sprintf(tm, "%.8s", buf + 11);
		if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
			scn->dial_end_date = l_tim;
		}
	}

	json_value_free(root_value);

	return 0;
}

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_fail_comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, short devSta, short state, long date)
// * @brief 治療情報を登録（患者未登録運転)する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] devSta 装置ステータス
// * @param[in] state 治療状況
// * @param[in] date 日付
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//int comsv_fail_comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, long p_pat_id, long date)
/**
 * @fn int comsv_fail_comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, short devSta, short state, time_t date)
 * @brief 治療情報を登録（患者未登録運転)する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] devSta 装置ステータス
 * @param[in] state 治療状況
 * @param[in] date 日付
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_fail_comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, long p_pat_id, time_t date)
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
{
	int ret, fd;
	char url[200];
	char resFile[40];
	char errFile[40];
	char dt[20], tm[10];
	char cdate[20];
	unsigned char cbuff[512] = {0};
	unsigned char logMessage[512] = {0};
	int ii = 0;
	int ret_comm = 0;
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_ord/unregistered_commfail");
	comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
	fd = mkstemp(resFile);
	if ( fd != 0 ) close(fd);
	comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
	fd = mkstemp(errFile);
	if ( fd != 0 ) close(fd);
	
	// 日付を対象文字列に変換
	if ( time_str(date, dt, tm, 1) == 0 ) {
		dt[4] = dt[7] = tm[2] = tm[5] = 0;
		sprintf(cdate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
	}
	else {
		strcpy(cdate, "null");
	}

	// ペイロードの内容をログ出力
	snprintf(logMessage, sizeof(logMessage), "通信障害治療情報登録, (装置番号:%ld)", devNo);
	LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

	// REST用文字列作成
	sprintf(
		cbuff
		, "./sh/comsv_rest_put.sh \"%s\" \"%ld\" \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\""
		, url
		, p_pat_id
		, facility_cd
		, devNo
		, cdate
		, resFile
		, errFile
	);

	if ( getCommAliveState() != 0 )
	{
		// AWSとDEの通信断
		// 退避ファイル
		ret = -9;
		
		// 使用したファイルの消し込み作業
		removeFileFullPath(resFile);
		removeFileFullPath(errFile);
	}
	else
	{
		// RESTをコールする
		ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "通信障害治療情報登録");

		if (ret != 0)
		{
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
			// ...
			ret_comm = comsv_rest_connection_watch(devCd, devId);
			if (ret_comm != 0)
			{
				setCommAliveState(1);
			}
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
		}
	}

	return ret;
}

/**
 * @fn void comsv_fail_analysis_file_name()
 * @brief analisys file name
 * @param[in] p_fileName ファイル名
 * @param[out] scn 装置制御データ構造体
 * @return 
 */
void comsv_fail_analysis_file_name(char * p_fileName, struct comsv_fail_scn_data_fm *scn)
{
	char seps[] = "_";
	char *token;
	int cnt = 1;
	
	token = strtok( p_fileName, seps );
	while(token != NULL) {
		if(cnt == 1) {
			strcpy(scn->facility_cd, token);
		}
		else if(cnt == 2) {
			strcpy(scn->deviceType, token);
		}
		else if(cnt == 3) {
			strcpy(scn->devid, token);
			break;
		}
		token = strtok( NULL, seps );
		cnt++;
	}
}

/**
 * @fn int comsv_fail_current_con_sock()
 * @brief find current run con_sock
 * @param[in] p_facility_cd
 * @param[in] p_deviceType
 * @param[in] p_devid
 * @return >=0:成功, -1:失敗
 */
int comsv_fail_current_con_sock(unsigned char *p_facility_cd, unsigned char *p_deviceType, unsigned char *p_devid)
{
	int no;
	unsigned char cDeviceType[4] = {0};
	unsigned char cDeviceNo[10] = {0};
	unsigned char cDeviceNo_con[10];
	
	// 型式コード
	memmove( cDeviceType, p_deviceType, 3 );
	cDeviceType[3] = 0;

	// 製造番号
	memmove( cDeviceNo, p_devid, 8);
	cDeviceNo[8] = 0;
	// 末尾の空白を除去
	trimEnd( cDeviceNo, ' ' );
	
	for ( no = 0; no < DEV_MAX; no++ ) {
		// #8730 2023.06.09 add メインから送られた蓄積系データの取り込み TDC米沢 end
		// 装置接続中の条件を解除
		// if ( con_sock[no].using == true && con_sock[no].running == true ) {
		//	 if ( con_sock[no].scn.conflg != 2  ) {
		//		 // 通信OK以外
		//		 continue;
		//	 }
		if ( con_sock[no].using == true) {
		// #8730 2023.06.09 add メインから送られた蓄積系データの取り込み TDC米沢 end
			
			memset(cDeviceNo_con, '\0', sizeof(cDeviceNo_con));
			memmove( cDeviceNo_con, con_sock[no].scn.devid, 8);
			// 末尾の空白を除去
			trimEnd( cDeviceNo_con, ' ' );
			
			if( strncmp(p_facility_cd, facility_cd, strlen(p_facility_cd)) == 0 &&
				strncmp(cDeviceType, con_sock[no].scn.deviceType, strlen(cDeviceType)) == 0 &&
				strcmp(cDeviceNo, cDeviceNo_con) == 0) {
					return no;
			}
		}
	}
	
	return -1;
}

/**
 * @fn int comsv_fail_put_machine_state()
 * @brief MNT_MACHINE_STATのデータを更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] p_ordNo オーダー番号
 * @param[in] p_pat_id 患者ID
 * @param[in] p_next_ord_no 次回オーダー番号
 * @param[in] p_next_pad_id 次患者ID
 * @param[in] p_start_time 透析開始日時
 * @param[in] p_end_time 透析終了日時
 * @param[in] p_sta
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
//int comsv_fail_put_machine_state(long devNo, unsigned char *devCd, unsigned char *devId, long p_ordNo, long p_pat_id, 
//								 long p_next_ord_no, long p_next_pad_id, long p_start_time, long p_end_time, short p_sta)
int comsv_fail_put_machine_state(long devNo, unsigned char *devCd, unsigned char *devId, long p_ordNo, long p_pat_id, 
								 long p_next_ord_no, long p_next_pad_id, time_t p_start_time, time_t p_end_time, short p_sta)
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
{
	int ret, fd;
	char url[200];
	char resFile[40];
	char errFile[40];
	char dt[20], tm[10];
	char param[40];
	char cdate_start[20];
	char cdate_end[20];
	char dev_sno[10];
	unsigned char cbuff[512] = {0};
	unsigned char logMessage[512] = {0};
	int ii = 0;
	int ret_comm = 0;
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_state/updateMachineState_commfail");

	comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
	fd = mkstemp(resFile);
	if ( fd != 0 ) close(fd);
	comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
	fd = mkstemp(errFile);
	if ( fd != 0 ) close(fd);
	
	memset(dev_sno, 0, sizeof(dev_sno));
	memcpy(dev_sno, devId, 8);
	str_trim(dev_sno);

	// 日付を対象文字列に変換
	if ( time_str(p_start_time, dt, tm, 1) == 0 ) {
		dt[4] = dt[7] = tm[2] = tm[5] = 0;
		sprintf(cdate_start, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
	}
	else {
		strcpy(cdate_start, "null");
	}
	
	if ( time_str(p_end_time, dt, tm, 1) == 0 ) {
		dt[4] = dt[7] = tm[2] = tm[5] = 0;
		sprintf(cdate_end, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
	}
	else {
		strcpy(cdate_end, "null");
	}

	// ペイロードの内容をログ出力
	snprintf(logMessage, sizeof(logMessage), "通信障害MntMachineState情報更新 (オーダー番号:%ld)", p_ordNo);
	LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

	// REST用文字列作成
	sprintf(
		cbuff
		, "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%ld\" \"%ld\" \"%ld\" \"%ld\" \"%s\" \"%s\" \"%d\" \"%s\" \"%s\""
		, url
		, facility_cd
		, devCd
		, dev_sno
		, p_ordNo
		, p_pat_id
		, p_next_ord_no
		, p_next_pad_id
		, cdate_start
		, cdate_end
		, p_sta
		, resFile
		, errFile
	);

	// RESTをコールする
	// ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);
	if ( getCommAliveState() != 0 )
	{
		// AWSとDEの通信断
		// 退避ファイル
		ret = -9;
		
		// 使用したファイルの消し込み作業
		removeFileFullPath(resFile);
		removeFileFullPath(errFile);
	}
	else
	{
		// RESTをコールする
		ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);

		if (ret != 0)
		{
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
			// ...
			ret_comm = comsv_rest_connection_watch(devCd, devId);
			if (ret_comm != 0)
			{
				setCommAliveState(1);
			}
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
		}
	}
	
	return ret;
}

/**
 * @fn int comsv_fail_put_tmp_machine_state()
 * @brief tmp_comm_failure_recoveryのデータを更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] p_ordNo オーダー番号
 * @param[in] p_pat_id 患者ID
 * @param[in] p_next_ord_no 次回オーダー番号
 * @param[in] p_next_pad_id 次患者ID
 * @param[in] p_start_time 透析開始日時
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
//int comsv_fail_put_tmp_machine_state(long devNo, unsigned char *devCd, unsigned char *devId, long p_ordNo, long p_pat_id, 
//									long p_next_ord_no, long p_next_pad_id, long p_start_time, long p_end_time)
int comsv_fail_put_tmp_machine_state(long devNo, unsigned char *devCd, unsigned char *devId, long p_ordNo, long p_pat_id, 
									long p_next_ord_no, long p_next_pad_id, time_t p_start_time, time_t p_end_time)
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
{
	int ret, fd;
	char url[200];
	char resFile[40];
	char errFile[40];
	char dt[20], tm[10];
	char param[40];
	char cdate_start[20];
	char cdate_end[20];
	char dev_sno[10];
	unsigned char cbuff[512] = {0};
	unsigned char logMessage[512] = {0};
	int ii = 0;
	int ret_comm = 0;
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_state/updateTmpCommFailureRecovery_commfail");

	comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
	fd = mkstemp(resFile);
	if ( fd != 0 ) close(fd);
	comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
	fd = mkstemp(errFile);
	if ( fd != 0 ) close(fd);
	
	memset(dev_sno, 0, sizeof(dev_sno));
	memcpy(dev_sno, devId, 8);
	str_trim(dev_sno);

	// 日付を対象文字列に変換
	if ( time_str(p_start_time, dt, tm, 1) == 0 ) {
		dt[4] = dt[7] = tm[2] = tm[5] = 0;
		sprintf(cdate_start, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
	}
	else {
		strcpy(cdate_start, "null");
	}
	
	if ( time_str(p_end_time, dt, tm, 1) == 0 ) {
		dt[4] = dt[7] = tm[2] = tm[5] = 0;
		sprintf(cdate_end, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
	}
	else {
		strcpy(cdate_end, "null");
	}

	// ペイロードの内容をログ出力
	snprintf(logMessage, sizeof(logMessage), "通信障害TmpMntMachineState情報更新 (オーダー番号:%ld)", p_ordNo);
	LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

	// REST用文字列作成
	sprintf(
		cbuff
		, "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%ld\" \"%ld\" \"%ld\" \"%ld\" \"%s\" \"%s\" \"%s\" \"%s\""
		, url
		, facility_cd
		, devCd
		, dev_sno
		, p_ordNo
		, p_pat_id
		, p_next_ord_no
		, p_next_pad_id
		, cdate_start
		, cdate_end
		, resFile
		, errFile
	);

	// RESTをコールする
	// ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);
	if ( getCommAliveState() != 0 )
	{
		// AWSとDEの通信断
		// 退避ファイル
		ret = -9;
		
		// 使用したファイルの消し込み作業
		removeFileFullPath(resFile);
		removeFileFullPath(errFile);
	}
	else
	{
		// RESTをコールする
		ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);

		if (ret != 0)
		{
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
			// ...
			ret_comm = comsv_rest_connection_watch(devCd, devId);
			if (ret_comm != 0)
			{
				setCommAliveState(1);
			}
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
		}
	}

	return ret;
}

/**
 * @fn int comsv_fail_del_tmp_machine_state()
 * @brief comsv_fail_del_tmp_machine_stateのデータをDELETEする
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_fail_del_tmp_machine_state(long devNo, unsigned char *devCd, unsigned char *devId)
{
	int ret, fd;
	char url[200];
	char resFile[40];
	char errFile[40];
	char dev_sno[10];
	unsigned char cbuff[512] = {0};
	unsigned char logMessage[512] = {0};
	int ii = 0;
	int ret_comm = 0;
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s%s", rest_device_edge_url, "/comsv_state/deleteTmpComm_commFail");

	comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
	fd = mkstemp(resFile);
	if ( fd != 0 ) close(fd);
	comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
	fd = mkstemp(errFile);
	if ( fd != 0 ) close(fd);
	
	memset(dev_sno, 0, sizeof(dev_sno));
	memcpy(dev_sno, devId, 8);
	str_trim(dev_sno);

	// ペイロードの内容をログ出力
	//snprintf(logMessage, sizeof(logMessage), "通信障害TmpMntMachineState情報Delete");
	//LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

	// REST用文字列作成
	sprintf(
		cbuff
		, "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%s\" \"%s\""
		, url
		, facility_cd
		, devCd
		, dev_sno
		, resFile
		, errFile
	);

	// RESTをコールする
	// ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);
	if ( getCommAliveState() != 0 )
	{
		// AWSとDEの通信断
		// 退避ファイル
		ret = -9;
		
		// 使用したファイルの消し込み作業
		removeFileFullPath(resFile);
		removeFileFullPath(errFile);
	}
	else
	{
		// RESTをコールする
		ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);

		if (ret != 0)
		{
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
			// ...
			ret_comm = comsv_rest_connection_watch(devCd, devId);
			if (ret_comm != 0)
			{
				setCommAliveState(1);
			}
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
		}
	}

	return ret;
}

/**
 * @fn int comsv_fail_comsv_rest_exec()
 * @brief call comsv_rest_exec()
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] p_data data
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_fail_comsv_rest_exec(long devNo, unsigned char *devCd, unsigned char *devId, unsigned char * p_data)
{
	int ret, fd;
	char resFile[128];
	char errFile[128];
	int ii = 0;
	int ret_comm = 0;
	unsigned char val[COMM_FAIL_MAX_DATASIZE] = {0};
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc
	
	comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
	fd = mkstemp(resFile);
	if ( fd != 0 ) close(fd);
	comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
	fd = mkstemp(errFile);
	if ( fd != 0 ) close(fd);
	
	ii = 0;

	if ( getCommAliveState() != 0 )
	{
		// AWSとDEの通信断
		// 退避ファイル
		ret = -9;
		
		// 使用したファイルの消し込み作業
		removeFileFullPath(resFile);
		removeFileFullPath(errFile);
	}
	else
	{
		sprintf(val, "%s \"%s\" \"%s\"", p_data, resFile, errFile);
		
		// RESTをコールする
		ret = comsv_rest_exec(devCd, devId, val, resFile, errFile, "通信障害情報更新");

		if (ret != 0)
		{
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
			// ...
			ret_comm = comsv_rest_connection_watch(devCd, devId);
			if (ret_comm != 0)
			{
				setCommAliveState(1);
			}
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
		}
	}
	
   return ret;
}


/**
* @brief データ収集用フォルダ内の通信電文からテキストデータ作成
*
* @details データ収集用の通信電文からテキスト形式のデータ作成を行う
*
* @description
* @param[in] *facilitycode   施設コード{TAB}
* @param[in] edgeno		  デバイスエッジ番号{TAB}
* @param[in] *p_fname		bin file name
* @param[in] *out_path	   データ出力用パス
* @param[out] *p_outFileName  output file name
* @return int -1:初期化エラー 0〜:データ作成件数
* @attention 特になし
*/
int comsv_fail_mst_make_collect( char *facilitycode, int edgeno, char * p_fname, char *out_path, char * p_outFileName )
{
	FILE *fp2, *fp1;
	int fh;
	int i, len;
	int offset1;
	int offset2;
	int tp, sp, ep;
	int no, mode;
	int ret, count, loopCount;
	int nclass;
	short val, dec;
	unsigned short uval;
	long num;
	unsigned long unum;
	time_t tim;
	char name[200];
	char fname[200];
	char dev, ver[5];
	char buf[100], wrk[100];
	unsigned char bin[500], txt[3000];
	char type[14][10] = { "LOG", "MONS", "MONF", "MON", "MNT1", "MNT2",
						 "MNT3", "MNT4", "MNT5", "MT0", "MT1", "OPE", 
						 "DAR",  "RMN"};
	struct moni_list mon;
	struct ment_list mnt;
	char command[512] = {0};
	char pathes[512] = {0};
	struct stat st;
    // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
	//char nowStr[20];
	char nowStr[30];
    // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
	char nowStrSplit[30];
	char uniqueFname[128];
	time_t nowTim;
	struct tm *local;
	char * bp;
	// add FNSI-バグ 通信サーバ(BIT) 高 start
	char * p1;
	char serialno[10];
	// add FNSI-バグ 通信サーバ(BIT) 高 end
	// #8729 2023.08.01 mod REST応答に対する処理修正 TDC高村 start
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//struct timeval myTime;
    struct timespec myTime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	// #11168 2024.11.06 add ログ追加 TDC片口 start
	unsigned char logMsg[512] = {0};
	// #11168 2024.11.06 add ログ追加 TDC片口 end

	/* 現在時刻を取得 */
	//nowTim = time(NULL);
	//local = localtime(&nowTim); /* 地方時に変換 */
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//gettimeofday(&myTime, NULL);
	//local = localtime(&myTime.tv_sec);
	//// ユニークな結果ファイル名作成
	//sprintf( nowStr, "%4d%02d%02d%02d%02d%02d",
	//local->tm_year + 1900, local->tm_mon + 1, local->tm_mday,
	//local->tm_hour, local->tm_min, local->tm_sec);
	//sprintf( nowStr, "%4d%02d%02d%02d%02d%02d%6d",
	//local->tm_year + 1900, local->tm_mon + 1, local->tm_mday,
	//local->tm_hour, local->tm_min, local->tm_sec, myTime.tv_usec);
    clock_gettime(CLOCK_REALTIME, &myTime);
	local = localtime(&myTime.tv_sec);
	sprintf( nowStr, "%4d%02d%02d%02d%02d%02d%6d",
	local->tm_year + 1900, local->tm_mon + 1, local->tm_mday,
	local->tm_hour, local->tm_min, local->tm_sec, myTime.tv_nsec / 1000);
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	sprintf(uniqueFname, COLLECT_OUTPUT, nowStr);
	// #8729 2023.08.01 mod REST応答に対する処理修正 TDC高村 end

	// データ収集格納ファイル一覧オープン
	count = 0;
	strcpy(name, p_fname);
	bp = strstr(name, ".bin");
	
	if(bp == NULL)
	{
		// #11168 2024.11.06 add ログ追加 TDC片口 start
		snprintf(logMsg, sizeof(logMsg), "bp == NULL name: %s", name);
		LogOutputs(NTSS_LOG_ERROR, logMsg, 0, "", "");
		// #11168 2024.11.06 add ログ追加 TDC片口 end
		return -1;
	}

	// データ収集格納ファイルオープン
	fh = open( name, O_RDONLY );
	if ( fh == -1 )
	{ 
		// #11168 2024.11.06 add ログ追加 TDC片口 start
		snprintf(logMsg, sizeof(logMsg), "ファイルオープン失敗 name: %s", name);
		LogOutputs(NTSS_LOG_ERROR, logMsg, 0, "", "");
		// #11168 2024.11.06 add ログ追加 TDC片口 end
		return -1;
	}
	memset( bin, 0, sizeof(bin) );
	len = read( fh, bin, sizeof(bin) );
	close( fh );
	if ( len <= 0 )
	{
		// #11168 2024.11.06 add ログ追加 TDC片口 start
		snprintf(logMsg, sizeof(logMsg), "ファイル読み込みサイズ <= 0 name: %s", name);
		LogOutputs(NTSS_LOG_ERROR, logMsg, 0, "", "");
		// #11168 2024.11.06 add ログ追加 TDC片口 end
		return -1;
	}

	// バイナリからテキストデータへ変換
	memset( fname, 0, sizeof(fname) );
	strcpy( fname, basename(name) );
	memset( txt, 0, sizeof(txt) );
	offset1 = offset2 = 0;
	// kind=LOG/MON/MONS/MONF/MNT1/MNT2/MNT3/MNT4/MNT5/MT0/MT1{TAB}
	// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
	// for ( i=0, mode=0; i < 13; i++ ) {
	for ( i=0, mode=0; i < 14; i++ ) {
	// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
		if ( str_idx( fname, type[i] ) >= 0 ) {
			sprintf( txt, "kind=%s\t", type[i] );
			mode = i;
			break;
		}
	}
	
	// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
	// if ( i >= 13 ) continue;
	if ( i >= 14 )
	{
		// #11168 2024.11.06 add ログ追加 TDC片口 start
		snprintf(logMsg, sizeof(logMsg), "type配列に一致する文字なし name: %s", name);
		LogOutputs(NTSS_LOG_ERROR, logMsg, 0, "", "");
		// #11168 2024.11.06 add ログ追加 TDC片口 end
		return -1;
	}
	// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
	if ( str_idx( fname, "_R_" ) >= 0 ) {
		// RO装置は製造番号8バイト、他は7バイト
		offset1 = 1;
	}
	// facilitycode=施設コード{TAB}
	sprintf( buf, "facilitycode=%.6s\t", facilitycode );
	strcat( txt, buf );
	// edgeno=デバイスエッジ番号{TAB}
	sprintf( buf, "edgeno=%d\t", edgeno );
	strcat( txt, buf );
	// mod FNSI-バグ 通信サーバ 高 start
	ret = str_idx( fname, "_" );
	// if ( mode == 0 ) {
	if ( mode == 0 && ret >= 20) {
	// mod FNSI-バグ 通信サーバ 高 end
		// ログファイルの場合
		// occurdate=発生日時{TAB}
		sprintf( buf, "occurdate=%.14s\t", fname );
		strcat( txt, buf );
		offset2 = 21;
	}
	else {
		// ログファイル以外の場合
		// occurdate=発生日時{TAB}
		sprintf( buf, "occurdate=%.14s\t", fname + strlen(fname) - 24 );
		strcat( txt, buf );
	}
	// devicetype=型式コード{TAB}
	sprintf( buf, "devicetype=%.3s\t", fname + offset2 );
	strcat( txt, buf );
	// serialno=製造番号{TAB}
	// mod FNSI-バグ 通信サーバ(BIT) 高 start
	/*if ( offset1 == 0 ) {
		sprintf( buf, "serialno=%.7s\t", fname + offset2 + 4 );
	}
	else {
		sprintf( buf, "serialno=%.8s\t", fname + offset2 + 4 ); 
	}*/
	memset(serialno, '\0', sizeof(serialno));
	p1 = ntss_strrstr(fname, "_0_");
	if(p1 == NULL) {
		p1 = ntss_strrstr(fname, "_1_");
		if(p1 == NULL) {
			p1 = ntss_strrstr(fname, "_2_");
			if(p1 == NULL) {
				p1 = ntss_strrstr(fname, "_3_");
			}
		}
	}
	memcpy(serialno, fname + offset2 + 4, strlen(fname + offset2 + 4) - strlen(p1));
	sprintf( buf, "serialno=%.8s\t", serialno );
	strcat( txt, buf );
	// commformat=通信フォーマット{TAB}
	// dev = fname[14 + offset1 + offset2];
	dev = *(p1 + 3);
	sprintf( buf, "commformat=%c\t", dev );
	// mod FNSI-バグ 通信サーバ(BIT) 高 end
	strcat( txt, buf );
	
	// commstatus=通信ステータス{TAB}
	// version=装置バージョン(新通信：0x00固定、NX通信：0x01～),{TAB}
	// mod FNSI-バグ 通信サーバ(BIT) 高 start
	// if ( fname[12 + offset1 + offset2] == '1' ) {
	if ( *(p1 + 1) == '1' ) {
	// mod FNSI-バグ 通信サーバ(BIT) 高 end
		sprintf( buf, "commstatus=%04x\t", *(short *)(bin + 10) );
		strcat( txt, buf );
		strcpy( ver, "00" );
	}
	// mod FNSI-バグ 通信サーバ(BIT) 高 start
	// else if ( fname[12 + offset1 + offset2] == '2' ) {
	else if ( *(p1 + 1) == '2' ) {
	// mod FNSI-バグ 通信サーバ(BIT) 高 end
		sprintf( buf, "commstatus=%04x\t", *(short *)(bin + 26) );
		strcat( txt, buf );
		strcpy( ver, "01" );
	}
	// add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
	// mod FNSI-バグ 通信サーバ(BIT) 高 start
	// else if ( fname[12 + offset1 + offset2] == '3' ) {
	else if ( *(p1 + 1) == '3' ) {
	// mod FNSI-バグ 通信サーバ(BIT) 高 start
		sprintf( buf, "commstatus=%04x\t", *(short *)(bin + 10) );
		strcat( txt, buf );
		strcpy( ver, "00" );
	}
	// add 治療記録用データと治療状況用データの登録先を振分けにする 高 end
	else return -1;
	sprintf( buf, "version=%s\t", ver );
	strcat( txt, buf );
	
	// 各種データ部
	if ( mode == 0 && strcmp( ver, "00" ) == 0 ) {
		// 新通信ログデータ
		// code=種別＋コード{TAB}
		sprintf( buf, "code=%02X%02X\t", bin[13], bin[14] );
		strcat( txt, buf );
		// 発生時刻の差し替え
		ret = str_idx( txt, "occurdate=" );
		if ( ret > 0 ) {
			memset( wrk, 0, sizeof(wrk) );
			memcpy( wrk, bin + 15, 7 );
			tim = 0;
			bcd_time( wrk, &tim );
			if ( tim != -1 ) {
				time_str( tim, buf, buf + 20, 1 );
				buf[4] = buf[7] = buf[22] = buf[25] = 0;
				sprintf( wrk, "%s%s%s%s%s%s",
					 buf, buf + 5, buf + 8, buf + 20, buf + 23, buf + 26 );
				memcpy( txt + ret + 10, wrk, 14 );
			}
		}
		// 装置記録区分
		nclass = 4;	// その他
		if( 0x80 <= bin[13] && bin[13] <= 0xbf ) {
			// 警報
			nclass = 1;
		} else if( 0x40 <= bin[13] && bin[13] <= 0x7f ) {
			// 報知
			nclass = 2;
		} else if( bin[13] == 0xf4 || bin[13] == 0xf5 ){
			// 操作
			nclass = 3;
		}
		if ( bin[13] == 0x01 && bin[14] && bin[14] != 0x03 && bin[14] <= 0x06 ) {
			// 対象測定データはモニタデータとしても保存
			ret = str_idx( txt, "kind=" );
			memcpy( txt + ret + 5, type[3], strlen(type[3]) );	// LOG -> MONS
			// データ種別
			//  2：透析中血圧(bin[14] == 0x01)
			//  3：再循環率  (bin[14] == 0x06)※
			//  4：体温	  (bin[14] == 0x02)※
			//  5：透析前血圧(bin[14] == 0x04)
			//  6：透析後血圧(bin[14] == 0x05)
			short datatype = bin[14] + 1;
			if( datatype == 3 ) datatype = 4;	// 体温
			if( datatype == 7 ) datatype = 3;	// 再循環率
			sprintf( buf, "class=%d\t", datatype );
			strcat( txt, buf );
			strcat( txt, "items={" );
			if ( bin[14] == 0x02 ) {
				// 体温測定
				val = hl_chg( *(short *)(bin + 24) );
				dsp_s_form( wrk, 6, 1, val );
				str_trim( wrk );
				sprintf( buf, "\"94\":%s", wrk );
				strcat( txt, buf );
			}
			else if ( bin[14] == 0x06 ) {
				// 再循環率測定
				val = hl_chg( *(short *)(bin + 24) );
				sprintf( buf, "\"89\":%d", val );
				strcat( txt, buf );
			}
			else {
				// 血圧測定（最高、最低、平均、脈拍）
				val = hl_chg( *(short *)(bin + 24) );
				sprintf( buf, "\"90\":%d,", val );
				strcat( txt, buf );
				val = hl_chg( *(short *)(bin + 26) );
				sprintf( buf, "\"91\":%d,", val );
				strcat( txt, buf );
				val = hl_chg( *(short *)(bin + 28) );
				sprintf( buf, "\"92\":%d,", val );
				strcat( txt, buf );
				val = hl_chg( *(short *)(bin + 30) );
				sprintf( buf, "\"93\":%d", val );
				strcat( txt, buf );
			}
			strcat( txt, "}\n" );
			// テキストデータをファイル出力
			sprintf( p_outFileName, "%s/%s", out_path, uniqueFname );
			fp2 = fopen( p_outFileName, "a" );
			if (fp2 != NULL)
			{
				if (fputs(txt, fp2) >= 0)
				{
					count++;
				}
				else
				{
					// #11168 2024.11.08 add ログ追加 TDC片口 start
					snprintf(logMsg, sizeof(logMsg), "comsv_fail_mst_make_collect 出力ファイル書込み失敗1 p_outFileName: %s", p_outFileName);
					LogOutputs(NTSS_LOG_ERROR, logMsg, 0, "", "");
					// #11168 2024.11.08 add ログ追加 TDC片口 end
				}
				fclose(fp2);
			}
			else
			{
				// #11168 2024.11.08 add ログ追加 TDC片口 start
				snprintf(logMsg, sizeof(logMsg), "comsv_fail_mst_make_collect 出力ファイルオープン失敗1 p_outFileName: %s", p_outFileName);
				LogOutputs(NTSS_LOG_ERROR, logMsg, 0, "", "");
				// #11168 2024.11.08 add ログ追加 TDC片口 end
			}
			// ログデータ用に変更
			ret = str_idx( txt, "kind=" );
			memcpy( txt + ret + 5, type[0], strlen(type[0]) );	// MONS -> LOG
			ret = str_idx( txt, "class=" );
			txt[ret] = 0;
		}
		sprintf( buf, "class=%d\t", nclass);
		strcat( txt, buf );
		// items={"1":測定データ,"2":測定データ, ...  "x":測定データ}{LF}
		for ( i=24, no=0; i<len; i+=2, no++ ) {
			val = hl_chg( *(short *)(bin + i) );
			//if ( val == (short)(0x8000) ) continue;
			sprintf( buf, "data%d=%d\t", no + 1, val );
			strcat( txt, buf );
		}
		strcat( txt, "items={}\n" );
	}
	else if ( mode == 0 ) {
		// NX通信ログデータ
		// code=種別＋コード{TAB}
		sprintf( buf, "code=%02X%02X\t", bin[32], bin[33] );
		strcat( txt, buf );
		// 発生時刻の差し替え
		ret = str_idx( txt, "occurdate=" );
		if ( ret > 0 ) {
			memset( wrk, 0, sizeof(wrk) );
			memcpy( wrk, bin + 34, 8 );
			// BCD8バイト→7バイトに加工
			wrk[6] = wrk[7];
			tim = 0;
			bcd_time( wrk, &tim );
			time_str( tim, buf, buf + 20, 1 );
			if ( tim != -1 ) {
				buf[4] = buf[7] = buf[22] = buf[25] = 0;
				sprintf( wrk, "%s%s%s%s%s%s",
					 buf, buf + 5, buf + 8, buf + 20, buf + 23, buf + 26 );
				memcpy( txt + ret + 10, wrk, 14 );
			}
		}
		// 装置記録区分
		nclass = 4;	// その他
		if( 0x80 <= bin[32] && bin[32] <= 0xbf ) {
			// 警報
			nclass = 1;
		} else if( 0x40 <= bin[32] && bin[32] <= 0x7f ) {
			// 報知
			nclass = 2;
		} else if( bin[32] == 0xf4 || bin[32] == 0xf5 ){
			// 操作
			nclass = 3;
		}
		sprintf( buf, "class=%d\t", nclass);
		strcat( txt, buf );
		if ( dev != 'R' ) {
			// RO装置以外の場合、アドレス０、２、３、４、５、６、７
			dec = hl_chg( *(short *)(bin + 48) );
			sprintf( buf, "data0=%d\t", dec );
			strcat( txt, buf );
			dec = 0;	// 出力する値は少数を含まない
			val = hl_chg( *(short *)(bin + 44) );
			sprintf( buf, "data2=%d\t", val );
			strcat( txt, buf );
			num = int_chg( *(int *)(bin + 50) );
			dsp_l_form( wrk, 8, dec, num );
			str_trim( wrk );
			sprintf( buf, "data3=%s\t", wrk );
			strcat( txt, buf );
			num = int_chg( *(int *)(bin + 56) );
			dsp_l_form( wrk, 8, dec, num );
			str_trim( wrk );
			sprintf( buf, "data4=%s\t", wrk );
			strcat( txt, buf );
			num = int_chg( *(int *)(bin + 62) );
			dsp_l_form( wrk, 8, dec, num );
			str_trim( wrk );
			sprintf( buf, "data5=%s\t", wrk );
			strcat( txt, buf );
			num = int_chg( *(int *)(bin + 68) );
			dsp_l_form( wrk, 8, dec, num );
			str_trim( wrk );
			sprintf( buf, "data6=%s\t", wrk );
			strcat( txt, buf );
			val = hl_chg( *(short *)(bin + 74) );
			sprintf( buf, "data7=%d\t", val );
			strcat( txt, buf );
		}
		strcat( txt, "items={}\n" );
	}
	// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
	// else if ( 1 <= mode && mode <=3 && strcmp( ver, "00" ) == 0 ) {
	else if ( ((1 <= mode && mode <= 3) || mode == 13) && strcmp( ver, "00" ) == 0 ) {
	// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
		// 新通信モニタデータ
		// code=種別＋コード{TAB}
		strcat( txt, "code=0000\t" );
		// データ種別[1：モニタ]
		strcat( txt, "class=1\t" );
		// items={"1":測定データ,"2":測定データ, ...  "x":測定データ}{LF}
		strcat( txt, "items={" );
		for ( i=12, no=0; i<len; i+=2, no++ ) {
			memset( &mon, 0, sizeof(mon) );
			ret = ntss_mst_moni_data( dev, ver, no, &mon );
			if ( ret == 1 ) {
				val = hl_chg( *(short *)(bin + i) );
				if( mon.type == '5') {
					// HEX shortを取得して4桁HEXに変換
					sprintf( wrk, "\"%04X\"", val );
				}else{
					// 数値
					if ( val == (short)(0x8000) ) {
						continue;
					}
					// mod FNSI-バグ 通信サーバ 高 start
					// else if ( (no == 38 || no == 79 || no == 88) && val < 0 ) {
					else if ( (no == 3 || no == 38 || no == 79 || no == 88) && val < 0 ) {
					// mod FNSI-バグ 通信サーバ 高 end
						// 0未満の場合は無効（残り（除水）, Kt/V測定値, URR, PRR）
						continue;
					}
					dsp_s_form( wrk, 6, mon.dec, val );
				}
				str_trim( wrk );
				// mod FNSI-バグ 通信サーバ 高 start
				// if ( no > 0 ) strcat( txt, "," );
				if ( txt[strlen(txt)-1] != '{' ) strcat( txt, "," );
				// mod FNSI-バグ 通信サーバ 高 end
				sprintf( buf, "\"%d\":%s", no, wrk );
				strcat( txt, buf );
			}
		}
		strcat( txt, "}\n" );
	}
	// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
	// else if ( 1 <= mode && mode <= 3 ) {
	else if ( (1 <= mode && mode <= 3) || mode == 13 ) {
	// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
		// データ種別[1：モニタ]
		strcat( txt, "class=1\t" );
		// NX通信モニタデータ
		strcat( txt, "items={" );
		ep = hl_chg( *(short *)(bin + 24) );
		for ( i = 0; i < ep; i++ ) {
			memset( &mon, 0, sizeof(mon) );
			sp = (i * 4) + 28;
			if ( sp >= len ) {
				break;
			}
			no = hl_chg( *(short *)(bin + sp) );
			ret = ntss_mst_moni_data( dev, ver, no, &mon );
			if ( ret != 1 ) {
				continue;
			}
			val = hl_chg( *(short *)(bin + sp + 2) );
			if( mon.type == '5') {
				// HEX shortを取得して4桁HEXに変換
				sprintf( wrk, "\"%04X\"", val );
			}else{
				// 数値
				// add FNSI-バグ 通信サーバ 高 start
				if ( val == (short)(0x8000) ) {
					continue;
				}
				// add FNSI-バグ 通信サーバ 高 end
				dsp_s_form( wrk, 6, mon.dec, val );
			}
			str_trim( wrk );
			// mod FNSI-バグ 通信サーバ 高 start
			// if ( i > 0 ) strcat( txt, "," );
			if ( txt[strlen(txt)-1] != '{' ) strcat( txt, "," );
			// mod FNSI-バグ 通信サーバ 高 end
			sprintf( buf, "\"%d\":%s", no, wrk );
			strcat( txt, buf );
		}
		strcat( txt, "}\n" );
	}
	else if ( 4 <= mode && mode <= 8 ) {
		// 新通信メンテナンスデータ
		// items={"1":測定データ,"2":測定データ, ...  "x":測定データ}{LF}
		strcat( txt, "items={" );
		if ( mode == 4 ) {
			// ＵＦＲＣ
			tp = sp = 40; ep = 49;
		}
		else if ( mode == 5 ) {
			// 漏血テスト
			tp = sp = 50; ep = 54;
		}
		else if ( mode == 6 ) {
			// 透析液流量
			tp = sp = 55; ep = 58;
		}
		else if ( mode == 7 ) {
			// 濃度
			tp = sp = 60; ep = 65;
		}
		else if ( mode == 8 ) {
			// 動作時間
			tp = sp = 0; ep = 39;
		}
		if ( tp > 0 ) {
			// 発生時刻の差し替え
			ret = str_idx( txt, "occurdate=" );
			if ( ret > 0 ) {
				tp *= 2;
				tp += 12;
				memset( wrk, 0, sizeof(wrk) );
				memcpy( wrk, bin + tp, 6 );
				tim = 0;
				bcd_time( wrk, &tim );
				if ( tim != -1 ) {
					time_str( tim, buf, buf + 20, 0 );
					buf[4] = buf[7] = buf[22] = 0;
					sprintf( wrk, "%s%s%s%s%s00",
						buf, buf + 5, buf + 8, buf + 20, buf + 23 );
					memcpy( txt + ret + 10, wrk, 14 );
				}
			}
		}
		for ( i=12 + sp*2, no=sp; i<len && no<=ep; i+=2, no++ ) {
			memset( &mnt, 0, sizeof(mnt) );
			ret = ntss_mst_ment_data( dev, ver, no, &mnt );
			if ( ret == 1 ) {
				val = hl_chg( *(short *)(bin + i) );
				if ( mnt.type == '5') {
					// HEX shortを取得して4桁HEXに変換
					sprintf( wrk, "\"%04X\"", val );
				}
				else{
					if ( mode == 8 ) {
						// 動作時間
						uval = (unsigned short)hl_chg( *(short *)(bin + i) );
						dsp_l_form( wrk, 6, mnt.dec, (long)uval );
					}
					else {
						if ( val == (short)(0x8000) ) {
							continue;
						}
						dsp_s_form( wrk, 6, mnt.dec, val );
					}
				}
				str_trim( wrk );
				if ( txt[strlen(txt)-1] != '{' ) strcat( txt, "," );
				sprintf( buf, "\"%d\":%s", no, wrk );
				strcat( txt, buf );
			}
		}
		strcat( txt, "}\n" );
	}
	else if ( 9 <= mode && mode <= 12 ) {
		// NX通信メンテナンスデータ
		// items={"1":測定データ,"2":測定データ, ...  "x":測定データ}{LF}
		strcat( txt, "items={" );
		tp = 28;
		if ( mode != 11 ) {
			// 発生時刻の差し替え
			ret = str_idx( txt, "occurdate=" );
			if ( ret > 0 ) {
				memset( wrk, 0, sizeof(wrk) );
				if ( mode == 9 ) {
					// 配管テスト
					wrk[0] = bin[tp+6]; wrk[1] = bin[tp+7];
					wrk[2] = bin[tp+10]; wrk[3] = bin[tp+11];
					wrk[4] = bin[tp+14]; wrk[5] = bin[tp+15];
				}
				else if ( mode == 10 ) {
					// 希釈テスト
					wrk[0] = bin[tp+2]; wrk[1] = bin[tp+3];
					wrk[2] = bin[tp+6]; wrk[3] = bin[tp+7];
					wrk[4] = bin[tp+10]; wrk[5] = bin[tp+11];
				}
				else if ( mode == 12 ) {
					// 溶解記録
					wrk[0] = bin[tp+2]; wrk[1] = bin[tp+3];
					wrk[2] = bin[tp+6]; wrk[3] = bin[tp+7];
					wrk[4] = bin[tp+14]; wrk[5] = bin[tp+15];
					// 西暦下2桁のみの対応
					if( wrk[0] == 0x00 ) wrk[0] = 0x20;
				}
				tim = 0;
				bcd_time( wrk, &tim );
				if ( tim != -1 ) {
					time_str( tim, buf, buf + 20, 0 );
					buf[4] = buf[7] = buf[22] = 0;
					sprintf( wrk, "%s%s%s%s%s00",
						buf, buf + 5, buf + 8, buf + 20, buf + 23 );
					memcpy( txt + ret + 10, wrk, 14 );
				}
			}
		}
		ep = hl_chg( *(short *)(bin + tp - 4) );
		for ( i = 0; i < ep; i++ ) {
			memset( &mnt, 0, sizeof(mnt) );
			if ( dev != 'A' && mode == 11 ) {
				sp = (i * 6) + tp;
			}
			else {
				sp = (i * 4) + tp;
			}
			if ( sp >= len ) break;
			no = offset2 = hl_chg( *(short *)(bin + sp) );
			if ( mode == 9 ) {
				// 配管テスト
				offset2 += 800;
			}
			else if ( mode == 10 ) {
				// 希釈テスト
				offset2 += 900;
			}
			else if ( mode == 12) {
				// 溶解記録
				offset2 += 700;
			}
			ret = ntss_mst_ment_data( dev, ver, offset2, &mnt );
			if ( ret != 1 ) continue;
			if( mnt.type == '5'){
				// HEX shortを取得して4桁HEXに変換
				val = hl_chg( *(short *)(bin + sp + 2) );
				sprintf( wrk, "\"%04X\"", val );
			}else{
				// 数値
				if ( mode == 11 ) {
					if ( dev == 'A' ) {
						// DAB OPE
						uval = (unsigned short)hl_chg( *(short *)(bin + sp + 2) );
						dsp_l_form( wrk, 5, mnt.dec, (long)uval );
					}
					else {
						// DAD OPE
						unum = (unsigned int)int_chg( *(int *)(bin + sp + 2) );
						dsp_ul_form( wrk, 8, mnt.dec, unum );
					}
				}
				else {
					val = hl_chg( *(short *)(bin + sp + 2) );
					if ( dev == 'D' && mode == 12 && no == 8 ) {
						// Ｂ原液濃度（1桁切り捨て、少数１桁表示）
						// 1234 -> 123 -> 12.3
						val /= 10;
					}
					dsp_s_form( wrk, 6, mnt.dec, val );
				}
			}
			str_trim( wrk );
			if ( txt[strlen(txt)-1] != '{' ) {
				strcat( txt, "," );
			}
			sprintf( buf, "\"%d\":%s", no, wrk );
			strcat( txt, buf );
		}
		strcat( txt, "}\n" );
	}

	// テキストデータをファイル出力
	sprintf( p_outFileName, "%s/%s", out_path, uniqueFname );

	fp2 = fopen( p_outFileName, "a" );
	if ( fp2 != NULL ) {
		if ( fputs( txt, fp2 ) >= 0 ) {
			count++;
		}
		else
		{
			// #11168 2024.11.08 add ログ追加 TDC片口 start
			snprintf(logMsg, sizeof(logMsg), "comsv_fail_mst_make_collect 出力ファイル書込み失敗2 p_outFileName: %s", p_outFileName);
			LogOutputs(NTSS_LOG_ERROR, logMsg, 0, "", "");
			// #11168 2024.11.08 add ログ追加 TDC片口 end
		}
		fclose( fp2 );
	}
	else
	{
		// #11168 2024.11.08 add ログ追加 TDC片口 start
		snprintf(logMsg, sizeof(logMsg), "comsv_fail_mst_make_collect 出力ファイルオープン失敗2 p_outFileName: %s", p_outFileName);
		LogOutputs(NTSS_LOG_ERROR, logMsg, 0, "", "");
		// #11168 2024.11.08 add ログ追加 TDC片口 end
	}

	return count;
}

/**
 * @brief データ収集キャプチャファイル送信
 * 
 * @param rest 
 * @param[in] *facilitycode   施設コード{TAB}
 * @param[in] devNo		   デバイスエッジ番号{TAB}
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] *p_fname		bin file name
 * @return bool false:エラー  true:success
 */
bool comsv_fail_runDataCollectPacketSend(char *facilitycode, long devNo, unsigned char *devCd, unsigned char *devId, char * p_fname)
{
    // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
	//unsigned char cbuff[NTSS_STR_MAX_SIZE] = {0};
	unsigned char cbuff[512] = {0};
    // #12507 2026.03.11 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
	unsigned char logMessage[512] = {0};
	FILE *fp1;
	char fname[200];
	unsigned char responseCode[255] = {0};
	char buf[200];
	struct stat st;
	int fd;
	char responseFile[40];
	char errFile[40];
	int ii = 0;
	int ret;
	char rest[200];
	// #8729 2023.08.01 add REST応答に対する処理修正 TDC高村 start
	char *path;
	char outPath[255];
	// #8729 2023.08.01 add REST応答に対する処理修正 TDC高村 end

	comsv_work_fpath(devNo, WORK_RES_CODE, responseFile);
	fd = mkstemp(responseFile);
	if ( fd != 0 ) close(fd);
	comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
	fd = mkstemp(errFile);
	if ( fd != 0 ) close(fd);
	
	strcpy(fname, p_fname);
	if (existFolderFile(fname, &st) != 1)
	{
		return false;
	}
	// #8729 2023.08.01 mod REST応答に対する処理修正 TDC高村 start
	/*
	if (st.st_size > 0)
	{
		// データあり
		snprintf(logMessage, sizeof(logMessage), "COMM_FAILモニタデータファイルアップロード REST コール, (%s)", fname);
		LogOutput(NTSS_LOG_INFO, logMessage);
		
		sprintf(rest, "%s%s", rest_device_edge_url, "/post_file_commfail");

		// RESTをコールする
		sprintf(
			cbuff, "./sh/post_data_file.sh \"%s\" \"%s\" \"%s\" \"%d\" \"%s\" \"%s\"", rest, fname, facilitycode, device_edge_no, responseFile, errFile);

		// コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
		ret = system(cbuff);
		if (WIFEXITED(ret))
		{
			// 子プロセスが正常に終了した場合

			// 子プロセスの終了ステータスを取得
			ret = WEXITSTATUS(ret);
		}
		if (readFileOneLine(responseCode, 50, responseFile) == 0)
		{
			snprintf(logMessage, sizeof(logMessage), "COMM_FAILモニタデータアップロード REST 応答あり, (%s)", responseCode);
		}
		else
		{
			snprintf(logMessage, sizeof(logMessage), "COMM_FAILモニタデータアップロード REST 実行システムコール応答, (%d)", ret);
		}
		LogOutput(NTSS_LOG_INFO, logMessage);

		// 終了コード作成
		if (0 < ret)
		{
			// 成功系
			if (200 == ret)
			{
				ret = 0;
			}
			else
			{
				ret = 1;
			}
		}
		else
		{
			// 転送失敗エラー
			ret = 2;
		}
	}
	else
	{
		ret = 0;
	}

	if (ret > 0 && readFileOneLine(responseCode, 255, errFile) == 0)
	{
		snprintf(logMessage, sizeof(logMessage), "COMM_FAILモニタデータアップロード REST 失敗応答を取得, (%s)", responseCode);
		LogResourceOutput(NTSS_LOG_ERROR, logMessage);
	}

	if (ret == 0)
	{
		// 転送成功していたら使用したファイルの消し込み作業
		removeFileFullPath(fname);
		removeFileFullPath(responseFile);
		removeFileFullPath(errFile);
	}
	
	if (ret > 0)
	{
		for ( ii = 0; ii < 2; ii++ )
		{
			// RESTをコールする
			ret = comsv_fail_alive_moni(devNo, devCd, devId);
			if(ret != 0)
				continue;
		}
	}
	
	// 取得失敗
	if (ret != 0 && ii == 2)
	{
		setCommAliveState(1);
	}
	*/
	if (st.st_size > 0)
	{
		// データあり
		snprintf(logMessage, sizeof(logMessage), "COMM_FAILモニタデータファイルアップロード REST コール, (%s)", fname);
		LogOutput(NTSS_LOG_INFO, logMessage);
		
		sprintf(rest, "%s%s", rest_device_edge_url, "/post_file_commfail");

		// RESTをコールする
		sprintf(
			cbuff, "./sh/post_data_file.sh \"%s\" \"%s\" \"%s\" \"%d\" \"%s\" \"%s\"", rest, fname, facilitycode, device_edge_no, responseFile, errFile);

		// RESTコールして結果を取得する
		ret = ntss_restcall(devCd, devId, cbuff, responseFile, errFile, "COMM_FAILモニタデータファイルアップロード");
		// 応答判定 
		if ( ret == 1 )
		{
			// 500応答の場合
			// 移動先ファイル名作成
			strcpy(cbuff, fname);
			sprintf(outPath, "./NG/%s",basename(cbuff));
			// NGフォルダ有無判定
			strcpy(cbuff, outPath);
			path = dirname(cbuff);
			if (existFolderFile(path, NULL) != 1) {
				// ない場合はフォルダ作成
				createFolder(path);
			}
			// アップロードファイルをNGフォルダへ移動
			if (moveFile(fname, outPath, NTSS_MOVEFILE_MODE_OVERWRITE) == 1) {
				snprintf(logMessage, NTSS_STR_MAX_SIZE, "COMM_FAILモニタデータファイルアップロード 500応答のため蓄積系データをNGフォルダへ移動 [%s] -> [%s]", fname, outPath);
				LogOutput(NTSS_LOG_INFO, logMessage);
			}
		}
		// #11157 2024.11.01 mod ntss_restcall内で成功時は0が返る TDC片口 start
		// else
		else if (ret == 0)
		// #11157 2024.11.01 mod ntss_restcall内で成功時は0が返る TDC片口 end
		{
			// 転送成功の場合

			// 使用したファイルの消し込み作業
			removeFileFullPath(fname);
		}
	}
	// #8729 2023.08.01 mod REST応答に対する処理修正 TDC高村 end

	// 送信成功があればtrue
	LogOutput(NTSS_LOG_INFO, "COMM_FAILモニタデータアップロード処理終了");
	
	if (ret ==  0)
	{
		return true;
	}
	else
	{
		return false;
	}
}

/**
 * @fn int comsv_rest_put_ProcessState(long devNo, unsigned char *devCd, unsigned char *devId, unsigned char state)
 * @brief 装置のProcess STATUS状態更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] state 装置ステータス
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_ProcessState(long devNo, unsigned char *devCd, unsigned char *devId, unsigned char state) 
{
	int ret, fd;
	char url[200];
	char resFile[40];
	char errFile[40];
	char dev_sno[10];
	unsigned char cbuff[512] = {0};
	unsigned char logMessage[512] = {0};
	int ii = 0;
	int ret_comm = 0;
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc
	
	if(state == 0) {
		// ペイロードの内容をログ出力
		snprintf(logMessage, sizeof(logMessage), "装置のProcess STATUS状態更新(装置番号:%ld), (装置ステータス:%d)", devNo, state);
		LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);
		
		return 0;
	}

	sprintf(url, "%s/comsv_state/updateProcessState_commfail", rest_device_edge_url);

	comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
	fd = mkstemp( resFile );
	if ( fd != 0 ) close(fd);
	comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
	fd = mkstemp( errFile );
	if ( fd != 0 ) close(fd);
 
	memset(dev_sno, 0, sizeof(dev_sno));
	memcpy(dev_sno, devId, 8);
	str_trim(dev_sno);

	// ペイロードの内容をログ出力
	snprintf(logMessage, sizeof(logMessage), "装置のProcess STATUS状態更新(装置番号:%ld)", devNo);
	LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

	// RESTをコールする
	sprintf(
		cbuff
		, "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%02d\" \"%s\" \"%s\""
		, url
		, facility_cd
		, devCd
		, dev_sno
		, state
		, resFile
		, errFile
	);

	if ( getCommAliveState() != 0 )
	{
		// AWSとDEの通信断
		// 退避ファイル
		ret = -9;
		
		// 使用したファイルの消し込み作業
		removeFileFullPath(resFile);
		removeFileFullPath(errFile);
	}
	else
	{
		// RESTをコールする
		ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);

		if (ret != 0)
		{
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
			// ...
			ret_comm = comsv_rest_connection_watch(devCd, devId);
			if (ret_comm != 0)
			{
				setCommAliveState(1);
			}
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
		}
	}

	return ret;
}

/**
 * @fn int comsv_rest_put_cancelSendCond(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo)
 * @brief 条件送信の取消を実施する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo ordNo
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_put_cancelSendCond(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo) 
{
	int ret, fd;
	char url[200];
	char resFile[40];
	char errFile[40];
	char dev_sno[10];
	unsigned char cbuff[512] = {0};
	unsigned char logMessage[512] = {0};
	int ii = 0;
	int ret_comm = 0;
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP PUT / PARAMETER"];
	/// edge<=ec2 [label = "HTTP STATUS"];
	/// @endmsc

	sprintf(url, "%s/comsv_ord/cancelSendCond_commfail", rest_device_edge_url);

	comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
	fd = mkstemp( resFile );
	if ( fd != 0 ) close(fd);
	comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
	fd = mkstemp( errFile );
	if ( fd != 0 ) close(fd);
 
	memset(dev_sno, 0, sizeof(dev_sno));
	memcpy(dev_sno, devId, 8);
	str_trim(dev_sno);

	// ペイロードの内容をログ出力
	snprintf(logMessage, sizeof(logMessage), "条件送信の取消(装置番号:%ld)", devNo);
	LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

	// RESTをコールする
	sprintf(
		cbuff
		, "./sh/comsv_rest_put.sh \"%s\" \"%s\" \"%.3s\" \"%s\" \"%ld\" \"%s\" \"%s\""
		, url
		, facility_cd
		, devCd
		, dev_sno
		, ordNo
		, resFile
		, errFile
	);

	if ( getCommAliveState() != 0 )
	{
		// AWSとDEの通信断
		// 退避ファイル
		ret = -9;
		
		// 使用したファイルの消し込み作業
		removeFileFullPath(resFile);
		removeFileFullPath(errFile);
	}
	else
	{
		// RESTをコールする
		ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, logMessage);

		if (ret != 0)
		{
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 start
			// ...
			ret_comm = comsv_rest_connection_watch(devCd, devId);
			if (ret_comm != 0)
			{
				setCommAliveState(1);
			}
			// #11367 2025.01.10 mod 疎通テストは1回だけ＆関数の応答に影響を与えない TDC片口 end
		}
	}

	return ret;
}

/**
 * @brief ファイルサイズを取得する
 * 
 * @param file 
 * @return int64_t 
 */
int64_t
comsv_fail_getFileSize(unsigned char *file)
{
	struct stat statBuf;

	if (stat(file, &statBuf) == 0)
		return statBuf.st_size;

	return -1;
}

// #11282 2025.02.28 mod 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 start

// // #8730 2023.06.09 add メインから送られた蓄積系データの取り込み TDC米沢 start
// /**
// * @brief メインから送られた蓄積系データを通信障害データリストファイルに登録する
// *
// * @details メインから送られた蓄積系データを通信障害データリストファイルに登録する
// *
// * @description
// * @return なし
// * @attention 特になし
// */
// int
// updateCommFailData()
// {
//	 unsigned char cbuff[NTSS_STR_MAX_SIZE] = {0};
//	 unsigned char logMessage[NTSS_STR_MAX_SIZE] = {0};
//	 char flist[200];
//	 char fname[200];
//	 char command[512] = {0};
//	 char buf[200];
//	 char cDeviceType[4];
//	 char cDeviceNo[9];
//	 char *pStr;
//	 int nFileCount = 0;
//	 int nDataType;
//	 char *collectFileList = "/tmp/moved_file_list.txt";
//	 char *searchFile = "moveFile_*.lst";
//	 FILE *fp1, *fp2;
//	 struct stat st;

//	 LogOutput(NTSS_LOG_INFO, "メインから送られた蓄積系データの登録 開始");

//	 // 対象フォルダのメインから移動された蓄積系データファイルリストのリストを作成[更新日昇順]
//	 sprintf(command, "find %s -maxdepth 2 -type f -name \"%s\" | xargs --no-run-if-empty ls -rt1 > %s", _comm_fail_directory, searchFile, collectFileList);
//	 system(command);
//	 LogOutput(NTSS_LOG_INFO, "メインから送られた蓄積系データの登録 転送リストの収集完了");

//	 fp1 = fopen(collectFileList, "r");
//	 if (fp1 != NULL)
//	 {
//		 for (;;)
//		 {
//			 memset(flist, 0, sizeof(flist));
//			 if (fgets(flist, sizeof(flist), fp1) == NULL)
//			 {
//				 break;
//			 }
//			 flist[strlen(flist) - 1] = 0; // 末尾の改行コード無視

//			 if (existFolderFile(flist, &st) != 1)
//			 {
//				 continue;
//			 }
//			 if (st.st_size > 0)
//			 {
//				 // 転送リストを開く
//				 fp2 = fopen(flist, "r");
//				 if (fp2 != NULL)
//				 {
//					 for (;;)
//					 {
//						 memset(fname, 0, sizeof(fname));
//						 if (fgets(fname, sizeof(fname), fp2) == NULL)
//						 {
//							 break;
//						 }
//						 fname[strlen(fname) - 1] = 0; // 末尾の改行コード無視

//						 if (existFolderFile(fname, &st) != 1)
//						 {
//							 continue;
//						 }
//						 if (st.st_size > 0)
//						 {
//							 // 蓄積系ファイルが存在する場合

//							 memset(cbuff, 0, sizeof(cbuff));
//							 memset(cDeviceType, 0, sizeof(cDeviceType));
//							 memset(cDeviceNo, 0, sizeof(cDeviceNo));
//							 nDataType = 0;

//							 // 蓄積系ファイルの種別判定
//							 if (strcasecmp(fname + strlen(fname) - 3, "bin") == 0)
//							 {
//								 // バイナリファイル(通信共通以外)

//								 // // ファイル名から各情報を取得
//								 // //  [型式コード]_[製造番号]_[通信方式]_[通信フォーマット]_[通信コマンド識別子]_[受信年月日時分秒マイクロ秒].bin
//								 // strcpy(cbuff, fname);
//								 // pStr = basename(cbuff);
//								 // // 型式コード
//								 // strncpy(cDeviceType, pStr, 3);
//								 // // 製造番号
//								 // *strstr(pStr + 4, "_") = NULL;
//								 // strcpy(cDeviceNo, pStr + 4);
//								 // // データ形式(bin)
//								 // nDataType = 1;
//							 }
//							 else
//							 {
//								 // テキストファイル(通信共通)

//								 // ファイルから各情報を取得
//								 if (readFileOneLine(cbuff, sizeof(cbuff), fname) == 0 )
//								 {
//									 // 型式コード
//									 strncpy(cDeviceType, strstr(cbuff, "devicetype=") + 11, 3);
//									 // 製造番号
//									 pStr = strstr(cbuff, "serialno=") + 9;
//									 *strstr(pStr, "\t") = NULL;
//									 strcpy(cDeviceNo, pStr);
//									 // データ形式(text)
//									 nDataType = 2;
//								 }
//							 }

//							 // 登録先装置が取得できた場合
//							 if (0 < nDataType)
//							 {
//								 // 転送された蓄積系データを通信障害データリストファイルに登録
//								 comsv_fail_append_data_full(devicecapConf.cFacilityCode, cDeviceType, cDeviceNo, fname, 1, nDataType);

//								 snprintf(logMessage, NTSS_STR_MAX_SIZE, "メインから送られた蓄積系データの登録 蓄積系データを登録 [%s]：[%s]", flist, fname);
//								 LogOutputs(NTSS_LOG_INFO, logMessage, 0, cDeviceType, cDeviceNo);

//								 nFileCount++;
//							 }
//						 }
//					 }
//					 fclose(fp2);

//					 // 転送リストを削除
//					 snprintf(logMessage, NTSS_STR_MAX_SIZE, "メインから送られた蓄積系データの登録 転送リストを削除 [%s]", flist);
//					 LogOutput(NTSS_LOG_INFO, logMessage);
//					 removeFileFullPath(flist);
//				 }
//			 }
//		 }
//		 fclose(fp1);
//	 }

//	 snprintf(logMessage, NTSS_STR_MAX_SIZE, "メインから送られた蓄積系データの登録 終了 [%d]件", nFileCount);
//	 LogOutput(NTSS_LOG_INFO, logMessage);

//	 return nFileCount;
// }
// // #8730 2023.06.09 add メインから送られた蓄積系データの取り込み TDC米沢 end

/**
 * メインから送られた蓄積系データの登録
 * @param devNo 装置番号
 * @param deviceType 装置型式
 * @param deviceSerial 装置シリアル
 * @param dataType 1:日機装装置,NX装置 2:通信共通
 */
int updateCommFailDataFromMain(long devNo, char *deviceType, char *deviceSerial, int dataType)
{
	unsigned char logMessage[NTSS_STR_MAX_SIZE] = {0};
	char fname[200];
	char command[512] = {0};
	char buf[200];
	int nFileCount = 0;
	char targetDir[128] = {0};
	char *collectFileName = "moved_file_list_XXXXXX";
	char collectFileList[256] = {0};
	unsigned char devType[5];
	unsigned char devSerial[10];
	int fd;
	FILE *fp;
	struct stat st;

	memset(devType, 0, sizeof(devType));
	memset(devSerial, 0, sizeof(devSerial));
	memcpy(devType, deviceType, 3);
	memcpy(devSerial, deviceSerial, 8);
	// 末尾の空白を除去
	trimEnd(devSerial, ' ');

	// #11282 2025.03.13 mod 通信共通の装置ログが非対応だった問題の修正 TDC片口 start
	// if (dataType == 1)
	// {
	//	 // nkk
	//	 snprintf(targetDir, 128, "%s/moveFiles/nkk_%s_%s", _comm_fail_data_directory, devType, devSerial);
	// }
	// else if (dataType == 2)
	// {
	//	 // 通信共通
	//	 snprintf(targetDir, 128, "%s/moveFiles/cp_%s_%s", _comm_fail_data_directory, devType, devSerial);
	// }
	snprintf(targetDir, 128, "%s/moveFiles/%s_%s", _comm_fail_data_directory, devType, devSerial);
	// #11282 2025.03.13 mod 通信共通の装置ログが非対応だった問題の修正 TDC片口 start

	if (getFileCount(targetDir) == 0)
	{
		// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知(初期値true) TDC片口 start
		LogOutputs(NTSS_LOG_INFO, "メインから送られた蓄積系データの登録 フォルダにファイルなし", 0, devType, devSerial);
		// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知(初期値true) TDC片口 end

		// フォルダにファイルなし
		return 0;
	}

	comsv_work_fpath(devNo, collectFileName, collectFileList);
	fd = mkstemp(collectFileList);
	if (fd != 0)
		close(fd);

	LogOutputs(NTSS_LOG_INFO, "メインから送られた蓄積系データの登録 開始", 0, devType, devSerial);

	// 対象フォルダのメインから移動された蓄積系データファイルリストのリストを作成[更新日昇順]
	sprintf(command, "find %s -maxdepth 1 -type f | xargs --no-run-if-empty ls -rt1 > %s", targetDir, collectFileList);
	system(command);
	LogOutputs(NTSS_LOG_INFO, "メインから送られた蓄積系データの登録 転送リストの収集完了", 0, devType, devSerial);

	fp = fopen(collectFileList, "r");
	if (fp != NULL)
	{
		for (;;)
		{
			memset(fname, 0, sizeof(fname));
			if (fgets(fname, sizeof(fname), fp) == NULL)
			{
				break;
			}
			fname[strlen(fname) - 1] = 0; // 末尾の改行コード無視

			if (existFolderFile(fname, &st) != 1)
			{
				continue;
			}
			if (st.st_size > 0)
			{
				// 蓄積系ファイルが存在する場合

				// #11282 2025.03.13 mod 通信共通の装置ログが非対応だった問題の修正 TDC片口 start
				// // 転送された蓄積系データを通信障害データリストファイルに登録
				// comsv_fail_append_data_full(devicecapConf.cFacilityCode, devType, devSerial, fname, 1, dataType);

				// 蓄積系ファイルの種別判定
				if (strcasecmp(fname + strlen(fname) - 3, "bin") == 0)
				{
					// 転送された蓄積系データを通信障害データリストファイルに登録(bin)
					comsv_fail_append_data_full(devicecapConf.cFacilityCode, devType, devSerial, fname, 1, 1);
				}
				else
				{
					// 転送された蓄積系データを通信障害データリストファイルに登録(text)
					comsv_fail_append_data_full(devicecapConf.cFacilityCode, devType, devSerial, fname, 1, 2);
				}
				// #11282 2025.03.13 mod 通信共通の装置ログが非対応だった問題の修正 TDC片口 end

				snprintf(logMessage, NTSS_STR_MAX_SIZE, "メインから送られた蓄積系データの登録 蓄積系データを登録 [%s]：[%s]", collectFileList, fname);
				LogOutputs(NTSS_LOG_INFO, logMessage, 0, devType, devSerial);

				nFileCount++;
			}
		}
		fclose(fp);

		// 転送リストを削除
		snprintf(logMessage, NTSS_STR_MAX_SIZE, "メインから送られた蓄積系データの登録 転送リストを削除 [%s]", collectFileList);
		LogOutputs(NTSS_LOG_INFO, logMessage, 0, devType, devSerial);
		removeFileFullPath(collectFileList);
	}

	snprintf(logMessage, NTSS_STR_MAX_SIZE, "メインから送られた蓄積系データの登録 終了 [%d]件", nFileCount);
	LogOutputs(NTSS_LOG_INFO, logMessage, 0, devType, devSerial);

	return nFileCount;
}

// #11282 2025.02.28 mod 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 end

// #11156 2024.11.21 add commFailData肥大化対策 TDC片口 start

/**
 *  "で囲まれた文字列から"を削除
 */
int strRemovQuote(char *string, char *outString)
{
	size_t strLength = strlen(string);
	size_t lastIndex = 0;
	if (string[0] != '\"' || string[strLength - 1] != '\"')
	{
		return -1;
	}
	strcpy(outString, string + 1);
	lastIndex = strlen(outString) - 1;
	outString[lastIndex] = '\0';
	return 0;
}

/**
 * @brief exec実行電文に含まれるcommFailDataフォルダの対象ファイルをcommFail管理ファイルに対応するサブディレクトリに移動する
 *
 * @details exec実行電文に含まれるcommFailDataフォルダの対象ファイルをcommFail管理ファイルに対応するサブディレクトリに移動する
 *
 * @description
 * @return なし
 * @attention 特になし
 */
void moveDirRestApiCallParamFile(unsigned char *commFailFilePath, unsigned char *execCommand, unsigned char *fileMovedExecCommand)
{
	unsigned char failDataPath[257] = {0};
	unsigned char movedCommFailDataPath[257] = {0};
	char targetText[128] = {0};
	char failDataBasePath[128] = {0};
	int idx = 0;
	// commFailDataフォルダのパス取得
	getCommFailDataDirectory(failDataBasePath);

	sprintf(fileMovedExecCommand, "%s", execCommand);

	while (1)
	{
		idx++;
		memset(targetText, 0, sizeof(targetText));
		memset(failDataPath, 0, sizeof(failDataPath));

		if (get_split_text(idx, execCommand, ' ', targetText) == 0)
		{
			// 文字列の終端までチェックした
			break;
		}

		if (strstr(targetText, failDataBasePath) != NULL)
		{
			// commFailDataフォルダパスがある
			if (strRemovQuote(targetText, failDataPath) != 0)
			{
				// ""除去失敗
				continue;
			}
			moveDirCommFailDataFile(commFailFilePath, failDataPath, movedCommFailDataPath);
			strReplace(fileMovedExecCommand, 512, failDataPath, movedCommFailDataPath);
		}
	}
}

/**
 * @brief commFailDataフォルダの対象ファイルをcommFail管理ファイルに対応するサブディレクトリに移動する
 *
 * @details commFailDataフォルダの対象ファイルをcommFail管理ファイルに対応するサブディレクトリに移動する
 *
 * @description
 * @return 1: 移動成功 other: 失敗
 * @attention 特になし
 */
int moveDirCommFailDataFile(unsigned char *commFailFilePath, unsigned char *originalCommFailDataPath, unsigned char *movedCommFailDataPath)
{
	char failDataPath[257] = {0};

	// commFailDataフォルダのパス作成
	getCommFileUseDirName(commFailFilePath, failDataPath);
	// ファイルパス作成
	sprintf(movedCommFailDataPath, "%s/%s", failDataPath, basename(originalCommFailDataPath));
	// 移動
	return moveFile(originalCommFailDataPath, movedCommFailDataPath, NTSS_MOVEFILE_MODE_OVERWRITE);
}

/**
 * @brief commFail管理ファイル専用サブディレクトリを生成
 *
 * @details commFail管理ファイル専用サブディレクトリを生成
 *
 * @description
 * @return なし
 * @attention 特になし
 */
void getCommFileUseDirName(unsigned char *commFailFilePath, unsigned char *uniqPath)
{
	char failDataBasePath[128] = {0};
	char failDataPath[257] = {0};
	unsigned char commFileDirName[128];

	// commFailDataフォルダのパス作成
	getCommFailDataDirectory(failDataBasePath);
	buildCommFileUniqDirName(commFailFilePath, commFileDirName);
	snprintf(failDataPath, sizeof(failDataPath),  "%s/%s", failDataBasePath, commFileDirName);
	stat_mkdir(failDataPath);

	sprintf(uniqPath, "%s", failDataPath);
}

/**
 * @brief commFail管理ファイル名からサブディレクトリ名を生成
 *
 * @details commFail管理ファイル名からサブディレクトリ名を生成
 *
 * @description
 * @return なし
 * @attention 特になし
 */
void buildCommFileUniqDirName(unsigned char *commFailFilePath, unsigned char *commFileDirName)
{
	char commFailBaseFile[128];
	unsigned char commFailFileName[128];
	unsigned char commFailFileExt[128];

	// commFail管理ファイル名の取得
	strncpy(commFailBaseFile, basename(commFailFilePath), sizeof(commFailBaseFile));
	comsv_fail_split_filename(commFailBaseFile, commFailFileName, commFailFileExt);
	// ユニークディレクトリ名の生成
	strReplace(commFailFileName, 128, "_recovery_task_list_", "_");
	sprintf(commFileDirName, "%s", commFailFileName);
}
// #11156 2024.11.21 add commFailData肥大化対策 TDC片口 end