package jp.co.nikkiso.ntss.api.service.report;

import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.core.JacksonException;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.PropertyNamingStrategies;
// add redmain #4822 鄧シン start
import com.sun.management.OperatingSystemMXBean;
import jp.co.nikkiso.ntss.api.constant.ApiConstant;
// add redmain #4822 鄧シン start
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.model.HighchartGenerateModel;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.api.service.RenderPoolService;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.service.utils.FontSubstitutionUtil;
import jp.co.nikkiso.ntss.api.service.utils.TmpFileService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstAddMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.ReportDao;
import jp.co.nikkiso.ntss.core.dao.SysMonitorItemDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MstAddMonitor;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.core.io.ResourceLoader;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.GraphicsEnvironment;
import java.awt.RenderingHints;
import java.awt.font.FontRenderContext;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.sql.Timestamp;
// add #6586 透析レポート：愁訴処置のプロットができない 王永吉 start
import java.text.ParseException;
import java.text.SimpleDateFormat;
// add #6586 透析レポート：愁訴処置のプロットができない 王永吉 end
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 帳票のチャートを生成するServiceクラス.
 */
@Service
public class ReportChartServiceImpl implements ReportChartService {

  @Value("${ntss.report.createTmpDir}")
  private String createTmpDir;

  /* add by chamaojia 2022-11-08 [7822] 定数の追加  --start */
  private static final long MINUTE_TIMESTAMP = 60 * 1000;
  /* add by chamaojia 2022-11-08 [7822] 定数の追加  --end */

  /**
   * グラフ時間軸のデフォルト値.
   */
  private static final Integer GRAPH_TIME_SCALE_DEFAULT = 6;

  /**
   * 帳票データ取得用のDaoインタフェース.
   */
  @Autowired
  private ReportDao reportDao;

  /**
   * 治療記録データ取得用のDaoインターフェイス.
   */
  @Autowired
  private TreatmentRecordDao treatmentRecordDao;

  /**
   * リソースファイルアクセス用.
   */
  @Autowired
  ResourceLoader resourceLoader;

  /**
   * {@link jp.co.nikkiso.ntss.core.dao.MniMonitorDao}のインタフェース.
   */
  @Autowired
  private MniMonitorDao mniMonitorDao;

  /**
   * {@link MstTreatmentDao}のインタフェース.
   */
  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  /**
   * {@link OrdMainDao}のインタフェース.
   */
  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * {@link MstAddMonitorDao}のインタフェース.
   */
  @Autowired
  private MstAddMonitorDao mstAddMonitorDao;

  /**
   * 一時ファイル作成のインタフェース.
   */
  @Autowired
  private TmpFileService tmpFileService;

  // add #6586 透析レポート：愁訴処置のプロットができない 王永吉 start

  // add #11232 #10515で入れた制限の見直し 房 start
  @Autowired
  private SysDataSetService sysDataSetService;
  // add #11232 #10515で入れた制限の見直し 房 end
  @Autowired
  LogService logService;
  // add #6586 透析レポート：愁訴処置のプロットができない 王永吉 end
  // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 start
  private boolean fromFlag = false;
  // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 end

  // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
  private static ApplicationContext applicationContext;

  @Autowired
  public void setApplicationContext(ApplicationContext context) {
    applicationContext = context;
  }
  // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
  // add highchart-export-serve change to Playwright  吉 start
  private final RenderPoolService pool;

  public ReportChartServiceImpl(RenderPoolService pool) {
    this.pool = pool;
  }

  // mod #10633 【たくしん会】帳票のフォント問題 吉 end
  // mod 10515 治療記録のバイタル/モニタに登録されているデータによってサーバーが高負荷となる 吉 end
  // mod 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 end
  // add 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 start
  @Override
  public int getVitalChartDataLen(Long ordNo) {
    List<ReportGraphSetting> reportGraphSettingList = getReportGraphSettingByOrdNo(ordNo);
    if(null != reportGraphSettingList && reportGraphSettingList.size()>0){
      return reportGraphSettingList.size()-2;
    }
    return reportGraphSettingList.size();
  }
  // add 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 end

  /**
   * 与えられたモニタデータのマップからプロットデータのリストを作成する.
   * リストは下記の様にデータが格納されている.
   *  [発生日時(UTC形式), 値]
   *
   * @param monitorData モニタデータ
   * @param offsetTime タイムスタンプオフセット
   * @return プロットデータ用のリスト
   */
  /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --start */
  private List<String> createPlotData(Map<Timestamp, String> monitorData, long offsetTime) {
  /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --end */
    //mod 6589 治癒経過表：プレビューでシステムエラー 吉 start
//    return monitorData.entrySet().stream()
//      .filter(e -> !StringUtils.isEmpty(e.getValue()))
//      .map(e -> String.format("[%d, %f]", e.getKey().getTime(), new BigDecimal(e.getValue())))
//      .collect(Collectors.toList());
    if(null != monitorData){
      /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --start */
      return monitorData.entrySet().stream()
        .filter(e -> !StringUtils.isEmpty(e.getValue()))
        .map(e -> String.format("[%d, %f]", e.getKey().getTime() - offsetTime, new BigDecimal(e.getValue())))
        .collect(Collectors.toList());
      /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --end */
    }else{
      return new ArrayList<>();
    }
    //mod 6589 治癒経過表：プレビューでシステムエラー 吉 start
  }

  /**
   * グラフ用のjsonテンプレートの文字列を取得する.
   *
   * @return テンプレート文字列
   */
  private String getChartJson() {
    String template;
    try {
      URL url = resourceLoader.getResource(ReportConstant.ReportGraph.TEMPLATE_CHART_JSON).getURL();
      try (
        InputStream is = url.openStream();
        ByteArrayOutputStream os = new ByteArrayOutputStream();) {

        byte[] buffer = new byte[1024];
        int len = is.read(buffer);
        while (len >= 0) {
          os.write(buffer, 0, len);
          len = is.read(buffer);
        }
        template = new String(os.toByteArray(), StandardCharsets.UTF_8);
      }
    } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      // テンプレートが取得できなかった場合は空文字列を返す
      return "";
    }
    //mod 8077 nvm14系でビルドすると帳票のトレンドグラフの対象データがある場合の処理でエラーが発生する。 朴 start
    // return template;
    return template.replaceAll("\\r\\n", "\n").replaceAll("\\r", "\n");
    //mod 8077 nvm14系でビルドすると帳票のトレンドグラフの対象データがある場合の処理でエラーが発生する。 朴 end
  }

  /**
   * モニタグラフ用のjsonを作成する.
   *
   * @param monitorDataMap モニタデータの{@link Map}
   * @param reportGraphSettingList 帳票グラフ設定
   * @param startTime 開始時刻
   * @param offsetTime タイムスタンプオフセット
   * @return
   */
  /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --start */
  // mod #10515 治療記録のバイタル/モニタに登録されているデータによってサーバーが高負荷となる 房 start
  // mod #11232 #10515で入れた制限の見直し 房 start
  // mod #10633 【たくしん会】帳票のフォント問題 吉 start
//  private String createJsonForMonitorChart(Map<Timestamp, Map<String, String>> monitorDataMap, List<ReportGraphSetting> reportGraphSettingList, long startTime, long offsetTime, String type, List listForDateValues) {
  // mod #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
