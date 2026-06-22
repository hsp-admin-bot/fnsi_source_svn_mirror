package jp.co.nikkiso.ntss.api.constant;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;

import java.util.List;

/**
 * 帳票に関する定数クラス.
 */
public class ReportConstant {

  /**
   * 帳票種別
   * ※ここを追加した場合、クライアント側のreportMenu.jsにも追加する事
   */
  public static class ReportClass {
    /**
     * 透析レポート
     */
    public static final Integer DIALYSIS_REPORT = 1;
    /**
     * 単患者帳票
     */
    public static final Integer ONE_PATIENT_REPORT = 2;
    /**
     * 複数患者帳票
     */
    public static final Integer MULTIPLE_PATIENT_REPORT = 3;
    /**
     * 準備リスト
     */
    public static final Integer PREPARATION_LIST_REPORT = 4;
    /**
     * 配布リスト（ベッド）
     */
    public static final Integer DISTRIBUTION_LIST_BED_REPORT = 5;
    /**
     * 配布リスト（物品）
     */
    public static final Integer DISTRIBUTION_LIST_GOODS_REPORT = 6;
    /**
     * 装置帳票
     */
    public static final Integer MACHINE_REPORT = 7;
    /**
     * ラベル
     */
    public static final Integer LABEL_REPORT = 8;
    /**
     * 紹介状
     */
    public static final Integer INTRODUCTION_REPORT = 9;
    // add FNSI-523 2次元帳票対応 夏 start
    /**
     * 単一集計
     */
    public static final Integer ONE_TOTAL_REPORT = 10;
    /**
     * 複数集計
     */
    public static final Integer MULTI_TOTAL_REPORT = 11;
    // add FNSI-523 2次元帳票対応 夏 end
  }

  /**
   * データキー
   */
  public static class ReportDataKey {
    /**
     * 複数患者
     */
    public static final String PAT_IDS = "patIds";
    /**
     * 単一患者
     */
    public static final String PAT_ID = "patId";
    /**
     * 複数オーダ番号
     */
    public static final String ORD_NOS = "ordNos";
    /**
     * 単一オーダ番号
     */
    public static final String ORD_NO = "ordNo";
    /**
     * 複数薬剤コード
     */
    public static final String MEDICINE_IDS = "medIds";
    /**
     * 複数ダイアライザコード
     */
    public static final String DIALYZER_IDS = "diaIds";
    /**
     * 複数医療材料コード
     */
    public static final String EQUIPMENT_IDS = "eqIds";
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    /**
     * 検査セット
     */
    public static final String EXAMSET_IDS = "esIds";
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    /**
     * 检查コード
     */
    public static final String INSPECT_IDS = "inspectIds";
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
    /**
     * テンプレート用のパラメータ
     */
    public static final String TEMPLATE_PARAMS = "tmplParams";

    /**
     * 日付
     */
    public static final String DATE = "date";
    /**
     * 範囲指定日付（開始）
     */
    public static final String DATE_FROM = "fromDate";
    /**
     * 範囲指定日付（終了）
     */
    public static final String DATE_TO = "toDate";

    // add FNSI-523 2次元帳票対応 夏 start
    /**
     * 範囲指定日付（終了）
     */
    public static final String FACILITY_CD = "facilityCd";
    // add FNSI-523 2次元帳票対応 夏 end

    /**
     * bvmsグラフデータ
     */
    public static final String BVMS_CHART_DATA = "bvmsChartData";

