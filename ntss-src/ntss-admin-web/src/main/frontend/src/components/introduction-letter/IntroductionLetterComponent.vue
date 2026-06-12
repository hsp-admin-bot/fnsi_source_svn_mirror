<template>
  <div id="introduction-letter">
    <div style="padding-left: 10px; overflow: hidden">
      <div class="form">
        <table>
          <tbody>
            <tr>
              <!--mod FNSI-改修内容redmine4420 范  start-->
              <!--          <td class="text-right">区分：</td>-->
              <td>区分：</td>
              <!--mod FNSI-改修内容redmine4420 范  end-->
              <td>
                <!-- mod FNSI-改修内容転入時の紹介状取込ができない 任 start-->
                <!--<v-ons-radio
                  v-model="letterCategory"
                  :value="0"
                  input-id="out"
                  modifier="round"
                  name="letterCategory"></v-ons-radio>
                <label for="out">転出</label>
                <v-ons-radio
                  v-model="letterCategory"
                  :value="1"
                  input-id="in"
                  modifier="round"
                  name="letterCategory"></v-ons-radio>
                <label for="in">転入</label>-->
                <v-ons-radio v-model="letterCategory" :value="0" input-id="out" modifier="round"
                  @click="setReportFlagTrue" :disabled="getViewMode || this.getUpdateMode"
                  name="letterCategory"></v-ons-radio>
                <label for="out">転出</label>
                <!--mod FNSI-改修内容redmine4168 任 start-->
                <!--<v-ons-radio
                  v-model="letterCategory"
                  :value="1"
                  input-id="in"
                  modifier="round"
                  @click="setReportFlagFalse"
                  :disabled="getViewMode"
                  name="letterCategory"></v-ons-radio>-->
                <v-ons-radio v-model="letterCategory" :value="1" input-id="in" modifier="round"
                  @click="setReportFlagFalse" :disabled="getViewMode || this.getUpdateMode" style="margin-left: 5px;"
                  name="letterCategory"></v-ons-radio>
                <!--mod FNSI-改修内容redmine4168 任 end-->
                <label for="in">転入</label>
                <!-- mod FNSI-改修内容転入時の紹介状取込ができない 任 end-->
                <!-- mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start-->
                <!-- <input type="date"
                  v-model="reportStartDate"
                  :disabled="getViewMode"
                  class="input ntss-input-date"
                  :class="reportStartDateClassCtrl.classObject"
                  ref="reportStartDateInput"
                  max="9999-12-31"/>
                <common-calendar v-model="reportStartDate" :disabled="getViewMode"/>-->
                <date-input
                  v-model="reportStartDate"
                  :disabled="getViewMode || getReportIsDel === '1'"
                  class="input ntss-input-date"
                  :class="reportStartDateClassCtrl.classObject"
                  classes="date-input-required"
                  ref="reportStartDateInput"
                  max="9999-12-31"
                  @focus="onFocusInStartDate"
                  @input="onInputStartDate"
                  @blur="onFocusOutStartDate()"
                  isRequired
                />
                <common-calendar v-model="reportStartDate" :disabled="getViewMode || getReportIsDel === '1'"
                  @input="handleReportStartDateChange()" />
                <!-- mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end-->
              </td>
            </tr>
            <tr>
              <!--mod FNSI-改修内容redmine4420 范  start-->
              <!-- <td class="text-right">転入出先：</td>-->
              <td>転入出先：</td>
              <!--mod FNSI-改修内容redmine4420 范  end-->

              <!--add FNSI-改修内容患者転入選択後、転出戻したら、画面の状態が元と違う 任 start-->
              <!--<td>
                <v-ons-input
                  type="text"
                  style="margin-right: 5px"
                  :value="getFacilityName(toFacilityCd)"
                  :disabled="true"/>
                <v-ons-button
                  ref="popoverButton"
                  class="common-style-select-button button"
                  @click="handleShowPopover()"
                >選択</v-ons-button>-->
              <td style="display: flex; align-items: center;">
                <custom-simple-textarea-b id="input-value-name" style="margin-right: 5px" v-model="inputValueName"
                  @blur="setValueName" :disabled="getViewMode" />
                <!--mod FNSI-改修内容画面デザイン 任 start-->
                <!--<v-ons-button
                  ref="popoverButton"
                  class="common-style-select-button button"
                  @click="handleShowPopover()"
                  :disabled="getViewMode"
                >選択</v-ons-button>-->
                <v-ons-button ref="popoverButton" class="common-style-select-button button btn3-normal"
                  @click="selectPopoverData(popoverDataMstFacility())" :disabled="getViewMode">選択</v-ons-button>
                <!--mod FNSI-改修内容画面デザイン 任 start-->
                <!--mod FNSI-改修内容患者転入選択後、転出戻したら、画面の状態が元と違う 任 end-->
              </td>
            </tr>
          </tbody>
        </table>
        <!--mod FNSI-改修内容redmine4180 任 start-->
        <!--<pop-over
          v-bind="popoverData"
          :target-position-element="$refs.popoverButton"
          @popover-close="closePopover"
          @popover-return="selectedValue"
        />-->
        <pop-over v-bind="popoverData" :target-position-element="$refs.popoverButton" @popover-close="closePopover"
          @popover-return="selectedValue" />
        <!--mod FNSI-改修内容redmine4180 任 end-->
      </div>
      <!-- mod FNSI-改修内容転入時の紹介状取込ができない/帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 start-->
      <!--<div class="template-content">
        <div v-html="getHtmlTemplate" id="content-html"></div>
      </div>-->
      <div v-if="getPathReal === null && !getIsNotExit" class="template-content">
        <!--mod FNSI-改修内容患者イベントbug 任 start-->
        <!--<div v-html="getHtmlTemplate" id="content-html"></div>-->
        <!--mod   Aspose.cells plug-in integration  吉 start-->
        <!--<div v-if="getUpdatePdf" v-html="getHtmlTemplate" id="content-html"></div>-->
        <!--mod 10499 紹介状画面でセルの縦配置設定が反映しない 吉 start-->
        <!--<div v-if="getUpdatePdf" v-html="getHtmlTemplate" id="content-html" align="center"></div>-->
        <!--mod 11488 紹介状登録内容保存時に帳票の版も記憶する 吉 start-->
        <!--<div v-if="getUpdatePdf" v-html="getHtmlTemplate" id="content-html-id" align="center"></div>-->
        <div v-if="getUpdatePdf" v-html="getHtmlTemplate" id="content-html-id" ref="contentHtml" align="center" v-show="pdfShow"></div>
        <!--mod 11488 紹介状登録内容保存時に帳票の版も記憶する 吉 end-->
        <!--mod 10499 紹介状画面でセルの縦配置設定が反映しない 吉 end-->
        <!--mod   Aspose.cells plug-in integration  吉 end-->
        <!--add FNSI-改修内容患者イベントbug 任 end-->
      </div>
      <div v-else-if="getPathReal !== null" class="template-content">
        <template>
          <!-- mod #12370 紹介状の転入の動作不正 修正 start -->
          <PdfViewer ref="pdf" v-for="i in numPages" :key="i" :src="getPathReal" :page="i"></PdfViewer>
          <!-- mod #12370 紹介状の転入の動作不正 修正 end -->
        </template>
      </div>
      <div v-else class="template-content">
        <span style="color: #FF0000">{{ this.msgDiaLog }}</span>
      </div>
      <!-- mod FNSI-改修内容転入時の紹介状取込ができない/帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 end-->
    </div>
  </div>
</template>

<script>
import $$ from "@/compat/jquery";
  /*add FNSI-改修内容redmain3772 范 start*/

  import {mapActions, mapGetters} from "@/compat/vue/vuex";
  /*mod FNSI-改修内容redmine4180 任 start*/
  /*import MasterSelector from "@/components/common/master-selector/MasterSelector";*/
  import MasterSelector from "@/components/common/master-selector/MasterSelectorFacility";
  /*mod FNSI-改修内容redmine4180 任 end*/
  import { makeRequiredClassConrtoller } from "@/functions/for-componet/ClassControlFunctions.js";
  import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
  /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
  /* mod #12370 紹介状の転入の動作不正 修正 start */
  // import pdf from "vue-pdf"
  import PdfViewer from "@/components/common/PdfViewer.vue";
  /* mod #12370 紹介状の転入の動作不正 修正 end */
  /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  import CustomSimpleTextareaTypeB from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeB";
  import dayjs from "@/compat/date/dayjs";
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
  /*add FNSI-改修内容患者転入選択後、転出戻したら、画面の状態が元と違う 任 start*/
  import {EventBus} from "@/compat/vue/event-bus.js";
  /*add FNSI-改修内容患者転入選択後、転出戻したら、画面の状態が元と違う 任 end*/
  /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
  /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
  //FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  /*add FNSI-改修内容redmain3772 范 end*/
  //FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
  /* add by chamaojia 2025-05-21 [11871]  --start */
  import { ApiHelper } from "@/apis/AxiosHelper";
  import { queryElementBySelectors,
  getScopedJQuery as createScopedJQuery} from "@/functions/common/LayoutMeasureHelper";
  // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260424 start
  import { sendRequestPostImageUpload, sendRequestPostImageDelete } from "@/apis/pat-event";
  import { dateFormat } from "@/functions/common/DateTimeUtils.js";
  import DateInput from "@/components/common/DateInput";
  // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260424 end
  /* add by chamaojia 2025-05-21 [11871]  --end */

/**
 * @description 紹介状作成コンポーネント
 */
