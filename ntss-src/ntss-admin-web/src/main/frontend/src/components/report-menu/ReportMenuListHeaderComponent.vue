<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header">
        <v-ons-col class="condition-search-col">
        </v-ons-col>
        <!-- mod FNSI-改修内容 画面ボタンの位置調整 穆 start -->
        <!-- <v-ons-col> -->
        <v-ons-col class="condition-search-col">
        <div class="condition btn-group">
          <!-- mod #699,700,751 陳 start -->
<!--          <v-ons-button-->
<!--            class="common-style-select-button btn-width-fix"-->
<!--            :class="(this.selectedPatients.length > 0 && this.selectedReportClassID) ? 'active':'disabled'"-->
<!--            @click="showExportPopover($event, 'left', true)"-->
<!--          >ファイル保存</v-ons-button>-->
          <!--mod 4391   吉 start-->
          <!--<v-ons-button
            class="common-style-select-button btn-width-fix"
            :class="((this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID != 7) || (this.selectedReportClassID ==7 && this.selectedMachines.length > 0)) ? 'active':'disabled'"
            @click="showExportPopover($event, 'left', true)"
          >ファイル保存</v-ons-button>-->
          <!--mod #11293 水質検査帳票の課題対応 limingzhe start-->
          <!-- <v-ons-button
            class="common-style-select-button btn-width-fix coment-higth btn3-normal"
            :class="((this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID != 7) || (this.selectedReportClassID ==7 && this.selectedMachines.length > 0)) ? 'active':'disabled'"
            @click="showExportPopover($event, 'left', true)"
          >ファイル保存</v-ons-button> -->
          <!--mod #11973 日常点検一覧帳票が正常に出せない limingzhe start-->
          <!-- <v-ons-button
            class="common-style-select-button btn-width-fix coment-higth btn3-normal"
            :class="((this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID !== 7 && !(this.selectedReportClassID === 11 && this.selectedReportTypeId === 3))
              || (this.selectedReportClassID === 7 && this.selectedMachines.length > 0)
              || (this.selectedReportClassID === 11 && this.selectedReportTypeId === 3 && this.selectedMachines.length > 0)
            ) ? 'active':'disabled'"
            @click="showExportPopover($event, 'left', true)"
          >ファイル保存</v-ons-button> -->
          <v-ons-button
            class="common-style-select-button btn-width-fix coment-higth btn3-normal"
            :class="isShowReport ? 'active':'disabled'"
            @click="showExportPopover($event, 'left', true)"
          >ファイル保存</v-ons-button>
          <!--mod #11973 日常点検一覧帳票が正常に出せない limingzhe end-->
          <!--mod #11293 水質検査帳票の課題対応 limingzhe end-->
          <!--mod 4391   吉 end-->
          <!-- mod #699,700,751 陳 end -->
          <!--mod 4391   吉 start-->
         <!-- <v-ons-button
            class="common-style-select-button btn-width-fix"
            :class="this.selectedReportClassID == 8 ? 'active':'disabled'"
            @click="generateValueTable($event, 'left', true)"
          >ラベル開始位置</v-ons-button>
          <v-ons-button
            class="common-style-select-button btn-width-fix"
            :class="(this.selectedReportClassID && this.extractCondition[this.selectedReportClassID]['isSort']) ? 'active': 'disabled'"
            @click="showPopover($event, 'left', true)"
          >並び替え</v-ons-button>-->
          <v-ons-button
            class="common-style-select-button btn-width-fix coment-higth btn3-normal"
            :class="this.selectedReportClassID == 8 ? 'active':'disabled'"
            @click="generateValueTable($event, 'left', true)"
          >ラベル開始位置</v-ons-button>
          <v-ons-button
            class="common-style-select-button btn-width-fix coment-higth btn3-normal"
            :class="(this.selectedReportClassID && this.extractCondition[this.selectedReportClassID]['isSort']) ? 'active': 'disabled'"
            @click="showPopover($event, 'left', true)"
          >並び替え</v-ons-button>
          <!--mod 4391   吉 end-->
         <!-- <br />-->
          <!-- mod #699,700,751 陳 start -->
