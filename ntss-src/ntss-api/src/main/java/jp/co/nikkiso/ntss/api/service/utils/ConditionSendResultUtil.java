package jp.co.nikkiso.ntss.api.service.utils;


import com.amazonaws.util.StringUtils;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import jp.co.nikkiso.ntss.api.constant.InOutInfoConstant;
import jp.co.nikkiso.ntss.api.request.AdditionCalculationRequest;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.api.service.additionInfo.AdditionCalculationService;
import jp.co.nikkiso.ntss.api.service.conditionSend.ConditionSendResultUtilService;
import jp.co.nikkiso.ntss.api.service.conditionSend.ConditionSendResultUtilUserService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstTabooAllergyDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dto.ordMaterialSave.OrdMaterialSaveDto;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTabooAllergy;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.custom.ComTypeAndFormatCd;
import jp.co.nikkiso.ntss.core.entity.custom.MstEquipmentMstMedicine;
import jp.co.nikkiso.ntss.core.entity.custom.MstTabooAllergyDetailInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatInfoTabooAllergy;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.api.service.ordChecklistService.OrdCheckListService;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import jp.co.nikkiso.ntss.core.utils.NumberFormatUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ObjectUtils;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 *
 * 条件送信結果(3011)処理用クラス(ord_main処理切り出し中)
 *
 */
@Component
public class ConditionSendResultUtil {

  /**
   * ステータス変更用DI
   */
  @Autowired
  OperateStatusUtil operateStatusUtil ;

  /**
   * DBアクセス 3010 DB6用DI
   */
  @Autowired
  ConditionSendResultUtilUserService conditionSendResultUtilUserService ;

  /**
   * DBアクセス 3010 DB5用DI
   */
  @Autowired
  ConditionSendResultUtilService conditionSendResultUtilService ;

  @Autowired
  private MstMachineDao mstMachineDao;

  @Autowired
  private LogService logService;

  @Autowired
  private AdditionCalculationService additionCalculationService;
  // add FNSI-分類不一致判断の追加 徐 start

  @Autowired
  private OrdMainDao ordMainDao;
  // add FNSI-分類不一致判断の追加 徐 end

  /** 計算材料保持サービス */
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;

  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  @Autowired
  private OrdCheckListService ordCheckListService;
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

  //add #10443 身体情報・DW・目標体重バグ全体見直し対応 朴 start
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  //add #10443 身体情報・DW・目標体重バグ全体見直し対応 朴 end

  /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
  @Autowired
  private MstTabooAllergyDao mstTabooAllergyDao;
  /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */

  // add 10739 by shiyw 20250303 start
  @Autowired
  private ObjectMapper objectMapper;
  @Autowired
  private MstKurDao mstKurDao;
  @Autowired
  private MstBedDao mstBedDao;
  @Autowired
  private MstTreatmentDao mstTreatmentDao;
  // add 10739 by shiyw 20250303 end

  /* add by chamaojia 2024-01-23 [10196]  Definition of constant array for user information item names in JSON --start */
  private static final String[] USER_JSON_RELATED_ARRAY = new String[]
          {"ind_user_id", "ind_user_last_name", "ind_user_first_name"
                  , "upd_user_id", "upd_user_last_name", "upd_user_first_name"};
  /* add by chamaojia 2024-01-23 [10196]  Definition of constant array for user information item names in JSON --end */

  /**
   * キー名の定義
   */
  public enum PARAMKEY {
    STATUS("status"),               //HTTPステータス
    ERRMSG("errmsg"),               //エラーメッセージ
    MSG("msg"),               //エラーメッセージ
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
//    add 8074 【デグレ】ログに誤った利用者が記録される 関 start
    LOGUSERID("user"),                  //利用者ID
//    add 8074 【デグレ】ログに誤った利用者が記録される 関  end
    COND_NO("condNo"),                  //治療条件番号

    IND_OFF_WATER_INFO("ind_off_water_info"),   //除水補正値

    //装置マスタ
    TMP_CENTER_HD("tmp_center_hd"),     // TMPゼロ補正警報中点HD
    TMP_CENTER_ECUM("tmp_center_ecum"), // TMPゼロ補正警報中点ECUM
    TMP_CENTER_HDF("tmp_center_hdf"),   // TMPゼロ補正警報中点HDF
    TMP_CENTER_HF("tmp_center_hf"),     // TMPゼロ補正警報中点HF
    TMP_CENTER_HD_HO("tmp_center_hd_ho"),//TMP初期補正中点（HD+補液）
    TMP_CENTER_OHF("tmp_center_ohf"),   //TMP初期補正中点（OHF）
    TMP_CENTER_OHDF("tmp_center_ohdf"),   //TMP初期補正中点（OHDF）

    COM_FORMAT_CD("com_format_cd"), //通信フォーマット

    MACHINE_OPTION("machine_option"),   //装置オプション
    DEVICE_TYPE_NAME("machine_type"),   //機種タイプ

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
    //add #10443 身体情報・DW・目標体重バグ全体見直し対応 朴 start
    INDICATOR_CD("indicator_cd"),               //指示者(Number)
    CHANGER_CD("changer_cd"),                   //更新者(Number)
    //add #10443 身体情報・DW・目標体重バグ全体見直し対応 朴 end

    DEV("dev"),                                  //装置設定(dev)
    PAT("pat"),                                  //装置設定(pat)
    //除水
    OFF_WATER_NAME("name_"),        //除水項目名
    OFF_WATER_VALUE("weight_"),        //除水補正値

    EXAM_DATE("exam_date"),             //検査日時


    //透析量プログラム
    AFVPROG("AFVPROG"),                     //透析量プログラム設定
    AFVPROG_SYS("AFVPROG_SYS"),             //透析量プログラム設定(システム）
    AFVPROG_SYS_ON("AFVPROG_SYS_ON"),       //透析量プログラム使用フラグ
    //ダイアライザー情報
    UFR_WARNING_MAX("ufr_warning_max"), // 初期UFR警報上限
    UFR_WARNING_MIN("ufr_warning_min"), // 初期UFR警報下限
    UFR_WARNING_REDUCTION("ufr_warning_reduction"), // UFR低下率警報点
    UREACLEARANCE("urea_clearance"),   // 尿素クリアランス
    BLOODAMT("bloodamt"),               // 血流量
    ALQD_FLOOD_VOL("alqd_flood_vol"),   // 透析液量

    EXAM_ITEM_CD("EXAM_ITEM_CD"),           //BUN値

    DEVICE_MODE("device_mode") ,             //装置モード

    //施設名
    FACILITY_NAME("facility_name"),
    //指示：治療方法名
    TREATMANT_NAME("treatment_name"),
    //指示：クール名
    KUR_NAME("kur_name"),
    //指示：ベッド名
    BED_NAME("bed_name"),
    //実績：装置番号
    MACHINE_NO("machine_no"),
    //実績：装置名
    MACHINE_NAME("machine_name"),

    //pat_uniqueのカラムキー
    //共通診療情報
    MEDICAL_CARE_INFO("medical_care_info"),
    DIALYSIS_COURSE_CD("dialysis_course_cd"),   //共通診療情報:診療科マスタ.診療科コード　※透析実施科コード
    WARD_CD("ward_cd"),                         //共通診療情報:病棟マスタ.病棟コード
    WARD_NAME("ward_name"),                     //実績：病棟名(mst_ward)
    COURSE_NAME("course_name"),                 //実績：診療科名(mst_courceから)
    DIALYSIS_COUNT("dialysis_count"),           //実績：透析回数(mst_courceから)
    PURIFICATION_COUNT("purification_count"),   //実績：浄化治療回数(mst_courceから)

    //-----------------------------------
    //体重情報Jsonキー
    J_WEIGHT_BEFORE("weight_before")          ,   //前体重
    J_WEIGHT_BEFORE_DATE("weight_before_date"),   //前体重測定日時
    J_WEIGHT_AFTER("weight_after")            ,   //後体重
    J_WEIGHT_AFTER_DATE("weight_after_date")  ,   //後体重測定日時
    J_CTR("ctr"),                                 //CTR
    J_CTR_MEASURE_DATE("ctr_measure_date"),       //CTR測定日時(登録用)
    J_CTR_EXAM_DATE("exam_date"),                //CTR測定日時(取得用)
    J_CTR_WEIGHT("ctr_weight"),                   //CTR測定時体重
    J_WATER_REMOVAL_TARGET("water_removal_target"), //目標除水量
    J_ADD_TOTAL("add_total"),                     //除水積算値
    J_ADD_WATER_TOTAL("add_water_total"),         //補液積算値
    J_KT_V_MEASURE("kt_v_measure"),               //Kt/V測定値
    J_URR("urr"),                                 //URR
    J_RE_LOOP_RATE_BASE("re_loop_rate_"),         // 再循環率(キーのベース型。ループ用)
    J_RE_LOOP_RATE_1("re_loop_rate_1"),           // 再循環率(1回目)
    J_RE_LOOP_RATE_2("re_loop_rate_2"),           // 再循環率(2回目)
    J_RE_LOOP_RATE_3("re_loop_rate_3"),           // 再循環率(3回目)
    J_RE_LOOP_RATE_4("re_loop_rate_4"),           // 再循環率(4回目)
    J_RE_LOOP_RATE_5("re_loop_rate_5"),           // 再循環率(5回目)
    J_DATE("date"),     //測定日時
    J_VALUE("value"),   //測定値

    //-----------------------------------
    //指示:治療条件情報
    COND_CD("cd"),                  //コード(DBキー)
    COND_NAME("name"),              //名称(DBキー)

    COND_VALUE("value"),            //値
    COND_NAME_1("value_name_1"),    //翻訳1
    COND_NAME_2("value_name_2"),    //翻訳2
    COND_UNIT("unit"),              //単位（指示／調製薬剤）
    COND_UNIT_SECOND("unit_second"),//単位（レセ）
    COND_DEC_PT("dec_pt"),              // 指示単位小数部桁数
    COND_DEC_PT_SECOND("dec_pt_second"),// レセ単位小数部桁数

    COND_MODEL_NUMBER("model_number"),  //ダイアライザマスタ:型番
    COND_MAKER("maker"),                //ダイアライザマスタ:メーカー名

    COND_MEDICINE_TYPE("medicine_type"),   //薬剤区分 1: 通常薬剤、2: 調製薬剤

    COND_CAT_EQUIP("EQUIP"),        //処理区分:医療材料
    COND_CAT_VA("VA"),              //処理区分:VA


    //-----------------------------------
    //投与薬剤
    MEDI_NO("no"),                          //識別番号
    MEDI_MEDICENE_TYPE("medicine_type"),    //薬剤区分
    MEDI_CD("cd"),                          //薬剤(or 調整薬剤)コード
    MEDI_TIMING_CD("timing_cd"),            //投与タイミングコード
    MEDI_PROCEDURE_CD("procedure_cd"),      //手技コード

    MEDI_CLASS_CD("class_cd"),              //薬剤分類コード
    MEDI_CLASS_NAME("class_name"),          //薬剤分類名
    MEDI_CLASS_TYPE("class_type"),          //分類区分
    MEDI_NAME("name"),                      //薬剤名
    MEDI_SHORT_NAME("short_name"),          //省略薬剤名
    MEDI_UNIT("unit"),                      //単位
    MEDI_AMOUNT("amount"),                  // 数量
    MEDI_DEC_PT("dec_pt"),                  // 指示単位小数部桁数

    MEDI_TIMING_NAME("timing_name"),        //投与タイミング名
    MEDI_PROCEDURE_NAME("procedure_name"),  //手技名

    MEDI_IND_INFO("indMediInfo"),       //指示
    MEDI_RST_INFO("rstMediInfo"),       //実績

    //実績に追加するキー
    MEDI_EFFECT_FLG("effect_flg"),          //投与実施フラグ ※0：未実施、1：実施済み
    MEDI_EFFECT_DATE("effect_date"),        //投与実施日時 ※ISO8601形式
    MEDI_EFFECT_USER_ID("effect_user_id"),  //投与実施者コード
    MEDI_EFFECT_USER_LAST_NAME("effect_user_last_name"),    //投与実施者名_姓
    MEDI_EFFECT_USER_FIRST_NAME("effect_user_first_name"),  //投与実施者名_名
    /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
    MEDI_MIX_INFO("mix_info"),              // 調整薬剤情報
    /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */

    //-----------------------------------
    //医療材料
    EQUI_CD("cd"),                          //医療材料コード

    EQUI_CLASS_CD("class_cd"),              //医療材料分類コード
    EQUI_CLASS_NAME("class_name"),          //医療材料分類名
    EQUI_CLASS_TYPE("class_type"),          //分類区分
    EQUI_NAME("name"),                      //医療材料名
    EQUI_SHORT_NAME("short_name"),          //省略医療材料名
    EQUI_UNIT("unit"),                      //単位

    EQUI_EQUIPMENT_CD("equipment_cd"),      //医療材料コード(DB)
    EQUI_EQUIPMENT_NAME("equipment_name"),  //医療材料名(DB)
    EQUI_TYPE("equip_type"),                //医療材料区分(DB)

    /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
    DATA_USE_END_DATE("use_end_date"),     // 使用終了日
    DATA_IS_DISP("is_disp"),               // 表示フラグ
    DATA_IS_DEL("is_del"),                 // 削除フラグ
    /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */

    ;

    //値格納用
    public final String strKey;

    //String型のコンストラクタ
    PARAMKEY(String strKey) {
      this.strKey = strKey ;
    }

    //String型のGetter
    public String get() {
      return this.strKey ;
    }

  }

  /**
   * 定数の定義
   * 定数をenumで定義します
   */
  public enum CONSTDEF {
    OFFLINE("1"),               //オフライン
    ONLINE("0"),                //オンライン

    MEDICINE_DEFAULT("1"),      //薬剤区分:通常薬剤
    MEDICINE_PREPARATION("2"),  //薬剤区分:調製薬剤

    MEDI_DONE("1"),      //投薬実施済み
    MEDI_NOTDONE("0"),   //投薬未実施

    PATVERIFIED_DONE("1"),      //患者確認済み
    PATVERIFIED_NOTDONE("0"),   //患者確認未確認

    DEVICE_MODE_PURIFICATION("9"),      //装置モード:特殊浄化("9")
    DISP_PURIFICATION("血液浄化装置"),    //装置モード:特殊浄化時の表示文言

    DEBUGFLAG("0"),             //デバッグ出力用フラグ "1":出力

    RST_INPUT_CLASS_DEFAULT("1"),   //登録区分：通常(透析装置や通信サーバーなどを伴う治療)
    RST_INPUT_CLASS_MANUAL("2"),    //登録区分：クライアントで手入力して作成

    ;
    //値格納用

    public final String strKey;

    //String型のコンストラクタ
    CONSTDEF(String strKey) {
      this.strKey = strKey ;
    }

    //String型のGetter
    public String get() {
      return this.strKey ;
    }

  }


  /**
   * Json処理カテゴリ定義
   * Jsonの構成パターンをenumで定義します
   */
  public enum CAT_JSON_PATTERN {
    STRING,
    KEYVALUE,
    DIM
  }


  /**
   *
   * 透析条件項目定義
   * 2018/11/20現在の@治療条件項目に従い定義
   */
  public enum DIALYSISCOND {
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
    //透析液使用数
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
    //IPワンショットスタート
    COND_IP_ONESHOT_START("34"),
    //IP電源自動切り
    COND_IP_AUTO_POWER_OFF("35"),
    //IP電源自動切り時間
    COND_IP_AUTO_POWER_OFF_TIME("36"),
    //IP電源OKモニタ切り
    COND_IP_AUTO_MONITOR_OFF("37"),
    //IP電源OKモニタ切り時間
    COND_IP_AUTO_MONITOR_OFF_TIME("38"),
    // add FNSI-FutreNetWeb+SI課題管理のNo3917 対応 韓 start
    //DW
    COND_DW("39")
    // add FNSI-FutreNetWeb+SI課題管理のNo3917 対応 韓 end
    ;
    //値格納領域
    //String
    private final String strval ;

    //String型のコンストラクタ
    DIALYSISCOND(String strval) {
      this.strval = strval ;
    }
    //String型のGetter
    public String get() {
      return this.strval ;
    }
  }

  /**
   * main処理 条件送信3011
   *    条件送信結果処理を行う
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 装置種別
   * @param machineSerial 装置シリアル
   * @param retVal  PARAMKEY:value    パラメータ授受用
   *        PARAMKEY.STATUS     Httpステータス
   *        PARAMKEY.RET_MSG    メッセージ
   */
  @Transactional
  public void mainProcessSendCondResult(
    String facilityCd, String machineTypeCd, String machineSerial, Map<PARAMKEY, Object> retVal
  ) throws JSONException
  {
    boolean ret;
    //結果返却用     Httpステータス
    HttpStatus status;
    //結果返却用     エラーメッセージ
    String retMsg = "", retLogMsg = "";

    boolean cryptoFlag = false ;        //false:暗号化しない(処理的には取得時に復号する)

    //クラス名の取得(ログ用)
    final String className = new Object(){}.getClass().getEnclosingClass().getName();
    //メソッド名の取得(ログ用)
    final String methodName = new Object(){}.getClass().getEnclosingMethod().getName();

    //----------------------------------------------
    //DIの確認 ここから

    /*
     * ステータス変更用DI
     */
    if(null == operateStatusUtil) {
      //DIに失敗
      retMsg = "operateStatusUtilのDIに失敗しました"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retMsg) ;
      // ロールバック用の例外を投げる
      exitMethod(className,methodName,retMsg);
    }

    /*
     * DBアクセス 3010 DB6用DI
     */
    if(null == conditionSendResultUtilUserService) {
      //DIに失敗
      retMsg = "conditionSendResultUtilUserServiceのDIに失敗しました"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retMsg) ;
      // ロールバック用の例外を投げる
      exitMethod(className,methodName,retMsg);
    }

    /*
     * DBアクセス 3010 DB5用DI
     */
    if(null == conditionSendResultUtilService) {
      //DIに失敗
      retMsg = "conditionSendResultUtilServiceのDIに失敗しました"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retMsg) ;
      // ロールバック用の例外を投げる
      exitMethod(className,methodName,retMsg);
    }

    //DIの確認 ここまで
    //----------------------------------------------

    //開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + "の処理を開始しました。");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    //-----------------------------------------------------
    //値の収集 ここから

    //現在日付時刻の取得  ※日付時刻設定用
    Timestamp ts = new Timestamp((new Date()).getTime());

    //条件送信日時
    Timestamp condSendDate = null ;
    //条件確認日時(患者確認日時) ※◦医器工、オフライン、特殊浄化の場合(つまり、オフラインの場合)、設定
    Timestamp condSetDate = null ;      //あとの処理でオフラインフラグ判定時に必要な場合は設定

    String isPatVerified = null ;       //患者確認済みフラグ 0:未確認 1:確認済み

// del 11454 時間外加算自動処理が機能していない zkm start
//    //bodyデータから引数を取得
//    //JSONObject宣言
//    //受信パラメータ受付用(送信body情報のJSON文字列格納)
//    JSONObject receiveData = null;
//    //各データブロックの取得(受信データのボディからの取得処理)
//    HashMap<PARAMKEY,Object> retValData = new HashMap<>() ;
//    ret = this.getDataFromBodyData(bodydata,retValData) ;
//
//    eventLogMessage.setLogMessage("01：パラメータ取得有無：" + ret);
//    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
//    if(ret) {
//      //受信データ
//      receiveData = (JSONObject)retValData.get(PARAMKEY.RECEIVE_DATA) ;
//    }
//    else
//    {
//      //データブロックの取得時にエラー発生
//      status = (HttpStatus)retValData.get(PARAMKEY.STATUS);
//      retMsg = (String)retValData.get(PARAMKEY.MSG);
//      retLogMsg = (String)retValData.get(PARAMKEY.ERRMSG);
//
//      retVal.put(PARAMKEY.STATUS, status) ;
//      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
//      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
//      exitMethod(className,methodName,retLogMsg);
//    }
//
//    //値の取得
//    //呼び出し時に渡される以下の値をbodyデータ(Json)から取得する
//    //・施設コード
//    //・型式コード
//    //・製造番号
//
//    //    施設コード   facility_cd
//    String facilityCd = (String)getDataFromJSON(receiveData, PARAMKEY.FACILITY_CD.get()) ;
//    //    型式コード   machine_type_cd
//    String machineTypeCd = (String)getDataFromJSON(receiveData, PARAMKEY.MACHINE_TYPE_CD.get()) ;
//    //    製造番号    machine_serial
//    String machineSerial = (String)getDataFromJSON(receiveData, PARAMKEY.MACHINE_SERIAL.get()) ;
// del 11454 時間外加算自動処理が機能していない zkm end

    eventLogMessage.setLogMessage("02：施設コード("+ facilityCd + ")型式コード(" + machineTypeCd +")製造番号取得" + machineSerial + ")取得");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    // del 11454 時間外加算自動処理が機能していない zkm start
//    if(null == facilityCd || null == machineTypeCd || null == machineSerial)
//    {
//      //必要パラメータが渡されていないので終了
//      String fmt = "渡されたパラメータが不正です。"+ PARAMKEY.FACILITY_CD.get()+"(%s) " + PARAMKEY.MACHINE_TYPE_CD.get()+"(%s) "+ PARAMKEY.MACHINE_SERIAL.get()+"(%s) " ;
//      retLogMsg = String.format(fmt, facilityCd,machineTypeCd,machineSerial);
//      retMsg = "装置が特定できません。";
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
//      // エラーメッセージ設定
//      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
//      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
//      // ロールバック用の例外を投げる
//      exitMethod(className,methodName,retLogMsg);
//    }
    // del 11454 時間外加算自動処理が機能していない zkm end

    //mnt_machine_stateのレコード取得
    //呼び出し時に渡される値を元にmnt_machine_stateのレコード(1件)を取得する
    List<MntMachineState> mntMachineState = conditionSendResultUtilService.getMntMachineStateInfo(
                                                  facilityCd,
                                                  machineTypeCd,
                                                  machineSerial
                                              );

    eventLogMessage.setLogMessage("03：mnt_machine_state取得件数" + mntMachineState.size());
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == mntMachineState || mntMachineState.size() != 1)
    {
      //mnt_machine_stateからのデータ取得に失敗
      String fmt = "mnt_machine_stateからのデータ取得に失敗しました facilityCd:%s machineTypeCd:%s machineSerial:%s"  ;
      retLogMsg = String.format(fmt, facilityCd, machineTypeCd, machineSerial) ;
      retMsg = "装置状態の取得に失敗しました。";
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      // ロールバック用の例外を投げる
      exitMethod(className,methodName,retLogMsg);
    }

    MntMachineState inMntMachineState = mntMachineState.get(0) ;

    //現患者のpat_idを取得したmnt_machine_stateのレコードから取得する
    Long nowPatId = inMntMachineState.getPatId() ;

    //ord_noを取得したmnt_machine_stateのレコードから取得する
    //注意:next_ord_noが今条件送信をしようとしている患者のもの
    Long ordNo = inMntMachineState.getNextOrdNo() ;

    //==================================================
    //対象ベッド透析状態確認
    //今の患者の治療状況のチェックを行う。「治療中」以上(治療が終わっていない)だと処理を中断する
    //==================================================
    ret = checkNowPatStatusNotUnderOperation(ordNo,facilityCd) ;
    eventLogMessage.setLogMessage("04：患者治療中有無(治療が終わってないなら処理中断)：" + ret);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!ret)
    {
      //現患者の状態が治療中以上なので処理終了
      String fmt = "現患者の治療状況が治療中以上です(patId:%s)"  ;
      retLogMsg = String.format(fmt, nowPatId) ;
      retMsg = "現患者が治療開始済みです。";
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      // ロールバック用の例外を投げる
      exitMethod(className,methodName,retLogMsg);
    }

    //ord_mainのデータ取得
    OrdMain ordMainData = this.getOrdMainData(ordNo,retVal) ;
    eventLogMessage.setLogMessage("05：ord_mainの取得：" + ordMainData);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == ordMainData)
    {
      // ロールバック用の例外を投げる
      exitMethod(className,methodName,(String)retVal.get(PARAMKEY.RET_MSG));
    }

    //------------------------------------------------------------
    //ord_mainから患者IDを取得(次患者チェック用)
    Long patIdFromOrdMain = ordMainData.getPatId();

    //------------------------------------------------------------
    //pat_idを取得したmnt_machine_stateのレコードから取得
    //注意:next_pat_idが今条件送信をしようとしている患者のもの
    Long nextPatId = inMntMachineState.getNextPatid() ;

    //------------------------------------------------------------
    //特殊血液浄化オフラインフラグ更新機能
    //※ここでは、値を決定するだけ(mnt_machine_state更新時に合わせて更新)
    //mnt_machine_state:is_offlineの更新
    // #10889 2024.10.16 mod オフラインフラグ条件の見直し TDC片口 start
    // // 更新条件:通信フォーマットがF,V,W,Y,Z または治療方法が特殊浄化
    // 更新条件:通信フォーマットがFかつ通信種別が0:オフライン運用の装置、または治療方法が特殊浄化
    // #10889 2024.10.16 mod オフラインフラグ条件の見直し TDC片口 end
    //オフラインかどうかの確認 true:オフライン
    boolean offlineFlag = conditionSendResultUtilService.checkOfflineOrNot(ordNo) ;
    String isOffline = CONSTDEF.ONLINE.get() ;  //TODO:ONLINE初期化
    eventLogMessage.setLogMessage("06：オフライン有無確認：" + offlineFlag);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(offlineFlag)
    {
      isOffline = CONSTDEF.OFFLINE.get() ;
      //条件確認日時(患者確認日時)を設定
      condSetDate = ts ;
      //条件送信日時を設定(条件確認日時と同じ)
      condSendDate = condSetDate ;
      //患者確認済みフラグを確認済みに設定
      isPatVerified = CONSTDEF.PATVERIFIED_DONE.get();
    }

    //------------------------------------------------------------
    //条件送信患者が次患者と不一致でないかチェックする
    //ord_mainのpat_idとmnt_machine_stateのnext_pat_idの比較
    eventLogMessage.setLogMessage("07：条件送信患者が次患者と一致するか確認");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07：条件送信患者：" + patIdFromOrdMain);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07：次患者：" + nextPatId);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!patIdFromOrdMain.equals(nextPatId))
    {
      //条件送信患者が次患者と不一致
      String fmt = "条件送信患者が次患者と不一致です pat_id:%s next_pat_id:%s"  ;
      retLogMsg = String.format(fmt, patIdFromOrdMain,nextPatId) ;
      retMsg = "条件送信患者が次患者と不一致です"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      // ロールバック用の例外を投げる
      exitMethod(className,methodName,retLogMsg);
    }

    //-----------------------------------------------------
    //値の格納
    //ord_mainを更新するために、ord_mainエンティティを組み立てる

    //格納先:ordMainエンティティの組み立て
    OrdMain outOrdMain = this.buildResultOrdMainEntity(
                            ordNo,
                            ordMainData,
                            mntMachineState.get(0).getCondSendDate(),
                            null,
                            cryptoFlag,
                            retVal);

    eventLogMessage.setLogMessage("08：ord_main更新に必要なoutOrdMain値：" + outOrdMain);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == outOrdMain)
    {
      //ordMainエンティティの組み立てに失敗
      String fmt = "ordMainエンティティの組み立てに失敗しました :%s"  ;
      retLogMsg = String.format(fmt, retVal.get(PARAMKEY.RET_LOG_MSG)) ;
      retMsg = (String)retVal.get(PARAMKEY.RET_MSG);
      // ロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
    }

    //--------------------------------------------

    //mnt_machine_stateの設定
    //mnt_machine_stateを更新するために、mnt_machine_stateエンティティを組み立てる
    MntMachineState outMntMachineState = new MntMachineState() ;

    //施設コード   facility_cd
    //更新キーとしてセット
    outMntMachineState.setFacilityCd(facilityCd);
    //型式コード   machine_type_cd
    //更新キーとしてセット
    outMntMachineState.setMachineTypeCd(machineTypeCd);
    //製造番号    machine_serial
    //更新キーとしてセット
    outMntMachineState.setMachineSerial(machineSerial);
    //変更しない    機種  model
    //変更しない    装置名 machine_name       TODO:済 すでに入っているかの確認→セットする必要があるかの確認(上で取ってきているのでセットは簡単)→すでに入っている
    //変更しない    ベッドコード  bed_cd
    //変更しない    ベッド名    bed_name         TODO:済 すでに入っているかの確認→セットする必要があるかの確認(上で取ってきているのでセットは簡単)→すでに入っている
    //変更しない    工程状態    process_state
    //変更しない    緊急発報件数  m_notice_cnt
    //変更しない    予防保守件数  preventive_mainte_cnt
    //変更しない    通信不良有無  is_preventive_mainte
    //変更しない    部品運転時間  use_time
    //変更しない    装置ステータス machine_status
    //変更しない    警報監視状態  alarm_moni
    //    オフラインフラグ    is_offline    オフライン状態かを確認して更新かどうかを判定
    outMntMachineState.setIsOffline(isOffline);
    //    システムで管理する一意なオーダ番号   ord_no
    outMntMachineState.setOrdNo(inMntMachineState.getNextOrdNo());
    //変更しない       次回透析オーダ番号   next_ord_no
    //    システムで管理する一意な患者ID    pat_id
    outMntMachineState.setPatId(inMntMachineState.getNextPatid());
    //変更しない       次患者ID   next_patid
    //変更しない       次患者クールCD    next_kur_cd
    //変更しない     透析開始予定日時    start_plan_date
    //mnt_machine_state更新時に変更しない    透析終了予定日時    end_plan_date  //あとで別SQLで処理
    //変更しない       前体重測定日時 weigh_before_date
    //    条件送信日時  cond_send_date
    //TODO:済 ※2019.03.26 治療方法が特殊浄化の場合、設定(condSetDateと同じ値)。その他は何もしない。SQL側でnull判定で「何もしない」処理をおこなう →済
    outMntMachineState.setCondSendDate(condSendDate);
    //    条件確認日時  cond_set_date ※治療方法が特殊浄化の場合、設定。その他はnull
    outMntMachineState.setCondSetDate(condSetDate);
    //オフライン時は設定     患者確認済みフラグ     is_pat_verified
    outMntMachineState.setIsPatVerified(isPatVerified);
    //TODO:済 2019.03.26 null初期化
    //    透析開始日時  start_date
    outMntMachineState.setStartDate(null);
    //TODO:済 2019.03.26 null初期化
    //    透析終了日時  end_date
    outMntMachineState.setEndDate(null);
    //    後体重測定日時 weigh_after_date  TODO:済 2019.03.26 null初期化
    outMntMachineState.setWeighAfterDate(null);
    //変更しない    警報、注意発生中リスト alarm_list
    //変更しない    登録日時    reg_date
    //    更新日時    up_date    //SQLで更新

    //TODO:レセプトメモ処理呼び出し
    //レセプトメモ処理の呼び出し(仕様策定中のため実装なし)

    //--------------------------------------------
    // DB更新

    //==================================================
    //対象ベッド透析状態確認
    //今の患者の治療状況のチェックを行う。「治療中」以上(治療が終わっていない)だと処理を中断する
    //==================================================
    ret = checkNowPatStatusNotUnderOperation(ordNo,facilityCd) ;
    eventLogMessage.setLogMessage("09：患者治療中有無(治療が終わってないなら処理中断)：" + ret);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!ret)
    {
      //現患者の状態が治療中以上なので処理終了
      String fmt = "現患者の治療状況が治療中以上です(patId:%s)"  ;
      retLogMsg = String.format(fmt, nowPatId) ;
      retMsg = "現患者の治療が終わっていません。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      // ロールバック用の例外を投げる
      exitMethod(className,methodName,retLogMsg);
    }

    //----------------------------------------------
    //ord_mainの更新
    // #8732 2023.06.06 add ログ強化 TDC片口 start
    eventLogMessage.setLogMessage("09.5-4 :  ord_mainの更新開始");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // #8732 2023.06.06 add ログ強化 TDC片口 end
