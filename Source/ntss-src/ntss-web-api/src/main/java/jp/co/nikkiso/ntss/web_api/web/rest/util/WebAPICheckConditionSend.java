package jp.co.nikkiso.ntss.web_api.web.rest.util;


import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.MissingFormatArgumentException;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jakarta.validation.Valid;

import jp.co.nikkiso.ntss.api.service.NameConcat.NameConcatService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.postgresql.util.PGobject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ObjectUtils;
import org.springframework.web.bind.annotation.RequestBody;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.service.WebAPICheckConditionSendService;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


/**
 * 修正履歴：
 * 2019.02.09(Sat) 若林　リファクタリング
 * 2019.02.12(Tue) 若林　getItemFromJson,setItemToJson,setCondInfoToDB追加
 * 2019.02.13(Wed) 若林　未使用定義削除
 * 2019.02.14(Thu) 若林  環境移行。パッケージパス変更
 * 2019.02.23(Sat) 若林  除水補正取得&設定。患者名取得&設定
 */


/**
 * 条件送信データ作成APIＩ
 *
 *
 */
@Component
public class WebAPICheckConditionSend {

  //DB access
  @Autowired
  WebAPICheckConditionSendService webAPICheckConditionSendService ;

  @Autowired
  LogService logService;

  // #11827 2025.05.14 add 姓名結合用サービス構築 TDC米沢 start
  // 姓名結合用サービス構築
  @Autowired
  NameConcatService nameConcatService;
  // #11827 2025.05.14 add 姓名結合要サービス構築 TDC米沢 end

  /**
   * 定数
   */
  private final String CONST_NAME_SEP = "" ;    //患者名の区切り文字

  /*
   * キー名の定義
   */
  public enum PARAMKEY {
    STATUS("status"),               //HTTPステータス
    MSG("msg"),               //エラーメッセージ
    ERRMSG("errmsg"),               //エラーメッセージ
    RECEIVE_DATA("recive_data"),    //受信データ
    TMP_SETTING("tmpSetting"),     //装置一時設定
    WEIGHT_DATA("weightData"),     //体重計情報
    INSERT_COND("insertCond"),     //条件送信データ
    RET_MSG("retMsg"),             //返却メッセージ
    RET_LOG_MSG("retLogMsg"),             //返却メッセージ
    OFFWATER_CORRECT("offwaterCorrect"),//除水補正
    TARE_CORRECT("tareCorrect"),   //風袋補正
    PATID("pat_id"),                 //患者ID
    BED_CD("bed_cd"),               //ベッド番号
    KUR_CD("kur_cd"),               //クールコード
    TREAT_DATE("treat_date"),       //治療日
    ORD_NO("ordNo"),                //オーダー番号
    IND_COND_INFO("ind_cond_info"),      //指示：治療条件情報
    FACILITY_CD("facility_cd"),     //施設コード
    RST_MACHINE_NO("rst_machine_no"),   //実績：装置番号
    MACHINE_TYPE_CD("machine_type_cd"), //型式コード
    MACHINE_SERIAL("machine_serial"),    //製造番号
    VALUE("value"),                     //値
    CALVALUE("calValue"),                //計算値
    UPPER("UPPER"),                     //Kt/V　上限値
    UNDER("UNDER"),                     //Kt/V　下限値

    COND_NO("condNo"),                  //治療条件番号

    IND_OFF_WATER_INFO("ind_off_water_info"),   //除水補正値
    RST_WEIGHT_INFO("rst_weight_info"),         //実績：体重情報
    WATER_REMOVAL_TARGET("water_removal_target"),     //実績：体重情報-目標除水量

    IND_DW("ind_dw"),                   // DW
    RST_DW("rst_dw"),

    //装置マスタ
    TMP_CENTER_HD("tmp_center_hd"),     // TMPゼロ補正警報中点HD
    TMP_CENTER_ECUM("tmp_center_ecum"), // TMPゼロ補正警報中点ECUM
    TMP_CENTER_HDF("tmp_center_hdf"),   // TMPゼロ補正警報中点HDF
    TMP_CENTER_HF("tmp_center_hf"),     // TMPゼロ補正警報中点HF
    TMP_CENTER_HD_HO("tmp_center_hd_ho"),//TMP初期補正中点（HD+補液）
    TMP_CENTER_OHF("tmp_center_ohf"),   //TMP初期補正中点（OHF）
    TMP_CENTER_OHDF("tmp_center_ohdf"),   //TMP初期補正中点（OHDF）

    COM_FORMAT_CD("com_format_cd"), //通信フォーマット
    MACHINE_NO("machine_no"),       //装置番号

    MACHINE_OPTION("machine_option"),   //装置オプション
    DEVICE_TYPE_NAME("machine_type"),   //型式
    DEVICE_TYPE_CD("machine_type_cd"),  //型式コード

    //患者情報
    CALC_DIALYSIS_DATE("CALC_DIALYSIS_DATE"),   //体液量算出時治療日
    WEIGHT_BEFORE("WEIGHT_BEFORE"),             //前体重
    WEIGHT_AFTER("WEIGHT_AFTER"),               //後体重
    ADD_TOTAL("ADD_TOTAL"),                     //除水積算値

    PAT_LAST_NAME("pat_last_name"),             //患者名(姓)
    PAT_FIRST_NAME("pat_first_name"),           //患者名(名)

    CALC_DIALYSIS_TIME("CALC_DIALYSIS_TIME"),   //算出透析時間
    CALC_BLOOD_VOL("CALC_BLOOD_VOL"),           //算出血流量

    DEVICE_SET_INFO("device_set_info"),         //装置設定情報
    PHYSICAL_INFO("physical_info"),             //身体情報
    DW("dw"),                                   //DW(ドライウエイト)

    DEV("dev"),                                  //装置設定(dev)
    PAT("pat"),                                  //装置設定(pat)
    //除水
    OFF_WATER_NAME("name_"),        //除水項目名
    OFF_WATER_VALUE("weight_"),        //除水補正値

    //身体情報
    EXAM_DATE("exam_date"),             //検査日時

    //透析量プログラム
    AFVPROG("AFVPROG"),                     //透析量プログラム設定
    AFVPROG_SYS("AFVPROG_SYS"),             //透析量プログラム設定(システム）
    AFVPROG_SYS_ON("AFVPROG_SYS_ON"),       //透析量プログラム使用フラグ
    //ダイアライザー情報
    UFR_WARNING_MAX("ufr_warning_max"), // 初期UFR警報上限
    UFR_WARNING_MIN("ufr_warning_min"), // 初期UFR警報下限
    UFR_WARNING_REDUCTION("ufr_warning_reduction"), // UFR低下率警報点
    UREACLEARANCE("urea_clearance"),    // 尿素クリアランス
    BLOODAMT("bloodamt"),               // 血流量
    ALQD_FLOOD_VOL("alqd_flood_vol"),   // 透析液量
    KOA("koa"),                         // KOA
    AREA("area"),                       // 面積
    DIALYZER_TYPE("dialyzer_type"),               // ダイアライザ種別
    GAS_PURGE_TIME("gas_purge_time"),              // ガスパージ時間
    SUBSTITUENT_WASH_AMT("substituent_wash_amt"),        // 置換洗浄量（透析液）
    MEMBRANE_WASH("membrane_wash"),               // 膜洗浄（中空糸）

    EXAM_ITEM_CD("EXAM_ITEM_CD"),           //BUN値

    DEVICE_MODE("device_mode") ,             //装置モード

    //装置オプション
    MACHINE_OPTION_DFAS("opt_2_13"),        //装置オプション   D-FAS(Jsonキー) 現行:オプションデータ2－ビット13

    // 体重実績
    RST_WEIGHT_BEFORE("weight_before"), // 体重実績.前体重
    ;

    //値格納用
    public String strKey = null ;

    //String型のコンストラクタ
    private PARAMKEY(String strKey) {
      this.strKey = strKey ;
    }

    //String型のGetter
    public String get() {
      return this.strKey ;
    }

  };

  /**
   *
   * 装置設定のキー
   *
   */
  public enum MACHINESETTINGKEY {
    ADR0000("0"),   //患者コード
    ADR0001("1"),   //患者コード
    ADR0002("2"),   //患者コード
    ADR0003("3"),   //患者コード
    ADR0004("4"),   //患者名
    ADR0005("5"),   //患者名
    ADR0006("6"),   //患者名
    ADR0007("7"),   //患者名
    ADR0008("8"),   //患者名
    ADR0009("9"),   //患者名
    ADR0010("10"),  //患者名
    ADR0011("11"),  //患者名
    ADR0012("12"),  //患者名
    ADR0013("13"),  //患者名
    ADR0014("14"),  //透析時間
    ADR0015("15"),  //治療モード
    ADR0016("16"),  //ＥＣＵＭ選択
    ADR0017("17"),  //ＥＣＵＭ量
    ADR0018("18"),  //ＥＣＵＭ時間
    ADR0019("19"),  //ＥＣＵＭ時間カウント選択
    ADR0020("20"),  //除水目標値
    ADR0021("21"),  //除水計算選択
    ADR0022("22"),  //除水計算優先項目選択
    ADR0023("23"),  //シングルニードル電源ＳＷ
    ADR0024("24"),  //シングルニードル切替圧上限
    ADR0025("25"),  //シングルニードル切替圧下限
    ADR0026("26"),  //透析液温度設定
    ADR0027("27"),  //透析液流量設定値
    ADR0028("28"),  //血流量設定
    ADR0029("29"),  //ＩＰ使用選択
    ADR0030("30"),  //ＩＰ速度設定
    ADR0031("31"),  //ＩＰスタート
    ADR0032("32"),  //ＩＰ自動ワンショット
    ADR0033("33"),  //ＩＰワンショット量
    ADR0034("34"),  //ＩＰ電源報知切りＳＷ
    ADR0035("35"),  //ＩＰ電源報知切り時間
    ADR0036("36"),  //ＩＰ電源自動切りＳＷ
    ADR0037("37"),  //ＩＰ電源自動切り時間
    ADR0038("38"),  //クリップ式気泡検出器切りＳＷ
    ADR0039("39"),  //除水開始遅延時間
    ADR0040("40"),  //透析前体重
    ADR0041("41"),  //ＤＷ
    ADR0042("42"),  //補正値の合計
    ADR0043("43"),  //除水量制限
    ADR0044("44"),  //除水量計算値
    ADR0045("45"),  //除水補正項目名１
    ADR0046("46"),  //除水補正項目名１
    ADR0047("47"),  //除水補正項目名１
    ADR0048("48"),  //除水補正項目名１
    ADR0049("49"),  //除水補正項目名１
    ADR0050("50"),  //除水補正項目名１
    ADR0051("51"),  //除水補正項目名１
    ADR0052("52"),  //除水補正項目名１
    ADR0053("53"),  //除水補正値１
    ADR0054("54"),  //除水補正項目名2
    ADR0055("55"),  //除水補正項目名2
    ADR0056("56"),  //除水補正項目名2
    ADR0057("57"),  //除水補正項目名2
    ADR0058("58"),  //除水補正項目名2
    ADR0059("59"),  //除水補正項目名2
    ADR0060("60"),  //除水補正項目名2
    ADR0061("61"),  //除水補正項目名2
    ADR0062("62"),  //除水補正値2
    ADR0063("63"),  //除水補正項目名3
    ADR0064("64"),  //除水補正項目名3
    ADR0065("65"),  //除水補正項目名3
    ADR0066("66"),  //除水補正項目名3
    ADR0067("67"),  //除水補正項目名3
    ADR0068("68"),  //除水補正項目名3
    ADR0069("69"),  //除水補正項目名3
    ADR0070("70"),  //除水補正項目名3
    ADR0071("71"),  //除水補正値3
    ADR0072("72"),  //除水補正項目名4
    ADR0073("73"),  //除水補正項目名4
    ADR0074("74"),  //除水補正項目名4
    ADR0075("75"),  //除水補正項目名4
    ADR0076("76"),  //除水補正項目名4
    ADR0077("77"),  //除水補正項目名4
    ADR0078("78"),  //除水補正項目名4
    ADR0079("79"),  //除水補正項目名4
    ADR0080("80"),  //除水補正値4
    ADR0081("81"),  //除水補正項目名5
    ADR0082("82"),  //除水補正項目名5
    ADR0083("83"),  //除水補正項目名5
    ADR0084("84"),  //除水補正項目名5
    ADR0085("85"),  //除水補正項目名5
    ADR0086("86"),  //除水補正項目名5
    ADR0087("87"),  //除水補正項目名5
    ADR0088("88"),  //除水補正項目名5
    ADR0089("89"),  //除水補正値5
    ADR0090("90"),  //前補液　濾過率
    ADR0091("91"),  //ヘマトクリット（Ht）
    ADR0092("92"),  //総タンパク(TP)
    ADR0093("93"),  //予備
    ADR0094("94"),  //予備
    ADR0095("95"),  //予備
    ADR0096("96"),  //予備
    ADR0097("97"),  //予備
    ADR0098("98"),  //予備
    ADR0099("99"),  //予備
    ADR0100("100"), //静脈圧自動設定警報幅上限HD/ECUM
    ADR0101("101"), //静脈圧自動設定警報幅下限HD/ECUM
    ADR0102("102"), //静脈圧自動設定警報限界上限
    ADR0103("103"), //静脈圧自動設定警報限界下限
    ADR0104("104"), //静脈圧固定警報上限
    ADR0105("105"), //静脈圧固定警報下限
    ADR0106("106"), //静脈圧自動設定警報幅上限HDF/HF
    ADR0107("107"), //静脈圧自動設定警報幅下限HDF/HF
    ADR0108("108"), //静脈圧固定警報上限透析準備
    ADR0109("109"), //静脈圧固定警報下限透析準備
    ADR0110("110"), //静脈圧固定警報上限ＳＮ
    ADR0111("111"), //静脈圧固定警報下限ＳＮ
    ADR0112("112"), //液圧自動設定警報幅上限HD/ECUM
    ADR0113("113"), //液圧自動設定警報幅下限HD/ECUM
    ADR0114("114"), //液圧自動設定警報限界上限
    ADR0115("115"), //液圧自動設定警報限界下限
    ADR0116("116"), //液圧固定警報上限
    ADR0117("117"), //液圧固定警報下限
    ADR0118("118"), //液圧自動設定警報幅上限HDF/HF
    ADR0119("119"), //液圧自動設定警報幅下限HDF/HF
    ADR0120("120"), //液圧自動設定警報幅上限ＳＮ
    ADR0121("121"), //液圧自動設定警報幅下限ＳＮ
    ADR0122("122"), //液圧自動設定警報限界上限ＳＮ
    ADR0123("123"), //液圧自動設定警報限界下限ＳＮ
    ADR0124("124"), //液圧固定警報上限ＳＮ
    ADR0125("125"), //液圧固定警報下限ＳＮ
    ADR0126("126"), //ＴＭＰ自動追従警報幅上限HD/ECUM
    ADR0127("127"), //ＴＭＰ自動追従警報幅下限HD/ECUM
    ADR0128("128"), //ＴＭＰ自動設定警報幅上限HD/ECUM
    ADR0129("129"), //ＴＭＰ自動設定警報幅下限HD/ECUM
    ADR0130("130"), //ＴＭＰ自動設定警報限界上限
    ADR0131("131"), //ＴＭＰ自動設定警報限界下限
    ADR0132("132"), //ＴＭＰ固定警報上限
    ADR0133("133"), //ＴＭＰ固定警報下限
    ADR0134("134"), //ＴＭＰ自動追従警報幅上限HDF/HF
    ADR0135("135"), //ＴＭＰ自動追従警報幅下限HDF/HF
    ADR0136("136"), //ＴＭＰ自動設定警報幅上限HDF/HF
    ADR0137("137"), //ＴＭＰ自動設定警報幅下限HDF/HF
    ADR0138("138"), //ＴＭＰ自動追従警報幅上限ＳＮ
    ADR0139("139"), //ＴＭＰ自動追従警報幅下限ＳＮ
    ADR0140("140"), //ＴＭＰ自動設定警報幅上限ＳＮ
    ADR0141("141"), //ＴＭＰ自動設定警報幅下限ＳＮ
    ADR0142("142"), //ＴＭＰ自動設定警報限界上限ＳＮ
    ADR0143("143"), //ＴＭＰ自動設定警報限界下限ＳＮ
    ADR0144("144"), //ＴＭＰ固定警報上限ＳＮ
    ADR0145("145"), //ＴＭＰ固定警報下限ＳＮ
    ADR0146("146"), //ダイアライザー差圧自動設定警報幅上限HD/ECUM
    ADR0147("147"), //ダイアライザー差圧自動設定警報幅下限HD/ECUM
    ADR0148("148"), //ダイアライザー差圧固定警報上限
    ADR0149("149"), //ダイアライザー差圧固定警報下限
    ADR0150("150"), //ダイアライザー差圧自動設定警報幅上限HDF/HF
    ADR0151("151"), //ダイアライザー差圧自動設定警報幅下限HDF/HF
    ADR0152("152"), //ダイアライザー入口圧自動設定警報幅上限HD/ECUM
    ADR0153("153"), //ダイアライザー入口圧自動設定警報幅下限HD/ECUM
    ADR0154("154"), //ダイアライザー入口圧自動設定警報限界上限
    ADR0155("155"), //ダイアライザー入口圧自動設定警報限界下限
    ADR0156("156"), //ダイアライザー入口圧固定警報上限
    ADR0157("157"), //ダイアライザー入口圧固定警報下限
    ADR0158("158"), //ダイアライザー入口圧自動設定警報幅上限HDF/HF
    ADR0159("159"), //ダイアライザー入口圧自動設定警報幅下限HDF/HF
    ADR0160("160"), //ダイアライザー入口圧固定警報上限透析準備
    ADR0161("161"), //ダイアライザー入口圧固定警報下限透析準備
    ADR0162("162"), //ダイアライザー入口圧固定警報上限ＳＮ
    ADR0163("163"), //ダイアライザー入口圧固定警報下限ＳＮ
    ADR0164("164"), //初期ＵＦＲ警報上限
    ADR0165("165"), //初期ＵＦＲ警報下限
    ADR0166("166"), //ＵＦＲ低下警報点
    ADR0167("167"), //ＴＭＰゼロ補正警報中点HD
    ADR0168("168"), //ＴＭＰゼロ補正警報上限HD
    ADR0169("169"), //ＴＭＰゼロ補正警報下限HD
    ADR0170("170"), //ＴＭＰゼロ補正警報中点ECUM
    ADR0171("171"), //ＴＭＰゼロ補正警報上限ECUM
    ADR0172("172"), //ＴＭＰゼロ補正警報下限ECUM
    ADR0173("173"), //ＴＭＰゼロ補正警報中点HDF
    ADR0174("174"), //ＴＭＰゼロ補正警報上限HDF
    ADR0175("175"), //ＴＭＰゼロ補正警報下限HDF
    ADR0176("176"), //ＴＭＰゼロ補正警報中点HF
    ADR0177("177"), //ＴＭＰゼロ補正警報上限HF
    ADR0178("178"), //ＴＭＰゼロ補正警報下限HF
    ADR0179("179"), //血流量操作範囲上限
    ADR0180("180"), //ＩＰ速度操作範囲上限
    ADR0181("181"), //除水速度操作範囲上限
    ADR0182("182"), //透析液温度操作範囲上限
    ADR0183("183"), //透析液温度操作範囲下限
    ADR0184("184"), //Ｎａ注入濃度操作範囲上限
    ADR0185("185"), //補液速度操作範囲上限（HDF）
    ADR0186("186"), //補液速度操作範囲上限（HF）
    ADR0187("187"), //ダイアライザ 尿素クリアランス
    ADR0188("188"), //ダイアライザ 血流量
    ADR0189("189"), //ダイアライザ 透析液流量
    ADR0190("190"), //血圧自動測定間隔
    ADR0191("191"), //血圧ｶﾌ選択
    ADR0192("192"), //昇圧値
    ADR0193("193"), //昇圧方法選択
    ADR0194("194"), //血圧連続測定動作選択
    ADR0195("195"), //血圧測定方法選択
    ADR0196("196"), //BV-UFC使用選択
    ADR0197("197"), //ＵＦＣ期間除水速度上限
    ADR0198("198"), //ＵＦＣ期間除水速度下限
    ADR0199("199"), //開始期間　時間
    ADR0200("200"), //プログラム補液　I-HDF　補液量設定
    ADR0201("201"), //プログラム補液　I-HDF　補液速度
    ADR0202("202"), //プログラム補液　I-HDF　補液周期
    ADR0203("203"), //プログラム補液　I-HDF　補液開始時間
    ADR0204("204"), //プログラム補液　I-HDF　除水再開時間
    ADR0205("205"), //プログラム補液　I-HDF　総補液量上限
    ADR0206("206"), //開始期間　除水速度倍率
    ADR0207("207"), //固定倍率除水期間　時間
    ADR0208("208"), //固定倍率除水期間　除水速度倍率
    ADR0209("209"), //固定倍率除水終了条件　最高血圧
    ADR0210("210"), //固定倍率除水終了条件　脈拍
    ADR0211("211"), //最高血圧上限
    ADR0212("212"), //最高血圧下限
    ADR0213("213"), //最低血圧上限
    ADR0214("214"), //最低血圧下限
    ADR0215("215"), //平均血圧上限
    ADR0216("216"), //平均血圧下限
    ADR0217("217"), //脈拍数上限
    ADR0218("218"), //脈拍数下限
    ADR0219("219"), //最高血圧上限警報　BP　動作選択
    ADR0220("220"), //最高血圧下限警報　BP　動作選択
    ADR0221("221"), //最高血圧上限警報　除水　動作選択
    ADR0222("222"), //最高血圧下限警報　除水　動作選択
    ADR0223("223"), //最高血圧上限警報　Na注入　動作選択
    ADR0224("224"), //最高血圧下限警報　Na注入　動作選択
    ADR0225("225"), //最高血圧上限警報　補液　動作選択
    ADR0226("226"), //最高血圧下限警報　補液　動作選択
    ADR0227("227"), //最高血圧上限警報　BP　速度
    ADR0228("228"), //最高血圧下限警報　BP　速度
    ADR0229("229"), //最高血圧上限警報　除水　速度
    ADR0230("230"), //最高血圧下限警報　除水　速度
    ADR0231("231"), //最高血圧上限警報　Na注入　速度
    ADR0232("232"), //最高血圧下限警報　Na注入　速度
    ADR0233("233"), //最高血圧上限警報　補液　速度
    ADR0234("234"), //最高血圧下限警報　補液　速度
    ADR0235("235"), //警報連動測定開始時刻
    ADR0236("236"), //治療条件連動測定時刻
    ADR0237("237"), //血圧測定自動停止(警報発生)
    ADR0238("238"), //血圧測定自動停止(条件変更)
    ADR0239("239"), //高速測定選択
    ADR0240("240"), //ＴＭＰ監視モード
    ADR0241("241"), //ＴＭＰゼロ補正の選択
    ADR0242("242"), //静脈圧自動設定警報監視有無
    ADR0243("243"), //ダイアライザー血液入口圧自動設定警報監視有無
    ADR0244("244"), //透析液圧自動設定警報監視有無
    ADR0245("245"), //ＴＭＰ自動設定警報監視有無
    ADR0246("246"), //差圧自動設定警報監視有無
    ADR0247("247"), //Ｎａ濃度自動設定警報監視有無
    ADR0248("248"), //固定倍率除水終了条件　ΔBV
    ADR0249("249"), //終了前期間 時間
    ADR0250("250"), //透析液濃度プログラム自動設定警報幅上限
    ADR0251("251"), //透析液濃度プログラム自動設定警報幅下限
    ADR0252("252"), //Ｂ液濃度プログラム自動設定警報幅上限
    ADR0253("253"), //Ｂ液濃度プログラム自動設定警報幅下限
    ADR0254("254"), //Ｎａ濃度自動設定警報幅上限
    ADR0255("255"), //Ｎａ濃度自動設定警報幅下限
    ADR0256("256"), //Ｎａ濃度固定警報上限
    ADR0257("257"), //Ｎａ濃度固定警報下限
    ADR0258("258"), //アクセス再循環測定使用選択
    ADR0259("259"), //自動測定1
    ADR0260("260"), //ΔＢＶ低下警報点１
    ADR0261("261"), //ΔＢＶ低下警報点２
    ADR0262("262"), //ΔBV変化率警報点
    ADR0263("263"), //自動測定2
    ADR0264("264"), //自動測定3
    ADR0265("265"), //自動測定4
    ADR0266("266"), //自動測定5
    ADR0267("267"), //ブラッドボリューム計使用の選択
    ADR0268("268"), //透析液流量　設定方法の選択
    ADR0269("269"), //透析液流量　比率設定値
    ADR0270("270"), //D-FAS　返血　動脈側返血使用選択
    ADR0271("271"), //開始時ΔBV基準値
    ADR0272("272"), //ΔBV基準線　指数１
    ADR0273("273"), //ΔBV基準線　指数２
    ADR0274("274"), //ΔBV基準線　指数３
    ADR0275("275"), //終了時ΔBV基準値
    ADR0276("276"), //予備
    ADR0277("277"), //ΔＢＶ除水低下速度
    ADR0278("278"), //ΔＢＶ除水低下遅延時間
    ADR0279("279"), //予備
    ADR0280("280"), //予備
    ADR0281("281"), //再循環率報知
    ADR0282("282"), //透析量プログラム使用選択
    ADR0283("283"), //体液量計算時後体重
    ADR0284("284"), //体液量+補正値
    ADR0285("285"), //目標後体重
    ADR0286("286"), //標準血流量
    ADR0287("287"), //KoA
    ADR0288("288"), //目標Kt/V
    ADR0289("289"), //予備
    ADR0290("290"), //ＵＦＲプログラム電源ＳＷ
    ADR0291("291"), //治療モード１
    ADR0292("292"), //治療モード２
    ADR0293("293"), //治療モード３
    ADR0294("294"), //治療モード４
    ADR0295("295"), //治療モード５
    ADR0296("296"), //治療モード６
    ADR0297("297"), //治療モード７
    ADR0298("298"), //治療モード８
    ADR0299("299"), //治療モード９
    ADR0300("300"), //治療モード１０
    ADR0301("301"), //ＵＦＲプログラム指数１
    ADR0302("302"), //ＵＦＲプログラム指数２
    ADR0303("303"), //ＵＦＲプログラム指数３
    ADR0304("304"), //ＵＦＲプログラム指数４
    ADR0305("305"), //ＵＦＲプログラム指数５
    ADR0306("306"), //ＵＦＲプログラム指数６
    ADR0307("307"), //ＵＦＲプログラム指数７
    ADR0308("308"), //ＵＦＲプログラム指数８
    ADR0309("309"), //ＵＦＲプログラム指数９
    ADR0310("310"), //ＵＦＲプログラム指数１０
    ADR0311("311"), //ＵＦＲプログラム最終位置
    ADR0312("312"), //ＵＦＲプログラムコース
    ADR0313("313"), //ＵＦＲプログラム開始数値
    ADR0314("314"), //ＵＦＲプログラム終了数値
    ADR0315("315"), //Ｎａ注入プログラム電源ＳＷ
    ADR0316("316"), //Ｎａ注入プログラム設定１
    ADR0317("317"), //Ｎａ注入プログラム設定２
    ADR0318("318"), //Ｎａ注入プログラム設定３
    ADR0319("319"), //Ｎａ注入プログラム設定４
    ADR0320("320"), //Ｎａ注入プログラム設定５
    ADR0321("321"), //Ｎａ注入プログラム設定６
    ADR0322("322"), //Ｎａ注入プログラム設定７
    ADR0323("323"), //Ｎａ注入プログラム設定８
    ADR0324("324"), //Ｎａ注入プログラム設定９
    ADR0325("325"), //Ｎａ注入プログラム設定１０
    ADR0326("326"), //Ｎａ注入プログラム切替時間
    ADR0327("327"), //Ｎａ注入プログラム　ＵＦＲプロとの連動選択
    ADR0328("328"), //Ｎａ注入プログラムコース
    ADR0329("329"), //Ｎａ注入プログラム開始数値
    ADR0330("330"), //Ｎａ注入プログラム終了数値
    ADR0331("331"), //D-FAS　脱血　同時脱血　脱血量
    ADR0332("332"), //D-FAS　脱血　片側脱血への切替え透析液圧
    ADR0333("333"), //D-FAS　脱血　脱血速度
    ADR0334("334"), //D-FAS　脱血　片側脱血(除水なし) 脱血量
    ADR0335("335"), //D-FAS　治療　治療開始時 血液ポンプ速度
    ADR0336("336"), //緊急補液　補液速度
    ADR0337("337"), //緊急補液　補液量
    ADR0338("338"), //D-FAS　脱血　片側脱血（除水あり）　脱血量
    ADR0339("339"), //D-FAS　脱血　脱血方法選択
    ADR0340("340"), //濃度プログラム電源ＳＷ
    ADR0341("341"), //透析液濃度プログラム設定１
    ADR0342("342"), //透析液濃度プログラム設定２
    ADR0343("343"), //透析液濃度プログラム設定３
    ADR0344("344"), //透析液濃度プログラム設定４
    ADR0345("345"), //透析液濃度プログラム設定５
    ADR0346("346"), //透析液濃度プログラム設定６
    ADR0347("347"), //透析液濃度プログラム設定７
    ADR0348("348"), //透析液濃度プログラム設定８
    ADR0349("349"), //透析液濃度プログラム設定９
    ADR0350("350"), //透析液濃度プログラム設定１０
    ADR0351("351"), //Ｂ液濃度プログラム設定１
    ADR0352("352"), //Ｂ液濃度プログラム設定２
    ADR0353("353"), //Ｂ液濃度プログラム設定３
    ADR0354("354"), //Ｂ液濃度プログラム設定４
    ADR0355("355"), //Ｂ液濃度プログラム設定５
    ADR0356("356"), //Ｂ液濃度プログラム設定６
    ADR0357("357"), //Ｂ液濃度プログラム設定７
    ADR0358("358"), //Ｂ液濃度プログラム設定８
    ADR0359("359"), //Ｂ液濃度プログラム設定９
    ADR0360("360"), //Ｂ液濃度プログラム設定１０
    ADR0361("361"), //透析液濃度プログラムステップ切替無し　コース
    ADR0362("362"), //透析液濃度プログラム開始数値
    ADR0363("363"), //透析液濃度プログラム終了数値
    ADR0364("364"), //Ｂ液濃度プログラムステップ切替無し　コース
    ADR0365("365"), //Ｂ液濃度プログラム開始数値
    ADR0366("366"), //Ｂ液濃度プログラム終了数値
    ADR0367("367"), //濃度プログラム切替時間
    ADR0368("368"), //濃度プログラム　ＵＦＲプロとの連動選択
    ADR0369("369"), //DP=Qd+Qs(補液速度加算)
    ADR0370("370"), //返血機能　使用液量
    ADR0371("371"), //返血機能　流速
    ADR0372("372"), //返血機能　血液判別器による終了選択
    ADR0373("373"), //D-FAS　返血　静脈側返血速度
    ADR0374("374"), //D-FAS　返血　静脈側最大返血量
    ADR0375("375"), //予約
    ADR0376("376"), //D-FAS　返血　動脈側最大返血量
    ADR0377("377"), //D-FAS　返血　静脈側返血　血液判別器使用選択
    ADR0378("378"), //D-FAS　返血　動脈側返血　血液判別器使用選択
    ADR0379("379"), //OHDF　補液速度比率
    ADR0380("380"), //補液速度
    ADR0381("381"), //補液温度設定値
    ADR0382("382"), //補液量設定値
    ADR0383("383"), //補液量設定値制限（OHDF・OHF用）
    ADR0384("384"), //AFBF　補液比率使用選択
    ADR0385("385"), //AFBF　補液比率
    ADR0386("386"), //補液速度設定範囲上限（AFBF）
    ADR0387("387"), //補液速度設定範囲下限（AFBF）
    ADR0388("388"), //補液選択（前・後）
    ADR0389("389"), //OHDF/OHF補液計算優先項目選択
    ADR0390("390"), //ＴＭＰゼロ補正警報中点OHDF
    ADR0391("391"), //ＴＭＰゼロ補正警報上限OHDF
    ADR0392("392"), //ＴＭＰゼロ補正警報下限OHDF
    ADR0393("393"), //ＴＭＰゼロ補正警報中点OHF
    ADR0394("394"), //ＴＭＰゼロ補正警報上限OHF
    ADR0395("395"), //ＴＭＰゼロ補正警報下限OHF
    ADR0396("396"), //補液速度操作範囲上限（OHDF）
    ADR0397("397"), //補液速度操作範囲上限（OHF）
    ADR0398("398"), //補液開始遅延時間
    ADR0399("399"), //予約
    ADR0400("400"), //QBプログラム血流量1
    ADR0401("401"), //QBプログラム血流量2
    ADR0402("402"), //QBプログラム血流量3
    ADR0403("403"), //QBプログラム血流量4
    ADR0404("404"), //QBプログラム血流量5
    ADR0405("405"), //QBプログラム血流量6
    ADR0406("406"), //QBプログラム血流量7
    ADR0407("407"), //QBプログラム血流量8
    ADR0408("408"), //QBプログラム血流量9
    ADR0409("409"), //QBプログラム血流量10
    ADR0410("410"), //QDプログラム透析液流量1
    ADR0411("411"), //QDプログラム透析液流量2
    ADR0412("412"), //QDプログラム透析液流量3
    ADR0413("413"), //QDプログラム透析液流量4
    ADR0414("414"), //QDプログラム透析液流量5
    ADR0415("415"), //QDプログラム透析液流量6
    ADR0416("416"), //QDプログラム透析液流量7
    ADR0417("417"), //QDプログラム透析液流量8
    ADR0418("418"), //QDプログラム透析液流量9
    ADR0419("419"), //QDプログラム透析液流量10
    ADR0420("420"), //QB、QDプログラム切替時間1
    ADR0421("421"), //QB、QDプログラム切替時間2
    ADR0422("422"), //QB、QDプログラム切替時間3
    ADR0423("423"), //QB、QDプログラム切替時間4
    ADR0424("424"), //QB、QDプログラム切替時間5
    ADR0425("425"), //QB、QDプログラム切替時間6
    ADR0426("426"), //QB、QDプログラム切替時間7
    ADR0427("427"), //QB、QDプログラム切替時間8
    ADR0428("428"), //QB、QDプログラム切替時間9
    ADR0429("429"), //QB、QDプログラム最大ステップ数
    ADR0430("430"), //QBプログラム電源
    ADR0431("431"), //QDプログラム電源
    ADR0432("432"), //プログラム補液方式選択 I-HDFプログラム使用選択
    ADR0433("433"), //予定補液回数
    ADR0434("434"), //補液バランス制限
    ADR0435("435"), //補液量01
    ADR0436("436"), //補液量02
    ADR0437("437"), //補液量03
    ADR0438("438"), //補液量04
    ADR0439("439"), //補液量05
    ADR0440("440"), //補液量06
    ADR0441("441"), //補液量07
    ADR0442("442"), //補液量08
    ADR0443("443"), //補液量09
    ADR0444("444"), //補液量10
    ADR0445("445"), //補液量11
    ADR0446("446"), //補液量12
    ADR0447("447"), //補液量13
    ADR0448("448"), //補液量14
    ADR0449("449"), //補液量15
    ADR0450("450"), //補液量16
    ADR0451("451"), //回収量01
    ADR0452("452"), //回収量02
    ADR0453("453"), //回収量03
    ADR0454("454"), //回収量04
    ADR0455("455"), //回収量05
    ADR0456("456"), //回収量06
    ADR0457("457"), //回収量07
    ADR0458("458"), //回収量08
    ADR0459("459"), //回収量09
    ADR0460("460"), //回収量10
    ADR0461("461"), //回収量11
    ADR0462("462"), //回収量12
    ADR0463("463"), //回収量13
    ADR0464("464"), //回収量14
    ADR0465("465"), //回収量15
    ADR0466("466"), //回収量16
    ADR0467("467"), //ダイアライザー膜面積
    ADR0468("468"), //VA確認報知基準値(静的静脈圧)
    ADR0469("469"), //VA確認報知基準値(アクセス内圧力比率)
    ADR0470("470"), //静的静脈圧記録 自動実施選択
    ADR0471("471"), //血圧測定 自動実施選択
    ADR0472("472"), //TMP閾値 速度低下
    ADR0473("473"), //TMP閾値 速度復帰
    ADR0474("474"), //補液量 速度低下
    ADR0475("475"), //補液量 速度復帰
    // #11124 2025.08.268 mod 酸素飽和度対応 TDC高村 start
    ADR0476("476"), //ΔSO2低下報知点
    // #11124 2025.08.268 mod 酸素飽和度対応 TDC高村 end
    ADR0477("477"), //
    ADR0478("478"), //
    ADR0479("479"), //
    ADR0480("480"), //
    ADR0481("481"), //
    ADR0482("482"), //
    ADR0483("483"), //
    ADR0484("484"), //
    ADR0485("485"), //
    ADR0486("486"), //
    ADR0487("487"), //
    ADR0488("488"), //
    ADR0489("489"), //
    ADR0490("490"), //
    ADR0491("491"), //
    ADR0492("492"), //
    ADR0493("493"), //
    ADR0494("494"), //
    ADR0495("495"), //
    ADR0496("496"), //
    ADR0497("497"), //
    ADR0498("498"), //
    ADR0499("499"), //
    ADROrdNo("ord_no"), //

    //B項目
    // DBから直接取得できない値は「B000-000」この形で定義する
    ADRB0000("B000-000"),        // ダイアライザ選択
    ADRB0002("B002-002"),        // ガスパージ時間
    ADRB0003("B003-003"),        // 置換洗浄量（透析液）
    ADRB0004("B004-004"),        // 膜洗浄（中空糸）
    ADRBB0030("B030-030"),       // 補液選択
    ADRBB0034("B034-034"),       // 治療モード
    ADRB0031("31"),       //後補液速度上限値
    ADRB0032("32"),       //後補液上限HF値
    ADRB0030("30"),       //補液上限HD+補液値
    ADRB0033("33"),       //後補液上限HD+補液値
    ADRB0034("34"),       //後補液上限OHDF値
    ADRB0035("35"),       //後補液上限OHF値

    ADRB0036("36"),       //治療開始時血流量使用有無

    ADRB0037("37"),       //ＴＭＰゼロ補正警報上限（HD+補液）
    ADRB0038("38"),       //ＴＭＰゼロ補正警報下限（HD+補液）

    ADRB0039("39"),       //後補液　OHDF/OHF　補液速度比率
    ADRB0040("40"),       //後補液　濾過率
    ;

    //値格納用
    public String strKey = null ;

    //String型のコンストラクタ
    private MACHINESETTINGKEY(String strKey) {
      this.strKey = strKey ;
    }

    //String型のGetter
    public String get() {
      return this.strKey ;
    }
  }

  /*
   *装置設定のキー
   */
  private enum MACHINEKEY {

    //装置オプション
    MACOPT_A0113("113"),        //D-FASオプション        2018/11/14 定義未定
//    MACOPT_A0207("207"),        //BV-UFC機能設定        2018/11/14 定義未定
    MACOPT_A0207("opt_3_7"),        //BV-UFC機能設定        2018/11/14 定義未定
    ;

    //値格納用
    public String strKey = null ;

    //String型のコンストラクタ
    private MACHINEKEY(String strKey) {
      this.strKey = strKey ;
    }

    //String型のGetter
    public String get() {
      return this.strKey ;
    }
  }

  /**
   * チェック項目の最大最小値定義など
   *
   */
  public enum CHECKCONST {
    //血流量
    BloodAmount_MAX_VALUE("600"),       //格納許容最大値
    BloodAmount_MIN_VALUE("0"),         //格納許容最小値
    BloodAmount_MAX_LENGTH(3),          //入力文字最大数
    //透析液温度
    DialyzeLiquidTemperature_MAX_VALUE("40.0"),    //格納許容最大値
    DialyzeLiquidTemperature_MIN_VALUE("33.0"),    //格納許容最小値
    DialyzeLiquidTemperature_MAX_LENGTH(4),        //入力文字最大数
    DialyzeLiquidTemperature_DECI(1),               //有効小数位

    //補液
    REPLENISH_SELECT_BEFORE("1"),              //前補液
    REPLENISH_SELECT_AFTER("0"),               //後補液

    //ON/OFF定義
    USE_ON(1) ,               //治療開始時血流量使用有無 ON
    USE_OFF(0) ,              //治療開始時血流量使用有無 OFF

    ;

    //値格納領域
    //int
    private int intval ;
    //String
    private String strval ;
    //double
    private double dblval ;

    //int型のコンストラクタ
    private CHECKCONST(int intval) {
        this.intval = intval ;
    }
    //String型のコンストラクタ
    private CHECKCONST(String strval) {
      this.strval = strval ;
      this.dblval = Double.parseDouble(strval) ;
    }

    //double型のGetter
    public Double getDbl() {
      return dblval ;
    }
    //int型のGetter
    public int getInt() {
      return intval ;
    }
    //String型のGetter
    public String getStr() {
      return strval ;
    }
  }


  //DBアクセッサ
  @Autowired
  private JdbcTemplate jdbcTemplate;

  /**
   * 条件送信データ項目
   *
   */
  public enum SEND_COND_PARAM {
    KIND_CD("kind_cd"),                 //種別
    DATE("date"),                       //発生(作成)日時
    TARGET_MACHINE("target_machine"),   //対象装置
    SEND_COND_DATA("send_cond_data"),   //条件送信データ
    MACHINE_SETTING("machine_setting"), //装置設定値
    MONI_WATCH("moni_watch"),           //モニタ監視設定値
    RESULT("result"),                   //送信結果[種別＝1：条件送信の場合のみ]

    HOST_WATCH("host_watch"),       //ホスト監視"

    MAIN_KEY_MACHINESETTING("dev"),            //装置設定キー
    MAIN_KEY_PATA("pat1"),                     //患者情報Aキー
    MAIN_KEY_PATB("pat2"),                     //患者情報Bキー

    ;
    //値格納領域
    //String
    private String strval ;

    //String型のコンストラクタ
    private SEND_COND_PARAM(String strval) {
      this.strval = strval ;
    }

    //String型のGetter
    public String get() {
      return this.strval ;
    }
  }

  /*
   * 指示共通関数定義情報
   */
  public enum CommonIndConst {
    //装置モード:不明("-1")
    DEVICE_MODE_UNKNOWN("-1"),
    DEVICE_MODE_UNKNOWN_NAME("不明"),
    //装置モード:HD("0")
    DEVICE_MODE_HD("0"),
    DEVICE_MODE_HD_NAME("HD"),
    //装置モード:ECUM("1")
    DEVICE_MODE_ECUM("1"),
    DEVICE_MODE_ECUM_NAME("ECUM"),
    //装置モード:HDF("2")
    DEVICE_MODE_HDF("2"),
    DEVICE_MODE_HDF_NAME("HDF"),
    //装置モード:HF("3")
    DEVICE_MODE_HF("3"),
    DEVICE_MODE_HF_NAME("HF"),
    //装置モード:HD＋補液("4")
    DEVICE_MODE_HD_REP_LIQ("4"),
    DEVICE_MODE_HD_REP_LIQ_NAME("HD＋補液"),
    //装置モード:ECUM+補液("5")
    DEVICE_MODE_ECUM_REP_LIQ("5"),
    DEVICE_MODE_ECUM_REP_LIQ_NAME("ECUM+補液"),
    //装置モード:AFBF("6")
    DEVICE_MODE_AFBF("6"),
    DEVICE_MODE_AFBF_NAME("AFBF"),
    //装置モード:OHDF("7")
    DEVICE_MODE_OHDF("7"),
    DEVICE_MODE_OHDF_NAME("OHDF"),
    //装置モード:OHF("8")
    DEVICE_MODE_OHF("8"),
    DEVICE_MODE_OHF_NAME("OHF"),
    //装置モード:特殊浄化("9")
    DEVICE_MODE_PURIFICATION("9"),
    DEVICE_MODE_PURIFICATION_NAME("特殊浄化"),
    //装置モード:I-HDF("10")
    DEVICE_MODE_PRO_REP_LIQ("10"),
    DEVICE_MODE_PRO_REP_LIQ_NAME("I-HDF"),

    //0：補液速度算出
    RL_CAL_SPEED("0"),
    //1：補液量設定算出
    RL_CAL_AMOUNT("1"),
    //2：比率算出
    RL_CAL_RATIO("2"),
    //3：濾過率算出
    RL_CAL_FILTERRATIO("3"),

    //透析液流量　設定方法
    //1：流量設定
    REPLENISH_SPEED_AMOUNT("1"),
    //2：比率設定
    REPLENISH_SPEED_RATIO("2"),

    //設定のON/OFF(有効/無効)
    SETTING_ON("1"),    //ON(有効)
    SETTING_OFF("0"),   //OFF(無効)

    //通信フォーマット
    COM_FORMAT_A("A"),  //DAB
    COM_FORMAT_B("B"),  //DBB
    COM_FORMAT_C("C"),  //DCS
    COM_FORMAT_D("D"),  //DCG
    COM_FORMAT_E("E"),  //DBG
    COM_FORMAT_F("F"),  //オフライン
    COM_FORMAT_G("G"),  //DBB2
    COM_FORMAT_H("H"),  //DCS2
    COM_FORMAT_I("I"),  //DCS3
    COM_FORMAT_J("J"),  //DBB3
    COM_FORMAT_M("M"),  //DCG2
    COM_FORMAT_N("N"),  //DBG2
    COM_FORMAT_V("V"),  //医器工(Ver4.0)（仮)
    COM_FORMAT_W("W"),  //医器工(Ver3.0) (条件送信が一部可能な装置)
    COM_FORMAT_Y("Y"),  //医器工(Ver2.0) (透析開始終了が拾える装置)
    COM_FORMAT_Z("Z"),  //医器工(Ver1.0) (モニタの読み込み可能な装置)


    //現行の割当コード    比較のためコメントとして残しておく
    //    DEVICE_TYPE_CD_001("001"),//DCS-73(I)
    //    DEVICE_TYPE_CD_002("002"),//DCS-73(H)
    //    DEVICE_TYPE_CD_003("003"),//DCS-27(I)
    //    DEVICE_TYPE_CD_004("004"),//DCS-27(H)
    //    DEVICE_TYPE_CD_005("005"),//DCS-28(I)
    //    DEVICE_TYPE_CD_006("006"),//DCS-28(H)
    //    DEVICE_TYPE_CD_007("007"),//DBB-73(J)
    //    DEVICE_TYPE_CD_008("008"),//DBB-73(G)
    //    DEVICE_TYPE_CD_009("009"),//DBB-27(J)
    //    DEVICE_TYPE_CD_010("010"),//DBB-27(G)
    //    DEVICE_TYPE_CD_011("011"),//DBG-03(N)
    //    DEVICE_TYPE_CD_012("012"),//DBG-03(E)
    //    DEVICE_TYPE_CD_013("013"),//DCG-03(M)
    //    DEVICE_TYPE_CD_014("014"),//DCG-03(D)
    //    DEVICE_TYPE_CD_015("015"),//DCS-72
    //    DEVICE_TYPE_CD_016("016"),//DCS-26
    //    DEVICE_TYPE_CD_017("017"),//DBB-72
    //    DEVICE_TYPE_CD_018("018"),//DBB-26
    //    DEVICE_TYPE_CD_019("019"),//DBG-02
    //    DEVICE_TYPE_CD_020("020"),//DCG-02
    //    DEVICE_TYPE_CD_021("021"),//DAB
    //    DEVICE_TYPE_CD_022("022"),//オフライン
    //    DEVICE_TYPE_CD_023("023"),//医器工(VER1.0)
    //    DEVICE_TYPE_CD_024("024"),//医器工(VER2.0)
    //    DEVICE_TYPE_CD_025("025"),//通信共通(V3.0)
    //    DEVICE_TYPE_CD_026("026"),//DCS-100NX(M)
    //    DEVICE_TYPE_CD_027("027"),//DBB-100NX(N)
    //    DEVICE_TYPE_CD_028("028"),//通信共通(V4.0)
    //    DEVICE_TYPE_CD_029("029"),//DCS-100NX(P)
    //    DEVICE_TYPE_CD_030("030"),//DBB-100NX(Q)

    DEVICE_TYPE_CD_069_DCS_200Si("069"),//DCS-200Si
    DEVICE_TYPE_CD_070_DBB_200Si("070"),//DBB-200Si
    DEVICE_TYPE_CD_071_DCS_100NX("071"),//DCS-100NX
    DEVICE_TYPE_CD_072_DBB_100NX("072"),//DBB-100NX
    DEVICE_TYPE_CD_073_DCG_03("073"),//DCG-03
    DEVICE_TYPE_CD_074_DBG_03("074"),//DBG-03
    DEVICE_TYPE_CD_075_DCS_27("075"),//DCS-27
    DEVICE_TYPE_CD_076_DBB_27("076"),//DBB-27
    DEVICE_TYPE_CD_077_DCS_28("077"),//DCS-28
    DEVICE_TYPE_CD_078_DBB_28("078"),//DBB-28
    DEVICE_TYPE_CD_079_DCS_73("079"),//DCS-73
    DEVICE_TYPE_CD_080_DBB_73("080"),//DBB-73
    DEVICE_TYPE_CD_081_DCG_02("081"),//DCG-02
    DEVICE_TYPE_CD_082_DBG_02("082"),//DBG-02
    DEVICE_TYPE_CD_083_DCS_26("083"),//DCS-26
    DEVICE_TYPE_CD_084_DBB_26("084"),//DBB-26
    DEVICE_TYPE_CD_085_DCS_25("085"),//DCS-25
    DEVICE_TYPE_CD_086_DBB_25("086"),//DBB-25
    DEVICE_TYPE_CD_087_DCS_72("087"),//DCS-72
    DEVICE_TYPE_CD_088_DBB_72("088"),//DBB-72
    DEVICE_TYPE_CD_179_DAB_50Si("179"),//DAB-50Si
    DEVICE_TYPE_CD_180_DAB_70Si("180"),//DAB-70Si
    DEVICE_TYPE_CD_181_DAB_10NX("181"),//DAB-10NX
    DEVICE_TYPE_CD_182_DAB_20NX("182"),//DAB-20NX
    DEVICE_TYPE_CD_183_DAB_30NX("183"),//DAB-30NX
    DEVICE_TYPE_CD_184_DAB_40NX("184"),//DAB-40NX
    DEVICE_TYPE_CD_185_DAB_50NX("185"),//DAB-50NX
    DEVICE_TYPE_CD_186_DAB_70NX("186"),//DAB-70NX
    DEVICE_TYPE_CD_260_DAD_70Si("260"),//DAD-70Si
    DEVICE_TYPE_CD_261_DAD_50NX("261"),//DAD-50NX
    DEVICE_TYPE_CD_262_DRY_50A("262"),//DRY-50A
    DEVICE_TYPE_CD_263_DRY_50B("263"),//DRY-50B
    DEVICE_TYPE_CD_290_DRO_Si("290"),//DRO-Si
    DEVICE_TYPE_CD_291_DRO_NX("291"),//DRO-NX
    DEVICE_TYPE_CD_292_DRO_NXR("292"),//DRO-NXR
    DEVICE_TYPE_CD_301_ADC_27("301"),//ADC-27
    DEVICE_TYPE_CD_302_ADB_27("302"),//ADB-27
    DEVICE_TYPE_CD_303_ADC_26("303"),//ADC-26
    DEVICE_TYPE_CD_304_ADB_26("304"),//ADB-26
    DEVICE_TYPE_CD_305_ADC_25("305"),//ADC-25

    ;

    //値格納用
    public String str ;
    public int intval ;

    //String型のコンストラクタ
    private CommonIndConst(String str) {
      this.str = str ;
      try {
        this.intval = Integer.parseInt(str);
      }
      catch(Exception e)
      {
        this.intval =  -1 ;
      }
    }

    //String型のGetter
    public String get() {
      return this.str ;
    }
//    //int型のGetter
//    public int getInt() {
//      return this.intval ;
//    }
  }

  /**
   *
   * 透析条件項目定義
   * 2018/11/20現在の@治療条件項目に従い定義 TODO:追加、コード変更などがないか確認
   */
  private enum DialysisCond {
    //治療時間
    COND_TOTAL_TIME("1"),
    //VA
    COND_VA("2"),
    //目標体重
    COND_TW("3"),
    //除水量制限
    COND_REMOVE_WATER_LIMIT("4"),
    //ダイアライザ
    COND_DIALYZER("5"),
    //吸着カラム
    COND_ADSORB_EQUIPMENT("6"),
    //1次膜
    COND_FIRST_FILM("7"),
    //2次膜
    COND_SECOND_FILM("8"),
    //穿刺針(せんししん)(A針)
    COND_PUNCTURE_NEEDLE_A("9"),
    //穿刺針(せんししん)(V針)
    COND_PUNCTURE_NEEDLE_V("10"),
    //穿刺針(せんししん)(SN針)
    COND_PUNCTURE_NEEDLE_SN("11"),
    //シングルニードル使用
    COND_SINGLE_NEEDLE("12"),
    //血液回路
    COND_BLOOD_CIRCUIT("13"),
    //血流量
    COND_BLOOD_MEASURE("14"),
    //透析液
    COND_DIALYZE_LIQUID("15"),
    //透析液流量
    COND_DIALYZE_FLOW("16"),
    //透析液
    COND_DIALYZE_MEASURE("17"),
    //透析液温度
    COND_DIALYZE_TEMPERATURE("18"),
    //補液
    COND_REPLENISH_LIQUID("19"),
    //補液量
    COND_REPLENISH_MEASURE("20"),
    //補液選択
    COND_REPLENISH_SELECT("21"),
    //補液使用数
    COND_REPLENISH_USE("22"),
    //補液温度
    COND_REPLENISH_TEMPERATURE("23"),
    //補液速度
    COND_REPLENISH_SPEED("24"),
    //抗凝固剤
    COND_ANTICOAGULAN_LIQUID("25"),
    //抗凝固剤ワンショット量
    COND_ANTICOAGULAN_ONESHOT("26"),
    //抗凝固剤持続速度
    COND_ANTICOAGULAN_SPEED("27"),
    //抗凝固剤持続総量
    COND_ANTICOAGULAN_TOTAL("28"),
    //IP使用選択
    COND_IP_SELECT("29"),
    //IPスタート
    COND_IP_START("30"),
    //IPワンショット量
    COND_IP_MEASURE("31"),
    //IP速度
    COND_IP_SPEED("32"),
    //IP速度最大値
    COND_IP_MAX_SPEED("33"),
    //自動ワンショット
    COND_IP_ONESHOT_START("34"),
    //IP電源自動切り
    COND_IP_AUTO_POWER_OFF("35"),
    //IP電源自動切り時間
    COND_IP_AUTO_POWER_OFF_TIME("36"),
    //IP電源OKモニタ切り
    COND_IP_AUTO_MONITOR_OFF("37"),
    //IP電源OKモニタ切り時間
    COND_IP_AUTO_MONITOR_OFF_TIME("38")
    ;
    //値格納領域
    //String
    private String strval ;

    //String型のコンストラクタ
    private DialysisCond(String strval) {
      this.strval = strval ;
    }

    //String型のGetter
    public String get() {
      return this.strval ;
    }
  }

  /*
   *出力メッセージ
   */
  private enum CHECKMESSAGE {
    MSG000001("該当する指示データがありません。"),
    MSG000001LOG("ord_mainでord_no(%s)に該当するデータがありません。"),
    MSG000002("指示番号が異常です。"),
    MSG000002LOG("ord_no(%s)が存在しないか、数字ではありません。"),
    MSG000003("尿素クリアランス(%s)>血流量(%s)になっています。"),
    MSG000003LOG("尿素クリアランス(%s)>血流量(%s)になっています。"),
    MSG000004("尿素クリアランス(%s)>透析液流量(%s)になっています。"),
    MSG000004LOG("尿素クリアランス(%s)>透析液流量(%s)になっています。"),
    MSG000005("血流量(%s)>血流量設定上限値(%s)になっています。"),
    MSG000005LOG("血流量(%s)>血流量設定上限値(%s)になっています。"),
    MSG000006("透析液温度(%s)<透析液温度下限値(%s)になっています。"),
    MSG000006LOG("透析液温度(%s)<透析液温度下限値(%s)になっています。"),
    MSG000007("透析液温度(%s)>透析液温度上限値(%s)になっています。"),
    MSG000007LOG("透析液温度(%s)>透析液温度上限値(%s)になっています。"),
    MSG000008("補液量上限が未設定です。"),
    MSG000008LOG("補液量上限（A-0383）が未設定です。"),
    MSG000009("補液量上限値(%s)<補液量(%s)になっています。"),
    MSG000009LOG("補液量上限値(%s)<補液量(%s)になっています。"),
    MSG000010("補液速度(%s)が(%s)を超えています。"),
    MSG000010LOG("補液速度(%s)が(%s)を超えています。"),
    MSG000011("%sの補液速度(%s)が上限値(%s)を超えています。 "),
    MSG000011LOG("%sの補液速度(%s)が上限値(%s)を超えています。 "),
    MSG000012("補液計算優先項目が未設定です。"),
    MSG000012LOG("補液計算優先項目(A-0389)が未設定です。"),
    MSG000013("指定の補液計算優先項目が対応していない装置です。"),
    MSG000013LOG("接続装置が指定の補液計算優先項目の対応している100NXシリーズ、DAB、オフライン、共通プロトコルVer1-3以外です。"),
    MSG000014("除水プロ電源設定値が電源ONになっています。"),
    MSG000014LOG("除水プロ電源設定（A-0290）値が電源ONになっています。"),
    MSG000015("装置オプションBV-UFC設定で治療モードがI-HDFです。"),
    MSG000015LOG("装置オプションBV-UFC設定で治療モードがI-HDFです。"),
    MSG000016("ECUM選択値が有効です。"),
    MSG000016LOG("ECUM選択値（A-0016)が有効です。"),
    MSG000017("透析液流量比率制御チェックで接続装置が非対応です。"),
    MSG000017LOG("透析液流量比率制御チェックで接続装置が100NXシリーズ、DAB、オフライン、共通プロトコルVer1-3以外"),
    MSG000018("QDプログラム透析液流量1-10の値が上限下限値の範囲を超えています。"),
    MSG000018LOG("QDプログラム透析液流量1-10の値が上限下限値の範囲を超えています。"),
    MSG000019("QDプログラムチェックで治療モードがI-HDFです。"),
    MSG000019LOG("QDプログラムチェックで治療モードがI-HDFです。"),
    MSG000020("透析液流量比率制御値に設定値がありません。"),
    MSG000020LOG("透析液流量比率制御値(A-0268)に設定値がありません。"),
    MSG000021("QBプログラムチェックで治療モードがI-HDFです。"),
    MSG000021LOG("QBプログラムチェックで治療モードがI-HDFです。"),
    MSG000022("QBプログラム血流量1-10の値が上限下限値の範囲を超えています。"),
    MSG000022LOG("QBプログラム血流量1-10の値が上限下限値の範囲を超えています。"),
    MSG000023("I-HDFプログラム使用選択値の値が１です"),
    MSG000023LOG("I-HDFプログラム使用選択値(A-0432)の値が１です"),
    MSG000024("装置情報が取得できませんでした。"),
    MSG000024LOG("装置マスタの情報が取得できませんでした(ord_no:%s)。"),
    MSG000025("患者情報が取得できませんでした。"),
    MSG000025LOG("患者情報が取得できませんでした(prtid:%s)。"),
    MSG000026("透析実績測定体重が取得できません(体液量算出時治療日:%s)。"),
    MSG000026LOG("透析実績測定体重が取得できません(患者ID:%s 体液量算出時治療日:%s)。"),
    MSG000027("BUN検査項目コードが取得できませんでした。"),
    MSG000027LOG("BUN検査項目コードが取得できませんでした。"),
    MSG000028("BUN検査項目コードの件数が足りませんでした。"),
    MSG000028LOG("BUN検査項目コードの件数が足りませんでした。"),
    MSG000029("体液量算出用のデータの取得に失敗しました。"),
    MSG000029LOG("体液量算出用のデータの取得に失敗しました。"),
    MSG000030("受信データに問題があります。"),
    MSG000030LOG("受信データに問題があります。詳細：%s"),
    MSG000031("ダイアライザマスタの情報が取得できませんでした(ダイアライザコード:%s 施設コード:%s)。"),
    MSG000032("DWが取得できませんでした。"),
    MSG000032LOG("pat_uniqueの身体情報からDWの値が取得できませんでした(ord_no:%s)。"),
    MSG000033("条件指示の血流量(%s)が異常値でした。"),
    MSG000033LOG("条件指示の血流量(%s)が数字ではありませんでした(ord_no:%s)。"),
    MSG000034("条件指示の透析液流量(%s)が異常値でした。"),
    MSG000034LOG("条件指示の透析液流量(%s)が数字ではありませんでした(ord_no:%s)。"),
    MSG000035("条件指示の透析液温度(%s)が異常値でした。"),
    MSG000035LOG("条件指示の透析液温度(%s)が数字ではありませんでした(ord_no:%s)。"),
    MSG000036("装置設定情報が取得できませんでした。"),
    MSG000036LOG("装置設定情報が取得できませんでした(ord_no:%s)。"),
    MSG000037("装置モードが取得できませんでした。"),
    MSG000037LOG("装置モードが取得できませんでした(ord_no:%s)"),
    MSG000038("条件指示の補液量(%s)が異常値でした。"),
    MSG000038LOG("条件指示の補液量(%s)が数字ではありませんでした(ord_no:%s)"),
    MSG000039("条件指示の補液速度(%s)が異常値でした。"),
    MSG000039LOG("条件指示の補液速度(%s)が数字ではありませんでした(ord_no:%s)"),
    MSG000040("尿素クリアランスの値(%s)が異常値でした。"),
    MSG000040LOG("尿素クリアランスの値(%s)が数字ではありませんでした(ord_no:%s)"),
    MSG000041("補液量上限の値(%s)が異常値でした。"),
    MSG000041LOG("補液量上限の値(%s)が数字ではありませんでした"),
    MSG000042("患者名が取得できませんでした。"),
    MSG000042LOG("患者基本情報の患者名が取得できませんでした(pat_id:%s)。"),
    MSG000043("ダイアライザが設定されていません。"),
    MSG000043LOG("ダイアライザが設定されていません。"),
    MSG000044("透析量プログラム設定が取得できませんでした。"),
    MSG000044LOG("透析量プログラム設定が取得できませんでした。"),
    MSG000045("指定されたダイアライザ情報がありません。"),
    MSG000045LOG("指定されたダイアライザ情報がありません。"),
    MSG000046("装置型式が取得できませんでした。"),
    MSG000046LOG("型式コードが取得できませんでした。"),
    MSG000047("TMP閾値 速度低下の値が上限下限値の範囲を超えています。"),
    MSG000047LOG("TMP閾値 速度低下の値が上限下限値の範囲を超えています。"),
    MSG000048("TMP閾値 速度復帰の値が上限下限値の範囲を超えています。"),
    MSG000048LOG("TMP閾値 速度復帰の値が上限下限値の範囲を超えています。"),
    MSG000049("TMP閾値 速度低下の値が速度復帰の値未満です。"),
    MSG000049LOG("TMP閾値 速度低下の値が速度復帰の値未満です。"),
    MSG000050(""),

    //補液速度　部分メッセージ
    REPLENISHSPEED_AFTER("後"),
    REPLENISHSPEED_BEFORE("前"),
    REPLENISHSPEED_OHF("補液上限OHF値"),
    REPLENISHSPEED_OHDF("補液上限OHDF値"),
    REPLENISHSPEED_HDREPLIQ("補液上限HD+補液値"),
    REPLENISHSPEED_HF("補液上限HF値"),
    REPLENISHSPEED_HDF("補液上限HDF値"),
    REPLENISHSPEED_OTHERS("その他(特殊浄化)"),


    ;

    //値格納領域
    private String str ;

    //String型のコンストラクタ
    private CHECKMESSAGE(String str)
    {
      this.str = str ;
    }

    //String型のGetter
    public String get() {
      return str ;
    }
  }

  /*
   *条件送信 送信用データ雛型(ＪＳＯＮ)  ※ord_mainに格納
   */
  private final String INSERT_COND_BASE =
      "{" +
      "\"" + SEND_COND_PARAM.MAIN_KEY_MACHINESETTING.get()  + "\":{}," +
      "\"" + SEND_COND_PARAM.MAIN_KEY_PATA.get() + "\":{}," +
      "\"" + SEND_COND_PARAM.MAIN_KEY_PATB.get() + "\":{}" +
      "}" ;

  //日付の最小値
  public static final Date DATE_MIN = new Date(0) ;
  //フィルタを行わない時のフィルタキー(データとしてDBに格納はしないこと！)
  public static final String FILTER_ANY = "any";

  /**
   * 条件送信データ登録用API(3010)
   * @param
   *    Long オーダー番号                ord_no          数値
   * @return Map<String,Object>
   *    キー:ret 成否 boolean
   *        true:正常
   *        false:エラー
   *    キー:msg メッセージ String
   *        表示エラーメッセージ
   *    キー:logMsg メッセージ String
   *        エラーの詳細
   */
  // TODO: 条件送信データ作成APIを修正する場合はadmin-webの同じクラスも同様の修正が必要
  public Map<String,Object> checkSendCond(
        Long ord_no
      )
  {
    Map<String,Object> retMap = new HashMap<String,Object>() ;

    //WebAPI呼び出し用Bodyデータ組み立て
    String bodyData = "{ordNo:\""+ord_no+"\"}" ;

    //WebAPIメソッド呼び出し(Webは経由しない、直呼び出し)
    ResponseEntity<String> response = postRequest(bodyData) ;

    Boolean ret = true ;
    String msg = "" ;

    //戻り値の変換
    //成功か失敗かでbooleanに振り分け
    if(response.getStatusCode() != HttpStatus.OK)
    {
      //処理が失敗した場合のメッセージの格納
      ret = false ;
      JSONObject str = new JSONObject(response.getBody().toString());
      if (str.has("retMsg")) {
        msg = str.getString("retMsg");
      }
    }

    //戻り値の組み立て
    retMap.put("ret", ret) ;
    retMap.put("msg", msg) ;

    return retMap ;
  }

  /**
   * WebAPI エンドポイント  条件送信画面系3010
   * @param bodydata　JSON形式データ
   *    1.オーダー番号                ord_no          数値文字列
   * @return HttpStatusとメッセージ(String)
   *    HttpStatus
   *        200:正常
   *        400:パラメータのチェック処理でのエラー
   *        500:上記以外のエラー全般
   *    メッセージ
   *        エラーの詳細
   */
  @Transactional
  private ResponseEntity<String> postRequest(
      @Valid @RequestBody String bodydata
  )
  {
//    String bodydata = "" ;
    //レスポンス用    HTTPステータス
    HttpStatus status = HttpStatus.OK;
    //レスポンス用    ResponseEntity  メッセージとステータスを詰める
    ResponseEntity<String> retResEnt = new ResponseEntity<String>(status);
    //レスポンス用    JSON組み立て用
    JSONObject msgJson = null;
    String retMsg = "" ;

    //クラス名の取得(ログ用)
    final String className = new Object(){}.getClass().getEnclosingClass().getName();
    //メソッド名の取得(ログ用)
    final String methodName = new Object(){}.getClass().getEnclosingMethod().getName();

    //開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + "の処理を開始しました。");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>();
    try {
      msgJson = new JSONObject("{}")  ;

      //------------------------------------
      //main処理
      //受信データの取得処理、チェック処理、送信データ作成処理を行う
      //* @param bodydata        ＷｅｂＡＰＩ呼び出し時の受信データ(Ｊｓｏｎ)
      //* @param retVal  <PARAMKEY:value>    パラメータ授受用
      //*        PARAMKEY.STATUS     Httpステータス
      //*        PARAMKEY.RET_MSG    メッセージ
      //*        PARAMKEY.RET_LOG_MSG    メッセージ
      //*        PARAMKEY.INSERT_COND  条件送信データ

      String updateInfo = mainProcess(bodydata,retVal);
      JSONObject jsonBody = new JSONObject(updateInfo);
      String ordNo = jsonBody.get("ordNo").toString();
      JSONObject sendCond = jsonBody.getJSONObject("tmpDeviceSetInfo");

      boolean retBool = setCondInfoToDB(ordNo,sendCond);

      //メソッド終了処理(戻り変数へのセット)
      if(retBool)
      {
        //Httpステータス　OK
        retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
        //メッセージは無し(空文字)
        retMsg = "" ;
        retVal.put(PARAMKEY.RET_MSG, retMsg) ;
        retVal.put(PARAMKEY.RET_LOG_MSG, retMsg) ;
      }
      else
      {
        //Httpステータス　500
        retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
        //メッセージ
        retMsg = "条件送信データ保存エラー" ;
        retVal.put(PARAMKEY.RET_MSG, retMsg) ;
        retMsg = "条件送信データ格納時のerror" ;
        retVal.put(PARAMKEY.RET_LOG_MSG, retMsg) ;
        // ログを出力しロールバック用の例外を投げる
        this.exitMethod(className,methodName,retMsg);
      }

      //---------------------------------------
      //終了ログ
      this.exitMethod(className,methodName,null);

    }
    catch(JSONException e)
    {
      //JSON関連のエラー
      status = HttpStatus.INTERNAL_SERVER_ERROR ;
      retMsg = "条件送信データ構築エラー";
      //一旦戻り値retValに格納("戻り値の組み立て処理"共通化のため)
      retVal.put(PARAMKEY.STATUS, status) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, e.getMessage()) ;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    catch(Exception e)
    {
       //RuntimeExceptionをキャッチする
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }

    //戻り値の組み立て
    try {
      //Httpステータスの取り出し
      status = (HttpStatus)retVal.get(PARAMKEY.STATUS) ;
      //メッセージの取り出し
      retMsg = (String)retVal.get(PARAMKEY.RET_MSG) ;
      String retLogMsg = "";
      if (retVal.containsKey(PARAMKEY.RET_LOG_MSG)) {
        retLogMsg = (String)retVal.get(PARAMKEY.RET_LOG_MSG) ;
      }
      //返却用Ｊｓｏｎオブジェクトにセット
      msgJson.put(PARAMKEY.RET_MSG.get(), retMsg) ;
      msgJson.put(PARAMKEY.RET_LOG_MSG.get(), retLogMsg) ;
    }
    catch(JSONException e)
    {//JSON操作での例外キャッチなので、戻り値のJSONの操作はできないから、ステータスだけ変更
      status = HttpStatus.INTERNAL_SERVER_ERROR ;
    }

    //返却値の生成
    retResEnt = new ResponseEntity<String>(msgJson.toString(),status);

    //ログの出力
    if(HttpStatus.OK != status)
    {//エラーログ
  	  eventLogMessage.setLogMessage(retMsg);
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    //終了ログ
      eventLogMessage.setLogMessage(className + "." + methodName + "の処理を終了しました。");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return retResEnt ;
  }

  /**
   * main処理 条件送信画面系3010
   *受信データの取得処理、チェック処理、送信データ作成処理を行う
   * @param bodydata        ＷｅｂＡＰＩ呼び出し時の受信データ(Ｊｓｏｎ)
   * @param retVal  <PARAMKEY:value>    パラメータ授受用
   *        PARAMKEY.STATUS     Httpステータス
   *        PARAMKEY.RET_MSG    メッセージ
   *        PARAMKEY.RET_LOG_MSG    メッセージ
   *        PARAMKEY.INSERT_COND  条件送信データ
   */
  private String mainProcess(
        String bodydata,
        HashMap<PARAMKEY,Object> retVal
  ) throws JSONException
  {
    //結果返却用     Httpステータス
    HttpStatus status = HttpStatus.OK;
    //結果返却用     エラーメッセージ
    String retMsg = "" ;
    String retLogMsg = "" ;

    //戻り値
    boolean ret = true ;

    //クラス名の取得(ログ用)
    final String className = new Object(){}.getClass().getEnclosingClass().getName();
    //メソッド名の取得(ログ用)
    final String methodName = new Object(){}.getClass().getEnclosingMethod().getName();

    //開始ログ

    EventLogMessage eventLogMessage = new EventLogMessage();
	eventLogMessage.setLogMessage(className + "." + methodName + "の処理を開始しました。");
	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //チェック用メソッドの戻り値
    HashMap<PARAMKEY,Object> retMethod = new HashMap<>() ;

    ServerMainlogWriterRapper(LOGLEVEL.DEBUG,"bodyData=" + bodydata);

    //装置設定JSON(入力用) ※DBから取得
    JSONObject machineSettingDevJson = new JSONObject();
    JSONObject machineSettingPatJson = new JSONObject();

    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    //JSONObject宣言
    //受信パラメータ受付用(送信body情報のJSON文字列格納)
    JSONObject receiveData = null;
    //条件送信データ(DB格納用)
    JSONObject sendCond = new JSONObject(INSERT_COND_BASE) ;

    //各データブロックの取得(受信データのボディからの取得処理)　※ord_noのみになった
    HashMap<PARAMKEY,Object> retValData = new HashMap<>() ;
    ret = this.getDataFromBodyData(bodydata,retValData) ;

    if(ret) {
      //受信データ
      receiveData = (JSONObject)retValData.get(PARAMKEY.RECEIVE_DATA) ;
    }
    else
    {
      //データブロックの取得時にエラー発生
      status = (HttpStatus)retValData.get(PARAMKEY.STATUS);
      retMsg = (String)retValData.get(PARAMKEY.MSG);
      retLogMsg = (String)retValData.get(PARAMKEY.ERRMSG);

      retVal.put(PARAMKEY.STATUS, status) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
    }

    dbgPrint("sendCond:" + sendCond) ;

    //値の取得
    //オーダー番号
    String ordNo = (String)getDataFromJSON(receiveData,PARAMKEY.ORD_NO.get()) ;

    if(null == ordNo || !ordNo.matches(("^[1-9]?[0-9]+$")))
    {//ord_noが存在しないか、数字ではなかったので終了
      retMsg = String.format(CHECKMESSAGE.MSG000002.get(),ordNo)  ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000002LOG.get(),ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
    }

    //データ存在チェック(ord_mainにデータがあるか)＆装置設定情報の取得


    //患者ID,治療日,条件指示情報,風袋・除水情報(装置設定組み立て時にセット)

    HashMap<PARAMKEY,Object> retValOrdMain = new HashMap<>() ;
    ret = getDataFromOrdMain(ordNo,retValOrdMain) ;
    if(!ret)
    {//ord_mainにord_noに対する該当レコードがない
      retMsg = String.format(CHECKMESSAGE.MSG000001.get(),ordNo) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000001LOG.get(),ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
    }

    //DBから取得したデータの変数への格納
    //患者ID
    String patId = (String)retValOrdMain.get(PARAMKEY.PATID);
    //治療日
    String treatDate = (String)retValOrdMain.get(PARAMKEY.TREAT_DATE);
    //施設コード
    String facilityCd = (String)retValOrdMain.get(PARAMKEY.FACILITY_CD);
    //指示：治療条件情報
    JSONObject indCondInfo = (JSONObject)retValOrdMain.get(PARAMKEY.IND_COND_INFO);

    //除水補正
    JSONObject indOffWaterInfo = (JSONObject)retValOrdMain.get(PARAMKEY.IND_OFF_WATER_INFO);

    //実績:体重情報
    JSONObject rstWeightInfo = (JSONObject)retValOrdMain.get(PARAMKEY.RST_WEIGHT_INFO);

    // 装置マスタ情報取得(ord_mainに紐付く情報の抽出)     mst_machine,mst_bed,ord_mainから取得
    HashMap<PARAMKEY,Object> retMaster = this.getDataFromMstMachine(ordNo) ;

    if(null == retMaster)
    {//装置マスタ情報が取得できなかった。
      retMsg = String.format(CHECKMESSAGE.MSG000024.get(),ordNo) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000024LOG.get(),ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
    }

    //装置タイプ(型式)を取得する　"DCS-100NX(M)"といった名前
    //装置タイプ(ord_main,mst_bed,mst_machine,mst_machine_typeから取得：条件(ord_no))

    String machineTypeCd = this.getMachineTypeCdFromDB(ordNo) ;   //装置マスタ、装置機種マスタから取得  ord_main,mst_bed,mst_machine,mst_machine_type

    if(null == machineTypeCd)
    {//型式コードが取得できなかった。
      retMsg = String.format(CHECKMESSAGE.MSG000046.get(),ordNo) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000046LOG.get(),ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
    }


    //装置オプション  ※装置マスタから取得   PARAMKEY.MACHINE_NO
    JSONObject machineOptionJson = (JSONObject)retMaster.get(PARAMKEY.MACHINE_OPTION) ;

    //通信フォーマット  ※装置マスタから取得   PARAMKEY.COM_FORMAT_CD
    String comFormat = (String)retMaster.get(PARAMKEY.COM_FORMAT_CD) ;

    //通信フォーマットが通信共通プロトコルVer1-4以外フラグ  true:Ver1-4以外　false:Ver1-4のどれか
    //※後のいくつかのチェック処理で判定に使用するためフラグとして準備しておく
    boolean flagComFormatNotCommonProtocol = this.getFlagComFormatNotCommonProtocol(comFormat) ;

    //装置設定情報の取得  ※ord_main,pat_mainから取得
    HashMap<PARAMKEY,Object> retMachineSetting = this.getMachineSetting(ordNo) ;
    if(null == retMachineSetting)
    {//装置設定情報が取得できなかった。
      retMsg = String.format(CHECKMESSAGE.MSG000036.get(),ordNo) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000036LOG.get(),ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
    }
    machineSettingDevJson = (JSONObject)retMachineSetting.get(PARAMKEY.DEV) ;
    machineSettingPatJson = (JSONObject)retMachineSetting.get(PARAMKEY.PAT) ;

    //------------------------------------------------------
    //患者情報(pat_unique)取得(dwの取得)
    HashMap<PARAMKEY,Object> retPatUnique = this.getDataFromPatUnique(patId) ;

    String dw = (String)retValOrdMain.get(PARAMKEY.IND_DW);

    if(null == dw) {
      if (null == retPatUnique)
      {//患者情報(の身体情報からdw)が取得できなかった。
        /*
        retMsg = String.format(CHECKMESSAGE.MSG000032.get(),ordNo) ;
        retLogMsg = String.format(CHECKMESSAGE.MSG000032LOG.get(),ordNo) ;
        // ログを出力する
  //      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
  //      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
  //      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
  //      // ログを出力しロールバック用の例外を投げる
  //      this.exitMethod(className,methodName,retMsg);
        */
      } else {
        //DWの取得  ※身体情報から取得(身体情報の中の最新の値のあるDWを取得したもの)
        dw = String.valueOf(retPatUnique.get(PARAMKEY.DW));
      }
    }

    //------------------------------------------------------
    //患者情報(retPatPersonalMain)取得
    HashMap<PARAMKEY,Object> retPatPersonalMain = this.getPatDataFromDB(patId) ;

    if(null == retPatPersonalMain)
    {//患者情報(患者名)が取得できなかった。
      retMsg = String.format(CHECKMESSAGE.MSG000042.get()) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000042LOG.get(),patId) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
    }
    // mod #9485 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。  shiyw start
    String patLastName = ObjectUtils.isEmpty(retPatPersonalMain.get(PARAMKEY.PAT_LAST_NAME)) ? "" : (String) retPatPersonalMain.get(PARAMKEY.PAT_LAST_NAME);
    String patFirstName = ObjectUtils.isEmpty(retPatPersonalMain.get(PARAMKEY.PAT_FIRST_NAME)) ? "" : (String) retPatPersonalMain.get(PARAMKEY.PAT_FIRST_NAME);
    // mod #9485 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。 shiyw end
    // #11827 2025.05.16 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
    // String patName = patLastName + CONST_NAME_SEP + patFirstName ;
    // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
    String patName;
    try {
    // 施設設定値取得
    nameConcatService.ReadFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.VIRTUAL_TERMINAL_NAME_CONCAT_SETTING);
    // 姓名結合
      patName = nameConcatService.NameConcat(patFirstName, patLastName);
    } finally {
      nameConcatService.ClearFacilitySettingValue();
    }
    // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
    // #11827 2025.05.14 mod 仮想端末姓名結合設定に準拠 TDC米沢 start

    //各変数の値を条件指示情報、装置設定から取得
    String tmp ;

    //血流量            ・ord_main-指示：治療条件情報(ind_cond_info)から取得　key:"14" 整数3桁小数0桁（0～600）
    Double condBloodMeasure = null ;
    tmp = this.getDataFromIndCond(indCondInfo,DialysisCond.COND_BLOOD_MEASURE.get());
    try{
      // アドレス335設定値
      condBloodMeasure = Double.parseDouble(tmp) ;
    }
    catch(Exception e)
    {//条件指示の血流量のパースに失敗した(数値ではなかった)。
    /*
      retMsg = String.format(CHECKMESSAGE.MSG000033.get(),tmp) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000033LOG.get(),tmp,ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
      */
    }
    //透析液流量　・ord_main-指示：治療条件情報(ind_cond_info)から取得　key:"16" 整数3桁小数0桁（300～700
    Double condDialyzeFlow = null ;
    tmp = this.getDataFromIndCond(indCondInfo,DialysisCond.COND_DIALYZE_FLOW.get());
    try{
      condDialyzeFlow = Double.parseDouble(tmp) ;
    }
    catch(Exception e)
    {//条件指示の透析液流量のパースに失敗した(数値ではなかった)。
    /*
      retMsg = String.format(CHECKMESSAGE.MSG000034.get(),tmp) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000034LOG.get(),tmp,ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
      */
    }
    //透析液温度　・ord_main-指示：治療条件情報(ind_cond_info)から取得　key:"18" 整数2桁小数1桁（33.0～40.0)
    Double condDialyzeTemperature = null ;
    tmp = this.getDataFromIndCond(indCondInfo,DialysisCond.COND_DIALYZE_TEMPERATURE.get());
    try{
      condDialyzeTemperature = Double.parseDouble(tmp) ;
    }
    catch(Exception e)
    {//条件指示の透析液温度のパースに失敗した(数値ではなかった)。
    /*
      retMsg = String.format(CHECKMESSAGE.MSG000035.get(),tmp) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000035LOG.get(),tmp,ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
      */
    }

    //補液量　       ・ord_main-指示：治療条件情報(ind_cond_info)から取得　key:"20" 整数3桁小数1桁（HDF、HF：0.0～30.0　HD＋補液：0.0～99.9　OHDF、OHF：0.0～192.0）
    Double condReplenishMeasure = null ;
    tmp = this.getDataFromIndCond(indCondInfo,DialysisCond.COND_REPLENISH_MEASURE.get());
    try{
      condReplenishMeasure = Double.parseDouble(tmp) ;
    }
    catch(Exception e)
    {//条件指示の補液量のパースに失敗した(数値ではなかった)。
    /*
      retMsg = String.format(CHECKMESSAGE.MSG000038.get(),tmp) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000038LOG.get(),tmp,ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
      */
    }
    //補液速度　     ・ord_main-指示：治療条件情報(ind_cond_info)から取得　key:"24" 整数3桁小数2桁（透析:0.0～24.00  特殊浄化:0.0～999.00）
    Double condReplenishSpeed = null ;
    tmp = this.getDataFromIndCond(indCondInfo,DialysisCond.COND_REPLENISH_SPEED.get());
    try{
      condReplenishSpeed = Double.parseDouble(tmp) ;
    }
    catch(Exception e)
    {//条件指示の補液速度のパースに失敗した(数値ではなかった)。
    /*
      retMsg = String.format(CHECKMESSAGE.MSG000039.get(),tmp) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000039LOG.get(),tmp,ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
      */
    }

    //補液選択の取得（条件指示から）　1=前補液、0=後補液
    String condReplenishSelect = this.getDataFromIndCond(indCondInfo,DialysisCond.COND_REPLENISH_SELECT.get());

    //装置設定Json　キーパス
    final String KEYPATH_DIA_DEV_A = "A" ;
    final String KEYPATH_OPE_DEV_A = "A" ;
    final String KEYPATH_OPE_DEV_B = "B" ;
    final String KEYPATH_DFAS_DEV_B = "B" ;
    final String KEYPATH_BVUFC_DEV_A = "A" ;
    final String KEYPATH_UFC_DEV_A = "A" ;
    final String KEYPATH_ECUM_DEV_A = "A" ;
    final String KEYPATH_IHDF_DEV_A = "A" ;
    final String KEYPATH_QBQD_DEV_A = "A" ;
    final String KEYPATH_WAR_DEV_A = "A" ;

    //装置モード      mst_treatmentから取得：条件(ord_no)
    String treatModeCd = (String)this.getDeviceModeFromMstTreatment(ordNo) ;

    if(null == treatModeCd)
    {//装置モードが取得できなかった。
    /*
      retMsg = String.format(CHECKMESSAGE.MSG000037.get(),ordNo) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000037LOG.get(),ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
      */
    }
    CommonIndConst treatMode = this.getTreatModeEnumKey(treatModeCd) ;   //処理しやすいようにEnumキー化(CommonIndConst)

    //透析量プログラム使用設定
    String alqdFloodVolProgSetting  = this.getItemFromJson(machineSettingDevJson,KEYPATH_DIA_DEV_A,MACHINESETTINGKEY.ADR0282.get()) ;

    //血流量設定上限値
    String bloodAmountUpperLimit = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0179.get()) ;

    //透析液温度上限値
    String dialyzeLiquidTemperatureUpperLimit = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0182.get()) ;
    //透析液温度下限値
    String dialyzeLiquidTemperatureUnderLimit = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0183.get()) ;

    //補液計算優先項目
    String replenishMeasureCalPrior = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0389.get()) ;
    //補液量上限
    String replenishMeasureUperLimit = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0383.get()) ;

    //BV-UFC設定値
    String itemA0196 = this.getItemFromJson(machineSettingDevJson,KEYPATH_BVUFC_DEV_A,MACHINESETTINGKEY.ADR0196.get()) ;
    //装置オプションBV-UFC機能（A-0207)の取得(A-0207は、装置マスタの装置オプションの設定項目(A-0207))
    String itemA0207_OPT = this.getItemFromJson(machineOptionJson,MACHINEKEY.MACOPT_A0207.get());

    //除水プロ電源設定
    String itemA0290 = this.getItemFromJson(machineSettingDevJson,KEYPATH_UFC_DEV_A,MACHINESETTINGKEY.ADR0290.get()) ;
    //ECUM選択値
    String itemA0016 = this.getItemFromJson(machineSettingDevJson,KEYPATH_ECUM_DEV_A,MACHINESETTINGKEY.ADR0016.get()) ;

    //透析液流量比率制御値設定方法
    String itemA0268 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0268.get()) ;

    //I-HDFプログラム使用選択値
    String itemA0432 = this.getItemFromJson(machineSettingDevJson,KEYPATH_IHDF_DEV_A,MACHINESETTINGKEY.ADR0432.get()) ;

    //補液上限HDF値(A-0185)
    String itemA0185 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0185.get()) ;
    //後補液上限HDF値(B-0031)
    String itemB0031 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_B,MACHINESETTINGKEY.ADRB0031.get()) ;
    //補液上限HF値(A-0186)
    String itemA0186 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0186.get()) ;
    //後補液上限HF値(B-0032)
    String itemB0032 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_B,MACHINESETTINGKEY.ADRB0032.get()) ;
    //補液上限HD+補液値(B-0030)
    String itemB0030 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_B,MACHINESETTINGKEY.ADRB0030.get()) ;
    //後補液上限HD+補液値(B-0033)
    String itemB0033 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_B,MACHINESETTINGKEY.ADRB0033.get()) ;
    //補液上限OHDF値(A-0396)
    String itemA0396 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0396.get()) ;
    //後補液上限OHDF値(B-0034)
    String itemB0034 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_B,MACHINESETTINGKEY.ADRB0034.get()) ;
    //補液上限OHF値(A-0397)
    String itemA0397 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0397.get()) ;
    //後補液上限OHF値(B-0035)
    String itemB0035 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_B,MACHINESETTINGKEY.ADRB0035.get()) ;
    // TMP閾値 速度低下(A-0472)
    String itemA0472 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0472.get()) ;
    // TMP閾値 速度復帰(A-0473)
    String itemA0473 = this.getItemFromJson(machineSettingDevJson,KEYPATH_OPE_DEV_A,MACHINESETTINGKEY.ADR0473.get()) ;
    // TMP自動設定警報限界上限(A-0130)
    String itemA0130 = this.getItemFromJson(machineSettingDevJson,KEYPATH_WAR_DEV_A,MACHINESETTINGKEY.ADR0130.get()) ;
    // TMP自動設定警報限界下限(A-0131)
    String itemA0131 = this.getItemFromJson(machineSettingDevJson,KEYPATH_WAR_DEV_A,MACHINESETTINGKEY.ADR0131.get()) ;
    // TMP固定警報上限(A-0132)
    String itemA0132 = this.getItemFromJson(machineSettingDevJson,KEYPATH_WAR_DEV_A,MACHINESETTINGKEY.ADR0132.get()) ;
    // TMP固定警報下限(A-0133)
    String itemA0133 = this.getItemFromJson(machineSettingDevJson,KEYPATH_WAR_DEV_A,MACHINESETTINGKEY.ADR0133.get()) ;


    //治療開始時血流量使用有無(B-0036)
    String itemB0036 = this.getItemFromJson(machineSettingDevJson,KEYPATH_DFAS_DEV_B,MACHINESETTINGKEY.ADRB0036.get()) ;

    //QB,QD 使用ステップ数
    String itemA0429 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0429.get()) ;

    //QBプログラム血流量1-10
    String itemA0400 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0400.get()) ;
    String itemA0401 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0401.get()) ;
    String itemA0402 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0402.get()) ;
    String itemA0403 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0403.get()) ;
    String itemA0404 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0404.get()) ;
    String itemA0405 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0405.get()) ;
    String itemA0406 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0406.get()) ;
    String itemA0407 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0407.get()) ;
    String itemA0408 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0408.get()) ;
    String itemA0409 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0409.get()) ;
    //QBプログラム血流量1-10
    String itemA0410 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0410.get()) ;
    String itemA0411 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0411.get()) ;
    String itemA0412 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0412.get()) ;
    String itemA0413 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0413.get()) ;
    String itemA0414 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0414.get()) ;
    String itemA0415 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0415.get()) ;
    String itemA0416 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0416.get()) ;
    String itemA0417 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0417.get()) ;
    String itemA0418 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0418.get()) ;
    String itemA0419 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0419.get()) ;

    //QBプログラム値(A-0430)の取得
    String itemA0430 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0430.get()) ;
    //QDプログラム値(A-0431)の取得
    String itemA0431 = this.getItemFromJson(machineSettingDevJson,KEYPATH_QBQD_DEV_A,MACHINESETTINGKEY.ADR0431.get()) ;

    //型式が100NXシリーズ・DABまたは、通信フォーマットがオフライン・通信共通プロトコルVer1-3のフラグ
    // true:型式が100NXシリーズ・DABまたは、通信フォーマットがオフライン・通信共通プロトコルVer1-3
    boolean flagNXOrComProtocol123 = this.getFlagNXOrComProtocol123(machineTypeCd,comFormat);

    //補液を使用するかどうかのフラグ(treatModeがHD/ECUM/I-HDF) true:補液を使用する
    boolean flagTreatModeIsReplenishment = this.getFlagTreatModeIsReplenishment(treatMode);


    //--------------------------------------------------------------------------------
    //ダイアライザー情報の取得（８．尿素クリアランスチェック処理と警報設定値の組み立てに使う）
    //「条件指示」情報の項目番号(DialysisCond.COND_DIALYZER:5)が血液浄化器(ダイアライザー)の値がダイアライザーコードなので、それを取得
    //そのダイアライザコードをキーに、ダイアライザーマスタから情報を取得する。
    //  ※ダイアライザーコードがない場合がある？　その場合、尿素クリアランスも取得できないはず。
    String dialyzerCd = this.getDataFromIndCond(indCondInfo,DialysisCond.COND_DIALYZER.get());

    if(null == dialyzerCd || "null".equals(dialyzerCd))
    {//ダイアライザが設定されていない
      /*
      retMsg = String.format(CHECKMESSAGE.MSG000043.get(),tmp) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000043LOG.get(),tmp,ordNo) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
      */
    }

    HashMap<PARAMKEY,Object> dialyzerInfo = null;
    if (dialyzerCd != null) {
      dialyzerInfo = this.getDialyzerInfoFromDB(
          dialyzerCd,
          facilityCd
          ) ;
    }
    // 存在しないデータがあってもデータなしとして処理継続させるため下記の条件追加
    if (null != dialyzerInfo) {

      if(null == dialyzerInfo)
      {//コードに対応するダイアライザ情報がない
        retMsg = String.format(CHECKMESSAGE.MSG000045.get(),tmp,ordNo) ;
        retLogMsg = String.format(CHECKMESSAGE.MSG000045LOG.get(),tmp,ordNo) ;
        retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
        retVal.put(PARAMKEY.RET_MSG, retMsg) ;
        retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
        retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
        // ログを出力しロールバック用の例外を投げる
        this.exitMethod(className,methodName,retLogMsg);
      }

      // pat2へダイアライザ情報登録(ダイアライザ選択・ガスパージ時間・置換洗浄量（透析液）・膜洗浄（中空糸))
      if (dialyzerInfo.get(PARAMKEY.DIALYZER_TYPE) == null || String.valueOf(dialyzerInfo.get(PARAMKEY.DIALYZER_TYPE)).equals("null")) {
        // デフォルト値
        machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0000.get(), "0");
      } else {
        machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0000.get(), dialyzerInfo.get(PARAMKEY.DIALYZER_TYPE));
      }

      if (dialyzerInfo.get(PARAMKEY.GAS_PURGE_TIME) == null || String.valueOf(dialyzerInfo.get(PARAMKEY.GAS_PURGE_TIME)).equals("null")) {
        // デフォルト値
        machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0002.get(), 5);
      } else {
        machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0002.get(), dialyzerInfo.get(PARAMKEY.GAS_PURGE_TIME));
      }

      if (dialyzerInfo.get(PARAMKEY.SUBSTITUENT_WASH_AMT) == null || String.valueOf(dialyzerInfo.get(PARAMKEY.SUBSTITUENT_WASH_AMT)).equals("null")) {
        // デフォルト値
        machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0003.get(), 1000);
      } else {
        machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0003.get(), dialyzerInfo.get(PARAMKEY.SUBSTITUENT_WASH_AMT));
      }

      if (dialyzerInfo.get(PARAMKEY.MEMBRANE_WASH) == null || String.valueOf(dialyzerInfo.get(PARAMKEY.MEMBRANE_WASH)).equals("null")) {
        // デフォルト値
        machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0004.get(), "0");
      } else {
        machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0004.get(), dialyzerInfo.get(PARAMKEY.MEMBRANE_WASH));
      }

      //尿素クリアランスの取得   ※ダイアライザマスタから取得
      tmp = (String)dialyzerInfo.get(PARAMKEY.UREACLEARANCE) ;
      Double ureaClearance = null ;
      try{
        ureaClearance = Double.parseDouble(tmp) ;
      }
      catch(Exception e)
      {//尿素クリアランスのパースに失敗した(数値ではなかった)。
        retMsg = String.format(CHECKMESSAGE.MSG000040.get(),tmp,ordNo) ;
        retLogMsg = String.format(CHECKMESSAGE.MSG000040LOG.get(),tmp,ordNo) ;
        retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
        retVal.put(PARAMKEY.RET_MSG, retMsg) ;
        retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
        retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
        // ログを出力しロールバック用の例外を投げる
        this.exitMethod(className,methodName,retLogMsg);
      }

      //======================================
      //8．尿素クリアランスチェック処理
      //======================================
      if (condBloodMeasure != null && condDialyzeFlow != null) {

        retMethod = this.checkUreaClearance(
            flagComFormatNotCommonProtocol,     //通信フォーマットが通信共通プロトコルVer1-4以外フラグ
            ureaClearance,                      //尿素クリアランス
            condBloodMeasure,                   //血流量
            condDialyzeFlow                     //透析液流量
        ) ;

        if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
        {
          retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
          retMsg = (String)retMethod.get(PARAMKEY.RET_MSG);
          retVal.put(PARAMKEY.RET_MSG, retMsg) ;
          retLogMsg = retMsg;
          if (retMethod.containsKey(PARAMKEY.RET_LOG_MSG)) {
            retLogMsg = (String)retMethod.get(PARAMKEY.RET_LOG_MSG);
          }
          retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
          retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
          // ログを出力しロールバック用の例外を投げる
          eventLogMessage.setLogMessage(retMsg);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        }
      }

    }

    // add FNSI-条件送信結果対応 李 start
    else {
      // デフォルト値
      machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0000.get(), "0");
      // デフォルト値
      machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0002.get(), 5);
      // デフォルト値
      machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0003.get(), 1000);
      // デフォルト値
      machineSettingPatJson.put(MACHINESETTINGKEY.ADRB0004.get(), "0");
    }
    // add FNSI-条件送信結果対応 李 end


    //======================================
    //9．透析量プログラムチェック処理
    //======================================
    String itemAOrdNo = this.getItemFromJson(machineSettingDevJson, KEYPATH_DIA_DEV_A, MACHINESETTINGKEY.ADROrdNo.get());
    retMethod = this.checkAlqdFloodVolProg(
        alqdFloodVolProgSetting,        //透析量プログラム使用設定
        this.getAlqdFloodVolProgFromDB(),    //透析量プログラム使用設定(システム設定)
        dw,                             //ドライウエイト
        treatMode,                      //装置治療モード
        patId,                          //患者ID
        flagComFormatNotCommonProtocol, //通信フォーマットが通信共通プロトコルVer1-4以外フラグ
        itemAOrdNo                       //液体量算出透析日のord_no
    ) ;

    if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
    {
      retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
      retMsg = (String)retMethod.get(PARAMKEY.RET_MSG);
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retLogMsg = retMsg;
      if (retMethod.containsKey(PARAMKEY.RET_LOG_MSG)) {
        retLogMsg = (String)retMethod.get(PARAMKEY.RET_LOG_MSG);
      }
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      eventLogMessage.setLogMessage(retMsg);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }

    //checkAlqdFloodVolProg(9．透析量プログラムチェック処理)で取得した値の格納
    //透析量プログラム設定(システム）
    String alqdFloodVolProgSettingSys = (String)retMethod.get(PARAMKEY.AFVPROG_SYS);
    //透析量プログラム設定(A-0282)
    alqdFloodVolProgSetting = (String)retMethod.get(PARAMKEY.AFVPROG);
    //透析量プログラム使用フラグ
    boolean flagAlqdFloodVolProgSysOn = (Boolean)retMethod.get(PARAMKEY.AFVPROG_SYS_ON);

    //======================================
    //****現行にあり**** 10．血流量設定上限値チェック処理
    //======================================
    if (condBloodMeasure != null) {
    retMethod = this.checkBloodAmountSetting(
            bloodAmountUpperLimit,      //血流量設定上限値
            condBloodMeasure            //血流量
        ) ;

    if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
    {
      /*
      retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
      retVal.put(PARAMKEY.RET_MSG, (String)retMethod.get(PARAMKEY.RET_MSG)) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, (String)retMethod.get(PARAMKEY.RET_LOG_MSG)) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retMsg);
      */
    }
    }

    //======================================
    //****現行にあり**** 11．透析液温度上下限値チェック処理
    //======================================
    if (condDialyzeTemperature != null) {
    retMethod = this.checkDialyzeLiquidTemperatureSetting(
        dialyzeLiquidTemperatureUpperLimit, //透析液温度上限値
        dialyzeLiquidTemperatureUnderLimit, //透析液温度下限値
        condDialyzeTemperature      //透析液温度
    ) ;

    if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
    {
      /*
      retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
      retVal.put(PARAMKEY.RET_MSG, (String)retMethod.get(PARAMKEY.RET_MSG)) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, (String)retMethod.get(PARAMKEY.RET_LOG_MSG)) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retMsg);
      */
    }
    }

    //======================================
    //14．補液計算優先項目チェック処理
    //======================================

    retMethod = this.checkReplenishCalcSetting(
        replenishMeasureCalPrior,           //補液計算優先項目
        treatMode,                          //装置治療モード
        flagNXOrComProtocol123,             //型式が100NXシリーズ・DABまたは通信フォーマットがオフライン・通信共通プロトコルVer1-3かどうかのフラグ
        flagComFormatNotCommonProtocol      //通信フォーマットが通信共通プロトコルVer1-4以外フラグ
    ) ;

    if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
    {
      /*
      retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
      retVal.put(PARAMKEY.RET_MSG, (String)retMethod.get(PARAMKEY.RET_MSG)) ;
        retVal.put(PARAMKEY.RET_LOG_MSG, (String)retMethod.get(PARAMKEY.RET_LOG_MSG)) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retMsg);
      */
    }

    if (condReplenishMeasure != null) {
      if(false == flagTreatModeIsReplenishment)
      {
        //補液を使用する場合は12,13のチェックをします

        //======================================
        //****現行にあり**** 12．補液量上限値チェック処理
        //======================================
        retMethod = this.checkReplenishMeasureSetting(
            replenishMeasureCalPrior,   //補液計算優先項目
            replenishMeasureUperLimit,  //補液量上限
            treatMode,              //装置治療モード
            machineTypeCd,            //型式コード
            condReplenishMeasure    //補液量
        ) ;

        if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
        {
          /*
          retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
          retVal.put(PARAMKEY.RET_MSG, (String)retMethod.get(PARAMKEY.RET_MSG)) ;
          retVal.put(PARAMKEY.RET_LOG_MSG, (String)retMethod.get(PARAMKEY.RET_LOG_MSG)) ;
          retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
          // ログを出力しロールバック用の例外を投げる
          this.exitMethod(className,methodName,retMsg);
          */
        }
      }

      if (condReplenishSpeed != null) {
      //======================================
      //****現行にあり**** 13．補液速度上下限値チェック処理
      //======================================
      retMethod = this.checkReplenishSpeedSetting(
          itemA0185,              //補液上限HDF値
          itemB0031,              //後補液上限HDF値
          itemA0186,              //補液上限HF値
          itemB0032,              //後補液上限HF値
          itemB0030,              //補液上限HD+補液値
          itemB0033,              //後補液上限HD+補液値
          itemA0396,              //補液上限OHDF値
          itemB0034,              //後補液上限OHDF値
          itemA0397,              //補液上限OHF値
          itemB0035,              //後補液上限OHF値
          replenishMeasureCalPrior,//補液計算優先項目
          condReplenishSelect,    //補液選択
          treatMode,              //装置治療モード
          condReplenishSpeed      //補液速度
      ) ;
      if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
      {
        /*
        retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
        retVal.put(PARAMKEY.RET_MSG, (String)retMethod.get(PARAMKEY.RET_MSG)) ;
        retVal.put(PARAMKEY.RET_LOG_MSG, (String)retMethod.get(PARAMKEY.RET_LOG_MSG)) ;
        retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
        // ログを出力しロールバック用の例外を投げる
        this.exitMethod(className,methodName,retMsg);
        */
      }
      }
    }

    //======================================
    //15．BV-UFCチェック処理
    //======================================

    retMethod = this.checkBVUFCSetting(
        itemA0196,                      //BV-UFC設定値(装置設定から取得)
        itemA0207_OPT,                  //BV-UFC機能設定(装置マスタの装置オプションから取得)
        itemA0290,                      //除水プロ電源設定
        itemA0016,                      //ECUM選択値
        treatMode,                      //装置治療モード
        machineTypeCd,                  //型式コード
        flagComFormatNotCommonProtocol //通信フォーマットが通信共通プロトコルVer1-4以外フラグ
    ) ;

    if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
    {
      /*
      retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
      retVal.put(PARAMKEY.RET_MSG, (String)retMethod.get(PARAMKEY.RET_MSG)) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, (String)retMethod.get(PARAMKEY.RET_LOG_MSG)) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retMsg);
      */
    }

    //======================================
    //16．透析液流量比率制御チェック処理
    //======================================

    retMethod = this.checkDialyzeFlowSetting(
        itemA0268,                          //透析液流量比率制御値設定方法
        flagNXOrComProtocol123,             //型式が100NXシリーズ・DABまたは通信フォーマットがオフライン・通信共通プロトコルVer1-3かどうかのフラグ
        flagComFormatNotCommonProtocol      //通信フォーマットが通信共通プロトコルVer1-4以外フラグ
    ) ;

    if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
    {
      /*
      retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
      retVal.put(PARAMKEY.RET_MSG, (String)retMethod.get(PARAMKEY.RET_MSG)) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, (String)retMethod.get(PARAMKEY.RET_LOG_MSG)) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retMsg);
      */
    }

    //======================================
    //17．QDプログラムチェック処理
    //======================================

    //QD,QB ステップ数の数値化
    int intItemA0429 = 0 ;
    try {
      intItemA0429 = Integer.parseInt(itemA0429);

      //負の数対策
      if(intItemA0429 < 0 ) intItemA0429 = 0 ;
    }
    catch(Exception e)
    {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(retMethod.toString());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      //sublist(0,0)で空のリスト渡しになります
      intItemA0429 = 0 ;
    }

    try {
      retMethod = this.checkQDProgramSetting(
        itemA0431,                          //QDプログラム値
        itemA0268,                           //透析流量比率設定方法
        Arrays.asList(
          itemA0410,                          //QDプログラム血流量1
          itemA0411,                          //QDプログラム血流量2
          itemA0412,                          //QDプログラム血流量3
          itemA0413,                          //QDプログラム血流量4
          itemA0414,                          //QDプログラム血流量5
          itemA0415,                          //QDプログラム血流量6
          itemA0416,                          //QDプログラム血流量7
          itemA0417,                          //QDプログラム血流量8
          itemA0418,                          //QDプログラム血流量9
          itemA0419                          //QDプログラム血流量10
        ).subList(0, intItemA0429),
        treatMode,                          //装置治療モード
        machineTypeCd,                      //型式コード
        flagComFormatNotCommonProtocol      //通信フォーマットが通信共通プロトコルVer1-4以外フラグ
    ) ;
    }
    catch(Exception e)
    {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }

    if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
    {
      /*
      retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
      retVal.put(PARAMKEY.RET_MSG, (String)retMethod.get(PARAMKEY.RET_MSG)) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, (String)retMethod.get(PARAMKEY.RET_LOG_MSG)) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retMsg);
      */
    }

    //======================================
    //18．QBプログラムチェック処理
    //======================================

    retMethod = this.checkQBProgramSetting(
        itemA0430,                          //QBプログラム値
        bloodAmountUpperLimit,              //血流量設定上限値
        Arrays.asList(
          itemA0400,                          //QBプログラム血流量1
          itemA0401,                          //QBプログラム血流量2
          itemA0402,                          //QBプログラム血流量3
          itemA0403,                          //QBプログラム血流量4
          itemA0404,                          //QBプログラム血流量5
          itemA0405,                          //QBプログラム血流量6
          itemA0406,                          //QBプログラム血流量7
          itemA0407,                          //QBプログラム血流量8
          itemA0408,                          //QBプログラム血流量9
          itemA0409                          //QBプログラム血流量10
        ).subList(0, intItemA0429),
        treatMode                           //装置治療モード
    ) ;

    if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
    {
      /*
      retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
      retVal.put(PARAMKEY.RET_MSG, (String)retMethod.get(PARAMKEY.RET_MSG)) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, (String)retMethod.get(PARAMKEY.RET_LOG_MSG)) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retMsg);
      */
    }

    //======================================
    //19．I-HDFプログラムチェック処理
    //======================================

    retMethod = this.checkIHDFProgramSetting(
        itemA0432,          //I-HDFプログラム使用選択値
        treatMode,          //装置治療モード
        comFormat           //通信フォーマット
    ) ;

    //======================================
    //20．TMP補液制御チェック処理
    //======================================

    eventLogMessage.setLogMessage("20．TMP補液制御チェック処理 開始");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    retMethod = this.checkTmpControlSetting(
        itemA0472,          //TMP閾値 速度低下
        itemA0473,          //TMP閾値 速度復帰
        itemA0130,          //TMP自動設定警報限界上限
        itemA0131,          //TMP自動設定警報限界下限
        itemA0132,          //TMP固定警報上限
        itemA0133,          //TMP固定警報下限
        machineTypeCd,      //型式コード
        treatMode,          //装置治療モード
        flagComFormatNotCommonProtocol
    ) ;

    if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
    {
      /*
      retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
      retVal.put(PARAMKEY.RET_MSG, (String)retMethod.get(PARAMKEY.RET_MSG)) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, (String)retMethod.get(PARAMKEY.RET_LOG_MSG)) ;
      retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
      // ログを出力しロールバック用の例外を投げる
      this.exitMethod(className,methodName,retMsg);
      */
    }

    //======================================
    //条件送信データの組み立て
    //======================================

    //TODO:実績：体重情報 で前体重がnullの場合、風袋・除水情報を入れない
    //TODO:現行の条件送信のチェック部分を実装
    //TODO:過去に測定したことのある(値がある)場合の処理

    //---------------------------------------
    //情報の組み立て 　ここから

    //処理用変数
    String retStr = null ;

    //装置設定JSON(出力用)
    JSONObject machineSettingJsonForSendCond = new JSONObject();
    //患者情報A
    JSONObject patInfoAJsonForSendCond = new JSONObject();
    //患者情報B
    JSONObject patInfoBJsonForSendCond = new JSONObject();

    //---------------------------------------
    //装置設定の組み立て
    //    設定先:machineSettingJsonForSendCond

    // ***** 透析条件(指示情報)から取得 してセット*****

    //装置設定アドレス(String)
    final String addrParams[] = {
      //0  患者コード    DBから取得してセット
      //1  患者コード   何も入れない
      //2  患者コード   何も入れない
      //3  患者コード   何も入れない
      //4  患者名   DBから取得してセット
      //5  患者名   何も入れない
      //6  患者名   何も入れない
      //7  患者名   何も入れない
      //8  患者名   何も入れない
      //9  患者名   何も入れない
      //10  患者名   何も入れない
      //11  患者名   何も入れない
      //12  患者名   何も入れない
      //13  患者名   何も入れない
      //14 指示：透析時間
      //15 治療モード　DB:MST_TREATMENTから取得 治療モード
      MACHINESETTINGKEY.ADR0016.get(),   //ＥＣＵＭ選択
      MACHINESETTINGKEY.ADR0017.get(),   //ＥＣＵＭ量
      MACHINESETTINGKEY.ADR0018.get(),   //ＥＣＵＭ時間
      MACHINESETTINGKEY.ADR0019.get(),   //ＥＣＵＭ時間
      //20 複雑 除水目標値
      MACHINESETTINGKEY.ADR0021.get(),   //除水計算選択
      MACHINESETTINGKEY.ADR0022.get(),   //除水計算優先項目選択
      //23 指示：シングルニードル電源
      MACHINESETTINGKEY.ADR0024.get(),   //シングルニードル切替圧上限
      MACHINESETTINGKEY.ADR0025.get(),   //シングルニードル切替圧下限
      //26 指示：透析液温度
      //27 指示：透析液流量
      //28 指示：血流量
      //29 指示：IP使用選択
      //30 指示：IP速度
      //31 指示：IPスタート
      //32 指示：自動ワンショット量
      //33 指示：IPワンショット量
      //34 指示：IP電源OKモニタ切り
      //35 指示：IP電源OKモニタ切り時間
      //36 指示：IP電源自動切り
      //37 指示：IP電源自動切り時間
      MACHINESETTINGKEY.ADR0038.get(),   //クリップ式気泡検出器切りＳＷ
      MACHINESETTINGKEY.ADR0039.get(),   //除水開始遅延時間
      MACHINESETTINGKEY.ADR0040.get(),//40 ？ 透析前体重
      //41 ＤＷ 患者情報:身体情報の日付最新のDW(あるもの)
      MACHINESETTINGKEY.ADR0042.get(),//42 ？ 補正値の合計
      MACHINESETTINGKEY.ADR0043.get(),//43 ？ 除水量制限
      //44 除水量計算値 除水補正値１～5の総計
      //45 除水補正項目名１ DBから取得 name_1
      //46 除水補正項目名１ なにもいれない
      //47 除水補正項目名１ なにもいれない
      //48 除水補正項目名１ なにもいれない
      //49 除水補正項目名１ なにもいれない
      //50 除水補正項目名１ なにもいれない
      //51 除水補正項目名１ なにもいれない
      //52 除水補正項目名１ なにもいれない
      //53 除水補正値１ DBから取得 value_1
      //54 除水補正項目名2 DBから取得 name_2
      //55 除水補正項目名2 なにもいれない
      //56 除水補正項目名2 なにもいれない
      //57 除水補正項目名2 なにもいれない
      //58 除水補正項目名2 なにもいれない
      //59 除水補正項目名2 なにもいれない
      //60 除水補正項目名2 なにもいれない
      //61 除水補正項目名2 なにもいれない
      //62 除水補正値2 DBから取得 value_2
      //63 除水補正項目名3 DBから取得 name_3
      //64 除水補正項目名3 なにもいれない
      //65 除水補正項目名3 なにもいれない
      //66 除水補正項目名3 なにもいれない
      //67 除水補正項目名3 なにもいれない
      //68 除水補正項目名3 なにもいれない
      //69 除水補正項目名3 なにもいれない
      //70 除水補正項目名3 なにもいれない
      //71 除水補正値3 DBから取得 name_3
      //72 除水補正項目名4 DBから取得 name_4
      //73 除水補正項目名4 なにもいれない
      //74 除水補正項目名4 なにもいれない
      //75 除水補正項目名4 なにもいれない
      //76 除水補正項目名4 なにもいれない
      //77 除水補正項目名4 なにもいれない
      //78 除水補正項目名4 なにもいれない
      //79 除水補正項目名4 なにもいれない
      //80 除水補正値4 DBから取得 name_4
      //81 除水補正項目名5 DBから取得 name_5
      //82 除水補正項目名5 なにもいれない
      //83 除水補正項目名5 なにもいれない
      //84 除水補正項目名5 なにもいれない
      //85 除水補正項目名5 なにもいれない
      //86 除水補正項目名5 なにもいれない
      //87 除水補正項目名5 なにもいれない
      //88 除水補正項目名5 なにもいれない
      //89 除水補正値5 DBから取得 name_5
      MACHINESETTINGKEY.ADR0090.get(),   //前補液　濾過率
      MACHINESETTINGKEY.ADR0091.get(),   //ヘマトクリット（Ht）
      MACHINESETTINGKEY.ADR0092.get(),   //総タンパク(TP)
      //93  予備
      //94  予備
      //95  予備
      //96  予備
      //97  予備
      //98  予備
      //99  予備
      MACHINESETTINGKEY.ADR0100.get(),   //静脈圧自動設定警報幅上限HD/ECUM
      MACHINESETTINGKEY.ADR0101.get(),   //静脈圧自動設定警報幅下限HD/ECUM
      MACHINESETTINGKEY.ADR0102.get(),   //静脈圧自動設定警報限界上限
      MACHINESETTINGKEY.ADR0103.get(),   //静脈圧自動設定警報限界下限
      MACHINESETTINGKEY.ADR0104.get(),   //静脈圧固定警報上限
      MACHINESETTINGKEY.ADR0105.get(),   //静脈圧固定警報下限
      MACHINESETTINGKEY.ADR0106.get(),   //静脈圧自動設定警報幅上限HDF/HF
      MACHINESETTINGKEY.ADR0107.get(),   //静脈圧自動設定警報幅下限HDF/HF
      MACHINESETTINGKEY.ADR0108.get(),   //静脈圧固定警報上限透析準備
      MACHINESETTINGKEY.ADR0109.get(),   //静脈圧固定警報下限透析準備
      MACHINESETTINGKEY.ADR0110.get(),   //静脈圧固定警報上限ＳＮ
      MACHINESETTINGKEY.ADR0111.get(),   //静脈圧固定警報下限ＳＮ
      MACHINESETTINGKEY.ADR0112.get(),   //液圧自動設定警報幅上限HD/ECUM
      MACHINESETTINGKEY.ADR0113.get(),   //液圧自動設定警報幅下限HD/ECUM
      MACHINESETTINGKEY.ADR0114.get(),   //液圧自動設定警報限界上限
      MACHINESETTINGKEY.ADR0115.get(),   //液圧自動設定警報限界下限
      MACHINESETTINGKEY.ADR0116.get(),   //液圧固定警報上限
      MACHINESETTINGKEY.ADR0117.get(),   //液圧固定警報下限
      MACHINESETTINGKEY.ADR0118.get(),   //液圧自動設定警報幅上限HDF/HF
      MACHINESETTINGKEY.ADR0119.get(),   //液圧自動設定警報幅下限HDF/HF
      MACHINESETTINGKEY.ADR0120.get(),   //液圧自動設定警報幅上限ＳＮ
      MACHINESETTINGKEY.ADR0121.get(),   //液圧自動設定警報幅下限ＳＮ
      MACHINESETTINGKEY.ADR0122.get(),   //液圧自動設定警報限界上限ＳＮ
      MACHINESETTINGKEY.ADR0123.get(),   //液圧自動設定警報限界下限ＳＮ
      MACHINESETTINGKEY.ADR0124.get(),   //液圧固定警報上限ＳＮ
      MACHINESETTINGKEY.ADR0125.get(),   //液圧固定警報下限ＳＮ
      MACHINESETTINGKEY.ADR0126.get(),   //ＴＭＰ自動追従警報幅上限HD/ECUM
      MACHINESETTINGKEY.ADR0127.get(),   //ＴＭＰ自動追従警報幅下限HD/ECUM
      MACHINESETTINGKEY.ADR0128.get(),   //ＴＭＰ自動設定警報幅上限HD/ECUM
      MACHINESETTINGKEY.ADR0129.get(),   //ＴＭＰ自動設定警報幅下限HD/ECUM
      MACHINESETTINGKEY.ADR0130.get(),   //ＴＭＰ自動設定警報限界上限
      MACHINESETTINGKEY.ADR0131.get(),   //ＴＭＰ自動設定警報限界下限
      MACHINESETTINGKEY.ADR0132.get(),   //ＴＭＰ固定警報上限
      MACHINESETTINGKEY.ADR0133.get(),   //ＴＭＰ固定警報下限
      MACHINESETTINGKEY.ADR0134.get(),   //ＴＭＰ自動追従警報幅上限HDF/HF
      MACHINESETTINGKEY.ADR0135.get(),   //ＴＭＰ自動追従警報幅下限HDF/HF
      MACHINESETTINGKEY.ADR0136.get(),   //ＴＭＰ自動設定警報幅上限HDF/HF
      MACHINESETTINGKEY.ADR0137.get(),   //ＴＭＰ自動設定警報幅下限HDF/HF
      MACHINESETTINGKEY.ADR0138.get(),   //ＴＭＰ自動追従警報幅上限ＳＮ
      MACHINESETTINGKEY.ADR0139.get(),   //ＴＭＰ自動追従警報幅下限ＳＮ
      MACHINESETTINGKEY.ADR0140.get(),   //ＴＭＰ自動設定警報幅上限ＳＮ
      MACHINESETTINGKEY.ADR0141.get(),   //ＴＭＰ自動設定警報幅下限ＳＮ
      MACHINESETTINGKEY.ADR0142.get(),   //ＴＭＰ自動設定警報限界上限ＳＮ
      MACHINESETTINGKEY.ADR0143.get(),   //ＴＭＰ自動設定警報限界下限ＳＮ
      MACHINESETTINGKEY.ADR0144.get(),   //ＴＭＰ固定警報上限ＳＮ
      MACHINESETTINGKEY.ADR0145.get(),   //ＴＭＰ固定警報下限ＳＮ
      MACHINESETTINGKEY.ADR0146.get(),   //ダイアライザー差圧自動設定警報幅上限HD/ECUM
      MACHINESETTINGKEY.ADR0147.get(),   //ダイアライザー差圧自動設定警報幅下限HD/ECUM
      MACHINESETTINGKEY.ADR0148.get(),   //ダイアライザー差圧固定警報上限
      MACHINESETTINGKEY.ADR0149.get(),   //ダイアライザー差圧固定警報下限
      MACHINESETTINGKEY.ADR0150.get(),   //ダイアライザー差圧自動設定警報幅上限HDF/HF
      MACHINESETTINGKEY.ADR0151.get(),   //ダイアライザー差圧自動設定警報幅下限HDF/HF
      MACHINESETTINGKEY.ADR0152.get(),   //ダイアライザー入口圧自動設定警報幅上限HD/ECUM
      MACHINESETTINGKEY.ADR0153.get(),   //ダイアライザー入口圧自動設定警報幅下限HD/ECUM
      MACHINESETTINGKEY.ADR0154.get(),   //ダイアライザー入口圧自動設定警報限界上限
      MACHINESETTINGKEY.ADR0155.get(),   //ダイアライザー入口圧自動設定警報限界下限
      MACHINESETTINGKEY.ADR0156.get(),   //ダイアライザー入口圧固定警報上限
      MACHINESETTINGKEY.ADR0157.get(),   //ダイアライザー入口圧固定警報下限
      MACHINESETTINGKEY.ADR0158.get(),   //ダイアライザー入口圧自動設定警報幅上限HDF/HF
      MACHINESETTINGKEY.ADR0159.get(),   //ダイアライザー入口圧自動設定警報幅下限HDF/HF
      MACHINESETTINGKEY.ADR0160.get(),   //ダイアライザー入口圧固定警報上限透析準備
      MACHINESETTINGKEY.ADR0161.get(),   //ダイアライザー入口圧固定警報下限透析準備
      MACHINESETTINGKEY.ADR0162.get(),   //ダイアライザー入口圧固定警報上限ＳＮ
      MACHINESETTINGKEY.ADR0163.get(),   //ダイアライザー入口圧固定警報下限ＳＮ
      //164 ダイアライザマスタから取得した値(UFR_WARNING_MAX)  初期UFR警報上限 初期ＵＦＲ警報上限
      //165 ダイアライザマスタから取得した値(UFR_WARNING_MIN)  初期UFR警報下限 初期ＵＦＲ警報下限
      //166 ダイアライザマスタから取得した値(UFR_WARNING_REDUCTION)  UFR低下率警報点 ＵＦＲ低下警報点
      //167 装置マスタから取得した値(TMP_CENTER_HD) ＴＭＰゼロ補正警報中点HD
      MACHINESETTINGKEY.ADR0168.get(),   //ＴＭＰゼロ補正警報上限HD
      MACHINESETTINGKEY.ADR0169.get(),   //ＴＭＰゼロ補正警報下限HD
      //170 装置マスタから取得した値(TMP_CENTER_ECUM) ＴＭＰゼロ補正警報中点ECUM
      MACHINESETTINGKEY.ADR0171.get(),   //ＴＭＰゼロ補正警報上限ECUM
      MACHINESETTINGKEY.ADR0172.get(),   //ＴＭＰゼロ補正警報下限ECUM
      //173 装置マスタから取得した値(TMP_CENTER_HDF) ＴＭＰゼロ補正警報中点HDF
      MACHINESETTINGKEY.ADR0174.get(),   //ＴＭＰゼロ補正警報上限HDF
      MACHINESETTINGKEY.ADR0175.get(),   //ＴＭＰゼロ補正警報下限HDF
      //176 装置マスタから取得した値(TMP_CENTER_HF) ＴＭＰゼロ補正警報中点HF
      MACHINESETTINGKEY.ADR0177.get(),   //ＴＭＰゼロ補正警報上限HF
      MACHINESETTINGKEY.ADR0178.get(),   //ＴＭＰゼロ補正警報下限HF
      MACHINESETTINGKEY.ADR0179.get(),   //血流量操作範囲上限
      //180 指示：IP速度最大値 ＩＰ速度操作範囲上限
      MACHINESETTINGKEY.ADR0181.get(),   //除水速度操作範囲上限
      MACHINESETTINGKEY.ADR0182.get(),   //透析液温度操作範囲上限
      MACHINESETTINGKEY.ADR0183.get(),   //透析液温度操作範囲下限
      MACHINESETTINGKEY.ADR0184.get(),   //Ｎａ注入濃度操作範囲上限
      MACHINESETTINGKEY.ADR0185.get(),   //前補液 補液速度操作範囲上限（HDF）
      MACHINESETTINGKEY.ADR0186.get(),   //前補液 補液速度操作範囲上限（HF）
      //187 ダイアライザマスタから取得した値(UREA_CLEARANCE)    尿素クリアランス ダイアライザ 尿素クリアランス
      //188 ダイアライザマスタから取得した値(BLOODAMT)          血流量 ダイアライザ 血流量
      //189 ダイアライザマスタから取得した値(ALQD_FLOOD_VOL)    透析液量 ダイアライザ 透析液流量
      MACHINESETTINGKEY.ADR0190.get(),   //血圧自動測定間隔
      MACHINESETTINGKEY.ADR0191.get(),   //血圧ｶﾌ選択
      MACHINESETTINGKEY.ADR0192.get(),   //昇圧値
      MACHINESETTINGKEY.ADR0193.get(),   //昇圧方法選択
      MACHINESETTINGKEY.ADR0194.get(),   //血圧連続測定動作選択
      MACHINESETTINGKEY.ADR0195.get(),   //血圧測定方法選択
      MACHINESETTINGKEY.ADR0196.get(),   //BV-UFC使用選択
      MACHINESETTINGKEY.ADR0197.get(),   //UFC期間除水速度上限
      MACHINESETTINGKEY.ADR0198.get(),   //UFC期間除水速度下限
      MACHINESETTINGKEY.ADR0199.get(),   //開始期間 時間
      MACHINESETTINGKEY.ADR0200.get(),   //I-HDF 補液量設定
      MACHINESETTINGKEY.ADR0201.get(),   //I-HDF 補液速度
      MACHINESETTINGKEY.ADR0202.get(),   //I-HDF 補液周期
      MACHINESETTINGKEY.ADR0203.get(),   //I-HDF 補液開始時間
      MACHINESETTINGKEY.ADR0204.get(),   //I-HDF 除水再開時間
      MACHINESETTINGKEY.ADR0205.get(),   //I-HDF 総補液量上限
      MACHINESETTINGKEY.ADR0206.get(),   //開始期間 除水速度倍率
      MACHINESETTINGKEY.ADR0207.get(),   //固定倍率除水期間 時間
      MACHINESETTINGKEY.ADR0208.get(),   //固定倍率除水期間 除水速度倍率
      MACHINESETTINGKEY.ADR0209.get(),   //固定倍率除水終了条件　最高血圧
      MACHINESETTINGKEY.ADR0210.get(),   //固定倍率除水終了条件　脈拍
      MACHINESETTINGKEY.ADR0211.get(),   //最高血圧上限
      MACHINESETTINGKEY.ADR0212.get(),   //最高血圧下限
      MACHINESETTINGKEY.ADR0213.get(),   //最低血圧上限
      MACHINESETTINGKEY.ADR0214.get(),   //最低血圧下限
      MACHINESETTINGKEY.ADR0215.get(),   //平均血圧上限
      MACHINESETTINGKEY.ADR0216.get(),   //平均血圧下限
      MACHINESETTINGKEY.ADR0217.get(),   //脈拍数上限
      MACHINESETTINGKEY.ADR0218.get(),   //脈拍数下限
      MACHINESETTINGKEY.ADR0219.get(),   //最高血圧上限警報　BP　動作選択
      MACHINESETTINGKEY.ADR0220.get(),   //最高血圧下限警報　BP　動作選択
      MACHINESETTINGKEY.ADR0221.get(),   //最高血圧上限警報　除水　動作選択
      MACHINESETTINGKEY.ADR0222.get(),   //最高血圧下限警報　除水　動作選択
      MACHINESETTINGKEY.ADR0223.get(),   //最高血圧上限警報　Na注入　動作選択
      MACHINESETTINGKEY.ADR0224.get(),   //最高血圧下限警報　Na注入　動作選択
      MACHINESETTINGKEY.ADR0225.get(),   //最高血圧上限警報　補液　動作選択
      MACHINESETTINGKEY.ADR0226.get(),   //最高血圧下限警報　補液　動作選択
      MACHINESETTINGKEY.ADR0227.get(),   //最高血圧上限警報　BP　速度
      MACHINESETTINGKEY.ADR0228.get(),   //最高血圧下限警報　BP　速度
      MACHINESETTINGKEY.ADR0229.get(),   //最高血圧上限警報　除水　速度
      MACHINESETTINGKEY.ADR0230.get(),   //最高血圧下限警報　除水　速度
      MACHINESETTINGKEY.ADR0231.get(),   //最高血圧上限警報　Na注入　速度
      MACHINESETTINGKEY.ADR0232.get(),   //最高血圧下限警報　Na注入　速度
      MACHINESETTINGKEY.ADR0233.get(),   //最高血圧上限警報　補液　速度
      MACHINESETTINGKEY.ADR0234.get(),   //最高血圧下限警報　補液　速度
      MACHINESETTINGKEY.ADR0235.get(),   //警報連動測定開始時刻
      MACHINESETTINGKEY.ADR0236.get(),   //治療条件連動測定時刻
      MACHINESETTINGKEY.ADR0237.get(),   //血圧測定自動停止(警報発生)
      MACHINESETTINGKEY.ADR0238.get(),   //血圧測定自動停止(条件変更)
      MACHINESETTINGKEY.ADR0239.get(),   //高速測定選択
      MACHINESETTINGKEY.ADR0240.get(),   //ＴＭＰ監視モード
      MACHINESETTINGKEY.ADR0241.get(),   //ＴＭＰゼロ補正の選択
      MACHINESETTINGKEY.ADR0242.get(),   //静脈圧自動設定警報監視有無
      MACHINESETTINGKEY.ADR0243.get(),   //ダイアライザー血液入口圧自動設定警報監視有無
      MACHINESETTINGKEY.ADR0244.get(),   //透析液圧自動設定警報監視有無
      MACHINESETTINGKEY.ADR0245.get(),   //ＴＭＰ自動設定警報監視有無
      MACHINESETTINGKEY.ADR0246.get(),   //差圧自動設定警報監視有無
      MACHINESETTINGKEY.ADR0247.get(),   //Ｎａ濃度自動設定警報監視有無
      MACHINESETTINGKEY.ADR0248.get(),   //固定倍率除水終了条件　ΔBV
      MACHINESETTINGKEY.ADR0249.get(),   //終了前期間 時間
      MACHINESETTINGKEY.ADR0250.get(),   //透析液濃度プログラム自動設定警報幅上限
      MACHINESETTINGKEY.ADR0251.get(),   //透析液濃度プログラム自動設定警報幅下限
      MACHINESETTINGKEY.ADR0252.get(),   //Ｂ液濃度プログラム自動設定警報幅上限
      MACHINESETTINGKEY.ADR0253.get(),   //Ｂ液濃度プログラム自動設定警報幅下限
      MACHINESETTINGKEY.ADR0254.get(),   //Ｎａ濃度自動設定警報幅上限
      MACHINESETTINGKEY.ADR0255.get(),   //Ｎａ濃度自動設定警報幅下限
      MACHINESETTINGKEY.ADR0256.get(),   //Ｎａ濃度固定警報上限
      MACHINESETTINGKEY.ADR0257.get(),   //Ｎａ濃度固定警報下限
      MACHINESETTINGKEY.ADR0258.get(),   //アクセス再循環測定使用選択
      MACHINESETTINGKEY.ADR0259.get(),   //自動測定1
      MACHINESETTINGKEY.ADR0260.get(),   //ΔＢＶ低下警報点１
      MACHINESETTINGKEY.ADR0261.get(),   //ΔＢＶ低下警報点２
      MACHINESETTINGKEY.ADR0262.get(),   //ΔBV変化率警報点
      MACHINESETTINGKEY.ADR0263.get(),   //自動測定2
      MACHINESETTINGKEY.ADR0264.get(),   //自動測定3
      MACHINESETTINGKEY.ADR0265.get(),   //自動測定4
      MACHINESETTINGKEY.ADR0266.get(),   //自動測定5
      MACHINESETTINGKEY.ADR0267.get(),   //ブラッドボリューム計使用の選択
      MACHINESETTINGKEY.ADR0268.get(),   //透析液流量　設定方法
      MACHINESETTINGKEY.ADR0269.get(),   //透析液流量　比率設定
      MACHINESETTINGKEY.ADR0270.get(),   //D-FAS 返血 動脈側返血使用選択
      MACHINESETTINGKEY.ADR0271.get(),   //開始時ΔBV基準値
      MACHINESETTINGKEY.ADR0272.get(),   //ΔBV基準線　指数1
      MACHINESETTINGKEY.ADR0273.get(),   //ΔBV基準線　指数2
      MACHINESETTINGKEY.ADR0274.get(),   //ΔBV基準線　指数3
      MACHINESETTINGKEY.ADR0275.get(),   //終了時ΔBV基準値
      //276  予約
      MACHINESETTINGKEY.ADR0277.get(),   //ΔＢＶ除水低下速度
      MACHINESETTINGKEY.ADR0278.get(),   //ΔＢＶ除水低下遅延時間
      //279  予約
      //280  予約
      MACHINESETTINGKEY.ADR0281.get(),   //再循環率報知
      MACHINESETTINGKEY.ADR0282.get(),   //透析量プログラム使用選択
      MACHINESETTINGKEY.ADR0283.get(),   //体液量計算時後体重
      MACHINESETTINGKEY.ADR0284.get(),   //体液量+補正値
      MACHINESETTINGKEY.ADR0285.get(),   //目標後体重
      MACHINESETTINGKEY.ADR0286.get(),   //標準血流量
      MACHINESETTINGKEY.ADR0287.get(),   //KoA
      MACHINESETTINGKEY.ADR0288.get(),   //目標Kt/V
      //289  予備
      MACHINESETTINGKEY.ADR0290.get(),   //ＵＦＲプログラム電源ＳＷ
      MACHINESETTINGKEY.ADR0291.get(),   //治療モード１
      MACHINESETTINGKEY.ADR0292.get(),   //治療モード２
      MACHINESETTINGKEY.ADR0293.get(),   //治療モード３
      MACHINESETTINGKEY.ADR0294.get(),   //治療モード４
      MACHINESETTINGKEY.ADR0295.get(),   //治療モード５
      MACHINESETTINGKEY.ADR0296.get(),   //治療モード６
      MACHINESETTINGKEY.ADR0297.get(),   //治療モード７
      MACHINESETTINGKEY.ADR0298.get(),   //治療モード８
      MACHINESETTINGKEY.ADR0299.get(),   //治療モード９
      MACHINESETTINGKEY.ADR0300.get(),   //治療モード１０
      MACHINESETTINGKEY.ADR0301.get(),   //ＵＦＲプログラム指数１
      MACHINESETTINGKEY.ADR0302.get(),   //ＵＦＲプログラム指数２
      MACHINESETTINGKEY.ADR0303.get(),   //ＵＦＲプログラム指数３
      MACHINESETTINGKEY.ADR0304.get(),   //ＵＦＲプログラム指数４
      MACHINESETTINGKEY.ADR0305.get(),   //ＵＦＲプログラム指数５
      MACHINESETTINGKEY.ADR0306.get(),   //ＵＦＲプログラム指数６
      MACHINESETTINGKEY.ADR0307.get(),   //ＵＦＲプログラム指数７
      MACHINESETTINGKEY.ADR0308.get(),   //ＵＦＲプログラム指数８
      MACHINESETTINGKEY.ADR0309.get(),   //ＵＦＲプログラム指数９
      MACHINESETTINGKEY.ADR0310.get(),   //ＵＦＲプログラム指数１０
      MACHINESETTINGKEY.ADR0311.get(),   //ＵＦＲプログラム最終位置
      MACHINESETTINGKEY.ADR0312.get(),   //ＵＦＲプログラムコース
      MACHINESETTINGKEY.ADR0313.get(),   //ＵＦＲプログラム開始数値
      MACHINESETTINGKEY.ADR0314.get(),   //ＵＦＲプログラム終了数値
      MACHINESETTINGKEY.ADR0315.get(),   //Ｎａ注入プログラム電源ＳＷ
      MACHINESETTINGKEY.ADR0316.get(),   //Ｎａ注入プログラム設定１
      MACHINESETTINGKEY.ADR0317.get(),   //Ｎａ注入プログラム設定２
      MACHINESETTINGKEY.ADR0318.get(),   //Ｎａ注入プログラム設定３
      MACHINESETTINGKEY.ADR0319.get(),   //Ｎａ注入プログラム設定４
      MACHINESETTINGKEY.ADR0320.get(),   //Ｎａ注入プログラム設定５
      MACHINESETTINGKEY.ADR0321.get(),   //Ｎａ注入プログラム設定６
      MACHINESETTINGKEY.ADR0322.get(),   //Ｎａ注入プログラム設定７
      MACHINESETTINGKEY.ADR0323.get(),   //Ｎａ注入プログラム設定８
      MACHINESETTINGKEY.ADR0324.get(),   //Ｎａ注入プログラム設定９
      MACHINESETTINGKEY.ADR0325.get(),   //Ｎａ注入プログラム設定１０
      MACHINESETTINGKEY.ADR0326.get(),   //Ｎａ注入プログラム切替時間
      MACHINESETTINGKEY.ADR0327.get(),   //Ｎａ注入プログラム　ＵＦＲプロとの連動選択
      MACHINESETTINGKEY.ADR0328.get(),   //Ｎａ注入プログラムコース
      MACHINESETTINGKEY.ADR0329.get(),   //Ｎａ注入プログラム開始数値
      MACHINESETTINGKEY.ADR0330.get(),   //Ｎａ注入プログラム終了数値
      MACHINESETTINGKEY.ADR0331.get(),   //同時脱血　脱血量
      MACHINESETTINGKEY.ADR0332.get(),   //片側脱血への切替え透析液圧
      MACHINESETTINGKEY.ADR0333.get(),   //脱血速度
      MACHINESETTINGKEY.ADR0334.get(),   //片側脱血(除水なし) 脱血量
      //335 複雑 治療開始時 血液ポンプ速度
      MACHINESETTINGKEY.ADR0336.get(),   //補液速度
      MACHINESETTINGKEY.ADR0337.get(),   //補液量
      MACHINESETTINGKEY.ADR0338.get(),   //片側脱血（除水あり）　脱血量
      MACHINESETTINGKEY.ADR0339.get(),   //脱血方法選択
      MACHINESETTINGKEY.ADR0340.get(),   //濃度プログラム電源ＳＷ
      MACHINESETTINGKEY.ADR0341.get(),   //透析液濃度プログラム設定１
      MACHINESETTINGKEY.ADR0342.get(),   //透析液濃度プログラム設定２
      MACHINESETTINGKEY.ADR0343.get(),   //透析液濃度プログラム設定３
      MACHINESETTINGKEY.ADR0344.get(),   //透析液濃度プログラム設定４
      MACHINESETTINGKEY.ADR0345.get(),   //透析液濃度プログラム設定５
      MACHINESETTINGKEY.ADR0346.get(),   //透析液濃度プログラム設定６
      MACHINESETTINGKEY.ADR0347.get(),   //透析液濃度プログラム設定７
      MACHINESETTINGKEY.ADR0348.get(),   //透析液濃度プログラム設定８
      MACHINESETTINGKEY.ADR0349.get(),   //透析液濃度プログラム設定９
      MACHINESETTINGKEY.ADR0350.get(),   //透析液濃度プログラム設定１０
      MACHINESETTINGKEY.ADR0351.get(),   //Ｂ液濃度プログラム設定１
      MACHINESETTINGKEY.ADR0352.get(),   //Ｂ液濃度プログラム設定２
      MACHINESETTINGKEY.ADR0353.get(),   //Ｂ液濃度プログラム設定３
      MACHINESETTINGKEY.ADR0354.get(),   //Ｂ液濃度プログラム設定４
      MACHINESETTINGKEY.ADR0355.get(),   //Ｂ液濃度プログラム設定５
      MACHINESETTINGKEY.ADR0356.get(),   //Ｂ液濃度プログラム設定６
      MACHINESETTINGKEY.ADR0357.get(),   //Ｂ液濃度プログラム設定７
      MACHINESETTINGKEY.ADR0358.get(),   //Ｂ液濃度プログラム設定８
      MACHINESETTINGKEY.ADR0359.get(),   //Ｂ液濃度プログラム設定９
      MACHINESETTINGKEY.ADR0360.get(),   //Ｂ液濃度プログラム設定１０
      MACHINESETTINGKEY.ADR0361.get(),   //透析液濃度プログラムステップ切替無し　コース
      MACHINESETTINGKEY.ADR0362.get(),   //透析液濃度プログラム開始数値
      MACHINESETTINGKEY.ADR0363.get(),   //透析液濃度プログラム終了数値
      MACHINESETTINGKEY.ADR0364.get(),   //Ｂ液濃度プログラムステップ切替無し　コース
      MACHINESETTINGKEY.ADR0365.get(),   //Ｂ液濃度プログラム開始数値
      MACHINESETTINGKEY.ADR0366.get(),   //Ｂ液濃度プログラム終了数値
      MACHINESETTINGKEY.ADR0367.get(),   //濃度プログラム切替時間
      MACHINESETTINGKEY.ADR0368.get(),   //濃度プログラム　ＵＦＲプロとの連動選択
      MACHINESETTINGKEY.ADR0369.get(),   //DP=Qd+Qs(補液速度加算)
      MACHINESETTINGKEY.ADR0370.get(),   //自動回収　使用液量
      MACHINESETTINGKEY.ADR0371.get(),   //自動回収　流速
      MACHINESETTINGKEY.ADR0372.get(),   //自動回収　血液判別器による終了選択
      MACHINESETTINGKEY.ADR0373.get(),   //静脈側返血速度
      MACHINESETTINGKEY.ADR0374.get(),   //静脈側最大返血量
      //375  予約
      MACHINESETTINGKEY.ADR0376.get(),   //動脈側最大返血量
      MACHINESETTINGKEY.ADR0377.get(),   //静脈側返血　血液判別器使用選択
      MACHINESETTINGKEY.ADR0378.get(),   //動脈側返血　血液判別器使用選択
      MACHINESETTINGKEY.ADR0379.get(),   //前補液　OHDF/OHF　補液速度比率
      //380 指示：補液速度 補液速度
      //381 指示：補液温度 補液温度設定値
      //382 指示：補液量 補液量設定値
      MACHINESETTINGKEY.ADR0383.get(),   //補液量設定値制限（OHDF・OHF用）
      MACHINESETTINGKEY.ADR0384.get(),   //AFBF　補液比率使用選択
      MACHINESETTINGKEY.ADR0385.get(),   //AFBF　補液比率
      MACHINESETTINGKEY.ADR0386.get(),   //補液速度設定範囲上限（AFBF）
      MACHINESETTINGKEY.ADR0387.get(),   //補液速度設定範囲下限（AFBF）
      //388 指示：補液選択 補液選択（前・後）
      MACHINESETTINGKEY.ADR0389.get(),   //OHDF/OHF補液計算優先項目選択
      //390 複雑 ＴＭＰゼロ補正警報中点OHDF
      MACHINESETTINGKEY.ADR0391.get(),   //ＴＭＰゼロ補正警報上限OHDF
      MACHINESETTINGKEY.ADR0392.get(),   //ＴＭＰゼロ補正警報下限OHDF
      //393 装置マスタから取得した値(TMP_CENTER_OHF) ＴＭＰゼロ補正警報中点OHF
      MACHINESETTINGKEY.ADR0394.get(),   //ＴＭＰゼロ補正警報上限OHF
      MACHINESETTINGKEY.ADR0395.get(),   //ＴＭＰゼロ補正警報下限OHF
      //396 補液選択(治療条件指示：項目番号21)のよる場合わけ 前補液 補液速度操作範囲上限（OHDF）
      //397 補液選択(治療条件指示：項目番号21)のよる場合わけ 前補液 補液速度操作範囲上限（OHF）
      MACHINESETTINGKEY.ADR0398.get(),   //補液開始遅延時間
      //399 予約
      MACHINESETTINGKEY.ADR0400.get(),   //QBプログラム血流量1
      MACHINESETTINGKEY.ADR0401.get(),   //QBプログラム血流量2
      MACHINESETTINGKEY.ADR0402.get(),   //QBプログラム血流量3
      MACHINESETTINGKEY.ADR0403.get(),   //QBプログラム血流量4
      MACHINESETTINGKEY.ADR0404.get(),   //QBプログラム血流量5
      MACHINESETTINGKEY.ADR0405.get(),   //QBプログラム血流量6
      MACHINESETTINGKEY.ADR0406.get(),   //QBプログラム血流量7
      MACHINESETTINGKEY.ADR0407.get(),   //QBプログラム血流量8
      MACHINESETTINGKEY.ADR0408.get(),   //QBプログラム血流量9
      MACHINESETTINGKEY.ADR0409.get(),   //QBプログラム血流量10
      MACHINESETTINGKEY.ADR0410.get(),   //QDプログラム透析液流量1
      MACHINESETTINGKEY.ADR0411.get(),   //QDプログラム透析液流量2
      MACHINESETTINGKEY.ADR0412.get(),   //QDプログラム透析液流量3
      MACHINESETTINGKEY.ADR0413.get(),   //QDプログラム透析液流量4
      MACHINESETTINGKEY.ADR0414.get(),   //QDプログラム透析液流量5
      MACHINESETTINGKEY.ADR0415.get(),   //QDプログラム透析液流量6
      MACHINESETTINGKEY.ADR0416.get(),   //QDプログラム透析液流量7
      MACHINESETTINGKEY.ADR0417.get(),   //QDプログラム透析液流量8
      MACHINESETTINGKEY.ADR0418.get(),   //QDプログラム透析液流量9
      MACHINESETTINGKEY.ADR0419.get(),   //QDプログラム透析液流量10
      MACHINESETTINGKEY.ADR0420.get(),   //QB、QDプログラム切替時間1
      MACHINESETTINGKEY.ADR0421.get(),   //QB、QDプログラム切替時間2
      MACHINESETTINGKEY.ADR0422.get(),   //QB、QDプログラム切替時間3
      MACHINESETTINGKEY.ADR0423.get(),   //QB、QDプログラム切替時間4
      MACHINESETTINGKEY.ADR0424.get(),   //QB、QDプログラム切替時間5
      MACHINESETTINGKEY.ADR0425.get(),   //QB、QDプログラム切替時間6
      MACHINESETTINGKEY.ADR0426.get(),   //QB、QDプログラム切替時間7
      MACHINESETTINGKEY.ADR0427.get(),   //QB、QDプログラム切替時間8
      MACHINESETTINGKEY.ADR0428.get(),   //QB、QDプログラム切替時間9
      MACHINESETTINGKEY.ADR0429.get(),   //QB、QDプログラム最大ステップ数
      MACHINESETTINGKEY.ADR0430.get(),   //QBプログラム電源
      MACHINESETTINGKEY.ADR0431.get(),   //QDプログラム電源
      MACHINESETTINGKEY.ADR0432.get(),   //I-HDFプログラム使用選択
      MACHINESETTINGKEY.ADR0433.get(),   //予定補液回数
      MACHINESETTINGKEY.ADR0434.get(),   //補液バランス制限
      MACHINESETTINGKEY.ADR0435.get(),   //補液量01
      MACHINESETTINGKEY.ADR0436.get(),   //補液量02
      MACHINESETTINGKEY.ADR0437.get(),   //補液量03
      MACHINESETTINGKEY.ADR0438.get(),   //補液量04
      MACHINESETTINGKEY.ADR0439.get(),   //補液量05
      MACHINESETTINGKEY.ADR0440.get(),   //補液量06
      MACHINESETTINGKEY.ADR0441.get(),   //補液量07
      MACHINESETTINGKEY.ADR0442.get(),   //補液量08
      MACHINESETTINGKEY.ADR0443.get(),   //補液量09
      MACHINESETTINGKEY.ADR0444.get(),   //補液量10
      MACHINESETTINGKEY.ADR0445.get(),   //補液量11
      MACHINESETTINGKEY.ADR0446.get(),   //補液量12
      MACHINESETTINGKEY.ADR0447.get(),   //補液量13
      MACHINESETTINGKEY.ADR0448.get(),   //補液量14
      MACHINESETTINGKEY.ADR0449.get(),   //補液量15
      MACHINESETTINGKEY.ADR0450.get(),   //補液量16
      MACHINESETTINGKEY.ADR0451.get(),   //回収量01
      MACHINESETTINGKEY.ADR0452.get(),   //回収量02
      MACHINESETTINGKEY.ADR0453.get(),   //回収量03
      MACHINESETTINGKEY.ADR0454.get(),   //回収量04
      MACHINESETTINGKEY.ADR0455.get(),   //回収量05
      MACHINESETTINGKEY.ADR0456.get(),   //回収量06
      MACHINESETTINGKEY.ADR0457.get(),   //回収量07
      MACHINESETTINGKEY.ADR0458.get(),   //回収量08
      MACHINESETTINGKEY.ADR0459.get(),   //回収量09
      MACHINESETTINGKEY.ADR0460.get(),   //回収量10
      MACHINESETTINGKEY.ADR0461.get(),   //回収量11
      MACHINESETTINGKEY.ADR0462.get(),   //回収量12
      MACHINESETTINGKEY.ADR0463.get(),   //回収量13
      MACHINESETTINGKEY.ADR0464.get(),   //回収量14
      MACHINESETTINGKEY.ADR0465.get(),   //回収量15
      MACHINESETTINGKEY.ADR0466.get(),   //回収量16
      MACHINESETTINGKEY.ADR0467.get(),   //ダイアライザー膜面積
      MACHINESETTINGKEY.ADR0468.get(),   //VA確認報知基準値(静的静脈圧)
      MACHINESETTINGKEY.ADR0469.get(),   //VA確認報知基準値(アクセス内圧力比率)
      MACHINESETTINGKEY.ADR0470.get(),   //静的静脈圧記録 自動実施選択
      MACHINESETTINGKEY.ADR0471.get(),   //血圧測定 自動実施選択
      MACHINESETTINGKEY.ADR0472.get(),   //TMP閾値 速度低下
      MACHINESETTINGKEY.ADR0473.get(),   //TMP閾値 速度復帰
      MACHINESETTINGKEY.ADR0474.get(),   //補液量 速度低下
      // #11124 2025.08.268 mod 酸素飽和度対応 TDC高村 start
      //MACHINESETTINGKEY.ADR0475.get() // 補液量 速度復帰
      MACHINESETTINGKEY.ADR0475.get(),   //補液量 速度復帰
      MACHINESETTINGKEY.ADR0476.get()    //ΔSO2低下報知点
      // #11124 2025.08.268 mod 酸素飽和度対応 TDC高村 end

    };

    //アドレスリスト分、ループする
    for(int i = 0 ; i < addrParams.length ; i++)
    {
      // リストにあるアドレスにDBから取得した値を設定する
      setDataToJson(
          machineSettingJsonForSendCond,
          addrParams[i],
          this.getItemFromJson(
              machineSettingDevJson,
              "A",
              addrParams[i]
            )
      ) ;
    }

    //---------------------------------------
    //「透析量プログラム」設定
    //---------------------------------------
    // 存在しないデータがあってもデータなしとして処理継続させるため下記の条件追加
    if (null != dialyzerInfo) {


    //透析量プログラム設定(A-0282)の設定
    retStr = flagAlqdFloodVolProgSysOn ? CommonIndConst.SETTING_ON.get() : CommonIndConst.SETTING_OFF.get() ;
    setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0282.get(),retStr) ;

    // 検査日(A-ord_no)のord_no取得
    if(flagAlqdFloodVolProgSysOn)
    {//「透析量プログラム」が「使用する」に設定されている場合のみ

      retMethod = this.procAlqdFloodVolProg(
          itemAOrdNo,
          patId,
          sendCond,
          machineSettingJsonForSendCond,
          indCondInfo,
          dw,
          dialyzerInfo
        );

      if((HttpStatus)retMethod.get(PARAMKEY.STATUS) != HttpStatus.OK)
      {
        retVal.put(PARAMKEY.STATUS, (HttpStatus)retMethod.get(PARAMKEY.STATUS)) ;
        retMsg = (String)retMethod.get(PARAMKEY.RET_MSG);
        retVal.put(PARAMKEY.RET_MSG, retMsg) ;
        retLogMsg = retMsg;
        if (retMethod.containsKey(PARAMKEY.RET_LOG_MSG)) {
          retLogMsg = (String)retMethod.get(PARAMKEY.RET_LOG_MSG);
        }
        retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
        retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
        // ログを出力しロールバック用の例外を投げる
        this.exitMethod(className,methodName,retMsg);
      }
    }
    }


    //---------------------------------------
    //患者情報設定
    //---------------------------------------

    //患者ID(ord_mainから)
    setDataToJson(machineSettingJsonForSendCond, MACHINESETTINGKEY.ADR0000.get(),patId) ;
    //患者名(pat_paersonal_mainから)
    setDataToJson(machineSettingJsonForSendCond, MACHINESETTINGKEY.ADR0004.get(),patName) ;

    //DW
    setDataToJson(machineSettingJsonForSendCond, MACHINESETTINGKEY.ADR0041.get(),dw) ;

  //---------------------------------------
  //  除水補正項目の格納
  //---------------------------------------

    //44 除水量計算値 除水補正値１～5の総計
    //45 除水補正項目名１ DBから取得 name_1
    //53 除水補正値１ DBから取得 value_1
    //54 除水補正項目名2 DBから取得 name_2
    //62 除水補正値2 DBから取得 value_2
    //63 除水補正項目名3 DBから取得 name_3
    //71 除水補正値3 DBから取得 name_3
    //72 除水補正項目名4 DBから取得 name_4
    //80 除水補正値4 DBから取得 name_4
    //81 除水補正項目名5 DBから取得 name_5
    //89 除水補正値5 DBから取得 name_5

    // { 除水項目名のアドレス,除水補正値のアドレス }
    final String[][] addrs = {
        {MACHINESETTINGKEY.ADR0045.get(),MACHINESETTINGKEY.ADR0053.get()},
        {MACHINESETTINGKEY.ADR0054.get(),MACHINESETTINGKEY.ADR0062.get()},
        {MACHINESETTINGKEY.ADR0063.get(),MACHINESETTINGKEY.ADR0071.get()},
        {MACHINESETTINGKEY.ADR0072.get(),MACHINESETTINGKEY.ADR0080.get()},
        {MACHINESETTINGKEY.ADR0081.get(),MACHINESETTINGKEY.ADR0089.get()}
    } ;

    long valueTotal = 0 ;   //総計
    long addValue = 0 ;     //項目ごとの値(一時的格納)

    for(int i = 0 ; i < addrs.length ; i++)
    {
      //nameの格納 除水補正項目名1～5
      setDataToJson(
          machineSettingJsonForSendCond,
          addrs[i][0],
          String.valueOf(indOffWaterInfo.get(PARAMKEY.OFF_WATER_NAME.get()+(i+1)))
        ) ;
      //valueの格納  除水補正値1～5
      String value = String.valueOf(indOffWaterInfo.get(PARAMKEY.OFF_WATER_VALUE.get()+(i+1))) ;
      setDataToJson(
          machineSettingJsonForSendCond,
          addrs[i][1],
          value
        ) ;

      //総計への加算
      try {
        addValue = Long.parseLong(value) ;
      }
      catch(Exception e)
      {
        //変換できなかったので0扱い
        addValue = 0 ;
      }
      finally
      {
        valueTotal += addValue ;
      }
    }

    //44 除水量計算値 除水補正値１～5の総計 + 前体重 - 目標体重（DW)
    setDataToJson(
          machineSettingJsonForSendCond,
          MACHINESETTINGKEY.ADR0044.get(),
          String.valueOf(this.calcOffWaterCalc(rstWeightInfo ,indCondInfo, dw, valueTotal))
        );

  //---------------------------------------
  // 装置マスタ情報(TMP中点)の格納
  //---------------------------------------

  // TMPゼロ補正警報中点HD
  //"A-0167""TMP_CENTER_HD"
  setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0167.get(),(String)retMaster.get(PARAMKEY.TMP_CENTER_HD)) ;
  // TMPゼロ補正警報中点ECUM
  //"A-0170""TMP_CENTER_ECUM"
  setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0170.get(),(String)retMaster.get(PARAMKEY.TMP_CENTER_ECUM)) ;
  // TMPゼロ補正警報中点HDF
  //"A-0173""TMP_CENTER_HDF"
  setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0173.get(),(String)retMaster.get(PARAMKEY.TMP_CENTER_HDF)) ;
  // TMPゼロ補正警報中点HF
  //"A-0176""TMP_CENTER_HF"
  setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0176.get(),(String)retMaster.get(PARAMKEY.TMP_CENTER_HF)) ;
  // TMPゼロ補正警報中点HD補液  or TMPゼロ補正警報中点OHDF
  if(treatMode.equals(CommonIndConst.DEVICE_MODE_PRO_REP_LIQ))
  {//治療モードがCommonIndConst.DEVICE_MODE_HD_REP_LIQの場合
    //"A-0390""TMP_CENTER_HD_HO"
    setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0390.get(),(String)retMaster.get(PARAMKEY.TMP_CENTER_HD_HO)) ;
    //  "A-0391"　B-0037
    setDataToJson(
          machineSettingJsonForSendCond,
          MACHINESETTINGKEY.ADR0391.get(),
          this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0037.get())
       ) ;
    //  "A-0392"　B-0038
    setDataToJson(
          machineSettingJsonForSendCond,
          MACHINESETTINGKEY.ADR0392.get(),
          this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0038.get())
        ) ;
  }
  else if(treatMode.equals(CommonIndConst.DEVICE_MODE_OHDF))
  {//治療モードがCommonIndConst.DEVICE_MODE_OHDFの場合
    //"A-0390""TMP_CENTER_OHDF"
    setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0390.get(),(String)retMaster.get(PARAMKEY.TMP_CENTER_OHDF)) ;
  }

  //■補液選択(治療条件指示：項目番号21)のよる場合わけ
  String replenishSelectValue = this.getDataFromIndCond(indCondInfo,DialysisCond.COND_REPLENISH_SELECT.get()) ;
  if(null == replenishSelectValue)
  {//補液を使用しない治療方法の場合(「補液選択」がnull)
    //"A-0185"    "B-0031"
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0185.get(),
        this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0031.get())
      ) ;
    //"A-0186"    "B-0032"
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0186.get(),
        this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0032.get())
      ) ;
    //"A-0396"    "B-0034"
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0396.get(),
        this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0034.get())
      ) ;
    //"A-0397"    "B-0035"
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0397.get(),
        this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0035.get())
      ) ;
    //"A-0379"    "B-0039"    hasi-Redmine#3126(受入NG対応)
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0379.get(),
        this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0039.get())
      ) ;
    //"A-0090"    "B-0040"    hasi-2016定期(Ver.5.00P1(No.01))
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0090.get(),
        this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0040.get())
      ) ;

  }
  else if(replenishSelectValue.equals("1"))
  {//前補液の場合(値が1)
    if(treatMode.equals(CommonIndConst.DEVICE_MODE_HD_REP_LIQ))
    {//治療モードがCommonIndConst.DEVICE_MODE_HD_REP_LIQの場合(「HD+補液」の場合)
      //    "A-0396"　"B-0030"
      setDataToJson(
          machineSettingJsonForSendCond,
          MACHINESETTINGKEY.ADR0396.get(),
          this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0030.get())
        ) ;
    }
  }
  else if(replenishSelectValue.equals("0"))
  {//後補液の場合(値が0)
    //    "A-0185"    "B-0031"
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0185.get(),
        this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0031.get())
      ) ;
    //    "A-0186"    "B-0032"
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0186.get(),
        this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0032.get())
      ) ;
    if(treatMode.equals(CommonIndConst.DEVICE_MODE_PRO_REP_LIQ))
    {//治療モードがCommonIndConst.DEVICE_MODE_HD_REP_LIQの場合(「HD+補液」の場合)
      //"A-0396"　"B-0033"
      setDataToJson(
          machineSettingJsonForSendCond,
          MACHINESETTINGKEY.ADR0396.get(),
          this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0033.get())
        ) ;
//    }else if(treatMode.equals(CommonIndConst.DEVICE_MODE_OHDF)) {
//      //「治療(装置)モード」が「OHDF」の場合(hasi-Redmine#3049:「HD+補液」以外に修正されている。理由は謎)
    }
    else
    {//「HD+補液」以外
      //        "A-0396"　"B-0034"
      setDataToJson(
          machineSettingJsonForSendCond,
          MACHINESETTINGKEY.ADR0396.get(),
          this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0034.get())
        ) ;
    }

    //    "A-0397"    "B-0035"
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0397.get(),
        this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0035.get())
        ) ;
    //    "A-0379"    "B-0039"    hasi-Redmine#3126(受入NG対応)
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0379.get(),
        this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0039.get())
        ) ;
    //    "A-0090"    "B-0040"    hasi-2016定期(Ver.5.00P1(No.01))
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0090.get(),
        this.getItemFromJson(machineSettingDevJson,"B",MACHINESETTINGKEY.ADRB0040.get())
        ) ;
  }


  //TMPゼロ補正警報中点OHF
  //    A-0393　装置マスタから取得した値(TMP_CENTER_OHF)
  setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0393.get(),
        (String)retMaster.get(PARAMKEY.TMP_CENTER_OHF)
     ) ;

  //■ダイアライザ(治療条件指示：項目番号5)
  //    治療条件指示にキーがあり、値(ダイアライザコード)が設定されている場合：
  //        ダイアライザマスタからダイアライザコードを元にレコードが取得できた場合：
  if(null != dialyzerInfo)
  {
    //"A-0164"    "UFR_WARNING_MAX"       初期UFR警報上限
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0164.get(),
        (String)dialyzerInfo.get(PARAMKEY.UFR_WARNING_MAX)
        ) ;
    //"A-0165"    "UFR_WARNING_MIN"       初期UFR警報下限
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0165.get(),
        (String)dialyzerInfo.get(PARAMKEY.UFR_WARNING_MIN)
        ) ;
    //"A-0166"    "UFR_WARNING_REDUCTION"     UFR低下率警報点
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0166.get(),
        (String)dialyzerInfo.get(PARAMKEY.UFR_WARNING_REDUCTION)
        ) ;
    //"A-0187"    "UREA_CLEARANCE"        尿素クリアランス
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0187.get(),
        (String)dialyzerInfo.get(PARAMKEY.UREACLEARANCE)
        ) ;
    //"A-0188"    "BLOODAMT"          血流量
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0188.get(),
        (String)dialyzerInfo.get(PARAMKEY.BLOODAMT)
        ) ;
    //"A-0189"    "ALQD_FLOOD_VOL"        透析液量
    setDataToJson(
        machineSettingJsonForSendCond,
        MACHINESETTINGKEY.ADR0189.get(),
        (String)dialyzerInfo.get(PARAMKEY.ALQD_FLOOD_VOL)
        ) ;
  }

    //指示情報の値を設定

    // [][0]:装置設定アドレス(String) [][1]:指示コード(String)
    String params[][] = {
        //    アドレス(14)    透析時間
        {MACHINESETTINGKEY.ADR0014.get(),DialysisCond.COND_TOTAL_TIME.get()},  //
        //    アドレス(23)    シングルニードル電源
        {MACHINESETTINGKEY.ADR0023.get(),DialysisCond.COND_SINGLE_NEEDLE.get()}, //
        //    アドレス(26)    透析液温度
        {MACHINESETTINGKEY.ADR0026.get(),DialysisCond.COND_DIALYZE_TEMPERATURE.get()},  //
        //    アドレス(27)    透析液流量
        {MACHINESETTINGKEY.ADR0027.get(),DialysisCond.COND_DIALYZE_FLOW.get()}, //
        //    アドレス(28)    血流量
        {MACHINESETTINGKEY.ADR0028.get(),DialysisCond.COND_BLOOD_MEASURE.get()},  //
        //    アドレス(29)    IP使用選択
        {MACHINESETTINGKEY.ADR0029.get(),DialysisCond.COND_IP_SELECT.get()},  //
        //    アドレス(30)    IP速度
        {MACHINESETTINGKEY.ADR0030.get(),DialysisCond.COND_IP_SPEED.get()}, //
        //    アドレス(31)    IPスタート
        {MACHINESETTINGKEY.ADR0031.get(),DialysisCond.COND_IP_START.get()}, //
        //    アドレス(32)    自動ワンショット量
        {MACHINESETTINGKEY.ADR0032.get(),DialysisCond.COND_IP_ONESHOT_START.get()},//
        //    アドレス(33)    IPワンショット量
        {MACHINESETTINGKEY.ADR0033.get(),DialysisCond.COND_IP_MEASURE.get()},//
        //    アドレス(34)    IP電源OKモニタ切り
        {MACHINESETTINGKEY.ADR0034.get(),DialysisCond.COND_IP_AUTO_MONITOR_OFF.get()}, //
        //    アドレス(35)    IP電源OKモニタ切り時間
        {MACHINESETTINGKEY.ADR0035.get(),DialysisCond.COND_IP_AUTO_MONITOR_OFF_TIME.get()},//
        //    アドレス(36)    IP電源自動切り
        {MACHINESETTINGKEY.ADR0036.get(),DialysisCond.COND_IP_AUTO_POWER_OFF.get()}, //
        //    アドレス(37)    IP電源自動切り時間
        {MACHINESETTINGKEY.ADR0037.get(),DialysisCond.COND_IP_AUTO_POWER_OFF_TIME.get()},//
        //    アドレス(180)    IP速度最大値
        {MACHINESETTINGKEY.ADR0180.get(),DialysisCond.COND_IP_MAX_SPEED.get()}, //
        //    アドレス(380)    補液速度
        {MACHINESETTINGKEY.ADR0380.get(),DialysisCond.COND_REPLENISH_SPEED.get()},//
        //    アドレス(381)    補液温度
        {MACHINESETTINGKEY.ADR0381.get(),DialysisCond.COND_REPLENISH_TEMPERATURE.get()},
        //    アドレス(382)    補液量
        {MACHINESETTINGKEY.ADR0382.get(),DialysisCond.COND_REPLENISH_MEASURE.get()},//
        //    アドレス(388)    補液選択
        {MACHINESETTINGKEY.ADR0388.get(),DialysisCond.COND_REPLENISH_SELECT.get()}
    };

    //値の設定
    for(int i = 0 ; i < params.length ; i++)
    {
      //※キーが無いor数値ではない場合はnull
      setSendCondDecDataFromIndCond(
            machineSettingJsonForSendCond,
            params[i][0],
            indCondInfo,
            params[i][1]
          );
    }

    // pat2へB-0030（補液選択)を設定する(※devタグ"388"キーと同値)
    machineSettingPatJson.put(MACHINESETTINGKEY.ADRBB0030.get(), getDataFromIndCond(indCondInfo, DialysisCond.COND_REPLENISH_SELECT.get()));

    //補液選択に関する特別の処理
    if(null == this.getValueFromJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0388.get()))
    {
      machineSettingJsonForSendCond.put(MACHINESETTINGKEY.ADR0388.get(), 0) ;
      // pat2へB-0030（補液選択)を設定する(※devタグ"388"キーと同値)
      machineSettingPatJson.put(MACHINESETTINGKEY.ADRBB0030.get(), 0);
    }

    //---------------------------------------------------------------
    //    アドレス(15)  治療モード   DBから取得した値

    machineSettingJsonForSendCond.put(
        MACHINESETTINGKEY.ADR0015.get(),
        treatModeCd
      ) ;

    // pat2へB-0034（治療モード)を設定する(※devタグ"15"キーと同値)
    machineSettingPatJson.put(MACHINESETTINGKEY.ADRBB0034.get(), treatModeCd);


    //---------------------------------------------------------------
    //    アドレス(20)  除水目標値   DBから 取得した値
    String waterRemovalTarget = String.valueOf(getDataFromJSON(rstWeightInfo,PARAMKEY.WATER_REMOVAL_TARGET.get()));
    machineSettingJsonForSendCond.put(
        MACHINESETTINGKEY.ADR0020.get(),
        waterRemovalTarget
      ) ;

    //---------------------------------------------------------------
    //    アドレス(335) 治療開始時 血液ポンプ速度  (現行ソース:MonTransmitCondition.aspx.cs:2170行目あたり)

    Integer intItemB0036 = null ;
    try {
      intItemB0036 = Integer.parseInt(itemB0036) ;
    }
    catch(Exception e)
    {
      //パースに失敗したのでOFF扱い
      intItemB0036 = CHECKCONST.USE_OFF.getInt() ;
    }

    Double setValue = null ;

    if(
        this.checkDFASOption(ordNo)
        &&
        CHECKCONST.USE_ON.getInt() == intItemB0036)
    {
      //装置オプションのDFASが使用(その施設の装置の1つでも使用)の場合(checkDFASOption() == true ) && B-0036(治療開始時血流量使用有無)が1
      // 血流量 COND_BLOOD_MEASUREを設定
      setValue = condBloodMeasure ;
    }
    else
    {
      // その他の場合は -1を設定
      setValue = Double.valueOf("-1") ;
    }

    //アドレス335への値のセット
    machineSettingJsonForSendCond.put( MACHINESETTINGKEY.ADR0335.get(),setValue ) ;


    //その他の値の設定

    if
    (
      treatMode.equals(CommonIndConst.DEVICE_MODE_HD)
      ||
      treatMode.equals(CommonIndConst.DEVICE_MODE_ECUM)
    )
    {
      //    アドレス(380)    補液速度
      machineSettingJsonForSendCond.put( MACHINESETTINGKEY.ADR0380.get(),0 ) ;
      //    アドレス(381)    補液温度
      machineSettingJsonForSendCond.put( MACHINESETTINGKEY.ADR0381.get(),33.0 ) ;
      //    アドレス(382)    補液量
      machineSettingJsonForSendCond.put( MACHINESETTINGKEY.ADR0382.get(),0 ) ;
      //    アドレス(388)    補液選択
      machineSettingJsonForSendCond.put( MACHINESETTINGKEY.ADR0388.get(),0 ) ;
      // pat2へB-0030（補液選択)を設定する(※devタグ"388"キーと同値)
      machineSettingPatJson.put(MACHINESETTINGKEY.ADRBB0030.get(), 0);
    }

    if (null != dialyzerInfo) {
    //"A-0467"    "AREA"        面積
      setDataToJson(
          machineSettingJsonForSendCond,
          MACHINESETTINGKEY.ADR0467.get(),
          (String)dialyzerInfo.get(PARAMKEY.AREA)
          ) ;
    }

    //装置設定の組み立て ここまで
    //---------------------------------------

    //患者情報の組み立て
//    machineSettingPatJson
    //キーは
    //"Annn-nnn" or "Bnnn-nnn"のフォーマット(n:0-9の数値)
    //"Annn-nnn"は、patInfoAJsonForSendCondに追加
    //"Bnnn-nnn"は、patInfoBJsonForSendCondに追加
    //追加の際、キーとして、"Annn-"および"Bnnn-"は削除。残りの数値は0サプレスする。

    Iterator<String> it = machineSettingPatJson.keys();

    while(it.hasNext())
    {
      String key = it.next() ;

      JSONObject targetJson = null ;

      if(key.startsWith("A"))
      {
        targetJson = patInfoAJsonForSendCond ;
      }
      if(key.startsWith("B"))
      {
        targetJson = patInfoBJsonForSendCond ;
      }
      else
      {
        //ありえない要素
      }

      //キーの生成
      //-までを削除
      String newKey = key.replaceAll("^..*-", "") ;
      //0サプレス
      newKey = String.valueOf(Integer.parseInt(newKey)) ;

      //要素の追加
      targetJson.put(newKey,machineSettingPatJson.get(key)) ;
    }

    //---------------------------------------
    //条件送信データ(sendCond)組み立て


    // {
    //    "dev":{ 装置設定 },
    //    "pat1":{ 次患者情報A },
    //    "pat2":{ 次患者情報B }
    // }


//    //条件送信データ(装置設定値とモニタ監視設定値が配下にあります)
//    JSONObject sendCondData = new JSONObject("{}");
//    //装置設定値のセット
//    sendCondData.put(SEND_COND_PARAM.MACHINE_SETTING.get(), machineSettingJsonForSendCond);
//    //モニタ監視設定値のセット
//    sendCondData.put(
//            SEND_COND_PARAM.MONI_WATCH.get(),
//            hostWatch == null ? new JSONObject("{}") :hostWatch
//          );
    //条件送信データのセット
//    setDataToJson(sendCond, SEND_COND_PARAM.SEND_COND_DATA.get(),sendCondData.toString()) ;

    machineSettingJsonForSendCond = new JSONObject(machineSettingJsonForSendCond.toString().replace("\"null\"","null")) ;

    sendCond.put(SEND_COND_PARAM.MAIN_KEY_MACHINESETTING.get(),machineSettingJsonForSendCond);
    sendCond.put(SEND_COND_PARAM.MAIN_KEY_PATA.get(),patInfoAJsonForSendCond);
    sendCond.put(SEND_COND_PARAM.MAIN_KEY_PATB.get(),patInfoBJsonForSendCond);


//    //送信結果のセット
//    String resultKind = "1" ;
//    setDataToJson(sendCond, SEND_COND_PARAM.RESULT.get(),resultKind) ;

    //条件送信データ組み立て ここまで
    //---------------------------------------

    //条件送信データのデータベースへの格納(テーブル:MntMachineState:tmp_device_set_info)

    JSONObject jsonBody = new JSONObject();
    jsonBody.put("ordNo", ordNo);
    jsonBody.put("tmpDeviceSetInfo", sendCond);
    jsonBody.put("retMsg", retMsg);
    String parame = jsonBody.toString();

    return parame;
  }
  //--------------------------------------------------------------------------
  // End of mainProcess
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  // Methods
  //--------------------------------------------------------------------------
  /**
   * 「透析量プログラム」設定処理
   * @param treatDate 治療日
   * @param patId 患者ID
   * @param sendCond 条件送信データ
   * @param machineSettingJsonForSendCond 装置設定
   * @param indCondInfo 指示：治療条件情報
   * @param dw DW
   * @param dialyzerInfo ダイアライザー情報
   * @return
   */
  private HashMap<PARAMKEY,Object> procAlqdFloodVolProg(
        String ordNo,
        String patId,
        JSONObject sendCond,
        JSONObject machineSettingJsonForSendCond,
        JSONObject indCondInfo,
        String dw,
        HashMap<PARAMKEY,Object> dialyzerInfo
      )
  {
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
    String retMsg = "" ;
    String retLogMsg = "" ;

    //処理用変数
    String retStr = null ;

    Date calcTreatDate = null ;  //体液量算出時治療日
    OrdMain ordMainInfo = null ;
    Double addTotal = null;
    Double weightAfter = null;
    // 体液量＋補正値
    String bodyFluidAndReviseValue = "" ; // 体液量+補正値
    Integer dialysisTime = null;
    Double aveBloodVol = null;
    Double aveDialysisFlow = null;
    Double KoA = null;
    String rstCondInfo;
    if (ordNo != null) {
      try {
        // 検査日のord_mainを取得
        ordMainInfo = webAPICheckConditionSendService.getDataFromOrdMain(Long.parseLong(ordNo));
        String regExamDate = ordMainInfo.getTreatDate();
      }
      catch(Exception e)
      {
        ordMainInfo = null ;
      }
    }
    if(null == ordMainInfo) {
      //患者情報が取得できない。
      retMsg = String.format(CHECKMESSAGE.MSG000025.get(),patId) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000025LOG.get(),patId) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      return retVal;
    }

    if (ordMainInfo.getTreatDate() != null) {
      try {
        calcTreatDate = new SimpleDateFormat("yyyyMMdd HH:mm:ss").parse(ordMainInfo.getTreatDate());
      } catch(Exception e) {
        calcTreatDate = null ;
      }
    }

    if (null != ordMainInfo)
    {//体液量算出時治療日があれば処理を行う
      // 体液量+補正値 A-0284
      // 体液量計測時後体重を取得
      String tableRstDialysisWeight = ordMainInfo.getRstWeightInfo();
      if(null == tableRstDialysisWeight) {
        //透析実績測定体重が取得できない。
        //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
        retMsg = String.format(CHECKMESSAGE.MSG000026.get(), calcTreatDate) ;
        retLogMsg = String.format(CHECKMESSAGE.MSG000026LOG.get(),patId, calcTreatDate) ;
        retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
        retVal.put(PARAMKEY.RET_MSG, retMsg) ;
        retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
        retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
        return retVal;
      }

      JSONObject json = new JSONObject(tableRstDialysisWeight);
      if (json.has("weight_after")) {
        //A-0283に"WEIGHT_AFTER"の値をセット
        String weightAfterDate = json.get("weight_after").toString();
        setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0283.get(), weightAfterDate);
        weightAfter = Double.parseDouble(weightAfterDate);
      }
      if (json.has("add_total")) {
        addTotal = Double.parseDouble(json.get("add_total").toString());
      }

      rstCondInfo = ordMainInfo.getRstCondInfo();
      dialysisTime = getDialysisTime(rstCondInfo);
      KoA = getKoA(rstCondInfo);
      aveBloodVol = getAveBloodVol(rstCondInfo);
      aveDialysisFlow = getAveDialysisFlow(rstCondInfo);

      /*
      String rstDeviceSetInfo = ordMainInfo.getRstDeviceSetInfo();
      if (rstDeviceSetInfo != null) {
        JSONObject A = getQbQd(rstDeviceSetInfo);
        if (A != null) {
          List<Integer> bloodVolList = new ArrayList<Integer>();
          setAveDate(A, bloodVolList, 400, 409);
          List<Integer> changeoverTimeList = new ArrayList<Integer>();
          if (A.has("420")) {
            setAveDate(A, changeoverTimeList, 420, 428);
          }
          Integer maxStep = Integer.parseInt(A.get("429").toString());
          aveBloodVol = getAverageFlow(bloodVolList, changeoverTimeList, maxStep, dialysisTime);

          List<Integer> dialysisFlowList = new ArrayList<Integer>();
          setAveDate(A, dialysisFlowList, 410, 419);
          aveDialysisFlow = getAverageFlow(dialysisFlowList, changeoverTimeList, maxStep, dialysisTime);
        }
      }
      */

      if (
          (ordMainInfo.getTreatDate() != null && ordMainInfo.getTreatDate().compareTo("") != 0)
            &&
          (dialysisTime != null)    // 体液量算出時透析時間が数値型
            &&
          (aveBloodVol != null)         // 体液量算出時血流量平均値が数値型
          )
      {
        // BUN検査項目コードの取得
        // TODO: 担当者会社設定
        Double BUN1 = Double.parseDouble(String.valueOf(54));
        Double BUN2 = Double.parseDouble(String.valueOf(18));
        if (BUN1 == null || BUN2 == null)
        {
            // DBエラー
          retMsg = String.format(CHECKMESSAGE.MSG000027.get(), calcTreatDate) ;
          retLogMsg = String.format(CHECKMESSAGE.MSG000027LOG.get(),patId, calcTreatDate) ;
          retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
          retVal.put(PARAMKEY.RET_MSG, retMsg) ;
          retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
          retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
          return retVal;
        }
        else if (BUN1 == null || BUN2 == null)
        {
          // TODO: マスタ比較担当者会社設定
            // マスタ件数不足
          retMsg = String.format(CHECKMESSAGE.MSG000028.get(), calcTreatDate) ;
          retLogMsg = String.format(CHECKMESSAGE.MSG000028LOG.get(),patId, calcTreatDate) ;
          retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
          retVal.put(PARAMKEY.RET_MSG, retMsg) ;
          retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
          retVal.put(PARAMKEY.INSERT_COND, sendCond) ;
          return retVal;
        }

        //体液量算出用のデータを取得
        Double calc = getBodyLiqCalc(
            // 透析後体重(kg)
            weightAfter,
            // 透析時間(min)
            Double.parseDouble(String.valueOf(dialysisTime)),
            // 透析前 BUN(mg/dL)
            // TODO: 担当者会社設定
            BUN1,
            // 透析後 BUN(mg/dL)
            // TODO: 担当者会社設定
            BUN2,
            // 除水の総量(L)
            addTotal,
            // 血液量(ml/min)
            aveBloodVol,
            // 透析液流量(ml/min)
            aveDialysisFlow,
            // KoA(ml/min)
            KoA
            );
        if (null == calc)
        {
            // DBエラー
          retMsg = String.format(CHECKMESSAGE.MSG000029.get(), calcTreatDate) ;
          retLogMsg = String.format(CHECKMESSAGE.MSG000029LOG.get(),patId, calcTreatDate) ;
          retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
          retVal.put(PARAMKEY.RET_MSG, retMsg) ;
          retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
          retVal.put(PARAMKEY.INSERT_COND, sendCond) ;

          return retVal;
        }

        // 体液量+補正値計算結果
        bodyFluidAndReviseValue = calc.toString();
      }
      else
      {
          // 計算不可のため、体液量+補正値デフォルト値
          List<Map<String,Object>> dtEmpty = DialysisCalculator.getEmptyParamDataTable();
          bodyFluidAndReviseValue = new DialysisCalculator(dtEmpty.get(0)).getBodyFluidAndReviseValue();
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("設定値不備のため計算できませんでした。体液量+補正値にデフォルト値を設定しました。");
      	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          eventLogMessage.setLogMessage("透析後体重" + weightAfter);
      	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          eventLogMessage.setLogMessage("透析時間" + dialysisTime);
      	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          eventLogMessage.setLogMessage("除水量" + addTotal);
      	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          eventLogMessage.setLogMessage("平均血液量" + aveBloodVol);
      	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          eventLogMessage.setLogMessage("平均透析流量" + aveDialysisFlow);
      	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

      // 体液量+補正値 A-0284
      setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0284.get(),bodyFluidAndReviseValue) ;
      // 目標後体重 A-0285 DialysisCond.COND_TW
      if (rstCondInfo != null) {
      JSONObject jsonRstCondInfo = new JSONObject(rstCondInfo);
      retStr = getDataFromIndCond(jsonRstCondInfo,DialysisCond.COND_TW.get());
      // 目標体重が「-1」の場合、DWの値を設定
      if ("-1".equals(retStr)) retStr = dw;
      setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0285.get(),retStr) ;
      // 標準血流量 A-0286 DialysisCond.COND_BLOOD_MEASUR
      retStr = getDataFromIndCond(jsonRstCondInfo,DialysisCond.COND_BLOOD_MEASURE.get());
      setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0286.get(),retStr) ;
      }
      // KOA A-0287 DialysisCond.COND_DIALYZER
      setDataToJson(machineSettingJsonForSendCond,MACHINESETTINGKEY.ADR0287.get(),(String)dialyzerInfo.get(PARAMKEY.KOA)) ;
    }
    return retVal;
  }


  /**
   * 補液を使用するかどうかの判定フラグ取得処理
   * treatModeが、HD/ECUM/I-HDFの場合、使用
   * @param CommonIndConst treatMode 治療モード
   * @return true:補液を使用する
   */
  private boolean getFlagTreatModeIsReplenishment(CommonIndConst treatMode)
  {
      return
      (
        treatMode.equals(CommonIndConst.DEVICE_MODE_HD)
        ||
        treatMode.equals(CommonIndConst.DEVICE_MODE_ECUM)
        ||
        treatMode.equals(CommonIndConst.DEVICE_MODE_PRO_REP_LIQ)
      ) ;
  }

  /**
   *
   * 型式が100NXシリーズ・DABまたは、通信フォーマットがオフライン・通信共通プロトコルVer1-3のフラグ取得処理
   * ※現行システムでは型式コード+通信フォーマットに番号を割り当てている
   *  新システムでは、型式コードのみで、その機種の対応通信フォーマットも含まれるという判定方法
   * @param machineTypeCd 型式コード
   * @param comFormat 通信フォーマットコード
   * @return true:型式が100NXシリーズ・DABまたは、通信フォーマットがオフライン・通信共通プロトコルVer1-3
   */
  private boolean getFlagNXOrComProtocol123(
      String machineTypeCd,
      String comFormat)
  {
     return
         (
             //型式が100NXシリーズ・DABまたは、通信フォーマットがオフライン・通信共通プロトコルVer1-3のコードリスト
             Arrays.asList(
                 CommonIndConst.DEVICE_TYPE_CD_069_DCS_200Si.get(), //DCS-200Si(M,P)
                 CommonIndConst.DEVICE_TYPE_CD_070_DBB_200Si.get(), //DBB-200Si(N,Q)
                 CommonIndConst.DEVICE_TYPE_CD_071_DCS_100NX.get(), //DCS-100NX(M,P)
                 CommonIndConst.DEVICE_TYPE_CD_072_DBB_100NX.get(),  //DBB-100NX(N,Q)
                                                          //DBA
                 CommonIndConst.DEVICE_TYPE_CD_179_DAB_50Si.get(),    //DAB-50Si
                 CommonIndConst.DEVICE_TYPE_CD_180_DAB_70Si.get(),    //DAB-70Si
                 CommonIndConst.DEVICE_TYPE_CD_181_DAB_10NX.get(),    //DAB-10NX
                 CommonIndConst.DEVICE_TYPE_CD_182_DAB_20NX.get(),    //DAB-20NX
                 CommonIndConst.DEVICE_TYPE_CD_183_DAB_30NX.get(),    //DAB-30NX
                 CommonIndConst.DEVICE_TYPE_CD_184_DAB_40NX.get(),    //DAB-40NX
                 CommonIndConst.DEVICE_TYPE_CD_185_DAB_50NX.get(),    //DAB-50NX
                 CommonIndConst.DEVICE_TYPE_CD_186_DAB_70NX.get()     //DAB-70NX
               ).contains(machineTypeCd)
             ||    //または
             // 通信フォーマットがオフライン・通信共通プロトコルVer1-3
             Arrays.asList(
                 CommonIndConst.COM_FORMAT_F.get(),    //オフライン
                 CommonIndConst.COM_FORMAT_W.get(),    //共通プロトコルVer3
                 CommonIndConst.COM_FORMAT_Y.get(),    //共通プロトコルVer2
                 CommonIndConst.COM_FORMAT_Z.get()     //共通プロトコルVer1
               ).contains(comFormat)
         );
  }

  /**
   * 100NXシリーズかどうかの確認処理
   * ※現行システムでは型式コード+通信フォーマットに番号を割り当てている
   *  新システムでは、型式コードのみで、その機種の対応通信フォーマットも含まれるという判定方法
   * @param machineTypeCd 型式コード
   * @return true:100NXシリーズ
   */
  private boolean checkIs100NXSeries(
        String machineTypeCd
      )
  {
    //100NXシリーズ   TODO:2019.03.29 12．補液量上限値チェック処理内:型式コード:コードの変更有り
    return
      Arrays.asList(
          CommonIndConst.DEVICE_TYPE_CD_069_DCS_200Si.get(), //DCS-200Si(M,P)
          CommonIndConst.DEVICE_TYPE_CD_070_DBB_200Si.get(), //DBB-200Si(N,Q)
          CommonIndConst.DEVICE_TYPE_CD_071_DCS_100NX.get(), //DCS-100NX(M,P)
          CommonIndConst.DEVICE_TYPE_CD_072_DBB_100NX.get()  //DBB-100NX(N,Q)
        ).contains(machineTypeCd);
  }

  /**
   * DBB-100NX(Q,N)かどうかの確認処理
   * ※現行システムでは型式コード+通信フォーマットに番号を割り当てている
   *  新システムでは、型式コードのみで、その機種の対応通信フォーマットも含まれるという判定方法
   *  ※ 2020.03.02 DBB200Siも同様のチェックに含む
   * @param machineTypeCd 型式コード
   * @return true:DBB-100NX | DBB-200Si
   */
  private boolean checkIsDBB100NXor200Si(String machineTypeCd)
  {
    return
    Arrays.asList(
        CommonIndConst.DEVICE_TYPE_CD_070_DBB_200Si.get(), //DBB-200Si
        CommonIndConst.DEVICE_TYPE_CD_072_DBB_100NX.get()  //DBB-100NX(N,Q)
      ).contains(machineTypeCd);
  }

  /**
   * 数値文字列かどうかの判定処理
   * @param inputStr    チェック対象文字列
   * @return 数値以外:null  数値の場合:元の文字列
   */
  String checkNumOrNot(
        String inputStr
      )
  {
    //戻り値に元の文字列をセット
    String ret = inputStr ;

    try {
       //パースの実行(整数値以外は失敗する)
       Integer.parseInt(inputStr) ;
    }
    catch(Exception e)
    {
      //パースに失敗したので数値以外
      ret = null ;
    }

    return ret ;
  }

  /**
   * メインメソッド終了処理
   *    終了ログを出力する。メッセージがnull以外の場合、RuntimeExceptionを投げる
   * @param className   クラス名
   * @param methodName  メソッド名
   * @param retMsg      メッセージ
   */
  void exitMethod(
        String className,
        String methodName,
        String retMsg
      )
  {
    String endMsg = className + "." + methodName + "の処理を終了しました。" ;

    //終了ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(endMsg);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null != retMsg)
    {
      //メッセージがnullでなければRuntimeExceptionを投げる(Rollback用)
      //LogLevel.ERRORのログが出ます
      throw new RuntimeException(endMsg+":"+retMsg);
    }
  }

  /**
          ※ 通信フォーマットが通信共通プロトコルVer1-4以外フラグ取得処理
   *@return  true:通信フォーマットがVer1-4以外　false:Ver1-4のどれか
   */
  private boolean getFlagComFormatNotCommonProtocol(
        String comFormat
      )
  {
    return  (
          !comFormat.equals(CommonIndConst.COM_FORMAT_V.get())
          &&
          !comFormat.equals(CommonIndConst.COM_FORMAT_W.get())
          &&
          !comFormat.equals(CommonIndConst.COM_FORMAT_Y.get())
          &&
          !comFormat.equals(CommonIndConst.COM_FORMAT_Z.get())

          ) ;
  }

  /**
   * ダイアライザ情報取得処理
   * @param dialyzerCd ダイアライザコード
   * @return    取得した値　<PARAMKEY,value>
   *       PARAMKEY.UFR_WARNING_MAX         :初期UFR警報上限
   *       PARAMKEY.UFR_WARNING_MIN         :初期UFR警報下限
   *       PARAMKEY.UFR_WARNING_REDUCTION   :UFR低下率警報点
   *       PARAMKEY.UREitemACLEARANCE          :尿素クリアランス
   *       PARAMKEY.BLOODAMT                :血流量
   *       PARAMKEY.ALQD_FLOOD_VOL          :透析液量
   *       PARAMKEY.KOA                     :KoA
   */
  private HashMap<PARAMKEY,Object> getDialyzerInfoFromDB(
                                              String dialyzerCd,
                                              String facilityCd
                                           )
  {
    //戻り値
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;

    String result = null ;


    try {
      //DBからのデータ取得
      MstDialyzer mstDialyzer = webAPICheckConditionSendService.getDialyzerInfoFromDialyzer(
                                                      Integer.valueOf(dialyzerCd)
                                            ) ;

      //SELECT結果の受け取り
      if(null != mstDialyzer )
      {
        //返却値の格納
         // 初期UFR警報上限
         result = String.valueOf(mstDialyzer.getUfrWarningMax()) ;
         retVal.put(PARAMKEY.UFR_WARNING_MAX, result);
         // 初期UFR警報下限
         result = String.valueOf(mstDialyzer.getUfrWarningMin()) ;
         retVal.put(PARAMKEY.UFR_WARNING_MIN, result);
         // UFR低下率警報点
         result = String.valueOf(mstDialyzer.getUfrWarningReduction()) ;
         retVal.put(PARAMKEY.UFR_WARNING_REDUCTION, result);
         // 尿素クリアランス
         result = String.valueOf(mstDialyzer.getUreaClearance()) ;
         retVal.put(PARAMKEY.UREACLEARANCE, result);
         // 血流量
         result = String.valueOf(mstDialyzer.getBloodamt()) ;
         retVal.put(PARAMKEY.BLOODAMT, result);
         // 透析液量
         result = String.valueOf(mstDialyzer.getAlqdFloodVol()) ;
         retVal.put(PARAMKEY.ALQD_FLOOD_VOL, result);
         // Koa
         result = String.valueOf(mstDialyzer.getKoa()) ;
         retVal.put(PARAMKEY.KOA, result);
         // 面積
         result = String.valueOf(mstDialyzer.getArea()) ;
         retVal.put(PARAMKEY.AREA, result);
         // ダイアライザ種別
         result = String.valueOf(mstDialyzer.getDialyzerType()) ;
         retVal.put(PARAMKEY.DIALYZER_TYPE, result);
         // ガスパージ時間
         result = String.valueOf(mstDialyzer.getGasPurgeTime()) ;
         retVal.put(PARAMKEY.GAS_PURGE_TIME, result);
         // 置換洗浄量（透析液）
         result = String.valueOf(mstDialyzer.getSubstituentWashAmt()) ;
         retVal.put(PARAMKEY.SUBSTITUENT_WASH_AMT, result);
         // 膜洗浄（中空糸）
         result = String.valueOf(mstDialyzer.getMembraneWash()) ;
         retVal.put(PARAMKEY.MEMBRANE_WASH, result);
      }
      else
      {
        //データがなかった
        retVal = null ;
      }
    }
    catch(Exception e)
    {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      retVal = null ;
    }

    return retVal ;
  }

  /**
   * 指示情報のデータを装置設定に設定する処理
   * @param JSONObject machineSettingJson 装置設定Json
   * @param String addrKey    アドレス
   * @param JSONObject いんdCondInfo 指示情報Json
   * @param String addrKey    項目番号
   * @return boolean true:成功 false:失敗
   */
  boolean setSendCondDecDataFromIndCond(
          JSONObject    machineSettingJson,
          String        addrKey,
          JSONObject     indCondInfo,
          String        itemKey
      )
  {
      boolean ret = true ;

      //項目番号に合致する情報を探す
      JSONObject indexObj = null;
      if (indCondInfo.has(itemKey)) {
        indexObj = indCondInfo.getJSONObject(itemKey) ;
      }

      String setValue = null ;

      if(null != indexObj)
      {
        setValue = String.valueOf(indexObj.get("value")) ;
        //チェック
        if(null != setValue)
        {
           //数値かどうかのチェック
          try {
            Double.parseDouble(setValue) ;
          }
          catch(NumberFormatException e)
          {
            //パースに失敗したので数値ではない
            setValue = null ;
          }
        }
      }
      //セット
    // mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao start
    if (("380".equals(addrKey) || "382".equals(addrKey)) && "-1".equals(setValue)) {
      machineSettingJson.put(addrKey, "0");
    } else {
      machineSettingJson.put(addrKey, setValue);
    }
    // mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao end

      return ret ;
  }
//  /**
//   * Json文字列の指定したキーに情報を設定する
//   * 呼び出し例）
//   * setItemToJson(inputJson,new String[]{"dc","dev","B"},"25","99.0")
//   * @param JSONObject jsonObject 取得元Json
//   * @param String[] path 取得キーまでのパス(index0から階層構造で指定)
//   * @param String key 取得キー
//   * @param String value 設定値
//   * @return　取得文字列
//   * 取得途中でキーに該当がなかった場合、空Jsonを生成
//   * 値の設定時は、上書きまたは新規生成となる。
//   */
//  boolean setItemToJson(
//      JSONObject jsonObject,
//      String[] path,
//      String key,
//      String value
//    )
//  {
//    boolean ret = true ;
//
//    if(null == path)
//    {//null対応：1階層のJsonでの値の設定
//      path = new String[0] ;
//    }
//
//    String[] keys = new String[path.length+1] ;
//    for(int i = 0 ; i < path.length ; i++)
//    {
//      keys[i] = path[i] ;
//    }
//
//    keys[path.length] = key ;
//
//    int len = keys.length ;    //キー数の取得
//
//    JSONObject tmpJson = jsonObject ;
//
//    for(int index = 0 ; index < len ; index++)
//    {
//      if(index == len -1)
//      {
//        //最後のキーの処理
//        try
//        {
//          //値の設定
//          tmpJson.put(keys[index], value) ;
//        }
//        catch(Exception e)
//        {
//          //パースエラー
//          ret = false ;
//        }
//      }
//      else
//      {
//        try {
//          //キーをもとにJson文字列を取得
//          tmpJson = tmpJson.getJSONObject(keys[index]) ;
//        }
//        catch(Exception e)
//        {
//          //キーがなかった
//          try
//          {
//            //キーを生成(要素は空Json)
//            tmpJson.put(keys[index], new JSONObject("{}")) ;
//            tmpJson = tmpJson.getJSONObject(keys[index]) ;
//          }
//          catch(Exception e2)
//          {
//            //キーを生成できなかった
//            ret = false ;
//            break ;
//          }
//        }
//        finally
//        {
//          if(null == tmpJson)
//          {
//            //戻り値をfalseに設定
//            ret = false ;
//            //ループの終了
//            break ;
//          }
//        }
//      }
//    }
//    return ret ;
//  }

  /**
   * Json文字列から指定したキー(アドレス文字列)の情報を取得する
   * 呼び出し例）
   * getItemFromJson(inputJson,"B","25")
   * @param JSONObject jsonObject 取得元Json
   * @param String path 取得キーの付加文字
   * @param String key 取得キー(アドレス文字列)
   * @return　取得文字列
   * 取得途中でJson文字列でないものもしくはキーに該当がなかった場合、戻り値はnull
   *　取得キー(取得キーの最後のキー)に該当する値がなかった場合、戻り値はnull
   */
  String getItemFromJson(
        JSONObject jsonObject,
        String path,
        String key
      )
  {
    //戻り値の初期化
    String ret = null;

    if (key.compareTo("ord_no") != 0) {
    //頭0埋め3桁化&頭にpathを付加
      key = ("000" + key) ;
      key = path + key.substring(key.length() - 3) ;
    }

    try
    {
      //値の取得

      ret = String.valueOf(jsonObject.get(key)) ;
    }
    catch(Exception e)
    {
      //キーがなかった or パースエラー
      ret = null ;
    }

    return ret ;
  }

  /**
   * Json文字列から指定したキーの情報を取得する
   * @param JSONObject jsonObject 取得元Json
   * @param String key 取得キー
   * @return　取得文字列
   * 取得途中でJson文字列でないものもしくはキーに該当がなかった場合、戻り値はnull
   *　取得キー(取得キーの最後のキー)に該当する値がなかった場合、戻り値はnull
   */
  String getItemFromJson(
        JSONObject jsonObject,
        String key
      )
  {
    //戻り値の初期化
    String ret = null;
    try
    {
      //値の取得

      ret = String.valueOf(jsonObject.get(key)) ;
    }
    catch(Exception e)
    {
      //キーがなかった or パースエラー
      ret = null ;
    }

    return ret ;
  }
  /**
   * 装置モードEnumキー取得処理
   * 処理を簡便にするために装置モードをEnumキー化する
   * @param String treatModeValue 装置モード(数値)
   * @return CommonIndConst treatMode 装置モード(Enumキー)
   */
  CommonIndConst getTreatModeEnumKey(String tmp)
  {
    CommonIndConst treatMode = CommonIndConst.DEVICE_MODE_UNKNOWN ;
    if(tmp.equals(CommonIndConst.DEVICE_MODE_UNKNOWN.get())) {
      //装置モード:不明
      treatMode = CommonIndConst.DEVICE_MODE_UNKNOWN ;
    }
    else if(tmp.equals(CommonIndConst.DEVICE_MODE_HD.get())) {
    //装置モード:HD
      treatMode = CommonIndConst.DEVICE_MODE_HD ;
    }
    else if(tmp.equals(CommonIndConst.DEVICE_MODE_ECUM.get())) {
    //装置モード:ECUM
      treatMode = CommonIndConst.DEVICE_MODE_ECUM ;
    }
    else if(tmp.equals(CommonIndConst.DEVICE_MODE_HDF.get())) {
    //装置モード:HDF
      treatMode = CommonIndConst.DEVICE_MODE_HDF ;
    }
    else if(tmp.equals(CommonIndConst.DEVICE_MODE_HF.get())) {
    //装置モード:HF
      treatMode = CommonIndConst.DEVICE_MODE_HF ;
    }
    else if(tmp.equals(CommonIndConst.DEVICE_MODE_HD_REP_LIQ.get())) {
    //装置モード:HD＋補液
      treatMode = CommonIndConst.DEVICE_MODE_HD_REP_LIQ ;
    }
    else if(tmp.equals(CommonIndConst.DEVICE_MODE_ECUM_REP_LIQ.get())) {
    //装置モード:ECUM＋補液
      treatMode = CommonIndConst.DEVICE_MODE_ECUM_REP_LIQ ;
    }
    else if(tmp.equals(CommonIndConst.DEVICE_MODE_AFBF.get())) {
    //装置モード:AFBF
      treatMode = CommonIndConst.DEVICE_MODE_AFBF ;
    }
    else if(tmp.equals(CommonIndConst.DEVICE_MODE_OHDF.get())) {
    //装置モード:OHDF
      treatMode = CommonIndConst.DEVICE_MODE_OHDF ;
    }
    else if(tmp.equals(CommonIndConst.DEVICE_MODE_OHF.get())) {
    //装置モード:OHF
      treatMode = CommonIndConst.DEVICE_MODE_OHF ;
    }
    else if(tmp.equals(CommonIndConst.DEVICE_MODE_PURIFICATION.get())) {
    //装置モード:特殊浄化
      treatMode = CommonIndConst.DEVICE_MODE_PURIFICATION ;
    }
    else if(tmp.equals(CommonIndConst.DEVICE_MODE_PRO_REP_LIQ.get())) {
    //装置モード:I-HDF
      treatMode = CommonIndConst.DEVICE_MODE_PRO_REP_LIQ ;
    }

    return treatMode ;
  }

  /**
   * 条件送信データをDBにセットする処理
   * 当該カラムに条件送信データを追加する
   * カラムがnullの場合、Json配列化して、新規追加する
   * データが存在する場合、Json配列の最後に追加する。
   * @param String ord_no オーダー番号
   * @param JSONObject jsonCondData 条件送信データ
   * @return boolean true:成功　false:失敗
   */
  public boolean setCondInfoToDB(
        String ord_no,
        JSONObject jsonCondData
      )
  {
    boolean ret = true ;

    int retUpdate = webAPICheckConditionSendService.insertSendCondData(
                          Long.parseLong(ord_no),
                          jsonCondData.toString()
                    );

    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("retUpdate:" + retUpdate);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

    if(1 != retUpdate)
    {
      //更新失敗
      ret = false ;
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("更新失敗:更新回数が1件以上です:" + retUpdate);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    }
    return ret ;
  }

  /**
   * 8．尿素クリアランスチェック処理
   * ・通信共通プロトコルVer1-4の場合、尿素クリアランスチェック処理は行わない。
   * ・尿素クリアランス>血流量の場合、送信処理は実行しない。
   * ・尿素クリアランス>透析液流量の場合、送信処理は実行しない。
   * @param flagComFormatNotCommonProtocol  通信フォーマットが通信共通プロトコルVer1-4以外フラグ
   * @param ureaClearance       尿素クリアランス(装置設定から)
   * @param condBloodMeasure    血流量(指示情報から)
   * @param condDialyzeMeasure  透析液流量(指示情報から)
   * @return <PARAMKEY,値>
   *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
   *            PARAMKEY.RET_MSG:エラーメッセージ
   */
  private HashMap<PARAMKEY,Object> checkUreaClearance(
      boolean flagComFormatNotCommonProtocol,
      Double ureaClearance,
      Double condBloodMeasure,
      Double condDialyzeMeasure
    )
  {
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
    String retMsg = "" ;
    String retLogMsg = "";

    //処理成否判定用フラグ
    boolean ret = true ;

    if(flagComFormatNotCommonProtocol)
    {//共通プロトコルVer1-4以外の場合、以下のチェック処理を行う
      ret = true ;
      // del FutreNetWeb+SI課題管理No7224 趙 start
      // if(ureaClearance > condBloodMeasure)
      // {//尿素クリアランス>血流量の場合
        //警告メッセージをセット（送信処理は行わない）
        // retMsg = String.format(CHECKMESSAGE.MSG000003.get(),ureaClearance , condBloodMeasure) ;
        // retLogMsg = String.format(CHECKMESSAGE.MSG000003LOG.get(),ureaClearance , condBloodMeasure) ;
        // ret = false ;
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        // EventLogMessage eventLogMessage = new EventLogMessage();
        // eventLogMessage.setLogMessage(retMsg);
        // logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // }
      // else if(ureaClearance > condDialyzeMeasure)
      // del FutreNetWeb+SI課題管理No7224 趙 end
      if(ureaClearance > condDialyzeMeasure)
      {//尿素クリアランス>透析液流量の場合
        //警告メッセージを設定（送信処理は行わない）
        retMsg = String.format(CHECKMESSAGE.MSG000004.get(),ureaClearance , condDialyzeMeasure) ;
        retLogMsg = String.format(CHECKMESSAGE.MSG000004LOG.get(),ureaClearance , condBloodMeasure) ;
        ret = false ;
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(retMsg);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      }

      if(!ret)
      {//上記判定で"送信処理は行わない"場合の処理
        //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
        retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
        retVal.put(PARAMKEY.RET_MSG, retMsg) ;
        retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(retMsg);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
        return retVal;
      }

    }

    return retVal ;
  }

  /**
   * 9．透析量プログラムチェック処理
   * ①．条件送信可能（前体重測定時で、ベッドが確定されている場合）のみ実行する。
   * ②．透析装置が通信共通プロトコルVer1-4以外の場合のみ実行する。
   * ③．透析液量プログラム使用になっている場合下記のチェック処理を実行する。
   * ・システム設定の透析量プログラム使用不可になっている場合は、透析量プログラム使用しないに変更して送信処理を実行する。
   * ・体液量算出時治療日が未設定の場合は、透析量プログラム使用しないに変更して送信処理を実行する。
   * ・透析実績から液体量算出治療日の透析実績（透析前体重、透析後体重、除水積算値の取得）を取得します。取得に失敗した場合は、透析量プログラムを使用しないに変更し、送信処理を続ける
   * ・DW＜液体量算出治療日の測定後後体重値*0.8の場合、透析量プログラムを使用しないに変更し、送信処理を続ける。
   * ・DW＞液体量算出治療日の測定後後体重値*1.2の場合、透析量プログラムを使用しないに変更し、送信処理を続ける。
   * ・検査結果「PAT_EXAMIN_HST」から液体量算出治療日の検査結果（BUN直前値、BUN直後値）を取得します。取得に失敗した場合は、透析量プログラムを使用しないに変更し、送信処理を続ける
   * ・Kt/V上下限値および、体液量＋補正値の算出を行う、算出に失敗した場合は、透析量プログラムを使用しないに変更し、送信処理を続ける
   * ・（DW＊0.4）＞　体液量＋補正値の場合、透析量プログラムを使用しないに変更し、送信処理を続ける。
   * ・（DW＊0.9）＜　体液量＋補正値の場合、透析量プログラムを使用しないに変更し、送信処理を続ける。
   * @param alqdFloodVolProgSetting 透析量プログラム設定(装置設定Json　key:282)
   * @param alqdFloodVolProgSystemSetting 透析量プログラム設定(システム設定)
   * @param DW                      ドライウエイト
   * @param treatMode               装置治療モード
   * @param patId                   患者ID
   * @param flagComFormatNotCommonProtocol  通信フォーマットが通信共通プロトコルVer1-4以外フラグ
   * @param calcTreatDate        液体量算出治療日
   * @return <PARAMKEY,値>
   *            PARAMKEY.AFVPROG:透析量プログラム設定(A-0282)
   *            PARAMKEY.AFVPROG_SYS:透析量プログラム設定(システム）
   *            PARAMKEY.AFVPROG_SYS_ON:透析量プログラム使用フラグ
   */
  private HashMap<PARAMKEY,Object> checkAlqdFloodVolProg(
      String alqdFloodVolProgSetting,
      String alqdFloodVolProgSystemSetting,
      String DW,
      CommonIndConst treatMode,
      String patId,
      boolean flagComFormatNotCommonProtocol,
      String ordNo
    )
  {
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;

    //一時変数
    String tmp ;
    Double addTotal = null;
    Double weightAfter = null;

    //ローカル変数(返却用)の初期化

    //透析量プログラム設定(システム）
    String alqdFloodVolProgSys = CommonIndConst.SETTING_ON.get() ;
    //透析量プログラム使用フラグ
    boolean flagAlqdFloodVolProgSysOn = alqdFloodVolProgSys.equals(CommonIndConst.SETTING_ON.get());

    if(flagComFormatNotCommonProtocol)
    {//通信共通プロトコルVer1-4以外の場合、以下の処理を行う
      //透析量プログラム設定(A-0282)の取得
      if(null != alqdFloodVolProgSetting && alqdFloodVolProgSetting.equals(CommonIndConst.SETTING_ON.get()))
      {//透析量プログラム設定が"使用する"の場合
        //透析量プログラム設定(システム）の取得
        alqdFloodVolProgSys = alqdFloodVolProgSystemSetting ;    //TODO:取得確認
        if(null == alqdFloodVolProgSys)
        {
          //透析量プログラム設定を取得できない
          String retMsg = String.format(CHECKMESSAGE.MSG000044.get()) ;
          String retLogMsg = String.format(CHECKMESSAGE.MSG000044LOG.get()) ;
          retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
          retVal.put(PARAMKEY.RET_MSG, retMsg) ;
          retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
          return retVal;
        }

        if(alqdFloodVolProgSys.equals(CommonIndConst.SETTING_ON.get()))
        {//透析量プログラム設定(システム）が"使用する"の場合
          //液体量算出治療日の透析実績取得（透析前体重、透析後体重、除水積算値の取得）を行う
          OrdMain ordMainInfo = null;
          if (ordNo != null && !ordNo.equals("null")) {
            // 検査日のord_mainを取得
            ordMainInfo = webAPICheckConditionSendService.getDataFromOrdMain(Long.parseLong(ordNo));
          }

          if(null != ordMainInfo)
          {//液体量算出治療日の透析実績取得ができた場合
            //液体量算出治療日の測定後後体重値の取得
            String tableRstDialysisWeight = ordMainInfo.getRstWeightInfo();

            JSONObject json = new JSONObject(tableRstDialysisWeight);
            if (json.has("weight_after")) {
              String weightAfterDate = json.get("weight_after").toString();
              weightAfter = Double.parseDouble(weightAfterDate) ;
            }
            if (json.has("add_total")) {
              addTotal = Double.parseDouble(json.get("add_total").toString());
            }

            if (addTotal == null || weightAfter == null) {
              //液体量算出治療日の透析実績取得ができなかった
              //透析液量プログラム設定を使用しないに変更(情報送信情報組み立て時に設定。フラグで記録)
              flagAlqdFloodVolProgSysOn = false ;
              EventLogMessage eventLogMessage = new EventLogMessage();
          	  eventLogMessage.setLogMessage("設定値不備のため、透析量プログラムを使用できませんでした。");
          	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              eventLogMessage.setLogMessage("透析後体重" + weightAfter);
          	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            } else {
              //DWの数値化
              String rstCondInfo = ordMainInfo.getRstCondInfo();
              Double targetWeightAfter = getTargetWeightAfter(rstCondInfo);
              Double condDw = targetWeightAfter;

              //DWの上限の計算
              Double dUpperLimit = 1.2 * weightAfter ;
              //DWの下限の計算
              Double dUnderLimit = 0.8 * weightAfter ;

              if(condDw <= dUpperLimit && condDw >= dUnderLimit)
              {//DWが範囲内の場合
                //液体量算出治療日の検査結果取得(液体量算出治療日の検査結果（BUN直前値、BUN直後値）を取得)
                // List<Map<String,Object>> retValResult = getBUNCode();
                // TODO: 担当者会社設定
                Double BUN1 = Double.parseDouble(String.valueOf(54));
                Double BUN2 = Double.parseDouble(String.valueOf(18));

                if(BUN1 != null && BUN2 != null)
                {//BUN直前値、BUN直後値が取得できた場合
                  //Kt/V上下限値および、体液量＋補正値の算出を行う

                  Integer dialysisTime = null;
                  Double aveBloodVol = null;
                  Double aveDialysisFlow = null;
                  Double KoA = null;

                  dialysisTime = getDialysisTime(rstCondInfo);
                  KoA = getKoA(rstCondInfo);
                  aveBloodVol = getAveBloodVol(rstCondInfo);
                  aveDialysisFlow = getAveDialysisFlow(rstCondInfo);

                  /*
                  String rstDeviceSetInfo = ordMainInfo.getRstDeviceSetInfo();
                  if (rstDeviceSetInfo != null) {
                    JSONObject A = getQbQd(rstDeviceSetInfo);
                    if (A != null) {
                      List<Integer> bloodVolList = new ArrayList<Integer>();
                      setAveDate(A, bloodVolList, 400, 409);
                      List<Integer> changeoverTimeList = new ArrayList<Integer>();
                      if (A.has("420")) {
                        setAveDate(A, changeoverTimeList, 420, 428);
                      }
                      Integer maxStep = Integer.parseInt(A.get("429").toString());
                      aveBloodVol = getAverageFlow(bloodVolList, changeoverTimeList, maxStep, dialysisTime);

                      List<Integer> dialysisFlowList = new ArrayList<Integer>();
                      setAveDate(A, dialysisFlowList, 410, 419);
                      aveDialysisFlow = getAverageFlow(dialysisFlowList, changeoverTimeList, maxStep, dialysisTime);
                    }
                  }
                  */

                  if (tableRstDialysisWeight == null || dialysisTime == null || aveBloodVol == null || aveDialysisFlow == null) {
                    //BUN直前値、BUN直後値が取得できなかった場合
                    //透析液量プログラム設定を使用しないに変更(情報送信情報組み立て時に設定。フラグで記録)
                    flagAlqdFloodVolProgSysOn = false ;
                    EventLogMessage eventLogMessage = new EventLogMessage();
                	eventLogMessage.setLogMessage("設定値不備のため、透析量プログラムを使用できませんでした。");
                	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                    eventLogMessage.setLogMessage("透析後体重" + weightAfter);
                	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                    eventLogMessage.setLogMessage("透析時間" + dialysisTime);
                	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                    eventLogMessage.setLogMessage("除水量" + addTotal);
                	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                    eventLogMessage.setLogMessage("平均血液量" + aveBloodVol);
                	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                    eventLogMessage.setLogMessage("平均透析流量" + aveDialysisFlow);
                	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                  } else {
                    Double calc = getBodyLiqCalc(
                        // 透析後体重(kg)
                        weightAfter,
                        // 透析時間(min)
                        Double.parseDouble(String.valueOf(dialysisTime)),
                        // 透析前 BUN(mg/dL)
                        // TODO: 担当者会社設定
                        BUN1,
                        // 透析後 BUN(mg/dL)
                        // TODO: 担当者会社設定
                        BUN2,
                        // 除水の総量(L)
                        addTotal,
                        // 血液量(ml/min)
                        aveBloodVol,
                        // 透析液流量(ml/min)
                        aveDialysisFlow,
                        // KoA(ml/min)
                        KoA
                        );

                      //体液量＋補正値の計算取得を行う
                    if(calc != null)
                    {//体液量＋補正値の計算取得できた場合
                      String bodyFluidAndReviseValue = calc.toString();
                      Double dBodyFluidAndReviseValue = Double.parseDouble(bodyFluidAndReviseValue);
                      dBodyFluidAndReviseValue = dBodyFluidAndReviseValue / 1000;
                      //Kt/V上下限値計算を行う
                      Map<String, Double> ktOverV = getKtOverVUpperAndUnderLimitInfo(
                          // TX： 透析時間(min)
                          dialysisTime,
                          // QB： 血液量(ml/min)
                          aveBloodVol,
                          // KOA0： KoA(ml/min)
                          KoA,
                          // VWa： 体液量 補正値(ml)
                          calc,
                          // BWa： 透析後体重(kg)
                          weightAfter,
                          // BW2： 目標透析終了時体重(kg)
                          targetWeightAfter,
                          // DBWX： 除水量(kg)
                          addTotal
                          );

                      if(null != ktOverV)
                      {//Kt/V上下限値計算できた場合
                        //DWのチェックを行う
                        //DWの上限の計算
                        dUpperLimit = 0.9 * dBodyFluidAndReviseValue ;
                        //DWの下限の計算
                        dUnderLimit = 0.4 * dBodyFluidAndReviseValue ;


                        if(condDw > dUpperLimit || condDw < dUnderLimit)
                        {//DWが範囲外の場合
                          //透析液量プログラム設定を使用しないに変更(情報送信情報組み立て時に設定。フラグで記録)
                          EventLogMessage eventLogMessage = new EventLogMessage();
                      	  eventLogMessage.setLogMessage("目標体重が範囲外です。透析量プログラムを使用できませんでした。");
                      	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                          eventLogMessage.setLogMessage("目標体重" + condDw);
                      	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                          eventLogMessage.setLogMessage("目標体重上限(体液量+補正値90%)" + dUpperLimit);
                      	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                          eventLogMessage.setLogMessage("目標体重下限(体液量+補正値40%)" + dUnderLimit);
                      	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                          flagAlqdFloodVolProgSysOn = false ;
                        }
                      }
                      else
                      {//Kt/Vの値が計算できなかった場合
                        //透析液量プログラム設定を使用しないに変更(情報送信情報組み立て時に設定。フラグで記録)
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        eventLogMessage.setLogMessage("Kt/V上下限値を取得できないため、透析量プログラムを使用できませんでした。");
                        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                        flagAlqdFloodVolProgSysOn = false ;
                      }
                    }
                    else
                    {
                      //体液量＋補正値の計算できなかった場合
                      //透析液量プログラム設定を使用しないに変更(情報送信情報組み立て時に設定。フラグで記録)
                      EventLogMessage eventLogMessage = new EventLogMessage();
                      eventLogMessage.setLogMessage("Kt/V上下限値を取得できないため、透析量プログラムを使用できませんでした。");
                  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                      flagAlqdFloodVolProgSysOn = false ;
                    }
                  }
                }
                else
                {//BUN直前値、BUN直後値が取得できなかった場合
                  //透析液量プログラム設定を使用しないに変更(情報送信情報組み立て時に設定。フラグで記録)
                  EventLogMessage eventLogMessage = new EventLogMessage();
                  eventLogMessage.setLogMessage("BUNが設定されていないため、透析量プログラムを使用できませんでした。");
              	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                  flagAlqdFloodVolProgSysOn = false ;
                }
              }
              else
              {//DWが範囲外だった場合
                //透析液量プログラム設定を使用しないに変更(情報送信情報組み立て時に設定。フラグで記録)
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage("目標体重が範囲外です。透析量プログラムを使用できませんでした。");
                logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                eventLogMessage.setLogMessage("目標体重" + condDw);
                logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                eventLogMessage.setLogMessage("目標体重上限(透析後体重120%)" + dUpperLimit);
                logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                eventLogMessage.setLogMessage("目標体重下限(透析後体重80%)" + dUnderLimit);
                logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                flagAlqdFloodVolProgSysOn = false ;
              }
            }
          }
          else
          {//液体量算出治療日の透析実績取得ができなかった
            //透析液量プログラム設定を使用しないに変更(情報送信情報組み立て時に設定。フラグで記録)
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("検査日が取得できないため、透析量プログラムを使用できませんでした。");
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            flagAlqdFloodVolProgSysOn = false ;
          }
        }
        else
        {//透析量プログラム設定(システム）がOFF
          //透析液量プログラム設定を使用しないに変更(情報送信情報組み立て時に設定。フラグで記録)
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("透析量プログラムを使用しない設定になっています。");
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          flagAlqdFloodVolProgSysOn = false ;
        }
      }
      else
      {
        //ON意外だった場合は、OFFに設定しておく
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("透析量プログラムを使用しない設定になっています。");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        alqdFloodVolProgSetting = CommonIndConst.SETTING_OFF.get();
        flagAlqdFloodVolProgSysOn = false ;
      }
    }else {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("通信共通プロトコルVer1-4またはオフラインです。透析量プログラムを使用できませんでした。");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  	  	flagAlqdFloodVolProgSysOn = false ;
    }

    //戻り値のセット(他の処理で使うため、メインに戻す)
    //透析量プログラム設定(A-0282)をセット
    retVal.put(PARAMKEY.AFVPROG, alqdFloodVolProgSetting) ;
    //透析量プログラム設定(システム）をセット
    retVal.put(PARAMKEY.AFVPROG_SYS, alqdFloodVolProgSys) ;
    //透析量プログラム使用フラグをセット
    retVal.put(PARAMKEY.AFVPROG_SYS_ON, Boolean.valueOf(flagAlqdFloodVolProgSysOn)) ;

    //戻す
    return retVal ;
  }

  /**
   * 10．血流量設定上限値チェック処理
   * 血流量設定上限値が、＞600の場合、もしくは、未設定の場合は、600を血流量設定上限値とする。
   * 血流量　>　血流量設定上限値の場合、警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
   * @param upperLimit          血流量設定上限値
   * @param condBloodMeasure    血流量
   * @return <PARAMKEY,値>
   *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
   *            PARAMKEY.RET_MSG:エラーメッセージ
   */
  private HashMap<PARAMKEY,Object> checkBloodAmountSetting(
        String uperLimit,
        Double condBloodMeasure
      )
  {
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;

    //血流量設定上限値(double)
    Double dUpperLimit = null;
    //血流量設定上限値最大(double)
    Double maxUpperLimit = CHECKCONST.BloodAmount_MAX_VALUE.getDbl() ;

    if(null == uperLimit) {
      //定義がない場合、固定値(600)を採用
      dUpperLimit = maxUpperLimit ;
    }
    else
    {
        try {
          dUpperLimit = Double.parseDouble(uperLimit);
          //血流量設定上限値が、＞600の場合、600を血流量設定上限値とする
          dUpperLimit = dUpperLimit > maxUpperLimit ? maxUpperLimit : dUpperLimit ;
        }
        catch(Exception e)
        {
          //doubleに変換できない場合(nullの場合もロジック的にはここに含めてもいいかもしれません)
          dUpperLimit = maxUpperLimit ;
        }
    }

    //値の比較
    if(condBloodMeasure > dUpperLimit) {
      //血流量　>　血流量設定上限値の場合、警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
      String retMsg = String.format(CHECKMESSAGE.MSG000005.get(),condBloodMeasure , dUpperLimit) ;
      String retLogMsg = String.format(CHECKMESSAGE.MSG000005LOG.get(),condBloodMeasure , dUpperLimit) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      return retVal;
    }

    return retVal ;
  }

//  /**
//   * JUnit 確認
//   */
//  private int testJunit(int input)
//  {
//    input++ ;
//    return input ;
//  }
//
  /**
   * 11．透析液温度上下限値チェック処理
   * 透析液温度上限値が、>40の場合、もしくは、未設定の場合は、40を血流量設定上限値とする
   * 透析液温度下限値が、<33の場合、もしくは、未設定の場合は、33を血流量設定下限値とする。
   * 透析液温度>透析液温度上限値もしくは透析液温度<透析液温度下限値の場合、警告メッセージを返却する（HttpStatusはOK以外）
   * @param upperLimit               透析液温度上限値
   * @param underLimit               透析液温度下限値
   * @param condDialyzeTemperature  透析液温度
   * @return <PARAMKEY,値>
   *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
   *            PARAMKEY.RET_MSG:エラーメッセージ
   */
  private HashMap<PARAMKEY,Object> checkDialyzeLiquidTemperatureSetting(
        String upperLimit,
        String underLimit,
        Double     condDialyzeTemperature
      )
  {
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;

    String retMsg = "" , retLogMsg = "";

    //上限値の決定
    //透析液温度上限値(dev:A-0182)を取得する:その値が、＞40の場合、もしくは、未設定の場合は、40を血流量設定上限値とする
    //透析液温度上限値(double)
    Double dUpperLimit = null;
    //透析液温度上限値最大(double)
    Double maxUpperLimit = CHECKCONST.DialyzeLiquidTemperature_MAX_VALUE.getDbl() ;

    if(null == upperLimit) {
      //定義がない場合、固定値(40)を採用
      dUpperLimit = maxUpperLimit ;
    }
    else
    {
        try {
          dUpperLimit = Double.parseDouble(upperLimit);
          //透析液温度上限値が、＞40の場合、40を透析液温度設定上限値とする
          dUpperLimit = dUpperLimit > maxUpperLimit ? maxUpperLimit : dUpperLimit ;
        }
        catch(Exception e)
        {
          //doubleに変換できない場合(nullの場合もロジック的にはここに含めてもいいかもしれません)
          dUpperLimit = maxUpperLimit ;
        }
    }

    //下限値の決定
    //透析液温度下限値(dev:A-0183)を取得する:その値が、<33の場合、もしくは、未設定の場合は、33を血流量設定上限値とする。
    //透析液温度下限値(double)

    Double dUnderLimit ;
    //透析液温度下限値最大(double)
    Double maxUnderLimit = CHECKCONST.DialyzeLiquidTemperature_MIN_VALUE.getDbl() ;

    if(null == underLimit) {
      //定義がない場合、固定値(33)を採用
      dUnderLimit = maxUnderLimit ;
    }
    else
    {
        try {
          dUnderLimit = Double.parseDouble(underLimit);
          //透析液温度下限値が、<33の場合、33を透析液温度設定上限値とする
          dUnderLimit = dUnderLimit < maxUnderLimit ? maxUnderLimit : dUnderLimit ;
        }
        catch(Exception e)
        {
          //doubleに変換できない場合(nullの場合もロジック的にはここに含めてもいいかもしれません)
          dUnderLimit = maxUnderLimit ;
        }
    }

    //値の比較 TODO:わかりやすいように条件整理
    if(condDialyzeTemperature > dUpperLimit)
    {//透析液温度>透析液温度上限値
      //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
      retMsg = String.format(CHECKMESSAGE.MSG000007.get(),condDialyzeTemperature,dUpperLimit) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000007LOG.get(),condDialyzeTemperature,dUpperLimit) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      return retVal;
    }
    else if(condDialyzeTemperature < dUnderLimit)
    {//透析液温度＜透析液温度下限値
      //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
      retMsg = String.format(CHECKMESSAGE.MSG000006.get(),condDialyzeTemperature,dUnderLimit) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000006LOG.get(),condDialyzeTemperature,dUnderLimit) ;
      retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      return retVal ;
    }

    return retVal ;
  }

  /**
   * 12．補液量上限値チェック処理
   * ・装置モードが、HD・ECUM・I-HDFの場合は、送信処理を続ける(メソッドの外で判定。該当する場合は、当メソッドを呼ばない)
   * ・補液計算優先項目（A-0389）が、補液比率の場合、又は、濾過率算出の場合は、送信処理を続ける。
   * また、補液計算優先項目が未設定の場合でも、処理を続ける
   * ・補液量上限（A-0383）が未設定の場合は、送信処理を行わない。
   * ・装置モードにより上限値が可変となり、上限値をと比較し、補液量が上限値を超えない場合、送信処理を続ける。
   * （2018/08/02　装置モードがOHDF,OHFで、透析装置がDCS-100NX,DBB-100NXの場合、上限240L、それ以外の透析装置の場合は、上限192Lとする）
   *     機種「DCS-100NX」・「DBB-100NX」は、下記の機種コードを示す。
   *     026：DCS-100NX(M)
   *     027：DBB-100NX(N)
   *     029：DCS-100NX(P)
   *     030：DBB-100NX(Q)
   *・補液量上限値(下記を上から順番にチェック)
   * 1.特殊浄化治療、不明の場合：999.0
   * 2.HDF,HF,AFBFの場合:    30.0
   * 3.HD＋補液の場合:        99.9
   * 4.OHDF,OHFの場合:
   *    接続装置がDCS-100NX,DBB-100NXの場合：        240.0
   *    接続装置がDCS-100NX,DBB-100NX以外の場合:192.0
   * 5.上記以外:             999.0
   * さらに
   * HDF,HF,AFBF,特殊浄化,不明以外で、患者情報の補液上限(A-0383)＜補液上限値の場合：補液量上限値を補液上限(A-0383)に置き換える
   *
   * @param itemA0389              補液計算優先項目
   * @param uperLimit              補液量上限
   * @param treatMode               装置治療モード
   * @param machineTypeCd           型式コード
   * @param condReplenishMeasure    補液量
   * @return <PARAMKEY,値>
   *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
   *            PARAMKEY.RET_MSG:エラーメッセージ
   */
  private HashMap<PARAMKEY,Object> checkReplenishMeasureSetting(
      String itemA0389,
      String upperLimit,
      CommonIndConst treatMode,
      String machineTypeCd,
      Double     condReplenishMeasure
    )
  {
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;

    String retMsg = "", retLogMsg = "";

    //補液計算優先項目（A-0389）が未設定、もしくは（補液比率もしくは、濾過率算出以外）だったら処理継続
    if(null == itemA0389
        ||
        !(
            itemA0389.equals(CommonIndConst.RL_CAL_RATIO.get())
            ||
            itemA0389.equals(CommonIndConst.RL_CAL_FILTERRATIO.get())
        )
      )
    {
      if(null == upperLimit)
      {//補液量上限（A-0383）が未設定
        //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
        retMsg = String.format(CHECKMESSAGE.MSG000008.get()) ;
        retLogMsg = String.format(CHECKMESSAGE.MSG000008LOG.get()) ;
        retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
        retVal.put(PARAMKEY.RET_MSG, retMsg) ;
        retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
        return retVal ;
      }
      else
      {
        //補液量上限(double)
        Double dUpperLimit = null ;
        try {
          dUpperLimit = Double.parseDouble(upperLimit) ;
        }
        catch(Exception e)
        {//補液量上限の値が数値ではない
          retMsg = String.format(CHECKMESSAGE.MSG000041.get(),upperLimit) ;
          retLogMsg = String.format(CHECKMESSAGE.MSG000041LOG.get(),upperLimit) ;
          retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
          retVal.put(PARAMKEY.RET_MSG, retMsg) ;
          retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
          return retVal ;
        }

        //補液量上限の決定
        Double maxUpperLimit = null ;

        //補液量上限(治療方法が特殊浄化、不明場合）
        if (treatMode.equals(CommonIndConst.DEVICE_MODE_UNKNOWN)|| treatMode.equals(CommonIndConst.DEVICE_MODE_PURIFICATION))
        {
          maxUpperLimit = 999.0;
        }
        //補液量上限(治療方法がＨＤＦ，ＨＦ，ＡＦＢＦ場合の場合）
        else if (treatMode.equals(CommonIndConst.DEVICE_MODE_HDF) || treatMode.equals(CommonIndConst.DEVICE_MODE_HF) || treatMode.equals(CommonIndConst.DEVICE_MODE_AFBF))
        {
          maxUpperLimit = 30.0;
        }
        //補液量上限(治療方法がＨＤ＋補液場合）
        else if (treatMode.equals(CommonIndConst.DEVICE_MODE_HD_REP_LIQ))
        {
          maxUpperLimit = 99.9;
        }
        //補液量上限(治療方法がＯＨＤＦ、ＯＨＦ）
        else if (treatMode.equals(CommonIndConst.DEVICE_MODE_OHDF) || treatMode.equals(CommonIndConst.DEVICE_MODE_OHF))
        {
          if(
              //100NXシリーズ   TODO:2019.03.29 12．補液量上限値チェック処理内:型式コード:コードの変更有り
              this.checkIs100NXSeries(machineTypeCd)
           )
          {
            maxUpperLimit = 240.0 ;
          }
          else
          {
            maxUpperLimit = 192.0 ;
          }
        }
        else
        {
         //それ以外の場合は通信上の上限値をセット
          maxUpperLimit = 999.0;
        }

        // HDF・HF・AFBF・特殊浄化・不明以外で患者情報の補液量制限が低い場合
        //補液量制限値を患者情報の補液量制限値置き換える
        // -1:不明、0:HD、1:ECUM,2:HDF、3:HF、4:HD+補液,5:ECUM+補液,6:AFBF,7:OHDF,8:OHF,9:特殊浄化
        if (
         // HDF・HF・AFBF・特殊浄化・不明以外
         !Arrays.asList(
             CommonIndConst.DEVICE_MODE_HDF,            //HDF
             CommonIndConst.DEVICE_MODE_HF,             //HF
             CommonIndConst.DEVICE_MODE_AFBF,           //AFBF
             CommonIndConst.DEVICE_MODE_PURIFICATION,   //特殊浄化
             CommonIndConst.DEVICE_MODE_UNKNOWN         //不明
             ).contains(treatMode)
         &&     //かつ
         //患者情報の補液が補液上限値よりも小さい場合
         (dUpperLimit < maxUpperLimit)
        )
        {
         //補液量制限値を患者情報の補液量制限値置き換える
          maxUpperLimit = dUpperLimit ;
        }

        //補液量上限値と補液量を比較
        if(maxUpperLimit < condReplenishMeasure)
        {//補液量上限値＜補液量
          //警告メッセージを表示し、測定画面に戻る（送信処理はは行わない）
          retMsg = String.format(CHECKMESSAGE.MSG000009.get(),maxUpperLimit , condReplenishMeasure) ;
          retLogMsg = String.format(CHECKMESSAGE.MSG000009LOG.get(),maxUpperLimit , condReplenishMeasure) ;
          retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
          retVal.put(PARAMKEY.RET_MSG, retMsg) ;
          retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
          return retVal ;
        }
      }
    }

    return retVal ;
  }

 /**
  * 13．補液速度上下限値チェック処理
  * 装置モードが、HD・ECUM・I-HDFの場合は、送信処理を続ける(メソッドの外で判定。該当する場合は、当メソッドを呼ばない)
  * 補液計算優先項目(A-0389)が、補液量設定算出の場合、又は、補液計算優先項目(A-0389)が未設定の場合下記を実行する。
  *  ・装置モードが、特殊浄化、AFBF、不明な場合で、補液速度が999.0以上の場合は、送信処理を行わない。
  *   ・装置モードが、HDFの場合は下記を実施する。
  *   後補液の場合、後補液速度上限値(B-0031)＜補液速度の場合は、送信処理を行わない。
  *   また、後補液速度上限(B-0031)が未設定の場合、999.0と比較する。
  *   "前補液の場合、補液速度上限値(A-0185)＜補液速度の場合は、送信処理を行わない。
  *   また、補液速度上限値(A-0185)が未設定の場合、999.0と比較する。
  *    ・装置モードが、HFの場合は下記を実施する。
  *    後補液の場合、後補液速度上限値HF(B-0032)＞補液速度の場合は、送信処理を行わない。
  *    また、後補液速度上限HF(B-0032)が未設定の場合、999.0と比較する。
  *    前補液の場合、補液速度上限値HF(A-0186)＞補液速度の場合は、送信処理を行わない。
  *    また、補液速度上限値HF(A-0186)が未設定の場合、999.0と比較する。
  *    装置モードが、HD+補液の場合は下記を実施する。
  *    後補液の場合、後補液速度上限値HD+補液(B-0033)＞補液速度の場合は、送信処理を行わない。
  *    また、後補液速度上限HD+補液(B-0033)が未設定の場合、999.0と比較する。
  *    前補液の場合、補液速度上限値HD+補液(B-0030)＞補液速度の場合は、送信処理を行わない。
  *    また、補液速度上限値HD+補液(B-0033)が未設定の場合、999.0と比較する。
  *    ・装置モードが、OHDFの場合は下記を実施する。
  *    後補液の場合、後補液速度上限値OHDF(B-0034)＞補液速度の場合は、送信処理を行わない。
  *    また、後補液速度上限OHDF(B-0034)が未設定の場合、999.0と比較する。
  *    前補液の場合、補液速度上限値OHDF(A-0396)＞補液速度の場合は、送信処理を行わない。
  *    また、補液速度上限値OHDF(A-0396)が未設定の場合、999.0と比較する。
  *     ・装置モードが、OHFの場合は下記を実施する。
  *     後補液の場合、後補液速度上限値OHF(B-0035)＞補液速度の場合は、送信処理を行わない。
  *     また、後補液速度上限OHF(B-0035)が未設定の場合、999.0と比較する。
  *     前補液の場合、補液速度上限値OHF(A-0397)＞補液速度の場合は、送信処理を行わない。
  *     また、補液速度上限値OHF(A-0397)が未設定の場合、999.0と比較する。
  *      ・補液速度＞999.0の場合、送信処理を行わない。
  * @param itemA0185               補液上限HDF値
  * @param itemB0031               後補液上限HDF値
  * @param itemA0186               補液上限HF値
  * @param itemB0032               後補液上限HF値
  * @param itemB0030               補液上限HD+補液値
  * @param itemB0033               後補液上限HD+補液値
  * @param itemA0396               補液上限OHDF値
  * @param itemB0034               後補液上限OHDF値
  * @param itemA0397               補液上限OHF値
  * @param itemB0035               後補液上限OHF値
  * @param replenishMeasureCalPrior補液計算優先項目
  * @param condReplenishSelect     補液選択
  * @param treatMode               装置治療モード
  * @param condReplenishSpeed      補液速度
  * @return <PARAMKEY,値>
  *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
  *            PARAMKEY.RET_MSG:エラーメッセージ
  */
 private HashMap<PARAMKEY,Object> checkReplenishSpeedSetting(
     String itemA0185,
     String itemB0031,
     String itemA0186,
     String itemB0032,
     String itemB0030,
     String itemB0033,
     String itemA0396,
     String itemB0034,
     String itemA0397,
     String itemB0035,
     String replenishMeasureCalPrior,
     String condReplenishSelect,
     CommonIndConst treatMode,
     Double     condReplenishSpeed
   )
 {
   //戻り値初期化
   HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
   retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
   String retMsg = "", retLogMsg = "";

   String item = null ;          //選択項目名の文字列
   String strMsgPart = null ;    //部分メッセージ(どの処理かの識別のための文字列：出力用)
   if(null == replenishMeasureCalPrior
       ||
       replenishMeasureCalPrior.equals(CommonIndConst.RL_CAL_AMOUNT.get())
     )
   {//補液計算優先項目（A-0389）が補液量設定算出||補液計算優先項目（A-0389）が未設定
     //装置モードごとの比較
     if(condReplenishSpeed > 999.0)
     {//どの場合でも、補液速度＞999.0の場合
       //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
       retMsg = String.format(CHECKMESSAGE.MSG000010.get(),condReplenishSpeed , 999.0) ;
       retLogMsg = String.format(CHECKMESSAGE.MSG000010LOG.get(),condReplenishSpeed , 999.0) ;
       retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
       retVal.put(PARAMKEY.RET_MSG, retMsg) ;
       retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
       return retVal;
     }
     else
     {
       //前補液フラグ    trueで前補液
       boolean flagBefore = condReplenishSelect.equals(CHECKCONST.REPLENISH_SELECT_BEFORE.getStr()) ;

       item = null ;

       //チェックを行うかのフラグ true:行う
       boolean checkFlag = false ;

       //装置モード名
       String treatModeName = null ;

       switch(treatMode)
       {
         case DEVICE_MODE_PURIFICATION:  //装置モードが、特殊浄化の場合
           treatModeName = CommonIndConst.DEVICE_MODE_PURIFICATION_NAME.get();
           break;
         case DEVICE_MODE_AFBF:          //装置モードが、AFBFの場合
           treatModeName = CommonIndConst.DEVICE_MODE_AFBF_NAME.get();
           break;
         case DEVICE_MODE_UNKNOWN:       //装置モードが、不明の場合
           treatModeName = CommonIndConst.DEVICE_MODE_UNKNOWN_NAME.get();
           break;
         case DEVICE_MODE_HDF:            //装置モードが、HDFの場合
           //前補液の場合    補液上限HDF値(A-0185)と比較
           //後補液の場合    後補液上限HDF値(B-0031)と比較
           item = flagBefore ? itemA0185 : itemB0031 ;
           treatModeName = CommonIndConst.DEVICE_MODE_HDF_NAME.get();
           strMsgPart = (flagBefore ? "" : CHECKMESSAGE.REPLENISHSPEED_AFTER.get()) + CHECKMESSAGE.REPLENISHSPEED_HDF.get() ;
           checkFlag = true;
           break;
         case DEVICE_MODE_HF:            //装置モードが、HFの場合
           //前補液の場合    補液上限HF値(A-0186)と比較
           //後補液の場合    後補液上限HF値(B-0032)と比較
           item = flagBefore ? itemA0186 : itemB0032 ;
           treatModeName = CommonIndConst.DEVICE_MODE_HF_NAME.get();
           strMsgPart = (flagBefore ? "" : CHECKMESSAGE.REPLENISHSPEED_AFTER.get()) + CHECKMESSAGE.REPLENISHSPEED_HF.get() ;
           checkFlag = true;
           treatModeName = "HF";
           break;
         case DEVICE_MODE_HD_REP_LIQ:    //装置モードが、HD+補液
           //前補液の場合    補液上限HD+補液値(B-0030)と比較
           //後補液の場合    後補液上限HD+補液値(B-0033)と比較
           item = flagBefore ? itemB0030 : itemB0033 ;
           treatModeName = CommonIndConst.DEVICE_MODE_HD_REP_LIQ_NAME.get();
           strMsgPart = (flagBefore ? "" : CHECKMESSAGE.REPLENISHSPEED_AFTER.get()) + CHECKMESSAGE.REPLENISHSPEED_HDREPLIQ.get() ;
           checkFlag = true;
           treatModeName = "HD+補液";
           break ;
         case DEVICE_MODE_OHDF:          //装置モードが、OHDFの場合
           //前補液の場合    補液上限OHDF値(A-0396)と比較
           //後補液の場合    後補液上限OHDF値(B-0034)と比較
           item = flagBefore ? itemA0396 : itemB0034 ;
           treatModeName = CommonIndConst.DEVICE_MODE_OHDF_NAME.get();
           strMsgPart = (flagBefore ? "" : CHECKMESSAGE.REPLENISHSPEED_AFTER.get()) + CHECKMESSAGE.REPLENISHSPEED_OHDF.get() ;
           checkFlag = true;
           treatModeName = "OHDF";
           break ;
         case DEVICE_MODE_OHF:          //装置モードが、OHFの場合
           //前補液の場合    補液上限OHF値(A-0397)と比較
           //後補液の場合    後補液上限OHF値(B-0035)と比較
           item = flagBefore ? itemA0397 : itemB0035 ;
           treatModeName = CommonIndConst.DEVICE_MODE_OHF_NAME.get();
           strMsgPart = (flagBefore ? "" : CHECKMESSAGE.REPLENISHSPEED_AFTER.get()) + CHECKMESSAGE.REPLENISHSPEED_OHF.get() ;
           checkFlag = true;
           treatModeName = "OHF";
           break ;
         default:
           //ここにはこない(HD,ECUM,I-HDF)
           strMsgPart = "その他(補液を使わない)" ;
           break ;
       }

       if(checkFlag)
       {
         String upperLimit = null == item ? "999.0" : item ;
         Double dUpperLimit = 0.0 ;

         try {
           dUpperLimit = Double.parseDouble(upperLimit) ;
         }
         catch(Exception e)
         {
           //パース失敗
           EventLogMessage eventLogMessage = new EventLogMessage();
           // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
           logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
           retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
           retVal.put(PARAMKEY.RET_MSG, "補液上限値が異常です。") ;
           retVal.put(PARAMKEY.RET_LOG_MSG, "補液上限値が異常です。" + e.getMessage()) ;
           return retVal;
         }

         //補液速度と  補液速度上限との比較
         if(condReplenishSpeed > dUpperLimit)
         {//補液速度> 補液速度上限の場合
               //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
           retMsg = String.format(CHECKMESSAGE.MSG000011.get(),strMsgPart,treatModeName , dUpperLimit) ;
           retLogMsg = String.format(CHECKMESSAGE.MSG000011LOG.get(),strMsgPart,treatModeName , dUpperLimit) ;
           retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
           retVal.put(PARAMKEY.RET_MSG, retMsg) ;
           retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
           return retVal;
         }
       }
     }
   }

   return retVal ;
 }

  /**
   * 14．補液計算優先項目チェック処理
   * ・透析装置が通信共通プロトコルVer1-4以外の場合のみ実行する。
   * ・補液計算優先項目(A-0389)が未設定の場合は、送信処理を行わない。
   * ・補液計算優先項目(A-0389)が補液比率算出もしくは、濾過率算出の場合で、透析治療の場合下記を実行する。
   * ・型式が、100NXシリーズ・DABまたは通信フォーマットがオフライン・通信共通プロトコルVer1-3以外の場合は、送信処理を行わない。
   *    (DCS-100NX(P),DBB-100NX(Q)を追加　Ver7.00より)
   *     機種「DCS-100NX」・「DBB-100NX」は、下記の機種コードを示す。
   *     026：DCS-100NX(M)
   *     027：DBB-100NX(N)
   *     029：DCS-100NX(P)
   *     030：DBB-100NX(Q)
   * @param replenishMeasureCalPrior 補液計算優先項目
   * @param treatMode       装置治療モード
   * @param flagNXOrComProtocol123   型式が100NXシリーズ・DABまたは通信フォーマットがオフライン・通信共通プロトコルVer1-3かどうかのフラグ
   * @param flagComFormatNotCommonProtocol  通信フォーマットが通信共通プロトコルVer1-4以外フラグ
   * @return <PARAMKEY,値>
   *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
   *            PARAMKEY.RET_MSG:エラーメッセージ
   */
  private HashMap<PARAMKEY,Object> checkReplenishCalcSetting(
      String replenishMeasureCalPrior,
      CommonIndConst treatMode,
      boolean flagNXOrComProtocol123,
      boolean flagComFormatNotCommonProtocol
    )
  {
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
    String retMsg = "", retLogMsg = "";

    if(flagComFormatNotCommonProtocol)
    {//通信共通プロトコルVer1-4以外

      if(null == checkNumOrNot(replenishMeasureCalPrior))
      {
        //補液計算優先項目(A-0389)が未設定
        //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
        retMsg = String.format(CHECKMESSAGE.MSG000012.get()) ;
        retLogMsg = String.format(CHECKMESSAGE.MSG000012LOG.get()) ;
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(retLogMsg);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
        retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
        retVal.put(PARAMKEY.RET_MSG, retMsg) ;
        retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
        return retVal;
      }
      else if(
        //補液比率算出||濾過率算出
        (
          replenishMeasureCalPrior.equals(CommonIndConst.RL_CAL_RATIO.get())
          ||
          replenishMeasureCalPrior.equals(CommonIndConst.RL_CAL_FILTERRATIO.get())
        )
        &&
        //透析治療(特殊浄化ではないという判定)
        (
            treatMode != CommonIndConst.DEVICE_MODE_PURIFICATION
        )
      )
      {//補液計算優先項目(A-0389)が(補液比率算出||濾過率算出)&&透析治療(特殊浄化ではないという判定)
        if(!
            //型式が100NXシリーズ・DABまたは通信フォーマットがオフライン・通信共通プロトコルVer1-3
            flagNXOrComProtocol123
         )
        {//接続装置が100NXシリーズ、DABまたは通信フォーマットがオフライン、共通プロトコルVer1-3以外
          //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
          retMsg = String.format(CHECKMESSAGE.MSG000013.get()) ;
          retLogMsg = String.format(CHECKMESSAGE.MSG000013LOG.get()) ;
          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(retLogMsg);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
          retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
          retVal.put(PARAMKEY.RET_MSG, retMsg) ;
          retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
          return retVal;
        }
      }
    }
    return retVal ;
  }

  /**
   * 15．BV-UFCチェック処理
   * ・通信共通プロトコルVer1-4の場合、BV-UFCチェック処理は行わない。
   * ・下記の状態であれば、BV-UFCチェック処理は行わず、次の送信処理を行う。
   * 100NXシリーズ以外、装置オプションのBV-UFC機能設定（A-0207)がOFFもしくは、未設定場合
   * ※(DCS-100NX(P),DBB-100NX(Q)を追加　Ver7.00より)
   *     機種「DCS-100NX」・「DBB-100NX」は、下記の機種コードを示す。
   *     026：DCS-100NX(M)
   *     027：DBB-100NX(N)
   *     029：DCS-100NX(P)
   *     030：DBB-100NX(Q)
   * BV-UFC設定値(A-0196)が、有効以外の場合もしくは、BV-UFC設定値(A-0196)が未設定の場合
   *  ・除水プロ電源設定(A-0290)が1(電源ON)の場合、送信処理を行わない。（未設定の場合も電源ONではないので次の処理を行う）
   *  ・治療モードがI-HDFの場合、送信処理を行わない。
   *  ・治療モードがECUMの場合で、ECUM選択(A-0016)が１（ECUM専用）の場合、送信処理を行わない。（未設定の場合もECUM専用ではないので次の処理を行う）
   * @param itemA0196      BV-UFC設定値
   * @param itemA0207      BV-UFC機能設定(装置オプションBV-UFC機能（A-0207)の取得に使用)
   * @param itemA0290      除水プロ電源設定
   * @param itemA0016      ECUM選択値
   * @param treatMode       装置治療モード
   * @param machineTypeCd   型式コード
   * @param flagComFormatNotCommonProtocol  通信フォーマットが通信共通プロトコルVer1-4以外フラグ
   * @return <PARAMKEY,値>
   *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
   *            PARAMKEY.RET_MSG:エラーメッセージ
   */
  private HashMap<PARAMKEY,Object> checkBVUFCSetting(
      String itemA0196,
      String itemA0207,
      String itemA0290,
      String itemA0016,
      CommonIndConst treatMode,
      String machineTypeCd,
      boolean flagComFormatNotCommonProtocol
    )
  {
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
    String retMsg = "", retLogMsg = "";

    //装置オプションBV-UFC機能（A-0207)の取得(A-0207は、装置マスタの装置オプションの設定項目(A-0207))

    if(null != itemA0207 )
    {//BV-UFC機能が設定されている(設定がある)
      if(flagComFormatNotCommonProtocol)
      {
        //通信共通プロトコルVer1-4以外の場合
        if(
            (
                //100NXシリーズ
                //TODO:2019.03.30 型式コード:コードが変更されます
                this.checkIs100NXSeries(machineTypeCd)
            )
            &&
            itemA0207.equals(CommonIndConst.SETTING_ON.get())
        )
        {
          //100NXシリーズ&&BV-UFC機能がON(A-0207)の場合
          if(null != checkNumOrNot(itemA0196))
          {//BV-UFC設定値(A-0196)が未設定以外の場合
            if(itemA0196.equals(CommonIndConst.SETTING_ON.get()))
            {//BV-UFC設定値(A-0196)が有効(1)設定
              if(null != checkNumOrNot(itemA0290) && itemA0290.equals(CommonIndConst.SETTING_ON.get()))
              {//除水プロ電源設定（A-0290）値が電源ON
                //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
                retMsg = String.format(CHECKMESSAGE.MSG000014.get()) ;
                retLogMsg = String.format(CHECKMESSAGE.MSG000014LOG.get()) ;
                retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
                retVal.put(PARAMKEY.RET_MSG, retMsg) ;
                retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
                return retVal;
              }
              else
              {
                if(treatMode.equals(CommonIndConst.DEVICE_MODE_PRO_REP_LIQ))
                {//治療モードがI-HDFの場合
                  //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
                  retMsg = String.format(CHECKMESSAGE.MSG000015.get()) ;
                  retLogMsg = String.format(CHECKMESSAGE.MSG000015LOG.get()) ;
                  retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
                  retVal.put(PARAMKEY.RET_MSG, retMsg) ;
                  retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
                  return retVal ;
                }
                else
                {
                  if(treatMode.equals(CommonIndConst.DEVICE_MODE_ECUM))
                  {//治療モードがECUMの場合
                    if(null != checkNumOrNot(itemA0016) && itemA0016.equals(CommonIndConst.SETTING_ON.get()))
                    {//ECUM選択値（A-0016)が有効の場合
                      //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
                      retMsg = String.format(CHECKMESSAGE.MSG000016.get()) ;
                      retLogMsg = String.format(CHECKMESSAGE.MSG000016LOG.get()) ;
                      retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
                      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
                      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
                      return retVal ;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return retVal ;
  }

  /**
   * 16．透析液流量比率制御チェック処理
   * ・透析装置が通信共通プロトコルVer1-4以外の場合のみ実行する。
   * ・透析液流量比率制御値設定方法(A-0268)が未設定の場合次の送信処理を行う。
   * ・透析液流量比率制御値設定方法(A-0268)が２(比率設定)場合下記を実行する。
   * ・100NXシリーズ・DAB・オフライン・通信共通プロトコルVer1-4以外の場合は、送信処理を行わない。
   *    (DCS-100NX(P),DBB-100NX(Q)を追加　Ver7.00より)
   *     機種「DCS-100NX」・「DBB-100NX」は、下記の機種コード(型式コード)を示す。
   *        026：DCS-100NX(M)
   *        027：DBB-100NX(N)
   *        029：DCS-100NX(P)
   *        030：DBB-100NX(Q)
   * @param itemA0268       透析液流量比率制御値設定方法
   * @param flagNXOrComProtocol123   型式が100NXシリーズ・DABまたは通信フォーマットがオフライン・通信共通プロトコルVer1-3かどうかのフラグ
   * @param flagComFormatNotCommonProtocol  通信フォーマットが通信共通プロトコルVer1-4以外フラグ
   * @return <PARAMKEY,値>
   *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
   *            PARAMKEY.RET_MSG:エラーメッセージ
   */
  private HashMap<PARAMKEY,Object> checkDialyzeFlowSetting(
      String itemA0268,
      boolean flagNXOrComProtocol123,
      boolean flagComFormatNotCommonProtocol
    )
  {
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
    String retMsg = "", retLogMsg = "";

    if(flagComFormatNotCommonProtocol)
    {//通信共通プロトコルVer1-4以外の場合、チェックを行う。
      if(null != itemA0268)
      {//透析液流量比率制御値(A-0268)が設定値がある
        if(itemA0268.equals(CommonIndConst.REPLENISH_SPEED_RATIO.get()))
        {//透析液流量比率制御値(A-0268)が比率設定
          if(!
              //型式が100NXシリーズ・DABまたは、通信フォーマットがオフライン・通信共通プロトコルVer1-3のコードリスト
              flagNXOrComProtocol123
           )
          {//接続装置が100NXシリーズ、DAB、オフライン、共通プロトコルVer1-3以外
            //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
            retMsg = String.format(CHECKMESSAGE.MSG000017.get()) ;
            retLogMsg = String.format(CHECKMESSAGE.MSG000017LOG.get()) ;
            retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
            retVal.put(PARAMKEY.RET_MSG, retMsg) ;
            retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
            return retVal;
          }
        }
      }
    }

    return retVal ;
  }


  /**
   * 17．QDプログラムチェック処理
   * ・QDプログラム値(A-0430)が未設定の場合次の送信処理を行う。
   * ・QDプログラム値(A-0430)が１場合下記を実行する。
   * ・透析液流量比率制御値(A-0268)が２(比率設定)場合は、送信処理を行わない。
   * ・装置モードがI-HDFの場合は、送信処理を行わない。
   * ・QDプログラム透析液流量１～１０の上限下限値チェックを行う。
   * （上限値700，下限値100、DBB-100NX(Q,N)は下限値300とする）
   * QDプログラム透析液流量1-10の値が上限下限値の範囲を超えている場合、送信処理を行わない。
   * @param itemA0431       QDプログラム値
   * @param itemA268        透析液流量比率制御設定方法(A-0268)
   * @param inputList       QDプログラム血流量のリスト(A-0429で指定されるステップ数分のリスト)
   *    0:itemA0410       QDプログラム血流量1
   *    1:itemA0411       QDプログラム血流量2
   *    2:itemA0412       QDプログラム血流量3
   *    3:itemA0413       QDプログラム血流量4
   *    4:itemA0414       QDプログラム血流量5
   *    5:itemA0415       QDプログラム血流量6
   *    6:itemA0416       QDプログラム血流量7
   *    7:itemA0417       QDプログラム血流量8
   *    8:itemA0418       QDプログラム血流量9
   *    9:itemA0419       QDプログラム血流量10
   * @param treatMode       装置治療モード
   * @param machineTypeCd   型式コード
   * @param flagComFormatNotCommonProtocol  通信フォーマットが通信共通プロトコルVer1-4以外フラグ
   * @return <PARAMKEY,値>
   *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
   *            PARAMKEY.RET_MSG:エラーメッセージ
   */
  private HashMap<PARAMKEY,Object> checkQDProgramSetting(
      String itemA0431,
      String itemA268,
      List<String> inputList,
      CommonIndConst treatMode,
      String machineTypeCd,
      boolean flagComFormatNotCommonProtocol
    )
  {
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
    String retMsg = "", retLogMsg = "";

    if(null != itemA0431)
    {//QDプログラム値(A-0431)の設定値がある

      if(itemA0431.equals(CommonIndConst.SETTING_ON.get()))
      {//QDプログラム値(A-0431)の値が１
        //透析液流量比率制御設定方法(A-0268)の取得
        if(null != itemA268)
        {//透析液流量比率制御値(A-0268)に設定値がある
          if(!itemA268.equals(CommonIndConst.REPLENISH_SPEED_RATIO.get()))
          {//透析液流量比率制御値(A-0268)が比率設定の以外
            if(!treatMode.equals(CommonIndConst.DEVICE_MODE_PRO_REP_LIQ))
            {//治療方法がI-HDF以外の場合
                //上下限のチェックメソッド(checkMaxMinLimit)を呼ぶ前の引数の準備(値のリスト化)
                //上限値700，下限値100、DBB-100NX(N,Q)は下限値300とする）
                Double max = 700.0 ;
                Double min = 100.0 ;
                if(
                    this.checkIsDBB100NXor200Si(machineTypeCd)
                  )
                {
                  //DBB-100NX(Q,N), DBB-200Siは下限値300とする
                  min = 300.0 ;
                }

                //上限下限チェックをおこなう
                if(!checkMaxMinLimit(inputList,max,min))
                {//QDプログラム透析液流量1-10の値のいずれかひとつでも上限下限値の範囲を超えている場合
                  //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
                  retMsg = String.format(CHECKMESSAGE.MSG000018.get()) ;
                  retLogMsg = String.format(CHECKMESSAGE.MSG000018LOG.get()) ;
                  retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
                  retVal.put(PARAMKEY.RET_MSG, retMsg) ;
                  retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
                  return retVal;
                }
            }
            else
            {//治療方法がI-HDFの場合
              //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
              retMsg = String.format(CHECKMESSAGE.MSG000019.get()) ;
              retLogMsg = String.format(CHECKMESSAGE.MSG000019LOG.get()) ;
              retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
              retVal.put(PARAMKEY.RET_MSG, retMsg) ;
              retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
              return retVal;
            }
          }
          else
          {//透析液流量比率制御値(A-0268)が比率設定の場合
            //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
            retMsg = String.format(CHECKMESSAGE.MSG000020.get()) ;
            retLogMsg = String.format(CHECKMESSAGE.MSG000020LOG.get()) ;
            retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
            retVal.put(PARAMKEY.RET_MSG, retMsg) ;
            retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
            return retVal;
          }
        }
      }
    }

    return retVal ;
  }

  /**
   * 18．QBプログラムチェック処理
   * ・QBプログラム値(A-0431)が未設定の場合次の送信処理を行う。
   * ・QBプログラム値(A-0431)が１場合下記を実行する。
   *  ・装置モードがI-HDFの場合は、送信処理を行わない。
   *  ・QBプログラム血流量１～１０の上限下限値チェックを行う。
   *   ・血流量設定上限値(A-0179)＞600の場合、もしくは、未設定の場合は、血流量設定値上限を600とする。
   *   ・QBプログラム血流量＞血流量設定上限値の場合は、送信処理を行わない。
   *   ・QBプログラム血流量＜40の場合は、送信処理を行わない。
   * @param itemA0430       QBプログラム値
   * @param itemA0179       血流量設定上限値
   * @param inputList       QBプログラム血流量のリスト(A-0429で指定されるステップ数分のリスト)
   *    0:itemA0410       QBプログラム血流量1
   *    1:itemA0411       QBプログラム血流量2
   *    2:itemA0412       QBプログラム血流量3
   *    3:itemA0413       QBプログラム血流量4
   *    4:itemA0414       QBプログラム血流量5
   *    5:itemA0415       QBプログラム血流量6
   *    6:itemA0416       QBプログラム血流量7
   *    7:itemA0417       QBプログラム血流量8
   *    8:itemA0418       QBプログラム血流量9
   *    9:itemA0419       QBプログラム血流量10
   * @param treatMode       装置治療モード
   * @return <PARAMKEY,値>
   *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
   *            PARAMKEY.RET_MSG:エラーメッセージ
   */
  private HashMap<PARAMKEY,Object> checkQBProgramSetting(
      String itemA0430,
      String itemA0179,
      List<String> inputList,
      CommonIndConst treatMode
    )
  {
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
    String retMsg = "", retLogMsg = "";

    if(null != itemA0430)
    {//QBプログラム値(A-0430)が設定値がある
      if(itemA0430.equals(CommonIndConst.SETTING_ON.get()))
      {//QBプログラム値(A-0430)の値が１
        if(treatMode.equals(CommonIndConst.DEVICE_MODE_PRO_REP_LIQ))
        {//治療方法がI-HDF
          //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
          retMsg = String.format(CHECKMESSAGE.MSG000021.get()) ;
          retLogMsg = String.format(CHECKMESSAGE.MSG000021LOG.get()) ;
          retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
          retVal.put(PARAMKEY.RET_MSG, retMsg) ;
          retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
          return retVal;
        }
        else
        {//血流量設定上限値(A-0179)を取得。未設定または>600の場合、600に設定
          Double qbUpperLimit = 600.0 ;
          Double dUpperLimit = null;

          try {
            dUpperLimit = Double.parseDouble(itemA0179);
          }
          catch(Exception e)
          {
            //パース失敗で、未設定相当
            //血流量設定上限値(A-0179)が未設定の場合,上限値を600とする
            dUpperLimit = qbUpperLimit;
          }
          if(dUpperLimit > qbUpperLimit)
          {
            //血流量設定上限値(A-0179)を上限値とする。ただし600を超えていた場合は、600を設定する
            dUpperLimit = qbUpperLimit ;
          }

          //QBプログラム血流量1-10の取得
          //上下限のチェックメソッド(checkMaxMinLimit)を呼ぶ前の引数の準備(値のリスト化)
          Double max = dUpperLimit ;
          Double min = 40.0 ;
          //上下限のチェック
          if(!checkMaxMinLimit(inputList,max,min))
          {//QBプログラム血流量1-10の値が上限下限値の範囲を超えている
            //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
            retMsg = String.format(CHECKMESSAGE.MSG000022.get()) ;
            retLogMsg = String.format(CHECKMESSAGE.MSG000022LOG.get()) ;
            retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
            retVal.put(PARAMKEY.RET_MSG, retMsg) ;
            retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
            return retVal;
          }
        }
      }
    }

    return retVal ;
  }


  /**
  * 19．I-HDFプログラムチェック処理
  * ・治療モードがIHDF以外の場合次の送信処理を行う。
  * ・I-HDFプログラム使用選択値(A-0432)が未設定の場合次の送信処理を行う。
  * ・I-HDFプログラム使用選択値(A-0432)が１場合下記を実行する。
  * ・通信フォーマットが、DBG2、M,DCG2,Nの場合は、送信処理を行わない。
  * @param itemA0432       I-HDFプログラム使用選択
  * @param treatMode       装置治療モード
  * @param comFormat       通信フォーマット
  * @return <PARAMKEY,値>
  *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
  *            PARAMKEY.RET_MSG:エラーメッセージ
  */
   private HashMap<PARAMKEY,Object> checkIHDFProgramSetting(
       String itemA0432,
       CommonIndConst treatMode,
       String comFormat
     )
   {
     //戻り値初期化
     HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
     retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
     String retMsg = "", retLogMsg = "";

     if(treatMode.equals(CommonIndConst.DEVICE_MODE_PRO_REP_LIQ))
     {//装置治療モードがI-HDF
       if(
           comFormat.equals(CommonIndConst.COM_FORMAT_M.get())
           ||
           comFormat.equals(CommonIndConst.COM_FORMAT_N.get())
       )
       {//通信フォーマットがDBG2,M,DCG2,N
         if(null != itemA0432)
         {//I-HDFプログラム使用選択値(A-0432)の設定値がある
           if(itemA0432.equals(CommonIndConst.SETTING_ON.get()))
           {//I-HDFプログラム使用選択値(A-0432)の値が１
               //警告メッセージを表示し、測定画面に戻る（送信処理は行わない）
               retMsg = String.format(CHECKMESSAGE.MSG000023.get()) ;
               retLogMsg = String.format(CHECKMESSAGE.MSG000023LOG.get()) ;
               retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
               retVal.put(PARAMKEY.RET_MSG, retMsg) ;
               retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
               return retVal;
           }
         }
       }
     }

     return retVal ;
   }
   /**
    * 20．TMP補液制御チェック処理
    * ・治療モードが特殊浄化以外かつ、装置が100NX,200Siの場合、値チェックの処理を行う。
    * ・
    * @param itemA0472       TMP閾値 速度低下
    * @param itemA0473       TMP閾値 速度復帰
    * @param itemA0130       TMP自動設定警報限界上限
    * @param itemA0131       TMP自動設定警報限界下限
    * @param itemA0132       TMP固定警報上限
    * @param itemA0133       TMP固定警報下限
    * @param machineTypeCd   型式コード
    * @param treatMode       装置治療モード
    * @param flagComFormatNotCommonProtocol  通信フォーマットが通信共通プロトコルVer1-4以外フラグ
    * @return <PARAMKEY,値>
    *            PARAMKEY.STATUS:Httpステータス       正常：HttpStatus.OK
    *            PARAMKEY.RET_MSG:エラーメッセージ
    */
   private HashMap<PARAMKEY, Object> checkTmpControlSetting(
       String itemA0472, String itemA0473, String itemA0130,
       String itemA0131, String itemA0132, String itemA0133,
       String machineTypeCd, CommonIndConst treatMode,
       boolean flagComFormatNotCommonProtocol
   ) {
     //戻り値初期化
     HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
     retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
     String retMsg = "", retLogMsg = "";

     if (!treatMode.equals(CommonIndConst.DEVICE_MODE_PURIFICATION) && flagComFormatNotCommonProtocol)
     {
       // 治療モードが特殊浄化でない,通信フォーマットが通信共通プロトコルVer1-4&オフライン以外
       if(this.checkIs100NXSeries(machineTypeCd) && !Objects.isNull(itemA0472) && !Objects.isNull(itemA0473)) {
         BigDecimal tmpSpeedDown = new BigDecimal(itemA0472);
         BigDecimal tmpSpeedRepair = new BigDecimal(itemA0473);
         if (tmpSpeedDown.compareTo(tmpSpeedRepair) < 0) {
           // TMP閾値 速度低下 < TMP閾値 速度復帰
           retMsg = String.format(CHECKMESSAGE.MSG000049.get()) ;
           retLogMsg = String.format(CHECKMESSAGE.MSG000049LOG.get()) ;
           retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
           retVal.put(PARAMKEY.RET_MSG, retMsg) ;
           retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
           return retVal;
         }
         List<String> warnUpperList = Arrays.asList(itemA0130, itemA0132);
         List<String> warnLowerList = Arrays.asList(itemA0131, itemA0133);
         for (String warn: warnUpperList) {
           if (!Objects.isNull(warn) && !warn.isEmpty()) {
             BigDecimal upper = new BigDecimal(warn);
             if (tmpSpeedDown.compareTo(upper) > 0) {
               // TMP閾値 速度低下 > TMP自動設定警報限界上限、固定上限
               retMsg = String.format(CHECKMESSAGE.MSG000047.get()) ;
               retLogMsg = String.format(CHECKMESSAGE.MSG000047LOG.get()) ;
               retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
               retVal.put(PARAMKEY.RET_MSG, retMsg) ;
               retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
               return retVal;
             }
             if (tmpSpeedRepair.compareTo(upper) > 0) {
               // TMP閾値 速度復帰 > TMP自動設定警報限界上限、固定上限
               retMsg = String.format(CHECKMESSAGE.MSG000048.get()) ;
               retLogMsg = String.format(CHECKMESSAGE.MSG000048LOG.get()) ;
               retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
               retVal.put(PARAMKEY.RET_MSG, retMsg) ;
               retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
               return retVal;
             }
           }
         }
         for (String warn: warnLowerList) {
           if (!Objects.isNull(warn) && !warn.isEmpty()) {
             BigDecimal lower = new BigDecimal(warn);
             if (tmpSpeedDown.compareTo(lower) < 0) {
               // TMP閾値 速度低下 < TMP自動設定警報限界下限、固定下限
               retMsg = String.format(CHECKMESSAGE.MSG000047.get()) ;
               retLogMsg = String.format(CHECKMESSAGE.MSG000047LOG.get()) ;
               retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
               retVal.put(PARAMKEY.RET_MSG, retMsg) ;
               retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
               return retVal;
             }
             if (tmpSpeedRepair.compareTo(lower) < 0) {
               // TMP閾値 速度復帰 < TMP自動設定警報限界下限、固定下限
               retMsg = String.format(CHECKMESSAGE.MSG000048.get()) ;
               retLogMsg = String.format(CHECKMESSAGE.MSG000048LOG.get()) ;
               retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
               retVal.put(PARAMKEY.RET_MSG, retMsg) ;
               retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
               return retVal;
             }
           }
         }
       }
     }
     return retVal ;
   }

  /**
   * KT/V上下限値取得処理
   * @param patId   患者ID
   * @param calcTreatDate 治療日
   * @return    <PARAMKEY,String>
   *            PARAMKEY.UPPER：KT/V上限
   *            PARAMKEY.UNDER：KT/V下限
   *            エラー時null
   */
  private HashMap<PARAMKEY,String> getKtOverVUpperAndUnderLimit(
        String patId,
        String calcTreatDate
      )
  {
    HashMap<PARAMKEY,String> ret = null ;
    String ktOverVUpperLimit = null ;
    String ktOverVUnderLimit = null ;

    //患者情報を取得する

    //Date型に変換
    Date formatDate = null ;
    try {
      formatDate = new SimpleDateFormat("yyyyMMdd HH:mm:ss").parse(calcTreatDate);
    }
    catch(Exception e)
    {
      formatDate = null ;
    }

    List<Map<String,Object>> tableDeviceSet = getDeviceSetDataDBInfo(patId,formatDate); //TODO:日付は仮置き
    if (tableDeviceSet == null)
    {
        return null;
    }
    else if (tableDeviceSet.size() > 0 && null != tableDeviceSet.get(0).get(PARAMKEY.CALC_DIALYSIS_DATE.get()))
    {
        Date dtmCalcDialysis = (Date)tableDeviceSet.get(0).get(PARAMKEY.CALC_DIALYSIS_DATE.get());

        // 体液量計測時後体重
        List<Map<String,Object>> tableRstDialysisWeight = getRstDialysisWeight(patId, dtmCalcDialysis); //TODO:SQL
        if (tableRstDialysisWeight == null)
        {
            return null;
        }

        Map<String,Object> dr = tableDeviceSet.get(0);    // 患者装置設定
        if (
            (true == ((String)dr.get(PARAMKEY.CALC_DIALYSIS_DATE.get())).matches("^[1-9]?[0-9]+$"))     // TODO:計算可能治療日がDateTime型(とりあえず数値かどうか)
              &&
            (true == ((String)dr.get(PARAMKEY.CALC_DIALYSIS_TIME.get())).matches("^[1-9]?[0-9]+$"))    // 体液量算出時透析時間が数値型
              &&
            (true == ((String)dr.get(PARAMKEY.CALC_BLOOD_VOL.get())).matches("^[1-9]?[0-9]+$"))         // 体液量算出時血流量平均値が数値型
            )
         {
            // BUN検査項目コードの取得
            List<Map<String,Object>> dtBUNCode = getBUNCode();  //TODO:SQL
            if (null == dtBUNCode)
            {
                // DBエラー
                return null;
            }
            else if (2 > dtBUNCode.size())
            {
                // マスタ件数不足
                return null;
            }

            String strBUNBfrCode = (String)dtBUNCode.get(0).get(PARAMKEY.EXAM_ITEM_CD.get());
            String strBUNAftCode = (String)dtBUNCode.get(1).get(PARAMKEY.EXAM_ITEM_CD.get());
            //体液量算出用のデータを取得
            DialysisCalculator calc = getBodyLiqCalcData(
                patId,
                (Date)dr.get(PARAMKEY.CALC_DIALYSIS_DATE.get()),
                Integer.parseInt((String)dr.get(PARAMKEY.CALC_DIALYSIS_TIME.get())),
                Integer.parseInt((String)dr.get(PARAMKEY.CALC_BLOOD_VOL.get())),
                strBUNBfrCode,
                strBUNAftCode);
            if (null == calc)
            {
                // DBエラー
                return null;
            }

            //KT/V上下限値の取得
            ktOverVUnderLimit = calc.getKtPerVLower();
            ktOverVUpperLimit = calc.getKtPerVUpper();

            if(null == ktOverVUnderLimit || null == ktOverVUpperLimit)
            {
              return null ;
            }
            else
            {
              ret.put(PARAMKEY.UNDER, ktOverVUnderLimit) ;
              ret.put(PARAMKEY.UPPER, ktOverVUpperLimit) ;
            }
        }
        else
        {
          return null ;
        }
    }
    return ret ;
  }

  /**
   * 患者情報取得処理
   * @param patId
   * @return
   */
  private List<Map<String,Object>> getDeviceSetDataDBInfo(
      String patId,
      Date treatDate)
  {
    List<Map<String,Object>> dt = null ;

    //最新患者情報取得処理(曜日判定)を呼び出す
    //  ※最終的に最新患者情報取得処理(本体)も呼び出される
    dt = getPatSamaryMergeWeekInfo(
              patId,
              treatDate,
              PatInfoTable.Device_Set
           );
    // DBデータ取得エラーチェック
    if (null == dt)
    {
        return null;
    }
    // DBデータ件数チェック
    if (0 == dt.size())
    {
        // エラーログ出力
      //★★★★★　ここでログを出すかは未定
//        LogErrorLog(CodeErr.DB_NODATA, null, String.Empty);
        return null;
    }

    return dt;
  }


  /**
   * 患者装置設定値対象テーブル
   *
   */
  public enum PatInfoTable
  {
      //患者風袋情報
      Revice_Tare,      //0
      //患者除水情報
      Revice_Off_water, //1
      //患者装置設定値情報
      Device_Set,       //2
  }


  /**
   * 曜日管理する患者情報の候補
   *
   */
  public enum FnwPatDayOfWeek
  {
      // 全曜日データ(=-1)(個別の曜日情報を持たない場合に適用されるデータ)
      AllWeek(-1),
      // 日曜日データ(=1)
      Sunday(Calendar.getInstance().SUNDAY),
      // 月曜日データ(=2)
      Monday(Calendar.getInstance().MONDAY),
      // 火曜日データ(=3)
      Tuesday(Calendar.getInstance().TUESDAY),
      // 水曜日データ(=4)
      Wednesday(Calendar.getInstance().WEDNESDAY),
      // 木曜日データ(=5)
      Thursday(Calendar.getInstance().THURSDAY),
      // 金曜日データ(=6)
      Friday(Calendar.getInstance().FRIDAY),
      // 土曜日データ(=7)
      Saturday(Calendar.getInstance().SATURDAY),
      ;

      private int dayOfWeekValue ;

      private FnwPatDayOfWeek(int dayOfWeekValue)
      {
        this.dayOfWeekValue = dayOfWeekValue ;
      }

      public int getInt()
      {
        return this.dayOfWeekValue ;
      }
  }


  /**
   * 最新患者情報取得処理(曜日判定)
   * 取得対象テーブル・取得対象の日付を引数で指定する
   * （取得対象の日付は関数内で曜日に変換する）
   * 対象テーブルは患者風袋補正情報・患者除水補正情報・患者装置設定値
   * @param strPatID            患者ID
   * @param dtDate              取得対象の日付
   * @param PatInfoTableName    取得対象テーブル
   * @return                    患者情報の取得結果(異常・取得失敗時：NULL）
   */
  public List<Map<String,Object>> getPatSamaryMergeWeekInfo(
                  String strPatID,
                  Date dtDate,
                  PatInfoTable PatInfoTableName
         )
  {
      int PatDayOfWeek;
      //曜日の決定
      if (dtDate == DATE_MIN)
      {
          // dtDateがDateTime.MinValueなら全曜日を使用
          PatDayOfWeek = FnwPatDayOfWeek.AllWeek.getInt();
      }
      else
      {
          // dtDateがDateTime.MinValue以外なら対象の日付の曜日を使用
          Calendar cal = Calendar.getInstance() ;
          cal.setTime(dtDate) ;
          PatDayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
      }
      //最新患者情報取得処理(本体)を呼ぶ
      return getPatSamaryMergeWeekInfo(strPatID, PatDayOfWeek, PatInfoTableName);
  }

  /**
   * 最新患者情報取得処理(本体)
   * 取得対象テーブル・取得対象の曜日を引数で指定する
   * 対象テーブルは患者風袋補正情報・患者除水補正情報・患者装置設定値
   * @param strPatID            患者ID
   * @param PatDayOfWeek        患者情報テーブルの取得対象の曜日
   * @param PatInfoTableName    取得対象の患者情報テーブル
   * @return                    患者情報の取得結果(異常・取得失敗時：NULL）
   */
  public List<Map<String,Object>> getPatSamaryMergeWeekInfo(
          String strPatID,
          int PatDayOfWeek,
          PatInfoTable PatInfoTableName)
  {
      // 患者装置設定取得
      List<Map<String,Object>> dt = null;
      if (strPatID == null)
      {
          return null;
      }

      StringBuffer setSql = new StringBuffer() ;
      switch (PatInfoTableName)
      {
          //患者風袋補正情報
          case Revice_Tare:

            //=========================================================
            //　使わないのでそのまま
            //=========================================================

//              sqlPrms.AddParam(":PATID", strPatID);   // 患者ID
//              sqlPrms.AddParam(":DAY_OF_WEEK", PatDayOfWeek);   // 対象曜日
//              dt = db.SelectTable(SQLPat.GetWeekTreInfo(), sqlPrms.GetParam());
//              if (dt == null)
//              {
//                  return null;
//              }
//              if (dt.Rows.Count != 6)
//              {
//                  LogManager.WriteErrorLog(logInfo, null, string.Format("DB取得件数不当 処理件数：{0}件", dt.Rows.Count.ToString()), null);
//                  return null;
//              }

              break;
          //患者除水補正情報
          case Revice_Off_water:

            //=========================================================
            //　使わないのでそのまま
            //=========================================================

//              sqlPrms.AddParam(":PATID", strPatID);   // 患者ID
//              sqlPrms.AddParam(":DAY_OF_WEEK", PatDayOfWeek);   // 対象曜日
//
//              dt = db.SelectTable(SQLPat.GetWeekOffWaterInfo(), sqlPrms.GetParam());
//              if (dt == null)
//              {
//                  return null;
//              }
//              if (dt.Rows.Count != 5)
//              {
////                  LogManager.WriteErrorLog(logInfo, null, string.Format("DB取得件数不当 処理件数：{0}件", dt.Rows.Count.ToString()), null);
//                  return null;
//              }

              break;
          //患者装置設定値情報
          case Device_Set:
              setSql.append("select ");
              setSql.append("a.patid, ");
              setSql.append("a.reg_date, ");
              setSql.append("a.set_data, ");
              setSql.append("a.host_watch, ");
              setSql.append("a.next_data, ");
              setSql.append("a.calc_dialysis_date, ");
              setSql.append("a.calc_dialysis_time, ");
              setSql.append("a.calc_blood_vol ");
              setSql.append("from ");
              setSql.append("v_pat_device_set a ");
              setSql.append("where ");
              setSql.append(String.format("a.patid = %s ",strPatID));   // 患者ID
              setSql.append("and ");
              setSql.append(String.format("a.day_of_week = %s ",PatDayOfWeek));   // 対象曜日

              dt = jdbcTemplate.queryForList(setSql.toString()) ;
              if (dt == null)
              {
                  return null;
              }
              if (dt.size() != 1)
              {
                  return null;
              }

              break;
          default:
              return null;
      }

      return dt;
  }

  /**
   * 透析実績測定体重 取得処理
   * @param patId
   * @return
   */
  private List<Map<String,Object>> getRstDialysisWeight(//TODO:SQL
      String strPatId,
      Date dtmStartDate)
  {
    List<Map<String,Object>> list = null ;

        //SQLは現行のもの
        //FN_MAX_DIALYSISが使われている(これが単純ではない)


        StringBuffer setSql = new StringBuffer() ;

        setSql.append("select ");
        setSql.append("RD.DIALYSIS_NO, ");
        setSql.append("RD.START_DATE, ");
        setSql.append("RDW.WEIGHT_AFTER ");
        setSql.append("from ");
        setSql.append("( ");
        setSql.append("select ");
        setSql.append("DIALYSIS_NO, ");
        setSql.append("BED_NO, ");
        setSql.append("START_DATE ");
        setSql.append("from ");
        setSql.append("RST_DIALYSIS ");
        setSql.append("where ");
        setSql.append(String.format("DIALYSIS_NO = FN_MAX_DIALYSIS(%s, %s, 1, 2, %s) ",strPatId,dtmStartDate,FILTER_ANY));
        setSql.append(") RD, ");
        setSql.append("( ");
        setSql.append("select ");
        setSql.append("DIALYSIS_NO, ");
        setSql.append("WEIGHT_AFTER ");
        setSql.append("from ");
        setSql.append("RST_DIALYSIS_WEIGHT ");
        setSql.append(") RDW ");
        setSql.append("where ");
        setSql.append("RD.DIALYSIS_NO = RDW.DIALYSIS_NO ");

        list = jdbcTemplate.queryForList(setSql.toString()) ;

    return list ;
  }

  /**
   * BUN検査項目コードの取得処理
   * BUN(前)・BUN(後)に該当する検査項目コードを取得
   * @return   BUN(前)・BUN(後)が格納されたList
   */
  private List<Map<String,Object>> getBUNCode()    //TODO: SQLが現行そのまま
  {
    List<Map<String,Object>> list = null ;

    StringBuffer setSql = new StringBuffer() ;

    //SQL組み立て
    setSql.append("select ");
    setSql.append(" calc.EXAM_ITEM_CD ");
    setSql.append("from ");
    setSql.append("( ");
    setSql.append(" select ");
    setSql.append("     a.CALC_ITEM_CD, ");
    setSql.append("     a.EXAM_ITEM_CD ");
    setSql.append(" from ");
    setSql.append("     MST_EXAM_CALC_ITEM a ");
    setSql.append(" where ");
    setSql.append("     a.UP_DATE = ");
    setSql.append("     ( ");
    setSql.append("         select ");
    setSql.append("             max(UP_DATE) ");
    setSql.append("         from ");
    setSql.append("             MST_EXAM_CALC_ITEM ");
    setSql.append("         where ");
    setSql.append("             CALC_ITEM_CD = a.CALC_ITEM_CD ");
    setSql.append("     ) ");
    setSql.append("     and ");
    setSql.append("     a.CALC_ITEM_CD in ('001', '002') ");
    setSql.append(") calc, ");
    setSql.append("( ");
    setSql.append(" select ");
    setSql.append("     a.EXAM_ITEM_CD ");
    setSql.append(" from ");
    setSql.append("     MST_EXAM_ITEM a ");
    setSql.append(" where ");
    setSql.append("     a.REG_DATE = ");
    setSql.append("     ( ");
    setSql.append("         select ");
    setSql.append("             max(REG_DATE) ");
    setSql.append("         from ");
    setSql.append("             MST_EXAM_ITEM ");
    setSql.append("         where ");
    setSql.append("             EXAM_ITEM_CD = a.EXAM_ITEM_CD ");
    setSql.append("     ) ");
    setSql.append("     and ");
    setSql.append("     a.DEL_FLG = '0' ");
    setSql.append(") exam ");
    setSql.append("where ");
    setSql.append("calc.EXAM_ITEM_CD = exam.EXAM_ITEM_CD ");
    setSql.append("order by ");
    setSql.append("calc.CALC_ITEM_CD ");

    //SQL実行
    list = jdbcTemplate.queryForList(setSql.toString()) ;
    //結果返却
    return list ;
  }

  /**
   * 体液量算出用データ取得処理
   * @param patID               患者ID
   * @param calcDate            体液量算出時治療日
   * @param calcDialysisTime    体液量算出時透析時間
   * @param calcBloodVolume     体液量算出時血流量平均値
   * @param strBUNBfrCode       BUN（前）検査項目コード
   * @param strBUNAftCode       BUN(後)検査項目コード
   * @return DialysisCalculator 体液量算出用データ
   */
  private DialysisCalculator getBodyLiqCalcData(
        String patID,
        Date calcDate,
        int calcDialysisTime,
        int calcBloodVolume,
        String strBUNBfrCode,
        String strBUNAftCode
      )
  {

    // 体液量算出用のパラメータ取得
      List<Map<String,Object>> dtBDY = null ;
    dtBDY = getBDYDialysis(patID, calcDate, strBUNBfrCode, strBUNAftCode);
    if (null == dtBDY)
    {
        return null;
    }
      Map<String,Object> rowBDY = dtBDY.get(0) ;
    if (true == rowBDY.containsKey(DialysisCalculator.BDY_BLOOD_CIRCULATE_TOTAL))
    {
        // 血流量積算値カラムは使用しない
        dtBDY.remove(DialysisCalculator.BDY_BLOOD_CIRCULATE_TOTAL);
    }
    if (false == rowBDY.containsKey(DialysisCalculator.BDY_BLOOD_VOLUME))
    {
        // 血流量平均値カラムを追加し、上位から指定された値を代入する
        rowBDY.put(DialysisCalculator.BDY_BLOOD_VOLUME,"");
    }
//    DataRow rowBDY = dtBDY.Rows[0];
//
    if (true == calcDate.equals((Date)rowBDY.get(DialysisCalculator.BDY_DIALYSIS_DATE)))
    {
        // 計算可能日の実績、BUN検査結果あり

        // 透析時間、血流量平均値は引数値を使用
        rowBDY.put(DialysisCalculator.BDY_RUNNING_TIME,calcDialysisTime);
        rowBDY.put(DialysisCalculator.BDY_BLOOD_VOLUME,calcBloodVolume);
    }
    else
    {
        //■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
        //■　ここは、現行ソースで、以下のコメントのみの処理
        //■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

        // 計算可能日の、有効な体液量計算パラメタ無し

        // 考えられる理由：
        // 計算可能日の実績が、削除　または　透析開始日時が変更された
        // または
        // 計算可能日のBUN検査結果が削除　または　検査日／検査区分が変更された
    }

    //    return new DialysisCalculator(logInfo, rowBDY);
    return new DialysisCalculator(rowBDY);

  }

  /**
   * 体液量算出に使用するデータテーブル取得処理
   * @param strPatID        取得対象患者ID
   * @param dtmCalcDialDate 体液量算出時治療日時
   * @param bunBefore       BUN(前)検査項目コード
   * @param bunAfter        BUN(後)検査項目コード
   * @return                体液量計算用透析実績、透析前・後BUN検査値(クラス変換用にカラム名称変換済み)
   */
  public List<Map<String,Object>> getBDYDialysis(
                  String strPatID,
                  Date dtmCalcDialDate,
                  String bunBefore,
                  String bunAfter
            )
  {
      Date examDateFrom = dtmCalcDialDate;
      Calendar cal = Calendar.getInstance() ;
      cal.setTime(examDateFrom);
      cal.add(Calendar.DATE, 1);
      cal.add(Calendar.MILLISECOND, -1);
      Date examDateTo = cal.getTime();

      StringBuffer setSql = new StringBuffer() ;

      HashMap<String,Object> sqlParam = new HashMap<>() ;

      sqlParam.put(":PATID", strPatID);
      sqlParam.put(":EXAM_ITEM_CD_BUN_BFR", bunBefore);
      sqlParam.put(":EXAM_ITEM_CD_BUN_AFT", bunAfter);
      sqlParam.put(":EXAM_DATE_FROM", examDateFrom);
      sqlParam.put(":EXAM_DATE_TO", examDateTo);
      sqlParam.put(":DIALYSIS_DATE_FROM", dtmCalcDialDate);
      sqlParam.put(":DIALYSIS_DATE_TO", dtmCalcDialDate);
      sqlParam.put(":SERIES_CD", FILTER_ANY);

      setSql = selectDialysisAmountProgInfo(sqlParam) ;

      List<Map<String,Object>> dtBDYDialysis = jdbcTemplate.queryForList(setSql.toString());
      if (null == dtBDYDialysis)
      {
          return null;
      }
      // 1件取れなかった場合
      else if (false == (1 == dtBDYDialysis.size()))
      {
          // 空で返す
          List<Map<String,Object>> dtEmpty = DialysisCalculator.getEmptyParamDataTable();
          return dtEmpty;
      }

      return dtBDYDialysis;
  }

  /**
   *　患者情報取得SQL組み立て処理
   * @param sqlParam    SQL組み立てに必要なパラメータ
   * @return　患者情報取得SQL
   */
  private StringBuffer selectDialysisAmountProgInfo(HashMap<String,Object> sqlParam)    //TODO:SQL
  {
    StringBuffer setSql = new StringBuffer() ;

    setSql.append("with ");
    // 最新の検査結果テーブルの主キー
    setSql.append("PAT_EXAMIN_HST_PK as ");
    setSql.append("( ");
    setSql.append(" select ");
    setSql.append("     REG_DATE,  ");
    setSql.append("     REG_EXAM_DATE,  ");
    setSql.append("     REG_ORDER_CLASS,  ");
    setSql.append("     max(UP_DATE) as UP_DATE ");
    setSql.append(" from ");
    setSql.append("     PAT_EXAMIN_HST ");
    setSql.append(" where ");
    setSql.append("     PATID = :PATID ");
    setSql.append(" group by ");
    setSql.append("     REG_DATE, REG_EXAM_DATE, REG_ORDER_CLASS  ");
    setSql.append("), ");
    // 検査区分が透析前かつ、BUN<前>検査結果を持つ検査結果（+検査結果詳細） ");
    setSql.append("PAT_EXAMIN_BFR as ");
    setSql.append("( ");
    setSql.append(" select ");
    setSql.append("     i.EXAM_DATE,  ");
    setSql.append("     j.EXAM_RST ");
    setSql.append(" from ");
            // 指定患者、指定期間、検査区分が透析前の、検査結果テーブル最新レコード
    setSql.append(" ( ");
    setSql.append("     select ");
    setSql.append("         a.REG_DATE,  ");
    setSql.append("         a.REG_EXAM_DATE,  ");
    setSql.append("         a.REG_ORDER_CLASS,  ");
    setSql.append("         a.EXAM_DATE  ");
    setSql.append("     from ");
    setSql.append("         ( ");
    setSql.append("         select ");
    setSql.append("             REG_DATE,  ");
    setSql.append("             REG_EXAM_DATE,  ");
    setSql.append("             REG_ORDER_CLASS, ");
    setSql.append("             UP_DATE,  ");
    setSql.append("             EXAM_DATE  ");
    setSql.append("         from ");
    setSql.append("             PAT_EXAMIN_HST ");
    setSql.append("         where ");
    setSql.append("             PATID = :PATID ");
    setSql.append("             and ");
    setSql.append("             EXAM_DATE between :EXAM_DATE_FROM and :EXAM_DATE_TO ");
    setSql.append("             and ");
    setSql.append("             ORDER_CLASS = '0' ");
    setSql.append("             and ");
    setSql.append("             DEL_FLG = '0' ");
    setSql.append("         ) a, ");
    setSql.append("         PAT_EXAMIN_HST_PK b ");
    setSql.append("     where ");
    setSql.append("         a.REG_DATE = b.REG_DATE ");
    setSql.append("         and");
    setSql.append("         a.REG_EXAM_DATE = b.REG_EXAM_DATE ");
    setSql.append("         and ");
    setSql.append("         a.REG_ORDER_CLASS = b.REG_ORDER_CLASS ");
    setSql.append("         and ");
    setSql.append("         a.UP_DATE = b.UP_DATE ");
    setSql.append(" ) i, ");//
            // BUN<前>検査項目コードを持つ検査結果詳細テーブル最新レコード
    setSql.append("( ");
    setSql.append("     select ");
    setSql.append("         a.REG_DATE, ");
    setSql.append("         a.REG_EXAM_DATE,  ");
    setSql.append("         a.REG_ORDER_CLASS,  ");
    setSql.append("         a.EXAM_RST ");
    setSql.append("     from ");
    setSql.append(          "PAT_EXAMIN_HST_DETAIL a,  ");
    setSql.append("         ( ");
    setSql.append("             select ");
    setSql.append("                 REG_DATE, REG_EXAM_DATE, REG_ORDER_CLASS, max(UP_DATE) as UP_DATE ");
    setSql.append("             from ");
    setSql.append("                 PAT_EXAMIN_HST_DETAIL  ");
    setSql.append("             where ");
    setSql.append("                 PATID = :PATID  ");
    setSql.append("                 and      ");
    setSql.append("                 EXAM_ITEM_CODE = :EXAM_ITEM_CD_BUN_BFR ");
    setSql.append("             group by ");
    setSql.append("                 REG_DATE, REG_EXAM_DATE, REG_ORDER_CLASS ");
    setSql.append("         ) b ");
    setSql.append("     where ");
    setSql.append("         a.PATID = :PATID ");
    setSql.append("         and  ");
    setSql.append("         a.REG_DATE = b.REG_DATE ");
    setSql.append("         and      ");
    setSql.append("         a.REG_EXAM_DATE = b.REG_EXAM_DATE ");
    setSql.append("         and      ");
    setSql.append("         a.REG_ORDER_CLASS = b.REG_ORDER_CLASS ");
    setSql.append("         and      ");
    setSql.append("         a.UP_DATE = b.UP_DATE  ");
    setSql.append("         and      ");
    setSql.append("         a.EXAM_ITEM_CODE = :EXAM_ITEM_CD_BUN_BFR  ");
    setSql.append("         and      ");
    setSql.append("         a.EXAM_RST is not null ");
    setSql.append(") j ");
                // 検査結果テーブルと検査結果詳細テーブルを結合
    setSql.append("where ");
    setSql.append("     i.REG_DATE = j.REG_DATE ");
    setSql.append("     and ");
    setSql.append("     i.REG_EXAM_DATE = j.REG_EXAM_DATE ");
    setSql.append("     and  ");
    setSql.append("     i.REG_ORDER_CLASS = j.REG_ORDER_CLASS ");
    setSql.append("), ");//
    // 検査区分が透析後かつ、BUN<後>検査結果を持つ検査結果（+検査結果詳細）
    setSql.append("PAT_EXAMIN_AFT as ");
    setSql.append("( ");
    setSql.append("     select ");
    setSql.append("         i.EXAM_DATE, ");
    setSql.append("         j.EXAM_RST ");
    setSql.append("     from ");
            // 検査結果テーブル（透析後）
    setSql.append("     ( ");
    setSql.append("         select ");
    setSql.append("             a.REG_DATE,  ");
    setSql.append("             a.REG_EXAM_DATE,  ");
    setSql.append("             a.REG_ORDER_CLASS, ");
    setSql.append("             a.EXAM_DATE  ");
    setSql.append("         from ");
                    // 指定患者、指定期間、検索分が透析後、未削除のレコード
    setSql.append("             ( ");
    setSql.append("                 select ");
    setSql.append("                     REG_DATE,  ");
    setSql.append("                     REG_EXAM_DATE,  ");
    setSql.append("                     REG_ORDER_CLASS,  ");
    setSql.append("                     UP_DATE,  ");
    setSql.append("                     EXAM_DATE  ");
    setSql.append("                 from ");
    setSql.append("                     PAT_EXAMIN_HST ");
    setSql.append("                 where ");
    setSql.append("                     PATID = :PATID ");
    setSql.append("                     and ");
    setSql.append("                     EXAM_DATE between :EXAM_DATE_FROM and :EXAM_DATE_TO ");
    setSql.append("                     and ");
    setSql.append("                     ORDER_CLASS = '1' ");
    setSql.append("                     and ");
    setSql.append("                     DEL_FLG = '0' ");
    setSql.append("             ) a, ");
    setSql.append("             PAT_EXAMIN_HST_PK b ");
    setSql.append("         where ");
    setSql.append("             a.REG_DATE = b.REG_DATE ");
    setSql.append("             and ");
    setSql.append("             a.REG_EXAM_DATE = b.REG_EXAM_DATE ");
    setSql.append("             and ");
    setSql.append("             a.REG_ORDER_CLASS = b.REG_ORDER_CLASS ");
    setSql.append("             and ");
    setSql.append("             a.UP_DATE = b.UP_DATE ");
    setSql.append("     ) i, ");
            // BUN<後>検査項目コードを持つ検査結果詳細テーブルの最新レコード
    setSql.append("     ( ");
    setSql.append("         select ");
    setSql.append("             a.REG_DATE, a.REG_EXAM_DATE, a.REG_ORDER_CLASS, a.EXAM_RST ");
    setSql.append("         from ");
    setSql.append("             PAT_EXAMIN_HST_DETAIL a,  ");
    setSql.append("             ( ");
    setSql.append("                 select ");
    setSql.append("                     REG_DATE,  ");
    setSql.append("                     REG_EXAM_DATE,  ");
    setSql.append("                     REG_ORDER_CLASS,  ");
    setSql.append("                     max(UP_DATE) as UP_DATE ");
    setSql.append("                 from ");
    setSql.append("                     PAT_EXAMIN_HST_DETAIL  ");
    setSql.append("                 where ");
    setSql.append("                     PATID = :PATID ");
    setSql.append("                 and ");
    setSql.append("                     EXAM_ITEM_CODE = :EXAM_ITEM_CD_BUN_AFT ");
    setSql.append("                 group by ");
    setSql.append("                     REG_DATE, REG_EXAM_DATE, REG_ORDER_CLASS ");
    setSql.append("             ) b ");
    setSql.append("         where ");
    setSql.append("             a.PATID = :PATID ");
    setSql.append("             and ");
    setSql.append("             a.REG_DATE = b.REG_DATE ");
    setSql.append("             and  ");
    setSql.append("             a.REG_EXAM_DATE = b.REG_EXAM_DATE ");
    setSql.append("             and ");
    setSql.append("             a.REG_ORDER_CLASS = b.REG_ORDER_CLASS ");
    setSql.append("             and ");
    setSql.append("             a.UP_DATE = b.UP_DATE  ");
    setSql.append("             and ");
    setSql.append("             a.EXAM_ITEM_CODE = :EXAM_ITEM_CD_BUN_AFT ");
    setSql.append("             and ");
    setSql.append("             a.EXAM_RST is not null ");
    setSql.append("     ) j ");
    setSql.append("     where ");
    setSql.append("         i.REG_DATE = j.REG_DATE ");
    setSql.append("         and  ");
    setSql.append("         i.REG_EXAM_DATE = j.REG_EXAM_DATE ");
    setSql.append("         and  ");
    setSql.append("         i.REG_ORDER_CLASS = j.REG_ORDER_CLASS ");
    setSql.append(" ) ");
    //-------- with句終了。ここから本体 ----------
    setSql.append("select ");
    setSql.append("     v.START_DATE            as BDY_DIALYSIS_DATE, ");
    setSql.append("     v.ADD_TOTAL             as BDY_ADD_TOTAL, ");
    setSql.append("     v.BLOOD_CIRCULATE_TOTAL as BDY_BLOOD_CIRCULATE_TOTAL, ");
    setSql.append("     v.RUNNING_TIME          as BDY_RUNNING_TIME,  ");
    setSql.append("     w.EXAM_RST_BFR          as BDY_BUN_BEFORE,  ");
    setSql.append("     w.EXAM_RST_AFT          as BDY_BUN_AFTER,  ");
    setSql.append("     x.WEIGHT_BEFORE         as BDY_WEIGHT_BEFORE, ");
    setSql.append("     x.WEIGHT_AFTER          as BDY_WEIGHT_AFTER,  ");
    setSql.append("     y.VALUE                 as BDY_LIQUID_VOLUME,  ");
    setSql.append("     z.KOA                   as BDY_KOA ");
    setSql.append("from  ");
        // 指定期間のその日最後の「透析」実績
    setSql.append("     ( ");
    setSql.append("         select ");
    setSql.append("             v1.DIALYSIS_NO,  ");
    setSql.append("             v1.START_DATE,  ");
    setSql.append("             v1.ADD_TOTAL,  ");
    setSql.append("             v1.BLOOD_CIRCULATE_TOTAL,  ");
    setSql.append("             v1.RUNNING_TIME ");
    setSql.append("         from ");
    setSql.append("             RST_DIALYSIS v1, ");
    setSql.append("             ( ");
    setSql.append("                 select ");
    setSql.append("                     FN_MAX_DIALYSIS(b.PATID, max(b.START_DATE), 1, 2, :SERIES_CD) as DIALYSIS_NO ");
    setSql.append("                 from ");
    setSql.append("                 ( ");
    setSql.append("                     select ");
    setSql.append("                         a.PATID, ");
    setSql.append("                         trunc(a.START_DATE) TRUNC_DATE, ");
    setSql.append("                         a.START_DATE ");
    setSql.append("                     from ");
    setSql.append("                         RST_DIALYSIS a ");
    setSql.append("                     where ");
    setSql.append("                         a.PATID = :PATID ");
    setSql.append("                         and ");
    setSql.append("                         a.START_DATE between :DIALYSIS_DATE_FROM and :DIALYSIS_DATE_TO ");
    setSql.append("                         and ");
    setSql.append("                         a.DEL_FLG = '0' ");
    setSql.append("                 ) b ");
    setSql.append("                 group by ");
    setSql.append("                     b.PATID, b.TRUNC_DATE ");
    setSql.append("             ) v2 ");
    setSql.append("         where ");
    setSql.append("             v1.DIALYSIS_NO = v2.DIALYSIS_NO ");
    setSql.append("     ) v, ");
        // 指定期間のBUN検査結果
        // 同日に有効なレコードが複数ある場合、検査日時の若い方のレコードが有効
    setSql.append("     ( ");
    setSql.append("         select ");
    setSql.append("             i.EXAM_DATE, ");
    setSql.append("             i.EXAM_RST as EXAM_RST_BFR, ");
    setSql.append("             j.EXAM_RST as EXAM_RST_AFT  ");
    setSql.append("         from ");
    setSql.append("         ( ");
    setSql.append("             select ");
    setSql.append("                 trunc(a.EXAM_DATE) as EXAM_DATE, a.EXAM_RST ");
    setSql.append("             from ");
    setSql.append("                 PAT_EXAMIN_BFR a, ");
    setSql.append("                 ( ");
    setSql.append("                     select ");
    setSql.append("                         min(EXAM_DATE) as EXAM_DATE ");
    setSql.append("                     from ");
    setSql.append("                         PAT_EXAMIN_BFR ");
    setSql.append("                     group by ");
    setSql.append("                         trunc(EXAM_DATE) ");
    setSql.append("                 ) b ");
    setSql.append("             where ");
    setSql.append("                 a.EXAM_DATE = b.EXAM_DATE ");
    setSql.append("         ) i, ");
    setSql.append("         ( ");
    setSql.append("             select ");
    setSql.append("                 trunc(a.EXAM_DATE) as EXAM_DATE, a.EXAM_RST ");
    setSql.append("             from ");
    setSql.append("                 PAT_EXAMIN_AFT a, ");
    setSql.append("                 ( ");
    setSql.append("                     select ");
    setSql.append("                         min(EXAM_DATE) as EXAM_DATE ");
    setSql.append("                     from ");
    setSql.append("                         PAT_EXAMIN_AFT ");
    setSql.append("                     group by ");
    setSql.append("                         trunc(EXAM_DATE) ");
    setSql.append("                 ) b ");
    setSql.append("             where ");
    setSql.append("                 a.EXAM_DATE = b.EXAM_DATE ");
    setSql.append("         ) j ");
    setSql.append("         where ");
    setSql.append("             i.EXAM_DATE = j.EXAM_DATE ");
    setSql.append("     ) w, ");//
        // 透析実績測定体重
    setSql.append("     RST_DIALYSIS_WEIGHT x, ");//
        // 透析実績透析条件(透析液流量)
    setSql.append("     ( ");
    setSql.append("         select ");
    setSql.append("             DIALYSIS_NO, VALUE ");
    setSql.append("         from ");
    setSql.append("             RST_DIALYSIS_COND ");
    setSql.append("         where ");
    setSql.append("             CTL_NO = '019' ");
    setSql.append("     ) y, ");
        // 透析実績透析条件+ダイアライザマスタ(KOA)
    setSql.append("     ( ");
    setSql.append("         select ");
    setSql.append("             a.DIALYSIS_NO, ");
    setSql.append("             b.KOA ");
    setSql.append("         from ");
    setSql.append("             RST_DIALYSIS_COND a, ");
    setSql.append("             V_MST_DIALYZER b ");
    setSql.append("         where ");
    setSql.append("             a.CTL_NO = '008' ");
    setSql.append("             and     a.VALUE = b.DIALYZER_CD ");
    setSql.append("     ) z ");
    // 治療日とBUN検査日が一致するレコードのみ取得する
    setSql.append("     where ");
    setSql.append("         trunc(v.START_DATE) = w.EXAM_DATE ");
    setSql.append("         and     v.DIALYSIS_NO = x.DIALYSIS_NO(+) ");
    setSql.append("         and     v.DIALYSIS_NO = y.DIALYSIS_NO(+) ");
    setSql.append("         and     v.DIALYSIS_NO = z.DIALYSIS_NO(+) ");//
    // 治療日の降順でソート
    setSql.append("     order by v.START_DATE desc ");


    //埋め込みパラメータの置き換え
    String forReplace = setSql.toString();

    forReplace.replace(":PATID", (String)sqlParam.get(":PATID"));
    forReplace.replace(":EXAM_ITEM_CD_BUN_BFR", (String)sqlParam.get(":EXAM_ITEM_CD_BUN_BFR"));
    forReplace.replace(":EXAM_ITEM_CD_BUN_AFT", (String)sqlParam.get(":EXAM_ITEM_CD_BUN_AFT"));

    forReplace.replace(":EXAM_DATE_FROM", (String)sqlParam.get(":EXAM_DATE_FROM"));
    forReplace.replace(":EXAM_DATE_TO", (String)sqlParam.get(":EXAM_DATE_TO"));
    forReplace.replace(":DIALYSIS_DATE_FROM", (String)sqlParam.get(":DIALYSIS_DATE_FROM"));
    forReplace.replace(":DIALYSIS_DATE_TO", (String)sqlParam.get(":DIALYSIS_DATE_TO"));

    forReplace.replace(":SERIES_CD", (String)sqlParam.get(":SERIES_CD"));


    setSql = new StringBuffer(forReplace) ;

    return setSql ;
  }

  /**
   * 単位変換(ml->L)処理
   * @param value 入力値(単位ml)
   * @return 数値文字列(0.00)(単位L)
   */
  private String calcBodyFluidAndReviseValueL(Double value)
  {
    String retValue = null ;

    retValue = String.format("%.2f",value/1000.0);

    return retValue ;
  }

//  /**
//   * TODO：取得場所をメインに移したことにより、不要になるかもしれないが削除は保留
//   * BV-UFC設定取得処理
//   * @param ordNo    オーダー番号
//   * @return    BV-UFC設定値(取得できなかった場合はnull)
//   */
//  private String getBVUFCSettingFromDB(    //TODO: JdbcTemplete -> DOMA
//          String ordNo
//        )
//  {
//    String settingBV_UFC = "" ;
//    JSONObject deviceOption = null ;
//
//    //SQL組み立て
//    StringBuffer setSql = new StringBuffer() ;
//
//
//    //ord_main,mst_bed経由でmst_machineから抽出(条件は,ordNo)
//
//    //SQLの組み立て
//    setSql.append("select ");
//    setSql.append("MAC.MACHINE_OPTION ");
//    setSql.append("from ");
//    setSql.append("MST_MACHINE MAC,ORD_MAIN ORD,MST_BED BED ");
//    setSql.append("where ");
//    setSql.append(String.format("ORD.ord_no = '%s' ",ordNo));
//    setSql.append("and ");
//    setSql.append("ORD.facility_cd = BED.facility_cd ");
//    setSql.append("and ");
//    setSql.append("ORD.bed_cd = BED.bed_cd ");
//    setSql.append("and ");
//    setSql.append("BED.facility_cd = MAC.facility_cd ");
//    setSql.append("and ");
//    setSql.append("BED.machine_no = MAC.machine_no ");
//
//    //SQLの実行
//    List<Map<String,Object>> list ;
//    try {
//      list = jdbcTemplate.queryForList(setSql.toString()) ;
//    }
//    catch(Exception e)
//    {//SQLエラー
//      list = null ;
//    }
//
//    if (null == list || list.size() == 0)
//    {//リストが、nullもしくはサイズが0
//      // 取得失敗のため終了
//      settingBV_UFC = null ;
//      return settingBV_UFC;
//    }
//
//    //戻り値の初期はnull
//    settingBV_UFC = null ;
//    //リスト分ループ
//    for(int i = 0 ; i < list.size(); i++)
//    {
//      //項目(DEVICE_OPTION)の取得
//      deviceOption = (JSONObject)list.get(i).get(PARAMKEY.MACHINE_OPTION.get()) ;
//      try {
//        //BV-UFC設定の取得(装置オプション"A-0207")
//        settingBV_UFC = (String)deviceOption.getString(MACHINEKEY.MACOPT_A0207.get()) ;
//      }
//      catch(Exception e)
//      {
//        settingBV_UFC = null ;
//      }
//      //有効な値が取れたらループ終了
//      if(settingBV_UFC.length() != 0) break ;
//    }
//
//    //値の返却
//    return settingBV_UFC ;
//  }

  /**
   * 透析量プログラム設定(システム）取得処理
   * システム設定テーブルからCDが37のデータの値(Value)を取得する
   * ※mst_facility_settingから取得。現在は、設定がないため、常にON
   * @return    透析量プログラム設定(システム）
   */
  private String getAlqdFloodVolProgFromDB()
  {
    String ret = null ;


    //TODO:mst_facility_settingから取得

    //TODO:mst_facility_settingから取得した値を返却
    //現在は、システム設定(オプション機能として契約上、透析量プログラムを使えるか使えないかを設定する)は、常にON(個別設定に従うことになる)
    ret = CommonIndConst.SETTING_ON.get();

    return ret ;
  }

//  /**
//   * ホスト監視情報取得処理
//   * @param patId   患者ＩＤ
//   * @return
//   */
//  private JSONObject getHostWatchfromDB(String patId)  //TODO:SQL
//  {
//    JSONObject retObj = null ;
//
//    //SQL組み立て
//    StringBuffer setSql = new StringBuffer() ;
//
//    //SQLの組み立て
//    setSql.append("select ");
//    setSql.append("host_watch ");
//    setSql.append("from ");
//    setSql.append("PAT_DEVICE_SET X");
//    setSql.append("inner join ");
//    setSql.append("( ");
//    setSql.append("select patid,MAX(REG_DATE) as regdate from PAT_DEVICE_SET group by patid ");
//    setSql.append(") Y ");
//    setSql.append("on ");
//    setSql.append("X.patid = Y.patid ");
//    setSql.append("and ");
//    setSql.append("X.REG_DATE = Y.regdate ");
//    setSql.append("and ");
//    setSql.append(String.format("X.PATID = '%s' ",patId));
//
//    List<Map<String,Object>> list ;
//    try {
//      list = jdbcTemplate.queryForList(setSql.toString()) ;
//    }
//    catch(Exception e)
//    {//SQLエラー
//      list = null ;
//    }
//
//    if (null == list || list.size() == 0)
//    {
//      // 取得失敗のため終了
//      retObj = null ;
//      return retObj;
//    }
//
//    retObj = (JSONObject)list.get(0).get(SEND_COND_PARAM.HOST_WATCH.get()) ;
//
//    return retObj ;
//  }

  /**
   * 機種タイプ(型式コード)取得処理
   * @param ordNo       オーダー番号
   * @return
   */
  private String getMachineTypeCdFromDB(String ordNo)
  {
    String machineTypeCd = null ;

    //SQLの実行

    try {
      List<Map<String,Object>> list = webAPICheckConditionSendService.getMachineTypeFromMstMachine(Long.parseLong(ordNo));
      if(null == list || 0 == list.size())
      {
        //DBにデータがない
        machineTypeCd = null ;
      }
      else
      {
        //値の取得
        machineTypeCd = (String)list.get(0).get(PARAMKEY.DEVICE_TYPE_CD.get()) ;
      }
    }
    catch(Exception e)
    {
      //SQLエラー発生
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      machineTypeCd = null ;
    }

    return machineTypeCd ;
  }

  /**
   * 体液量＋補正値計算取得処理
   * @param patId  患者ID
   * @param treatDate　   治療日
   * @return
   */
  private String getBodyFluidAndReviseValue(
        String patId,
        String treatDate
      )
  {
    String ret = null ;

    // Date型変換
    Date formatDate = null ;
    try {
      formatDate = new SimpleDateFormat("yyyyMMdd HH:mm:ss").parse(treatDate);
    }
    catch(Exception e)
    {
      formatDate = null ;
    }
    List<Map<String,Object>> tableDeviceSet = getDeviceSetDataDBInfo(patId,formatDate); //TODO:日付は仮置き
    if (tableDeviceSet == null)
    {
        return null;
    }
    else if (tableDeviceSet.size() > 0 && null != tableDeviceSet.get(0).get(PARAMKEY.CALC_DIALYSIS_DATE.get()))
    {
        Date dtmCalcDialysis = (Date)tableDeviceSet.get(0).get(PARAMKEY.CALC_DIALYSIS_DATE.get());

        // 体液量計測時後体重
        List<Map<String,Object>> tableRstDialysisWeight = getRstDialysisWeight(patId, dtmCalcDialysis); //TODO:メソッド
        if (tableRstDialysisWeight == null)
        {
            return null;
        }

        Map<String,Object> dr = tableDeviceSet.get(0);    // 患者装置設定
        if (
            (true == ((String)dr.get(PARAMKEY.CALC_DIALYSIS_DATE.get())).matches("^[1-9]?[0-9]+$"))     //TODO: 計算可能治療日がDateTime型(とりあえず数値かどうか)
              &&
            (true == ((String)dr.get(PARAMKEY.CALC_DIALYSIS_TIME.get())).matches("^[1-9]?[0-9]+$"))    // 体液量算出時透析時間が数値型
              &&
            (true == ((String)dr.get(PARAMKEY.CALC_BLOOD_VOL.get())).matches("^[1-9]?[0-9]+$"))         // 体液量算出時血流量平均値が数値型
            )
         {
            // BUN検査項目コードの取得
            List<Map<String,Object>> dtBUNCode = getBUNCode();//TODO:メソッド
            if (null == dtBUNCode)
            {
                // DBエラー
                return null;
            }
            else if (2 > dtBUNCode.size())
            {
                // マスタ件数不足
                return null;
            }

            String strBUNBfrCode = (String)dtBUNCode.get(0).get(PARAMKEY.EXAM_ITEM_CD.get());
            String strBUNAftCode = (String)dtBUNCode.get(1).get(PARAMKEY.EXAM_ITEM_CD.get());
            //体液量算出用のデータを取得
            DialysisCalculator calc = getBodyLiqCalcData(
                patId,
                (Date)dr.get(PARAMKEY.CALC_DIALYSIS_DATE.get()),
                Integer.parseInt((String)dr.get(PARAMKEY.CALC_DIALYSIS_TIME.get())),
                Integer.parseInt((String)dr.get(PARAMKEY.CALC_BLOOD_VOL.get())),
                strBUNBfrCode,
                strBUNAftCode);
            if (null == calc)
            {
                // DBエラー
                return null;
            }

            //体液量＋補正値の取得
            String bodyFluidAndReviseValue = calc.getBodyFluidAndReviseValue();

            if(null == bodyFluidAndReviseValue)
            {
              return null ;
            }
            else
            {
              ret = bodyFluidAndReviseValue ;
            }
        }
        else
        {
          return null ;
        }
    }
    return ret ;
  }

  /**
   * 液体量算出治療日透析実績取得処理
   * @param calcTreatDate    液体量算出治療日
   * @return
   */
  private HashMap<PARAMKEY,Object> getRstDialysisDataFromDB(    //TODO:SQL
            String strPatId,
            String calcTreatDate
            )
  {
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    List<Map<String,Object>> list = null ;

    //SQLは現行のもの
    //FN_MAX_DIALYSISが使われている(これが単純ではない)


    StringBuffer setSql = new StringBuffer() ;

    // TODO: SQL未実装のため呼び出さない透析量プログラム担当会社へ
    setSql.append("select ");
    setSql.append(" RD.ADD_TOTAL as ADD_TOTAL, ");
    setSql.append(" RDW.WEIGHT_BEFORE as WEIGHT_BEFORE, ");
    setSql.append(" RDW.WEIGHT_AFTER as WEIGHT_AFTER ");
    setSql.append("from ");
    setSql.append(" ( ");
    setSql.append("     select ");
    setSql.append("         ADD_TOTAL ");
    setSql.append("     from ");
    setSql.append("         RST_DIALYSIS ");
    setSql.append("     where ");
    setSql.append(String.format("DIALYSIS_NO = FN_MAX_DIALYSIS(%s, %s, 1, 2, %s) ",strPatId,calcTreatDate,FILTER_ANY));
    setSql.append(" ) RD, ");
    setSql.append(" ( ");
    setSql.append("     select ");
    setSql.append("         DIALYSIS_NO, ");
    setSql.append("         WEIGHT_BEFORE, ");
    setSql.append("         WEIGHT_AFTER ");
    setSql.append("     from ");
    setSql.append("         RST_DIALYSIS_WEIGHT ");
    setSql.append(" ) RDW ");
    setSql.append("where ");
    setSql.append(" RD.DIALYSIS_NO = RDW.DIALYSIS_NO ");

    list = jdbcTemplate.queryForList(setSql.toString()) ;

    if(null == list || 0 == list.size())
    {
      retVal = null ;
    }
    else
    {
      retVal.put(PARAMKEY.ADD_TOTAL, list.get(0).get(PARAMKEY.ADD_TOTAL.get())) ;
      retVal.put(PARAMKEY.WEIGHT_BEFORE, list.get(0).get(PARAMKEY.WEIGHT_BEFORE.get())) ;
      retVal.put(PARAMKEY.WEIGHT_AFTER, list.get(0).get(PARAMKEY.WEIGHT_AFTER.get())) ;
    }

    return retVal ;
  }

  /**
   * D-FASオプションチェック処理
   * @return
   */
  private boolean checkDFASOption(String ordNo)
  {
    boolean ret = true ;
    // 指定タグ(D-FAS)の装置オプション情報のチェック
    ret =  this.checkMachineOption(ordNo,PARAMKEY.MACHINE_OPTION_DFAS.get());
    return ret ;
  }

  /**
   *　患者情報取得処理
   * 患者情報をDBから取得する
   * @param patId       患者ID
   * @return <PARAMKEY:value>
   *    PARAMKEY.PAT_LAST_NAME  患者名(姓)
   *    PARAMKEY.PAT_FIRST_NAME 患者名(名)
   */
  HashMap<PARAMKEY,Object> getPatDataFromDB(
        String patId
      )
  {
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;

    Map<String,Object> map = webAPICheckConditionSendService.getPatNameFromPatPersonalMain(Long.valueOf(patId));
    if (null == map || map.size() == 0)
    {
      // 取得失敗のため終了
      retVal = null ;
      return retVal;
    }

    retVal.put(PARAMKEY.PAT_LAST_NAME, map.get(PARAMKEY.PAT_LAST_NAME.get())) ;
    retVal.put(PARAMKEY.PAT_FIRST_NAME, map.get(PARAMKEY.PAT_FIRST_NAME.get())) ;

    return retVal ;
  }

  /**
   * ord_mainデータ取得処理
   * @param ord_no  オーダー番号
   * @param retValOrdMain 返却値 <PARAMKEY:value>
   *            PATID           ：患者ID
   *            BED_NO          ：ベッド番号
   *            KUR_CD          ：クールコード
   *            DIALYSIS_DATE   ：治療日
   *            FACILITY_CD     ：施設コード
   * @return
   *        true:成功
   */
  private boolean getDataFromOrdMain(
          String ordNo,
          HashMap<PARAMKEY,Object> retValOrdMain
      )
  {
    boolean ret = true ;
    String patId = null;            //患者ID
    String bedNo = null  ;          //ベッド番号
    String kurCd = null  ;          //クールコード
    String treatDate = null ;       //治療日
    String facilityCd = null ;      //施設コード
    JSONObject indCondInfo = null ;  //条件指示情報
    JSONObject indOffWaterInfo = null ;  //除水補正
    JSONObject rstWeightInfo = null ;  //実績:体重情報

    // ord_mainよりレコードを取得 ※レビュー指摘で、mainの取得構造は変えずに、取得元のDaoを変えるという方針の実装
    OrdMain ordMainData = null ;

    try {
      ordMainData = webAPICheckConditionSendService.getDataFromOrdMain(Long.parseLong(ordNo));
    }
    catch(Exception e)
    {//SQLエラー発生
      EventLogMessage eventLogMessage = new EventLogMessage();
  	  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      ordMainData = null ;
    }

    if (null == ordMainData)
    {
        // 取得失敗のため終了
        ret = false ;
        return ret;
    }

    Object valObj = null ;

    // 患者IDの取得
    patId = ordMainData.getPatId().toString() ;

    // 指示ベッドコードの取得
    valObj = ordMainData.getIndBedCd() ;
    bedNo = valObj == null ? null : valObj.toString();
    // 指示クールコードの取得
    valObj = ordMainData.getIndKurCd() ;
    kurCd = valObj == null ? null : valObj.toString();
    // 治療日の取得
    valObj = ordMainData.getTreatDate() ;
    treatDate = valObj == null ? null : valObj.toString();
    // 施設コードの取得
    valObj = ordMainData.getFacilityCd() ;
    facilityCd = valObj == null ? null : valObj.toString();

    // 指示:治療条件情報の取得
    try {
      valObj = ordMainData.getIndCondInfo() ;

      if(null == valObj)
      {
        indCondInfo = null ;
      }
      else
      {
        indCondInfo = new JSONObject((String)valObj) ;
      }
    }
    catch(Exception e)
    {//JSONエラー
      indCondInfo = null ;
    }

    // 指示:除水補正の取得
    try {
      valObj = ordMainData.getIndOffWaterInfo() ;

      if(null == valObj)
      {
        indOffWaterInfo = null ;
      }
      else
      {
        indOffWaterInfo = new JSONObject((String)valObj) ;
      }
    }
    catch(Exception e)
    {//JSONエラー
      indCondInfo = null ;
    }

    // 実績:体重情報の取得
    try {
      valObj = ordMainData.getRstWeightInfo() ;

      if(null == valObj)
      {
        rstWeightInfo = null ;
      }
      else
      {
        rstWeightInfo = new JSONObject((String)valObj) ;
      }
    }
    catch(Exception e)
    {//JSONエラー
      indCondInfo = null ;
    }

    String indDw = null;
    String rstDw = null;
    // DWの取得
    valObj = ordMainData.getIndDw();
    indDw = valObj == null ? null : valObj.toString();
    valObj = ordMainData.getRstDw();
    rstDw = valObj == null ? null : valObj.toString();

    //返却準備
    retValOrdMain.put(PARAMKEY.PATID, patId);
    retValOrdMain.put(PARAMKEY.BED_CD, bedNo);
    retValOrdMain.put(PARAMKEY.KUR_CD, kurCd);
    retValOrdMain.put(PARAMKEY.TREAT_DATE, treatDate);
    retValOrdMain.put(PARAMKEY.FACILITY_CD, facilityCd);
    retValOrdMain.put(PARAMKEY.IND_COND_INFO, indCondInfo);
    retValOrdMain.put(PARAMKEY.IND_OFF_WATER_INFO, indOffWaterInfo);
    retValOrdMain.put(PARAMKEY.RST_WEIGHT_INFO, rstWeightInfo);
    retValOrdMain.put(PARAMKEY.IND_DW, indDw);
    retValOrdMain.put(PARAMKEY.RST_DW, rstDw);

    return ret ;
  }

  /**
   * 指定装置オプションチェック処理
   * 装置マスタの装置オプション(Json)で、指定キーの設定が有効(="1")な装置が存在するか調べる
   * ※同じ施設コード内で1つでも存在すれば有効と判定する
   * @param ordNo     オーダー番号
   * @param tagName   装置オプションのキー名
   * @return    true:指定装置オプション 有効 / false:指定装置オプション 無効
   */
  private boolean checkMachineOption(
      String ordNo,
      String keyName
  )
  {
    //戻り値 初期値:false
    boolean ret = false ;

    // 装置マスタより装置オプション一覧を取得
    List<String> list ;
    try {
      list = webAPICheckConditionSendService.getMachineOptionsFromMstMachine(Long.parseLong(ordNo));
    }
    catch(Exception e)
    {//SQLエラー
      EventLogMessage eventLogMessage = new EventLogMessage();
  	  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      list = null ;
    }
    if (null == list || list.size() == 0)
    {
        // 取得失敗のため終了
        ret = false ;
        return ret;
    }

    JSONObject objJson = null ;
    String tmpStr = null ;

    //取得した装置オプションのレコード数分ループして確認
    for(int i = 0 ; i < list.size(); i++)
    {
        try {
          objJson = new JSONObject(list.get(i)) ;
        }
        catch(Exception e)
        {
          //Json化に失敗: 装置オプションが存在しないものがある
          // 処理を継続。次のレコードへ進む
          continue;
        }

        // 指定タグのオプション値の取得

        tmpStr = "" ;   //念の為、一時変数を初期化(修正が入った場合を考慮)
        if(objJson.has(keyName))
        {
          //キーが有ったのでオプションの確認
          try {
            tmpStr = objJson.get(keyName).toString() ;
            // 1を有効とする(文字列比較)
            if (null != tmpStr && tmpStr.equals(CommonIndConst.SETTING_ON.get()))
            {
                // 有効な装置が存在した
                ret = true ;        //有効
                return ret;
            }
          }
          catch(Exception e)
          {
            //文字列化できなかったなど、キー項目が取得できなかったので次へ進む
            continue;
          }
        }

    }
    return ret ;
  }

  /**
   * 装置設定取得処理
   * ord_main,pat_mainから装置設定情報を取得する
   * ord_mainを経由(等価Join:施設コード＆患者ID)して取得
   * @param ordNo オーダー番号：抽出キー
   * @return    取得した値　<PARAMKEY,value>
   *         PARAMKEY.
   */
  private HashMap<PARAMKEY,Object> getMachineSetting(
        String ordNo
      )
  {
    //戻り値
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    try {
      //DBからのデータ取得
      List<Map<String,Object>> list = webAPICheckConditionSendService.getMachineSetting(Long.parseLong(ordNo)) ;

      //SELECT結果の受け取り
      if(null != list && 1 == list.size())
      {
        //Jsonデータを受け取るためにいったんPGobjectで受けます
        String pgDev = list.get(0).get(PARAMKEY.DEV.get()).toString();
        //PGobjectの値(String)をJSONObject化します
        JSONObject devJson = null ;
        if("null".compareTo(pgDev) != 0)
        {
          devJson = new JSONObject(pgDev) ;
        }
        //返却値の格納
        retVal.put(PARAMKEY.DEV, devJson);

        //Jsonデータを受け取るためにいったんPGobjectで受けます
        PGobject pgPat = (PGobject)list.get(0).get(PARAMKEY.PAT.get());
        if(null != pgPat)
        {
          devJson = new JSONObject(pgPat.getValue()) ;
        }
        //返却値の格納
        retVal.put(PARAMKEY.PAT, devJson);
      }
      else
      {
        //データがなかった
        retVal = null ;
      }
    }
    catch(Exception e)
    {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      retVal = null ;
    }

    return retVal ;

  }

  /**
   * 患者基本情報取得処理
   * 患者基本情報から情報(dw)を取得する
   * @param patId患者ID：抽出キー
   * @return    取得した値　<PARAMKEY,value>
   *         PARAMKEY.dw
   */
  private HashMap<PARAMKEY,Object> getDataFromPatUnique(
        String patId
      )
  {
    //戻り値
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;
    try {
      //DBからのデータ取得
      List<PatUnique> list = webAPICheckConditionSendService.getDataFromPatUnique(Long.parseLong(patId)) ;

      //SELECT結果の受け取り
      if(null != list && 1 == list.size())
      {
        //身体情報の取得＆格納
        String physicalInfoJson = list.get(0).getPhysical_info();
        //PGobjectの値(String)をJSONObject化します
        JSONArray physicalInfoJsonArray = null ;
        Double dwDbl = null ;
        if(null != physicalInfoJson)
        {
          //JsonArray化
          physicalInfoJsonArray = new JSONArray(physicalInfoJson);

          //並べ替え(検査日時:降順)

          String sortKey = PARAMKEY.EXAM_DATE.get();

          //JSONArrayをList<JSONObject>化
          List<JSONObject> jsonList = new ArrayList<JSONObject>();
          for (int i = 0; i < physicalInfoJsonArray.length(); i++) {
              jsonList.add(physicalInfoJsonArray.getJSONObject(i));
          }

          //検査日時:降順に並べ替え(要素0が検査日時最新のデータという並び)
            jsonList.sort(
                (s1,s2)
                ->
                    compareDateLong(
                        getValueFromJson(s2,sortKey),
                        getValueFromJson(s1,sortKey)
                      )
            );

          //取得対象
          String key = PARAMKEY.DW.get() ;

          //要素0～確認して、値があればその値を採用(最新の有効データを採用)
          for(int i = 0 ; i < jsonList.size() ; i++)
          {
            JSONObject tmpObj = jsonList.get(i) ;
            dwDbl = null ;
            //キーが有るかの確認
            if(tmpObj.has(key))
            {
              //キーが有った場合、値が数値かを確認する
              Object value =  tmpObj.get(key) ;
              try {
                //Doubleに変換してみる
                dwDbl = Double.valueOf(String.valueOf(value)) ;
              }
              catch(Exception e)
              {
                // 変換できなかったので次のデータの確認
                continue ;
              }
              //値が確定したので ループ終了
              break ;
            }
          }
        }
        //返却値の格納
        if(null != dwDbl)
        {
          //見つかった
          retVal.put(PARAMKEY.DW, dwDbl);
        }
        else
        {
          //見つからなかった
          retVal = null ;
        }
      }
      else
      {
        //データがなかった
        retVal = null ;
      }
    }
    catch(Exception e)
    {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      retVal = null ;
    }

    return retVal ;
  }

  /**
   * ISO8601日付の比較
   * 入力日付のフォーマットは、yyyy-MM-dd'T'HH:mm:ssX
   * @param s1  比較1
   * @param s2  比較2
   * @return
   *   s1 == s2 の場合は値0
   *   s1 <  s2 の場合は0より小さい値
   *   s1 >  s2 の場合は0より大きい値
   */
  private int compareDateLong(Object s1,Object s2)
  {
    String targetDate1 = null ;
    String targetDate2 = null ;

    final String format = "yyyy-MM-dd'T'HH:mm:ssXXX" ;

    try {
      //時間をlong値に変換
      String date1 = s1.toString();
      String date2 = s2.toString();
      Pattern pattern = Pattern.compile("T");
      Matcher matcher1 = pattern.matcher(date1);
      Matcher matcher2 = pattern.matcher(date2);

      String formatDate1 = matcher1.find() ? date1 : date1 + "T00:00:00+09:00";
      String formatDate2 = matcher2.find() ? date2 : date2 + "T00:00:00+09:00";

      DateTimeFormatter f = DateTimeFormatter.ofPattern(format);
      LocalDateTime d1 = LocalDateTime.parse(formatDate1, f);
      LocalDateTime d2 = LocalDateTime.parse(formatDate2, f);

      DateTimeFormatter ff = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
      targetDate1 = d1.format(ff);
      targetDate2 = d2.format(ff);
    }
    catch(Exception e)
    {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }


    return targetDate1.compareTo(targetDate2);
  }


  /**
   * JSONObjectからの値の取得処理
   * 値が取得できない場合(キーが存在しないなど)はnullを返却する
   * @param jObj jsonオブジェクト
   * @param key  キー
   * @return 取得した値(キーが存在しない場合null)
   */
  private Object getValueFromJson(JSONObject jObj,String key)
  {
    Object ret = null ;

    try {
      //Jsonからキーを元に取得
      ret = jObj.get(key) ;
    }
    catch(Exception e)
    {
      //例外が発生したので、戻り値をnullに設定
      ret = null ;
    }
    return ret ;
  }

  /**
   * 装置モード取得処理
   * 治療方法マスタから情報を取得する
   * ord_mainを経由(等価Join:施設コード＆治療方法コード)して取得
   * @param ordNo オーダー番号
   * @return    取得した値　<PARAMKEY,value>
   *         PARAMKEY.DEVICE_MODE:装置モード
   */
  private String getDeviceModeFromMstTreatment(
        String ordNo
      )
  {
    //戻り値
    String retDeviceMode = null ;

    //データ抽出
    try {
      //DBからのデータ取得
      List<String> list = webAPICheckConditionSendService.getDeviceModeFromMstTreatment(Long.parseLong(ordNo)) ;

      //SELECT結果の受け取り
      if(null != list && 1 == list.size())
      {
        retDeviceMode = list.get(0);
      }
      else
      {
        //データがなかった
        retDeviceMode = null ;
      }
    }
    catch(Exception e)
    {
      EventLogMessage eventLogMessage = new EventLogMessage();
  	  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      retDeviceMode = null ;
    }
    return retDeviceMode ;
  }

  /**
   * 通信フォーマット取得処理
   * 装置マスタから情報を取得する ※取得条件が変わるかもしれない(2018/10/03)
   * ord_mainとベッドマスタを経由(等価Join:施設コード＆ベッドコード)して取得(等価Join:施設コード＆装置番号)
   * @param ordNo オーダー番号
   * @return    取得した値　<PARAMKEY,value>
   *         PARAMKEY.MACHINE_NO:装置番号
   *         PARAMKEY.DEV_COM_FORMAT_CD:通信フォーマット
   *         PARAMKEY.MACHINE_OPTION:装置オプション(Json)
   */
  private HashMap<PARAMKEY,Object> getDataFromMstMachine(
        String ordNo
      )
  {
    //戻り値
    HashMap<PARAMKEY,Object> retVal = new HashMap<>() ;

    String result = null ;

    //データ抽出
    try {
      //DBからのデータ取得
      List<Map<String,Object>> list = webAPICheckConditionSendService.getDataFromMstMachine(Long.parseLong(ordNo)) ;

      //SELECT結果の受け取り
      if(null != list && 1 == list.size())
      {
        //装置オプションの取得＆格納
        dbgPrint("machine_option:" + list.get(0).get(PARAMKEY.MACHINE_OPTION.get())) ;
        //Jsonデータを受け取るためにいったんPGobjectで受けます
        PGobject pgMachineOption = (PGobject)list.get(0).get(PARAMKEY.MACHINE_OPTION.get());
        //PGobjectの値(String)をJSONObject化します
        JSONObject machineOption = null ;
        if(null != pgMachineOption)
        {
          machineOption = new JSONObject(pgMachineOption.getValue());
        }
        retVal.put(PARAMKEY.MACHINE_OPTION, machineOption);

        //装置番号の取得＆格納

        Object tmpObj = list.get(0).get(PARAMKEY.MACHINE_NO.get()) ;
        result =  null == tmpObj ? null : String.valueOf(tmpObj) ;
        retVal.put(PARAMKEY.MACHINE_NO, result);

        //通信フォーマットの取得＆格納
        tmpObj = list.get(0).get(PARAMKEY.COM_FORMAT_CD.get()) ;
        result = null == tmpObj ? null : String.valueOf(tmpObj) ;
        retVal.put(PARAMKEY.COM_FORMAT_CD, result);
        // TMPゼロ補正警報中点HD
        result = String.valueOf(list.get(0).get(PARAMKEY.TMP_CENTER_HD.get())) ;
        retVal.put(PARAMKEY.TMP_CENTER_HD, result);
        // TMPゼロ補正警報中点ECUM
        result = String.valueOf(list.get(0).get(PARAMKEY.TMP_CENTER_ECUM.get())) ;
        retVal.put(PARAMKEY.TMP_CENTER_ECUM, result);
        // TMPゼロ補正警報中点HDF
        result = String.valueOf(list.get(0).get(PARAMKEY.TMP_CENTER_HDF.get())) ;
        retVal.put(PARAMKEY.TMP_CENTER_HDF, result);
        // TMPゼロ補正警報中点HF
        result = String.valueOf(list.get(0).get(PARAMKEY.TMP_CENTER_HF.get())) ;
        retVal.put(PARAMKEY.TMP_CENTER_HF, result);
        //TMP初期補正中点（HD+補液）
        result = String.valueOf(list.get(0).get(PARAMKEY.TMP_CENTER_HD_HO.get())) ;
        retVal.put(PARAMKEY.TMP_CENTER_HD_HO, result);
        //TMP初期補正中点（OHF）
        result = String.valueOf(list.get(0).get(PARAMKEY.TMP_CENTER_OHF.get())) ;
        retVal.put(PARAMKEY.TMP_CENTER_OHF, result);
        //TMP初期補正中点（OHDF）
        result = String.valueOf(list.get(0).get(PARAMKEY.TMP_CENTER_OHDF.get())) ;
        retVal.put(PARAMKEY.TMP_CENTER_OHDF, result);
      }
      else
      {
        //データがなかった
        retVal = null ;
      }
    }
    catch(Exception e)
    {
      EventLogMessage eventLogMessage = new EventLogMessage();
  	  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      retVal = null ;
    }

    return retVal ;

  }

  /**
   * 条件指示からのデータ取得処理
   * 条件指示の構造は、以下
   * ['1':{'value':'2.3',...},'2':{'value':'2.5'...},{},{},{}.......,{}]
   * @param jsonObjArray
   * @param key
   * @return
   */
  private String getDataFromIndCond(
        JSONObject jsonObj,
        String key
      )
  {
    String ret = null ;

    try {
      ret = String.valueOf(jsonObj.getJSONObject(key).get("value")) ;
      if("null".equals(ret))
      {
        ret = null;
      }
    }
    catch(Exception e)
    {
      //想定されたエラーでハンドリング:JSONパース or nullpointer
      ret = null ;
    }

    //================================

    return ret ;
  }

  /**
   * Jsonデータの設定処理
   * Ｊｓｏｎデータに値を設定する。
   * @param jsonObj     Jsonデータ
   * @param key         キー
   * @param value       値
   */
  private void setDataToJson(JSONObject jsonObj,String key,String value)
  {

    try {
      jsonObj.put(key,value) ;
    }
    catch(Exception e)
    {
      EventLogMessage eventLogMessage = new EventLogMessage();
  	  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }


  /**
   * Jsonオブジェクトからの値取得処理
   * @param jsonObj　JSONオブジェクト
   * @param key     キー
   * @return    取得した値(値がない場合null)
   */
  private Object getDataFromJSON(JSONObject jsonObj ,String key)
  {
    Object retObj = null ;

    try {
      //キーに対応する値を取得
      retObj = jsonObj.get(key) ;
    }
    catch(Exception e)
    {//取得に失敗したらnullを返す
      retObj = null ;
    }

    return retObj ;
  }



//  /**
//   * Json要素のコピー処理
//   * @param to      コピー先
//   * @param from    コピー元
//   * @param surfix  キー接尾辞(コピー時にキーの後ろに付加する。nullの場合、なにもしない）
//   * @param key     キー名
//   */
//  private void setJsonData(JSONObject to,JSONObject from,String surfix,String key)
//  {
//    //接尾辞の判定
//    String surfixStr =  surfix == null ? "" : surfix ;
//    try {
//      //要素のコピー
//      to.put(key+surfixStr, from.getString(key)) ;
//      dbgPrint("key:"+key+" from.getString(key):" + from.getString(key)) ;
//    }
//    catch(Exception e)
//    {
//    }
//  }

  /**
   * 上下限チェック
   * @param list    List<String> チェック対象の数値文字列リスト
   * @param max     範囲最大値
   * @param min     範囲最小値
   * @return    true:list内のすべての値がminとmaxの間　false:list内にminとmaxの範囲外の値があった。nullの値があった。
   */
  private boolean checkMaxMinLimit(
      List<String> list,
      Double max,
      Double min
      )
  {
    boolean ret = true ;

    Double tmpValue = 0.0 ;

    //要素数分のループ
    for (int i = 0 ; i < list.size() ; i++) {
      try {
        //数値のダブル化
        tmpValue = Double.parseDouble(list.get(i)) ;
      }
      catch(Exception e)
      {//ダブル変換できなかったのでエラー終了
        ret = false ;
        break ;
      }

      //値の範囲チェック
      if(tmpValue < min || tmpValue > max)
      {//上限、下限の範囲外だったので処理終了
        ret = false ;
        break ;
      }
    }

    return ret ;
  }


  /**
   * 受信データ取得処理
   * ボディで送られてきたJSONデータを分解取得する
   * @param bodydata    送信されてきたデータ
   * @param retVal      <PARAMKEY:Object>　返却値
   *                PARAMKEY.RECEIVE_DATA   送信データ(JSON)
   * @return    true:成功　false：失敗
   */
  private boolean getDataFromBodyData(
      String bodydata,
      HashMap<PARAMKEY,Object> retVal
    )
  {
    boolean ret = true ;
    HttpStatus status = HttpStatus.OK; ;
    String retMsg = "", retLogMsg = "";
    JSONObject receiveData = null ;

    //受信パラメータのＪＳＯＮ化
    try {
      receiveData= new JSONObject(bodydata) ;
    }
    catch(JSONException e)
    {
      //ＪＳＯＮパースに失敗
      status = HttpStatus.INTERNAL_SERVER_ERROR ;
      retMsg = String.format(CHECKMESSAGE.MSG000030.get(), e.getMessage()) ;
      retLogMsg = String.format(CHECKMESSAGE.MSG000030LOG.get(), e.getMessage()) ;
      ServerMainlogWriterRapper(LOGLEVEL.DEBUG,"retLogMsg:" +retLogMsg);
      ret = false ;
    }
    finally {
      retVal.put(PARAMKEY.STATUS, status) ;
      retVal.put(PARAMKEY.MSG, retMsg);
      retVal.put(PARAMKEY.ERRMSG, retLogMsg) ;
      retVal.put(PARAMKEY.RECEIVE_DATA, receiveData) ;
    }

    return ret ;
  }


//  /**
//   * データ取得処理
//   * JSONObjectからキー情報を元に対応する値を取得する。
//   * @param tmpDatasource   JsonObject
//   * @param key             キー情報
//   * @return    キー情報に対応する値(値が存在しない、キーが存在しない場合はnull)
//   */
//  private String getDataFromJSONObject(
//          JSONObject tmpDatasource,
//          String key
//      )
//  {
//    String ret = null ;
//    String tmpDatavalue = null ;
//
//    try {
//      //一時データの設定値の取得
//      tmpDatavalue = tmpDatasource.getString(key) ;
//
//      if(null == tmpDatavalue || 0 == tmpDatavalue.length())
//      {//データがなかった　or 空文字だった
//        ret = null ;
//      }
//      else
//      {//戻り値に取得値をセットする。
//        ret = tmpDatavalue ;
//      }
//    }
//    catch(JSONException e)
//    {
//      ret = null ;
//    }
//
//    return ret ;
//  }


  /**
   * ログレベル
   *
   */
  private enum LOGLEVEL {
    INFO,
    DEBUG,
    TRACE,
    WARN,
    ERROR,
    FATAL
  }

  /**
   * ログ出力ラッパー
   * @param loglevel    ログレベル   ※enum LOGLEVEL参照
   * @param logFormat   ログフォーマット（メッセージ）
   * @param args        ログフォーマットの穴埋めパラメーター（可変）
   * @return
   */
  private void ServerMainlogWriterRapper(LOGLEVEL loglevel,String logFormat,Object... args) {

    //ロガー
    Logger logger = LoggerFactory.getLogger(WebAPICheckConditionSend.class);


    //メッセージの組み立て
    String logmsg ;
    try {
        logmsg = String.format(logFormat, args) ;
    }
    catch(MissingFormatArgumentException e)
    {
      //引数が合わなかったときなどは、そのまま出力
      logmsg = "log format error!!:" + logFormat ;

      //引数があったら、メッセージの後に連結します
      if(args != null && args.length > 0) {
        for(Object obj:args)
        {
          logmsg += ":" + obj ;
        }
      }
    }

    //ログレベルによる場合分け
    switch(loglevel) {
      case INFO:
        logger.info(logmsg);
        break ;
      case DEBUG:
        logger.debug(logmsg);
        break ;
      case TRACE:
        logger.trace(logmsg);
        break ;
      case WARN:
        logger.warn(logmsg);
        break ;
      case ERROR:
        logger.error(logmsg);
        break ;
      default:
        logger.debug(logmsg);
    }
  }

  /**
   * デバッグ用
   * @param strMsg
   */
  private void dbgPrint(String strMsg)
  {
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(strMsg);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
  }

  public Map<String,Object> getTmpDviceSetInfo(
      Long ord_no
  )
  {
    Boolean ret = true ;
    String msg = "", logMsg = "" ;

    Map<String,Object> retMap = new HashMap<String,Object>() ;
    HashMap<PARAMKEY,Object> retVal = new HashMap<>();
    String bodyData = "{ordNo:\""+ord_no+"\"}" ;

    try {
      //メソッド呼び出し
      String response = mainProcess(bodyData, retVal);

      JSONObject json = new JSONObject(response);
      retMap.put("ordNo", json.getLong("ordNo"));
      retMap.put("tmpDeviceSetInfo", json.getJSONObject("tmpDeviceSetInfo"));
      retMap.put("msg", json.getString("retMsg"));
      if (json.has("retLogMsg")) {
        retMap.put("logMsg", json.getString("retLogMsg"));
      } else {
        retMap.put("logMsg", json.getString("retMsg"));
      }
    }
    catch(JSONException e)
    {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("条件送信tmpDeviceSetInfo作成失敗");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      msg = "条件作成失敗";
      ret = false ;
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage = new EventLogMessage();
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

    }
    catch(Exception e)
    {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("条件送信tmpDeviceSetInfo作成失敗");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      msg = "条件作成失敗";
      logMsg = e.getMessage();
      ret = false ;
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage = new EventLogMessage();
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
    }

    if (retVal.containsKey(PARAMKEY.RET_LOG_MSG)) {
      String retMsg = retVal.get(PARAMKEY.RET_LOG_MSG).toString() ;
      EventLogMessage eventLogMessage = new EventLogMessage();
  	  eventLogMessage.setLogMessage(retMsg);
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }


    //戻り値の組み立て
    retMap.put("ret", ret);
    retMap.put("msg", msg);
    retMap.put("logMsg", logMsg);

    return retMap ;
  }

  private void setAveDate(JSONObject list, List<Integer> setlist, Integer startStep, Integer endStep) {
    for (Integer i = startStep; i <= endStep; i++) {
      String number = String.valueOf(i);
      Integer value = Integer.parseInt(list.get(number).toString());
      setlist.add(value);
    }
  }

  private Double getAverageFlow(List<Integer> flowArray, List<Integer> changeoverTimeList, Integer maxStep, Integer time) {
    Double dialysisTime = Double.parseDouble(time.toString());
    // 経過流量合計：[流量1×切替時間1]＋[流量2×切替時間2]＋・・・
    int progressFlowSum = 0;
    // 切替時間合計
    Double changeoverTimeSum = Double.parseDouble("0");
    // 最終流量
    Double lastFlow = null;
    // 最終ステップ数を取得
    int stepNumber = maxStep - 1;

    // 経過流量合計と最終流量と切替時間合計を設定
    for (int i = 0; i < flowArray.size(); i++) {
      if (i < stepNumber) {
        // ステップ数を超えるまで流量と切替時間を設定
        Double flow = Double.parseDouble(flowArray.get(i).toString());
        Integer changeoverTime = changeoverTimeList.get(i);

        if (changeoverTimeSum.compareTo(dialysisTime) < 0 ) {
          // 透析時間を超えるまで経過流量合計と切替時間合計を計算
          progressFlowSum += flow * changeoverTime;
          changeoverTimeSum += changeoverTime;
        } else if (changeoverTimeSum.compareTo(dialysisTime) == 0) {
          // 切替時間合計と透析時間が同じ場合：最終流量
          lastFlow = flow;
          break;
        } else {
          // 切替時間合計が透析時間を超えた場合：1つ前が最終流量
          lastFlow = Double.parseDouble(flowArray.get(i - 1).toString());
          break;
        }
      } else if (i == stepNumber) {
        if (changeoverTimeSum >= dialysisTime) {
          // 切替時間合計が透析時間以上だった場合：1つ前が最終流量
          lastFlow = Double.parseDouble(flowArray.get(i - 1).toString());
        } else {
          // ステップ数が最終流量
          lastFlow = Double.parseDouble(flowArray.get(i).toString());
        }
      }
    }

    // 計算式： {経過流量合計＋[流量最終×(透析時間－切替時間合計)]} / 透析時間
    Double averageFlow =
      (progressFlowSum + lastFlow * (dialysisTime - changeoverTimeSum)) /
      dialysisTime;

    return averageFlow;
  }

  // 透析後体重(kg)
  // 透析時間(min)
  // 透析前 BUN(mg/dL)
  // 透析後 BUN(mg/dL)
  // 除水の総量(L)
  // 血液量(ml/min)
  // 透析液流量(ml/min)
  // KoA(ml/min)
  private Double getBodyLiqCalc(
      Double BW,
      Double dialysisTime,
      Double BUN1,
      Double BUN2,
      Double DBWX,
      Double QB,
      Double QD,
      Double KOA0
      ) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("体液量+補正値:計算値パラメータ");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("透析後体重:" + BW);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("透析時間:" + dialysisTime);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("透析前BUN:" + BUN1);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("透析後BUN:" + BUN2);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("除水の総量:" + DBWX);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("血液量:" + QB);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("透析液流量:" + QD);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("KoA:" + KOA0);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    if (
      BW == null ||
      dialysisTime == null ||
      BUN1 == null ||
      BUN2 == null ||
      DBWX == null ||
      QB == null ||
      QD == null ||
      KOA0 == null
      ) {
      return null;
    }

    // 再循環率(%)※固定値
    int RR = 0;
    Double TX = Double.parseDouble(dialysisTime.toString());

    Double calValue = null;
    int calRound = 0;

    Double R = BUN2 / BUN1;
    Double KOA = (-1.1985 + 0.81572 * 0.4343 * Math.log(QD)) * KOA0;
    RR = RR / 100;
    Double KTVU =
      -Math.log(R - (0.008 * TX) / 60) + ((4 - 3.5 * R) * DBWX) / BW;
    Double K1 = KTVU / TX;
    Double VW = BW * 400;

    for (;;) {
      // 無限ループ防止のため最大計算回数で制限
      int MAX_CALC_ROUND = 100000;
      if (MAX_CALC_ROUND < ++calRound) {
        // 失敗
        return null;
      }

      Double DBW = DBWX / VW;
      Double P1 =
        0.8306 * Math.pow(10, 10) * Math.pow(DBW, 2) -
        0.1118 * Math.pow(10, 7) * DBW -
        0.0834 * Math.pow(10, 4);
      Double P2 =
        -2.2858 * Math.pow(10, 8) * Math.pow(DBW, 2) +
        1.09 * Math.pow(10, 5) * DBW +
        0.2607 * Math.pow(10, 2);
      Double P3 =
        0.96 * Math.pow(10, 6) * Math.pow(DBW, 2) -
        1.2556 * Math.pow(10, 3) * DBW -
        0.1732;
      Double P4 =
        0.1248 * Math.pow(10, 4) * Math.pow(DBW, 2) -
        0.0728 * 10 * DBW -
        0.0076 * Math.pow(10, -2);
      Double K2 =
        K1 + P1 * Math.pow(K1, 3) + P2 * Math.pow(K1, 2) + P3 * K1 + P4;
      Double K21 = K2 * VW;
      Double K22 = ((1 - RR) * K21) / (1 - RR - (RR * K21) / QB);
      Double AA = 1 - Math.exp(KOA * (1 / QB - 1 / QD));
      Double BB = 1 / QD - (1 / QB) * Math.exp(KOA * (1 / QB - 1 / QD));
      Double K = AA / BB;
      Double D = K22 - K;

      if (D >= 0) {
        calValue = VW;
        return calValue;
      }

      VW = VW + 20;
      continue;
    }
  }

  // TX： 透析時間(min)
  // QB： 血液量(ml/min)
  // KOA0： KoA(ml/min)
  // VWa： 体液量 補正値(ml)
  // BWa： 透析後体重(kg)
  // BW2： 目標透析終了時体重(kg)
  // DBWX： 除水量(kg)
  private Map<String, Double> getKtOverVUpperAndUnderLimitInfo(
      Integer time,
      Double aveBloodVol,
      Double koA,
      Double calc,
      Double weightAfter,
      Double targetWeightAfter,
      Double addTotal
      ) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("Kt/V上下限:計算値パラメータ");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("透析時間:" + time);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("血液量:" + aveBloodVol);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("KoA:" + koA);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("体液量+補正値:" + calc);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("透析後体重:" + weightAfter);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("目標透析終了時体重:" + targetWeightAfter);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage("除水量:" + addTotal);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    if (
      time == null ||
      aveBloodVol == null ||
      koA == null ||
      calc == null ||
      weightAfter == null ||
      targetWeightAfter == null ||
      addTotal == null
      ) {
      return null;
    }
    Double dialysisTime = Double.parseDouble(time.toString());
    Double UpperLimit = Double.parseDouble("700");
    Double UnderLimit = Double.parseDouble("300");
    Double RR = Double.parseDouble("0");
    Double ktOverVUpperLimit = getKtOverVUpperLimit(UpperLimit, dialysisTime, aveBloodVol, RR, koA, calc, weightAfter, targetWeightAfter, addTotal);
    Double ktOverVUnderLimit = getKtOverVUnderLimit(UnderLimit, dialysisTime, aveBloodVol, RR, koA, calc, weightAfter, targetWeightAfter, addTotal);
    if (ktOverVUpperLimit == null || ktOverVUnderLimit == null) {
      return null;
    }
    Map<String, Double> mapInfo = new HashMap<>();
    mapInfo.put("ktOverVUpperLimit", ktOverVUpperLimit);
    mapInfo.put("ktOverVUnderLimit", ktOverVUnderLimit);

    return mapInfo;
  }

  // QD： 可能なKtV上限値※固定値
  // TX： 透析時間(min)
  // QB： 血液量(ml/min)
  // RR： 再循環率(%)※固定値
  // KOA0： KoA(ml/min)
  // VWa： 体液量 補正値(ml)
  // BWa： 透析後体重(kg)
  // BW2： 目標透析終了時体重(kg)
  // DBWX： 除水量(kg)
  private Double getKtOverVUpperLimit(Double QD, Double TX, Double QB, Double RR, Double KOA0, Double VWa, Double BWa, Double BW2, Double DBWX) {
    Double maxCalKtv = null;

    Integer calRound = 0;

    Double DD = Double.parseDouble("0");
    Integer N = 0;

    RR = RR / 100;

    Double VWX = VWa + (BW2 - BWa) * 1000;
    Double DBW = DBWX / VWX;

    if (QB.equals(QD)) {
      QD = QB + 10;
    }

    Double KOA = (-1.1985 + 0.81572 * 0.4343 * Math.log(QD)) * KOA0;
    Double AA = 1 - Math.exp(KOA * (1 / QB - 1 / QD));
    Double BB = 1 / QD - (1 / QB) * Math.exp(KOA * (1 / QB - 1 / QD));
    Double K22 = AA / BB;
    Double K21 = (K22 * (1 - RR - (RR * K22) / QB)) / (1 - RR);
    Double K2 = K21 / VWX;
    Double KTVX = 1.5;

    for (;;) {
      // goto360:
      // 無限ループ防止のため最大計算回数で制限
      Integer MAX_CALC_ROUND = 100000;
      if (MAX_CALC_ROUND < ++calRound) {
        // 失敗
        return null;
      }

      Double K1X = KTVX / TX;
      Double P1 =
        0.8306 * Math.pow(10, 10) * Math.pow(DBW, 2) -
        0.1118 * Math.pow(10, 7) * DBW -
        0.0834 * Math.pow(10, 4);
      Double P2 =
        -2.2858 * Math.pow(10, 8) * Math.pow(DBW, 2) +
        1.09 * Math.pow(10, 5) * DBW +
        0.2607 * Math.pow(10, 2);
      Double P3 =
        0.96 * Math.pow(10, 6) * Math.pow(DBW, 2) -
        1.2556 * Math.pow(10, 3) * DBW -
        0.1732;
      Double P4 =
        0.1248 * Math.pow(10, 4) * Math.pow(DBW, 2) -
        0.0728 * 10 * DBW -
        0.0076 * Math.pow(10, -2);
      Double K2X =
        K1X + P1 * Math.pow(K1X, 3) + P2 * Math.pow(K1X, 2) + P3 * K1X + P4;

      if (N != 99999) {
        DD = K2 - K2X;
        N = 99999;
      }

      Double D = K2 - K2X;
      if (DD > 0) {
        if (D < 0) {
          maxCalKtv = KTVX - 0.01;
          return maxCalKtv;
        }

        KTVX = KTVX + 0.01;
        continue;
      } else if (DD < 0) {
        if (D > 0) {
          maxCalKtv = KTVX - 0.01;
          return maxCalKtv;
        }

        KTVX = KTVX - 0.01;
        continue;
      } else if (DD == 0) {
        maxCalKtv = KTVX - 0.01;
        return maxCalKtv;
      }

      if (D < 0) {
        maxCalKtv = KTVX - 0.01;
        return maxCalKtv;
      }

      KTVX = KTVX + 0.01;
      continue;
    }
  }

  private Double getKtOverVUnderLimit(Double QD, Double TX, Double QB, Double RR, Double KOA0, Double VWa, Double BWa, Double BW2, Double DBWX) {
    Double minCalKtv = null;

    Integer calRound = 0;
    Double DD = Double.parseDouble("0");
    Integer N = 0;

    RR = RR / 100;

    Double VWX = VWa + (BW2 - BWa) * 1000;
    Double DBW = DBWX / VWX;
    if (QB.equals(QD)) {
      QD = QB + 10;
    }

    Double KOA = (-1.1985 + 0.81572 * 0.4343 * Math.log(QD)) * KOA0;
    Double AA = 1 - Math.exp(KOA * (1 / QB - 1 / QD));
    Double BB = 1 / QD - (1 / QB) * Math.exp(KOA * (1 / QB - 1 / QD));
    Double K22 = AA / BB;
    Double K21 = (K22 * (1 - RR - (RR * K22) / QB)) / (1 - RR);
    Double K2 = K21 / VWX;
    Double KTVX = 1.2;

    for (;;) {
      // 無限ループ防止のため最大計算回数で制限
      Integer MAX_CALC_ROUND = 100000;
      if (MAX_CALC_ROUND < ++calRound) {
        // 失敗
        return null;
      }

      Double K1X = KTVX / TX;
      Double P1 =
        0.8306 * Math.pow(10, 10) * Math.pow(DBW, 2) -
        0.1118 * Math.pow(10, 7) * DBW -
        0.0834 * Math.pow(10, 4);
      Double P2 =
        -2.2858 * Math.pow(10, 8) * Math.pow(DBW, 2) +
        1.09 * Math.pow(10, 5) * DBW +
        0.2607 * Math.pow(10, 2);
      Double P3 =
        0.96 * Math.pow(10, 6) * Math.pow(DBW, 2) -
        1.2556 * Math.pow(10, 3) * DBW -
        0.1732;
      Double P4 =
        0.1248 * Math.pow(10, 4) * Math.pow(DBW, 2) -
        0.0728 * 10 * DBW -
        0.0076 * Math.pow(10, -2);
      Double K2X =
        K1X + P1 * Math.pow(K1X, 3) + P2 * Math.pow(K1X, 2) + P3 * K1X + P4;

      if (N != 99999) {
        DD = K2 - K2X;
        N = 99999;
      }

      Double D = K2 - K2X;
      if (DD > 0) {
        if (D < 0) {
          minCalKtv = KTVX + 0.01;
          return minCalKtv;
        }

        KTVX = KTVX + 0.01;
        continue;
      } else if (DD < 0) {
        if (D > 0) {
          minCalKtv = KTVX + 0.01;
          return minCalKtv;
        }

        KTVX = KTVX - 0.01;
        continue;
      } else if (DD == 0) {
        minCalKtv = KTVX + 0.01;
        return minCalKtv;
      }

      if (D < 0) {
        minCalKtv = KTVX + 0.01;
        return minCalKtv;
      }

      KTVX = KTVX + 0.01;
      continue;
    }
  }

  private Integer getDialysisTime(String rstCondInfo) {
    if (rstCondInfo != null) {
      JSONObject jsonRstCondInfo = new JSONObject(rstCondInfo);
      if (jsonRstCondInfo.has("1")) {
        JSONObject rstCondInfo_1 = new JSONObject(jsonRstCondInfo.get("1").toString());
        if (rstCondInfo_1.get("value") == null) {
          return null;
        }
        return Integer.parseInt(rstCondInfo_1.get("value").toString());
      }
    }
    return null;
  }

  private Double getTargetWeightAfter(String rstCondInfo) {
    if (rstCondInfo != null) {
      JSONObject jsonRstCondInfo = new JSONObject(rstCondInfo);
      if (jsonRstCondInfo.has("3")) {
        JSONObject rstCondInfo_3 = new JSONObject(jsonRstCondInfo.get("3").toString());
        if (rstCondInfo_3.get("value") == null) {
          return null;
        }
        return Double.parseDouble(rstCondInfo_3.get("value").toString());
      }
    }
    return null;
  }

  private Double getKoA(String rstCondInfo) {
    if (rstCondInfo != null) {
      JSONObject jsonRstCondInfo = new JSONObject(rstCondInfo);
      if (jsonRstCondInfo.has("5")) {
        JSONObject rstCondInfo_1 = new JSONObject(jsonRstCondInfo.get("5").toString());
        Integer dialyzerCd = Integer.parseInt(rstCondInfo_1.get("value").toString());
        //DBからのデータ取得
        MstDialyzer mstDialyzer = webAPICheckConditionSendService.getDialyzerInfoFromDialyzer(Integer.valueOf(dialyzerCd));
        return mstDialyzer.getKoa();
      }
    }
    return null;
  }

  private Double getAveBloodVol(String rstCondInfo) {
    if (rstCondInfo != null) {
      JSONObject jsonRstCondInfo = new JSONObject(rstCondInfo);
      if (jsonRstCondInfo.has("14")) {
        JSONObject rstCondInfo_14 = new JSONObject(jsonRstCondInfo.get("14").toString());
        if (rstCondInfo_14.get("value") == null) {
          return null;
        }
        return Double.parseDouble(rstCondInfo_14.get("value").toString());
      }
    }
    return null;
  }

  private Double getAveDialysisFlow(String rstCondInfo) {
    if (rstCondInfo != null) {
      JSONObject jsonRstCondInfo = new JSONObject(rstCondInfo);
      if (jsonRstCondInfo.has("16")) {
        JSONObject rstCondInfo_16 = new JSONObject(jsonRstCondInfo.get("16").toString());
        if (rstCondInfo_16.get("value") == null) {
          return null;
        }
        return Double.parseDouble(rstCondInfo_16.get("value").toString());
      }
    }
    return null;
  }

  private JSONObject getQbQd(String rstDeviceSetInfo) {
    JSONObject info = null;
    try {
      JSONObject jsonRstDeviceSetInfo = new JSONObject(rstDeviceSetInfo);
      JSONObject qbqd = new JSONObject(jsonRstDeviceSetInfo.get("qbqd").toString());
      JSONObject dev = new JSONObject(qbqd.get("dev").toString());
      info = new JSONObject(dev.get("A").toString());
    } catch(Exception e) {
      return null;
    }
    return info;
  }

  /**
   * 除水量計算値の算出
   * @param rstWeightInfo 体重実績（前体重取得用）
   * @param indCondInfo 指示（目標体重取得用）
   * @param dw DW
   * @param offWaterTotal 除水補正値合計（グラム）
   * @return
   */
  private BigDecimal calcOffWaterCalc(JSONObject rstWeightInfo, JSONObject indCondInfo, String dw, long offWaterTotal) {

    // 前体重
    String beforeWeightStr = String.valueOf(getDataFromJSON(rstWeightInfo, PARAMKEY.RST_WEIGHT_BEFORE.get()));
    if (Objects.isNull(beforeWeightStr) || beforeWeightStr.isEmpty() || Objects.equals(beforeWeightStr, "null")) {
      // 前体重取得失敗
      return null;
    }
    BigDecimal beforeWeight = new BigDecimal(beforeWeightStr);

    // 目標体重
    String targetWeightStr = getDataFromIndCond(indCondInfo, DialysisCond.COND_TW.get());
    // 目標体重が「-1」「null」の場合、DWの値を設定
    if (Objects.isNull(targetWeightStr) || "-1".equals(targetWeightStr) || "null".equals(targetWeightStr)) {
      targetWeightStr = dw;
    }
    BigDecimal targetWeight = new BigDecimal(targetWeightStr);

    // 除水補正合計 gをkgに変換し、1g部分を切り上げ
    BigDecimal offWaterGram = BigDecimal.valueOf(offWaterTotal);
    BigDecimal offWaterKiloGram = offWaterGram.divide(BigDecimal.valueOf(1000), 2, RoundingMode.CEILING);

    // 前体重 + 除水補正合計 - 目標体重
    return beforeWeight.add(offWaterKiloGram).subtract(targetWeight);
  }
}
