/**
* @file comsv_work_data.c
* @brief 作業データ用処理
* @author Y.Takamura
* @date 2019/05/14
* @details 作業データ用フォルダ・ファイル作成を行う
*/

#include <stdio.h>
#include <stdlib.h>
// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
#include <stdbool.h>
// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include <string.h>
#include <sys/stat.h>
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "comsv_work_data.h"

// #12302 2025.10.10 add ログ出力のためのライブラリ追加 TDC米沢 start
#include "../common/libs/ntss_log_lib.h"
// #12302 2025.10.10 add ログ出力のためのライブラリ追加 TDC米沢 end

/**
* @fn int comsv_work_mkdir()
* @brief 作業データ用フォルダ作成
* @return int 0:成功 -1:失敗
* @details 作業データ用フォルダを作成する
*/ 
int comsv_work_mkdir() {
    int ret = -1;

    if ( stat_mkdir(WORK_DATA_PATH) == true ) ret = 0;

    return ret;
}

/**
* @fn int comsv_work_mkdir_dev(long dev_no)
* @brief 作業データ用フォルダ作成
* @param[in] dev_no 装置番号
* @return int 0:成功 -1:失敗
* @details 作業データ用フォルダ（共通データ／装置番号）を作成する
*/ 
int comsv_work_mkdir_dev(long dev_no) {
    int ret = -1;
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char buf[20];
    char buf[30];
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end

    if ( dev_no < 0 ) {
        // 共通データフォルダ作成
        sprintf(buf, "%s/%s", WORK_DATA_PATH, WORK_COMMON_PATH);
    }
    else {
        // 装置番号フォルダ作成
        // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
        // sprintf(buf, "%s/%08lX", WORK_DATA_PATH, dev_no);
        sprintf(buf, "%s/%08lX", WORK_TMP_DATA_PATH, dev_no);
        // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    }
    if ( stat_mkdir(buf) == true ) ret = 0;

    return ret;
}

/**
* @fn char *comsv_work_fpath(long dev_no, char *name, char *fpath)
* @brief 作業データ用ファイル名作成
* @param[in] dev_no 装置番号
* @param[in] name 対象ファイル名
* @param[out] fpath 作成したファイルパス名
* @details 作業データ用ファイル名を作成する
*/ 
void comsv_work_fpath(long dev_no, char *name, char *fpath) {
    int ret;

    if ( dev_no < 0 ) {
        // ファイル名作成（共通データフォルダ）
        sprintf(fpath, "%s/%s/%s", WORK_DATA_PATH, WORK_COMMON_PATH, name);
    }
    else {
        // ファイル名作成（装置番号フォルダ）
        // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
        // sprintf(fpath, "%s/%08lX/%s", WORK_DATA_PATH, dev_no, name);
        sprintf(fpath, "%s/%08lX/%s", WORK_TMP_DATA_PATH, dev_no, name);
        // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    }
}

// add AWSとDEの通信断からの復旧 高 start
/**
* @fn int comsv_work_mkdir_commfail()
* @brief 作業データ用フォルダ作成
* @return int 0:成功 -1:失敗
* @details 作業データ用フォルダを作成する
*/ 
int comsv_work_mkdir_commfail()
{
    int ret = -1;
    // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
    // if ( stat_mkdir(WORK_FAIL_PATH) == true )  {
    //     if ( stat_mkdir(WORK_FAIL_DATA_PATH) == true ) ret = 0;
    // }
    char failPath[128] = {0};
    char failDataPath[128] = {0};

    getCommFailDirectory(failPath);
    getCommFailDataDirectory(failDataPath);
    if ( stat_mkdir(failPath) == true )  {
        if ( stat_mkdir(failDataPath) == true ) ret = 0;
    }
    // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end

    return ret;
}

/**
* @fn comsv_work_fpath_commfail(char *fpath)
* @brief 作業データ用ファイル名作成
* @param[out] fpath 作成したファイルパス名
* @details 作業データ用ファイル名を作成する
*/ 
void comsv_work_fpath_commfail(char *fpath)
{
    // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
    //sprintf(fpath, "%s", WORK_FAIL_PATH);
    getCommFailDirectory(fpath);
    // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
}

/**
* @fn comsv_work_fpath_commFailData(char *fpath)
* @brief 作業データ用ファイル名作成
* @param[out] fpath 作成したファイルパス名
* @details 作業データ用ファイル名を作成する
*/ 
void comsv_work_fpath_commFailData(char *fpath)
{
    // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
    //sprintf(fpath, "%s", WORK_FAIL_DATA_PATH);
    getCommFailDataDirectory(fpath);
    // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
}
// add AWSとDEの通信断からの復旧 高 end

// add FNSI-バグ 通信サーバ 高(#5618) start
/**
* @fn int comsv_work_mkdir_dev_commfail()
* @brief 作業データ用フォルダ作成
* @param[in] dev_no 装置番号
* @return int 0:成功 -1:失敗
* @details 作業データ用フォルダを作成する
*/ 
int comsv_work_mkdir_dev_commfail(long dev_no)
{
    int ret = -1;
    // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
    // char buf[128] = {0};
    // // 装置番号フォルダ作成
    // sprintf(buf, "./%s_%08lX", WORK_DEV_FAIL_DATA_PATH, dev_no);
    char buf[160] = {0};
    char path[128] = {0};
    getCommDevFailDataDirectory(path);
    // 装置番号フォルダ作成
    sprintf(buf, "%s_%08lX", path, dev_no);
    // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end

    if ( stat_mkdir(buf) == true ) ret = 0;

    return ret;
}

/**
* @fn comsv_work_fpath_dev_commfail(char *fpath)
* @brief 作業データ用ファイル名作成
* @param[in] dev_no 装置番号
* @param[out] fpath 作成したファイルパス名
* @details 作業データ用ファイル名を作成する
*/ 
void comsv_work_fpath_dev_commfail(long dev_no, char *fpath)
{
    // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
    // sprintf(fpath, "./%s_%08lX", WORK_DEV_FAIL_DATA_PATH, dev_no);
    char path[128] = {0};
    getCommDevFailDataDirectory(path);
    // 装置番号フォルダ作成
    sprintf(fpath, "%s_%08lX", path, dev_no);
    // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
}

/**
 * @brief 更新用フォルダの削除
 * 
 * @return true 
 * @return false 
 */
bool removeWorkDir(u_char *dirPath)
{
    u_char command[512] = {0};
    unsigned char logMessage[512] = {0};
    sprintf(command, "rm -rf %s", dirPath);
    system(command);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            ///snprintf(logMessage, sizeof(logMessage), "作業フォルダの削除成功 (%d) {%s} ", res, command);
            //LogOutput(NTSS_LOG_INFO, logMessage);
            return true;
        }
    }
    //snprintf(logMessage, sizeof(logMessage), "作業フォルダの削除失敗 (%d) {%s} ", res, command);
    //LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

/**
 * @brief COPY用フォルダの
 * 
 * @return true 
 * @return false 
 */
bool copyWorkDir(u_char *s_dirPath, u_char *d_dirPath)
{
    u_char command[512] = {0};
    unsigned char logMessage[512] = {0};
    sprintf(command, "cp -rf %s/* %s", s_dirPath, d_dirPath);
    system(command);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            //snprintf(logMessage, sizeof(logMessage), "作業フォルダのCOPY成功 (%d) {%s} ", res, command);
            //LogOutput(NTSS_LOG_INFO, logMessage);
            return true;
        }
    }
    //snprintf(logMessage, sizeof(logMessage), "作業フォルダのCOPY失敗 (%d) {%s} ", res, command);
    //LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

