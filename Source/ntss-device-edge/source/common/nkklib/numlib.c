/**
* @file numlib.c
* @brief 整数データ変換関数
* @author Y.Takamura
* @date 2017/09/09
* @details 整数データ変換用の関数ライブラリ
*/

#include <stdio.h>
#include <string.h>

/**
* @fn short hl_chg(short num)
* @brief 整数データの上位・下位変換
* @param[in] num 整数データ
* @return short 整数データ(変換結果)
* @details ビッグエンディアンをリトルエンディアンに変換
*/
short hl_chg(short num)
{
    short a,b;

    a = (num>>8)&0xff;
    b = num<<8;
    return(a+b);
}

/**
* @fn int int_chg(int num)
* @brief 倍整数データの上位・下位変換
* @param[in] num 倍整数データ
* @return int 倍整数データ(変換結果)
* @details ビッグエンディアンをリトルエンディアンに変換
*/
int int_chg(unsigned int num)
{
    int ret;

    ret  = num << 24;
    ret |= (num & 0x0000ff00) << 8;
    ret |= (num & 0x00ff0000) >> 8;
    ret |= num >> 24;
    return(ret);
}

/**
* @fn long long_chg(long num)
* @brief 倍整数データの上位・下位変換
* @param[in] num 倍整数データ
* @return short 倍整数データ(変換結果)
* @details ビッグエンディアンをリトルエンディアンに変換
*/
long long_chg(long num)
{
    long ret;
    char buf[10];

    *(long*)(buf) = num;
    ret = ((buf[0] & 0xff) << 24) + ((buf[1] & 0xff) << 16) + ((buf[2] & 0xff) << 8) + (buf[3] & 0xff);
    return(ret);
}

/**
* @fn void short_set(unsigned char *sp, short num)
* @brief 整数データの文字データ変換
* @param[out] *sp 文字データ
* @param[in] num 整数データ
* @details ビッグエンディアンをリトルエンディアンに変換
*/
void short_set(unsigned char *sp, short num)
{
    *sp++ = ((num>>8)&0xff);
    *sp = (num&0xff);
}

/**
* @fn void bcdtobin(char *bcd, int keta, long *bin)
* @brief BCDバイナリー変換
* @param[in] *bcd bcd値
* @param[in] keta 変換する桁数
* @param[out] *bin バイナリー値
* @details BCDをバイナリーに変換
*/
void bcdtobin(char *bcd, int keta, long *bin)
{
    int i;
    long d;
    unsigned char n;

    d = 0l;
    for ( i=0; i<keta; i++ ) {
        d *= 10;
        n = bcd[i / 2];
        if ( i % 2 == 0 ) {
            n >>= 4;
        }
        n &= 0xf;
        d += n;
    }
    *bin = d;
}

/**
* @fn int bintobcd(long bin, int keta, char *bcd)
* @brief バイナリーBCD変換
* @param[in] bin バイナリー値
* @param[in] keta 変換する桁数
* @param[out] *bcd bcd値
* @return int 変換した桁数
* @details バイナリーをBCDに変換
*/
int bintobcd(long bin, int keta, char *bcd)
{
    int i, m, k, n;
    char s = 0;
    char d = 0;

    m = (keta - 1) / 2;
    n = m + 1;
    n *= 2;
    for ( i=0,k=0; i<n; i++ ) {
        if ( i < keta ) {
            if ( bin>0l ) {
                k++;
            }
            d = bin % 10;
            bin /= 10;
        }
        else {
            d = 0;
        }
        if ( i % 2 ) {
            d <<= 4;
            s |= d;
            bcd[m--] = s;
        }
        else {
            s = d;
        }
    }
    return (k);
}