export default {
  mixins: [baseCardContent],

  data() {
    return {
      /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
      reportStartDate: null,
      /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
      reportStartDateClassCtrl: makeRequiredClassConrtoller(true),
      /* del by chamaojia 2025-05-21 [11871]  --start */
      /*facilityList: null,*/
      /* del by chamaojia 2025-05-21 [11871]  --end */
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
      realPath: null,
      /*add FNSI-改修内容redmine4179 任 start*/
      inputValueName: null,
      /*add FNSI-改修内容redmine4179 任 end*/
      msgDiaLog: DIALOG_MESSAGES["02700017"].message,
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
      // 転入出先文情報
      /*mod FNSI-改修内容redmine4180 任 start*/
      /*popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "right",
        popoverTitleHeader: "転入出先",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverContentLabel: "転入出先名",
        popoverContentDataset: [],
        popoverContentSelected: {}
      },*/
      popoverData: {
        popoverVisible: false,
        popoverTitleHeader: "施設",
        popoverContentLabel: "施設名",
        popoverContentDataset: [],
        popoverContentSelected: {}
      },
      /*mod FNSI-改修内容redmine4180 任 end*/
      isFound: false,

      numPages: 2,
      /* add by chamaojia 2025-05-21 [11871]  --start */
      facilityNameList: [],
      /* add by chamaojia 2025-05-21 [11871]  --end */
      // add 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 start
      pdfShow: false,
      contentObserver: null,
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
      reportStartDateInputInit: null,
      hasFocusStartDate: false,
      hasInputStartDate: false,
      inProgressChangeConditionSee: false,
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
      imageUploadButtons: {},
      uploadedImages: {},
      showUploadButton: false,
      fileList: null,
      deletedImages: [],
      activeUploadCell: null,
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    };
  },

  props: {
    getViewMode: {
      type: Boolean,
      default: false
    },
    getUpdateMode: {
      type: Boolean,
      default: false
    },
  },

  components: {
    /*mod FNSI-改修内容転入時の紹介状取込ができない/転入転出の患者情報連動 任 start*/
    /*"pop-over": MasterSelector*/
    /* mod #12370 紹介状の転入の動作不正 修正 start */
    // "pop-over": MasterSelector,pdf,
    "pop-over": MasterSelector, PdfViewer,
    /* mod #12370 紹介状の転入の動作不正 修正 end */
    "common-calendar": commonCalender,
    /*mod FNSI-改修内容転入時の紹介状取込ができない/転入転出の患者情報連動 任 end*/
    "custom-simple-textarea-b": CustomSimpleTextareaTypeB,
    "date-input": DateInput,
  },

  computed: {
    /*mod FNSI-改修内容転入転出の患者情報連動 任 start*/
    /*...mapGetters("pat-info", ["selectedPatId"]),*/
    ...mapGetters("pat-info", ["selectedPatId", "getReportStartDate"]),
    /*mod FNSI-改修内容転入転出の患者情報連動 任 end*/
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("introduction-letter", [
      "getLetterCategory",
      "getToFacilityCd",
      /*add FNSI-改修内容転入時の紹介状取込ができない/帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 start*/
      "getPathReal",
      "getIsNotExit",
      /*add FNSI-改修内容患者イベントbug 任 start*/
      "getUpdatePdf",
      /*add FNSI-改修内容患者イベントbug 任 end*/
      /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 start*/
      "getIsGoNext",
      /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 end*/
      /*add FNSI-改修内容転入時の紹介状取込ができない/帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 end*/
      "getHtmlTemplate"
      // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
      ,"getReportIsDel"
      // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
    ]),
    ...mapGetters("pat-event/detail", [
      "getPatEventRecord"
    ]),
    // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
    ...mapGetters("pat-event/list", [
      "getReportFlag",
      "getEventStartDate"
    ]),
    // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
    /* del by chamaojia 2025-05-21 [11871]  --start */
    /*...mapGetters("sys-facility", ["getSysFacilities", "getSysFacilitiesForName"]),*/
    /* del by chamaojia 2025-05-21 [11871]  --end */
    letterCategory: {
      get() {
        /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
        if (this.getLetterCategory === "0") {
          this.setReportFlag(true)
        }
        /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
        return this.getLetterCategory;
      },
      set(value) {
        this.setLetterCategory(value);
      }
    },
    toFacilityCd: {
      get() {
        return this.getToFacilityCd;
      },
      set(value) {
        this.setToFacilityCd(value);
      }
    },
  },
  async created() {
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 start*/
    if (!this.getUpdateMode) {
      this.setLetterCategory("0");
      this.setReportStartDate(null);
      this.setToFacilityCd();
      // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 start
      this.setToMedicalInstitutionCd();
      // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 end
    }
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 end*/
    /* mod for 紹介状性能 周 start */
    /**
     * レイアウトHTML, 転入出先をロード
     */
    /* del for 紹介状性能 周 start */
    // await facility()
    //     .then(response => {
    //       const facilityList = response.map(res => {
    //         return {
    //           facilityCd: res.facilityCd,
    //           facilityName: res.facilityName,
    //           prefecturesCd: res.prefecturesCd,
    //           // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 start
    //           medicalInstitutionCd:res.medicalInstitutionCd
    //           // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 end
    //         };
    //       });
    //       this.facilityList = facilityList;
    //     })
    /* del by chamaojia 2025-05-21 [11871]  --start */
    /*this.facilityList = this.getSysFacilities;*/
    /* del by chamaojia 2025-05-21 [11871]  --end */
    /* mod for 紹介状性能 周 end */
    let letterInfo = this.getPatEventRecord && this.getPatEventRecord.letterInfo && JSON.parse(this.getPatEventRecord.letterInfo);
    if (letterInfo) {
      /* add by chamaojia 2025-05-21 [11871]  --start */
      const rest = await ApiHelper.get("/sysFacility/getSysFacilityByCd/" + letterInfo.to_facility_cd);
      if (rest.data) {
        const obj = {
          cd: rest.data.medicalInstitutionCd,
          name: rest.data.facilityName
        };
        this.facilityNameList.push(obj);

      }
      /* add by chamaojia 2025-05-21 [11871]  --end */
      this.setLetterCategory(letterInfo.letter_category.toString());
      /*mod FNSI-改修内容redmain6622 任 start*/
      /*this.setToFacilityCd(letterInfo.to_facility_cd);*/
      /*mod FNSI-改修内容redmain6609 周 start*/
      /*this.setToFacilityCd(letterInfo.to_medical_institution_cd);*/
      this.setToFacilityCd(letterInfo.to_facility_cd);
      /*mod FNSI-改修内容redmain6609 周 end*/
      /*mod FNSI-改修内容redmain6622 任 end*/
      // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 start
      this.setToMedicalInstitutionCd(letterInfo.to_medical_institution_cd);
      // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 end
    }
    this.timerAction = setInterval(() => {
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
        //const isF = document.querySelectorAll("td[id]");
        const isF = this.getLetterCells();
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
        this.isFound = isF.length > 0;
      }, 500);
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    this.$nextTick(() => {
      setTimeout(() => {
        this.processInitialTemplateImages();
        if (letterInfo) {
          const letterData = letterInfo.letter_data;
          if (letterData) {
            this.applySavedLetterData(letterData);
          }
        }
        this.processStoredImages();
      }, 500);
    });
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end

      if (this.getHtmlTemplate && letterInfo) {
        const letterData = letterInfo.letter_data;
        if (letterData) {
          try {
            // mod #7162 紹介状画面で編集しても保存されないことを修正 劉 start
            this.$nextTick(() => {
              // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
              // Object.keys(letterData).map(x => {
              //   /*del FNSI-改修内容bug修正 任 start*/
              //   if(x !== "pat-name-area"){
              //     document.getElementById(`${x}`).innerHTML = letterData[x];
              //   }
              //   /*del FNSI-改修内容bug修正 任 end*/
              // });
              document
              .querySelectorAll("td[excelCoordinate]")
              .forEach((tdElement) => {
                // もしくは letterData に対応する空文字列でない値が入っていない
                // 以上の場合は書き戻し対象外とする
                // mod 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 start
                // if (!letterData[tdElement.getAttribute("excelCoordinate")]) return;
                // tdElement.innerHTML = letterData[tdElement.getAttribute("excelCoordinate")];

                // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
                const coordinate = tdElement.getAttribute("excelCoordinate");
                const cellData = letterData[coordinate];
                if (!cellData) {
                  tdElement.innerHTML = "";
                } else {
                  tdElement.setAttribute('data-original-content', cellData);
                  const cleanedData = this.cleanImageData(cellData);
                  tdElement.innerHTML = cleanedData;
                  const imgElements = tdElement.querySelectorAll('img');
                  imgElements.forEach(img => {
                    if (img.hasAttribute('width') && img.hasAttribute('height')) {
                      const originalWidth = img.getAttribute('width');
                      const originalHeight = img.getAttribute('height');
                      img.style.width = originalWidth + 'px';
                      img.style.height = originalHeight + 'px';
                    }
                    img.style.height = '23px';
                    img.style.width = 'auto';
                    img.style.maxWidth = '100%';
                    img.style.maxHeight = '100%';
                    img.style.minWidth = '23px';
                    img.style.minHeight = '23px';
                    img.style.objectFit = 'contain';
                    img.style.display = 'block';
                  });
                  if (!this.getViewMode) {
                    this.bindImageClickEvent(tdElement, coordinate);
                  }
                }
                // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end

                // del #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
                // if (!letterData[tdElement.getAttribute("excelCoordinate")]) {
                //   tdElement.innerHTML = "";
                // } else {
                //   tdElement.innerHTML =
                //     letterData[tdElement.getAttribute("excelCoordinate")];
                // }
                // del #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end

                // mod 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 end
              });
              // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
            })
            // mod #7162 紹介状画面で編集しても保存されないことを修正 劉 end
          } catch(error) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('IntroductionLetterComponent.vue', 'facility', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            return;
          }
        }
      }
      // add 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 start
      this.pdfShow = true;
      // add 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 end
  },
  watch: {
    reportStartDate() {
      // 入力値が変更されたらエラースタイルをクリアする
      this.reportStartDateClassCtrl.setInvalid(false);
    },
    getHtmlTemplate(value) {
      if (value) {
        if (!this.getUpdateMode) {
          this.handleEnableControl();
        } else {
          if (!this.getViewMode) {
            this.handleEnableControl();
          }
        }
      }
    },
    isFound(value) {
      if (value) {
        clearInterval(this.timerAction);
        if (!this.getUpdateMode) {
          this.handleEnableControl();
        } else {
          if (!this.getViewMode) {
            this.handleEnableControl();
          }
        }
      }
    },
    getViewMode(value) {
      if (!value) {
        this.handleEnableControl();
      }
    }
  },
  methods: {
    scopedJQuery() {
      return createScopedJQuery(this.$el || this, $$) || $$;
    },
    getLetterRoot() {
      return this.$refs.letterRoot || this.$el || document;
    },
    getLetterContentRoot() {
      return this.$refs.contentHtml
        || queryElementBySelectors(["#content-html-id", "#table_0", "#section"], this.getLetterRoot())
        || null;
    },
    getLetterCells(root = null) {
      const target = root || this.getLetterContentRoot() || this.getLetterRoot();
      return Array.from(target?.querySelectorAll?.("td[excelCoordinate]") || []);
    },
    getLetterCellByCoordinate(key) {
      if (!key) return null;
      const matched = this.getLetterCells().find((cell) => cell.getAttribute?.("excelCoordinate") === key || cell.id === key);
      return matched || queryElementBySelectors([`#${key}`, `[id="${key}"]`], this.getLetterContentRoot() || this.getLetterRoot());
    },
    getLetterInputValueElement() {
      return queryElementBySelectors(["#input-value-name"], this.getLetterRoot());
    },
    // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
    ...mapActions("introduction-letter", [
      "setLetterCategory",
      "setToFacilityCd",
      // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 start
      "setToMedicalInstitutionCd"
      // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 end
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
      , "setTemplate"
      , "setHtmlTemplate"
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
    ]),
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
    ...mapActions("pat-event/list", [
      "setReportFlag"
    ]),
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 start*/
    ...mapActions("pat-info", ["setReportStartDate"]),
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 end*/
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    processInitialTemplateImages() {
      this.$nextTick(() => {
        document.querySelectorAll("td[excelCoordinate]").forEach(tdElement => {
          const coordinate = tdElement.getAttribute("excelCoordinate");
          const innerHTML = tdElement.innerHTML;
          if (innerHTML.includes('<img')) {
            const hasSemicolonPath = innerHTML.includes(';path:') ||
              (innerHTML.includes(';') && innerHTML.lastIndexOf(';') > innerHTML.indexOf('>'));
            let fullContent = innerHTML;
            if (!hasSemicolonPath) {
              const imgMatch = innerHTML.match(/<img[^>]*src="([^"]+)"[^>]*>/);
              if (imgMatch && imgMatch[1]) {
                const src = imgMatch[1];
                fullContent = `${innerHTML};path:${src}`;
              }
            }
            tdElement.setAttribute('data-original-content', fullContent);
            const cleanContent = this.cleanImageDataForDisplay(innerHTML);
            tdElement.innerHTML = cleanContent;
            const imgElements = tdElement.querySelectorAll('img');
            imgElements.forEach(img => {
              img.removeAttribute('width');
              img.removeAttribute('height');
              img.style.maxWidth = 'none';
              img.style.maxHeight = 'none';
              img.style.minWidth = '0';
              img.style.minHeight = '0';
              img.style.objectFit = 'contain';
              img.style.display = 'block';
              this.applyImageAlignment(tdElement, img);
            });
            if (!this.getViewMode) {
              this.bindImageClickEvent(tdElement, coordinate);
            }
          }
        });
      });
    },
    fitImageToCellByHeight(cell, img) {
      if (!cell || !img) return;
      const cellStyle = window.getComputedStyle(cell);
      const paddingY =
        (parseFloat(cellStyle.paddingTop) || 0) +
        (parseFloat(cellStyle.paddingBottom) || 0);
      const availableHeight = Math.max(1, cell.clientHeight - paddingY);
      const imgWidth = img.naturalWidth || img.width;
      const imgHeight = img.naturalHeight || img.height;
      if (!imgWidth || !imgHeight) {
        img.style.height = '23px';
        img.style.width = 'auto';
        return;
      }
      const ratio = imgWidth / imgHeight;
      const maxSmallCellHeight = 40;
      let targetHeight, targetWidth;
      if (availableHeight <= maxSmallCellHeight) {
        targetHeight = 23;
        targetWidth = targetHeight * ratio;
        const availableWidth =
          cell.clientWidth -
          (parseFloat(cellStyle.paddingLeft) || 0) -
          (parseFloat(cellStyle.paddingRight) || 0);
        if (targetWidth > availableWidth) {
          targetWidth = availableWidth;
          targetHeight = targetWidth / ratio;
        }
      } else {
        targetHeight = availableHeight;
        targetWidth = targetHeight * ratio;
        const availableWidth =
          cell.clientWidth -
          (parseFloat(cellStyle.paddingLeft) || 0) -
          (parseFloat(cellStyle.paddingRight) || 0);
        if (targetWidth > availableWidth) {
          targetWidth = availableWidth;
          targetHeight = targetWidth / ratio;
        }
      }

      img.style.height = `${targetHeight}px`;
      img.style.width = `${targetWidth}px`;
      img.style.maxWidth = 'none';
      img.style.maxHeight = 'none';
      img.style.minWidth = '0';
      img.style.minHeight = '0';
      img.style.objectFit = 'contain';
      img.style.display = 'block';
      img.style.verticalAlign = 'top';
      cell.style.overflow = 'hidden';
      cell.style.boxSizing = 'border-box';
      cell.style.maxWidth = '100%';
      cell.style.maxHeight = '100%';
    },
    applySavedLetterData(letterData) {
      if (!letterData) return;
      this.$nextTick(() => {
        document.querySelectorAll("td[excelCoordinate]").forEach(tdElement => {
          const coordinate = tdElement.getAttribute("excelCoordinate");
          const cellData = letterData[coordinate];
          if (cellData) {
            tdElement.setAttribute('data-original-content', cellData);
            const cleanedData = this.cleanImageDataForDisplay(cellData);
            tdElement.innerHTML = cleanedData;
            const imgElements = tdElement.querySelectorAll('img');
            imgElements.forEach(img => {
              if (img.naturalWidth && img.naturalHeight) {
                this.fitImageToCellByHeight(tdElement, img);
              } else {
                img.style.height = '23px';
                img.style.width = 'auto';
                img.addEventListener('load', () => {
                  this.fitImageToCellByHeight(tdElement, img);
                }, { once: true });
              }
              this.applyImageAlignment(tdElement, img);
            });
            this.removeUploadButton(coordinate);
          }
        });
      });
    },
    cleanImageDataForDisplay(cellData) {
      if (!cellData || typeof cellData !== 'string') {
        return cellData || '';
      }
      let cleaned = cellData.replace(/<img([^>]*?)\s(width|height)\s*=\s*["'][^"']*["']([^>]*?)>/gi, '<img$1$3>');
      if (cleaned.includes(';path:')) {
        const lastSemicolonIndex = cleaned.lastIndexOf(';');
        const htmlContent = cleaned.substring(0, lastSemicolonIndex);
        return htmlContent;
      }
      if (cleaned.includes('<img')) {
        return cleaned;
      }
      if (cleaned.includes('<') && cleaned.includes('>')) {
        return cleaned;
      }
      return `<span>${cleaned}</span>`;
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    handleResetControl() {
      this.getLetterCells().forEach(x => x.innerHTML="");
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    addImageUploadButtons() {
      this.$nextTick(() => {
        const allCells = document.querySelectorAll('td[excelCoordinate][contenteditable="true"]');
        const editableCells = Array.from(allCells).filter(cell => {
          // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260427 start
          // return this.hasBorderStyle(cell);
          return true;
          // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260427 end
        });
        this.cleanupImageUploadButtonsComplete();
        this.floatingButtonContainer = document.createElement('div');
        this.floatingButtonContainer.id = 'floating-image-upload-container';
        this.floatingButtonContainer.style.cssText = `
          position: fixed;
          display: none;
          z-index: 2147483647;
          pointer-events: none;
        `;
        document.body.appendChild(this.floatingButtonContainer);
        const uploadBtn = document.createElement('button');
        uploadBtn.className = 'image-upload-btn floating-upload-btn';
        uploadBtn.type = 'button';
        uploadBtn.innerHTML = '+';
        uploadBtn.title = '画像をアップロードします';
        uploadBtn.style.cssText = `
          background: #4291B9;
          color: white;
          border: none;
          border-radius: 3px;
          width: 20px;
          height: 20px;
          cursor: pointer;
          line-height: 1;
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 0;
          margin: 0;
          opacity: 0.8;
          pointer-events: auto;
          border-bottom: 3px solid #4974a0;
          box-shadow: unset;
        `;
        this.floatingButtonContainer.appendChild(uploadBtn);

        const handleUploadClick = (e) => {
          e.preventDefault();
          e.stopPropagation();
          const coordinate = uploadBtn.dataset.coordinate;
          if (!coordinate) return;
          const hiddenInput = document.createElement('input');
          hiddenInput.type = 'file';
          hiddenInput.accept = 'image/*';
          hiddenInput.style.cssText = 'position:absolute;left:-9999px;top:-9999px;opacity:0;';
          hiddenInput.onchange = (event) => {
            if (hiddenInput.files && hiddenInput.files.length > 0) {
              this.handleImageUpload(event, coordinate);
            }
            document.body.removeChild(hiddenInput);
            this.hideFloatingButton();
          };
          document.body.appendChild(hiddenInput);
          hiddenInput.click();
        };

        uploadBtn.addEventListener('click', handleUploadClick);

        const handleGlobalMouseDown = (e) => {
          if (!this.floatingButtonContainer || !this.floatingButtonContainer.style) {
            document.removeEventListener('mousedown', handleGlobalMouseDown);
            return;
          }

          if (
            this.floatingButtonContainer.style.display === 'block' &&
            !this.floatingButtonContainer.contains(e.target) &&
            (!this.activeUploadCell || !this.activeUploadCell.contains(e.target))
          ) {
            this.hideFloatingButton();
          }
        };

        this.globalMouseDownListener = handleGlobalMouseDown;
        document.addEventListener('mousedown', handleGlobalMouseDown);

        const showFloatingButton = (cell) => {
          if (cell.getAttribute('isimage') === 'true') return;
          const rect = cell.getBoundingClientRect();
          uploadBtn.dataset.coordinate = cell.getAttribute('excelCoordinate');
          this.floatingButtonContainer.style.top = `${rect.top + 2}px`;
          this.floatingButtonContainer.style.left = `${rect.right - 22}px`;
          this.floatingButtonContainer.style.display = 'block';
          this.activeUploadCell = cell;

          const handleScroll = () => {
            this.hideFloatingButton();
          };

          const debounce = (func, wait) => {
            let timeout;
            return function executedFunction(...args) {
              const later = () => {
                clearTimeout(timeout);
                func(...args);
              };
              clearTimeout(timeout);
              timeout = setTimeout(later, wait);
            };
          };

          const debouncedHandleScroll = debounce(handleScroll, 50);

          window.addEventListener('scroll', debouncedHandleScroll, { passive: true });
          window.addEventListener('wheel', debouncedHandleScroll, { passive: true });

          this.currentScrollHandlers = {
            scroll: debouncedHandleScroll,
            wheel: debouncedHandleScroll
          };
        };

        this.hideFloatingButton = () => {
          if (this.floatingButtonContainer && this.floatingButtonContainer.style) {
            this.floatingButtonContainer.style.display = 'none';
          }
          this.activeUploadCell = null;

          if (this.currentScrollHandlers) {
            window.removeEventListener('scroll', this.currentScrollHandlers.scroll);
            window.removeEventListener('wheel', this.currentScrollHandlers.wheel);
            this.currentScrollHandlers = null;
          }
        };

        editableCells.forEach(cell => {
          if (window.getComputedStyle(cell).position === 'static') {
            cell.style.position = 'relative';
          }

          cell.addEventListener('dblclick', () => {
            showFloatingButton(cell);
          });
          // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260509 start
          cell.addEventListener('click', () => {
            showFloatingButton(cell);
          });
          // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260509 end
        });

        this.floatingButtonContainer.addEventListener('mouseenter', () => {
          this.floatingButtonContainer.style.display = 'block';
        });

        this.floatingButtonContainer.addEventListener('mouseleave', () => {
        });
      });
    },
    cleanupImageUploadButtonsComplete() {
      if (this.globalMouseDownListener) {
        document.removeEventListener('mousedown', this.globalMouseDownListener);
        this.globalMouseDownListener = null;
      }

      if (this.currentScrollHandlers) {
        window.removeEventListener('scroll', this.currentScrollHandlers.scroll);
        window.removeEventListener('wheel', this.currentScrollHandlers.wheel);
        this.currentScrollHandlers = null;
      }

      if (this.hideFloatingButton) {
        this.hideFloatingButton();
      }

      if (this.floatingButtonContainer && document.body.contains(this.floatingButtonContainer)) {
        document.body.removeChild(this.floatingButtonContainer);
        this.floatingButtonContainer = null;
      }

      this.activeUploadCell = null;
    },
    hideFloatingButton() {
      if (this.floatingButtonContainer) {
        this.floatingButtonContainer.style.display = 'none';
        this.activeUploadCell = null;
      }
    },
    setupTableEventDelegation() {
      const tableContainer = document.querySelector('.template-content');
      if (!tableContainer) return;
      if (this.tableDelegationHandlers) {
        tableContainer.removeEventListener('click', this.tableDelegationHandlers.click);
      }
      const handleClick = (e) => {
        const deleteBtn = e.target.closest('.image-delete-btn');
        if (deleteBtn) {
          e.preventDefault();
          e.stopPropagation();
          e.stopImmediatePropagation();
          const coordinate = deleteBtn.dataset.coordinate;
          this.deleteImage(coordinate);
        }
      };
      tableContainer.addEventListener('click', handleClick, true);
      this.tableDelegationHandlers = {
        click: handleClick
      };
    },
    beforeDestroy() {
      this.cleanupImageUploadButtonsComplete();
      this.deletedImages = [];
    },
    rebindImageUploadButtons() {
      this.cleanupImageUploadButtonsComplete();
      this.addImageUploadButtons();
    },
    // del #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260427 start
    // hasBorderStyle(cell) {
    //   const computedStyle = window.getComputedStyle(cell);
    //   const borderTop = computedStyle.borderTopWidth;
    //   const borderRight = computedStyle.borderRightWidth;
    //   const borderBottom = computedStyle.borderBottomWidth;
    //   const borderLeft = computedStyle.borderLeftWidth;
    //   // if ((borderTop && borderTop !== '0px') ||
    //   //   (borderRight && borderRight !== '0px') ||
    //   //   (borderBottom && borderBottom !== '0px') ||
    //   //   (borderLeft && borderLeft !== '0px')) {
    //   //   return true;
    //   // }
    //   return true;
    // },
    // del #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260427 end
    removeAllImageClickEvents() {
      const allImages = document.querySelectorAll('#content-html-id img');
      allImages.forEach(img => {
        const newImg = img.cloneNode(true);
        img.parentNode.replaceChild(newImg, img);
        newImg.style.cursor = 'default';
      });
    },
    async handleImageUpload(event, coordinate) {
      const file = event.target.files[0];
      if (!file) return;

      this.setLoadingScreenVisible(true);
      try {
        const cell = document.querySelector(`td[excelCoordinate="${coordinate}"]`);
        if (!cell) return;

        cell.innerHTML = '';
        cell.setAttribute('contenteditable', 'true');
        cell.removeAttribute('isimage');
        cell.style.overflow = '';
        cell.style.boxSizing = '';

        const cellStyle = window.getComputedStyle(cell);
        const paddingY =
          (parseFloat(cellStyle.paddingTop) || 0) +
          (parseFloat(cellStyle.paddingBottom) || 0);
        const paddingX =
          (parseFloat(cellStyle.paddingLeft) || 0) +
          (parseFloat(cellStyle.paddingRight) || 0);

        const availableHeight = Math.max(1, cell.clientHeight - paddingY);
        const availableWidth = Math.max(1, cell.clientWidth - paddingX);
        const isSmallCell = availableHeight <= 40;

        const reader = new FileReader();
        reader.onload = (e) => {
          const base64Image = e.target.result;
          const img = document.createElement('img');

          img.src = base64Image;
          img.alt = '画像をアップロードします';
          img.style.cssText = `
            display: block;
            object-fit: contain;
            max-width: 100%;
            max-height: 100%;
            cursor: ${this.getViewMode ? 'default' : 'pointer'};
          `;

          const cell = document.querySelector(`td[excelCoordinate="${coordinate}"]`);
          if (cell) {
            this.applyImageAlignment(cell, img);
          }

          if (!this.getViewMode) {
            this.bindImageClickToElement(img, coordinate);
          }

          cell.appendChild(img);

          img.onload = () => {
            this.adjustImageSizeWithSmallCellFix(
              cell,
              img,
              availableWidth,
              availableHeight,
              isSmallCell
            );
          };

          requestAnimationFrame(() => {
            this.adjustImageSizeWithSmallCellFix(
              cell,
              img,
              availableWidth,
              availableHeight,
              isSmallCell
            );
          });

          this.uploadedImages[coordinate] = {
            base64: base64Image,
            file,
            fileName: file.name,
            fileType: file.type,
            size: file.size,
            lastModified: file.lastModified
          };

          cell.setAttribute('isimage', 'true');
          cell.setAttribute('contenteditable', 'false');

          this.removeUploadButton(coordinate);
        };

        reader.readAsDataURL(file);

      } finally {
        this.setLoadingScreenVisible(false);
        event.target.value = '';
      }
    },
    applyImageAlignment(cell, img) {
      const classList = cell.classList;
      let textAlign = 'center';

      for (let cls of classList) {
        const style = this.getCssPropertyForClass(cls, 'text-align');
        if (style) {
          const lowerStyle = style.toLowerCase().trim();
          if (lowerStyle === 'left' || lowerStyle === 'right' || lowerStyle === 'center') {
            textAlign = lowerStyle;
            break;
          }
        }
      }
      switch (textAlign) {
        case 'left':
          img.style.display = 'block';
          img.style.marginLeft = '0';
          img.style.marginRight = 'auto';
          break;
        case 'right':
          img.style.display = 'block';
          img.style.marginLeft = 'auto';
          img.style.marginRight = '0';
          break;
        case 'center':
        default:
          img.style.display = 'block';
          img.style.marginLeft = 'auto';
          img.style.marginRight = 'auto';
          break;
      }
    },
    getCssPropertyForClass(className, property) {
      for (let sheet of document.styleSheets) {
        try {
          if (!sheet.cssRules) continue;
          for (let rule of sheet.cssRules) {
            if (rule.selectorText && rule.selectorText.includes('.' + className)) {
              const value = rule.style.getPropertyValue(property);
              if (value) {
                return value;
              }
            }
          }
        } catch (e) {
          continue;
        }
      }
      return null;
    },
    adjustImageSizeWithSmallCellFix(cell, img, availableWidth, availableHeight, isSmallCell) {
      if (!cell || !img) return;
      const imgWidth = img.naturalWidth || img.width;
      const imgHeight = img.naturalHeight || img.height;
      if (!imgWidth || !imgHeight) {
        img.style.height = '23px';
        img.style.width = 'auto';
        return;
      }

      const ratio = imgWidth / imgHeight;
      let targetHeight, targetWidth;
      if (isSmallCell) {
        targetHeight = 23;
        targetWidth = targetHeight * ratio;
        if (targetWidth > availableWidth) {
          targetWidth = availableWidth;
          targetHeight = targetWidth / ratio;
        }
      } else {
        targetHeight = availableHeight;
        targetWidth = targetHeight * ratio;
        if (targetWidth > availableWidth) {
          targetWidth = availableWidth;
          targetHeight = targetWidth / ratio;
        }
      }
      img.style.height = `${targetHeight}px`;
      img.style.width = `${targetWidth}px`;
      img.style.maxWidth = 'none';
      img.style.maxHeight = 'none';
      img.style.minWidth = '0';
      img.style.minHeight = '0';
      cell.style.overflow = 'hidden';
      cell.style.boxSizing = 'border-box';
    },
    bindImageClickToElement(imgElement, coordinate) {
      if (!imgElement || !coordinate || this.getViewMode) return;
      imgElement.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        this.deleteImage(coordinate);
      });
    },
    removeUploadButton(coordinate) {
      const cell = document.querySelector(`td[excelCoordinate="${coordinate}"]`);
      if (cell) {
        delete this.imageUploadButtons[coordinate];
      }
    },
    processStoredImages() {
      document.querySelectorAll('td[excelCoordinate]').forEach(tdElement => {
        const coordinate = tdElement.getAttribute('excelCoordinate');
        const img = tdElement.querySelector('img');
        if (img && !img.getAttribute('data-is-stored')) {
          const originalContent = tdElement.getAttribute('data-original-content');
          if (originalContent && originalContent.includes(';path:')) {
            const pathMatch = originalContent.match(/;path:([^;]+)/);
            if (pathMatch && pathMatch[1]) {
              const serverPath = pathMatch[1];
              img.setAttribute('data-is-stored', 'true');
              img.setAttribute('data-serverpath', serverPath);
              if (this.uploadedImages[coordinate]) {
                this.uploadedImages[coordinate].isStored = true;
                this.uploadedImages[coordinate].serverPath = serverPath;
              }
            }
          }
        }
      });
    },
    async saveLetterImages() {
      const uploadResult = await this.uploadImage();
      if (!uploadResult) {
        return { success: false };
      }
      this.updateImagesToServerPath(uploadResult.results);
      if (this.deletedImages && this.deletedImages.length > 0) {
        for (let i = 0; i < this.deletedImages.length; i++) {
          const imgInfo = this.deletedImages[i];
          try {
            await this.deleteSingleImage(imgInfo);
          } catch (error) {
            return { success: false };
          }
        }
      }
      return { success: true };
    },
    async deleteSingleImage(imgInfo) {
      try {
        const result = await this.deleteImageList({
          facilityCd: this.facilityCd,
          patId: this.getPatEventRecord.patId,
          removedFiles: [imgInfo]
        });
        return result;
      } catch (error) {
        getErrorMessage('IntroductionLetterComponent.vue', 'deleteSingleImage', error);
        return false;
      }
    },
    async deleteMarkedImages() {
      if (this.deletedImages.length === 0) {
        return true;
      }
      const patId = this.getPatEventRecord.patId;
      try {
        const result = await this.deleteImageList({
          facilityCd: this.facilityCd,
          patId: patId,
          removedFiles: this.deletedImages
        });
        if (result) {
          this.deletedImages = [];
        }
        return result;
      } catch (error) {
        getErrorMessage('IntroductionLetterComponent.vue', 'deleteMarkedImages', error);
        return false;
      }
    },
    async deleteImageList(params) {
      await sendRequestPostImageDelete({
        facilityCd: params.facilityCd,
        patId: params.patId,
        removedFiles: params.removedFiles
      }).catch(error => {
        getErrorMessage('IntroductionLetterComponent.vue', 'deleteImageList', error);
        return false;
      });
      return true;
    },
    emitUploadImage() {
      this.uploadImage();
    },
    async uploadImage() {
      const rec = this.getPatEventRecord;
      if (!rec.patEventCd || rec.patEventCd === 0) {
        return false;
      }
      let dt = new Date(rec.eventDate);
      let eventDate =
        dt.getFullYear() +
        ("00" + (dt.getMonth() + 1)).slice(-2) +
        ("00" + dt.getDate()).slice(-2);
      const entries = Object.entries(this.uploadedImages);
      if (entries.length === 0) {
        return true;
      }
      let successCount = 0;
      let errorCount = 0;
      const uploadResults = [];
      for (const [coordinate, fileInfo] of entries) {
        const isDeleted = this.deletedImages.some(img => img.coordinate === coordinate);
        if (isDeleted && !fileInfo) {
          continue;
        }
        if (isDeleted && fileInfo) {
          this.deletedImages = this.deletedImages.filter(img => img.coordinate !== coordinate);
        }
        if (fileInfo.isStored) {
          uploadResults.push({
            coordinate,
            serverPath: fileInfo.serverPath,
            fileName: fileInfo.fileName,
            status: 'already_stored'
          });
          continue;
        }
        if (!fileInfo || !fileInfo.fileName) {
          continue;
        }
        try {
          const fieldName = coordinate.replace(":", "-");
          const serverPath = `${this.getPatEventRecord.patId}/${this.getPatEventRecord.patEventCd}/image/${fieldName}-0/${fileInfo.fileName}`;
          const formData = new FormData();
          if (fileInfo.file) {
            formData.append("files", fileInfo.file, fileInfo.fileName);
          } else if (fileInfo.base64) {
            const base64Data = fileInfo.base64.split(',')[1];
            const byteCharacters = atob(base64Data);
            const byteArrays = [];
            for (let offset = 0; offset < byteCharacters.length; offset += 512) {
              const slice = byteCharacters.slice(offset, offset + 512);
              const byteNumbers = new Array(slice.length);
              for (let i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
              }
              const byteArray = new Uint8Array(byteNumbers);
              byteArrays.push(byteArray);
            }
            const blob = new Blob(byteArrays, { type: fileInfo.fileType || 'image/png' });
            formData.append("files", blob, fileInfo.fileName);
          } else {
            continue;
          }
          const patId = rec.patId;
          const response = await sendRequestPostImageUpload(
            {
              facilityCd: this.facilityCd,
              patId: patId,
              eventDate: eventDate,
              patEventCd: rec.patEventCd,
              fieldName: fieldName,
              imageNo: 0
            },
            formData
          );
          if (response.status === 200) {
            successCount++;
            fileInfo.isStored = true;
            fileInfo.serverPath = serverPath;
            uploadResults.push({
              coordinate,
              serverPath: serverPath,
              fileName: fileInfo.fileName,
              status: 'uploaded'
            });
          } else {
            errorCount++;
          }
        } catch (error) {
          errorCount++;
          getErrorMessage('IntroductionLetterComponent.vue', 'uploadImage', error);
        }
      }
      return errorCount === 0;
    },
    fileToBase64(file) {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = () => resolve(reader.result);
        reader.onerror = error => reject(error);
      });
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    handleEnableControl() {
      const processedCoordinates = new Set();
      this.getLetterCells().forEach(x => {
          if(x.className !== "pat-name-area"){
            // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
            const coordinate = x.getAttribute('excelCoordinate');
            if (processedCoordinates.has(coordinate)) {
              return;
            }
            processedCoordinates.add(coordinate);
            const innerHTML = x.innerHTML;
            const hasAnyBase64Image = /data:image\/[^;]+;base64,/i.test(innerHTML);
            let hasImgTag = x.querySelector('img');
            if (!hasImgTag) {
              const spans = x.querySelectorAll('span');
              for (let span of spans) {
                if (span.querySelector('img')) {
                  hasImgTag = true;
                  break;
                }
              }
            }
            if (hasAnyBase64Image || hasImgTag) {
              x.setAttribute("contenteditable", "false");
              x.setAttribute('isimage', 'true');
            } else {
              x.setAttribute("contenteditable", true);
              x.removeAttribute('isimage');
            }
            // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
            /*add FNSI-改修内容redmine4410 任 end*/
              // add 9483 紹介状画面でVA画像の表示不良 吉 start
              if(x.innerHTML.indexOf("data:image/png;base64") == -1) {
                // add 9483 紹介状画面でVA画像の表示不良 吉 end
                x.setAttribute("contenteditable", true)
                // add 9483 紹介状画面でVA画像の表示不良 吉 start
              }
              // add 9483 紹介状画面でVA画像の表示不良 吉 end
            /*add FNSI-改修内容redmine4410 任 start*/
            // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
            // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正 ②患者情報の表示のずれが発生 ③空白画面の出力問題  吉 start
            // const cellWidth = x.offsetWidth;
            // const textWidth = x.scrollWidth;
            // if (x.style.zoom == 1 || "" == x.style.zoom) {
            //   let scale = Math.min(1, cellWidth / textWidth);
            //   x.style.zoom = scale;
            // }
            // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正 ②患者情報の表示のずれが発生 ③空白画面の出力問題  吉 end
            if(x.hasAttribute("isimage")){
              x.style.textAlign = 'left';
              x.style.verticalAlign = 'top';
              x.style.align = 'left';
              x.style.userSelect = 'none';
            }
            else if (x.hasAttribute("isshrink")) {
              const cellWidth = x.offsetWidth;
              const textWidth = x.scrollWidth;
              if (x.style.zoom == 1 || "" == x.style.zoom) {
                let scale = Math.min(1, cellWidth / textWidth);
                x.style.zoom = scale;
              }
            }
            else {
              // x.style.whiteSpace = 'normal';
              // x.style.wordWrap = 'break-word';
              if (this.getHtmlTemplate && x.className) {
                const regex = new RegExp(`\\.${x.className}\\s*\\{\\s*([\\s\\S]*?)\\s*\\}`, 'g');
                const computedStyles = regex.exec(this.getHtmlTemplate);
                if (computedStyles && computedStyles[0] && computedStyles[0]?.indexOf('white-space:nowrap;') > -1) {
                  x.style.overflow = 'hidden';
                  x.addEventListener('blur', () => {
                    x.innerHTML = x.innerHTML.replace(/<br>/g, '').replace(/\n/g, '');
                    x.scrollLeft = 0;
                  });
                }
                if (computedStyles && computedStyles[0] && computedStyles[0]?.indexOf('text-align:right;') > -1) {
                  // mod #11534 紹介状画面の右寄せの入力欄でカーソル移動がおかしい limingzhe start
                  //x.style.direction = 'rtl';
                  x.style.textIndent = '-9999px';
                  // mod #11534 紹介状画面の右寄せの入力欄でカーソル移動がおかしい limingzhe end
                }
                if (x.hasAttribute("isalignr")) {
                  if (computedStyles && computedStyles[0] && computedStyles[0]?.indexOf('text-align:general;') > -1) {
                    // mod #11534 紹介状画面の右寄せの入力欄でカーソル移動がおかしい limingzhe start
                    //x.style.direction = 'rtl';
                    x.style.textIndent = '-9999px';
                    x.style.textAlign = 'right';
                    // mod #11534 紹介状画面の右寄せの入力欄でカーソル移動がおかしい limingzhe end
                  }
                }
              }
            }
            // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
          }
        });
      /*add FNSI-改修内容redmine4410 任 end*/
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
      this.reportStartDateInputInit = this.reportStartDate;
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
      this.addImageUploadButtons();
      this.bindAllImageClickEvents();
      this.processStoredImages();
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
      // add #12324 紹介状の出力時にpat_eventを参照する 20260414 wangzhao start
      this.setupNumberFormatCells();
      // add #12324 紹介状の出力時にpat_eventを参照する 20260414 wangzhao end
    },
    // add #12324 紹介状の出力時にpat_eventを参照する wangzhao 20260414 start
    setupNumberFormatCells() {
      const numberCells = this.getAllNumberFormatCells();
      numberCells.forEach(cellInfo => {
        const cell = cellInfo.element;
        const decimalPlaces = cellInfo.decimalPlaces;
        const format = cellInfo.format;
        cell.setAttribute('data-number-format', format);
        cell.setAttribute('data-decimal-places', decimalPlaces);
        this.initializeNumberCell(cell, decimalPlaces);
        this.setupSmartNumberValidation(cell, decimalPlaces);
      });
    },
    initializeNumberCell(cell, decimalPlaces = 2) {
      const value = cell.textContent.trim();
      if (value) {
        const num = parseFloat(value);
        if (!isNaN(num)) {
          const formatted = this.formatNumberWithDecimals(num, decimalPlaces);
          if (formatted !== value) {
            cell.textContent = formatted;
          }
        }
      }
    },
    setupSmartNumberValidation(cell, decimalPlaces = 2) {
      let validationTimer = null;
      let isFormatting = false;
      const formatNumber = () => {
        if (isFormatting) return;
        isFormatting = true;
        const value = cell.textContent.trim();
        if (!value || value === '-' || value === '.') {
          isFormatting = false;
          return;
        }
        const num = parseFloat(value);
        if (isNaN(num)) {
          isFormatting = false;
          return;
        }
        const formatted = this.formatNumberWithDecimals(num, decimalPlaces);
        if (formatted !== value) {
          const selection = window.getSelection();
          const range = selection.rangeCount > 0 ? selection.getRangeAt(0) : null;
          const cursorPosition = range ? range.startOffset : 0;
          cell.textContent = formatted;
          setTimeout(() => {
            this.setCursorPosition(cell, cursorPosition, formatted.length);
            isFormatting = false;
          }, 0);
        } else {
          isFormatting = false;
        }
      };
      const validateAndFormat = () => {
        if (validationTimer) {
          clearTimeout(validationTimer);
        }
        validationTimer = setTimeout(() => {
          formatNumber();
        }, 800);
      };
      const inputHandler = () => {
        this.filterNumberInput(cell, decimalPlaces);
        validateAndFormat();
      };
      const blurHandler = () => {
        formatNumber();
        if (validationTimer) {
          clearTimeout(validationTimer);
          validationTimer = null;
        }
      };
      cell.addEventListener('input', inputHandler);
      cell.addEventListener('blur', blurHandler);
      cell._numberValidation = {
        inputHandler,
        blurHandler,
        timer: validationTimer,
        decimalPlaces: decimalPlaces
      };
    },
    filterNumberInput(cell, decimalPlaces = 2) {
      const value = cell.textContent;
      let filtered = value.replace(/[^\d.-]/g, '');
      const minusCount = (filtered.match(/-/g) || []).length;
      if (minusCount > 1) {
        filtered = filtered.replace(/-/g, '');
        filtered = '-' + filtered;
      } else if (minusCount === 1 && !filtered.startsWith('-')) {
        filtered = '-' + filtered.replace(/-/g, '');
      }
      const dotCount = (filtered.match(/\./g) || []).length;
      if (dotCount > 1) {
        const parts = filtered.split('.');
        filtered = parts[0] + '.' + parts.slice(1).join('');
      }
      if (filtered.includes('.')) {
        const parts = filtered.split('.');
        if (parts[1] && parts[1].length > decimalPlaces) {
          filtered = parts[0] + '.' + parts[1].substring(0, decimalPlaces);
        }
      }
      if (filtered !== value) {
        const selection = window.getSelection();
        const range = selection.rangeCount > 0 ? selection.getRangeAt(0) : null;
        const cursorPosition = range ? range.startOffset : 0;
        cell.textContent = filtered;
        setTimeout(() => {
          this.setCursorPosition(cell, cursorPosition, filtered.length);
        }, 0);
      }
    },
    setCursorPosition(element, position, maxLength) {
      const safePosition = Math.min(position, maxLength);
      setTimeout(() => {
        const range = document.createRange();
        const selection = window.getSelection();
        if (element.childNodes.length > 0 && element.firstChild.nodeType === Node.TEXT_NODE) {
          const textNode = element.firstChild;
          range.setStart(textNode, safePosition);
          range.setEnd(textNode, safePosition);
        } else {
          range.selectNodeContents(element);
          range.collapse(false);
        }
        range.collapse(false);
        selection.removeAllRanges();
        selection.addRange(range);
      }, 0);
    },
    formatNumberWithDecimals(number, decimalPlaces) {
      if (isNaN(number)) return '';
      const isNegative = number < 0;
      const absNumber = Math.abs(number);
      let formatted = absNumber.toFixed(decimalPlaces);
      if (formatted.includes('e')) {
        const [coefficient, exponent] = formatted.split('e');
        const exp = parseInt(exponent, 10);
        const coeff = parseFloat(coefficient);
        if (exp >= 0) {
          formatted = (coeff * Math.pow(10, exp)).toFixed(decimalPlaces);
        } else {
          formatted = (coeff / Math.pow(10, -exp)).toFixed(decimalPlaces);
        }
      }
      if (isNegative) {
        formatted = '-' + formatted;
      }
      return formatted;
    },
    cleanupValidationTimers() {
      document.querySelectorAll('td[excelCoordinate]').forEach(cell => {
        if (cell._validationTimer) {
          clearTimeout(cell._validationTimer);
          cell._validationTimer = null;
        }
        if (cell._numberValidation) {
          const { inputHandler, blurHandler, timer } = cell._numberValidation;
          if (inputHandler) cell.removeEventListener('input', inputHandler);
          if (blurHandler) cell.removeEventListener('blur', blurHandler);
          if (timer) clearTimeout(timer);
          delete cell._numberValidation;
        }
      });
    },
    getAllNumberFormatCells() {
      const numberFormatCells = [];
      if (!this.getHtmlTemplate) {
        return numberFormatCells;
      }
      const allCells = document.querySelectorAll('td[excelCoordinate]');
      allCells.forEach(cell => {
        if (!cell.className) return;
        const className = cell.className;
        const regex = new RegExp(`\\.${className}\\s*\\{[\\s\\S]*?\\}`, 'g');
        const matches = this.getHtmlTemplate.match(regex);
        if (!matches) return;
        const numberFormatRule = matches.find(match =>
          match.includes("mso-number-format:")
        );
        if (numberFormatRule) {
          const formatMatch = numberFormatRule.match(/mso-number-format:\s*['"]?([^'"]+)['"]?/);
          if (formatMatch && formatMatch[1]) {
            const format = formatMatch[1].trim();
            const decimalPlaces = this.getDecimalPlacesFromFormat(format);
            if (decimalPlaces >= 0) {
              numberFormatCells.push({
                coordinate: cell.getAttribute('excelCoordinate'),
                className: cell.className,
                currentValue: cell.innerHTML,
                element: cell,
                format: format,
                decimalPlaces: decimalPlaces
              });
            }
          }
        }
      });
      return numberFormatCells;
    },
    getDecimalPlacesFromFormat(format) {
      if (!format) return -1;
      const cleanFormat = format.replace(/\\/g, '');
      if (cleanFormat.includes('.')) {
        const parts = cleanFormat.split('.');
        if (parts.length === 2) {
          const decimalPart = parts[1];
          if (/^0+$/.test(decimalPart)) {
            return decimalPart.length;
          }
        }
      } else if (cleanFormat === '0') {
        return 0;
      }
      return -1;
    },
    // add #12324 紹介状の出力時にpat_eventを参照する wangzhao 20260414 end
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    bindAllImageClickEvents() {
      if (this.getViewMode) return;
      const allCells = document.querySelectorAll('td[excelCoordinate]');
      allCells.forEach(cell => {
        const coordinate = cell.getAttribute('excelCoordinate');
        const imgElements = cell.querySelectorAll('img');
        imgElements.forEach(img => {
          const newImg = img.cloneNode(true);
          img.parentNode.replaceChild(newImg, img);
          if (!this.getViewMode) {
            newImg.addEventListener('click', (e) => {
              e.preventDefault();
              e.stopPropagation();
              this.deleteImage(coordinate);
            });
            newImg.style.cursor = 'pointer';
          } else {
            newImg.style.cursor = 'default';
          }
        });
      });
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    /**
     * 転入出先ポップオーバー非表示
     */
    closePopover() {
      this.popoverData.popoverVisible = false;
    },
    /*add FNSI-改修内容redmine4180 任 start*/
    popoverDataMstFacility() {
      /* modify by chamaojia 2025-05-21 [11871]  --start */
      // this.popoverData = this.createPopoverDataFacility(
      //   this.popoverData.popoverTitleHeader,
      //   this.popoverData.popoverContentLabel,
      //   this.facilityList,
      //   this.getToFacilityCd || null
      // );
      this.popoverData = {
        popoverVisible: false,
        popoverTitleHeader: this.popoverData.popoverTitleHeader,
        popoverContentLabel: this.popoverData.popoverContentLabel,
        popoverContentDataset: [],
        popoverContentSelected:
        {
          "value": this.getToFacilityCd || null,
          "text": "",
          "prefecturesCd": "",
          "medicalInstitutionCd": this.getToFacilityCd || null
        }
      };
      /* modify by chamaojia 2025-05-21 [11871]  --end */
      return this.popoverData
    },
    selectPopoverData(popoverData) {
      this.showPopover(popoverData);
    },
    /*add FNSI-改修内容redmine4180 任 end*/
    selectedValue(data) {
      /* add by chamaojia 2025-05-21 [11871]  --start */
      this.facilityNameList = [];
      const obj = {
        cd: data.value,
        name: data.text
      };
      this.facilityNameList.push(obj);
      /* add by chamaojia 2025-05-21 [11871]  --end */
      this.setToFacilityCd(data.value);
      this.setToMedicalInstitutionCd(data.medicalInstitutionCd);
      this.getFacilityName(data.value);
    },
    /*add FNSI-改修内容redmine4179 任 start*/
    setValueName(){
      this.inputValueName  = this.getLetterInputValueElement()?.value || this.inputValueName
      /* modify by chamaojia 2025-05-21 [11871]  --start */
      // const element = this.facilityList.find(item => item.facilityName === this.inputValueName);
      const element = this.facilityNameList.find(item => item.name === this.inputValueName);
      /* modify by chamaojia 2025-05-21 [11871]  --end */
      if (element) {
        /* modify by chamaojia 2025-05-21 [11871]  --start */
        /*this.setToFacilityCd(element.medicalInstitutionCd);
        this.setToMedicalInstitutionCd(element.medicalInstitutionCd);*/
        this.setToFacilityCd(element.cd);
        this.setToMedicalInstitutionCd(element.cd);
        /* modify by chamaojia 2025-05-21 [11871]  --end */
      } else {
        this.setToFacilityCd(this.inputValueName);
        this.setToMedicalInstitutionCd(null);
      }
    },
    /*add FNSI-改修内容redmine4179 任 end*/
    /** 紹介日を設定 */
    renewReportStartDate() {
      // 画面左イベントリストで選択済イベントの日付を紹介日にする
      if (dayjs(this.getReportStartDate).isValid()) {
        this.reportStartDate = dayjs(this.getReportStartDate).format("YYYY-MM-DD");
        return;
      }
      // 患者カレンダーから新規作成で遷移してきた場合、カレンダーでクリックした日付を紹介日にする
      if (this.getEventStartDate) {
        this.reportStartDate = this.getEventStartDate;
        return;
      }
      // 上記以外はシステム日付
      this.reportStartDate = dayjs().format("YYYY-MM-DD");
    },
    showPopover() {
      this.popoverData.popoverVisible = true;
    },
    getFacilityName(cd) {
      let facilityName = "";
      /*add FNSI-改修内容5449 任 start*/
      if (cd !== undefined && cd !== "" && cd !== null) {
        /* modify by chamaojia 2025-05-21 [11871]  --start */
        // /* mod FNSi5317患者経過総合ビューアで紹介状の有無が表示されない 周 start */
        // if (this.getSysFacilitiesForName) {
        //   const element = this.getSysFacilitiesForName.find(item => item.medicalInstitutionCd === cd);
        //   if (element) {
        //     facilityName = element.facilityName;
        //     /*add FNSI-改修内容redmine4179 任 start*/
        //   }else{
        //     facilityName = cd;
        //     /*add FNSI-改修内容redmine4179 任 end*/
        //     /*add FNSI-改修内容5449 任 start*/
        //   }
        //   /*add FNSI-改修内容5449 任 end*/
        // }
        //   //facilityName = cd;
        // /* mod FNSi5317患者経過総合ビューアで紹介状の有無が表示されない 周 end */
        const element = this.facilityNameList.find(item => item.cd === cd);
        if (element) {
          facilityName = element.name;
        } else {
          facilityName = cd;
        }
        /* modify by chamaojia 2025-05-21 [11871]  --end */
      }
      /*add FNSI-改修内容redmine4179 任 start*/
      this.inputValueName = facilityName;
      /*add FNSI-改修内容redmine4179 任 end*/
      return facilityName;
    },
    setContentToLayout(letterIndex) {
      if (null == letterIndex) {
        this.handleResetControl();
      }
      try {
        const letterInfo = JSON.parse(
          this.letterList[letterIndex].letterInfo.initValue
        );
        Object.keys(letterInfo).map(x => {
          const cell = this.getLetterCellByCoordinate(x);
          if (cell) { cell.innerHTML = letterInfo[x]; }
        });
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IntroductionLetterComponent.vue', 'setContentToLayout', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        // console.log(error);
        this.handleResetControl();
      }
    },
    getReportStartDateValue() {
      return this.reportStartDate ? this.reportStartDate : null;
    },
    getReportStartDateValidationMessage() {
      // エラースタイルのクリア
      this.reportStartDateClassCtrl.setInvalid(false);

      const validationMessage = this.$refs.reportStartDateInput.validationMessage;
      if (validationMessage !== "") {
        // バリデーションメッセージが発生している場合はエラースタイルにする
        // ダイアログの表示などは呼び出し側のPatEventDetailComponentで行われる
        this.reportStartDateClassCtrl.setInvalid(true);
      }
      return validationMessage;
    },
    async validateBeforeRegister() {
      // エラースタイルのクリア
      this.reportStartDateClassCtrl.setInvalid(false);

      // 必須項目チェック
      let requiredError = false;
      if (this.reportStartDate === "") {
        this.reportStartDateClassCtrl.setInvalid(true);
        requiredError = true;
      }
      if (requiredError) {
        await this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "必須項目未入力",
          // message: DIALOG_MESSAGES["99999994"]
          title: DIALOG_MESSAGES["99999994"].title,
          message: DIALOG_MESSAGES["99999994"].message
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return false;
      }

      return true;
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    cleanImageData(data) {
      if (!data || typeof data !== 'string') {
        return data || '';
      }
      if (data.includes('<img')) {
        const imgStartIndex = data.indexOf('<img');
        let imgEndIndex = data.indexOf('>', imgStartIndex);
        if (imgEndIndex === -1) {
          return data;
        }
        const semicolonAfterImg = data.indexOf(';', imgEndIndex);
        if (semicolonAfterImg > imgEndIndex) {
          const afterSemicolon = data.substring(semicolonAfterImg + 1).trim();
          const cleaned = data.substring(0, semicolonAfterImg);
          this.$nextTick(() => {
            this.processImageWithFullPath(cleaned, afterSemicolon);
          });
          return cleaned;
        } else {
          return data;
        }
      }
      return data;
    },
    processImageWithFullPath(htmlWithoutSemicolon, fullPath) {
      if (!htmlWithoutSemicolon || !fullPath) return;
      const tempDiv = document.createElement('div');
      tempDiv.innerHTML = htmlWithoutSemicolon;
      const imgElement = tempDiv.querySelector('img');
      if (imgElement) {
        let fileName = '';
        if (fullPath.includes('/')) {
          const pathParts = fullPath.split('/');
          fileName = pathParts[pathParts.length - 1];
          if (fileName.includes('?')) {
            fileName = fileName.split('?')[0];
          }
        } else {
          fileName = fullPath;
        }
        imgElement.dataset.fullpath = fullPath;
        imgElement.dataset.filename = fileName;
      }
      return tempDiv.innerHTML;
    },
    bindImageClickEvent(cell, coordinate) {
      if (!cell || this.getViewMode) return;
      const imgElements = cell.querySelectorAll('img');
      imgElements.forEach(img => {
        const newImg = img.cloneNode(true);
        newImg.style.maxWidth = '100%';
        newImg.style.maxHeight = '100%';
        newImg.style.minWidth = '23px';
        newImg.style.minHeight = '23px';
        newImg.style.objectFit = 'contain';
        newImg.style.display = 'block';
        if (!newImg.dataset.fullpath) {
          const originalContent = cell.getAttribute('data-original-content');
          if (originalContent && originalContent.includes(';')) {
            const parts = originalContent.split(';');
            if (parts.length > 1) {
              const fullPath = parts[1].trim();
              newImg.dataset.fullpath = fullPath;
              if (fullPath.includes('/')) {
                const pathParts = fullPath.split('/');
                const fileName = pathParts[pathParts.length - 1];
                if (fileName.includes('?')) {
                  newImg.dataset.filename = fileName.split('?')[0];
                } else {
                  newImg.dataset.filename = fileName;
                }
              } else {
                newImg.dataset.filename = fullPath;
              }
            }
          }
        }
        img.parentNode.replaceChild(newImg, img);
        if (!this.getViewMode) {
          newImg.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            this.deleteImage(coordinate);
          });
          newImg.style.cursor = 'pointer';
        } else {
          newImg.style.cursor = 'default';
        }
      });
    },
    deleteImage(coordinate) {
      if (this.getViewMode) {
        return;
      }
      this.$ons.notification.confirm({
        title: '削除確認',
        message: '登録済みの画像を削除しますか？',
        callback: async (index) => {
          if (index === 1) {
            const cell = document.querySelector(`td[excelCoordinate="${coordinate}"]`);
            if (cell) {
              const initialTemplateData = this.$store.getters["introduction-letter/getInitialTemplateData"] || {};
              const isInitialImage = initialTemplateData[coordinate] && initialTemplateData[coordinate].includes('<img');

              if (isInitialImage) {
                this.$store.commit("introduction-letter/removeInitialTemplateImage", coordinate);
              } else if (this.uploadedImages[coordinate]) {
                delete this.uploadedImages[coordinate];
              } else {
                let fileName = "";
                let fullPath = "";
                const originalContent = cell.getAttribute('data-original-content');
                if (originalContent && originalContent.includes(';')) {
                  const lastSemicolonIndex = originalContent.lastIndexOf(';');
                  if (lastSemicolonIndex !== -1) {
                    const afterSemicolon = originalContent.substring(lastSemicolonIndex + 1).trim();
                    if (afterSemicolon.startsWith('path:')) {
                      fullPath = afterSemicolon.substring(5);
                    } else {
                      fullPath = afterSemicolon;
                    }
                    if (fullPath.includes('/')) {
                      const pathParts = fullPath.split('/');
                      fileName = pathParts[pathParts.length - 1];
                      if (fileName.includes('?')) {
                        fileName = fileName.split('?')[0];
                      }
                    } else {
                      fileName = fullPath;
                    }
                  }
                }
                if (!fileName) {
                  fileName = `image_${coordinate.replace(/:/g, '_')}.png`;
                }
                const fieldName = coordinate.replace(":", "-");
                const imagePath = `${this.getPatEventRecord.patId}/${this.getPatEventRecord.patEventCd}/image/${fieldName}-0/${fileName}`;
                const deleteInfo = {
                  coordinate: coordinate,
                  file_name: fileName,
                  file_path: imagePath,
                  is_send_va: "0",
                  file_modified_time: dateFormat.format(new Date(), "yyyyMMddhhmmss"),
                  name: ""
                };
                this.deletedImages.push(deleteInfo);
              }

              cell.innerHTML = '';
              cell.setAttribute('contenteditable', 'true');
              cell.removeAttribute('isimage');
              cell.removeAttribute('data-original-content');
              this.rebindImageUploadButtons();
            }
            this.$nextTick(() => {
              const cell = document.querySelector(`td[excelCoordinate="${coordinate}"]`);
              if (cell) {
                const rect = cell.getBoundingClientRect();
                const uploadBtn = document.querySelector('.floating-upload-btn');
                if (uploadBtn && rect) {
                  uploadBtn.dataset.coordinate = coordinate;
                  uploadBtn.parentElement.style.top = `${rect.top + 2}px`;
                  uploadBtn.parentElement.style.left = `${rect.right - 22}px`;
                  uploadBtn.parentElement.style.display = 'block';
                }
              }
            });
          }
        }
      })
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    getLetterData() {
      let letterData = {};
      const contentDiv = document.getElementById("table_0");
      if (!contentDiv) {
        return letterData;
      }

      const cells = contentDiv.querySelectorAll('td[excelCoordinate]');
      const pageData = {};
      let templateImageInfo = this.getImagesFromTemplate();
      let existingLetterData = {};
      if (this.getPatEventRecord && this.getPatEventRecord.letterInfo) {
        try {
          const letterInfoObj = JSON.parse(this.getPatEventRecord.letterInfo);
          if (letterInfoObj.letter_data) {
            existingLetterData = letterInfoObj.letter_data;
          }
        } catch (e) {
          // error
        }
      }
      const isNewRecord = Object.keys(existingLetterData).length === 0;
      const initialImageInfo = isNewRecord ? templateImageInfo : existingLetterData;

      for (let tdElement of cells) {
        const coordinate = tdElement.getAttribute("excelCoordinate");
        if (!coordinate) continue;

        const isNewUpload = this.uploadedImages && this.uploadedImages[coordinate];
        const isDeleted = this.deletedImages && this.deletedImages.some(img => img.coordinate === coordinate);
        const initialValue = initialImageInfo[coordinate] || "";
        const hasInitialImage = this.hasImageInCell(initialValue);
        const cell = document.querySelector(`td[excelCoordinate="${coordinate}"]`);
        const currentContent = tdElement.innerHTML;
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = currentContent;
        const textContent = tempDiv.textContent || tempDiv.innerText || '';
        const trimmedText = textContent.replace(/\s+/g, ' ').trim();
        const hasActualContent = trimmedText.length > 0;
        const hasImgInDOM = cell && cell.querySelector('img');
        const hasImgInContent = currentContent.includes('<img');

        if (isDeleted && !isNewUpload) {
          if (hasActualContent) {
            pageData[coordinate] = currentContent;
          } else {
            pageData[coordinate] = "";
          }
          continue;
        }

        if (isNewRecord) {
          if (isDeleted) {
            if (hasActualContent) {
              pageData[coordinate] = currentContent;
            } else {
              pageData[coordinate] = "";
            }
            continue;
          }

          if (isNewUpload) {
            const fileInfo = this.uploadedImages[coordinate];
            if (fileInfo && fileInfo.isStored && fileInfo.serverPath) {
              pageData[coordinate] = fileInfo.serverPath;
            } else {
              const fieldName = coordinate.replace(":", "-");
              const imagePath = `${this.getPatEventRecord.patId}/${this.getPatEventRecord.patEventCd}/image/${fieldName}-0/${fileInfo.fileName}`;
              pageData[coordinate] = imagePath;
            }
            continue;
          }

          if (hasInitialImage && hasImgInDOM) {
            pageData[coordinate] = initialValue;
            continue;
          }

          if (hasInitialImage && !hasImgInDOM) {
            if (hasActualContent) {
              pageData[coordinate] = currentContent;
            } else {
              pageData[coordinate] = "";
            }
            continue;
          }

          if (!hasInitialImage && hasImgInContent) {
            const fieldName = coordinate.replace(":", "-");
            const fileName = this.getImageFileName(currentContent) || `${fieldName}_${Date.now()}.png`;
            const imagePath = `${this.getPatEventRecord.patId}/${this.getPatEventRecord.patEventCd}/image/${fieldName}-0/${fileName}`;
            pageData[coordinate] = imagePath;
            continue;
          }
          pageData[coordinate] = currentContent;
          continue;
        }

        if (isDeleted) {
          if (hasActualContent) {
            pageData[coordinate] = currentContent;
          } else {
            pageData[coordinate] = "";
          }
          continue;
        }

        let serverPath = null;
        if (cell) {
          const img = cell.querySelector('img');
          if (img) {
            const isStored = img.getAttribute('data-is-stored') === 'true';
            const storedPath = img.getAttribute('data-serverpath');
            if (isStored && storedPath) {
              serverPath = storedPath;
            }
          }
        }

        if (hasImgInDOM || hasImgInContent) {
          if (serverPath) {
            pageData[coordinate] = serverPath;
          } else if (isNewUpload) {
            const fileInfo = this.uploadedImages[coordinate];
            if (fileInfo) {
              if (fileInfo.isStored && fileInfo.serverPath) {
                pageData[coordinate] = fileInfo.serverPath;
              } else {
                const fieldName = coordinate.replace(":", "-");
                const imagePath = `${this.getPatEventRecord.patId}/${this.getPatEventRecord.patEventCd}/image/${fieldName}-0/${fileInfo.fileName}`;
                pageData[coordinate] = imagePath;
              }
            }
          } else if (hasInitialImage) {
            const isSameImage = this.isSameImage(currentContent, initialValue);
            if (isSameImage) {
              pageData[coordinate] = initialValue;
            } else {
              const fieldName = coordinate.replace(":", "-");
              const fileName = this.getImageFileName(currentContent) || `${fieldName}_${Date.now()}.png`;
              const imagePath = `${this.getPatEventRecord.patId}/${this.getPatEventRecord.patEventCd}/image/${fieldName}-0/${fileName}`;
              pageData[coordinate] = imagePath;
            }
          } else {
            const fieldName = coordinate.replace(":", "-");
            const fileName = this.getImageFileName(currentContent) || `${fieldName}_${Date.now()}.png`;
            const imagePath = `${this.getPatEventRecord.patId}/${this.getPatEventRecord.patEventCd}/image/${fieldName}-0/${fileName}`;
            pageData[coordinate] = imagePath;
          }
          continue;
        }

        if (hasInitialImage) {
          if (hasActualContent) {
            pageData[coordinate] = currentContent;
          } else {
            pageData[coordinate] = "";
          }
        } else {
          pageData[coordinate] = currentContent;
        }
      }

      return pageData;
    },
    // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    isSameImage(content1, content2) {
      if (!content1 || !content2) return false;

      if (content1 === content2) {
        return true;
      }
      const extractImagePath = (content) => {
        if (!content || typeof content !== 'string') return '';
        if (content.includes('/image/') && !content.includes('<img')) {
          return content;
        }
        if (content.trim().startsWith(';path:')) {
          const afterPath = content.substring(6).trim();
          if (afterPath.includes('/image/') && !afterPath.includes('<img')) {
            return afterPath;
          }
          if (afterPath.includes('<img')) {
            const imgStart = afterPath.indexOf('<img');
            if (imgStart > 0) {
              return afterPath.substring(0, imgStart).trim();
            }
          }
          return afterPath;
        }

        if (content.includes('<img')) {
          const match = content.match(/src=["']([^"']+)["']/);
          if (match && match[1]) {
            return match[1];
          }
        }

        return content;
      };

      const path1 = extractImagePath(content1);
      const path2 = extractImagePath(content2);

      if (!path1 || !path2) return false;
      if (path1.includes('/image/') && path2.includes('/image/')) {
        return path1 === path2;
      }
      if (path1.startsWith('data:') && path2.startsWith('data:')) {
        return path1.substring(0, 200) === path2.substring(0, 200);
      }

      return false;
    },
    getImagesFromTemplate() {
      const templateData = {};
      if (!this.getHtmlTemplate) {
        return templateData;
      }

      const tempDiv = document.createElement('div');
      tempDiv.innerHTML = this.getHtmlTemplate;

      const cellsWithImages = tempDiv.querySelectorAll('td[excelCoordinate]');
      cellsWithImages.forEach(cell => {
        const coordinate = cell.getAttribute('excelCoordinate');
        if (!coordinate) return;

        const img = cell.querySelector('img');
        if (img) {
          const src = img.getAttribute('src') || '';
          const alt = img.getAttribute('alt') || '';

          if (src) {
            let parentSpan = img.closest('span');
            if (parentSpan) {
              templateData[coordinate] = parentSpan.outerHTML;
            } else {
              if (src.startsWith('data:')) {
                templateData[coordinate] = `<img src="${src}" alt="${alt}">`;
              } else if (src.includes('/')) {
                templateData[coordinate] = `<img src="${src}" alt="${alt}">;path:${src}`;
              }
            }
          }
        }
      });

      return templateData;
    },
    hasImageInCell(content) {
      if (!content || typeof content !== 'string') {
        return false;
      }
      return this.isImageContent(content) || this.isBase64Image(content);
    },
    updateImagesToServerPath(imageUploadResults) {
      if (!imageUploadResults || !Array.isArray(imageUploadResults)) return;
      imageUploadResults.forEach(result => {
        const { coordinate, serverPath, fileName } = result;
        const cell = document.querySelector(`td[excelCoordinate="${coordinate}"]`);
        if (!cell) return;
        const img = cell.querySelector('img');
        if (img) {
          img.setAttribute('data-is-stored', 'true');
          img.setAttribute('data-serverpath', serverPath);
          img.setAttribute('data-filename', fileName);
          const newOriginalContent = `<img src="${serverPath}" data-is-stored="true" data-filename="${fileName}" />;path:${serverPath}`;
          cell.setAttribute('data-original-content', newOriginalContent);
          if (this.uploadedImages[coordinate]) {
            this.uploadedImages[coordinate].isStored = true;
            this.uploadedImages[coordinate].serverPath = serverPath;
          }
        }
      });
    },
    isInitialTemplateImageContent(content) {
      if (!content || typeof content !== 'string') {
        return false;
      }
      return this.isImageContent(content);
    },
    sameAsInitialImage(currentContent, initialContent) {
      if (!currentContent || !initialContent) {
        return false;
      }
      const currentPath = this.extractPathFromOriginalContent(currentContent);
      const initialPath = this.extractPathFromOriginalContent(initialContent);
      if (!currentPath || !initialPath) {
        return false;
      }
      return currentPath === initialPath ||
        currentPath.includes(initialPath) ||
        initialPath.includes(currentPath);
    },
    getImageFileName(content) {
      if (!content) return null;
      const path = this.extractPathFromOriginalContent(content);
      if (path) {
        const parts = path.split('/');
        if (parts.length > 0) {
          return parts[parts.length - 1];
        }
      }
      if (content.includes('data:image/png')) {
        return 'image.png';
      } else if (content.includes('data:image/jpeg') || content.includes('data:image/jpg')) {
        return 'image.jpg';
      } else if (content.includes('data:image/gif')) {
        return 'image.gif';
      }
      return null;
    },
    isBase64Image(content) {
      if (!content || typeof content !== 'string') {
        return false;
      }
      if (content.includes('data:image/') && content.includes('base64,')) {
        return true;
      }
      const imgMatch = content.match(/<img[^>]+src="(data:image\/[^;]+;base64,[^"]+)"[^>]*\/?>/);
      if (imgMatch && imgMatch[1]) {
        return true;
      }
      return false;
    },
    extractPathFromOriginalContent(originalContent) {
      if (!originalContent || typeof originalContent !== 'string') {
        return null;
      }
      const pathIndex = originalContent.lastIndexOf(';path:');
      if (pathIndex !== -1) {
        const afterPath = originalContent.substring(pathIndex + 6);
        const match = afterPath.match(/[^;]+\.(png|jpg|jpeg|gif)/i);
        if (match) {
          return match[0].trim();
        }
      }
      const lastSemicolonIndex = originalContent.lastIndexOf(';');
      if (lastSemicolonIndex !== -1) {
        const afterSemicolon = originalContent.substring(lastSemicolonIndex + 1).trim();
        if (afterSemicolon.includes('/') && (afterSemicolon.includes('.png') || afterSemicolon.includes('.jpg') || afterSemicolon.includes('.jpeg'))) {
          return afterSemicolon;
        }
      }
      if (originalContent.includes('/') && (originalContent.includes('.png') || originalContent.includes('.jpg') || originalContent.includes('.jpeg'))) {
        if (!originalContent.includes('data:image/')) {
          return originalContent;
        }
      }
      return null;
    },
    extractPurePath(content) {
      if (!content || typeof content !== 'string') {
        return content;
      }
      if (this.isPureImagePath(content)) {
        return content.trim();
      }
      const serverPathMatch = content.match(/data-serverpath=["']([^"']+)["']/);
      if (serverPathMatch && serverPathMatch[1]) {
        return serverPathMatch[1];
      }
      const pathMatch = content.match(/;path:([^;]+)/);
      if (pathMatch && pathMatch[1]) {
        return pathMatch[1].trim();
      }
      const lastSemicolonIndex = content.lastIndexOf(';');
      if (lastSemicolonIndex !== -1) {
        const afterSemicolon = content.substring(lastSemicolonIndex + 1).trim();
        if (this.isPureImagePath(afterSemicolon)) {
          return afterSemicolon;
        }
      }
      const pattern = /\b\d+\/\d+\/image\/[A-Za-z0-9-]+\/[^<>&"']+\.(png|jpg|jpeg|gif)\b/i;
      const match = content.match(pattern);
      if (match) {
        return match[0];
      }
      return null;
    },
    isPureImagePath(content) {
      if (!content || typeof content !== 'string') {
        return false;
      }
      const trimmed = content.trim();
      const pathPattern = /^\d+\/\d+\/image\/[A-Za-z0-9-]+\/[^<>]+\.(png|jpg|jpeg|gif)$/i;
      return pathPattern.test(trimmed) && !trimmed.includes('<') && !trimmed.includes('>') && !trimmed.includes('data-');
    },
    isNewImagePath(content) {
      if (!content || typeof content !== 'string') {
        return false;
      }
      const trimmedContent = content.trim();
      const pattern1 = /^\d+\/\d+\/image\/[A-Za-z]+\d+-[A-Za-z]+\d+-\d+\/.+\.(png|jpg|jpeg)/i;
      const pattern2 = /^\d+\/\d+\/image\/[A-Za-z]+\d+-[A-Za-z]+\d+-\d+\/.+\.(png|jpg|jpeg)/i;
      return pattern1.test(trimmedContent) || pattern2.test(trimmedContent);
    },
    isPlainText(content) {
      if (!content || typeof content !== 'string') {
        return false;
      }
      const textWithoutTags = content.replace(/<[^>]*>/g, '').trim();
      if (textWithoutTags.length === 0) {
        return false;
      }
      const hasImageContent = content.includes('<img') ||
        content.includes(';path:') ||
        content.includes('data:image/') ||
        (content.includes('/') && (content.includes('.png') || content.includes('.jpg')));
      return !hasImageContent;
    },
    isImageContent(content) {
      if (!content || typeof content !== 'string') {
        return false;
      }
      return content.includes('<img') ||
        content.includes(';path:') ||
        content.includes('data:image/') ||
        (content.includes('/') && (content.includes('.png') || content.includes('.jpg')));
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    // PatEventDetailComponentのupdateLetter実行時に
    // APIで取得したhtmlTempleteに値が入っていなかった項目のみ
    // getLetterDataで退避した入力状態を使って書き戻すための関数
    restoreLetterData(letterData) {
      if (!letterData) return;
      // htmlTemplete による部分のみを処理対象とする
      // mod 10499 紹介状画面でセルの縦配置設定が反映しない 吉 start
      // const contentDiv = document.getElementById("content-html");
      const contentDiv = this.getLetterContentRoot();
      // mod 10499 紹介状画面でセルの縦配置設定が反映しない 吉 end
      if (!contentDiv) return;
      // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
      // contentDiv.querySelectorAll("td[id]").forEach(tdElement => {
      //   // htmlTemplete により空文字列でない値が入っている
      //   // もしくは letterData に対応する空文字列でない値が入っていない
      //   // 以上の場合は書き戻し対象外とする
      //   if (!!tdElement.textContent || !letterData[tdElement.id]) return;
      //   tdElement.innerHTML = letterData[tdElement.id];
      // });
      contentDiv.querySelectorAll("td[excelCoordinate]").forEach(tdElement => {
        // htmlTemplete により空文字列でない値が入っている
        // もしくは letterData に対応する空文字列でない値が入っていない
        // 以上の場合は書き戻し対象外とする
        if (!!tdElement.textContent || !letterData[tdElement.getAttribute("excelCoordinate")]) return;
        tdElement.innerHTML = letterData[tdElement.getAttribute("excelCoordinate")];
      });
      // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
    },
    setReportFlagTrue() {
      /*add FNSI-改修内容患者転入選択後、転出戻したら、画面の状態が元と違う 任 start*/
      if (this.getPathReal !== null) {
        EventBus.$emit("changLetterCategory");
      }
      /*add FNSI-改修内容患者転入選択後、転出戻したら、画面の状態が元と違う 任 end*/
      this.setReportFlag(true)
      /*add FNSI-改修内容redmain3772 范 start*/
      // mod 10499 紹介状画面でセルの縦配置設定が反映しない 吉 start
      // $$("#content-html").show();
      this.scopedJQuery()("#content-html-id").show();
      // mod 10499 紹介状画面でセルの縦配置設定が反映しない 吉 end
      /*add FNSI-改修内容redmain3772 范 end*/
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
      this.handleReportStartDateChange();
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
    },
    setReportFlagFalse() {
      this.setReportFlag(false)
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/

      /*add FNSI-改修内容redmain3772 范 start*/
      // mod 10499 紹介状画面でセルの縦配置設定が反映しない 吉 start
      // $$("#content-html").hide();
      this.scopedJQuery()("#content-html-id").hide();
      // mod 10499 紹介状画面でセルの縦配置設定が反映しない 吉 end
      /*add FNSI-改修内容redmain3772 范 end*/
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
      this.reportStartDateInputInit = this.reportStartDate;
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
    },

    initContentObserver() {

      if (this.contentObserver) {
        this.contentObserver.disconnect();
      }

      this.contentObserver = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
          if (mutation.type === 'childList' || mutation.type === 'characterData') {
            this.handleContentChange(mutation);
          }
        });
      });

      const contentElement = this.getLetterContentRoot();
      if (contentElement) {

        const config = {
          childList: true,
          subtree: true,
          characterData: true,
          characterDataOldValue: true
        };

        this.contentObserver.observe(contentElement, config);
      }
    },

    handleContentChange(mutation) {
      this.$emit('content-changed', {
        target: mutation.target,
        type: mutation.type,
        oldValue: mutation.oldValue
      });
    },
    // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
    async handleReportStartDateChange() {
      if (this.hasFocusStartDate) return;
      if (this.inProgressChangeConditionSee) return;
      this.inProgressChangeConditionSee = true;
      // 転出日の値が変更されない場合、処理をしない
      if (this.reportStartDateInputInit !== null && this.reportStartDateInputInit !== "" &&
        this.reportStartDateInputInit !== this.reportStartDate && this.getReportFlag) {
        // 新規登録かつテンプレートが存在する場合、APIを呼び出す
        if (this.getUpdateMode === false && (this.getPathReal === null && !this.getIsNotExit)) {
          let keyHandler = null;
          setTimeout(() => {
            const buttons = document.querySelectorAll(".alert-dialog-button");
            if (!buttons.length) {
              return;
            }
            let currentIndex = buttons.length - 1;
            updateSelected();
            function updateSelected() {
              buttons.forEach(btn => {
                btn.classList.remove(
                  "keyboard-selected",
                  "keyboard-left",
                  "keyboard-right"
                );
              });

              const current = buttons[currentIndex];
              current.classList.add("keyboard-selected");
              if (currentIndex === 0) {
                current.classList.add("keyboard-left");
              }
              if (currentIndex === buttons.length - 1) {
                current.classList.add("keyboard-right");
              }
            }
            keyHandler = (e) => {
              if (e.key === "ArrowLeft") {
                e.preventDefault();
                currentIndex = (currentIndex - 1 + buttons.length) % buttons.length;
                updateSelected();
              }
              if (e.key === "ArrowRight") {
                e.preventDefault();
                currentIndex = (currentIndex + 1) % buttons.length;
                updateSelected();
              }
              if (e.key === "Enter") {
                e.preventDefault();
                const realButton = buttons[currentIndex].querySelector("button");
                if (realButton) {
                  realButton.click();
                } else {
                  buttons[currentIndex].click();
                }
              }
            };
            document.addEventListener("keydown", keyHandler);
          }, 0);
          // 確認メッセージを出す
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[12000014].title,
            message: DIALOG_MESSAGES[12000014].message,
            callback: answer => {
              document.removeEventListener("keydown", keyHandler);
              if (answer === 1) {
                this.beforeStep();
              } else if (answer === 0) {
                // 元値を戻る
                this.reportStartDate = this.reportStartDateInputInit;
              }
            }
          });
        }
      }
      setTimeout(() => { this.inProgressChangeConditionSee = false }, 100);
    },
    async beforeStep() {
      this.setLoadingScreenVisible(true);
      this.setHtmlTemplate(null);
      await this.setTemplate({
        patId: this.getPatEventRecord.patId,
        reportCd: this.getPatEventRecord.reportCd,
        reportStartDate: this.reportStartDate
      })
      this.$nextTick(() => {
        this.setLoadingScreenVisible(false);
        this.handleEnableControl();
        this.reportStartDateInputInit = this.reportStartDate;
      });
    },
    onFocusInStartDate() {
      this.hasInputStartDate = false;
      this.hasFocusStartDate = true;
    },
    onInputStartDate() {
      if (!this.hasInputStartDate) {
        this.hasInputStartDate = true;
      }
    },
    onFocusOutStartDate() {
      this.hasFocusStartDate = false;
      if (this.hasInputStartDate) {
        this.hasInputStartDate = false;
        this.handleReportStartDateChange();
      }
    },
    // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
  },
  mounted() {
    this.renewReportStartDate();
    this.$nextTick(() => {
      setTimeout(() => {
        this.inputValueName = this.getFacilityName(this.getToFacilityCd);
        if (!this.getViewMode) {
          this.handleEnableControl();
          // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正 ②患者情報の表示のずれが発生 ③空白画面の出力問題  吉 start
          // del 10499 紹介状画面でセルの縦配置設定が反映しない 吉 start
          // document
          //   .querySelectorAll("td[id]")
          //   .forEach(x =>
          //     /*add FNSI-改修内容redmine4410 任 start*/
          //   {
          //     if(x.className !== "pat-name-area"){
          //       const cellWidth = x.offsetWidth;
          //       const textWidth = x.scrollWidth;
          //       let scale = Math.min(1, cellWidth / textWidth);
          //       x.style.zoom = scale;
          //
          //     }
          //   });
          // del 10499 紹介状画面でセルの縦配置設定が反映しない 吉 end
          // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正 ②患者情報の表示のずれが発生 ③空白画面の出力問題  吉 end
        }
        // add 10499 紹介状画面でセルの縦配置設定が反映しない 吉 start
        else{
          (this.getLetterContentRoot() || this.getLetterRoot())
            // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
            //.querySelectorAll("td[id]")
            .querySelectorAll("td[excelCoordinate]")
            // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
            .forEach(x =>
              /*add FNSI-改修内容redmine4410 任 start*/ {
              if (x.className !== "pat-name-area") {
                // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
                // const cellWidth = x.offsetWidth;
                // const textWidth = x.scrollWidth;
                // let scale = Math.min(1, cellWidth / textWidth);
                // x.style.zoom = scale;
                if (x.hasAttribute("isimage")) {
                  x.style.textAlign = 'left';
                  x.style.verticalAlign = 'top';
                  x.style.align = 'left';
                  x.style.userSelect = 'none';
                }
                else if (x.hasAttribute("isshrink")) {
                  const cellWidth = x.offsetWidth;
                  const textWidth = x.scrollWidth;
                  let scale = Math.min(1, cellWidth / textWidth);
                  x.style.zoom = scale;
                }
                else {
                  // x.style.whiteSpace = 'normal';
                  // x.style.wordWrap = 'break-word';
                  if (this.getHtmlTemplate && x.className) {
                    const regex = new RegExp(`\\.${x.className}\\s*\\{\\s*([\\s\\S]*?)\\s*\\}`, 'g');
                    const computedStyles = regex.exec(this.getHtmlTemplate);
                    if (computedStyles && computedStyles[0] && computedStyles[0]?.indexOf('white-space:nowrap;') > -1) {
                      x.style.overflow = 'hidden';
                      x.addEventListener('blur', () => {
                        x.innerHTML = x.innerHTML.replace(/<br>/g, '').replace(/\n/g, '');
                        x.scrollLeft = 0;
                      });
                    }
                    if (computedStyles && computedStyles[0] && computedStyles[0]?.indexOf('text-align:right;') > -1) {
                      // mod #11534 紹介状画面の右寄せの入力欄でカーソル移動がおかしい limingzhe start
                      //x.style.direction = 'rtl';
                      x.style.textIndent = '-9999px';
                      // mod #11534 紹介状画面の右寄せの入力欄でカーソル移動がおかしい limingzhe end
                    }
                    if (x.hasAttribute("isalignr")) {
                      if (computedStyles && computedStyles[0] && computedStyles[0]?.indexOf('text-align:general;') > -1) {
                        // mod #11534 紹介状画面の右寄せの入力欄でカーソル移動がおかしい limingzhe start
                        //x.style.direction = 'rtl';
                        x.style.textIndent = '-9999px';
                        x.style.textAlign = 'right';
                        // mod #11534 紹介状画面の右寄せの入力欄でカーソル移動がおかしい limingzhe end
                      }
                    }
                  }
                }
                // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
              }
            });
          // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正 ②患者情報の表示のずれが発生 ③空白画面の出力問題  吉 end
        }
        // add 10499 紹介状画面でセルの縦配置設定が反映しない 吉 end
      }, 200);
      this.initContentObserver();
    })
    // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正 ②患者情報の表示のずれが発生 ③空白画面の出力問題  吉 start
    this._letterClickHandler = (event) => {
      this.getLetterCells().forEach((x) => {
        if (x.className !== 'pat-name-area' && x.hasAttribute('isshrink')) {
          const cellWidth = x.offsetWidth;
          const textWidth = x.scrollWidth;
          if (x.style.zoom == 1) {
            const scale = Math.min(1, cellWidth / textWidth);
            x.style.zoom = scale;
          }
        }
      });
      if (event?.target?.style) {
        event.target.style.zoom = 1;
      }
    };
    (this.$el?.ownerDocument || document).addEventListener('click', this._letterClickHandler);
    // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
    this.reportStartDateInputInit = this.reportStartDate;
    // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
  },
  beforeUnmount() {
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260521 start
    this.cleanupImageUploadButtonsComplete();
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260521 end
    this.reportStartDateClassCtrl.destroy();
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    if (this.contentObserver) {
      this.contentObserver.disconnect();
      this.contentObserver = null;
    }
    if (this._letterClickHandler) {
      (this.$el?.ownerDocument || document).removeEventListener('click', this._letterClickHandler);
    }
  },
  unmounted() {
    clearInterval(this.timerAction);
  }
};
</script>

