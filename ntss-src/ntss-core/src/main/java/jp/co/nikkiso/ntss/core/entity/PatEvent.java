package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 患者イベント管理クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_event")
@Getter
@Setter
public class PatEvent extends BaseEntity {

	@Domain(valueType = String.class)
	@Getter
	@Setter
	@NoArgsConstructor
	public static class LetterInfo {

		private static ObjectMapper objectMapper = new ObjectMapper();

		private static ModelMapper modelMapper = new ModelMapper();

		/**
		 * 選択された帳票Cd
		 */
		@JsonProperty("report_cd")
		private long reportCd = 0;

		/**
		 * 画面上に入力したデータ
		 */
		@JsonProperty("letter_data")
		private Map<String, String> letterData = new HashMap<String, String>();

		/**
		 * 転入出先
		 */
		@JsonProperty("to_facility_cd")
		private String to_facility_cd = "";

		/**
		 * 紹介状区分
		 */
		@JsonProperty("letter_category")
		private long letterCategory = 0;

		/**
		 * 発行日
		 */
		@JsonProperty("letter_issue_date")
		private String letterIssueDate = "";
		// add #12324 紹介状の出力時にpat_eventを参照する zhao start
		/**
		 * 管理番号
		 */
		@JsonProperty("ctlNo")
		private String ctlNo = "";
		// add #12324 紹介状の出力時にpat_eventを参照する zhao end
		/**
		 * コンストラクタ.
		 *
		 * @param value JSON文字列
		 */
		@SuppressWarnings("serial")
		public LetterInfo(String value) {
			try {
				LetterInfo obj = objectMapper.readValue(value, LetterInfo.class);
				modelMapper.map(obj, this);
			} catch (JacksonException e) {
				throw new NtssException("帳票マスタのファイルパス情報設定内容が不正です") {
				};
			}
		}

		/**
		 * 基本型の値を返す.
		 *
		 * @return 基本型の値
		 */
		@JsonIgnore
		public String getValue() {
			try {
				return objectMapper.writeValueAsString(this);
			} catch (JacksonException e) {
				return null;
			}
		}
	}

	/**
	 * システムで管理する一意な患者イベントコード
	 */
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	Long patEventCd;
	/**
	 * システムで管理する一意な患者ID
	 */
	Long patId;
	/**
	 * 施設コード
	 */
	String facilityCd;
	/**
	 * FNW+で管理する施設内の一意なシーケンスID
	 */
	Long fnCtlNo;
	/**
	 * 状況区分
	 */
	String eventStatus;

	/**
	 * テンプレートコード
	 */
	Long templateCd;
	/**
	 * テンプレート名称
	 */
	String templateName;
	/**
	 * カテゴリコード
	 */
	Long categoryCd;
	/**
	 * カテゴリ名称
	 */
	String categoryName;
	/**
	 * 利用種別
	 */
	Integer useType;
	/**
	 * VA画像フラグ
	 */
	//String isVa;
	/**
	 * 観察記録対象フラグ
	 */
	//String isObserve;
	/**
	 * システムで管理する一意なオーダ番号
	 */
	Long ordNo;
	/**
	 * 項目情報
	 */
	String inputParams;
	/**
	 * イベント開始日時
	 */
	String eventStartDate;
	/**
	 * イベント終了日時
	 */
	String eventEndDate;
	/**
	 * イベント開始時刻
	 */
	String eventStartTime;
	/**
	 * イベント終了時刻
	 */
	String eventEndTime;
	/**
	 * サブカテゴリコード
	 */
	Long subCategoryCd;
	/**
	 * サブカテゴリ名称
	 */
	String subCategoryName;
	/**
	 * 項目実績
	 */
	String resultParams;
	/**
	 * スコア合計
	 */
	Integer scoreTotal;
	/**
	 * 起票者情報
	 */
	String regStaffInfo;
	/**
	 * 編集者情報
	 */
	String upStaffInfo;
	/**
	 * 掲示板管理番号
	 */
	Long bbsCtlNo;
	/**
	 * 最新フラグ
	 */
	String isNewest;
	/**
	 * 削除フラグ
	 */
	String isDel;

	/**
	 * 紹介状データ
	 */
	String letterInfo;
  /*add FNSI-改修内容転入時の紹介状取込ができない   任 start*/
	String reportUrl;
  /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
	String reportDate;
  /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
  /*add FNSI-改修内容転入時の紹介状取込ができない   任 end*/
  /*add FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 start*/
  @Transient
  List<Long> bbsCtlNoList;
  @Transient
  List<Long> patEventCdList;
  /*add FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 end*/
  /*add FNSI-改修内容5570 任 start*/
  @Transient
  String resultParamsOld;
  /*add FNSI-改修内容5570 任 end*/
  @Transient
  String procState;
  @Transient
  Boolean isObserveRecordLog;
  @Transient
  Long findOrdNo;
  @Transient
  String templateLayoutDiff;
  @Transient
  String observeRecordDiff;
}
