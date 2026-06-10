<template>
  <div class="pat-header">
    <v-touch :disabled="searchedPatList.length === 0 || !isPatSelected" @swipeleft="selectPatPre()">
      <v-touch :disabled="searchedPatList.length === 0 || !isPatSelected" @swiperight="selectPatNext()">
        <table class="event-area">
          <tr>
            <td class="search-button-area">
              <div class="search-button"
                @click="getStateUserAccountInfo.patId === null ? (isSideBarVisble = !isSideBarVisble) : (isSideBarVisble = false)">
              </div>
            </td>
            <td class="pat-name-area" id="pat-name-area">
              <label>
                <span
                  v-show="!isCreatePage || isNullPat"
                  class="hosp-pat-id"
                  ref="displayPos"
                  @mousedown="checkPatInfoLongPress(1)"
                  @mouseup="checkPatInfoLongPress(0)"
                  @touchstart="checkPatInfoLongPress(1)"
                  @touchend="checkPatInfoLongPress(0)"
                >
                  {{ isNullPat ? "患者割り当てをしてください。" : hospPatId }}<img v-if="isSame" class='same-icon' :src="image_src_same" />
                </span>
                <br />
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <span :class="patNameClass" id="pat-header-pat-name" @click="clickHeader()"> -->
                <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
                <!-- <span :class="patNameClass" id="pat-header-pat-name" @click="getItemAuthorized('PatHeader', 'default_authority') && clickHeader()"> -->
                <span :class="patNameClass" id="pat-header-pat-name" @click="clickHeader()">
                <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  {{ isNullPat ? "？？？？患者" : patName }}
                </span>
                <v-ons-popover
                  :target="popoverTarget"
                  :visible.sync="popoverVisible"
                  :class="[fontSizeSet, 'popover-style']"
                  direction="down"
                  cancelable
                >
                  <p style="text-align: center">保守ID: {{ patId }}</p>
                </v-ons-popover>
              </label>
            </td>
            <td v-if="!isCreatePage" class="pat-icon-area">
              <span v-if="isPatSelected">
                <div class="in-out-area">{{ inOutClassName }}</div>
                <div class="icon-area" v-if="getStateUserAccountInfo.patId === null">
                  <span class="icon-padding taboo-allergy-area" @click="showTabooAllergy">
                    <img class="pat-icon" :src="iconTabooAllergy" alt="pat-icon-taboo"/>
                    <!-- 全禁忌・アレルギー -->
                    <v-ons-popover
                      :class="[fontSizeSet, 'vons-popover']"
                      :visible.sync="isTabooAllergyVisible"
                      :target="popoverTarget"
                      direction="down"
                      cancelable
                      @preshow="popoverPreShow"
                      @postshow="popoverPostShow"
                      @posthide="popoverPosthide"
                    >
                      <!--mod FNSI-画面部品デザイン じょはく start-->
                      <div class="taboo-allergy-popover-div">
                        <taboo-allergy-detail
                          class-name="禁忌"
                          class="fab-font-color"
                          v-bind="allTabooDetailName"
                          v-if="hasTabooAllergy"
                        />
                        <taboo-allergy-detail
                          class-name="アレルギー"
                          class="fab-font-color"
                          v-bind="allAllergyDetailName"
                          v-if="hasTabooAllergy"
                        />
                        <div class="fab-font-color" v-show="!hasTabooAllergy">禁忌・アレルギー無し</div>
                      </div>
                    </v-ons-popover>
                  </span>
                  <span class="icon-padding infect-area" @click="showInfection">
                    <img class="pat-icon" :src="iconInfect" alt="pat-icon-infection"/>
                    <!-- 感染症カード -->
                    <v-ons-popover
                      :class="[fontSizeSet, 'infection-popover']"
                      :visible.sync="isInfectionVisible"
                      :target="popoverTarget"
                      direction="down"
                      cancelable
                      @preshow="popoverPreShow"
                      @postshow="popoverPostShow"
                      @posthide="popoverPosthide"
                    >
                      <div class="infection-popover-div">
                        <infection-items
                          :mst-infection="mstInfection"
                          :infection-data="infectionData"
                        />
                      </div>
                    </v-ons-popover>
                  </span>
                  <span class="icon-padding implant-area" @click="showImplant" >
                    <img class="pat-icon" :src="iconImplant" alt="pat-icon-implant"/>
                    <!-- インプラントカード -->
                    <v-ons-popover
                      :class="[fontSizeSet, 'implant-popover']"
                      :visible.sync="isImplantVisible"
                      :target="popoverTarget"
                      direction="down"
                      cancelable
                      @preshow="popoverPreShow"
                      @postshow="popoverPostShow"
                      @posthide="popoverPosthide"
                    >
                      <div class="implant-popover-div">
                        <!-- change the tag from "v-if" to "v-show" modify by maxueqiang -->
                        <div class="fab-font-color" v-show="implantData.length == 0">インプラント無し</div>
                        <div class="fab-font-color" v-show="implantData.length !== 0">インプラント一覧</div>
                        <!-- change the tag from "v-if" to "v-show" modify by maxueqiang -->
                        <span>
                          <span v-for="(pat, patIndex) in implantData" :key="patIndex">
                            <div class="fab-font-color">
                              {{ patIndex +1 }}:
                              {{ mstCdToNameOrNull(mstImplant, pat.implant_cd, 'implantCd', 'implantName') }}
                            </div>
                            <div class="fab-font-color">
                              {{showFromToDateString(pat.reg_date,pat.remove_date)}}
                            </div>
                            <!--mod FNSI-画面部品デザイン じょはく end-->
                          </span>
                        </span>
                      </div>
                    </v-ons-popover>
                  </span>
                </div>
              </span>
            </td>
            <td class="patinfo-treattime-area">
              <div class="patinfo-treattime-area-scroll">
                <div class="patinfo-treattime-area-scroll-child" style="width:max-content; padding-left: 20px;">
                  <div v-if="!isCreatePage && isPatSelected" class="pat-header-pat-info-area">
                    <div>
                      {{ patSex }} {{ patBloodTypeAbo }}({{ patBloodTypeRh }})
                    </div>
                    <div>
                      {{ patBirthday }}({{ age }})
                    </div>
                  </div>
                  <div
                    v-if="!isCreatePage && isPatSelected && !isUpdatingAcceptanceStatusInfo && treatmentCount !== 0"
                    class="treatment-time-area"
                    @click="showAcceptanceStatusInfo"
                  >
                    <!-- mod FutreNetWeb+SI課題管理No4369対応 趙 end -->
                    <div v-if="isTreatmentTime(0)" :style="treatmentTimeStyle(0)">
                      <span v-if="isTreatmentCount(2)" :style="treatmentcountStyle(0)" class="treatment-count-area">{{treatmentCount}}</span>
                      <div :style="treatmentProgressStyle(0)"></div>
                    </div>
                    <!-- 治療状況がない場合のツールチップ呼び出し用領域確保 -->
                    <div v-else>&emsp;</div>
                    <!-- 治療進捗状況表示用 -->
                    <v-ons-popover
                      :class="[fontSizeSet, 'acceptance-status-info-popover']"
                      :visible.sync="popoverAcceptanceStatusInfoVisible"
                      :target="popoverAcceptanceStatusInfoTarget"
                      direction="down"
                      cancelable
                    >
                      <div v-if="isTreatmentCount(1)" class="acceptance-status-info-area">
                        <span
                          v-for="(itemData, itemIndex) in this.acceptanceStatusInfo()"
                          :key="itemIndex"
                        >
                          <div v-if="isTreatmentTime(itemIndex)" class="acceptance-status-info-bar">
                            <div :style="treatmentTimeStyle(itemIndex)">
                              <div :style="treatmentProgressStyle(itemIndex)"></div>
                            </div>
                          </div>
                        </span>
                      </div>
                      <div class="acceptance-statusn-info-button-area">
                        <ons-button
                          class="common-style-ok-button btn3-normal"
                          :disabled="!isPatEditAuthority"
                          @click="updateAcceptanceStatusInfo"
                        >更新</ons-button>
                      </div>
                    </v-ons-popover>
                  </div>
                </div>
              </div>
            </td>
          </tr>
        </table>
      </v-touch>
    </v-touch>

    <!-- サイドバー -->
    <div v-if="isSideBarVisble" style="width: 0;">
      <side-bar />
    </div>
    <div
      v-if="!isPatInfoPageShowing&& isPatInfoVisible && isPatSelected"
      :class='["card-list", cardListSize]'
      :style="{ width: windowWidth + 'px' }"
    >
      <!--modify by shiyinwang 2022-10-25 [6119] Each time click header, reload patient information --end    -->
      <!-- mod 不要な判断条件を削除する 炜 end     -->
      <card-list :pat-record="selectedPat" :header-click="true" ref="cardList" />
      <!--add 画面部品デザイン-じょはく start-->
      <div v-if="selectedPat !== null" class="type-right">
        <img class="menu-btn" id="menu-btn" :src="imgUrl" @click="menuDisplay()" />
      </div>
      <!--add 画面部品デザイン-じょはく end-->
    </div>
  </div>
</template>

<script>
  // del #10359_NG対応 編集権限の動作不正 dengshen start
  // // add #10359 編集権限の動作不正 dengshen start
  // import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  // // add #10359 編集権限の動作不正 dengshen end
  // del #10359_NG対応 編集権限の動作不正 dengshen end
  // ライブラリ
  import Vue from "vue";
  import _ from "underscore";
  import moment from "moment";
  import VueTouch from "vue-touch";
  import {EventBus} from "@/eventBus.js";
  import {mapActions, mapGetters, mapMutations} from "vuex";
  import {calculateAge} from "@/functions/PatInfoFunctions";
  import {
    PAT_BLOOD_TYPE_ABO_OPTIONS,
    PAT_BLOOD_TYPE_RH_OPTIONS,
    PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS
  } from "@/constants/PatInfo.js";
  import {
    deduplicateObjects,
    deserializeJsonColumn,
    mstCdToName,
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // mstCdToNameIncludeDeleted
    mstCdToNameIncludeExpiredAndDeleted
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
  } from "@/functions/common/CommonFunctions.js";
  import PopoverMixin from "@/components/PopoverMixin";
  // コンポーネント
  import cardList from "@/components/pat-info/PatInfoCardList.vue";
  import sideBar from "@/components/side-contents/SideBar.vue";
  import infectionItems from "@/components/header-contents/PatHeaderInfectionItems.vue";
  import tabooAllergyDetail from "@/components/pat-info/taboo-allergy-card/TabooAllergyDetail.vue";
  import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
  import { FUNC_PAT_INFO } from "@/constants/function-code";
  import {AUTHORITY_CODES} from "@/constants/userAuthority";
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
  import {popoverPosthide, popoverPostShow, popoverPreShow} from "@/functions/common/CommonPopoverFunctions";
  import { createTimerManager } from "@/functions/for-componet/TimerManagerFunctions";
  // add 徐博 start
  import { PAT_HEADER } from "@/components/pat-info/PatInfoConfig.js"
  // add 徐博 end
  // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
  import { messageFormat } from '@/functions/common/MessageFormat';
  // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
  import { getMstInfo } from "@/apis/mst-info";

  Vue.use(VueTouch);

