/**
* @file comsv_work_data.h
* @brief 作業データ関連ヘッダー
* @author Y.Takamura
* @date 2019/05/14
*/

/// @name 作業データ用フォルダ・ファイル定義
//@{
#define WORK_DATA_PATH	    "./data"	            ///< 作業データ用フォルダ
// #8731 2023.05.17 add 一時ファイルの保存先を/tmp/下にする TDC片口 start
#define WORK_TMP_DATA_PATH	    "/tmp/comsv_data"	    ///< テンポラリデータ用フォルダ
// #8731 2023.05.17 add 一時ファイルの保存先を/tmp/下にする TDC片口 end
#define WORK_COMMON_PATH	"COMMON"	            ///< 共通データフォルダ
#define WORK_COMSV_SET	    "comsv_set.json"	    ///< 通信サーバ設定用
#define WORK_COMSV_CHECK    "comsv_check.json"	    ///< チェックリストマスタ用
#define WORK_COMSV_EXAM     "comsv_exam.json"	    ///< 検査項目マスタ用
#define WORK_COMSV_USER 	"comsv_user.json"	    ///< 仮想端末（処置者）用
#define WORK_COMSV_TREAT 	"comsv_treat.json"	    ///< 仮想端末（愁訴処置）用
#define WORK_COMSV_STATUS 	"comsv_status.json"	    ///< 装置ステータス一括更新用
#define WORK_DEV_STATE      "dev_state.json"	    ///< 装置状態用
#define WORK_DEV_COND       "dev_cond.json"	        ///< 設定値情報用
#define WORK_DEV_NPAT       "dev_npat.json" 	    ///< 次患者情報用
#define WORK_DEV_MONI       "dev_moni.json" 	    ///< モニタ情報用
#define WORK_PAT_HOST       "pat_host.json" 	    ///< 患者ホスト報知定義用
#define WORK_LCD_REQ32      "lcdreq32.json" 	    ///< 仮想端末（酸素吸入）用
#define WORK_LCD_REQ33      "lcdreq33.json" 	    ///< 仮想端末（検査結果）用
#define WORK_LCD_REQ36      "lcdreq36.json" 	    ///< 仮想端末（ログ）用
#define WORK_LCD_REQ38      "lcdreq38.json" 	    ///< 仮想端末（体重トレンド）用
#define WORK_LCD_REQ40      "lcdreq40.json" 	    ///< 仮想端末（透析日報）用
#define WORK_LCD_REQ41      "lcdreq41.json" 	    ///< 仮想端末（投与薬剤）用
#define WORK_LCD_REQ42      "lcdreq42.json" 	    ///< 仮想端末（抗凝固剤）用
#define WORK_LCD_REQ44      "lcdreq44.json" 	    ///< 仮想端末（禁忌）用
#define WORK_LCD_REQ45      "lcdreq45.json" 	    ///< 仮想端末（メモ）用
#define WORK_LCD_REQ51      "lcdreq51.json" 	    ///< 仮想端末（穿刺／回収／担当）用
#define WORK_LCD_REQ52      "lcdreq52.json" 	    ///< 仮想端末（指示／特記）用
#define WORK_LCD_REQ53      "lcdreq53.json" 	    ///< 仮想端末（CTRトレンド）用
#define WORK_LCD_REQ54      "lcdreq54_no\%d.json" 	///< 仮想端末（チェックリスト）用
#define WORK_LCD_REQ56      "lcdreq56.json"         ///< レポート画像直近オーダ用
#define WORK_LCD_CASH       "lcdcash.json" 	        ///< 仮想端末データキャッシュ用
// #11946 2025.06.09 mod ダウンロードファイル名を重複しない名称に変更する TDC米沢 start
// #define WORK_IMG_VA         "image_va"              ///< ＶＡ画像取得用
// #define WORK_IMG_REPORT     "image_report"          ///< レポート画像取得用
#define WORK_IMG_VA         "image_va_XXXXXX"       ///< ＶＡ画像取得用
#define WORK_IMG_REPORT     "image_report_XXXXXX"   ///< レポート画像取得用
// #11946 2025.06.09 mod ダウンロードファイル名を重複しない名称に変更する TDC米沢 end
#define WORK_RES_CODE       "ResCode_XXXXXX" 	    ///< レスポンスコード用
#define WORK_ERR_CODE       "ErrCode_XXXXXX" 	    ///< エラーコード用
// add AWSとDEの通信断からの復旧 高 start
// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
// #define WORK_FAIL_PATH	    "./commFail"	        ///< 作業データ用フォルダ
// #define WORK_FAIL_DATA_PATH	 "./commFailData"	    ///< 作業データ用フォルダ
#define WORK_FAIL_PATH	    "commFail"	        ///< 作業データ用フォルダ
#define WORK_FAIL_DATA_PATH	 "commFailData"	    ///< 作業データ用フォルダ
// #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
// add AWSとDEの通信断からの復旧 高 end
//@}