<!--          <v-ons-button-->
<!--            class="common-style-select-button btn-width-fix"-->
<!--            :class="(this.selectedPatients.length > 0 && this.selectedReportClassID) ? 'active':'disabled'"-->
<!--            @click="previewFile"-->
<!--          >プレビュー</v-ons-button>-->
<!--          <v-ons-button-->
<!--            class="common-style-select-button btn-width-fix"-->
<!--            :class="(this.selectedPatients.length > 0 && this.selectedReportClassID) ? 'active':'disabled'"-->
<!--            @click="printFile"-->
<!--          >印刷</v-ons-button>-->
          <!--mod 4391   吉 start -->
          <!--<v-ons-button
            class="common-style-select-button btn-width-fix"
            :class="((this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID != 7) || (this.selectedReportClassID ==7 && this.selectedMachines.length > 0)) ? 'active':'disabled'"
            @click="previewFile"
          >プレビュー</v-ons-button>
          <v-ons-button
            class="common-style-select-button btn-width-fix"
            :class="((this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID != 7) || (this.selectedReportClassID ==7 && this.selectedMachines.length > 0)) ? 'active':'disabled'"
            @click="printFile"
          >印刷</v-ons-button>-->
          <!--mod #11293 水質検査帳票の課題対応 limingzhe start-->
          <!-- <v-ons-button
            class="common-style-select-button btn-width-fix coment-higth btn3-normal"
            :class="((this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID != 7) || (this.selectedReportClassID ==7 && this.selectedMachines.length > 0)) ? 'active':'disabled'"
            @click="previewFile"
          >プレビュー</v-ons-button>
          <v-ons-button
            class="common-style-select-button btn-width-fix coment-higth btn3-normal"
            :class="((this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID != 7) || (this.selectedReportClassID ==7 && this.selectedMachines.length > 0)) ? 'active':'disabled'"
            @click="showPrintPopover($event, 'down', true)"
          >印刷</v-ons-button> -->
          <!--mod #11973 日常点検一覧帳票が正常に出せない limingzhe start-->
          <!-- <v-ons-button
            class="common-style-select-button btn-width-fix coment-higth btn3-normal"
            :class="((this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID !== 7 && !(this.selectedReportClassID === 11 && this.selectedReportTypeId === 3))
              || (this.selectedReportClassID === 7 && this.selectedMachines.length > 0)
              || (this.selectedReportClassID === 11 && this.selectedReportTypeId === 3 && this.selectedMachines.length > 0)
            ) ? 'active':'disabled'"
            @click="previewFile"
          >プレビュー</v-ons-button>
          <v-ons-button
            class="common-style-select-button btn-width-fix coment-higth btn3-normal"
            :class="((this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID !== 7 && !(this.selectedReportClassID === 11 && this.selectedReportTypeId === 3))
              || (this.selectedReportClassID === 7 && this.selectedMachines.length > 0)
              || (this.selectedReportClassID === 11 && this.selectedReportTypeId === 3 && this.selectedMachines.length > 0)
            ) ? 'active':'disabled'"
            @click="showPrintPopover($event, 'down', true)"
          >印刷</v-ons-button> -->
          <v-ons-button
            class="common-style-select-button btn-width-fix coment-higth btn3-normal"
            :class="isShowReport ? 'active':'disabled'"
            @click="previewFile"
          >プレビュー</v-ons-button>
          <v-ons-button
            class="common-style-select-button btn-width-fix coment-higth btn3-normal"
            :class="isShowReport ? 'active':'disabled'"
            @click="showPrintPopover($event, 'down', true)"
          >印刷</v-ons-button>
          <!--mod #11973 日常点検一覧帳票が正常に出せない limingzhe end-->
          <!--mod #11293 水質検査帳票の課題対応 limingzhe end-->
          <!--mod 4391   吉 end-->
          <!-- mod #699,700,751 陳 end -->
        </div>
        <!-- mod FNSI-改修内容 画面ボタンの位置調整 穆 end -->
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-card>
</template>