/**
 * @description 患者情報ヘッダ
 */
export default {
  mixins: [PopoverMixin, UserAuthorityMixin],
  components: {
    "card-list": cardList,
    "side-bar": sideBar,
    "infection-items": infectionItems,
    "taboo-allergy-detail": tabooAllergyDetail
  },
  props: {
    isCreatePage: {
      type: Boolean,
      default: false
    },
    /** スワイプによる患者切替の無効フラグ */
    isCannotSwipe: {
      type: Boolean,
      default: false
    },
    /** 体重計・条件送信画面用動作モード */
    isWeightScale: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      // add 徐博 start
      imgUrl: '',
      // add 徐博 end
      // FNSI - add-画面部品デザイン-じょはく start
      direction: null,
      // FNSI - add-画面部品デザイン-じょはく end
      isSideBarVisble: false,
      isInfectionVisible: false,
      isImplantVisible: false,
      isTabooAllergyVisible: false,
      popoverTarget: null,
      iconHasTabooAllergy: "●",
      iconNoTabooAllergy: "○",
      iconHasInfect: "●",
      iconNoInfect: "○",
      iconHasImplant: "●",
      iconNoImplant: "○",
      mstTabooAllergy: null,
      mstMedicine: null,
      mstMedicineMix: null,
      mstEquipment: null,
      mstDialyzer: null,
      sysGenericMedicine: null,
      mstInfection: null,
      mstImplant: null,
      srcFuncNameOnCreated: "",
      // 同姓同名アイコン
      image_src_same: require('../../assets/name_duplication3.png'),
      // 禁忌・アレルギーアイコン
      image_src_taboo_on: require('../../assets/taboo_on.png'),
      image_src_taboo_off: require('../../assets/taboo_off.png'),
      // 感染症アイコン
      image_src_infection_on: require('../../assets/infection_on.png'),
      image_src_infection_off: require('../../assets/infection_off.png'),
      // インプラントアイコン
      image_src_implant_on: require('../../assets/implant_on.png'),
      image_src_implant_off: require('../../assets/implant_off.png'),
      blowTimer: 0,
      popoverVisible: false,
      isAndroid: false,
      isIOS: false,
      // この関数で返した状態が beforeDestroy でのdataリセット処理に使われるため
      // createTimerManager はこの時点ではわず、created で行う
      timerManager: null,

      // 治療進捗状況表示用
      popoverAcceptanceStatusInfoVisible: false,
      popoverAcceptanceStatusInfoTarget: null,
      //add 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 start
      initDate:null
      //add 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 end
    };
  },

  computed: {
    //施設コード取得用
    // FNSI - add-画面部品デザイン-じょはく start
    ...mapGetters("account-edit", ["getTheme"]),
    // FNSI - add-画面部品デザイン-じょはく end
    // add FNSI-体重計測定レイアウト調整 陳 start
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    // add FNSI-体重計測定レイアウト調整 陳 end
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", [
      "selectedPat",
      "selectedPatId",
      "selectedPatName",
      "searchedPatList",
      "isPatInfoPageShowing",
      // del FNSI- 非同期処理中でも画面遷移ができる 徐博 start
      // "isLoadingPat",
      // del FNSI- 非同期処理中でも画面遷移ができる 徐博 end
      "isPatInfoVisible",
      "treatmentPatList",
      "srcFuncName",
      "isNullPat",
      "isUpdatingAcceptanceStatusInfo",
      "isPatInfoChaned"
    ]),
    ...mapGetters("treatment-record/common", ["getOrdNoForSideBarRecord"]),
    ...mapGetters("window-size", {
      windowWidth: "getMainWindowWidth"
    }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getFontSize"]),
    /**
     * @description 表示する患者名
     */
    patName() {
      if (this.isCreatePage) {
        return "新規登録する患者情報を入力して下さい";
      }
      // del FNSI- 非同期処理中でも画面遷移ができる 徐博 start
      /*if (this.isLoadingPat) {
        return "";
      }*/
      // del FNSI- 非同期処理中でも画面遷移ができる 徐博 end
      // mod #9231 ????患者選択からほかの患者へ切り替え時　一瞬 "患者未選択"と表示される 朴 start
      if (this.selectedPat === null && this.selectedPatIdIndex === -1) {
      // mod #9231 ????患者選択からほかの患者へ切り替え時　一瞬 "患者未選択"と表示される 朴 end
        return "患者未選択";
      }
      // mod #12462 患者情報共有 Ji start
      // return this.selectedPatName;
      const title = this.selectedPat?.pat_personal_main_title;
      const lastName = title?.pat_last_name ?? "";
      const firstName = title?.pat_first_name ?? "";

      return (lastName && firstName) ? `${lastName} ${firstName}` : this.selectedPatName;
      // mod #12462 患者情報共有 Ji end
    },

    /**
     * @description 患者名に適用するクラス
     */
    patNameClass() {
      return {
        "pat-create": this.isCreatePage,
        "pat-name": !this.isCreatePage,
        // "pat-name-in-hospital":
        //   this.isPatSelected &&
        //   this.getPatPersonalMainColumnData("in_out_class") === 1 &&
        //   !this.isCreatePage
      };
    },

    /**
     * @description 患者一覧におけるpat_idのリスト
     */
    patIdList() {
      let patIdList = [];
      // リストに ord_no を含め、pat_id と ord_no の複合で選択切替をできるようにする
      if (this.srcFuncName === "") {
        this.searchedPatList.forEach(record => {
          patIdList.push({patId:record.pat_id, ordNo:null});
        });
      } else {
        this.treatmentPatList.forEach(record => {
          patIdList.push({patId:record.pat_id === null ? null : Number(record.pat_id), ordNo:record.ord_no});
        });
      }
      return patIdList;
    },

    /**
     * @description 患者一覧における選択患者IDのインデックスを取得
     * @summary 前後患者取得用
     * @returns {Number} 患者一覧インデックス
     */
    selectedPatIdIndex() {
      let indexNo = -1;
      this.patIdList.some((obj, index) => {
        // pat_id と ord_no の複合で判別(ordNoForSideBarRecordは、通常時はnull)
        // mod #9231 ????患者の場合ord_no考慮追加 朴 start
        // if (obj.patId === this.selectedPatId && obj.ordNo === this.getOrdNoForSideBarRecord) {
        //   indexNo = index;
        //   return true;
        // }
        // obj.ordNo がnullでは無い場合は、ordNoのみで一致判定を行う
        if (obj.ordNo != null && obj.ordNo === this.getOrdNoForSideBarRecord) {
          indexNo = index;
          return true;
        } else if (obj.ordNo === null && obj.patId && obj.patId === this.selectedPatId) {
          indexNo = index;
          return true;
        }
        // mod #9231 ????患者の場合ord_no考慮追加 朴 end
      }, this);
      return indexNo;
    },

    /**
     * @description 患者ID
     * @returns {String}
     */
    patId() {
      return this.selectedPatId;
    },

    /**
     * @description 病院内患者ID
     * @returns {String}
     */
    hospPatId() {
      // mod #12462 患者情報共有 Ji start
      // return this.isPatSelected
      //   ? "ID:" + this.getPatPersonalMainColumnData("hosp_pat_id")
      //   : "";
      return this.isPatSelected
        ? (
          this.selectedPat?.pat_personal_main_title?.hosp_pat_id
            ? "ID:" + this.selectedPat.pat_personal_main_title.hosp_pat_id
            : "ID:" + this.getPatPersonalMainColumnData("hosp_pat_id")
        )
        : "";
	// mod #12462 患者情報共有 Ji end
    },

    /**
     * @description 入外名称
     * @returns {String}
     */
    inOutClassName () {
      let value = "不明"
      switch (this.getPatPersonalMainColumnData("in_out_class")) {
        case 0:
          value = "外来";
          break;
        case 1:
          value = "入院";
          break;
        // mod 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
        // case 2:
        // // add FNSI Fix in_out_class type 関 start
        // break;
        //case 11:
        case 2:
        // mod 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
          // add FNSI Fix in_out_class type 関 end
          value = "死亡";
          break;

        case 3:
          // value = "-";　modify　by　maxueqiang　
          value = "－";
          break;
        default:
          value = "不明";
      }
      return value
    },

    /**
     * @description 画面表示用性別
     * @summary DBの値を画面表示用値へ変換
     * @returns {String}
     */
    patSex() {
      // mod #12462 患者情報共有 Ji start
      // const dbValue = this.getPatPersonalMainColumnData("pat_sex");
      const dbValue = this.selectedPat?.pat_personal_main_title
        ? this.selectedPat?.pat_personal_main_title.pat_sex
        : this.getPatPersonalMainColumnData("pat_sex");
      // mod #12462 患者情報共有 Ji end
      const patSexData = PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS.find(
        patSex => patSex.value === dbValue
      );
      // TODO: DB値が不適切だったら不明を表示している
      if (patSexData === undefined) {
        //console.log(`${dbValue}:DB値が適切でない(カラム名pat_sex)`);
        return "不明";
      }
      return patSexData.displayValue;
    },

    /**
     * @description 画面表示用血液型(abo)
     * @summary DBの値を画面表示用値へ変換
     * @returns {String}
     */
    patBloodTypeAbo() {
      // mod #12462 患者情報共有 Ji start
      // const dbValue = this.getPatPersonalMainColumnData("pat_blood_type_abo");
      const dbValue = this.selectedPat?.pat_personal_main_title
        ? this.selectedPat?.pat_personal_main_title.pat_blood_type_abo 
        : this.getPatPersonalMainColumnData("pat_blood_type_abo");
      // mod #12462 患者情報共有 Ji end
      const patBloodTypeAboData = PAT_BLOOD_TYPE_ABO_OPTIONS.find(
        patBloodTypeAbo => patBloodTypeAbo.value === dbValue
      );
      // TODO: DB値が不適切だったら不明を表示している
      if (patBloodTypeAboData === undefined) {
        //(`${dbValue}:DB値が適切でない(カラム名pat_blood_type_abo)`);
        return "不明";
      }
      return patBloodTypeAboData.displayValue;
    },

    /**
     * @description 画面表示用血液型(rh)
     * @summary DBの値を画面表示用値へ変換
     * @returns {String}
     */
    patBloodTypeRh() {
      // mod #12462 患者情報共有 Ji start
      // const dbValue = this.getPatPersonalMainColumnData("pat_blood_type_rh");
      const dbValue = this.selectedPat?.pat_personal_main_title
        ? this.selectedPat?.pat_personal_main_title.pat_blood_type_rh 
        : this.getPatPersonalMainColumnData("pat_blood_type_rh");
	// mod #12462 患者情報共有 Ji end
      const patBloodTypeRhData = PAT_BLOOD_TYPE_RH_OPTIONS.find(
        patBloodTypeRh => patBloodTypeRh.value === dbValue
      );
      // TODO: DB値が不適切だったら不明を表示している
      if (patBloodTypeRhData === undefined) {
        //console.log(`${dbValue}:DB値が適切でない(カラム名pat_blood_type_rh)`);
        return "不明";
      }
      return patBloodTypeRhData.displayValue;
    },

    /**
     * @description 画面表示用生年月日
     * @returns {String}
     */
    patBirthday() {
      // mod #12462 患者情報共有 Ji start
      // if (this.getPatPersonalMainColumnData("pat_birthday") === null) {
      //   return "不明";
      // }
      // return moment(this.getPatPersonalMainColumnData("pat_birthday")).format(
      //   "YYYY/MM/DD"
      // );
      const birthday = this.selectedPat?.pat_personal_main_title
        ? this.selectedPat?.pat_personal_main_title.pat_birthday 
        : this.getPatPersonalMainColumnData("pat_birthday");

      if (birthday === null) {
        return "不明";
      }

      return moment(birthday).format("YYYY/MM/DD");
      // mod #12462 患者情報共有 Ji end
    },

    /**
     * @description 年齢
     * @returns {Number}
     */
    age() {
      // mod 8294 死亡患者の年齢が現時点での年齢で表示されている 関 start
      // const age = calculateAge(
      //   this.getPatPersonalMainColumnData("pat_birthday")
      // );
      // mod #12462 患者情報共有 Ji start
      // const age = calculateAge(
      //   this.getPatPersonalMainColumnData("pat_birthday"),this.getPatPersonalMainColumnData("is_die") == 1 ?  moment(this.getPatPersonalMainColumnData("die_date")).format("YYYYMMDD") : moment(new Date()).format("YYYYMMDD")
      // );
      const title = this.selectedPat?.pat_personal_main_title;
      const birthday = title ? title.pat_birthday : this.getPatPersonalMainColumnData("pat_birthday");
      const isDie = title ? title.isDie : this.getPatPersonalMainColumnData("isDie");
      const dieDate = title ? title.dieDate : this.getPatPersonalMainColumnData("dieDate");

      const age = calculateAge(
        birthday,
        isDie == 1
          ? moment(dieDate).format("YYYYMMDD")
          : moment(new Date()).format("YYYYMMDD")
       // mod #12462 患者情報共有 Ji end
      );
      // mod 8294 死亡患者の年齢が現時点での年齢で表示されている 関  end
      return age > 0 ? `${age}歳` : "不明";
    },

    /**
     * @description 患者選択フラグ
     * @returns {Boolean}
     */
    isPatSelected() {
      return this.selectedPat !== null;
    },

    /**
     * @description 同姓同名有無フラグ
     * @returns {Boolean}
     */
    isSame() {
      // DBカラム名 is_same 仕様'0'なし'1'あり
      return this.isPatSelected && !this.isCreatePage
        ? this.getPatMainColumnData("is_same") === "1"
        : false;
    },

    /**
     * @description 禁忌・アレルギーアイコンソース
     * @returns {String}
     */
    iconTabooAllergy() {
      return this.hasTabooAllergy
        ? this.image_src_taboo_on
        : this.image_src_taboo_off;
    },

    /**
     * @description 感染症アイコンソース
     * @returns {String}
     */
    iconInfect() {
      return this.hasInfect ? this.image_src_infection_on : this.image_src_infection_off;
    },

    /**
     * @description インプラントアイコンソース
     * @returns {String}
     */
    iconImplant() {
      return this.hasImplant ? this.image_src_implant_on : this.image_src_implant_off;
    },

    /**
     * @description 禁忌・アレルギー有無
     * @returns {Boolean}
     */
    hasTabooAllergy() {
      // DBカラム名 taboo_allergy_info 配列要素0ならなし
      // mod #12462 患者情報共有 Ji start
      // return (
      //   JSON.parse(this.getPatMainColumnData("taboo_allergy_info")).length !== 0
      // );
      const tabooAllergy = this.selectedPat?.pat_main_title
        ? JSON.parse(this.selectedPat?.pat_main_title.taboo_allergy_info )
        : JSON.parse(this.getPatMainColumnData("taboo_allergy_info"));
      return (
        tabooAllergy.length !== 0
      );
    },
      // mod #12462 患者情報共有 Ji end

    /**
     * @description 感染症有無
     * @returns {Boolean}
     */
    hasInfect() {
      // DBカラム名 is_infect 仕様'0'なし'1'あり
      // mod #12462 患者情報共有 Ji start
      // return this.getPatMainColumnData("is_infect") === "1";
      const infect = this.selectedPat?.pat_main_title
        ? this.selectedPat?.pat_main_title.is_infect
        : this.getPatMainColumnData("is_infect");
      return (
        infect === "1"
      );
    },
     // mod #12462 患者情報共有 Ji end

    /**
     * @description インプラント有無
     * @returns {Boolean}
     */
    hasImplant() {
      // DBカラム名 is_implant 仕様'0'なし'1'あり
      // mod #12462 患者情報共有 Ji start
      // return this.getPatMainColumnData("is_implant") === "1";
      const implant = this.selectedPat?.pat_main_title
        ? this.selectedPat?.pat_main_title.is_implant
        : this.getPatMainColumnData("is_implant");
      return (
        implant === "1"
      );
    },
      // mod #12462 患者情報共有 Ji end

    /**
     * @description 患者情報3テーブルの内容を1つに展開
     */
    patInfoRaw() {
      return {
        ...this.selectedPat.pat_main
      };
    },

    /**
     * @description 感染症カード用データ
     */
    infectionData() {
      const deserializedRecord = deserializeJsonColumn(this.patInfoRaw, [
        "infect_info"
      ]);
      // this.mstInfection は描画開始時点ではnullになっており、そのまま処理を行うとエラーとなります。
      // 描画エラーが発生した場合、部品の高さの正常な値が取得できない為の対応です。
      if (this.mstInfection == null) {
        return deserializedRecord.infect_info;
      }
      // add FutreNetWeb+SI課題管理No4671 趙 start
      // mod 8331 患者情報の感染症で削除済みの項目がSi側で表示される 関 start
      let mstInfectionTmp = [];
      //  for (const mst of this.mstInfection) {
      //   const targetInfection = deserializedRecord.infect_info.find(infection => {
      //     return infection.infection_cd === mst.infectionCd;
      //   });
      //   let infection_cd;
      //   let infect;
      //   let exam_date;
      //   let up_date;
      //   if (targetInfection === undefined) {
      //     infection_cd = mst.infectionCd;
      //     infect = "0";
      //     exam_date = null;
      //     up_date = null;
      //     const infection = {
      //       infect,
      //       up_date,
      //       exam_date,
      //       infection_cd
      //     };
      //     deserializedRecord.infect_info.push(infection);
      //   }
      // }
      for (const mst of this.mstInfection) {
        const targetInfection = deserializedRecord.infect_info.find(infection => {
          return infection.infection_cd === mst.infectionCd;
        });
        let infection_cd;
        let infect;
        let exam_date;
        let up_date;
        if (targetInfection === undefined) {
          infection_cd = mst.infectionCd;
          infect = "0";
          exam_date = null;
          up_date = null;
          const infection = {
            infect,
            up_date,
            exam_date,
            infection_cd
          };
          mstInfectionTmp.push(infection);
        } else {
          mstInfectionTmp.push(targetInfection);
        }
      }
      deserializedRecord.infect_info = mstInfectionTmp;
      // mod 8331 患者情報の感染症で削除済みの項目がSi側で表示される 関  end
      // add FutreNetWeb+SI課題管理No4671 趙 end
      return deserializedRecord.infect_info;
    },

    /**
     * @description インプラント用データ
     */
    implantData() {
      const deserializedRecord = deserializeJsonColumn(this.patInfoRaw, [
        "implant_info"
      ]);
      return deserializedRecord.implant_info;
    },


    /**
     * @description 感染症カード用データ
     */
    tabooAllergyData() {
      return JSON.parse(this.selectedPat.pat_main.taboo_allergy_info);
    },

    // 全ての禁忌詳細
    allTabooDetail() {
      return this.collectAllTabooAllergyDetail(PAT_HEADER.CLASS_TABOO);
    },

    // 全ての禁忌薬剤名称
    allTabooMedicine() {
      return this.extractMedicineNameFromDetail(this.allTabooDetail);
    },

    // 全ての禁忌調整薬剤名称
    allTabooMedicineMix() {
      return this.extractMedicineMixNameFromDetail(this.allTabooDetail);
    },

    // 全ての禁忌医療材料名称
    allTabooEquip() {
      return this.extractEquipNameFromDetail(this.allTabooDetail);
    },

    // 全ての禁忌ダイアライザ名称
    allTabooDialyzer() {
      return this.extractDialyzerNameFromDetail(this.allTabooDetail);
    },

    // 全ての禁忌一般名処方名称
    allTabooGenericMedicine() {
      return this.extractGenericMedicineNameFromDetail(this.allTabooDetail);
    },

    // 全ての禁忌フリーワード名称
    allTabooFreeWord() {
      return this.extractFreeWordNameFromDetail(this.allTabooDetail);
    },

    // 全ての禁忌名称を集めた詳細表示ポップオーバー用オブジェクト
    allTabooDetailName() {
      return {
        medicine: this.allTabooMedicine,
        medicineMix: this.allTabooMedicineMix,
        equip: this.allTabooEquip,
        dialyzer: this.allTabooDialyzer,
        genericMedicine: this.allTabooGenericMedicine,
        freeWord: this.allTabooFreeWord
      };
    },

    // 全ての禁忌詳細
    allAllergyDetail() {
      return this.collectAllTabooAllergyDetail(PAT_HEADER.CLASS_ALLERGY);
    },

    // 全てのアレルギー薬剤名称
    allAllergyMedicine() {
      return this.extractMedicineNameFromDetail(this.allAllergyDetail);
    },

    // 全てのアレルギー調整薬剤名称
    allAllergyMedicineMix() {
      return this.extractMedicineMixNameFromDetail(this.allAllergyDetail);
    },

    // 全てのアレルギー医療材料名称
    allAllergyEquip() {
      return this.extractEquipNameFromDetail(this.allAllergyDetail);
    },

    // 全てのアレルギーダイアライザ名称
    allAllergyDialyzer() {
      return this.extractDialyzerNameFromDetail(this.allAllergyDetail);
    },

    // 全てのアレルギー一般名処方名称
    allAllergyGenericMedicine() {
      return this.extractGenericMedicineNameFromDetail(this.allAllergyDetail);
    },

    // 全てのアレルギーフリーワード名称
    allAllergyFreeWord() {
      return this.extractFreeWordNameFromDetail(this.allAllergyDetail);
    },

    // 全てのアレルギー名称を集めた詳細表示ポップオーバー用オブジェクト
    allAllergyDetailName() {
      return {
        medicine: this.allAllergyMedicine,
        medicineMix: this.allAllergyMedicineMix,
        equip: this.allAllergyEquip,
        dialyzer: this.allAllergyDialyzer,
        genericMedicine: this.allAllergyGenericMedicine,
        freeWord: this.allAllergyFreeWord
      };
    },

    /**
     * @deprecated 治療状況
     * @returns
     */
    acceptanceStatusInfos() {
      return this.acceptanceStatusInfo()
    },
    /**
     * @description 治療状況件数
     * @returns
     */
    treatmentCount() {
      let ret = 0;
      const info = this.acceptanceStatusInfo();
      if( info != null ) {
        info.forEach(( item, index ) => {
          if( this.treatmentProgress( info, index ) != null ) {
            ret = ret + 1;
          }
        });
      }
      return ret;
    },
    /**
     * @description 患者情報編集権限
     */
    isPatEditAuthority() {
      return this.getUserAuthorityCds().includes(AUTHORITY_CODES.PAT_EDIT) ||
        this.getUserAuthorityCds().includes(AUTHORITY_CODES.PAT_PEDIT);
    },

    cardListSize() {
      switch (+this.getFontSize) {
        case 0:
          return "small";
        case 1:
          return "medium";
        case 2:
          return "big";
        case 3:
          return "xbig";
        default:
          return "";
      }
    }
  },

  watch: {
    getTheme(val) {
      if (val == 0) {
        if (this.direction == 'left') {
          this.imgUrl = 'img/pat-info/left_w.png'
        } else if (this.direction == 'right') {
          this.imgUrl = 'img/pat-info/right_w.png'
        }
      } else if (val == 1) {
        if (this.direction == 'left') {
          this.imgUrl = 'img/pat-info/left_b.png'
        } else if (this.direction == 'right') {
          this.imgUrl = 'img/pat-info/right_b.png'
        }
      }
    },
    direction(val) {
      if (val == 'left') {
        if (this.getTheme == 0) {
          this.imgUrl = 'img/pat-info/left_w.png'
        } else if (this.getTheme == 1) {
          this.imgUrl = 'img/pat-info/left_b.png'
        }
      } else if (val == 'right') {
        if (this.getTheme == 0) {
          this.imgUrl = 'img/pat-info/right_w.png'
        } else if (this.getTheme == 1) {
          this.imgUrl = 'img/pat-info/right_b.png'
        }
      }
    },
    selectedPat: {
      handler() {
        // 選択患者変更時サイドバーを閉じる
        this.isSideBarVisble = false;
        // 患者名の文字数により文字サイズを変更する
        // 患者名幅の調整
        if (this.timerManager) {
          this.timerManager.setTimeout(this.calPatNameAreaWidth, 1000);
        }
        // add FutreNetWeb+SI課題管理No4821 趙 start
        this.rebuildAcceptanceStatusInfo()
        // add FutreNetWeb+SI課題管理No4821 趙 end
      },
      deep: true
    },
    windowWidth(){
      this.calPatNameAreaWidth();
    },
    getFontSize(){
      this.calPatNameAreaWidth();
    }
  },

  async created() {
    this.timerManager = createTimerManager();
    this.path = this.$router.currentRoute.name
    if (this.path !== "pat-viewer") {
    // mod 徐博 end
      // FNSI - add-5407  start
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      // FNSI - add-5407  end
    }
    // mod 患者経過総合ビューアLoading問題対応 李 end

    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }
    if (this.isPatSelected && !this.isWeightScale) {
      // 再描画時(別のヘッダが表示された後の再表示)はそれまで選択されていた患者をストアに格納(最新の状態にするため)
      // ※体重計画面の場合は初期化状態から始まるため行わない
      // ここでのselectPatのリアクションが終わるまでの間のフラグを設定する
      this.setInSelectPatAtPatHeaderCreated(true);
      this.selectPat(this.selectedPatId).then(() => {
        this.setInSelectPatAtPatHeaderCreated(false);
        if (this.$route.name === "pat-info") {
          this.setStartRenderPatInfoContent(true);
        }
      });
    } else {
      this.setStartRenderPatInfoContent(true);
    }

    if (!this.isPatInfoPageShowing) {
      // ヘッダのカード一覧を非表示
      this.setIsPatInfoVisible(false);
    }
    // FNSI - add-画面部品デザイン-じょはく start
    this.direction = "left";
    // FNSI - add-画面部品デザイン-じょはく end
    //施設コードを抽出条件に追加
    const requestParam = {
      facilityCd: this.getFacilityCd
    };

    // const [
    //   responseTabooAllergy,
    //   responseMedicine,
    //   responseEquipment,
    //   responseDialyzer,
    //   responseGenericMedicine,
    //   responseInfection,
    //   responseMedicineMix,
    //   responseImplant
    // ] = await Promise.all([
    //   ApiHelper.get("/mstInfo/mstTabooAllergyIncludeDeleted", requestParam),
    //   ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", requestParam),
    //   ApiHelper.get("/mstInfo/mstEquipmentIncludeDeleted", requestParam),
    //   ApiHelper.get("/mstInfo/mstDialyzerIncludeDeleted", requestParam),
    //   ApiHelper.get("/mstInfo/sysGenericMedicineIncludeDeleted"),
    //   ApiHelper.get("/mstInfo/mstInfection", requestParam),
    //   ApiHelper.get("/mstInfo/mstMedicineMixIncludeDeleted", requestParam),
    //   ApiHelper.get("/mstInfo/mstImplant", requestParam)
    // ]).catch(() => {
    //   //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
    //   getErrorMessage('PatHeader.vue', 'created', 'マスタ取得失敗');
    //   //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
    //   throw new Error("[PatHeader.vue]created(): マスタ取得失敗");
    // });
    const reqMstNames = [
      "mstTabooAllergyIncludeDeleted", "mstMedicineIncludeDeleted", "mstEquipmentIncludeDeleted", "mstDialyzerIncludeDeleted",
      "sysGenericMedicineIncludeDeleted", "mstInfection", "mstMedicineMixIncludeDeleted", "mstImplant"
    ];
    await getMstInfo({
      reqMstNamesArr: reqMstNames
    }).then((response) => {
      if (response.status === 200 && response.data) {
        response = response.data;
        this.mstTabooAllergy = response.mstTabooAllergyIncludeDeleted;
        this.mstMedicine = response.mstMedicineIncludeDeleted;
        this.mstEquipment = response.mstEquipmentIncludeDeleted;
        this.mstDialyzer = response.mstDialyzerIncludeDeleted;
        this.sysGenericMedicine = response.sysGenericMedicineIncludeDeleted;
        this.mstInfection = response.mstInfection;
        this.mstMedicineMix = response.mstMedicineMixIncludeDeleted;
        this.mstImplant = response.mstImplant;
      }
    }).catch(() => {
      getErrorMessage('PatHeader.vue', 'created', 'マスタ取得失敗');
      throw new Error("[PatHeader.vue]created(): マスタ取得失敗");
    });
    // created時の遷移元機能名を保存
    this.srcFuncNameOnCreated = this.srcFuncName;
    // add FutreNetWeb+SI課題管理No4821 趙 start
    this.rebuildAcceptanceStatusInfo();
    // add FutreNetWeb+SI課題管理No4821 趙 end

    // mod 患者経過総合ビューアLoading問題対応 李 start
    if (this.path !== "pat-viewer") {
      // FNSI - add-5407  start
      this.setLoadingScreenVisible(false);
      // FNSI - add-5407  end
    }
    // mod 患者経過総合ビューアLoading問題対応 李 end
  },

  mounted() {
    if (this.getWeightMode.isWeightMode) {
      // 体重計モード時、初期表示の段階でヘッダー内のサイズ等を調整
      this.calPatNameAreaWidthWeightMode();
    }
  },

  beforeDestroy() {
    this.timerManager.destroy();
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    //  add FNSI-ジャンプメニューの固定化 徐博 start
    menuDisplay() {
      let name = document.getElementById("menu-bar-id");
      if (name.classList.contains("block")) {
        // FNSI - add-画面部品デザイン-じょはく start
        this.direction = "right";
        // FNSI - add-画面部品デザイン-じょはく end
        // FNSI - del-画面部品デザイン-じょはく start
        // document.getElementById("menu-btn").src = "img/pat-info/right.png";
        // FNSI - del-画面部品デザイン-じょはく end
        document.getElementById("menu-btn").style.marginLeft = "0px";
        document.getElementById("menu-bar-id").setAttribute("class", "menu-bar-contents button-size none");
        document.getElementsByClassName("card-infos")[0].style.marginLeft = "0px";
      } else {
        // FNSI - add-画面部品デザイン-じょはく start
        this.direction = "left";
        // FNSI - add-画面部品デザイン-じょはく end
        // FNSI - del-画面部品デザイン-じょはく start
        // document.getElementById("menu-btn").src = "img/pat-info/left.png";
        // FNSI - del-画面部品デザイン-じょはく end
        document.getElementById("menu-btn").style.marginLeft = "130px";
        document.getElementById("menu-bar-id").setAttribute("class", "menu-bar-contents button-size block");
        document.getElementsByClassName("card-infos")[0].style.marginLeft = "143px";
      }
    },
    //  add FNSI-ジャンプメニューの固定化 徐博 end

    // add FNSI-体重計測定レイアウト調整　陳 start
    changeBodyClass() {
      return this.getWeightMode.isWeightMode ? "pat-header_mode" : "pat-header";
    },
    // add FNSI-体重計測定レイアウト調整　陳 end
    mstCdToName,
    ...mapActions("pat-info", [
      "setInSelectPatAtPatHeaderCreated",
      "selectPat",
      "rebuildAcceptanceStatusInfo",
      "clearSelectedPat",
    ]),
    ...mapActions("loading-screen", [
      "setLoadingScreenMessage",
      "setLoadingScreenVisible"
    ]),
    ...mapMutations("pat-info", {
      setIsPatInfoPageShowing: "setIsPatInfoPageShowing",
      // del FNSI- 非同期処理中でも画面遷移ができる 徐博 start
      // setIsLoadingPat: "setIsLoadingPat",
      // del FNSI- 非同期処理中でも画面遷移ができる 徐博 end
      setIsPatInfoVisible: "setIsPatInfoVisible",
      setIsNullPat: "setIsNullPat",
      setIsPatInfoChaned: "setIsPatInfoChaned",
      setStartRenderPatInfoContent: "setStartRenderPatInfoContent",
      setOtherFacilityInfo: "setOtherFacilityInfo"
    }),
    ...mapActions("indication", ["setSelectedIndIndex"]),
    ...mapActions("treatment-record/common", ["setOrdNo", "setOrdNoForSideBarRecord"]),
    ...mapGetters("user", ["getUserAuthorityCds"]),

    /**
     * @description ヘッダクリック時のカード一覧表示切り替え
     */
    async clickHeader() {
      if (this.path == "pat-info") {
        return true;
      }
      if (this.selectedPat !== null) {
        // 権限チェックを行う
        if (!this.hasNextAuthority(FUNC_PAT_INFO)) {
          return true;
        }
      } else {
        if (this.isPatInfoVisible) this.setIsPatInfoVisible(false);
        return true;
      }
      // mod 徐博 start
      // if (
      //   !this.isPatInfoPageShowing &&
      //   this.getStateUserAccountInfo.patId === null
      // ) {
      // if (!this.isPatInfoPageShowing && this.getStateUserAccountInfo.patId === null && this.$refs.cardList != undefined) {
      //   // mod 徐博 end
      //   // 編集有無確認
      //   this.$refs.cardList.checkEditCard();
      // }

      // add by shiyw for 6119 start
      if (!this.isPatInfoVisible) {
        this.setIsPatInfoVisible(true);
      }else {
        if (this.isPatInfoChaned) {
          await this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
             // title: "内容破棄",
             title: DIALOG_MESSAGES[13000004].title,
             // message: "編集内容が破棄されます。</br>よろしいですか？",
             message: messageFormat(DIALOG_MESSAGES[13000004].message),
             // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer !== 0) {
                this.setIsPatInfoChaned(false);
                this.setIsPatInfoVisible(false);
              }
            }
          });
        } else {
          this.setIsPatInfoVisible(false);
        }
      }
      // add by shiyw for 6119 end
    },

    // 名称取得(削除済み処理付)
    mstCdToNameOrNull(mstData, mstCd, mstCdColumn, mstNameColumn){
      const returnName =  mstCdToName(mstData, mstCd, mstCdColumn, mstNameColumn);
      if(returnName == null){
        return "削除済み";
      }
      return returnName;
    },

    /**
     * 患者ID表示吹き出し 長押しウォッチャー
     */
    checkPatInfoLongPress(isMouseDown) {
      if (isMouseDown) {
        this.blowTimer = setTimeout(() => {
          this.showSearchPopover();
        }, 5000);
      } else {
        if (! this.popoverVisible){
          this.clickHeader();
        }
        clearTimeout(this.blowTimer);
      }
    },

    /**
     * 患者ID表示用関数
     */
    showSearchPopover() {
      this.popoverTarget = this.$refs.displayPos;
      this.popoverVisible = true;
    },

    /**
     * @description 患者選択
     * @summary 選択した患者の患者情報レコードをストアに格納する
     */
    // mod #12462 患者情報共有 Ji start
    async setSelectedPat(selectedPatId, selectedFacility) {
      this.setIsNullPat(false);
      // del FNSI- 非同期処理中でも画面遷移ができる 徐博 start
      // this.setIsLoadingPat(true);
      // del FNSI- 非同期処理中でも画面遷移ができる 徐博 end
      // オーダ番号をクリア
      this.setOrdNo(null);
      if (selectedPatId === null) {
        // add #9231 ????患者選択時、前患者情報が表示される ヘッダースワップ時 朴 start
        this.clearSelectedPat();
        // add #9231 ????患者選択時、前患者情報が表示される ヘッダースワップ時 朴 end
        this.setIsNullPat(true);
        // 現在の表示画面が治療状況リストの場合、治療状況を再読み込みさせる
        if (this.$router.currentRoute.name.indexOf("treatment-record") === 0) {
          EventBus.$emit("refresh");
        }
      } else {
        await this.selectPat({selectedPatId, selectedFacility}).catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('PatHeader.vue', 'setSelectedPat', '患者選択失敗');
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          // TODO: エラー処理ちゃんと考える
          throw new Error("[PatHeader.vue]setSelectedPat(): 患者選択失敗");
        });
        if ((this.$route.name === "pat-info" || this.$route.name === "deviceset-info") && (this.getPatientShareFacilityCdMode == null || this.getPatientShareMode == 1)) {
          this.setOtherFacilityInfo({
            isOtherFacility: false,
            otherFacilityCd: null
          });
        }
      }
      // mod #12462 患者情報共有 Ji end
      // del FNSI- 非同期処理中でも画面遷移ができる 徐博 start
      // this.setIsLoadingPat(false);
      // del FNSI- 非同期処理中でも画面遷移ができる 徐博 end
    },

    /**
     * @description 患者一覧における前の患者を選択
     */
    async selectPatPre() {
      // 患者情報画面展開状態のスワイプ操作禁止
      if (this.isPatInfoVisible) return;
      if (this.isPatInfoChaned) {
        let isCanceled = false;
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
             // title: "内容破棄",
             title: DIALOG_MESSAGES[13000004].title,
             // message: "編集内容が破棄されます。</br>よろしいですか？",
             message: messageFormat(DIALOG_MESSAGES[13000004].message),
             // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 0) {
              isCanceled = true;
            } else {
              this.setIsPatInfoChaned(false);
            }
          }
        });
        if (isCanceled) return;
      }
      // 利用者が在宅患者の場合は何もせずに処理を抜けます。
      if (this.getStateUserAccountInfo.patId !== null) return;
      // サイドバーの検索などで遷移元機能名がクリアされた場合、何もせずに処理を抜けます。
      if (this.srcFuncNameOnCreated !== this.srcFuncName) return;
      // 患者スワイプ無効状態では患者を切り替えたくないので抜けます。
      if (this.isCannotSwipe) return;
      if (this.selectedPatIdIndex === -1) {
        // TODO: ダイアログ「患者一覧に選択中の患者がいないため、患者一覧先頭の患者に移動します。」
      } else {
        const prePatIdIndex =
          this.selectedPatIdIndex === 0
            ? this.patIdList.length - 1
            : this.selectedPatIdIndex - 1;
        const prePatId = this.patIdList[prePatIdIndex].patId;
        if (this.srcFuncName !== "") {
          // 選択されている ord_no の更新
          this.setOrdNoForSideBarRecord(this.patIdList[prePatIdIndex].ordNo);
        }
        this.setSelectedIndIndex(prePatIdIndex);
        this.setSelectedPat(prePatId);
        if (this.$route.name === "pat-prescription") {
          EventBus.$emit("change-patient-prescription", prePatId);
        }
      }
    },

    /**
     * @description 患者一覧における次の患者を選択
     */
    async selectPatNext() {
      // 患者情報画面展開状態のスワイプ操作禁止
      if (this.isPatInfoVisible) return;
      if (this.isPatInfoChaned) {
        let isCanceled = false;
        await this.$ons.notification.confirm({
             // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
             // title: "内容破棄",
             title: DIALOG_MESSAGES[13000004].title,
             // message: "編集内容が破棄されます。</br>よろしいですか？",
             message: messageFormat(DIALOG_MESSAGES[13000004].message),
             // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 0) {
              isCanceled = true;
            } else {
              this.setIsPatInfoChaned(false);
            }
          }
        });
        if (isCanceled) return;
      }
      // 利用者が在宅患者の場合は何もせずに処理を抜けます。
      if (this.getStateUserAccountInfo.patId !== null) return;
      // サイドバーの検索などで遷移元機能名がクリアされた場合、何もせずに処理を抜けます。
      if (this.srcFuncNameOnCreated !== this.srcFuncName) return;
      // 患者スワイプ無効状態では患者を切り替えたくないので抜けます。
      if (this.isCannotSwipe) return;
      if (this.selectedPatIdIndex === -1) {
        // TODO: ダイアログ「患者一覧に選択中の患者がいないため、患者一覧先頭の患者に移動します。」
      } else {
        const nextPatIdIndex =
          this.selectedPatIdIndex === this.patIdList.length - 1
            ? 0
            : this.selectedPatIdIndex + 1;
        const nextPatId = this.patIdList[nextPatIdIndex].patId;
        if (this.srcFuncName !== "") {
          // 選択されている ord_no の更新
          this.setOrdNoForSideBarRecord(this.patIdList[nextPatIdIndex].ordNo);
        }
        this.setSelectedIndIndex(nextPatIdIndex);
        this.setSelectedPat(nextPatId);
        if (this.$route.name === "pat-prescription") {
          EventBus.$emit("change-patient-prescription", nextPatId);
        }
      }
    },

    /**
     * @description pat_personal_mainレコードのカラムを取得
     * @param {String} カラム名
     * @returns {any}
     */
    getPatPersonalMainColumnData(columnName) {
      return this.selectedPat.pat_personal_main[columnName];
    },

    /**
     * @description pat_mainレコードのカラムを取得
     * @param {String} カラム名
     * @returns {any}
     */
    getPatMainColumnData(columnName) {
      return this.selectedPat.pat_main[columnName];
    },

    /**
     * @description 感染症を表示
     */
    showInfection(event) {
      this.isInfectionVisible = true;
      this.popoverTarget = event;
    },

    /**
     * @description 禁忌・アレルギーを表示
     */
    showTabooAllergy(event) {
      this.isTabooAllergyVisible = true;
      this.popoverTarget = event;
    },

    /**
     * @description インプラントを表示
     */
    showImplant(event) {
      this.isImplantVisible = true;
      this.popoverTarget = event;
    },


    // 禁忌・アレルギーマスタの内容詳細から薬剤名称を取り出す
    extractMedicineNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        // mod 徐博 start
        // CLASS_MEDICINE,
        PAT_HEADER.CLASS_MEDICINE,
        // mod 徐博 end
        this.mstMedicine,
        "medicineCd",
        "medicineName"
      );
    },
    // add 9987 by kangjie 20231215 start
    extractMedicineMixNameFromDetail(tabooAllergyDetail) {
      // classMedicineMix
      return this.extractTabooAllergyNameFromDetail (
          tabooAllergyDetail,
          PAT_HEADER.CLASS_MEDICINMIX,
          this.mstMedicineMix,
          "medicineMixCd",
          "medicineMixName");
    },
    // add 9987 by kangjie 20231215 end

    // 禁忌・アレルギーマスタの内容詳細から調整薬剤名称を取り出す
    // extractMedicineMixNameFromDetail(tabooAllergyDetail) {
    //   if(!tabooAllergyDetail) return
    //   // 禁忌・アレルギーマスタの内容詳細から薬剤コードを取り出す
    //   const medicineList = tabooAllergyDetail
    //     // mod 徐博 start
    //     // .filter(detail => detail.classCd === CLASS_MEDICINE)
    //     .filter(detail => detail.classCd === PAT_HEADER.CLASS_MEDICINE)
    //     // mod 徐博 end
    //
    //   // 詳細登録された薬剤を含む調整薬剤を絞り込み名称を取得する
    //   const medicineMixNameList = this.mstMedicineMix
    //     .filter(item => {
    //       const mixInfo = JSON.parse(item.mixInfo)
    //       let isInclude = false
    //       if (mixInfo) {
    //         isInclude =
    //           mixInfo.some(info =>
    //             medicineList.some(medicine => info.cd === medicine.cd)
    //           )
    //       }
    //       return isInclude
    //     })
    //     .map(item => {
    //
    //       // 参照先の禁忌アレルギーが削除されている薬剤を含む調整薬剤であるか判定
    //       const mixInfo = JSON.parse(item.mixInfo)
    //       let isDispDeleted = false
    //       if (mixInfo) {
    //         isDispDeleted =
    //           mixInfo.some(info =>
    //             // 調整薬剤に含まれる薬剤を参照している禁忌アレルギーが削除されているか
    //             // 参照先の禁忌アレルギーが削除されていない物品が１つでも含まれていればfalseを返す
    //             medicineList.some(medicine => info.cd === medicine.cd && medicine.isDispDeleted) &&
    //             !medicineList.some(medicine => info.cd === medicine.cd && !medicine.isDispDeleted)
    //           )
    //       }
    //
    //       if (item.isDisp !== "0" && item.isDel !== "1" && !isDispDeleted) {
    //         return item.medicineMixName
    //       } else {
    //         // 調整薬剤が削除されている、または参照先の禁忌アレルギーが削除されている場合【削除済み】を付与する
    //         // mod 徐博 start
    //         // return DELETED + item.medicineMixName
    //         return PAT_HEADER.DELETED + item.medicineMixName
    //         // mod 徐博 end
    //       }
    //     })
    //
    //   return medicineMixNameList
    // },

    // 禁忌・アレルギーマスタの内容詳細から医療材料名称を取り出す
    extractEquipNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        // mod 徐博 start
        // CLASS_EQUIPMENT,
        PAT_HEADER.CLASS_EQUIPMENT,
        // mod 徐博 end
        this.mstEquipment,
        "equipmentCd",
        "equipmentName"
      );
    },

    // 禁忌・アレルギーマスタの内容詳細からダイアライザ名称を取り出す
    extractDialyzerNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        // mod 徐博 start
        // CLASS_DIALYZER,
        PAT_HEADER.CLASS_DIALYZER,
        // mod 徐博 end
        this.mstDialyzer,
        "dialyzerCd",
        "modelNumber"
      );
    },

    // 禁忌・アレルギーマスタの内容詳細から一般名処方名称を取り出す
    extractGenericMedicineNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        // mod 徐博 start
        // CLASS_GENERIC_MEDICINE,
        PAT_HEADER.CLASS_GENERIC_MEDICINE,
        // mod 徐博 end
        this.sysGenericMedicine,
        "genericCd",
        "genericName"
      );
    },

    // 禁忌・アレルギーマスタの内容詳細からフリーワード名称を取り出す
    extractFreeWordNameFromDetail(tabooAllergyDetail) {
      if (tabooAllergyDetail === undefined) {
        return;
      }
      // フリーワード名称は禁忌・アレルギーマスタの詳細から取得
      return tabooAllergyDetail
        // mod 徐博 start
        // .filter(detail => detail.classCd === CLASS_FREEWORD)
        // .map(detail => detail.isDispDeleted ? DELETED + detail.name : detail.name );
        .filter(detail => detail.classCd === PAT_HEADER.CLASS_FREEWORD)
        .map(detail => detail.isDispDeleted ? PAT_HEADER.DELETED + detail.name : detail.name );
        // mod 徐博 end
    },

    // 禁忌・アレルギーマスタの内容詳細から名称を取り出す
    // ※引数でいずれかの区分と名称変換に必要な情報を指定
    extractTabooAllergyNameFromDetail(
      tabooAllergyDetail,
      tabooAllergyClass,
      mst,
      cdColumn,
      nameColumn
    ) {
      if (tabooAllergyDetail === undefined) {
        return;
      }
      return tabooAllergyDetail
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // .filter(detail => detail.classCd === tabooAllergyClass)
        // .map(detail => mstCdToNameIncludeDeleted(mst, detail.cd, cdColumn, nameColumn, detail.isDispDeleted));
        .filter(detail => detail.classCd === tabooAllergyClass && detail.tabooAllergyDeleted != true)
        .map(detail => mstCdToNameIncludeExpiredAndDeleted(mst, detail.cd, cdColumn, nameColumn, detail.isDispDeleted));
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    },

    // 全ての禁忌、またはアレルギー詳細を集める
    // ※引数でいずれかの区分を指定
    collectAllTabooAllergyDetail(tabooAllergyClass) {
      if (this.mstTabooAllergy === null) {
        // マスタ読み込み完了前は何もしない
        return;
      }

      const tabooAllergy = [];
      const otherDetailInfoList = [];
      this.tabooAllergyData.forEach(el => {
        // add 9987 by kangjie 20231229 start
        // if (el.category_class === "0") {
        if (el.category_class === "0" || el.category_class === "5" ) {
          // add 9987 by kangjie 20231229 end
          // 対象区分：禁忌・アレルギーのみを集める
          tabooAllergy.push(el);
        } else {
          // 対象区分：禁忌・アレルギー以外を集める
          // mst_taboo_allergyテーブルのdetail_infoカラムの形で格納
          if (el.taboo_allergy_class === tabooAllergyClass) {
            otherDetailInfoList.push({
              // 各マスタへの紐づけ
              classCd: el.category_class,
              // 各マスタコード
              cd: el.taboo_allergy_cd
            });
          }
        }
      });

      if (_.isEmpty(tabooAllergy) && _.isEmpty(otherDetailInfoList)) {
        return;
      }

      // コードをマスタの内容詳細に変換する
      const allDetail = [...otherDetailInfoList];
      for (const taboo of tabooAllergy) {
        if (taboo.taboo_allergy_cd !== null) {
          if (tabooAllergyClass === taboo.taboo_allergy_class) {
            const targetMst = this.mstTabooAllergy.find(
              mst => mst.tabooAllergyCd === taboo.taboo_allergy_cd
            );
            if (targetMst !== undefined) {
              if (targetMst.detailInfo !== null) {
                // 内容詳細JSONをデシリアライズして展開
                const detailInfo = JSON.parse(targetMst.detailInfo).map(item => {
                  return {
                    ...item,
                    // 禁忌アレルギーコード
                    tabooAllergyCd: targetMst.tabooAllergyCd,
                    // 参照先禁忌アレルギーが削除されているかを示すフラグ
                    tabooAllergyDeleted: targetMst.isDisp === "0" || targetMst.isDel === "1"
                  }
                })
                allDetail.push(...detailInfo);
              }
            }
          }
        } else {
          if (tabooAllergyClass === taboo.taboo_allergy_class) {
            const detailInfo = {cd: null,
                                name: taboo.content,
                                classCd: PAT_HEADER.CLASS_FREEWORD,
                                tabooAllergyCd: taboo.taboo_allergy_cd,
                                tabooAllergyDeleted: false,
                                type: null};
            allDetail.push(detailInfo);
          }
        }
      }

      // 禁忌アレルギーの削除情報を付与する
      const allDetailProcessed = allDetail.map(detail => {
        const isAllDeleted = allDetail
          .filter(item =>
            item.cd === detail.cd && item.classCd === detail.classCd
          )
          .every(item => {
            // 対象物品が含まれるすべての禁忌アレルギーが削除されている場合、trueを返す
            return item.tabooAllergyDeleted
          })

        return {
          ...detail,
          isDispDeleted: isAllDeleted
        }
      })

      // 区分とコードと禁忌対象名の重複を排除
      return deduplicateObjects(allDetailProcessed, "classCd", "cd", "name");
    },

    //yyyymmdd文字列をyyyy/mm/ddフォーマットに変換
    formatDate(date) {
      return date === null ? null : moment(date).format("YYYY/MM/DD");
    },

    // 導入日と除去日の日付情報から「FROM～TO」「FROM～」「～TO」「」（未出力）切り替え
    showFromToDateString(from,to){
      // mod FNSI-改修内容 バグ対応 趙 start
      // if(from == null && to == null){
      if((from == null || from == "") && (to == null || to == "")){
        // mod FNSI-改修内容 バグ対応 趙 end
        //FROM-TO両方ともnull
        return "";
        // mod FNSI-改修内容 バグ対応 趙 start
        // }else if(from == null){
      }else if((from == null || from == "") && (to != null && to != "")){
        // mod FNSI-改修内容 バグ対応 趙 end
        return "～ " + this.formatDate(to);
        // mod FNSI-改修内容 バグ対応 趙 start
        // }else if(to == null){
        // mod FNSI-改修内容 バグ対応 趙 end
      }else if((from != null && from != "") && (to == null || to == "")){
        return this.formatDate(from) + " ～ ";
      }else{
        return this.formatDate(from) + " ～ " + this.formatDate(to);
      }
    },
    // ID・名前エリアの横幅設定
    calPatNameAreaWidth() {
      // 体重計モード時は専用の処理に移行
      if (this.getWeightMode.isWeightMode) {
        this.calPatNameAreaWidthWeightMode();
        return;
      }

      const getFirstElementByClassName = (className) => {
        const elements = document.getElementsByClassName(className);
        return elements.length > 0 ? elements[0] : null;
      };

      // 非表示にした要素を元に戻す
      const patInfoArea = getFirstElementByClassName("pat-header-pat-info-area");
      if (patInfoArea) {
        patInfoArea.style.display = "inline-block";
      }
      const treatmentTimeArea = getFirstElementByClassName("treatment-time-area");
      if (treatmentTimeArea) {
        treatmentTimeArea.style.display = "inline-block";
      }

      // 新規患者作成時は実行しない
      const nameArea = document.getElementById("pat-header-pat-name");
      if (nameArea && nameArea.classList && nameArea.classList.contains("pat-create")) {
        return;
      }

      // ID・名前エリア MAX幅
      // ヘッダー横幅 - サイドコンテンツ - ②エリア - ③④エリア - フロートメニュー
      const calcPatNameMaxWidth = () => (
        document.getElementsByClassName("pat-header")[0].clientWidth
        - document.getElementsByClassName("search-button-area")[0].clientWidth
        - document.getElementsByClassName("pat-icon-area")[0].clientWidth
        - document.getElementsByClassName("patinfo-treattime-area-scroll")[0].firstElementChild.clientWidth
        - document.getElementById("user-menu").clientWidth
      );
      let patNameMaxWidth = getFirstElementByClassName("pat-header") ? calcPatNameMaxWidth() : 0;

      // ID・名前エリア MIN幅
      // iPhone横幅(375px) - サイドコンテンツ - ②エリア - フロートメニュー
      const searchButtonArea = getFirstElementByClassName("search-button-area");
      const patIconArea = getFirstElementByClassName("pat-icon-area");
      const userMenu = document.getElementById("user-menu");
      const patNameMinWidth = (searchButtonArea && patIconArea && userMenu) ? (
        375
        - searchButtonArea.clientWidth
        - patIconArea.clientWidth
        - userMenu.clientWidth
      ) : 0;

      // MAX幅がMIN幅未満の場合、治療進捗バーエリアを削除
      if (patNameMaxWidth < patNameMinWidth) {
        if (treatmentTimeArea) {
          treatmentTimeArea.style.display = "none";
        }

        // MAX幅の再計算
        patNameMaxWidth = calcPatNameMaxWidth();
      }

      // MAX幅がMIN幅未満の場合、患者情報エリアを削除
      if (patNameMaxWidth < patNameMinWidth) {
        if (patInfoArea) {
          patInfoArea.style.display = "none";
        }

        // MAX幅の再計算
        patNameMaxWidth = calcPatNameMaxWidth();
      }

      // エリア削除してもMAX幅がMIN幅未満の場合、MAX幅 = MIN幅にする
      if (patNameMaxWidth < patNameMinWidth) {
        // MAX幅の再計算
        patNameMaxWidth = patNameMinWidth;
      }

      // 患者名フォントサイズ：標準
      if (nameArea) {
        nameArea.style.fontSize = "3.5em";
      }

      // ID・名前エリアはMIN幅・MAX幅のみ設定し、横幅を自動変更できるようにする
      const patNameArea = document.getElementById("pat-name-area");
      if (patNameArea) {
        patNameArea.style.minWidth = patNameMinWidth + "px";
        patNameArea.style.maxWidth = patNameMaxWidth + "px";
      }
      if (nameArea) {
        nameArea.style.maxWidth = patNameMaxWidth + "px";

        // 変更後の幅を取る
        let changedWidth = nameArea.clientWidth;

        // 変更後の幅がMAX幅を超える場合、フォントサイズを小さくする
        if (changedWidth >= patNameMaxWidth) {
          // 患者名フォントサイズ：第1段階
          nameArea.style.fontSize = "2.5em";

          // 変更後の幅を取る
          changedWidth = nameArea.clientWidth;
        }

        // 変更後の幅がMAX幅を超える場合、フォントサイズを小さくする
        // ここまで小さくしても収まらない場合、「…」で省略
        if (changedWidth >= patNameMaxWidth) {
          // 患者名フォントサイズ：第2段階
          nameArea.style.fontSize = "1.5em"
        }
      }
    },

    // ID・名前エリアの横幅設定 体重計モード用
    calPatNameAreaWidthWeightMode() {
      // 治療進捗バーエリアを非表示
      if(document.getElementsByClassName("treatment-time-area").length > 0) {
        document.getElementsByClassName("treatment-time-area")[0].style.display = "none";
      }

      // ID・名前エリア MAX幅
      // ヘッダー横幅 - サイドコンテンツ - ②エリア - ③④エリア - フロートメニュー
      let patNameMaxWidth = document.getElementsByClassName("pat-header")[0].clientWidth
        - document.getElementsByClassName("search-button-area")[0].clientWidth
        - document.getElementsByClassName("pat-icon-area")[0].clientWidth
        - document.getElementsByClassName("patinfo-treattime-area-scroll")[0].firstElementChild.clientWidth
        - document.getElementById("user-menu").clientWidth;

      // ID・名前エリア MIN幅
      // IDと同姓同名アイコンが表示できる幅(410px)で固定
      let patNameMinWidth = 410;

      // エリア削除してもMAX幅がMIN幅未満の場合、MAX幅 = MIN幅にする
      if(patNameMaxWidth < patNameMinWidth) {
        // MAX幅の再計算
        patNameMaxWidth = patNameMinWidth;
      }

      // 患者名フォントサイズ：標準
      document.getElementById("pat-header-pat-name").style.fontSize = "6em";

      // ID・名前エリアはMIN幅・MAX幅のみ設定し、横幅を自動変更できるようにする
      document.getElementById("pat-name-area").style.minWidth = patNameMinWidth + "px" ;
      document.getElementById("pat-name-area").style.maxWidth = patNameMaxWidth + "px" ;
      document.getElementById("pat-header-pat-name").style.maxWidth = patNameMaxWidth + "px" ;

      // 変更後の幅を取る
      let changedWidth = document.getElementById("pat-header-pat-name").clientWidth;

      // 変更後の幅がMAX幅を超える場合、フォントサイズを小さくする
      if (changedWidth >= patNameMaxWidth) {
        // 患者名フォントサイズ：第1段階
        document.getElementById("pat-header-pat-name").style.fontSize = "5em";

        // 変更後の幅を取る
        changedWidth = document.getElementById("pat-header-pat-name").clientWidth;

        // 変更後の幅がMAX幅を超える場合、フォントサイズを小さくする
        // ここまで小さくしても収まらない場合、「…」で省略
        if (changedWidth >= patNameMaxWidth) {
          // 患者名フォントサイズ：第2段階
          document.getElementById("pat-header-pat-name").style.fontSize = "4em";
        }
      }
    },

    /**
     * @description 治療進捗状況ソート
     * @returns ソート後の治療進捗状況リスト
     */
    sortAcceptanceStatusInfo( info ) {
      let ret = JSON.parse( info );
      // 配列判定
      if(!(ret instanceof Array)) {
        // 配列化
        ret =JSON.parse( "[" + info + "]");
      }
      // 配列内をソート
      ret.sort( function(a, b){
        // 治療状態が小さい順
        if( a.class < b.class ) {
          return -1;
        } else if( a.class > b.class ) {
          return 1;
          // 治療開始日が大きい順
        } else if( b.start_date < a.start_date) {
          return -1;
        } else if( b.start_date > a.start_date) {
          return 1;
          // 治療開始日がNULLは後
        } else if( a.start_date != null && b.start_date == null) {
          return -1;
        } else if( a.start_date ==null && b.start_date != null) {
          return 1;
          // オーダー番号が大きい順
        } else if( b.ord_no < a.ord_no) {
          return -1;
        } else if( b.ord_no > a.ord_no) {
          return 1;
        } else {
          return 0;
        }
      });
      return ret;
    },
    /**
     * @description 治療進捗状態を取得
     * @returns
     */
    acceptanceStatusInfo() {
      let ret = null;
      if(this.selectedPat != null && this.selectedPat.pat_main != null) {
        ret = this.sortAcceptanceStatusInfo(
          this.selectedPat.pat_main.acceptance_status_info
        );
      }
      return ret;
    },
    /**
     * @description 治療状況件数表示有無
     * @returns
     */
    isTreatmentCount(num) {
      return num <= this.treatmentCount;
    },
    /**
     * @description 治療時間経過カラースタイル
     * @returns
     */
    colorStyle( index ) {
      let color;
      const classType = this.treatmentClassType( this.acceptanceStatusInfo(), index );
      if (
        classType === "1" ||
        classType === "2"
      ) {
        color = "#42CB92";
      } else if (
        classType === "3"
      ) {
        color = "#2CA06F";
      } else if (
        classType === "4" ||
        classType === "5"
      ) {
        color = "#557769";
      }
      return color;
    },

    /**
     * @description 治療時間経過カラースタイル
     * @returns
     */
    treatmentcountStyle( index ) {
      let color;
      const classType = this.treatmentClassType( this.acceptanceStatusInfo(), index );
      if (
        classType === "1" ||
        classType === "2" ||
        classType === "3"
      ) {
        color = "#050505";
      } else if (
        classType === "4" ||
        classType === "5"
      ) {
        color = "white";
      }
      return `color: ${color};`;
    },

    /**
     * @description 治療時間スタイル
     * @returns
     */
    treatmentTimeStyle( index ) {
      return `border: 1px solid; color: ${
        this.colorStyle(index)
      }; height: 25px; width: ${120}px; border-radius: 25px; position: relative; background-color: white;`;
    },

    /**
     * @description 治療経過時間スタイル
     * @returns
     */
    treatmentProgressStyle( index ) {
      const info = this.acceptanceStatusInfo();
      return `background-color: ${this.colorStyle(index)}; height: 25px; width: ${this.treatmentProgress(info, index) + 25}px; border-radius: 25px;`;
    },

    /**
     * @description 治療経過時間
     * @returns
     */
    treatmentProgress( info, index ) {
      const classType = this.treatmentClassType( info, index );

      // "1","2": 0%表示
      if (classType === "1" || classType === "2") {
        return 0;
      }
      // "4","5": 100%黒色表示(治療終了)
      if (classType === "4" || classType === "5") {
        return 95;
      }
      // "0","6" null: 非表示
      if (
        classType === "0" ||
        classType === "6" ||
        classType === null ||
        classType === undefined
      ) {
        return null;
      }

      // 実績治療開始日時
      const start_date_time = info[index].start_date_time;
      // 透析時間(分)
      const treatment_time = info[index].treatment_time;
      if (start_date_time === null || treatment_time === null) {
        if (classType === "3") {
          return 0;
        }
        return null;
      }

      // "3": 経過時間表示
      const treatmentStartDateTime = moment(start_date_time);
      //mod 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 start
      // const now = moment();
      const now = this.initDate!=null? this.initDate:moment();
      this.initDate=now;
      //mod 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 end

      // ミリ秒を分へ変換
      const treatmentProgressTime = now.diff(treatmentStartDateTime) / 60000;

      // %へ変換
      let treatmentTimeRatio = (treatmentProgressTime / treatment_time) * 100;
      // 120pxの内25pxは0表示、残り95pxで経過を表示する
      treatmentTimeRatio *= 0.95;

      // 治療が開始していない場合の処理
      if (treatmentTimeRatio < 0) {
        return 0;
      }

      return treatmentTimeRatio >= 95 ? 95 : treatmentTimeRatio;
    },

    /**
     * @description 治療日時有無
     * @returns
     */
    isTreatmentTime( index ) {
      // 治療状況
      const info = this.acceptanceStatusInfo();
      return this.treatmentProgress(info, index) !== null;
    },

    /**
     * @description 治療種類
     * @returns
     */
    treatmentClassType( info, index ) {
      let ret = null;
      // 治療種類
      if ( info
        && index < info.length
        && info[index]
        && 'class' in info[index]) {
        ret = info[index].class
      }
      return ret;
    },

    /**
     * @description 治療進捗状況一覧を表示
     */
    showAcceptanceStatusInfo(event) {
      this.popoverAcceptanceStatusInfoTarget = event;
      this.popoverAcceptanceStatusInfoVisible = true;
    },
    /**
     * @description 治療進捗状態を更新
     */
    async updateAcceptanceStatusInfo() {
      this.popoverAcceptanceStatusInfoVisible = false;
      await this.$ons.notification.confirm({
        modifier:"info",
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title:"確認",
        title: DIALOG_MESSAGES[13000042].title,
        // message:"治療進捗状況を更新します。<br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000042].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer == 1){
             //add 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 start
            this.initDate = moment();
             //add 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 end
            this.rebuildAcceptanceStatusInfo();

          }
        }
      });
    }
    // del #10359_NG対応 編集権限の動作不正 dengshen start
    // // add #10359 編集権限の動作不正 dengshen start
    // ,getItemAuthorized(pageCd, itemCd) {
    //   return getAuthorized(pageCd, itemCd);
    // },
    // // add #10359 編集権限の動作不正 dengshen end
    // del #10359_NG対応 編集権限の動作不正 dengshen end
  }
};
</script>

