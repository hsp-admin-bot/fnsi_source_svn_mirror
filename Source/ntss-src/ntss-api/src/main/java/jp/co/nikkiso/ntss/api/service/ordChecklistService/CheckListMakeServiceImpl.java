package jp.co.nikkiso.ntss.api.service.ordChecklistService;

import java.io.IOException;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;


import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.json.JSONArray;
import org.json.JSONObject;
import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist.OrdChecklistRegCheckInfo;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist.OrdChecklistRegStaffInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
class CheckListMakeServiceImpl implements CheckListMakeService {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end


  @Autowired
  private OrdChecklistDao ordChecklistDao;
  @Autowired
  PatIndApproveDao patIndApproveDao;

  // チェックリスト実績作成用医療材料情報クラス
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class OrdChecklistRegEquipInfo {
    /**
     * ObjectMapper
     */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /**
     * ModelMapper
     */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 医療材料コード
     */
    @JsonProperty("code")
    private Integer code;
// del 10310 needle _ typeの使用を削除するには gjn start
    /**
     * 穿刺針区分(0: 未指定、1: A針、2: V針、3: SN)
     */
//    @JsonProperty("needle_type")
//    private Short needleType;
// del 10310 needle _ typeの使用を削除するには gjn end
    /**
     * 医療材料更新日時
     */
    @JsonProperty("code_update")
    private Timestamp codeUpdate;

    /**
     * 医療材料名
     */
    @JsonProperty("name")
    private String name;

    /**
     * 数量
     */
    @JsonProperty("amount")
    private String amount;

    /**
     * 単位
     */
    @JsonProperty("unit")
    private String unit;

    /**
     * 医療材料区分
     */
    @JsonProperty("equip_type")
    private Integer equipType;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    public OrdChecklistRegEquipInfo(String value) {
      this(value, null);
    }

    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    public OrdChecklistRegEquipInfo(String value, LogService logService) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      try {
        OrdChecklistRegEquipInfo obj = objectMapper.readValue(value, OrdChecklistRegEquipInfo.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        if (logService != null) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      }
    }

    /**
     * 基本型の値を返す.
     *
     * @return 基本型の値
     */
    @JsonIgnore
    public String getValue() {
      try {
        return objectMapper.writeValueAsString(this);
      } catch (JacksonException e) {
        return null;
      }
    }

  }

  // チェックリスト実績作成用投与薬剤情報クラス
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class OrdChecklistRegMediInfo {
    /**
     * ObjectMapper
     */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /**
     * ModelMapper
     */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 投与薬剤コード
     */
    @JsonProperty("code")
    private Integer code;
// del 10310 needle _ typeの使用を削除するには gjn start
    /**
     * 穿刺針区分(null)
     */
//    @JsonProperty("needle_type")
//    private Short needleType;
// del 10310 needle _ typeの使用を削除するには gjn end
    /**
     * 薬剤区分(1: 通常薬剤、2: 調製薬剤)
     */
    @JsonProperty("medicine_type")
    private Integer medicineType;

    /**
     * 投与薬剤更新日時
     */
    @JsonProperty("code_update")
    private Timestamp codeUpdate;

    /**
     * 投与薬剤名
     */
    @JsonProperty("name")
    private String name;

    /**
     * 数量
     */
    @JsonProperty("amount")
    private String amount;

    /**
     * 単位
     */
    @JsonProperty("unit")
    private String unit;

    /**
     * 薬剤識別番号
     */
    @JsonProperty("medicine_no")
    private String medicineNo;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    public OrdChecklistRegMediInfo(String value) {
      this(value, null);
    }

    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    public OrdChecklistRegMediInfo(String value, LogService logService) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      try {
        OrdChecklistRegMediInfo obj = objectMapper.readValue(value, OrdChecklistRegMediInfo.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        if (logService != null) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      }
    }

    /**
     * 基本型の値を返す.
     *
     * @return 基本型の値
     */
    @JsonIgnore
    public String getValue() {
      try {
        return objectMapper.writeValueAsString(this);
      } catch (JacksonException e) {
        return null;
      }
    }

  }

