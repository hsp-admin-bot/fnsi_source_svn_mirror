package jp.co.nikkiso.ntss.api.model;

import lombok.Data;

import java.util.List;

@Data
public class PatHighChartsJsonInfo {

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * JSONデータ
   */
  private List<HighChartsJsonModel> models;
  // add #10633 【たくしん会】帳票のフォント問題 吉 start
  /**
   * フォント
   */
  private String fontType;
  // add #10633 【たくしん会】帳票のフォント問題 吉 end
}
