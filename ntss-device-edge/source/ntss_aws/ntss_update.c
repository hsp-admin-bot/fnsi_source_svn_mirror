
#include "ntss_update.h"

/**
 * @brief 応答RESTに対して応答を返す
 * 
 * @param rest REST
 * @param cPayload 応答内容
 * @param payLoadLen 応答内容の文字列長
 * @return true 
 * @return false 
 */
bool responseCall(u_char *rest, u_char *cManageNo, u_char *status, u_char *info)
{
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *tempFileM = "./tmpMUpdResM.dat";
    // char *tempFileS = "./tmpMUpdResS.dat";
    // char *tempFileI = "./tmpMUpdResI.dat";
    // char *sendBodyFile = "./tmpMUpdResponseBody.txt";
    char *tempFileM = "/tmp/tmpMUpdResM.dat";
    char *tempFileS = "/tmp/tmpMUpdResS.dat";
    char *tempFileI = "/tmp/tmpMUpdResI.dat";
    char *sendBodyFile = "/tmp/tmpMUpdResponseBody.txt";
    unsigned char cbuff[NTSS_STR_MAX_SIZE * 2] = {0};
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    char outFile[100];
    int ret;
    // char *responseFile = "./tmpMUpdResponseCode.txt";
    // char *errFile = "./tmpMUpdErrResponseCode.txt";
    char *responseFile = "/tmp/tmpMUpdResponseCode.txt";
    char *errFile = "/tmp/tmpMUpdErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //unsigned char responseCode[255] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end

    // 一時ファイル作成
    outputFile(tempFileM, cManageNo, strlen(cManageNo));
    outputFile(tempFileS, status, strlen(status));
    outputFile(tempFileI, info, strlen(info));

    // ペイロードの内容をログ出力
    snprintf(logMessage, MAX_LOG_TEXT, "ファイル更新応答, (%s, %s, %s)", cManageNo, status, info);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // REST送信用BODY作成
    sprintf(
        cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "content" // key
        ,
        tempFileM // value
        ,
        sendBodyFile // output_file
        ,
        1 // 新規作成
    );
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cbuff);

    // REST送信用BODY作成
    sprintf(
        cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "status" // key
        ,
        tempFileS // value
        ,
        sendBodyFile // output_file
        ,
        0 // 追記
    );
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cbuff);

    // REST送信用BODY作成
    sprintf(
        cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "info" // key
        ,
        tempFileI // value
        ,
        sendBodyFile // output_file
        ,
        0 // 追記
    );
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cbuff);

    // RESTをコールする
    sprintf(
        cbuff, "./sh/post_b64.sh \"%s\" \"%s\" \"%s\" \"%s\"", rest, sendBodyFile, responseFile, errFile);
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
    /*
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
    ret = ntss_restcall("", "", cbuff, responseFile, errFile, "ファイル更新応答");

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
bool xxdFile(u_char *hexFileName, u_char *fileName)
{
    u_char command[512] = {0};
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
bool unzipFile(u_char *fileName, u_char *exDir, u_char *password)
{
    u_char command[512] = {0};
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

/**
 * @brief アップデータをバックアップ
 * 
 * @return true 
 * @return false 
 */