  /**
   * 登録用チェックリストデータを作成
   * {@inheritDoc}
   */
  @Override
  public List<OrdChecklist> getRegisterChecklistRst(OrdMainForCheckListSchedule ordMain,
                                                    JsonNode mstChecklist,
                                                    Long checklistCd,
                                                    boolean hasDummyData) throws IOException {
    List<OrdChecklist> regList = new ArrayList<>();
    // リストコード分繰り返し
    if (!mstChecklist.isNull() && mstChecklist.isArray()) {
      for (int i = 0; i < mstChecklist.size(); i++) {
        JsonNode setting = mstChecklist.get(i);
        // リストコード（list_cd）「１～８」
        Short listcd = Short.parseShort(setting.get("list_cd").asText());

        // 機能リスト（funclist）「１～１０」
        JsonNode funclist = setting.get("funclist");
        JsonNode dPCd = setting.get("dialysis_prog_cd");
        String dialysisProgCd = dPCd.asText();
        // 機能リスト分繰り返し
        if (!funclist.isNull() && funclist.isArray() && !"3".equals(dialysisProgCd)) {
          for (int j = 0; j < funclist.size(); j++) {
            JsonNode list = funclist.get(j);

            // 機能種別（func_class）「0：通常リスト」「1：治療条件」「2：医療材料」「3：投与薬剤」
            String strfuncclass = list.get("func_class").asText();
            Short funcClass = null;
            if (!strfuncclass.equals("null") && !"".equals(strfuncclass)) {
              funcClass = Short.parseShort(list.get("func_class").asText());
            }

            // 機能種別未登録の場合
            if (funcClass == null) {
              continue;
            }

            // 登録用
            OrdChecklist regdata = new OrdChecklist();
            regdata.setOrdNo(ordMain.getOrdNo());
            regdata.setIsCheck(CoreConstant.FlagType.FLAG_OFF);
            regdata.setRstClass(Short.parseShort(dialysisProgCd));
            regdata.setListCd(listcd);
            regdata.setFuncClass(funcClass);
            regdata.setIsDisp(CoreConstant.FlagType.FLAG_ON);
            regdata.setIsDel(CoreConstant.FlagType.FLAG_OFF);
            regdata.setFacilityCd(ordMain.getFacilityCd());

            OrdChecklistRegStaffInfo regStaffInfo = new OrdChecklistRegStaffInfo();
            regdata.setRegStaffInfo(regStaffInfo);

            // チェックリスト項目情報作成用
            OrdChecklistRegCheckInfo checkinfo = new OrdChecklistRegCheckInfo();
            // checklist_cd
            checkinfo.setChecklistCd(checklistCd);
            // item_number
            checkinfo.setItemNumber(Short.parseShort(list.get("item_number").asText()));
            // class_cd
            String classcode = list.get("class_cd").asText();
            // 患者経過総合ビューアレイアウトマスタの項目定義⇒治療条件No
            Integer classcd = null;
            if (!classcode.equals("null") && !"".equals(classcode)) {
              classcd = Integer.parseInt(list.get("class_cd").toString());
              checkinfo.setClassCd(Integer.parseInt(classcode));
            }

            List<OrdChecklist> registerChecklist = null;

            switch (funcClass) {
              // 機能種別（func_class）「0：通常リスト」
              case (short) 0:
                registerChecklist = getRegisterChecklistTsuujourisuto(regdata, checkinfo, list);
                break;
              // 機能種別（func_class）「1：治療条件」
              case (short) 1:
                // 「5：ダイアライザ」「6：吸着カラム」「7：1次膜」「8：2次膜」「9：穿刺針(A針)」「10：穿刺針(V針)」「11：穿刺針(SN)」
                registerChecklist = getRegisterChecklistChiryoujoukenRst(regdata, checkinfo, ordMain, classcd, list);
                break;
              // 機能種別（func_class）「2：医療材料」
              case (short) 2:
                registerChecklist = getRegisterChecklistIryouzairyouRst(regdata, checkinfo, ordMain, classcd);
                break;
              // 機能種別（func_class）「3：投与薬剤」
              case (short) 3:
                registerChecklist = getRegisterChecklistTouyoyakuzaiRst(regdata, checkinfo, ordMain, classcd, list);
                break;
              default:
                break;
            }

            if (registerChecklist != null && registerChecklist.size() > 0) {
              regList.addAll(registerChecklist);
            } else {
              // ダミーデータを作成
              if (hasDummyData) {
                OrdChecklist dummy = regdata.clone();
                // チェックリスト実績「実施状態」（０：未実施）
                dummy.setIsCheck(CoreConstant.FlagType.FLAG_OFF);
                // チェックリスト実績「実績区分」（７８９：ダミーデータ）
                // 透析開始前工程
                if ("0".equals(dialysisProgCd)) {
                  dummy.setRstClass(Short.parseShort("7"));
                  // 透析中工程
                } else if ("1".equals(dialysisProgCd)) {
                  dummy.setRstClass(Short.parseShort("8"));
                  // 透析終了後工程
                } else if ("2".equals(dialysisProgCd)) {
                  dummy.setRstClass(Short.parseShort("9"));
                }
                // チェックリスト実績「表示フラグ」（０：非表示）
                dummy.setIsDisp(CoreConstant.FlagType.FLAG_ON);

                dummy.setIsDel(CoreConstant.FlagType.FLAG_OFF);
                // チェックリスト実績「チェックリスト項目情報」
                checkinfo = settingNormalCheckList(checkinfo, list);

                dummy.setRstChecklistInfo(checkinfo);

                regList.add(dummy);
              }
            }
          }
        }
      }
    }
    return regList;
  }