    /**
     * 印刷開始テンプレート番号. 帳票種別ラベルで使用する.
     */
    public static final String PRINTING_START_TMPL_NO = "startPos";
    /*add FNSI-改修内容装置帳票の対応 任 start*/
    public static final String MACHINE_NO = "machineNo";
    /*add FNSI-改修内容装置帳票の対応 任 end*/
    // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
    public static final String MACHINE_NOS = "machineNos";
    // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
    //add 帳票用のパラメーター設定処理  吉 start
    public static final String ORD_PRESCRIPTION_NOS = "ordPrescriptionNos";
    //add 帳票用のパラメーター設定処理  吉 end
    //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
    // add #6346 処方の項目が足りない 王永吉 start
    /**
     * 処方番号
     */
    public static final String ORD_PRESCRIPTION_NO = "ordPrescriptionNo";
    // add #6346 処方の項目が足りない 王永吉 end
    /**
     * フリーワード
     */
    public static final String freeWord = "freeWord";
    /**
     * 治療日
     */
    public static final String treatDate= "treatDate";
    /**
     * クール
     */
    public static final String kurCdList= "kurCdList";
    /**
     *ベッド
     */
    public static final String bedCdListString= "bedCdListString";
    // add #11973 日常点検一覧帳票が正常に出せない limingzhe start
    /**
     * クールコード
     */
    public static final String KUR_CDS= "kurCds";
    /**
     *ベッドコード
     */
    public static final String BED_CDS= "bedCds";
    // add #11973 日常点検一覧帳票が正常に出せない limingzhe end
    /**
     * 予定/実績
     */
    public static final String expressCondCd= "expressCondCd";
    /**
     * 期間
     */
    public static final String period= "period";
    /**
     * 種別
     */
    public static final String kind= "kind";
    /**
     * 週数
     */
    public static final String weeks= "weeks";
    // add 項目別(印刷情報一覧)の項目が実装されない  吉 end

    // add #5984 連携稼働ビューア  コンテンツを追加する  孟堅 start
    /**
     * 検査オーダS
     */
    public static final String examineCoopOrdNo="examineCoopOrdNo";
    /**
     * 一般撮影検査オーダS
     */
    public static final String angiographyCoopOrdNo="angiographyCoopOrdNo";
    /**
     * オーダS
     */
    public static final String coopOrdNo="coopOrdNo";
    // add #5984 連携稼働ビューア  コンテンツを追加する 孟堅 end

    // add 11010 スケジュール表出力時の処理が不足している gjn start
    public static final String kurCdLists = "kurCdLists";

    public static final String bedCdLists = "bedCdLists";
    // add 11010 スケジュール表出力時の処理が不足している gjn end

    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
    /**
     * 帳票種別
     */
    public static final String reportClass = "reportClass";
    /**
     * 基準日指定
     */
    public static final String dateKind = "dateKind";
    // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
    /**
     * 基準日(印刷情報用)
     */
    public static final String dateKindPrint = "dateKindPrint";
    /**
     * 処方区分
     */
    public static final String prescriptionKbn = "prescriptionKbn";
    /**
     * 紹介区分
     */
    public static final String introductionKbn = "introductionKbn";
    // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    /**
     * 単位ページ番号
     */
    public static final String currentPage = "currentPage";
    /**
     * 単位ページ総数
     */
    public static final String totalPages = "totalPages";
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end

    // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
    /**
     * 並び替え
     */
    public static final String SORT_CONDITIONS = "sortConditions";
    public static final String SORT_CONDITION_COLUMN = "sortColumn";
    public static final String SORT_CONDITION_ORDER = "sortOrder";

    /**
     * 検査区分
     */
    public static final String EXAM_CLASSS = "regOrderClassList";

    /**
     * 処方区分
     */
    public static final String PRESCRIPTION_CLASSS = "prescriptionClassList";

    /**
     * 紹介区分
     */
    public static final String LETTER_CLASSS = "letterCategoryList";
    // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
  }

  // add #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 start
  /**
   * 印刷情報データキー
   */
  public static class ReportPrintedInfo {
    /**
     * 単位ページ番号
     */
    // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe start
    //public static final String CURRENTPAGE = "[0.currentPage]";
    public static final String CURRENTPAGE = "0.currentPage";
    // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe end

    /**
     * 単位ページ総数
     */
    // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe start
    //public static final String TOTALPAGES = "[0.totalPages]";
    public static final String TOTALPAGES = "0.totalPages";
    // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe end
  }
  // add #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 end

