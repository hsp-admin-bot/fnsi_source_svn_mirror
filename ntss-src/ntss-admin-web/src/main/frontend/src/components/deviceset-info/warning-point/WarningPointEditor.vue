<template>
  <div v-if="deviceSetInfo !== null" class="device-info-container">
    <div class="device-info-content">
      <div class="device-info-content-area">
        <v-ons-row
          v-if="showButton"
          class="common-style-header device-info-main-title"
        >
          警報点
        </v-ons-row>
        <div class="device-info-main-content">
          <!-- TMP監視 -->
          <div class="device-info-tmp-monitor">
            <v-ons-row class="common-style-header device-info-cell-title">
              TMP監視モード
            </v-ons-row>
            <v-ons-row class="device-info-cell">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   :ref="`radio_TMP監視`" -->
              <!--   :device-info="tmpMode" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`TMP監視モード`)" -->
              <!-- /> -->
              <device-radio
                :ref="`radio_TMP監視`"
                :device-info="tmpMode"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`TMP監視モード`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-row>
          </div>

          <!-- ヘッダー部 -->
          <div class="device-info-header">
            <!-- ヘッダー１ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col class="common-style-header device-info-cell-title">
                警報点設定
              </v-ons-col>
              <v-ons-col
                class="common-style-header device-info-cell-name flex-area"
              />
              <v-ons-col
                class="common-style-header device-info-cell-value sab-title"
              >
                自動設定警報幅(mmHg)
              </v-ons-col>
              <v-ons-col
                class="common-style-header device-info-cell-value sab-title"
              >
                自動設定警報限界値(mmHg)
              </v-ons-col>
              <v-ons-col
                class="common-style-header device-info-cell-value sab-title"
              >
                固定警報点(mmHg)
              </v-ons-col>
              <v-ons-col
                class="common-style-header device-info-cell-value sab-title"
              >
                自動追従警報幅(mmHg)
              </v-ons-col>
            </v-ons-row>

            <!-- ヘッダー２ -->
            <v-ons-row class="device-info-cell-bottom">
              <v-ons-col class="common-style-header device-info-cell-title" />
              <v-ons-col
                class="common-style-header device-info-cell-name flex-area"
              />
              <v-ons-col class="common-style-header device-info-cell-name">
                上限値
              </v-ons-col>
              <v-ons-col class="common-style-header device-info-cell-value">
                下限値
              </v-ons-col>
              <v-ons-col class="common-style-header device-info-cell-name">
                上限値
              </v-ons-col>
              <v-ons-col class="common-style-header device-info-cell-value">
                下限値
              </v-ons-col>
              <v-ons-col class="common-style-header device-info-cell-name">
                上限値
              </v-ons-col>
              <v-ons-col class="common-style-header device-info-cell-value">
                下限値
              </v-ons-col>
              <v-ons-col class="common-style-header device-info-cell-name">
                上限値
              </v-ons-col>
              <v-ons-col class="common-style-header device-info-cell-value">
                下限値
              </v-ons-col>
            </v-ons-row>
          </div>

          <!-- データ部 -->
          <div id="device-info">
            <!-- 列１ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              >
                HD/ECUM
              </v-ons-col>
              <v-ons-col class="device-info-cell-name flex-area">
                静脈圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_静脈圧1" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[100]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧1`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_静脈圧1"
                  class="monitoring-enable"
                  :device-info="devA[100]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧1`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_静脈圧2" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[101]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧2`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_静脈圧2"
                  class="monitoring-enable"
                  :device-info="devA[101]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧2`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_静脈圧3" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[102]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧3`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_静脈圧3"
                  class="monitoring-enable"
                  :device-info="devA[102]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧3`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_静脈圧4" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[103]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧4`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_静脈圧4"
                  class="monitoring-enable"
                  :device-info="devA[103]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧4`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_静脈圧5" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[104]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧5`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_静脈圧5"
                  class="monitoring-enable"
                  :device-info="devA[104]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧5`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_静脈圧6" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[105]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧6`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_静脈圧6"
                  class="monitoring-enable"
                  :device-info="devA[105]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧6`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列２ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">
                ﾀﾞｲｱﾗｲｻﾞ入口圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_ダイアライザ1" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[152]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_ダイアライザ1"
                  class="monitoring-enable"
                  :device-info="devA[152]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_ダイアライザ2" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[153]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_ダイアライザ2"
                  class="monitoring-enable"
                  :device-info="devA[153]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_ダイアライザ3" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[154]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_ダイアライザ3"
                  class="monitoring-enable"
                  :device-info="devA[154]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_ダイアライザ4" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[155]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_ダイアライザ4"
                  class="monitoring-enable"
                  :device-info="devA[155]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_ダイアライザ5" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[156]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_ダイアライザ5"
                  class="monitoring-enable"
                  :device-info="devA[156]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_ダイアライザ6" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[157]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_ダイアライザ6"
                  class="monitoring-enable"
                  :device-info="devA[157]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列３ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">
                液圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_液圧1" -->
                <!--   :class="monitoringEnableLiquidPressure" -->
                <!--   :device-info="devA[112]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_液圧1"
                  :class="monitoringEnableLiquidPressure"
                  :device-info="devA[112]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_液圧2" -->
                <!--   :class="monitoringEnableLiquidPressure" -->
                <!--   :device-info="devA[113]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_液圧2"
                  :class="monitoringEnableLiquidPressure"
                  :device-info="devA[113]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_液圧3" -->
                <!--   :class="monitoringEnableLiquidPressure" -->
                <!--   :device-info="devA[114]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_液圧3"
                  :class="monitoringEnableLiquidPressure"
                  :device-info="devA[114]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_液圧4" -->
                <!--   :class="monitoringEnableLiquidPressure" -->
                <!--   :device-info="devA[115]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_液圧4"
                  :class="monitoringEnableLiquidPressure"
                  :device-info="devA[115]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_液圧5" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[116]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_液圧5"
                  class="monitoring-enable"
                  :device-info="devA[116]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_液圧6" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[117]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_液圧6"
                  class="monitoring-enable"
                  :device-info="devA[117]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列４ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">TMP</v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_TMP1" -->
                <!--   :class="monitoringEnableAutoConfig" -->
                <!--   :device-info="devA[128]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_TMP1"
                  :class="monitoringEnableAutoConfig"
                  :device-info="devA[128]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_TMP2" -->
                <!--   :class="monitoringEnableAutoConfig" -->
                <!--   :device-info="devA[129]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_TMP2"
                  :class="monitoringEnableAutoConfig"
                  :device-info="devA[129]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_TMP3" -->
                <!--   :class="monitoringEnableAutoTrackingConfig" -->
                <!--   :device-info="devA[130]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_TMP3"
                  :class="monitoringEnableAutoTrackingConfig"
                  :device-info="devA[130]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_TMP4" -->
                <!--   :class="monitoringEnableAutoTrackingConfig" -->
                <!--   :device-info="devA[131]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_TMP4"
                  :class="monitoringEnableAutoTrackingConfig"
                  :device-info="devA[131]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_TMP5" -->
                <!--   :class="monitoringEnableAutoTrackingConfig" -->
                <!--   :device-info="devA[132]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_TMP5"
                  :class="monitoringEnableAutoTrackingConfig"
                  :device-info="devA[132]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_TMP6" -->
                <!--   :class="monitoringEnableAutoTrackingConfig" -->
                <!--   :device-info="devA[133]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_TMP6"
                  :class="monitoringEnableAutoTrackingConfig"
                  :device-info="devA[133]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_TMP7" -->
                <!--   :class="monitoringEnableAutoTracking" -->
                <!--   :device-info="devA[126]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_TMP7"
                  :class="monitoringEnableAutoTracking"
                  :device-info="devA[126]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_TMP8" -->
                <!--   :class="monitoringEnableAutoTracking" -->
                <!--   :device-info="devA[127]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_TMP8"
                  :class="monitoringEnableAutoTracking"
                  :device-info="devA[127]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
            </v-ons-row>

            <!-- 列５ -->
            <v-ons-row class="device-info-cell-bottom">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">
                差圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_差圧1" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[146]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_差圧1"
                  class="monitoring-enable"
                  :device-info="devA[146]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_差圧2" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[147]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_差圧2"
                  class="monitoring-enable"
                  :device-info="devA[147]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_差圧5" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[148]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_差圧5"
                  class="monitoring-enable"
                  :device-info="devA[148]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_差圧6" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[149]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_差圧6"
                  class="monitoring-enable"
                  :device-info="devA[149]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列６ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              >
                HDF/HF
              </v-ons-col>
              <v-ons-col class="device-info-cell-name flex-area">
                静脈圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_静脈圧1" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[106]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_静脈圧1"
                  class="monitoring-enable"
                  :device-info="devA[106]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_静脈圧2" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[107]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_静脈圧2"
                  class="monitoring-enable"
                  :device-info="devA[107]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列７ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">
                ﾀﾞｲｱﾗｲｻﾞ入口圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_ダイアライザ1" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[158]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_ダイアライザ1"
                  class="monitoring-enable"
                  :device-info="devA[158]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_ダイアライザ2" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[159]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_ダイアライザ2"
                  class="monitoring-enable"
                  :device-info="devA[159]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列８ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">
                液圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_液圧1" -->
                <!--   :class="monitoringEnableLiquidPressure" -->
                <!--   :device-info="devA[118]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_液圧1"
                  :class="monitoringEnableLiquidPressure"
                  :device-info="devA[118]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_液圧2" -->
                <!--   :class="monitoringEnableLiquidPressure" -->
                <!--   :device-info="devA[119]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_液圧2"
                  :class="monitoringEnableLiquidPressure"
                  :device-info="devA[119]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列９ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">TMP</v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_TMP1" -->
                <!--   :class="monitoringEnableAutoConfig" -->
                <!--   :device-info="devA[136]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_TMP1"
                  :class="monitoringEnableAutoConfig"
                  :device-info="devA[136]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_TMP2" -->
                <!--   :class="monitoringEnableAutoConfig" -->
                <!--   :device-info="devA[137]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_TMP2"
                  :class="monitoringEnableAutoConfig"
                  :device-info="devA[137]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_TMP3" -->
                <!--   :class="monitoringEnableAutoTracking" -->
                <!--   :device-info="devA[134]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_TMP3"
                  :class="monitoringEnableAutoTracking"
                  :device-info="devA[134]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_TMP4" -->
                <!--   :class="monitoringEnableAutoTracking" -->
                <!--   :device-info="devA[135]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_TMP4"
                  :class="monitoringEnableAutoTracking"
                  :device-info="devA[135]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
            </v-ons-row>

            <!-- 列１０ -->
            <v-ons-row class="device-info-cell-bottom">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">
                差圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_差圧1" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[150]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_差圧1"
                  class="monitoring-enable"
                  :device-info="devA[150]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_HDF_差圧2" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[151]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_HDF_差圧2"
                  class="monitoring-enable"
                  :device-info="devA[151]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列１１ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              >
                シングルニードル
              </v-ons-col>
              <v-ons-col class="device-info-cell-name flex-area">
                静脈圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_静脈圧1" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[110]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_静脈圧1"
                  class="monitoring-enable"
                  :device-info="devA[110]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_静脈圧2" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[111]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_静脈圧2"
                  class="monitoring-enable"
                  :device-info="devA[111]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列１２ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">
                ﾀﾞｲｱﾗｲｻﾞ入口圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_ダイアライザ1" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[162]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_ダイアライザ1"
                  class="monitoring-enable"
                  :device-info="devA[162]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_ダイアライザ2" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[163]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_ダイアライザ2"
                  class="monitoring-enable"
                  :device-info="devA[163]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列１３ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">
                液圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_液圧1" -->
                <!--   :class="monitoringEnableLiquidPressure" -->
                <!--   :device-info="devA[120]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_液圧1"
                  :class="monitoringEnableLiquidPressure"
                  :device-info="devA[120]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_液圧2" -->
                <!--   :class="monitoringEnableLiquidPressure" -->
                <!--   :device-info="devA[121]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_液圧2"
                  :class="monitoringEnableLiquidPressure"
                  :device-info="devA[121]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_液圧3" -->
                <!--   :class="monitoringEnableLiquidPressure" -->
                <!--   :device-info="devA[122]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_液圧3"
                  :class="monitoringEnableLiquidPressure"
                  :device-info="devA[122]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_液圧4" -->
                <!--   :class="monitoringEnableLiquidPressure" -->
                <!--   :device-info="devA[123]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_液圧4"
                  :class="monitoringEnableLiquidPressure"
                  :device-info="devA[123]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_液圧5" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[124]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_液圧5"
                  class="monitoring-enable"
                  :device-info="devA[124]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_液圧6" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[125]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_液圧6"
                  class="monitoring-enable"
                  :device-info="devA[125]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列１４ -->
            <v-ons-row class="device-info-cell-bottom">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">TMP</v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_TMP1" -->
                <!--   :class="monitoringEnableAutoConfig" -->
                <!--   :device-info="devA[140]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_TMP1"
                  :class="monitoringEnableAutoConfig"
                  :device-info="devA[140]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_TMP2" -->
                <!--   :class="monitoringEnableAutoConfig" -->
                <!--   :device-info="devA[141]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_TMP2"
                  :class="monitoringEnableAutoConfig"
                  :device-info="devA[141]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_TMP3" -->
                <!--   :class="monitoringEnableAutoTrackingConfig" -->
                <!--   :device-info="devA[142]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_TMP3"
                  :class="monitoringEnableAutoTrackingConfig"
                  :device-info="devA[142]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_TMP4" -->
                <!--   :class="monitoringEnableAutoTrackingConfig" -->
                <!--   :device-info="devA[143]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_TMP4"
                  :class="monitoringEnableAutoTrackingConfig"
                  :device-info="devA[143]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
            <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_TMP5" -->
                <!--   :class="monitoringEnableAutoTrackingConfig" -->
                <!--   :device-info="devA[144]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_TMP5"
                  :class="monitoringEnableAutoTrackingConfig"
                  :device-info="devA[144]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_TMP6" -->
                <!--   :class="monitoringEnableAutoTrackingConfig" -->
                <!--   :device-info="devA[145]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_TMP6"
                  :class="monitoringEnableAutoTrackingConfig"
                  :device-info="devA[145]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_TMP7" -->
                <!--   :class="monitoringEnableAutoTracking" -->
                <!--   :device-info="devA[138]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_TMP7"
                  :class="monitoringEnableAutoTracking"
                  :device-info="devA[138]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_SN_TMP8" -->
                <!--   :class="monitoringEnableAutoTracking" -->
                <!--   :device-info="devA[139]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_SN_TMP8"
                  :class="monitoringEnableAutoTracking"
                  :device-info="devA[139]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
            </v-ons-row>

            <!-- 列１５ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              >
                透析準備
              </v-ons-col>
              <v-ons-col class="device-info-cell-name flex-area">
                静脈圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_透析準備_静脈圧1" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[108]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_透析準備_静脈圧1"
                  class="monitoring-enable"
                  :device-info="devA[108]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_透析準備_静脈圧2" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[109]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_透析準備_静脈圧2"
                  class="monitoring-enable"
                  :device-info="devA[109]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列１６ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">
                ﾀﾞｲｱﾗｲｻﾞ入口圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_透析準備_ダイアライザ1" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[160]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_透析準備_ダイアライザ1"
                  class="monitoring-enable"
                  :device-info="devA[160]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_透析準備_ダイアライザ2" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[161]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_透析準備_ダイアライザ2"
                  class="monitoring-enable"
                  :device-info="devA[161]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>

            <!-- 列１７ -->
            <!--mod FNSI-改修内容redmain6221 任 start-->
            <!--<v-ons-row class="device-info-cell-bottom">-->
            <v-ons-row class="device-info-cell-bottom device-info-cell-new">
              <!--mod FNSI-改修内容redmain6221 任 end-->
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell-name"
              />
              <v-ons-col class="device-info-cell-name flex-area">
                Na濃度(mEq/L)
              </v-ons-col>
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_Na1" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[254]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_Na1"
                  class="monitoring-enable"
                  :device-info="devA[254]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_Na2" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[255]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_Na2"
                  class="monitoring-enable"
                  :device-info="devA[255]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
              <v-ons-col class="device-info-cell-name">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_Na3" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[256]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_Na3"
                  class="monitoring-enable"
                  :device-info="devA[256]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_Na4" -->
                <!--   class="monitoring-enable" -->
                <!--   :device-info="devA[257]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @input="setDeviceInfoChange(`血流量`)" -->
                <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-input-number
                  ref="required_Na4"
                  class="monitoring-enable"
                  :device-info="devA[257]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @input="setDeviceInfoChange(`血流量`)"
                  @wheel.prevent="setDeviceInfoChange(`血流量`)"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-name" />
              <v-ons-col class="device-info-cell-value" />
            </v-ons-row>
          </div>

          <!-- 自動設定警報監視有無 -->
          <div class="auto-alert-setting-header">
            <v-ons-row class="common-style-header device-info-cell-title device-info-cell-bottom">
              自動設定警報監視有無
            </v-ons-row>
          </div>

          <div>
            <v-ons-row class="device-info-cell-bottom auto-alert-setting">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell auto-alert-cell-title"
              >
                静脈圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name auto-alert-cell">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-radio -->
                <!--   ref="radio_静脈圧" -->
                <!--   :device-info="devA[242]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-radio
                  ref="radio_静脈圧"
                  :device-info="devA[242]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell auto-alert-cell-title"
              >
                透析液圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name auto-alert-cell">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-radio -->
                <!--   ref="radio_透析液圧" -->
                <!--   :device-info="devA[244]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-radio
                  ref="radio_透析液圧"
                  :device-info="devA[244]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell auto-alert-cell-title"
              >
                差圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name auto-alert-cell">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-radio -->
                <!--   ref="radio_差圧" -->
                <!--   :device-info="devA[246]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-radio
                  ref="radio_差圧"
                  :device-info="devA[246]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
            </v-ons-row>

            <v-ons-row class="device-info-cell-bottom auto-alert-setting">
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell auto-alert-cell-title"
              >
                ﾀﾞｲｱﾗｲｻﾞ入口圧
              </v-ons-col>
              <v-ons-col class="device-info-cell-name auto-alert-cell">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-radio -->
                <!--   ref="radio_入口圧" -->
                <!--   :device-info="devA[243]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-radio
                  ref="radio_入口圧"
                  :device-info="devA[243]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell auto-alert-cell-title"
              >
                TMP
              </v-ons-col>
              <v-ons-col class="device-info-cell-name auto-alert-cell">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-radio -->
                <!--   ref="radio_TMP" -->
                <!--   :device-info="devA[245]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-radio
                  ref="radio_TMP"
                  :device-info="devA[245]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
              <v-ons-col
                class="common-style-header device-info-cell-title device-info-cell auto-alert-cell-title"
              >
                Na濃度
              </v-ons-col>
              <v-ons-col class="device-info-cell-name auto-alert-cell">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-radio -->
                <!--   ref="radio_Na" -->
                <!--   :device-info="devA[247]" -->
                <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                <!--   @change="setDeviceInfoChange(`静脈圧`)" -->
                <!-- /> -->
                <device-radio
                  ref="radio_Na"
                  :device-info="devA[247]"
                  :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                  @change="setDeviceInfoChange(`静脈圧`)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
            </v-ons-row>
          </div>
        </div>

        <v-ons-row v-if="showButton" class="button-area">
          <v-ons-col class="button-cancel">
            <v-ons-button
              class="common-style-cancel-button"
              @click="cancelConfirm()"
            >
              {{ cancelButtonLabel }}
            </v-ons-button>
          </v-ons-col>
          <v-ons-col class="button-ok">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   v-if="!isTreatRecord" -->
            <!--   class="common-style-ok-button" -->
            <!--   @click="saveConfirm()" -->
            <!-- > -->
            <v-ons-button
              v-if="!isTreatRecord"
              class="common-style-ok-button"
              @click="saveConfirm()"
              :disabled="!getItemAuthorized('DevicesetInfo', 'default_authority') || getIsOtherFacility"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              {{ saveButtonLabel }}
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>

        <message-dialog
          v-model:visible="isDialogVisble"
          v-bind="dialogProps"
          type="1"
        />
        <message-dialog
          v-model:visible="isCancelDialogVisble"
          v-bind="dialogProps"
          type="2"
          @confirm="cancelEdit"
        />
        <message-dialog
          v-model:visible="isUpdateAllPatDialogVisble"
          v-bind="dialogProps"
          type="5"
          @confirm="setUpdateAllPatFlg"
        />
      </div>
    </div>
  </div>
