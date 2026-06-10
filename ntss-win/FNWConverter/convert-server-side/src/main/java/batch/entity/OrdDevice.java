package batch.entity;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class OrdDevice {
    /**
     * システムで管理する一意なオーダ番号
     */
    private Long ordNo;

    /**
     * FNW+で管理する施設内の一意な装置番号
     */
    private Integer fnDeviceNo;

    /**
     * 実績：治療開始日時
     */
    private Timestamp rstAcceptDate;

    /**
     * 実績：治療終了日時
     */
    private Timestamp rstEndDate;

    // add #11781 mnt_motion_record.ord_no修正　limingyang start
    /**
     * 実績：FNW+透析番号
     */
    private Long rstFnDialysisNo;
    // add #11781 mnt_motion_record.ord_no修正　limingyang end
}
