/**
* @file codelib.c
* @brief UTF-8,UTF-16／SJISコード変換関数
* @author Y.Takamura
* @date 2017/08/07
* @details UTF-8,UTF-16／SJISコード変換用の関数ライブラリ
*/

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <iconv.h>

/**
* @def MAX_BUF
* @brief バッファーサイズ
* @details 文字列の最大サイズ
*/
#define MAX_BUF 2048

/**
* @fn int utf8tosjis(char *utf8, char *sjis)
* @brief UTF-8からSJIS変換
* @param[in] *utf8 UTF-8文字列
* @param[out] *sjis SJIS文字列
* @return int 0:成功 -1:失敗
* @details UTF-8文字列をSJIS文字列に変換
*/
int utf8tosjis(char *utf8, char *sjis)
{
    char inbuf[MAX_BUF+1] = { 0 };
    char outbuf[MAX_BUF+1] = { 0 };
    char *in = inbuf;
    char *out = outbuf;
    size_t in_size = (size_t)MAX_BUF;
    size_t out_size = (size_t)MAX_BUF;
    //iconv_t ic = iconv_open("SJIS", "UTF-8");
    iconv_t ic = iconv_open("SJIS-WIN", "UTF-8");

    if ( strlen(utf8) == 0 || strlen(utf8) > MAX_BUF ) {
        iconv_close(ic);
        return -1;
    }

    memcpy( in, utf8, strlen(utf8) );
    iconv( ic, &in, &in_size, &out, &out_size );
    iconv_close(ic);
    memcpy( sjis, outbuf, strlen(outbuf) );

    return 0;
}

/**
* @fn int utf16tosjis(char *utf16, int utf16_len, char *sjis)
* @brief UTF-16からSJIS変換
* @param[in] *utf16 UTF-16文字列
* @param[in] *utf16_len UTF-16文字列長
* @param[out] *sjis SJIS文字列
* @return int 0:成功 -1:失敗
* @details UTF-16文字列をSJIS文字列に変換
*/
int utf16tosjis(char *utf16, int utf16_len, char *sjis)
{
    char inbuf[MAX_BUF+1] = { 0 };
    char outbuf[MAX_BUF+1] = { 0 };
    char *in = inbuf;
    char *out = outbuf;
    size_t in_size = (size_t)MAX_BUF;
    size_t out_size = (size_t)MAX_BUF;
    //iconv_t ic = iconv_open("SJIS", "UTF-16");
    iconv_t ic = iconv_open("SJIS-WIN", "UTF-16");

    if ( utf16_len <= 0 || utf16_len > MAX_BUF ) {
        iconv_close(ic);
        return -1;
    }

    memcpy( in, utf16, utf16_len );
    iconv( ic, &in, &in_size, &out, &out_size );
    iconv_close(ic);
    memcpy( sjis, outbuf, strlen(outbuf) );

    return 0;
}

/**
* @fn int utf16Btosjis(char *utf16, int utf16_len, char *sjis)
* @brief UTF-16BEからSJIS変換
* @param[in] *utf16 UTF-16BE文字列
* @param[in] *utf16_len UTF-16BE文字列長
* @param[out] *sjis SJIS文字列
* @return int 0:成功 -1:失敗
* @details UTF-16BE文字列をSJIS文字列に変換
*/
int utf16Btosjis(char *utf16, int utf16_len, char *sjis)
{
    char inbuf[MAX_BUF+1] = { 0 };
    char outbuf[MAX_BUF+1] = { 0 };
    char *in = inbuf;
    char *out = outbuf;
    size_t in_size = (size_t)MAX_BUF;
    size_t out_size = (size_t)MAX_BUF;
    //iconv_t ic = iconv_open("SJIS", "UTF-16BE");
    iconv_t ic = iconv_open("SJIS-WIN", "UTF-16BE");

    if ( utf16_len <= 0 || utf16_len > MAX_BUF ) {
        iconv_close(ic);
        return -1;
    }

    memcpy( in, utf16, utf16_len );
    iconv( ic, &in, &in_size, &out, &out_size );
    iconv_close(ic);
    memcpy( sjis, outbuf, strlen(outbuf) );

    return 0;
}

/**
* @fn int sjistoutf8(char *sjis, char *utf8)
* @brief SJISからUTF-8変換
* @param[in] *sjis SJIS文字列
* @param[out] *utf8 UTF-8文字列
* @return int 0:成功 -1:失敗
* @details SJIS文字列をUTF-8文字列に変換
*/
int sjistoutf8(char *sjis, char *utf8)
{
    char inbuf[MAX_BUF+1] = { 0 };
    char outbuf[MAX_BUF+1] = { 0 };
    char *in = inbuf;
    char *out = outbuf;
    size_t in_size = (size_t)MAX_BUF;
    size_t out_size = (size_t)MAX_BUF;
    //iconv_t ic = iconv_open("UTF-8", "SJIS");
    iconv_t ic = iconv_open("UTF-8", "SJIS-WIN");

    if ( strlen(sjis)==0 ) {
        iconv_close(ic);
        return -1;
    }

    memcpy( in, sjis, strlen(sjis) );
    iconv( ic, &in, &in_size, &out, &out_size );
    iconv_close(ic);
    memcpy( utf8, outbuf, strlen(outbuf) );

    return 0;
}

