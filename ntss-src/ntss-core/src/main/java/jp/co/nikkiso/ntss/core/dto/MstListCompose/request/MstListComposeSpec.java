package jp.co.nikkiso.ntss.core.dto.MstListCompose.request;

import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Getter
@Setter
public class MstListComposeSpec {
  private String id;   // リストの一意ID（返却時のキーとして使用）
  private String name; // 任意の表示名称
  private String displayType; // ポップアップ表示形式（分類表示 or リスト表示）
  private String filterKey;  // class
  private String filterLabel;  // 機能分類

  private MstListComposeSourceType sourceType; // FIXED, MST, MST_COMBINED, MAIN_DISTINCT

  // FIXED：固定リスト
  private List<Map<String, Object>> fixedItems;

  // 単一ソース（MST / MAIN_DISTINCT で使用可能）
  private MstListComposeSource mstSource;

  // 複数ソース（MST_COMBINED / MAIN_DISTINCT で使用可能）
  private List<MstListComposeSource> mstSourceList;

  // リストレベルのキー・マッピング（ソース単位のマッピング適用後に実施）
  private List<MstListComposeKeyMapping> keyMapping;

}
