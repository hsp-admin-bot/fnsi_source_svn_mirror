package jp.co.nikkiso.ntss.core.entity.custom;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ExternalCoopPayload {
	/**
	 * 最大検索数
	 */
	private int limit;

	/**
	 * 電文種別
	 */
	private List<String> coopCd;

	/**
	 * 向き（送受信）
	 */
	private List<String> direction;

	/**
	 * 変換処理ステータスコード
	 */
	private List<String> anaResult;

	/**
	 * 配信処理ステータスコード
	 */
	private List<String> coopResult;

	/**
	 * 変換処理開始日時
	 */
	private String fromDate;

	/**
	 * 変換処理完了日時
	 */
	private String toDate;

	/**
	 * 通信開始日時
	 */
	private String fromRegDate;

	/**
	 * 通信終了日時
	 */
	private String toRegDate;
// add FNSI-改修内容検索でも 基準日の検索ができるよう追加(初期値:当日) liang start
	private String fromBaseDate;

	private String toBaseDate;
// add FNSI-改修内容検索でも 基準日の検索ができるよう追加(初期値:当日) liang end
	/**
	 * 電文内容
	 */
	private String content;

	/**
	 * 並び替え用検索フラグ
	 */
	private boolean isSearch;
  // #9509 検索条件のフリーワードの検索範囲について 2023-08-30 卓 start
  /**
   *   患者番号(システム)
   */
  private List<Long> patIdList;
  // #9509 検索条件のフリーワードの検索範囲について 2023-08-30 卓 end

  // add 9583 by kangjie 20240401 start
  private String ctlNo;

  private String ordNo;
  // add 9583 by kangjie 20240401 end
}
