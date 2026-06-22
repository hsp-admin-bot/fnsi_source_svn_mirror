/**
* @file comsv_lcd_info.h
* @brief 仮想端末関連ヘッダー
* @author Y.Takamura
* @date 2019/01/07
*/

/// @name 仮想端末データ数定義
//@{
#define	REQ29_MAX			320			///< 仮想端末（処置者）項目最大数
#define	REQ29_PAGE_MAX		14			///< 仮想端末（処置者）ページ最大数
#define	REQ29_DISP_MAX		24			///< 仮想端末（処置者）１ページ項目数
#define	REQ33_MAX			100			///< 仮想端末（検査結果）項目最大数
#define	REQ33_DATE_MAX		12			///< 仮想端末（検査結果）日付最大数
#define	REQ36_MAX			10			///< 仮想端末（処置者）１画面最大数
#define	REQ38_MAX			15			///< 仮想端末（体重トレンド）測定回数最大数
#define	REQ40_MAX			8			///< 仮想端末（透析日報）項目最大数
#define	REQ41_MAX			20			///< 仮想端末（投与薬剤）項目最大数
#define	REQ44_MAX			5			///< 仮想端末（禁忌）項目最大数
#define	REQ46_MAX			4			///< 仮想端末（検査グラフ）項目最大数
#define	REQ46_DATE_MAX		12			///< 仮想端末（検査グラフ）日付最大数
#define	REQ47_MAX			6			///< 仮想端末（レーダーチャート）項目最大数
#define	REQ47_DATE_MAX		12			///< 仮想端末（レーダーチャート）日付最大数
#define	REQ50_MAX			200			///< 仮想端末（愁訴・処置）項目最大数
#define	REQ52_MAX			100			///< 仮想端末（指示／特記）ページ最大数
#define	REQ53_MAX			100			///< 仮想端末（CTRトレンド）最大数
#define	REQ54_MAX			20			///< 仮想端末（チェックリスト）項目最大数
#define	REQ54_NO_MAX		8			///< 仮想端末（チェックリスト）画面No最大数
#define	REQ56_MAX			3			///< 画像転送（過去レポート）最大数
//@}

/**
 * @brief 仮想端末（処置者）構造体
 */
typedef struct {
	long	id[REQ29_MAX];				///< 処置者ID
	char	name[REQ29_MAX][20];		///< 処置者名称（姓+名）
} LcddataReq29_t;

/**
 * @brief 仮想端末（酸素吸入）構造体
 */
typedef struct {
	short	status;						///< 状況（0:使用前 1:使用中）
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long	s_time;						///< 開始時刻
	time_t	s_time;						///< 開始時刻
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	short	amount;						///< 吸入量
	char	s_staff[20];				///< 開始処置者名称
	char	e_staff[20];				///< 終了処置者名称
} LcddataReq32_t;

/**
 * @brief 仮想端末（検査結果）構造体
 */
typedef struct {
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long	date;						///< 検査日
	time_t	date;						///< 検査日
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	short	class;						///< 検査日区分（0:前 1:後 2:他）
	long	item_cd[REQ33_MAX];			///< 検査コード
	char	item_name[REQ33_MAX][20];	///< 検査名称
	char	item_unit[REQ33_MAX][8];	///< 検査単位
	short	item_dec[REQ33_MAX];		///< 少数以下桁数
	long	item_data[REQ33_MAX];		///< 検査結果値
} LcddataReq33_t;

/**
 * @brief 仮想端末（ログ）構造体
 */
typedef struct {
	int		all_count;					///< 総件数
	int		count;						///< １画面件数
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long	date[REQ36_MAX];			///< 発生日時
	time_t	date[REQ36_MAX];			///< 発生日時
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	char	message[REQ36_MAX][20];		///< メッセージ
} LcddataReq36_t;

/**
 * @brief 仮想端末（体重トレンド）構造体
 */
typedef struct {
	int		count;						///< 件数
	char	date[REQ38_MAX][10];		///< 日付
	short	pre_weight[REQ38_MAX];		///< 前回後体重
	short	bef_weight[REQ38_MAX];		///< 前体重
	short	gain[REQ38_MAX];			///< 増加量
	short	dw[REQ38_MAX];				///< ＤＷ
	short	aft_weight[REQ38_MAX];		///< 後体重
	short	loss[REQ38_MAX];			///< 減少量
} LcddataReq38_t;

/**
 * @brief 仮想端末（透析日報）構造体
 */
typedef struct {
	int		count;						///< 項目数
	char	name[REQ40_MAX][16];		///< 項目名称
	char	data[REQ40_MAX][12];		///< 項目内容
} LcddataReq40_t;

/**
 * @brief 仮想端末（投与薬剤）構造体
 */
