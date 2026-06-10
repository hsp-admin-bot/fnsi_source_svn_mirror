package jp.co.nikkiso.ntss.web_api.service;

import jp.co.nikkiso.ntss.core.entity.custom.ExamResult;
import jp.co.nikkiso.ntss.core.entity.custom.ExamResultParam;

import java.util.List;

// mod #8144 【デグレ】検査計算結果が検査後にしか反映されない dou start

/**
 * 検査結果計算のServiceインタフェース.
 */
public interface ExamResultCalcUtilService {

  /**
   * 検査計算項目の計算処理を行う
   *
   * @param examMainCds 患者検査結果コード
   */
  void calculate(List<Long> examMainCds, List<Long> recalculationExamItem);

  /**
   * 検査結果計算
   * 透析量(Kt/V)
   * 計算式：-ln(透析後BUN/透析前BUN)
   */
  Double getCalcKtV(ExamResult examResult);

  /**
   * 検査結果計算
   * 透析量(Kt/Ve)
   * 計算式：Kt/Vsp - 0.6 * Kt/Vsp / 透析時間 + 0.03
   */
  Double getCalcKtVe(ExamResultParam examResultParam, ExamResult examResult);

  /**
   * 検査結果計算
   * 透析量(Kt/Vsp)
   * 計算式：-ln[(透析後BUN/透析前BUN) - 0.008 * 透析時間] + [(4 - 3.5 * (透析後BUN/透析前BUN)] * 除水積算値 / 後体重
   */
  Double getCalcKtVsp(ExamResultParam examResultParam, ExamResult examResult);

  /**
   * 検査結果計算
   * 透析量(Daugirdas Kt/V)
   * 計算式：-ln[(透析後BUN/透析前BUN) - 0.008 * 透析時間] + [(4 - 3.5 * (透析後BUN/透析前BUN)] * 体重減少量 / 後体重
   */
  Double getCalcDaugirdasKtV(ExamResultParam examResultParam, ExamResult examResult);

  /**
   * 検査結果計算
   * BUN除去率
   * 計算式：((透析前BUN-透析後BUN)/透析前BUN)*100
   */
  Double getCalcExclusionRate(ExamResult examResult);

  /**
   * 検査結果計算
   * 時間平均BUN(TAC_BUN)
   * 計算式：(前回の透析後BUN + 今回の透析前BUN) / 2
   */
  Double getCalcTacBun(ExamResultParam examResultParam, ExamResult examResult);

  /**
   * 検査結果計算
   * 補正化 Ca
   * 計算式：血清Ca濃度 – (4+ 血清アルブミン濃度)
   * ※血清アルブミン濃度が4以下のみ補正
   */
  Double getCalcCorCa(ExamResult examResult);

  /**
   * 検査結果計算
   * クリアスペース率
   * 計算式：[1 - [(透析後BUN/透析前BUN - 0.008*透析時間) * (1 - 0.6/透析時間) + 0.008 * 透析時間] / [1 + 1.81 * (除水量 / 後体重)]] * 100
   */
  Double getCalcClearSpace(ExamResultParam examResultParam, ExamResult examResult);

  /**
   * 検査結果計算
   * PCR
   * 計算式：(G+1.2)*9.35(g/day)
   */
  Double getCalcPcr(ExamResultParam examResultParam, ExamResult examResult);

  /**
   * 検査結果計算
   * CreatininIndex
   * 計算式：省略
   */
  Double getCalcCreatininIndex(ExamResultParam examResultParam, ExamResult examResult);

  /**
   * 検査結果計算
   * 透析量(Kt/V(shinzato))
   * 計算式：省略
   */
  Double getCalcKtVShinzato(ExamResultParam examResultParam, ExamResult examResult);

  /**
   * 検査結果計算
   * BMI
   * 計算式：後体重÷（身長×身長）
   */
  Double getCalcBmi(ExamResultParam examResultParam, ExamResult examResult);

  /**
   * 検査結果計算
   * GNRI
   * 計算式：（14.89×透析前ｱﾙﾌﾞﾐﾝ値)＋(41.7×(後体重÷(22×身長×身長)))
   * 後体重>(22 * 身長 * 身長)の場合は(後体重 / (22 * 身長 * 身長))=1
   */
  Double getCalcGnri(ExamResultParam examResultParam, ExamResult examResult);

  /**
   * 検査結果計算
   * Cr除去率
   * 計算式：(C1-C2)/C1×100
   */
  Double getCalcCrExclusionRate(ExamResult examResult);

  /**
   * 検査結果計算
   * TSAT
   * 計算式：[血清鉄(Fe)/総鉄結合能(TIBC)] * 100
   * ※                        透析前の検査値で計算
   */
  Double getCalcTsat(ExamResult examResult);
// mod #8144 【デグレ】検査計算結果が検査後にしか反映されない dou end
}
