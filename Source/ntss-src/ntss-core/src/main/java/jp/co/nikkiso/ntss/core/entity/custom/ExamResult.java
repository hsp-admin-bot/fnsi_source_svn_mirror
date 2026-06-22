package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import lombok.Data;

import java.sql.Timestamp;
import java.util.List;

/**
 * 検査計算結果
 */
@Data
public class ExamResult {

  /**
   * Ca
   */
  private String ca;

  /**
   * 透析前Ca
   */
  private String caBefore;

  /**
   * 透析後Ca
   */
  private String caAfter;

  /**
   * Alb
   */
  private String alb;

  /**
   * 透析前Alb
   */
  private String albBefore;

  /**
   * 透析後Alb
   */
  private String albAfter;

  /**
   * 透析前Bun
   */
  private String bunBefore;

  /**
   * 透析後Bun
   */
  private String bunAfter;

  /**
   * 前回の透析後Bun
   */
  private String lastTimeBunAfter;

  /**
   * 透析前Cr
   */
  private String crBefore;

  /**
   * 透析後Cr
   */
  private String crAfter;


  /**
   * 透析前Fe
   */
  private String feBefore;

  /**
   * 透析前Tibc
   */
  private String tibcBefore;

  /**
   * 透析前valHem
   */
  private String valHemBefore;

  /**
   * 透析後valHem
   */
  private String valHemAfter;

  /**
   * 検査開始時刻
   */
  private Timestamp examStratTime;

  /**
   * 検査終了時刻
   */
  private Timestamp examEndTime;

  /**
   * 治療情報
   */
  private OrdMain ordMain;

  /**
   * 検査結果list
   */
  private List<PatExamMain> patExamMainList;
}