bool backupMyDirUpd()
{
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    u_char command[512] = {0};
    u_char updMyFile[128] = {0};
    u_char updMyConfigFile[128] = {0};
    u_char updMyVersionFile[128] = {0};
    u_char updBuFile[128] = {0};
    u_char updBuConfigFile[128] = {0};
    u_char updBuVersionFile[128] = {0};
    u_char updBuConfDir[128] = {0};
    u_char updBuShDir[128] = {0};
    u_char updBuVerDir[128] = {0};

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
    u_char command[512] = {0};

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
    u_char command[512] = {0};

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

bool backupMyMainSubDir(u_char *subdir)
{
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    u_char command[512] = {0};

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
    u_char command[512] = {0};
    u_char updMyFile[256] = {0};
    u_char updMyConfigFile[256] = {0};
    u_char updMyVersionFile[256] = {0};
    u_char updMySh[256] = {0};

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
bool backupMyDir(u_char *kind)
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
bool updateMyDir(u_char *kind, u_char *updDir)
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

    // 未設定識別子なのでfalseを返す
    return false;
}

bool updateFile(u_char *targetFile, u_char *fromDir, u_char *toDir)
{
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    u_char command[1028] = {0};
    u_char fromFile[512] = {0};
    u_char toFile[512] = {0};

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

bool updateMainApps(u_char *updDir)
{
    FILE *fp1;
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    u_char command[512] = {0};
    u_char name[512] = {0};
    u_char updMyFile[512] = {0};
    u_char updMyConfigFile[512] = {0};
    u_char updMyVersionFile[256] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *updTargetListFile = "../updateTargetFileList.list";
    u_char *updTargetListFile = "/tmp/updateTargetFileList.list";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    bool ret = true;

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
                        break;
                    name[strlen(name) - 1] = 0;

                    // ファイルパスの先頭から展開ルートフォルダへのパスを削除
                    strcpy(name, &name[strlen(updDir)]);
                    if (updateFile(name, updDir, "./") == false)
                    {
                        ret = false;
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

    return false;
}

bool updateUpdateApp(u_char *updDir)
{

    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    u_char command[512] = {0};
    u_char updMyFile[256] = {0};
    u_char updMyConfigFile[256] = {0};
    u_char updMyVersionFile[256] = {0};
    u_char updMySh[256] = {0};

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
            return true;
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "ファイル上書き失敗 (%d) %s > %s", res, updMyFile, "./");
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return false;
}

bool chmodExeFile()
{

    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    u_char command[512] = {0};
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
bool removeWorkDir(u_char *dirPath)
{
    u_char command[512] = {0};
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
 * @param responseCode 応答コード："1":受信成功 "2":更新処理成功 "-1":他の処理中
 * @return true 
 * @return false 
 */
bool sendResponse(u_char *seqNo, u_char *responseCode, u_char *message)
{

    u_char responseRest[512] = {0};
    u_char cPayload[512] = {0};
    ConfigParameter_t conf = getConfigParameter();

    sprintf(responseRest, "%s/%s", conf.awsHostUrl, API_UPDATER_RESPONSE);
    sprintf(cPayload, "{%s}", message);

    return responseCall(responseRest, seqNo, responseCode, cPayload);
}

/**
 * @brief 一時フォルダにバックアップファイルをコピー
 * 
 * @param kind 更新識別子 0:ntss_updater.exe以外の復元 1: ntss_updater.exeの復元
 * @param updDir 一時ファイルの置き場
 * @return true 
 * @return false 
 */
bool cpRestoreDir(u_char *kind, u_char *tmpDir)
{

    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    u_char command[512] = {0};

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

bool restoreApplication(u_char *cPayload)
{
    // 電文 シーケンスNo

    u_char seqNo[20] = {0};
    u_char *kind = "1";

    ConfigParameter_t conf = getConfigParameter();
    u_char restoreFolderPath[512] = {0};
    u_char information[1024] = {0};
    u_char informationErr[1024] = {0};

    // 作業パスを設定
    sprintf(restoreFolderPath, "../%s", RESTORE_DIR_UPD);

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        return false;
    }
    // information
    snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", cPayload);

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        return false;
    }

    // 2.一時フォルダにバックアップデータをコピー
    if (cpRestoreDir(kind, restoreFolderPath) == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "バックアップファイルのコピー失敗");
        sendResponse(seqNo, "-2", informationErr);
        return false;
    }

    // 3.自フォルダにバックアップデータを復元
    if (updateMyDir(kind, restoreFolderPath) == false)
    {
        // 失敗
        chmodExeFile();
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "バックアップファイルの復元失敗");
        sendResponse(seqNo, "-2", informationErr);
        return false;
    }
    if (chmodExeFile() == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "ファイル権限変更失敗");
        sendResponse(seqNo, "-2", informationErr);
        return false;
    }
    removeWorkDir(restoreFolderPath);

    overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);

    // 4.処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        return false;
    }

    // 5.OSの再起動
    return serviceReboot();
}

bool serviceRebootOrder(u_char *cPayload)
{
    // 電文 シーケンスNo
    u_char seqNo[20] = {0};
    u_char information[1024] = {0};
    u_char informationErr[1024] = {0};

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        return false;
    }
    // information
    snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", cPayload);

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        return false;
    }

    if (serviceReboot() == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "NTSSサービス再起動コマンド実行失敗");
        sendResponse(seqNo, "-2", informationErr);
        return false;
    }

    // 処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
        return false;
    }

    return true;
}

bool serviceReboot()
{
    unsigned char logMessage[100] = {0};

    int res = system("service ntss-updater restart &");
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, 100, "NTSSアップデータサービス再起動コマンド実行 (%d)", res);
            LogOutput(NTSS_LOG_INFO, logMessage);
            return true;
        }
    }
    system("service ntss-updater restart &");

    return false;
}

bool osRebootOrder(u_char *cPayload)
{
    // 電文 シーケンスNo
    u_char seqNo[20] = {0};
    u_char information[1024] = {0};
    u_char informationErr[1024] = {0};

    // シーケンスNo
    if (get_text(1, cPayload, seqNo) == 0)
    {
        // なし
        return false;
    }
    // information
    snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", cPayload);

    // 1.受信応答
    if (sendResponse(seqNo, "1", information) == false)
    {
        // 失敗
        return false;
    }

    if (osReboot() == false)
    {
        // 失敗
        snprintf(informationErr, 1023, "%s,\"%s\":\"%s\"", information, "message", "OS再起動コマンド実行失敗");
        sendResponse(seqNo, "-2", informationErr);
        return false;
    }

    // 処理完了応答
    if (sendResponse(seqNo, "2", information) == false)
    {
        // 失敗
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
