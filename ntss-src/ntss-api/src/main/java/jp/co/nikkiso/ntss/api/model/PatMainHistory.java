package jp.co.nikkiso.ntss.api.model;


import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBAttribute;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;
import jp.co.nikkiso.ntss.api.model.patMainHistoryDetail.AdditionInfo;
import jp.co.nikkiso.ntss.api.model.patMainHistoryDetail.ChargeStaffInfo;
import jp.co.nikkiso.ntss.api.model.patMainHistoryDetail.ImplantInfo;
import jp.co.nikkiso.ntss.api.model.patMainHistoryDetail.InfectInfo;
import jp.co.nikkiso.ntss.api.model.patMainHistoryDetail.MedicalCareInfo;
import jp.co.nikkiso.ntss.api.model.patMainHistoryDetail.PatGroupInfo;
import jp.co.nikkiso.ntss.api.model.patMainHistoryDetail.PatMemoInfo;
import jp.co.nikkiso.ntss.api.model.patMainHistoryDetail.TabooAllergyInfo;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;
import java.util.List;

// add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
@DynamoDBTable(tableName = "pat_main_history")
@Document(collection = "pat_main_history")
@Getter
@Setter
public class PatMainHistory {

    @DynamoDBHashKey(attributeName = "_id")
    @Field("_id")
    private String _id;

    /**
     * 患者コード
     */
    @DynamoDBHashKey(attributeName = "pat_id")
    @Field("pat_id")
    private String pat_id;

    /**
     * 施設コード
     */
    @DynamoDBAttribute(attributeName = "facility_cd")
    @Field("facility_cd")
    private String facility_cd;

    @DynamoDBAttribute(attributeName = "is_same")
    @Field("is_same")
    private String is_same;

    @DynamoDBAttribute(attributeName = "is_implant")
    @Field("is_implant")
    private String is_implant;

    @DynamoDBAttribute(attributeName = "is_infect")
    @Field("is_infect")
    private String is_infect;

    @DynamoDBAttribute(attributeName = "is_diabetes")
    @Field("is_diabetes")
    private String is_diabetes;
    // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    @DynamoDBAttribute(attributeName = "is_blood_suger_exam")
    @Field("is_blood_suger_exam")
    private String is_blood_suger_exam = "";
    // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    @DynamoDBAttribute(attributeName="dialysis_underlying_disease")
    @Field("dialysis_underlying_disease")
    private String dialysis_underlying_disease = "";
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    @DynamoDBAttribute(attributeName = "in_out_current_state")
    @Field("in_out_current_state")
    private String in_out_current_state = "";

    @DynamoDBAttribute(attributeName = "in_out_plan_state")
    @Field("in_out_plan_state")
    private String in_out_plan_state = "";

    /* modify by chamaojia 2023-08-07 [9239] データ型の変更  --start */
    @DynamoDBAttribute(attributeName = "in_out_plan_date")
    @Field("in_out_plan_date")
//  private Timestamp in_out_plan_date = new Timestamp(0);
    private Date in_out_plan_date = new Date();
    /* modify by chamaojia 2023-08-07 [9239] データ型の変更  --end */

    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    @DynamoDBAttribute(attributeName = "pat_memo_info")
    @Field("pat_memo_info")
    //  private String pat_memo_info;
    private List<PatMemoInfo> pat_memo_info;

    @DynamoDBAttribute(attributeName = "addition_info")
    @Field("addition_info")
    //  private String addition_info;
    private List<AdditionInfo> addition_info;

    @DynamoDBAttribute(attributeName = "charge_staff_info")
    @Field("charge_staff_info")
    //  private String charge_staff_info;
    private List<ChargeStaffInfo> charge_staff_info;

    @DynamoDBAttribute(attributeName = "pat_group_info")
    @Field("pat_group_info")
    //  private String pat_group_info;
    private List<PatGroupInfo> pat_group_info;

    @DynamoDBAttribute(attributeName = "taboo_allergy_info")
    @Field("taboo_allergy_info")
    //  private String taboo_allergy_info;
    private List<TabooAllergyInfo> taboo_allergy_info;

    @DynamoDBAttribute(attributeName = "infect_info")
    @Field("infect_info")
    //  private String infect_info;
    private List<InfectInfo> infect_info;

    @DynamoDBAttribute(attributeName = "implant_info")
    @Field("implant_info")
    //  private String implant_info;
    private List<ImplantInfo> implant_info;
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

    @DynamoDBAttribute(attributeName = "tare_info")
    @Field("tare_info")
    private String tare_info;

    @DynamoDBAttribute(attributeName = "off_water_info")
    @Field("off_water_info")
    private String off_water_info;

    @DynamoDBAttribute(attributeName = "device_set_info")
    @Field("device_set_info")
    private String device_set_info;

    @DynamoDBAttribute(attributeName = "acceptance_status_info")
    @Field("acceptance_status_info")
    private String acceptance_status_info;

    @DynamoDBAttribute(attributeName = "is_del")
    @Field("is_del")
    private String is_del;

    @DynamoDBAttribute(attributeName = "up_date")
    @Field("up_date")
    private String up_date;

    @DynamoDBAttribute(attributeName = "reg_date")
    @Field("reg_date")
    private String reg_date;

    @DynamoDBAttribute(attributeName = "is_wheel_chair")
    @Field("is_wheel_chair")
    private String is_wheel_chair;

    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    @DynamoDBAttribute(attributeName = "medical_care_info")
    @Field("medical_care_info")
    // private String medical_care_info;
    private MedicalCareInfo medical_care_info;
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

    @DynamoDBAttribute(attributeName = "sch_ext_end_date")
    @Field("sch_ext_end_date")
    private String sch_ext_end_date;

    @DynamoDBAttribute(attributeName = "sch_ext_status")
    @Field("sch_ext_status")
    private String sch_ext_status;

    @DynamoDBAttribute(attributeName = "ins_date")
    @Field("ins_date")
    private Date ins_date = new Date();

    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
    @DynamoDBAttribute(attributeName="facility_name")
    @Field("facility_name")
    private String facility_name;
    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

    // add #10210 帳票における患者情報の取得元について limingzhe start
    @DynamoDBAttribute(attributeName="host_notification_info")
    @Field("host_notification_info")
    private String host_notification_info;

    @DynamoDBAttribute(attributeName="wheel_chair_cd")
    @Field("wheel_chair_cd")
    private Long wheel_chair_cd;

    @DynamoDBAttribute(attributeName="wheel_chair_name")
    @Field("wheel_chair_name")
    private String wheel_chair_name;

    @DynamoDBAttribute(attributeName="wheel_chair_weight")
    @Field("wheel_chair_weight")
    private Integer wheel_chair_weight;
    // add #10210 帳票における患者情報の取得元について limingzhe end

    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    @DynamoDBAttribute(attributeName="card_idm")
    @Field("card_idm")
    private String card_idm;
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end

    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    @DynamoDBAttribute(attributeName="latest_flag")
    @Field("latest_flag")
    private String latest_flag;
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
}
// add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