// add FNSI-バグ 通信サーバ 高 start
#define WORK_DEV_FAIL_DATA_PATH "commDevFailData" ///< 作業データ用フォルダ
#define WORK_DEV_ORDNO       "dev_ordno.json" 	  ///< 患者情報用
// add FNSI-バグ 通信サーバ 高 end

/**
* @fn int comsv_work_mkdir()
* @brief 作業データ用フォルダ作成
* @return int 0:成功 -1:失敗
* @details 作業データ用フォルダを作成する
*/ 
extern int comsv_work_mkdir();

/**
* @fn int comsv_work_mkdir_dev(long dev_no)
* @brief 作業データ用装置番号フォルダ作成
* @param[in] dev_no 装置番号
* @return int 0:成功 -1:失敗
* @details 作業データ用装置番号フォルダを作成する
*/ 
extern int comsv_work_mkdir_dev(long dev_no);

/**
* @fn char *comsv_work_fpath(long dev_no, char *name, char *fpath)
* @brief 作業データ用ファイル名作成
* @param[in] dev_no 装置番号
* @param[in] name 対象ファイル名
* @param[out] fpath 作成したファイルパス名
* @details 作業データ用ファイル名を作成する
*/ 
extern void comsv_work_fpath(long dev_no, char *name, char *fpath);

// add AWSとDEの通信断からの復旧 高 start
/**
* @fn int comsv_work_mkdir_commfail()
* @brief 作業データ用フォルダ作成
* @return int 0:成功 -1:失敗
* @details 作業データ用フォルダを作成する
*/ 
extern int comsv_work_mkdir_commfail();

/**
* @fn comsv_work_fpath_commfail(char *fpath)
* @brief 作業データ用ファイル名作成
* @param[out] fpath 作成したファイルパス名
* @details 作業データ用ファイル名を作成する
*/ 
extern void comsv_work_fpath_commfail(char *fpath);

/**
* @fn comsv_work_fpath_commFailData(char *fpath)
* @brief 作業データ用ファイル名作成
* @param[out] fpath 作成したファイルパス名
* @details 作業データ用ファイル名を作成する
*/ 
extern void comsv_work_fpath_commFailData(char *fpath);

// add AWSとDEの通信断からの復旧 高 end

// add FNSI-バグ 通信サーバ 高(#5618) start
/**
* @fn int comsv_work_mkdir_dev_commfail()
* @brief 作業データ用フォルダ作成
* @param[in] dev_no 装置番号
* @return int 0:成功 -1:失敗
* @details 作業データ用フォルダを作成する
*/ 
int comsv_work_mkdir_dev_commfail(long dev_no);

/**
* @fn comsv_work_fpath_dev_commfail(char *fpath)
* @brief 作業データ用ファイル名作成
* @param[in] dev_no 装置番号
* @param[out] fpath 作成したファイルパス名
* @details 作業データ用ファイル名を作成する
*/ 
void comsv_work_fpath_dev_commfail(long dev_no, char *fpath);

/**
 * @brief 更新用フォルダの削除
 * 
 * @return true 
 * @return false 
 */
bool removeWorkDir(u_char *dirPath);

/**
 * @brief COPY用フォルダの
 * 
 * @return true 
 * @return false 
 */
bool copyWorkDir(u_char *s_dirPath, u_char *d_dirPath);

/**
 * @brief check date
 * 
 * @return true 
 * @return false 
 */
bool is_valid_date(unsigned char * p);

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
void makeTreatedDialysisFolderFileName(long dev_no, char *pdir, char *pfile, char *pfolder);
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
void makeTreatedDialysisReportFolder(long dev_no, char *pdir1, char *pdir2, char *path);
/**
* @fn void makeTreatedDialysisLcdReq56FileName(long ord_no);
* @brief 治療外透析番号格納ファイル名を作成する
* @param[in]    ord_no  治療中透析番号
* @param[out]   file    作成した治療外透析番号格納ファイル名
* @return なし
* @details 治療外透析番号格納ファイル名作成
*/
void makeTreatedDialysisLcdReq56FileName(long ord_no, char *file);
// #12302 2025.10.10 mod ログ出力追加 TDC米沢 start
// /**
// * @fn void *searchTreatedDialysisFile(long dev_no, long ord_no, char *dir1, char *dir2, char *search, char *file)
// * @brief 治療済透析レポート関連ファイルを検索する
// * @param[in]    dev_no  装置番号
// * @param[in]    dir1    対象ディレクトリ1 
// * @param[in]    dir2    対象ディレクトリ2
// * @param[in]    search  検索するファイル名
// * @param[out]   file    見つかったファイル名[フルパス](空：該当なし)
// * @return なし
// * @details 治療済透析レポート関連ファイル検索
// */
// void searchTreatedDialysisFile(long dev_no, char *dir1, char *dir2, char *search, char *file);
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
void searchTreatedDialysisFile(char *dev_type, char *dev_id, long dev_no, char *pdir1, char *pdir2, char *search, char *file);
// #12302 2025.10.10 mod ログ出力追加 TDC米沢 end
