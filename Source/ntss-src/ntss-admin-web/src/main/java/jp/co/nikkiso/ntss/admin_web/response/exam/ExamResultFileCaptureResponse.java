package jp.co.nikkiso.ntss.admin_web.response.exam;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import lombok.AllArgsConstructor;

/**
 *　患者検査結果のResponse.
 */
@AllArgsConstructor
public class ExamResultFileCaptureResponse {
  
  /**
   * 登録失敗行番号リスト.
   */
  public List<Integer> lstSkipRecNo;
  
  /**
   *  登録成功件数
   */
  public int registCnt;
  
  /**
   *  登録した検査結果コードのリスト
   */
  public List<Long> examMainCdList;

  // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
  /**
   *  主鍵と患者関係の対応関係を生成する
   */
  public Map<Long,Long> examMainCdPatIdMap;
  // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
  
  /**
   *  登録成功件数
   */
  public int skipCnt() {
    return lstSkipRecNo.size();
  };

  /**
   * 空の情報を返却するコンストラクタ.
   */
  public ExamResultFileCaptureResponse() {
    this.lstSkipRecNo = Collections.emptyList();
    this.registCnt = 0;
  }
}