<style lang="scss" scoped>
div[id^="introduction-letter"] {
  color: var(--ntss-base-color);

  input,
  select {
    font-size: inherit;
  }

  input:disabled {
    color: initial;
    cursor: not-allowed;
    background-color: white;
    height: 1.5em;
  }

  .button {
    cursor: pointer;
    width: auto;
  }

  .flex-left {
    flex: 0 0 12%;
  }

  .table-history {
    width: 100%;
    height: calc(100vh - 160px);
    border-collapse: collapse;
    border: 1px solid #b5b5b5;
    table-layout: fixed;

    thead {
      background-color: #cccccc;
      color: #050505;
    }

    th {
      border: 1px solid #b5b5b5;
      text-align: left;
    }

    td,
    th {
      padding: 3px;
    }

    tr:not(:last-child) {
      height: 30px;
    }

    tr.tr-list {
      cursor: pointer;

      :hover,
      :active {
        background-color: #cccccc;
        color: #050505;
      }
    }

    tr.highlight {
      background-color: #cccccc;
      color: #050505;
    }
  }

  .text-right {
    text-align: right;
  }

  .form table tr {
    height: 35px;
  }

  .footer-button {
    margin-top: 10px;

    .button {
      margin-left: 5px;
    }
  }

  // mod 10499 紹介状画面でセルの縦配置設定が反映しない 吉 start
  // #content-html {
  #content-html-id {
    // mod 10499 紹介状画面でセルの縦配置設定が反映しない 吉 end
    overflow: auto;
    // add 9483　紹介状画面でVA画像の表示不良　吉 start
    position: relative;
    // add 9483　紹介状画面でVA画像の表示不良　吉 end
  }

  .new-item {
    color: green !important;
  }

  .normal-item {
    color: var(--ntss-base-color);
  }
}

