<template>
  <div id="survey-type-modal-content">
    <div class="survey-type">
      <v-ons-row class="input-row-header">
        <v-ons-col class="input-item-name">
          <label>{{ title }}</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt"></v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row" v-for="(item, index) in inputModel" :key="index">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="'checkbox-' + index"
            :value="item.surveyTypeCd"
            v-model="listSurveyType"
            @change="selectType($event, item.surveyTypeCd)"
          ></v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-hd">{{item.surveyTypeName}}</label>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapActions, mapGetters } from "vuex";
export default {
  data() {
    return {
      title: "水質調査種別",
      inputModel: [],
      listSurveyType: [],
      dataInsert: []
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      editRecord: "getEditRecord"
    })
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    selectType: function($event) {
      let id = $event.target.value;
      if ($event.target.checked) {
        if (!this.listSurveyType.includes(id)) {
          this.listSurveyType.push(id);
          this.dataInsert.push(+id)
        }
      } else {
        this.listSurveyType = this.listSurveyType.filter(item => +item !== +id);
        this.dataInsert = this.dataInsert.filter(item => +item !== +id);
      }
      this.editRecord["surveyTypeList"] = JSON.stringify(this.dataInsert);
      this.setEditRecord(this.editRecord);
    }
  },
  async created() {
    if (this.editRecord["surveyTypeList"]) {
      this.listSurveyType = JSON.parse(this.editRecord["surveyTypeList"]);
      this.listSurveyType = this.listSurveyType.map(item => {
        return item.toString();
      })
    }

    let response = await ApiHelper.get("mstInfo/mstWaterSurveyType").catch(
      error => {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('WaterQualitySurveyTypeModal.vue','created',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        throw new Error(error);
      }
    );
    this.inputModel = response.data;
  },
  async mounted() {
    // 縦スクロールバー表示
    let modalObj = document.getElementsByClassName("modal-body");
    if (modalObj.length >= 1) {
      modalObj[0].classList.remove("modal-overflow-hidden");
      modalObj[0]?.classList?.add("modal-scroll");
    }
  }
};
</script>

<style>
#survey-type-modal-content {
  font-size: 1.2em;
  padding-left: 20px;
}
.modal-scroll {
  overflow-x: hidden;
  overflow-y: scroll;
}
.survey-type {
  border: solid 1px rgb(150, 150, 150);
  border-radius: 5px;
  padding: 10px 20px;
  margin-top: 10px;
  margin-bottom: 20px;
  margin-right: 20px;
}
.input-row {
  margin-bottom: 5px;
}
.input-row-header {
  margin-bottom: 10px;
  padding-bottom: 5px;
  border-bottom: 1px solid #bbb;
}
.input-item-name {
  font-size: 1.2em;
  font-weight: bold;
  margin-top: 10px;
  max-width: 15%;
}
.input-item-check {
  font-size: 1.2em;
  font-weight: bold;
  margin-top: 10px;
  max-width: 3%;
}
.input-item-check-name {
  font-size: 1.2em;
  font-weight: bold;
  margin-top: 10px;
  max-width: 15%;
}
</style>
