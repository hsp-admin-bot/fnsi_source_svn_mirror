/**
* @file timelib.c
* @brief 時間／BCDデータ変換関数
* @author Y.Takamura
* @date	2017/08/07
* @details 時間／BCDデータ変換用の関数ライブラリ
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/**
* @fn int time_str(time_t timc, char *date, char *time, int flg)
* @brief 日付文字列変換
* @param[in] timc time_t
* @param[out] *date 日付文字列(9999/99/99)
* @param[out] *time 時刻文字列(99:99(:99))
* @param[in] flg bit0==0:time="99:99" bit0==1:time="99:99:99" bit1==0:date="9999/99/99" bit1==1:date="9999/99/99 (XX)"
* @return int 0:成功 -1:失敗
* @details time_tを文字列("yyyy/mm/dd","hh:mm:ss")に変換
*/
int time_str(time_t timc, char *date, char *time, int flg)
{
    struct tm *tmc;
    static char *week[] = {" (日)"," (月)"," (火)"," (水)"," (木)"," (金)"," (土)"," (  )"};

    if ( !timc ) {
        strcpy(date, "    /  /  ");
        if ( flg&2 ) {
            strcat(date, week[7]);
        }
        if ( flg ) {
            strcpy(time, "  :  :  ");
        }
        else {
            strcpy(time, "  :  ");
        }
        return (-1);
    }
    tmc = localtime(&timc);
    sprintf(date, "%04d/%02d/%02d", 1900+tmc->tm_year, tmc->tm_mon+1, tmc->tm_mday);
    if ( flg&2 ) {
        if ( tmc->tm_wday < 0 || tmc->tm_wday > 6 ) {
            tmc->tm_wday = 7;
        }
        strcat(date, week[tmc->tm_wday]);
    }
    if ( flg&1 ) {
        sprintf(time, "%02d:%02d:%02d", tmc->tm_hour, tmc->tm_min, tmc->tm_sec);
    }
    else {
        sprintf(time, "%02d:%02d", tmc->tm_hour, tmc->tm_min);
    }
    return (0);
}

/**
* @fn int str_time(char *date, char *time, time_t *timc, int flg)
* @brief 文字列日付変換
* @param[in] *date 日付文字列(9999/99/99)
* @param[in] *time 時刻文字列(99:99(:99))
* @param[out] *timc time_t
* @param[in] flg 0:time="99:99" 1:time="99:99:99"
* @return int 0:成功 -1:失敗
* @details 文字列("yyyy/mm/dd","hh:mm:ss")をtime_tに変換
*/
int str_time(char *date, char *time, time_t *timc, int flg)
{
	struct tm tmc;
	int ret = 0;
	char buf[10];

	buf[4] = 0;
	memcpy(buf, date, 4);		/* 年 */
	tmc.tm_year = atoi(buf) - 1900;
	buf[2] = 0;
	memcpy(buf, date+5, 2);		/* 月 */
	tmc.tm_mon = atoi(buf) - 1;
	memcpy(buf, date+8, 2);		/* 日 */
	tmc.tm_mday = atoi(buf);
	memcpy(buf, time, 2);		/* 時 */
	tmc.tm_hour = atoi(buf);
	memcpy(buf, time+3, 2);		/* 分 */
	tmc.tm_min = atoi(buf);
	tmc.tm_sec = 0;
	if ( flg ) {
		memcpy(buf, time+6, 2);	/* 秒 */
		tmc.tm_sec = atoi(buf);
	}
	tmc.tm_isdst = -1;

	*timc = mktime(&tmc);
	if ( *timc == -1 ) {
		ret = -1;
	}
	return(ret);
}


/**
* @fn void bcd_time(char *bcd, time_t *timc)
* @brief BCD日付変換
* @param[in] bcd bcd値
* @param[out] *timc time_t
* @details BCDをtime_tに変換
*/
void bcd_time(char *bcd, time_t *timc)
{
    struct tm tmc;
    long bin;
    extern void bcdtobin(char *bcd, int keta, long *bin);

    bcdtobin(bcd, 4, &bin);
    tmc.tm_year = bin - 1900;
    bcdtobin(bcd+2, 2, &bin);
    tmc.tm_mon = bin - 1;
    bcdtobin(bcd+3, 2, &bin);
    tmc.tm_mday = bin;
    bcdtobin(bcd+4, 2, &bin);
    tmc.tm_hour = bin;
    bcdtobin(bcd+5, 2, &bin);
    tmc.tm_min = bin;
    bcdtobin(bcd+6, 2, &bin);
    tmc.tm_sec = bin;
    tmc.tm_isdst = -1;
    *timc = mktime(&tmc);
}

/**
* @fn int time_bcd(time_t timc, char *bcd)
* @brief 日付BCD変換
* @param[in] timc time_t
* @param[out] -1:異常 0～6:曜日
* @return int 変換した桁数
* @details time_tをBCDに変換
*/
int time_bcd(time_t timc, char *bcd)
{
    struct tm *tmc;
    extern int bintobcd(long bin, int keta, char *bcd);
	
    if ( timc == 0 ) {
        memset(bcd, 0, 7);
        return (-1);
    }

    tmc = localtime(&timc);
    if ( tmc != NULL ) {
        bintobcd((long)(1900+tmc->tm_year), 4, bcd);
        bintobcd((long)(tmc->tm_mon+1), 2, bcd + 2);
        bintobcd((long)tmc->tm_mday, 2, bcd + 3);
        bintobcd((long)tmc->tm_hour, 2, bcd + 4);
        bintobcd((long)tmc->tm_min, 2, bcd + 5);
        bintobcd((long)tmc->tm_sec, 2, bcd + 6);
        return (tmc->tm_wday);
    }
    else {
        memset(bcd, 0, 7);
        return (0);
    }
}
