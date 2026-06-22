/**
* @brief NTSS暗号/復号関数ヘッダーファイル
*
* @details NTSS暗号/復号関数
*
* @description ntss program

* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_dec.h
* @author H.Yonezawa
* @date 2017/12/21
*/

#ifndef NTSS_ENC_DEC_H
#define NTSS_ENC_DEC_H

#include <sys/types.h>
#include <sys/stat.h>

/// NTSS暗号/復号処理方式
typedef enum NTSS_ENCDECNTSSTEXT_MODE {
    /// 暗号化
    NTSS_ENCDECNTSSTEXT_MODE_ENC,
    /// 復号化
    NTSS_ENCDECNTSSTEXT_MODE_DEC
} NtssEncDecNtssTextMode;

/**
* @brief 指定文字列を暗号/復号化する
*
* @details 指定文字列を暗号/複合化する
*
* @description
* `param[in]    Mode        処理方法
* @param[in]    *cText      暗号/復号化する文字列
* @param[in]    nBufferSize バッファーサイズ
* @param[out]   *cBuffer    暗号/復号化文字列格納先バッファ
* @return １：復号成功/else：復号失敗
* @attention 特になし
*/
extern int
encdecNTSSText( NtssEncDecNtssTextMode Mode
              , u_char *cText
              , int nBufferSize
              , u_char *cBuffer
              );

#endif