  /**
   * 帳票ファイルダウンロードオプション
   */
  public static class ReportDownloadOption {
    /**
     * エクセルファイル
     */
    public static final Integer REPORT_DOWNLOAD_OPTION_EXCEL = 0;
    /**
     * PDFファイル
     */
    public static final Integer REPORT_DOWNLOAD_OPTION_PDF = 1;
  }

  /**
   * 帳票グラフに関する定数定義
   */
  public static class ReportGraph {

    /**
     * モニタ項目コード:最高血圧
     */
    public static final String MONITOR_ITEM_CD_BP_MAX = "90";

    /**
     * モニタ項目コード:平均血圧
     */
    public static final String MONITOR_ITEM_CD_BP_AVE = "92";

    /**
     * モニタ項目コード:最低血圧
     */
    public static final String MONITOR_ITEM_CD_BP_MIN = "91";

    /**
     * グラフのJSONテンプレートファイル
     */
    public static final String TEMPLATE_CHART_JSON = "classpath:report/chart/vital.chart-template.json";

    public static final String LIC = "classpath:report/lic/Aspose.Cells.Java.lic";
    // add highchart-export-serve change to Playwright  吉 start
    public static final String TEMPLATE_HIGHCHART_JS = "classpath:report/chart/highcharts.js";
    // add highchart-export-serve change to Playwright  吉 end
    /**
     * 血圧情報以外に出力可能な項目数
     */
    public static final Integer MAX_REPORT_GRAPH_COUNT = 5;

    /**
     * 一時ファイルのプレフィックス
     */
    public static final String TEMP_FILE_PREFIX = "nkk-report";

    /**
     * プレフィックス：最大血圧
     */
    public static final String PREFIX_BP_MAX = "bpMax";

    /**
     * プレフィックス：平均血圧
     */
    public static final String PREFIX_BP_AVE = "bpAve";

    /**
     * プレフィックス：最低血圧
     */
    public static final String PREFIX_BP_MIN = "bpMin";

    /**
     * プレフィックス：血圧情報以外
     */
    public static final String PREFIX_ITEM = "item";

    /**
     * 帳票グラフで対象とする {@link jp.co.nikkiso.ntss.core.entity.MniMonitor} のデータタイプの配列
     */
    public static final Short[] TARGET_DATA_TYPE = {
      // del #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
//      CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_MONITOR,
      // del #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
      CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP,
      CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_TEMPERATURE,
      CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_BEFORE_BP,
      CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_AFTER_BP
    };

    // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
    public static final Short[] ALL_DATA_TYPE = {
      CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_MONITOR,
      CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP,
      CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_TEMPERATURE,
      CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_BEFORE_BP,
      CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_AFTER_BP
    };
    // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
  }

  // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 start
  /**
   * 事前処理用項目
   */
  public static final String PreSqlInfoItem = "PreSqlInfoItem";
  // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 end