<style scoped>
.card-list {
  font-size: 150%;
  position: fixed;
  background-color: var(--header-item-background-color);
  padding: 20px;
  opacity: 1;
  visibility: visible;
  transition: opacity 0.3s, height 0.3s, visibility 0.3s;
  box-sizing: border-box;
}
/*mod FNSI- 徐博 start*/
.card-list.small {
  top: 49.59px;
  height: calc(100% - 52px);
}

.card-list.medium {
  top: 62px;
  height: calc(100% - 64px);
}

.card-list.big {
  top: 68.19px;
  height: calc(100% - 71px);
}

.card-list.xbig {
  top: 80.59px;
  height: calc(100% - 82px);
}
/*mod FNSI- 徐博 end*/
.card-list.hidden {
  opacity: 0;
  height: 0;
  visibility: hidden;
}
/*mod FNSI- 徐博 start*/
.card-list >>> .menu-bar {
  position: absolute;
  left: 161px !important;
  top: 20px;
}
/* mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start */
.card-list >>> .card-infos {
  height: 100% !important;
  margin-left: 143px;
  overflow-y: scroll;
}
/* mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end */
/*mod FNSI- 徐博 end*/
.card-list >>> .pat-info-header-area .btn-cancel,
.card-list >>> .pat-info-header-area .btn-save {
  position: absolute;
}

