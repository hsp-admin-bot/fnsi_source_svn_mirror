package jp.co.nikkiso.ntss.core.constant;

import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstVaDao;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstVa;
import jp.co.nikkiso.ntss.core.utils.AppContextUtils;
import org.apache.commons.lang3.StringUtils;
import org.seasar.doma.jdbc.SelectOptions;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.regex.Pattern;

/**
 * 治療条件設定項目定義Enum
 *
 * @author Tao.zhou
 */
public enum TreatmentItemsDef {

  /** 治療時間 */
  T_I_START_DATE("1", "分" , "240"
          , "", "", getItemValueFormatPatten("0" , "0"), 5,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** VA */
  T_I_VA("2", "", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealName(String facilityCd, String cd, Integer type) {
      return getRealNameFromMstVa(facilityCd,cd);
    }
  },
  /** 目標体重 */
  T_I_WEIGHT("3", "Kg", "-1"
          , "300.00", "0.00", getItemValueFormatPatten("2"), 5,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** 除水量制限 */
  T_I_FILTER_LIMIT("4", "L", "5.00"
          , "39.99", "0.00", getItemValueFormatPatten("2"), 4,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** ダイアライザ */
  T_I_DIALYZER("5", "本", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealName(String facilityCd,String cd,Integer type) {
      return getRealNameFromMstDialyzer(facilityCd,cd);
    }
  },
  /** 吸着カラム */
  T_I_COLUMN("6", "", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealUnit(String itemCode,String facilityCd,String cd,Integer type){
      return getRealUnitFromMstEquipment(facilityCd,cd);
    }
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return getRealNameFromMstEquipment(facilityCd,cd);
    }
  },
  /** 1次膜 */
  T_I_FIRST_PASS("7", "", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealUnit(String itemCode,String facilityCd,String cd,Integer type){
      return getRealUnitFromMstEquipment(facilityCd,cd);
    }
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return getRealNameFromMstEquipment(facilityCd,cd);
    }
  },
  /** 2次膜 */
  T_I_SECOND_PASS("8", "", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealUnit(String itemCode,String facilityCd,String cd,Integer type){
      return getRealUnitFromMstEquipment(facilityCd,cd);
    }
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return getRealNameFromMstEquipment(facilityCd,cd);
    }
  } ,
  /** 穿刺針(A) */
  T_I_NEEDLE_A("9", "", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealUnit(String itemCode,String facilityCd,String cd,Integer type){
      return getRealUnitFromMstEquipment(facilityCd,cd);
    }
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return getRealNameFromMstEquipment(facilityCd,cd);
    }
  },
  /** 穿刺針(V) */
  T_I_NEEDLE_V("10", "", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealUnit(String itemCode,String facilityCd,String cd,Integer type){
      return getRealUnitFromMstEquipment(facilityCd,cd);
    }
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return getRealNameFromMstEquipment(facilityCd,cd);
    }
  },
  /** 穿刺針(SN) */
  T_I_NEEDLE_SN("11", "", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealUnit(String itemCode,String facilityCd,String cd,Integer type){
      return getRealUnitFromMstEquipment(facilityCd,cd);
    }
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return getRealNameFromMstEquipment(facilityCd,cd);
    }
  },
  /** シングルニードル */
  T_I_NEEDLE_SELECTION("12", "", "0"
          , "1", "0", getItemValueFormatPatten("1", "0"), 1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")) {
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return "1".equals(cd) ? "使用する" : "使用しない";
    }
  },
  /** 血液回路 */
  // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
  T_I_TUBE("13", "", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
    @Override
    public String getRealUnit(String itemCode,String facilityCd,String cd,Integer type){
      return getRealUnitFromMstEquipment(facilityCd,cd);
    }
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return getRealNameFromMstEquipment(facilityCd,cd);
    }
  },
  /** 血流量 */
  T_I_BLOOD_FLOW("14", "mL/min", "200"
          , "600", "0", getItemValueFormatPatten("3", "0"), 3,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** 透析液 */
  // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
  T_I_DIALYSES("15", "", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "medicine_type",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")) {
    // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end

    /**
     * 薬剤タイプと薬剤コードによる本物の薬剤の入手
     *
     * @param facilityCd 施設コード
     * @param itemCode 項目ID
     * @param cd  薬剤コード
     * @param type  薬剤タイプ
     * @return  薬剤
     */
    @Override
    public String getRealUnit(String itemCode, String facilityCd, String cd, Integer type) {
      return getRealUnitFromMedic(itemCode, facilityCd, cd, type);
    }
    @Override
    public String getRealName(String facilityCd, String cd, Integer type) {
      return getRealNameFromMedic(facilityCd, cd, type);
    }
  },
  /** 透析液流量 */
  T_I_DIALYSES_FLOW_RATE("16", "mL/min", "500"
          , "700", "100", getItemValueFormatPatten("3", "0"), 3,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** 透析液使用数 */
  T_I_DIALYSES_AMOUNT("17", "", "0"
          , "9999999", "0", getItemValueFormatPatten("0", "0"), 7,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealName(String facilityCd, String cd, Integer type) {
      return getRealNameFromMedic(facilityCd, cd, type);
    }
    @Override
    public String getRealUnit(String itemCode, String facilityCd, String cd, Integer type) {
      return getRealUnitSecondFromMedic(itemCode, facilityCd, cd, type);
    }
  },
  /** 透析液温度 */
  T_I_DIALYSES_TEMPERATURE("18", "℃", "36.0"
          , "40.0", "33.0", getItemValueFormatPatten("3", "1"), 4,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** 補液 */
  T_I_IV("19", "", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "medicine_type",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){

    /**
     * 薬剤タイプと薬剤コードによる本物の薬剤の入手
     *
     * @param facilityCd 施設コード
     * @param itemCode 項目ID
     * @param cd  薬剤コード
     * @param type  薬剤タイプ
     * @return  薬剤
     */
    @Override
    public String getRealUnit(String itemCode, String facilityCd, String cd, Integer type) {
      return getRealUnitFromMedic(itemCode, facilityCd, cd, type);
    }

    @Override
    public String getRealName(String facilityCd, String cd, Integer type) {
      return getRealNameFromMedic(facilityCd, cd, type);
    }
  },
  /** 補液量 */
  T_I_IV_AMOUNT("20", "L", "0.0"
          , "999.0", "0.0", getItemValueFormatPatten("4", "1"), 4,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** 補液選択 */
  T_I_IV_SELECTION("21", "", "1"
          , "1", "0", "", 1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")) {
    @Override
    public String getRealName(String facilityCd, String cd, Integer type) {
      return "1".equals(cd) ? "前補液" : "後補液";
    }
  },
  /** 補液使用数 */
  T_I_IV_COUNT("22", "", "0"
          , "99999", "0", getItemValueFormatPatten("5", "0"), 5,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealUnit(String itemCode, String facilityCd, String cd, Integer type) {
      return getRealUnitSecondFromMedic(itemCode,facilityCd,cd,type);
    }
  },
  /** 補液温度 */
  T_I_IV_TEMPERATURE("23", "℃", "36.0"
          , "40.0", "33.0", getItemValueFormatPatten("3", "1"), 4,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** 補液速度 */
  T_I_IV_FLOW_RATE("24", "L/h", "0.00"
          , "999.00", "0.00", getItemValueFormatPatten("5", "2"), 7,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** 抗凝固剤 */
  T_I_ANTICOAGULANT("25", "", null
          , "", "", "", -1,
    Arrays.asList(
      "value",
      "medicine_type",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){

    @Override
    public String getRealName(String facilityCd, String cd, Integer type) {
      return getRealNameFromMedic(facilityCd, cd, type);
    }
    @Override
    public String getRealUnit(String itemCode, String facilityCd, String cd, Integer type) {
      return getRealUnitFromMedic(itemCode,facilityCd,cd,type);
    }
  },
  /** ワンショット量 */
  T_I_ANTICOAGULANT_ONESHOT_AMOUNT("26", "", "0"
          , "9999999", "0", getItemValueFormatPatten("0", "0"), 7,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealUnit(String itemCode, String facilityCd, String cd, Integer type) {
      return getRealUnitFromMedic(itemCode,facilityCd,cd,type);
    }
  },
  /** 持続速度 */
  T_I_ANTICOAGULANT_FLOW_RATE("27", "", "0"
          , "9999999", "0", getItemValueFormatPatten("0", "0"), 7,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealUnit(String itemCode, String facilityCd, String cd, Integer type) {
      return getRealUnitFromMedic(itemCode,facilityCd,cd,type);
    }
  },
  /** 持続総量 */
  T_I_ANTICOAGULANT_AMOUNT_TOTAL("28", "", "0"
          , "9999999", "0", getItemValueFormatPatten("0", "0"), 7,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")){
    @Override
    public String getRealUnit(String itemCode, String facilityCd, String cd, Integer type) {
      return getRealUnitFromMedic(itemCode,facilityCd,cd,type);
    }
  },
  /** IP使用選択 */
  T_I_IP_SELECTION("29", "", "1"
          , "1", "0", getItemValueFormatPatten("1", "0"), 1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")) {
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return "1".equals(cd) ? "使用する" : "使用しない";
    }
  },
  /** IPスタート */
  T_I_IP_START("30",  "", "1"
          , "1", "0", getItemValueFormatPatten("1", "0"), 1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")) {
    @Override
    public String getRealName(String facilityCd, String cd, Integer type) {
      return "0".equals(cd) ? "手動" : "自動";
    }
  },
  /** IPワンショット量 */
  T_I_IP_ONESHOT_AMOUNT("31", "mL", "0.0"
          , "20.0", "0.0", getItemValueFormatPatten("3", "1"), 4,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** IP速度 */
  T_I_IP_FLOW_RATE("32", "mL/h", "0.0"
          , "10.0", "0.0", getItemValueFormatPatten("3", "1"), 4,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** IP速度最大値 */
  T_I_IP_FLOW_RATE_LIMIT("33", "mL/h", "10.0"
          , "10.0", "0.0", getItemValueFormatPatten("3", "1"), 4,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** 自動ワンショット */
  T_I_IP_ONESHOT_SELECTION("34", "", "0"
          , "1", "0", getItemValueFormatPatten("1", "0"), 1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")) {
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return "1".equals(cd) ? "使用する" : "使用しない";
    }
  },
  /** IP電源自動切り */
  T_I_IP_AUTO_OFF("35", "", "0"
          , "1", "0", getItemValueFormatPatten("1", "0"), 1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")) {
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return "0".equals(cd) ? "切" : "入";
    }
  },
  /** IP電源自動切り時間 */
  T_I_IP_AUTO_OFF_TIMING("36", "分前", "0"
          , "120", "0", getItemValueFormatPatten("3", "0"), 3,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** IP電源OKモニタ切り */
  T_I_IP_MONITOR_OFF("37", "", "0"
          , "1", "0", getItemValueFormatPatten("1", "0"), 1,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")) {
    @Override
    public String getRealName(String facilityCd,String cd,Integer type){
      return "0".equals(cd) ? "切" : "入";
    }
  },
  /** IP電源OKモニタ切り時間 */
  T_I_IP_MONITOR_OFF_TIMING("38", "分前", "0"
          , "120", "0", getItemValueFormatPatten("3", "0"), 3,
    Arrays.asList(
      "value",
      "ind_user_id",
      "ind_user_last_name",
      "ind_user_first_name",
      "upd_user_id",
      "upd_user_last_name",
      "upd_user_first_name",
      "input_class",
      "cop_order_no",
      "is_editable")),
  /** DW */
  T_I_DW("39", "", "0.00"
          , "300.00", "0.00", getItemValueFormatPatten("5", "2"), 7, Arrays.asList(
    ""));



  /** 治療条件項目番号 */
  private final String itemCode;

  /** 治療条件項目デフォルト単位 */
  private final String defaultUnit;

  /** 治療条件項目デフォルト設定値：初期値 */
  private final String defaultValue;

  /** 設定値デフォルトフォーマットパータン */
  private final String valueFormatPatten;

  /** 設定値の最大値 */
  private final String maxValue;

  /** 設定値の最小値 */
  private final String minValue;

  /** 設定値桁数 -1:制限しない */
  private final int maxLength;
  /** item对应的value包含的json key */
  private final List<String> defaultJSONKey;

  /**
   * 治療条件情報の初期化設定
   *
   * @param itemCode          項目番号
   * @param defaultUnit       デフォルトの単位値は、不要な場合は空の文字列に設定されます
   * @param defaultValue      デフォルト値。nullに設定されている場合は、そのデフォルト値をnullに設定でき、JSONのnullに再変換する必要があります
   * @param maxValue          最大値（空の文字列またはnullに設定されている場合）は、制限されていないことを示します
   * @param minValue          最小値（空の文字列またはnullに設定されている場合）は、制限されていないことを示します
   * @param valueFormatPatten 設定値のフォーマットされたパターンは、NULLに設定されている場合、取得時に最大長制限を判断して戻り値を決定します。
   *                          1、最大長さが制限されていない場合は、整数パターン:%dを返します。
   *                          2、最大長さが制限されている場合は、純小数パターン:%を返します。[maxLength]f
   * @param maxLength         最大长度限制
   * @param defaultJSONKey    item对应的value包含的json key
   */
  TreatmentItemsDef(String itemCode
          , String defaultUnit
          , String defaultValue
          , String maxValue
          , String minValue
          , String valueFormatPatten
          , int maxLength, List<String> defaultJSONKey
  ) {
    this.itemCode = itemCode;
    this.defaultUnit = defaultUnit;
    this.defaultValue = defaultValue;
    this.maxValue = maxValue;
    this.minValue = minValue;
    this.valueFormatPatten = valueFormatPatten;
    this.maxLength = maxLength;
    this.defaultJSONKey = defaultJSONKey;
  }

  /**
  * @Author kangjie
  * @Description 10150_9664
  * @Date 2024/09/04 11:23
  * @Param [code]
  * @return java.util.List<java.lang.String>
  **/
  public static List<String> getDefaultJSONKeyByCode(String code){
    if (StringUtils.isNoneEmpty(code) && isInteger(code)) {
      Optional<TreatmentItemsDef> first = Arrays.stream(TreatmentItemsDef.values()).filter(
        currentItem -> StringUtils.equals(code, currentItem.getItemCode())).findFirst();
      if (first.isPresent()) {
        return first.get().defaultJSONKey;
      }
    }
    return null;
  }

  /**
   * 項目IDより、治療条件設定項目定義を取得
   *
   * @param itemCode 項目ID
   * @return  治療条件設定項目定義
   */
  public static TreatmentItemsDef getTreatmentItemByCode(String itemCode) {
    if (StringUtils.isNoneEmpty(itemCode) && isInteger(itemCode)) {
      return Arrays.stream(TreatmentItemsDef.values()).filter(
              currentItem -> StringUtils.equals(currentItem.getItemCode(), itemCode)
      ).findFirst().orElse(null);
    }

    return null;
  }

  /**
   * MSTテーブルから実際の単位値を取得する
   *
   * @param itemCode 項目ID
   * @return  治療条件設定実際の単位値
   */
  public String getRealUnit(String itemCode, String facilityCd, String cd, Integer type) {
    return getDefaultUnit(itemCode);
  }

  protected final String getRealUnitFromMedic(String itemCode, String facilityCd, String cd, Integer type) {
    if (!isInteger(cd)  || StringUtils.isEmpty(facilityCd) || type == null)
      return TreatmentItemsDef.getDefaultUnit(itemCode);

    if (type == 1) {
      MstMedicineDao bean = AppContextUtils.getBean(MstMedicineDao.class);
      MstMedicine mstMedicine = bean.selectByMediCd(Integer.valueOf(cd));
      return Objects.isNull(mstMedicine) ?TreatmentItemsDef.getDefaultUnit(itemCode):mstMedicine.getUnit();
    }

    if (type == 2) {
      MstMedicineMixDao bean = AppContextUtils.getBean(MstMedicineMixDao.class);
      MstMedicineMix mstMedicineMix = bean.selectByMedicineMixCd(Integer.valueOf(cd));
      return Objects.isNull(mstMedicineMix)? TreatmentItemsDef.getDefaultUnit(itemCode):mstMedicineMix.getUnit();
    }
    return null;
  }

  protected final String getRealUnitSecondFromMedic(String itemCode, String facilityCd, String cd, Integer type){
    if (!isInteger(cd)  || StringUtils.isEmpty(facilityCd) || type == null)
      return TreatmentItemsDef.getDefaultUnit(itemCode);

    if (type == 1) {
      MstMedicineDao bean = AppContextUtils.getBean(MstMedicineDao.class);
      MstMedicine mstMedicine = bean.selectByMediCd(Integer.valueOf(cd));
      return Objects.isNull(mstMedicine) ?TreatmentItemsDef.getDefaultUnit(itemCode):mstMedicine.getUnitSecond();
    }
    if (type == 2) {
      MstMedicineMixDao bean = AppContextUtils.getBean(MstMedicineMixDao.class);
      MstMedicineMix mstMedicineMix = bean.selectByMedicineMixCd(Integer.valueOf(cd));
      return Objects.isNull(mstMedicineMix)? TreatmentItemsDef.getDefaultUnit(itemCode):mstMedicineMix.getUnit();
    }
    return null;
  }

  public String getRealName(String itemCode, String facilityCd, String cd, Integer type) {
    TreatmentItemsDef itemsDef = getTreatmentItemByCode(itemCode);
    if (itemsDef != null) {
      if (!isInteger(cd)  || StringUtils.isEmpty(facilityCd)) {
        return itemsDef.getDefaultValue();
      } else {
        return itemsDef.getRealName(facilityCd, cd, type);
      }
    } else {
      return null;
    }
  }


  public String getRealName(String facilityCd, String cd, Integer type) {
    return null;
  }
  protected String getRealNameFromMstVa(String facilityCd, String cd) {
    MstVaDao bean = AppContextUtils.getBean(MstVaDao.class);
    MstVa mstVa = bean.selectByCd(Integer.parseInt(cd));
    return Objects.isNull(mstVa) ? null:mstVa.getVaName();
  }

  protected String getRealNameFromMstDialyzer(String facilityCd, String cd) {
    MstDialyzerDao bean = AppContextUtils.getBean(MstDialyzerDao.class);
    MstDialyzer mstDialyzer = bean.selectByDialyzerCd(SelectOptions.get(), Integer.parseInt(cd));
    return Objects.isNull(mstDialyzer)?null:mstDialyzer.getModelNumber();
  }

  protected String getRealNameFromMstEquipment(String facilityCd,String cd) {
    MstEquipmentDao bean = AppContextUtils.getBean(MstEquipmentDao.class);
    MstEquipment mstEquipment = bean.selectByEquipmentCd(Integer.parseInt(cd));
    return Objects.isNull(mstEquipment) ? null:mstEquipment.getEquipmentName();
  }

  protected String getRealUnitFromMstEquipment(String facilityCd,String cd) {
    if (!isInteger(cd)) return null;
    MstEquipmentDao bean = AppContextUtils.getBean(MstEquipmentDao.class);
    MstEquipment mstEquipment = bean.selectByEquipmentCd(Integer.parseInt(cd));
    return Objects.isNull(mstEquipment) ? null:mstEquipment.getUnit();
  }


  protected final String getRealNameFromMedic(String facilityCd, String cd, Integer type) {
    if (!isInteger(cd)  || StringUtils.isEmpty(facilityCd) || type == null)
      return StringUtils.EMPTY;

    Optional<MedicineTypeDaoEum> medicEnumOpt = MedicineTypeDaoEum.getMedicEnum(type);

    if (medicEnumOpt.isPresent()) {
      // NULLの可能性がある
      return medicEnumOpt.get().getMedicName(facilityCd, Integer.parseInt(cd));

    } else {
      return StringUtils.EMPTY;
    }
  }

  public static String getDefaultUnit(String itemCode) {
    TreatmentItemsDef currentItem = getTreatmentItemByCode(itemCode);
    return currentItem == null ? StringUtils.EMPTY : currentItem.getDefaultUnit();
  }


  public static String getDefaultValue(String itemCode) {
    TreatmentItemsDef currentItem = getTreatmentItemByCode(itemCode);
    return currentItem == null ? StringUtils.EMPTY : currentItem.getDefaultValue();
  }

  /**
   * Format the value
   *  Obtain the formatting definition of the specified project through the project number,
   *  thereby converting the set value into a string in the specified format
   *
   * @param itemCode  項目ID
   * @param valueForFormat 設定値
   * @return 書式設定後の設定値
   */
  public static String getFormattedValue(String itemCode, Double valueForFormat) {
    // get currentItem by ItemCode
    TreatmentItemsDef currentItem = getTreatmentItemByCode(itemCode);
    if (currentItem == null)
      return StringUtils.EMPTY;

    return currentItem.getFormattedValue(valueForFormat);
  }

  /** フォーマットパータンの開始 */
  private static final String DEFAULT_FORMAT_START = "%";
  /** デフォルト精度 */
  private static final String DEFAULT_ACC_LENGTH = "1";
  /**  */
  private static final String POINT = ".";
  /**  */
  private static final String FLOAT_PATTEN = "f";

  private static final String NUM_PATTEN = "d";

  /**
   * デフォルトのフォーマットパータンを取得
   *
   * @return デフォルトのフォーマットパータン
   */
  public static String getItemValueDefaultFormatPatten() {
    return getItemValueFormatPatten(DEFAULT_ACC_LENGTH);
  }

  /**
   * 設定精度のフォーマットパータン構成メソッド
   *  e.g.
   *  ・整数部長さは「2」、小数部長さは「2」 -> %2.2f
   *  ・整数部長さは「0」、小数部長さは「2」 -> %.2f
   *  ・小数部長さは「0」、整数部長さは「2」 -> %2d
   *  ・整数部と小数部のパラメータは非正整数　-> %d
   *
   * @param intLength 整数部長さ属性
   * @param accLength 小数部長さ属性
   * @return  フォーマットパータン
   */
  private static String getItemValueFormatPatten(String intLength, String accLength) {
    intLength = StringUtils.isEmpty(intLength) ? StringUtils.EMPTY : intLength;
    accLength = StringUtils.isEmpty(accLength) ? StringUtils.EMPTY : accLength;

    if (isInteger(intLength) && Integer.parseInt(intLength) > 0) {
      if (isInteger(accLength) && Integer.parseInt(accLength) > 0) {
        return DEFAULT_FORMAT_START + intLength + POINT + accLength + FLOAT_PATTEN;
      } else {
        return DEFAULT_FORMAT_START + intLength + NUM_PATTEN;
      }
    } else {
      if (isInteger(accLength) && Integer.parseInt(accLength) > 0) {
        return DEFAULT_FORMAT_START + POINT + accLength + FLOAT_PATTEN;
      } else {
        return DEFAULT_FORMAT_START + NUM_PATTEN;
      }
    }
  }

  public static String getItemValueFormatPatten(String accLength) {
    return DEFAULT_FORMAT_START + POINT + accLength + FLOAT_PATTEN;
  }

  /**
   * パラメータが非負整数かどうかを判断する
   *
   * @param str パラメータ
   * @return 非負整数はtrue
   */
  public static boolean isInteger(String str) {
    if (StringUtils.isEmpty(str)) return false;
    Pattern pattern = Pattern.compile("^\\d*$");
    return pattern.matcher(str).matches();
  }

  /**
   * パラメータが非負フロートかどうかを判断する。
   * フロート数に正常に変換できるの場所、trueを戻り。
   * e.g.   "12.345" -> true
   *        "12"  -> true
   *        "12." -> false
   *        ".1234" -> false
   *        "12.0" -> true
   *        "00.00" -> true
   *        "010.02030" -> true
   *        null -> false
   *        "" -> false
   */
  public static boolean isFloat(String str) {
    if (StringUtils.isEmpty(str)) return false;
    Pattern pattern = Pattern.compile("^\\d+(\\.\\d+)?$");
    return pattern.matcher(str).matches();
  }

  public String getItemCode() {
    return itemCode;
  }

  public String getDefaultUnit() {
    return defaultUnit;
  }

  public String getDefaultValue() {
    return defaultValue;
  }

  public String getValueFormatPatten() {
    if (StringUtils.isEmpty(valueFormatPatten)) {
      if (maxLength == -1) {
        return getItemValueFormatPatten("0", "0");
      } else if (maxLength > 0) {
        return getItemValueFormatPatten(String.valueOf(getMaxLength()));
      } else {
        return getItemValueDefaultFormatPatten();
      }
    }
    return valueFormatPatten;
  }

  public String getMaxValue() {
    return maxValue;
  }

  public String getMinValue() {
    return minValue;
  }

  public int getMaxLength() {
    return maxLength;
  }

  /**
   * According to the formatting format set in this project, format the specified setting value into a string.
   *
   * @param valueForFormat 設定値
   * @return  書式設定後の設定値
   */
  public String getFormattedValue(Double valueForFormat) {

    String formatPatten = getValueFormatPatten();

    // 設定値が整数の場合は、pattenを%fではなく%dに設定します
//    if (valueForFormat.longValue() == valueForFormat.doubleValue()) {
//      if (formatPatten.endsWith(FLOAT_PATTEN)) {
//        formatPatten = getItemValueFormatPatten(
//          String.valueOf(Math.max(maxLength, 0))
//          , "0");
//      }
//    } else {
//      if (formatPatten.endsWith(NUM_PATTEN)) {
//        formatPatten = getItemValueFormatPatten(
//          "0"
//          , String.valueOf(Math.max(maxLength, 0)));
//      }
//    }
    // 書式設定
    return getFormattedValueWithDecPoint(formatPatten, valueForFormat);
  }


  /**
   * According to the formatting format set in this project, format the specified setting value into a string.
   *
   * @param valueForFormat 設定値
   * @return  書式設定後の設定値
   */
  public String getFormattedValue(BigDecimal valueForFormat) {
    // 書式設定
    return getFormattedValueWithDecPoint(getValueFormatPatten(), valueForFormat);
  }

  /**
   * <p>Format the specified setting value into a string based on the given formatting pattern.
   * <br/> At the same time, the value range set for the project will also be compared, and if it exceeds the range, its boundary value will be returned by default.</p>
   * <p> In this method, only determine whether a pattern has been given (set as the default pattern for the item when it is empty),
   * <br/>but do not verify the formatted pattern.  If the pattern does not match the set value type, an exception will be thrown.</p>
   *
   *
   * @param formatPatten  formatted pattern
   * @param valueForFormat  setting value
   * @return  書式設定後の設定値
   */
  public String getFormattedValueWithDecPoint(String formatPatten, Double valueForFormat) {
    if (valueForFormat == null)
      return getDefaultValue();

    if (valueForFormat.isNaN() || valueForFormat.isInfinite())
      return getDefaultValue();

    formatPatten = StringUtils.isEmpty(formatPatten) ? getValueFormatPatten() : formatPatten;

    String valueStr = String.format(formatPatten, valueForFormat).trim();

    // Min Value
//    if (StringUtils.isNotEmpty(minValue)) {
//      if (compareWithMinValue(valueStr) < 0)
//        return minValue;
//    }
    // Max Value
//    if (StringUtils.isNotEmpty(maxValue)) {
//      if (compareWithMaxValue(valueStr) > 0)
//        return maxValue;
//    }

    return valueStr;
  }


  public String getFormattedValueWithDecPoint(String formatPatten, BigDecimal valueForFormat) {
    if (valueForFormat == null)
      return getDefaultValue();

    formatPatten = StringUtils.isEmpty(formatPatten) ? getValueFormatPatten() : formatPatten;
    String valueStr = String.format(formatPatten, valueForFormat).trim();

    // Min Value
    if (StringUtils.isNotEmpty(minValue)) {
      if (compareWithMinValue(valueStr) < 0)
        return minValue;
    }
    // Max Value
    if (StringUtils.isNotEmpty(maxValue)) {
      if (compareWithMaxValue(valueStr) > 0)
        return maxValue;
    }
    return valueStr;
  }

  /**
   * パラメータと定義された最大値の比較
   *
   * @param cmpValue 比較する数値
   * @return 1 -> パラメータが最大値より大きい
   *         0 -> パラメータは最大値と等しい（通常）
   *        -1 -> パラメータが最大値未満（通常）
   */
  public int compareWithMaxValue(String cmpValue) {
    if (!isFloat(cmpValue)) return 1;
    return new BigDecimal(cmpValue).compareTo(new BigDecimal(maxValue));
  }

  /**
   * パラメータと定義された最小値の比較
   *
   * @param cmpValue 比較する数値
   * @return 1 -> パラメータが最小値より大きい（通常）
   *         0 -> パラメータは最小値と等しい（通常）
   *        -1 -> パラメータが最小値未満
   */
  public int compareWithMinValue(String cmpValue) {
    if (!isFloat(cmpValue)) return -1;
    return new BigDecimal(cmpValue).compareTo(new BigDecimal(minValue));
  }
}
