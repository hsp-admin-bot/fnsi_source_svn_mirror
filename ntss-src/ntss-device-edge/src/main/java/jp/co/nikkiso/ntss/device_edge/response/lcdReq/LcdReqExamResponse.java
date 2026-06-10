package jp.co.nikkiso.ntss.device_edge.response.lcdReq;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LcdReqExamResponse {

  /**
   * システムで管理する一意な検査結果ID.
   */
  private Long examMainCd;

  /**
   * 結果時検査日時
   */
  private String resultExamDate;

  /**
   * 登録時検査区分（仮想端末表示用）
   * 0: 透析前 1: 透析後 2: その他（pat_exam_mainテーブルの値とは異なる）
   */
  private Integer regOrderClass;

  /**
   * 検査結果情報
   */
  private String examResultInfo;

  /**
   * FNSiの検査測定区分から仮想端末の検査測定区分にコードを変換する
   * @param regOrderClassFNSi FNSiの検査測定区分
   * @return
   */
  public Integer getRegOrderClassFNSi2Machine(String regOrderClassFNSi) {
    switch (regOrderClassFNSi) {
    case "0":
      // FNSiの"0"はその他(2)
      return 2;
    case "1":
      // FNSiの"1"は透析前(0)
      return 0;
    case "2":
      // FNSiの"2"は透析後(1)
      return 1;
    default:
      // 不明はその他(2)
      return 2;
    }
  }
}
