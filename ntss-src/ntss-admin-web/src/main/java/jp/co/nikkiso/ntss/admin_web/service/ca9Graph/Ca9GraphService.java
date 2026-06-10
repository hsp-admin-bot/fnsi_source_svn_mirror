package jp.co.nikkiso.ntss.admin_web.service.ca9Graph;

import java.util.List;
import java.util.Map;

public interface Ca9GraphService {

  /**
   * グラフ設定を取得
   * @throws Exception
   */
  Map<String, String> getGraphSetting(String facilityCd) throws Exception;

  /**
   * 分布での検査項目を取得
   * @throws Exception
   */
  List<Map<String, String>> getPatExamItemDistributionGraphData(Map<String, String> params) throws Exception;

  /**
   * 経過での検査項目を取得
   * @throws Exception
   */
  List<Map<String, String>> getPatExamItemProgressGraphData(Map<String, String> params, Long patId) throws Exception;

  /**
   * 患者グループを更新
   * @throws Exception
   */
  List<Map<String, Object>> updatePatGroup(List<Map<String, String>> payload, String facilityCd) throws Exception;
  // add bug 7940 修正 chen start
  List<Map<String, Object>> updatePatGroupByGroupList(List<Map<String, String>> payload, String facilityCd, List<String> groupIdList) throws Exception;
  // add bug 7940 修正 chen end

}
