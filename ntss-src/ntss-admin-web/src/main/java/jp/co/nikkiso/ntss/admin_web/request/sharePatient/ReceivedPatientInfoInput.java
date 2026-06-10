package jp.co.nikkiso.ntss.admin_web.request.sharePatient;

import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.custom.ReceivedPatientInfo;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReceivedPatientInfoInput extends ReceivedPatientInfo {
    private Map<String, String> payload;
    /**
     * 院内患者ID .
     */
    private String hospPatId;

    /**
     * 患者名.
     */
    private String patName;
}