/*add FNSI-改修内容転入転出の患者情報連動 任 start*/
#date-input-report {
  width: 9em;
  margin-left: 10px;
}

/*add FNSI-改修内容転入転出の患者情報連動 任 end*/
/*add FNSI-改修内容redmine4168 任 start*/
.radio-radio {
  margin-left: 5px;
}

/*add FNSI-改修内容redmine4168 任 end*/
// 紹介状の帳票表示エリアの背景がダークテーマだと黒になるため帳票の内容が見えない  6104  shan  start
.template-content {
  background: #fafafa;
  border-radius: 5px;
}

// 紹介状の帳票表示エリアの背景がダークテーマだと黒になるため帳票の内容が見えない  6104  shan  end

/* ntss.css の .custom-textarea:disabled と競合する為、個別定義 */
td textarea:focus {
  border-style: inset;
  border-color: unset;
}
@media print {
  /* テーブルを画面幅に収める */
  #content-html-id {
    padding-right: 2mm !important;
  }
  #content-html-id :deep(table) {
    width: 100% !important;
  }
  #content-html-id :deep(#section) {
    padding: 0;
  }
  /* セルの固定幅を無効化 */
  #content-html-id :deep(td),
  #content-html-id :deep(th) {
    width: auto !important;
    max-width: 100% !important;

    white-space: normal !important;
    word-break: break-word;
    overflow-wrap: anywhere;
  }
}

/* add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start */
.image-upload-container {
  transition: opacity 0.3s;
  pointer-events: auto;
}
.image-upload-btn {
  opacity: 0.7 !important;
  transition: opacity 0.3s, transform 0.3s;
}
.image-upload-btn:hover {
  opacity: 1 !important;
  transform: scale(1.1);
  background: #0056b3 !important;
}
td[isimage] {
  min-height: 50px;
  padding: 5px;
  overflow: hidden;
  position: relative;
}
td[isimage] img {
  max-width: 100%;
  max-height: 150px;
  object-fit: contain;
  display: block;
  margin: 0 auto;
}
td[excelCoordinate][contenteditable="true"] {
  position: relative;
  min-height: 30px;
}
td[excelCoordinate][contenteditable="true"]:focus {
  outline: 2px solid #007bff;
}
/* add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end */
</style>
