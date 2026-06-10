package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@NoArgsConstructor
public class FacCalComReg {

	/**
	 * 掲示板番号
	 */
	@Id
	private Long fcrCtlNo;

	/**
	 * 施設コード
	 */
	private String facilityCd;

	/**
	 * 対象患者
	 */
	private String patInfo;

	/**
	 * 対象スタッフ
	 */
	private String staffInfo;

	/**
	 * タイトル
	 */
	private String title;

	/**
	 * 内容
	 */
	private String content;

	/**
	 * ファイル情報
	 */
	private String fileInfo;

	/**
	 * コメント登録開始日
	 */
	private Timestamp comRegStartDate;

	/**
	 * 掲載終了日時
	 */
	private Timestamp comRegEndDate;

	/**
	 * コメント登録終了日
	 */
	private Timestamp noticeStartDate;

	/**
	 * 掲載終了日時
	 */
	private Timestamp noticeEndDate;

	/**
	 * カラー
	 */
	private String color;

	/**
	 * 起票者ID
	 */
	private Long regStaffId;

	/**
	 * 起票名
	 */
	private String regStaffName;

	/**
	 * 最終更新者ID
	 */
	private Long updStaffId;

	/**
	 * 最終更新者名
	 */
	private String updStaffName;

	/**
	 * 登録日時
	 */
	private Timestamp regDate;

	/**
	 * 更新日時
	 */
	private Timestamp upDate;

	/**
	 * 表示フラグ.
	 */
	private String isDisp;

	/**
	 * 削除フラグ.
	 */
	private String isDel;
	
}