/**
 * @brief check date
 * 
 * @return true     is date
 * @return false    is not date
 */
bool is_valid_date(unsigned char * p)
{
    int i;
    unsigned char  sYear[5], sDat[3];
    int iYear, iDat;
   
    // check length
    if(strlen(p) != 14)
        return false;
    
    // check digit
    for(i = 0; i < 14; i++){
        if(p[i] >= '0' && p[i] <= '9'){
        }
        else {
            return false;
        }
    }
    
    // check year
    memcpy(sYear, p, 4);
    sYear[4] = '\0';
    iYear = atoi(sYear);
    if(iYear < 1900)
        return false;
    
    // check month
    memcpy(sDat, p+4, 2);
    sDat[2] = '\0';
    iDat = atoi(sDat);
    if(iDat <= 0 || iDat > 12)
        return false;
    
    // check day
    memcpy(sDat, p+6, 2);
    sDat[2] = '\0';
    iDat = atoi(sDat);
    if(iDat <= 0 || iDat > 31)
        return false;
    
    // check hour
    memcpy(sDat, p+8, 2);
    sDat[2] = '\0';
    iDat = atoi(sDat);
    if(iDat < 0 || iDat > 23)
        return false;
    
    // check minute
    memcpy(sDat, p+10, 2);
    sDat[2] = '\0';
    iDat = atoi(sDat);
    if(iDat < 0 || iDat > 59)
        return false;
    
    // check second
    memcpy(sDat, p+12, 2);
    sDat[2] = '\0';
    iDat = atoi(sDat);
    if(iDat < 0 || iDat > 59)
        return false;
     
     return true;   
}

