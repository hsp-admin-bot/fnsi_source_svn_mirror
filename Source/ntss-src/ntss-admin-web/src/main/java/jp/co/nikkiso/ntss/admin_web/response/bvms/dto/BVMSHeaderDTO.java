package jp.co.nikkiso.ntss.admin_web.response.bvms.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.math.BigDecimal;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class BVMSHeaderDTO {
    /**
     * 西暦下2桁
     */
    private Long lastTwoDigits;
    /**
     * 月
     */
    private Long month;
    /**
     * 日
     */
    private Long day;
    /**
     * 透析前体重
     */
    private BigDecimal weightBeforeDialysis;
    /**
     * 装置型式
     */
    private String equipmentModel;
    /**
     * バージョン
     */
    private String version;
    /**
     * サブバージョン
     */
    private Long subVersion;

    /**
     * 患者名
     */
    private String patientName;
    /**
     * 装置製造番号
     */
    private Long equipmentSerialNumber;
    /**
     * DDM校正時透過AD値
     */
    private Long transmittedADValue;
    /**
     * DDM校正時参照AD値
     */
    private Long referenceAdValue;
    /**
     * 発生日時
     */
    private Long dateTime;
    /**
     * 工程
     */
    private Long process;
    /**
     * ΔBV値
     */
    private BigDecimal aBVValue;
    /**
     * 除水速度
     */
    private BigDecimal dewateringSpeed;
    /**
     * 除水量積算値(L) 除水積算
     */
    private BigDecimal waterRemovalIntegratedValue;
    /**
     * 血流量(mL/min)
     */
    private Long booldFlow;
    /**
     * 透析液濃度(mS/cm)
     */
    private BigDecimal dialysateConcentration;
    /**
     * 最高血圧(mmHg)
     */
    private Long systolicBloodPressure;

    /**
     * 最低血圧(mmHg)
     */
    private Long diastolicBloodPressure;
    /**
     * 最低血圧(mmHg) private Long diastolicBloodPressure; /** 脈拍(bpm)
     */
    private Long pulseWithNoHeader;
}
