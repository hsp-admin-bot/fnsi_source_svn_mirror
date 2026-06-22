#include "ntss_properties.h"

/**
 * @brief プロセスの存在確認
 * 
 * @param pid プロセスID
 * @return bool 
 */
bool exist_process(pid_t pid)
{
    int r = kill(pid, 0);
    if (r == 0)
    {
        // pid は存在する
        return true;
    }
    if (EPERM == errno)
    {
        // そのプロセスにシグナルを送る権限がない・・・存在すると見なす
        return true;
    }

    // pid は存在しない
    return false;
}

//! 処理中フラグ
jobStatus_t _is_job_running = {0};
bool getIsJobRunning()
{
    int status = 0;
    if (_is_job_running.jobPId > 0)
    {
        if (exist_process(_is_job_running.jobPId) == false)
        {
            // ジョブを実行しているプロセスがすでに存在しない
            _is_job_running.isRunning = false;
            _is_job_running.jobPId = -1;
        }
    }
    return _is_job_running.isRunning;
}
void setIsJobRunning(bool value, int pId)
{
    _is_job_running.isRunning = value;
    _is_job_running.jobPId = pId;
}
void setIsJobRunningValue(bool value)
{
    _is_job_running.isRunning = value;
}
void setIsJobRunningPid(pid_t pId)
{
    _is_job_running.jobPId = pId;
}

//! WS死活応答有無フラグ
bool _is_response_ok = false;
bool getIsResponseOk()
{
    return _is_response_ok;
}
void setIsResponseOk(bool value)
{
    _is_response_ok = value;
}

//! 実行状態
RunningParameter_t _runningParameter = {0};

RunningParameter_t getRunningParameter()
{
    return _runningParameter;
}
void setRunningParameter(bool isRunning, bool isRcvSignal, u_char *message)
{
    _runningParameter.isRunning = isRunning;
    _runningParameter.isRcvSignal = isRcvSignal;
    sprintf(_runningParameter.exitMessage, "%s", message);
}

int _use_dl_folder = 0;
int getUseDlFolder()
{
    return _use_dl_folder;
}
void setUseDlFolder(int value)
{
    _use_dl_folder = value;
}
u_char _log_gather_seq_no[20] = {0};
u_char *getLogGatherSeqNo()
{
    return _log_gather_seq_no;
}
void setLogGatherSeqNo(u_char *seqNo)
{
    sprintf(_log_gather_seq_no, "%s", seqNo);
}


/**
 * @brief ダウンロードフォルダの設定
 *
 */
void resetDlFolder()
{
	ConfigParameter_t configParam = getConfigParameter();
	int useIndex = -1;
	unsigned long long freesize = 0;
	unsigned long long tempFreesize = 0;
	int i = 0;
	u_char sampleFile[150] = {0};
	for (i = 0; i < 3; i++)
	{
		if (existFolderFile(configParam.dlFolder[i], NULL) != 1)
		{
			if (createFolder(configParam.dlFolder[i]) != 1)
			{
				// ディレクトリがなく、作成もできない
				continue;
			}
		}
		if (existFolderInFiles(configParam.dlFolder[i]) == 1)
		{
			// フォルダ内にファイルがある場合は削除
			if (deleteFolderInFiles(configParam.dlFolder[i]) != 1)
			{
				// 削除失敗：readonlyになっている可能性
				continue;
			}
		}
		else 
		{
			snprintf(sampleFile, 150, "%sdummy", configParam.dlFolder[i]);
			if (outputFile(sampleFile, "test", 5) == 1)
			{
				// フォルダ内にファイルが作成できた場合は削除
				if (deleteFolderInFiles(configParam.dlFolder[i]) != 1)
				{
					// 削除失敗：readonlyになっている可能性
					continue;
				}
			}
			else
			{
				// フォルダ内にファイルが作成できなかった：readonlyになっている可能性
				continue;
			}
		}

		tempFreesize = getFreeSize(configParam.dlFolder[i]);
		if (freesize < tempFreesize)
		{
			// 空き容量が一番大きいフォルダをダウンロードフォルダとして使用する
			useIndex = i;
			freesize = tempFreesize;
		}
	}

	setUseDlFolder(useIndex);
}