/**
* @fn void dsp_s_form(char *buf, int len, int dp, short num)
* @brief 整数データの文字列変換
* @param[out] *buf 文字列データ
* @param[in] len 文字列長
* @param[in] dp 小数点以下桁数
* @param[in] num 整数データ
* @details 整数データを指定フォーマットの文字列に変換
*/
void dsp_s_form(char *buf, int len, int dp, short num)
{
    char form[16];
    int i,n,s,k;

    for ( i=0,n=1; i<dp; i++ ) n*=10;
    if ( dp>0 ) {
        k=len-dp-1;
        if ( k<1 ) k=1;
        sprintf(form,"%%%dd.%%0%dd",k,dp);
        s = num%n;
        if ( s<0 ) s*=(-1);
        sprintf(buf,form,num/n,s);
        if ( strlen(buf) > len ) len = strlen(buf);
        if ( num<0 && (num/n)==0 ) {
            for ( i=0; i<len; i++ ) {
               if ( buf[i]!=' ' ) break;
            }
            if ( i>0 ) buf[i-1]='-';
            else {
                memmove(buf+1,buf,len);
                buf[0]='-';
            }
        }
    }
    else {
        sprintf(form,"%%%dd",len);
        sprintf(buf,form,num);
    }
}

/**
* @fn void dsp_l_form(char *buf, int len, int dp, long num)
* @brief 倍整数データの文字列変換
* @param[out] *buf 文字列データ
* @param[in] len 文字列長
* @param[in] dp 小数点以下桁数
* @param[in] num 倍整数データ
* @details 倍整数データを指定フォーマットの文字列に変換
*/
void dsp_l_form(char *buf, int len, int dp, long num)
{
    char form[16];
    int i,n,k;
    long s;

    for ( i=0,n=1; i<dp; i++ ) n*=10;
    if ( dp>0 ) {
        k=len-dp-1;
        if ( k<1 ) k=1;
        sprintf(form,"%%%dld.%%0%dld",k,dp);
        s = num%n;
        if ( s<0 ) s*=(-1);
        sprintf(buf,form,num/n,s);
        if ( strlen(buf) > len ) len = strlen(buf);
        if ( num<0 && (num/n)==0 ) {
            for ( i=0; i<len; i++ ) {
               if ( buf[i]!=' ' ) break;
            }
            if ( i>0 ) buf[i-1]='-';
            else {
                memmove(buf+1,buf,len);
                buf[0]='-';
            }
        }
    }
    else {
        sprintf(form,"%%%dld",len);
        sprintf(buf,form,num);
    }
}

/**
* @fn void dsp_ul_form(char *buf, int len, int dp, unsigned long num)
* @brief 符号なし倍整数データの文字列変換
* @param[out] *buf 文字列データ
* @param[in] len 文字列長
* @param[in] dp 小数点以下桁数
* @param[in] num 倍整数データ
* @details 倍整数データを指定フォーマットの文字列に変換
*/
void dsp_ul_form(char *buf, int len, int dp, unsigned long num)
{
    char form[16];
    int i,n,k;
    unsigned long s;

    for ( i=0,n=1; i<dp; i++ ) n*=10;
    if ( dp>0 ) {
        k=len-dp-1;
        if ( k<1 ) k=1;
        sprintf(form,"%%%dlu.%%0%dlu",k,dp);
        s = num%n;
        if ( s<0 ) s*=(-1);
        sprintf(buf,form,num/n,s);
        if ( strlen(buf) > len ) len = strlen(buf);
        if ( num<0 && (num/n)==0 ) {
            for ( i=0; i<len; i++ ) {
               if ( buf[i]!=' ' ) break;
            }
            if ( i>0 ) buf[i-1]='-';
            else {
                memmove(buf+1,buf,len);
                buf[0]='-';
            }
        }
    }
    else {
        sprintf(form,"%%%dlu",len);
        sprintf(buf,form,num);
    }
}

/**
* @fn void dsp_t_form(char *buf, int len, short num)
* @brief 整数データの時間文字列変換
* @param[out] *buf 文字列データ
* @param[in] len 文字列長
* @param[in] num 整数データ
* @details 整数データを時刻フォーマットの文字列に変換
*/
void dsp_t_form( char *buf, int len, short num )
{
	memset(buf,' ',len);
	if ( len>5 ) len-=5;
	else len=0;
	sprintf(buf+len,"%2d:%02d",num/60,num%60);
}
