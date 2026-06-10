/**
 * @description 指示者選択ドロップダウン用のMixin
 * @summary
 *   ■機能
 *     指示者選択ドロップダウン表示用に、
 *     ・医師のリスト
 *     ・初期選択指示者
 *     を返す
 *
 *   ■ 初期選択指示者
 *     ・サインイン者が医師＋編集権限あり = サインイン者がデフォルト選択状態
 *     ・サインイン者が医師＋代行編集あり = シフト医師＞デフォルト指示者が選択状態
 *     ・サインイン者が医師以外＋代行編集or編集権限あり = シフト医師＞デフォルト指示者が選択状態
 *     ・シフト医師、デフォルト医師が未設定
 *       シフト医師、デフォルト医師がリストに含まれていない(存在しない)
 *       = 未選択
 *
 * @example
 *   メソッドを呼び出す際に、呼び出し画面の権限コード(constants\userAuthority.jsに定義)の、
 *   編集権限、代行編集権限 を引数に入れてください
 *
 *   this.getIndUserList(AUTHORITY_CODES.IND_EXAM_EDIT, AUTHORITY_CODES.IND_EXAM_PEDIT)
 *     .then(response => {
 *       this.doctorList = response.doctorList;
 *       this.$nextTick(() => {
 *         this.selectDoctor = response.iniSelectId;
 *       });
 *   });
 *
 *   <!-- kendo-dropdownlist に取得データを指定 -->
 *   <kendo-dropdownlist
 *     v-model="selectDoctor"
 *     :data-source="doctorList"
 *     :data-text-field="'fullName'"
 *     :data-value-field="'user_id'">
 *   </kendo-dropdownlist>
 *
 */
import moment from "moment";
import { ApiHelper } from "@/apis/AxiosHelper";
import {
  sendRequestGetDoctorsAtFacility,
  // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
  sendRequestGetDoctorsAtFacilityIncludeDel
  // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
} from "@/apis/facility";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";

