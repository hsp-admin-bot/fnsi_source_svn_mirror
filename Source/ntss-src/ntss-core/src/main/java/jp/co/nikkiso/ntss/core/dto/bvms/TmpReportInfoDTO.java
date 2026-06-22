package jp.co.nikkiso.ntss.core.dto.bvms;

import lombok.Data;

@Data
public class TmpReportInfoDTO {

    /**
     * 最高血圧(mmHg)
     */
    private RangeDTO sysBP;
    /**
     * 最低血圧(mmHg)
     */
    private RangeDTO diaBP;

    /**
     * 脈拍(bpm)
     */
    private RangeDTO pulse;
}
