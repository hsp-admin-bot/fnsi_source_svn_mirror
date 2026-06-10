package batch.entity;

import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBAttribute;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;

import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Field;

/**
 * 治療情報履歴
 */
@DynamoDBTable(tableName="ord_main_hst")
@Document(collection="ord_main_hst")
@Getter
@Setter
public class OrdMainHst {
    /**
     * ID
     */
    @DynamoDBHashKey(attributeName="_id")
    @Field("_id")
    private String Id;

    /**
     * システムで管理する一意なオーダ番号
     */
    @DynamoDBHashKey(attributeName="ord_no")
    @Field("ord_no")
    private String ordNo;

    /**
     * システムで管理する一意な患者ID
     */
    @DynamoDBHashKey(attributeName="pat_id")
    @Field("pat_id")
    private String patId;

    /**
     * FNW+で管理する施設内の一意な患者ID
     */
    @DynamoDBHashKey(attributeName="fn_pat_id")
    @Field("fn_pat_id")
    private String fnPatId;

    /**
     * 治療日
     */
    @DynamoDBHashKey(attributeName="treat_date")
    @Field("treat_date")
    private String treatDate;

    /**
     * 治療曜日
     */
    @DynamoDBAttribute(attributeName="treat_week")
    @Field("treat_week")
    private String treatWeek;

    /**
     * 患者コード
     */
    @DynamoDBAttribute(attributeName="facility_cd")
    @Field("facility_cd")
    private String facilityCd;

    /**
     * 施設名
     */
    @DynamoDBAttribute(attributeName="facility_name")
    @Field("facility_name")
    private String facilityName;

    /**
     * VAコード
     */
    @DynamoDBAttribute(attributeName="ind_va_cd")
    @Field("ind_va_cd")
    private String indVaCd;

    /**
     * 治療方法コード
     */
    @DynamoDBAttribute(attributeName="ind_treatment_cd")
    @Field("ind_treatment_cd")
    private String indTreatmentCd;

    /**
     * 治療方法名
     */
    @DynamoDBAttribute(attributeName="ind_treatment_name")
    @Field("ind_treatment_name")
    private String indTreatmentName;

    /**
     * クールコード
     */
    @DynamoDBAttribute(attributeName="ind_kur_cd")
    @Field("ind_kur_cd")
    private String indKurCd;

    /**
     * クール名
     */
    @DynamoDBAttribute(attributeName="ind_kur_name")
    @Field("ind_kur_name")
    private String indKurName;

    /**
     * 治療開始時刻
     */
    @DynamoDBAttribute(attributeName="ind_treat_start_time")
    @Field("ind_treat_start_time")
    private String indTreatStartTime;

    /**
     * ベッドコード
     */
    @DynamoDBAttribute(attributeName="ind_bed_cd")
    @Field("ind_bed_cd")
    private String indBedCd;

    /**
     * ベッド名
     */
    @DynamoDBAttribute(attributeName="ind_bed_name")
    @Field("ind_bed_name")
    private String indBedName;

    /**
     * 治療予定指示者情報
     */
    @DynamoDBAttribute(attributeName="ind_schedule_user_info")
    @Field("ind_schedule_user_info")
    private String indScheduleUserInfo;

    /**
     * 治療条件情報
     */
    @DynamoDBAttribute(attributeName="ind_cond_info")
    @Field("ind_cond_info")
    private String indCondInfo;

    /**
     * 投与薬剤情報
     */
    @DynamoDBAttribute(attributeName="ind_medi_info")
    @Field("ind_medi_info")
    private String indMediInfo;

    /**
     * 医療材料情報
     */
    @DynamoDBAttribute(attributeName="ind_equip_info")
    @Field("ind_equip_info")
    private String indEquipInfo;

    /**
     * 指示コメント情報
     */
    @DynamoDBAttribute(attributeName="ind_ind_comment_info")
    @Field("ind_ind_comment_info")
    private String indIndCommentInfo;

    /**
     * 風袋補正
     */
    @DynamoDBAttribute(attributeName="ind_tare_info")
    @Field("ind_tare_info")
    private String indTareInfo;

    /**
     * 除水補正
     */
    @DynamoDBAttribute(attributeName="ind_off_water_info")
    @Field("ind_off_water_info")
    private String indOffWaterInfo;

    /**
     * 装置設定情報
     */
    @DynamoDBAttribute(attributeName="ind_device_set_info")
    @Field("ind_device_set_info")
    private String indDeviceSetInfo;

    /**
     * FNW+透析番号
     */
    @DynamoDBAttribute(attributeName="rst_fn_dialysis_no")
    @Field("rst_fn_dialysis_no")
    private String rstFnDialysisNo;

    /**
     * 関連透析番号
     */
    @DynamoDBAttribute(attributeName="rst_relation_dialysis_no")
    @Field("rst_relation_dialysis_no")
    private String rstRelationDialysisNo;