/**
* @fn int sjistoutf16(char *sjis, int utf16_len, char *utf16)
* @brief SJISからUTF-16変換
* @param[in] *sjis SJIS文字列
* @param[in] utf16_len UTF-16最大文字列長
* @param[out] *utf8 UTF-16文字列
* @return int 0:成功 -1:失敗
* @details SJIS文字列をUTF-16文字列に変換
*/
int sjistoutf16(char *sjis, int utf16_len, char *utf16)
{
    char inbuf[MAX_BUF+1] = { 0 };
    char outbuf[MAX_BUF+1] = { 0 };
    char *in = inbuf;
    char *out = outbuf;
    size_t in_size = (size_t)MAX_BUF;
    size_t out_size = (size_t)MAX_BUF;
    //iconv_t ic = iconv_open("UTF-16", "SJIS");
    iconv_t ic = iconv_open("UTF-16", "SJIS-WIN");

    if ( strlen(sjis) == 0 || strlen(sjis) > MAX_BUF ) {
        iconv_close(ic);
        return -1;
    }

    memcpy( in, sjis, strlen(sjis) );
    iconv( ic, &in, &in_size, &out, &out_size );
    iconv_close(ic);
    memcpy( utf16, outbuf, utf16_len );

    return 0;
}

/**
* @fn int sjistoutf16B(char *sjis, int utf16_len, char *utf16)
* @brief SJISからUTF-16BE変換
* @param[in] *sjis SJIS文字列
* @param[in] utf16_len UTF-16BE最大文字列長
* @param[out] *utf8 UTF-16BE文字列
* @return int 0:成功 -1:失敗
* @details SJIS文字列をUTF-16BE文字列に変換
*/
int sjistoutf16B(char *sjis, int utf16_len, char *utf16)
{
    char inbuf[MAX_BUF+1] = { 0 };
    char outbuf[MAX_BUF+1] = { 0 };
    char *in = inbuf;
    char *out = outbuf;
    size_t in_size = (size_t)MAX_BUF;
    size_t out_size = (size_t)MAX_BUF;
    //iconv_t ic = iconv_open("UTF-16BE", "SJIS");
    iconv_t ic = iconv_open("UTF-16BE", "SJIS-WIN");

    if ( strlen(sjis) == 0 || strlen(sjis) > MAX_BUF ) {
        iconv_close(ic);
        return -1;
    }

    memcpy( in, sjis, strlen(sjis) );
    iconv( ic, &in, &in_size, &out, &out_size );
    iconv_close(ic);
    memcpy( utf16, outbuf, utf16_len );

    return 0;
}

/**
* @fn int str_idx( char *source, char *word )
* @brief 文字列から検索文字の位置を取得
* @param[in] *source 文字列
* @param[in] *word_検索文字列
* @return int -1:対象無し 0<=:対象文字の位置
* @details 文字列に含まれる検索文字列位置を取得
*/
int str_idx( char *source, char *word )
{
	int idx;
	char *ret;

	if ( (ret = strstr( source, word)) != NULL ) {
		idx = ret - source;
		//printf("%sは%d番目にありました．\n", word, idx);
	} else {
		idx = -1;
		//printf("%sはありませんでした．\n", word);
	}
	return idx;
}

/**
* @fn int str_idx( char *source )
* @brief 文字列から空白を除去
* @param[in] *source 文字列
* @details 文字列に含まれる前後の空白を除去
*/
void str_trim( char *source )
{
	int i, j;
 
	// 文字列の最後から空白を読み飛ばして除外する
	for ( i = strlen(source)-1; i >= 0 && isspace( source[i] ); i-- );
	source[i+1] = '\0';
	// 先頭から空白でない文字まで読み飛ばす
	for ( i = 0; isspace( source[i] ); i++ );
	// 前方の空白を詰める
	if ( i > 0 ) {
		j = 0;
		while ( source[i] ) source[j++] = source[i++];
		source[j] = '\0';
	}
}

/**
* @fn int get_text( int no, char *source, char *text )
* @brief テキストデータ(タブ区切り)取得
* @param[in] no 取得位置（1〜）
* @param[in] *source 対象文字列
* @param[out] *text 取得文字列
* @details テキスト(タブ区切り)から指定位置の文字列を取得
*/
int get_text( int no, char *source, char *text )
{
	int j=0,cnt=1;

	while ( 1 )	{
		if ( *source==0x00 || *source==0x0d || *source==0xa ) break;
		if ( *source=='\t' ) {
			cnt++;
			if ( no < cnt ) break;
			*source++;
			continue;
		}
		if ( no==cnt ) {
			text[j] = *source;
			j++;
		}
		source++;
	}
	text[j]=0;

	return( strlen(text) );
}

// #11156 2024.11.22 add commFailData肥大化対策 TDC片口 start
/**
 * @fn int get_split_text( int no, char *source, char separatorChar, char *text )
 * @brief テキストデータ(セパレータ区切り)取得
 * @param[in] no 取得位置（1〜）
 * @param[in] *source 対象文字列
 * @param[in] separator セパレータ文字
 * @param[out] *text 取得文字列
 * @details テキスト(セパレータ区切り)から指定位置の文字列を取得
 */
int get_split_text(int no, char *source, char separatorChar, char *text)
{
    int j = 0, cnt = 1;

    while (1)
    {
        if (*source == 0x00 || *source == 0x0d || *source == 0xa)
            break;
        if (*source == separatorChar)
        {
            cnt++;
            if (no < cnt)
                break;
            *source++;
            continue;
        }
        if (no == cnt)
        {
            text[j] = *source;
            j++;
        }
        source++;
    }
    text[j] = 0;

    return (strlen(text));
}

// #11156 2024.11.22 add commFailData肥大化対策 TDC片口 end
