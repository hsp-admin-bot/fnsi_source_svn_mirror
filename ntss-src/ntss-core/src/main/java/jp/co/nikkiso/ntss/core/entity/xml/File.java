package jp.co.nikkiso.ntss.core.entity.xml;

/**
 * 複数ファイル出力の設定におけるfile要素を表現するJAXBエンティティです。
 * 
 * <p>
 * file要素は、CSVレイアウト設定内で複数ファイルを出力する場合に使用され、
 * 指定されたSQL（sqlCode属性）を元にdetail_idを取得し、各レコードに対応するレイアウト（mst_coop_layout_detail）に基づいて
 * ファイル単位のデータ出力を行います。
 * </p>
 * 
 * <p>
 * このクラスは {@code <file>} タグに対応し、親要素からの継承として {@link Item} を継承します。
 * </p>
 *
 * @see jp.co.nikkiso.ntss.core.entity.xml.Item
 */
public class File extends Occ {
}