</template>

<script>
  // add #10359 編集権限の動作不正 dengshen start
  import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  // add #10359 編集権限の動作不正 dengshen end
  import {DEVICE_TYPE_WAR} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
  import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
  import { EventBus } from "@/compat/vue/event-bus.js";
  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

  /**
 * @classdesc 警報点情報クラス
 */
class WarningPointInfo {
  /**
   * @constructor
   * @param {String} name 警報点名称
   * @param {Object} upperDevInfo 警報点上限の装置設定値オブジェクト
   * @param {Object} lowerDevInfo 警報点下限の装置設定値オブジェクト
   */
  constructor(name, upperDevInfo, lowerDevInfo) {
    this.name = name;
    this.upper = upperDevInfo.value.editValue;
    this.lower = lowerDevInfo.value.editValue;
  }
}

/**
 * @description 警報点設定値編集画面
 */
export default {
  mixins: [baseEditor],

  data() {
    return {
      deviceType: DEVICE_TYPE_WAR
    };
  },

  computed: {
    /**
     * @description TMP監視モード
     */
    tmpMode() {
      return this.devA[240];
    },

    /**
     * @description TMP監視モード設定値
     */
    tmpModeValue() {
      return this.tmpMode.value.editValue;
    },

    /**
     * @description TMP監視モード:TMP自動追従のとき有効色となるclassオブジェクト
     */
    monitoringEnableAutoTracking() {
      return {
        "monitoring-enable": this.tmpModeValue === "0"
      };
    },

    /**
     * @description TMP監視モード:TMP自動設定のとき有効色となるclassオブジェクト
     */
    monitoringEnableAutoConfig() {
      return {
        "monitoring-enable": this.tmpModeValue === "1"
      };
    },

    /**
     * @description TMP監視モード:透析液圧のとき有効色となるclassオブジェクト
     */
    monitoringEnableLiquidPressure() {
      return {
        "monitoring-enable": this.tmpModeValue === "2"
      };
    },

    /**
     * @description TMP監視モード:TMP自動追従/TMP自動設定のとき有効色となるclassオブジェクト
     */
    monitoringEnableAutoTrackingConfig() {
      return {
        "monitoring-enable":
          this.tmpModeValue === "0" || this.tmpModeValue === "1"
      };
    },

    /**
     * @description 上下限値バリデーション用リスト
     * @summary バリデーションをループで済ませられるようにカテゴリ1/2ごとの警報点設定値を格納している
     * @returns {Object}
     */
    validationList() {
      // カテゴリ1名称
      const hd = "HD/ECUM";
      const hdf = "HDF/HF";
      const sn = "シングルニードル";
      const preparation = "透析準備";

      // カテゴリ2名称
      const vein = "静脈圧";
      const dialyzer = "ダイアライザ入口圧";
      const liquid = "液圧";
      const tmp = "TMP";
      const difference = "差圧";

      // 警報点名称
      const configWidth = "自動設定警報幅";
      const configLimit = "自動設定警報限界値";
      const fixedPoint = "固定警報点";
      const tracking = "自動追従警報幅";

      return {
        [hd]: {
          [vein]: [
            new WarningPointInfo(configWidth, this.devA[100], this.devA[101]),
            new WarningPointInfo(configLimit, this.devA[102], this.devA[103]),
            new WarningPointInfo(fixedPoint, this.devA[104], this.devA[105])
          ],
          [dialyzer]: [
            new WarningPointInfo(configWidth, this.devA[152], this.devA[153]),
            new WarningPointInfo(configLimit, this.devA[154], this.devA[155]),
            new WarningPointInfo(fixedPoint, this.devA[156], this.devA[157])
          ],
          [liquid]: [
            new WarningPointInfo(configWidth, this.devA[112], this.devA[113]),
            new WarningPointInfo(configLimit, this.devA[114], this.devA[115]),
            new WarningPointInfo(fixedPoint, this.devA[116], this.devA[117])
          ],
          [tmp]: [
            new WarningPointInfo(configWidth, this.devA[128], this.devA[129]),
            new WarningPointInfo(configLimit, this.devA[130], this.devA[131]),
            new WarningPointInfo(fixedPoint, this.devA[132], this.devA[133]),
            new WarningPointInfo(tracking, this.devA[126], this.devA[127])
          ],
          [difference]: [
            new WarningPointInfo(configWidth, this.devA[146], this.devA[147]),
            new WarningPointInfo(fixedPoint, this.devA[148], this.devA[149])
          ]
        },

        [hdf]: {
          [vein]: [
            new WarningPointInfo(configWidth, this.devA[106], this.devA[107])
          ],
          [dialyzer]: [
            new WarningPointInfo(configWidth, this.devA[158], this.devA[159])
          ],
          [liquid]: [
            new WarningPointInfo(configWidth, this.devA[118], this.devA[119])
          ],
          [tmp]: [
            new WarningPointInfo(configWidth, this.devA[136], this.devA[137]),
            new WarningPointInfo(tracking, this.devA[134], this.devA[135])
          ],
          [difference]: [
            new WarningPointInfo(configWidth, this.devA[150], this.devA[151])
          ]
        },

        [sn]: {
          [vein]: [
            new WarningPointInfo(fixedPoint, this.devA[110], this.devA[111])
          ],
          [dialyzer]: [
            new WarningPointInfo(fixedPoint, this.devA[162], this.devA[163])
          ],
          [liquid]: [
            new WarningPointInfo(configWidth, this.devA[120], this.devA[121]),
            new WarningPointInfo(configLimit, this.devA[122], this.devA[123]),
            new WarningPointInfo(fixedPoint, this.devA[124], this.devA[125])
          ],
          [tmp]: [
            new WarningPointInfo(configWidth, this.devA[140], this.devA[141]),
            new WarningPointInfo(configLimit, this.devA[142], this.devA[143]),
            new WarningPointInfo(fixedPoint, this.devA[144], this.devA[145]),
            new WarningPointInfo(tracking, this.devA[138], this.devA[139])
          ]
        },

        [preparation]: {
          [vein]: [
            new WarningPointInfo(fixedPoint, this.devA[108], this.devA[109])
          ],
          [dialyzer]: [
            new WarningPointInfo(fixedPoint, this.devA[160], this.devA[161])
          ]
        }
      };
    }
  },

  methods: {
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return !this.getIsOtherFacility && getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setDeviceInfoChange(itemName) {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc start
      // EventBus.$emit("deviceSetChanged");
      EventBus.$emit("deviceSetChanged", this.isEdited());
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc end
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

    /**
     * @description 保存前のバリデーション処理
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateBeforeUpdating() {
      let msgObj;
      // バリデーション用リストからカテゴリ1を取り出す
      for (const category1 in this.validationList) {
        // カテゴリ1からカテゴリ2を取り出す
        for (const category2 in this.validationList[category1]) {
          // カテゴリ2から各警報点を取り出す
          for (const value of this.validationList[category1][category2]) {
            msgObj = this.validateUpperLowerValue(
              value.upper,
              value.lower,
              `${category1} ${category2} ${value.name}`);
            if (msgObj !== null) {
              return msgObj;
            }
          }
        }
      }

      // Na濃度にはカテゴリ2がないので個別にバリデーション
      msgObj = this.validateUpperLowerValue(
        this.devA[254].value.editValue,
        this.devA[255].value.editValue,
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"Na濃度 自動設定警報幅"*/
        "準備回収 Ｎａ濃度 自動設定警報幅"
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */);
      if (msgObj !== null) {
        return msgObj;
      }
      msgObj = this.validateUpperLowerValue(
        this.devA[256].value.editValue,
        this.devA[257].value.editValue,
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"Na濃度 固定警報点"*/
        "準備回収 Ｎａ濃度 固定警報点"
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */);
      if (msgObj !== null) {
        return msgObj;
      }

      return null;
    },

    /**
     * @description 「上限 > 下限」のバリデーション
     * @summary 設定値が「上限 > 下限」でないときダイアログを表示
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateUpperLowerValue(upperValue, lowerValue, itemName) {
      if (upperValue <= lowerValue) {
        return {
          messageCd: 50000005,
          stringParams: [`${itemName}`]
        };
      }
      return null;
    }
  }
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>
<style scoped>
.device-info-header {
  position: -webkit-sticky;
  position: sticky;
  top: 0px;
  z-index: 2;
}

.device-info-cell-title {
  position: -webkit-sticky;
  position: sticky;
  background-image: none;
  /*mod FNSI-改修内容4194 任 start*/
  /*left: 5px;*/
  left: 0px;
  /*mod FNSI-改修内容4194 任 end*/
  z-index: 1;
}

