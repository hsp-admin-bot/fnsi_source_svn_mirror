
#include "ntss_update.h"

/**
 * @brief S3からファイルをダウンロードする
 *
 * @param rest ダウンロード機能を持つREST
 * @param bucket S3のバケット
 * @param filename DL対象のファイル名
 * @return true DL成功
 * @return false DL失敗
 */
bool downloadFile(unsigned char *rest, unsigned char *bucket, unsigned char *filename, unsigned char *hexFileName)
{
    unsigned char cBuff[NTSS_STR_MAX_SIZE * 2] = {0};
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    char outFile[100];
    int ret;
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *responseFile = "./tmpDlCode.txt";
    // char *errFile = "./tmpDlErrResponseCode.txt";
    char *responseFile = "/tmp/tmpDlCode.txt";
    char *errFile = "/tmp/tmpDlErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    unsigned char responseCode[255] = {0};

    // ペイロードの内容をログ出力
    snprintf(logMessage, MAX_LOG_TEXT, "ダウンロード要求, (%s/%s)", bucket, filename);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // RESTをコールする
    sprintf(
        cBuff, "./sh/ntss_download.sh \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\"", rest, bucket, filename, responseFile, errFile, hexFileName);
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cBuff);

    if (WIFEXITED(ret))
    {
        // 子プロセスが正常に終了した場合

        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS(ret);
    }
    if (readFileOneLine(responseCode, 50, responseFile) == 0)
    {
        snprintf(logMessage, MAX_LOG_TEXT, "REST 応答あり, (%s)", responseCode);
    }
    else
    {
        snprintf(logMessage, MAX_LOG_TEXT, "REST 実行システムコール応答, (%d)", ret);
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
            // エラー
            ret = 1;
        }
    }
    else
    {
        // 転送失敗エラー
        ret = 2;
    }

    if (ret > 0 && readFileOneLine(responseCode, 255, errFile) == 0)
    {
        snprintf(logMessage, MAX_LOG_TEXT, "REST 失敗応答を取得, (%s)", responseCode);
        LogResourceOutput(NTSS_LOG_ERROR, logMessage);
    }

    if (ret == 0)
    {
        // 使用したファイルの消し込み作業
        removeFileFullPath(responseFile);
        removeFileFullPath(errFile);
        return true;
    }
    return false;
}

/**
 * @brief 応答RESTに対して応答を返す
 *
 * @param rest REST
 * @param cManageNo 管理番号
 * @param status ステータス
 * @param info 付随情報
 * @return true
 * @return false
 */
bool responseCall(unsigned char *rest, unsigned char *cManageNo, unsigned char *status, unsigned char *info)
{
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *tempFileM = "./tmpUpdResM.dat";
    // char *tempFileS = "./tmpUpdResS.dat";
    // char *tempFileI = "./tmpUpdResI.dat";
    // char *sendBodyFile = "./tmpUpdResponseBody.txt";
    char *tempFileM = "/tmp/tmpUpdResM.dat";
    char *tempFileS = "/tmp/tmpUpdResS.dat";
    char *tempFileI = "/tmp/tmpUpdResI.dat";
    char *sendBodyFile = "/tmp/tmpUpdResponseBody.txt";
    unsigned char cBuff[NTSS_STR_MAX_SIZE * 2] = {0};
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    char outFile[100];
    int ret;
    // char *responseFile = "./tmpUpdResponseCode.txt";
    // char *errFile = "./tmpUpdErrResponseCode.txt";
    char *responseFile = "/tmp/tmpUpdResponseCode.txt";
    char *errFile = "/tmp/tmpUpdErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    unsigned char responseCode[255] = {0};

    // 一時ファイル作成
    outputFile(tempFileM, cManageNo, strlen(cManageNo));
    outputFile(tempFileS, status, strlen(status));
    outputFile(tempFileI, info, strlen(info));

    // ペイロードの内容をログ出力
    snprintf(logMessage, MAX_LOG_TEXT, "ファイル更新応答, (%s, %s, %s)", cManageNo, status, info);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // REST送信用BODY作成
    sprintf(
        cBuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "content" // key
        ,
        tempFileM // value
        ,
        sendBodyFile // output_file
        ,
        1 // 新規作成
    );
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cBuff);

    // REST送信用BODY作成
    sprintf(
        cBuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "status" // key
        ,
        tempFileS // value
        ,
        sendBodyFile // output_file
        ,
        0 // 追記
    );
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cBuff);

    // REST送信用BODY作成
    sprintf(
        cBuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "info" // key
        ,
        tempFileI // value
        ,
        sendBodyFile // output_file
        ,
        0 // 追記
    );
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cBuff);

    // RESTをコールする
    sprintf(
        cBuff, "./sh/post_b64.sh \"%s\" \"%s\" \"%s\" \"%s\"", rest, sendBodyFile, responseFile, errFile);
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
    /*
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cBuff);

    if (WIFEXITED(ret))
    {
        // 子プロセスが正常に終了した場合

        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS(ret);
    }
    if (readFileOneLine(responseCode, 50, responseFile) == 0)
    {
        snprintf(logMessage, MAX_LOG_TEXT, "REST 応答あり, (%s)", responseCode);
    }
    else
    {
        snprintf(logMessage, MAX_LOG_TEXT, "REST 実行システムコール応答, (%d)", ret);
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
            // エラー
            ret = 1;
        }
    }
    else
    {
        // 転送失敗エラー
        ret = 2;
    }

    if (ret > 0 && readFileOneLine(responseCode, 255, errFile) == 0)
    {
        snprintf(logMessage, MAX_LOG_TEXT, "REST 失敗応答を取得, (%s)", responseCode);
        LogResourceOutput(NTSS_LOG_ERROR, logMessage);
    }
    */
    // RESTコールして結果を取得する
    // #12003 2025.07.25 add 通信不可フラグを参照しないREST API呼び出しを可能とする TDC片口 start
    // ret = ntss_restcall("", "", cBuff, responseFile, errFile, "ファイル更新応答");
    ret = ntss_restcall_force_ex("", "", cBuff, responseFile, errFile, "ファイル更新応答", 3, 5, false);
    // #12003 2025.07.25 add 通信不可フラグを参照しないREST API呼び出しを可能とする TDC片口 end

    // 使用したファイルの消し込み作業
    removeFileFullPath(tempFileM);
    removeFileFullPath(tempFileS);
    removeFileFullPath(tempFileI);
    removeFileFullPath(sendBodyFile);

    if (ret == 0)
    {
        /*
        // 使用したファイルの消し込み作業
        removeFileFullPath(tempFileM);
        removeFileFullPath(tempFileS);
        removeFileFullPath(tempFileI);
        removeFileFullPath(sendBodyFile);
        removeFileFullPath(responseFile);
        removeFileFullPath(errFile);
        */
        return true;
    }
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
    return false;
}

/**
 * @brief ファイルのデコード
 *
 * @return true
 * @return false
 */
bool xxdFile(unsigned char *hexFileName, unsigned char *fileName)
{
    unsigned char command[512] = {0};
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    sprintf(command, "xxd -r -p %s > %s", hexFileName, fileName);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "ファイルのデコード成功 (%d) %s > %s", res, hexFileName, fileName);
            LogOutput(NTSS_LOG_INFO, logMessage);
            removeFileFullPath(hexFileName);
            return true;
        }
    }

    snprintf(logMessage, MAX_LOG_TEXT, "ファイルのデコード失敗 (%d) %s > %s", res, hexFileName, fileName);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);
    return false;
}

/**
 * @brief 圧縮ファイルの展開
 *
 * @param fileName 圧縮ファイル名
 * @param exDir 展開先ディレクトリ
 * @param password パスワード
 * @return true
 * @return false
 */
