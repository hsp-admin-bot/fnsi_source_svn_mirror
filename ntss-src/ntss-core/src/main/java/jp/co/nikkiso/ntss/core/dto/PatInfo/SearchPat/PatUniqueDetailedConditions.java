package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.util.List;

import lombok.Data;

/**
 * pat_unique検索条件
 */
@Data
public class PatUniqueDetailedConditions {
  // 既往歴情報.転帰のリスト
  private List<String> outComeList;
  // 既往歴情報.病名コード
  private Integer diseaseCd;
  // 既往歴情報.透析導入原疾患
  private List<Integer> dialysis_underlying_disease_List;
  // 既往歴情報.主病
  private Integer primary_disease_cd;
}
