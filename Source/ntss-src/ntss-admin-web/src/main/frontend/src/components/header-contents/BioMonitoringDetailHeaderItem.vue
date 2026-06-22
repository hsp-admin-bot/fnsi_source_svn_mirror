/**
 * 生体モニタリングページ用ヘッダ
 */
<template>

  <!-- 詳細グラフ用ヘッダ -->

  <div class='headbox header-item header-pat-info-label'>

    <div class='header-pat-info1' v-show='machinedata[detailGraphIndex].view_patInfo'>
      <div class='header-pat-info1-id-area'>
        <div class='header-pat-info1-id'>{{ machinedata[detailGraphIndex].hospPatId }}</div>
        <div class='header-pat-info1-same' v-show='machinedata[detailGraphIndex].view_isSame'>同名患者あり</div>
      </div>
      <div class='header-text-patname'>{{ machinedata[detailGraphIndex].patName }}</div>
    </div>

    <div class='header-pat-info2'>
      <div class='header-pat-icons' v-show='machinedata[detailGraphIndex].view_patInfo'>
<!--
        <img class='img-icon' :src=image_src_in v-show='machinedata[detailGraphIndex].view_inClass'/>
        <img class='img-icon' :src=image_src_out v-show='machinedata[detailGraphIndex].view_outClass'/>
        <img class='img-icon' :src=image_src_same v-show='machinedata[detailGraphIndex].view_isInfect'/>
        <img class='img-icon' :src=image_src_taboo v-show='machinedata[detailGraphIndex].view_tabooInfo'/>
        <img class='img-icon' :src=image_src_infect v-show='machinedata[detailGraphIndex].view_isInfect'/>
        <img class='img-icon' :src=image_src_same v-show='machinedata[detailGraphIndex].view_isImplant'/>
-->
        <div class='inout' v-show='machinedata[detailGraphIndex].view_inClass'>入院</div>
        <div class='inout' v-show='machinedata[detailGraphIndex].view_outClass'>外来</div>
        <div v-bind:class="['icon-div', machinedata[detailGraphIndex].view_tabooInfo ? 'taboo-on': 'taboo-off']"></div>
        <div v-bind:class="['icon-div', machinedata[detailGraphIndex].view_isInfect ? 'infect-on': 'infect-off']"></div>
        <div v-bind:class="['icon-div', machinedata[detailGraphIndex].view_isImplant ? 'implant-on': 'implant-off']"></div>
      </div>

      <div  class='layoutbox'>

        <div class='header-text-margin' >{{ machinedata[detailGraphIndex].view_patSex }}</div>
        <div  class='header-text-margin' >{{ machinedata[detailGraphIndex].view_patBloodType }}</div>
        <div  class='header-text-margin' >{{ machinedata[detailGraphIndex].view_patBirthday }}</div>

      </div>

    </div>
  </div>
</template>

<script>
/* eslint-disable */
import { mapState } from "@/compat/vue/vuex";

import hospitalizationImg from "../../assets/hospitalization.png";
import outpatientImg from "../../assets/outpatient.png";
import nameDuplicationImg from "../../assets/name_duplication.png";
import infectionImg from "../../assets/infection.png";

export default {
  data() {
    return {
      image_src_in: hospitalizationImg,
      image_src_out: outpatientImg,
      image_src_same: nameDuplicationImg,
      image_src_taboo: infectionImg,
      image_src_infect: infectionImg
    };
  },
  computed: {
    ...mapState('listGraph', ['machinedata', 'detailGraphIndex'])
  },
  methods: {
    loadData() {}
  },
};
</script>

<style scoped>

/* ヘッダーパネル設定 */
.headbox {
  width: 100%;
  display: flex;
}
/* 患者ID、患者名表示部　*/
.header-pat-info1 {
  width: 40%;
  margin: 0px 5px;
  overflow: hidden;
}
/* 患者ID、同名患者表示部　*/
.header-pat-info1-id-area {
  width: 100%;
  margin-top: 1px;
  height: 1em;
}
/* 患者ID　*/
.header-pat-info1-id {
  width: 75px;
  margin-top: 2px;
  display: inline-block;
}
/* 同名患者　*/
.header-pat-info1-same {
  display: inline-block;
}
/* 患者名 */
.header-text-patname {
  font-size: 35px;
  display: block;
  float: left;
}
/* 患者情報表示部　*/
.header-pat-info2{
  width: calc( 100% - 40% - 60px);
  overflow: hidden;
}
/* 患者情報アイコン表示部*/
.header-pat-icons {
  height:20px;
  margin-top: 4px;
  /*display: inline-block;*/
}
/* 入院/外来　*/
.inout {
  display: inline-block;
  margin-top: 2px;
  margin-right: 5px;
  font-size:1.8em;
  vertical-align: 2px;
}
/* 各種アイコン共通設定 */
.icon-div {
  margin-top: 2px;
  display: inline-block;
  width: 1.9em;
  height: 1.9em;
  border-radius: 50%;
}
/* 禁忌・アレルギーあり */
.taboo-on {
  background: #FF0000;
}
/* 禁忌・アレルギーなし */
.taboo-off {
  width: 1.5em;
  height: 1.5em;
  border: solid 2px #FF0000;
}
/* 感染症あり */
.infect-on {
  background: #E29763;
}
/* 感染症なし */
.infect-off {
  width: 1.5em;
  height: 1.5em;
  border: solid 2px #E29763;
}
/* インプラントあり */
.implant-on {
  background: #F4D779;
}
/* インプラントなし */
.implant-off {
  width: 1.5em;
  height: 1.5em;
  border: solid 2px #F4D779;
}
/* 性別、血液型、誕生日表示部 */
.layoutbox {
  display: flex;
  flex-wrap: wrap;
  margin-top: 8px;
  font-size:1.8em;
}
/* 患者情報表示文字マージン設定 */
.header-text-margin {
  margin-left: 5px;
}

/* iPhone縦方向表示用 */
@media screen and (max-width: 380px ) {
  /* 患者ID、患者名表示部　*/
  .header-pat-info1 {
    width: 190px;
  }
  /* 患者情報表示部　*/
  .header-pat-info2{
    width: 115px;
  }
  /* 入院/外来　*/
  .inout {
    font-size:1.4em;
  }
  /* 性別、血液型、誕生日表示部 */
  .layoutbox {
    margin-top: 2px;
    font-size:1.2em;
  }
}

.fab-top-right {
  top: 10px;
  bottom: auto;
  right: 10px;
  left: auto;
  position: absolute;
}
.img-icon {
  width: 13%;
  height: auto;
  min-width: 20px;
  max-width: 60px;
}
.textitems {
  font-size: 24px;
}
</style>