.device-info-tmp-monitor .device-info-cell-title
{
  background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}

.flex-area {
  position: -webkit-sticky;
  position: sticky;
  left: 10%;
  z-index: 1;
  background-image: none;
}

.device-info-main-content {
  overflow: visible;
}

.device-info-content {
  max-height: 630px;
  max-width: 500px;
}

.device-info-container {
  height: var(--height);
  width: var(--width);
}

/* .monitoring-enable :deep(.custom-input-number){
  background-color: lightskyblue;
} */

.device-info-cell-sab-title {
  border-bottom: solid 1px var(--ntss-border-color);
  border-top: none;
}

.device-info-cell {
  border-bottom: none;
}

.device-info-cell-bottom {
  border: solid 1px var(--ntss-border-color);
  border-top: none;
}
/*add FNSI-改修内容redmain6221 任 start*/
.device-info-cell-new {
  border-top: solid 1px var(--ntss-border-color) !important;
}
/*add FNSI-改修内容redmain6221 任 end*/

.device-info-cell-title {
  flex: 0 0 11%;
  word-break: break-all;
}

/* 中央線 ※テーマで色切り替え */
.device-info-cell-value {
  border-right: solid 1px var(--ntss-border-color);
}
/*add FNSI-改修内容redmain6221 任 start*/
.device-info-cell-none {
  border-right: none;
}
/*add FNSI-改修内容redmain6221 任 end*/