//    add 8074 【デグレ】ログに誤った利用者が記録される 関 start
    outOrdMain.setLogUserId("-1");
//    add 8074 【デグレ】ログに誤った利用者が記録される 関  end
    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
    outOrdMain.setUpdateFlg(false);
    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
    ret = this.updateOrdMain(outOrdMain, retVal);
    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
    outOrdMain.setUpdateFlg(true);
    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
    eventLogMessage.setLogMessage("10：ord_main更新成功有無：" + ret);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!ret)
    {
      // ロールバック用の例外を投げる
      this.exitMethod(className,methodName,(String)retVal.get(PARAMKEY.RET_LOG_MSG));
    }

    /* #10196 追加計算#10196 追加計算材料保持レコード更新 2024-01-30 Add by zhou.tao Start */
    //----------------------------------------------
    //ord_material_saveの更新
    outOrdMain.setFacilityCd(ordMainData.getFacilityCd());
    outOrdMain.setPatId(ordMainData.getPatId());
    outOrdMain.setTreatDate(ordMainData.getTreatDate());
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    this.ordMaterialSaveService.batchProcessingData(
//      Collections.singletonList(
//        ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveDto(ordNo, true, true, true
//            , true, "2", outOrdMain)
//        )
//      )
//    );
    ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquipTreatment(Collections.singletonList(ordNo));
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
    // del 11613 by shiyw 20250307 start
    //this.ordMaterialSaveService.updateIsConfirm(ordNo, ordMainData.getPatId());
    // del 11613 by shiyw 20250307 end
    /* #10196 追加計算材料保持レコード更新 2024-01-30 Add by zhou.tao End */

    // ord_check_listの更新
    //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    List<Long> ordnoList = new ArrayList<>();
    ordnoList.add(ordNo);
    try {
      this.ordCheckListService.syncOrdChecklistForResult(ordnoList);
    }
    catch(Exception e)
    {
      ordnoList = null;
    }

    //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    //----------------------------------------------
    //mnt_machine_stateの更新

    int retInt = conditionSendResultUtilService.updateMntMachineState(outMntMachineState) ;
    eventLogMessage.setLogMessage("11：mnt_machine_state更新成功有無(※1件なら成功)：" + retInt);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if( 1 != retInt )
    {
      //mnt_machine_stateの更新失敗
      retLogMsg = "mnt_machine_stateの更新に失敗しました" ;
      retMsg = "装置状態情報の更新に失敗しました。" ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      // ロールバック用の例外を投げる
      exitMethod(className,methodName,retLogMsg);
    }

    //----------------------------------------------
    //治療予定終了時間算出＆格納(mnt_machine_state)
    //計算は以下:
    //mnt_machine_state:end_plan_date
    //      =
    //  mnt_machine_state:start_plan_date+ord_main
    //      +
    //  ord_main:ind_cond_info(指示)/治療時間(分)(項目番号1)
    //TODO:SQLの表記変更→レビュー時に済

    retInt = conditionSendResultUtilService.updateEndPlanDateOnMntMachineState(
      ordNo,
      facilityCd,
      machineTypeCd,
      machineSerial
    ) ;

    eventLogMessage.setLogMessage("12：mnt_machine_stateのend_plan_date更新成功有無(※1件なら成功)：" + retInt);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("12：更新絞り込みパラメータordNo：" + ordNo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("12：更新絞り込みパラメータfacilityCd：" + facilityCd);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("12：更新絞り込みパラメータmachineTypeCd：" + machineTypeCd);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("12：更新絞り込みパラメータmachineSerial：" + machineSerial);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if( 1 != retInt )
    {
      //治療予定終了時刻更新失敗
      retMsg = "治療予定終了時刻の更新に失敗しました" ;
      retLogMsg = "治療予定終了時刻の更新に失敗しました" ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      // ロールバック用の例外を投げる
      exitMethod(className,methodName,retLogMsg);
    }

    //TODO:再送信時もステータス変更があるか確認
    //TODO:SQLの||(連結)の確認 →型指定のための表現だった。cast(as char)に置き換え
    //----------------------------------------------
    //ステータスの更新(ord_mainとpat_main)
    //ord_mainの実績:治療状況(rst_dialysis_state)を設定
    //  mst_machineのcom_typeに応じて決定
    //    0：通信なし(オフライン運用)、3：医器工V4 の場合⇒"2"：条件送信確認済み
    //    上記以外の場合⇒"1"：条件送信済
    //  ※当処理のord_main更新時点ですでに"2"：条件送信確認済み 以降の場合は変更しない(DAOのSQLで判定)
    //ord_mainの実績:条件送信日時(rst_cond_send_date)の更新(mnt_machine_stateの条件送信日時cond_send_dateで更新)
    //pat_mainの治療進捗状態(acceptance_status_info)(Json)のclassをord_mainの実績:治療状況と同値に設定
    //operateStatusUtil.changeTreatStatusOrdAndPat:
    //    ステータス                             ord_mainのステータス変更以外の処理
    //    1：条件送信済                ※実績：条件送信日時も設定。pat_mainは区分のみ設定(値は何もしない)

    //-----------------------------------------------------
    //通信種別に応じてrst_dialysis_stateの値を決定する
    eventLogMessage.setLogMessage("13：mst_machine取得開始");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    ComTypeAndFormatCd comTypeAndFormatCd = mstMachineDao.selectComTypeAndFormatCd(facilityCd, machineTypeCd, machineSerial);
    if (comTypeAndFormatCd == null) {
      //mst_machineからのデータ取得に失敗
      String fmt = "mst_machineからのデータ取得に失敗しました facilityCd:%s machineTypeCd:%s machineSerial:%s"  ;
      retLogMsg = String.format(fmt, facilityCd, machineTypeCd, machineSerial) ;
      retMsg = "装置情報の取得に失敗しました。";
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      // ロールバック用の例外を投げる
      exitMethod(className, methodName, retLogMsg);
    }
    final int comType = Optional.ofNullable(comTypeAndFormatCd.getComType()).orElse(0);
    eventLogMessage.setLogMessage("13：mst_machine取得終了 通信種別：" + comType);
    eventLogMessage.setSqlIdentification("facilityCd = " + facilityCd + ",machineTypeCd=" + machineTypeCd + ",machineSerial=" + machineSerial);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, "MstMachineDao/selectComTypeAndFormatCd");
    String settingStatus = null ;
    if (0 == comType || 3 == comType) {
      //0：通信なし(オフライン運用)、3：医器工V4 の場合
      //"2"：条件送信確認済み とする
      // mod 実績：治療状況（ord_main.rst_dialysis_state）の状態変更 高 start
      // settingStatus = OperateStatusUtil.STATUS.ENSURE_SENDCOND.get();
      settingStatus = OperateStatusUtil.STATUS.DONE_SENDCOND.get();
      // mod 実績：治療状況（ord_main.rst_dialysis_state）の状態変更 高 end
    }
    else
    {
      //"1"：条件送信済 とする
      settingStatus = OperateStatusUtil.STATUS.DONE_SENDCOND.get();
    }
    ret =  operateStatusUtil.changeTreatStatusOrdAndPat(patIdFromOrdMain, ordNo, settingStatus, null, null) ;
    eventLogMessage.setLogMessage("13：ord_mainおよびpat_mainのステータスの更新成功有無：" + ret);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("13：パラメータordNo：" + ordNo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("13：パラメータsettingStatus：" + settingStatus);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!ret )
    {
      //ステータスの更新失敗
      retLogMsg = "ord_mainおよびpat_mainのステータスの更新に失敗しました" ;
      retMsg = "治療状況の更新に失敗しました。" ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      // ロールバック用の例外を投げる
      exitMethod(className, methodName, retLogMsg);
    }

    //ロールバック確認用     TODO:済んだら削除
    if(ret) {
        //わざと失敗 -> ここまでの更新が全てなかったことになるのが正常(ロールバックが実行された)
//       exitMethod(className,methodName,"ロールバック確認のためのコード");
    }
    //----------------------------------------------
    //加算処理
    AdditionCalculationRequest request = new AdditionCalculationRequest();
    request.setFacilityCd(facilityCd);
    request.setOrdNo(ordNo);
    request.setPatId(ordMainData.getPatId());
    request.setEventId(3);
    additionCalculationService.calculationAddition(request);

    //----------------------------------------------
    //戻り値の返却
    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
    retVal.put(PARAMKEY.RET_MSG, retMsg) ;
    retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;

    //終了ログ
    exitMethod(className,methodName,null);

    return ;
  }

  //=================================================================
  // Methods
  //=================================================================

  /**
   * 結果反映処理(ord_mainの組み立て&更新)
   * @param ordNo オーダー番号
   * @param userId 利用者ID
   * @param retVal  PARAMKEY:value    パラメータ授受用
   *        PARAMKEY.STATUS     Httpステータス
   *        PARAMKEY.RET_MSG    メッセージ
   */
  @Transactional
  public void makeSendResult(Long ordNo, Long userId, Map<PARAMKEY, Object> retVal) throws RuntimeException {
    String retMsg = null, retLogMsg = "";
    boolean ret;

    //クラス名の取得(ログ用)
    final String className = new Object(){}.getClass().getEnclosingClass().getName();
    //メソッド名の取得(ログ用)
    final String methodName = new Object(){}.getClass().getEnclosingMethod().getName();

    //開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
   	eventLogMessage.setLogMessage(className + "." + methodName + "の処理を開始しました。");
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    //ord_mainデータの取得
    OrdMain ordMainData = this.getOrdMainData(ordNo,retVal);
    if(null == ordMainData)
    {
      //pat_mainのデータ取得に失敗
      String fmt = "ordMainデータ取得に失敗しました。 :%s"  ;
      retLogMsg = String.format(fmt, retVal.get(PARAMKEY.RET_LOG_MSG)) ;
      retMsg = (String)retVal.get(PARAMKEY.RET_MSG);
      // ロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
    }

    //結果反映(更新用エンティティの作成)
    OrdMain outOrdMain = this.buildResultOrdMainEntity(
        ordNo,
        ordMainData,
        null,
        OperateStatusUtil.STATUS.DONE_MEASURE_AFTER_WEIGHT.get(),
        false,
        retVal
    );
    if(null == outOrdMain)
    {
      //ordMainエンティティの組み立てに失敗
      String fmt = "ordMainエンティティの組み立てに失敗しました :%s"  ;
      retLogMsg = String.format(fmt, retVal.get(PARAMKEY.RET_LOG_MSG)) ;
      retMsg = (String)retVal.get(PARAMKEY.RET_MSG);
      // ロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
    }

    if (userId != null) {
      outOrdMain.setLogUserId(userId.toString());
    }

    //ord_mainデータの更新
    ret = this.updateOrdMain(outOrdMain, retVal);

    if(!ret)
    {
      //ordMainデータ更新に失敗
      String fmt = "ordMainデータ更新に失敗しました :%s"  ;
      retLogMsg = String.format(fmt, retVal.get(PARAMKEY.RET_LOG_MSG)) ;
      retMsg = (String)retVal.get(PARAMKEY.RET_MSG);
      // ロールバック用の例外を投げる
      this.exitMethod(className,methodName,retLogMsg);
    }

    /* #10196 追加計算材料保持レコード更新 2024-01-30 Add by zhou.tao Start */
    //----------------------------------------------
    //ord_material_saveの更新
    // mod #12250 ord_material_saveの処理を2回重複実行している zkm start
//    if (ordMainData != null) {
//      outOrdMain.setFacilityCd(ordMainData.getFacilityCd());
//      outOrdMain.setPatId(ordMainData.getPatId());
//      if (StringUtils.isNullOrEmpty(outOrdMain.getTreatDate()))
//        outOrdMain.setTreatDate(ordMainData.getTreatDate());
//    }
//    this.ordMaterialSaveService.batchProcessingData(
//      Collections.singletonList(
//        ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveDto(ordNo, true, true, true
//            , false, "2", outOrdMain)
//        )
//      )
//    );
    ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(Collections.singletonList(ordNo));
    // mod #12250 ord_material_saveの処理を2回重複実行している zkm end
    // del 11613 by shiyw 20250307 start
    //this.ordMaterialSaveService.updateIsConfirm(ordNo, outOrdMain.getPatId());
    // del 11613 by shiyw 20250307 end
    /* #10196 追加計算材料保持レコード更新 2024-01-30 Add by zhou.tao End */

    // 加算処理
    AdditionCalculationRequest request = new AdditionCalculationRequest();
    request.setFacilityCd(ordMainData.getFacilityCd());
    request.setOrdNo(ordNo);
    request.setPatId(ordMainData.getPatId());
    request.setEventId(3);
    additionCalculationService.calculationAddition(request);

    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
    retVal.put(PARAMKEY.RET_MSG, retMsg) ;
    retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
    //終了ログ-makeSendResultの処理を終了しました。
    exitMethod(className,methodName,null);
  }
  /**
   *  ord_mainの更新
   *
   * @param outOrdMain outOrdMain
   * @param retVal  PARAMKEY:value    パラメータ授受用
   *        PARAMKEY.STATUS     Httpステータス
   *        PARAMKEY.RET_MSG    メッセージ
   *        PARAMKEY.RET_LOG_MSG    詳細メッセージ
   * @return boolean true:正常/false:異常
   */
  private boolean updateOrdMain(
        OrdMain outOrdMain,
        Map<PARAMKEY, Object> retVal
      )
  {
    //----------------------------------------------
    //ord_mainの更新

    int retInt = conditionSendResultUtilService.updateOrdMain(outOrdMain) ;
    if( 1 != retInt )
    {
      //ord_mainの更新失敗
      String retLogMsg = "ord_mainの更新に失敗しました ";
      String retMsg = "治療情報の更新に失敗しました ";
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      // ロールバック用の例外を投げる
      return false;
    }

    return true;
  }
  /**
   *  ord_mainの取得
   *
   * @param ordNo オーダー番号
   * @param retVal  PARAMKEY:value    パラメータ授受用
   *        PARAMKEY.STATUS     Httpステータス
   *        PARAMKEY.RET_MSG    メッセージ
   *        PARAMKEY.RET_LOG_MSG    詳細メッセージ
   * @return OrdMainエンティティ
   */
  private OrdMain getOrdMainData(
        Long ordNo,
        Map<PARAMKEY, Object> retVal
  ) throws JSONException
  {
    //ord_mainのデータ取得
    OrdMain ordMainData = conditionSendResultUtilService.getOrdMainInfo(ordNo) ;
    if(null == ordMainData)
    {
      //ord_mainからのデータ取得に失敗
      String fmt = "ord_mainからのデータ取得に失敗しました ordNo:%s"  ;
      String retLogMsg = String.format(fmt, ordNo) ;
      String retMsg = "治療情報の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      //※流れ的にこのreturnがなくても問題ないが、後に変更が入った場合のことを考えreturn nullしておく
      return null;
    }

    return ordMainData;
  }

  /**
   *  条件送信結果処理を行う(ord_mainの組み立て)
   *
   * @param ordNo               オーダー番号
   * @param ordMainData         ord_mainデータ
   * @param rstCondSendDate     実績条件送信日時
   * @param rstDialysisState    実績:治療状況(nullの時は何もしない)
   * @param cryptoFlag          false:暗号化しない(処理的には取得時に復号する)

   * @param retVal  PARAMKEY:value    パラメータ授受用
   *        PARAMKEY.STATUS     Httpステータス
   *        PARAMKEY.RET_MSG    メッセージ
   *        PARAMKEY.RET_LOG_MSG    詳細メッセージ
   * @return OrdMainエンティティ
   */
  private OrdMain buildResultOrdMainEntity(
        Long ordNo,
        OrdMain ordMainData,
        Timestamp rstCondSendDate,
        String rstDialysisState,
        boolean cryptoFlag,
        Map<PARAMKEY, Object> retVal
  ) throws JSONException
  {
    //結果返却用     エラーメッセージ
    String retMsg = "", retLogMsg = "";

    //クラス名の取得(ログ用)
    final String className = new Object(){}.getClass().getEnclosingClass().getName();
    //メソッド名の取得(ログ用)
    final String methodName = new Object(){}.getClass().getEnclosingMethod().getName();

    //----------------------------------------------
    //DIの確認 ここから

    /*
     * ステータス変更用DI
     */
    if(null == operateStatusUtil) {
      //DIに失敗
      retMsg = "operateStatusUtilのDIに失敗しました"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retMsg) ;
      //異常終了
      return null;
    }

    /*
     * DBアクセス 3010 DB6用DI
     */
    if(null == conditionSendResultUtilUserService) {
      //DIに失敗
      retMsg = "conditionSendResultUtilUserServiceのDIに失敗しました"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retMsg) ;
      //異常終了
      return null;
    }

    /*
     * DBアクセス 3010 DB5用DI
     */
    if(null == conditionSendResultUtilService) {
      //DIに失敗
      retMsg = "conditionSendResultUtilServiceのDIに失敗しました"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retMsg) ;
      //異常終了
      return null;
    }

    //DIの確認 ここまで
    //----------------------------------------------

    //開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + "の処理を開始しました。");
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //-----------------------------------------------------
    //値の収集 ここから

    //------------------------------------------------------------
    //ord_mainから患者IDを取得(次患者チェック用)
    Long patIdFromOrdMain = ordMainData.getPatId();

    Long nextPatId = patIdFromOrdMain;

    String facilityCd = ordMainData.getFacilityCd();

   //------------------------------------------------------------
    //条件送信済みかどうかの確認(ord_main:実績治療状況(rst_dialysis_state)が0以外)
    //現行ソースのコメント:透析番号が既に割り振られているかチェックを行う
    Long nowStatus = parseLong(ordMainData.getRstDialysisState()) ;

    boolean reSendFlag = false ;        //再送信フラグ true:再送信処理

    eventLogMessage.setLogMessage("07-1：対象患者確認");
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-1：：患者ID：" + nextPatId);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-1：：患者状況：" + nowStatus);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null != nowStatus  && nowStatus > 0)
    {
      reSendFlag = true ;

      //以下の処理は、初回送信時とほぼ同じなので、初回送信での処理にreSendFlagで判定して差分の処理を追加する

      //TODO:実績展開処理

      //      患者情報を取得
      //      クール情報取得
      //      患者CTR情報取得
      //      設定時にベースとなる時間を取得する
      //      体重計の測定時刻を取得する  　再送信が行われても一番最初に測定した時刻が入室時刻になるため
      //      透析スケジュールから、指示IDと治療方法コードと同日複数回を取得する
      //      透析実績 更新
      //      透析実績測定体重　更新、
      //      透析実績風袋補正　削除＆挿入
      //      透析実績除水量補正　削除＆挿入
      //      透析実績装置設定　削除＆挿入
      //      指示共通関数の初期化
      //      予定指示取得
      //      透析実績透析条件　削除＆挿入
      //      透析実績医療材料　削除＆挿入
      //      透析実績投薬　削除＆挿入　※投薬実施済みの薬剤は残して、実施済みでない投薬指示実績は削除する
      //      透析実績補足指示　削除＆挿入
      //      透析実績レセプトメモ　更新
      //      チェックリストに透析実績番号を入れる　更新
      //      透析スケジュールに実績透析番号を設定する　更新
      //      透析工程管理テーブルの透析予定開始時間から、透析時間を足して透析予定終了時間を算出する
      //      透析工程管理テーブル更新前に、対象ベッドの透析状態を確認
      //      透析中(運転開始 ～ 排液前)の場合、透析工程管理テーブル更新処理はスキップ
      //      透析工程に存在する全患者の透析状態を取得
      //      　全てがOKの場合は、透析工程管理に以下を設定する 　更新：・透析番号 ・患者ID　・透析予定終了時間
      //      ステータスを処理完了にする

      //TODO:ここで処理しない場合は、以下削除
      //      retMsg = "実績展開処理"  ;
      //      retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
      //      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      //      return ;
    }

    //------------------------------------------------------------
    //実績：血液浄化装置名称   治療方法が「特殊浄化」の場合、固定文字列「血液浄化装置」を入れる
    //※ord_mainの項目(ord_main更新時に一緒に更新する)
    String bloodPurifierName = null ;

    eventLogMessage.setLogMessage("07-2：対象ord_no：" + ordNo);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    boolean isDeviceModeIsPureOrNot = conditionSendResultUtilService.checkDeviceModeIsPureOrNot(ordNo);
    if(isDeviceModeIsPureOrNot)
    {
      //治療方法が「特殊浄化」だったので、固定文言を格納
      bloodPurifierName = CONSTDEF.DISP_PURIFICATION.get();
    }

    //------------------------------------------------------------
    //pat_mainからのデータ取得 ※実績:装置設定のために装置設定を取得
    PatMain patMainData = conditionSendResultUtilService.getPatMainInfo(nextPatId) ;

    eventLogMessage.setLogMessage("07-3：patMain取得：" + patMainData);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == patMainData)
    {
      //pat_mainのデータ取得に失敗
      String fmt = "pat_mainのデータ取得に失敗しました  pat_id:%s"  ;
      retLogMsg = String.format(fmt, patIdFromOrdMain) ;
      retMsg = "患者取得に失敗しました。";
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      //異常終了
      return null;
    }

    /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
    // 禁忌・アレルギーを取得
    MstTabooAllergy mstTabooAllergy = new MstTabooAllergy();
    mstTabooAllergy.setFacilityCd(facilityCd);
    List<MstTabooAllergy> tabooAllergyList = null;
    String patTabooAllergyInfo = patMainData.getTaboo_allergy_info();
    if (!ObjectUtils.isEmpty(patTabooAllergyInfo) && !"[]".equals(patTabooAllergyInfo)) {
      tabooAllergyList = mstTabooAllergyDao.selectAll(SelectOptions.get(), mstTabooAllergy);
    }
    /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */

    //------------------------------------------------------------
    //pat_uniqueからのデータ取得
    PatUnique patUniqueData = conditionSendResultUtilService.getPatUniqueInfo(nextPatId) ;

    eventLogMessage.setLogMessage("07-4：patUnique取得：" + patUniqueData);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == patUniqueData)
    {
      //pat_uniqueのデータ取得に失敗
      String fmt = "pat_uniqueのデータ取得に失敗しました  pat_id:%s"  ;
      retLogMsg = String.format(fmt, patIdFromOrdMain) ;
      retMsg = "患者身体情報の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      //異常終了
      return null;
    }

    //共通診療情報の取得(pat_mainから)
    //共通診療情報から以下のコードを取得するため
    // 病棟コード
    // 診療科コード(透析実施科コード)

    //共通診療情報の取得
    String medicalCareInfo = patMainData.getMedical_care_info() ;

    //共通診療情報のJson化
    JSONObject medicalCareInfoJson = null ;
    eventLogMessage.setLogMessage("07-5：medicalCareInfo取得：" + medicalCareInfo);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    try {
      medicalCareInfoJson = new JSONObject(medicalCareInfo) ;
    }
    catch(Exception e)
    {
      medicalCareInfoJson = null ;
    }
    //実績：病棟コードの取得(nulllの可能性あり)
    Integer rstWardCd = parseInteger(getValueFromJson(medicalCareInfoJson, PARAMKEY.WARD_CD.get())) ;
    eventLogMessage.setLogMessage("07-6：病棟コード取得：" + rstWardCd);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //実績：診療科コード(透析実施科コード)の取得(nulllの可能性あり)
    Integer rstCourseCd = parseInteger(getValueFromJson(medicalCareInfoJson, PARAMKEY.DIALYSIS_COURSE_CD.get())) ;
    eventLogMessage.setLogMessage("07-6：診療科コード取得：" + rstCourseCd);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //実績：透析回数の取得(nullの可能性あり)
    Integer rstDialysisCnt = ordMainData.getRstDialysisCnt();
    Integer dialysisCnt = null;
    eventLogMessage.setLogMessage("07-6：特殊浄化フラグ：" + isDeviceModeIsPureOrNot);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if (isDeviceModeIsPureOrNot) {
      dialysisCnt = parseInteger(getValueFromJson(medicalCareInfoJson, PARAMKEY.PURIFICATION_COUNT.get()));
    } else {
      dialysisCnt = parseInteger(getValueFromJson(medicalCareInfoJson, PARAMKEY.DIALYSIS_COUNT.get()));
    }
    rstDialysisCnt = dialysisCnt == null ? 0 + 1: dialysisCnt + 1;
    eventLogMessage.setLogMessage("07-6：透析回数or浄化治療回数取得：" + rstDialysisCnt);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //------------------------------------------------------------
    //病棟名および診療科名をDBから取得する
    // 取得したコードに紐付く名称を取得
    // 病棟コード->mst_ward.病棟名
    // 診療科コード(透析実施科コード)->mst_course.診療科名
    Map<String,Object> namesMapByCd = conditionSendResultUtilService.getWardAndCourseName(
                                              facilityCd,
                                              rstWardCd,
                                              rstCourseCd
                                            ) ;
    eventLogMessage.setLogMessage("07-6：病棟名および診療科名取得：" + namesMapByCd);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == namesMapByCd)
    {
      //病棟名または診療科名の取得失敗
      String fmt = "病棟名または診療科名の取得に失敗しました  施設コード:%s 病棟コード:%s 診療科コード:%s"  ;
      retLogMsg = String.format(fmt, facilityCd, rstWardCd, rstCourseCd) ;
      retMsg = "病棟名・診療科名の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //実績：病棟名(mst_wardから)の取得
    String rstWardName = (String)namesMapByCd.get(PARAMKEY.WARD_NAME.get()) ;
    //実績：診療科名(mst_courceから)の取得
    String rstCourseName = (String)namesMapByCd.get(PARAMKEY.COURSE_NAME.get()) ;

    //実績：DW TODO:SQL取得への差し替えの場合あり
    //pat_uniqueの身体情報から取得する
    //身体情報はJson配列
    //以下の条件をすべて満たす配列要素(Json)のdwを採用する
    //1.最新の検査日付
    //2.dwに値が設定されている

    Double rstDw = (Double)null ;       //TODO:格納処理の開放

    JSONArray physical_info = null ;
    String ordMainTreatDate = ordMainData.getTreatDate();

    // add 10705 条件送信、手動実績作成治療法特殊浄化はind_dw rst_dwに値を与えない 関  start
    JSONObject ordIndCondInfo = null == ordMainData.getIndCondInfo() ?
      new JSONObject() :
      new JSONObject(ordMainData.getIndCondInfo());
    // add 10705 条件送信、手動実績作成治療法特殊浄化はind_dw rst_dwに値を与えない 関  end

    try {
      physical_info = new JSONArray(patUniqueData.getPhysical_info()) ;
    }
    catch(Exception e)
    {
      physical_info =  null ;
    }
    rstDw = parseDouble(getValueFromJson(
        getDataFromPhysicalInfo(physical_info, PARAMKEY.DW.get(), ordMainTreatDate),
        PARAMKEY.DW.get()
     )) ;
    eventLogMessage.setLogMessage("07-7：実績DW取得：" + rstDw);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    // mod 10705 条件送信、手動実績作成治療法特殊浄化はind_dw rst_dwに値を与えない 関  start
    if (ordIndCondInfo.has("3")) {
      if(rstDw == null) rstDw = 0d;
    }
    // mod 10705 条件送信、手動実績作成治療法特殊浄化はind_dw rst_dwに値を与えない 関  end

    //add #10443 身体情報・DW・目標体重バグ全体見直し対応 朴 start
    //------------------------------------------------------------
    //指示：DW指示者情報 ind_dw_user_info
    //■Json構造
    //    {
    //      "ind_user_id": (Number)指示者コード(利用者マスタ.利用者ID),
    //      "ind_user_last_name": (String)指示者名_姓(利用者マスタ.利用者名_姓),
    //      "ind_user_first_name": (String)指示者名_名(利用者マスタ.利用者名_名),
    //      "upd_user_id": (Number)更新者コード(利用者マスタ.利用者ID),
    //      "upd_user_last_name": (String)更新者名_姓(利用者マスタ.利用者名_姓),
    //      "upd_user_first_name": (String)更新者名_名(利用者マスタ.利用者名_名)
    //    }
    JSONObject physicalInfoOnejObj = getDataFromPhysicalInfo(physical_info, PARAMKEY.DW.get(), ordMainTreatDate);

    Long indUserId;
    String indLastName = null;
    String indFirstName = null;
    Long updUserId;
    String updLastName = null;
    String updFirstName = null;

    MstPersonalUser user;
    indUserId = parseLong(getValueFromJson(physicalInfoOnejObj, PARAMKEY.INDICATOR_CD.get()));
    // 指示者名取得
    if (indUserId != null && indUserId != 0) {
      user = mstPersonalUserDao.selectById(indUserId);
      indLastName = user.getUserLastName();
      indFirstName = user.getUserFirstName();
    }

    updUserId = parseLong(getValueFromJson(physicalInfoOnejObj, PARAMKEY.CHANGER_CD.get()));
    // 指示者名取得
    if (updUserId != null && updUserId != 0) {
      user = mstPersonalUserDao.selectById(updUserId);
      updLastName = user.getUserLastName();
      updFirstName = user.getUserFirstName();
    }

    JSONObject indDwUserInfoJson = new JSONObject();
    indDwUserInfoJson.put("ind_user_id", indUserId);
    indDwUserInfoJson.put("ind_user_last_name", indLastName);
    indDwUserInfoJson.put("ind_user_first_name", indFirstName);
    indDwUserInfoJson.put("upd_user_id", updUserId);
    indDwUserInfoJson.put("upd_user_last_name", updLastName);
    indDwUserInfoJson.put("upd_user_first_name", updFirstName);
    String indDwUserInfo = indDwUserInfoJson.toString();

    eventLogMessage.setLogMessage("07-7+：指示：DW指示者情報取得：" + indDwUserInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //add #10443 身体情報・DW・目標体重バグ全体見直し対応 朴 end

    //------------------------------------------------------------
    //名称の取得
    //ord_mainの各コード項目の名称等を該当テーブルから取得する
    // 施設名       mst_facility
    // 治療方法名 mst_treatment
    // クール名      mst_kur
    // ベッド名       mst_bed
    // 装置番号    mst_bed
    // 装置名        mst_machine

    Map<String,Object> namesMap = conditionSendResultUtilService.getNamesFromDbs(ordNo) ;
    eventLogMessage.setLogMessage("07-8：ord_main項目名称等を該当テーブルから取得：" + namesMap);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == namesMap)
    {
      //名称の取得失敗
      String fmt = "名称の取得に失敗しました  ordNo:%s"  ;
      retLogMsg = String.format(fmt, ordNo) ;
      retMsg = "治療指示の各項目の名称取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //各名称の取り出し
    // 施設名
    String facilityName = (String)getValueFromMap(namesMap, PARAMKEY.FACILITY_NAME.get()) ;
    // 指示：治療方法名
    String indTreatmentName = (String)getValueFromMap(namesMap, PARAMKEY.TREATMANT_NAME.get()) ;
      /* add by shiyw 2024-01-29 [#10196] --start */
    // 指示：device_mode
    BigDecimal indDdeviceModeDcl = (BigDecimal) getValueFromMap(namesMap, PARAMKEY.DEVICE_MODE.get());
    Integer indDdeviceMode = indDdeviceModeDcl.intValue();
      /* add by shiyw 2024-01-29 [#10196] --end */
    // 指示：クール名
    String indKurName = (String)getValueFromMap(namesMap, PARAMKEY.KUR_NAME.get()) ;
    // 指示：ベッド名
    String indBedName = (String)getValueFromMap(namesMap, PARAMKEY.BED_NAME.get()) ;
    // 実績：装置番号(nullの場合あり)
    Long rstMachineNo = parseLong(getValueFromMap(namesMap, PARAMKEY.MACHINE_NO.get())) ;
    // 実績：装置名
    String rstMachineName = (String)getValueFromMap(namesMap, PARAMKEY.MACHINE_NAME.get()) ;
    eventLogMessage.setLogMessage("07-8：施設名：" + facilityName);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-8：治療方法名：" + indTreatmentName);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-8：クール名：" + indKurName);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-8：ベッド名：" + indBedName);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-8：装置番号：" + rstMachineNo);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-8：装置名：" + rstMachineName);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // 実績：入外区分
    //  入外区分をpat_personal_mainから取得する(db6)
    Short rstInOutClass = null ;
    try {
      rstInOutClass = Short.valueOf(conditionSendResultUtilUserService.getInOutClassbyPatId(nextPatId).toString()) ;
      // 患者個人情報.入外区分が「-」の場合、実績：入外区分に「外来」を設定する
      if (rstInOutClass == Short.valueOf(InOutInfoConstant.PatInfoInOutClass.IN_OUT_CLASS_ABSRENCE)) {
        rstInOutClass = Short.valueOf(InOutInfoConstant.PatInfoInOutClass.IN_OUT_CLASS_OUTPATIENT);
      }
    }
    catch(Exception e)
    {
      rstInOutClass = null ;
    }

    //実績：体重情報 rst_weight_info
    //体重情報(Json)を組み立てる

    String rstWeightInfo = null ;

    //TODO:済 2019.03.27 項目が変わっている。コメント追加
    //以下、フォーマット ※のところは値が入るところ。その他は入らない
    //  {
    //  "weight_before": null ,       //前体重                      ※
    //  "weight_before_date": null,   //前体重測定日時      ※ISO8601
    //  "weight_after": null,         //後体重                      ※
    //  "weight_after_date": null,    //後体重測定日時      ※ISO8601
    //  "ctr": null,                  //CTR            ※
    //  "ctr_measure_date": null,     //CTR測定日時            ※ISO8601
    //  "ctr_weight": null,           //CTR測定時体重        ※ISO8601
    //  "water_removal_target": null, //目標除水量
    //  "water_removal_rst":          //(Number)実績除水量,
    //  "add_total": null,            //除水積算値
    //  "add_water_total": null,      //補液積算値
    //  "kt_v_measure": null,         //Kt/V測定値
    //  "urr": null,                  //URR
    //  "weight_decreased":           //(Number)減少量
    //  "re_loop_rate_main":          //(Number)治療記録で選択された再循環率の番号を格納
    //  "re_loop_rate_1": { "date": null, "value": null },    // 再循環率(1回目)
    //  "re_loop_rate_2": { "date": null, "value": null },    // 再循環率(2回目)
    //  "re_loop_rate_3": { "date": null, "value": null },    // 再循環率(3回目)
    //  "re_loop_rate_4": { "date": null, "value": null },    // 再循環率(4回目)
    //  "re_loop_rate_5": { "date": null, "value": null }     // 再循環率(5回目)
    //  }

    String rstWeight = (String)ordMainData.getRstWeightInfo() ;
    rstWeight = null == rstWeight ? "{}" : rstWeight ;
    JSONObject rstWeightInfoJson = new JSONObject(rstWeight) ;

    //以下の4項目は、すでに入っている
    //何もしない 前体重,
    //何もしない 前体重測定日時 (*1)
    //何もしない 後体重
    //何もしない 後体重測定日時 (*1)

    //TODO:済 CTR関連の値の取得
    //pat_uniqueの身体情報から取得する
    //身体情報はJson配列
    //以下の条件をすべて満たす配列要素(Json)のctrを採用する
    //1.最新の検査日付
    //2.ctrに値が設定されている

    JSONObject ctrObj = getDataFromPhysicalInfo(physical_info, PARAMKEY.J_CTR.get(), ordMainTreatDate);
    eventLogMessage.setLogMessage("07-9：身体情報取得：" + ctrObj);
    eventLogMessage.setFacilityCd(facilityCd);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    Double ctr = (Double)null;                  //CTR
    ctr = parseDouble(getValueFromJson(
            ctrObj,
            PARAMKEY.J_CTR.get()
         )) ;
    eventLogMessage.setLogMessage("07-9：CTR取得：" + ctr);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    String ctrMeasureDate=(String)null;       //CTR測定日時(検査日時を採用)
    ctrMeasureDate = (String)getValueFromJson(
        ctrObj,
        PARAMKEY.J_CTR_EXAM_DATE.get()
     ) ;
    if (ctrMeasureDate != null) {
      Pattern pattern = Pattern.compile("T");
      Matcher matcher = pattern.matcher(ctrMeasureDate);
      ctrMeasureDate = matcher.find() ? ctrMeasureDate : ctrMeasureDate + "T00:00:00.000+09:00";
    }

    eventLogMessage.setLogMessage("07-9：CTR測定日時取得：" + ctrMeasureDate);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    Double ctrWeight = (Double)null;           //CTR測定時体重
    ctrWeight = parseDouble(getValueFromJson(
        ctrObj,
        PARAMKEY.J_CTR_WEIGHT.get()
     )) ;
    eventLogMessage.setLogMessage("07-9：CTR測定時体重取得：" + ctrWeight);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    rstWeightInfoJson.put(PARAMKEY.J_CTR.get(), ctr) ;
    rstWeightInfoJson.put(PARAMKEY.J_CTR_MEASURE_DATE.get(), ctrMeasureDate) ;
    rstWeightInfoJson.put(PARAMKEY.J_CTR_WEIGHT.get(), ctrWeight) ;

    //※キーの増減等があるため、キーの追加は保留(コメントアウトして残しておく)
    //以下の項目は存在していないはずだが、存在している場合も考慮する
    //キーの存在確認をおこない、なければキーを追加
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_WATER_REMOVAL_TARGET.get(),(String)null) ;
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_WATER_REMOVAL_TARGET.get(), (String)null) ;
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_ADD_TOTAL.get(), (String)null) ;
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_ADD_WATER_TOTAL.get(), (String)null) ;
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_KT_V_MEASURE.get(), (String)null) ;
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_URR.get(), (String)null) ;

    //条件送信タイミングで入っているはずなので、処理しない(コメントアウトして残しておく)
    //    for(int i = 1 ; i <= 5 ; i++)
    //    {
    //      JSONObject setJson = new JSONObject("{}") ;
    //      setJson.put(PARAMKEY.J_DATE.get(), (String)null);
    //      setJson.put(PARAMKEY.J_VALUE.get(), (String)null);
    //      setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_RE_LOOP_RATE_BASE.get()+i, (String)null);
    //    }

    rstWeightInfo = rstWeightInfoJson.toString() ;

    //"null" -> null に変換
    rstWeightInfo = parseJSONObjectNullToNormalNull(rstWeightInfo) ;
    eventLogMessage.setLogMessage("07-10：null置換");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //値の収集 ここまで
    //-----------------------------------------------------

    //-----------------------------------------------------
    //名前部分の置き換え ここから
    //id,cdだけが設定されている状態なので、対応する名称をテーブルから取得、設定する

    //各Jsonの指示者、更新者は、idだけが設定されている状態なので、
    //mst_personal_user(db6)から該当レコードを取得して
    //名前(姓)、名前(名)に設定する

    //置き換えのキー定義(idのキー名および名前(姓)、名前(名)のキー名)
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --start */
//    String[][] keys = {
//        {"ind_user_id","ind_user_last_name","ind_user_first_name"},
//        {"upd_user_id","upd_user_last_name","upd_user_first_name"}
//      } ;
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --end */

    //指示：治療予定指示者情報 ind_schedule_user_info
    //指示：治療予定指示者情報の指示者、更新者の姓名設定
    String indScheduleUserInfo = ordMainData.getIndScheduleUserInfo() ;
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --start */
    /*eventLogMessage.setLogMessage("07-11：指示：治療予定指示者情報の指示者、更新者の姓名設定：パラメータチェック");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-11：指示：治療予定指示者情報の指示者、更新者の姓名設定：パラメータチェック");
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-11：keys" + keys);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-11：facilityCd" + facilityCd);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-11：cryptoFlag" + cryptoFlag);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-11：CAT_JSON_PATTERN" + CAT_JSON_PATTERN.STRING);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    indScheduleUserInfo = fillNamesJson(
        indScheduleUserInfo,
        keys,
        facilityCd,
        cryptoFlag,
        CAT_JSON_PATTERN.STRING
      );

    if(null == indScheduleUserInfo)
    {
      //指示：治療予定指示者情報の指示者、更新者の姓名設定に失敗
      retLogMsg = "指示：治療予定指示者情報の指示者、更新者の姓名設定に失敗しました。"  ;
      retMsg = "治療予定指示者・更新者情報の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }*/
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --end */

    dbgPrint("indScheduleUserInfo:" + indScheduleUserInfo);

    //------------------------------------------------------------
    //指示：治療条件情報             ind_cond_info               キー付きJson {"":{},"":{}・・・・,"":{}}

    //登録者、更新者の名前取得設定
    String indCondInfo = ordMainData.getIndCondInfo() ;
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --start */
    /*eventLogMessage.setLogMessage("07-12：登録者、更新者の名前取得設定：パラメータチェック");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-12：indCondInfo" + indCondInfo);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-12：CAT_JSON_PATTERN" + CAT_JSON_PATTERN.KEYVALUE);
   	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    indCondInfo = fillNamesJson(
          indCondInfo,
          keys,
          facilityCd,
          cryptoFlag,
          CAT_JSON_PATTERN.KEYVALUE
        );

    if(null == indCondInfo)
    {
      //指示：治療条件情報の指示者、更新者の姓名設定に失敗
      retLogMsg = "指示：治療条件情報の指示者、更新者の姓名設定に失敗しました。"  ;
      retMsg = "治療条件指示者・更新者情報の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }*/
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --end */

    dbgPrint("indCondInfo:" + indCondInfo);

    //指示：治療条件情報のJson化
    JSONObject jObj = new JSONObject(indCondInfo) ;

    //------------------------------------------------------------
    //指示：治療条件情報は、valueに値ではなくコードが設定されているものがあり、
    //その場合、コードに対応する名称を翻訳1フィールド(name_1)に設定する
    //(ダイアライザだけは、翻訳2フィールド(name_2)も設定する)
    //------------------------------------------------------------

    //------------------------------------------------------------
    //ダイアライザ系(mst_dialyzerから名称を取得する)
    //    5 ダイアライザ         mst_dialyzer.dialyzer_cd

    // mod FNSI-障害票一覧_患者経過総合ビューアNo.83 李 start
    if (jObj.has(DIALYSISCOND.COND_DIALYZER.get())) {
      JSONObject itemObj = (JSONObject)jObj.get(DIALYSISCOND.COND_DIALYZER.get()) ;
      Integer dialyzerCd = this.parseInteger(getValueFromJson(itemObj, PARAMKEY.COND_VALUE.get())) ;

      //ダイアライザだけ名称が2個:型番(value_name_1用)とメーカー名(value_name_2用)を取得

      //取得したコードを元にダイアライザマスタから名称を取得(DBから)
      eventLogMessage.setLogMessage("07-13：ダイアライザマスタ取得：パラメータチェック");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage.setLogMessage("07-13：facilityCd" + facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage.setLogMessage("07-13：dialyzerCd" + dialyzerCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      Map<String,Object> dialyzerMap = conditionSendResultUtilService.getDialyzerNames(
        facilityCd,
        dialyzerCd) ;
      // TODO: 手動実績作成が失敗するので一旦コメントアウト
      // if(null == dialyzerMap)
      // {
      //   //ダイアライザマスタから名称取得に失敗
      //   retMsg = "ダイアライザマスタから名称取得に失敗しました。facilityCd:%s dialyzerCd:%s"  ;
      //   retMsg = String.format(retMsg, facilityCd,dialyzerCd) ;
      //   // エラーステータス設定
      //   retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      //   // エラーメッセージ設定
      //   retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      //   //異常終了
      //   return null;
      // }
      /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
      if (dialyzerMap != null) {
        //翻訳1:型番
        String dialyzerName = getValueFromMap(dialyzerMap, PARAMKEY.COND_MODEL_NUMBER.get()).toString();
        dialyzerName = dialyzerName == null ? "" : dialyzerName;
        Object useEndDateObj = getValueFromMap(dialyzerMap, PARAMKEY.DATA_USE_END_DATE.get());
        String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
        String isDisp = getValueFromMap(dialyzerMap, PARAMKEY.DATA_IS_DISP.get()).toString();
        String isDel = getValueFromMap(dialyzerMap, PARAMKEY.DATA_IS_DEL.get()).toString();
        String prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, "4", dialyzerCd
                , "5", null, useEndDate, isDisp, isDel, null);
        itemObj.put(PARAMKEY.COND_NAME_1.get(), prefixName + dialyzerName) ;
        //翻訳2:メーカー名
        itemObj.put(PARAMKEY.COND_NAME_2.get(), getValueFromMap(dialyzerMap, PARAMKEY.COND_MAKER.get())) ;
      } else {
        if (dialyzerCd != null) {
          itemObj.put(PARAMKEY.COND_NAME_1.get(), CoreConstant.NamePrefixJapan.DELETED) ;
        }
      }
      /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
    }
    // mod FNSI-障害票一覧_患者経過総合ビューアNo.83 李 end

    /* del by chamaojia 2024-01-25 [10196]  no '39' project --start */
    /*// add FNSI-FutreNetWeb+SI課題管理のNo3917 対応 韓 start
    // 手動実績作成した時に身体情報のDWを治療情報の「指示：治療条件情報」に設定
    if (jObj.has(DIALYSISCOND.COND_DW.get())) {
      JSONObject itemObj = (JSONObject)jObj.get(DIALYSISCOND.COND_DW.get());
      itemObj.put(PARAMKEY.COND_VALUE.get(), rstDw);
      jObj.put(DIALYSISCOND.COND_DW.get(),itemObj);
    }
    // add FNSI-FutreNetWeb+SI課題管理のNo3917 対応 韓 start*/
    /* del by chamaojia 2024-01-25 [10196]  no '39' project --end */

    //------------------------------------------------------------
    //医療材料系(mst_equipmentから名称を取得する)
    //    6 吸着カラム          mst_equipment.equipment_cd
    //    7 1次膜                 mst_equipment.equipment_cd
    //    8 2次膜                 mst_equipment.equipment_cd
    //    13 血液回路          mst_equipment.equipment_cd
    //    9 穿刺針(A針)  mst_equipment.equipment_cd
    //    10 穿刺針(V針) mst_equipment.equipment_cd
    //    11 穿刺針(SN)  mst_equipment.equipment_cd

    String[] itemListEqu = {
        //吸着カラム
        DIALYSISCOND.COND_ADSORB_EQUIPMENT.get(),
        //1次膜
        DIALYSISCOND.COND_FIRST_FILM.get(),
        //2次膜
        DIALYSISCOND.COND_SECOND_FILM.get(),
        //血液回路
        DIALYSISCOND.COND_BLOOD_CIRCUIT.get(),
        //穿刺針(せんししん)(A針)
        DIALYSISCOND.COND_PUNCTURE_NEEDLE_A.get(),
        //穿刺針(せんししん)(V針)
        DIALYSISCOND.COND_PUNCTURE_NEEDLE_V.get(),
        //穿刺針(せんししん)(SN針)
        DIALYSISCOND.COND_PUNCTURE_NEEDLE_SN.get()
    };

    /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
    /* modify by chamaojia 2024-01-26 [10196] Change the name of the method being called --start */
    boolean retEq = setIndCondInfoNamesAndUnit(PARAMKEY.COND_CAT_EQUIP.get(),facilityCd,itemListEqu,jObj
            , patTabooAllergyInfo, tabooAllergyList) ;
    /* modify by chamaojia 2024-01-26 [10196] Change the name of the method being called --end */
    /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
    eventLogMessage.setLogMessage("07-14：医療材料の名称情報取得設定成功有無：" + retEq);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!retEq)
    {
      //医療材料の名称情報取得設定に失敗
      retLogMsg = "医療材料の名称情報取得設定に失敗しました。" ;
      retMsg = "医療材料名の取得に失敗しました。" ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //------------------------------------------------------------
    //VA系(mst_vaから名称を取得する)
    //    2 VA  mst_va.va_cd

    String[] itemListVA = {
        //VA
        DIALYSISCOND.COND_VA.get()
    };

    /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
    /* modify by chamaojia 2024-01-26 [10196] Change the name of the method being called --start */
    boolean retVa = setIndCondInfoNamesAndUnit(PARAMKEY.COND_CAT_VA.get(),facilityCd,itemListVA,jObj
            , patTabooAllergyInfo, tabooAllergyList) ;
    /* modify by chamaojia 2024-01-26 [10196] Change the name of the method being called --end */
    /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
    eventLogMessage.setLogMessage("07-15：VAの名称情報取得設定成功有無：" + retVa);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!retVa)
    {
      //VAの名称情報取得設定に失敗
      retLogMsg = "VAの名称情報取得設定に失敗しました。" ;
      retMsg = "VA名の取得に失敗しました。" ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    /* add by chamaojia 2024-01-26 [10196] Add fixed value name translation --start */
    /**
     * Fixed name translation
     *   12  シングルニードル    "1"：使用する  "0"：使用しない
     *   21  補液選択          "1"：前補液  "2"：後補液
     *   29  IP使用選択        "1"：使用する  "0"：使用しない
     *   30  IPスタート        "0"：手動  "1"：自動
     *   34  IPワンショットスタート    "1"：自動  "0"：手動
     *   35  IP電源自動切り     "0"：切   "1"：入
     *   37  IP電源OKモニタ切り  "0"：切   "1"：入
     */
    String[] itemListToFixedName = {
            // シングルニードル
            DIALYSISCOND.COND_SINGLE_NEEDLE.get(),
            // 補液選択
            DIALYSISCOND.COND_REPLENISH_SELECT.get(),
            // IP使用選択
            DIALYSISCOND.COND_IP_SELECT.get(),
            // IPスタート
            DIALYSISCOND.COND_IP_START.get(),
            // IPワンショットスタート
            DIALYSISCOND.COND_IP_ONESHOT_START.get(),
            // IP電源自動切り
            DIALYSISCOND.COND_IP_AUTO_POWER_OFF.get(),
            // IP電源OKモニタ切り
            DIALYSISCOND.COND_IP_AUTO_MONITOR_OFF.get()
    };
    setIndCondInfoNames(itemListToFixedName, jObj);
    /* add by chamaojia 2024-01-26 [10196] Add fixed value name translation --end */

    //------------------------------------------------------------
    //薬剤系(mst_medicineまたはmst_medicine_mixから名称を取得する)
    //1.薬剤区分(1: 通常薬剤、2: 調製薬剤)で取得先テーブルを選択して名称セット
    //    15 透析液             mst_medicine.medicine_cd or mst_preparation_medicine.preparation_medicine_cd
    //    19 補液                 mst_medicine.medicine_cd or mst_preparation_medicine.preparation_medicine_cd
    //    25 抗凝固剤         mst_medicine.medicine_cd or mst_preparation_medicine.preparation_medicine_cd

    String[] itemListMedic = {
        //透析液
        DIALYSISCOND.COND_DIALYZE_LIQUID.get(),
        //補液
        DIALYSISCOND.COND_REPLENISH_LIQUID.get(),
        //抗凝固剤
        DIALYSISCOND.COND_ANTICOAGULAN_LIQUID.get()
    };

    //overloaded method(setIndCondInfoNames) ※オーバーロードしてます
    //TODO:薬剤マスタまたは調製薬剤マスタからデータを取得する実装となっている。条件はjobjの当該項目medicineType。
    //TODO:調製薬剤が取られるのは実装時は抗凝固剤のみのため、透析液・補液の調製薬剤取得による動作保証無し
    /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
    boolean retMedic = setIndCondInfoNames(facilityCd,itemListMedic,jObj
            , patTabooAllergyInfo, tabooAllergyList, indDdeviceMode) ;
    /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
    eventLogMessage.setLogMessage("07-16：薬剤の名称情報取得設定成功有無：" + retMedic);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!retMedic)
    {
      //薬剤の名称情報取得設定に失敗
      retLogMsg = "薬剤の名称情報取得設定に失敗しました。" ;
      retMsg = "薬剤名の取得に失敗しました。" ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //------------------------------------------------------------
    //2.jobj(治療条件)に対して項目によってunit（単位)のセットとvalue(数値)に対する小数点以下桁数の付与処理を行う
    //    17 透析液使用数   15:透析液コードよりunit_second/unit及び unit_decimal_point_second/unit_decimal_pointを取得
    //    22 補液使用数     19:補液コードよりunit_second/unit及び unit_decimal_point_second/unit_decimal_pointを取得
    //    26 抗凝固剤ワンショット量   25:抗凝固剤コードよりunit及び unit_decimal_pointを取得
    //    27 抗凝固剤持続速度        25:抗凝固剤コードよりunit及び unit_decimal_pointを取得
    //    28 抗凝固剤持続総量        25:抗凝固剤コードよりunit及び unit_decimal_pointを取得
    //    15 透析液    unit
    //    19 補液    unit
    //    25 抗凝固剤    unit
    //    ※透析液及び補液は調製薬剤にセットされない想定だが、セットされた場合にはレセ単位が無いため通常の値を表示する仕様としている

    String[] itemListUnitAndPoint = {
      //透析液使用数
      DIALYSISCOND.COND_DIALYZE_MEASURE.get(),
      //補液使用数
      DIALYSISCOND.COND_REPLENISH_USE.get(),
      //抗凝固剤ワンショット量
      DIALYSISCOND.COND_ANTICOAGULAN_ONESHOT.get(),
      //抗凝固剤持続速度
      DIALYSISCOND.COND_ANTICOAGULAN_SPEED.get(),
      //抗凝固剤持続総量
      DIALYSISCOND.COND_ANTICOAGULAN_TOTAL.get(),
      /* add by chamaojia 2024-01-26 [10196] Add translation for units' 15 ',' 19 ', and' 25 ' --start */
      // 透析液
      DIALYSISCOND.COND_DIALYZE_LIQUID.get(),
      // 補液
      DIALYSISCOND.COND_REPLENISH_LIQUID.get(),
      // 抗凝固剤
      DIALYSISCOND.COND_ANTICOAGULAN_LIQUID.get()
      /* add by chamaojia 2024-01-26 [10196] Add translation for units' 15 ',' 19 ', and' 25 ' --end */
    };

    // 基本処理はsetIndCondInfoNamesをベースとし、nameの代わりにunit値とvalueの小数点桁数のセットを行う
    // TODO:薬剤マスタまたは調製薬剤マスタからデータを取得する実装となっている。
    //      条件はjobjの対応項目medicineType(例:透析液使用数なら対応する透析液のmedicineType)
    boolean retUnit = setIndCondInfoUnitAndPoint(facilityCd,itemListUnitAndPoint,jObj) ;
    eventLogMessage.setLogMessage("07-17：薬剤の単位及び小数点桁数制御：" + retUnit);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!retUnit)
    {
      //薬剤の名称情報取得設定に失敗
      retLogMsg = "薬剤の単位及び小数点桁数制御設定に失敗しました。" ;
      retMsg = "薬剤情報の取得に失敗しました。" ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    /* add by chamaojia 2024-01-26 [10196] Default and initial value settings --start */
    for (String key : jObj.keySet()) {
      JSONObject content = (JSONObject)jObj.get(key);
      // Default Unit Supplement
      if (content.has(PARAMKEY.COND_VALUE.get()) && content.get(PARAMKEY.COND_VALUE.get()) != null
              && !"".equals(TreatmentItemsDef.getDefaultUnit(key))) {
        content.put(PARAMKEY.COND_UNIT.get(), TreatmentItemsDef.getDefaultUnit(key));
      }
      // Initial value settings for unit and translation names
      if (!content.has(PARAMKEY.COND_UNIT.get())) {
        content.put(PARAMKEY.COND_UNIT.get(), JSONObject.NULL);
      }
      if (!content.has(PARAMKEY.COND_NAME_1.get())) {
        content.put(PARAMKEY.COND_NAME_1.get(), JSONObject.NULL);
      }
      // add 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる zkm start
      if (key.equals(DIALYSISCOND.COND_DIALYZER.get())) {
        if (!content.has(PARAMKEY.COND_NAME_2.get())) {
          content.put(PARAMKEY.COND_NAME_2.get(), JSONObject.NULL);
        }
      }
      // add 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる zkm end
    }
    /* add by chamaojia 2024-01-26 [10196] Default and initial value settings --end */

    //指示：治療条件情報のJson化したものをStringに戻す
    indCondInfo = jObj.toString();

    //------------------------------------------------------------
    //指示：投与薬剤情報             ind_medi_info              配列Json [{},{},・・・{}]
    String indMediInfo = ordMainData.getIndMediInfo() ;
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --start */
    /*indMediInfo = fillNamesJson(
            indMediInfo,
            keys,
            facilityCd,
            cryptoFlag,
            CAT_JSON_PATTERN.DIM
          );

    eventLogMessage.setLogMessage("07-18：指示：投与薬剤情報の指示者、更新者の姓名設定：" + indMediInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == indMediInfo)
    {
      //指示：投与薬剤情報の指示者、更新者の姓名設定に失敗
      retLogMsg = "指示：投与薬剤情報の指示者、更新者の姓名設定に失敗しました。"  ;
      retMsg = "投与薬剤情報の指示者、更新者の設定に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }*/
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --end */

    dbgPrint("indMediInfo:" + indMediInfo);

    //投与薬剤情報の穴埋め(ユーザ名関連以外)
    //  薬剤分類コード          mst_medicine.class_cd             or mst_preparation_medicine.class_cd
    //  薬剤分類名               mst_medicine_class.class_name
    //  分類区分                   mst_medicine_class.class_type
    //  薬剤名                       mst_medicine.medicine_name        or mst_preparation_medicine.preparation_medicine_name
    //  省略薬剤名               mst_medicine.medicine_short_name  or mst_preparation_medicine.preparation_medicine_short_name
    //  単位                           mst_medicine.unit                 or mst_preparation_medicine.unit
    //  投与タイミング名称     mst_medicate_timing.medicate_timing_name
    //  手技名称                   mst_procedure.pricedure_name
    //実施情報のキー追加   TODO:済 実績のみに入れるように制御
    //  投与実施フラグ  未実施 ※0：未実施、1：実施済み → 0
    //  投与実施日時 ※ISO8601形式 → null
    //  投与実施者コード → null
    //  投与実施者名_姓 → null
    //  投与実施者名_名 → null


    //実績：投与薬剤情報の格納変数
    String rstMediInfo = null ;
    //投与薬剤情報の穴埋め処理
    /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
    Map<String,String> mapMediInfo = setMedicineInfo(indMediInfo,rstMediInfo,facilityCd
            , patTabooAllergyInfo, tabooAllergyList) ;
    /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
    eventLogMessage.setLogMessage("07-18：指示：投与薬剤情報の指示者、更新者の姓名設定：" + indMediInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == mapMediInfo)
    {
      //指示：投与薬剤情報の名称設定に失敗
      retLogMsg = "指示：投与薬剤情報の名称設定に失敗しました。"  ;
      retMsg = "投与薬剤名の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //指示:投与薬剤情報用の値の取得
    indMediInfo = mapMediInfo.get(PARAMKEY.MEDI_IND_INFO.get()) ;
    //実績:投与薬剤情報用の値の取得
    rstMediInfo = mapMediInfo.get(PARAMKEY.MEDI_RST_INFO.get()) ;

    //再送信の場合の追加処理
    if(reSendFlag && ordMainData.getRstMediInfo() != null)
    {
      //再送信時は、実績:投薬情報の投薬済み(投与実施フラグ:"1")の情報は残して、ここまでで名称穴埋め+実施情報の付加の終わっている実績:投薬情報へマージする
      eventLogMessage.setLogMessage("07-20-1：指示：投与薬剤情報：");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage.setLogMessage("07-20-1：ordMainData.getRstMediInfo()：" + ordMainData.getRstMediInfo());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage.setLogMessage("07-20-1：rstMediInfo：" + rstMediInfo);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      rstMediInfo = mergeRstMediIntoIndMedi(ordMainData.getRstMediInfo(),rstMediInfo) ;
    }

    //"null" -> null 変換
    indMediInfo = parseJSONObjectNullToNormalNull(indMediInfo) ;
    eventLogMessage.setLogMessage("07-20：null置換");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    dbgPrint("indMediInfo:" + indMediInfo);


    //TODO:ここからレビュー再開2019.03.19
    //------------------------------------------------------------
    //指示：医療材料情報             ind_equip_info              配列Json [{},{},・・・{}]
    String indEquipInfo = ordMainData.getIndEquipInfo() ;
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --start */
    /*indEquipInfo = fillNamesJson(
            indEquipInfo,
            keys,
            facilityCd,
            cryptoFlag,
            CAT_JSON_PATTERN.DIM
          );

    eventLogMessage.setLogMessage("07-21：医療材料情報の指示者、更新者の姓名設定" + indEquipInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == indEquipInfo)
    {
      //指示：医療材料情報の指示者、更新者の姓名設定に失敗
      retLogMsg = "指示：医療材料情報の指示者、更新者の姓名設定に失敗しました。"  ;
      retMsg = "医療材料の指示者、更新者の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }*/
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --end */

    dbgPrint("indEquipInfo:" + indEquipInfo);

    //指示：医療材料情報の穴埋め
    //  医療材料分類コード       mst_equipment.class_cd
    //  医療材料分類名            mst_equipment_class.class_name
    //  分類区分                        mst_equipment_class.class_type
    //  医療材料名                    mst_equipment.equipment_name
    //  省略医療材料名            mst_equipment.equipment_short_name
    //  単位                                mst_equipment.unit
    /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
    indEquipInfo = setEquipmentInfo(indEquipInfo,facilityCd, patTabooAllergyInfo, tabooAllergyList) ;
    /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */

    if(null == indEquipInfo)
    {
      //指示：医療材料情報の名称設定に失敗
      retLogMsg = "指示：医療材料情報の名称設定に失敗しました。"  ;
      retMsg = "医療材料名の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //"null" -> null 変換
    indEquipInfo = parseJSONObjectNullToNormalNull(indEquipInfo) ;
    eventLogMessage.setLogMessage("07-22：null置換");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    dbgPrint("indEquipInfo:" + indEquipInfo);

    //------------------------------------------------------------
    //指示：指示コメント情報           ind_ind_comment_info        配列Json [{},{},・・・{}]
    String indIndCommentInfo = ordMainData.getIndIndCommentInfo() ;
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --start */
    /*indIndCommentInfo = fillNamesJson(
            indIndCommentInfo,
            keys,
            facilityCd,
            cryptoFlag,
            CAT_JSON_PATTERN.DIM
          );

    eventLogMessage.setLogMessage("07-23：指示：指示コメント情報の指示者、更新者の姓名設定" + indIndCommentInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == indIndCommentInfo)
    {
      //指示：指示コメント情報の指示者、更新者の姓名設定に失敗
      retLogMsg = "指示：指示コメント情報の指示者、更新者の姓名設定に失敗しました。"  ;
      retMsg = "指示コメント情報の指示者、更新者の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }*/
    /* del by chamaojia 2024-01-25 [10196]  Name translation does not need to be processed here --end */

    //"null" -> null 変換
    indIndCommentInfo = parseJSONObjectNullToNormalNull(indIndCommentInfo) ;
    eventLogMessage.setLogMessage("07-24：null置換");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    dbgPrint("indIndCommentInfo:" + indIndCommentInfo);

    //名前部分の置き換え ここまで
    //-----------------------------------------------------

    // add FNSI-実績：登録区分の修正 徐 start
    //実績：登録区分 -> 「クライアントで手入力して作成」
    // Short rstInputClass = Short.valueOf(CONSTDEF.RST_INPUT_CLASS_MANUAL.get());
    //実績：登録区分 -> 通常(透析装置や通信サーバーなどを伴う治療)
    Short rstInputClass;
    if (StringUtils.isNullOrEmpty(rstDialysisState)) {
      // 実績：登録区分 -> 「透析装置や通信サーバーなどを伴う治療」
      rstInputClass = Short.valueOf(CONSTDEF.RST_INPUT_CLASS_DEFAULT.get());
    } else {
      //実績：登録区分 -> 「クライアントで手入力して作成」
      rstInputClass = Short.valueOf(CONSTDEF.RST_INPUT_CLASS_MANUAL.get());
    }
    // add FNSI-実績：登録区分の修正 徐 end
    eventLogMessage.setLogMessage("07-25：実績：登録区分取得" + rstInputClass);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //-----------------------------------------------------
    //指示:風袋補正→実績:風袋補正への展開

    String rstTareInfo = extendIndTareInfoToRstTareInfo(
                            ordMainData.getIndTareInfo(),
                            ordMainData.getRstTareInfo()
                          ) ;

    eventLogMessage.setLogMessage("07-26：指示:風袋補正→実績:風袋補正への展開" + rstTareInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == rstTareInfo)
    {
      //指示:風袋補正→実績:風袋補正への展開に失敗
      retLogMsg = "指示:風袋補正→実績:風袋補正への展開に失敗しました。"  ;
      retMsg = "風袋情報の展開に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //風袋の実績展開 ここまで
    //-----------------------------------------------------


    /* del by chamaojia 2024-01-25 [10196]  'rst_device_set_info'  is no longer in use --start */
    //-----------------------------------------------------
    //指示:装置設定→実績:装置設定への展開 :TODO:済 2019.03.27 try-catch
    // 指示:装置設定とpat_mainの装置設定を単純マージして実績:装置設定へ設定する

    /*String rstDeviceSetInfo = extendIndDeviceSetInfoToRstDeviceSetInfo(
                            ordMainData.getIndDeviceSetInfo(),
                            patMainData.getDevice_set_info()
                          ) ;

    eventLogMessage.setLogMessage("07-27：指示:装置設定→実績:装置設定への展開" + rstDeviceSetInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == rstDeviceSetInfo)
    {
      //指示:装置設定→実績:装置設定への展開に失敗
      retLogMsg = "指示:装置設定→実績:装置設定への展開に失敗しました。"  ;
      retMsg = "装置設定の展開に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }*/
    /* del by chamaojia 2024-01-25 [10196]  'rst_device_set_info'  is no longer in use --end */

    //指示:装置設定→実績:装置設定への展開 ここまで
    //-----------------------------------------------------

    //-----------------------------------------------------
    //値の格納
    //ord_mainを更新するために、ord_mainエンティティを組み立てる

    //格納先:ordMainエンティティ
    eventLogMessage.setLogMessage("07-28：ord_main更新に必要なoutOrdMain値を作成開始(指示)");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    OrdMain outOrdMain = new OrdMain() ;

    //システムで管理する一意なオーダ番号   ord_no
    //更新キーとしてセット
    outOrdMain.setOrdNo(ordNo) ;
    //変更しない       システムで管理する一意な患者ID    pat_id
    //変更しない       FNW+で管理する施設内の一意な患者ID    fn_pat_id
    //変更しない       治療日 treat_date
    //変更しない       治療曜日    treat_week
    //変更しない       施設コード   facility_cd
    //    施設名 facility_name
    outOrdMain.setFacilityName(facilityName);
    //変更しない           指示：VAコード    ind_va_cd
    //変更しない           指示：治療方法コード  ind_treatment_cd
    //    指示：治療方法名    ind_treatment_name
    outOrdMain.setIndTreatmentName(indTreatmentName);
      /* add by shiyw 2024-01-29 [#10196] --start */
    outOrdMain.setIndDeviceMode(indDdeviceMode);
      /* add by shiyw 2024-01-29 [#10196] --start */
    //変更しない               指示：クールコード   ind_kur_cd
    //    指示：クール名 ind_kur_name
    outOrdMain.setIndKurName(indKurName);
    //変更しない    指示：治療開始時刻   ind_treat_start_time
    //変更しない    指示：ベッドコード   ind_bed_cd
    //    指示：ベッド名 ind_bed_name
    outOrdMain.setIndBedName(indBedName);
    //    指示：治療予定指示者情報    ind_schedule_user_info
    outOrdMain.setIndScheduleUserInfo(indScheduleUserInfo);
    //    指示：治療条件情報   ind_cond_info
    outOrdMain.setIndCondInfo(indCondInfo);
    //    指示：投与薬剤情報   ind_medi_info
    outOrdMain.setIndMediInfo(indMediInfo);
    //    指示：医療材料情報   ind_equip_info
    outOrdMain.setIndEquipInfo(indEquipInfo);
    //    指示：指示コメント情報 ind_ind_comment_info
    outOrdMain.setIndIndCommentInfo(indIndCommentInfo);
    // mod 10705 条件送信、手動実績作成治療法特殊浄化はind_dw rst_dwに値を与えない 関  start
    // add FNSI-身体情報のDWを取得して、ind_dwおよびrst_dwに展開保存する。 徐 start
    if (ordIndCondInfo.has("3")) {
      outOrdMain.setIndDw(BigDecimal.valueOf(rstDw));
    }
    // add FNSI-身体情報のDWを取得して、ind_dwおよびrst_dwに展開保存する。 徐 end
    // mod 10705 条件送信、手動実績作成治療法特殊浄化はind_dw rst_dwに値を与えない 関  end
    //mod #10443 身体情報・DW・目標体重バグ全体見直し対応 朴 start
    outOrdMain.setIndDwUserInfo(indDwUserInfo);
    //mod #10443 身体情報・DW・目標体重バグ全体見直し対応 朴 end
    //変更しない        指示：風袋補正 ind_tare_info
    //変更しない        指示：除水補正 ind_off_water_info
    //変更しない        指示：装置設定情報   ind_device_set_info
    //変更しない        実績：FNW+透析番号 rst_fn_dialysis_no
    //変更しない        実績：関連透析番号   rst_relation_dialysis_no
    //変更しない        実績：版番号  rst_edition
    //変更しない        実績：版番号更新フラグ rst_is_update_edition
    //    実績：登録区分 rst_input_class
    outOrdMain.setRstInputClass(rstInputClass);
    //nullの場合なにもしない  OperateStateで設定     実績：治療状況 rst_dialysis_state
    if(null != rstDialysisState)
    {
      outOrdMain.setRstDialysisState(rstDialysisState);
    }
    eventLogMessage.setLogMessage("07-29：ord_main更新に必要なoutOrdMain値を作成開始(実績)");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //    実績：治療方法コード  rst_treatment_cd
    outOrdMain.setRstTreatmentCd(ordMainData.getIndTreatmentCd());
    //    実績：治療方法名    rst_treatment_name
    outOrdMain.setRstTreatmentName(outOrdMain.getIndTreatmentName());
    //    実績：クールコード   rst_kur_cd
    outOrdMain.setRstKurCd(ordMainData.getIndKurCd());
    //    実績：クール名 rst_kur_name
    outOrdMain.setRstKurName(outOrdMain.getIndKurName());
    //    実績：ベッドコード   rst_bed_cd
	//mod 8347【デグレ】????患者治療割り当てができない zhao start
    //outOrdMain.setRstBedCd(ordMainData.getIndBedCd());
    outOrdMain.setRstBedCd(ordMainData.getIndBedCd().longValue());
	//mod 8347【デグレ】????患者治療割り当てができない zhao end
    //    実績：ベッド名 rst_bed_name
    outOrdMain.setRstBedName(outOrdMain.getIndBedName());
    //    実績：装置番号 rst_machine_no
    outOrdMain.setRstMachineNo(rstMachineNo);
    //    実績：装置名  rst_machine_name
    outOrdMain.setRstMachineName(rstMachineName);
    //    実績：条件送信日時   rst_cond_send_date
    outOrdMain.setRstCondSendDate(rstCondSendDate);
    //変更しない           実績：受付日時 rst_accept_date
    //変更しない           実績：治療開始日時   rst_start_date
    //変更しない           実績：治療終了日時   rst_end_date
    //変更しない           実績：帰宅日時 rst_return_home_date
    //    実績：入外区分 rst_in_out_class
    outOrdMain.setRstInOutClass(rstInOutClass);
    // add FNSI-特殊血液浄化回数がカウントしない 徐 start

    if (isDeviceModeIsPureOrNot) {
      //    実績：特殊浄化回数
      outOrdMain.setRstPurificationCnt(rstDialysisCnt);
    } else {
      //    実績：透析回数 rst_dialysis_cnt
      outOrdMain.setRstDialysisCnt(rstDialysisCnt);
    }
    // add FNSI-特殊血液浄化回数がカウントしない 徐 end
    //    実績：病棟コード    rst_ward_cd
    outOrdMain.setRstWardCd(rstWardCd);
    //    実績：病棟名  rst_ward_name
    outOrdMain.setRstWardName(rstWardName);
    //    実績：診療科コード   rst_course_cd
    // FNSI-add 診療科表示不正 徐 start
    // outOrdMain.setRstCourseCd(rstWardCd);
    outOrdMain.setRstCourseCd(rstCourseCd);
    // FNSI-add 診療科表示不正 徐 end
    //    実績：診療科名 rst_course_name
    outOrdMain.setRstCourseName(rstCourseName);
    //    実績：DW   rst_dw
    // mod 10705 条件送信、手動実績作成治療法特殊浄化はind_dw rst_dwに値を与えない 関  start
    if (ordIndCondInfo.has("3")) {
      outOrdMain.setRstDw(BigDecimal.valueOf(rstDw));
    }
    // mod 10705 条件送信、手動実績作成治療法特殊浄化はind_dw rst_dwに値を与えない 関  end
    //変更しない              実績：穿刺者情報    rst_puncture_user_info
    //変更しない              実績：返血者情報    rst_return_user_info
    //変更しない              実績：担当者情報    rst_charge_user_info
    //変更しない              実績：血液循環積算値  rst_blood_circulate_total
    //変更しない              実績：透析運転時間   rst_running_time
    //変更しない              実績：Kt/V rst_kt_v
    //変更しない              実績：透析記録確認日時 rec_set_date
    //変更しない              実績：送信管理番号   send_ctl_no
    //    実績：血液浄化装置名称 blood_purifier_name
    outOrdMain.setBloodPurifierName(bloodPurifierName);
    //変更しない             実績：プログラム補液引き残し量 pull_leave_amount
    //    実績：治療条件情報   rst_cond_info
    // 目標体重が「-1」の場合、DWの値を設定
    // mod bug 6968 修正 chen start
    JSONObject rstCondInfo = null == outOrdMain.getIndCondInfo() ?
      new JSONObject() :
      new JSONObject(outOrdMain.getIndCondInfo());
    // JSONObject rstCondInfo = new JSONObject(outOrdMain.getIndCondInfo());
    // mod bug 6968 修正 chen end
    if (true == rstCondInfo.has(DIALYSISCOND.COND_TW.get())) {
      JSONObject twInfo = new JSONObject(rstCondInfo.get(DIALYSISCOND.COND_TW.get()).toString());
      if (
        "-1".equals(String.valueOf(getValueFromJson(twInfo, PARAMKEY.COND_VALUE.get()))) ||
        "null".equals(String.valueOf(getValueFromJson(twInfo, PARAMKEY.COND_VALUE.get())))
      ) {
        // mod #10824 手動実際作成する時、rst_cond_infoの[3].value値が０ではなく、"0.00"を転換する zkm start
//        twInfo.put(PARAMKEY.COND_VALUE.get(), rstDw);
        twInfo.put(PARAMKEY.COND_VALUE.get(), String.format("%.2f", rstDw));
        // mod #10824 手動実際作成する時、rst_cond_infoの[3].value値が０ではなく、"0.00"を転換する zkm end
        rstCondInfo.put(DIALYSISCOND.COND_TW.get(), twInfo);
      }
    }
    // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen start
    if (rstCondInfo.has(DIALYSISCOND.COND_REPLENISH_MEASURE.get()) && rstCondInfo.has(DIALYSISCOND.COND_REPLENISH_SPEED.get())) {

      JSONObject condReplenishMeasure = new JSONObject(rstCondInfo.get(DIALYSISCOND.COND_REPLENISH_MEASURE.get()).toString());
      JSONObject condReplenishSpeed = new JSONObject(rstCondInfo.get(DIALYSISCOND.COND_REPLENISH_SPEED.get()).toString());

      if ("-1".equals(String.valueOf(getValueFromJson(condReplenishMeasure, PARAMKEY.COND_VALUE.get()))) &&
        "-1".equals(String.valueOf(getValueFromJson(condReplenishSpeed, PARAMKEY.COND_VALUE.get())))) {
        JSONObject deviceSetInfo = new JSONObject(patMainData.getDevice_set_info());

        Double QB = 0d;
        Double Ht = 0d;
        Double TP = 0d;
        Double FF = 0d;
        Double QUF = 0d;
        //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao start
        Double DT = 0d;
        //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao end

        JSONObject condReplenishSelect = new JSONObject(rstCondInfo.get(DIALYSISCOND.COND_REPLENISH_SELECT.get()).toString());

        if (deviceSetInfo != null && deviceSetInfo.length() != 0){
          if ("1".equals(String.valueOf(getValueFromJson(condReplenishSelect, PARAMKEY.COND_VALUE.get())))) {
            // "前補液"
            FF = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
              .getJSONObject("dev")
              .getJSONObject("A").get("90").toString());
          } else {
            // "後補液"
            FF = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
              .getJSONObject("dev")
              .getJSONObject("B").get("40").toString());
          }
          Ht = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
            .getJSONObject("dev")
            .getJSONObject("A").get("91").toString());
          TP = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
            .getJSONObject("dev")
            .getJSONObject("A").get("92").toString());
          //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao start
          DT = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
            .getJSONObject("dev")
            .getJSONObject("A").get("398").toString());
          //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao end
        }

        if (rstCondInfo.has(DIALYSISCOND.COND_BLOOD_MEASURE.get()) && !rstCondInfo.isNull(DIALYSISCOND.COND_BLOOD_MEASURE.get())) {
          JSONObject condTimeJson = (JSONObject) rstCondInfo.get(DIALYSISCOND.COND_BLOOD_MEASURE.get());
          QB = condTimeJson.getDouble(PARAMKEY.COND_VALUE.get());
        }

        // 前体重
        //mod  #10881 補液設定が「濾過率から算出」かつ透析前体重の小数点以下がX.00の場合に指示展開エラーが発生する。 start
//        Double weigheBefore = rstWeightInfoJson.isNull("weight_before") ? 0d : (Double)rstWeightInfoJson.get("weight_before");
        Double weigheBefore = rstWeightInfoJson.isNull("weight_before") ? 0d : rstWeightInfoJson.optDouble("weight_before", 0d);
        //mod  #10881 補液設定が「濾過率から算出」かつ透析前体重の小数点以下がX.00の場合に指示展開エラーが発生する。 end

        // 目標体重
        Double targetWeight = 0d;
        if (rstCondInfo.has(DIALYSISCOND.COND_TW.get()) && !rstCondInfo.isNull(DIALYSISCOND.COND_TW.get())) {
          JSONObject condTimeJson = (JSONObject) rstCondInfo.get(DIALYSISCOND.COND_TW.get());
          targetWeight = condTimeJson.getDouble(PARAMKEY.COND_VALUE.get());
        }

        // 透析時間
        Double condTime = 0d;
        if (rstCondInfo.has(DIALYSISCOND.COND_TOTAL_TIME.get()) && !rstCondInfo.isNull(DIALYSISCOND.COND_TOTAL_TIME.get())) {
          JSONObject condTimeJson = (JSONObject) rstCondInfo.get(DIALYSISCOND.COND_TOTAL_TIME.get());
          condTime = condTimeJson.getDouble(PARAMKEY.COND_VALUE.get());
        }
        //add 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao start
        Double dd = 0d;
        if (rstCondInfo.has(DIALYSISCOND.COND_REMOVE_WATER_LIMIT.get()) && !rstCondInfo.isNull(DIALYSISCOND.COND_REMOVE_WATER_LIMIT.get())) {
          JSONObject condTimeJson = (JSONObject) rstCondInfo.get(DIALYSISCOND.COND_REMOVE_WATER_LIMIT.get());
          dd = condTimeJson.getDouble(PARAMKEY.COND_VALUE.get());
        }
        //add 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao end
        //add 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao start
        JSONObject tereInfo = new JSONObject(ordMainData.getIndTareInfo());
        Integer tereInfoWeight1 = toWeight(tereInfo.get("weight_1").toString());
        Integer tereInfoWeight2 = toWeight(tereInfo.get("weight_2").toString());
        Integer tereInfoWeight3 = toWeight(tereInfo.get("weight_3").toString());
        Integer tereInfoWeight4 = toWeight(tereInfo.get("weight_4").toString());
        Integer tereInfoWeight5 = toWeight(tereInfo.get("weight_5").toString());
        Integer tereInfoWeightAmount = tereInfoWeight1+tereInfoWeight2+tereInfoWeight3+tereInfoWeight4+tereInfoWeight5;
        JSONObject offWaterInfo = new JSONObject(ordMainData.getIndOffWaterInfo());
        Integer offWaterInfoWeight1 = toWeight(offWaterInfo.get("weight_1").toString());
        Integer offWaterInfoWeight2 = toWeight(offWaterInfo.get("weight_2").toString());
        Integer offWaterInfoWeight3 = toWeight(offWaterInfo.get("weight_3").toString());
        Integer offWaterInfoWeight4 = toWeight(offWaterInfo.get("weight_4").toString());
        Integer offWaterInfoWeight5 = toWeight(offWaterInfo.get("weight_5").toString());
        Integer offWaterInfoWeightAmount = offWaterInfoWeight1+offWaterInfoWeight2+offWaterInfoWeight3+offWaterInfoWeight4+offWaterInfoWeight5;
        //add 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao end

        // 除水速度
        //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao start
        //QUF = (weigheBefore - targetWeight) / (condTime / 60);
        Double ddRel = weigheBefore + Double.parseDouble(offWaterInfoWeightAmount.toString())/1000  - targetWeight;
        if( ddRel> dd){
          QUF = dd / (condTime / 60);
        }else{
          QUF = ddRel / (condTime / 60);
        }
        QUF = Double.parseDouble(new BigDecimal(QUF).setScale(4,BigDecimal.ROUND_UP).toString());
        //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao end

        //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao start
        //Double QPW = ((100 - Ht) / 100) * (1 - (0.0107 * TP)) * QB;
        Double QPW = ((100 - Ht) / 100) * (1 - (0.0107 * TP)) * QB;
        QPW = Double.parseDouble(new BigDecimal(QPW).setScale(1,BigDecimal.ROUND_DOWN).toString());
        //add 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao end

        // 条件から装置情報を取得
        List<MstMachine> machines = mstMachineDao.selectByBedCd(facilityCd, ordMainData.getIndBedCd().longValue());

        // 医器工V3、V4：補液速度、補液量ともに0を展開する。
        if ("3".equals(machines.get(0).getComType().toString())) {
          condReplenishMeasure.put(PARAMKEY.COND_VALUE.get(), "0");
          condReplenishSpeed.put(PARAMKEY.COND_VALUE.get(), "0");
        } else {
          // 新通信、オフライン
          Double value = 0d;
          //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao start
          String valueString = "0";
          String valueSaveString = "0";
          //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao end
          if ("1".equals(String.valueOf(getValueFromJson(condReplenishSelect, PARAMKEY.COND_VALUE.get())))) {
            // "前補液"
            //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao start
            value = ((QPW * 60 / 1000 * FF / 100) - QUF) / (1 - (FF / 100));
            //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao end
          } else {
            // "後補液"
            //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao start
            value = (QPW * 60 / 1000 * FF / 100) - QUF;
            //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao end
          }

          //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao start
          String replenishMeasureString = "0";
          if (rstCondInfo.has(DIALYSISCOND.COND_TOTAL_TIME.get()) && !rstCondInfo.isNull(DIALYSISCOND.COND_REPLENISH_LIQUID.get())) {
            BigDecimal valueDec = new BigDecimal(value);
            valueString = valueDec.setScale(4,BigDecimal.ROUND_UP).toString();
            valueSaveString = valueDec.setScale(2,BigDecimal.ROUND_UP).toString();
            Double replenishMeasure = Double.parseDouble(valueString) * (condTime - DT) / 60;
            BigDecimal replenishMeasureDec = new BigDecimal(replenishMeasure);
            replenishMeasureString = replenishMeasureDec.setScale(1,BigDecimal.ROUND_DOWN).toString();
            //condReplenishMeasure.put(PARAMKEY.COND_VALUE.get(), QPW.toString());
          }
          if(weigheBefore==0){
            replenishMeasureString = "0.0";
            valueSaveString = "0.00";
          }
          condReplenishMeasure.put(PARAMKEY.COND_VALUE.get(), replenishMeasureString);
          //condReplenishSpeed.put(PARAMKEY.COND_VALUE.get(), value.toString());
          condReplenishSpeed.put(PARAMKEY.COND_VALUE.get(), valueSaveString);
          //mod 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 zhao end
        }
        rstCondInfo.put(DIALYSISCOND.COND_REPLENISH_MEASURE.get(), condReplenishMeasure);
        rstCondInfo.put(DIALYSISCOND.COND_REPLENISH_SPEED.get(), condReplenishSpeed);
      }
    }
    // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen end
    /* modify by chamaojia 2024-01-26 [10196] Complete the deletion of user content in the JSON item --start */
    outOrdMain.setRstCondInfo(clearRstToUserInfo(false, rstCondInfo.toString()));
    //    実績：投与薬剤情報   rst_medi_info
    outOrdMain.setRstMediInfo(clearRstToUserInfo(true, rstMediInfo));
    //    実績：医療材料情報   rst_equip_info
    outOrdMain.setRstEquipInfo(clearRstToUserInfo(true, outOrdMain.getIndEquipInfo()));
    //    実績：指示コメント情報 rst_ind_comment_info
    outOrdMain.setRstIndCommentInfo(clearRstToUserInfo(true, outOrdMain.getIndIndCommentInfo()));
    /* modify by chamaojia 2024-01-26 [10196] Complete the deletion of user content in the JSON item --end */
    //    実績：風袋補正 rst_tare_info
    outOrdMain.setRstTareInfo(rstTareInfo);
    //    実績：除水補正 rst_off_water_info
    outOrdMain.setRstOffWaterInfo(ordMainData.getIndOffWaterInfo());
    /* del by chamaojia 2024-01-25 [10196]  'rst_device_set_info'  is no longer in use --start */
    //    実績：装置設定情報   rst_device_set_info