  /**
   * 登録用チェックリストデータを取得「0：通常リスト」
   *
   * @param regdata
   * @param checkinfo
   * @param list
   * @return
   */
  private List<OrdChecklist> getRegisterChecklistTsuujourisuto(OrdChecklist regdata,
                                                               OrdChecklistRegCheckInfo checkinfo,
                                                               JsonNode list) {
    List<OrdChecklist> reglist = new ArrayList<>();
    // 既存ソース
    checkinfo = settingNormalCheckList(checkinfo, list);

    // チェックリスト項目情報を設定（rst_checklist_info）
    regdata.setRstChecklistInfo(checkinfo);
    reglist.add(regdata);

    return reglist;
  }

  /**
   * 通常リスト用のチェックリスト作成
   *
   * @param checkinfo
   * @param list
   * @return
   */
  private OrdChecklistRegCheckInfo settingNormalCheckList(OrdChecklistRegCheckInfo checkinfo, JsonNode list) {

    // code
    checkinfo.setCode(null);
    // code_update
    checkinfo.setCodeUpdate(null);
    // name
    String listname = list.get("list_name").asText();
    checkinfo.setName(listname);
    // del 10310 needle _ typeの使用を削除するには gjn start
    // needle_type
//    checkinfo.setNeedleType(null);
    // del 10310 needle _ typeの使用を削除するには gjn end
    // amount
    checkinfo.setAmount(null);
    // unit
    checkinfo.setUnit(null);

    return checkinfo;
  }

