/**
 * 音声ガイダンスタブ画面
 */
<template>
  <div class="ntss-send-condition-text">
    <div class="wrap-block">
      <div class="check-area">
        <custom-checkbox
          :value="patOkEnabled"
          :checked-value="'1'"
          :unchecked-value="'0'"
          @change="changeCheckBox"
        >測定開始</custom-checkbox>
      </div>
      <div class="label-area">
        <label>再生遅延（秒）</label>
      </div>
      <div class="text-area" v-if="patOkDelay.editValue !== null">
        <custom-input-number-pro
          class="number-text"
          :digits="4"
          :min="0"
          :max="9999"
          :step="1"
          :emptyVal="9999"
          :disabled="getPatOkEnabled"
          :value="patOkDelay.editValue"
          @handlerInput="(val) => {
            patOkDelay.editValue = val;
            changeCheckBox()
          }"
        />
      </div>
      <v-ons-button class="btn3-normal file-button" @click="callPlayAudioStart">再生</v-ons-button>
    </div>
    <div class="wrap-block">
      <div class="check-area">
        <custom-checkbox
          :value="measureEnabled"
          :checked-value="'1'"
          :unchecked-value="'0'"
          @change="changeCheckBox"
        >測定値受信</custom-checkbox>
      </div>
      <div class="label-area">
        <label>再生遅延（秒）</label>
      </div>
      <div class="text-area" v-if="receiveWeightDelay.editValue !== null">
        <custom-input-number-pro
          class="number-text"
          :digits="4"
          :min="0"
          :max="9999"
          :step="1"
          :emptyVal="9999"
          :disabled="getMeasureEnabled"
          :value="receiveWeightDelay.editValue"
          @handlerInput="(val) => {
            receiveWeightDelay.editValue = val;
            changeCheckBox()
          }"
        />
      </div>
      <v-ons-button class="btn3-normal file-button" @click="callPlayAudioMeasure">再生</v-ons-button>
    </div>
    <div class="wrap-block">
      <div class="check-area">
        <custom-checkbox
          :value="sendOkEnabled"
          :checked-value="'1'"
          :unchecked-value="'0'"
          @change="changeCheckBox"
        >送信成功</custom-checkbox>
      </div>
      <div class="label-area">
        <label>再生遅延（秒）</label>
      </div>
      <div class="text-area" v-if="sendOkDelay.editValue !== null">
        <custom-input-number-pro
          class="number-text"
          :digits="4"
          :min="0"
          :max="9999"
          :step="1"
          :emptyVal="9999"
          :disabled="getSendOkEnabled"
          :value="sendOkDelay.editValue"
          @handlerInput="(val) => {
            sendOkDelay.editValue = val;
            changeCheckBox()
          }"          
        />
      </div>
      <v-ons-button class="btn3-normal file-button" @click="callPlayAudioSendOk">再生</v-ons-button>
    </div>
    <div class="wrap-block">
      <div class="check-area">
        <custom-checkbox
          :value="sendNgEnabled"
          :checked-value="'1'"
          :unchecked-value="'0'"
          @change="changeCheckBox"
        >送信失敗</custom-checkbox>
      </div>
      <div class="label-area">
        <label>再生遅延（秒）</label>
      </div>
      <div class="text-area" v-if="sendNgDelay.editValue !== null">
        <custom-input-number-pro
          class="number-text"
          :digits="4"
          :min="0"
          :max="9999"
          :step="1"
          :emptyVal="9999"
          :disabled="getSendNgEnabled"
          :value="sendNgDelay.editValue"
          @handlerInput="(val) => {
            sendNgDelay.editValue = val;
            changeCheckBox()
          }"          
        />
      </div>
      <v-ons-button class="btn3-normal file-button" @click="callPlayAudioErr">再生</v-ons-button>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import customCheckbox from "@/components/common/custom-form-tags/CustomCheckbox.vue";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";
