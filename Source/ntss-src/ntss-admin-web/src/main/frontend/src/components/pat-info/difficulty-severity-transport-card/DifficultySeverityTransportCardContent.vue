<template>
  <div id="difficulty-severity-transport-card-contents">
    <table class="difficulty-table">
      <tbody>
      <tr>
        <th class="radio-area">主</th>
        <th>
          <label>
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-checkbox -->
            <!--   :disabled="!hasDialDiffEdit || editFlag " -->
            <!--   @change="toggleAllDialDiff" -->
            <!-- />透析困難 -->
            <v-ons-checkbox
              :disabled="!hasDialDiffEdit || !getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              @change="toggleAllDialDiff"
              v-model="allDialDiff"
            />透析困難
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
          </label>
        </th>
        <th class="date-area">登録日時</th>
      </tr>
      <tr>
        <!-- 未登録ラジオボタン -->
        <td :class="classObjIsMainChanged" class="radio-area">
          <custom-radio
            :value="{
              initValue: hasDialDiffInit ? '1' :'0',
              editValue: hasDialDiffEdit ? '1' :'0'
            }"
            :radio-value="0"
            :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
            name="is_main"
            @change="clearDialDiff()"
          />
        </td>
        <td>未登録</td>
        <td></td>
      </tr>
      <tr v-for="(json, index) in sharedDiffInfo" :key="index+100">
        <td :class="classObjIsMainChanged(json)">
          <custom-radio
            :value="getPatDataJsonArray(json, 'is_main')"
            radio-value="1"
            name="is_main"
            :disabled="true"
          />
        </td>
        <td>
          <custom-checkbox
            :value="getPatDataJsonArray(json, 'is_dial_diff')"
            checked-value="1"
            unchecked-value="0"
            :disabled="true"
          >
            {{ getPatDataJsonArray(json, "dialysis_difficulty_name").initValue }}
          </custom-checkbox>
        </td>
        <td class="date-area">
          {{ formatRegDate(getPatDataJsonArray(json, "reg_date").editValue) }}
        </td>
      </tr>
      <tr v-for="(json, index) in dialDiffInfo" :key="index">
        <!-- 主たるラジオボタン -->
        <td :class="classObjIsMainChanged(json)">
          <custom-radio
            :value="getPatDataJsonArray(json, 'is_main')"
            radio-value="1"
            name="is_main"
            :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
            @change="setIsMain(index)"
          />
        </td>
        <!-- 透析困難チェックボックス -->
        <!--
          TODO: 仕様不明確なのでFNWと動作が異なる
          (主たるのチェックは外させない、未登録選択時はチェックさせない
        -->
        <td>
          <custom-checkbox
            :value="getPatDataJsonArray(json, 'is_dial_diff')"
            checked-value="1"
            unchecked-value="0"
            :disabled="!hasDialDiffEdit || isMainDialDiff(json) || !getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          >
            {{
              getDialysisDifficultyName(
                mstDialDiff,
                getPatDataJsonArray(json, "dial_diff_cd").initValue,
                "dialysisDifficultyCd",
                "dialysisDifficultyName",
                getPatDataJsonArray(json, "fn_dial_diff_cd").initValue,
                getPatDataJsonArray(json, "dialysis_difficulty_name").initValue
              )
            }}
          </custom-checkbox>
        </td>
        <!-- 登録日時 -->
        <td class="date-area">
          {{ formatRegDate(getPatDataJsonArray(json, "reg_date").editValue) }}
        </td>
      </tr>
    
      </tbody>
    </table>

    <table class="card-table">
      <tbody>
      <tr>
        <td class="item-title">重症度</td>
        <td colspan="2">
          <custom-simple-textarea-a
            :value="getPatData('severity_cd')"
            :display-string="
              severityName
            "
            :disabled="true"
            style="width: 100%; vertical-align: middle; color: #1f1f21;"
          />
        </td>
        <td class="choice-button-area">
          <common-master-selector
            :masterType="MasterType.SEVERITY_PAT_INFO"
            :facilityCd="composeFacilityCd"
            :initItem="{ value: getPatData('severity_cd') ? getPatData('severity_cd').initValue : null }"
            :editItem="{ value: getPatData('severity_cd') ? getPatData('severity_cd').editValue : null }"
            :btnName="'選択'"
            :isVisible="false"
            :btnClass="'common-style-select-button btn3-normal'"
            :btnDisabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
            @popover-return="onSeverityReturn"
          />
        </td>
      </tr>
      <tr>
        <td class="item-title">搬送区分</td>
        <td colspan="2">
          <custom-simple-textarea-a
            :value="getPatData('transport_cd')"
            :display-string="
              transportName
            "
            :disabled="true"
            style="width: 100%; vertical-align: middle; color: #1f1f21;"
          />
        </td>
        <td class="choice-button-area">
          <common-master-selector
            :masterType="MasterType.TRANSPORT_PAT_INFO"
            :facilityCd="composeFacilityCd"
            :initItem="{ value: getPatData('transport_cd') ? getPatData('transport_cd').initValue : null }"
            :editItem="{ value: getPatData('transport_cd') ? getPatData('transport_cd').editValue : null }"
            :btnName="'選択'"
            :isVisible="false"
            :btnClass="'common-style-select-button btn3-normal'"
            :btnDisabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
            @popover-return="onTransportReturn"
          />
        </td>
      </tr>
      <tr class="wheel-chair-area">
        <!-- 車いす有無 -->
        <td class="item-title" :class="editClass" @click="checkEditWheelChair">車いす利用</td>
        <td colspan="2">
          <div style="display: flex; align-items: center;">
            <custom-checkbox
              :value="getPatData('is_wheel_chair')"
              checked-value="1"
              unchecked-value="0"
              :disabled="isPersonal || !getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              @change="handleWheelChairChange($event.target.value)"
            ></custom-checkbox>
            <!-- テキストエリア -->
            <custom-simple-textarea-a v-if="showWheelChair"
              :value="getPatData('wheel_chair_cd')"
              :display-string="wheelChairName"
              :disabled="true"
              style="width: 100%; vertical-align: middle; color: #1f1f21;"
            />
          </div>
        </td>
        <td class="choice-button-area" v-if="showWheelChair">
          <common-master-selector
            :masterType="MasterType.WHEEL_CHAIR_PAT_INFO"
            :facilityCd="composeFacilityCd"
            :initItem="{ value: getPatData('wheel_chair_cd') ? getPatData('wheel_chair_cd').initValue : null }"
            :editItem="{ value: getPatData('wheel_chair_cd') ? getPatData('wheel_chair_cd').editValue : null }"
            :btnName="'選択'"
            :isVisible="false"
            :btnClass="'common-style-select-button btn3-normal'"
            :btnDisabled="isPersonal || !getItemAuthorized('PatInfo', 'default_authority')"
            @popover-return="onWheelChairReturn"
          />
        </td>
      </tr>
    
      </tbody>
    </table>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized, deepCopy } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import dayjs from "@/compat/date/dayjs";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
