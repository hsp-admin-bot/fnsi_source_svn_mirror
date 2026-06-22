package jp.co.nikkiso.ntss.admin_web.response.bvms.dto;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BVMSGraphInfoDTO {
    List<ErrorCellDTO> errorCells;
}
