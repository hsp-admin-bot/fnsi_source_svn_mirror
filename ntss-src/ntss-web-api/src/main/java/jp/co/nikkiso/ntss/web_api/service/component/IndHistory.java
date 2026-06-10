package jp.co.nikkiso.ntss.web_api.service.component;

import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBAttribute;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBRangeKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;

import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import lombok.Getter;
import lombok.Setter;

/**
 * 指示履歴クラス
 */
@DynamoDBTable(tableName="ind_history")
@Document(collection="ind_history")
@Getter
@Setter
public class IndHistory {
  /**
   * 患者コード
   */
  @DynamoDBHashKey(attributeName="pat_id")
  @Field("pat_id")
  private String patId;

  /**
   * 施設コード
   */
  @DynamoDBAttribute(attributeName="facility_cd")
  @Field("facility_cd")
  private String facilityCd;

	@DynamoDBHashKey(attributeName = "_id")
	@Field("_id")
	private String _id;

  @DynamoDBHashKey(attributeName="ord_no")
  @Field("ord_no")
  private String ordNo;

  /**
   * 発行日
   */
  @DynamoDBRangeKey(attributeName="log_date")
  @Field("log_date")
  private String logDate;

  /**
   * 開始日
   */
  @DynamoDBAttribute(attributeName="treatment_start_date")
  @Field("treatment_start_date")
  private String treatmentStartDate;

  /**
   * 終了日
   */
  @DynamoDBAttribute(attributeName="treatment_end_date")
  @Field("treatment_end_date")
  private String treatmentEndDate;

  /**
   * 曜日
   */
  @DynamoDBAttribute(attributeName="treatment_weekday")
  @Field("treatment_weekday")
  private String treatmentWeekday;

  /**
   * 治療方法
   */
  @DynamoDBAttribute(attributeName="treatment_method")
  @Field("treatment_method")
  private String treatmentMethod;

  /**
   * クール
   */
  @DynamoDBAttribute(attributeName="treatment_course")
  @Field("treatment_course")
  private String treatmentCourse;

  /**
   * 対象
   */
  @DynamoDBAttribute(attributeName="log_target")
  @Field("log_target")
  private String logTarget;

  /**
   * 対象ソート順
   */
  @DynamoDBAttribute(attributeName="sort_no")
  @Field("sort_no")
  private Integer sortNo;

  /**
   * 操作区分
   */
  @DynamoDBAttribute(attributeName="log_class")
  @Field("log_class")
  private String logClass;

  /**
   * 内容
   */
  @DynamoDBAttribute(attributeName="log_content")
  @Field("log_content")
  private String logContent;

	/**
	 * 指示受け者1
	 */
	@DynamoDBAttribute(attributeName = "receiver_1")
	@Field("receiver_1")
	private String receiver1;

	/**
	 * 指示受け日1
	 */
	@DynamoDBAttribute(attributeName = "receive_date1")
	@Field("receive_date1")
	private String receiveDate1;

	/**
	 * 指示受け者1
	 */
	@DynamoDBAttribute(attributeName = "receiver_2")
	@Field("receiver_2")
	private String receiver2;

	/**
	 * 指示受け日1
	 */
	@DynamoDBAttribute(attributeName = "receive_date2")
	@Field("receive_date2")
	private String receiveDate2;

	/**
	 * 指示承認者1
	 */
	@DynamoDBAttribute(attributeName = "approver_1")
	@Field("approver_1")
	private String approver1;

	/**
	 * 指示承認日1
	 */
	@DynamoDBAttribute(attributeName = "approval_date1")
	@Field("approval_date1")
	private String approvalDate1;

	/**
	 * 指示承認者1
	 */
	@DynamoDBAttribute(attributeName = "approver_2")
	@Field("approver_2")
	private String approver2;

	/**
	 * 指示承認日1
	 */
	@DynamoDBAttribute(attributeName = "approval_date2")
	@Field("approval_date2")
	private String approvalDate2;

  /**
   * 指示者
   */
  @DynamoDBAttribute(attributeName="created_by")
  @Field("created_by")
  private String createdBy;

  /**
   * 更新者
   */
  @DynamoDBAttribute(attributeName="updated_by")
  @Field("updated_by")
  private String updatedBy;

  /**
   * 指示者ID
   */
  @DynamoDBAttribute(attributeName="created_user_id")
  @Field("created_user_id")
  private Long createdUserId;

  /**
   * 更新者ID
   */
  @DynamoDBAttribute(attributeName="updated_user_id")
  @Field("updated_user_id")
  private Long updatedUserId;
}