bool unzipFile(unsigned char *fileName, unsigned char *exDir, unsigned char *password)
{
    unsigned char command[512] = {0};
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // 展開先ディレクトリを削除
    sprintf(command, "rm -rf %s", exDir);
    system(command);

    sprintf(command, "unzip -P %s %s -d %s", password, fileName, exDir);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "圧縮ファイルの展開成功 (%d) %s > %s", res, fileName, exDir);
            LogOutput(NTSS_LOG_INFO, logMessage);
            removeFileFullPath(fileName);
            return true;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "圧縮ファイルの展開失敗 (%d) %s > %s", res, fileName, exDir);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}
// #12003 2026.01.05 add 圧縮ファイルの形式変更 TDC片口 start
/**
 * @brief 展開されたディレクトリから"DE_UPDATE"という固定名のファイルが含まれているディレクトリを検索し、
 * そのディレクトリを更新ファイルのルートディレクトリとして上書き用ディレクトリとして配置する
 *
 * @param searchDir ZIPファイルを展開した先
 * @param exDir 上書き用ファイル置き場
 * @return true 成功
 * @return false 失敗
 */
extern bool moveUpdateFiles(unsigned char *searchDir, unsigned char *exDir)
{
    FILE *fp1;
    unsigned char tmpStr[128] = {0};
    unsigned char dirName[128] = {0};
    unsigned char command[512] = {0};
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char tmpFileName[64] = "/tmp/update_file_dir_XXXXXX";
    unsigned char findTargetFileName[160] = {0};
    int fd = mkstemp(tmpFileName);
    if (fd != 0)
    {
        close(fd);
    }

    // 移動先ディレクトリを削除
    removeWorkDir(exDir);

    snprintf(command, 510, "find \"%s\" -name \"DE_UPDATE\" -type f -exec dirname {} \\; > %s", searchDir, tmpFileName);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "DE_UPDATEファイル検索処理成功 (%d) %s > %s", res, searchDir, tmpFileName);
            LogOutput(NTSS_LOG_INFO, logMessage);

            // ファイルパス格納ファイルオープン
            fp1 = fopen(tmpFileName, "r");
            if (fp1 != NULL)
            {
                memset(dirName, 0, sizeof(dirName));
                if (fgets(dirName, sizeof(dirName), fp1) == NULL)
                {
                    snprintf(logMessage, MAX_LOG_TEXT, "DE_UPDATEファイル検出失敗 (%d) %s > %s", res, searchDir, tmpFileName);
                    LogResourceOutput(NTSS_LOG_ERROR, logMessage);
                    remove(tmpFileName);
                    removeWorkDir(searchDir);
                    fclose(fp1);
                    return false;
                }
                fclose(fp1);
            }
            // 改行コード除去
            dirName[strlen(dirName) - 1] = 0;

            // 見つけた検索対象ファイルを削除
            snprintf(findTargetFileName, 159, "%s/DE_UPDATE", dirName);
            remove(findTargetFileName);

            // 検索対象ファイルがあったディレクトリを移動
            snprintf(command, 511, "mv -f \"%s\" \"%s\"", dirName, exDir);
            res = system(command);
            if (WIFEXITED(res))
            {
                // 正常終了
                if (0 == WEXITSTATUS(res))
                {
                    // コマンド正常終了
                    snprintf(logMessage, MAX_LOG_TEXT, "ファイル移動成功 (%d) %s > %s", res, dirName, exDir);
                    LogOutput(NTSS_LOG_INFO, logMessage);

                    remove(tmpFileName);
                    removeWorkDir(searchDir);
                    return true;
                }
            }
            snprintf(logMessage, MAX_LOG_TEXT, "ファイル移動失敗 (%d) %s > %s", res, dirName, exDir);
            LogResourceOutput(NTSS_LOG_ERROR, logMessage);

            return false;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "DE_UPDATEファイル検索処理失敗 (%d) %s > %s", res, searchDir, tmpFileName);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);
    remove(tmpFileName);
    removeWorkDir(searchDir);

    return false;
}
// #12003 2026.01.05 add 圧縮ファイルの形式変更 TDC片口 end

/**
 * @brief アップデータをバックアップ
 *
 * @return true
 * @return false
 */
bool backupMyDirUpd()
{
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};
    unsigned char updMyFile[128] = {0};
    unsigned char updMyConfigFile[128] = {0};
    unsigned char updMyVersionFile[128] = {0};
    unsigned char updBuFile[128] = {0};
    unsigned char updBuConfigFile[128] = {0};
    unsigned char updBuVersionFile[128] = {0};
    unsigned char updBuConfDir[128] = {0};
    unsigned char updBuShDir[128] = {0};
    unsigned char updBuVerDir[128] = {0};

    sprintf(updMyFile, "%s%s", "./", UPD_MY_FILE);
    sprintf(updMyConfigFile, "%s%s", "./", UPD_MY_CONFIG_FILE);
    sprintf(updMyVersionFile, "%s%s", "./", UPD_MY_VERSION_FILE);

    sprintf(updBuFile, "%s%s", BK_UPD_DIR, UPD_MY_FILE);
    sprintf(updBuConfigFile, "%s%s", BK_UPD_DIR, UPD_MY_CONFIG_FILE);
    sprintf(updBuVersionFile, "%s%s", BK_UPD_DIR, UPD_MY_VERSION_FILE);
    sprintf(updBuShDir, "%s%s", BK_UPD_DIR, "sh/");
    sprintf(updBuConfDir, "%s%s", BK_UPD_DIR, "conf/");
    sprintf(updBuVerDir, "%s%s", BK_UPD_DIR, "version/");

    removeWorkDir(BK_UPD_DIR);

    if (existFolderFile(BK_UPD_DIR, NULL) != 1)
    {
        createFolder(BK_UPD_DIR);
    }
    if (existFolderFile(updBuShDir, NULL) != 1)
    {
        createFolder(updBuShDir);
    }
    if (existFolderFile(updBuConfDir, NULL) != 1)
    {
        createFolder(updBuConfDir);
    }
    if (existFolderFile(updBuVerDir, NULL) != 1)
    {
        createFolder(updBuVerDir);
    }

    sprintf(command, "cp -f \"%s\" \"%s\"", updMyFile, updBuFile);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "ファイルバックアップ成功 (%d) %s > %s", res, updMyFile, updBuFile);
            LogOutput(NTSS_LOG_INFO, logMessage);
            // configをコピー（ない場合はcpがエラーになるかもしれんが無視）
            sprintf(command, "cp -f \"%s\" \"%s\"", updMyConfigFile, updBuConfigFile);
            res = system(command);
            if (WIFEXITED(res))
            {
                // 正常終了
                if (0 == WEXITSTATUS(res))
                {
                    snprintf(logMessage, MAX_LOG_TEXT, "ファイルバックアップ成功 (%d) %s > %s", res, updMyConfigFile, updBuConfigFile);
                    LogOutput(NTSS_LOG_INFO, logMessage);
                }
                else
                {
                    snprintf(logMessage, MAX_LOG_TEXT, "ファイルバックアップ失敗 (%d) %s > %s", res, updMyConfigFile, updBuConfigFile);
                    LogResourceOutput(NTSS_LOG_ERROR, logMessage);
                }
            }
            // versionをコピー（ない場合はcpがエラーになるかもしれんが無視）
            sprintf(command, "cp -f \"%s\" \"%s\"", updMyVersionFile, updBuVersionFile);
            res = system(command);
            if (WIFEXITED(res))
            {
                // 正常終了
                if (0 == WEXITSTATUS(res))
                {
                    snprintf(logMessage, MAX_LOG_TEXT, "ファイルバックアップ成功 (%d) %s > %s", res, updMyVersionFile, updBuVersionFile);
                    LogOutput(NTSS_LOG_INFO, logMessage);
                }
                else
                {
                    snprintf(logMessage, MAX_LOG_TEXT, "ファイルバックアップ失敗 (%d) %s > %s", res, updMyVersionFile, updBuVersionFile);
                    LogResourceOutput(NTSS_LOG_ERROR, logMessage);
                }
            }
            // shフォルダをコピー（ない場合はcpがエラーになるかもしれんが無視）
            sprintf(command, "cp -f ./sh/* %s", updBuShDir);
            res = system(command);
            if (WIFEXITED(res))
            {
                // 正常終了
                if (0 == WEXITSTATUS(res))
                {
                    snprintf(logMessage, MAX_LOG_TEXT, "ファイルバックアップ成功 (%d) ./sh/* > %s", res, updBuShDir);
                    LogOutput(NTSS_LOG_INFO, logMessage);
                }
                else
                {
                    snprintf(logMessage, MAX_LOG_TEXT, "ファイルバックアップ失敗 (%d) ./sh/* > %s", res, updBuShDir);
                    LogResourceOutput(NTSS_LOG_ERROR, logMessage);
                }
            }
            return true;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "ファイルバックアップ失敗 (%d) %s > %s", res, updMyFile, updBuFile);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