//    outOrdMain.setRstDeviceSetInfo(rstDeviceSetInfo);
    /* del by chamaojia 2024-01-25 [10196]  'rst_device_set_info'  is no longer in use --end */
    //    実績：体重情報 rst_weight_info   ※組み立てて入れる
    outOrdMain.setRstWeightInfo(rstWeightInfo);
    //変更しない                 実績：バイタル情報   rst_vital_info
    //変更しない                 実績：愁訴情報 rst_complaint_info
    //変更しない                 実績：愁訴処置情報   rst_treatment_info
    //変更しない                 実績：愁訴処置者情報  rst_treat_staff_info
    //変更しない                 実績：回診記録情報   rst_rounds_info
    //変更しない                 削除フラグ   is_del
    //    更新日時    up_date    SQLで更新
    //変更しない                 登録日時    reg_date

    /* add by chamaojia 2025-01-16 [11467] add a new assignment for 【rst_device_mode】 --start */
    outOrdMain.setRstDeviceMode(indDdeviceMode);
    /* add by chamaojia 2025-01-16 [11467] add a new assignment for 【rst_device_mode】 --end */

    //終了ログ
    this.exitMethod(className,methodName,null);

    return outOrdMain;
  }

  /* add by chamaojia 2024-01-26 [10196] Clear user information from "rst" --start */
  /**
   * Clear user information from "rst"
   *
   * @param arrayFlag  true: Array
   * @param jsonInfo   JSON to be processed
   * @return
   */
  public String clearRstToUserInfo(boolean arrayFlag, String jsonInfo) {
    if (arrayFlag) {   // Array
        /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
      //JSONArray jsonArray = new JSONArray(jsonInfo);
      JSONArray jsonArray = new JSONArray(ObjectUtils.isEmpty(jsonInfo)? "[]" : jsonInfo);
        /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
      for(int i = 0; i < jsonArray.length(); i++) {
        for(String name: USER_JSON_RELATED_ARRAY) {
          jsonArray.getJSONObject(i).remove(name);
        }
      }
      return jsonArray.toString();
    } else {  // Object
      JSONObject jsonObject = new JSONObject(jsonInfo);
      for(String key : jsonObject.keySet()) {
        for(String name: USER_JSON_RELATED_ARRAY) {
          jsonObject.getJSONObject(key).remove(name);
        }
      }
      return jsonObject.toString();
    }
  }
  /* add by chamaojia 2024-01-26 [10196] Clear user information from "rst" --end */

  /**
   * メインメソッド終了処理
   *    終了ログを出力する。メッセージがnull以外の場合、RuntimeExceptionを投げる
   * @param className   クラス名
   * @param methodName  メソッド名
   * @param retMsg      メッセージ
   */
