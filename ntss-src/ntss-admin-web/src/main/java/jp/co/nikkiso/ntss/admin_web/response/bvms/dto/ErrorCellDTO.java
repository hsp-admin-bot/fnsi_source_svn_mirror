package jp.co.nikkiso.ntss.admin_web.response.bvms.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class ErrorCellDTO {
    private Long row;
    private Integer column;
    private String errorMessage;
    private String value;
}