bool backupMyMainExe()
{
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};

    sprintf(command, "find -maxdepth 1 -type f -name \"*.exe\" -exec cp -f \"{}\" \"%s\" \\;", BK_MAIN_DIR);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "exeのバックアップ成功 (%d) [%s]", res, command);
            LogOutput(NTSS_LOG_INFO, logMessage);

            return true;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "exeのバックアップ失敗 (%d) [%s]", res, command);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

bool backupMyMainLocalSh()
{
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};

    sprintf(command, "find -maxdepth 1 -type f -name \"*.sh\" -exec cp -f \"{}\" %s \\;", BK_MAIN_DIR);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "shファイルのバックアップ成功 (%d) [%s]", res, command);
            LogOutput(NTSS_LOG_INFO, logMessage);

            return true;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "shファイルのバックアップ失敗 (%d) [%s]", res, command);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

bool backupMyMainSubDir(unsigned char *subdir)
{
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};

    sprintf(command, "cp -rf \"./%s\" \"%s%s\" ", subdir, BK_MAIN_DIR, subdir);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "%sフォルダのバックアップ成功 (%d) [%s]", subdir, res, command);
            LogOutput(NTSS_LOG_INFO, logMessage);

            return true;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "%sフォルダのバックアップ失敗 (%d) [%s]", subdir, res, command);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

/**
 * @brief メインアプリをバックアップ
 *
 * @return true
 * @return false
 */
bool backupMyDirMain()
{
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};
    unsigned char updMyFile[256] = {0};
    unsigned char updMyConfigFile[256] = {0};
    unsigned char updMyVersionFile[256] = {0};
    unsigned char updMySh[256] = {0};

    sprintf(updMyFile, "%s%s", BK_MAIN_DIR, UPD_MY_FILE);
    sprintf(updMyConfigFile, "%s%s", BK_MAIN_DIR, UPD_MY_CONFIG_FILE);
    sprintf(updMyVersionFile, "%s%s", BK_MAIN_DIR, UPD_MY_VERSION_FILE);

    removeWorkDir(BK_MAIN_DIR);

    if (existFolderFile(BK_MAIN_DIR, NULL) != 1)
    {
        createFolder(BK_MAIN_DIR);
    }

    if (backupMyMainExe())
    {
        // exeバックアップ成功

        // *.shのバックアップ
        backupMyMainLocalSh();
        // ntss_updater.exeをバックアップから削除
        removeFileFullPath(updMyFile);

        if (backupMyMainSubDir("conf"))
        {
            // ntss_updater.confをコピー対象外とするために削除
            removeFileFullPath(updMyConfigFile);
        }
        if (backupMyMainSubDir("version"))
        {
            // updater_version.datをコピー対象外とするために削除
            removeFileFullPath(updMyVersionFile);
        }
        backupMyMainSubDir("sh");
        backupMyMainSubDir("mst");

        return true;
    }

    return false;
}

/**
 * @brief 自分自身のフォルダのバックアップを作成
 *
 * @return true
 * @return false
 */
bool backupMyDir(unsigned char *kind)
{
    if (strcmp(kind, "0") == 0)
    {
        // ntss_updater.exe以外の更新
        return backupMyDirMain();
    }
    else if (strcmp(kind, "1") == 0)
    {
        // ntss_updater.exeの更新
        return backupMyDirUpd();
    }
    else if (strcmp(kind, "2") == 0)
    {
        // すべての更新
        if (backupMyDirMain() == false)
        {
            return false;
        }
        if (backupMyDirUpd() == false)
        {
            return false;
        }
        return true;
    }

    return false;
}

/**
 * @brief 更新用ファイルから自分に上書き
 *
 * @param kind 更新識別子 0:ntss_updater.exe以外の更新 1: ntss_updater.exeの更新
 * @param updDir ZIPを展開したファイルの置き場
 * @return true
 * @return false
 */
uint8_t updateMyDir(unsigned char *kind, unsigned char *updDir)
{

    if (strcmp(kind, "0") == 0)
    {
        // ntss_updater.exe以外の更新
        return updateMainApps(updDir);
    }
    else if (strcmp(kind, "1") == 0)
    {
        // ntss_updater.exeの更新
        return updateUpdateApp(updDir);
    }
    else if (strcmp(kind, "2") == 0)
    {
        // すべての更新
        return updateAllApps(updDir);
    }

    // 未設定識別子なのでfalseを返す
    return false;
}

bool updateFile(unsigned char *targetFile, unsigned char *fromDir, unsigned char *toDir)
{
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[1028] = {0};
    unsigned char fromFile[512] = {0};
    unsigned char toFile[512] = {0};

    sprintf(fromFile, "%s%s", fromDir, targetFile);
    sprintf(toFile, "%s%s", toDir, targetFile);
    sprintf(command, "mv -f \"%s\" \"%s\"", fromFile, toFile);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "ファイル上書き成功 (%d) %s > %s", res, fromFile, toFile);
            LogOutput(NTSS_LOG_INFO, logMessage);
            return true;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "ファイル上書き失敗 (%d) %s > %s", res, fromFile, toFile);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

/**
 * @brief ファイル更新
 *
 * @param updDir 更新ファイルの場所
 * @return uint8_t 1:成功 0:失敗
 */