typedef struct {
	int		count;						///< 件数
	int		no[REQ41_MAX];				///< No
	char	name[REQ41_MAX][28];		///< 名称
	char	amount[REQ41_MAX][8];		///< 数量
	char	unit[REQ41_MAX][8];			///< 単位
	char	progress[REQ41_MAX][3];		///< 透析工程コード
	char	medicated[REQ41_MAX];		///< 投薬実施フラグ
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long	time[REQ41_MAX];			///< 実施時刻
	time_t	time[REQ41_MAX];			///< 実施時刻
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	short	alert_time[REQ41_MAX];		///< お知らせ通知時間
    // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
    char	alert[REQ41_MAX];		    ///< 通知フラグ
    // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end
    // add FNSI-バグ 通信サーバ 高 start
    char	effectFlg[REQ41_MAX];		///< 投薬実施済フラグ
    // add FNSI-バグ 通信サーバ 高 end
} LcddataReq41_t;

/**
 * @brief 仮想端末（抗凝固剤）構造体
 */
typedef struct {
	char	name[40];					///< 抗凝固剤名称
	char	unit[8];					///< 抗凝固剤単位
	double	value1;						///< ワンショット量
	double	value2;						///< 持続速度
	double	value3;						///< 持続総量
} LcddataReq42_t;

/**
 * @brief 仮想端末（禁忌）構造体
 */
typedef struct {
	int		count;						///< 件数
	char	name[REQ44_MAX][40];		///< 禁忌
} LcddataReq44_t;

/**
 * @brief 仮想端末（メモ）構造体
 */
typedef struct {
	char	memo[500];					///< メモ(500:40文字×13行)
} LcddataReq45_t;

/**
 * @brief 仮想端末（検査グラフ）構造体
 */
typedef struct {
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long	date;						///< 検査日
	time_t	date;						///< 検査日
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	short	class;						///< 検査日区分（0:前 1:後 2:他）
	short	count;						///< 項目数
	long	item_cd[REQ46_MAX];			///< 検査コード
	char	item_name[REQ46_MAX][20];	///< 検査名称
	char	item_unit[REQ46_MAX][8];	///< 検査単位
	short	item_dec[REQ46_MAX];		///< 少数以下桁数
	long	item_upper[REQ46_MAX];		///< グラフ上限値
	long	item_lower[REQ46_MAX];		///< グラフ下限値
	long	item_data[REQ46_MAX][REQ46_DATE_MAX];	///< 検査結果値
    // add FNSI-バグ 通信サーバ 高 start
    short   graph_type[REQ46_MAX];      ///< グラフ種類（0:通常 1:折れ線グラフ 2:棒グラフ）
    // add FNSI-バグ 通信サーバ 高 end
} LcddataReq46_t;

/**
 * @brief 仮想端末（レーダーチャート）構造体
 */
typedef struct {
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long	date;						///< 検査日
	time_t	date;						///< 検査日
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	short	class;						///< 検査日区分（0:前 1:後 2:他）
	short	count;						///< 項目数
	long	item_cd[REQ47_MAX];			///< 検査コード
	char	item_name[REQ47_MAX][20];	///< 検査名称
	char	item_unit[REQ47_MAX][8];	///< 検査単位
	short	item_dec[REQ47_MAX];		///< 少数以下桁数
	long	item_upper[REQ47_MAX];		///< グラフ上限値
	long	item_lower[REQ47_MAX];		///< グラフ下限値
	long	item_data[REQ47_MAX];		///< 検査結果値
} LcddataReq47_t;

/**
 * @brief 仮想端末（愁訴・処置）構造体
 */
typedef struct {
	int		c_code[REQ50_MAX];			///< 愁訴コード
	char	c_name[REQ50_MAX][20];		///< 愁訴名称
	int		t_code[REQ50_MAX];			///< 処置コード
	char	t_name[REQ50_MAX][20];		///< 処置名称
} LcddataReq50_t;

/**
 * @brief 仮想端末（穿刺／回収／担当）構造体
 */
typedef struct {
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//char	p_name[2][20];				///< 穿刺者１／２
	//long	p_time[2];					///< 穿刺時刻１／２
	//char	r_name[2][20];				///< 回収者１／２
	//long	r_time[2];					///< 回収時刻１／２
	//char	c_name[2][20];				///< 担当者１／２
	//long	c_time[2];					///< 担当時刻１／２
	char	p_name[2][20];				///< 穿刺者１／２
	time_t	p_time[2];					///< 穿刺時刻１／２
	char	r_name[2][20];				///< 回収者１／２
	time_t	r_time[2];					///< 回収時刻１／２
	char	c_name[2][20];				///< 担当者１／２
	time_t	c_time[2];					///< 担当時刻１／２
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
} LcddataReq51_t;

