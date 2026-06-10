/**
* @file nkklib.h
* @brief 共通ライブラリ用ヘッダー
* @author Y.Takamura
* @date 2017/09/09
* @details C/C++で利用する為の共通ライブラリ用ヘッダー
*/

/**
* timelib.c
*/
extern int time_str(time_t timc, char *date, char *time, int flg);
extern int str_time(char *date, char *time, time_t *timc, int flg);
extern void bcd_time(char *bcd, time_t *timc);
extern int time_bcd(time_t timc, char *bcd);

/**
* codelib.c
*/
extern int utf8tosjis(char *utf8, char *sjis);
extern int utf16tosjis(char *utf16, int utf16_len, char *sjis);
extern int utf16Btosjis(char *utf16, int utf16_len, char *sjis);
extern int sjistoutf8(char *sjis, char *utf8);
extern int sjistoutf16(char *sjis, int utf16_len, char *utf16);
extern int sjistoutf16B(char *sjis, int utf16_len, char *utf16);
extern int str_idx( char *source, char *word );
extern void str_trim( char *source );
extern int get_text( int no, char *source, char *text );
// #11156 2024.11.22 add commFailData肥大化対策 TDC片口 start
extern int get_split_text(int no, char *source, char separatorChar, char *text);
// #11156 2024.11.22 add commFailData肥大化対策 TDC片口 end

/**
* numlib.c
*/
extern short hl_chg(short num);
extern int int_chg(int num);
extern long long_chg(long num);
extern void short_set(unsigned char *sp, short num);
extern void bcdtobin(char *bcd, int keta, long *bin);
extern int bintobcd(long bin, int keta, char *bcd);
extern void dsp_s_form(char *buf, int len, int dp, short num);
extern void dsp_l_form(char *buf, int len, int dp, long num);
extern void dsp_ul_form(char *buf, int len, int dp, unsigned long num);
extern void dsp_t_form(char *buf, int len, short num);

/**
* loglib.c
*/
extern void log_output(char *msg);
extern void get_prg_name(char *prg_name);