<script>
// add FNSI-改修内容 画面ボタンの位置調整 穆 start
import { EventBus } from "@/eventBus.js";
import {
  EXTRACTION_CONDITION
} from "@/constants/reportMenu.js";
import {mapGetters} from "vuex";
// add FNSI-改修内容 画面ボタンの位置調整 穆 end
export default {
  // mod FNSI-改修内容 画面ボタンの位置調整 穆 start
  // name: "ReportMenuListHeaderComponent"
  name: "ReportMenuListHeaderComponent",
  data() {
      return {
        selectedPatients:[],
        // add #699,700,751 陳 start
        selectedMachines:[],
        // add #699,700,751 陳 end
        selectedReportClassID:null,
        // add #11293 水質検査帳票の課題対応 limingzhe start
        selectedReportTypeId:null,
        // add #11293 水質検査帳票の課題対応 limingzhe end
        extractCondition: EXTRACTION_CONDITION
      };
    },
  created() {
    setTimeout(() => {
      EventBus.$on("selectedPatients", (param) =>{
        this.selectedPatients = param.paramSelected;
        this.selectedReportClassID = param.paramReportClassID;
      });
      // add #699,700,751 陳 start
      EventBus.$on("selectedMachines", (param) =>{
        this.selectedMachines = param.paramSelected;
        // add #11293 水質検査帳票の課題対応 limingzhe start
        this.selectedReportTypeId = param.selectedReportTypeId;
        // add #11293 水質検査帳票の課題対応 limingzhe end
      });
      // add #699,700,751 陳 end
    }, 200);
    //add 4391   吉 start
    this.$nextTick(() => {
      this.gridSetting();
    });
    //add 4391   吉 end
  },
  beforeDestroy() {
    EventBus.$off("selectedPatients");
    EventBus.$off("selectedMachines");
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  //add 4391   吉 start
  computed: {
    ...mapGetters("account-edit", ["getFontSize"]),
    // add #11973 日常点検一覧帳票が正常に出せない limingzhe start
    isShowReport() {
      var bShow = false;
      if(this.selectedReportClassID === 7){
        if (this.selectedMachines.length > 0) {
          bShow = true;
        }
      }
      else if(this.selectedReportClassID === 11){
        if(this.selectedReportTypeId === 3) {
          if (this.selectedMachines.length > 0) bShow = true;
        }
        else if(this.selectedReportTypeId === 4) {
          if (this.selectedMachines.length > 0) bShow = true;
        }
        // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
        else if(this.selectedReportTypeId === 5) {
          if (this.selectedMachines.length > 0) bShow = true;
        }
        // add #11985 定期点検一覧帳票が正常に出せない limingzhe end
        else if(this.selectedPatients.length > 0 && this.selectedReportClassID)
        {
          bShow = true;
        }
      }
      else if(this.selectedPatients.length > 0 && this.selectedReportClassID)
      {
        bShow = true;
      }
      return bShow;
    },
    // add #11973 日常点検一覧帳票が正常に出せない limingzhe end
  },
  watch : {
    getFontSize() {
      this.gridSetting();
    },
  },
  //add 4391   吉 end
  methods: {
    //add 4391   吉 start
    gridSetting(){
      const heigths = document.getElementsByClassName("condition-search-col")[0].clientHeight;
      document.getElementsByClassName("coment-higth")[0].style.height = heigths -20 + "px";
      document.getElementsByClassName("coment-higth")[1].style.height = heigths -20 + "px";
      document.getElementsByClassName("coment-higth")[2].style.height = heigths -20 + "px";
      document.getElementsByClassName("coment-higth")[3].style.height = heigths -20 + "px";
      document.getElementsByClassName("coment-higth")[4].style.height = heigths -20 + "px";
    },
    //add 4391   吉 end
    showExportPopover(event, direction, coverTarget = false) {
      let param = {
              paramEvent: event,
              paramDirection: direction,
              paramCoverTarget: coverTarget
            };
      EventBus.$emit("exportMsg", param);
    },
    generateValueTable(event, direction, coverTarget = false) {
      let param = {
              paramEvent: event,
              paramDirection: direction,
              paramCoverTarget: coverTarget
            };
      EventBus.$emit("printMsg", param);
    },
    showPopover(event, direction, coverTarget = false) {
      let param = {
              paramEvent: event,
              paramDirection: direction,
              paramCoverTarget: coverTarget
            };
      EventBus.$emit("msg", param);
    },
    // 印刷
    showPrintPopover(event, direction, coverTarget = false) {
      let param = {
              paramEvent: event,
              paramDirection: direction,
              paramCoverTarget: coverTarget
            };
      EventBus.$emit("printerSelectMsg", param);
    },
    previewFile() {
      EventBus.$emit("previewFileMsg");
    },
    printFile() {
      EventBus.$emit("printFileMsg");
    },
  }
  // mod FNSI-改修内容 画面ボタンの位置調整 穆 end
};
</script>
<!-- add FNSI-改修内容 画面ボタンの位置調整 穆 start -->
<style lang="scss" scoped>
.condition {
  .disabled {
    pointer-events: none;
    opacity: 0.6;
  }
  .active {
    opacity: 1;
    pointer-events: all;
  }
}
.btn-group {
  //mod 4391   吉 start
  margin-left: 80px;
  margin-top: 5px;
  //mod 4391   吉 end
  .button {
    margin: 5px 0 0 5px;
    cursor: pointer;
  }
}
.btn-width-fix {
  //mod 4391   吉 start
  /*width: 9em !important;*/
  width: 17%  !important;
  //mod 4391   吉 end
  font-size: 1.1em !important;
}
.condition-search-col {
  position:absolute;
  right:0px;
  //mod 4391   吉 start
  /*width:500px;*/
  width:760px;
  //mod 4391   吉 end
}
// FNSI-改修内容4391bug修正 関 start
.common-style-select-button{
  height: 30px;
}
// FNSI-改修内容4391bug修正 関 start
// add FNSI-改修内容5765修正 関 start
@media screen and (max-width: 480px) {
.btn-group{
  margin-left: 410px;
  margin-top: -2px;
}
.btn-width-fix{
  width: 8em !important;
}
.coment-higth{
  height: 21px !important;
}
//add 5935 スマホサイズで並び替えの表示が切れる場合がある 王永吉 start
.button--material {
  min-height: 0px;
  line-height: 32px !important;
}
//add 5935 スマホサイズで並び替えの表示が切れる場合がある 王永吉 end
}
// add FNSI-改修内容5765修正 関　end
</style>
<!-- add FNSI-改修内容 画面ボタンの位置調整 穆 end -->
