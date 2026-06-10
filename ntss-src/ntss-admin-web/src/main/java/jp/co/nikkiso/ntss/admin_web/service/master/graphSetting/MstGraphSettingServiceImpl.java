package jp.co.nikkiso.ntss.admin_web.service.master.graphSetting;

import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.OPERATION;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.SORT_INPUT_TIME;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.SORT_RANK;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.CaseFormat;

import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterColumn;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstGraphSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstGraphSetting;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.FieldType;
import jp.co.nikkiso.ntss.core.entity.custom.GraphSettingInfo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class MstGraphSettingServiceImpl implements MstGraphSettingService {

  /**
   * KendoUI 数値項目の標準フォーマット(整数部のみ少数なし).
   */
  static final String NUMBER_FORMAT = "n0";

  /**
   * ソート用表示項目名.
   */
  static final String SORT_RANK_TITLE = "並び順";

  /**
   * レコード追加許可項目名.
   */
  static final String ALLOW_ADD_RECORD = "allowAddRecord";

  /**
   * 施設マスタのDaoインタフェース.
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;

  /**
   * P-Ca9分割グラフ設定マスタのDaoインタフェース.
   */
  @Autowired
  private MstGraphSettingDao mstGraphSettingDao;

  /**
   * 利用者マスタ(個人情報DB)のDaoインタフェース.
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 利用者マスタのDaoインタフェース.
   */
  @Autowired
  private MstUserDao mstUserDao;

  //DB更新ログ出力ロジック wp start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  //DB更新ログ出力ロジック wp end
  @Autowired
  private LogService logService;


  /**
   * {@inheritDoc}
   */
  @Override
  public MasterDataResponse getMasterData(String facilityCd) {

    MasterDataResponse masterResponse = new MasterDataResponse();

    // カラム情報の作成
    masterResponse.columns = makeMasterColumn();

    // スキーマのフィールド情報の作成
    masterResponse.localDataSource.schema.model.fields = makeMasterField();

    // 対象データ取得
    masterResponse.localDataSource.data = selectUserDataByFacilityCd(facilityCd);

    // 成功レスポンス返却
    return masterResponse;
  }

  // P-Ca9分割グラフ設定データ一覧取得
  public List<Map<String, Object>> selectUserDataByFacilityCd(String facilityCd) {

    // 施設コードを元にP-Ca9分割グラフ設定データ(Mst/Sys)を取得:全項目ケースのためfacilitySettingNoはnullセット
    List<MstGraphSetting> settingInfoListValue = mstGraphSettingDao.selectGraphSetting(facilityCd);

    List<GraphSettingInfo> settingInfoList = getListSysGraphSetting();
    // 取得データをMstUserDataに統合
    List<Map<String, Object>> facilitySettingList = new ArrayList<Map<String, Object>>();
    for(GraphSettingInfo settingInfo : settingInfoList){

      // オブジェクトをHashMapに変換
      Map<String, Object> hashData = new HashMap<>();
      hashData.put("functionName", settingInfo.getFunctionName());
      hashData.put("graphSettingNo", settingInfo.getGraphSettingNo());
      hashData.put("facilityCd", settingInfo.getFacilityCd());
      hashData.put("value", settingInfo.getDefaultValue());
      hashData.put("inputType", settingInfo.getInputType());
      hashData.put("optionValue", settingInfo.getOptionValue());
      hashData.put("makerSetting", settingInfo.getMakerSetting());
      hashData.put("description", settingInfo.getDescription());
      hashData.put("dispOrder", settingInfo.getDispOrder());
      for (int i = 0; i < settingInfoListValue.size(); i++) {
        if(settingInfo.getGraphSettingNo().equals(settingInfoListValue.get(i).getGraphSettingNo())) {
          hashData.put("value", settingInfoListValue.get(i).getValue());
          break;
        }
      }
      facilitySettingList.add(hashData);
    }

    return facilitySettingList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<GraphSettingInfo> getListSysGraphSetting() {
    List<GraphSettingInfo> gList = new ArrayList<>();
    GraphSettingInfo graphSettingInfo = null;

    graphSettingInfo = new GraphSettingInfo("1", null, "6", null, 4, "[{\"id\":\"0\",\"name\":\"透析前\"},{\"id\":\"1\",\"name\":\"透析後\"},{\"id\":\"2\",\"name\":\"その他\"},{\"id\":\"3\",\"name\":\"透析前＋透析後\"},{\"id\":\"4\",\"name\":\"透析前＋その他\"},{\"id\":\"5\",\"name\":\"透析後＋その他\"},{\"id\":\"6\",\"name\":\"すべて\"}]", "検査結果取得の検査区分", 0, "グラフ表示対象の検査データの取得検査区分を指定する。透析前／透析後／その他／透析前＋透析後／透析前＋その他／透析後＋その他／すべて", (double)1);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("2",  null, "0", null, 4, "[{\"id\":\"0\",\"name\":\"未登録\"}]", "X軸検査マスタ指定", 0, "X軸に出力する検査項目コード", (double) 2);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("3",  null, "0", null, 4, "[{\"id\":\"0\",\"name\":\"未登録\"}]", "Y軸検査マスタ指定", 0, "Y軸に出力する検査項目コード", (double) 3);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("4",  null, "8.5", null, 2, "", "X軸グラフ上限値", 0, "X軸の上限値を設定", (double) 4);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("5",  null, "6.0", null, 2, "", "X軸グラフ閾値上限", 0, "X軸の閾値上限(X軸目盛線)を設定", (double) 5);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("6",  null, "3.5", null, 2, "", "X軸グラフ閾値下限", 0, "X軸の閾値下限(X軸目盛線)を設定", (double) 6);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("7",  null, "1.0", null, 2, "", "X軸グラフ下限値", 0, "X軸の下限値を設定", (double) 7);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("8",  null, "11.6", null, 2, "", "Y軸グラフ上限値", 0, "Y軸の上限値を設定", (double) 8);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("9",  null, "10.0", null, 2, "", "Y軸グラフ閾値上限", 0, "Y軸の閾値上限(Y軸目盛線)を設定", (double) 9);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("10", null, "8.4", null, 2, "", "Y軸グラフ閾値下限", 0, "Y軸の閾値下限(Y軸目盛線)を設定", (double) 10);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("11", null, "6.8", null, 2, "", "Y軸グラフ下限値", 0, "Y軸の下限値を設定", (double) 11);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("12", null, "3", null, 2, "", "グラフプロットのサイズ", 0, "グラフのプロットのサイズ", (double) 12);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("13", null, "#33ff0a", null, 1, "", "プロットの色", 0, "グラフのプロットの色", (double) 13);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("14", null, "#ff0000", null, 1, "", "プロットの色（選択患者）", 0, "グラフのプロットの色（「分布」表示で選択した患者）", (double) 14);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("15", null, "#33ff0a", null, 1, "", "プロットの色（範囲外）", 0, "グラフの上下限値を超えるプロットの色", (double)15);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("16", null, "#ff0000", null, 1, "", "プロットの色（経過表示期間①）", 0, "グラフのプロットの色（「経過」表示の期間①）", (double) 16);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("17", null, "#d22d2d", null, 1, "", "プロットの色（経過表示期間②）", 0, "グラフのプロットの色（「経過」表示の期間②）", (double) 17);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("18", null, "#ff4d4d", null, 1, "", "プロットの色（経過表示期間③）", 0, "グラフのプロットの色（「経過」表示の期間③）", (double) 18);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("19", null, "#ffb3b3", null, 1, "", "プロットの色（経過表示期間④）", 0, "グラフのプロットの色（「経過」表示の期間④）", (double) 19);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("20", null, "#ff0000", null, 1, "", "線の色（経過表示期間①）", 0, "グラフの折れ線の色（「経過」表示の期間①）", (double) 20);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("21", null, "#ff4d4d", null, 1, "", "線の色（経過表示期間②）", 0, "グラフの折れ線の色（「経過」表示の期間②）", (double) 21);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("22", null, "#ff7a7a", null, 1, "", "線の色（経過表示期間③）", 0, "グラフの折れ線の色（「経過」表示の期間③）", (double) 22);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("23", null, "#ffb3b3", null, 1, "", "線の色（経過表示期間④）", 0, "グラフの折れ線の色（「経過」表示の期間④）", (double) 23);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("24", null, "1", null, 2, "", "グラフ線の太さ", 0, "折れ線グラフの線の太さ", (double) 24);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("25", null, "炭酸Ca↓\nCa非含有P吸着薬↑\n活性型ビタミンD↓\nシナカルセト↑*", null, 1, "", "集計情報エリア1説明文", 0, "集計エリアのエリア1のツールチップに表示する説明文", (double) 25);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("26", null, "炭酸Ca↑\nCa非含有P吸着薬↑\n活性型ビタミンD↓\nシナカルセト↑*", null, 1, "", "集計情報エリア2説明文", 0, "集計エリアのエリア2のツールチップに表示する説明文", (double) 26);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("27", null, "炭酸Ca↑\nCa非含有P吸着薬↑\nシナカルセト↓**", null, 1, "", "集計情報エリア3説明文", 0, "集計エリアのエリア3のツールチップに表示する説明文", (double) 27);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("28", null, "炭酸Ca↓\nCa非含有P吸着薬へ切り替え活性型ビタミンD↓\nシナカルセト↑*", null, 1, "", "集計情報エリア4説明文", 0, "集計エリアのエリア4のツールチップに表示する説明文", (double) 28);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("29", null, "P,Ca管理目標値", null, 1, "", "集計情報エリア5説明文", 0, "集計エリアのエリア5のツールチップに表示する説明文", (double) 29);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("30", null, "炭酸Ca↑\n炭酸Caの食間投与活性型ビタミンD↑\nシナカルセト↓**", null, 1, "", "集計情報エリア6説明文", 0, "集計エリアのエリア6のツールチップに表示する説明文", (double) 30);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("31", null, "炭酸Ca↓\nCa非含有P吸着薬↓\n活性型ビタミンD↓", null, 1, "", "集計情報エリア7説明文", 0, "集計エリアのエリア7のツールチップに表示する説明文", (double) 31);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("32", null, "炭酸Ca↓\nCa非含有P吸着薬↓\n活性型ビタミンD↑", null, 1, "", "集計情報エリア8説明文", 0, "集計エリアのエリア8のツールチップに表示する説明文", (double) 32);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("33", null, "Ca非含有P吸着薬↓\n炭酸Caの食間投与活性型ビタミンD↑\nシナカルセト↓**", null, 1, "", "集計情報エリア9説明文", 0, "集計エリアのエリア9のツールチップに表示する説明文", (double) 33);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("34", null, "0", null, 4, "[{\"id\":\"0\",\"name\":\"未登録\"}]", "グラフエリア1患者グループ", 0, "グラフエリア1に該当する患者グループコード", (double) 34);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("35", null, "0", null, 4, "[{\"id\":\"0\",\"name\":\"未登録\"}]", "グラフエリア2患者グループ", 0, "グラフエリア2に該当する患者グループコード", (double) 35);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("36", null, "0", null, 4, "[{\"id\":\"0\",\"name\":\"未登録\"}]", "グラフエリア3患者グループ", 0, "グラフエリア3に該当する患者グループコード", (double) 36);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("37", null, "0", null, 4, "[{\"id\":\"0\",\"name\":\"未登録\"}]", "グラフエリア4患者グループ", 0, "グラフエリア4に該当する患者グループコード", (double) 37);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("38", null, "0", null, 4, "[{\"id\":\"0\",\"name\":\"未登録\"}]", "グラフエリア5患者グループ", 0, "グラフエリア5に該当する患者グループコード", (double) 38);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("39", null, "0", null, 4, "[{\"id\":\"0\",\"name\":\"未登録\"}]", "グラフエリア6患者グループ", 0, "グラフエリア6に該当する患者グループコード", (double) 39);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("40", null, "0", null, 4, "[{\"id\":\"0\",\"name\":\"未登録\"}]", "グラフエリア7患者グループ", 0, "グラフエリア7に該当する患者グループコード", (double) 40);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("41", null, "0", null, 4, "[{\"id\":\"0\",\"name\":\"未登録\"}]", "グラフエリア8患者グループ", 0, "グラフエリア8に該当する患者グループコード", (double) 41);
    gList.add(graphSettingInfo);

    graphSettingInfo = new GraphSettingInfo("42", null, "0", null, 4, "[{\"id\":\"0\",\"name\":\"未登録\"}]", "グラフエリア9患者グループ", 0, "グラフエリア9に該当する患者グループコード", (double) 42);
    gList.add(graphSettingInfo);

    return gList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstFacility> selectMstFacility() {
    return null;
  }

  /**
   * 文字列をスネークケースに変換.
   *
   * @param targetString 対象文字列
   * @return 変換後文字列
   */
  private String convertToSnake(String targetString) {
    return CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, targetString);
  }

  /**
   * フォーマット文字列をKendoUI用に変換.
   *
   * @param formatString 対象文字列
   * @return 変換後文字列
   */
  private String getKendoFormatString(String formatString) {
    return "{0:" + formatString + "}";
  }

  /**
   * カラム情報の作成.
   *
   * @return カラム情報リスト
   */
  private List<MasterColumn> makeMasterColumn() {

    // カラム情報の作成
    List<MasterColumn> masterColumns = new ArrayList<MasterColumn>();

    MasterColumn masterColumn = null;

    // 表示順
    masterColumn = new MasterColumn("dispOrder", "No", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 施設設定番号
    masterColumn = new MasterColumn("facilitySettingNo", "No", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // ソート順項目を追加
    masterColumn = new MasterColumn(SORT_RANK, SORT_RANK_TITLE, false, false, getKendoFormatString(NUMBER_FORMAT), null, false, "");
    masterColumns.add(masterColumn);

    // ソート順用追加時刻項目を追加
    masterColumn = new MasterColumn(SORT_INPUT_TIME, SORT_INPUT_TIME, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 設定名称
    masterColumn = new MasterColumn("functionName", "設定名称", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // facilityCd
    masterColumn = new MasterColumn("facilityCd", "施設コード", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // value
    masterColumn = new MasterColumn("value", "値", true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 画面表示値格納項目
    masterColumn = new MasterColumn("dispValue", "設定値", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // input_type
    masterColumn = new MasterColumn("inputType", "入力分類", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // option情報
    masterColumn = new MasterColumn("optionValue", "option情報", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 操作権限可否
    masterColumn = new MasterColumn("makerSetting", "操作権限可否", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 設定説明
    masterColumn = new MasterColumn("description", "設定説明", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 付加情報としてoperationを追加
    masterColumn = new MasterColumn(OPERATION, OPERATION, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 付加情報として追加許可を追加(allowAddRecord=1)
    masterColumn = new MasterColumn(ALLOW_ADD_RECORD, ALLOW_ADD_RECORD, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    return masterColumns;

  }

  /**
   * フィールド情報の作成.
   *
   * @return フィールド情報MAP
   */
  private Map<String, Object> makeMasterField() {

    Map<String, Object> fieldsMap = new HashMap<>();
    Map<String, Object> fieldsList;

    // function_name
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("functionName", fieldsList);

    // facility_setting_no
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("facilitySettingNo", fieldsList);

    // facility_cd
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("facilityCd", fieldsList);

    // value
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("value", fieldsList);

    // dispValue
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("dispValue", fieldsList);

    // input_type
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put("inputType", fieldsList);

    // option_value
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("optionValue", fieldsList);

    // maker_setting
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put("makerSetting", fieldsList);

    // description
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("description", fieldsList);

    // disp_order
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put("dispOrder", fieldsList);

    return fieldsMap;
  }

  @Override
  @Transactional
  public void saveMstGraphSetting(Map<String, List<String>> payload) throws Exception {
      ObjectMapper mapper = new ObjectMapper();
      List<Long> listUserId = new ArrayList<>();
      // 登録処理
      for (int i = 0; payload.get("insertRecord").size() > i; i++) {
        MstGraphSetting mstGraphSetting = mapper.readValue(payload.get("insertRecord").get(i),
            MstGraphSetting.class);
        // update実行し対象がない場合にinsertを追加実行

        //DB更新ログ出力ロジック wp start

        String mmsTbN = "mst_graph_setting";

        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" graph_setting_no = '" + mstGraphSetting.getGraphSettingNo() + "'" +"\n");
        wheres.append(" and \n");
        wheres.append(" facility_cd = '" + mstGraphSetting.getFacilityCd() + "'" +"\n");
        // logCommon設定
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(mstGraphSettingDao, mmsTbN, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        //DB更新ログ出力ロジック wp end

        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(mstGraphSetting,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        int result = mstGraphSettingDao.update(mstGraphSetting);

        //DB更新ログ出力ロジック wp start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && result > 0) {
          logCommon.updateLog();
        }
        //DB更新ログ出力ロジック wp end

        if(result == 0 ) {
          result = mstGraphSettingDao.insert(mstGraphSetting);
        }
      }
  }


  //DB更新ログ出力ロジック wp start

  /**
   * ログ情報設定
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return   eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  //DB更新ログ出力ロジック wp end
}
