<!-- 処方一覧画面 -->
<template>
  <div class='main-content-area kendo-grid-style-page' style="overflow: hidden;">
    <div class='prescription-list-main-content'>
      <kendo-grid
        ref='prescriptionlistgrid'
        :data-source='prescriptionDataSource1'
        :editable='false'
        :reorderable='false'
        :resizable='true'
        :selectable='"cell"'
        :height="kendoGridHeight"
        :scrollable="true"
        :change="onClick"
        :data-bound="setFontColor"
        :sortable="{ compare: compareByField }"
        :sort="sortHandler"
      >
      <kendo-grid-column v-for='category in prescriptionGridColumns' :key="category.length"
        :headerTemplate='category.headerTemplate'
        :template="category.template"
        :title='category.title'
        :width='category.width'
        :field='category.field'
        :columns='category.columns'
        :hidden='category.hidden'
        :locked='category.locked'
        :lockable='category.lockable'
        :values="category.values"
        :attributes="category.attributes"
        ></kendo-grid-column>
      </kendo-grid>
    </div>
    <popover-prescription-info
      ref="popoverPrescriptionInfo"
      v-if="popoverData.popoverVisible"
      v-bind="popoverData"
      :target-position-element="popoverTarget"
      @popover-close="closePopover"
    />
  </div>
</template>

<script>
import $$ from "jquery";
import Kendo from "@progress/kendo-ui";
import { mapGetters, mapActions, mapMutations } from "vuex";
import { sendRequestGetprescriptionList } from "@/apis/pat-prescription";
import moment from "moment";
import PopoverMixin from "@/components/PopoverMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
// #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
import { EventBus } from "@/eventBus.js";
// #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
import { sortableCompare } from "@/functions/SortFunctions";
import PrescriptionInfoContent from "@/components/prescription/PrescriptionInfoContent";
import PrintMixin from "@/components/PrintMixin";

// カラム定数
const CNO_PAT_ID = 1;
const CNO_PAT_NAME = 2;
const CNO_DATE_INFO = 3;
const CNO_CLASS_INFO = 4;
const CNO_NEXT_STATE_INFO = 8;
const CNO_NEXT_DATE_INFO = 9;
const CNO_NEXT_CLASS_INFO = 10;
const CNO_PRE_1_DATE_INFO = 12;
const CNO_PRE_1_CLASS_INFO = 13;
const CNO_PRE_2_DATE_INFO = 16;
const CNO_PRE_2_CLASS_INFO = 17;
const CNO_PRE_3_DATE_INFO = 20;
const CNO_PRE_3_CLASS_INFO = 21;

// ソートキー変換用のマップ
const SORT_KEY_MAP = {
  p_save_state: "p_save_state_org",       // 指定日情報.交付
  p_class: "p_class_org",                 // 指定日情報.処方区分
  next_save_state: "next_save_state_org", // 次回処方.交付
  next_class: "next_class_org",           // 次回処方.処方区分
  pre_1_class: "pre_1_class_org",         // 前回処方.処方区分
  pre_2_class: "pre_2_class_org",         // 2回前処方.処方区分
  pre_3_class: "pre_3_class_org",         // 3回前処方.処方区分
  kur: "kur_start_time",                  // クール
  bed_name: "bed_order_index",            // ベッド
  treatment_method: "treatment_order_index" // 治療方法
};