/* ヘッダーパネル設定 */
table,
table th,
table td {
  height: 100%;
}

.search-button {
  width: 2em;
  height: 6.2em;
  background-color: rgb(64, 64, 64);
  visibility: hidden;
}

.pat-header {
  width: 100%;
  height: 6.2em;
  background-color: var(--header-item-background-color);
  background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  background-image:         linear-gradient(rgba(210,210,210,.2) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  font-size: 1em;
}
/* add FNSI-体重計測定レイアウト調整　陳 start */
.pat-header_mode {
  width: 100%;
  height: 8.5em;
  background-color: var(--header-item-background-color);
  background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  background-image:         linear-gradient(rgba(210,210,210,.2) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  font-size: 1em;
}
/* add FNSI-体重計測定レイアウト調整　陳 end */
.event-area {
  color: var(--ntss-header-color);
  width: 100%;
  border-collapse: collapse;
  table-layout: auto;
}

.search-button-area {
  width: 2em;
}

.pat-name-area {
  width: 20em;
}

.hosp-pat-id {
  width: 100%;
  font-size: 1.1em;
  display: inline-block;
  /*add FNSI-改修内容5960 任 start*/
  word-break: keep-all;
  /*add FNSI-改修内容5960 任 end*/
}

.same-icon{
  height: 1.0em;
  display: inline-block;
  margin-left: 0.5em;
  vertical-align: -0.1em;
}

.loading-modal {
  text-align: center;
  font-size: 30px;
}

/* .pat-same,
.hosp-pat-id {
  font-size: 1.5em;
} */

.pat-icon-area {
  width: 80px;
  min-width: 80px;
  vertical-align: top;
}

.in-out-area {
  margin-top: 0.5em;
}

.icon-area {
  font-size: 22px;
}

.patinfo-treattime-area{
  max-width: calc(100% - 4em - 285px);
  font-size: 1.5em;
  vertical-align: top;
}

.patinfo-treattime-area-scroll {
  overflow-x: auto;
}

.patinfo-treattime-area-scroll::-webkit-scrollbar {
  display: none;
}

.pat-header-pat-info-area {
  width: 10em;
  display:inline-block;
  margin-top: 0.5em;
}
/* add 患者情報共通ヘッダーの文字数および文字サイズによる、フォントサイズ制御が動かなくなり、スマホ患者名がほとんど見えなくなる 5771　shan start */
.pat-name {
  display: inline-block;
  /* width: 99%; */
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 3.5em;
}
/* add 患者情報共通ヘッダーの文字数および文字サイズによる、フォントサイズ制御が動かなくなり、スマホ患者名がほとんど見えなくなる 5771　shan end */
.pat-name-in-hospital {
  color: rgb(163, 86, 163);
}

.pat-create {
  display: inline-block;
  width: auto;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.taboo-allergy-area {
  color: red;
}

.infect-area {
  color: orange;
}

.implant-area {
  color: yellow;
}

.treatment-time-area {
  position: relative;
  width: max-content;
  margin-right: 2em;
  display:inline-block;
  cursor: pointer;
}

.treatment-count-area {
  position: absolute;
  color: var(--ntss-base-color);
  line-height: 28px;
  display: flex;
  width: 100%;
  justify-content: center;
}

/* スマホスタイル */
@media screen and (max-width: 500px) {
  .pat-header-pat-info-area,
  .treatment-time-area,
  .patinfo-treattime-area-scroll-child {
    display: none;
  }

  .pat-icon-area {
    padding-right: 15px;
  }

  .hosp-pat-id {
    font-size: 11px;
  }
}
@media screen and (min-height:650px) {
  .taboo-allergy-popover-div,
  .infection-popover-div,
  .implant-popover-div {
    max-height: 600px !important;
  }
}

.vons-popover >>> .popover__content {
  max-width: 500px;
  margin: 3px;
}

.infection-item >>> .calender {
  display: none;
}

.infection-popover >>> .popover__content {
  max-width: 500px;
  margin: 3px;
}

.infection-popover >>> input[type="date"] {
  width: 100%;
}

.implant-popover >>> .popover__content {
  max-width: 500px;
  margin: 3px;
}

.taboo-allergy-popover-div,
.implant-popover-div {
  padding: 25px;
  overflow: auto;
  height: calc(100% - 50px);
}

.infection-popover-div {
  padding: 15px;
  overflow: auto;
  height: calc(100% - 30px);
}

.acceptance-status-info-popover >>> .popover--top {
  max-width: 150px;
}
.acceptance-status-info-popover >>> .popover__content {
  min-height: auto;
  margin: 3px 3px 3px 0;
}
.acceptance-status-info-popover >>>.acceptance-status-info-area {
  max-height: 10em;
  margin: 5px 0 0 5px;
  overflow-y: auto;
}
.acceptance-status-info-popover >>>.acceptance-status-info-bar {
  padding: 1px 3px 3px 1px;
}
.acceptance-status-info-popover >>>.acceptance-statusn-info-button-area {
  text-align: right;
  padding: 5px;
}
.acceptance-status-info-popover >>>.common-style-ok-button {
  width: 100%;
}

.popover-style >>> .popover__content {
  width: 300px;
  height: 2em;
  font-size: 2em;
  margin: 3px;
}
.pat-icon {
  max-height: 30px;
  max-width: 26px;
  display: inline-block;
  cursor: pointer;
}
/*add FNSI-画面部品デザイン じょはく start*/
/* mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start */
.pat-info-header-area {
  width: 100%;
  height: calc(100% - 40px);
}
/* mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end */
/*add FNSI-画面部品デザイン じょはく end*/
/*add FNSI-改修内容4132 任 start*/
@media screen and (max-width: 600px){
  #pat-name-area{
    width: 15em!important;
  }
}
/*add FNSI-改修内容4132 任 end*/
@media print {
  .card-list {
    position: relative !important;
    padding: 0;
    top: 0 !important;
  }
  .pat-info-header-area {
    height: auto !important;
    background-color: unset;
  }
  .card-list >>> .menu-bar {
    top: 0;
  }
  .card-list >>> div {
    height: auto !important;
  }
  /** 見出し開閉ボタン非表示 */
  .type-right {
    display: none;
  }
}
</style>