// mod 11454 時間外加算自動処理が機能していない zkm start
//  void exitMethod(
  public void exitMethod(
// mod 11454 時間外加算自動処理が機能していない zkm end
        String className,
        String methodName,
        String retMsg
      )
  {
    String endMsg = className + "." + methodName + "の処理を終了しました。" ;

    if(null == retMsg)
    {
      //終了ログ
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(endMsg);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }
    else
    {
      //メッセージがnullでなければRuntimeExceptionを投げる(Rollback用)
      //LogLevel.ERRORのログが出ます
      throw new RuntimeException(endMsg+":"+retMsg);
    }
  }

//  /**
//   * @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//   * @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//   * @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//   * @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//   * @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//   * @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//   * @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//   * @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//   */
//  private void buildOrdMainEntity(
//        Long ordNo,
//        OrdMain ordMainData
//      )
//  {
//
//    //------------------------------------------------------------
//    //名称の取得
//    //ord_mainの各コード項目の名称等を該当テーブルから取得する
//    // 施設名       mst_facility
//    // 治療方法名 mst_treatment
//    // クール名      mst_kur
//    // ベッド名       mst_bed
//    // 装置番号    mst_bed
//    // 装置名        mst_machine
//
//    Map<String,Object> namesMap = conditionSendResultUtilService.getNamesFromDbs(ordNo) ;
//
//    if(null == namesMap)
//    {
////      //名称の取得失敗
////      retMsg = "名称の取得に失敗しました  ordNo:%s"  ;
////      retMsg = String.format(retMsg, ordNo) ;
////      // エラーステータス設定
////      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
////      // エラーメッセージ設定
////      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
////      // ロールバック用の例外を投げる
////      exitMethod(className,methodName,retMsg);
//    }
//
//    //各名称の取り出し
//    // 施設名
//    String facilityName = (String)getValueFromMap(namesMap,PARAMKEY.FACILITY_NAME.get()) ;
//    // 指示：治療方法名
//    String indTreatmentName = (String)getValueFromMap(namesMap,PARAMKEY.TREATMANT_NAME.get()) ;
//    // 指示：クール名
//    String indKurName = (String)getValueFromMap(namesMap,PARAMKEY.KUR_NAME.get()) ;
//    // 指示：ベッド名
//    String indBedName = (String)getValueFromMap(namesMap,PARAMKEY.BED_NAME.get()) ;
//    // 実績：装置番号(nullの場合あり)
//    Long rstMachineNo = parseLong(getValueFromMap(namesMap,PARAMKEY.MACHINE_NO.get())) ;
//    // 実績：装置名
//    String rstMachineName = (String)getValueFromMap(namesMap,PARAMKEY.MACHINE_NAME.get()) ;
//
//    //-----------------------------------------------------
//    //名前部分の置き換え ここから
//    //id,cdだけが設定されている状態なので、対応する名称をテーブルから取得、設定する
//
//    //各Jsonの指示者、更新者は、idだけが設定されている状態なので、
//    //mst_personal_user(db6)から該当レコードを取得して
//    //名前(姓)、名前(名)に設定する
//
//    //置き換えのキー定義(idのキー名および名前(姓)、名前(名)のキー名)
//    String[][] keys = {
//        {"ind_user_id","ind_user_last_name","ind_user_first_name"},
//        {"upd_user_id","upd_user_last_name","upd_user_first_name"}
//      } ;
//
//    //指示：治療予定指示者情報 ind_schedule_user_info
//    //指示：治療予定指示者情報の指示者、更新者の姓名設定
//    String indScheduleUserInfo = ordMainData.getIndScheduleUserInfo() ;
//    indScheduleUserInfo = fillNamesJson(
//        indScheduleUserInfo,
//        keys,
//        facilityCd,
//        cryptoFlag,
//        CAT_JSON_PATTERN.STRING
//      );
//
//    if(null == indScheduleUserInfo)
//    {
////      //指示：治療予定指示者情報の指示者、更新者の姓名設定に失敗
////      retMsg = "指示：治療予定指示者情報の指示者、更新者の姓名設定に失敗しました。"  ;
////      // エラーステータス設定
////      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
////      // エラーメッセージ設定
////      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
////      // ロールバック用の例外を投げる
////      exitMethod(className,methodName,retMsg);
//    }
//
//    dbgPrint("indScheduleUserInfo:" + indScheduleUserInfo);
//
//    //----------------------------------------------------------------------------
//
//    //格納先:ordMainエンティティ
//    OrdMain outOrdMain = new OrdMain() ;
//
//    //システムで管理する一意なオーダ番号   ord_no
//    //更新キーとしてセット
//    outOrdMain.setOrdNo(ordNo) ;
//    //変更しない       システムで管理する一意な患者ID    pat_id
//    //変更しない       FNW+で管理する施設内の一意な患者ID    fn_pat_id
//    //変更しない       治療日 treat_date
//    //変更しない       治療曜日    treat_week
//    //変更しない       施設コード   facility_cd
//    //    施設名 facility_name
//    outOrdMain.setFacilityName(facilityName);
//    //変更しない           指示：VAコード    ind_va_cd
//    //変更しない           指示：治療方法コード  ind_treatment_cd
//    //    指示：治療方法名    ind_treatment_name
//    outOrdMain.setIndTreatmentName(indTreatmentName);
//    //変更しない               指示：クールコード   ind_kur_cd
//    //    指示：クール名 ind_kur_name
//    outOrdMain.setIndKurName(indKurName);
//    //変更しない    指示：治療開始時刻   ind_treat_start_time
//    //変更しない    指示：ベッドコード   ind_bed_cd
//    //    指示：ベッド名 ind_bed_name
//    outOrdMain.setIndBedName(indBedName);
//    //    指示：治療予定指示者情報    ind_schedule_user_info
//    outOrdMain.setIndScheduleUserInfo(indScheduleUserInfo);
//    //    指示：治療条件情報   ind_cond_info
//    outOrdMain.setIndCondInfo(indCondInfo);
//    //    指示：投与薬剤情報   ind_medi_info
//    outOrdMain.setIndMediInfo(indMediInfo);
//    //    指示：医療材料情報   ind_equip_info
//    outOrdMain.setIndEquipInfo(indEquipInfo);
//    //    指示：指示コメント情報 ind_ind_comment_info
//    outOrdMain.setIndIndCommentInfo(indIndCommentInfo);
//    //変更しない        指示：風袋補正 ind_tare_info
//    //変更しない        指示：除水補正 ind_off_water_info
//    //変更しない        指示：装置設定情報   ind_device_set_info
//    //変更しない        実績：FNW+透析番号 rst_fn_dialysis_no
//    //変更しない        実績：関連透析番号   rst_relation_dialysis_no
//    //変更しない        実績：版番号  rst_edition
//    //変更しない        実績：版番号更新フラグ rst_is_update_edition
//    //変更しない        実績：登録区分 rst_input_class
//    //OperateStateで設定          実績：治療状況 rst_dialysis_state
//    //    実績：治療方法コード  rst_treatment_cd
//    outOrdMain.setRstTreatmentCd(ordMainData.getIndTreatmentCd());
//    //    実績：治療方法名    rst_treatment_name
//    outOrdMain.setRstTreatmentName(outOrdMain.getIndTreatmentName());
//    //    実績：クールコード   rst_kur_cd
//    outOrdMain.setRstKurCd(ordMainData.getIndKurCd());
//    //    実績：クール名 rst_kur_name
//    outOrdMain.setRstKurName(outOrdMain.getIndKurName());
//    //    実績：ベッドコード   rst_bed_cd
//    outOrdMain.setRstBedCd(ordMainData.getIndBedCd());
//    //    実績：ベッド名 rst_bed_name
//    outOrdMain.setRstBedName(outOrdMain.getIndBedName());
//    //    実績：装置番号 rst_machine_no
//    outOrdMain.setRstMachineNo(rstMachineNo);
//    //    実績：装置名  rst_machine_name
//    outOrdMain.setRstMachineName(rstMachineName);
//    //    実績：条件送信日時   rst_cond_send_date
////    outOrdMain.setRstCondSendDate(mntMachineState.get(0).getCondSendDate());
//    outOrdMain.setRstCondSendDate(null);
//    //変更しない           実績：受付日時 rst_accept_date
//    //変更しない           実績：治療開始日時   rst_start_date
//    //変更しない           実績：治療終了日時   rst_end_date
//    //変更しない           実績：帰宅日時 rst_return_home_date
//    //    実績：入外区分 rst_in_out_class
//    outOrdMain.setRstInOutClass(rstInOutClass);
//    //変更しない           実績：透析回数 rst_dialysis_cnt
//    //    実績：病棟コード    rst_ward_cd
//    outOrdMain.setRstWardCd(rstWardCd);
//    //    実績：病棟名  rst_ward_name
//    outOrdMain.setRstWardName(rstWardName);
//    //    実績：診療科コード   rst_course_cd
//    outOrdMain.setRstCourseCd(rstWardCd);
//    //    実績：診療科名 rst_course_name
//    outOrdMain.setRstCourseName(rstCourseName);
//    //    実績：DW   rst_dw
//    outOrdMain.setRstDw(rstDw);
//    //変更しない              実績：穿刺者情報    rst_puncture_user_info
//    //変更しない              実績：返血者情報    rst_return_user_info
//    //変更しない              実績：担当者情報    rst_charge_user_info
//    //変更しない              実績：血液循環積算値  rst_blood_circulate_total
//    //変更しない              実績：透析運転時間   rst_running_time
//    //変更しない              実績：Kt/V rst_kt_v
//    //変更しない              実績：透析記録確認日時 rec_set_date
//    //変更しない              実績：送信管理番号   send_ctl_no
//    //    実績：血液浄化装置名称 blood_purifier_name
//    outOrdMain.setBloodPurifierName(bloodPurifierName);
//    //変更しない             実績：プログラム補液引き残し量 pull_leave_amount
//    //    実績：治療条件情報   rst_cond_info
//    // 目標体重が「-1」の場合、DWの値を設定
//    JSONObject rstCondInfo = new JSONObject(outOrdMain.getIndCondInfo());
//    if (true == rstCondInfo.has(DIALYSISCOND.COND_TW.get())) {
//      JSONObject twInfo = new JSONObject(rstCondInfo.get(DIALYSISCOND.COND_TW.get()).toString());
//      if ("-1".equals(String.valueOf(getValueFromJson(twInfo, PARAMKEY.COND_VALUE.get())))) {
//        twInfo.put(PARAMKEY.COND_VALUE.get(), rstDw);
//        rstCondInfo.put(DIALYSISCOND.COND_TW.get(), twInfo);
//      }
//    }
//    outOrdMain.setRstCondInfo(rstCondInfo.toString());
//    //    実績：投与薬剤情報   rst_medi_info
//    outOrdMain.setRstMediInfo(rstMediInfo);
//    //    実績：医療材料情報   rst_equip_info
//    outOrdMain.setRstEquipInfo(outOrdMain.getIndEquipInfo());
//    //    実績：指示コメント情報 rst_ind_comment_info
//    outOrdMain.setRstIndCommentInfo(outOrdMain.getIndIndCommentInfo());
//    //    実績：風袋補正 rst_tare_info
//    outOrdMain.setRstTareInfo(rstTareInfo);
//    //    実績：除水補正 rst_off_water_info
//    outOrdMain.setRstOffWaterInfo(ordMainData.getIndOffWaterInfo());
//    //    実績：装置設定情報   rst_device_set_info
//    outOrdMain.setRstDeviceSetInfo(rstDeviceSetInfo);
//    //    実績：体重情報 rst_weight_info   ※組み立てて入れる
//    outOrdMain.setRstWeightInfo(rstWeightInfo);
//    //変更しない                 実績：バイタル情報   rst_vital_info
//    //変更しない                 実績：愁訴情報 rst_complaint_info
//    //変更しない                 実績：愁訴処置情報   rst_treatment_info
//    //変更しない                 実績：愁訴処置者情報  rst_treat_staff_info
//    //変更しない                 実績：回診記録情報   rst_rounds_info
//    //変更しない                 削除フラグ   is_del
//    //    更新日時    up_date    SQLで更新
//    //変更しない                 登録日時    reg_date
//  }


  /**
   * 装置設定展開処理
   *  指示:装置設定とpat_main:装置設定をマージする
   *  ---------------------------------------
   *  指示:装置設定
   *    構造:
   *     {
   *       "dc": {},
   *       "na": {},
   *       "dia": {},
   *       "ufr": {},
   *       "ihdf": {},
   *       "qbqd": {},
   *       "vbufc": {}
   *    }
   *  pat_main:装置設定
   *    構造:
   *    {
   *       "bp": {},
   *       "bv": {},
   *       "ope": {},
   *       "pri": {},
   *       "war": {},
   *       "dfas": {},
   *       "ecum": {}
   *    }
   *  実績:装置設定
   *    構造:
   *     {
   *       "dc": {},
   *       "na": {},
   *       "dia": {},
   *       "ufr": {},
   *       "ihdf": {},
   *       "qbqd": {},
   *       "vbufc": {},
   *       "bp": {},
   *       "bv": {},
   *       "ope": {},
   *       "pri": {},
   *       "war": {},
   *       "dfas": {},
   *       "ecum": {}
   *    }
   * @param indDeviceSetInfo String 指示:装置設定
   * @param deviceSetInfoFromPatMain String pat_main:装置設定
   * @return String 実績:装置設定
   */
  String extendIndDeviceSetInfoToRstDeviceSetInfo(
      String indDeviceSetInfo,
      String deviceSetInfoFromPatMain
  )
  {
    String ret = null ;

    //指示:装置設定を元に実績:装置設定を組み立てる
    JSONObject rstDeviceSetInfoJson = null ;
    JSONObject deviceSetInfoFromPatMainJson = null ;

    try {
      // 指示:装置設定を元に実績:装置設定をJson化
      rstDeviceSetInfoJson = new JSONObject(indDeviceSetInfo) ;
      // ord_main:装置設定をJson化
      deviceSetInfoFromPatMainJson = new JSONObject(deviceSetInfoFromPatMain) ;

      //pat_main:装置設定のすべての要素を実績:装置設定に追加
      for(Iterator<String> i = deviceSetInfoFromPatMainJson.keys() ; i.hasNext();)
      {
        String key = i.next() ;
        // 要素の取得&追加
        rstDeviceSetInfoJson.put(key, deviceSetInfoFromPatMainJson.get(key)) ;
      }

      ret = rstDeviceSetInfoJson.toString() ;
    }
    catch(Exception e)
    {
      //これは、終了させるレベルのエラーなので詳細ログを出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      ret = null ;
    }
    //実績:装置設定を返却
    return ret ;
  }

  /**
   * 風袋補正展開処理
   *  指示:風袋補正を実績:風袋補正に展開する。
   *      1.キー before,afterが実績になければ作成
   *          どちらにも、指示:風袋補正をそのままコピー
   *      2.name_1～name_5を上書き(or作成)
   *      ※車椅子関連の情報に関してはなにもしない(消さない。キーがなくても作成しない)
   *      ※実績展開時に車椅子関連の情報が存在するかどうかは不明
   *
   *  指示:風袋補正
   *    構造:
   *     {
   *       "name_1": "項目1名称", "weight_1": 項目1重さ(数値),
   *       "name_2": "項目2名称", "weight_2": 項目2重さ(数値),
   *       "name_3": "項目3名称", "weight_3": 項目3重さ(数値),
   *       "name_4": "項目4名称", "weight_4": 項目4重さ(数値),
   *        "name_5": "項目5名称", "weight_5": 項目5重さ(数値)
   *    }
   *  実績:風袋補正
   *    構造:
   *     {
   *       before: {
   *         "name_1": (String)"項目1名称", "weight_1": (Number)項目1重さ,
   *         "name_2": (String)"項目2名称", "weight_2": (Number)項目2重さ,
   *         "name_3": (String)"項目3名称", "weight_3": (Number)項目3重さ,
   *         "name_4": (String)"項目4名称", "weight_4": (Number)項目4重さ,
   *         "name_5": (String)"項目5名称", "weight_5": (Number)項目5重さ,
   *         "wheel_chair_cd" : (Number)"車いすマスタ.車いすコード",
   *         "wheel_chair_name": (String)"車いすマスタ.車いす名称",
   *         "wheel_chair_weight": (Number)"車いすマスタ.車いす重量"
   *       },
   *      after: { (beforeと同じ構造) }
   *     }
   * @param indTareInfo String 指示:風袋補正
   * @param rstTareInfo String 実績:風袋補正
   * @return String 実績:風袋補正
   */
  String extendIndTareInfoToRstTareInfo(
      String indTareInfo,
      String rstTareInfo
  )
  {
    //キー定義
    final String KEY_BEFORE = "before" ;    // キー:前体重測定時の風袋
    final String KEY_AFTER  = "after" ;     // キー:後体重測定時の風袋
    final String KEY_NAME   = "name_" ;     // キー:名称
    final String KEY_WEIGHT = "weight_" ;   // キー:重さ

    //指示:風袋補正 参照用(shallow copy用にfinalで固定。最終的にはdeep copy)
    JSONObject indTareInfoJson = null ;

    try {
      indTareInfoJson = new JSONObject(indTareInfo) ;
    }
    catch(Exception e)
    {
      //元になる情報がJsonパースできない
      //これは、終了させるレベルのエラーなので詳細ログを出力。nullを戻す
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return null ;
    }

    // 構造があるかの確認(Jsonパースしてみて確認)
    JSONObject rstTareInfoJson = null ;

    try {
      //実績:風袋補正を取得&Json化(失敗した場合、catchで新規作成します)
      rstTareInfoJson = new JSONObject(rstTareInfo) ;

      //Jsonキー配列:前・後
      String[] keyItems = {
          KEY_BEFORE,
          KEY_AFTER
      } ;

      //beforeとafter分、ループ処理
      for(int index = 0 ; index < keyItems.length ; index++)
      {

        boolean errFlag = false ;       //エラーフラグ:true->エラー発生
        //キーが有るかの確認
        if(rstTareInfoJson.has(keyItems[index]))
        {
          // キーが有った

          //  キー内容の置き換え
          try {
            JSONObject setJson = (JSONObject)rstTareInfoJson.get(keyItems[index]) ;

            for(int i = 1 ; i <= 5 ; i++)
            {
              //   名称置き換え
              String key = KEY_NAME + i ;
              setJson.put(key, indTareInfoJson.get(key)) ;
              //   重さ置き換え
              key = KEY_WEIGHT + i ;
              setJson.put(key, indTareInfoJson.get(key)) ;
            }
          }
          catch(Exception e)
          {
            //パース失敗などのエラー発生
            errFlag = true ;
          }
        }
        else
        {
          //キーがなかった
          errFlag = true ;
        }

        if(errFlag)
        {
          // エラーが発生
          //  そのまま指示:風袋補正をShallow Copy
          rstTareInfoJson.put(keyItems[index], indTareInfoJson) ;
        }
      }
    }
    catch(Exception e)
    {
      //なにかあったら、上書きせずにエラー扱い
      if(null != rstTareInfo && 0 != rstTareInfo.length())
      {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return null ;
      }
      else
      {
        //なかったので新規作成
        rstTareInfoJson = new JSONObject("{}") ;
        // before分(そのまま指示:風袋補正をShallow Copy)
        rstTareInfoJson.put(KEY_BEFORE, indTareInfoJson) ;
        // after分(そのまま指示:風袋補正をShallow Copy)
        rstTareInfoJson.put(KEY_AFTER, indTareInfoJson) ;
      }
    }

    rstTareInfo = null ;

    if(null != rstTareInfoJson)
    {
      //String化(deep copy)
      rstTareInfo = rstTareInfoJson.toString() ;
    }
    return rstTareInfo ;
  }

  /**
   * 身体情報からの値の取得処理
   * 身体情報を検査日時順に並べ替え、keyに対応する最新の値を含むJSONObjectを取得して返却する
   * WeightServiceImpl.java lastCtrMeasure(PhysicalInfo physicalInfo, String baseDate)同様の処理内容
   * @param physical_info 身体情報Json配列 [{},{},・・・,{}]
   * @param key 取得値のキー
   * @return 取得した値
   */
  private JSONObject getDataFromPhysicalInfo(
                    JSONArray physical_info,
                    String key,
                    String ordMainTreatDate
                 )
  {
    JSONObject ret = null ;
    LocalDateTime baseDateTime;
    if (ordMainTreatDate == null) {
      // ord_mainの治療日が存在しないなら
      // 現在日付+1日を設定
      baseDateTime = LocalDate.now().plusDays(1).atTime(0, 0);
    } else {
      try {
        LocalDate localBaseDate = LocalDate.parse(ordMainTreatDate, DateTimeFormatter.ofPattern("yyyyMMdd"));
        // ord_mainの治療日+1日を設定
        baseDateTime = localBaseDate.plusDays(1).atTime(0, 0);
      } catch (Exception ex) {
        baseDateTime = LocalDate.now().plusDays(1).atTime(0, 0);
      }
    }

    String sortKey = PARAMKEY.EXAM_DATE.get();

    //JSONArrayをList<JSONObject>化
    List<JSONObject> jsonList = new ArrayList<JSONObject>();
    for (int i = 0; i < physical_info.length(); i++) {
        jsonList.add(physical_info.getJSONObject(i));
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

    final String format = "yyyy-MM-dd'T'HH:mm:ssXXX" ;
    final String formatLong = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX" ;

    //要素0～確認して、値があればその値を採用(最新の有効データを採用)
    for(int i = 0 ; i < jsonList.size() ; i++)
    {
      LocalDateTime examDateTime;
      try {
        //時間をlong値に変換
        String examDate = getValueFromJson(jsonList.get(i), sortKey).toString();
        Pattern pattern = Pattern.compile("T");
        Matcher matcher = pattern.matcher(examDate);
        String formatDate = matcher.find() ? examDate : examDate + "T00:00:00.000+09:00";
        DateTimeFormatter f = DateTimeFormatter.ofPattern(format);
        if (formatDate.length() > 25) {
          f = DateTimeFormatter.ofPattern(formatLong);
        }
        examDateTime = LocalDateTime.parse(formatDate, f);
      } catch(Exception e) {
        // 変換できなかったので次のデータの確認
        continue;
      }

      if (examDateTime.isAfter(baseDateTime) || examDateTime.isEqual(baseDateTime)) {
        // 治療日よりも後に登録したデータは無視(未来日.isAfter(基準日) :true)
        continue;
      }

      JSONObject tmpObj = jsonList.get(i) ;
      //キーが有るかの確認
      if(tmpObj.has(key))
      {
        //キーが有った場合、値が数値かを確認する
        Object value =  tmpObj.get(key) ;
        try {
          //Doubleに変換してみる
          Double.valueOf(String.valueOf(value)) ;
        }
        catch(Exception e)
        {
          // 変換できなかったので次のデータの確認
          continue ;
        }
        //戻り値が確定
        ret = tmpObj ;
        //ループ終了
        break ;
      }
    }

    return ret ;
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
    final String formatLong = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX" ;
// add #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou start
    final String formatShort = "yyyy-MM-dd HH:mm:ss" ;
// add #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou end

    try {
      //時間をlong値に変換
      String date1 = s1.toString();
      String date2 = s2.toString();
// mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou start
//      Pattern pattern = Pattern.compile("T");
      Pattern pattern = Pattern.compile(":");
// mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou end
      Matcher matcher1 = pattern.matcher(date1);
      Matcher matcher2 = pattern.matcher(date2);

      String formatDate1 = matcher1.find() ? date1 : date1 + "T00:00:00.000+09:00";
      String formatDate2 = matcher2.find() ? date2 : date2 + "T00:00:00.000+09:00";

      DateTimeFormatter f1 = DateTimeFormatter.ofPattern(format);
      if (formatDate1.length() > 25) {
        f1 = DateTimeFormatter.ofPattern(formatLong);
// add #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou start
      } else if (formatDate1.length() == 19) {
        f1 = DateTimeFormatter.ofPattern(formatShort);
// add #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou end
      }
      DateTimeFormatter f2 = DateTimeFormatter.ofPattern(format);
      if (formatDate2.length() > 25) {
        f2 = DateTimeFormatter.ofPattern(formatLong);
// add #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou start
      } else if (formatDate2.length() == 19) {
        f2 = DateTimeFormatter.ofPattern(formatShort);
// add #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou end
      }

      LocalDateTime d1 = LocalDateTime.parse(formatDate1, f1);
      LocalDateTime d2 = LocalDateTime.parse(formatDate2, f2);

      DateTimeFormatter ff = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
      targetDate1 = d1.format(ff);
      targetDate2 = d2.format(ff);
    }
    catch(Exception e)
    {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }


    return targetDate1.compareTo(targetDate2);
  }

  /**
   * JSONObjectのnullの置換処理
   * JSONObject.NULLは、Json文字列中では"null"という文字列になるので
   * これをただのnullに置き換える
   * @param inputStr 入力文字列
   * @return 置換後の文字列
   */
  String parseJSONObjectNullToNormalNull(String inputStr)
  {
      /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
      if(ObjectUtils.isEmpty(inputStr)) {
          return inputStr;
      }
      /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    //置換元
    final String fromStr = "\"null\"" ;
    //置換先
    final String toStr = "null" ;

    //文字列置換実行
    return inputStr.replace(fromStr, toStr) ;
  }

  /**
   * 投薬情報マージ処理
   * 処理概要:
   * 実績から投薬実施済みを残して、その他は削除。その後指示とマージする。
   * @param rstMediInfo 実績:投薬情報(Json配列文字列)
   * @param indMediInfo 指示:投薬情報(Json配列文字列)
   * @return マージされた指示:投薬情報(Json配列文字列)
   */
  private String mergeRstMediIntoIndMedi(
      String rstMediInfo,
      String indMediInfo
    )
  {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("07-18-2：投薬情報マージ処理開始");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //実績のJsonArray化
    JSONArray rstArry;
    if (rstMediInfo == null) {
      rstArry = new JSONArray();
    } else {
      rstArry = new JSONArray(rstMediInfo);
    }

    //実績から投薬済み以外を削除(投薬済みだけ残す)
    int length = rstArry.length() ;
    for(int i = length -1  ; i >= 0  ; i--)
    {
      JSONObject tmpObj = rstArry.getJSONObject(i) ;
      //投与実施フラグの取得
      Object MediEffectFlg = getValueFromJson(tmpObj, PARAMKEY.MEDI_EFFECT_FLG.get()) ;
      String value;
      if (MediEffectFlg == null || String.valueOf(MediEffectFlg).equals("null")) {
        value = null;
      } else {
        value = (String)MediEffectFlg;
      }
      //投与実施フラグの確認
      if(null != value && !CONSTDEF.MEDI_DONE.get().equals(value))
      {
        // 投与実施フラグが存在&&投与実施フラグが実施済み以外
        // 投薬済みではないので削除
        rstArry.remove(i) ;
      }
    }

    //マージ作業
    //指示のJsonArray化
    JSONArray indArry;
    if (rstMediInfo == null) {
      indArry = new JSONArray();
    } else {
      indArry = new JSONArray(indMediInfo);
    }

    //指示の数だけループ
    for(int i = 0 ; i < indArry.length(); i++)
    {
      //指示の個別の投薬情報
      JSONObject indObj = indArry.getJSONObject(i) ;
      Object mediNo = getValueFromJson(indObj, PARAMKEY.MEDI_NO.get());
      //指示の識別番号取得
      Integer indNo;
      if (mediNo == null || String.valueOf(mediNo).equals("null")) {
        indNo = null;
      } else {
        indNo = parseInteger(mediNo);
      }


      //実績から同じ識別番号を探す
      for(int j = 0 ; j < rstArry.length(); j++)
      {
        //実績の個別の投薬情報
        JSONObject rstObj = rstArry.getJSONObject(j) ;
        //実績の識別番号取得
        Object medi_no = getValueFromJson(rstObj, PARAMKEY.MEDI_NO.get());
        Integer rstNo;
        if (medi_no == null || String.valueOf(medi_no).equals("null")) {
          rstNo = null;
        } else {
          rstNo = parseInteger(medi_no);
        }

        if(rstNo != null && rstNo.equals(indNo))
        {
          //同じ識別番号があったので、指示のJsonを実績のJsonで置き換え
          //処理上、元の配列から削除する(参照情報がなくなる)ためdeep copy)
          indArry.put(i,new JSONObject(rstObj.toString())) ;
          //実績のJsonArrayから、削除
          rstArry.remove(j) ;
          break ;
        }
      }
    }
    //一致しなかった実績の残りを指示に追加
    for(int i = 0 ; i < rstArry.length(); i++)
    {
      indArry.put(indArry.length(),rstArry.getJSONObject(i)) ;
    }

    //---------------------------------------
    //識別番号でソート

    String sortKey = PARAMKEY.MEDI_NO.get();

    //JSONArrayをList<JSONObject>化
    List<JSONObject> jsonList = new ArrayList<JSONObject>();
    for (int i = 0; i < indArry.length(); i++) {
        jsonList.add(indArry.getJSONObject(i));
    }

    //識別番号:昇順
    jsonList.sort(
        (s1,s2)
        ->
        parseInteger(getValueFromJson(s1,sortKey)) - parseInteger(getValueFromJson(s2,sortKey))
    );

    //再びJsonArray化
    JSONArray sortedJsonArray = new JSONArray() ;
    for (int i = 0; i < indArry.length(); i++) {
      sortedJsonArray.put(jsonList.get(i));
    }

    eventLogMessage.setLogMessage("07-18-2：投薬情報マージ処理終了");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //指示を文字列化
    return sortedJsonArray.toString() ;
  }
  /**
   * Jsonキー設定処理
   * キーが存在しない場合のみ値を設定する
   * 値がnullの場合は、JSONObject.NULLを値として設定する
   * @param jObj 設定先JSONObject
   * @param key キー
   * @param value 値
   */
  private void setJsonNonExistKeyAndValue(
          JSONObject jObj,
          String key,
          String value
      )
  {
    if(!jObj.has(key)) {
      //キーがない場合だけ追加
      if(null == value)
      {
        value = String.valueOf(JSONObject.NULL) ;
      }
      jObj.put(key, value) ;
    }
  }
  /**
   * Jsonキー設定処理
   * キーの値を上書き設定する
   * 値がnullの場合は、JSONObject.NULLを値として設定する
   * @param jObj 設定先JSONObject
   * @param key キー
   * @param value 値
   */
  private void setJsonKeyAndValue(JSONObject jObj, String key, Object value) {
    if(null == value) {
      jObj.put(key, JSONObject.NULL) ;
    } else {
      jObj.put(key, value);
    }
  }

  /**
   * 指定患者の治療状況確認
   *  実績:治療状況が、治療中以上かどうかの確認
   * @param ord_no  オーダ番号
   * @param facility_cd  施設コード
   * @return false:治療中以上
   */
  private boolean checkNowPatStatusNotUnderOperation(
            Long ord_no,
            String facility_cd)
  {
    boolean ret = true ;

    //チェックメソッドの呼び出し
    ret = conditionSendResultUtilService.checkPatStatusNotUnderOperation(ord_no, facility_cd) ;

    return ret ;
  }

  /**
   * 指示情報(薬剤)の名称補完処理 setIndCondInfoNames:overloaded
   * @param facilityCd  施設コード
   * @param initItemList 治療条件項目番号(リスト)
   * @param jObj 処理対象の治療条件Json
   * @param patTabooAllergyInfo   禁忌・アレルギー情報(患者)
   * @param tabooAllergyList      禁忌・アレルギーマスタ
   * @param indDeviceMode         装置モード
   * @return true:正常 false:異常
   */
  private boolean setIndCondInfoNames(
          String facilityCd,
          String[] initItemList,
          JSONObject jObj,
          /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
          String patTabooAllergyInfo,
          List<MstTabooAllergy> tabooAllergyList,
          Integer indDeviceMode
          /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
      )
  {

    boolean ret = true ;

    try
    {
      List<String> setItemList = new ArrayList<String>(Arrays.asList(initItemList));
      for(int i = setItemList.size()-1 ; i >= 0 ; i--)
      {
        if (!jObj.has(setItemList.get(i))) {
          setItemList.remove(setItemList.get(i));
        }
      }
      String[] itemList = (String[]) setItemList.toArray(new String[setItemList.size()]);

      //配列の要素数分ループ
      for(int i = 0 ; i < itemList.length ; i++)
      {
        // 対象の項目のJson
        JSONObject tmpObj = (JSONObject)jObj.get(itemList[i]) ;
        // 設定されている値を取得
        Integer cd = parseInteger(getValueFromJson(tmpObj, PARAMKEY.COND_VALUE.get()));
        /* add by chamaojia 2024-07-05 [10754] end without a primary key for query --start */
        if(null == cd)
        {
          //コードがnullの場合はスキップ
          continue;
        }
        /* add by chamaojia 2024-07-05 [10754] end without a primary key for query --end */
        // 設定されている薬剤区分を取得
        Integer type  = parseInteger(getValueFromJson(tmpObj, PARAMKEY.COND_MEDICINE_TYPE.get()));
        // DBからデータを取得
        Map<String,Object> medicineMap = conditionSendResultUtilService.getMedicineInfo(
            facilityCd,
            type,
            cd
          );
        // 翻訳にセット
        /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
        if(null != medicineMap)
        {
          String medicineName = medicineMap.get(PARAMKEY.MEDI_NAME.get()).toString();
          Integer classType = parseInteger(medicineMap.get(PARAMKEY.MEDI_CLASS_TYPE.get()));
          Object useEndDateObj = medicineMap.get(PARAMKEY.DATA_USE_END_DATE.get());
          String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
          String isDisp = medicineMap.get(PARAMKEY.DATA_IS_DISP.get()).toString();
          String isDel = medicineMap.get(PARAMKEY.DATA_IS_DEL.get()).toString();
          String prefixName = "";
          if (type == 1) {
            prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, type.toString()
                    , cd, itemList[i], classType, useEndDate, isDisp, isDel, indDeviceMode);
          } else if (type == 2) {
            String mixInfo = medicineMap.get(PARAMKEY.MEDI_MIX_INFO.get()).toString();
            prefixName = getMedicineMixPrefixOfName(patTabooAllergyInfo, tabooAllergyList
                    , cd, itemList[i], classType, isDisp, isDel, mixInfo, facilityCd);
          }
          tmpObj.put(PARAMKEY.COND_NAME_1.get(), prefixName + medicineName) ;
          //TODO:単位保管場所はCDの保管場所と違うため一旦無効化
          //tmpObj.put(PARAMKEY.COND_UNIT.get(), (String)medicineMap.get(PARAMKEY.MEDI_UNIT.get()));
        } else {
          tmpObj.put(PARAMKEY.COND_NAME_1.get(), CoreConstant.NamePrefixJapan.DELETED) ;
        }
        /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
      }
    }
    catch(Exception e)
    {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      ret = false ;
    }

    return ret ;
  }

  /* add by chamaojia 2024-01-26 [10196] Fixed name translation --start */
  /**
   * Fixed name translation
   * @param initItemList 治療条件項目番号(リスト)
   * @param jObj 処理対象の治療条件Json
   */
  private void setIndCondInfoNames(
          String[] initItemList,
          JSONObject jObj
  )
  {
    for (String itemCode : initItemList) {
      if (jObj.has(itemCode)) {
        JSONObject tmpObj = (JSONObject)jObj.get(itemCode);
        if (tmpObj.has(PARAMKEY.COND_VALUE.get())) {
          String nameTranslation = null;
          switch (itemCode) {
            case "12":   // シングルニードル
            case "29":   // IP使用選択
              nameTranslation = "1".equals(tmpObj.get(PARAMKEY.COND_VALUE.get())) ? "使用する" : "使用しない";
              break;
            case "21":   // 補液選択
              nameTranslation = "1".equals(tmpObj.get(PARAMKEY.COND_VALUE.get())) ? "前補液" : "後補液";
              break;
            case "30":   // IPスタート
            case "34":   // IPワンショットスタート
              nameTranslation = "0".equals(tmpObj.get(PARAMKEY.COND_VALUE.get())) ? "手動" : "自動";
              break;
            case "35":   // IP電源自動切り
            case "37":   // IP電源OKモニタ切り
              nameTranslation = "0".equals(tmpObj.get(PARAMKEY.COND_VALUE.get())) ? "切" : "入";
              break;
            default:
              break;
          }
          if (nameTranslation != null) {
            tmpObj.put(PARAMKEY.COND_NAME_1.get(), nameTranslation);
          }
        }
      }
    }
  }
  /* add by chamaojia 2024-01-26 [10196] Fixed name translation --end */

  /* modify by chamaojia 2024-01-26 [10196] Method added translation for units --start */
  /**
   * 指示情報の名称補完処理 + unit
   * @param target 対象処理区分  "EQUIP":医材  "VA":VA
   * @param facilityCd  施設コード
   * @param initItemList 治療条件項目番号(リスト)
   * @param jObj 指示：治療条件情報Json
   * @param patTabooAllergyInfo   禁忌・アレルギー情報(患者)
   * @param tabooAllergyList      禁忌・アレルギーマスタ
   * @return true:成功 false:失敗
   */
  private boolean setIndCondInfoNamesAndUnit(
          String target,
          String facilityCd,
          String[] initItemList,
          JSONObject jObj,
          /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
          String patTabooAllergyInfo,
          List<MstTabooAllergy> tabooAllergyList
          /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
      )
  {
    boolean ret = true ;

    try
    {
      List<String> setItemList = new ArrayList<String>(Arrays.asList(initItemList));
      for(int i = setItemList.size()-1 ; i >= 0 ; i--)
      {
        if (!jObj.has(setItemList.get(i))) {
          setItemList.remove(setItemList.get(i));
        }
      }
      String[] itemList = (String[]) setItemList.toArray(new String[setItemList.size()]);
      //処理対象用Listの準備
      List<JSONObject> objList = new ArrayList<JSONObject>(itemList.length)  ;
      //コードListの準備
      List<Integer> cdList = new ArrayList<Integer>(itemList.length)  ;
      //SQL条件用Listの準備
      List<Integer> sqlCdList = new ArrayList<Integer>(itemList.length)  ;

      for(int i = 0 ; i < itemList.length ; i++)
      {
        //処理対象のJsonのListへの格納
        objList.add((JSONObject)jObj.get(itemList[i])) ;
        //値(コード)の取得
        String value = String.valueOf(objList.get(i).get(PARAMKEY.COND_VALUE.get())) ;

        //値(コード)のInteger化
        Integer cd = parseInteger(value) ;
        cdList.add(cd); //コードリストへの追加
        if(null != cd)
        {
          //nullの場合以外をSQL条件用リストに追加 ※nullがあると、Domaのパースで実行時エラーになるためnullは追加しない
          sqlCdList.add(cd) ;
        }
      }

      //名称をまとめて取得
      List<Map<String,Object>> equipMapList = conditionSendResultUtilService.getNameListWithCase(
          target,
          facilityCd,
          sqlCdList) ;

      //処理対象リストを回して該当するCDを探して値をはめていきます
      for(int i = 0 ; i < cdList.size() ; i++)
      {
        /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
        Integer equipCd  = cdList.get(i);
        if(null == equipCd)
        {
          //コードがnullの場合はスキップ
          continue;
        }

        Optional<Map<String, Object>> equipMap = equipMapList.stream().filter(e -> equipCd.equals(e.get(PARAMKEY.COND_CD.get()))).findFirst();
        if (equipMap.isPresent()) {
          String equipmentName = equipMap.get().get(PARAMKEY.COND_NAME.get()).toString();
          String prefixName = "";
          String isDisp = equipMap.get().get(PARAMKEY.DATA_IS_DISP.get()).toString();
          String isDel = equipMap.get().get(PARAMKEY.DATA_IS_DEL.get()).toString();
          if (PARAMKEY.COND_CAT_EQUIP.get().equals(target)) {
            Integer classType = parseInteger(equipMap.get().get(PARAMKEY.EQUI_CLASS_TYPE.get()));
            Object useEndDateObj = equipMap.get().get(PARAMKEY.DATA_USE_END_DATE.get());
            String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
            prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, "3", equipCd
                    , itemList[i], classType, useEndDate, isDisp, isDel, null);
          } else {
            // VA prefix
            if (isDataDeleted(isDisp, isDel)) {
              prefixName = CoreConstant.NamePrefixJapan.DELETED;
            }
          }
          objList.get(i).put(PARAMKEY.COND_NAME_1.get(), prefixName + equipmentName) ;
          if (target.equals(PARAMKEY.COND_CAT_EQUIP.get())) {
            objList.get(i).put(PARAMKEY.COND_UNIT.get(), (String)equipMap.get().get(PARAMKEY.COND_UNIT.get())) ;
          }

        } else {
          objList.get(i).put(PARAMKEY.COND_NAME_1.get(), CoreConstant.NamePrefixJapan.DELETED) ;
        }

//        // 取得した名称Listのループ
//        for(int j = 0 ; j < equipMapList.size() ; j++)
//        {
//          //  取得した名称のコードを取得
//          Integer cd = this.parseInteger(String.valueOf(equipMapList.get(j).get(PARAMKEY.COND_CD.get()))) ;
//          //  処理対象のコードと比較
//          if(cdList.get(i).equals(cd))
//          {
//            //   コードが一致
//            //   翻訳に名称をセットする
//            objList.get(i).put(PARAMKEY.COND_NAME_1.get(), (String)equipMapList.get(j).get(PARAMKEY.COND_NAME.get())) ;
//            if (target.equals(PARAMKEY.COND_CAT_EQUIP.get())) {
//              objList.get(i).put(PARAMKEY.COND_UNIT.get(), (String)equipMapList.get(j).get(PARAMKEY.COND_UNIT.get())) ;
//            }
//            break ;
//          }
//        }
        /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
      }
    }
    catch(Exception e)
    {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      ret = false ;
    }

    return ret ;
  }
  /* modify by chamaojia 2024-01-26 [10196] Method added translation for units --end */

  /**
   * 指示情報(薬剤)の単位及び数量小数点補完処理 setIndCondInfoUnitAndPoint
   * @param facilityCd  施設コード
   * @param initItemList 保管対象項目の一覧
   * @param jObj 処理対象の治療条件Json
   * @return true:正常 false:異常
   */
  private boolean setIndCondInfoUnitAndPoint(
          String facilityCd,
          String[] initItemList,
          JSONObject jObj
      )
  {

    boolean ret = true ;

    try
    {
      List<String> setItemList = new ArrayList<String>(Arrays.asList(initItemList));
      for(int i = setItemList.size()-1 ; i >= 0 ; i--)
      {
        if (!jObj.has(setItemList.get(i))) {
          setItemList.remove(setItemList.get(i));
        }
      }
      String[] itemList = (String[]) setItemList.toArray(new String[setItemList.size()]);

      int anticoagulantMaxPoint = 0; // 抗凝固剤の量項目の最大小数点以下
      // 抗凝固剤の数量項目の数量一時保存
      Map<Integer, String> anticoagulantItemMap = new HashMap<>();
      //配列の要素数分ループ
      for(int i = 0 ; i < itemList.length ; i++)
      {
        // 対象項目のJson
        JSONObject tmpObj = (JSONObject)jObj.get(itemList[i]) ;
        Integer tmpId = Integer.parseInt(itemList[i]);

        // 対象項目のコード値を取得＆参照項目のコード値をセット
        Integer refId = null;
        /* modify by chamaojia 2024-01-26 [10196] Add translation for units' 15 ',' 19 ', and' 25 ' --start */
        switch(tmpId){
          case 15:
          case 17:
            // 透析液コード
            refId = 15;
            break;
          case 19:
          case 22:
            // 補液コード
            refId = 19;
            break;
          case 25:
          case 26:
          case 27:
          case 28:
            // 抗凝固剤コード
            refId = 25;
            break;
        }
        /* modify by chamaojia 2024-01-26 [10196] Add translation for units' 15 ',' 19 ', and' 25 ' --end */

        // 対象の参照項目Json
        JSONObject refObj = (JSONObject)jObj.get(Integer.toString(refId));

        Integer cd = parseInteger(getValueFromJson(refObj, PARAMKEY.COND_VALUE.get()));
        // 設定されている薬剤区分を取得
        Integer type  = parseInteger(getValueFromJson(refObj, PARAMKEY.COND_MEDICINE_TYPE.get()));

        // DBからデータを取得
        Map<String,Object> medicineMap = conditionSendResultUtilService.getMedicineInfo(
            facilityCd,
            type,
            cd
          );
        // 翻訳にセット
        if(null != medicineMap)
        {
          /* modify by chamaojia 2024-05-20 [10196] 小数処理ロジックの追加 --start */
          //jsonに追加するunit 透析液及び補液はレセ単位／抗凝固剤は指示単位
          String decimalPointColumnName = null;
          if(tmpId == 17 || tmpId == 22){
            tmpObj.put(PARAMKEY.COND_UNIT.get(), (String)medicineMap.get(PARAMKEY.COND_UNIT_SECOND.get()));
            decimalPointColumnName = PARAMKEY.COND_DEC_PT_SECOND.get();
          }
          else if(tmpId == 27){
            //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
            tmpObj.put(PARAMKEY.COND_UNIT.get(), medicineMap.get(PARAMKEY.COND_UNIT.get()) != null ? medicineMap.get(PARAMKEY.COND_UNIT.get()) + "/h" : null);
            //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
            decimalPointColumnName = PARAMKEY.COND_DEC_PT.get();
          }
          else{
            //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
            tmpObj.put(PARAMKEY.COND_UNIT.get(), medicineMap.get(PARAMKEY.COND_UNIT.get()) != null && !"".equals((String)medicineMap.get(PARAMKEY.COND_UNIT.get())) ? medicineMap.get(PARAMKEY.COND_UNIT.get()) : null);
            //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
            decimalPointColumnName = PARAMKEY.COND_DEC_PT.get();
          }
          if (tmpId != 15 && tmpId != 19 && tmpId != 25) {
            // 小数点以下の桁数の処理
            Integer decPoint= Integer.parseInt(medicineMap.get(decimalPointColumnName).toString());
            String dataValue = NumberFormatUtils.getValueToDecimalProcessed(tmpObj.get(PARAMKEY.COND_VALUE.get()).toString(), decPoint);

            /**
             * 抗凝固剤の量を表す3つの必要な小数点以下の桁数を統一する（最大小数点以下）
             * 抗凝固剤ワンショット量、抗凝固剤持続速度、抗凝固剤持続総量
             */
            if (tmpId == 26 || tmpId == 27 || tmpId == 28) {
              if (!ObjectUtils.isEmpty(dataValue)) {
                anticoagulantItemMap.put(tmpId, dataValue);
                int decimalDigits = getDecimalDigits(dataValue);
                if (decimalDigits > anticoagulantMaxPoint) {
                  anticoagulantMaxPoint = decimalDigits;
                }
              }
            } else {
              tmpObj.put(PARAMKEY.COND_VALUE.get(), dataValue);
            }
          }
          /* modify by chamaojia 2024-05-20 [10196] 小数処理ロジックの追加 --end */
        }
      }
      /* add by chamaojia 2024-05-20 [10196] --start */
      // 抗凝固剤の量を表す3つの必要な小数点以下の桁数を統一する（最大小数点以下）
      int finalAnticoagulantMaxPoint = anticoagulantMaxPoint;
      anticoagulantItemMap.forEach((key, value) -> {
        JSONObject tmpObj = (JSONObject)jObj.get(key.toString());
        int decimalDigits = getDecimalDigits(value);
        if (finalAnticoagulantMaxPoint > decimalDigits) {
          tmpObj.put(PARAMKEY.COND_VALUE.get()
                  , NumberFormatUtils.getValueToDecimalProcessed(value, finalAnticoagulantMaxPoint));
        } else {
          tmpObj.put(PARAMKEY.COND_VALUE.get(), value);
        }
      });
      /* add by chamaojia 2024-05-20 [10196] --end */
    }
    catch(Exception e)
    {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      ret = false ;
    }
    return ret ;
  }

  /* add by chamaojia 2024-05-20 [10196] --start */
  /**
   * 小数点以下の桁数を取得
   * @param numberStr 文字列タイプの数値
   * @return
   */
  private int getDecimalDigits(String numberStr) {
    if (numberStr == null || numberStr.isEmpty()) {
      return 0;
    }

    // 文字列の両端のスペースを除去する
    numberStr = numberStr.trim();

    // 小数点が含まれているかどうかをチェック
    int decimalIndex = numberStr.indexOf('.');
    if (decimalIndex == -1) {
      // 小数点がない場合は整数とみなされ、小数点以下の桁数は0です
      return 0;
    }

    // 小数点以下の文字数、つまり小数点以下の桁数を返します
    return numberStr.length() - decimalIndex - 1;
  }
  /* add by chamaojia 2024-05-20 [10196] --end */

  /**
   * 医療材料情報穴埋め処理
   * @param indEquipInfo 医療材料情報情報:JsonArray文字列
   * @param facilityCd 施設コード
   * @param patTabooAllergyInfo   禁忌・アレルギー情報(患者)
   * @param tabooAllergyList      禁忌・アレルギーマスタ
   * @return String 医療材料情報(失敗時null)
   */
  private String setEquipmentInfo(
                String indEquipInfo,
                String facilityCd,
                /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
                String patTabooAllergyInfo,
                List<MstTabooAllergy> tabooAllergyList
                /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
         )
  {
    String ret = null ;
      /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    // JSONArray jsonArry = new JSONArray(indEquipInfo) ;
      JSONArray jsonArry = new JSONArray(ObjectUtils.isEmpty(indEquipInfo)? "[]" : indEquipInfo);
      /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    for(int i = 0 ; i < jsonArry.length() ; i++)
    {
      //処理対象データ(Json)の取得(i番目の要素)
      JSONObject jObj = (JSONObject)jsonArry.get(i) ;

      //Jsonの構造
      //  {
      //    "class_cd": 医療材料分類コード, (*2)  mst_equipment.class_cd
      //    "class_name": 医療材料分類名, (*2)  mst_equipment_class.class_name
      //    "class_type": 分類区分, (*2)       mst_equipment_class.class_type
      //    "cd": 医療材料コード, (*1)           入っている(抽出キー)
      //    "name": 医療材料名, (*2)           mst_equipment.equipment_name
      //    "short_name": 省略医療材料名, (*2)  mst_equipment.equipment_short_name
      //    "needle_type": 穿刺針区分, (*3)    入力値(なにもしない)
      //    "amount": 数量, (*1)              入力値(なにもしない
      //    "unit": 単位, (*2)                 mst_equipment.unit
      //    "ind_user_id": 指示者コード(利用者マスタ.利用者ID), (*1) 更新しない
      //    "ind_user_last_name": 指示者名_姓(利用者マスタ.利用者名_姓), (*2) 名前処理で一括処理(ここではしない)
      //    "ind_user_first_name": 指示者名_名(利用者マスタ.利用者名_名), (*2) 名前処理で一括処理(ここではしない)
      //    "upd_user_id": 更新者コード(利用者マスタ.利用者ID), (*1) 更新しない
      //    "upd_user_last_name": 更新者名_姓(利用者マスタ.利用者名_姓), (*2) 名前処理で一括処理(ここではしない)
      //    "upd_user_first_name": 更新者名_名(利用者マスタ.利用者名_名), (*2) 名前処理で一括処理(ここではしない)
      //    "input_class": 登録区分, (*1)(*4) 更新しない
      //    "is_editable": 編集可否フラグ, (*1)(*5) 更新しない
      //    "cop_order_no": 連携オーダ番号 (*6) 更新しない
      //    "equip_type": 医療材料区分(0：医療材料、1：ダイアライザ)
      //  }

      //コード収集
      //医療材料区分の取得
      Integer equipType = parseInteger(getValueFromJson(jObj, PARAMKEY.EQUI_TYPE.get())) ;

      //医療材料コードの取得
      Integer cd = parseInteger(getValueFromJson(jObj, PARAMKEY.EQUI_CD.get())) ;

      if (equipType == 0) {
        //取得したコードを元に医療材料情報から名称を取得(DBから)
        Map<String,Object> mediMap = conditionSendResultUtilService.getEquipmentInfo(
                                                              facilityCd,
                                                              cd) ;

        /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
        if (mediMap != null) {
          //Jsonにセット(名称穴埋め)
          //医療材料分類コード
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_CLASS_CD.get(), getValueFromMap(mediMap, PARAMKEY.EQUI_CLASS_CD.get()));
          //医療材料分類名
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_CLASS_NAME.get(), getValueFromMap(mediMap, PARAMKEY.EQUI_CLASS_NAME.get()));
          //分類区分
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_CLASS_TYPE.get(), getValueFromMap(mediMap, PARAMKEY.EQUI_CLASS_TYPE.get()));
          //医療材料名
          String equitmentName = getValueFromMap(mediMap, PARAMKEY.EQUI_NAME.get()).toString();
          Object useEndDateObj = getValueFromMap(mediMap, PARAMKEY.DATA_USE_END_DATE.get());
          String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
          String isDisp = getValueFromMap(mediMap, PARAMKEY.DATA_IS_DISP.get()).toString();
          String isDel = getValueFromMap(mediMap, PARAMKEY.DATA_IS_DEL.get()).toString();
          String prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, "3", cd
                  , null, null, useEndDate, isDisp, isDel, null);
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_NAME.get(), prefixName + equitmentName);
          //省略医療材料名
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_SHORT_NAME.get(), getValueFromMap(mediMap, PARAMKEY.EQUI_SHORT_NAME.get()));
          //単位
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_UNIT.get(), getValueFromMap(mediMap, PARAMKEY.EQUI_UNIT.get()));
        } else {
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_NAME.get(), CoreConstant.NamePrefixJapan.DELETED);
        }
        /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
      } else if (equipType == 1) {
        //取得したコードを元にダイアライザ情報から名称を取得(DBから)
        Map<String,Object> mediMap = conditionSendResultUtilService.getDialyzerNames(
                                                              facilityCd,
                                                              cd) ;
        /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
        if (mediMap != null) {
          //Jsonにセット(名称穴埋め)
          //医療材料名
          String dialyzerName = getValueFromMap(mediMap, PARAMKEY.COND_MODEL_NUMBER.get()).toString();
          Object useEndDateObj = getValueFromMap(mediMap, PARAMKEY.DATA_USE_END_DATE.get());
          String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
          String isDisp = getValueFromMap(mediMap, PARAMKEY.DATA_IS_DISP.get()).toString();
          String isDel = getValueFromMap(mediMap, PARAMKEY.DATA_IS_DEL.get()).toString();
          String prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, "4", cd
                  , null, null, useEndDate, isDisp, isDel, null);
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_NAME.get(), prefixName + dialyzerName);
          // add #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_UNIT.get(), "本");
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_CLASS_CD.get(), JSONObject.NULL);
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_CLASS_NAME.get(), JSONObject.NULL);
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_CLASS_TYPE.get(), JSONObject.NULL);
          //省略医療材料名
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_SHORT_NAME.get(), dialyzerName);
          // add #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
        } else {
          setJsonKeyAndValue(jObj, PARAMKEY.EQUI_NAME.get(), CoreConstant.NamePrefixJapan.DELETED);
        }
        /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
      }
    }
    ret = jsonArry.toString() ;

    return ret ;
  }
  /**
   * 投与薬剤情報穴埋め処理
   * ※実績:投与薬剤情報は、指示:投与薬剤情報のディープコピー+実施情報
   * @param indMediInfo 指示:投与薬剤情報:JsonArray
   * @param rstMediInfo 実績:投与薬剤情報:null(指示:投与薬剤情報がコピーされる)
   * @param facilityCd 施設コード
   * @param patTabooAllergyInfo   禁忌・アレルギー情報(患者)
   * @param tabooAllergyList      禁忌・アレルギーマスタ
   * @return 投与薬剤情報(失敗時null)
   *    PARAMKEY.MEDI_IND_INFO.get():指示:投与薬剤情報
   *    PARAMKEY.MEDI_RST_INFO.get():実績:投与薬剤情報
   */
  private Map<String,String> setMedicineInfo(
                String indMediInfo,
                String rstMediInfo,
                String facilityCd,
                /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
                String patTabooAllergyInfo,
                List<MstTabooAllergy> tabooAllergyList
                /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
         )
  {
    //戻り値
    Map<String,String> ret = new HashMap<String,String>() ;
      /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    // JSONArray jsonArry = new JSONArray(indMediInfo) ;
    JSONArray jsonArry = new JSONArray(ObjectUtils.isEmpty(indMediInfo)? "[]" : indMediInfo);
      /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    for(int i = 0 ; i < jsonArry.length() ; i++)
    {

      //処理対象データ(Json)の取得(i番目の要素)
      JSONObject jObj = (JSONObject)jsonArry.get(i) ;

      //Jsonの構造
      //    {
      //      "no": 識別番号, (*1)                  更新しない
      //      "class_cd": 薬剤分類コード, (*3)       mst_medicine.class_cd
      //                                          mst_preparation_medicine.class_cd
      //      "class_name": 薬剤分類名, (*3)       mst_medicine_class.class_name
      //      "class_type": 分類区分, (*3)         mst_medicine_class.class_type
      //      "medicine_type": 薬剤区分, (*2)(*4)   判定に使用: 1: 通常薬剤mst_medicine、2: 調製薬剤mst_preparation_medicine
      //      "cd": 薬剤(調整薬剤)コード, (*2)         はいってる(薬剤区分によりコードの意味が変わる(テーブル切り替え))(抽出キー)
      //      "name": 薬剤名, (*3)                 mst_medicine.medicine_name
      //                                          mst_preparation_medicine.preparation_medicine_name
      //      "short_name": 省略薬剤名, (*3)       mst_medicine.medicine_short_name
      //                                          mst_preparation_medicine.preparation_medicine_short_name
      //      "unit": 単位, (*3)                  mst_medicine.unit
      //                                          mst_preparation_medicine.unit
      //      "amount": 数量, (*2)               更新しない
      //      "timing_cd": 投与タイミングコード, (*2)  更新しない
      //      "timing_name": 投与タイミング名, (*3)   mst_medicate_timing.medicate_timing_name
      //      "procedure_cd": 手技コード, (*2)     更新しない
      //      "procedure_name": 手技名, (*3)      mst_procedure.pricedure_name
      //      "comment": コメント, (*2)              更新しない
      //      "ind_user_id": 指示者コード(利用者マスタ.利用者ID), (*2) 更新しない
      //      "ind_user_last_name": 指示者名_姓(利用者マスタ.利用者名_姓), (*3) 名前処理で一括処理(ここではしない)
      //      "ind_user_first_name": 指示者名_名(利用者マスタ.利用者名_名), (*3) 名前処理で一括処理(ここではしない)
      //      "upd_user_id": 更新者コード(利用者マスタ.利用者ID), (*2) 更新しない
      //      "upd_user_last_name": 更新者名_姓(利用者マスタ.利用者名_姓), (*3) 名前処理で一括処理(ここではしない)
      //      "upd_user_first_name": 更新者名_名(利用者マスタ.利用者名_名), (*3) 名前処理で一括処理(ここではしない)
      //      "input_class": 登録区分, (*2)(*5) 更新しない
      //      "is_editable": 編集可否フラグ, (*2)(*6) 更新しない
      //      "cop_order_no": 連携オーダ番号 (*7) 更新しない
      //    }, ・・・

      //コード収集

      //薬剤区分の取得
      Integer medicine_type = parseInteger(getValueFromJson(jObj, PARAMKEY.MEDI_MEDICENE_TYPE.get())) ;
      //薬剤(or 調整薬剤)コードの取得
      Integer cd = parseInteger(getValueFromJson(jObj, PARAMKEY.MEDI_CD.get())) ;
      //投与タイミングコードの取得
      Integer timing_cd = parseInteger(getValueFromJson(jObj, PARAMKEY.MEDI_TIMING_CD.get())) ;
      //手技コードの取得
      Integer procedure_cd = parseInteger(getValueFromJson(jObj, PARAMKEY.MEDI_PROCEDURE_CD.get())) ;

      //取得したコードを元に薬剤情報から名称を取得(DBから)
      Map<String,Object> mediMap = conditionSendResultUtilService.getMedicineInfo(
                                                            facilityCd,
                                                            medicine_type,
                                                            cd) ;

      /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
      if (mediMap != null) {
        //Jsonにセット(名称穴埋め)
        //薬剤分類コード
        setJsonKeyAndValue(jObj, PARAMKEY.MEDI_CLASS_CD.get(), getValueFromMap(mediMap, PARAMKEY.MEDI_CLASS_CD.get()));
        //薬剤分類名
        setJsonKeyAndValue(jObj, PARAMKEY.MEDI_CLASS_NAME.get(), getValueFromMap(mediMap, PARAMKEY.MEDI_CLASS_NAME.get())) ;
        //分類区分
        setJsonKeyAndValue(jObj, PARAMKEY.MEDI_CLASS_TYPE.get(), getValueFromMap(mediMap, PARAMKEY.MEDI_CLASS_TYPE.get())) ;
        //薬剤名
        String medicineName = getValueFromMap(mediMap, PARAMKEY.MEDI_NAME.get()).toString();
        Object useEndDateObj = getValueFromMap(mediMap, PARAMKEY.DATA_USE_END_DATE.get());
        String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
        String isDisp = getValueFromMap(mediMap, PARAMKEY.DATA_IS_DISP.get()).toString();
        String isDel = getValueFromMap(mediMap, PARAMKEY.DATA_IS_DEL.get()).toString();
        String prefixName = "";
        if (medicine_type == 1) {
          prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, medicine_type.toString(), cd
                  , null, null, useEndDate, isDisp, isDel, null);
        } else if (medicine_type == 2) {
          String mixInfo = getValueFromMap(mediMap, PARAMKEY.MEDI_MIX_INFO.get()).toString();
          prefixName = getMedicineMixPrefixOfName(patTabooAllergyInfo, tabooAllergyList, cd
                  , null, null, isDisp, isDel, mixInfo, facilityCd);
        }
        setJsonKeyAndValue(jObj, PARAMKEY.MEDI_NAME.get(), prefixName + medicineName) ;
        //省略薬剤名
        setJsonKeyAndValue(jObj, PARAMKEY.MEDI_SHORT_NAME.get(), getValueFromMap(mediMap, PARAMKEY.MEDI_SHORT_NAME.get())) ;
        //単位
        setJsonKeyAndValue(jObj, PARAMKEY.MEDI_UNIT.get(), getValueFromMap(mediMap, PARAMKEY.MEDI_UNIT.get())) ;
        /* modify by chamaojia 2024-05-20 [10196] 小数処理ロジックの追加 --start */
        // 数量
        Integer decPoint= Integer.parseInt(getValueFromMap(mediMap, PARAMKEY.MEDI_DEC_PT.get()).toString());
        setJsonKeyAndValue(jObj, PARAMKEY.MEDI_AMOUNT.get()
                , NumberFormatUtils.getValueToDecimalProcessed(jObj.get(PARAMKEY.MEDI_AMOUNT.get()).toString(), decPoint)) ;
        /* modify by chamaojia 2024-05-20 [10196] 小数処理ロジックの追加 --end */

        //投与タイミング
        String timing_name = conditionSendResultUtilService.getTimingName(
                facilityCd,
                timing_cd) ;

        //Jsonにセット(名称穴埋め)
        //投与タイミング名称
        jObj.put(PARAMKEY.MEDI_TIMING_NAME.get(), timing_name) ;

        //手技
        String procedure_name = conditionSendResultUtilService.getProcedureName(
                facilityCd,
                procedure_cd) ;

        //Jsonにセット(名称穴埋め)
        //手技名称
        jObj.put(PARAMKEY.MEDI_PROCEDURE_NAME.get(), procedure_name) ;
      } else {
        setJsonKeyAndValue(jObj, PARAMKEY.MEDI_NAME.get(), CoreConstant.NamePrefixJapan.DELETED) ;
      }
      /* modify by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */
    }

    //----------------------------------------------------------------------
    //実績へ実施情報のキーを追加

    //  投与実施フラグ  未実施 ※0：未実施、1：実施済み → 0  effect_flg
    //  投与実施日時 ※ISO8601形式 → null            effect_date
    //  投与実施者コード → null                     effect_user_id
    //  投与実施者名_姓 → null                     effect_user_last_name
    //  投与実施者名_名 → null                     effect_user_first_name


    //指示->実績へのコピー(ディープコピー)
    JSONArray rstJsonArry = new JSONArray(jsonArry.toString()) ;

    for(int i = 0 ; i < rstJsonArry.length() ; i++)
    {
      //処理対象データ(Json)の取得(i番目の要素)
      JSONObject jObj = (JSONObject)rstJsonArry.get(i) ;

      //-------------------------------------------
      //実施情報のキー追加

      //投与実施フラグ  未実施 ※0：未実施、1：実施済み
      setJsonNonExistKeyAndValue(jObj, PARAMKEY.MEDI_EFFECT_FLG.get(), CONSTDEF.MEDI_NOTDONE.get()) ;
      //投与実施日時 ※ISO8601形式
      setJsonNonExistKeyAndValue(jObj, PARAMKEY.MEDI_EFFECT_DATE.get(),(String)null) ;
      //投与実施者コード
      setJsonNonExistKeyAndValue(jObj, PARAMKEY.MEDI_EFFECT_USER_ID.get(),(String)null) ;
      //投与実施者名_姓
      setJsonNonExistKeyAndValue(jObj, PARAMKEY.MEDI_EFFECT_USER_LAST_NAME.get(),(String)null) ;
      //投与実施者名_名
      setJsonNonExistKeyAndValue(jObj, PARAMKEY.MEDI_EFFECT_USER_FIRST_NAME.get(),(String)null) ;
    }

    //戻り値の組み立て
    ret.put(PARAMKEY.MEDI_IND_INFO.get(), parseJSONObjectNullToNormalNull(jsonArry.toString())) ;
    ret.put(PARAMKEY.MEDI_RST_INFO.get(), parseJSONObjectNullToNormalNull(rstJsonArry.toString())) ;

    return ret ;
  }

  /**
   * Mapからの値の取得処理
   * 値が取得できない場合(キーが存在しないなど)はnullを返却する
   * @param mapObj Mapオブジェクト
   * @param key  キー
   * @return 取得した値(キーが存在しない場合null)
   */
  private Object getValueFromMap(Map mapObj,String key)
  {
    Object ret = null ;

    try {
      //mapからキーを元に取得
      ret = mapObj.get(key) ;
    }
    catch(Exception e)
    {
      //例外が発生したので、戻り値をnullに設定
      ret = null ;
    }
    return ret ;
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
      if(!jObj.isEmpty() && !jObj.isNull(key))
      {
        ret = jObj.get(key) ;
      }
    }
    catch(Exception e)
    {
      //例外が発生したので、戻り値をnullに設定
      ret = null ;
    }
    return ret ;
  }


  /**
   * Longへのパース処理
   * Longへパースできない場合はnullを返却する
   * @param inObj 入力
   * @return Long化した入力値(パースできない場合null)
   */
  private Long parseLong(Object inObj)
  {
    Long ret = null ;

    try {
      //Longにパース
      ret = Long.valueOf(String.valueOf(inObj)) ;
    }
    catch(Exception e)
    {
      //パースに失敗した場合null
      ret = null ;
    }

    return ret ;
  }
  /**
   * Doubleへのパース処理
   * Doubleへパースできない場合はnullを返却する
   * @param inObj 入力
   * @return Double化した入力値(パースできない場合null)
   */
  private Double parseDouble(Object inObj)
  {
    Double ret = null ;

    try {
      //Doubleにパース
      ret = Double.valueOf(String.valueOf(inObj)) ;
    }
    catch(Exception e)
    {
      //パースに失敗した場合null
      ret = null ;
    }

    return ret ;
  }
  /**
   * Integerへのパース処理
   * Integerへパースできない場合はnullを返却する
   * @param inObj 入力
   * @return Integer化した入力値(パースできない場合null)
   */
  private Integer parseInteger(Object inObj)
  {
    Integer ret = null ;

    try {
      //Integerにパース
      ret = Integer.valueOf(String.valueOf(inObj)) ;
    }
    catch(Exception e)
    {
      //パースに失敗した場合null
      ret = null ;
    }

    return ret ;
  }

  /**
   * Json文字列中のユーザー名の置き換え処理(拡張:オーバーロード)
   * キーで指定されたidを元に名前の抽出を行い、キーで指定した名前(姓)、名前(名)の値を設定する
   * @param inStr 設定先JSON文字列
   * @param keys    キーの意味:{id,名前(姓),名前(名)}
   * @param facilityCd    施設コード
   * @param cryptoFlag    暗号/復号フラグ false:復号化したデータ
   * @param pattern     処理パターン
   *                    STRING(プレーンなJson)
   *                    KEY(キーと値)
   *                    DIM(配列))
   * @return 名前部分を埋めた入力json文字列
   */
  private String fillNamesJson(
        String inStr ,
        String[][] keys,
        String facilityCd,
        boolean cryptoFlag,
        CAT_JSON_PATTERN pattern
      )
  {
    String ret = null ;

    //指定される処理パターン(Jsonの構成)による条件分け
    switch(pattern) {
      case STRING:      //プレーンなJson(キー:値,キー:値・・・)の場合の処理 {"":"","":"",・・・,"":""}
        //名称置き換え処理の呼び出し
        ret = fillNamesJson(
            inStr,
            keys,
            facilityCd,
            cryptoFlag
          ).toString();
        break ;
      case KEYVALUE:      //キーとJsonの場合の処理    {"":{},"":{},・・・・,"":{}}
        JSONObject jsonObj = null ;
        try {
          jsonObj = new JSONObject(inStr) ;
        }
        catch(Exception e)
        {
          ret = null ;
          break ;
        }

        //キーの数だけループします
        for(String key : jsonObj.keySet())
        {
          //JSONObjectを取得
          JSONObject tmpObj = jsonObj.getJSONObject(key) ;
          //名前置き換え処理の呼び出し
          tmpObj = (JSONObject)fillNamesJson(
              tmpObj,
              keys,
              facilityCd,
              cryptoFlag
            );
          //もとに戻す
          jsonObj.put(key, tmpObj) ;
        }

        ret = jsonObj.toString() ;
        break ;
      case DIM:      //Json配列の場合の処理     [{},{},・・・・,{}]
        JSONArray jsonArryObj = null ;
        try {
          jsonArryObj = new JSONArray(inStr) ;

          //配列の要素数だけループします
          for(int i = 0 ; i < jsonArryObj.length(); i++)
          {
            //JSONObjectを取得
            JSONObject tmpObj = (JSONObject)jsonArryObj.get(i) ;
            //名前置き換え処理の呼び出し
            tmpObj = (JSONObject)fillNamesJson(
                tmpObj,
                keys,
                facilityCd,
                cryptoFlag
              );
            //元のArrayに設定し直す
            jsonArryObj.put(i, tmpObj) ;
          }
          ret = jsonArryObj.toString() ;
        }
        catch(Exception e)
        {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          ret =  null ;
        }

        break ;
      default:
        ret =  null ;
    }

    return ret ;
  }

  /**
   * Json文字列中のユーザー名の置き換え処理
   * キーで指定されたidを元に名前の抽出を行い、キーで指定した名前(姓)、名前(名)の値を設定する
   * @param inObj 置き換え対象JSONObject
   * @param keys    キーの意味:{id,名前(姓),名前(名)}
   * @param facilityCd    施設コード
   * @param cryptoFlag    暗号/復号フラグ false:復号化したデータ
   * @return 名前部分を埋めた入力json文字列
   */
  Object fillNamesJson(
        Object inObj ,
        String[][] keys,
        String facilityCd,
        boolean cryptoFlag
      )
  {
    Object ret = null ;

    JSONObject jsonObj = null ;

    //渡されたオブジェクトの型判定
    if(inObj instanceof JSONObject)
    {
      //Jsonだった場合
      jsonObj = (JSONObject)inObj ;
    }
    else if(inObj instanceof String)
    {
      //文字列だったのでJsonオブジェクトにします
      jsonObj = new JSONObject((String)inObj) ;
    }
    //idの収集(名前取得時の引数)
    List<Long> userIdList = new ArrayList<Long>() ;

    Long userId = null ;
    for(int i = 0 ; i < keys.length ; i++)
    {
      if (!jsonObj.has(keys[i][0])) {
        continue;
      }
      Object tmpObj = jsonObj.get(keys[i][0]) ;

      //取得値をユーザIDとしてLongへパース
      userId = parseLong(tmpObj) ;

      //数値変換でエラーなので無視
      if(null == userId ) continue ;

      userIdList.add(userId) ;
    }

    //-----------------------------------------------
    //ユーザー情報の取得 from DB6 mst_personal_user

    //施設コード(引数)
    List<String> facilityCdList = new ArrayList<String>() ;
    facilityCdList.add(facilityCd) ;

    //戻り値の構成
    // {{"与えたid","名前(姓)","名前(名)"},・・・}

    //DBから取得
    List<String[]> namesList = conditionSendResultUtilUserService.getUsersNames(facilityCdList,userIdList,cryptoFlag);

    //穴埋め
    Long keyUserId = null ;
    for(int j = 0 ; j < keys.length ; j++)
    {
      keyUserId = parseLong(getValueFromJson(jsonObj,keys[j][0])) ;
      //longに変換できないので処理しない
      if(null == keyUserId) continue ;

      for(int i = 0 ; i < namesList.size() ; i++)
      {
        userId = Long.parseLong(namesList.get(i)[0]);
        if(userId.equals(keyUserId))
        {
          //名前の挿入
          jsonObj.put(keys[j][1], namesList.get(i)[1]) ;
          jsonObj.put(keys[j][2], namesList.get(i)[2]) ;
          break ;
        }
      }
    }

    ret = jsonObj;

    return ret ;
  }
  /**
   * Jsonオブジェクトからの値取得処理
   * 値が取得できない場合(キーが存在しないなど)はnullを返却する
   * @param jsonObj　JSONオブジェクト
   * @param key     キー
   * @return    取得した値(値がない場合null)
   */