uint8_t updateMainApps(unsigned char *updDir)
{
    FILE *fp1;
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};
    unsigned char name[512] = {0};
    unsigned char updMyFile[512] = {0};
    unsigned char updMyConfigFile[512] = {0};
    unsigned char updMyVersionFile[256] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *updTargetListFile = "../updateTargetFileList.list";
    unsigned char *updTargetListFile = "/tmp/updateTargetFileList.list";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    uint8_t ret = 1;

    // updater.exeと.confをコピー対象外とするために削除
    sprintf(updMyFile, "%s%s", updDir, UPD_MY_FILE);
    sprintf(updMyConfigFile, "%s%s", updDir, UPD_MY_CONFIG_FILE);
    sprintf(updMyVersionFile, "%s%s", updDir, UPD_MY_VERSION_FILE);
    removeFileFullPath(updMyFile);
    removeFileFullPath(updMyConfigFile);
    removeFileFullPath(updMyVersionFile);

    sprintf(command, "find %s -type f > %s", updDir, updTargetListFile);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "更新対象ファイル一覧取得成功 (%d) %s > %s", res, updDir, updTargetListFile);
            LogOutput(NTSS_LOG_INFO, logMessage);

            // ファイル一覧オープン
            fp1 = fopen(updTargetListFile, "r");
            if (fp1 != NULL)
            {
                for (;;)
                {
                    memset(name, 0, sizeof(name));
                    if (fgets(name, sizeof(name), fp1) == NULL)
                    {
                        break;
                    }
                    name[strlen(name) - 1] = 0;

                    // ファイルパスの先頭から展開ルートフォルダへのパスを削除
                    strcpy(name, &name[strlen(updDir)]);
                    if (updateFile(name, updDir, "./") == false)
                    {
                        ret = 0;
                        break;
                    }
                }
                fclose(fp1);
            }
            remove(updTargetListFile);

            return ret;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "更新対象ファイル一覧取得失敗 (%d) %s > %s", res, updDir, updTargetListFile);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return 0;
}

/**
 * @brief アップデータ更新
 *
 * @param updDir 更新ファイルの場所
 * @return uint8_t 2:成功 0:失敗
 */
uint8_t updateUpdateApp(unsigned char *updDir)
{

    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};
    unsigned char updMyFile[256] = {0};
    unsigned char updMyConfigFile[256] = {0};
    unsigned char updMyVersionFile[256] = {0};
    unsigned char updMySh[256] = {0};

    sprintf(updMyFile, "%s%s", updDir, UPD_MY_FILE);
    sprintf(updMyConfigFile, "%s%s", updDir, UPD_MY_CONFIG_FILE);
    sprintf(updMyVersionFile, "%s%s", updDir, UPD_MY_VERSION_FILE);
    sprintf(updMySh, "%s%s", updDir, "sh/*");

    sprintf(command, "mv -f \"%s\" ./", updMyFile);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "ファイル上書き成功 (%d) %s > %s", res, updMyFile, "./");
            LogOutput(NTSS_LOG_INFO, logMessage);
            // configを移動（ない場合はエラーになるかもしれんが無視）
            sprintf(command, "mv -f \"%s\" ./conf/", updMyConfigFile);
            system(command);
            // versionを移動（ない場合はエラーになるかもしれんが無視）
            sprintf(command, "mv -f \"%s\" ./version/", updMyVersionFile);
            system(command);
            // shを移動（ない場合はエラーになるかもしれんが無視）
            sprintf(command, "mv -f \"%s\" ./sh/", updMySh);
            system(command);
            return 2;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "ファイル上書き失敗 (%d) %s > %s", res, updMyFile, "./");
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return 0;
}

/**
 * @brief 全アプリ更新
 *
 * @param updDir 更新ファイルの場所
 * @return uint8_t 0:失敗 1:メインアプリ更新 2:アップデータ更新 4:
 */
uint8_t updateAllApps(unsigned char *updDir)
{
    FILE *fp1;
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};
    unsigned char name[512] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *updTargetListFile = "../updateTargetAllFileList.list";
    unsigned char *updTargetListFile = "/tmp/updateTargetAllFileList.list";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    uint8_t ret = 0;
    bool hasApp = false;
    bool hasUpd = false;
    bool hasLogger = false;

    sprintf(command, "find %s -type f > %s", updDir, updTargetListFile);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "更新対象ファイル一覧取得成功 (%d) %s > %s", res, updDir, updTargetListFile);
            LogOutput(NTSS_LOG_INFO, logMessage);

            // ファイル一覧オープン
            fp1 = fopen(updTargetListFile, "r");
            if (fp1 != NULL)
            {
                for (;;)
                {
                    memset(name, 0, sizeof(name));
                    if (fgets(name, sizeof(name), fp1) == NULL)
                    {
                        break;
                    }
                    name[strlen(name) - 1] = 0;

                    // ファイルパスの先頭から展開ルートフォルダへのパスを削除
                    strcpy(name, &name[strlen(updDir)]);
                    if (updateFile(name, updDir, "./") == false)
                    {
                        ret = 0;
                        break;
                    }

                    // 更新ファイルの情報を取得
                    if (strstr(name, "logger") != NULL)
                    {
                        // ロガーアプリが更新
                        hasLogger = true;
                    }
                    else if (strstr(name, "updater") != NULL)
                    {
                        // アップデータアプリ関係が更新
                        hasUpd = true;
                    }
                    else
                    {
                        // それ以外のファイル -> メインアプリ関係が更新
                        hasApp = true;
                    }
                }
                fclose(fp1);
            }
            remove(updTargetListFile);

            if (hasApp == true)
            {
                ret += 1;
            }
            if (hasUpd == true)
            {
                ret += 2;
            }
            if (hasLogger == true)
            {
                ret += 4;
            }

            return ret;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "更新対象ファイル一覧取得失敗 (%d) %s > %s", res, updDir, updTargetListFile);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return 0;
}

bool updateMyConf(unsigned char *updMyFile)
{

    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};

    sprintf(command, "mv -f \"%s\" ./conf/", updMyFile);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "ファイル上書き成功 (%d) %s > %s", res, updMyFile, "./conf/");
            LogOutput(NTSS_LOG_INFO, logMessage);
            return true;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "ファイル上書き失敗 (%d) %s > %s", res, updMyFile, "./conf/");
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

bool chmodExeFile()
{

    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};
    sprintf(command, "chmod 775 ./*.exe ./sh/*.sh");
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "ファイル権限変更成功 (%d) {%s} ", res, command);
            LogOutput(NTSS_LOG_INFO, logMessage);
            return true;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "ファイル権限変更失敗 (%d) {%s} ", res, command);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

/**
 * @brief 更新用フォルダの削除
 *
 * @return true
 * @return false
 */
bool removeWorkDir(unsigned char *dirPath)
{
    unsigned char command[512] = {0};
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    sprintf(command, "rm -rf \"%s\"", dirPath);
    system(command);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "作業フォルダの削除成功 (%d) {%s} ", res, command);
            LogOutput(NTSS_LOG_INFO, logMessage);
            return true;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "作業フォルダの削除失敗 (%d) {%s} ", res, command);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

/**
 * @brief 応答を返す
 *
 * @param seqNo シーケンスNo
 * @param responseCode 応答コード："1":受信成功 "2":処理成功 "-1":他の処理中 "-2":エラー
 * @param message 付加情報
 * @return true
 * @return false
 */
bool sendResponse(unsigned char *seqNo, unsigned char *responseCode, unsigned char *message)
{

    unsigned char responseRest[512] = {0};
    unsigned char cPayload[1050] = {0};
    ConfigParameter_t conf = getConfigParameter();

    sprintf(responseRest, "%s/%s", conf.awsHostUrl, API_UPDATER_RESPONSE);
    sprintf(cPayload, "{%s}", message);

    return responseCall(responseRest, seqNo, responseCode, cPayload);
}

/**
 * @brief アプリの更新処理
 *
 * @param cPayload 受信命令データ内容
 * @return true
 * @return false
 */