    /**
     * 版番号
     */
    @DynamoDBAttribute(attributeName="rst_edition")
    @Field("rst_edition")
    private String rstEdition;

    /**
     * 版番号更新フラグ
     */
    @DynamoDBAttribute(attributeName="rst_is_update_edition")
    @Field("rst_is_update_edition")
    private String rstIsUpdateEdition;

    /**
     * 登録区分
     */
    @DynamoDBAttribute(attributeName="rst_input_class")
    @Field("rst_input_class")
    private String rstInputClass;

    /**
     * 治療状況
     */
    @DynamoDBAttribute(attributeName="rst_dialysis_state")
    @Field("rst_dialysis_state")
    private String rstDialysisState;

    /**
     * 治療方法コード
     */
    @DynamoDBAttribute(attributeName="rst_treatment_cd")
    @Field("rst_treatment_cd")
    private String rstTreatmentCd;

    /**
     * 治療方法名
     */
    @DynamoDBAttribute(attributeName="rst_treatment_name")
    @Field("rst_treatment_name")
    private String rstTreatmentName;

    /**
     * クールコード
     */
    @DynamoDBAttribute(attributeName="rst_kur_cd")
    @Field("rst_kur_cd")
    private String rstKurCd;

    /**
     * クール名
     */
    @DynamoDBAttribute(attributeName="rst_kur_name")
    @Field("rst_kur_name")
    private String rstKurName;

    /**
     * ベッドコード
     */
    @DynamoDBAttribute(attributeName="rst_bed_cd")
    @Field("rst_bed_cd")
    private String rstBedCd;

    /**
     * ベッド名
     */
    @DynamoDBAttribute(attributeName="rst_bed_name")
    @Field("rst_bed_name")
    private String rstBedName;

    /**
     * 装置番号
     */
    @DynamoDBAttribute(attributeName="rst_machine_no")
    @Field("rst_machine_no")
    private String rstMachineNo;

    /**
     * 装置名
     */
    @DynamoDBAttribute(attributeName="rst_machine_name")
    @Field("rst_machine_name")
    private String rstMachineName;

    /**
     * 条件送信日時
     */
    @DynamoDBAttribute(attributeName="rst_cond_send_date")
    @Field("rst_cond_send_date")
    private String rstCondSendDate;

    /**
     * 受付日時
     */
    @DynamoDBAttribute(attributeName="rst_accept_date")
    @Field("rst_accept_date")
    private String rstAcceptDate;

    /**
     * 治療開始日時
     */
    @DynamoDBAttribute(attributeName="rst_start_date")
    @Field("rst_start_date")
    private String rstStartDate;

    /**
     * 治療終了日時
     */
    @DynamoDBAttribute(attributeName="rst_end_date")
    @Field("rst_end_date")
    private String rstEndDate;

    /**
     * 帰宅日時
     */
    @DynamoDBAttribute(attributeName="rst_return_home_date")
    @Field("rst_return_home_date")
    private String rstReturnHomeDate;

    /**
     * 入外区分
     */
    @DynamoDBAttribute(attributeName="rst_in_out_class")
    @Field("rst_in_out_class")
    private String rstInOutClass;

    /**
     * 透析回数
     */
    @DynamoDBAttribute(attributeName="rst_dialysis_cnt")
    @Field("rst_dialysis_cnt")
    private String rstDialysisCnt;

    /**
     * 病棟コード
     */
    @DynamoDBAttribute(attributeName="rst_ward_cd")
    @Field("rst_ward_cd")
    private String rstWardCd;

    /**
     * 病棟名
     */
    @DynamoDBAttribute(attributeName="rst_ward_name")
    @Field("rst_ward_name")
    private String rstWardName;

    /**
     * 診療科コード
     */
    @DynamoDBAttribute(attributeName="rst_course_cd")
    @Field("rst_course_cd")
    private String rstCourseCd;

    /**
     * 診療科名
     */
    @DynamoDBAttribute(attributeName="rst_course_name")
    @Field("rst_course_name")
    private String rstCourseName;

    /**
     * 治療記録の治療条件で入力された場合にDWを更新
     */
    @DynamoDBAttribute(attributeName="rst_dw")
    @Field("rst_dw")
    private String rstDw;

    /**
     * 穿刺者情報
     */
    @DynamoDBAttribute(attributeName="rst_puncture_user_info")
    @Field("rst_puncture_user_info")
    private String rstPunctureUserInfo;

    /**
     * 返血者情報
     */
    @DynamoDBAttribute(attributeName="rst_return_user_info")
    @Field("rst_return_user_info")
    private String rstReturnUserInfo;

    /**
     * 担当者情報
     */
    @DynamoDBAttribute(attributeName="rst_charge_user_info")
    @Field("rst_charge_user_info")
    private String rstChargeUserInfo;

    /**
     * 血液循環積算値
     */
    @DynamoDBAttribute(attributeName="rst_blood_circulate_total")
    @Field("rst_blood_circulate_total")
    private String rstBloodCirculateTotal;