  /**
   * 登録用チェックリストデータを取得「1：治療条件」
   *
   * @param regdata
   * @param checkinfo
   * @param ordMain
   * @param classcd
   * @param list
   * @return
   */
  private List<OrdChecklist> getRegisterChecklistChiryoujoukenRst(OrdChecklist regdata,
                                                                  OrdChecklistRegCheckInfo checkinfo,
                                                                  OrdMainForCheckListSchedule ordMain,
                                                                  Integer classcd,
                                                                  JsonNode list) {
    List<OrdChecklist> reglist = new ArrayList<>();
    if (classcd == null) {
      return reglist;
    }

    // class_cd
    List<Integer> condclasscd = new ArrayList<>();
    condclasscd.add(classcd);

    // ダイアライザの場合「5：ダイアライザまたは吸着カラム(6),一次膜(7),二次膜(8)」
    if (Objects.equals(classcd, 5)) {
      // 吸着カラムも追加
      condclasscd.add(6);
      // 一次膜
      condclasscd.add(7);
      // 二次膜
      condclasscd.add(8);
    }
    // 吸着カラムはダイアライザと同時設定にしたので除外
    // ※仕様変更後,既存データ保守用コード「吸着カラム(6)⇒チェックリストマスタは破棄」
    if (Objects.equals(classcd, 6)) {
      return reglist;
    }
    // 穿刺針の場合「9:穿刺針(10,11含む)」
    if (Objects.equals(classcd, 9)) {
      // 穿刺針(V針)
      condclasscd.add(10);
      // 穿刺針(SN)
      condclasscd.add(11);
    }
    // 透析液の場合「15：透析液」
    if (Objects.equals(classcd, 15)) {
      // 「17：透析液使用数」
      condclasscd.add(17);
    }
    // 補液の場合「19：補液」
    if (Objects.equals(classcd, 19)) {
      // 「22：補液使用数」
      condclasscd.add(22);
    }
    // 抗凝固剤の場合「25：抗凝固剤」
    if (Objects.equals(classcd, 25)) {
      // 「26：抗凝固剤ワンショット量」
      condclasscd.add(26);
      // 「28：抗凝固剤持続総量」
      condclasscd.add(28);
    }

    if (ordMain.getRstCondInfo() != null) {
      // 対象の治療条件取得
      List<JSONObject> condList = getCondInfo(ordMain.getRstCondInfo(), condclasscd);

      // 対象の治療条件取得「再作成」「薬剤場合用」
      List<JSONObject> res = new ArrayList<>();
      // 「17：透析液使用数」
      BigDecimal amount15 = BigDecimal.ZERO;
      // 「22：補液使用数」
      BigDecimal amount19 = BigDecimal.ZERO;
      // 「26：抗凝固剤ワンショット量」＋「28：抗凝固剤持続総量」
      BigDecimal amount25 = BigDecimal.ZERO;

      String unit15 = null;

      String unit19 = null;

      String unit25 = null;

      for (JSONObject cond : condList) {
        if (!cond.has("code") || cond.isNull("code")) {
          continue;
        }
        String strcode = cond.get("code").toString();
        BigDecimal regcode = BigDecimal.ZERO;
        if (!strcode.equals("null")) {
          String regexp = "\"";
          if (cond.get("code").toString().indexOf(regexp) > -1) {
            regcode = new BigDecimal(cond.get("code").toString().replaceAll(regexp, ""));
          } else {
            regcode = new BigDecimal(cond.get("code").toString());
          }
        }
        String  unit = cond.has("unit") && !cond.isNull("unit") ? cond.get("unit").toString() : null;

        if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "17")) {
          amount15 = amount15.add(regcode);
          unit15 = unit;
        } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "22")) {
          amount19 = amount19.add(regcode);
          unit19 = unit;
        } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "26")) {
          amount25 = amount25.add(regcode);
          unit25 = unit;
        } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "28")) {
          amount25 = amount25.add(regcode);
          unit25 = unit;
        } else {
          res.add(cond);
        }
      }

      for (JSONObject cond : res) {
        if (!cond.has("code") || cond.isNull("code")) {
          continue;
        }
        // チェックリスト項目情報作成用
        OrdChecklistRegCheckInfo condcheckinfo = checkinfo.clone();

        // code「設定値：value」
        String strcode = cond.get("code").toString();
        Integer regcode = null;
        if (!strcode.equals("null")) {
          regcode = Integer.parseInt(cond.get("code").toString());
          condcheckinfo.setCode(regcode);
        }

        // code_update
        condcheckinfo.setCodeUpdate(null);
        // name
        condcheckinfo.setName(null);
        // class_cd
        if (cond.has("class_cd") && !cond.isNull("class_cd")) {
          String strClassCd = cond.get("class_cd").toString();
          Integer regClassCd = null;
          if (!strClassCd.equals("null")) {
            regClassCd = Integer.valueOf(cond.get("class_cd").toString());
            condcheckinfo.setClassCd(regClassCd);
          }
        }

        // ダイアライザの場合「5：ダイアライザ」
        if (Objects.equals(classcd, 5)) {
          if (Objects.equals(condcheckinfo.getClassCd(), 5)) {
            // ダイアライザマスタから情報取得
            condcheckinfo = settingCondEquipCheckInfoRst(condcheckinfo, ordMain, condcheckinfo.getClassCd());
            // equiptype
            condcheckinfo.setEquipType(1);
          } else {
            // 吸着カラム・1次膜・2次膜：医療材料から情報取得
            condcheckinfo = settingCondEquipCheckInfoRst(condcheckinfo, ordMain, condcheckinfo.getClassCd());
            // equiptype
            condcheckinfo.setEquipType(0);
          }
        }
        // 薬剤の場合「15：透析液」「19：補液」「25：抗凝固剤」
        else if (Objects.equals(classcd, 15) || Objects.equals(classcd, 19) || Objects.equals(classcd, 25)) {

          condcheckinfo = settingCondMedicineCheckInfoRst(condcheckinfo, ordMain, condcheckinfo.getClassCd());
          // 薬剤場合「数量設定」
          if (Objects.equals(classcd, 15)) {
            condcheckinfo.setAmount(amount15.toString());
            condcheckinfo.setUnit(unit15);
          } else if (Objects.equals(classcd, 19)) {
            condcheckinfo.setAmount(amount19.toString());
            condcheckinfo.setUnit(unit19);
          } else if (Objects.equals(classcd, 25)) {
            condcheckinfo.setAmount(amount25.toString());
            condcheckinfo.setUnit(unit25);
          }
        }
        // 医療材料の場合
        else {
          condcheckinfo = settingCondEquipCheckInfoRst(condcheckinfo, ordMain, condcheckinfo.getClassCd());
          // equiptype
          condcheckinfo.setEquipType(0);
        }
// del 10310 needle _ typeの使用を削除するには gjn start
        // needle_type「穿刺針種別」
        // 「9：穿刺針(A針)⇒1」
        // 「10：穿刺針(V針)⇒2」
        // 「11：穿刺針(SN)⇒3」
        // 「その他：空白」
//        if (cond.has("needle_type") && !cond.isNull("needle_type")) {
//          String strntype = cond.get("needle_type").toString();
//          if (!strntype.equals("") && !strntype.equals("null")) {
//            Short ntype = Short.parseShort(strntype);
//            condcheckinfo.setNeedleType(ntype);
//          }
//        }
// del 10310 needle _ typeの使用を削除するには gjn end
        if (condcheckinfo != null) {
          // 登録用
          OrdChecklist condregdata = regdata.clone();
          // rst_checklist_info「チェックリスト項目情報」
          condregdata.setRstChecklistInfo(condcheckinfo);
          // チェックリスト実績登録
          reglist.add(condregdata);
        }
      }
    }
    return reglist;
  }

  // 対象の治療条件情報取得
  List<JSONObject> getCondInfo(String info, List<Integer> codelist) {

    // 応答用
    List<JSONObject> res = new ArrayList<>();

    // 治療条件指示がない場合
    if (info == null) {
      return res;
    }
// del 10310 needle _ typeの使用を削除するには gjn start
    // 穿刺針種類
//    HashMap<Integer, Integer> needleType_cond = new HashMap<Integer, Integer>();
//    needleType_cond.put(9, 1);
//    needleType_cond.put(10, 2);
//    needleType_cond.put(11, 3);
// del 10310 needle _ typeの使用を削除するには gjn end
    try {
      // 治療条件指示リスト
      ObjectMapper map = new ObjectMapper();
      JsonNode condlist = map.readTree(info);

      for (int condlp = 0; condlp < codelist.size(); condlp++) {

        JSONObject obj = new JSONObject();

        // class_cdがある場合
        if (!Objects.isNull(codelist.get(condlp))) {

          // 対象の治療条件
          String code = codelist.get(condlp).toString();
          JsonNode condinfo = condlist.has(code) ? condlist.get(code) : null;
          JsonNode value = Objects.isNull(condinfo) || !condinfo.has("value") ? null : condinfo.get("value");
          String strval = Objects.isNull(value) ? "null" : value.asText();
          // 対象の治療条件がある場合
          if (!Objects.isNull(condinfo) && !strval.equals("null") && !"".equals(strval)) {
// del 10310 needle _ typeの使用を削除するには gjn start
            // 穿刺針種別
//            String ntype = "";
//            // 穿刺針の場合
//            if (!Objects.isNull(needleType_cond.get(codelist.get(condlp)))) {
//              ntype = needleType_cond.get(codelist.get(condlp)).toString();
//            }
            // del 10310 needle _ typeの使用を削除するには gjn end
            obj.put("code", condinfo.get("value").asText());
            if (condinfo.has("medicine_type")) {
              String strmtype = condinfo.get("medicine_type").asText();
              Integer mtype = null;
              if (!strmtype.equals("null") && !"".equals(strmtype)) {
                mtype = Integer.parseInt(strmtype);
                obj.put("medicine_type", mtype);
              } else {
                obj.put("medicine_type", JSONObject.NULL);
              }
            }
            if (condinfo.has("unit")) {
              String unit = condinfo.get("unit").asText();
              obj.put("unit", unit);
            }
            // del 10310 needle _ typeの使用を削除するには gjn start
//            obj.put("needle_type", ntype);
// del 10310 needle _ typeの使用を削除するには gjn end
            obj.put("class_cd", codelist.get(condlp));

            res.add(obj);
          }
        }
      }

    } catch (JacksonException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return res;

  }

  private OrdChecklistRegCheckInfo settingCondEquipCheckInfoRst(OrdChecklistRegCheckInfo condcheckinfo, OrdMainForCheckListSchedule ordMain, Integer classCd) {

    JSONObject rstCondInfo = new JSONObject(ordMain.getRstCondInfo());
    if (rstCondInfo.has(classCd.toString())) {
      JSONObject condJsonObj = rstCondInfo.getJSONObject(classCd.toString());
      // name
      condcheckinfo.setName(condJsonObj.isNull("value_name_1") ? null : condJsonObj.get("value_name_1").toString());
      // amount
      condcheckinfo.setAmount("1");
      // medicine_type
      condcheckinfo.setMedicineType(null);
      // unit
      condcheckinfo.setUnit(condJsonObj.isNull("unit") ? null : condJsonObj.get("unit").toString());
      // medicineno
      condcheckinfo.setMedicineNo(null);
    }
    return condcheckinfo;
  }

  private OrdChecklistRegCheckInfo settingCondMedicineCheckInfoRst(OrdChecklistRegCheckInfo condcheckinfo,
                                                                   OrdMainForCheckListSchedule ordMain, Integer classcd) {
    JSONObject rstCondInfo = new JSONObject(ordMain.getRstCondInfo());
    if (rstCondInfo.has(classcd.toString())) {
      JSONObject condJsonObj = rstCondInfo.getJSONObject(classcd.toString());
      // name
      condcheckinfo.setName(condJsonObj.isNull("value_name_1") ? null : condJsonObj.get("value_name_1").toString());
      // amount
      condcheckinfo.setAmount(null);
      // equiptype
      condcheckinfo.setEquipType(null);
      // medicineno
      condcheckinfo.setMedicineNo(null);
      // medicinetype
      condcheckinfo.setMedicineType(condJsonObj.isNull("medicine_type") ? null : Integer.parseInt(condJsonObj.get("medicine_type").toString()));
    }
    return condcheckinfo;
  }

  /**
   * 登録用チェックリストデータを取得「2：医療材料」
   *
   * @param regdata
   * @param checkinfo
   * @param ordMain
   * @param classcd
   * @return
   */
  private List<OrdChecklist> getRegisterChecklistIryouzairyouRst(OrdChecklist regdata,
                                                                 OrdChecklistRegCheckInfo checkinfo,
                                                                 OrdMainForCheckListSchedule ordMain,
                                                                 Integer classcd) {
    List<OrdChecklist> reglist = new ArrayList<>();
    if (classcd == null) {
      return reglist;
    }
    // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
    if (ordMain.getRstEquipInfo() != null) {
      JSONArray equipInfo = new JSONArray(ordMain.getRstEquipInfo());
      for (Object jsonItem : equipInfo) {
        JSONObject jsonObjectItem = (JSONObject) jsonItem;
        OrdChecklistRegCheckInfo equipcheckinfo = checkinfo.clone();
        Integer equipType = jsonObjectItem.get("equip_type") != JSONObject.NULL ?
          Integer.parseInt(jsonObjectItem.get("equip_type").toString()) : null;
        // ダイアライザ
        if (equipType.equals(1) && classcd.equals(0)) {
          equipcheckinfo.setEquipType(jsonObjectItem.get("equip_type") != JSONObject.NULL ?
            Integer.parseInt(jsonObjectItem.get("equip_type").toString()) : null);

          equipcheckinfo.setCode(jsonObjectItem.get("cd") != JSONObject.NULL ?
            Integer.parseInt(jsonObjectItem.get("cd").toString()) : null);

          equipcheckinfo.setName(jsonObjectItem.get("name") != JSONObject.NULL ?
            jsonObjectItem.get("name").toString() : null);

          equipcheckinfo.setAmount(jsonObjectItem.get("amount") != JSONObject.NULL ?
            jsonObjectItem.get("amount").toString() : null);

          equipcheckinfo.setUnit("本");

          // 登録用
          OrdChecklist equipdata = regdata.clone();
          // rst_checklist_info「チェックリスト項目情報」
          equipdata.setRstChecklistInfo(equipcheckinfo);
          // チェックリスト実績登録
          reglist.add(equipdata);

          //  その他 医療材料
        } else {
          if (equipType.equals(0) && jsonObjectItem.get("class_cd") != JSONObject.NULL) {
            Integer rstClassCd = Integer.parseInt(jsonObjectItem.get("class_cd").toString());
            if (rstClassCd.equals(classcd)) {
              equipcheckinfo.setEquipType(jsonObjectItem.get("equip_type") != JSONObject.NULL ?
                Integer.parseInt(jsonObjectItem.get("equip_type").toString()) : null);

              equipcheckinfo.setCode(jsonObjectItem.get("cd") != JSONObject.NULL ?
                Integer.parseInt(jsonObjectItem.get("cd").toString()) : null);

              equipcheckinfo.setName(jsonObjectItem.get("name") != JSONObject.NULL ?
                jsonObjectItem.get("name").toString() : null);

              equipcheckinfo.setUnit(jsonObjectItem.has("unit") && jsonObjectItem.get("unit") != JSONObject.NULL ?
                jsonObjectItem.get("unit").toString() : null);

              equipcheckinfo.setAmount(jsonObjectItem.get("amount") != JSONObject.NULL ?
                jsonObjectItem.get("amount").toString() : null);
              // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
              // 登録用
              OrdChecklist equipdata = regdata.clone();
              // rst_checklist_info「チェックリスト項目情報」
              equipdata.setRstChecklistInfo(equipcheckinfo);
              // チェックリスト実績登録
              reglist.add(equipdata);
            }
          }
        }
      }
    }
    return reglist;
  }

  /**
   * 登録用チェックリストデータを取得「3：投与薬剤」
   *
   * @param regdata
   * @param checkinfo
   * @param ordMain
   * @param classcd
   * @param list
   * @return
   */
  private List<OrdChecklist> getRegisterChecklistTouyoyakuzaiRst(OrdChecklist regdata,
                                                                 OrdChecklistRegCheckInfo checkinfo,
                                                                 OrdMainForCheckListSchedule ordMain,
                                                                 Integer classcd,
                                                                 JsonNode list) {

    List<OrdChecklist> reglist = new ArrayList<>();
    if (classcd == null) {
      return reglist;
    }
    if (ordMain.getRstMediInfo() != null) {
      JSONArray mediInfo = new JSONArray(ordMain.getRstMediInfo());
      for (Object jsonItem : mediInfo) {
        JSONObject jsonObjectItem = (JSONObject) jsonItem;
        OrdChecklistRegCheckInfo medicinecheckinfo = checkinfo.clone();
        if (!jsonObjectItem.isNull("class_cd")) {
          Integer rstClassCd = Integer.parseInt(jsonObjectItem.get("class_cd").toString());
          if (rstClassCd.equals(classcd)) {
            // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
            medicinecheckinfo.setMedicineType(jsonObjectItem.get("medicine_type") != JSONObject.NULL ?
              Integer.parseInt(jsonObjectItem.get("medicine_type").toString()) : null);

            medicinecheckinfo.setCode(jsonObjectItem.get("cd") != JSONObject.NULL ?
              Integer.parseInt(jsonObjectItem.get("cd").toString()) : null);

            medicinecheckinfo.setName(jsonObjectItem.get("name") != JSONObject.NULL ?
              jsonObjectItem.get("name").toString() : null);

            medicinecheckinfo.setUnit(jsonObjectItem.get("unit") != JSONObject.NULL ?
              jsonObjectItem.get("unit").toString() : null);

            medicinecheckinfo.setAmount(jsonObjectItem.get("amount") != JSONObject.NULL ?
              jsonObjectItem.get("amount").toString() : null);

            medicinecheckinfo.setMedicineNo(jsonObjectItem.get("no") != JSONObject.NULL ?
              jsonObjectItem.get("no").toString() : null);
            // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
            // 登録用
            OrdChecklist medicinedata = regdata.clone();
            // rst_checklist_info「チェックリスト項目情報」
            medicinedata.setRstChecklistInfo(medicinecheckinfo);
            // チェックリスト実績登録
            reglist.add(medicinedata);
          }
        }
      }
    }
    return reglist;
  }

  /**
   * marge OrdCheckList left
   *
   * @param ordChecklistListOfMarge
   * @param ordChecklistListForMarge
   * @return
   */
  public void margeOrdCheckListInsCheckLeft(List<OrdChecklist> ordChecklistListOfMarge, List<OrdChecklist> ordChecklistListForMarge) {
    // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
    //margeのOrdChecklistから実施済みのデータを抽出する
    List<Long> checklistCtlNosDel = new ArrayList<>();
    if (ordChecklistListOfMarge != null) {
      List<OrdChecklist> coincideOf = new ArrayList<>();
      List<OrdChecklist> coincideFor = new ArrayList<>();
      //isCheck 状態を更新した上で挿入する必要がある項目
      List<OrdChecklist> coincideForIsCheck = new ArrayList<>();
      if (ordChecklistListForMarge.size() > 0) {
        for (OrdChecklist ordChecklist : ordChecklistListForMarge) {
          for (OrdChecklist ordChecklist1 : ordChecklistListOfMarge) {
            if (ordChecklist1.getFuncClass() != 0) { //非通常
              if (Objects.equals(ordChecklist.getRstClass(), ordChecklist1.getRstClass())
                && Objects.equals(ordChecklist.getListCd(), ordChecklist1.getListCd())
                && Objects.equals(ordChecklist.getFuncClass(), ordChecklist1.getFuncClass())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getItemNumber(), ordChecklist1.getRstChecklistInfo().getItemNumber())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getClassCd(), ordChecklist1.getRstChecklistInfo().getClassCd())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getCode(), ordChecklist1.getRstChecklistInfo().getCode())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getMedicineType(), ordChecklist1.getRstChecklistInfo().getMedicineType())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getEquipType(), ordChecklist1.getRstChecklistInfo().getEquipType())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getMedicineNo(), ordChecklist1.getRstChecklistInfo().getMedicineNo())
                ) {
                if (Objects.equals(ordChecklist.getRstChecklistInfo().getAmount(), ordChecklist1.getRstChecklistInfo().getAmount())) {
                  if ("1".equals(ordChecklist1.getIsCheck())) {
                    coincideForIsCheck.add(ordChecklist);
                  }
                  coincideOf.add(ordChecklist1);
                  coincideFor.add(ordChecklist);
                }else if (equalsAsNumber(ordChecklist.getRstChecklistInfo().getAmount(), ordChecklist1.getRstChecklistInfo().getAmount())){
                  ordChecklist.setIsCheck(ordChecklist1.getIsCheck());
                  ordChecklist.setRegStaffInfo(ordChecklist1.getRegStaffInfo());
                  ordChecklist.setOccurDate(ordChecklist1.getOccurDate());
                  ordChecklist.setRegDate(ordChecklist1.getRegDate());
                  ordChecklist.setUpDate(new Timestamp(System.currentTimeMillis()));
                }
              }
            } else { //FuncClass == 0の場合は通常処理で、さらにnameの判定を追加する
              if (Objects.equals(ordChecklist.getRstClass(), ordChecklist1.getRstClass())
                && Objects.equals(ordChecklist.getListCd(), ordChecklist1.getListCd())
                && Objects.equals(ordChecklist.getFuncClass(), ordChecklist1.getFuncClass())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getItemNumber(), ordChecklist1.getRstChecklistInfo().getItemNumber())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getName(), ordChecklist1.getRstChecklistInfo().getName())
              ) {
                if ("1".equals(ordChecklist1.getIsCheck())) {
                  coincideForIsCheck.add(ordChecklist);
                }
                coincideOf.add(ordChecklist1);
                coincideFor.add(ordChecklist);
              }
            }
          }
        }
      }
      //ordChecklistListOfMargeとcoincideOfが一致しない項目を抽出し、ord_checklist から削除する
      List<OrdChecklist> differentOf = new ArrayList<>();
      differentOf = ordChecklistListOfMarge.stream()
        .filter(obj -> !coincideOf.contains(obj)).collect(Collectors.toList());
      if (differentOf.size() > 0) {
        differentOf.forEach(f -> {
          checklistCtlNosDel.add(f.getChecklistCtlNo());
        });
        //ord_checklist から削除する(物理削除)
        ordChecklistDao.deleteChecklistByCtlNo(checklistCtlNosDel);
      }
      //ordChecklistListForMargeとcoincideForが一致しない項目を抽出し、ord_checklistに挿入する
      List<OrdChecklist> differentForAdd = new ArrayList<>();
      differentForAdd = ordChecklistListForMarge.stream()
        .filter(obj -> !coincideFor.contains(obj)).collect(Collectors.toList());
      if (differentForAdd.size() > 0) {
        //ord_checklistに挿入する
        ordChecklistDao.insertByList(differentForAdd);
      }
    }
  }
  public static boolean equalsAsNumber(String a, String b) {
    if (a == null || b == null || a.trim().isEmpty() || b.trim().isEmpty()) {
      return false;
    }
    try {
      return new BigDecimal(a.trim()).compareTo(new BigDecimal(b.trim())) == 0;
    } catch (NumberFormatException e) {
      return false;
    }
  }
  // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
}
