package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.util.Map;

/**
 * 電文から抽出した項目に基づき、エンティティを作成する機能を規定するインタフェース。
 */
public interface EntityLogic {

  // FIXME
  // 当初、型パラメータTを持つgenericインタフェース EntityLogic<T> とする予定であった。
  // こうすると、T createEntity(paramMap)、void check(... T entity)のようにエンティティ型が
  // テンプレート化され、
  // class PatMainLogic implements EntityLogic<PatMain> ならば、patMainLogic.createEntity(paramMap)の返値は
  // PatMainになり、ダウンキャストが不要となる。
  // しかし、テーブルによって実装クラスが変わるがメソッド呼び出しはinterfaceを経由して統一的に記述する場合、
  // EntityLogic<?> entityLogic; // PatMainLogic, PatExamMainLogic等のいずれかのオブジェクトが入る。（エンティティ型はワイルドカードを使用するしかない）
  // entityLogic.check(div, ... entity);
  // という呼び出しで要求されるentityの型がcapture#6-of ?のようになり、Objectでさえも渡せなくなる。
  // 結局、テーブル名を引数として patMainLogic, patExamMainLogic等にswitch処理を振り分ける非効率な方法しかなくなる。
  // そのため、genericの使用をやめ、この場面に限ってダウンキャストを認める方法に変更した。

  /**
   * マップからエンティティを作成する。
   *
   * @param paramMap カラム名とカラム値のマップ
   * @return エンティティ
   */
  Object createEntity(Map<String, Object> paramMap);

  /**
   * 電文から抽出した項目をチェックおよび編集する。（新規登録時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   */
  void check(String facilityCd, Map<String, Object> paramMap);

  /**
   * 電文から抽出した項目をチェックおよび編集する。（更新時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @param entity 対象テーブルから取得したエンティティ（更新の場合に使用）
   */
  void check(String facilityCd, Map<String, Object> paramMap, Object entity);
}