bool updateApplication(unsigned char *cPayload)
{
    // 電文 シーケンスNo{TAB}識別子{TAB}バケット{TAB}ファイル名{TAB}予約時間
    // 識別子・・・0: ntss_updater.exe以外の更新 1: ntss_updater.exeの更新

    unsigned char seqNo[20] = {0};
    unsigned char kind[10] = {0};
    unsigned char *hexFileName = "hexDlFile.txt";
    unsigned char bucket[255] = {0};
    unsigned char fileName[256] = {0};
    unsigned char plan[20] = {0};
    unsigned char downloadRest[512] = {0};
    unsigned char hexFilePath[512] = {0};
    unsigned char dlFilePath[512] = {0};
    unsigned char updateFolderPath[512] = {0};
    unsigned char information[1024] = {0};
    unsigned char informationErr[1024] = {0};
    bool hasPlan = true;
    uint8_t updateResult;
    // #12003 2025.07.25 add ログ強化 TDC片口 start
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 end

    resetDlFolder();

    ConfigParameter_t conf = getConfigParameter();
    int useFolderIdx = getUseDlFolder();

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "シーケンスNo取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // 識別子
    if (get_text(2, cPayload, kind) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "識別子取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // バケット
    if (get_text(3, cPayload, bucket) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "バケット取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // ファイル名
    if (get_text(4, cPayload, fileName) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイル名取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // 予約時刻
    if (get_text(5, cPayload, plan) == 0)
    {
        // なし: 即時実行
        hasPlan = false;
    }

    // API作成
    sprintf(downloadRest, "%s/%s", conf.awsHostUrl, API_DOWNLOAD);

    // information
    snprintf(information, 1023, "\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":\"%s\"", "updater_info", cPayload, "download_bucket", bucket, "download_file", fileName);

    // 作業パスを設定
    if (useFolderIdx < 0)
    {
        sprintf(hexFilePath, "../%s", hexFileName);
        sprintf(dlFilePath, "../%s", fileName);
        sprintf(updateFolderPath, "../%s", UPD_DIR);
    }
    else
    {
        sprintf(hexFilePath, "%s%s", conf.dlFolder[useFolderIdx], hexFileName);
        sprintf(dlFilePath, "%s%s", conf.dlFolder[useFolderIdx], fileName);
        sprintf(updateFolderPath, "%s%s", conf.dlFolder[useFolderIdx], UPD_DIR);
    }

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 2.更新データをダウンロード
    if (downloadFile(downloadRest, bucket, fileName, hexFilePath) == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "ダウンロード失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ダウンロード失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 3.更新データをデコードして展開
    if (xxdFile(hexFilePath, dlFilePath) == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "ファイルデコード失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイルデコード失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // #12003 2026.01.05 mod 圧縮ファイルの形式変更 TDC片口 start
    // if (unzipFile(dlFilePath, updateFolderPath, conf.zipPassword) == false)
    // {
    //     // 失敗
    //     snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "圧縮ファイル解凍失敗");
    //     sendResponse(seqNo, "-2", informationErr);
    //     // #12003 2025.07.25 add ログ強化 TDC片口 start
    //     snprintf(logMessage, MAX_LOG_TEXT, "圧縮ファイル解凍失敗 {%s} ", information);
    //     LogOutput(NTSS_LOG_ERROR, logMessage);
    //     // #12003 2025.07.25 add ログ強化 TDC片口 end
    //     return false;
    // }

    unsigned char tmpPath[128] = "/tmp/dl_dir";
    if (unzipFile(dlFilePath, tmpPath, conf.zipPassword) == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "圧縮ファイル解凍失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "圧縮ファイル解凍失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    if (moveUpdateFiles(tmpPath, updateFolderPath) == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "更新対象ファイル取得失敗");
        sendResponse(seqNo, "-2", informationErr);
        snprintf(logMessage, MAX_LOG_TEXT, "更新対象ファイル取得失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        return false;
    }
    // #12003 2026.01.05 mod 圧縮ファイルの形式変更 TDC片口 end

    if (hasPlan == true)
    {
        // 予約あり
        if (outputPlanInfoFile(PLAN_FILE, plan, updateFolderPath, seqNo, kind, information) == false)
        {
            // 予約ファイル書き出し失敗
            snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "予約ファイル保存失敗");
            sendResponse(seqNo, "-2", informationErr);
            // #12003 2025.07.25 add ログ強化 TDC片口 start
            snprintf(logMessage, MAX_LOG_TEXT, "予約ファイル保存失敗 {%s} ", information);
            LogOutput(NTSS_LOG_ERROR, logMessage);
            // #12003 2025.07.25 add ログ強化 TDC片口 end
            return false;
        }
        overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);

        // 予約時刻登録通知
        if (callPlanInfoPostApi(seqNo, plan) == false)
        {
            // 予約時刻登録失敗
            snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "予約時刻DB登録失敗");
            snprintf(information, 1023, "%s", informationErr);
            // #12003 2025.07.25 add ログ強化 TDC片口 start
            snprintf(logMessage, MAX_LOG_TEXT, "予約時刻DB登録失敗 {%s} ", information);
            LogOutput(NTSS_LOG_ERROR, logMessage);
            // #12003 2025.07.25 add ログ強化 TDC片口 end
        }
        // 予約処理完了応答
        if (sendResponse(seqNo, "3", information) == false)
        {
            // 失敗
            // #12003 2025.07.25 add ログ強化 TDC片口 start
            snprintf(logMessage, MAX_LOG_TEXT, "予約処理完了応答失敗 {%s} ", information);
            LogOutput(NTSS_LOG_ERROR, logMessage);
            // #12003 2025.07.25 add ログ強化 TDC片口 end
            return false;
        }
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "更新処理予約完了 {%s} ", plan);
        LogOutput(NTSS_LOG_INFO, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return true;
    }

    // 4.現行フォルダをコピー
    if (backupMyDir(kind) == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "ファイルバックアップ失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイルバックアップ失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // 5.自フォルダに更新データを反映
    updateResult = updateMyDir(kind, updateFolderPath);
    if (updateResult == 0)
    {
        // 失敗
        chmodExeFile();
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "更新データ反映失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "更新データ反映失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    if (chmodExeFile() == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "ファイル権限変更失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイル権限変更失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    removeWorkDir(updateFolderPath);

    overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);

    // 6.処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "処理完了応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 7.サービスの再起動
    if (strcmp(kind, "0") == 0)
    {
        return serviceReboot();
    }
    else if (strcmp(kind, "1") == 0)
    {
        return meReboot();
    }
    else if (strcmp(kind, "2") == 0)
    {
        return allReboot(updateResult) > 0;
    }
    return true;
}

/**
 * @brief 一時フォルダにバックアップファイルをコピー
 *
 * @param kind 更新識別子 0:ntss_updater.exe以外の復元 1: ntss_updater.exeの復元
 * @param updDir 一時ファイルの置き場
 * @return true
 * @return false
 */
bool cpRestoreDir(unsigned char *kind, unsigned char *tmpDir)
{

    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};

    removeWorkDir(tmpDir);

    if (existFolderFile(tmpDir, NULL) != 1)
    {
        createFolder(tmpDir);
    }

    if (strcmp(kind, "0") == 0)
    {
        // ntss_updater.exe以外の復元
        sprintf(command, "cp -rf %s%s \"%s\" ", BK_MAIN_DIR, "*", tmpDir);
    }
    else if (strcmp(kind, "1") == 0)
    {
        // ntss_updater.exeの復元
        sprintf(command, "cp -rf %s%s \"%s\" ", BK_UPD_DIR, "*", tmpDir);
    }
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "%sフォルダのコピー成功 (%d) [%s]", tmpDir, res, command);
            LogOutput(NTSS_LOG_INFO, logMessage);

            return true;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "%sフォルダのコピー失敗 (%d) [%s]", tmpDir, res, command);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

bool restoreApplication(unsigned char *cPayload)
{
    // 電文 シーケンスNo

    unsigned char seqNo[20] = {0};
    unsigned char restoreFolderPath[512] = {0};
    unsigned char information[1024] = {0};
    unsigned char informationErr[1024] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 start
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 end

    resetDlFolder();

    ConfigParameter_t conf = getConfigParameter();
    int useFolderIdx = getUseDlFolder();

    // 作業パスを設定
    if (useFolderIdx < 0)
    {
        sprintf(restoreFolderPath, "../%s", RESTORE_DIR_MAIN);
    }
    else
    {
        sprintf(restoreFolderPath, "%s%s", conf.dlFolder[useFolderIdx], RESTORE_DIR_MAIN);
    }

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "シーケンスNo取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // information
    snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", cPayload);

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "受信応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 2.一時フォルダにバックアップデータをコピー
    if (cpRestoreDir("0", restoreFolderPath) == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "バックアップファイルのコピー失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "バックアップファイルのコピー失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 3.自フォルダにバックアップデータを復元
    if (updateMyDir("0", restoreFolderPath) == 0)
    {
        // 失敗
        chmodExeFile();
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "バックアップファイルの復元失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "バックアップファイルの復元失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    if (chmodExeFile() == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "ファイル権限変更失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイル権限変更失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    removeWorkDir(restoreFolderPath);

    overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);

    // 4.処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "処理完了応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 5.OSの再起動
    return serviceReboot();
}

bool serviceStopOrder(unsigned char *cPayload)
{
    // 電文 シーケンスNo
    unsigned char seqNo[20] = {0};
    unsigned char information[1024] = {0};
    unsigned char informationErr[1024] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 start
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 end

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "シーケンスNo取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // information
    snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", cPayload);

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "受信応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    if (serviceStop() == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "NTSSサービス停止コマンド実行失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "NTSSサービス停止コマンド実行失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "処理完了応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    return true;
}

bool serviceStop()
{
    unsigned char logMessage[100] = {0};

    int res = system("service ntss stop &");
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, 100, "NTSSサービス停止コマンド実行 (%d)", res);
            LogOutput(NTSS_LOG_INFO, logMessage);
            return true;
        }
    }
    system("service ntss restart &");

    return false;
}

bool serviceStartOrder(unsigned char *cPayload)
{
    // 電文 シーケンスNo
    unsigned char seqNo[20] = {0};
    unsigned char information[1024] = {0};
    unsigned char informationErr[1024] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 start
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 end

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "シーケンスNo取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // information
    snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", cPayload);

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "受信応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    if (serviceStart() == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "NTSSサービス起動コマンド実行失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "NTSSサービス起動コマンド実行失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "処理完了応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    return true;
}

bool serviceStart()
{
    unsigned char logMessage[100] = {0};

    int res = system("service ntss start &");
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, 100, "NTSSサービス起動コマンド実行 (%d)", res);
            LogOutput(NTSS_LOG_INFO, logMessage);
            return true;
        }
    }
    system("service ntss restart &");

    return false;
}

