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
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

@RestController
@RequestMapping(AdminWebConstant.Uri.EXCEPTION_PERIOD)
public class ExceptionPeriodResource {
  @Autowired
  private ExceptionPeriodService ExceptionPeriodService;

  @GetMapping("{pat_id}/{facility_cd}")
  public ResponseEntity<?> getOrdExceptionPeriod( @PathVariable Long pat_id,
                                                  @PathVariable String facility_cd,
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                  @AuthenticationPrincipal NtssUser ntssUser
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facility_cd != null && !facility_cd.isEmpty() &&
          !facility_cd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facility_cd=" + facility_cd + " " + "pat_id=" + pat_id + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    List<ExceptionPeriodResponse> res = ExceptionPeriodService.selectOrdExceptionPeriod(facility_cd, pat_id);

    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  @PostMapping("/saveExceptionPeriod")
  public ResponseEntity<?> saveMultiWaterSurvey(@RequestBody List<ExceptionPeriodResponse> exceptionPeriodList,
                                                @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        for (ExceptionPeriodResponse exceptionPeriodResponse : exceptionPeriodList) {
          String facilityCd = exceptionPeriodResponse.getFacilityCd();
          if (facilityCd != null && !facilityCd.isEmpty() &&
            !facilityCd.equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "pat_id=" + exceptionPeriodResponse.getPatId() + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
          }
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    int res = ExceptionPeriodService.updateOrdExceptionPeriod(exceptionPeriodList, ntssUser);

    return new ResponseEntity<>(res, HttpStatus.OK);
  }
}
