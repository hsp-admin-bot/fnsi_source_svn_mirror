package jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ht;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.CoordinateDTO;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HtGraph1CoordinateDTO{

    /**
     * Ht(%)*10
     */
    private List<CoordinateDTO> hts;

    /**
     * 最高血圧(mmHg)
     */
    private List<CoordinateDTO> sysBPs;
    /**
     * 最低血圧(mmHg)
     */
    private List<CoordinateDTO> diaBPs;

    /**
     * イベントID
     */
    private List<CoordinateDTO> events;

    /**
     * 脈拍(bpm)
     */
    private List<CoordinateDTO> pulses;
}