  // add 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 start
  // table 最大 幅
  public static final int MIN_WIDTH = 45;
  //全体の比例
  public static final int HIGH_CHAR_HEIGHT_CONT_EQ = 26;
  //ユニットの高さ
  public static final int HIGH_CHAR_HEIGHT_UNIT_HEIGHT = 24;
  //highchars图例 幅
  public static final int LEGEND_WIDTH = 35;
  // add 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 end
  // add #11625 【標準帳票】クラス「指示履歴」の仕様変更② sunsy start
  public static class LogTargetClass {
    public static final String TREATMENT_SCHEDULE = "治療予定";
    public static final String TREATMENT_METHOD = "治療方法";
    public static final String KUR = "クール";
    public static final String TREATMENT_DATE = "治療開始時刻";
    public static final String BED = "ベッド";
    public static final String TREATMENT_TIME = "治療時間";
    public static final String VA = "VA";
    public static final String DW = "DW";
    public static final String TARGET_WEIGHT = "目標体重";
    public static final String WATER_LIMIT = "除水量制限";
    public static final String DIALYSIS = "ダイアライザ";
    public static final String ADSORPTION_COLUMN = "吸着カラム";
    public static final String PRIMARY_FILM = "1次膜";
    public static final String SECONDARY_FILM = "2次膜";
    public static final String NEEDLES_A = "穿刺針(A針)";
    public static final String NEEDLES_V = "穿刺針(V針)";
    public static final String NEEDLES_SN = "穿刺針(SN)";
    public static final String SINGLE_NEEDLE_USE = "シングルニードル使用";
    public static final String BLOOD_CIRCUIT = "血液回路";
    public static final String BLOOD_FLOW = "血流量";
    public static final String DIALYSATE = "透析液";
    public static final String DIALYSATE_FLOW = "透析液流量";
    public static final String DIALYSATES_USED_NUM = "透析液使用数";
    public static final String DIALYSATE_TEMPERATURE = "透析液温度";
    public static final String FLUID_REPLENISHMENT = "補液";
    public static final String FR_VOLUME = "補液量";
    public static final String FR_SELECTION = "補液選択";
    public static final String FR_USE_NUM = "補液使用数";
    public static final String FR_TEMPERATURE = "補液温度";
    public static final String FR_VELOCITY = "補液速度";
    public static final String ANTICOAGULANTS = "抗凝固剤";
    public static final String ANTICOAGULANTS_ONESHOT_QUANTITY = "抗凝固剤ワンショット量";
    public static final String ANTICOAGULANTS_DURATION_RATE = "抗凝固剤持続速度";
    public static final String ANTICOAGULANTS_SUSTAINED_TOTAL_AMOUNT = "抗凝固剤持続総量";
    public static final String IP_USAGE_SELECTION = "IP使用選択";
    public static final String IP_START = "IPスタート";
    public static final String IP_ONESHOT_QUANTITY = "IPワンショット量";
    public static final String IP_VELOCITY = "IP速度";
    public static final String IP_VELOCITY_MAX = "IP速度最大値";
    public static final String AUTO_ONESHOT = "自動ワンショット";
    public static final String IP_AUTO_OFF = "IP電源自動切り";
    public static final String IP_AUTO_OFF_TIME = "IP電源自動切り時間";
    public static final String IP_POWER_OK_MONITOR_OFF = "IP電源OKモニタ切り";
    public static final String IP_POWER_OK_MONITOR_OFF_TIME = "IP電源OKモニタ切り時間";
    public static final String MEDICINE_AMOUNT_UNIT = "投与薬剤(数量+単位)";
    public static final String MEDICINE_NAME_AMOUNT_UNIT = "投与薬剤(薬剤名+数量+単位)";
    public static final String EQUIPMENT = "医療材料";
    public static final String CONTENT = "指示コメント";
  }
  // add #11625 【標準帳票】クラス「指示履歴」の仕様変更② sunsy end

  // add #11127 グループ除外処理の残対応（モニタ、身体情報）　高　start
  public static class DeatilNotIFNullClass {
    // 対象クラスと、付加情報(※)
    public static final List<String> FIELDS = List.of(
      "103occur_date",// 実績.バイタル(昇順).測定日時
      "235occur_date",// 実績.バイタル(降順).測定日時
      "38exam_date",// 患者情報.身体情報(昇順).検査日時
      "38order_class",// 患者情報.身体情報(昇順).検査タイミング
      "38ctr_weight",// 患者情報.身体情報(昇順).検査時体重
      "38indicator_start_date",// 患者情報.身体情報(昇順).目標体重指示開始日
      "38indicator_name",// 患者情報.身体情報(昇順).指示者
      "39exam_date",// 患者情報.身体情報(降順).検査日時
      "39order_class",// 患者情報.身体情報(降順).検査タイミング
      "39ctr_weight",// 患者情報.身体情報(降順).検査時体重
      "39indicator_start_date",// 患者情報.身体情報(降順).目標体重指示開始日
      "39indicator_name"// 患者情報.身体情報(降順).指示者
    );
  }
  // add #11127 グループ除外処理の残対応（モニタ、身体情報）　高　end
}
