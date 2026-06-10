/**
* @file comsv_transfer.c
* @brief 画像転送処理
* @author Y.Takamura
* @date 2019/05/14
* @details 透析装置に画像転送を行う為の処理
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "ntss_comsv.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end

/**
 * @fn int comsv_bmp_post(long device_no, unsigned char *devCd, unsigned char *devId, long ordNo, short type)
 * @brief 画像転送用のイメージ（ＢＭＰ）を取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] type 画像タイプ（0:ＶＡ、1:レポート）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_bmp_post(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short type) {
    int ret, fd;
    char url[200];
    // #11946 2025.06.16 mod 重複しないダウンロードファイル名称が格納できるサイズを確保 TDC米沢 start
    // char imgFile[40];
    char imgFile[50];
    // #11946 2025.06.16 mod 重複しないダウンロードファイル名称が格納できるサイズを確保 TDC米沢 end
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char typeText[30] = {0};
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST"];
	/// edge<=ec2 [label = "HTTP STATUS / BITMAP"];
	/// @endmsc

    if ( type == 0 ) {
        // ＶＡ画像
    	sprintf(url, "%s%s", rest_device_edge_url, "/va");
        comsv_work_fpath(devNo, WORK_IMG_VA, imgFile);
        snprintf(typeText, sizeof(typeText), "ＶＡ画像");
    }
    else {
        // レポート画像
    	sprintf(url, "%s%s", rest_device_edge_url, "/dialreport");
        comsv_work_fpath(devNo, WORK_IMG_REPORT, imgFile);
        snprintf(typeText, sizeof(typeText), "レポート画像");
    }
    // #11946 2025.06.09 add ダウンロードファイル名を重複しない名称に変更する TDC米沢 start
    fd = mkstemp( imgFile );
    if ( fd != 0 ) close(fd);
    // #11946 2025.06.09 add ダウンロードファイル名を重複しない名称に変更する TDC米沢 end
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp( resFile );
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp( errFile );
    if ( fd != 0 ) close(fd);

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "画像転送用イメージ取得 (装置番号:%ld/オーダー番号:%ld/%s)", devNo, ordNo, typeText);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_bmp_post.sh \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\""
        , url
        , ordNo
        , imgFile
        , resFile
        , errFile
    );

    // RESTをコールする
    ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "画像転送用イメージ取得");
    return ret;
}

/**
 * @fn int comsv_ftp_put(long devNo, unsigned char *devCd, unsigned char *devId, char *url, short type, char *upFile) 
 * @brief 画像データ（ＶＡ、レポート）をFTPでアップロードする
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] url ホスト名（FTPサーバのIPアドレス）
 * @param[in] type 画像タイプ（0:ＶＡ、1:レポート）
 * @param[in] upFile アップロードファイル名
 * @return 0:成功, -1:エラー
 */
int comsv_ftp_put(long devNo, unsigned char *devCd, unsigned char *devId, char *url, short type, char *upFile) {
    int ret, fd;
    char folder[20];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char typeText[30] = {0};
	// シーケンス図
	/// @msc "FTP"
	/// edge [label="COMSV"],dev [label="DEVICE"];
	/// edge=>dev [label = "FTP PUT / BITMAP"];
	/// edge<=dev [label = "FTP STATUS"];
	/// @endmsc
    
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp( resFile );
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp( errFile );
    if ( fd != 0 ) close(fd);

    if ( type == 0 ) {
        // ＶＡ画像
        snprintf(typeText, sizeof(typeText), "ＶＡ画像");
    }
    else {
        // レポート画像
        snprintf(typeText, sizeof(typeText), "レポート画像");
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "FTP画像転送, (%s/%s/%s)", url, typeText, upFile);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    if ( type == 0 ) {
        // ＶＡ画像
        strcpy(folder, "VA");
    }
    else {
        // レポート画像
        strcpy(folder, "report");
    }

    // curl用文字列作成
    sprintf(
        cbuff
        , "sudo bash ./sh/comsv_ftp_put.sh \"%s\" \"GUEST\" \"GUEST\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , folder
        , upFile
        , resFile
        , errFile
    );

    // RESTをコールする
    ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "FTP画像転送");

    // アップロードファイルを削除
    //remove(upFile);

    return ret;
}

// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
///**
//* @fn void comsv_bmp_remove(long dev_no)
//* @brief ビットマップファイル削除
//* @param[in] dev_no 装置番号
//* @details ビットマップファイルを全て削除する
//*/
// void comsv_bmp_remove(long dev_no)
/**
* @fn void comsv_bmp_remove(long dev_no, unsigned char *devCd, unsigned char *devId)
* @brief ビットマップファイル削除
* @param[in] dev_no 装置番号
* @param[in] devCd  型式コード
* @param[in] devId  製造番号
* @details ビットマップファイルを全て削除する
*/
void comsv_bmp_remove(long dev_no, unsigned char *devCd, unsigned char *devId)
// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
{
    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
	// char fpath[64];
	// char buf[64];
	char fpath[128];
	char buf[128];
    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end

    // 画像ファイル
	comsv_work_fpath(dev_no, "*.bmp", fpath);
	sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
	system(buf);

    // #12302 2025.10.23 add 圧縮ファイル、REST画像添付ファイルの削除を追加 TDC米沢 start
    // 圧縮ファイル
	comsv_work_fpath(dev_no, "*.zip", fpath);
	sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
	system(buf);
    // 添付ファイル
	comsv_work_fpath(dev_no, "image_*", fpath);
	sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
	system(buf);
    // #12302 2025.10.23 add 圧縮ファイル、REST画像添付ファイルの削除を追加 TDC米沢 end

    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
    // 過去透析番号情報ファイル
	comsv_work_fpath(dev_no, "*_lcdreq56.json", fpath);
    sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
    system(buf);
	comsv_work_fpath(dev_no, "", fpath);
    sprintf(buf, "治療済透析情報と画像情報を削除, %s", fpath);
    LogOutputs(NTSS_LOG_INFO, buf, 0, devCd, devId);

    // 治療済透析レポート情報格納先フォルダ１
    // 画像ファイル
    makeTreatedDialysisFolderFileName(dev_no, configParam.TreatedDialysisReportDataDirectory, "*.bmp", fpath);
    sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
    system(buf);
    // #12302 2025.10.23 add 圧縮ファイル、REST画像添付ファイルの削除を追加 TDC米沢 start
    // 圧縮ファイル
    makeTreatedDialysisFolderFileName(dev_no, configParam.TreatedDialysisReportDataDirectory, "*.zip", fpath);
    sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
    system(buf);
    // 添付ファイル
    makeTreatedDialysisFolderFileName(dev_no, configParam.TreatedDialysisReportDataDirectory, "image_*", fpath);
	sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
	system(buf);
    // #12302 2025.10.23 add 圧縮ファイル、REST画像添付ファイルの削除を追加 TDC米沢 end
    // 過去透析番号情報ファイル
    makeTreatedDialysisFolderFileName(dev_no, configParam.TreatedDialysisReportDataDirectory, "*_lcdreq56.json", fpath);
    sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
    system(buf);
    makeTreatedDialysisFolderFileName(dev_no, configParam.TreatedDialysisReportDataDirectory, "", fpath);
    sprintf(buf, "治療済透析情報と画像情報を削除, %s", fpath);
    LogOutputs(NTSS_LOG_INFO, buf, 0, devCd, devId);

    // 治療済透析レポート情報格納先フォルダ２
    // 画像ファイル
    makeTreatedDialysisFolderFileName(dev_no, configParam.TreatedDialysisReportDataDirectory2, "*.bmp", fpath);
    sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
    system(buf);
    // #12302 2025.10.23 add 圧縮ファイル、REST画像添付ファイルの削除を追加 TDC米沢 start
    // 圧縮ファイル
    makeTreatedDialysisFolderFileName(dev_no, configParam.TreatedDialysisReportDataDirectory2, "*.zip", fpath);
    sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
    system(buf);
    // 添付ファイル
    makeTreatedDialysisFolderFileName(dev_no, configParam.TreatedDialysisReportDataDirectory2, "image_*", fpath);
    sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
    system(buf);
    // #12302 2025.10.23 add 圧縮ファイル、REST画像添付ファイルの削除を追加 TDC米沢 end
    // 過去透析番号情報ファイル
    makeTreatedDialysisFolderFileName(dev_no, configParam.TreatedDialysisReportDataDirectory2, "*_lcdreq56.json", fpath);
    sprintf(buf, "rm %s > /dev/null 2>&1", fpath);
    system(buf);
    makeTreatedDialysisFolderFileName(dev_no, configParam.TreatedDialysisReportDataDirectory2, "", fpath);
    sprintf(buf, "治療済透析情報と画像情報を削除, %s", fpath);
    LogOutputs(NTSS_LOG_INFO, buf, 0, devCd, devId);
    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
}