export default {
  mixins: [PopoverMixin, PrintMixin],
  components: {
    "popover-prescription-info": PrescriptionInfoContent
  },
  data() {
    return {
      isChkDisabled: "",
      prescriptionDataSource1: {},
      treatDate: moment().format("YYYY/MM/DD"),
      popoverTarget: null,
      //ポップオーバーの呼び出し元の要素の表示位置
      popoverTargetPosition: {
        //行番号
        rowIndex: -1,
        //列番号
        colIndex: -1
      },
      popoverData: {
        // ポップオーバー表示フラグ
        popoverVisible: false,
        // 処方情報
        prescriptionInfoData: null,
        // 処方箋の詳細情報
        prescriptionDetailList: []
      },
      gridCellData: "",
      // Grid 高さ
      kendoGridHeight: 300,
      firstLoadFlg: true,
      //自画面の名称
      selfScreenName: "",
      //同姓同名アイコン
      imageSrcSame: require('../../assets/name_duplication.png'),
      currentSort: null,
      scrollPosition: {
        top: 0,
        left: 0
      },
      resizeFlg: false,
      scrollQuerySelector: ".k-grid-content", // スクロールコンテナ
      addClassTargetQuerySelector: [".k-grid-header-wrap table, .k-grid-content table"], // scroll-rightmostクラスを付与する対象のクエリセレクタ
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      sidebarWidth: "getSidebarWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
      getPatientShareMode: "getPatientShareMode",//自施設(1) or 他施設(0)
      getPatientShareFacilityCdMode: "getPatientShareFacilityCdMode"//施設cd
    }),
    ...mapGetters("prescription/list", [
      "getCondition",
      "getOrdPreNo"
    ]),

    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId", "getIsOtherFacility", "getOtherFacilityCd"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-prescription", ["getRouteFlag", "getAppointedDate", "getInputModal", "getPrescriptionDetail"]),
    prescriptionGridColumns() {
      return [
        {
          field: "pat_id",
          hidden: true,
          locked: true,
          title: "患者ID(システムID)"
        },
        {
          field: "hosp_pat_id",
          hidden: false,
          locked: true,
          title: "患者ID",
          width: "160px",
          attributes: { class: 'hosp-pat-id-body' }
        },
        {
          field: "pat_name",
          hidden: false,
          locked: true,
          title: "患者名",
          template: `<span class="#: in_out_class === 1 ? 'in_class_prescription' : '' #">#: pat_name # ` +
                    `# if(is_same === '1'){ # <img src="#: image_src_same #" class="pat-name-same-icon"> # } #</span>`,
          width: "139.6px",
        },
        {
          field: "date_info",
          hidden: false,
          title: "指定日情報 " + this.getAppointedDate,
          columns: [
            {
              // 処方-交付
              field: "p_save_state",
              hidden: false,
              title: "交付",
              width: "6em"
            },
            {
              // 処方-処方区分
              field: "p_class",
              hidden: false,
              title: "処方区分",
              width: "8em"
            },
            {
              // クール
              field: "kur",
              hidden: false,
              title: "クール",
              width: "8em"
            },
            {
              // ベッド
              field: "bed_name",
              hidden: false,
              title: "ベッド",
              width: "10em"
            },
            {
              // 治療
              field: "treatment_method",
              hidden: false,
              title: "治療方法", // mod #10184 処方画面文言修正 宮崎
              width: "6em"
            }
          ],
          values: [
            {
              value: 0
            }
          ]
        },
        {
          // 次回処方
          field: "next",
          hidden: false,
          lockable: false,
          title: "次回処方",
          columns: [
            {
              // 次回処方-交付
              field: "next_save_state",
              hidden: false,
              title: "交付",
              width: "8em"
            },
            {
              // 次回処方-処方日
              field: "next_date",
              hidden: false,
              title: "処方日",
              width: "8em"
            },
            {
              // 次回処方-処方区分
              field: "next_class",
              hidden: false,
              title: "処方区分",
              width: "8em"
            },
          ],
          values: [
            {
              value: 1
            }
          ]
        },
        {
          // 前回処方日
          field: "pre_1",
          hidden: false,
          lockable: false,
          title: "前回処方日",
          columns: [
            {
              // 前回処方日-チェック
              field: "pre_1_check",
              hidden: false,
              title: "Pre1CheckAll",
              headerTemplate: `<div style="">` +
                              `<input type="checkbox" ${ this.isChkDisabled } id="pre1-header-chb" class="checkbox__input header-checkbox">` +
                              `<span class="checkbox__checkmark"></span></div>`,
              template: `<div class="checkbox" # if(typeof pre_1_check === 'undefined' || pre_1_date == null || pre_1_date == ''){ # style="display: none;" # } #>` +
                        // `<input type="checkbox" ${ this.isChkDisabled } id="pre_1_check_#: pre_1_ord_pre_no #" class="checkbox__input" # if(typeof pre_1_check !== 'undefined' && pre_1_check){ # checked # } #>` +
                        `<input type="checkbox" id="pre_1_check_#: pre_1_ord_pre_no #" class="checkbox__input" 
                        # if(pre_1_disabled || '${this.isChkDisabled}' === 'disabled'){ # disabled # } # 
                        # if(typeof pre_1_check !== 'undefined' && pre_1_check){ # checked # } #>` +
                        `<span class="checkbox__checkmark"></span></div>`,
              width: "3.5em",
              sortable: false,
              attributes: {
                "class": "#= pre_1_disabled ? 'other-facility-cell' : '' #"
              },
            },
            {
              // 前回処方日-処方日
              field: "pre_1_date",
              hidden: false,
              title: "処方日",
              width: "8em",
              attributes: {
                "class": "#= pre_1_disabled ? 'other-facility-cell' : '' #"
              },
            },
            {
              // 前回処方日-処方区分
              field: "pre_1_class",
              hidden: false,
              title: "処方区分",
              width: "8em",
              attributes: {
                "class": "#= pre_1_disabled ? 'other-facility-cell' : '' #"
              },
            },
            {
              // 前回処方日-処方オーダー番号
              field: "pre_1_ord_pre_no",
              hidden: true,
              title: "処方オーダー番号"
            },
          ],
          values: [
            {
              value: 2
            }
          ]
        },
        {
          // 2回前処方日
          field: "pre_2",
          hidden: false,
          lockable: false,
          title: "2回前処方日",
          columns: [
            {
              // 2回前処方日-チェック
              field: "pre_2_check",
              hidden: false,
              title: "Pre2CheckAll",
              headerTemplate: `<div style="">` +
                              `<input type="checkbox" ${ this.isChkDisabled } id="pre2-header-chb" class="checkbox__input header-checkbox">` +
                              `<span class="checkbox__checkmark"></span></div>`,
              template: `<div class="checkbox" # if(typeof pre_2_check === 'undefined' || pre_2_date == null || pre_2_date == ''){ # style="display: none;" # } #>` +
                        // `<input type="checkbox" ${ this.isChkDisabled } id="pre_2_check_#: pre_2_ord_pre_no #" class="checkbox__input" # if(typeof pre_2_check !== 'undefined' && pre_2_check){ # checked # } #>` +
                        `<input type="checkbox" id="pre_2_check_#: pre_2_ord_pre_no #" class="checkbox__input"
                          # if(pre_2_disabled || '${this.isChkDisabled}' === 'disabled'){ # disabled # } #
                          # if(typeof pre_2_check !== 'undefined' && pre_2_check){ # checked # } # >` +
                        `<span class="checkbox__checkmark"></span></div>`,
              width: "3.5em",
              sortable: false,
              attributes: {
                "class": "#= pre_2_disabled ? 'other-facility-cell' : '' #"
              },
            },
            {
              // 2回前処方日-処方日
              field: "pre_2_date",
              hidden: false,
              title: "処方日",
              width: "8em",
              attributes: {
                "class": "#= pre_2_disabled ? 'other-facility-cell' : '' #"
              },
            },
            {
              // 2回前処方日-処方区分
              field: "pre_2_class",
              hidden: false,
              title: "処方区分",
              width: "8em",
              attributes: {
                "class": "#= pre_2_disabled ? 'other-facility-cell' : '' #"
              },
            },
            {
              // 2回前処方日-処方オーダー番号
              field: "pre_2_ord_pre_no",
              hidden: true,
              title: "処方オーダー番号"
            },
          ],
          values: [
            {
              value: 2
            }
          ]
        },
        {
          // 3回前処方日
          field: "pre_3",
          hidden: false,
          lockable: false,
          title: "3回前処方日",
          columns: [
            {
              // 3回前処方日-チェック
              field: "pre_3_check",
              hidden: false,
              title: "Pre3CheckAll",
              headerTemplate: `<div style="">` +
                              `<input type="checkbox" ${ this.isChkDisabled } id="pre3-header-chb" class="checkbox__input header-checkbox">` +
                              `<span class="checkbox__checkmark"></span></div>`,
              template: `<div class="checkbox" # if(typeof pre_3_check === 'undefined' || pre_3_date == null || pre_3_date == ''){ # style="display: none;" # } #>` +
                        // `<input type="checkbox" ${ this.isChkDisabled } id="pre_3_check_#: pre_3_ord_pre_no #" class="checkbox__input" # if(typeof pre_3_check !== 'undefined' && pre_3_check){ # checked # } #>` +
                        `<input type="checkbox" id="pre_3_check_#: pre_3_ord_pre_no #" class="checkbox__input" 
                          # if(pre_3_disabled || '${this.isChkDisabled}' === 'disabled'){ # disabled # } #
                          # if(typeof pre_3_check !== 'undefined' && pre_3_check){ # checked # } # >` +
                        `<span class="checkbox__checkmark"></span></div>`,
              width: "3.5em",
              sortable: false,
              attributes: {
                "class": "#= pre_3_disabled ? 'other-facility-cell' : '' #"
              },
            },
            {
              // 3回前処方日-処方日
              field: "pre_3_date",
              hidden: false,
              title: "処方日",
              width: "8em",
              attributes: {
                "class": "#= pre_3_disabled ? 'other-facility-cell' : '' #"
              },
            },
            {
              // 3回前処方日-処方区分
              field: "pre_3_class",
              hidden: false,
              title: "処方区分",
              width: "8em",
              attributes: {
                "class": "#= pre_3_disabled ? 'other-facility-cell' : '' #"
              },
            },
            {
              // 3回前処方日-処方オーダー番号
              field: "pre_3_ord_pre_no",
              hidden: true,
              title: "処方オーダー番号"
            },
          ],
          values: [
            {
              value: 2
            }
          ]
        }
      ]
    }
  },
  methods: {
    ...mapActions("pat-info", ["selectPat", "setSearchedPatList"]),
    ...mapMutations("pat-prescription", ["setRouteFlag", "setAppointedDate"]),
    ...mapActions("prescription/list", [
      "setOrdPreNo",
    ]),
    ...mapActions("pat-prescription", ["sendRequestGetOrderPrescriptionDetail"]),
    
    /**
     * 列ヘッダクリック時にソート順を設定
     * @param {*} e 
     */
    sortHandler(e) {
      this.currentSort = e.sort;
    },
    /**
     * 列ヘッダクリック時のソート処理
     * @param {*} a 
     * @param {*} b 
     */
    compareByField(a, b) {
      // ソートなしはreturn
      if (!this.currentSort || !this.currentSort.field) return;

      const sortFieldName = SORT_KEY_MAP[this.currentSort.field] || this.currentSort.field;
      // 共通関数でソート      
      return sortableCompare(a, b, sortFieldName, true);
    },

    async getList(){

      const patList = this.searchedPatList.map(x=>{
        return {
          pat_id: Number(x.pat_id),
          hosp_pat_id: x.hosp_pat_id,
          pat_name: (x.pat_last_name == null ? "": x.pat_last_name) + ' ' + (x.pat_first_name == null ? "": x.pat_first_name),
          in_out_class: x.in_out_class,
          is_same: x.is_same,
          pat_name_sort: x.pat_name_sort, // 患者名ソート用文字列
        }
      });
      const patIdList = patList.map(x => x.pat_id).filter(y => y);
      let prescriptionTypeList = [];
      if(this.getCondition.viewPreOut){
        prescriptionTypeList.push('1')
      }
      if(this.getCondition.viewPreIn){
        prescriptionTypeList.push('2')
      }
      if (this.getAppointedDate == ""){
        this.setAppointedDate(moment().format("YYYY/MM/DD"));
      }
      // mod #12462 患者情報共有 Ji start
      const patientShareMode = (this.getIsOtherFacility === false || (this.getOtherFacilityCd !== null && this.getOtherFacilityCd !== this.getFacilityCd)) ? 1 : this.getPatientShareMode
      const newList = await sendRequestGetprescriptionList(patIdList, this.getAppointedDate.replace(/\//g, ""), prescriptionTypeList, patientShareMode).then(result => result.data);
      // mod #12462 患者情報共有 Ji end
      newList.map(x => {
        // ソートで使用するため元の値を保管
        x.prescriptionTypeOrg = x.prescriptionType;
        x.issueStateOrg = x.issueState;
        x.prescriptionType2Org = x.prescriptionType2;
        x.issueState2Org = x.issueState2;
        
        if(x.prescriptionType == "1"){
          x.prescriptionType = "院外";
        }else if(x.prescriptionType == "2"){
          x.prescriptionType = "院内";
        }
        if(x.issueState == "0"){
          x.issueState = "未"
        }else if(x.issueState == "1"){
          x.issueState = "済"
        }

        if(x.prescriptionType2 == "1"){
            x.prescriptionType2 = "院外";
        }else if(x.prescriptionType2 == "2"){
            x.prescriptionType2 = "院内";
        }
        if(x.issueState2 == "0"){
          x.issueState2 = "未"
        }else if(x.issueState2 == "1"){
          x.issueState2 = "済"
        }

        return x;
      });
      const nowDate = moment().format("YYYY/MM/DD");
      const grouped = this.groupBy(newList, x => x.patId);
      const resultList = patList.map(pat => {
        const x = grouped.filter(y => pat.pat_id == y[0].patId)[0];
        const hasNext = x.filter(y => y.issueDate > nowDate);
        const len = x.length;
        let has2 = false;
        let has3 = false;
        let has4 = false;
        if (hasNext.length > 0) {
          switch (len) {
            case 2:
              has2 = true;
              break;
            case 3:
              has2 = true;
              has3 = true;
              break;
            case 4:
              has2 = true;
              has3 = true;
              has4 = true;
              break;
            default:
              break;
          }
          return {
            pat_id: x[0].patId,
            hosp_pat_id: pat.hosp_pat_id,
            in_out_class: pat.in_out_class,
            is_same: pat.is_same,
            image_src_same: this.imageSrcSame,
            pat_first_name: "",
            pat_last_name: "",
            pat_name: pat.pat_name,
            p_save_state: x[0].issueState2,
            p_class: x[0].prescriptionType2,
            p_save_state_org: x[0].issueState2Org,   // 指定日情報.交付
            p_class_org: x[0].prescriptionType2Org,  // 指定日情報.処方区分
            p_ord_pre_no: x[0].ordPrescriptionNo2,
            kur: x[0].indKurName,
            bed_name: x[0].indBedName,
            treatment_method: x[0].indTreatmentName,
            next_save_state: x[0].issueState,
            next_date: x[0].issueDate,
            next_class: x[0].prescriptionType,
            next_save_state_org: x[0].issueStateOrg, // 次回処方.交付
            next_class_org: x[0].prescriptionTypeOrg,// 次回処方.処方区分
            next_ord_pre_no: x[0].ordPrescriptionNo,
            pre_1_check: false,
            pre_1_date: has2 ? x[1].issueDate : "",
            pre_1_class: has2 ? x[1].prescriptionType : "",
            pre_1_class_org: has2 ? x[1].prescriptionTypeOrg : "",// 前回処方.処方区分
            pre_1_ord_pre_no: has2 ? x[1].ordPrescriptionNo : "",
            pre_2_check: false,
            pre_2_date: has3 ? x[2].issueDate : "",
            pre_2_class: has3 ? x[2].prescriptionType : "",
            pre_2_class_org: has3 ? x[2].prescriptionTypeOrg : "",// 2回前処方.処方区分
            pre_2_ord_pre_no: has3 ? x[2].ordPrescriptionNo : "",
            pre_3_check: false,
            pre_3_date: has4 ? x[3].issueDate : "",
            pre_3_class: has4 ? x[3].prescriptionType : "",
            pre_3_class_org: has4 ? x[3].prescriptionTypeOrg : "",// 3回前処方.処方区分
            pre_3_ord_pre_no: has4 ? x[3].ordPrescriptionNo : "",
            pat_name_sort: pat.pat_name_sort,
            kur_start_time: x[0].kurStartTime,
            bed_order_index: x[0].bedOrderIndex,
            treatment_order_index: x[0].treatmentOrderIndex,
	    // add #12462 患者情報共有 Ji start
            pre_1_disabled: !(has2 && x[1]) || x[1].facilityCd !== this.getFacilityCd,
            pre_2_disabled: !(has3 && x[2]) || x[2].facilityCd !== this.getFacilityCd,
            pre_3_disabled: !(has4 && x[3]) || x[3].facilityCd !== this.getFacilityCd,
	    // add #12462 患者情報共有 Ji end
          }
        } else {
          switch (len) {
            case 2:
              has2 = true;
              break;
            case 3:
              has2 = true;
              has3 = true;
              break;
            default:
              break;
          }
          return {
            pat_id: x[0].patId,
            hosp_pat_id: pat.hosp_pat_id,
            in_out_class: pat.in_out_class,
            is_same: pat.is_same,
            image_src_same: this.imageSrcSame,
            pat_first_name: "",
            pat_last_name: "",
            pat_name: pat.pat_name,
            p_save_state: x[0].issueState2,
            p_class: x[0].prescriptionType2,
            p_save_state_org: x[0].issueState2Org,   // 指定日情報.交付
            p_class_org: x[0].prescriptionType2Org,  // 指定日情報.処方区分
            p_ord_pre_no: x[0].ordPrescriptionNo2,
            kur: x[0].indKurName,
            bed_name: x[0].indBedName,
            treatment_method: x[0].indTreatmentName,
            next_save_state: "",
            next_date: "",
            next_class: "",
            next_save_state_org: "", // 次回処方.交付
            next_class_org: "",      // 次回処方.処方区分
            next_ord_pre_no: "",
            pre_1_check: false,
            pre_1_date: x[0].issueDate,
            pre_1_class: x[0].prescriptionType,
            pre_1_class_org: x[0].prescriptionTypeOrg,// 前回処方.処方区分
            pre_1_ord_pre_no: x[0].ordPrescriptionNo,
            pre_2_check: false,
            pre_2_date: has2 ? x[1].issueDate : "",
            pre_2_class: has2 ? x[1].prescriptionType : "",
            pre_2_class_org: has2 ? x[1].prescriptionTypeOrg : "",// 2回前処方.処方区分
            pre_2_ord_pre_no: has2 ? x[1].ordPrescriptionNo : "",
            pre_3_check: false,
            pre_3_date: has3 ? x[2].issueDate : "",
            pre_3_class: has3 ? x[2].prescriptionType : "",
            pre_3_class_org: has3 ? x[2].prescriptionTypeOrg : "",// 3回前処方.処方区分
            pre_3_ord_pre_no: has3 ? x[2].ordPrescriptionNo : "",
            pat_name_sort: pat.pat_name_sort,
            kur_start_time: x[0].kurStartTime,
            bed_order_index: x[0].bedOrderIndex,
            treatment_order_index: x[0].treatmentOrderIndex,
	    // add #12462 患者情報共有 Ji start
            pre_1_disabled: !x[0] || x[0].facilityCd !== this.getFacilityCd,
            pre_2_disabled: !(has2 && x[1]) || x[1].facilityCd !== this.getFacilityCd,
            pre_3_disabled: !(has3 && x[2]) || x[2].facilityCd !== this.getFacilityCd,
	    // add #12462 患者情報共有 Ji end
          }
        } 
      });
      
      // 患者検索でソート更新・検索実行した場合、処方側のソート状態を保持する（処方画面でソート指定したときのみソート条件保持）
      this.prescriptionDataSource1 = new Kendo.data.DataSource({data: resultList, sort: this.currentSort ? this.currentSort : null});
      this.$nextTick(() => {
        // 選択中の処方オーダー番号の更新
        this.updateOrdPreNo();
        // チェックボックスの再描画
        const ordPreNoList = this.getOrdPreNo;
        ordPreNoList.forEach(function(id) {
          this.setCheckBoxes(id);
        }, this);
        // 全チェックボタンの状態を確認
        this.checkAllBtnStatus();
      });
    },

    groupBy(array, f) {
      var groups = {};
      array.forEach(x => {
          var group = JSON.stringify(f(x));
          groups[group] = groups[group] || [];
          groups[group].push(x);
      });
      return Object.keys(groups).map(x => groups[x]);
    },

    initGoToInfo(){
      if (this.selectedPatId && this.getRouteFlag) {
        this.$router.push({ name: "pat-prescription" });
      }
    },

    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      // mod #10225 処方薬剤選択に一般名処方が表示しない。yqz start
      // this.kendoGridHeight = document.getElementsByClassName("main-content-area kendo-grid-style-page")[0].clientHeight;
      this.kendoGridHeight = document.getElementsByClassName("main-content-area kendo-grid-style-page")[0]?.clientHeight;
      // mod #10225 処方薬剤選択に一般名処方が表示しない。yqz end
    },
    setFontColor(ev){
      // Databaund 時のイベント
      // console.log("Databaund - setFontColorイベント");
      // Grid高さの調整
      this.$nextTick(() => {
        this.calculateGridHeight();
      });

      if (this.firstLoadFlg) {
        this.$nextTick(() => {
          setTimeout(() => {
            // console.log("初期表示の時にはリサイズが必要");
            $$(window).trigger('resize');
          }, 1);
        });
        this.firstLoadFlg = false;
      }

      // ヘッダースタイル適用
      this.setHeaderStyle();

      // CheckBox チェック時のイベントを一旦削除してから付与する(再描画の度にイベントが外れる為、都度設定する)
      this.$refs.prescriptionlistgrid.kendoWidget().table[0].removeEventListener("click", function(e){this.chektestfnk(e)}.bind(this));
      this.$refs.prescriptionlistgrid.kendoWidget().thead[0].removeEventListener("click", function(e){this.allCheck(e)}.bind(this));
      // CheckBox チェック時のイベントを付与
      this.$refs.prescriptionlistgrid.kendoWidget().table[0].addEventListener("click", function(e){this.chektestfnk(e)}.bind(this));
      this.$refs.prescriptionlistgrid.kendoWidget().thead[0].addEventListener("click", function(e){this.allCheck(e)}.bind(this));

      // チェック状態が消えるためチェックボックスの再描画
      const ordPreNoList = this.getOrdPreNo;
      ordPreNoList.forEach(function(id) {
        this.setCheckBoxes(id);
      }, this);
      // 全チェックボタンの状態を確認
      this.checkAllBtnStatus();
      //処方情報のポップオーバー表示時にウィンドウのリサイズによってグリッドの再描画が発生した場合
      if(this.popoverTarget){
        //処方情報のポップオーバーの非表示への切替
        this.$refs.popoverPrescriptionInfo.updateVisibleFlg(false, true);
      }
      this.$nextTick(() => {
        if (this.resizeFlg) {
          //スクロールバーの位置をイベント発生前の位置に戻す
          ev.sender.content[0].scrollTop = this.scrollPosition.top;
          ev.sender.content[0].scrollLeft = this.scrollPosition.left;
          if(!this.firstLoadFlg){
            this.resizeFlg = false;
          }
        } else {
          ev.sender.content[0].scrollTop = 0;
          ev.sender.content[0].scrollLeft = 0;
        }
        //処方情報のポップオーバー表示時にウィンドウのリサイズによってグリッドの再描画が発生した場合
        if(this.popoverTarget){
          const grid = this.$refs.prescriptionlistgrid.kendoWidget();
          //ポップオーバーの呼び出し元の要素の再取得
          this.popoverTarget = grid.element[0].childNodes[2].children[0].lastChild.childNodes[this.popoverTargetPosition.rowIndex].cells[this.popoverTargetPosition.colIndex];
          //処方情報のポップオーバーの再表示
          this.$refs.popoverPrescriptionInfo.updateVisibleFlg(true, false);
        }
      });
    },
    setHeaderStyle() {
      // ヘッダーにスタイル適用
      this.$refs.prescriptionlistgrid.$el.firstElementChild?.classList?.add(
        "master-grid-header"
      );
    },
    // 患者ID、患者名項目をクリックした場合は、処方画面に遷移
    async onClick(e) {
      if (e.sender) {
        // 選択行取得
        const selcolIndex = e.sender.cellIndex(e.sender.select().closest("td"));
        const patId = e.sender.dataItem(e.sender.select().closest("tr")).pat_id;
        // 患者ID、患者名列の場合
        if (selcolIndex === CNO_PAT_ID || selcolIndex === CNO_PAT_NAME) {
          await this.selectPat(patId);
          await this.$router.push({ name: "pat-prescription" });
        } else {
          //処方情報ポップオーバーの表示処理が実行済みの場合(セルを連続でクリックした場合)
          if(this.popoverTarget){
            return;
          }
          const prescriptionData = this.prescriptionDataSource1.data().find((item) => {
            return item.pat_id === patId;
          });
          let ordPrescriptionNo = null;
          // 指定日情報-交付、指定日情報-処方区分列の場合
          if (selcolIndex === CNO_DATE_INFO || selcolIndex === CNO_CLASS_INFO) {
            ordPrescriptionNo = prescriptionData.p_ord_pre_no;
          // 次回処方-交付、次回処方-処方日、次回処方-処方区分列の場合
          } else if (selcolIndex === CNO_NEXT_STATE_INFO || selcolIndex === CNO_NEXT_DATE_INFO || selcolIndex === CNO_NEXT_CLASS_INFO) {
            ordPrescriptionNo = prescriptionData.next_ord_pre_no;
            console.log(ordPrescriptionNo);
          // 前回処方日-処方日、前回処方日-処方区分列の場合
          } else if (selcolIndex === CNO_PRE_1_DATE_INFO || selcolIndex === CNO_PRE_1_CLASS_INFO) {
            ordPrescriptionNo = prescriptionData.pre_1_ord_pre_no;
          // 2回前処方日-処方日、2回前処方日-処方区分列の場合
          } else if (selcolIndex === CNO_PRE_2_DATE_INFO || selcolIndex === CNO_PRE_2_CLASS_INFO) {
            ordPrescriptionNo = prescriptionData.pre_2_ord_pre_no;
          // 3回前処方日-処方日、3回前処方日-処方区分列の場合
          } else if (selcolIndex === CNO_PRE_3_DATE_INFO || selcolIndex === CNO_PRE_3_CLASS_INFO) {
            ordPrescriptionNo = prescriptionData.pre_3_ord_pre_no;
          }
          //選択したデータの処方オーダー番号が取得できた場合
          if(ordPrescriptionNo){
            await this.sendRequestGetOrderPrescriptionDetail(ordPrescriptionNo);
            this.showPopover(e);
            const row = e.sender.dataItem(e.sender.select().closest("tr"));
            let rowIndex = this.prescriptionDataSource1.view().indexOf(row);
            //呼び出し元の要素の表示位置(行番号)の設定
            this.popoverTargetPosition.rowIndex = rowIndex;
            //呼び出し元の要素の表示位置(列番号)の設定
            this.popoverTargetPosition.colIndex = selcolIndex - 3;
          }
        }
      }
    },
    /**
     * ポップオーバー表示処理
     */
    showPopover(event) {
      this.popoverTarget = event.sender.select()[0];
      this.popoverData.popoverVisible = true;
      this.popoverData.prescriptionInfoData = this.getInputModal;
      this.popoverData.prescriptionDetailList = this.getPrescriptionDetail;
    },
    /**
     * ポップオーバー非表示処理
     */
    closePopover() {
      this.popoverData.popoverVisible = false;
      this.popoverTarget = null;
      this.popoverTargetPosition.rowIndex = -1;
      this.popoverTargetPosition.colIndex = -1;
    },
    // チェック時にチェック状態を保持
    allCheck(e) {
      if (e.target.checked != null && this.prescriptionDataSource1._data.length !== 0) {

        // データ分だけチェックボックスにチェックを入れる
        if (e.target.id.indexOf("pre1-header-chb") >= 0) {
          // 前回処方日
          this.prescriptionDataSource1._data.forEach(function(obj) {
            if (typeof obj.pre_1_date !== 'undefined' && (obj.pre_1_date !== null && obj.pre_1_date !== '')) {
              const targetId = "pre_1_check_" + obj.pre_1_ord_pre_no;
	      // mod #12462 患者情報共有 Ji start
              const el = document.getElementById(targetId);
              // document.getElementById(targetId).checked = e.target.checked;
              if (el && !el.disabled) {
                el.checked = e.target.checked;
              }
	      // mod #12462 患者情報共有 Ji end
              if (e.target.checked) {
                // 他のチェックを解除
                if (typeof obj.pre_2_date !== 'undefined') {
                  const pre2Id = "pre_2_check_" + obj.pre_2_ord_pre_no;
		  // mod #12462 患者情報共有 Ji start
                  // document.getElementById(pre2Id).checked = false;
                  const el2 = document.getElementById(pre2Id);
                  if (el2 && !el2.disabled) {
                    el2.checked = false;
                  }
		  // mod #12462 患者情報共有 Ji end
                }
                if (typeof obj.pre_3_date !== 'undefined') {
                  const pre3Id = "pre_3_check_" + obj.pre_3_ord_pre_no;
		  // mod #12462 患者情報共有 Ji start
                  // document.getElementById(pre3Id).checked = false;
                  const el3 = document.getElementById(pre3Id);
                  if (el3 && !el3.disabled) {
                    el3.checked = false;
                  }
		  // mod #12462 患者情報共有 Ji end
                }
              }
            }
          }, this);
        } else if (e.target.id.indexOf("pre2-header-chb") >= 0) {
          // 2回前処方日
          this.prescriptionDataSource1._data.forEach(function(obj) {
            if (typeof obj.pre_2_date !== 'undefined' && (obj.pre_2_date !== null && obj.pre_2_date !== '')) {
              const targetId = "pre_2_check_" + obj.pre_2_ord_pre_no;
	      // mod #12462 患者情報共有 Ji start
              const el = document.getElementById(targetId);
              if (el && !el.disabled) {
                el.checked = e.target.checked;
              }
              // document.getElementById(targetId).checked = e.target.checked;
	      // mod #12462 患者情報共有 Ji end
              if (e.target.checked) {
                // 他のチェックを解除
                if (typeof obj.pre_1_date !== 'undefined') {
                  const pre1Id = "pre_1_check_" + obj.pre_1_ord_pre_no;
		  // mod #12462 患者情報共有 Ji start
                  // document.getElementById(pre1Id).checked = false;
                  const el1 = document.getElementById(pre1Id);
                  if (el1 && !el1.disabled) {
                    el1.checked = false;
                  }
		  // mod #12462 患者情報共有 Ji end
                }
                if (typeof obj.pre_3_date !== 'undefined') {
                  const pre3Id = "pre_3_check_" + obj.pre_3_ord_pre_no;
		  // mod #12462 患者情報共有 Ji start
                  // document.getElementById(pre3Id).checked = false;
                  const el3 = document.getElementById(pre3Id);
                  if (el3 && !el3.disabled) {
                    el3.checked = false;
                  }
		  // mod #12462 患者情報共有 Ji end
                }
              }
            }
          }, this);
        } else if (e.target.id.indexOf("pre3-header-chb") >= 0) {
          // 3回前処方日
          this.prescriptionDataSource1._data.forEach(function(obj) {
            if (typeof obj.pre_3_date !== 'undefined' && (obj.pre_3_date !== null && obj.pre_3_date !== '')) {
              const targetId = "pre_3_check_" + obj.pre_3_ord_pre_no;
	      // mod #12462 患者情報共有 Ji start
              const el = document.getElementById(targetId);
              if (el && !el.disabled) {
                el.checked = e.target.checked;
              }
              // document.getElementById(targetId).checked = e.target.checked;
	      // mod #12462 患者情報共有 Ji end
              if (e.target.checked) {
                // 他のチェックを解除
                if (typeof obj.pre_1_date !== 'undefined') {
                  const pre1Id = "pre_1_check_" + obj.pre_1_ord_pre_no;
		  // mod #12462 患者情報共有 Ji start
                  // document.getElementById(pre1Id).checked = false;
                  const el1 = document.getElementById(pre1Id);
                  if (el1 && !el1.disabled) {
                    el1.checked = false;
                  }
		  // mod #12462 患者情報共有 Ji end
                }
                if (typeof obj.pre_2_date !== 'undefined') {
                  const pre2Id = "pre_2_check_" + obj.pre_2_ord_pre_no;
		  // mod #12462 患者情報共有 Ji start
                  // document.getElementById(pre2Id).checked = false;
                  const el2 = document.getElementById(pre2Id);
                  if (el2 && !el2.disabled) {
                    el2.checked = false;
                  }
		  // mod #12462 患者情報共有 Ji end
                }
              }
            }
          }, this);
        }
        // 全チェックボタンの状態を確認
        this.checkAllBtnStatus();
        this.checkOrdPreNo();
      }
    },
    // チェック時にチェック状態を保持
    chektestfnk(e) {
      if (e.target.checked != null) {
        let targetPre = "";
        if (e.target.id.indexOf("pre_1_check_") >= 0) {
          targetPre = "pre1Checks";
        } else if (e.target.id.indexOf("pre_2_check_") >= 0) {
          targetPre = "pre2Checks";
        } else if (e.target.id.indexOf("pre_3_check_") >= 0) {
          targetPre = "pre3Checks";
        }

        // 同じ行の他チェックを排他処理
        const ordPreNo = e.target.id.slice(12);
        const targetObj = this.prescriptionDataSource1._data.find(function(obj) {
          return obj.pre_1_ord_pre_no === Number(ordPreNo) || obj.pre_2_ord_pre_no === Number(ordPreNo) || obj.pre_3_ord_pre_no === Number(ordPreNo);
        });

        if (targetPre === "pre1Checks") {
          if(typeof targetObj.pre_2_date !== 'undefined'){
            document.getElementById("pre_2_check_" + targetObj.pre_2_ord_pre_no).checked = false;
          }
          if(typeof targetObj.pre_3_date !== 'undefined'){
            document.getElementById("pre_3_check_" + targetObj.pre_3_ord_pre_no).checked = false;
          }
        } else if (targetPre === "pre2Checks") {
          document.getElementById("pre_1_check_" + targetObj.pre_1_ord_pre_no).checked = false;
          if(typeof targetObj.pre_3_date !== 'undefined'){
            document.getElementById("pre_3_check_" + targetObj.pre_3_ord_pre_no).checked = false;
          } 
        } else if (targetPre === "pre3Checks") {
          document.getElementById("pre_1_check_" + targetObj.pre_1_ord_pre_no).checked = false;
          document.getElementById("pre_2_check_" + targetObj.pre_2_ord_pre_no).checked = false;
        }

        // 全チェックボタンの状態を確認
        this.checkAllBtnStatus();
        this.checkOrdPreNo();
      }
    },
    // チェック処理後の全チェックボタン制御
    checkAllBtnStatus() {
      let pre1AllFlg = true;
      let pre2AllFlg = true;
      let pre3AllFlg = true;

      let pre1Count = 0;
      let pre2Count = 0;
      let pre3Count = 0;

      // チェック状態確認
      if(typeof this.prescriptionDataSource1._data !== 'undefined'){
        this.prescriptionDataSource1._data.forEach(function(obj) {
          if (pre1AllFlg && typeof obj.pre_1_date !== 'undefined') {
            // 配列にないか、チェックされていない(false)
	    // mod #12462 患者情報共有 Ji start
            // const pre1Obj = document.getElementById("pre_1_check_" + obj.pre_1_ord_pre_no).checked;
            // if (pre1Obj === false && (obj.pre_1_date !== null && obj.pre_1_date !== '')) {
            //   pre1AllFlg = false;
            // }
            // if(obj.pre_1_date !== null && obj.pre_1_date !== ''){
            //   pre1Count++;
            // }
            const el = document.getElementById("pre_1_check_" + obj.pre_1_ord_pre_no);
            if (el && !el.disabled && obj.pre_1_date !== null && obj.pre_1_date !== '' ) {
              if (!el.checked) {
                pre1AllFlg = false;
              }
	    // mod #12462 患者情報共有 Ji end
              pre1Count++;
            }
          }
          if (pre2AllFlg && typeof obj.pre_2_date !== 'undefined') {
	    // mod #12462 患者情報共有 Ji start
            // const pre2Obj = document.getElementById("pre_2_check_" + obj.pre_2_ord_pre_no).checked;
            // if (pre2Obj === false && (obj.pre_2_date !== null && obj.pre_2_date !== '')) {
            //   pre2AllFlg = false;
            // }
            // if(obj.pre_2_date !== null && obj.pre_2_date !== ''){
            //   pre2Count++;
            // }
            const el = document.getElementById("pre_2_check_" + obj.pre_2_ord_pre_no);
            if (el && !el.disabled && obj.pre_2_date !== null && obj.pre_2_date !== '' ) {
              if (!el.checked) {
                pre2AllFlg = false;
              }
	    // mod #12462 患者情報共有 Ji end
              pre2Count++;
            }
          }
          if (pre3AllFlg && typeof obj.pre_3_date !== 'undefined') {
	    // mod #12462 患者情報共有 Ji start
            // const pre3Obj = document.getElementById("pre_3_check_" + obj.pre_3_ord_pre_no).checked;
            // if (pre3Obj === false && (obj.pre_3_date !== null && obj.pre_3_date !== '')) {
            //   pre3AllFlg = false;
            // }
            // if(obj.pre_3_date !== null && obj.pre_3_date !== ''){
            //   pre3Count++;
            // }
            const el = document.getElementById("pre_3_check_" + obj.pre_3_ord_pre_no);
            if (el && !el.disabled && obj.pre_3_date !== null && obj.pre_3_date !== '' ) {
              if (!el.checked) {
                pre3AllFlg = false;
              }
	    // mod #12462 患者情報共有 Ji end
              pre3Count++;
            }
          }
        }, this);
      }
      // 状態に応じてチェック状態を変更する
      // mod #12462 患者情報共有 Ji start
      // if(pre1Count > 0){
      //   pre1AllFlg ? document.getElementById("pre1-header-chb").checked = true : document.getElementById("pre1-header-chb").checked = false;
      // }
      const header1 = document.getElementById("pre1-header-chb");
      if (header1) {
        if (pre1Count > 0) {
          header1.checked = pre1AllFlg;
        } else {
          header1.checked = false;
        }
      }
      // if(pre2Count > 0){
      //   pre2AllFlg ? document.getElementById("pre2-header-chb").checked = true : document.getElementById("pre2-header-chb").checked = false;
      // }
      const header2 = document.getElementById("pre2-header-chb");
      if (header2) {
        if (pre2Count > 0) {
          header2.checked = pre2AllFlg;
        } else {
          header2.checked = false;
        }
      }
      // if(pre3Count > 0){
      //   pre3AllFlg ? document.getElementById("pre3-header-chb").checked = true : document.getElementById("pre3-header-chb").checked = false;
      // }
      const header3 = document.getElementById("pre3-header-chb");
      if (header3) {
        if (pre3Count > 0) {
          header3.checked = pre3AllFlg;
        } else {
          header3.checked = false;
        }
      }
      // mod #12462 患者情報共有 Ji end
    },

    // 選択した処方の処方オーダー番号を一括コピー対象に設定
    checkOrdPreNo() {
      let ordPreNo = [];

      // チェック状態確認
      this.prescriptionDataSource1._data.forEach(function(obj) {
        if (typeof obj.pre_1_date !== 'undefined') {
          // 配列にないか、チェックされていない(false)
          const pre1Obj = document.getElementById("pre_1_check_" + obj.pre_1_ord_pre_no).checked;
          if(pre1Obj === true){
            ordPreNo.push(obj.pre_1_ord_pre_no);
          }
        }
        if (typeof obj.pre_2_date !== 'undefined') {
          const pre2Obj = document.getElementById("pre_2_check_" + obj.pre_2_ord_pre_no).checked;
          if(pre2Obj === true){
            ordPreNo.push(obj.pre_2_ord_pre_no);
          }
        }
        if (typeof obj.pre_3_date !== 'undefined') {
          const pre3Obj = document.getElementById("pre_3_check_" + obj.pre_3_ord_pre_no).checked;
          if(pre3Obj === true){
            ordPreNo.push(obj.pre_3_ord_pre_no);
          }
        }
      }, this);

      // 選択したOrdPreNoを設定
      this.setOrdPreNo(ordPreNo);
    },

    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name) {
        this.getList();
      }
    },

    // 検索条件が変わった場合のordPreNoの更新
    updateOrdPreNo() {
      const ordPreNoList = this.getOrdPreNo;
      if (ordPreNoList.length !== 0 && typeof this.prescriptionDataSource1._data !== 'undefined') {
        let newOrdPreNoList = [];
        this.prescriptionDataSource1._data.forEach(function(obj) {
          if(ordPreNoList.indexOf(obj.pre_1_ord_pre_no) >= 0) {
            newOrdPreNoList.push(obj.pre_1_ord_pre_no);
          }
          if(ordPreNoList.indexOf(obj.pre_2_ord_pre_no) >= 0) {
            newOrdPreNoList.push(obj.pre_2_ord_pre_no);
          }
          if(ordPreNoList.indexOf(obj.pre_3_ord_pre_no) >= 0) {
            newOrdPreNoList.push(obj.pre_3_ord_pre_no);
          }
        }, this);
        this.setOrdPreNo(newOrdPreNoList);
      }
    },
    // チェックボックスの再描画
    setCheckBoxes(id) {
      const pre1Id = "pre_1_check_" + id;
      const pre2Id = "pre_2_check_" + id;
      const pre3Id = "pre_3_check_" + id;

      if (document.getElementById(pre1Id) != null) {
        document.getElementById(pre1Id).checked = true;
      }
      if (document.getElementById(pre2Id) != null) {
        document.getElementById(pre2Id).checked = true;
      }
      if (document.getElementById(pre3Id) != null) {
        document.getElementById(pre3Id).checked = true;
      }
    },
    getAuthority() {
      const pEdit = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PRESCRIPTION_PEDIT);
      const edit = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PRESCRIPTION_EDIT);
      if(pEdit == false && edit == false){
        this.isChkDisabled = "disabled" ;
      }else{
        this.isChkDisabled = "" ;
      }
    },
  },

  watch: {
    searchedPatList() {
      this.getList();
    },
    selectedPatId(){
      if(this.selectedPatId){
        this.$router.push({ name: "pat-prescription" });
      }
    },
    windowHeight() {
      //イベント発生前のスクロールバーの位置を保持
      const scrollTop = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop;
      const scrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      this.resizeFlg = true;
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      // 画面印刷中は処理しない
      if (this.isPrint) return;
      
      this.calculateGridHeight();
    },
    sidebarWidth() {
      $$(window).trigger('resize');
    },
    // ヘッダ検索条件
    getCondition() {
      const gridObj = this.$refs.prescriptionlistgrid.kendoWidget();
      this.getCondition.viewPatId ? gridObj.showColumn(CNO_PAT_ID) : gridObj.hideColumn(CNO_PAT_ID);
      this.getCondition.viewDateInfo ? gridObj.showColumn(CNO_DATE_INFO) : gridObj.hideColumn(CNO_DATE_INFO);
      this.getList();
    },
    // add #12462 患者情報共有 Ji start
    getPatientShareMode() {
      this.getList();
    },
    getPatientShareFacilityCdMode() {
      this.getList();
    },
    // add #12462 患者情報共有 Ji end
  },
  mounted() {
    this.initGoToInfo();
    this.setRouteFlag(true);
  },
  created() {
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
    EventBus.$off("refresh", this.refresh);
    EventBus.$on("refresh", this.refresh);
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    this.getAuthority();
  },
  updated() {
    const gridObj = this.$refs.prescriptionlistgrid.kendoWidget();
    this.getCondition.viewPatId ? gridObj.showColumn(CNO_PAT_ID) : gridObj.hideColumn(CNO_PAT_ID);
    this.getCondition.viewDateInfo ? gridObj.showColumn(CNO_DATE_INFO) : gridObj.hideColumn(CNO_DATE_INFO);
  },
  beforeDestroy() {
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
    EventBus.$off("refresh", this.refresh);
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style scoped>
.main-content-area {
  min-width: 200px;
}
.prescription-list-main-content {
  font-size:1em;
}
.prescription-list-main-content >>> .k-i-sort-asc-sm::before {
  content: "▲" !important;
  color: #ffffff;
}
.prescription-list-main-content >>> .k-i-sort-desc-sm::before {
  content: "▼" !important;
  color: #ffffff;
}
.prescription-list-main-content >>> .k-grid-content-locked {
  touch-action: auto;
  -webkit-overflow-scrolling: touch;
  overflow-y: auto;
  scrollbar-width: none; /* Firefox */
}
.prescription-list-main-content >>> .k-grid-content-locked::-webkit-scrollbar {
  display: none; /* Chrome, Safari */
}
@media print {  
  /** スクロールコンテナ */
  .prescription-list-main-content >>> .k-grid-header-wrap,
  .prescription-list-main-content >>> .k-grid-content {
    overflow: hidden !important;
    height: auto !important;
  }
  
  /** 固定列調整 */
  .prescription-list-main-content >>> .k-grid-content-locked {
    height: auto !important;
  }
  /** 固定列枠線 */
  .prescription-list-main-content >>> .k-grid-header-locked::after {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-header-background-color);
    pointer-events: none;
  }
  .prescription-list-main-content >>> .k-grid-content-locked::after {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-border-color);
    pointer-events: none;
  }
  /** ヘッダのズレ原因を除去 */
  .prescription-list-main-content >>> .k-grid-header {
    padding-right: 0 !important;
  }
  /** gridの幅 */
  .prescription-list-main-content >>> .k-grid {
    width: 100vw;
    height: auto !important;
  }
  .prescription-list-main-content {
    display: inline-block; /** ヘッダとbodyでページわかれるのを防止 */
  }
  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  /* 右端時固定列最前面表示*/
  .prescription-list-main-content:has(table.scroll-rightmost) >>> .k-grid-content-locked,
  .prescription-list-main-content:has(table.scroll-rightmost) >>> .k-grid-header-locked {
    z-index: 1;
  }
  .main-content-area:has(table.scroll-rightmost) {
    margin-left: -1px !important;
  }
  .prescription-list-main-content >>> .k-grid-header-wrap:has(table.scroll-rightmost),
  .prescription-list-main-content >>> .k-grid-content:has(table.scroll-rightmost) {
    position: static;
  }
}
</style>
<style >
.in_class_prescription {
  color: #A356A3;
}
</style>
