package jp.co.nikkiso.ntss.admin_web.response.bvms.dto;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class BVMSGraphDTO {
    private List<ErrorCellDTO> errorCells;
    List<BVMSRowDTO> rows;
}