export default {
  methods: {
    /**
     * kendo-dropdownlist用の指示者リスト、初期選択指示者を返します.
     * @param authEditCd 表示画面の編集権限
     * @param authPEditCd 表示画面の代行編集権限
     * @returns {} 医師のリスト、初期選択指示者
     */
    async getIndUserList(authEditCd, authPEditCd, selectFacilityCd) {
      // const facilityCd = this.$store.getters["user/getFacilityCd"];
      const facilityCd = selectFacilityCd ? selectFacilityCd : this.$store.getters["user/getFacilityCd"];
      const userAuthorityCds = this.$store.getters["user/getUserAuthorityCds"];
      const userId = this.$store.getters["account-edit/getStateUserAccountInfo"].userId;
      let doctorFlg = false;
      let defaultDoctorId = null;
      let inUserId = null;
      let doctorList = [{ user_id: undefined, fullName: "" }];
      
      const [doctorResponse, defaultDoctor, shiftDoctorId] = await Promise.all([
        // 職種が医師の利用者一覧を取得
        sendRequestGetDoctorsAtFacility(facilityCd),
        // デフォルト指示者取得
        sendRequestGetMstFacilitySettingValue(facilityCd, "1025"),
        // シフト医師取得
        getShiftDoctor(facilityCd),
      ]);
      
      // 医師のリストを作成
      doctorResponse.data.forEach(doctor => {
        doctorList.push({
          ...doctor,
          fullName:  `${doctor.user_last_name} ${doctor.user_first_name}`
        });
        // 利用者が医師の場合：本人医師フラグを立てる
        if (doctor.user_id === userId) {
          doctorFlg = true;
        }
      });
      
      // 編集権限がなく、かつシフト医師/デフォルト指示医が一覧に含まれる場合：シフト医師/デフォルト指示医セット
      if (doctorList.some(d => d.user_id === shiftDoctorId)) {
        defaultDoctorId = shiftDoctorId; // シフト医師優先
      } else if (doctorList.some(d => d.user_id === defaultDoctor.data)) {
        defaultDoctorId = defaultDoctor.data;
      }

      // 本人医師 かつ編集権限がある場合：サインイン者がディフォルト選択状態
      if(doctorFlg && userAuthorityCds.includes(authEditCd)){
        inUserId = userId;
      }
      // add #10359 編集権限の動作不正 dengshen start
      else {
        inUserId = defaultDoctorId ? defaultDoctorId : undefined;
      }
      // add #10359 編集権限の動作不正 dengshen end

      return {
        // 初期選択指示者
        iniSelectId: inUserId,
        // 医師のリスト
        doctorList: doctorList
      };
    },

    // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
    async getIndUserListIncludeDel(authEditCd, authPEditCd) {
      const facilityCd = this.$store.getters["user/getFacilityCd"];
      const userAuthorityCds = this.$store.getters["user/getUserAuthorityCds"];
      const userId = this.$store.getters["account-edit/getStateUserAccountInfo"].userId;
      let doctorFlg = false;
      let defaultDoctorId = null;
      let inUserId = null;
      // 空項目を追加
      let doctorList = [{user_id: undefined, fullName: ""}];
      
      const [doctorResponse, defaultDoctor, shiftDoctorId] = await Promise.all([
        // 職種が医師の利用者一覧を取得
        sendRequestGetDoctorsAtFacilityIncludeDel(facilityCd),
        // デフォルト指示者取得
        sendRequestGetMstFacilitySettingValue(facilityCd, "1025"),
        // シフト医師取得
        getShiftDoctor(facilityCd),
      ]);

      // 医師のリストを作成
      doctorResponse.data.forEach(doctor => {
        doctorList.push({
          ...doctor,
          fullName: `${doctor.user_last_name} ${doctor.user_first_name}`
        });
        // 利用者が医師の場合：本人医師フラグを立てる
        if (doctor.user_id === userId) {
          doctorFlg = true;
        }
      });
      
      // 編集権限がなく、かつシフト医師/デフォルト指示医が一覧に含まれる場合：シフト医師/デフォルト指示医セット
      if (doctorList.some(d => d.user_id === shiftDoctorId)) {
        defaultDoctorId = shiftDoctorId; // シフト医師優先
      } else if (doctorList.some(d => d.user_id === defaultDoctor.data)) {
        defaultDoctorId = defaultDoctor.data;
      }
      
      // 本人医師 かつ編集権限がある場合：サインイン者がディフォルト選択状態
      if (doctorFlg && userAuthorityCds.includes(authEditCd)) {
        inUserId = userId;
      } else {
        inUserId = defaultDoctorId ? defaultDoctorId : undefined;
      }
      return {
        // 初期選択指示者
        iniSelectId: inUserId,
        // 医師のリスト
        doctorList: doctorList
      };
    },
    // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
    
    /**
     * スケジュール表用の指示者リスト、初期選択指示者を返します.（スケジュール移動編集権限の場合）
     * @returns {} 医師のリスト、初期選択指示者
     */
    async getIndUserListSchedule() {
      const facilityCd = this.$store.getters["user/getFacilityCd"];
      let defaultDoctorId = null;
      // 空項目を追加
      let doctorList = [{user_id: undefined, fullName: ""}];
      
      const [doctorResponse, defaultDoctor, shiftDoctorId] = await Promise.all([
        // 職種が医師の利用者一覧を取得
        sendRequestGetDoctorsAtFacility(facilityCd),
        // デフォルト指示者取得
        sendRequestGetMstFacilitySettingValue(facilityCd, "1025"),
        // シフト医師取得
        getShiftDoctor(facilityCd),
      ]);
      
      // 医師のリストを作成
      doctorResponse.data.forEach(doctor => {
        doctorList.push({
          ...doctor,
          fullName:  `${doctor.user_last_name} ${doctor.user_first_name}`
        });
      });
      
      // 編集権限がなく、かつシフト医師/デフォルト指示医が一覧に含まれる場合：シフト医師/デフォルト指示医セット
      if (doctorList.some(d => (shiftDoctorId !== "" && shiftDoctorId !== null) && d.user_id === shiftDoctorId)) {
        defaultDoctorId = shiftDoctorId; // シフト医師優先
      } else if (doctorList.some(d => d.user_id === defaultDoctor.data)) {
        defaultDoctorId = defaultDoctor.data;
      }
      
      return {
        // 初期選択指示者
        iniSelectId: defaultDoctorId,
        // 医師のリスト
        doctorList: doctorList
      };
    }
    
  }
}

/**
 * クールマスタ：医師シフト設定の今日の曜日の現在時間の医師のuser_idを返します
 * @param {string} facilityCd 施設コード
 * @returns {Promise<number|null>} 医師のuser_id
 */
export async function getShiftDoctor(facilityCd) {
  // 現在時間のクールマスタ取得
  const response = await ApiHelper.get("/mstInfo/mstKur", {
    facility_cd: facilityCd,
    is_del: "0"
  });
  const mstKurList = response.data || [];
  const currentTime = moment().format("HHmmss");

  const mstKur = mstKurList.find(
    ({ kurStartTime, kurEndTime }) =>
      currentTime >= kurStartTime && currentTime <= kurEndTime
  );

  let shiftDoctorId = null;
  if (mstKur) {
    const mstUserAuth = JSON.parse(mstKur.mstUserAuthentication);
    const weekDays = ["Sun", "Mon", "Tues", "Wednes", "Thurs", "Fri", "Satur"];
    const today = weekDays[new Date().getDay()];
    shiftDoctorId = mstUserAuth.data?.[0]?.[today]?.user_id ?? null;
  }
  if (shiftDoctorId !== "" && shiftDoctorId !== null) {
    shiftDoctorId = Number(shiftDoctorId);
  }
  
  return shiftDoctorId;
}
