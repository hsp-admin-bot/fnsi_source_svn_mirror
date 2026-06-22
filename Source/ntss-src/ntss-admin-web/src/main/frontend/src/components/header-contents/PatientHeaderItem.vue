/**
 * 患者情報ヘッダ
 */
<template>
  <div class='headbox' style="font-size:12px; padding: 3px;">
    <div style="min-width: 200px; width: 20%;">
      <div>
        <label style="width: 30%;">院内ID</label>
        <label style="width: 70%;">{{ hospPatId }}</label>
      </div>
      <div>
        <label style="width: 30%;">ふりがな</label>
        <label style="width: 70%;">{{ patNameKana }}</label>
      </div>
      <div>
        <label style="width: 30%;">患者名</label>
        <label style="width: 70%;">{{ patName }}</label>
      </div>
    </div>
    <div style="display: flex; width: 80%;" >
      <div style="display: flex; min-width: 220px; width: 20%;">
        <div style="width: 20%;">
          <div>
            <label >性別</label>
          </div>
          <div>
            <label >{{ patSex }}</label>
          </div>
        </div>
        <div  style="width: 30%;">
          <div>
            <label >血液型</label>
          </div>
          <div>
            <label >{{ patBloodABO + '(' + patBloodRH + ')' }}</label>
          </div>
        </div>
        <div>
          <div>
            <label >生年月日</label>
          </div>
          <div>
            <label >{{ patBirthday + '(' + patAge + '歳)' }}</label>
          </div>
        </div>
      </div>
      <div>
        <img class="img-icon" :src="image_src_in" v-show="isInClass"/>
        <img class="img-icon" :src="image_src_out" v-show="isOutClass" />
        <img class="img-icon" :src="image_src_same" v-show="isSame"/>
        <img class="img-icon" :src="image_src_taboo" v-show="isSame" />
        <img class="img-icon" :src="image_src_infect" v-show="isInfect" />
        <img class="img-icon" :src="image_src_implant" v-show="isImplant" /> 
      </div>

    </div>
  </div>
</template>

<script>
/* eslint-disable */
import { mapState, mapActions } from "@/compat/vue/vuex";

import hospitalizationImg from "../../assets/hospitalization.png";
import outpatientImg from "../../assets/outpatient.png";
import nameDuplicationImg from "../../assets/name_duplication.png";
import infectionImg from "../../assets/infection.png";

const data = function() {
  return {
    /* テストデータ */
    patList: [
      { patId: '000000000001' },
      { patId: '000000000002' },
    ],
    patIndex: 0,
    image_src_in: hospitalizationImg,
    image_src_out: outpatientImg,
    image_src_same: nameDuplicationImg,
    image_src_taboo: infectionImg,
    image_src_infect: infectionImg,
    image_src_implant: infectionImg,
  };
};

const computed = {
  ...mapState('patient', [
    'patientData',
    'patId',
  ]),
  
  hospPatId: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return this.patientData.hospPatId;
      }
      return '';
    },
  },
  patName: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return this.patientData.patName;
      }
      return '患者が選択されていません';
    },
  },
  patNameKana: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return this.patientData.patNameKana;
      }
      return '';
    },
  },
  patSex: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return this.patientData.patSex;
      }
      return '不明';
    },
  },
  patAge: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return this.patientData.patAge;
      }
      return '－';
    },
  },
  patBirthday: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return this.patientData.patBirthday;
      }
      return '不明';
    },
  },
  patBloodABO: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return this.patientData.patBloodTypeAbo;
      }
      return '不明';
    },
  },
  patBloodRH: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return this.patientData.patBloodTypeRh;
      }
      return '不明';
    },
  },
  /*
  patInout: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return this.patientData.inOutClass;
      }
      return '';
    },
  },
  */
  isInClass: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return ('1' != this.patientData.inOutClass);
      }
      return false;
    },
  },
  isOutClass: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return ('1' == this.patientData.inOutClass);
      }
      return false;
    },
  },
  isSame: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return ('1' == this.patientData.isSame);
      }
      return false;
    },
  },
  isInfect: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return ('1' == this.patientData.isInfect);
      }
      return false;
    },
  },
  isTaboo: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        // console.log('禁忌A：' + this.patientData.isTaboo);
        return this.patientData.isTaboo;
      }
      // console.log('禁忌B：データなし');
      return '';
    },
  },
  isImplant: {
    get() {
      if (null != this.patientData && undefined != this.patientData) {
        return ('1' == this.patientData.isImplant);
      }
      return false;
    },
  },
};

const methods = {
  ...mapActions('patient', {
    getPatient: 'getPatient',
  }),
  
  getPatInfo() {
    var patId = this.patList[this.patIndex].patId;
    this.getPatient({ patId });
  },
};

const mounted = function() {
  //setTimeout(this.getPatInfo, 50);
  this.getPatInfo();
};

export default {
  data,
  methods,
  computed,
  mounted,
};

</script>

<style scoped>
.headbox
{
  width: 100%;
  min-width: 500px;
  display: flex;
  justify-content: flex-start;
}
.layoutbox
{
  width: 50%;
  min-width: 200px;
  display: flex;
  justify-content: space-around;
}
.fab-top-right {
  top: 10px;
  bottom: auto;
  right: 10px;
  left: auto;
  position: absolute;
}
.img-icon {
  width: 16%;
  height: auto;
  min-width: 20px;
  max-width: 60px;
}
.textitems
{
  font-size: 24px;
}
</style>