// mod 11454 時間外加算自動処理が機能していない zkm start
//  private Object getDataFromJSON(JSONObject jsonObj ,String key)
  public Object getDataFromJSON(JSONObject jsonObj ,String key)
// mod 11454 時間外加算自動処理が機能していない zkm end
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
  /**
   * 受信データ取得処理
   * ボディで送られてきたJSONデータを分解取得する
   * @param bodydata    送信されてきたデータ
   * @param retVal      PARAMKEY:Object　返却値
   *                PARAMKEY.RECEIVE_DATA   送信データ(JSON)
   * @return    true:成功　false：失敗
   */
// mod 11454 時間外加算自動処理が機能していない zkm start
//  private boolean getDataFromBodyData(
  public boolean getDataFromBodyData(
// mod 11454 時間外加算自動処理が機能していない zkm end
      String bodydata,
      HashMap<PARAMKEY,Object> retVal
    )
  {
    boolean ret = true ;
    HttpStatus status = HttpStatus.OK; ;
    String retMsg = "", retLogMsg = "";
    JSONObject receiveData = null ;

    try {
      //受信パラメータのJson化
      receiveData= new JSONObject(bodydata) ;
    }
    catch(JSONException e)
    {
      // Jsonパースに失敗
      status = HttpStatus.INTERNAL_SERVER_ERROR ;
      retMsg = String.format("送信データエラー") ;
      retLogMsg = String.format("パースに失敗しました。 %s", e.getMessage()) ;
      ret = false ;
    }
    finally {
      //戻り値の設定
      // Httpステータス
      retVal.put(PARAMKEY.STATUS, status) ;
      // メッセージ
      retVal.put(PARAMKEY.MSG, retMsg);
      retVal.put(PARAMKEY.ERRMSG, retLogMsg);
      // 受信データ
      retVal.put(PARAMKEY.RECEIVE_DATA, receiveData) ;
    }

    return ret ;
  }

  /**
   * デバッグ出力
   * CONSTDEF.DEBUGFLAGの値が"1"の場合、出力する
   * @param str 出力文字列
   */
  private void dbgPrint(String str)
  {
    //CONSTDEF.DEBUGFLAGの値を確認
    if(CONSTDEF.DEBUGFLAG.get().equals("1"))
    {
      //CONSTDEF.DEBUGFLAGが"1"だったので出力
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(str);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    }


  }

  /**
   * 分類区分取得処理
   *
   * @param cd           医療材料コードと薬剤コード
   * @param classTypeflg 0:医療材料分類; 1:薬剤分類;
   * @param facilityCd   施設コード
   * @return classType
   */
  private MstEquipmentMstMedicine getClassType(int cd, int classTypeflg, String facilityCd) {
    MstEquipmentMstMedicine classType = new MstEquipmentMstMedicine();
    if (classTypeflg == 0) {
      classType = ordMainDao.selectClassTypeFromMstEquipment(cd, facilityCd);
    }
    if (classTypeflg == 1) {
      classType = ordMainDao.selectClassTypeFromMstMedicine(cd, facilityCd);
      if (classType == null) {
        classType = ordMainDao.selectClassTypeFromMstMedicineMix(cd, facilityCd);
      }
    }
    return classType;
  }

  //add 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 start zhao
  public Integer toWeight(String weigh){
    if("null".equals(weigh)){
      return 0;
    }else {
      return Integer.parseInt(weigh);
    }

  }
  //add 9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 end zhao

  /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
  /**
   * 薬剤/医療材料/ダイアライザ 名前の接頭辞取得
   * @param patTabooAllergyInfo  禁忌・アレルギー情報(患者)
   * @param tabooAllergyList     禁忌・アレルギーマスタ
   * @param dataType             データ型
   *                                 "1":普通薬剤 "2":調製薬剤 "3":医材 "4":ダイアライザ
   * @param cd                   薬剤コード/医療材料コード/ダイアライザコード
   * @param itemCd               治療条件項目番号
   * @param classType            薬剤分類コード/医療材料分類コード
   * @param useEndDate           使用終了日
   * @param isDisp               表示フラグ
   * @param isDel                削除フラグ
   * @param indDeviceMode        装置モード
   * @return
   */
  private String getPrefixOfName(String patTabooAllergyInfo, List<MstTabooAllergy> tabooAllergyList
          , String dataType, Integer cd, String itemCd, Integer classType, String useEndDate
          , String isDisp, String isDel, Integer indDeviceMode) {
    StringBuilder prefixName = new StringBuilder();
    // 【禁忌・ｱﾚﾙｷﾞｰ】、【禁忌】、【ｱﾚﾙｷﾞｰ】prefix supplementation
    String tabooAllergyType = getTabooAllergyType(patTabooAllergyInfo, tabooAllergyList, dataType, cd);
    if (!ObjectUtils.isEmpty(tabooAllergyType)) {
      String tabooAllergyPrefix = "";
      if ("1".equals(tabooAllergyType)) { // 禁忌
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.TABOO;
      } else if ("2".equals(tabooAllergyType)) { // ｱﾚﾙｷﾞｰ
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.ALLERGY;
      } else if ("3".equals(tabooAllergyType)) { // 禁忌・ｱﾚﾙｷﾞｰ
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.TABOO_AND_ALLERGY;
      }
      prefixName.append(tabooAllergyPrefix);
    }

    // 【分類不一致】prefix supplementation
    if (isDataInconsistentClassification(itemCd, classType, indDeviceMode)) {
      prefixName.append(CoreConstant.NamePrefixJapan.INCONSISTENT_CLASSIFICATION);
    }

    // 【期限切れ】prefix supplementation
    if (isDataExpired(useEndDate)) {
      prefixName.append(CoreConstant.NamePrefixJapan.EXPIRED);
    }

    // 【削除済み】prefix supplementation
    if (isDataDeleted(isDisp, isDel)) {
      prefixName.append(CoreConstant.NamePrefixJapan.DELETED);
    }

    return prefixName.toString();
  }

  /**
   * 調整薬剤 名前の接頭辞取得
   * @param patTabooAllergyInfo  禁忌・アレルギー情報(患者)
   * @param tabooAllergyList     禁忌・アレルギーマスタ
   * @param cd                   調整薬剤コード
   * @param itemCd               治療条件項目番号
   * @param classType            調整薬剤分類コード
   * @param isDisp               表示フラグ
   * @param isDel                削除フラグ
   * @param mixInfo              調整薬剤情報
   * @param facilityCd           施設コード
   * @return
   */
  private String getMedicineMixPrefixOfName(String patTabooAllergyInfo, List<MstTabooAllergy> tabooAllergyList
          , Integer cd, String itemCd, Integer classType, String isDisp, String isDel, String mixInfo, String facilityCd) {
    StringBuilder prefixName = new StringBuilder();
    JSONArray mixInfoJSONArray = ObjectUtils.isEmpty(mixInfo) ? new JSONArray() : new JSONArray(mixInfo);

    // 【禁忌・ｱﾚﾙｷﾞｰ】、【禁忌】、【ｱﾚﾙｷﾞｰ】prefix supplementation
    String tabooAllergyType = getTabooAllergyType(patTabooAllergyInfo, tabooAllergyList, "2", cd);
    boolean isDataExpired = false;
    boolean isDataIncludeDeleted = false;
    boolean isDataDeleted = isDataDeleted(isDisp, isDel);

    if (tabooAllergyType != null && !"3".equals(tabooAllergyType)) {
      Set<String> tabooAllergyTypeSet = new HashSet<>();
      if (!"".equals(tabooAllergyType)) {
        tabooAllergyTypeSet.add(tabooAllergyType);
      }
      for (int i = 0; i < mixInfoJSONArray.length(); i++) {
        JSONObject mediObj = mixInfoJSONArray.getJSONObject(i);
        if (mediObj == null || mediObj.get(PARAMKEY.MEDI_CD.get()) == null) {
          continue;
        }

        String subTabooAllergyType = getTabooAllergyType(patTabooAllergyInfo, tabooAllergyList
                , "1", Integer.valueOf(mediObj.get(PARAMKEY.MEDI_CD.get()).toString()));
        if (!ObjectUtils.isEmpty(subTabooAllergyType)) {
          if ("3".equals(subTabooAllergyType)) {
            tabooAllergyType = subTabooAllergyType;
            break;
          }
          tabooAllergyTypeSet.add(subTabooAllergyType);
        }
      }

      if (tabooAllergyTypeSet.size() != 0) {
        if (tabooAllergyTypeSet.contains("1") && tabooAllergyTypeSet.contains("2")) {
          tabooAllergyType = "3";
        } else if (tabooAllergyTypeSet.contains("1") && !tabooAllergyTypeSet.contains("2")) {
          tabooAllergyType = "1";
        } else if (!tabooAllergyTypeSet.contains("1") && tabooAllergyTypeSet.contains("2")) {
          tabooAllergyType = "2";
        }
      }
    }

    for (int i = 0; i < mixInfoJSONArray.length(); i++) {
      JSONObject mediObj = mixInfoJSONArray.getJSONObject(i);
      if (mediObj == null || mediObj.get(PARAMKEY.MEDI_CD.get()) == null) {
        continue;
      }

      Map<String,Object> mediMap = conditionSendResultUtilService.getMedicineInfo(
              facilityCd,
              1,
              Integer.valueOf(mediObj.get(PARAMKEY.MEDI_CD.get()).toString()));
      if (mediMap != null) {
        Object useEndDateObj = getValueFromMap(mediMap, PARAMKEY.DATA_USE_END_DATE.get());
        String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
        if (isDataExpired(useEndDate)) {
          isDataExpired = true;
        }

        if (!isDataDeleted) {
          String isDispToSub = getValueFromMap(mediMap, PARAMKEY.DATA_IS_DISP.get()).toString();
          String isDelToSub = getValueFromMap(mediMap, PARAMKEY.DATA_IS_DEL.get()).toString();
          if (isDataDeleted(isDispToSub, isDelToSub)) {
            isDataIncludeDeleted = true;
          }
        }
      } else {
        isDataIncludeDeleted = true;
      }
    }

    // 【禁忌・ｱﾚﾙｷﾞｰ】、【禁忌】、【ｱﾚﾙｷﾞｰ】prefix supplementation
    if (!ObjectUtils.isEmpty(tabooAllergyType)) {
      String tabooAllergyPrefix = "";
      if ("1".equals(tabooAllergyType)) {  // 禁忌
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.TABOO;
      } else if ("2".equals(tabooAllergyType)) {  // ｱﾚﾙｷﾞｰ
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.ALLERGY;
      } else if ("3".equals(tabooAllergyType)) {  // 禁忌・ｱﾚﾙｷﾞｰ
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.TABOO_AND_ALLERGY;
      }
      prefixName.append(tabooAllergyPrefix);
    }

    // 【分類不一致】prefix supplementation
    if (isDataInconsistentClassification(itemCd, classType, null)) {
      prefixName.append(CoreConstant.NamePrefixJapan.INCONSISTENT_CLASSIFICATION);
    }

    // 【期限切れ】prefix supplementation
    if (isDataExpired) {
      prefixName.append(CoreConstant.NamePrefixJapan.EXPIRED);
    }

    // 【削除済み】prefix supplementation
    if (isDataDeleted) {
      prefixName.append(CoreConstant.NamePrefixJapan.DELETED);
    } else {
      if (isDataIncludeDeleted) {
        prefixName.append(CoreConstant.NamePrefixJapan.INCLUDE_DELETED);
      }
    }

    return prefixName.toString();
  }

  /**
   * Judgment of contraindications and allergies
   * @param patTabooAllergyInfo  禁忌・アレルギー情報(患者)
   * @param tabooAllergyList     禁忌・アレルギーマスタ
   * @param dataType             データ型
   *                                "1":普通薬剤 "2":調製薬剤 "3":医材 "4":ダイアライザ
   * @param cd                   薬剤コード/医療材料コード/ダイアライザコード
   * @return  "": 内容がありません  "1":禁忌  "2":ｱﾚﾙｷﾞｰ  "3":禁忌・ｱﾚﾙｷﾞｰ
   */
  private String getTabooAllergyType(String patTabooAllergyInfo, List<MstTabooAllergy> tabooAllergyList
          , String dataType, Integer cd) {
    if (ObjectUtils.isEmpty(patTabooAllergyInfo) || "[]".equals(patTabooAllergyInfo)) {
      return null;
    }

    try {
      List<PatInfoTabooAllergy> tabooAllergyInfoList = new ObjectMapper()
              .readValue(patTabooAllergyInfo, new TypeReference<ArrayList<PatInfoTabooAllergy>>() {});
      boolean tabooFlag = false;    // 禁忌存在フラグ
      boolean allergyFlag = false;  // アレルギ存在マーカー
      for (PatInfoTabooAllergy tabooAllergyInfo : tabooAllergyInfoList) {
        String tabooAllergyCd = tabooAllergyInfo.getTaboo_allergy_cd();
        Optional<MstTabooAllergy> mstTabooAllergy = tabooAllergyList.stream()
                .filter(a -> a.getTabooAllergyCd().equals(tabooAllergyCd)).findFirst();
        if (mstTabooAllergy.isPresent()) {
          List<MstTabooAllergyDetailInfo> tabooAllergyDetailInfoList = new ObjectMapper()
                  .readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<ArrayList<MstTabooAllergyDetailInfo>>() {});
          int existsCount = tabooAllergyDetailInfoList.stream()
                  .filter(t -> dataType.equals(t.getClassCd()) && cd.toString().equals(t.getCd()))
                  .collect(Collectors.toList()).size();
          if (existsCount > 0) {
            if ("1".equals(tabooAllergyInfo.getTaboo_allergy_class())) {
              // 禁忌
              tabooFlag = true;
            } else if ("2".equals(tabooAllergyInfo.getTaboo_allergy_class())) {
              // アレルギー
              allergyFlag = true;
            }
          }
        }
      }

      if (tabooFlag && !allergyFlag) {
        // 禁忌
        return "1";
      } else if (!tabooFlag && allergyFlag) {
        // ｱﾚﾙｷﾞｰ
        return "2";
      } else if (tabooFlag && allergyFlag) {
        // 禁忌・ｱﾚﾙｷﾞｰ
        return "3";
      }
    } catch (JsonProcessingException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }
    return "";
  }

  /**
   * Determine if data classification is inconsistent
   * @param itemCd      治療条件項目番号
   * @param classType   薬剤分類コード/医療材料分類コード
   * @param indDeviceMode  装置モード
   * @return
   */
  private boolean isDataInconsistentClassification(String itemCd, Integer classType, Integer indDeviceMode) {
    // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
    //    if (ObjectUtils.isEmpty(itemCd) || ObjectUtils.isEmpty(classType)) {
    //      return false;
    //    }
    if (ObjectUtils.isEmpty(itemCd)) {
      return false;
    }
    // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
    Set<Integer> needClassTypeSet = new HashSet<>();
    switch (itemCd) {
      case "6":  // 吸着カラム
        // 4:医材分類-吸着カラム
        needClassTypeSet.add(4);
        break;
      case "7":  // 1次膜
      case "8":  // 2次膜
        // 5:医材分類-吸着器
        needClassTypeSet.add(5);
        // 6:医材分類-分離器
        needClassTypeSet.add(6);
        break;
      case "9":  // 穿刺針(A)
      case "10": // 穿刺針(V)
      case "15": // 透析液
        // 2:薬剂分類-透析液/医材分類-穿刺針(SN以外)
        needClassTypeSet.add(2);
        break;
      case "11": // 穿刺針(SN)
        // 3:医材分類-穿刺針(SN)
        needClassTypeSet.add(3);
        break;
      case "19": // 補液
        // OHDF、OHF、I-HDF 補液=透析液
        if (indDeviceMode != null
                && (indDeviceMode == 7 || indDeviceMode == 8 || indDeviceMode == 10)) {
          // 2:薬剂分類-透析液
          needClassTypeSet.add(2);
        } else {
          // 3:薬剂分類-補液
          needClassTypeSet.add(3);
        }
        break;
      case "13": // 血液回路
      case "25": // 抗凝固剤
        // 1:薬剂分類-抗凝固剤/医材分類-血液回路
        needClassTypeSet.add(1);
        break;
      default:
        break;
    }
    // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
    if (needClassTypeSet.size() == 0) {
      return false;
    }
    // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
    if (!needClassTypeSet.contains(classType)) {
      return true;
    }

    return false;
  }

  /**
   * Determine whether the data has expired
   * @param useEndDate     使用終了日（yyyyMMdd）
   * @return true: expired
   */
  private boolean isDataExpired(String useEndDate) {
    if (ObjectUtils.isEmpty(useEndDate) || useEndDate.length() != 8) {
      return false;
    }
    try{
      LocalDate endDate = LocalDate.parse(useEndDate, DateTimeFormatter.ofPattern("yyyyMMdd"));
      LocalDate currentDate = LocalDate.now();
      // expiration date before current date
      if (endDate.isBefore(currentDate)) {
        return true;
      }
    }catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }

    return false;
  }

  /**
   * Determine if the data has been deleted
   * @param isDisp 表示フラグ
   * @param isDel  削除フラグ
   * @return  true: deleted
   */
  private boolean isDataDeleted(String isDisp, String isDel) {
    if (ObjectUtils.isEmpty(isDisp) || ObjectUtils.isEmpty(isDel)) {
      return true;
    }

    if ("0".equals(isDisp) || "1".equals(isDel)) {
      return true;
    }
    return false;
  }
  /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */

  // add 10739 by shiyw 20250303 start
  public String processPatIndApproveJson(String facilityCd, Long ordNo, String content) {
      OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
      if (!"0".equals(ordMain.getRstDialysisState())) {
        return content;
      }
      PatMain patMainData = conditionSendResultUtilService.getPatMainInfo(ordMain.getPatId());
      if (null == patMainData) {
        return content;
      }
      //ord_mainの各コード項目の名称等を該当テーブルから取得する
      Map<String, Object> namesMap = conditionSendResultUtilService.getNamesFromDbs(ordNo);
      if (null == namesMap) {
        //名称の取得失敗
        return content;
      }
      // 指示：device_mode
      BigDecimal indDdeviceModeDcl = (BigDecimal) getValueFromMap(namesMap, PARAMKEY.DEVICE_MODE.get());
      Integer indDeviceMode = indDdeviceModeDcl.intValue();

      // 禁忌・アレルギーを取得
      MstTabooAllergy mstTabooAllergy = new MstTabooAllergy();
      mstTabooAllergy.setFacilityCd(facilityCd);
      List<MstTabooAllergy> tabooAllergyList = null;
      String patTabooAllergyInfo = patMainData.getTaboo_allergy_info();
      if (!ObjectUtils.isEmpty(patTabooAllergyInfo) && !"[]".equals(patTabooAllergyInfo)) {
        tabooAllergyList = mstTabooAllergyDao.selectAll(SelectOptions.get(), mstTabooAllergy);
      }

      try {
        JsonNode checkContentNode = objectMapper.readTree(content);
        Map<Integer, String> unitMap = new HashMap<>();
        for (JsonNode node : checkContentNode) {
          int subCategoryNo = node.get("subCategoryNo").asInt();
          String PREFIX = "prefix";
          String DISP_VAL = "dispVal";
          // 治療方法
          if (subCategoryNo == 2) {
            JsonNode itemInfo = node.get("itemInfo");
            // nullの場合は-2を返します
            Integer itemCd = itemInfo.get("itemCd").asInt(-2);
            if (itemCd != -2) {
              MstTreatment mstTreatment = mstTreatmentDao.selectByCd(itemCd);
              JsonNode value = itemInfo.get("data").get("value");
              ObjectNode valueNode = (ObjectNode) value;
              if (mstTreatment != null) {
                if (value.isObject()) {
                  valueNode.put(DISP_VAL, mstTreatment.getTreatmentName());
                }
              } else {
                MstTreatment mstParams = new MstTreatment();
                mstParams.setFacilityCd(facilityCd);
                List<MstTreatment> delMstTreatments = mstTreatmentDao.selectAllDel(SelectOptions.get(), mstParams);
                Optional<MstTreatment> delTreatment = delMstTreatments.stream().filter(t -> t.getTreatmentCd().equals(itemCd)).findAny();
                if (delTreatment.isPresent()) {
                  valueNode.put(PREFIX, CoreConstant.NamePrefixJapan.DELETED);
                  valueNode.put(DISP_VAL, delTreatment.get().getTreatmentName());
                }
              }
            }
          } else {
            JsonNode subCategoryItems = node.get("subCategoryItem");
            String UNIT = "unit";
            for (JsonNode item : subCategoryItems) {
              JsonNode itemInfo = item.get("itemInfo");
              int itemNo = itemInfo.get("itemNo").asInt(-2); // nullの場合は-2を返します
              Integer itemCd;
              if (itemInfo.get("itemCd").equals("未登録")) {
                itemCd = -2;
              } else {
                itemCd = itemInfo.get("itemCd").asInt(-2); // nullの場合は-2を返します
              }
              Integer itemType = itemInfo.get("itemType").asInt(-2); // nullの場合は-2を返します
              JsonNode value = itemInfo.get("data").get("value");
              ObjectNode valueNode = (ObjectNode) value;
              if (itemCd == -2 && 4 != subCategoryNo || !value.isObject()) {
                continue;
              }

              // スケジュール
              if (subCategoryNo == 3) {
                // 指示：クール名
                if (itemNo == 1) {
                  MstKur mstKur = mstKurDao.selectByKurCd(String.valueOf(itemCd));
                  if (mstKur != null) {
                    if (value.isObject()) {
                      valueNode.put(DISP_VAL, mstKur.getKurName());
                    }
                  } else {
                    List<MstKur> delMstKurs = mstKurDao.selectByFacilityCdDel(SelectOptions.get(), facilityCd);
                    Optional<MstKur> delKur = delMstKurs.stream().filter(t -> t.getKurCd().equals(itemCd)).findAny();
                    if (delKur.isPresent()) {
                      valueNode.put(PREFIX, CoreConstant.NamePrefixJapan.DELETED);
                      valueNode.put(DISP_VAL, delKur.get().getKurName());
                    }
                  }
                }
                // 指示：ベッド名
                if (itemNo == 3) {
                  MstBed mstBed = mstBedDao.selectByBedCd(Long.valueOf(itemCd), null, null);
                  if (mstBed != null) {
                    valueNode.put(DISP_VAL, mstBed.getBedName());
                    if (!"1".equals(mstBed.getIsDisp())) {
                      valueNode.put(PREFIX, CoreConstant.NamePrefixJapan.DELETED);
                    }
                  }
                }
              }
              // 治療条件
              else if (subCategoryNo == 4) {
                // 2:  VA
                // 5:  ダイアライザ
                // 6:  吸着カラム
                // 7:  1次膜
                // 8:  2次膜
                // 9:  穿刺針(A針)
                // 10: 穿刺針(V針)
                // 11: 穿刺針(SN)
                // 13: 血液回路
                // 15: 透析液
                // 19: 補液
                // 25: 抗凝固剤
                Set<Integer> indCondKeys = Set.of(2, 5, 6, 7, 8, 9, 10, 11, 13, 15, 19, 25);
                if (indCondKeys.contains(itemNo)) {
                  if (-2 == itemCd) {
                    valueNode.put(DISP_VAL, "未登録");
                    continue;
                  }
                  switch (itemNo) {
                    case 2:
                      //名称をまとめて取得
                      List<Map<String, Object>> vaMapList = conditionSendResultUtilService
                        .getNameListWithCase(PARAMKEY.COND_CAT_VA.get(), facilityCd, List.of(itemCd));

                      Optional<Map<String, Object>> vaMap = vaMapList.stream()
                        .filter(e -> Integer.valueOf(itemCd).equals(e.get(PARAMKEY.COND_CD.get()))).findFirst();
                      if (vaMap.isPresent()) {
                        String equipmentName = vaMap.get().get(PARAMKEY.COND_NAME.get()).toString();
                        String prefixName = "";
                        String isDisp = vaMap.get().get(PARAMKEY.DATA_IS_DISP.get()).toString();
                        String isDel = vaMap.get().get(PARAMKEY.DATA_IS_DEL.get()).toString();
                        if (isDataDeleted(isDisp, isDel)) {
                          prefixName = CoreConstant.NamePrefixJapan.DELETED;
                        }
                        valueNode.put(PREFIX, prefixName);
                        valueNode.put(DISP_VAL, equipmentName);
                      } else {
                        valueNode.put(PREFIX, CoreConstant.NamePrefixJapan.DELETED);
                      }
                      break;
                    case 5:
                      Map<String, Object> dialyzerMap = conditionSendResultUtilService.getDialyzerNames(facilityCd, itemCd);
                      if (dialyzerMap != null) {
                        String dialyzerName = getValueFromMap(dialyzerMap, PARAMKEY.COND_MODEL_NUMBER.get()).toString();
                        dialyzerName = dialyzerName == null ? "" : "[" + dialyzerName + "]";
                        Object useEndDateObj = getValueFromMap(dialyzerMap, PARAMKEY.DATA_USE_END_DATE.get());
                        String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
                        String isDisp = getValueFromMap(dialyzerMap, PARAMKEY.DATA_IS_DISP.get()).toString();
                        String isDel = getValueFromMap(dialyzerMap, PARAMKEY.DATA_IS_DEL.get()).toString();
                        String prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, "4", itemCd
                          , "5", null, useEndDate, isDisp, isDel, null);
                        valueNode.put(PREFIX, prefixName);
                        valueNode.put(DISP_VAL, dialyzerName);
                      } else {
                        valueNode.put(PREFIX, CoreConstant.NamePrefixJapan.DELETED);
                      }
                      break;
                    case 6, 7, 8, 9, 10, 11, 13:
                      //名称をまとめて取得
                      List<Map<String, Object>> equipMapList = conditionSendResultUtilService
                        .getNameListWithCase(PARAMKEY.COND_CAT_EQUIP.get(), facilityCd, List.of(itemCd));

                      Optional<Map<String, Object>> equipMap = equipMapList.stream()
                        .filter(e -> Integer.valueOf(itemCd).equals(e.get(PARAMKEY.COND_CD.get()))).findFirst();
                      if (equipMap.isPresent()) {
                        String equipmentName = equipMap.get().get(PARAMKEY.COND_NAME.get()).toString();
                        String prefixName = "";
                        String isDisp = equipMap.get().get(PARAMKEY.DATA_IS_DISP.get()).toString();
                        String isDel = equipMap.get().get(PARAMKEY.DATA_IS_DEL.get()).toString();
                        Integer classType = parseInteger(equipMap.get().get(PARAMKEY.EQUI_CLASS_TYPE.get()));
                        Object useEndDateObj = equipMap.get().get(PARAMKEY.DATA_USE_END_DATE.get());
                        String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
                        prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, "3", itemCd
                          , String.valueOf(itemNo), classType, useEndDate, isDisp, isDel, null);
                        valueNode.put(PREFIX, prefixName);
                        valueNode.put(DISP_VAL, equipmentName);
                      } else {
                        valueNode.put(PREFIX, CoreConstant.NamePrefixJapan.DELETED);
                      }
                      break;
                    case 15, 19, 25:
                      if (-2 == itemType) {
                        continue;
                      }
                      // DBからデータを取得
                      Map<String, Object> medicineMap = conditionSendResultUtilService
                        .getMedicineInfo(facilityCd, itemType, itemCd);
                      if (null != medicineMap) {
                        String medicineName = medicineMap.get(PARAMKEY.MEDI_NAME.get()).toString();
                        Integer classType = parseInteger(medicineMap.get(PARAMKEY.MEDI_CLASS_TYPE.get()));
                        Object useEndDateObj = medicineMap.get(PARAMKEY.DATA_USE_END_DATE.get());
                        String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
                        String isDisp = medicineMap.get(PARAMKEY.DATA_IS_DISP.get()).toString();
                        String isDel = medicineMap.get(PARAMKEY.DATA_IS_DEL.get()).toString();
                        String prefixName = "";
                        if (itemType == 1) {
                          prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, String.valueOf(itemType)
                            , itemCd, String.valueOf(itemNo), classType, useEndDate, isDisp, isDel, indDeviceMode);
                        } else if (itemType == 2) {
                          String mixInfo = medicineMap.get(PARAMKEY.MEDI_MIX_INFO.get()).toString();
                          prefixName = getMedicineMixPrefixOfName(patTabooAllergyInfo, tabooAllergyList
                            , itemCd, String.valueOf(itemNo), classType, isDisp, isDel, mixInfo, facilityCd);
                        }
                        valueNode.put(PREFIX, prefixName);
                        valueNode.put(DISP_VAL, medicineName);
                        if (List.of(15, 19).contains(itemNo)) {
                          unitMap.put(itemNo, medicineMap.get(PARAMKEY.COND_UNIT_SECOND.get()) != null ? (String) medicineMap.get(PARAMKEY.COND_UNIT_SECOND.get()) : null);
                        } else {
                          unitMap.put(itemNo, medicineMap.get(PARAMKEY.COND_UNIT.get()) != null ? (String) medicineMap.get(PARAMKEY.COND_UNIT.get()) : null);
                        }
                      } else {
                        valueNode.put(PREFIX, CoreConstant.NamePrefixJapan.DELETED);
                      }
                      break;
                    default:
                      break;
                  }
                }
              }
              // 投与薬剤
              else if (subCategoryNo == 5) {
                //取得したコードを元に薬剤情報から名称を取得(DBから)
                Map<String, Object> mediMap = conditionSendResultUtilService.getMedicineInfo(
                  facilityCd,
                  itemType,
                  itemCd);

                if (mediMap != null) {
                  //Jsonにセット(名称穴埋め)
                  Object useEndDateObj = getValueFromMap(mediMap, PARAMKEY.DATA_USE_END_DATE.get());
                  String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
                  String isDisp = getValueFromMap(mediMap, PARAMKEY.DATA_IS_DISP.get()).toString();
                  String isDel = getValueFromMap(mediMap, PARAMKEY.DATA_IS_DEL.get()).toString();
                  String prefixName = "";
                  if (itemType == 1) {
                    prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, itemType.toString(), itemCd
                      , null, null, useEndDate, isDisp, isDel, null);
                  } else if (itemType == 2) {
                    String mixInfo = getValueFromMap(mediMap, PARAMKEY.MEDI_MIX_INFO.get()).toString();
                    prefixName = getMedicineMixPrefixOfName(patTabooAllergyInfo, tabooAllergyList, itemCd
                      , null, null, isDisp, isDel, mixInfo, facilityCd);
                  }
                  valueNode.put(PREFIX, prefixName);
                  valueNode.put(UNIT, null != getValueFromMap(mediMap, PARAMKEY.MEDI_UNIT.get())
                    ? String.valueOf(getValueFromMap(mediMap, PARAMKEY.MEDI_UNIT.get())) : "");
                } else {
                  valueNode.put(PREFIX, CoreConstant.NamePrefixJapan.DELETED);
                }
              }
              // 医療材料
              else if (subCategoryNo == 6) {
                if (itemType == 0) {
                  //取得したコードを元に医療材料情報から名称を取得(DBから)
                  Map<String, Object> map = conditionSendResultUtilService.getEquipmentInfo(
                    facilityCd,
                    itemCd);

                  if (map != null) {
                    Object useEndDateObj = getValueFromMap(map, PARAMKEY.DATA_USE_END_DATE.get());
                    String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
                    String isDisp = getValueFromMap(map, PARAMKEY.DATA_IS_DISP.get()).toString();
                    String isDel = getValueFromMap(map, PARAMKEY.DATA_IS_DEL.get()).toString();
                    String prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, "3", itemCd
                      , null, null, useEndDate, isDisp, isDel, null);
                    valueNode.put(PREFIX, prefixName);
                    valueNode.put(UNIT, null != getValueFromMap(map, PARAMKEY.EQUI_UNIT.get())
                      ? String.valueOf(getValueFromMap(map, PARAMKEY.EQUI_UNIT.get())) : "");
                  } else {
                    valueNode.put(PREFIX, CoreConstant.NamePrefixJapan.DELETED);
                  }
                } else if (itemType == 1) {
                  Map<String, Object> map = conditionSendResultUtilService.getDialyzerNames(
                    facilityCd,
                    itemCd);
                  if (map != null) {
                    Object useEndDateObj = getValueFromMap(map, PARAMKEY.DATA_USE_END_DATE.get());
                    String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
                    String isDisp = getValueFromMap(map, PARAMKEY.DATA_IS_DISP.get()).toString();
                    String isDel = getValueFromMap(map, PARAMKEY.DATA_IS_DEL.get()).toString();
                    String prefixName = getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, "4", itemCd
                      , null, null, useEndDate, isDisp, isDel, null);
                    valueNode.put(PREFIX, prefixName);
                    valueNode.put(UNIT, "本");
                  } else {
                    valueNode.put(PREFIX, CoreConstant.NamePrefixJapan.DELETED);
                  }
                }
              }
            }
            // unit 設定
            if (subCategoryNo == 4) {
              for (JsonNode item : subCategoryItems) {
                JsonNode itemInfo = item.get("itemInfo");
                int itemNo = itemInfo.get("itemNo").asInt(-2); // nullの場合は-2を返します
                JsonNode value = itemInfo.get("data").get("value");
                ObjectNode valueNode = (ObjectNode) value;
                if (!value.isObject()) {
                  continue;
                }

                // -1:  dw
                // 1:  治療時間
                // 3:  目標体重
                // 4:  除水量制限
                // 12: シングルニードル使用
                // 14: 血流量
                // 16: 透析液流量
                // 17: 透析液使用数
                // 18: 透析液温度
                // 20: 補液量
                // 21: 補液選択
                // 22: 補液使用数
                // 23: 補液温度
                // 24: 補液速度
                // 26: 抗凝固剤ワンショット量
                // 27: 抗凝固剤持続速度
                // 28: 抗凝固剤持続総量
                // 29: IP使用選択
                // 30: IPスタート
                // 31: IPワンショット量
                // 32: IP速度
                // 33: IP速度最大値
                // 34: IPワンショットスタート
                // 35: IP電源自動切り
                // 36: IP電源自動切り時間
                // 37: IP電源OKモニタ切り
                // 38: IP電源OKモニタ切り時間
                Set<Integer> indCondKeys = Set.of(-1,1,3,4,12,14,16,17,18,20,21,22,23,24,26,27,28,29,30,31,32,33,34,35,36,37,38);
                if (indCondKeys.contains(itemNo)) {
                  String dispVal = valueNode.get(DISP_VAL).asText("no value");
                  if ("no value".equals(dispVal)) {
                    continue;
                  }
                  String unit = switch (itemNo) {
                    case 3 -> "-1".equals(dispVal) ? null : "kg";
                    case 4,20 -> "L";
                    case 14, 16 -> "mL/min";
                    case 17 -> unitMap.getOrDefault(15, null);
                    case 22 -> unitMap.getOrDefault(19, null);
                    case 18, 23 ->"℃";
                    case 24 -> "L/h";
                    case 26, 28 -> unitMap.containsKey(25) ? StringUtils.isNullOrEmpty(unitMap.get(25)) ? null : unitMap.get(25) : null;
                    case 27 -> unitMap.containsKey(25) ? StringUtils.isNullOrEmpty(unitMap.get(25)) ? null : unitMap.get(25) + "/h" : null;
                    case 31 -> "mL";
                    case 32,33 -> "mL/h";
                    case 36,38 -> "分";
                    default -> null;
                  };
                  valueNode.put(UNIT, unit);
                }
              }
            }
          }
        }
        return objectMapper.writeValueAsString(checkContentNode);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (facilityCd != null) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
      return null;
    }
  // add 10739 by shiyw 20250303 end
}
