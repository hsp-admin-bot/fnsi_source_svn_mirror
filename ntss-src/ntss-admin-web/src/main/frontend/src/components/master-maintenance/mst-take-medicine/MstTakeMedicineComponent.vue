<template>
    <div slot="body" :class="['view', modalMessageSize]">
      <p>{{editRecord.name}}</p>
      <com-textarea
        :content="listDetail"
        idTextarea="com-textarea-take-medicine"
        cssClass="textarea"
        defaultHeight="400px"
        @set-content-data="setContentData"
      />
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import CommonTextArea from "@/components/common/CommonTextArea";
import {EventBus} from "@/eventBus";
export default {
  name: "MstTakeMedicineModal",
  mixins: [MasterMaintenanceMixin],
  components: {
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      listDetail: "",
      initDetail: "",
    }
  },
  computed: {
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      masterName: "getMasterName",
      editRecord: "getEditRecord",
      columns: "getColumns"
    }),
    ...mapGetters("account-edit", ["getFontSize"]),
    modalMessageSize() {
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
    mounted() {
    //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    // editRecordから取得
    getSelectByField(field) {
       return this.editRecord[field];
    },
     //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },

    setContentData(newValue) {
      this.listDetail = newValue;
      // mod 10291 【因島データ】 Convert '\r\n' (Windows) and '\n' (Unix Mac)  to  '\r\n' shiyw start
      // var list = newValue.split("\n").join(",");
      // while(list.substring(list.length - 1) == ','){
      //   list = list.substring(0,list.length - 1);
      // }
      // this.editRecord.listDetails = list;
      let resultText = this.lineBreakConversion(newValue);
      while (resultText.endsWith('\r\n')) {
        resultText = resultText.substring(0,resultText.length - 2);
      }
      this.editRecord.listDetails = resultText;
      // mod 10291 【たくしん会】処方のコンバートが正しくない shiyw end
      this.setEditRecord(this.editRecord);
      //mod マスタ詳細画面がありません破棄メッセージ 张博 start
      if (this.initDetail!==this.listDetail) {
        this.changeButton();
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
      //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    },
    //add 10291 【たくしん会】処方のコンバートが正しくない  shiyw start
    lineBreakConversion(text){
      if( text === null || text === undefined) {
        return "";
      }
      const  regex = /\r?\n/g;
      let result = text.replaceAll(regex,'\r\n');
      return result
    }
    //add 10291 【因島データ】 Convert '\r\n' (Windows) and '\n' (Unix Mac)  to  '\r\n'  shiyw end
  },
  created() {
    //mod 10291 【因島データ】 Convert '\r\n' (Windows) and '\n' (Unix Mac)  to  '\r\n' shiyw start
    //var list = this.getSelectByField("listDetails").split(",");
    this.listDetail = this.lineBreakConversion(this.getSelectByField("listDetails"));
    //mod 10291 【因島データ】 Convert '\r\n' (Windows) and '\n' (Unix Mac)  to  '\r\n' shiyw end
    this.initDetail = this.listDetail;
  }
}
</script>

<style scoped>
.view{
  padding: 0 10px 10px 10px;
  overflow-y: auto;
}

.textarea{
  width: 100%;
  height: 400px;
  font-size: unset;
}

.view.small {
  max-height: calc(100% - 21px);
}

.view.medium {
  max-height: calc(100% - 12px);
}

.view.big {
  max-height: calc(100% - 6px);
}

.view.xbig {
  max-height: calc(100% - 2px);
}
</style>