bool serviceRebootOrder(unsigned char *cPayload)
{
    // 電文 シーケンスNo
    unsigned char seqNo[20] = {0};
    unsigned char information[1024] = {0};
    unsigned char informationErr[1024] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 start
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 end

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "シーケンスNo取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // information
    snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", cPayload);

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    if (serviceReboot() == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "NTSSサービス再起動コマンド実行失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "NTSSサービス再起動コマンド実行失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "処理完了応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    return true;
}

bool serviceReboot()
{
    unsigned char logMessage[100] = {0};

    int res = system("service ntss restart &");
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, 100, "NTSSサービス再起動コマンド実行 (%d)", res);
            LogOutput(NTSS_LOG_INFO, logMessage);

            // バージョン情報通知
            versionPost();

            return true;
        }
    }
    system("service ntss restart &");

    return false;
}

bool meRebootOrder(unsigned char *cPayload)
{
    // 電文 シーケンスNo
    unsigned char seqNo[20] = {0};
    unsigned char information[1024] = {0};
    unsigned char informationErr[1024] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 start
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 end

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "シーケンスNo取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // information
    snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", cPayload);

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    if (meReboot() == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "NTSSアップデータサービス再起動コマンド実行失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "NTSSアップデータサービス再起動コマンド実行失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "処理完了応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    return true;
}

bool meReboot()
{
    unsigned char logMessage[100] = {0};
    pid_t pid = getpid();
    char command[255] = {0};

    sprintf(command, "kill -1 %d &", pid);

    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, 100, "NTSSアップデータサービス再起動コマンド実行 (%d)", res);
            LogOutput(NTSS_LOG_INFO, logMessage);

            // バージョン情報通知
            versionPost();
            return true;
        }
    }

    return false;
}

bool osRebootOrder(unsigned char *cPayload)
{
    // 電文 シーケンスNo
    unsigned char seqNo[20] = {0};
    unsigned char information[1024] = {0};
    unsigned char informationErr[1024] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 start
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 end

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "シーケンスNo取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // information
    snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", cPayload);

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    if (osReboot() == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "OS再起動コマンド実行失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "OS再起動コマンド実行失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "処理完了応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    return true;
}

bool osReboot()
{
    unsigned char logMessage[100] = {0};
    system("service ntss stop &");
    int res = system("(sleep 10s;reboot) &");
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, 100, "再起動コマンド実行 (%d)", res);
            LogOutput(NTSS_LOG_INFO, logMessage);
            return true;
        }
    }
    system("service ntss restart &");

    return false;
}

