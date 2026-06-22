package jp.co.nikkiso.ntss.web_api.service.component;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import lombok.Getter;
import lombok.Setter;

/**
 * 指示履歴クラス
 */
@Document(collection="ind_history")
@Getter
@Setter
public class IndHistory {
  /**
   * 患者コード
   */
  @Field("pat_id")
  private String patId;

  /**
   * 施設コード
   */
  @Field("facility_cd")
  private String facilityCd;
	@Field("_id")
  @JsonProperty("_id")
	private String _id;
  @Field("ord_no")
  private String ordNo;

  /**
   * 発行日
   */
  @Field("log_date")
  private String logDate;

  /**
   * 開始日
   */
  @Field("treatment_start_date")
  private String treatmentStartDate;

  /**
   * 終了日
   */
  @Field("treatment_end_date")
  private String treatmentEndDate;

  /**
   * 曜日
   */
  @Field("treatment_weekday")
  private String treatmentWeekday;

  /**
   * 治療方法
   */
  @Field("treatment_method")
  private String treatmentMethod;

  /**
   * クール
   */
  @Field("treatment_course")
  private String treatmentCourse;

  /**
   * 対象
   */
  @Field("log_target")
  private String logTarget;

  /**
   * 対象ソート順
   */
  @Field("sort_no")
  private Integer sortNo;

  /**
   * 操作区分
   */
  @Field("log_class")
  private String logClass;

  /**
   * 内容
   */
  @Field("log_content")
  private String logContent;

	/**
	 * 指示受け者1
	 */
	@Field("receiver_1")
	private String receiver1;

	/**
	 * 指示受け日1
	 */
	@Field("receive_date1")
	private String receiveDate1;

	/**
	 * 指示受け者1
	 */
	@Field("receiver_2")
	private String receiver2;

	/**
	 * 指示受け日1
	 */
	@Field("receive_date2")
	private String receiveDate2;

	/**
	 * 指示承認者1
	 */
	@Field("approver_1")
	private String approver1;

	/**
	 * 指示承認日1
	 */
	@Field("approval_date1")
	private String approvalDate1;

	/**
	 * 指示承認者1
	 */
	@Field("approver_2")
	private String approver2;

	/**
	 * 指示承認日1
	 */
	@Field("approval_date2")
	private String approvalDate2;

  /**
   * 指示者
   */
  @Field("created_by")
  private String createdBy;

  /**
   * 更新者
   */
  @Field("updated_by")
  private String updatedBy;

  /**
   * 指示者ID
   */
  @Field("created_user_id")
  private Long createdUserId;

  /**
   * 更新者ID
   */
  @Field("updated_user_id")
  private Long updatedUserId;
}
