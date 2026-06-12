package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.destinationGroup.DestinationGroupNameResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.DestinationGroupService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.dao.MstDestinationGroupDao;
import jp.co.nikkiso.ntss.core.entity.MstDestinationGroup;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(Uri.DESTINATION_GROUP)
@Slf4j
public class DestinationGroupResource {

  @Autowired
  private DestinationGroupService destinationGroupService;
  @Autowired
  LogEventUtils logEventUtils;
  @Autowired
  MstDestinationGroupDao mstDestinationGroupDao;

  private ResponseEntity<DestinationGroupNameResponse> validateGroupAccess(NtssUser ntssUser,
      Long destinationGroupCd) {
    if (ntssUser == null || ntssUser.isNkkAdminUser()) {
      return null;
    }
    MstDestinationGroup mstDestinationGroup = mstDestinationGroupDao.selectByDestinationGroupCd(destinationGroupCd);
    if (mstDestinationGroup != null && mstDestinationGroup.getFacilityCd() != null
        && !mstDestinationGroup.getFacilityCd().equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstDestinationGroup.getFacilityCd() + " " + "destinationGroupCd=" + destinationGroupCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    return null;
  }

  @GetMapping("/{destinationGroupCd}/name")
  public ResponseEntity<DestinationGroupNameResponse> getDestinationGroupName(
      @PathVariable Long destinationGroupCd,
      @AuthenticationPrincipal NtssUser ntssUser) {
    ResponseEntity<DestinationGroupNameResponse> authError = validateGroupAccess(ntssUser, destinationGroupCd);
    if (authError != null) {
      return authError;
    }

    String mappingUrl = Uri.DESTINATION_GROUP;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
        destinationGroupCd);
    DestinationGroupNameResponse destinationGroupNameResponse =
        destinationGroupService.createDestinationGroupNameResponse(destinationGroupCd);

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        destinationGroupCd);
    return new ResponseEntity<>(destinationGroupNameResponse, HttpStatus.OK);
  }

  private String getClassName() {
    return this.getClass().getName();
  }

  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }
}
