package jp.co.nikkiso.ntss.api.service.report;

import java.util.List;
import java.util.Map;

/**
 * 帳票のチャートを生成するServiceインタフェース.
 */
public interface ReportChartService {

  /**
   * チャートイメージ種別
   */
  public enum ChartImageType {
    SVG,
    PNG
  }

  int  getVitalChartDataLen(Long ordNo);

  // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 start
  void fromFlag(boolean flagF);
  // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 end

  // add highchart-export-serve change to Playwright  吉 start
  List<Integer> playWrightgetTableHeight(Long ordNo, ChartImageType type, String colWidth, String getRowHeight, Map<String, Object> dataKey);

  List<String> getTableHtml(Long ordNo, int colWidth,int getRowHeight,int tableFirstTdWidth,Map<String, Object> dataKey);

  List<byte[]> getPngByPlayWright(Long ordNo, ChartImageType type,boolean isDeviceEdge,Map<String, Object> dataKey);
  // add highchart-export-serve change to Playwright  吉 end
}
