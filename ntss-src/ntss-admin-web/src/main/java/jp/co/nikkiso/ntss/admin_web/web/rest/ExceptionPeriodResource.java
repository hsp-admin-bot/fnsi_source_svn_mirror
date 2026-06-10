package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import jp.co.nikkiso.ntss.admin_web.response.exceptionPeriod.ExceptionPeriodResponse;
import jp.co.nikkiso.ntss.admin_web.service.exceptionPeriod.ExceptionPeriodService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


import java.util.List;

@RestController
@RequestMapping(AdminWebConstant.Uri.EXCEPTION_PERIOD)
public class ExceptionPeriodResource {
  @Autowired
  private ExceptionPeriodService ExceptionPeriodService;

  @GetMapping("{pat_id}/{facility_cd}")
  public ResponseEntity<?> getOrdExceptionPeriod( @PathVariable Long pat_id, @PathVariable String facility_cd) {

    List<ExceptionPeriodResponse> res = ExceptionPeriodService.selectOrdExceptionPeriod(facility_cd, pat_id);

    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  @PostMapping("/saveExceptionPeriod")
  public ResponseEntity<?> saveMultiWaterSurvey(@RequestBody List<ExceptionPeriodResponse> exceptionPeriodList,
                                                @AuthenticationPrincipal NtssUser ntssUser) {

    int res = ExceptionPeriodService.updateOrdExceptionPeriod(exceptionPeriodList, ntssUser);

    return new ResponseEntity<>(res, HttpStatus.OK);
  }
}
