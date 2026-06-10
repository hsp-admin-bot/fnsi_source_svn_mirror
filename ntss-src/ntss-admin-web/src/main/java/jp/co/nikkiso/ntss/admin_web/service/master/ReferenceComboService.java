package jp.co.nikkiso.ntss.admin_web.service.master;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;
import jp.co.nikkiso.ntss.core.exception.InvalidSchemaDefinitionException;

/**
 * 参照型コンボのServiceインターフェース
 */
public interface ReferenceComboService {
  /**
   * マスタ定義テーブルの参照型コンボの構造定義データから、実際のデータを取得する。
   * @param facilityCd 施設コード
   * @param referenceComboTargetTable 参照型コンボの構造定義データ
   * @return 参照型コンボの実際のデータ
   * @throws InvalidSchemaDefinitionException
   */
  List<ReferenceCombo> build(String facilityCd, ReferenceComboTargetTable referenceComboTargetTable) throws InvalidSchemaDefinitionException;
}