/**
 * @brief 仮想端末（指示／特記）構造体
 */
typedef struct {
	int		count;						///< 件数
	char	comment[400];				///< コメント
} LcddataReq52_t;

/**
 * @brief 仮想端末（CTRトレンド）構造体
 */
typedef struct {
	int		count;						///< 件数
	char	date[REQ53_MAX][10];		///< 日付
	short	ctr[REQ53_MAX];				///< CTR
	short	ctr_weight[REQ53_MAX];		///< CTR測定時体重
} LcddataReq53_t;

/**
 * @brief 仮想端末（チェックリスト）構造体
 */
typedef struct {
	int		count;						///< 件数
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long	chk_time[REQ54_MAX];		///< 実施時刻
	time_t	chk_time[REQ54_MAX];		///< 実施時刻
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	char	chk_name[REQ54_MAX][20];	///< 項目名
} LcddataReq54_t;

/**
 * @brief レポート画像転送（過去レポート）構造体
 */
typedef struct {
	long	last_no[REQ56_MAX];			///< 直近オーダ番号
	char	last_name[REQ56_MAX][40];	///< 直近ファイル名
	long	week_no[REQ56_MAX];			///< 同一曜日オーダ番号
	char	week_name[REQ56_MAX][40];	///< 同一曜日ファイル名
} LcddataReq56_t;

/**
* @fn int comsv_lcd_disp(int thread_no, unsigned char *dp, struct scn_data_fm *sp)
* @brief ＬＣＤデータ表示処理
* @param[in] thread_no スレッド番号
* @param[out] dp 表示データ
* @param[in,out] sp 装置制御データ
* @return int 表示データ長
* @details 新通信装置に表示するＬＣＤデータ表示処理
*/
extern int comsv_lcd_disp(int thread_no, unsigned char *dp, struct scn_data_fm *sp);

/**
* @fn int comsv_lcd_knjichk(unsigned char *data, int p)
* @brief 漢字チェック(シフトJIS)
* @param[in] data チェック対象文字列
* @param[in] p チェック位置
* @return int タイプ（0:ANK,1:漢字1バイト目,2:漢字2バイト目）
* @details 文字列の指定位置のコードタイプを取得
*/
extern int comsv_lcd_knjichk(unsigned char *data, int p);

/**
* @fn int comsv_lcd_memcpy(char *buff, char *data, int len)
* @brief lcd表示用データ作成
* @param[out] buff 作成データ
* @param[in] data コピー元データ
* @param[in] len 長さ
* @return int タイプ（1:漢字1バイト目,0:その他）
* @details lcd表示用のデータ作成（漢字チェックあり）
*/
extern int comsv_lcd_memcpy(char *buff, char *data, int len);

/**
* @fn short comsv_lcd_strshort(char *buf, short dp)
* @brief 文字列から数値変換
* @param[in] buf 文字列データ
* @param[in] dp 小数点以下桁数
* @return short 変換した数値
* @details 文字列から数値に変換（'0'～'9','.'以外を除去、'-'の場合はマイナス値）
*/
extern short comsv_lcd_strshort(char *buf, short dp);

/**
* @fn long comsv_lcd_strlong(char *buf, short dp)
* @brief 文字列から数値変換
* @param[in] buf 文字列データ
* @param[in] dp 小数点以下桁数
* @return long 変換した数値
* @details 文字列から数値に変換（'0'～'9','.'以外を除去、'-'の場合はマイナス値）
*/
extern long comsv_lcd_strlong(char *buf, short dp);

/**
* @fn void comsv_lcd_input(struct scn_data_fm *sp)
* @brief ＬＣＤデータ入力処理
* @param[in,out] sp 装置制御データ
* @details 新通信装置から入力されたＬＣＤデータ入力処理
*/
extern void comsv_lcd_input(struct scn_data_fm *sp);

/**
* @fn void comsv_lcd_input_cash(struct scn_data_fm *sp)
* @brief ＬＣＤデータ入力キャッシュ処理
* @param[in,out] sp 装置制御データ
* @details 新通信装置から入力されたＬＣＤデータ入力キャッシュ処理
*/
extern void comsv_lcd_input_cash(struct scn_data_fm *sp);

/**
* @fn long comsv_lcd_search(char *user_name)
* @brief 処置者名称から処置者ID取得
* @param[in] user_name 検索対象となる処置者名称
* @return long 処置者ID（一致なしは0）
* @details 指定した処置者名称から処置者IDを取得
*/
extern long comsv_lcd_search(char *user_name);

// add FNSI-バグ 通信サーバ 高 start
extern void comsv_effectFlg_check(struct scn_data_fm *sp, LcddataReq41_t * req41);
// add FNSI-バグ 通信サーバ 高 end
