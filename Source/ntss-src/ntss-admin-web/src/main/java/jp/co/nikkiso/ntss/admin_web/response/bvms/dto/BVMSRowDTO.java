package jp.co.nikkiso.ntss.admin_web.response.bvms.dto;

import java.math.BigDecimal;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class BVMSRowDTO {
    private Long row;
    /**
     * 測定時刻(時)
     */
    private Integer hour;
    /**
     * 測定時刻(分)
     */
    private Integer min;
    /**
     * 測定時刻(秒)
     */
    private Integer sec;
    /**
     * 経過時間(sec)
     */
    private BigDecimal treatTime;
    /**
     * ΔBV値(%)*10
     */
    private BigDecimal dBV;
    /**
     * ΔBV基準値(%)*10
     */
    private BigDecimal dBVBaseValue;
    /**
     * 除水速度(L/h)*100
     */
    private BigDecimal uFPSpeed;
    /**
     * 除水量積算値(L)*100
     */
    private BigDecimal uFVolume;
    /**
     * 血流量(mL/min)
     */
    private BigDecimal bPSpeed;
    /**
     * 透析液濃度(mS/cm)*10
     */
    private BigDecimal totalCond;
    /**
     * 最高血圧(mmHg)
     */
    private BigDecimal sysBP;
    /**
     * 最低血圧(mmHg)
     */
    private BigDecimal diaBP;
    /**
     * 脈拍(bpm)
     */
    private BigDecimal pulse;
    /**
     * イベントID
     */
    private BigDecimal event;
    private BigDecimal bloodFlowVolume;
    private BigDecimal dBVReferenceAreaUpperLimit;
    private BigDecimal dBVReferenceAreaLowerLimit;
    private BigDecimal dBVAVR5min;
    /**
     * 再循環率(%)
     */
    private BigDecimal recirculationRate;
    private BigDecimal pRR;
    /**
     * Kt/V*100
     */
    private BigDecimal ktV;
    /**
     * URR(%)*10
     */
    private BigDecimal uRR;
    /**
     * 透析液流量(mL/min)
     */
    private BigDecimal dP;
    /**
     * 補液速度
     */
    private BigDecimal qs;
    /**
     * 治療モード
     */
    private BigDecimal treatMode;
    private BigDecimal estimateBloodFlow;
    private BigDecimal drainAbs;
    private BigDecimal bVUFCStepNo;
    /**
     * LDQb(mL/min)
     */
    private BigDecimal lDQb;
    /**
     * Ht(%)*10
     */
    private BigDecimal ht;
    private BigDecimal star;
    private BigDecimal s;
    private BigDecimal ia;
    private BigDecimal ra;
    private BigDecimal ga;
    private BigDecimal iv;
    /**
     * Kc
     */
    private BigDecimal kc;
    /**
     * TIS
     */
    private BigDecimal tis;
    /**
     * RIS
     */
    private BigDecimal ris;
    private BigDecimal ic;
    private BigDecimal artPressAve;

    /**
     * ヘッダー文字列の無いこれらの項
     */
    private BVMSHeaderDTO bvmsHeaderDTO;
    private List<ErrorCellDTO> errorColumns;
}