    /**
     * 透析運転時間
     */
    @DynamoDBAttribute(attributeName="rst_running_time")
    @Field("rst_running_time")
    private String rstRunningTime;

    /**
     * Kt/V
     */
    @DynamoDBAttribute(attributeName="rst_kt_v")
    @Field("rst_kt_v")
    private String rstKtV;

    /**
     * 透析記録確認日時
     */
    @DynamoDBAttribute(attributeName="rec_set_date")
    @Field("rec_set_date")
    private String recSetDate;

    /**
     * 送信管理番号
     */
    @DynamoDBAttribute(attributeName="send_ctl_no")
    @Field("send_ctl_no")
    private String sendCtlNo;

    /**
     * 血液浄化装置名称
     */
    @DynamoDBAttribute(attributeName="blood_purifier_name")
    @Field("blood_purifier_name")
    private String bloodPurifierName;

    /**
     * プログラム補液引き残し量
     */
    @DynamoDBAttribute(attributeName="pull_leave_amount")
    @Field("pull_leave_amount")
    private String pullLeaveAmount;

    /**
     * 治療条件情報
     */
    @DynamoDBAttribute(attributeName="rst_cond_info")
    @Field("rst_cond_info")
    private String rstCondInfo;

    /**
     * 投与薬剤情報
     */
    @DynamoDBAttribute(attributeName="rst_medi_info")
    @Field("rst_medi_info")
    private String rstMediInfo;

    /**
     * 医療材料情報
     */
    @DynamoDBAttribute(attributeName="rst_equip_info")
    @Field("rst_equip_info")
    private String rstEquipInfo;

    /**
     * 指示コメント情報
     */
    @DynamoDBAttribute(attributeName="rst_ind_comment_info")
    @Field("rst_ind_comment_info")
    private String rstIndCommentInfo;

    /**
     * 風袋補正
     */
    @DynamoDBAttribute(attributeName="rst_tare_info")
    @Field("rst_tare_info")
    private String rstTareInfo;

    /**
     * 除水補正
     */
    @DynamoDBAttribute(attributeName="rst_off_water_info")
    @Field("rst_off_water_info")
    private String rstOffWaterInfo;

    /**
     * 体重測定記録番号
     */
    @DynamoDBAttribute(attributeName="weight_scale_no")
    @Field("weight_scale_no")
    private String weightScaleNo;

    /**
     * 体重情報
     */
    @DynamoDBAttribute(attributeName="rst_weight_info")
    @Field("rst_weight_info")
    private String rstWeightInfo;

    /**
     * 愁訴情報
     */
    @DynamoDBAttribute(attributeName="rst_complaint_info")
    @Field("rst_complaint_info")
    private String rstComplaintInfo;

    /**
     * 愁訴処置情報
     */
    @DynamoDBAttribute(attributeName="rst_treatment_info")
    @Field("rst_treatment_info")
    private String rstTreatmentInfo;

    /**
     * 愁訴処置者情報
     */
    @DynamoDBAttribute(attributeName="rst_treat_staff_info")
    @Field("rst_treat_staff_info")
    private String rstTreatStaffInfo;

    /**
     * 回診記録情報
     */
    @DynamoDBAttribute(attributeName="rst_rounds_info")
    @Field("rst_rounds_info")
    private String rstRoundsInfo;

    /**
     * 削除フラグ
     */
    @DynamoDBAttribute(attributeName="is_del")
    @Field("is_del")
    private String isDel;

    /**
     * 更新日時
     */
    @DynamoDBAttribute(attributeName="up_date")
    @Field("up_date")
    private String upDate;

    /**
     * 登録日時
     */
    @DynamoDBAttribute(attributeName="reg_date")
    @Field("reg_date")
    private String regDate;

    /**
     * FNW+同日複数回
     */
    @DynamoDBAttribute(attributeName="fn_plural")
    @Field("fn_plural")
    private String fnPlural;

    /**
     * 治療種別
     */
    @DynamoDBAttribute(attributeName="treat_type")
    @Field("treat_type")
    private String treatType;

    /**
     * 確定フラグ
     */
    @DynamoDBAttribute(attributeName="is_confirm")
    @Field("is_confirm")
    private String isConfirm;

    /**
     * 条件送信時に身体情報のDWを展開する
     */
    @DynamoDBAttribute(attributeName="ind_dw")
    @Field("ind_dw")
    private String indDw;

    /**
     * 特殊浄化回数
     */
    @DynamoDBAttribute(attributeName="rst_purification_cnt")
    @Field("rst_purification_cnt")
    private String rstPurificationCnt;

    /**
     * 加算情報
     */
    @DynamoDBAttribute(attributeName="addition_info")
    @Field("addition_info")
    private String additionInfo;

    /**
     * 作成日時
     */
    @DynamoDBAttribute(attributeName="ins_date")
    @Field("ins_date")
    private String insDate;

}
