package jp.co.nikkiso.ntss.admin_web.service.indHistory;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

/**
 * 
 * 検索条件
 *
 */
@Getter
@Setter
public class IndicationSearch {
	/**
	 * 指示発行日・指示開始日グループボタン
	 */
	private int treatmentDateOpt;
	/**
	 * 指示発行日・指示開始日デートピッカー
	 */
	private String treatmentStartDate;
	/**
	 * 治療予定日デートピッカー
	 */
	private String treatmentScheduledDate;
    /**
     * 指示：クールコード
     */
    private List<Long> kurCode;
    /**
     * 透析室・ベッドグループコード
     */
    private Long bedGroup;
	/**
	 * チェック1ラジオボタン
	 */
	private int check1;
	/**
	 * チェック2ラジオボタン
	 */
	private int check2;
	/**
	 * 承認1ラジオボタン
	 */
	private int approver1;
	/**
	 * /**
	 * 承認2ラジオボタン
	 */
	private int approver2;
	/**
	 * 指示者プルダウンリスト
	 */
	private String createdBy;
	/**
	 * 対象指示
	 */
	private IndicationTarget indicationTarget;
	/**
	 * 施設コード
	 */
	private String facilityCd;
}
