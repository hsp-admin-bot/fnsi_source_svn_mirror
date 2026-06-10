<template>
  <div class="wrap-block ntss-send-condition-text">
    <div class="vertical-div">
      <custom-checkbox
        :value="formColorEnabled"
        :checked-value="'1'"
        :unchecked-value="'0'"
        @change="changeFormColor"
      >背景色</custom-checkbox>
      <input
        class="scale-input"
        type="color"
        :disabled="formColorEnabled.editValue !== '1'"
        v-model="backgroundColor"
        @change="changeFormColor"
        @focus="editStart"
        @blur="editEnd"
      />
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import customCheckbox from "@/components/common/custom-form-tags/CustomCheckbox.vue";
export default {
  components: {
    "custom-checkbox": customCheckbox
  },
  data() {
    return {
      formColorEnabled: { initValue: null, editValue: null },
      colorSetting: null,
      backgroundColor: null,
      //Android端末で編集中であることを示すフラグ
      androidFlg: false
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn"
    })
  },
  methods: {
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    ...mapActions("mst-weight", {
      setIsGridEditing: "setIsGridEditing"
    }),
    async editStart() {
      if (this.androidFlg) {
        await this.setIsGridEditing(true);
      }
    },
    editEnd() {
      this.setIsGridEditing(false);
    },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    passFather(){
      let giveUpFlg = false;
      if (this.formColorEnabled.initValue!==this.formColorEnabled.editValue) {
          giveUpFlg=true;
      }
      return giveUpFlg;
    },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    changeFormColor() {
      if (this.formColorEnabled.editValue === "1") {
        this.colorSetting.form = this.backgroundColor;
      } else {
        this.colorSetting = {};
      }
      this.updateEditRecord("colorSetting", JSON.stringify(this.colorSetting));
    },
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    }
  },
  created() {
    // 端末判別
    if (navigator.userAgent.match(/Android/)) {
      this.androidFlg = true;
    }
  },
  mounted() {
    // 親画面から配色設定JSONデータ取得
    this.colorSetting = JSON.parse(this.editRecord.colorSetting);
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start
    if (this.colorSetting === undefined || this.colorSetting.form === undefined || this.colorSetting.form === null) {
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
      this.formColorEnabled.initValue = "0";
      this.backgroundColor = "#ffffff";
    } else {
      this.formColorEnabled.initValue = "1";
      this.backgroundColor = this.colorSetting.form;
    }
    this.formColorEnabled.editValue = this.formColorEnabled.initValue;
  }
};
</script>

<style scoped>
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}
.scale-label {
  margin-left: auto;
  margin-right: auto;
  font-size: 1.5em;
  margin: 5px 10px;
  min-width: 190px;
  height: 20px;
  text-align: left;
}
.wrap-block {
  margin-top: 12px;
  margin-left: 10px;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}

.scale-input {
  font-size: 1.25em;
  margin: 5px 10px;
  width: 120px;
  height: 25px;
  text-align: left;
}
</style>
