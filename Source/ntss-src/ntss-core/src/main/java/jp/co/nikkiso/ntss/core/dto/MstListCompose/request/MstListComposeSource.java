package jp.co.nikkiso.ntss.core.dto.MstListCompose.request;

import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Getter
@Setter
public class MstListComposeSource {
  private String mstCode;                 // 登録済みのSQLファイルのキーに対応
  private String sourceTag;               // 統合／識別用のタグ（keyMapping で使用）
  private Map<String, String> sqlParams;  // 各ソースごとに個別指定可能なSQLパラメータ
  private List<MstListComposeKeyMapping> keyMapping;  // ソース単位のキー・マッピング（先に適用）
  private String distinctField;           // null 以外の場合、当該フィールドで重複排除を行う（MAIN_DISTINCT 用）
}
