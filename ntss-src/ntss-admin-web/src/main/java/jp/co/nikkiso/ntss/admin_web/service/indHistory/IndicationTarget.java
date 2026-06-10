package jp.co.nikkiso.ntss.admin_web.service.indHistory;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

/**
 * 検索項目
 * 指示対象
 */
@Getter
@Setter
public class IndicationTarget {
	/**
	 * すべてチェックボックス
	 */
	private boolean indication;
	/**
	 * 選択された指示者一覧
	 */
	private List<String> indicationList;
}