//  private String createJsonForMonitorChart(Map<Timestamp, Map<String, String>> monitorDataMap, List<ReportGraphSetting> reportGraphSettingList,
//                                           long startTime, long offsetTime, String type, List listForDateValues,String fountStr) {
    private String createJsonForMonitorChart(Map<Timestamp, Map<String, String>> bataruDataMap,Map<Timestamp, Map<String, String>> monitorDataMap, List<ReportGraphSetting> reportGraphSettingList,
                                           long startTime, long offsetTime, String type, List listForDateValues,String fountStr) {
    // mod #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
    // mod #10633 【たくしん会】帳票のフォント問題 吉 end
    // mod #11232 #10515で入れた制限の見直し 房 end
    // mod #10515 治療記録のバイタル/モニタに登録されているデータによってサーバーが高負荷となる 房 end
  /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --end */
    // 出力するモニタ項目コードのリスト
      // mod #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
    List<String> monitorItemCdList = reportGraphSettingList.stream().map(r -> r.cd).collect(Collectors.toList());
//    // モニタ項目毎のマップに変換
//    Map<String, Map<Timestamp, String>> convertMonitorDataMap = convertMonitorData(monitorItemCdList, monitorDataMap);
//    List<String> monitorItemCdList = reportGraphSettingList.stream().filter(r -> !"1".equals(r.dataType)).map(r -> r.cd).collect(Collectors.toList());
    List<String> bataruItemCdList = reportGraphSettingList.stream().map(r -> r.cd).collect(Collectors.toList());
    Set<String> combinedSet = new HashSet<>();
    combinedSet.addAll(monitorItemCdList);
    combinedSet.addAll(bataruItemCdList);
    List<String> orderedList = reportGraphSettingList.stream()
      .map(r -> r.cd)
      .filter(combinedSet::contains)
      .collect(Collectors.toList());
    // モニタ項目毎のマップに変換
    Map<String, Map<Timestamp, String>> convertMonitorDataMap = convertMonitorData(bataruItemCdList, bataruDataMap);

    Map<String, Map<Timestamp, String>> convertMonitorDataMap1 = convertMonitorData(monitorItemCdList, monitorDataMap);
    for (Map.Entry<String, Map<Timestamp, String>> entry : convertMonitorDataMap1.entrySet()) {
      String key = entry.getKey();
      Map<Timestamp, String> innerMap1 = entry.getValue();
      convertMonitorDataMap.computeIfAbsent(key, k -> new LinkedHashMap<>());
      Map<Timestamp, String> innerMap = convertMonitorDataMap.get(key);
      for (Map.Entry<Timestamp, String> subEntry : innerMap1.entrySet()) {
        innerMap.putIfAbsent(subEntry.getKey(), subEntry.getValue());
      }
    }
    // mod #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end

    // mod 記録画面の帳票グラフ表示対応 夏 start
//    // 血圧(最大)
//    List<String> bpMax = createPlotData(convertMonitorDataMap.get(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_MAX));
//    // グラフの左端を調整するためにダミーデータを先頭に追加する.
//    if (startTime != 0) {
//      bpMax.add(0, String.format("[%d, null]", startTime));
//    }
//    // 血圧(平均)
//    List<String> bpMin = createPlotData(convertMonitorDataMap.get(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_AVE));
//    // 血圧(最低)
//    List<String> bpAve = createPlotData(convertMonitorDataMap.get(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_MIN));

    List<String> bpMax = new ArrayList<>();
    List<String> bpMin = new ArrayList<>();
    List<String> bpAve = new ArrayList<>();
    if(convertMonitorDataMap.size() !=0) {
      // 血圧(最大)
      /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --start */
      bpMax = createPlotData(convertMonitorDataMap.get(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_MAX), offsetTime);
//      // グラフの左端を調整するためにダミーデータを先頭に追加する.
//      if (startTime != 0) {
//        bpMax.add(0, String.format("[%d, null]", startTime));
//      }
      // mod #6166 帳票グラフの表示不正 王永吉 start
      //// 血圧(平均)
      //bpMin = createPlotData(convertMonitorDataMap.get(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_AVE));
      //// 血圧(最低)
      //bpAve = createPlotData(convertMonitorDataMap.get(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_MIN));
      // 血圧(平均)
      bpAve = createPlotData(convertMonitorDataMap.get(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_AVE), offsetTime);
      // 血圧(最低)
      bpMin = createPlotData(convertMonitorDataMap.get(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_MIN), offsetTime);
      /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --end */
      // mod #6166 帳票グラフの表示不正 王永吉 end
    }else{
      bpMax.add("");
      bpMin.add("");
      bpAve.add("");
    }
    // mod 記録画面の帳票グラフ表示対応 夏 end

    // 血圧以外のプロットデータを格納するリスト
    // ※追加した順序を担保する為、LinkedHashMapを使用している.
    Map<String, List<String>> plotData = new LinkedHashMap<>();
    // mod #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
      // monitorItemCdList.forEach(m -> {
    orderedList.forEach(m -> {
      // mod #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
      // 血圧の場合は何もしない.
      if (isBp(m)) {
        return;
      }
      // 血圧以外の場合
      /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --start */
      plotData.put(m, createPlotData(convertMonitorDataMap.get(m), offsetTime));
      /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --end */
    });
    // JSONテンプレートを取得
    String template = getChartJson();
    // グラフ用テンプレート文字列が取得できなかった場合
    if (StringUtils.isEmpty(template)) {
      return "";
    }

    // add 記録画面の帳票グラフ表示対応 夏 start
    if(reportGraphSettingList.size() != 0) {
    // add 記録画面の帳票グラフ表示対応 夏 end
      // 最大血圧
      // add 8071 治療方法のグラフ設定が反映されない 吉 start
      // mod #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 start
      // String bloodPreName = "血圧<br><span style='font-size:14px;color:";
      String bloodPreName = "";
      // mod #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 end
      // add 8071 治療方法のグラフ設定が反映されない 吉 end

      // del #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 start
//Optional<ReportGraphSetting> bpMaxReportGraphSetting =
//        reportGraphSettingList.stream()
//          .filter(e -> e.getCd().equals(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_MAX)).findFirst();
//      // add 8071 治療方法のグラフ設定が反映されない 吉 start
//      bloodPreName = bloodPreName + bpMaxReportGraphSetting.get().getPlotColor() + "'>" + changeshowShape(bpMaxReportGraphSetting.get().getPlotType())+"</span><br><span style='font-size:14px;color:";
//      // add 8071 治療方法のグラフ設定が反映されない 吉 end
//      template = replaceGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_MAX, bpMaxReportGraphSetting.get());
//      // 平均血圧
//      Optional<ReportGraphSetting> bpAveReportGraphSetting =
//        reportGraphSettingList.stream()
//          .filter(e -> e.getCd().equals(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_AVE)).findFirst();
//      // add 8071 治療方法のグラフ設定が反映されない 吉 start
//      bloodPreName = bloodPreName + bpAveReportGraphSetting.get().getPlotColor() + "'>" + changeshowShape(bpAveReportGraphSetting.get().getPlotType())+"</span><br><span style='font-size:14px;color:";
//      // add 8071 治療方法のグラフ設定が反映されない 吉 end
//      template = replaceGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_AVE, bpAveReportGraphSetting.get());
//      // 最低血圧
//      Optional<ReportGraphSetting> bpMinReportGraphSetting =
//        reportGraphSettingList.stream()
//          .filter(e -> e.getCd().equals(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_MIN)).findFirst();
//      // add 8071 治療方法のグラフ設定が反映されない 吉 start
//      bloodPreName = bloodPreName + bpMinReportGraphSetting.get().getPlotColor() + "'>" + changeshowShape(bpMinReportGraphSetting.get().getPlotType())+"</span>";
//      bpMinReportGraphSetting.get().setName(bloodPreName);
//      // add 8071 治療方法のグラフ設定が反映されない 吉 end
//      template = replaceGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_MIN, bpMinReportGraphSetting.get());
//      // add 記録画面の帳票グラフ表示対応 夏 start
// del #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 end

      // add #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 start
      Optional<ReportGraphSetting> bpMaxReportGraphSetting =
        reportGraphSettingList.stream()
          .filter(e -> e.getCd().equals(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_MAX) && (null == e.showCheck || e.showCheck)).findFirst();
      // 平均血圧
      Optional<ReportGraphSetting> bpAveReportGraphSetting =
        reportGraphSettingList.stream()
          .filter(e -> e.getCd().equals(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_AVE) && (null == e.showCheck || e.showCheck)).findFirst();
      // 最低血圧
      Optional<ReportGraphSetting> bpMinReportGraphSetting =
        reportGraphSettingList.stream()
          .filter(e -> e.getCd().equals(ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_MIN) && (null == e.showCheck || e.showCheck)).findFirst();
      boolean max = !bpMaxReportGraphSetting.isEmpty();
      boolean ave = !bpAveReportGraphSetting.isEmpty();
      boolean min = !bpMinReportGraphSetting.isEmpty();
      class SpanLine {
        String html;
        boolean isEmpty;
        SpanLine(String html, boolean isEmpty) {
          this.html = html;
          this.isEmpty = isEmpty;
        }
      }
      List<SpanLine> lines = new ArrayList<>();
      lines.add(bpMaxReportGraphSetting.isEmpty()
        ? new SpanLine("<span style='font-size:14px;color:'>　</span>", true)
        : new SpanLine("<span style='font-size:14px;color:" + bpMaxReportGraphSetting.get().plotColor + "'>" +
        changeshowShape(bpMaxReportGraphSetting.get().plotType) + "</span>", false));
      lines.add(bpAveReportGraphSetting.isEmpty()
        ? new SpanLine("<span style='font-size:14px;color:'>　</span>", true)
        : new SpanLine("<span style='font-size:14px;color:" + bpAveReportGraphSetting.get().plotColor + "'>" +
        changeshowShape(bpAveReportGraphSetting.get().plotType) + "</span>", false));
      lines.add(bpMinReportGraphSetting.isEmpty()
        ? new SpanLine("<span style='font-size:14px;color:'>　</span>", true)
        : new SpanLine("<span style='font-size:14px;color:" + bpMinReportGraphSetting.get().plotColor + "'>" +
        changeshowShape(bpMinReportGraphSetting.get().plotType) + "</span>", false));
      lines.sort(Comparator.comparing(line -> line.isEmpty));
      bloodPreName += "血圧<br>" +
        lines.get(0).html + "<br>" +
        lines.get(1).html + "<br>" +
        lines.get(2).html;
      if(max){
        bpMaxReportGraphSetting.get().setName(bloodPreName);
        template = replaceGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_MAX, bpMaxReportGraphSetting.get());
      }else{
        template = replaceDefaultReportGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_MAX);
      }
      if (ave) {
        bpAveReportGraphSetting.get().setName(bloodPreName);
        template = replaceGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_AVE, bpAveReportGraphSetting.get());
      }else {
        template = replaceDefaultReportGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_AVE);
      }
      if(min){
        bpMinReportGraphSetting.get().setName(bloodPreName);
        template = replaceGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_MIN, bpMinReportGraphSetting.get());
      }else{
        template = replaceDefaultReportGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_MIN);
      }
      if(bpMaxReportGraphSetting.isEmpty() && bpAveReportGraphSetting.isEmpty() && bpMinReportGraphSetting.isEmpty()){
        template = template.replace("#bp.min#", String.join(",", "0"))
          .replace("#bp.max#", String.join(",", "0"))
          .replace("#bp.tickInterval#", String.join(",", "0"))
          .replace("#bp.labelsFormat#", String.join(",", ""))
          .replace("#bp.tickPositioner#", String.join(",", ""));
      }
      // add #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 end
    // add 記録画面の帳票グラフ表示対応 夏 start
    }else{
      template = replaceDefaultReportGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_MAX);
      template = replaceDefaultReportGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_AVE);
      template = replaceDefaultReportGraphSetting(template, ReportConstant.ReportGraph.PREFIX_BP_MIN);
      template = template.replace("#bp.min#", String.join(",", "0"))
        .replace("#bp.max#", String.join(",", "0"))
        .replace("#bp.tickInterval#", String.join(",", "0"))
        .replace("#bp.labelsFormat#", String.join(",", ""))
        // add #11232 #10515で入れた制限の見直し 房 start
        .replace("#bp.tickPositioner#", String.join(",", ""));
        // add #11232 #10515で入れた制限の見直し 房 end
    }
    // add 記録画面の帳票グラフ表示対応 夏 end

    // 血圧のプロットデータを埋め込む
    template = template.replace("#bpMax#", String.join(",", bpMax))
      .replace("#bpMin#", String.join(",", bpMin))
      .replace("#bpAve#", String.join(",", bpAve));

    // 血圧以外の情報
    Set<String> keys = plotData.keySet();
    // 血圧以外の情報を展開時にプレフィックスに付与するインデックス
    // ※"item1" の "1" の部分
    int index = 1;
    for (String key : keys) {
      // プレフィックス生成
      String prefix = ReportConstant.ReportGraph.PREFIX_ITEM + index;
      // 帳票グラフ設定からモニタ項目コードに該当する設定を取得する.
      Optional<ReportGraphSetting> reportGraphSetting =
        reportGraphSettingList.stream().filter(e -> e.getCd().equals(key)).findFirst();
      // 帳票グラフ設定を元にJsonテンプレート文字列を置換.
      template = replaceGraphSetting(
        template,
        prefix,
        reportGraphSetting.get()
      ).replace(String.format("#%s#", prefix), String.join(",", plotData.get(key)));
      index++;
    }

    // 5件に満たない場合はテンプレートに埋め込まれている置換文字を空データで埋める.
    for (; index <= ReportConstant.ReportGraph.MAX_REPORT_GRAPH_COUNT; index++) {
      String prefix = ReportConstant.ReportGraph.PREFIX_ITEM + index;
      template = replaceGraphSetting(template, prefix, null);
      template = template.replace(String.format("#%s#", prefix), "");

    }
    // add #6586 透析レポート：愁訴処置のプロットができない 王永吉 start
    // mod #11232 #10515で入れた制限の見直し 房 start
    if (listForDateValues != null && listForDateValues.size() > 0) {
      // mod #11232 #10515で入れた制限の見直し 房 end
      if (!"".equals(listForDateValues.get(0))) {
        String strTarget = "}\n" + "  ]\n" + "}";
        int lastIndex1 = template.lastIndexOf(strTarget);
        // mod bug 8077 修正 chen start
        String aFirst = null;
        if (lastIndex1 > 0) {
          aFirst = template.substring(0, lastIndex1);
        } else {
          aFirst = template;
        }
        // mod bug 8077 修正 chen end

        String doingJson = listForDateValues.get(0).toString();
        doingJson = doingJson.replace("#itemSyuuso.lineWidth#", "0");
        doingJson = doingJson.replace("#itemSyuuso.lineColor#", "#fb89c2");
        doingJson = doingJson.replace("#itemSyuuso.lineType#", "Solid");
        doingJson = doingJson.replace("#itemSyuuso.plotType#", "diamond");
        doingJson = doingJson.replace("#itemSyuuso.plotFillColor#", "#000000");
        doingJson = doingJson.replace("#itemSyuuso.plotLineColor#", "#000000");
        doingJson = doingJson.replace("#itemSyuuso.plotSize#", "5");

        /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --start */
        template = aFirst + getDoingJsonToHandleData(doingJson, offsetTime);
        /* modify by chamaojia 2022-11-08 [7822] オフセットパラメータの追加  --end */
      }
    }
    // add #6586 透析レポート：愁訴処置のプロットができない 王永吉 end
    // add #10633 【たくしん会】帳票のフォント問題 吉 start
    if(!StringUtils.isEmpty(fountStr)){
      // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//      template = template.replace("#chart.fontFamily#",fountStr+",helvetica, arial, hiragino kaku gothic pro, meiryo, ms pgothic, sans-serif");
      Map<String,String> resultNew = chartFontFamily(fountStr);
      template = template.replace("#chart.fontFamily#", resultNew.get(fountStr));
      // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    }
    // add #10633 【たくしん会】帳票のフォント問題 吉 end
    // 埋め込んだテンプレートを返す.
    return template;
  }

  /* add by chamaojia 2022-11-08 [7822] データオフセットを処理する新しい方法の追加  --start */
  /**
   * データの処理、タイムスタンプによるオフセットの追加
   * @param doingJson   処理されるデータ文字列
   * @param offsetTime  タイムスタンプオフセット
   * @return
   */
  private String getDoingJsonToHandleData(String doingJson, long offsetTime) {
    if (offsetTime != 0) {
      // 固定文字列判定切り取りにより、dataノードのデータを取り出す
      int dataStartIndex = doingJson.lastIndexOf("\"data\": ");
      // mod bug 8077 修正 chen start
      if (dataStartIndex >= 0 && doingJson.length() > dataStartIndex + 9) {
      // mod bug 8077 修正 chen end
        String dataLastStr = doingJson.substring(dataStartIndex + 9);
        int dataEndIndex = dataLastStr.lastIndexOf("]],");
        if (dataEndIndex >= 0) {
          String dataStr = dataLastStr.substring(0, dataEndIndex + 2);
          String[] dataArr = dataStr.split(", ");
          if (dataArr.length > 0) {
            StringBuilder doingJsonToExistData = new StringBuilder(doingJson.substring(0, dataStartIndex + 9));
            // タイムスタンプデータをオフセットで処理し、文字列を再構築する
            for (int i = 0;i < dataArr.length;i++) {
              if (dataArr[i].contains("[")) {
                long time = Long.parseLong(dataArr[i].substring(1)) -  offsetTime;
                doingJsonToExistData = doingJsonToExistData.append("[").append(time);
              } else {
                doingJsonToExistData = doingJsonToExistData.append(dataArr[i]);
              }
              if (i != dataArr.length - 1) {
                doingJsonToExistData = doingJsonToExistData.append(", ");
              }
            }
            doingJsonToExistData = doingJsonToExistData.append(dataLastStr.substring(dataEndIndex + 2));
            return doingJsonToExistData.toString();
          }
        }
      }
    }

    return doingJson;
  }
  /* add by chamaojia 2022-11-08 [7822] データオフセットを処理する新しい方法の追加  --start */

  // add #6586 透析レポート：愁訴処置のプロットができない 王永吉 start
  // mod #11232 #10515で入れた制限の見直し 房 start
  private List<Map<String, Object>> syuusoValues(List<Map<String, Object>> valuesOfSyuuso) {
    // mod #11232 #10515で入れた制限の見直し 房 end
    String syuusoStrList = "";
    ArrayList listForDate = new ArrayList();
    boolean quieFlag = false;
    String strDoData = "";
    int doingData = 0;
    if (valuesOfSyuuso.size() > 0) {
      ArrayList syuusoList = new ArrayList();
      Map<String, Object> syuusoIn = new HashMap<>();
      List<Map<String, Object>> values = valuesOfSyuuso;
      for (int i = 0; i < values.size(); i++) {
        Object syuusoTime = values.get(i).get("occur_time");
        Object syuusoDay = values.get(i).get("occur_date");
        if (!"".equals(syuusoTime) && syuusoTime != null && !"".equals(syuusoDay) && syuusoDay != null) {
          // 標準時間を取得する
          String syuusoDayTime = "";
          if (syuusoTime.toString().length() <= 5) {
            syuusoDayTime = syuusoDay + " " + syuusoTime + ":00";
          } else {
            syuusoDayTime = syuusoDay + " " + syuusoTime;
          }
          // mod #11737 グラフがセルサイズにフィットしないときがある 房 start
//          SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
          SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
          // mod #11737 グラフがセルサイズにフィットしないときがある 房 start
          Date date = null;
          try {
            date = simpleDateFormat.parse(syuusoDayTime);
          } catch (ParseException e) {

          }
          if (date != null) {
            long fastTime = date.getTime();
            if (i == 0) {
              listForDate.add(date.getTime());
            }
            quieFlag = true;
            for (String con : syuusoIn.keySet()){
              if (con.equals(String.valueOf(fastTime))){
                quieFlag = false;
              }
            }
            if (quieFlag){
              doingData++;
              strDoData = String.valueOf(doingData) + ".000000";
            }
            syuusoIn.put(String.valueOf(fastTime), strDoData);
            syuusoList.add(syuusoIn);
            syuusoIn = new HashMap<>();
          }
        }
      }
      if (syuusoList.size() > 0) {
        String syuusoDateList = syuusoList.toString().replace("{", "[")
          .replace("}", "]")
          .replace("=", ", ");
        // 新しいjson文の生成
        syuusoStrList = "}," +
          "    {" +
          "      \"type\": \"spline\"," +
          "      \"lineWidth\": #itemSyuuso.lineWidth#," +
          "      \"lineColor\": \"#itemSyuuso.lineColor#\"," +
          "      \"color\": \"#FFFFFF\"," +
          "      \"dashStyle\": \"#itemSyuuso.lineType#\"," +
          "      \"marker\": {" +
          "        \"symbol\": \"#itemSyuuso.plotType#\"," +
          "        \"fillColor\": \"#itemSyuuso.plotFillColor#\"," +
          "        \"lineColor\": \"#itemSyuuso.plotLineColor#\"," +
          "        \"radius\": #itemSyuuso.plotSize#," +
          "        \"enabled\": true" +
          "      }," +
          "      \"dataLabels\": {" +
          "        \"enabled\": true," +
          "        \"style\":" +
          "        {" +
          "          \"fontWeight\": \"bold\"," +
          "          \"fontSize\": \"12px\"," +
          "          \"color\": \"#000000\"" +
          "        }," +
          "        \"align\": \"left\"," +
          "        \"verticalAlign\": \"middle\"" +
          "      }," +
          "      \"showInLegend\": false***@," +
          "      \"data\": " + syuusoDateList + "," +
          "      \"yAxis\": 1" +
          "    }" +
          "  ]" +
          "}" +
          "";
        listForDate.add(0, syuusoStrList);
      }
    } else {
      listForDate = new ArrayList();
      listForDate.add("");
      listForDate.add(null);
    }
    // mod #11232 #10515で入れた制限の見直し 房 start
//    listForDateValues = listForDate;
    return listForDate;
    // mod #11232 #10515で入れた制限の見直し 房 end
  }
  // add #6586 透析レポート：愁訴処置のプロットができない 王永吉 end

  /**
   * グラフ用のJsonテンプレート文字列の内容を置き換える
   * <code>prefix</code>が「"bpMax"」の場合、"#bp.max#"と"#bp.min#"に最大値及び最小値を設定する.
   * <code>reportGraphSetting</code>が<code>null</code>の場合、デフォルト値で置換する.
   * デフォルト値で置換する際は、{@link this#replaceDefaultReportGraphSetting(String, String)} で行う.
   *
   * @param template グラフ用のJsonテンプレート文字列
   * @param prefix 接頭語
   * @param reportGraphSetting 帳票グラフ設定
   * @return 置換したJsonテンプレート文字列
   */
  private String replaceGraphSetting(String template, String prefix, ReportGraphSetting reportGraphSetting) {
    if (reportGraphSetting == null) {
      return replaceDefaultReportGraphSetting(template, prefix);
    }
    // del #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 start
//    if (prefix.equals(ReportConstant.ReportGraph.PREFIX_BP_MAX) ||
//        prefix.startsWith(ReportConstant.ReportGraph.PREFIX_ITEM)) {
    // del #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 end
      // tickInterval(チックインターバル) を算出
      // 計算式 : (最大値 - 最小値) / 5
      Double decMax = reportGraphSetting.getMax() - reportGraphSetting.getMin();
      Double tickInterval = decMax / 5;
      // add 8071 治療方法のグラフ設定が反映されない 吉 start
      Double first = reportGraphSetting.getMin() != null ?  reportGraphSetting.getMin() : 0;
      String arrStr = ""+ first;
      for(int i = 1; i <= 5; i++){
        Double changeNum = first + tickInterval*i;
        arrStr+=","+ changeNum;
      }
      // add 8071 治療方法のグラフ設定が反映されない 吉 end
    // mod #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 start
    // String ketString = prefix.equals(ReportConstant.ReportGraph.PREFIX_BP_MAX) ? "bp" : prefix;
       String ketString = prefix.equals(ReportConstant.ReportGraph.PREFIX_BP_MAX) ||
       prefix.equals(ReportConstant.ReportGraph.PREFIX_BP_AVE) ||
       prefix.equals(ReportConstant.ReportGraph.PREFIX_BP_MIN) ? "bp" : prefix;
    // mod #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 end
      String labelsFormat = "{value:.1f}";
      template = template.replace(String.format("#%s.%s#", ketString, "max"), reportGraphSetting.getMax().toString())
        .replace(String.format("#%s.%s#", ketString, "min"), reportGraphSetting.getMin().toString())
        // mod 8071 治療方法のグラフ設定が反映されない 吉 start
        //.replace(String.format("#%s.%s#", ketString, "tickInterval"), tickInterval.toString())
        .replace(String.format("#%s.%s#", ketString, "tickPositioner"), arrStr)
        // mod 8071 治療方法のグラフ設定が反映されない 吉 end
        .replace(String.format("#%s.%s#", ketString, "labelsFormat"), isDecimal(tickInterval) ? labelsFormat : "");
    // del #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 start
    //    }
    // del #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 end
    // プロットを塗りつぶすか否か
    // ※プロットタイプの文字列の末尾が[-b]で終わっているか否かで判断する.
    boolean isFill = reportGraphSetting.getPlotType().endsWith("-b");
    // シンボル
    // ※塗りつぶしの場合、シンボル文字列の末尾に[-b]が付いているので除去する.
    String symbol = reportGraphSetting.getPlotType().replace("-b", "");
    // add 8071 治療方法のグラフ設定が反映されない 吉 start
    String name = "";
    String showName = "";
    if(null != reportGraphSetting.getName() && !reportGraphSetting.getName().contains("血圧<br><span")){
      name = subStringFun(reportGraphSetting.getName(),2);
      if(reportGraphSetting.getName().length()<=2){
        showName = "<span style='font-size:14px;color:#000000'>"+name+"</span>"+"<br>　　<br><span style='color:"+reportGraphSetting.getLineColor()+"'>"+changeshowShape(reportGraphSetting.getPlotType())+"</span>";
      }else{
        showName = "<span style='font-size:14px;color:#000000'>"+name+"</span>"+"<br><span style='color:"+reportGraphSetting.getLineColor()+"'>"+changeshowShape(reportGraphSetting.getPlotType())+"</span>";
      }
    }else{
      showName = "<span style='font-size:14px;color:#000000'>"+reportGraphSetting.getName()+"</span>";
    }
    // add 8071 治療方法のグラフ設定が反映されない 吉 end
    return
      template.replace(String.format("#%s.%s#", prefix, "enabled"), Boolean.TRUE.toString())
        // mod 8071 治療方法のグラフ設定が反映されない 吉 start
        // .replace(String.format("#%s.%s#", prefix, "itemName"), reportGraphSetting.getName())
        // mod #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 start
        //.replace(String.format("#%s.%s#", prefix, "itemName"), showName)
        .replace(String.format("#%s.%s#", prefix.equals("bpMax")||prefix.equals("bpAve")?"bpMin":prefix, "itemName"), showName)
        // mod #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 end
        // mod 8071 治療方法のグラフ設定が反映されない 吉 end
        .replace(String.format("#%s.%s#", prefix, "lineWidth"), reportGraphSetting.getLineThickness().toString())
        .replace(String.format("#%s.%s#", prefix, "lineColor"), reportGraphSetting.getLineColor())
        .replace(String.format("#%s.%s#", prefix, "lineType"), reportGraphSetting.getLineType())
        .replace(String.format("#%s.%s#", prefix, "plotType"), symbol)
        .replaceAll(String.format("#%s.%s#", prefix, "plotFillColor"), isFill ? reportGraphSetting.getPlotColor() : "#FFFFFF")
        .replaceAll(String.format("#%s.%s#", prefix, "plotLineColor"), reportGraphSetting.getPlotColor())
        .replace(String.format("#%s.%s#", prefix, "plotSize"), reportGraphSetting.getPlotSize().toString());
  }
  // add 8071 治療方法のグラフ設定が反映されない 吉 start
  public String changeshowShape(String plotType){
    Map<String,String>map = new HashMap<>();
    map.put("triangle","△　");
    map.put("triangle-b","▲　");
    map.put("triangle-down","▽　");
    map.put("triangle-down-b","▼　");
    map.put("square","□　");
    map.put("square-b","■　");
    map.put("diamond","◇　");
    map.put("diamond-b","◆　");
    map.put("circle","○　");
    map.put("circle-b","●　");
    map.put("double-circle","◎　");
    return map.get(plotType);
  }
  public static String subStringFun(String source, int length) {
    if(source.length()<=length){
      if(source.getBytes().length<6){
        source=source+"　";
      }
      return source;
    }else if(source.length() == 3 ){
      String name = "";
      if(source.substring(0,2).getBytes().length<6){
        name= source.substring(0,2) +"　<br>";
      }else{
        name= source.substring(0,2) +"<br>";
      }
      source = source.substring(2);
      if(source.getBytes().length<3){
        name = name + source+"　　";
      }else{
        name = name + source+"　";
      }
      return name;
    }else{
      source = source.substring(0,4);
      String name = "";
      if(source.substring(0,2).getBytes().length<6){
        name= source.substring(0,2) +"　<br>";
      }else{
        name= source.substring(0,2) +"<br>";
      }
      source = source.substring(2);
      if(source.getBytes().length<6){
        name = name + source+"　";
      }else{
        name = name + source;
      }
      return name;
    }
  }
  // add 8071 治療方法のグラフ設定が反映されない 吉 end

  /**
   * Jsonテンプレート内の置換文字列をデフォルト値で置換する.
   * 尚、置換するキーは、<code>prefix</code>を元に#prefix.XXX#の文字列を作成し置換する.
   * ※"XXX"は下記の通りとする.
   *
   *  max : "0"
   *  min : "0"
   *  tickInterval  : "0"
   *  itemName  : 空文字
   *  labelsFormat  : 空文字
   *  enabled : false
   *  lineWidth : "0"
   *  lineColor : 空文字
   *  lineType  : 空文字
   *  plotType  : 空文字
   *  plotFillColor : 空文字
   *  plotLineColor : 空文字
   *  plotSize  : "0"
   *
   * @param template グラフ用のJsonテンプレート文字列
   * @param prefix 接頭語
   * @return デフォルト値で置換したJsonテンプレート文字列
   */
  private String replaceDefaultReportGraphSetting(String template, String prefix) {
    return template.replace(String.format("#%s.%s#", prefix, "max"), "0")
      .replace(String.format("#%s.%s#", prefix, "min"), "0")
      // add 8071 治療方法のグラフ設定が反映されない 吉 start
      .replace(String.format("#%s.%s#", prefix, "tickPositioner"), "")
      // add 8071 治療方法のグラフ設定が反映されない 吉 end
      .replace(String.format("#%s.%s#", prefix, "tickInterval"), "0")
      .replace(String.format("#%s.%s#", prefix, "itemName"), "")
      .replace(String.format("#%s.%s#", prefix, "labelsFormat"), "")
      .replace(String.format("#%s.%s#", prefix, "enabled"), Boolean.FALSE.toString())
      .replace(String.format("#%s.%s#", prefix, "lineWidth"), "0")
      .replace(String.format("#%s.%s#", prefix, "lineColor"), "")
      .replace(String.format("#%s.%s#", prefix, "lineType"), "")
      .replace(String.format("#%s.%s#", prefix, "plotType"), "")
      .replaceAll(String.format("#%s.%s#", prefix, "plotFillColor"), "")
      .replaceAll(String.format("#%s.%s#", prefix, "plotLineColor"), "")
      .replace(String.format("#%s.%s#", prefix, "plotSize"), "0");
  }

  /**
   * 与えられた<code>monitorItemCd</code>が最高血圧、最低血圧、平均血圧かを判断する.
   *
   * @param monitorItemCd 判断するモニタ項目コード
   * @return true : 最高血圧、最低血圧、平均血圧の場合
   *         false : それ以外
   */
  private boolean isBp(String monitorItemCd) {
    return (ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_AVE.equals(monitorItemCd) ||
            ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_MAX.equals(monitorItemCd) ||
            ReportConstant.ReportGraph.MONITOR_ITEM_CD_BP_MIN.equals(monitorItemCd));
  }

  /**
   * <code>value</code>が小数値か判断する.
   * 1.0 の場合、整数値と判断する.
   *
   * @param value 検証する値
   * @return true : 小数値
   *         false : 整数値
   */
  private boolean isDecimal(Double value) {
    String strValue = String.valueOf(value);
    return !strValue.matches("^.*\\.0+$");
  }

  /**
   * グラフの開始日時を取得する.
   * 取得したモニタデータ以外
   *
   * @param dateList 発生日時のリスト
   * @param rstStartDate オーダの実績の治療開始日時
   * @return 開始日時
   */
  private long getStartTime(List<Timestamp> dateList, Timestamp rstStartDate) {
    if (!dateList.isEmpty()) {
      return getStandardStartTime(dateList.get(0).getTime());
    }
    return rstStartDate == null ? 0L : getStandardStartTime(rstStartDate.getTime());
  }

  /**
   * 指定された開始時間の基準とする日時を取得する.
   *
   * @param startTime 開始時間
   * @return 基準とする開始時間
   */
  private long getStandardStartTime(long startTime) {
    final long xAxisUnit = 30 * 60 * 1000; // 30分ごと
    return ((startTime / xAxisUnit) * xAxisUnit);
  }

  /**
   *
   * @param dateList
   * @return
   */
  private long getEndTime(List<Timestamp> dateList) {
    // mod #10515 shiyw start
    // return dateList.isEmpty() ? dateList.get(dateList.size() - 1).getTime() : 0L;
    return !dateList.isEmpty() ? dateList.get(dateList.size() - 1).getTime() : 0L;
    // mod #10515 shiyw end
  }

  /**
   * オーダ番号に該当するグラフ時間軸を取得する.
   * @param ordNo オーダ番号
   * @return グラフ時間軸
   */
  private Integer getGraphTimeScale(Long ordNo) {
    try {
      // 治療方法マスタを取得し、グラフ時間軸を返す
      if(null != treatmentRecordDao.selectMstTreatmentByOrdNo(ordNo)){
        return treatmentRecordDao.selectMstTreatmentByOrdNo(ordNo).getGraphTimeScale();
      }else{
        return 6;
      }

    } catch (EmptyResultDataAccessException e) {
      // 取得に失敗したらデフォルト値を返す
      return GRAPH_TIME_SCALE_DEFAULT;
    }
  }

  /**
   * グラフ生成時に使用するスクリプトファイルパスを生成する.
   *
   * @return スクリプトの文字列
   */
  private String getScript() {
    String script;
    try {
      URL url = resourceLoader.getResource("classpath:report/chart/chart-symbol.js").getURL();
      try (
        InputStream is = url.openStream();
        ByteArrayOutputStream os = new ByteArrayOutputStream();) {

        byte[] buffer = new byte[1024];
        int len = is.read(buffer);
        while (len >= 0) {
          os.write(buffer, 0, len);
          len = is.read(buffer);
        }
        script = new String(os.toByteArray(), StandardCharsets.UTF_8);
      }
    }  catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      return "";
    }
    return script;
  }

  /**
   * 時間スケールにおけるグラフ幅を取得する.
   * 時間スケールがnullの場合、1200を返却する.
   * また、時間スケールが6/8/10以外の場合、1200を返却する.
   *
   * @param graphTimeScale 時間スケール（6/8/10）
   * @return 時間スケールにおけるグラフ幅
   */
  // mod 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 start
