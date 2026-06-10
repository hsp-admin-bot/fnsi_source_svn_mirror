import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  async list(condition = {}) {
    try {
      const res = await ApiHelper.post(
        "/mainData/getOrdSearchResult",
        condition
      );
      return res.data;
    } catch (error) {
      throw error;
    }
  },
  async getIndicationDetail(ordNo) {
    try {
      const [ordMainRes, patIndApproveRes] = await Promise.all([
        ApiHelper.get(`/mainData/getOrdMainByOrdNo/${ordNo}`),
        ApiHelper.get(`/patIndApprove/${ordNo}`)
      ]);

      return [
        ordMainRes.data,
        //#10407:変更なしでも画面を表示させる Start
        patIndApproveRes.data.pat_ind_approve != undefined ? JSON.parse(patIndApproveRes.data.pat_ind_approve) : null
        //#10407:変更なしでも画面を表示させる End

      ];
    } catch (error) {
      throw error;
    }
  },
  check(ordNo, { checker1Id, checker2Id, checkContent }) {
    return ApiHelper.put(`/patIndApprove/check/${ordNo}`, {
      pat_ind_approve: JSON.stringify({
        check_user1_cd: checker1Id,
        check_user2_cd: checker2Id,
        check_content: checkContent
      })
    });
  },
  check1(param) {
    return ApiHelper.put(`/patIndApprove/check1`, {
      pat_ind_approve: JSON.stringify(param)
    });
  },
  check2(param) {
    return ApiHelper.put(`/patIndApprove/check2`, {
      pat_ind_approve: JSON.stringify(param)
    });
  },
  approve(ordNo, { approver1Id, approver2Id, approveContent }) {
    return ApiHelper.put(`/patIndApprove/approve/${ordNo}`, {
      pat_ind_approve: JSON.stringify({
        approve_user1_cd: approver1Id,
        approve_user2_cd: approver2Id,
        approve_content: approveContent
      })
    });
  },
  approve1(param) {
    return ApiHelper.put(`/patIndApprove/approve1`, {
      pat_ind_approve: JSON.stringify(param)
    });
  },
  approve2(param) {
    return ApiHelper.put(`/patIndApprove/approve2`, {
      pat_ind_approve: JSON.stringify(param)
    });
  },
  // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
  // bulkCheck1(payload) {
  //   return ApiHelper.put(`/patIndApprove/bulkCheck1`, {
  //       pat_ind_approve_list: JSON.stringify(payload)
  //   });
  // },
  // bulkCheck2(payload) {
  //   return ApiHelper.put(`/patIndApprove/bulkCheck2`, {
  //     pat_ind_approve_list: JSON.stringify(payload)
  // });
  // },
  //del #9507 一括指示受けに時間がかかる zrx start
  // bulkCheck1(payload, unchecked1Indications, facilityCd, userId) {
  //   return ApiHelper.put(`/patIndApprove/bulkCheck1`, {
  //     pat_ind_approve_list: JSON.stringify(payload),
  //     unchecked1Indications: JSON.stringify(unchecked1Indications),
  //     facility_cd: facilityCd,
  //     user_id: userId
  //   });
  // },
  // bulkCheck2(payload, unchecked2Indications, facilityCd, userId) {
  //   return ApiHelper.put(`/patIndApprove/bulkCheck2`, {
  //     pat_ind_approve_list: JSON.stringify(payload),
  //     unchecked2Indications: JSON.stringify(unchecked2Indications),
  //     facility_cd: facilityCd,
  //     user_id: userId
  //   });
  // },
  // // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
  // bulkApprove1(payload) {
  //   return ApiHelper.put(`/patIndApprove/bulkApprove1`, {
  //       pat_ind_approve_list: JSON.stringify(payload)
  //     }
  //   );
  // },
  // bulkApprove2(payload) {
  //   return ApiHelper.put(`/patIndApprove/bulkApprove2`, {
  //       pat_ind_approve_list: JSON.stringify(payload)
  //     }
  //   );
  // },
  //del #9507 一括指示受けに時間がかかる zrx end
  uncheck1(ordNo) {
    return ApiHelper.put(`/patIndApprove/uncheck1/${ordNo}`);
  },
  uncheck2(ordNo) {
    return ApiHelper.put(`/patIndApprove/uncheck2/${ordNo}`);
  },
  unapprove1(ordNo) {
    return ApiHelper.put(`/patIndApprove/unapprove1/${ordNo}`);
  },
  unapprove2(ordNo) {
    return ApiHelper.put(`/patIndApprove/unapprove2/${ordNo}`);
  },
  async searchList(condition = {}) {
    try {
      const res = await ApiHelper.post(
        "/indHistory/searchList",
        condition
      );
      return res.data;
    } catch (error) {
      throw error;
    }
  },
  async updIndHistoryList(param = {}) {
    try {
      const res = await ApiHelper.post(
        "/indHistory/updIndHistoryList",
        param
      );
      return res.data;
    } catch (error) {
      throw error;
    }
  },
  async searchDetail(param = {}) {
    try {
      const res = await ApiHelper.post(
        "/indHistory/searchDetail",
        param
      );
      return res.data;
    } catch (error) {
      throw error;
    }
  },
  async updIndHistoryDetail(param = {}) {
    try {
      const res = await ApiHelper.post(
        "/indHistory/updIndHistoryDetail",
        param
      );
      return res.data;
    } catch (error) {
      throw error;
    }
  },
  async insertPatIndApproveHistory(param = {}) {
    try {
      const res = await ApiHelper.post(
        "/patIndApproveHistory",
        param
      );
      return res.data;
    } catch (error) {
      throw error;
    }
  },
  //add #9507 一括指示受けに時間がかかる zrx start
  async bulkCheckOrApprove(param = {}) {
    try {
      const res = await ApiHelper.post(
        "/patIndApprove/bulkCheckOrApprove",
        param
      );
      return res.data;
    } catch (error) {
      throw error;
    }
  },
  //add #9507 一括指示受けに時間がかかる zrx end
// add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou start
  async getTreatmentConditionSetting(facilityCd, treatMethodName) {
    try {
      const treatmentConditionSetting = await ApiHelper.get(`/indication-result/getTreatmentConditionSetting/${facilityCd}/${treatMethodName}`);
      return treatmentConditionSetting.data;
    } catch (error) {
      throw error;
    }
  },
// add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou end
};