// add FNSI-バグ 通信サーバ 高(#5618) end

// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
/**
* @fn char* makeTreatedDialysisReportFolderName(long dev_no, char *pdir, char *pfile, char *folder);
* @brief 治療済透析レポート格納用フォルダ/ファイル名を作成する
* @param[in]    dev_no  装置番号
* @param[in]    pdir    対象ディレクトリ
* @param[in]    pfile   対象ファイル(フォルダ名を作成する場合はNULLを指定)
* @param[out]   pfolder 作成したフォルダ/ファイル名(フルパス)
* @return なし
* @details 治療済透析レポート格納用フォルダ/ファイル名作成
*/
void makeTreatedDialysisFolderFileName(long dev_no, char *pdir, char *pfile, char *pfolder) {
    // ファイル名チェック
    if(pfile == NULL) {
        // ファイル名が指定されていない場合

        // 装置番号のフォルダ名を作成する
        sprintf(pfolder, "%s/%08lX", pdir, dev_no);
    } else {
        // ファイル名が指定されている場合

        // 装置番号のフォルダ名 + ファイル名を作成する
        char folder[50];
        makeTreatedDialysisFolderFileName(dev_no, pdir, NULL, folder);
        sprintf(pfolder, "%s/%s", folder, pfile);
    }
}
/**
* @fn char *makeTreatedDialysisReportFolder(long dev_no, char *pdir1, char *pdir2, char *path)
* @brief 治療済透析レポート格納用フォルダを作成する
* @param[in] dev_no 装置番号
* @param[in] dir1   対象ディレクトリ1 
* @param[in] dir2   対象ディレクトリ2
* @param[out] path  作成したフォルダ名(空：作成失敗)
* @return なし
* @details 治療済透析レポート格納用フォルダ取得
*/
void makeTreatedDialysisReportFolder(long dev_no, char *pdir1, char *pdir2, char *path) {
	char *pdir = NULL;

	// USB書き込みチェック
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 start
	// char *pMedia = checkMountMedia(pdir1);
	// if ( pMedia == NULL ) pMedia = pdir1;
    char *pMedia = pdir1;
    char dev[10] = {0};
    if( checkMountMedia( pdir1,  dev ) == 1 ) pMedia = dev;
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 end
	// 外部メディア書き込みチェック
	if (checkWriteMountMedia(pMedia)) {
		pdir = pdir1;
	} else {
		// SD書き込みチェック
        // #11965 2025.07.11 mod 関数修正対応 TDC米沢 start
		// char *pMedia = checkMountMedia(pdir2);
		// if ( pMedia == NULL ) pMedia = pdir2;
        pMedia = pdir2;
        dev[0] = 0;
        if( checkMountMedia( pdir2,  dev ) == 1 ) pMedia = dev;
        // #11965 2025.07.11 mod 関数修正対応 TDC米沢 end
		// 外部メディア書き込みチェック
		if (checkWriteMountMedia(pMedia)) {
			pdir = pdir2;
		}
	}
    // 書き込み先が取得できた場合
    if(pdir != NULL)
    {
        // 装置番号のフォルダを作成する
        makeTreatedDialysisFolderFileName(dev_no, pdir, NULL, path);
        if ( stat_mkdir(path) == false ) path[0] = NULL;
    }
}
/**
* @fn void makeTreatedDialysisLcdReq56FileName(long ord_no);
* @brief 治療外透析番号格納ファイル名を作成する
* @param[in]    ord_no  治療中透析番号
* @param[out]   file    作成した治療外透析番号格納ファイル名
* @return なし
* @details 治療外透析番号格納ファイル名作成
*/
void makeTreatedDialysisLcdReq56FileName(long ord_no, char *file) {
    sprintf(file, "%d_%s", ord_no, WORK_LCD_REQ56);
}
// #12302 2025.10.10 mod ログ出力追加 TDC米沢 start
// /**
// * @fn void searchTreatedDialysisFile(long dev_no, long ord_no, char *dir1, char *dir2, char *search, char *file)
// * @brief 治療済透析レポート関連ファイルを検索する
// * @param[in]    dev_no  装置番号
// * @param[in]    dir1    対象ディレクトリ1 
// * @param[in]    dir2    対象ディレクトリ2
// * @param[in]    search  検索するファイル名
// * @param[out]   file    見つかったファイル名[フルパス](空：該当なし)
// * @return なし
// * @details 治療済透析レポート関連ファイル検索
// */
// void searchTreatedDialysisFile(long dev_no, char *pdir1, char *pdir2, char *search, char *file) {
//     // 揮発領域で検索するファイル名を作成する
//     comsv_work_fpath(dev_no, search, file);
//     if (existFolderFile(file, NULL) != 1) {
//         // 該当なし