bool confFileUpdate(unsigned char *cPayload)
{
    // 電文 シーケンスNo{TAB}バケット{TAB}ファイル名

    unsigned char seqNo[20] = {0};
    unsigned char bucket[255] = {0};
    unsigned char fileName[2024] = {0};
    unsigned char downloadRest[512] = {0};
    unsigned char hexFilePath[512] = {0};
    unsigned char dlFilePath[512] = {0};
    unsigned char *hexFileName = "hexDlConfFile.txt";
    unsigned char information[1024] = {0};
    unsigned char informationErr[1024] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 start
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 end

    resetDlFolder();

    ConfigParameter_t conf = getConfigParameter();
    int useFolderIdx = getUseDlFolder();

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "シーケンスNo取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // バケット
    if (get_text(2, cPayload, bucket) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "バケット取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // ファイル名
    if (get_text(3, cPayload, fileName) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイル名取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // information
    snprintf(information, 1023, "\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":\"%s\"", "updater_info", cPayload, "download_bucket", bucket, "download_file", fileName);

    // API作成
    sprintf(downloadRest, "%s/%s", conf.awsHostUrl, API_DOWNLOAD);

    // 作業パスを設定
    if (useFolderIdx < 0)
    {
        sprintf(hexFilePath, "../%s", hexFileName);
        sprintf(dlFilePath, "../%s", fileName);
    }
    else
    {
        sprintf(hexFilePath, "%s%s", conf.dlFolder[useFolderIdx], hexFileName);
        sprintf(dlFilePath, "%s%s", conf.dlFolder[useFolderIdx], fileName);
    }

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 2.更新データをダウンロード
    if (downloadFile(downloadRest, bucket, fileName, hexFilePath) == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "ファイルダウンロード失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイルダウンロード失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 3.更新データをデコード
    if (xxdFile(hexFilePath, dlFilePath) == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "ファイルデコード失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイルデコード失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 4.現行フォルダをアップロード
    // if(uploadNTSSConf(&conf, useFolderIdx) != 1){
    //     // 失敗
    //     return false;
    // }

    // 5.自フォルダに更新データを反映
    if (updateMyConf(dlFilePath) == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "更新データ反映失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "更新データ反映失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);

    // 6.処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "処理完了応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 7.OSの再起動
    // return osReboot();
    return true;
}

/**
 * @brief confファイルアップロード
 *
 * @return true
 * @return false
 */
bool confFileGather(unsigned char *cPayload)
{
    unsigned char seqNo[20] = {0};
    unsigned char information[1024] = {0};
    unsigned char informationErr[1024] = {0};
    unsigned char cNow[20];
    FILE *fp;
    time_t tim;
    struct tm tmc;
    int16_t funcRes = 0;
    // #12003 2025.07.25 add ログ強化 TDC片口 start
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 end

    resetDlFolder();

    ConfigParameter_t conf = getConfigParameter();
    int useFolderIdx = getUseDlFolder();

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "シーケンスNo取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // 現在時刻取得
    time(&tim);
    localtime_r(&tim, &tmc);
    // 当日文字列作成
    sprintf(
        cNow, "%04d%02d%02d%02d%02d%02d.ZIP", tmc.tm_year + 1900, tmc.tm_mon + 1, tmc.tm_mday, tmc.tm_hour, tmc.tm_min, tmc.tm_sec);
    // フォルダのアップロード先
    unsigned char cUploadPath[NTSS_STR_MAX_SIZE];
    sprintf(
        cUploadPath, conf.uploadConfS3Path, conf.facilityCode, conf.deviceNo);
    // information
    snprintf(information, 1023, "\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":\"%s\"", "updater_info", cPayload, "upload_bucket", cUploadPath, "upload_file", cNow);
    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    funcRes = uploadNTSSConf(&conf, useFolderIdx, cNow);
    if (funcRes == -1)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "ファイル圧縮失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイル圧縮失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    else if (funcRes == -2)
    {
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "ファイルアップロード失敗");
        sendResponse(seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイルアップロード失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "処理完了応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    return true;
}

bool sendLogGatherSignal(unsigned char *cPayload)
{
    unsigned char seqNo[20] = {0};
    unsigned char command[512] = {0};
    unsigned char charPid[10] = {0};
    long pid_l = 0;
    int pid = 0;
    unsigned char cBuff[NTSS_STR_MAX_SIZE * 2] = {0};
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *responseFile = "./tmpPID.txt";
    char *responseFile = "/tmp/tmpPID.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    bool ret = false;
    unsigned char information[1024] = {0};
    unsigned char informationErr[1024] = {0};
    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "シーケンスNo取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    setLogGatherSeqNo(seqNo);

    snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", cPayload);
    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        // return false;
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, MAX_LOG_TEXT, "ログファイルアップロード要求");
    LogOutput(NTSS_LOG_INFO, logMessage);

    // RESTをコールする
    sprintf(cBuff, "./sh/find_pid.sh \"%s\" \"%s\"", LOGGER_NAME, responseFile);
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    system(cBuff);

    if (readFileOneLine(charPid, 10, responseFile) == 0)
    {
        pid_l = strtol(charPid, NULL, 10);
        if (pid_l != 0 && errno != ERANGE)
        {
            pid = (int)pid_l;
            snprintf(logMessage, MAX_LOG_TEXT, "ログファイルアップロード要求シグナル送信: PID: %d", pid);
            LogOutput(NTSS_LOG_INFO, logMessage);
            setIsJobRunningPid(pid);
            kill(pid, SIG_LOG_GATHER);
            ret = true;
        }
        else
        {
            snprintf(logMessage, MAX_LOG_TEXT, "ロガーPID取得失敗: 取得PID: %ld", pid_l);
            LogOutput(NTSS_LOG_ERROR, logMessage);
            snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", logMessage);
            sendResponse(seqNo, "-2", informationErr);
            ret = false;
        }
    }
    else
    {
        snprintf(logMessage, MAX_LOG_TEXT, "ロガーPIDが見つかりませんでした");
        LogOutput(NTSS_LOG_ERROR, logMessage);
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", logMessage);
        sendResponse(seqNo, "-2", informationErr);
        ret = false;
    }

    removeFileFullPath(responseFile);

    return ret;
}

bool checkPlanUpdate()
{
    PlanParameter_t planParam = {0};
    unsigned char msg[512] = {0};
    struct tm planTm;
    time_t localTime;

    if (existFolderFile(PLAN_FILE, NULL) != 1)
    {
        // ファイルなし:予定なし
        return true;
    }

    if (readPlanInfoFile(
            PLAN_FILE,
            planParam.planDateTime,
            planParam.updateFolderPath,
            planParam.seqNo,
            planParam.kind,
            planParam.information) == false)
    {
        removeFileFullPath(PLAN_FILE);
        return false;
    }

    // 予定日チェック
    memset(&planTm, 0, sizeof(planTm));
    sscanf(planParam.planDateTime, "%4d%2d%2d%2d%2d%2d", &planTm.tm_year, &planTm.tm_mon, &planTm.tm_mday, &planTm.tm_hour, &planTm.tm_min, &planTm.tm_sec);
    planTm.tm_year -= 1900;
    planTm.tm_mon -= 1;
    /* 現在時刻の取得 */
    time(&localTime);

    if (localTime < mktime(&planTm))
    {
        // まだ予定日時ではない
        return true;
    }
    sprintf(msg, "更新予定日時になりました:[%s]", planParam.planDateTime);
    LogOutput(NTSS_LOG_INFO, msg);

    removeFileFullPath(PLAN_FILE);

    return planUpdateApplication(&planParam);
}

/**
 * @brief スケジュールに合わせて取得済みの更新ファイルを適用する
 *
 * @param planParam 更新用パラメータ
 * @return true 成功
 * @return false 失敗
 */
bool planUpdateApplication(PlanParameter_t *planParam)
{
    unsigned char informationErr[1075] = {0};
    uint8_t updateResult;
    // #12003 2025.07.25 add ログ強化 TDC片口 start
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 end

    // 4.現行フォルダをコピー
    if (backupMyDir(planParam->kind) == false)
    {
        // 失敗
        snprintf(informationErr, 1074, "%s,\"%s\":\"%s\"", planParam->information, "message", "ファイルバックアップ失敗");
        sendResponse(planParam->seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイルバックアップ失敗 {%s} ", planParam->information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // 5.自フォルダに更新データを反映
    updateResult = updateMyDir(planParam->kind, planParam->updateFolderPath);
    if (updateResult == 0)
    {
        // 失敗
        chmodExeFile();
        snprintf(informationErr, 1074, "%s,\"%s\":\"%s\"", planParam->information, "message", "更新データ反映失敗");
        sendResponse(planParam->seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "更新データ反映失敗 {%s} ", planParam->information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    if (chmodExeFile() == false)
    {
        // 失敗
        snprintf(informationErr, 1074, "%s,\"%s\":\"%s\"", planParam->information, "message", "ファイル権限変更失敗");
        sendResponse(planParam->seqNo, "-2", informationErr);
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "ファイル権限変更失敗 {%s} ", planParam->information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    removeWorkDir(planParam->updateFolderPath);

    overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);

    // 予約完了（削除）通知
    if (callPlanInfoPostApi("", "") == false)
    {
        // 予約時刻DB削除失敗
    }
    // 6.処理完了応答
    if (sendResponse(planParam->seqNo, "2", planParam->information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "処理完了応答失敗 {%s} ", planParam->information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    // 7.サービスの再起動
    if (strcmp(planParam->kind, "0") == 0)
    {
        return serviceReboot();
    }
    else if (strcmp(planParam->kind, "1") == 0)
    {
        return meReboot();
    }
    else if (strcmp(planParam->kind, "2") == 0)
    {
        return allReboot(updateResult) > 0;
    }
    return true;
}

bool loggerReboot()
{
    unsigned char logMessage[100] = {0};

    int res = system("service ntss-logger restart &");
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, 100, "NTSSロガー再起動コマンド実行 (%d)", res);
            LogOutput(NTSS_LOG_INFO, logMessage);
            // バージョン情報通知
            versionPost();
            return true;
        }
    }
    system("service ntss-logger restart &");

    return false;
}

/**
 * @brief 対象サービスリブート
 * @param targets 0x01: メインアプリ 0x02: アップデータ 0x04: ロガー
 *
 * @return uint8_t 1:成功 else:以下の足し算 -1:メイン失敗 -2:アップデータ失敗 -4:ロガー失敗
 */
uint8_t allReboot(uint8_t targets)
{
    uint8_t ret = 1;
    if (targets & 0x01)
    {
        if (serviceReboot() == false)
        {
            ret = -1;
        }
    }
    // #12003 2026.01.05 mod ロガーアプリの再起動が行われない不具合 TDC片口 start
    // if (targets & 0x02)
    // {
    //     if (meReboot() == false)
    //     {
    //         if (ret > 0)
    //         {
    //             ret = 0;
    //         }
    //         ret -= 2;
    //     }
    // }
    // if (targets & 0x04)
    // {
    //     if (loggerReboot() == false)
    //     {
    //         if (ret > 0)
    //         {
    //             ret = 0;
    //         }
    //         ret -= 4;
    //     }
    // }
    if (targets & 0x04)
    {
        if (loggerReboot() == false)
        {
            if (ret > 0)
            {
                ret = 0;
            }
            ret -= 4;
        }
    }
    if (targets & 0x02)
    {
        if (meReboot() == false)
        {
            if (ret > 0)
            {
                ret = 0;
            }
            ret -= 2;
        }
    }
    // #12003 2026.01.05 mod ロガーアプリの再起動が行われない不具合 TDC片口 end
    return ret;
}
/**
 * @brief 予定キャンセル
 *
 * @return true 成功
 * @return false 失敗
 */
bool planCancel(unsigned char *cPayload)
{
    // 電文 シーケンスNo
    unsigned char seqNo[20] = {0};
    unsigned char information[1024] = {0};
    unsigned char informationErr[1024] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 start
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #12003 2025.07.25 add ログ強化 TDC片口 end

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "シーケンスNo取得失敗 {%s} ", cPayload);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }
    // information
    snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", cPayload);

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    if (existFolderFile(PLAN_FILE, NULL) == 1)
    {
        // ファイルあり
        // 予約削除
        if (removeFileFullPath(PLAN_FILE) == false)
        {
            // 失敗
            snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "予約削除失敗");
            sendResponse(seqNo, "-2", informationErr);
            // #12003 2025.07.25 add ログ強化 TDC片口 start
            snprintf(logMessage, MAX_LOG_TEXT, "予約削除失敗 {%s} ", information);
            LogOutput(NTSS_LOG_ERROR, logMessage);
            // #12003 2025.07.25 add ログ強化 TDC片口 end
            return false;
        }
    }

    // 予約削除通知
    if (callPlanInfoPostApi("", "") == false)
    {
        // 予約時刻登録失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "予約時刻DB削除失敗");
        snprintf(information, 1023, "%s", informationErr);
    }
    // 処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        // #12003 2025.07.25 add ログ強化 TDC片口 start
        snprintf(logMessage, MAX_LOG_TEXT, "処理完了応答失敗 {%s} ", information);
        LogOutput(NTSS_LOG_ERROR, logMessage);
        // #12003 2025.07.25 add ログ強化 TDC片口 end
        return false;
    }

    return true;
}

// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
/**
 * @brief 予定ファイル出力
 * @param filePath 出力先ファイルのフルパス
 * @param planDateTime 予定yyyymmddhhmmss
 * @param updateFolderPath 更新用ファイル保存フォルダ
 * @param seqNo シーケンスNo
 * @param kind 更新対象
 * @param information 受信電文
 *
 */
bool outputPlanInfoFile(
    unsigned char *filePath,
    unsigned char *planDateTime,
    unsigned char *updateFolderPath,
    unsigned char *seqNo,
    unsigned char *kind,
    unsigned char *information)
{
    if (outputFile(filePath, planDateTime, strlen(planDateTime)) != 1)
    {
        return false;
    }
    if (outputAppendFile(filePath, "\n", strlen("\n")) != 1)
    {
        return false;
    }
    if (outputAppendFile(filePath, updateFolderPath, strlen(updateFolderPath)) != 1)
    {
        return false;
    }
    if (outputAppendFile(filePath, "\n", strlen("\n")) != 1)
    {
        return false;
    }
    if (outputAppendFile(filePath, seqNo, strlen(seqNo)) != 1)
    {
        return false;
    }
    if (outputAppendFile(filePath, "\n", strlen("\n")) != 1)
    {
        return false;
    }
    if (outputAppendFile(filePath, kind, strlen(kind)) != 1)
    {
        return false;
    }
    if (outputAppendFile(filePath, "\n", strlen("\n")) != 1)
    {
        return false;
    }
    if (outputAppendFile(filePath, information, strlen(information)) != 1)
    {
        return false;
    }
    if (outputAppendFile(filePath, "\n", strlen("\n")) != 1)
    {
        return false;
    }
    return true;
}

/**
 * @brief 予定ファイル読み込み
 * @param filePath 読み込みファイルのフルパス
 * @param planDateTime 予定yyyymmddhhmmss
 * @param updateFolderPath 更新用ファイル保存フォルダ
 * @param seqNo シーケンスNo
 * @param kind 更新対象
 * @param information 受信電文
 *
 */
bool readPlanInfoFile(
    unsigned char *filePath,
    unsigned char *planDateTime,
    unsigned char *updateFolderPath,
    unsigned char *seqNo,
    unsigned char *kind,
    unsigned char *information)
{
    FILE *fin;
    unsigned char msg[256] = {0};

    if ((fin = fopen(filePath, "r")) == NULL)
    {
        sprintf(msg, "ファイルを開けません:[%s]", filePath);
        LogResourceOutput(NTSS_LOG_ERROR, msg);
        return false;
    }

    if (fgets(planDateTime, MAX_DATASIZE, fin) == NULL)
    {
        /* EOF */
        fclose(fin);
        return false;
    }
    // 余計な改行コード削除
    removeLastLf(planDateTime);

    if (fgets(updateFolderPath, MAX_DATASIZE, fin) == NULL)
    {
        /* EOF */
        fclose(fin);
        sprintf(msg, "更新ファイルパスの取得に失敗しました:[%s]", filePath);
        LogResourceOutput(NTSS_LOG_ERROR, msg);
        return false;
    }
    // 余計な改行コード削除
    removeLastLf(updateFolderPath);

    if (fgets(seqNo, MAX_DATASIZE, fin) == NULL)
    {
        sprintf(msg, "シーケンスの取得に失敗しました:[%s]", filePath);
        LogResourceOutput(NTSS_LOG_ERROR, msg);
    }
    // 余計な改行コード削除
    removeLastLf(seqNo);

    if (fgets(kind, MAX_DATASIZE, fin) == NULL)
    {
        /* EOF */
        sprintf(msg, "種別の取得に失敗しました:[%s]", filePath);
        LogResourceOutput(NTSS_LOG_ERROR, msg);
    }
    // 余計な改行コード削除
    removeLastLf(kind);

    if (fgets(information, MAX_DATASIZE, fin) == NULL)
    {
        /* EOF */
        sprintf(msg, "電文の取得に失敗しました:[%s]", filePath);
        LogResourceOutput(NTSS_LOG_ERROR, msg);
    }
    // 余計な改行コード削除
    removeLastLf(information);

    // close
    fclose(fin);

    return true;
}
// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
