package jp.co.nikkiso.ntss.api.utils;

import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.model.ExcelItemModel;
import org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Excelツールクラス
 *
 * @author 李
 * @date 2023-09-07
 */
public class ExcelUtil {
  /**
   * 内容处理コンテンツ処理
   * @param reportOutputInfo 処理が必要なデータ
   * @param params           XML構成
   * @return
   */
  public static Map<String,String> hande(Map<String, String> reportOutputInfo, List<ReportXmlParam> params){
    Map<String, String> result = new HashMap<>();

    // add 9618(9577) 因島帳票の表示不具合（準備・回収リスト） 李 start
    result = removeBlankLines(reportOutputInfo, params);
    // add 9618(9577) 因島帳票の表示不具合（準備・回収リスト） 李 end

    return result;
  }

  // add 9618(9577) 因島帳票の表示不具合（準備・回収リスト） 李 start

  /**
   * 空白行を除く
   * 9618(9577) 因島帳票の表示不具合（準備・回収リスト）
   *
   * @param reportOutputInfo 処理が必要なデータ
   * @param params           XML構成
   * @return 処理後のデータ
   */
  private static Map<String, String> removeBlankLines(Map<String, String> reportOutputInfo, List<ReportXmlParam> params) {
    Map<String, Object> xmlAllocation = analysisXml(params);

    Integer max = xmlAllocation.get("max_col") != null ? Integer.parseInt(xmlAllocation.get("max_col").toString()) : 0;

    //region データ初期化
    if (max == null && max < 0) {
      max = 0;
    }
    if (max < 1) {
      return reportOutputInfo;
    }
    //endregion データ初期化

    //region 変数の宣言
    Map<String, String> result = new HashMap<>();
    List<ExcelItemModel> excelItemModelList = new ArrayList<>();
    List<ExcelItemModel> objList = null;
    boolean isNotEmptyData = false, isGroupData = false;
    String beginInitiate_x = "";
    //データ数
    int dataSum = 0;
    //endregion 変数の宣言

    //リストに変換
    for (String key : reportOutputInfo.keySet()) {
      excelItemModelList.add(new ExcelItemModel(key, reportOutputInfo.get(key)));
    }

    //1.順序による順序付け
    List<ExcelItemModel> list = excelItemModelList
      .stream()
      .sorted(Comparator.comparing(ExcelItemModel::getSort))
      .collect(Collectors.toList());

    //2.グループ名によるグループ化クエリー
    Map<String, List<ExcelItemModel>> excelItemGroup = list
      .stream()
      .collect(Collectors.groupingBy(po -> po.getGroupName()));
    // add #9577 大量の空行が発生する 高　start
    excelItemGroup = excelItemGroup.entrySet().stream()
      .sorted(Map.Entry.comparingByKey())
      .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue, (e1, e2) -> e1, LinkedHashMap::new));
    // add #9577 大量の空行が発生する 高　end

    for (String key : excelItemGroup.keySet()) {
      objList = excelItemGroup.get(key);
      isNotEmptyData = false;
      isGroupData = false;

      for (ExcelItemModel item : objList) {
        isGroupData = item.isGroupData();
        if (!item.isGroupData()) {
          result.put(item.getData_key(), item.getData_value());
        }

        isNotEmptyData = StringUtils.isNotBlank(item.getData_value());

        if (StringUtils.isBlank(beginInitiate_x)) {
          beginInitiate_x = item.getInitiate_x();
        }

        if (isGroupData && isNotEmptyData) {
          break;
        }
      }

      if (isGroupData && isNotEmptyData) {
        dataSum++;

        for (ExcelItemModel item : objList) {
          item.setPage((dataSum - 1) / max + 1);

          item.setOffset(dataSum % max == 0 ? max : dataSum % max);

          result.put(item.getData_key(), item.getData_value());
        }
      }
    }

    return result;
  }

  // add 9618(9577) 因島帳票の表示不具合（準備・回収リスト） 李 end

  /**
   * 解析XML
   * @param params
   * @return
   */
  private static Map<String, Object> analysisXml(List<ReportXmlParam> params) {
    Map<String, Object> result = new HashMap<>();

    Integer max_col = 0;
    for (ReportXmlParam xml : params) {
      // add #9577 大量の空行が発生する 高　start
      if (null != xml.getReportXmlTmplRepeat().getRepeatCountV() && !"".equals(xml.getReportXmlTmplRepeat().getRepeatCountV()) &&
        null != xml.getReportXmlTmplRepeat().getRepeatCountH() && !"".equals(xml.getReportXmlTmplRepeat().getRepeatCountH()) ) {
        if (xml.getReportXmlTmplRepeat().getRepeatCountH() < xml.getReportXmlTmplRepeat().getRepeatCountV()) {
          max_col = xml.getReportXmlTmplRepeat().getRepeatCountV();
        } else {
          max_col = xml.getReportXmlTmplRepeat().getRepeatCountH();
        }
      }
      // add #9577 大量の空行が発生する 高　end
      // del #9577 大量の空行が発生する 高　start
//      if (null != xml.getReportXmlTmplRepeat().getRepeatCountV() && !"".equals(xml.getReportXmlTmplRepeat().getRepeatCountV())) {
//        max_col = xml.getReportXmlTmplRepeat().getRepeatCountV();
//      }
      // del #9577 大量の空行が発生する 高　end
    }

    result.put("max_col", max_col);
    return result;
  }
}