.flex-area {
  flex: 0 0 15%;
}

 
/* カスタム系スタイル指定 */
.device-input-number :deep(.custom-input-number),
.device-input-time :deep(.custom-input-time) {
  /* mod FutreNetWeb+SI課題管理No3897対応 趙 start*/
  /* width: 45px; */
  /*mod FNSI-改修内容4371 任 start*/
  /*mod #4371-文字サイズを特大にすると一部設定値が見切れる 徐博 start*/
  /*width: 50px;*/
  width: 4em;
  /*mod #4371-文字サイズを特大にすると一部設定値が見切れる 徐博 end*/
  /*width: 60px;*/
  /*mod FNSI-改修内容4371 任 end*/
  /* mod FutreNetWeb+SI課題管理No3897対応 趙 end*/
}

/* スマホ用 */
@media screen and (max-width: 450px) {
  .device-info-cell :deep(.custom-radio) {
    display: -webkit-box;
  }
}
/*add FNSI-改修内容4194 任 start*/
.device-info-content-area {
  padding: 5px 5px 5px 0 !important;
}
/*add FNSI-改修内容4194 任 end*/

/* ウィンドウ幅1170px以下の時に適用 */
@media screen and (max-width: 1170px) {
/* ウィンドウ幅を狭めると文字サイズによって(特大など)レイアウトが崩れ始める。
   レイアウト崩れの回避と見出し文言改行とのバランスを加味し、1170pxを境界値とし横スクロールを発生させる。 */
  .device-info-container {
    width: 1015px;       /* 横スクロールを発生させる為、コンテナ幅を固定 */
  }
  .flex-area {
    left: 111px;         /* コンテナ幅固定に伴い、表示位置調整 */
    background-color: var(--ntss-base-background-color);
  }
  .common-style-header {
    background-color: var(--ntss-header-background-color);
    color: var(--ntss-header-color);
  }
  .auto-alert-cell-title {
    position: static;    /* stickyを解除し、通常の位置付けに戻す */
    left: auto;          /* leftの0pxを解除し、初期値に戻す */
    z-index: auto;       /* z-indexを解除し、初期状態に戻す */
  }
}

@media print {
  /** ヘッダを折り返して横を収める */
  .device-info-cell-title {
    flex: 0 0 8%;
  }
  .flex-area {
    flex: 0 0 11%;
  }
  /** 数値IFの固定幅解除 */
  .device-input-number :deep(.custom-input-number){
    width: 100%;
  }
}
</style>