//         // 対象ディレクトリ２で検索するファイル名を作成する
//         makeTreatedDialysisFolderFileName(dev_no, pdir2, search, file);
//         if (existFolderFile(file, NULL) != 1) {
//             // 該当なし

//             // 対象ディレクトリ１で検索するファイル名を作成する
//             makeTreatedDialysisFolderFileName(dev_no, pdir1, search, file);
//             if (existFolderFile(file, NULL) != 1) {
//                 // 該当なし
//                 file[0] = NULL;
//             }
//         }
//     }
// }
// // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
/**
* @fn void searchTreatedDialysisFile(char *dev_type, char *dev_id, long dev_no, char *pdir1, char *pdir2, char *search, char *file)
* @brief 治療済透析レポート関連ファイルを検索する
* @param[in]    dev_type    装置型式
* @param[in]    dev_id      製造番号
* @param[in]    dev_no      装置番号
* @param[in]    dir1        対象ディレクトリ1 [USBを想定]
* @param[in]    dir2        対象ディレクトリ2 [SDを想定]
* @param[in]    search      検索するファイル名
* @param[out]   file        見つかったファイル名[フルパス](空：該当なし)
* @return なし
* @details 治療済透析レポート関連ファイル検索
*/
void searchTreatedDialysisFile(char *dev_type, char *dev_id, long dev_no, char *pdir1, char *pdir2, char *search, char *file) {
    char logMsg[512] = {0};

    // 揮発領域で検索するファイル名を作成する
    comsv_work_fpath(dev_no, search, file);
    if (existFolderFile(file, NULL) != 1) {
        // 該当なし

        // ログ追加
		snprintf(logMsg, sizeof(logMsg), "過去レポートファイル検索, 該当なし, (%s)", file);
		LogOutputs(NTSS_LOG_INFO, logMsg, 0, dev_type, dev_id);

        // 対象ディレクトリ２で検索するファイル名を作成する
        makeTreatedDialysisFolderFileName(dev_no, pdir2, search, file);
        if (existFolderFile(file, NULL) != 1) {
            // 該当なし

            // ログ追加
    		snprintf(logMsg, sizeof(logMsg), "過去レポートファイル検索, 該当なし, (%s)", file);
            LogOutputs(NTSS_LOG_INFO, logMsg, 0, dev_type, dev_id);

            // 対象ディレクトリ１で検索するファイル名を作成する
            makeTreatedDialysisFolderFileName(dev_no, pdir1, search, file);
            if (existFolderFile(file, NULL) != 1) {
                // 該当なし

                // ログ追加
	        	snprintf(logMsg, sizeof(logMsg), "過去レポートファイル検索, 該当なし, (%s)", file);
                LogOutputs(NTSS_LOG_INFO, logMsg, 0, dev_type, dev_id);

                file[0] = NULL;
            }
        }
    }
}
// #12302 2025.10.10 mod ログ出力追加 TDC米沢 end