// #12302 2025.10.23 add 圧縮ファイルで取得 TDC米沢 start
/**
 * @fn int comsv_zip_post(long device_no, unsigned char *devCd, unsigned char *devId, long ordNo, short type)
 * @brief 画像転送用のイメージ（ＢＭＰ）の圧縮ファイルを取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] type 画像タイプ（0:ＶＡ、1:レポート）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_zip_post(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short type) {
    int ret, fd;
    char url[200];
    // #11946 2025.06.16 mod 重複しないダウンロードファイル名称が格納できるサイズを確保 TDC米沢 start
    // char imgFile[40];
    char imgFile[50];
    // #11946 2025.06.16 mod 重複しないダウンロードファイル名称が格納できるサイズを確保 TDC米沢 end
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char typeText[30] = {0};
	// シーケンス図
	/// @msc "REST API CALL"
	/// edge [label="COMSV"],ec2 [label="EC2"];
	/// edge=>ec2 [label = "HTTP POST"];
	/// edge<=ec2 [label = "HTTP STATUS / BITMAP"];
	/// @endmsc

    if ( type == 0 ) {
        // ＶＡ画像
    	sprintf(url, "%s%s", rest_device_edge_url, "/va");
        comsv_work_fpath(devNo, WORK_IMG_VA, imgFile);
        snprintf(typeText, sizeof(typeText), "ＶＡ画像");
    }
    else {
        // レポート画像
    	sprintf(url, "%s%s", rest_device_edge_url, "/dialreport");
        comsv_work_fpath(devNo, WORK_IMG_REPORT, imgFile);
        snprintf(typeText, sizeof(typeText), "レポート画像");
    }
    // #11946 2025.06.09 add ダウンロードファイル名を重複しない名称に変更する TDC米沢 start
    fd = mkstemp( imgFile );
    if ( fd != 0 ) close(fd);
    // #11946 2025.06.09 add ダウンロードファイル名を重複しない名称に変更する TDC米沢 end
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp( resFile );
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp( errFile );
    if ( fd != 0 ) close(fd);

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "画像転送用圧縮ファイル取得 (装置番号:%ld/オーダー番号:%ld/%s)", devNo, ordNo, typeText);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/comsv_zip_post.sh \"%s\" \"%ld\" \"%s\" \"%s\" \"%s\""
        , url
        , ordNo
        , imgFile
        , resFile
        , errFile
    );

    // RESTをコールする
    ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "画像転送用圧縮ファイル取得");
    return ret;
}
/**
 * @fn int comsv_unzip(unsigned char *devCd, unsigned char *devId, unsigned char *zip, unsigned char *dir, unsigned char *title)
 * @brief 圧縮ファイルを解凍する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] zip   圧縮ファイル名
 * @param[in] dir   展開先フォルダ名
 * @param[in] title ログタイトル
 * @return 0:成功, else:エラー
 */
int comsv_unzip(unsigned char *devCd, unsigned char *devId, unsigned char *zip, unsigned char *dir, unsigned char *title) {
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char typeText[30] = {0};

    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/unzip.sh \"%s\" \"%s\""
        , zip
        , dir
    );

    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    int ret = system( cbuff );

    if( WIFEXITED( ret ))
    {
        // 子プロセスが正常に終了した場合

        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS( ret );
    }

    // ログ出力
    snprintf(logMessage, sizeof(logMessage), "%s圧縮ファイル解凍%s[%d] (%s → %s)", title, (ret == 0 ? "成功" : "失敗"), ret, zip, dir);
    LogOutputs((ret == 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR) , logMessage, 0, devCd, devId);

    return ret;
}
// #12302 2025.10.23 add 圧縮ファイルで取得 TDC米沢 end
// #12353 2025.10.23 add FTP転送完了ファイルを転送 TDC米沢 start
/**
 * @fn int comsv_ftp_endfile_put(long devNo, unsigned char *devCd, unsigned char *devId, char *url)  
 * @brief FTP転送完了ファイルをFTPでアップロードする
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] url ホスト名（FTPサーバのIPアドレス）
 * @return 0:成功, else:エラー
 */
int comsv_ftp_endfile_put(long devNo, unsigned char *devCd, unsigned char *devId, char *url) {
    int ret, fd;
    char upFile[40];
    char resFile[40];
    char errFile[40];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char typeText[30] = {0};

    // FTP転送完了ファイル作成
    comsv_work_fpath(devNo, FTP_END_FILE, upFile);
    outputAppendFile(upFile, NULL, 0);
    
    comsv_work_fpath(devNo, WORK_RES_CODE, resFile);
    fd = mkstemp( resFile );
    if ( fd != 0 ) close(fd);
    comsv_work_fpath(devNo, WORK_ERR_CODE, errFile);
    fd = mkstemp( errFile );
    if ( fd != 0 ) close(fd);

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "FTP転送完了ファイル転送, (%s → %s/end/)", url, upFile);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // curl用文字列作成
    sprintf(
        cbuff
        , "sudo bash ./sh/comsv_ftp_put.sh \"%s\" \"GUEST\" \"GUEST\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        , "end"
        , upFile
        , resFile
        , errFile
    );

    // RESTをコールする
    ret = comsv_rest_exec(devCd, devId, cbuff, resFile, errFile, "FTP転送完了ファイル転送");

    // アップロードファイルを削除
    removeFileFullPath(upFile);

    return ret;
}
// #12353 2025.10.23 add FTP転送完了ファイルを転送 TDC米沢 end