//  private Integer getChartWidth(Integer graphTimeScale) {
//    // 初期のグラフ幅
//    Integer chartWidth = 1200;
//    // 引数がnullの場合
//    if (graphTimeScale == null) {
//      return chartWidth;
//    }
//    if (graphTimeScale.equals(8)) {
//      chartWidth = 1500;
//    } else if (graphTimeScale.equals(10)) {
//      chartWidth = 1800;
//    } else {
//      chartWidth = 1200;
//    }
//    return chartWidth;
//  }
  private Integer getChartWidth(Integer count,Integer graphTimeScale,String colWidth) {
    // 初期のグラフ幅
    Integer chartWidth = Integer.valueOf(colWidth);
    Integer contSize = 45;
    // 引数がnullの場合
    if (graphTimeScale == null) {
      return chartWidth;
    }
    if (graphTimeScale.equals(6) && count.equals(1)) {
      chartWidth = 560;
    } else {
      chartWidth = graphTimeScale * 2 * contSize + count * 30;
    }
    return chartWidth;
  }
  // mod 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 end

  /**
   * {@link SysMonitorItemDao}
   */
  @Autowired
  private SysMonitorItemDao sysMonitorItemDao;

  /**
   * 表示するモニタ項目数の最大個数
   */
  private static final Integer MAX_MONITOR_ITEM = 13 ;

  /**
   * オーダ番号の治療方法に登録されているトレンドグラフに出力するモニタ項目のリストを取得する.
   * また、第2引数で最大取得件数が指定されている場合、最大取得件数を超えるモニタ項目数が
   * 治療方法マスタのトレンドグラフモニタ項目が登録されている場合、最大取得件数を超えるモニタ項目は除外する.
   * ※最大取得項目数にnullを指定した場合、治療方法マスタのトレンドグラフモニタ項目に登録されている全ての
   *   モニタ項目のリストを返す.
   * 以下の場合、空のリストを返却する.
   *   ・治療方法が未設定の場合
   *   ・治療方法のトレンドグラフのモニタ項目が未登録の場合
   *
   * @param ordNo オーダ番号
   * @param maxCount 最大取得件数(nullの場合は治療方法マスタに登録されているモニタ項目全て)
   * @return 出力するモニタ項目のリスト
   */
  private List<SysMonitorItem> getSysMonitorItemList(Long ordNo, Integer maxCount) {
    // 返却用
    List<SysMonitorItem> sysMonitorItemList = new LinkedList<>();
    // add 2020-09-21 FNSI-仕様追加 出力データなしの場合に帳票も表示する 夏 start
    try {
    // add 2020-09-21 FNSI-仕様追加 出力データなしの場合に帳票も表示する 夏 end
      // オーダ番号に紐づく治療方法マスタを取得
      // mod #11737 グラフがセルサイズにフィットしないときがある 房 start
      // MstTreatment mstTreatment = treatmentRecordDao.selectMstTreatmentByOrdNo(ordNo);
      MstTreatment mstTreatment =  ordMainDao.selectMstTreatmentByOrdNo(ordNo);
      // mod #11737 グラフがセルサイズにフィットしないときがある 房 end
      // 治療方法マスタが取得できない場合
      if (mstTreatment == null) {
        return sysMonitorItemList;
      }

      // 治療方法マスタから印刷するモニタ項目を取得
      String strPrintMonitorItem = mstTreatment.getMonitorDataItemPrint();
      // 治療方法マスタに出力するモニタ項目が未設定もしくは空の場合
      if (strPrintMonitorItem == null || strPrintMonitorItem.length() == 0) {
        return sysMonitorItemList;
      }
      // add #11786 【因島】ΔBVの値表示が機器切り替えに対応できていない 吉 start
      SysMonitorItem sys17 = new SysMonitorItem();
      sys17.setMoniDataNo("17");
      List<SysMonitorItem>List17 = new ArrayList<>();
      List17.add(sys17);
      List<MniMonitor> mon17 = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, List17, Collections.EMPTY_LIST,mstTreatment.getFacilityCd());

      SysMonitorItem sys100 = new SysMonitorItem();
      sys100.setMoniDataNo("100");
      List<SysMonitorItem>List100 = new ArrayList<>();
      List100.add(sys100);
      List<MniMonitor> mon100 = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, List100, Collections.EMPTY_LIST,mstTreatment.getFacilityCd());
      // add #11786 【因島】ΔBVの値表示が機器切り替えに対応できていない 吉 end
      // add #12678 【因島】ΔBVの値表示に関する再調整 zhao start
      String displayKbn = setDisplayKbn(mon17, mon100);
      // add #12678 【因島】ΔBVの値表示に関する再調整 zhao end
      // 治療方法マスタに登録されている印刷するモニタ項目コードのリストを作成
      JSONArray jsonArray = new JSONArray(strPrintMonitorItem);
      jsonArray.forEach(dispMoniItem -> {
        // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 start
//        String moniDataNo = (String)((JSONObject)dispMoniItem).get("moni_data_no");
//        SysMonitorItem sysMonitorItem = sysMonitorItemDao.selectByMoniDataNo(moniDataNo);
//        if (sysMonitorItem != null) {
//          sysMonitorItemList.add(sysMonitorItem);
//        }
        SysMonitorItem sysMonitorItem = new SysMonitorItem();
        String moniDataNo = String.valueOf(((JSONObject)dispMoniItem).get("moni_data_no"));
        // mod #11786 【因島】ΔBVの値表示が機器切り替えに対応できていない 吉 start
        // sysMonitorItem = sysMonitorItemDao.selectByMoniDataNo(moniDataNo);
        // mod #12678 【因島】ΔBVの値表示に関する再調整 zhao start
        //if("100".equals(moniDataNo) && (null == mon100 || mon100.size() == 0)){
        if("100".equals(moniDataNo) && "17".equals(displayKbn)){
          // mod #12678 【因島】ΔBVの値表示に関する再調整 zhao end
          sysMonitorItem = sysMonitorItemDao.selectByMoniDataNo("17");
          // mod #12678 【因島】ΔBVの値表示に関する再調整 zhao start
        //}else if("17".equals(moniDataNo) && (null == mon17 || mon17.size() == 0)){
        }else if("17".equals(moniDataNo) && "100".equals(displayKbn)){
          // mod #12678 【因島】ΔBVの値表示に関する再調整 zhao end
          sysMonitorItem = sysMonitorItemDao.selectByMoniDataNo("100");
        }else{
          sysMonitorItem = sysMonitorItemDao.selectByMoniDataNo(moniDataNo);
        }
        // mod #11786 【因島】ΔBVの値表示が機器切り替えに対応できていない 吉 end
        if (sysMonitorItem != null) {
            sysMonitorItemList.add(sysMonitorItem);
          } else {
            MstAddMonitor addMonitor = new MstAddMonitor();
            // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 start
            // addMonitor = mstAddMonitorDao.selectByMonitorItemName(mstTreatment.getFacilityCd(),Integer.valueOf(moniDataNo));
            addMonitor = mstAddMonitorDao.selectByMonitorItemName(mstTreatment.getFacilityCd(), moniDataNo);
            // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 end
            if (addMonitor != null) {
              sysMonitorItem = new SysMonitorItem();
              sysMonitorItem.setMoniDataName(addMonitor.getVitalMonitorItemName());
              sysMonitorItem.setUnit("");
              //add #10077 by zhangruixue 2024-1-17  start
              sysMonitorItem.setMoniDataNo(String.valueOf(addMonitor.getVitalMonitorItemCd() + 10000));
              //add #10077 by zhangruixue 2024-1-17  end
              sysMonitorItemList.add(sysMonitorItem);
            }
          }
        // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 end
      });
      // 登録件数が最大個数を超えている場合、超えている分を削除する
      if (maxCount != null && sysMonitorItemList.size() > maxCount) {
        sysMonitorItemList.subList(maxCount, sysMonitorItemList.size()).clear();
      }
      return sysMonitorItemList;
    // add 2020-09-21 FNSI-仕様追加 出力データなしの場合に帳票も表示する 夏 start
    }catch (Exception e){
      return sysMonitorItemList;
    }
    // add 2020-09-21 FNSI-仕様追加 出力データなしの場合に帳票も表示する 夏 end
  }

  /**
   * 渡されたモニタ項目リストの結果を取得する.
   * 渡されたモニタ項目リストの何れかのモニタ項目データ値が登録されている場合は、その発生日時でマップに格納する.
   * ※発生日時で登録されていないモニタ項目データ値は空文字を設定する.
   *
   * @param ordNo オーダ番号
   * @param sysMonitorItemList 取得するモニタ項目のリスト
   * @param dataTypeList 取得するデータタイプのリスト
   * @return 発生日時毎のモニタデータのマップ
   *         key : 発生日時(Timestamp)
   *         value :
   *           key : モニタ項目コード
   *           value : モニタ項目データ値
   *                   ※発生日時にモニタ項目データがない場合、モニタ項目データ値は空文字を設定する.
   *                     また、変換項目が登録されている場合には、変換した値を設定する.
   */
  // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 start
  // private Map<Timestamp, Map<String, String>> getMonitorData(Long ordNo, List<SysMonitorItem> sysMonitorItemList, List<Short> dataTypeList) {
  // mod 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 start
  // private Map<Timestamp, Map<String, String>> getMonitorDataForMonitor(Long ordNo, List<SysMonitorItem> sysMonitorItemList, List<Short> dataTypeList) {
  private Map<Timestamp, Map<String, String>> getMonitorDataForMonitor(Long ordNo, List<SysMonitorItem> sysMonitorItemList, List<Short> dataTypeList,String facilityCd) {
    // mod 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 end
  // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 end
    // モニタデータ取得
    // mod 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 start
    // List<MniMonitor> mniMonitorList = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, sysMonitorItemList, dataTypeList);
    List<MniMonitor> mniMonitorList = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, sysMonitorItemList, dataTypeList,facilityCd);
    // mod 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 end
    // 列データのマップ
    Map<Timestamp, Map<String, String>> colDataMap = new LinkedHashMap<>();

    for (MniMonitor mniMonitor : mniMonitorList) {
      String monitorData = mniMonitor.getMonitorData();
      Map<String,Object> map = convertJsonToMap(monitorData);
      if (map == null) {
        // Json文字列からマップへの変換に失敗
        continue;
      }
      // 項目毎の値を格納するマップ
      Map<String, String> itemMap = new LinkedHashMap<>();
      colDataMap.put(mniMonitor.getOccurDate(), itemMap);
      for (SysMonitorItem sysMonitorItem : sysMonitorItemList) {
        String mniDataNo = sysMonitorItem.getMoniDataNo();
        // モニタデータに取得するモニタ項目番号のデータが含まれていない
        if (!map.containsKey(mniDataNo)) {
          // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 start
          // itemMap.put(sysMonitorItem.getMoniDataName(), "");
          if (map.containsKey(sysMonitorItem.getMoniDataName())) {
            itemMap.put(sysMonitorItem.getMoniDataName(), String.valueOf(map.get(sysMonitorItem.getMoniDataName())));
          } else {
            itemMap.put(sysMonitorItem.getMoniDataName(), "");
          }
          // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 end
          continue;
        }
        // mod #7868 コンバータされた施設の透析レポートが表示できない 鄭爽　start
        // String value = Objects.requireNonNull(map).get(mniDataNo).toString();
        String value = null;
        if (!"".equals(Objects.requireNonNull(map).get(mniDataNo)) && Objects.requireNonNull(map).get(mniDataNo) != null) {
          value = Objects.requireNonNull(map).get(mniDataNo).toString();
        }
        // mod #7868 コンバータされた施設の透析レポートが表示できない 鄭爽　end
        // 変換項目が設定されている場合
        if (sysMonitorItem.getConvItem() != null) {
          ObjectMapper mapper = new ObjectMapper();
          Map<String, String> convItemMap = null;
          try {
            convItemMap = mapper.readValue(sysMonitorItem.getConvItem(), new TypeReference<Map<String, String>>(){});
          } catch (JacksonException e) {
            // 変換項目のJSONの読込に失敗した場合は変換は行わない.
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (!StringUtils.isEmpty(facilityCd)) {
              eventLogMessage.setFacilityCd(facilityCd);
            }
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
          }
          if (convItemMap != null && convItemMap.containsKey(value)) {
            value = convItemMap.get(value);
          }
        }
        itemMap.put(sysMonitorItem.getMoniDataName(), value == null ? "" : value);
      }
    }
    return colDataMap;
  }

  // add #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 start
  // mod 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 start
  // private Map<Timestamp, Map<String, String>> getMonitorDataForBaitaru(Long ordNo, List<SysMonitorItem> sysMonitorItemList, List<Short> dataTypeList) {
  private Map<Timestamp, Map<String, String>> getMonitorDataForBaitaru(Long ordNo,
              List<SysMonitorItem> sysMonitorItemList, List<Short> dataTypeList,String facilityCd) {
    // mod 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 end
    // モニタデータ取得
    // mod 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 start
    // List<MniMonitor> mniMonitorList = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, sysMonitorItemList, dataTypeList);
    // mod #11897 治療経過表のグラフ出力が要求通りではない 高 start
//    List<MniMonitor> mniMonitorList = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo,
//      sysMonitorItemList, dataTypeList,facilityCd);
    List<MniMonitor> mniMonitorList = mniMonitorDao.selectMonitorDataByMoniDataNoAll(ordNo, dataTypeList,facilityCd);
    // mod #11897 治療経過表のグラフ出力が要求通りではない 高 end
    // mod 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 end
    // add #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 start
    List<MniMonitor> mniMonitorListSub = new ArrayList<>();
    MniMonitor mni = new MniMonitor();
    String strMonitorData = "";
    for (int i = 0; i < mniMonitorList.size(); i++) {
      mni = mniMonitorList.get(i);
      if (i != mniMonitorList.size() - 1) {
        // mod #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
        // if (mniMonitorList.get(i).getOccurDate().compareTo(mniMonitorList.get(i + 1).getOccurDate())==0) {
        if (mniMonitorList.get(i).getOccurDate().compareTo(mniMonitorList.get(i + 1).getOccurDate())==0
        && mniMonitorList.get(i).getDataType() == mniMonitorList.get(i + 1).getDataType()) {
          // mod #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
          strMonitorData = mni.getMonitorData().substring(0,mni.getMonitorData().length() - 1);
        } else {
          if (!"".equals(strMonitorData)) {
            strMonitorData = strMonitorData + ", " + mni.getMonitorData().substring(1, mni.getMonitorData().length());
          } else {
            strMonitorData = mni.getMonitorData();
          }
          mni.setMonitorData(strMonitorData);
          mniMonitorListSub.add(mni);
          strMonitorData = "";
        }
      } else {
        if (!"".equals(strMonitorData)) {
          strMonitorData = strMonitorData + ", " + mni.getMonitorData().substring(1, mni.getMonitorData().length());
        } else {
          strMonitorData = mni.getMonitorData();
        }
        mni.setMonitorData(strMonitorData);
        mniMonitorListSub.add(mni);
      }
    }
    mniMonitorList = mniMonitorListSub;
    // add #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 end
    // 列データのマップ
    Map<Timestamp, Map<String, String>> colDataMap = new LinkedHashMap<>();

    for (MniMonitor mniMonitor : mniMonitorList) {
      String monitorData = mniMonitor.getMonitorData();
      Map<String,Object> map = convertJsonToMap(monitorData);
      if (map == null) {
        // Json文字列からマップへの変換に失敗
        continue;
      }
      // 項目毎の値を格納するマップ
      Map<String, String> itemMap = new LinkedHashMap<>();
      colDataMap.put(mniMonitor.getOccurDate(), itemMap);
      for (SysMonitorItem sysMonitorItem : sysMonitorItemList) {
        // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
        if((sysMonitorItem.getVitalMonitorClass().equals("1") && mniMonitor.getDataType() == 2)
          ||(sysMonitorItem.getVitalMonitorClass().equals("1") && mniMonitor.getDataType() == 3)
          ||(sysMonitorItem.getVitalMonitorClass().equals("1") && mniMonitor.getDataType() == 4)
          ||(sysMonitorItem.getVitalMonitorClass().equals("1") && mniMonitor.getDataType() == 5)
          ||(sysMonitorItem.getVitalMonitorClass().equals("1") && mniMonitor.getDataType() == 6)
          || (sysMonitorItem.getVitalMonitorClass().equals("2") && mniMonitor.getDataType() == 1)){
          // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
          String mniDataNo = sysMonitorItem.getMoniDataNo();
          // モニタデータに取得するモニタ項目番号のデータが含まれていない
          if (!map.containsKey(mniDataNo)) {
            // itemMap.put(sysMonitorItem.getMoniDataName(), "");
            if (map.containsKey(sysMonitorItem.getMoniDataName())) {
              itemMap.put(mniDataNo, String.valueOf(map.get(sysMonitorItem.getMoniDataName())));
            } else {
              itemMap.put(mniDataNo, "");
            }
            continue;
          }
          // String value = Objects.requireNonNull(map).get(mniDataNo).toString();
          String value = null;
          if (!"".equals(Objects.requireNonNull(map).get(mniDataNo)) && Objects.requireNonNull(map).get(mniDataNo) != null) {
            value = Objects.requireNonNull(map).get(mniDataNo).toString();
          }
          // 変換項目が設定されている場合
          if (sysMonitorItem.getConvItem() != null) {
            ObjectMapper mapper = new ObjectMapper();
            Map<String, String> convItemMap = null;
            try {
              convItemMap = mapper.readValue(sysMonitorItem.getConvItem(), new TypeReference<Map<String, String>>(){});
            } catch (JacksonException e) {
              // 変換項目のJSONの読込に失敗した場合は変換は行わない.
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (!StringUtils.isEmpty(facilityCd)) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
            }
            if (convItemMap != null && convItemMap.containsKey(value)) {
              value = convItemMap.get(value);
            }
          }
          itemMap.put(mniDataNo, value == null ? "" : value);
          // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
        }
        // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
      }
    }
    return colDataMap;
  }
  // add #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 end





  /**
   * 与えられたJson文字列をマップに変換する.
   *
   * @param json JSON文字列
   * @return json文字列から生成したマップM
   */
  private Map<String, Object> convertJsonToMap(String json) {
    // Objectマッパーのインスタンス生成
    ObjectMapper mapper = new ObjectMapper();
    // 変換先のマップの型指定
    TypeReference<Map<String, Object>> reference = new TypeReference<Map<String, Object>>() {};
    try {
      // Map生成
      return mapper.readValue(json, reference);
    } catch (Exception e) {
      // JSONパース失敗時はnullを返す
    }
    return null;
  }

  /**
   * htmlから指定された画像ファイルを作成し、作成した画像ファイルのバイト配列のリストを作成する.
   *
   * @param htmlList 画像出力するhtmlのリスト
   * @param type 出力する画像の拡張子
   * @return
   */
  // mod 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 start
  // private List<byte[]> createImageToByteArray(List<String> htmlList, ChartImageType type) {
  private List<byte[]> createImageToByteArray(List<String> htmlList, ChartImageType type,Integer chartWidth) {
    // mod 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 end
    // 拡張子
    String ext = type.toString().toLowerCase();
    // HTML一時保存ファイルパス
    Path htmlPath = null;
    // 画像一時保存ファイルパス
    Path imagePath = null;
    // 返却用
    List<byte[]> result = new LinkedList<>();
    for (String html : htmlList) {
      try{
        // HTMLデータを一時ファイルに保存
        htmlPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".html");
        Files.write(htmlPath, html.getBytes(StandardCharsets.UTF_8));
        imagePath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", "." + ext);

        // HTMLからイメージファイル生成
        // mod 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 start
//        String[] command = {
//          "wkhtmltoimage",
//          "--width 840",
//          "--encoding",
//          "utf-8",
//          htmlPath.toString(),
//          imagePath.toString()
//        };
        String command = "wkhtmltoimage --load-error-handling ignore --encoding utf-8  --width  "+ chartWidth +" "+ htmlPath.toString() +" "+imagePath.toString();
        // mod 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 end
        Runtime rt = Runtime.getRuntime();
        int resultExecCommand = rt.exec(command).waitFor();
        if (resultExecCommand == 0) {
          // 生成したイメージをBase64に変換
          byte[] imageByteArray = Files.readAllBytes(imagePath);
          result.add(imageByteArray);
        } else {
          // wkhtmltoimageの実行に失敗した
          throw new IOException("wkhtmltoimage failed:" + resultExecCommand);
        }
      } catch (IOException | InterruptedException e) {
        throw new NtssException("帳票のモニタデータの画像ファイルの出力に失敗しました。");
      } catch (Exception e) {
        throw new NtssException("帳票のモニタデータの画像ファイルの出力に失敗しました。");
      } finally {
        // 一時ファイルを削除
        Optional.ofNullable(htmlPath).ifPresent(path -> path.toFile().delete());
        Optional.ofNullable(imagePath).ifPresent(path -> path.toFile().delete());
      }
    }
    return result;
  }

  /**
   * 治療開始日時を基準にscaleで設定された時間分（30分間隔)の開始日時と終了日時を算出し、マップを作成する.
   * 治療終了日時が設定されている場合で、scaleを元に作成した最終終了日時より未来日時の場合は、scaleの値を2倍に増幅させ
   * マップを作成する.
   * 治療開始日がnullの場合、空の配列を返す.
   *
   * @param rstStartDate 治療開始日時
   * @param rstEndDate 治療終了日時
   * @param scale 治療方法マスタに登録されているスケール
   * @return
   */
  private List<Map<LocalDateTime, LocalDateTime>> createScaleDateTimeMap(Timestamp rstStartDate, Timestamp rstEndDate, Integer scale) {
    // 治療開始日時未登録
    if (rstStartDate == null) {
      return new LinkedList<>();
    }
    // 治療終了日時のローカル変数
    LocalDateTime endDate = null;
    // 治療開始日時の秒数をゼロとする
    LocalDateTime startDate = rstStartDate.toLocalDateTime().withSecond(0);
    // 出力数の初期化
    int loopCount = 1;
    if (rstEndDate != null) {
      // 治療終了日時が設定されている場合、ローカル変数に設定
      endDate = rstEndDate.toLocalDateTime().withSecond(59);
      // 治療開始日時と治療終了日時から差分(時間)を計算する.
      Duration d = Duration.between(startDate, endDate);
      // long → int に型変換を行っているが、治療開始日と治療終了日の差分である為、
      // intの最大値を超える事はない.
      // Integer diffHours = new Integer((int)d.toHours());
      Long diffMinutes = d.toMinutes();
      // スケールを分に換算
      Integer scaleToMinutes = scale * 60;
      if (diffMinutes > scaleToMinutes) {
        // 切上げ
        int tempRoopCount = (int)Math.ceil((double)diffMinutes / (double)scaleToMinutes);
        loopCount = tempRoopCount;
      }
    }

    // ページ毎の期間マップを保持するリスト
    List<Map<LocalDateTime, LocalDateTime>> pageList = new LinkedList<>();
    // 治療開始日時を退避
    LocalDateTime tempLocalDateTime = startDate;
    for (int index1 = 0; index1 < loopCount; index1++) {
      // 開始日時と終了日時を格納するアップ
      Map<LocalDateTime, LocalDateTime> scaleMap = new LinkedHashMap<>();
      for (int idx = 0; idx < scale * 2; idx++) {
        // mod #7822 透析記録用紙の血圧グラフ，トレンドデータの不正 姜 start
        // scaleMap.put(tempLocalDateTime, tempLocalDateTime.plusMinutes(30).withSecond(59));
        scaleMap.put(tempLocalDateTime, tempLocalDateTime.plusMinutes(29).withSecond(59));
        // mod #7822 透析記録用紙の血圧グラフ，トレンドデータの不正 姜 end
        // mod #7822 透析記録用紙の血圧グラフ，トレンドデータの不正 王永吉 start
//        tempLocalDateTime = tempLocalDateTime.plusMinutes(31);
        // mod #8120 治療経過表のトレンドグラフ画像の表部分が表示いない。 姜 start
        //　tempLocalDateTime = tempLocalDateTime.plusMinutes(30);
        // mod #7822 透析記録用紙の血圧グラフ，トレンドデータの不正 姜 start
        // tempLocalDateTime = tempLocalDateTime.plusMinutes(29);
        tempLocalDateTime = tempLocalDateTime.plusMinutes(30);
        // mod #7822 透析記録用紙の血圧グラフ，トレンドデータの不正。 姜 end
        // mod #8120 治療経過表のトレンドグラフ画像の表部分が表示いない。 姜 end
        // mod #7822 透析記録用紙の血圧グラフ，トレンドデータの不正 王永吉 end
      }
      pageList.add(deepCopy(scaleMap));
    }
    return pageList;
  }

  /**
   * 与えられたマップをディープコピーする.
   *
   * @param target コピー元のマップ
   * @return ディープコピーしたマップ
   */
  private Map<LocalDateTime, LocalDateTime> deepCopy(Map<LocalDateTime, LocalDateTime> target) {
    // コピーするマップ
    Map<LocalDateTime, LocalDateTime> copyMap = new LinkedHashMap<>();
    target.keySet().stream().forEach(k -> {
      copyMap.put(k, target.get(k));
    });
    return copyMap;
  }

  /**
   * <code>ordNo</code>の実績情報に関する治療方法マスタに登録されている帳票グラフ設定を取得する.
   * 実績情報に治療方法コードが指定されていない場合、指示情報の治療方法マスタに登録されてい帳票グラフ設定を取得する.
   *
   * @param ordNo オーダ番号
   * @return オーダ番号に該当する帳票グラフ設定
   */
  private List<ReportGraphSetting> getReportGraphSettingByOrdNo(Long ordNo) {
    // モニタ項目を取得
    List<SysMonitorItem> sysMonitorItemList = sysMonitorItemDao.selectAll();
    // オーダ番号からオーダメインを取得
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    // add FNSI-改修内容#6023 周 start
    if(null == ordMain) {
      return new ArrayList<>();
    }
    // add #11786 【因島】ΔBVの値表示が機器切り替えに対応できていない 吉 start
    SysMonitorItem sys17 = new SysMonitorItem();
    sys17.setMoniDataNo("17");
    List<SysMonitorItem>List17 = new ArrayList<>();
    List17.add(sys17);
    List<MniMonitor> mon17 = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, List17, Collections.EMPTY_LIST,ordMain.getFacilityCd());

    SysMonitorItem sys100 = new SysMonitorItem();
    sys100.setMoniDataNo("100");
    List<SysMonitorItem>List100 = new ArrayList<>();
    List100.add(sys100);
    List<MniMonitor> mon100 = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, List100, Collections.EMPTY_LIST,ordMain.getFacilityCd());
    // add #11786 【因島】ΔBVの値表示が機器切り替えに対応できていない 吉 end
    // add #12678 【因島】ΔBVの値表示に関する再調整 zhao start
    String displayKbn = setDisplayKbn(mon17, mon100);
    // add #12678 【因島】ΔBVの値表示に関する再調整 zhao end
    // add FNSI-改修内容#6023 周 end
    // バイタルモニタ項目を取得
    List<MstAddMonitor> mstAddMonitorList = mstAddMonitorDao.selectAllByFacilityCd(ordMain.getFacilityCd());
    // add #9312 治療状況リスト，マップの表示が不正 房 start
    if(mstAddMonitorList != null && mstAddMonitorList.size() > 0) {
      mstAddMonitorList.stream().forEach(el -> {
        el.setVitalMonitorItemCd(el.getVitalMonitorItemCd() + 10000);
      });
    }
    // add #9312 治療状況リスト，マップの表示が不正 房 end
    // オーダ番号に登録されている治療方法マスタを取得する.
    MstTreatment mstTreatment = ordMainDao.selectMstTreatmentByOrdNo(ordNo);
    // 治療方法未指定または、オーダ番号に該当するオーダが存在しない場合
    // mod redmain #4822 鄧シン start
    // if (mstTreatment == null || mstTreatment.getReportGraphSetting() == null) {
    //   return Collections.emptyList();
    if (mstTreatment == null) {
      mstTreatment = new MstTreatment();
      mstTreatment.setReportGraphSetting(ApiConstant.DEFAULT_JSON_DATA);
    } else if (mstTreatment.getReportGraphSetting() == null){
      mstTreatment.setReportGraphSetting(ApiConstant.DEFAULT_JSON_DATA);
    }
    // mod redmain #4822 鄧シン end
    // 返却用のリスト
    List<ReportGraphSetting> reportGraphSettingList = new ArrayList<>();
    // 帳票グラフ設定のjson文字列を分解
    try {
      // オブジェクトマッパー
      ObjectMapper mapper = new ObjectMapper().rebuild()
          .propertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE)
          .build();
      JSONArray jsonArray = new JSONArray(mstTreatment.getReportGraphSetting());
      // add #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
      ReportGraphSetting graphSetting17 = null;
      ReportGraphSetting graphSetting100 = null;
      for (int i = 0; i < jsonArray.length(); i++) {
        JSONObject obj = jsonArray.getJSONObject(i);
        String cdInJson = obj.optString("cd", "");
        if ("17".equals(cdInJson) && graphSetting17 == null) {
          graphSetting17 = mapper.readValue(obj.toString(), ReportGraphSetting.class);
        } else if ("100".equals(cdInJson) && graphSetting100 == null) {
          graphSetting100 = mapper.readValue(obj.toString(), ReportGraphSetting.class);
        }
      }
      final ReportGraphSetting setting17 = graphSetting17;
      final ReportGraphSetting setting100 = graphSetting100;
      // add #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
      jsonArray.forEach(j -> {
        try {
          ReportGraphSetting entity = mapper.readValue(j.toString(), ReportGraphSetting.class);
          // add #11786 【因島】ΔBVの値表示が機器切り替えに対応できていない 吉 start
          String itCd = entity.getCd();
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
//          if("100".equals(itCd)){
//            // mod #12678 【因島】ΔBVの値表示に関する再調整 zhao start
//            //if((null == mon100 || mon100.size()==0) && null != mon17){
//            if("17".equals(displayKbn)){
//              // mod #12678 【因島】ΔBVの値表示に関する再調整 zhao end
//              itCd = "17";
//              entity.setCd("17");
//            }
//          }else if("17".equals(itCd)){
//            // mod #12678 【因島】ΔBVの値表示に関する再調整 zhao start
//            //if((null == mon17 || mon17.size()==0) && null != mon100){
//            if("100".equals(displayKbn)){
//              // mod #12678 【因島】ΔBVの値表示に関する再調整 zhao end
//              itCd = "100";
//              entity.setCd("100");
//            }
//          }
          if ("100".equals(itCd) && "17".equals(displayKbn) && setting17 != null) {
            entity = mapper.readValue(mapper.writeValueAsString(setting17), ReportGraphSetting.class);
            itCd = entity.getCd();
          } else if ("17".equals(itCd) && "100".equals(displayKbn) && setting100 != null) {
            entity = mapper.readValue(mapper.writeValueAsString(setting100), ReportGraphSetting.class);
            itCd = entity.getCd();
          }
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
          // add #11786 【因島】ΔBVの値表示が機器切り替えに対応できていない 吉 end
          // モニタ項目名称を設定
          Integer type = entity.getType();
          // mod #11786 【因島】ΔBVの値表示が機器切り替えに対応できていない 吉 start
          String cd = itCd;
          // mod #11786 【因島】ΔBVの値表示が機器切り替えに対応できていない 吉 end
          String name = "";
          // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
          String dataType = "";
          // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
          if (type != null && type.equals(1)) {
            Optional<SysMonitorItem> item = sysMonitorItemList.stream().filter(s -> s.getMoniDataNo().equals(cd)).findFirst();
            name = item.get() != null ? item.get().getMoniDataShortName() : "不明";
            // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
            dataType = item.get() != null ? item.get().getVitalMonitorClass() : "";
            // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
          } else if (type != null && type.equals(2)) {
            Optional<MstAddMonitor> item = mstAddMonitorList.stream().filter(m -> m.getVitalMonitorItemCd().toString().equals(cd)).findFirst();
            name = item.get() != null ? item.get().getVitalMonitorItemName() : "不明";
            // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
            dataType = item.get() != null ? item.get().getVitalMonitorClass() : "";
            // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
          }
          entity.setName(name);
          // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
          entity.setDataType(dataType);
          // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
          // mod #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 start
          // reportGraphSettingList.add(entity);
          if(cd.equals("90") || cd.equals("91") || cd.equals("92")){
            if(null == entity.showCheck || entity.showCheck){
              reportGraphSettingList.add(entity);
            }
          }else{
            reportGraphSettingList.add(entity);
          }
          // mod #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 end
        } catch (JacksonException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
        }
      });
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return reportGraphSettingList;
  }

  /**
   * 帳票グラフ設定からモニタ項目に変換する.
   *
   * @param reportGraphSettingList 帳票グラフ設定
   * @return モニタ項目設定
   */
  private List<SysMonitorItem> convertReportGraphSettingToSysMonitorItem(List<ReportGraphSetting> reportGraphSettingList) {
    return reportGraphSettingList.stream()
      .map(r -> new SysMonitorItem(){
        {
          setMoniDataNo(r.cd);
          // モニタ名にモニタ項目コードを設定しているのは、トレンドグラフ用の関数を使用する為、意図的に設定している.
          // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 start
          // setMoniDataName(r.cd);
          // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
          setVitalMonitorClass(r.dataType);
          // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
          setMoniDataName(r.name);
          // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 end
        }
      }).collect(Collectors.toList());
  }

  /**
   * 与えられた発生日時毎のモニタデータのマップからモニタ項目コード毎の
   * モニタデータのマップ(key:発生日時)のマップに変換する.
   *
   * [変換前]
   *  key : 発生日時
   *  value : マップ
   *    key : モニタ項目コード
   *    value : 値
   * [変換後]
   *  key : モニタ項目コード
   *  value : マップ
   *    key : 発生日時
   *    value : 値
   *
   * 同じ発生日時の場合、更新日時が新しい方を採用する.
   *
   * @param monitorItemCdList 帳票グラフに出力するモニタ項目コードのリスト
   * @param monitorDataMap 発生日時毎にモニタデータ
   * @return モニタ項目毎のモニタデータ
   */
  private Map<String, Map<Timestamp, String>> convertMonitorData(
    List<String> monitorItemCdList,
    Map<Timestamp, Map<String, String>> monitorDataMap) {
    // 戻り値用
    Map<String, Map<Timestamp, String>> result = new HashMap<>();

    monitorDataMap.keySet().forEach(key -> {

      monitorItemCdList.forEach(cd -> {
        // モニタデータにモニタ項目のデータが含まれない場合
        if (!monitorDataMap.get(key).containsKey(cd)) {
          return;
        }
        // 含まれる場合
        String value =  monitorDataMap.get(key).get(cd);
        // add #9312 治療状況リスト，マップの表示が不正 房 start
        try {
          // add #11250 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合  吉 start
          value = toHalfWidth(value);
          // add #11250 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合  吉 end
          Double.parseDouble(value);
        } catch (Exception e) {
          value = "";
        }
        // add #9312 治療状況リスト，マップの表示が不正 房 end
        if (result.containsKey(cd)) {
          result.get(cd).put(key, value);
        } else {
          Map<Timestamp, String> detail = new TreeMap<>();
          detail.put(key, value);
          result.put(cd, detail);
        }
      });
    });
    return result;
  }
  // add #11250 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合  吉 start
  public static String toHalfWidth(String str) {
    char[] chars = str.toCharArray();
    for (int i = 0; i < chars.length; i++) {
      if (chars[i] >= 65281 && chars[i] <= 65374) {
        chars[i] = (char)(chars[i] - 65248);
      }
    }
    return new String(chars);
  }
  // add #11250 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合  吉 end

  // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 start
  public void fromFlag(boolean flagF) {
    fromFlag = flagF;
  }
  // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 end

  /**
   * 帳票グラフ設定
   */
  @Getter
  @Setter
  @NoArgsConstructor
  @EqualsAndHashCode(callSuper =  false)
  public static class ReportGraphSetting {
    /**
     * 血圧情報有無
     * ※{@link JsonProperty} アノテーションは意図的に付与しています.
     *   {@link ObjectMapper#setPropertyNamingStrategies(PropertyNamingStrategies)}で指定した場合でも、
     *   正しく設定されない為、{@link JsonProperty}で対応しています.
     */
    @JsonProperty("is_bp")
    private boolean isBp;
    /**
     * モニタ項目コード
     */
    private String cd;
    /**
     * モニタ区分
     *  1 : {@link SysMonitorItem}のモニタ項目
     *  2 : {@link jp.co.nikkiso.ntss.core.entity.MstAddMonitor} のモニタ項目
     */
    private Integer type;
    /**
     * プロット形状
     */
    private String plotType;
    /**
     * プロット色
     */
    private String plotColor;
    /**
     * プロットサイズ
     */
    private Integer plotSize;
    /**
     * 線種
     */
    private String lineType;
    /**
     * 線色
     */
    private String lineColor;
    /**
     * 線の太さ
     */
    private Integer lineThickness;
    /**
     * グラフ上限値
     */
    private Double max;
    /**
     * グラフ下限値
     */
    private Double min;
    /**
     * モニタ項目コードに該当するモニタ項目名
     * ※帳票グラフ設定のjson内には含まれていない.
     *
     */
    private String name;
    // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
    private String dataType;
    // add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
    // add #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 start
    @JsonProperty("show_check")
    private Boolean showCheck;
    // add #11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする 吉 end
  }


  @Override
  public List<Integer> playWrightgetTableHeight(Long ordNo, ChartImageType type,String colWidth,String getRowHeight, Map<String, Object> dataKey) {
    try {
      List<Integer> list = new ArrayList<>();
      // オーダ番号に紐づくオーダを取得
      OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
      if (ordMain == null) {
        // 該当オーダ番号が見つからない
        return new ArrayList<>();
      }
      Integer graphTimeScale = getGraphTimeScale(ordNo);
      if (graphTimeScale == null) {
        graphTimeScale = GRAPH_TIME_SCALE_DEFAULT;
      }
      // オーダ番号から登録されている帳票グラフ設定を取得する.
      List<ReportGraphSetting> reportGraphSettingList = getReportGraphSettingByOrdNo(ordNo);
      // 帳票グラフをモニタ項目(sys_monitor_item)に変換する.
      String doWidth = "";
      int count = (int)reportGraphSettingList.stream().filter(e->e.cd.equals("90")|| e.cd.equals("91")  || e.cd.equals("92")).count();
      int junmCount = 0;
      switch (count){
        case 2:
          junmCount = 1;
          break;
        case 3:
          junmCount = 2;
          break;
        default:
          junmCount = 0;
          break;
      }
      // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
//      switch (reportGraphSettingList.size()-junmCount) {
      int duplicateCdCount = countDuplicateCd(reportGraphSettingList);
      int legendCount = reportGraphSettingList.size() - junmCount - duplicateCdCount;
      switch (legendCount) {
      // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
        case 0:
        case 1:
        case 2:
          doWidth = "100";
          break;
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
//          doWidth = String.valueOf(((reportGraphSettingList.size()-junmCount) * ReportConstant.LEGEND_WIDTH));
          doWidth = String.valueOf(legendCount * ReportConstant.LEGEND_WIDTH);
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
          break;
        default:
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
//          doWidth = String.valueOf(reportGraphSettingList.size() * 30);
          doWidth = String.valueOf(legendCount * 30);
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
          break;
      }
      String finalDoWidth = doWidth;

      // 治療方法に登録されているモニタ項目のリストを取得.
      List<SysMonitorItem> sysMonitorItemList = getSysMonitorItemList(ordNo, MAX_MONITOR_ITEM);
      // 出力するモニタ項目がない場合
      if (sysMonitorItemList.isEmpty()) {
        list.add(0);
        int charHeigth= ReportConstant.HIGH_CHAR_HEIGHT_UNIT_HEIGHT * ReportConstant.HIGH_CHAR_HEIGHT_CONT_EQ;
        //  playwright_count_height =   cell_width * (highchartHeigth + table_height) / cell_heigth
        int playwrightCountWidth = Integer.valueOf(colWidth)*charHeigth/Integer.valueOf(getRowHeight);
        list.add(charHeigth);
        list.add(Integer.valueOf(finalDoWidth));
        list.add(playwrightCountWidth);
        return list;
      }

      int taleHeight = 0;
      for(SysMonitorItem item : sysMonitorItemList){
        String itemName = item.getMoniDataName();
        int fontSize = 16;
        // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
//        if(null != reportGraphSettingList && reportGraphSettingList.size()-junmCount<=4){
        if(null != reportGraphSettingList && legendCount<=4){
        // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
          if(item.getUnit() != null){
            itemName = itemName +" "+item.getUnit();
          }
          if(itemName.length()>=12){
            fontSize = 12;
          }
        }
        int tableTdHeight = calcHtmlTdHeight(itemName,Integer.valueOf(finalDoWidth),String.valueOf(dataKey.get("fountStr")),fontSize,-1,0,0,2,2);
        taleHeight+= tableTdHeight;
      }
      // highchartHeigth = table_heigth / monitCount * (全体の比例 - monitCount)
      int charHeigth= taleHeight/sysMonitorItemList.size() * (ReportConstant.HIGH_CHAR_HEIGHT_CONT_EQ - sysMonitorItemList.size());
      //  playwright_count_height =   cell_width * (highchartHeigth + table_height) / cell_heigth
      int playwrightCountWidth = Integer.valueOf(colWidth)*(charHeigth+taleHeight+ReportConstant.HIGH_CHAR_HEIGHT_CONT_EQ)/Integer.valueOf(getRowHeight);

      if((playwrightCountWidth - Integer.valueOf(finalDoWidth))/(graphTimeScale*2) > ReportConstant.MIN_WIDTH){
        list.add(taleHeight);
        list.add(charHeigth);
        list.add(Integer.valueOf(finalDoWidth));
        list.add(playwrightCountWidth);
      }else{
        list.add(taleHeight);
        playwrightCountWidth = (graphTimeScale*2)* ReportConstant.MIN_WIDTH + Integer.valueOf(finalDoWidth);
        int playwrightCountHeight = Integer.valueOf(getRowHeight) * playwrightCountWidth / Integer.valueOf(colWidth);
        list.add(playwrightCountHeight - taleHeight-ReportConstant.HIGH_CHAR_HEIGHT_CONT_EQ);
        list.add(Integer.valueOf(finalDoWidth));
        list.add(playwrightCountWidth);
      }
      return list;
    }catch (Exception e){
      return new ArrayList<>();
    }
  }

  /**
   * セルの高さ（ピクセル）を計算する
   *
   * @param text         コンテンツ
   * @param tdWidth      セルの合計幅（ピクセル）
   * @param fontName     フォント名
   * @param fontSize     フォントサイズ（ピクセル）
   * @param paddingLeft  左内側余白（px）
   * @param paddingRight 右内側余白（px）
   * @param paddingTop   上内側余白（px）
   * @param paddingBottom 下内側余白（px）
   * @return セルの高さ（px）
   */
  public static int calcHtmlTdHeight(String text,
                                     int tdWidth,
                                     String fontName,
                                     int fontSize,
                                     float lineHeightCss,
                                     int paddingLeft,
                                     int paddingRight,
                                     int paddingTop,
                                     int paddingBottom) {

    if (text == null) text = "";
    float avail = tdWidth - paddingLeft - paddingRight;
    if (avail <= 0) avail = 1;

    // created Graphics2D
    BufferedImage img = new BufferedImage(1, 1, BufferedImage.TYPE_INT_ARGB);
    Graphics2D g2d = img.createGraphics();
    try {
      g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
        RenderingHints.VALUE_TEXT_ANTIALIAS_ON);

      Font font = new Font(fontName, Font.PLAIN, fontSize);
      g2d.setFont(font);
      FontRenderContext frc = g2d.getFontRenderContext();

      int htmlLineHeight;
      if (lineHeightCss <= 0) {
        // CSS：line-height: normal;
        htmlLineHeight = (int) Math.ceil(fontSize * 1.2);
      } else if (lineHeightCss < 10) {
        // CSS：line-height: 1.5 比例形式
        htmlLineHeight = (int) Math.ceil(fontSize * lineHeightCss);
      } else {
        // CSS：line-height: 20px 絶対値
        htmlLineHeight = (int) Math.ceil(lineHeightCss);
      }

      String[] paragraphs = text.split("\\r?\\n", -1);
      int totalLines = 0;

      for (String para : paragraphs) {
        if (para.length() == 0) {
          totalLines += 1;
          continue;
        }

        int start = 0;
        int len = para.length();

        while (start < len) {
          int low = start + 1;
          int high = len;
          int fit = start;

          while (low <= high) {
            int mid = (low + high) >>> 1;
            String sub = para.substring(start, mid);
            double w = font.getStringBounds(sub, frc).getWidth();

            if (w <= avail) {
              fit = mid;
              low = mid + 1;
            } else {
              high = mid - 1;
            }
          }

          if (fit == start) {
            fit = start + 1;
          } else {
            int lastSpace = -1;
            for (int i = fit - 1; i >= start; i--) {
              if (Character.isWhitespace(para.charAt(i))) {
                lastSpace = i;
                break;
              }
            }
            if (lastSpace > start) {
              fit = lastSpace + 1;
            }
          }

          int nextStart = fit;
          while (nextStart < len && Character.isWhitespace(para.charAt(nextStart))) {
            nextStart++;
          }
          start = nextStart;
          totalLines++;
        }
      }

      // 3) HTML 全高：rowCount × htmlLineHeight + padding
      return totalLines * htmlLineHeight + paddingTop + paddingBottom;

    } finally {
      g2d.dispose();
    }
  }

  /**
   * モニタデータ表示用のHTMLテーブルを生成する
   * このメソッドは、透析治療中のモニタデータを時間軸に沿って表示するための
   * HTMLテーブルを生成します。治療開始/終了時刻、時間スケール、モニタ項目設定に
   * 基づいて、複数のHTMLテーブル文字列のリストを返します。
   * 主な処理内容：
   * 1. オーダ番号から治療情報とモニタ項目を取得
   * 2. 時間スケールに基づいて表示期間を分割
   * 3. 各期間ごとにHTMLテーブルテンプレートを生成
   * 4. モニタデータを時間セルに埋め込み
   * 5. 治療開始/終了時刻の範囲外データは除外
   * 6. 各時間セルに最も近いタイムスタンプのデータを表示
   *
   * @param ordNo オーダ番号
   * @param tableWidth テーブルの幅（px）
   * @param tableHeight テーブルの高さ（px）
   * @param tableFirstTdWidth 第一列の幅（px）
   * @param dataKey 追加データマップ
   *                facilityCd: 施設コード
   *                fountStr: フォント名
   * @return HTMLテーブル文字列のリスト
   *         各要素は1つの時間範囲を表すHTMLテーブル
   *         エラー時は空リストを返す
   */
  @Override
  public List<String> getTableHtml(Long ordNo, int tableWidth,int tableHeight,int tableFirstTdWidth,Map<String, Object> dataKey) {
    try {
      List<String> htmlList = new LinkedList<>();
      // dataKeyから施設コードとフォント名を取得
      String facilityCd = dataKey.get("facilityCd").toString();
      String fontStr = dataKey.get("fountStr").toString();

      // 治療方法に登録されているモニタ項目リストを取得
      List<SysMonitorItem> sysMonitorItemList = getSysMonitorItemList(ordNo, MAX_MONITOR_ITEM);

      // モニタデータ（経過時間など）を取得
      Map<Timestamp, Map<String, String>> colDataMap = getMonitorDataForMonitor(ordNo,
        sysMonitorItemList, Arrays.asList(ReportConstant.ReportGraph.ALL_DATA_TYPE),facilityCd);

      // オーダ情報を取得
      OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);

      // グラフの時間スケールを取得
      Integer graphTimeScale = getGraphTimeScale(ordNo);
      if (graphTimeScale == null) {
        graphTimeScale = GRAPH_TIME_SCALE_DEFAULT;
      }

      // 帳票グラフ設定を取得
      List<ReportGraphSetting> reportGraphSettingList = getReportGraphSettingByOrdNo(ordNo);
      // add #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
      int legendSize = reportGraphSettingList.size() - countDuplicateCd(reportGraphSettingList);
      // add #12678 【因島】ΔBVの値表示に関する再調整 sunsy end

      // 帳票グラフ設定をモニタ項目に変換
      List<SysMonitorItem> convertSysMonitorItemList = convertReportGraphSettingToSysMonitorItem(reportGraphSettingList);

      // バイタルデータ取得用のデータタイプリスト
      List<Short> dataTypeList = new ArrayList<>(Arrays.asList(ReportConstant.ReportGraph.ALL_DATA_TYPE));

      // バイタルモニタデータを取得
      // key: 発生日時, value: Map<モニタ項目コード, 値>
      Map<Timestamp, Map<String, String>> monitorDataMap = getMonitorDataForBaitaru(ordNo,
        convertSysMonitorItemList, dataTypeList,facilityCd);

      // 全タイムスタンプのリストを作成
      List<Timestamp> dateList = new ArrayList<>(monitorDataMap.keySet());
      long startTime = getStartTime(dateList, ordMain.getRstStartDate());

      // 治療開始日時を決定
      Timestamp rstStartDate = null;
      if (startTime != 0L) {
        LocalDateTime startAddT = null;
        if (ordMain.getRstStartDate() != null){
          // 治療開始30分前から表示
          startAddT = ordMain.getRstStartDate().toLocalDateTime().withSecond(0).minusMinutes(30);
          rstStartDate = Timestamp.valueOf(startAddT);
        } else {
          startTime = getStartTime(dateList, ordMain.getRstStartDate());
          rstStartDate = new Timestamp(startTime);
        }
      } else {
        // データがない場合は現在時刻を使用
        rstStartDate = new Timestamp(System.currentTimeMillis());
      }

      // 空表作成フラグ
      // true: データなしで空の表を作成
      // false: データを埋め込んで表を作成
      boolean isEmptyGrid = startTime == 0L ? true : false;

      // 時間スケールに基づいて表示期間を分割
      List<Map<LocalDateTime, LocalDateTime>> scaleMapList;
      List<SysMonitorItem> sysHighchartItemList = convertReportGraphSettingToSysMonitorItem(reportGraphSettingList);
      // バイタルモニタークラスが"2"の項目をフィルタ
      List<SysMonitorItem> isHaveMonitList = sysHighchartItemList.stream().filter(e ->Objects.equals(e.getVitalMonitorClass(), "2")).toList();

      // 終了時刻を決定
      if (ordMain.getRstEndDate() != null && null != dateList && dateList.size()>0) {
        Timestamp endTime;
        if(null != isHaveMonitList && isHaveMonitList.size()>0){
          // モニタ項目がある場合は最終データ時刻と治療終了時刻の遅い方を使用
          endTime = dateList.get(dateList.size() - 1).getTime() > ordMain.getRstEndDate().getTime()?dateList.get(dateList.size() - 1):ordMain.getRstEndDate();
        }else{
          endTime = ordMain.getRstEndDate();
        }
        scaleMapList = createScaleDateTimeMap(rstStartDate, endTime, graphTimeScale);
      }
      else if (ordMain.getRstEndDate() == null && null != dateList && dateList.size()>0) {
        // 治療終了時刻がない場合は最終データ時刻を使用
        scaleMapList = createScaleDateTimeMap(rstStartDate,dateList.get(dateList.size() - 1) , graphTimeScale);
      }
      else {
        scaleMapList = createScaleDateTimeMap(rstStartDate, ordMain.getRstEndDate(), graphTimeScale);
      }

      // 各時間スケール範囲ごとにHTMLテーブルを生成
      for (int index = 0; index < scaleMapList.size(); index++) {
        Map<LocalDateTime, LocalDateTime> scaleMap = scaleMapList.get(index);

        // HTMLテーブルテンプレートを構築
        StringBuilder sb = new StringBuilder();
        // フォント指定がある場合はフォントファミリーを設定
        if (!StringUtils.isEmpty(fontStr)) {
          Map<String,String> resultNew = chartFontFamily(fontStr);
          sb.append("<table border=1 style=\"border: #000000; border-collapse: collapse; font-family: "+ resultNew.get(fontStr) +"; table-layout: fixed; width:" + (tableWidth-10) + "px;height:"+tableHeight+"px\">");
        } else {
          sb.append("<table border=1 style=\"border: #000000; border-collapse: collapse; font-family: "+ fontStr +"; table-layout: fixed; width:" + (tableWidth-10)
            + "px\">");
        }

        // 各モニタ項目の行を生成
        sysMonitorItemList.stream().forEach(s ->{
          String itemName = s.getMoniDataName();
          int fontSize = 16;
          // 項目数が少ない場合、長い項目名のフォントサイズを調整
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
//          if(null != reportGraphSettingList && reportGraphSettingList.size()-2<=4){
          if(null != reportGraphSettingList && legendSize - 2 <= 4){
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
            String itemNameStr = itemName ;
            if(s.getUnit() != null){
              itemNameStr = itemNameStr +" "+s.getUnit();
            }
            if(itemNameStr.length()>=12){
              fontSize = 12;
            }
          }

          // 第一列：モニタ項目名と単位を表示
          sb.append("<tr>").append("<td style=\"width:" + (tableFirstTdWidth-10) + "px;font-size:"+fontSize+"px;padding-left:10px;\">")
            .append(itemName)
            .append(s.getUnit() == null ? "" : " ")
            .append(s.getUnit() == null ? "" : s.getUnit())
            .append("</td>");

          // 各時間セルに置換用のキーを埋め込む
          // キー形式："項目名+タイムスタンプ" → 後で実際の値に置換
          scaleMap.entrySet().stream().forEach(k -> {
            sb.append("<td style=\"text-align:center;\">");
            // 空表の場合は置換キーを設定しない
            if (!isEmptyGrid) {
              sb.append(itemName).append(Timestamp.valueOf(k.getValue()));
            }
            sb.append("</td>");
          });
          sb.append("</tr>");
        });
        sb.append("</table>");

        // テンプレート文字列を保存
        String template = sb.toString();
        boolean treatmentStartFlg = true;

        // 各時間セルに実際のモニタデータを埋め込む
        for (Map.Entry<LocalDateTime, LocalDateTime> entry : scaleMap.entrySet()) {

          Timestamp startTimestamp = Timestamp.valueOf(entry.getKey());
          Timestamp endTimestamp = Timestamp.valueOf(entry.getValue());

          // 中央時間（開始時間 + 15分）
          Timestamp midTimestamp = Timestamp.valueOf(entry.getKey().plusMinutes(15));

          // 各項目ごとの最適値を格納
          Map<String, String> resultData = new HashMap<>();

          // 各項目ごとの最小時間差を記録
          Map<String, Long> fieldMinTimeDiff = new HashMap<>();

          for (Map.Entry<Timestamp, Map<String, String>> colEntry : colDataMap.entrySet()) {

            Timestamp ts = colEntry.getKey();

            // 分単位に切り捨て
            Timestamp key = Timestamp.valueOf(
              ts.toLocalDateTime().truncatedTo(ChronoUnit.MINUTES)
            );

            // 対象時間範囲外の場合はスキップ
            if (key.before(startTimestamp) || key.after(endTimestamp)) {
              continue;
            }

            // 中央時間との差（絶対値）
            long timeDiff = Math.abs(key.getTime() - midTimestamp.getTime());

            Map<String, String> currentData = colEntry.getValue();

            // 各項目をループ処理
            for (Map.Entry<String, String> fieldEntry : currentData.entrySet()) {

              String field = fieldEntry.getKey();
              String value = fieldEntry.getValue();

              // 空値は対象外
              if (value == null || value.trim().isEmpty()) {
                continue;
              }

              if (!fieldMinTimeDiff.containsKey(field)) {
                // 初回登録
                fieldMinTimeDiff.put(field, timeDiff);
                resultData.put(field, value);
              } else {
                long oldDiff = fieldMinTimeDiff.get(field);

                if (timeDiff < oldDiff) {
                  // 中央時間により近い場合は更新
                  fieldMinTimeDiff.put(field, timeDiff);
                  resultData.put(field, value);
                }
              }
            }
          }

          // ================== 出力処理 ==================

          for (SysMonitorItem sysMonitorItem : sysMonitorItemList) {

            String fieldName = sysMonitorItem.getMoniDataName();
            String placeHolder = fieldName + endTimestamp;

            if (resultData.containsKey(fieldName)) {
              // 値が存在する場合 → 置換
              template = template.replace(placeHolder, resultData.get(fieldName));
            } else {
              // 値が存在しない場合 → 空文字でクリア
              template = template.replace(placeHolder, "");
            }
          }
        }


        htmlList.add(template);
      }
      return htmlList;
    }catch (Exception e){
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      // エラー時は空リストを返す
      return new ArrayList<>();
    }
  }

  private String createJsonForMonitorChart(Map<Timestamp, Map<String, String>> bataruDataMap,Map<Timestamp, Map<String, String>> monitorDataMap, List<ReportGraphSetting> reportGraphSettingList, long startTime, long offsetTime, List listForDateValues,String fountStr) {
    return createJsonForMonitorChart(bataruDataMap,monitorDataMap, reportGraphSettingList, startTime, offsetTime, null, listForDateValues,fountStr);

  }
  // add #10515 治療記録のバイタル/モニタに登録されているデータによってサーバーが高負荷となる 房 end

  // add #9312 治療状況リスト，マップの表示が不正 房 start
  private Map<Timestamp, Map<String, String>> getMonitorDataForMonitorForNo(Long ordNo, List<SysMonitorItem> sysMonitorItemList, List<Short> dataTypeList,String facilityCd) {
    // モニタデータ取得
    List<MniMonitor> mniMonitorList = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, sysMonitorItemList, dataTypeList,facilityCd);
    // 列データのマップ
    Map<Timestamp, Map<String, String>> colDataMap = new LinkedHashMap<>();

    for (MniMonitor mniMonitor : mniMonitorList) {
      String monitorData = mniMonitor.getMonitorData();
      Map<String,Object> map = convertJsonToMap(monitorData);
      if (map == null) {
        // Json文字列からマップへの変換に失敗
        continue;
      }
      // 項目毎の値を格納するマップ
      Map<String, String> itemMap = new LinkedHashMap<>();
      colDataMap.put(mniMonitor.getOccurDate(), itemMap);
      for (SysMonitorItem sysMonitorItem : sysMonitorItemList) {
        String mniDataNo = sysMonitorItem.getMoniDataNo();
        // モニタデータに取得するモニタ項目番号のデータが含まれていない
        if (!map.containsKey(mniDataNo)) {
          if (map.containsKey(sysMonitorItem.getMoniDataName())) {
            itemMap.put(sysMonitorItem.getMoniDataName(), String.valueOf(map.get(sysMonitorItem.getMoniDataName())));
          } else {
            itemMap.put(sysMonitorItem.getMoniDataName(), "");
          }
          continue;
        }
        String value = null;
        if (!"".equals(Objects.requireNonNull(map).get(mniDataNo)) && Objects.requireNonNull(map).get(mniDataNo) != null) {
          value = Objects.requireNonNull(map).get(mniDataNo).toString();
        }
        // 変換項目が設定されている場合
        if (sysMonitorItem.getConvItem() != null) {
          ObjectMapper mapper = new ObjectMapper();
          Map<String, String> convItemMap = null;
          try {
            convItemMap = mapper.readValue(sysMonitorItem.getConvItem(), new TypeReference<Map<String, String>>(){});
          } catch (JacksonException e) {
            // 変換項目のJSONの読込に失敗した場合は変換は行わない.
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (!StringUtils.isEmpty(facilityCd)) {
              eventLogMessage.setFacilityCd(facilityCd);
            }
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
          }
          if (convItemMap != null && convItemMap.containsKey(value)) {
            value = convItemMap.get(value);
          }
        }
        itemMap.put(sysMonitorItem.getMoniDataNo(), value == null ? "" : value);
      }
    }
    return colDataMap;
  }
  // add #9312 治療状況リスト，マップの表示が不正 房 end

  // add #11232 #10515で入れた制限の見直し 房 start
  private List<Map<String, Object>> sql6ResultEdit(long ordNo, String facilityCd) {
    List<Map<String, Object>> listForDateValues = new ArrayList<>();
    Map<String, Object> tempDateKey = new HashMap<>();
    tempDateKey.put("ordNo", ordNo);
    tempDateKey.put("facilityCd", facilityCd);
    List<Map<String, Object>> sqlResults = new ArrayList<>();
    try {
      sqlResults = sysDataSetService.getDataListAsync(6l, tempDateKey, null).get();
    } catch (Exception ex) {
      throw new NtssException("帳票のモニタデータの画像ファイルの出力に失敗しました。");
    }
    if (sqlResults != null && sqlResults.size() > 0) {
      listForDateValues = syuusoValues(sqlResults);
    }
    return listForDateValues;
  }
  // add #11232 #10515で入れた制限の見直し 房 end

  // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
  public Map<String, String> chartFontFamily(String fountStr) {
    SysSystemDefineDao dao = applicationContext.getBean(SysSystemDefineDao.class);
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//    Map<String, List<String>> fontRules = null;
    Map<String, String> fontRules = null;
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    Map<String, String> resultNew = new HashMap<>();
    // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
    String defaultFont = "";
    // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    try {
      fontRules = FontSubstitutionUtil.loadFontRulesFromDB(dao);
      // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
      defaultFont = FontSubstitutionUtil.loadDefaultFontRulesFromDB(dao);
      // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
    Set<String> systemFonts = getSystemFonts();
    Set<String> lowerCaseSystemFonts = new HashSet<>();
    for (String font : systemFonts) {
      lowerCaseSystemFonts.add(font.toLowerCase());
    }
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//    if (!lowerCaseSystemFonts.contains(fountStr.toLowerCase())) {
//      List<String> substitutes = fontRules.get(fountStr);
//      if (substitutes != null) {
//        for (String sub : substitutes) {
//          if (lowerCaseSystemFonts.contains(sub.toLowerCase())) {
//            resultNew.put(fountStr,sub);
//            break;
//          }
//        }
//      } else {
//        resultNew.put(fountStr,fountStr);
//      }
//    } else {
//      resultNew.put(fountStr,fountStr);
//    }
    if (!lowerCaseSystemFonts.contains(fountStr.toLowerCase())) {
      String substitutes = fontRules.get(fountStr);
      if (substitutes != null) {
        if (lowerCaseSystemFonts.contains(substitutes.toLowerCase())) {
          resultNew.put(fountStr,substitutes);
        }
        else {
          resultNew.put(fountStr,defaultFont);
        }
      } else {
        resultNew.put(fountStr,defaultFont);
      }
    } else {
      resultNew.put(fountStr,fountStr);
    }
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    return resultNew;
  }

  /**
   *
   * すべてのシステムフォントを取得する方法
   *
   * */
  public static Set<String> getSystemFonts() {
    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
    return new HashSet<>(Arrays.asList(ge.getAvailableFontFamilyNames()));
  }
  // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end


  private String getSystemStatus() {
    OperatingSystemMXBean osBean = ManagementFactory.getPlatformMXBean(OperatingSystemMXBean.class);
    long totalMemory = osBean.getTotalPhysicalMemorySize() / 1024 / 1024;
    long freeMemory = osBean.getFreePhysicalMemorySize() / 1024 / 1024;
    double systemCpuLoad = osBean.getSystemCpuLoad() * 100;
    double processCpuLoad = osBean.getProcessCpuLoad() * 100;
    return String.format("SystemCPU=%.1f%%, ProcessCPU=%.1f%%, TotalMem=%dMB, FreeMem=%dMB",
      systemCpuLoad, processCpuLoad, totalMemory, freeMemory);
  }

  /**
   * HighchartsライブラリのJavaScriptコードを取得する
   * このメソッドは、classpathからHighchartsライブラリのJavaScriptファイルを読み込み、
   * 文字列として返します。読み込まれたコードは、Playwrightによるブラウザレンダリング時に
   * ページに注入されて使用されます。
   * @return HighchartsライブラリのJavaScriptコード
   */
  // add highchart-export-serve change to Playwright  吉 start
  private String getHighchartJS() {
    String template;
    try {
      // リソースからHighcharts JavaScriptファイルのURLを取得
      URL url = resourceLoader.getResource(ReportConstant.ReportGraph.TEMPLATE_HIGHCHART_JS).getURL();
      try (
        InputStream is = url.openStream();
        ByteArrayOutputStream os = new ByteArrayOutputStream();) {

        // ファイルの内容を1KBずつ読み込む
        byte[] buffer = new byte[1024];
        int len = is.read(buffer);
        while (len >= 0) {
          os.write(buffer, 0, len);
          len = is.read(buffer);
        }
        // バイト配列をUTF-8文字列に変換
        template = new String(os.toByteArray(), StandardCharsets.UTF_8);
      }
    } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      return "";
    }
    // 改行コードを統一して返す
    return template.replaceAll("\\r\\n", "\n").replaceAll("\\r", "\n");
  }

  /**
   * PlaywrightでHighchartsグラフをPNG画像として生成する
   * このメソッドは、透析治療のモニタデータをHighchartsグラフとして可視化し、
   * Playwrightを使用してブラウザでレンダリングし、PNG画像バイト配列として返します。
   * 複数のグラフを同時に生成し、各グラフは時間スケールに基づいて分割されます。
   *
   * @param ordNo オーダ番号
   * @param type 画像タイプ（通常はPNG）
   * @param isDeviceEdge ジャーナル出力モードかどうか
   *                         true: 複数ページ対応
   *                         false: 単一ページのみ
   * @param dataKey 追加パラメータマップ
   * @return PNG画像のバイト配列リスト
   *         各要素は1つのグラフ画像
   *         エラー時は空リストを返す
   */
  public List<byte[]> getPngByPlayWright(Long ordNo, ChartImageType type,boolean isDeviceEdge,Map<String, Object> dataKey) {
    String facilityCd = String.valueOf(dataKey.get("facilityCd"));
    String fountStr = String.valueOf(dataKey.get("fountStr"));
    String chartHeight = String.valueOf(dataKey.get("charHeight"));
    String chartWidth =  String.valueOf(dataKey.get("countWidth"));
    String playWrightWidth =  String.valueOf(dataKey.get("countHeight"));
    String tableFirstTdWidth =  String.valueOf(dataKey.get("tableFirstTdWidth"));
    String highchatIsNewPage = String.valueOf(dataKey.get("highchatIsNewPage"));
    List<String> tableHtmlList = (List<String>) dataKey.get("tableHtmlList");

    // 返却用の画像データリスト
    List<byte[]> chartData = new ArrayList<>();
    // 画像の拡張子
    String ext = type.toString().toLowerCase();

    // 帳票グラフ設定を取得
    List<ReportGraphSetting> reportGraphSettingList = getReportGraphSettingByOrdNo(ordNo);

    // 帳票グラフ設定をモニタ項目に変換
    List<SysMonitorItem> sysMonitorItemList = convertReportGraphSettingToSysMonitorItem(reportGraphSettingList);
    // 取得するデータタイプのリスト
    List<Short> dataTypeList = new ArrayList<>(Arrays.asList(ReportConstant.ReportGraph.ALL_DATA_TYPE));
    // モニタデータ取得
    //  key   : 発生日時
    //  value : Map
    //  key   : モニタ項目コード
    //  value : 値
    Map<Timestamp, Map<String, String>> bataruDataMap = getMonitorDataForBaitaru(ordNo,
      sysMonitorItemList, dataTypeList,facilityCd);
    Map<Timestamp, Map<String, String>> monitorDataMap = new HashMap<>();

    // 治療方法に登録されているモニタ項目のリストを取得
    sysMonitorItemList = getSysMonitorItemList(ordNo, MAX_MONITOR_ITEM);

    // 経過時間などの追加モニタデータを取得
    List<SysMonitorItem> isHaveMonitList =new ArrayList<>();
    if (!sysMonitorItemList.isEmpty()) {
      // バイタルモニタークラスが"2"の項目を抽出
      isHaveMonitList = sysMonitorItemList.stream().filter(e ->Objects.equals(e.getVitalMonitorClass(), "2")).toList();
      Map<Timestamp, Map<String, String>> colDataMap = getMonitorDataForMonitorForNo(ordNo,
        sysMonitorItemList, Collections.EMPTY_LIST,facilityCd);
      // バイタルデータと統合
      if(colDataMap != null && colDataMap.size() > 0) {
        for(Timestamp timestamp : colDataMap.keySet()) {
          if(!monitorDataMap.containsKey(timestamp)) {
            monitorDataMap.put(timestamp, colDataMap.get(timestamp));
          }
        }
      }
    }

    // オーダ情報を取得
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);

    // 一時ファイル管理用リスト
    List<File> tmpFiles = new ArrayList<>();

    // 全タイムスタンプを統合してソート
    List<Timestamp> dateList = new ArrayList<>();
    List<Timestamp> monitdateList = new ArrayList<>(monitorDataMap.keySet());
    List<Timestamp> batarudateList = new ArrayList<>(bataruDataMap.keySet());
    dateList.addAll(monitdateList);
    dateList.addAll(batarudateList);
    dateList.sort(Comparator.naturalOrder());

    // 治療開始/終了時刻を決定
    long startTime;
    long endTime;
    long offsetTime = 0L;

    if(dateList.size() != 0) {
      // データが存在する場合
      if (ordMain.getRstStartDate() == null) {
        // 治療開始時刻が登録されていない場合、最初のデータ時刻を使用
        startTime = dateList.get(0).getTime();
      } else {
        startTime = ordMain.getRstStartDate().getTime();
      }
      // 30分単位からのオフセットを計算
      offsetTime = startTime % (30 * MINUTE_TIMESTAMP) / MINUTE_TIMESTAMP * MINUTE_TIMESTAMP;
      // 30分単位に標準化
      startTime = getStandardStartTime(startTime);

      // 終了時刻を決定
      if (ordMain.getRstEndDate() != null) {
        if(null != isHaveMonitList && isHaveMonitList.size()>0){
          // モニタ項目がある場合：最終データ時刻と治療終了時刻の遅い方を使用
          endTime = dateList.get(dateList.size() - 1).getTime() > ordMain.getRstEndDate().getTime()?dateList.get(dateList.size() - 1).getTime():ordMain.getRstEndDate().getTime();
        }else{
          // バイタルデータのみの場合
          endTime = batarudateList.size()>0 && batarudateList.get(batarudateList.size() - 1).getTime() > ordMain.getRstEndDate().getTime()?batarudateList.get(batarudateList.size() - 1).getTime():ordMain.getRstEndDate().getTime();
        }
      } else {
        // 治療終了時刻がない場合は最終データ時刻を使用
        endTime = getEndTime(dateList);
      }
    }else{
      // データが全くない場合
      startTime = 0L;
      endTime = 0L;
    }

    // データがない場合、SQL6の結果から開始時刻を取得
    List listForDateValues = sql6ResultEdit(ordNo, facilityCd);
    if (startTime == 0L && listForDateValues != null && listForDateValues.size() > 0){
      if(!"".equals(listForDateValues.get(0)) && listForDateValues.get(1) != null){
        startTime = (long) listForDateValues.get(1);
        offsetTime = startTime % (30 * MINUTE_TIMESTAMP) / MINUTE_TIMESTAMP * MINUTE_TIMESTAMP;
        startTime = getStandardStartTime(startTime);
      }
    }

    // 最大240時間制限：240時間を超える場合は切り捨て
    int millisecondsOf240h = 240 * 60 * 60 * 1000;
    if( (endTime - startTime)  > millisecondsOf240h) {
      endTime = startTime + millisecondsOf240h;
    }

    // グラフの時間スケールを取得
    Integer graphTimeScale = getGraphTimeScale(ordNo);
    long timeScale = graphTimeScale * 60 * MINUTE_TIMESTAMP;
    // Highcharts用のJSONデータを生成
    String monitorJson = createJsonForMonitorChart(bataruDataMap,monitorDataMap, reportGraphSettingList, startTime, offsetTime, listForDateValues,fountStr);
    // X軸のラベル表示有無
    boolean isDispXAxisLabel = startTime != 0 ? true : false;
    // X軸の最小値を決定
    // データがない場合は現在時刻を基準とする
    long xAxisMin = startTime != 0 ? startTime - (30 * MINUTE_TIMESTAMP) : getStandardStartTime(new Date().getTime());

    // カスタムシンボル（バツ印）のスクリプトパスを取得
    // Highcharts標準シンボル: 丸、四角、ダイアモンド、三角上下のみ
    String script = getScript();
    String highchartsExportCommandInfo = "";

    try {
      // 画像リソースのURLを取得
      URL imgUrl = resourceLoader.getResource("classpath:report/img").getURL();

      // グラフレイアウトパラメータの初期化
      int chartMarginLeft = 0;   // グラフ左余白
      int legendXL = 0;           // 凡例X座標
      String marginLeft = "";
      String legendX = "";
      String doHeight = "";
      boolean doJson = false;
      Map<String, Integer> doOffSetKey = new HashMap();
      doOffSetKey.put("#item1.offset#", 0);
      doOffSetKey.put("#item2.offset#", 0);
      doOffSetKey.put("#item3.offset#", 0);
      doOffSetKey.put("#item4.offset#", 0);
      doOffSetKey.put("#item5.offset#", 0);
      Map<String, Integer> doLabelsXVaule = new HashMap();
      doLabelsXVaule.put("#labels1.X#", -25);
      doLabelsXVaule.put("#labels2.X#", -35);
      doLabelsXVaule.put("#labels3.X#", -45);
      doLabelsXVaule.put("#labels4.X#", -60);
      doLabelsXVaule.put("#labels5.X#", -70);
      Map<String, String> doLabelsAlignVaule = new HashMap();
      doLabelsAlignVaule.put("#labels1.align#", "center");
      doLabelsAlignVaule.put("#labels2.align#", "center");
      doLabelsAlignVaule.put("#labels3.align#", "center");
      doLabelsAlignVaule.put("#labels4.align#", "center");
      doLabelsAlignVaule.put("#labels5.align#", "center");
      String json2 = "";
      String itemDistance = "35";
      // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
//      if (reportGraphSettingList.size() >= 3){
      int duplicateCdCount = countDuplicateCd(reportGraphSettingList);
      int legendSize = reportGraphSettingList.size() - duplicateCdCount;
      if (legendSize >= 3){
      // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
        for (int g = 3; g < reportGraphSettingList.size(); g++){
          String doStr = reportGraphSettingList.get(g).name;
          String moji = doStr.replaceAll("\\s*","").replaceAll("[^(\\u4e00-\\u9fa5)]","");
          String eiOrSuuti = doStr.replaceAll("\\s*","").replaceAll("[^(a-zA-Z0-9)]","");
          int keyS = g - 2;
          String doOffSetOfKey = "#item" + keyS + ".offset#";
          String doLabelsXKey = "#labels" + keyS + ".X#";
          String labelsAlignVaule = "#labels" + keyS + ".align#";
          int value = 0;
          int valueKey = 0;
          if (eiOrSuuti.length() == 2 && doStr.length() == 4 ){
            value = 10 - keyS / 2;
            valueKey = doLabelsXVaule.get(doLabelsXKey) - 10;
          } else if (doStr.length() < 4 && eiOrSuuti.length() == 0){
            value = (4 - doStr.length()) * 10  - keyS / 2;
            valueKey = doLabelsXVaule.get(doLabelsXKey) - (4 - doStr.length()) * 10;
          } else if (eiOrSuuti.length() > 0 && doStr.length() < 8 && moji.length() == 0){
            value = (8 - doStr.length()) * 5  - keyS / 2;
            valueKey = doLabelsXVaule.get(doLabelsXKey) - (8 - doStr.length()) * 5;
          } else {
            continue;
          }
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
//          if (!(g > 3 && reportGraphSettingList.size() >= g + 3 && reportGraphSettingList.size() >= 7)){
          if (!(g > 3 && legendSize >= g + 3 && legendSize >= 7)){
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
            doLabelsAlignVaule.replace(labelsAlignVaule, "left");
          }
        }
        doJson = true;
      }

      // 表示項目に合わせた余白サイズの設定
      // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
//      switch (reportGraphSettingList.size()) {
      switch (legendSize) {
      // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
        case 3:
        case 4:
          chartMarginLeft = 100 +6;
          break;
        case 5:
        case 6:
        case 7:
        case 8:
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
//          chartMarginLeft = (reportGraphSettingList.size()-2) * ReportConstant.LEGEND_WIDTH + 5;
          chartMarginLeft = (legendSize - 2) * ReportConstant.LEGEND_WIDTH + 5;
          // mod #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
          break;
        default:
          chartMarginLeft = 90 + 10 ;
          legendXL = -8;
          break;
      }
      if (legendXL == 0) {
        legendXL = chartMarginLeft - 455;
      }

      marginLeft = String.valueOf(chartMarginLeft);
      legendX = String.valueOf(legendXL);
      doHeight = String.valueOf(chartHeight);

      // Playwrightレンダリング用モデルリスト
      List<HighchartGenerateModel> highchartGenerateModels = new ArrayList();

      // 一時スクリプトファイルを作成
      Path scriptPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, ReportConstant.ReportGraph.TEMP_FILE_PREFIX, ".js");
      Files.write(scriptPath, script.getBytes(StandardCharsets.UTF_8), StandardOpenOption.WRITE);
      tmpFiles.add(scriptPath.toFile());

      // 時間軸を分割して各グラフのJSONを生成
      do {
        // グラフの軸範囲とサイズをJSON置換
        json2 = monitorJson
          // x軸の最小値
          .replace("#xAxis.min#", Long.toString(xAxisMin))
          // x軸の最大値
          .replace("#xAxis.max#", Long.toString(xAxisMin + timeScale))
          // グラフ幅
          .replace("#chart.width#", String.valueOf(chartWidth))
          // グラフ高
          .replace("#chart.height#", doHeight)
          // 左幅
          .replace("#chart.marginLeft#", tableFirstTdWidth)
          // 凡例位置
          .replace("#legend.x#", legendX)
          // imgUrlを設定する
          .replace("#imgUrl#", String.valueOf(imgUrl))
          // x軸のラベル表示
          .replace("#xAxis.label.enabled#", Boolean.toString(isDispXAxisLabel))
          .replace("#xAxis.label.offsetValue#", String.valueOf(offsetTime))
          .replace("#series.showInLegend.other#", "true")
          .replace("false***@", "false");
        for (String key: doOffSetKey.keySet()){
          json2 = json2.replace(key, doOffSetKey.get(key).toString());
        }
        for (String key: doLabelsXVaule.keySet()){
          json2 = json2.replace(key, doLabelsXVaule.get(key).toString());
        }
        for (String key: doLabelsAlignVaule.keySet()){
          json2 = json2.replace(key, doLabelsAlignVaule.get(key));
        }
        if (doJson){
          json2 = json2.replace("#legend.layout#", "horizontal").replace("#legend.itemDistance#", itemDistance);
        } else {
          json2 = json2.replace("#legend.layout#\",", "vertical\"").replace("\"itemDistance\": #legend.itemDistance#,", "")
            .replace("\"reversed\": true", "").replace("\"text\": \"最高血圧\",", "\"text\": \"血圧\",")
            .replace("\"text\": \"平均血圧\",", "\"text\": \"\",").replace("\"text\": \"最低血圧\",", "\"text\": \"\",");
        }
        HighchartGenerateModel highchartGenerateModel = new HighchartGenerateModel();
        Path jsonPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, ReportConstant.ReportGraph.TEMP_FILE_PREFIX, ".json");
        Files.write(jsonPath, json2.getBytes(StandardCharsets.UTF_8), StandardOpenOption.WRITE);
        highchartGenerateModel.setInJsonFilePath(json2);
        tmpFiles.add(jsonPath.toFile());
        String imgFilePath  = jsonPath.toString().replace(".json","." + ext);
        tmpFiles.add(new File(imgFilePath));
        highchartGenerateModel.setOutImagefilePath(imgFilePath);
        highchartGenerateModels.add(highchartGenerateModel);
        // 次の時間範囲へ移動
        xAxisMin += timeScale;
      } while (xAxisMin < endTime && highchatIsNewPage.equals("1"));

      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage("===========================");
      logService.log(LogLevel.INFO, eventLogMessage,
        LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU,
        LoggingConstant.SERVICE_NAME.FNSI,null);

      // Playwrightレンダリング実行
      if(null != highchartGenerateModels && highchartGenerateModels.size() > 0){
        // mod #11573水平展開  吉 start
        // if(!isJournalChannel || !highchatIsNewPage.equals("1") || highchartGenerateModels.size()<=1){
        if(isDeviceEdge || !highchatIsNewPage.equals("1") || highchartGenerateModels.size()<=1){
          // mod #11573水平展開  吉 end
          HighchartGenerateModel highchartGenerateModel =  highchartGenerateModels.get(0);
          List<HighchartGenerateModel> newModel = new ArrayList<>();
          List<String> tableList = new ArrayList<>();
          newModel.add(highchartGenerateModel);
          tableList.add(tableHtmlList.get(0));

          // PlaywrightWorkerPoolを使用してレンダリング
          long start = new Date().getTime();
          List<String> files = pool.renderCharts(newModel,tableList,dataKey,getHighchartJS());
          long end = new Date().getTime();

          // レンダリング時間をログ出力
          eventLogMessage.setFacilityCd(facilityCd);
          eventLogMessage.setLogMessage("highcharts生成⇒ReportChartServiceImpl::getMonitorChartData playwrightでグラフを生成する時間（単数）:"
            + new BigDecimal(end - start).divide(new BigDecimal("1000")).setScale(2, RoundingMode.HALF_UP) + "s");
          logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

          if (null != files && files.size() > 0) {
            // 生成された画像ファイルを読み込む
            chartData.add(Files.readAllBytes(Path.of(highchartGenerateModel.getOutImagefilePath())));
          }else{
            // レンダリング失敗
            eventLogMessage.setFacilityCd(facilityCd);
            eventLogMessage.setLogMessage("playwright Error:");
            logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }else{
          // 複数グラフモード：バッチ処理で複数グラフを同時にレンダリング
          eventLogMessage.setFacilityCd(facilityCd);
          eventLogMessage.setLogMessage("isJournalChannel start");
          logService.log(LogLevel.INFO, eventLogMessage,
            LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU,
            LoggingConstant.SERVICE_NAME.FNSI,null);

          // PlaywrightWorkerPoolを使用して一括レンダリング
          long start = new Date().getTime();
          StringBuilder batchParams = new StringBuilder();
          List<String> files = pool.renderCharts(highchartGenerateModels,tableHtmlList,dataKey,getHighchartJS());
          long end = new Date().getTime();

          eventLogMessage.setFacilityCd(facilityCd);
          eventLogMessage.setLogMessage("highcharts生成⇒ReportChartServiceImpl::getMonitorChartData playwrightでグラフを生成する時間（複数）:"
            + new BigDecimal(end - start).divide(new BigDecimal("1000")).setScale(2, RoundingMode.HALF_UP) + "s");
          logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

          if (null != files && files.size() > 0) {
            // 生成された全画像ファイルを読み込む
            for (HighchartGenerateModel model : highchartGenerateModels) {
              chartData.add(Files.readAllBytes(Path.of(model.getOutImagefilePath())));
            }
          }else{
            // レンダリング失敗
            eventLogMessage.setFacilityCd(facilityCd);
            eventLogMessage.setLogMessage("playwright Error:");
            logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
      }
    } catch (Exception e) {
      // 例外が発生した場合は空のデータを返す
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      String stackTraceStr = ExcetionStackTraceToString(e);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage("帳票highcharts出力失敗　" +
        "「facility_cd: "  +facilityCd + ";ordNo:"+ordNo+"」," +
        "「highchartsExportCommandInfo: "  + highchartsExportCommandInfo + "」," +
        "「error:" + stackTraceStr + "」");
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
    } finally {
      // 一時ファイルをクリーンアップ（
      tmpFiles.forEach(f -> {
        if(f.exists()) {
          f.delete();
        }
      });
    }
    return chartData;
  }
  // add highchart-export-serve change to Playwright  吉 end
  // add #12678 【因島】ΔBVの値表示に関する再調整 zhao start
  /**
   * すべてのモニタデータに0以外の値があるかどうか
   *
   * @param mon17 モニタデータ
   * @param mon100 モニタデータ
   * @return ""以外： 値がある一方で表示する（見出し・プロット・値）
   *         ""： 設定した方
   */
  private String setDisplayKbn(List<MniMonitor> mon17, List<MniMonitor> mon100){
    boolean mon17Value = havaValue(mon17, "17");
    boolean mon100Value = havaValue(mon100, "100");
    if(mon17Value && !mon100Value){
      return "17";
    } else if(!mon17Value && mon100Value){
      return "100";
    }else {
      return "";
    }
  }

  /**
   * すべてのモニタデータに0以外の値があるかどうか
   *
   * @param mon モニタデータ
   * @param key 17/100
   * @return false 0以外の値がない　true 0以外の値がある
   */
  private boolean havaValue(List<MniMonitor> mon, String key){
    if((null == mon || mon.size() == 0)){
      return false;
    }
    for (MniMonitor mniMonitor : mon) {
      String monitorData = mniMonitor.getMonitorData();
      Map<String,Object> map = convertJsonToMap(monitorData);
      if (map == null) {
        // Json文字列からマップへの変換に失敗
        continue;
      }
      if(map.containsKey(key)){
        if (Double.parseDouble(map.get(key).toString()) != 0) {
          return true;
        }
      }
    }
    return false;
  }
  // add #12678 【因島】ΔBVの値表示に関する再調整 zhao end

  // add #12678 【因島】ΔBVの値表示に関する再調整 sunsy start
  /**
   * @param reportGraphSettingList 治療方法の帳票グラフ設定内容
   * @return 重複された項目の数（highchartsの項目配置箇所の幅さ計算に不要な数）
   */
  private int countDuplicateCd(List<ReportGraphSetting> reportGraphSettingList) {
    return (int) reportGraphSettingList.stream()
      .collect(Collectors.groupingBy(e -> e.cd, Collectors.counting()))
      .values().stream()
      .filter(cnt -> cnt > 1)
      .mapToLong(cnt -> cnt - 1)
      .sum();
  }
  // add #12678 【因島】ΔBVの値表示に関する再調整 sunsy end
}