export default {
  components: {
    "custom-checkbox": customCheckbox,
    "custom-input-number-pro": CustomInputNumberPro
  },
  data() {
    return {
      patOkEnabled: { initValue: null, editValue: null },
      measureEnabled: { initValue: null, editValue: null },
      sendOkEnabled: { initValue: null, editValue: null },
      sendNgEnabled: { initValue: null, editValue: null },
      patOkDelay: { initValue: null, editValue: null },
      receiveWeightDelay: { initValue: null, editValue: null },
      sendOkDelay: { initValue: null, editValue: null },
      sendNgDelay: { initValue: null, editValue: null },
      audioSetting: null,
      //Android端末で編集中であることを示すフラグ
      androidFlg: false,
      audioStartId: 0,
      audioMeasureId: 0,
      audioSendOkId: 0,
      audioErrId: 0
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
    }),
    getPatOkEnabled() {
      if (this.patOkEnabled.editValue === "1") {
        return false;
      }
      return true;
    },
    getMeasureEnabled() {
      if (this.measureEnabled.editValue === "1") {
        return false;
      }
      return true;
    },
    getSendOkEnabled() {
      if (this.sendOkEnabled.editValue === "1") {
        return false;
      }
      return true;
    },
    getSendNgEnabled() {
      if (this.sendNgEnabled.editValue === "1") {
        return false;
      }
      return true;
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
    this.audioSetting = JSON.parse(this.editRecord.audioSetting);
    this.patOkEnabled.initValue = this.audioSetting.pat_ok === "1" ? "1" : "0";
    this.patOkEnabled.editValue = this.patOkEnabled.initValue;
    this.measureEnabled.initValue =
      this.audioSetting.receive_weight === "1" ? "1" : "0";
    this.measureEnabled.editValue = this.measureEnabled.initValue;
    this.sendOkEnabled.initValue =
      this.audioSetting.send_ok === "1" ? "1" : "0";
    this.sendOkEnabled.editValue = this.sendOkEnabled.initValue;
    this.sendNgEnabled.initValue =
      this.audioSetting.send_ng === "1" ? "1" : "0";
    this.sendNgEnabled.editValue = this.sendNgEnabled.initValue;
    // 患者認識再生遅延時間
    if (
      this.audioSetting.pat_ok_delay === undefined ||
      this.audioSetting.pat_ok_delay === null
    ) {
      this.patOkDelay.initValue = 0;
    } else {
      this.patOkDelay.initValue = this.audioSetting.pat_ok_delay;
    }
    this.patOkDelay.editValue = this.patOkDelay.initValue;
    // 体重読み込み時再生遅延時間
    if (
      this.audioSetting.receive_weight_delay === undefined ||
      this.audioSetting.receive_weight_delay === null
    ) {
      this.receiveWeightDelay.initValue = 0;
    } else {
      this.receiveWeightDelay.initValue = this.audioSetting.receive_weight_delay;
    }
    this.receiveWeightDelay.editValue = this.receiveWeightDelay.initValue;
    // 送信完了再生遅延時間
    if (
      this.audioSetting.send_ok_delay === undefined ||
      this.audioSetting.send_ok_delay === null
    ) {
      this.sendOkDelay.initValue = 0;
    } else {
      this.sendOkDelay.initValue = this.audioSetting.send_ok_delay;
    }
    this.sendOkDelay.editValue = this.sendOkDelay.initValue;
    // 送信失敗再生遅延時間
    if (
      this.audioSetting.send_ng_delay === undefined ||
      this.audioSetting.send_ng_delay === null
    ) {
      this.sendNgDelay.initValue = 0;
    } else {
      this.sendNgDelay.initValue = this.audioSetting.send_ng_delay;
    }
    this.sendNgDelay.editValue = this.sendNgDelay.initValue;
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
    ...mapActions("send-condition/scale/audio", [
      "initAudio",
      "playAudioStart",
      "playAudioErr",
      "playAudioSendOk",
      "playAudioMeasure"
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
      if (this.patOkEnabled.initValue != this.patOkEnabled.editValue ||
          this.measureEnabled.initValue != this.measureEnabled.editValue||
          this.sendOkEnabled.initValue != this.sendOkEnabled.editValue ||
          this.sendNgEnabled.initValue != this.sendNgEnabled.editValue ||
          this.patOkDelay.initValue != this.patOkDelay.editValue ||
          this.receiveWeightDelay.initValue != this.receiveWeightDelay.editValue||
          this.sendOkDelay.initValue != this.sendOkDelay.editValue ||
          this.sendNgDelay.initValue != this.sendNgDelay.editValue
      ) {
            giveUpFlg = true;
      }
      return giveUpFlg;
    },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    changeCheckBox() {
      this.audioSetting.pat_ok = this.patOkEnabled.editValue;
      this.audioSetting.receive_weight = this.measureEnabled.editValue;
      this.audioSetting.send_ok = this.sendOkEnabled.editValue;
      this.audioSetting.send_ng = this.sendNgEnabled.editValue;
      this.audioSetting.pat_ok_delay = parseFloat(this.patOkDelay.editValue);
      this.audioSetting.receive_weight_delay = parseFloat(this.receiveWeightDelay.editValue);
      this.audioSetting.send_ok_delay = parseFloat(this.sendOkDelay.editValue);
      this.audioSetting.send_ng_delay = parseFloat(this.sendNgDelay.editValue);

      this.updateEditRecord("audioSetting", JSON.stringify(this.audioSetting));
    },
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    callPlayAudioStart() {
      this.audioStartId = setTimeout(() => {
        this.playAudioStart();
      }, this.patOkDelay.editValue * 1000);
    },
    callPlayAudioMeasure() {
      this.audioMeasureId = setTimeout(() => {
        this.playAudioMeasure();
      }, this.receiveWeightDelay.editValue * 1000);
    },
    callPlayAudioSendOk() {
      this.audioSendOkId = setTimeout(() => {
        this.playAudioSendOk();
      }, this.sendOkDelay.editValue * 1000);
    },
    callPlayAudioErr() {
      this.audioErrId = setTimeout(() => {
        this.playAudioErr();
      }, this.sendNgDelay.editValue * 1000);
    }
  },
  beforeDestroy() {
    clearTimeout(this.audioStartId);
    clearTimeout(this.audioMeasureId);
    clearTimeout(this.audioSendOkId);
    clearTimeout(this.audioErrId);
  }
};
</script>

<style scoped>
.check-area {
  margin-left: 10px;
  width: 8em;
}
.wrap-block {
  margin-top: 12px;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  align-items: center;
}
.file-button {
  width: 5em;
  text-align: center;
  font-size: 100%;
}
.label-area {
  width: 8em;
}
.text-area {
  width: 8em;
}
.number-text {
  font-size: 1em;
  margin: 5px 10px;
  width: 6em;
  text-align: left;
}
</style>