// mod 7825患者情報>車椅子利用の表示が更新されない limingyang start
//import { mapGetters } from "@/compat/vue/vuex";
import {mapActions, mapGetters} from "@/compat/vue/vuex";
// mod 7825患者情報>車椅子利用の表示が更新されない limingyang end
// del #10359 編集権限の動作不正 dengshen start
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// import {AUTHORITY_CODES} from "@/constants/userAuthority"; //施設コード取得のために追加
// del #10359 編集権限の動作不正 dengshen end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { buildMasterPopover } from "@/components/common/master-selector/builder/builderFactory";
// del #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 start
// import { error } from '@/compat/charts/highcharts';
// del #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 end
export default {
  name: "DifficultySeverityTransportCard",
  mixins: [baseCardContent],
  components: {
    "common-master-selector": commonMasterSelector
  },

  data() {
    return {
      mstDialDiff: null,
      MasterType,
      severityName: "",
      transportName: "",
      // del #10359 編集権限の動作不正 dengshen start
      // // add 編集権限の適用 liang start
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // editFlag: null,
      // // add 編集権限の適用 liang end
      // del #10359 編集権限の動作不正 dengshen end
      wheelChairName: "未登録",
      sharedDiffInfo: [],

      allDialDiff: false,
      severityOptions: [],
      transportOptions: [],
      wheelChairOptions: [],
      showWheelChair: false,
      isPersonal:false
    };
  },
  props: {
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
  },
  computed: {
    ...mapGetters("pat-info", [
      "selectedPatId",
      "getIsOtherFacility",
      "getOtherFacilityCd",
    ]),

    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getUserId","getStateUserAccountInfo","getUseFunctions"]),
    ...mapGetters("account-edit", ["getUserId","getStateUserAccountInfo","getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    ...mapGetters("send-condition/scale/setting", ["getWheelChairList"]),

    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    /**
     * 透析困難 情報のgetter/setter
     */
    dialDiffInfo: {
      get() {
        if (this.sharedDiffInfo.length > 0) {
          return this.editRecord?.dial_diff_com_info.map((n, i) => n - this.sharedDiffInfo[i]);
        }
        return this.editRecord?.dial_diff_com_info;
      },

      set(value) {
        if (this.editRecord?.dial_diff_com_info) {
          this.editRecord.dial_diff_com_info = value;
        }
      }
    },

    /**
     * @description チェックされた透析困難の件数
     */
    dialDiffNum() {
      // mod #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 zkm start
      // return this.dialDiffInfo.filter(
      //   dialDiff => dialDiff.is_dial_diff.editValue === "1"
      // ).length;
      return Array.isArray(this.dialDiffInfo) ? this.dialDiffInfo.filter(
        dialDiff => dialDiff.is_dial_diff.editValue === "1"
      ).length : 0;
      // mod #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 zkm end
    },

    /**
     * @description 初期状態で透析困難が登録されている(未登録ではない)かどうか
     */
    hasDialDiffInit() {
      return this.dialDiffInfo.some(el => el.is_main.initValue === "1");
    },

    /**
     * @description 編集状態で透析困難が登録されている(未登録ではない)かどうか
     */
    hasDialDiffEdit() {
      return this.dialDiffInfo.some(el => el.is_main.editValue === "1");
    },

    /**
     * @description 未登録ラジオボタンの変更背景色クラス
     */
    classObjHasDialDiffChanged() {
      return {
        "has-dial-diff-changed": this.hasDialDiffInit !== this.hasDialDiffEdit
      };
    },

    /**
     * @description チェックボックスチェック時の文字色変更用(デザインの都合上、共通とは別に定義)
     */
    editClass() {
      return {
        // 編集時に適用されるclass
        "custom-checkbox-edited": this.editRecord.is_wheel_chair.editValue !== this.editRecord.is_wheel_chair.initValue,
        // 文字選択無効class
        "custom-checkbox-select-disabled": true
      };
    },

    composeFacilityCd() {
      return this.getIsOtherFacility ? this.getOtherFacilityCd : this.getFacilityCd;
    }
  },

  watch: {
    selectedPatId() {
      this.switchingSelectedPatFlg = true;
      this.refreshData();
      this.$nextTick(() => {
        this.switchingSelectedPatFlg = false;
      });
    },
    getOtherFacilityCd() {
      this.refreshData();
    },
  },

  async created() {
    this.refreshData();
    // del #10359 編集権限の動作不正 dengshen start
    // // add 編集権限の適用 liang start
    // if ( this.isCreationPat ) {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isCreatePatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   this.isCreatePatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isCreatePatViewAuthorized && this.isPatEditAuthorized);
    // } else {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    //   this.isPatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isPatViewAuthorized && this.isPatEditAuthorized);
    // }
    // // add 編集権限の適用 liang end
    // del #10359 編集権限の動作不正 dengshen end
  },
  // add bug #7125 修正 chen start
  beforeUnmount() {
  },
  // add bug #7125 修正 chen end

  methods: {
    formatRegDate(date) {
      return date === null
        ? null
        : dayjs(date, "YYYYMMDDHHmmss").format("YYYY/MM/DD HH:mm:ss");
    },
    // add 7825患者情報>車椅子利用の表示が更新されない limingyang start
    ...mapActions("loading-screen", ["setLoadingScreenMessage","setLoadingScreenVisible"]),
    // add 7825患者情報>車椅子利用の表示が更新されない limingyang end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // 主たるフラグセット
    setIsMain(selectedIndex) {
      // 全ての透析困難情報をループ
      this.dialDiffInfo.forEach((dialDiff, index) => {
        if (index === selectedIndex) {
          // 選択した透析困難を主たる透析困難とする
          dialDiff.is_main.editValue = "1";
          dialDiff.is_dial_diff.editValue = "1";
        } else {
          // それ以外の主たるフラグを折る
          dialDiff.is_main.editValue = "0";
        }
      });
    },
    // add bug #7125 修正 chen start
    async refreshData() {
      this.setLoadingScreenVisible(true);
      const requestParam = {
        facilityCd: this.getIsOtherFacility ? this.getOtherFacilityCd : this.getFacilityCd,
        selectedPatId: this.selectedPatId
      };

      const [
        responseDialDiff,
        responseWheelChair,
      ] = await Promise.all([
        // mod #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 dou start
        // ApiHelper.get("/mstInfo/mstDialysisDifficulty", requestParam),
        ApiHelper.get("/master_maintenance/mst_dialysis_difficulty/data", requestParam),
        // mod #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 dou end
        this.isCreationPat ? null : ApiHelper.get(`/weight_setting/wheel_chair/personal/${this.selectedPatId}`),
      ]).catch(error => {
        this.setLoadingScreenVisible(false);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('DifficultySeverityTransportCardContent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        throw error;
      });

      // ---------------
      // 透析困難処理
      // ---------------
      // mod #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 dou start
      // this.mstDialDiff = responseDialDiff.data;
      this.mstDialDiff = responseDialDiff.data.localDataSource.data.map(x => {
        return {
          clientIp: null,
          dialysisDifficultyCd: x.code,
          dialysisDifficultyName: x.isDisp == 1 ? x.name : "【削除済み】" + x.name,
          facilityCd: this.getIsOtherFacility ? this.getOtherFacilityCd : this.getFacilityCd,
          fnDialysisDifficultyCd: null,
          inHospitalCd_1: x.inHospitalCd1,
          inHospitalCd_2: x.inHospitalCd2,
          isDel: x.isDel,
          isDisp: x.isDisp,
          logUserId: null,
          operatorId: null,
          regDate: null,
          upDate: x.upDate,
          updateFlg: null
        }
      })
      // del #10945 患者情報の透析困難でマスタの表示順が反映されない zhangyue start
      // this.mstDialDiff.sort((x, y) => x.dialysisDifficultyCd - y.dialysisDifficultyCd);
      // del #10945 患者情報の透析困難でマスタの表示順が反映されない zhangyue end
      // mod #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 dou end
      //  dialDiffInfoをマスタ基準で作り変える
      //  ※マスタ表示順切り替え対応
      const dialDiffInfoNew = [];
      // TODO: マスタを表示順でループ
      // ⇒ mst_selector(?)から取れば表示順になるはず
      for (const mst of this.mstDialDiff) {
        // dialDiffInfoから一致するコードを探す
        const targetDialDiff = this.dialDiffInfo && this.dialDiffInfo.find(dialDiff => {
          return dialDiff.dial_diff_cd.initValue === mst.dialysisDifficultyCd;
        });
        let newDialDiff;
        if (targetDialDiff === undefined) {
          // add #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 dou start
          // 削除済み
          if (mst.isDisp == 0) {
            continue;
          }
          // add #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 dou end
          // dialDiffInfoにないコード(新規追加されたマスタ)の場合は追加
          newDialDiff = {
            dial_diff_cd: mst.dialysisDifficultyCd,
            is_dial_diff: "0",
            is_main: "0",
            reg_date: null
          };
        } else {
          // add #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 dou start
          // 削除済み
          if (mst.isDisp == 0 && targetDialDiff.is_dial_diff.initValue == "0") {
            continue;
          } else {
            // add #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 dou end
            // 存在するコードはそのまま追加
            newDialDiff = {
              dial_diff_cd: targetDialDiff.dial_diff_cd.initValue,
              is_dial_diff: targetDialDiff.is_dial_diff.initValue,
              is_main: targetDialDiff.is_main.initValue,
              reg_date: targetDialDiff.reg_date.initValue
            };
          }
        }
        dialDiffInfoNew.push(newDialDiff);
      }
      // add #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 start
      /**
      if (dialDiffInfoNew.length > 0) {
        // 主たるを先頭に
        const targetIndex = dialDiffInfoNew.findIndex(el => el.is_main === "1");

        if (targetIndex !== -1) {
          dialDiffInfoNew.unshift(dialDiffInfoNew.splice(targetIndex, 1)[0]);
        }
      }
      */
      // add #9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 end
      this.sharedDiffInfo = this.dialDiffInfo && this.dialDiffInfo.filter(e => e.readonly && e.readonly.initValue === true);
      if (!this.getIsOtherFacility) {
        this.dialDiffInfo = [];
        dialDiffInfoNew.forEach(el => this.pushJsonArray("dial_diff_com_info", el));
      }

      // 個人所有フラグ初期化
      this.isPersonal = false;

      await this.loadComposeOptions();
      const wheelChairData = responseWheelChair?.data;
      if (wheelChairData?.length) {
        // 個人所有の車いすが存在する場合は強制チェックON
        // ※wheel_chair_cdの値は更新時そのままにするので、個人所有車いすコードで上書きしない
        this.editRecord.is_wheel_chair.editValue = "1";
        this.editRecord.is_wheel_chair.initValue = "1";
        // 名称を個別にセット
        this.wheelChairName = wheelChairData[0].wheelChairName;
        // 個人所有フラグ
        this.isPersonal = true;
      }
      // 車いす選択欄の表示非表示を切り替え
      this.showWheelChair = (this.editRecord?.is_wheel_chair?.editValue === '1');

      this.initRecord = deepCopy(this.editRecord);
      this.setLoadingScreenVisible(false);
    },
    // add bug #7125 修正 chen end

    setPopOverValue(item, value) {
      this.setPatData(item, value);
    },

    resolveOptionText(options, value, showUnregistered) {
      const defaultText = showUnregistered ? "未登録" : "";
      if (!options?.length || value == null || value === "") {
        return defaultText;
      }
      const hit = options.find(option => String(option.value) === String(value));
      return hit && hit.text ? String(hit.text) : defaultText;
    },

    async loadComposeOptions() {
      const facilityCd = this.composeFacilityCd;
      const severityCd = this.getPatData("severity_cd")?.editValue;
      const transportCd = this.getPatData("transport_cd")?.editValue;
      const wheelChairCd = this.getPatData("wheel_chair_cd")?.editValue;

      const [severity, transport, wheelChair] = await Promise.all([
        buildMasterPopover(MasterType.SEVERITY_PAT_INFO, {
          facilityCd,
          extraParams: { initValue: severityCd }
        }),
        buildMasterPopover(MasterType.TRANSPORT_PAT_INFO, {
          facilityCd,
          extraParams: { initValue: transportCd }
        }),
        buildMasterPopover(MasterType.WHEEL_CHAIR_PAT_INFO, {
          facilityCd,
          extraParams: { initValue: wheelChairCd }
        })
      ]);

      this.severityOptions = severity?.master?.options ?? [];
      this.transportOptions = transport?.master?.options ?? [];
      this.wheelChairOptions = wheelChair?.master?.options ?? [];

      this.severityName = this.resolveOptionText(this.severityOptions, severityCd, false);
      this.transportName = this.resolveOptionText(this.transportOptions, transportCd, false);
      if (!this.isPersonal) {
        this.wheelChairName = this.resolveOptionText(this.wheelChairOptions, wheelChairCd, true);
      }
    },

    onSeverityReturn(row) {
      const value = row?.value ?? null;
      this.setPatData("severity_cd", value);
      if (row?.text === "未登録") {
        this.severityName = "";
        return;
      }
      this.severityName = row?.text != null && row.text !== ""
        ? String(row.text)
        : this.resolveOptionText(this.severityOptions, value, false);
    },

    onTransportReturn(row) {
      const value = row?.value ?? null;
      this.setPatData("transport_cd", value);
      if (row?.text === "未登録") {
        this.transportName = "";
        return;
      }
      this.transportName = row?.text != null && row.text !== ""
        ? String(row.text)
        : this.resolveOptionText(this.transportOptions, value, false);
    },

    onWheelChairReturn(row) {
      const value = row?.value ?? null;
      this.setPatData("wheel_chair_cd", value);
      this.wheelChairName = row?.text != null && row.text !== ""
        ? String(row.text)
        : this.resolveOptionText(this.wheelChairOptions, value, true);
    },

    getDialysisDifficultyName(
      mstData,
      mstCd,
      mstCdColumn,
      mstNameColumn,
      patFnCd,
      patName
    ) {
      if (!mstData || mstData.length === 0) {
        return "削除済み";
      }
      if (
        !Object.prototype.hasOwnProperty.call(mstData[0], mstCdColumn) ||
        !Object.prototype.hasOwnProperty.call(mstData[0], mstNameColumn)
      ) {
        return "削除済み";
      }
      const mstRecord = mstData.find(
        mst => mst[mstCdColumn] == mstCd
      );
      if (mstRecord && mstRecord[mstNameColumn]) {
        return mstRecord[mstNameColumn];
      }
      const patFnCdRecord = mstData.find(
        mst => mst[mstCdColumn] == patFnCd
      );
      if (patFnCdRecord && patFnCdRecord[mstNameColumn]) {
        return patFnCdRecord[mstNameColumn];
      }
      if (patName != null) {
        return patName;
      }
      return "削除済み";
    },

    /**
     * @description 全透析困難のチェック切り替え
     */
    toggleAllDialDiff(event) {
      const isChecked = event.target.checked;
      if (isChecked && this.hasDialDiffEdit) {
        // 未登録以外のとき全チェック
        this.dialDiffInfo.forEach(dialDiff => {
          dialDiff.is_dial_diff.editValue = "1";
        });
      } else if (!isChecked) {
        // 主たる以外のチェックは外す
        this.dialDiffInfo.forEach(dialDiff => {
          if (dialDiff.is_main.editValue === "0") {
            dialDiff.is_dial_diff.editValue = "0";
          }
        });
      }
    },

    // 透析困難を未登録にする
    clearDialDiff() {
      this.dialDiffInfo.forEach(dialDiff => {
        dialDiff.is_main.editValue = "0";
        dialDiff.is_dial_diff.editValue = "0";
      });
      // ヘッダー部の透析困難を未選択に戻す
      this.allDialDiff = false;
    },

    isMainDialDiff(dialDiff) {
      return dialDiff.is_main.editValue === "1";
    },

    // 登録日時をセット
    // ※保存時に呼び出す
    setRegDate() {
      const regdate = dayjs().format("YYYYMMDDHHmmss");
      // 全ての透析困難情報をループ
      this.dialDiffInfo.forEach(dialDiff => {
        if (
          (dialDiff.is_main.initValue !== dialDiff.is_main.editValue &&
            dialDiff.is_dial_diff.editValue === "1") ||
          (dialDiff.is_dial_diff.initValue === "0" &&
            dialDiff.is_dial_diff.editValue === "1")
        ) {
          // 主たる透析困難が変更されている、または
          // 透析困難が新しくチェックされているなら登録日時を変更
          this.setPatDataJsonArray(dialDiff, "reg_date", regdate);
        } else if (dialDiff.is_dial_diff.editValue === "0") {
          // 透析困難のチェックが外れたなら登録日時を削除
          this.setPatDataJsonArray(dialDiff, "reg_date", null);
        }
      });
    },

    // 透析困難情報をリセットする
    // ※保存時に呼び出す
    setClearDialDiffInfo() {
      this.clearDialDiff();
    },

    // 透析困難が未登録か確認する
    // ※保存時に呼び出す
    getHasDialDiffEdit() {
      return this.hasDialDiffEdit;
    },

    /**
     * @description 主たるラジオボタンの変更背景色クラス
     */
    classObjIsMainChanged(json) {
      return {
        "is-main-changed": json.is_main.initValue !== json.is_main.editValue,
        "radio-area": true
      };
    },

    /**
     * @description チェックボックのラベルクリック時の処理(デザインの都合上、共通とは別に定義)
     */
    checkEditWheelChair() {
      // 車いすが個人所有の場合は、強制チェックONの為、処理を抜ける
      if (this.isPersonal) {
        return;
      }
      //#9819 add 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-10 卓 start
      // mod #10359 編集権限の動作不正 dengshen start
      // if (this.editFlag){
      if (!this.getItemAuthorized('PatInfo', 'default_authority')){
      // mod #10359 編集権限の動作不正 dengshen end
        return;
      }
      //#9819 add 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-10 卓 end
      let val = this.editRecord.is_wheel_chair;
      if (val.editValue === "1"){
          val.editValue = "0";
      }else if (val.editValue === "0"){
         val.editValue = "1";
      }
      this.handleWheelChairChange(val.editValue);
    },
    /**
     * @description 車いす有無のチェック切り替え時処理
     * @param value 1:チェックON 0:チェックOFF
     */
    handleWheelChairChange(value){
      if(value === '0'){
        // 車いすを未登録に変更
        this.setPatData('wheel_chair_cd', null);
      }
      // 車いす表示名設定
      const wheelChairCd = this.getPatData("wheel_chair_cd")?.editValue;
      this.wheelChairName = this.resolveOptionText(
        this.wheelChairOptions,
        wheelChairCd,
        value === "1"
      );
      // 選択欄の表示非表示を切り替え
      this.showWheelChair = (value === '1');
    },
  }
};
</script>

<style scoped>
:deep(ons-checkbox.checkbox) {
  margin-top: 0;
}

.difficulty-table {
  border-collapse: collapse;
  width: 100%;
}

.difficulty-table th,
.difficulty-table td {
  border: solid 1px;
}

/* 未登録ラジオボタンと主たるラジオボタンの変更背景色 */
.has-dial-diff-changed,
.is-main-changed {
  /* TODO: 外枠に色をつけたいが、borderではうまくつかないので、背景色で */
  /*border: solid 1px green;*/
  background-color: green;
}
/* カード内のtableタグ */
.card-table {
  width: 100%;
}

/* 項目内容 */
.card-table tr td {
  padding: 2px;
}

/* 項目名 */
.card-table tr td:first-child {
  width: 30%;
}

/* 横に広げる */
.custom-input {
  display: inline-block;
  width: 100%;
  box-sizing: border-box;
  font-size: inherit;
}

/* 登録日時 */
.date-area {
  width: 25%;
  text-align: center;
}

/* 選択ボタン */
button {
  font-size: 15px;
}

/* 選択ボタン項目 */
.choice-button-area {
  width: 20%;
}

.radio-area {
  width: 10%;
  text-align: center;
}

.custom-checkbox-edited {
  color: green;
  font-weight: bold;
}

.custom-checkbox-select-disabled {
  user-select: none;
}
/* ntss.css の .custom-textarea:disabled と競合する為、個別定義 */
td .custom-textarea-edited {
  border: 2px green solid;
}
.wheel-chair-area {
  height: 2.5em;
}
</style>
