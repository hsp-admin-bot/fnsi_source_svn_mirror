package jp.co.nikkiso.ntss.admin_web.response.bvms.dto.bv;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.CoordinateDTO;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BVGraph1CoordinateDTO{
    /**
     * ΔBV値(%)*10
     */
    private List<CoordinateDTO> dBVs;
    /**
     * ΔBV基準値(%)*10
     */
    private List<CoordinateDTO> dBVBaseValues;

    private List<CoordinateDTO> dBVReferenceAreaUpperLimits;
    private List<CoordinateDTO> dBVReferenceAreaLowerLimits;
    private List<CoordinateDTO> dBVAVR5mins;

    /**
     * 最高血圧(mmHg)
     */
    private List<CoordinateDTO> sysBPs;
    /**
     * 最低血圧(mmHg)
     */
    private List<CoordinateDTO> diaBPs;

    /**
     * 脈拍(bpm)
     */
    private List<CoordinateDTO> pulses;
    /**
     * イベントID
     */
    private List<CoordinateDTO> events;
}
