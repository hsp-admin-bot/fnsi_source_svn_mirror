<template>
  <div v-if="deviceSetInfo !== null" class="device-info-container">
    <div class="device-info-content">
      <div class="device-info-content-area">
        <v-ons-row
          v-if="showButton"
          class="common-style-header device-info-main-title"
        >
          血圧計
        </v-ons-row>
        <div class="device-info-main-content">
          <v-ons-row class="common-style-header device-info-cell-title">
            警報点設定
          </v-ons-row>

          <v-ons-row class="common-style-header device-info-cell-title">
            <v-ons-col />
            <v-ons-col class="device-info-cell-name">上限値</v-ons-col>
            <v-ons-col>下限値</v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">最高血圧</v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_最高血圧上限" -->
              <!--   :device-info="maxBloodPressure.upper" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
              <!-- /> -->
              <device-input-number
                ref="required_最高血圧上限"
                :device-info="maxBloodPressure.upper"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange('最高血圧上限')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_最高血圧下限" -->
              <!--   :device-info="maxBloodPressure.lower" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
              <!-- /> -->
              <device-input-number
                ref="required_最高血圧下限"
                :device-info="maxBloodPressure.lower"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange('最高血圧上限')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">最低血圧</v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_最低血圧上限" -->
              <!--   :device-info="minBloodPressure.upper" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
              <!-- /> -->
              <device-input-number
                ref="required_最低血圧上限"
                :device-info="minBloodPressure.upper"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange('最高血圧上限')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_最低血圧下限" -->
              <!--   :device-info="minBloodPressure.lower" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
              <!-- /> -->
              <device-input-number
                ref="required_最低血圧下限"
                :device-info="minBloodPressure.lower"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange('最高血圧上限')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">平均血圧</v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_平均血圧上限" -->
              <!--   :device-info="avgBloodPressure.upper" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
              <!-- /> -->
              <device-input-number
                ref="required_平均血圧上限"
                :device-info="avgBloodPressure.upper"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange('最高血圧上限')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_平均血圧下限" -->
              <!--   :device-info="avgBloodPressure.lower" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
              <!-- /> -->
              <device-input-number
                ref="required_平均血圧下限"
                :device-info="avgBloodPressure.lower"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange('最高血圧上限')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">脈拍数</v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_脈拍数上限" -->
              <!--   :device-info="pulseRate.upper" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
              <!-- /> -->
              <device-input-number
                ref="required_脈拍数上限"
                :device-info="pulseRate.upper"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange('最高血圧上限')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_脈拍数下限" -->
              <!--   :device-info="pulseRate.lower" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
              <!-- /> -->
              <device-input-number
                ref="required_脈拍数下限"
                :device-info="pulseRate.lower"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange('最高血圧上限')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="common-style-header device-info-cell-title">
            最高血圧警報との連動動作
          </v-ons-row>

          <v-ons-row class="common-style-header device-info-cell-title">
            <v-ons-col />
            <v-ons-col class="device-info-cell-name">上限値警報時</v-ons-col>
            <v-ons-col>下限値警報時</v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">血液ポンプ</v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod FNSI-改修内容 外結対応 趙 start -->
              <v-ons-row>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   ref="required_血液ポンプ上限" -->
                  <!--   :device-info="devA[227]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
                  <!-- /> -->
                  <device-input-number
                    ref="required_血液ポンプ上限"
                    :device-info="devA[227]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange('最高血圧上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-checkbox -->
                  <!--   ref="check1" -->
                  <!--   :device-info="devA[219]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @change="setDeviceInfoChange('血液ポンプ上限')" -->
                  <!-- /> -->
                  <device-checkbox
                    ref="check1"
                    :device-info="devA[219]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @change="setDeviceInfoChange('血液ポンプ上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <v-ons-row>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   ref="required_血液ポンプ下限" -->
                  <!--   :device-info="devA[228]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
                  <!-- /> -->
                  <device-input-number
                    ref="required_血液ポンプ下限"
                    :device-info="devA[228]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange('最高血圧上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-checkbox -->
                  <!--   ref="check2" -->
                  <!--   :device-info="devA[220]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @change="setDeviceInfoChange('血液ポンプ下限')" -->
                  <!-- /> -->
                  <device-checkbox
                    ref="check2"
                    :device-info="devA[220]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @change="setDeviceInfoChange('血液ポンプ下限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
              <!-- mod FNSI-改修内容 外結対応 趙 end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">除水ポンプ</v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod FNSI-改修内容 外結対応 趙 start -->
              <v-ons-row>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   ref="required_除水ポンプ上限" -->
                  <!--   :device-info="devA[229]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
                  <!-- /> -->
                  <device-input-number
                    ref="required_除水ポンプ上限"
                    :device-info="devA[229]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange('最高血圧上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-checkbox -->
                  <!--   ref="check3" -->
                  <!--   :device-info="devA[221]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @change="setDeviceInfoChange('除水ポンプ上限')" -->
                  <!-- /> -->
                  <device-checkbox
                    ref="check3"
                    :device-info="devA[221]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @change="setDeviceInfoChange('除水ポンプ上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <v-ons-row>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   ref="required_除水ポンプ下限" -->
                  <!--   :device-info="devA[230]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
                  <!-- /> -->
                  <device-input-number
                    ref="required_除水ポンプ下限"
                    :device-info="devA[230]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange('最高血圧上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-checkbox -->
                  <!--   ref="check4" -->
                  <!--   :device-info="devA[222]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @change="setDeviceInfoChange('除水ポンプ下限')" -->
                  <!-- /> -->
                  <device-checkbox
                    ref="check4"
                    :device-info="devA[222]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @change="setDeviceInfoChange('除水ポンプ下限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
              <!-- mod FNSI-改修内容 外結対応 趙 end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">Na注入ポンプ</v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod FNSI-改修内容 外結対応 趙 start -->
              <v-ons-row>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   ref="required_Na注入ポンプ上限" -->
                  <!--   :device-info="devA[231]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
                  <!-- /> -->
                  <device-input-number
                    ref="required_Na注入ポンプ上限"
                    :device-info="devA[231]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange('最高血圧上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-checkbox -->
                  <!--   ref="check5" -->
                  <!--   :device-info="devA[223]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @change="setDeviceInfoChange('Na注入ポンプ上限')" -->
                  <!-- /> -->
                  <device-checkbox
                    ref="check5"
                    :device-info="devA[223]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @change="setDeviceInfoChange('Na注入ポンプ上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <v-ons-row>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   ref="required_Na注入ポンプ下限" -->
                  <!--   :device-info="devA[232]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
                  <!-- /> -->
                  <device-input-number
                    ref="required_Na注入ポンプ下限"
                    :device-info="devA[232]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange('最高血圧上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-checkbox -->
                  <!--   ref="check6" -->
                  <!--   :device-info="devA[224]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @change="setDeviceInfoChange('Na注入ポンプ下限')" -->
                  <!-- /> -->
                  <device-checkbox
                    ref="check6"
                    :device-info="devA[224]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @change="setDeviceInfoChange('Na注入ポンプ下限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
              <!-- mod FNSI-改修内容 外結対応 趙 end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">補液ポンプ</v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod FNSI-改修内容 外結対応 趙 start -->
              <v-ons-row>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   ref="required_補液ポンプ上限" -->
                  <!--   :device-info="devA[233]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
                  <!-- /> -->
                  <device-input-number
                    ref="required_補液ポンプ上限"
                    :device-info="devA[233]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange('最高血圧上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-checkbox -->
                  <!--   ref="check7" -->
                  <!--   :device-info="devA[225]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @change="setDeviceInfoChange('補液ポンプ上限')" -->
                  <!-- /> -->
                  <device-checkbox
                    ref="check7"
                    :device-info="devA[225]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @change="setDeviceInfoChange('補液ポンプ上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <v-ons-row>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   ref="required_補液ポンプ下限" -->
                  <!--   :device-info="devA[234]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
                  <!-- /> -->
                  <device-input-number
                    ref="required_補液ポンプ下限"
                    :device-info="devA[234]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange('最高血圧上限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-checkbox -->
                  <!--   ref="check8" -->
                  <!--   :device-info="devA[226]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @change="setDeviceInfoChange('補液ポンプ下限')" -->
                  <!-- /> -->
                  <device-checkbox
                    ref="check8"
                    :device-info="devA[226]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @change="setDeviceInfoChange('補液ポンプ下限')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
              <!-- mod FNSI-改修内容 外結対応 趙 end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="common-style-header device-info-cell-title">
            血圧
          </v-ons-row>

          <v-ons-row
            v-for="(item, index) in bloodPressureDevInfoList"
            :key="index"
            class="device-info-cell"
          >
            <v-ons-col class="device-info-cell-name">
              {{ item.devInfo.formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   v-if="item.type === 'input'" -->
              <!--   :ref="`required_bp_${index}`" -->
              <!--   :device-info="item.devInfo" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--       @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--       @change="setDeviceInfoChange('最高血圧上限')" -->
              <!-- /> -->
              <device-input-number
                v-if="item.type === 'input'"
                :ref="`required_bp_${index}`"
                :device-info="item.devInfo"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange('最高血圧上限')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   v-else -->
              <!--   :ref="`radio_bp_${index}`" -->
              <!--   :device-info="item.devInfo" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`${ item.devInfo.formLabel }`)" -->
              <!-- /> -->
              <device-radio
                v-else
                :ref="`radio_bp_${index}`"
                :device-info="item.devInfo"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`${ item.devInfo.formLabel }`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
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
              :disabled="!getItemAuthorized('DevicesetInfo', 'default_authority')"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              {{ saveButtonLabel }}
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>

      <message-dialog
        :visible.sync="isDialogVisble"
        v-bind="dialogProps"
        type="1"
      />
      <message-dialog
        :visible.sync="isCancelDialogVisble"
        v-bind="dialogProps"
        type="2"
        @confirm="cancelEdit"
      />
      <message-dialog
        :visible.sync="isUpdateAllPatDialogVisble"
        v-bind="dialogProps"
        type="5"
        @confirm="setUpdateAllPatFlg"
      />
    </div>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper.js";
import { DEVICE_TYPE_BP } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
import { mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

/**
 * @classdesc 上下限値情報クラス
 */
class ValidationInfo {
  /**
   * @constructor
   * @param {String}  name 項目名称
   * @param {Object}  upperDevInfo 上限の装置設定値オブジェクト
   * @param {Object}  lowerDevInfo 下限の装置設定値オブジェクト
   * @param {Number}  minValue 最小値
   * @param {Number}  maxValue 最大値
   * @param {boolean} isZeroSet 0許容(0設定可能)フラグ
   */
  constructor(name, upperDevInfo, lowerDevInfo, minValue, maxValue, isZeroSet) {
    this.name = name;
    this.upper = upperDevInfo.value.editValue;
    this.lower = lowerDevInfo.value.editValue;
    this.min = minValue;
    this.max = maxValue;
    this.isZeroSet = isZeroSet;
  }
}

/**
 * @description 血圧計設定値編集画面
 */
export default {
  mixins: [baseEditor],

  data() {
    return {
      deviceType: DEVICE_TYPE_BP,
      mstMachine: null
    };
  },

  computed: {
    ...mapGetters("master-maintenance", ["getEditRecord"]),
    ...mapGetters("pat-info", ["getIsOtherFacility", "getOtherFacilityCd"]),
    /**
     * @description 最高血圧
     */
    maxBloodPressure() {
      return {
        upper: this.devA[211],
        lower: this.devA[212],
        min: 40,
        max: this.isChildCuff ? 120 : 250
      };
    },

    /**
     * @description 最低血圧
     */
    minBloodPressure() {
      return {
        upper: this.devA[213],
        lower: this.devA[214],
        min: this.isChildCuff ? 20 : 40,
        max: this.isChildCuff ? 90 : 200
      };
    },

    /**
     * @description 平均血圧
     */
    avgBloodPressure() {
      return {
        upper: this.devA[215],
        lower: this.devA[216],
        min: this.isChildCuff ? 30 : 40,
        max: this.isChildCuff ? 100 : 235
      };
    },

    /**
     * @description 脈拍数
     */
    pulseRate() {
      return {
        upper: this.devA[217],
        lower: this.devA[218],
        min: 40,
        max: this.isChildCuff ? 240 : 200
      };
    },

    /**
     * @description 昇圧値
     */
    voltageBoost() {
      return this.devA[192];
    },

    /**
     * @description 血液カフ幼児フラグ
     */
    isChildCuff() {
      return this.devA[191].value.editValue === "1";
    },

    /**
     * @description 「血圧」項目のv-forループ用リスト
     */
    bloodPressureDevInfoList() {
      return [
        { devInfo: this.devA[191], type: "radio" },
        { devInfo: this.devA[190], type: "input" },
        { devInfo: this.devA[192], type: "input" },
        { devInfo: this.devA[193], type: "radio" },
        { devInfo: this.devA[195], type: "radio" },
        { devInfo: this.devA[239], type: "radio" },
        { devInfo: this.devA[194], type: "radio" },
        { devInfo: this.devA[235], type: "input" },
        { devInfo: this.devA[236], type: "input" },
        { devInfo: this.devA[237], type: "radio" },
        { devInfo: this.devA[238], type: "radio" }
      ];
    },

    /**
     * @description 上下限値バリデーション用リスト
     * @summary バリデーションをループで済ませられるように上下限を持つ項目の設定値を格納している
     * @returns {Object}
     */
    validationList() {
      return [
        new ValidationInfo(
          "最高血圧",
          this.maxBloodPressure.upper,
          this.maxBloodPressure.lower,
          this.maxBloodPressure.min,
          this.maxBloodPressure.max,
          true
        ),
        new ValidationInfo(
          "最低血圧",
          this.minBloodPressure.upper,
          this.minBloodPressure.lower,
          this.minBloodPressure.min,
          this.minBloodPressure.max,
          true
        ),
        new ValidationInfo(
          "平均血圧",
          this.avgBloodPressure.upper,
          this.avgBloodPressure.lower,
          this.avgBloodPressure.min,
          this.avgBloodPressure.max,
          false
        ),
        new ValidationInfo(
          "脈拍数",
          this.pulseRate.upper,
          this.pulseRate.lower,
          this.pulseRate.min,
          this.pulseRate.max,
          true
        )
      ];
    },

    hasZeroSetRecord() {
      // FNW外部設計書「ただし、装置マスタに機種「通信共通(V4.0)」の装置が存在する場合のみ、0を設定可能とする。」
      // 医器工V4(通信共通(V4.0))「学会定数: "V"」
      const zeroSetRecord = "V";
      const record = this.mstMachine.find(
        record => record.comFormatCd === zeroSetRecord
      );
      return record !== undefined;
    }
  },

  async created() {
    const response = await ApiHelper.get(
      `/bed_layout/mst_machine/${this.facilityCd}`
    ).catch((error) => {
      //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
      getErrorMessage('BloodPressureEditor.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
      // console.log(error);
    });
    this.mstMachine = response.data;
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setDeviceInfoChange(itemName) {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc start
      // EventBus.$emit("deviceSetChanged");
      EventBus.$emit("deviceSetChanged", this.isEdited());
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc end
    },
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start

    /**
     * @description 保存前のバリデーション処理
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateBeforeUpdating() {
      let msgObj;

      // 成人/幼児で上下限値が変わる項目のバリデーション
      for (const item of this.validationList) {
        /*
          上限値チェック
         */
        const upperName = `${item.name}(上限)`;
        // 最小値を下回っていないか
        msgObj = this.validateMinValue(
          item.upper,
          item.min,
          upperName,
          item.isZeroSet && this.hasZeroSetRecord
        );
        if (msgObj !== null) {
          return msgObj;
        }
        // 最大値を上回っていないか
        msgObj = this.validateMaxValue(item.upper, item.max, upperName);
        if (msgObj !== null) {
          return msgObj;
        }

        /*
          下限値チェック
         */
        const lowerName = `${item.name}(下限)`;
        // 最小値を下回っていないか
        msgObj = this.validateMinValue(item.lower, item.min, lowerName, true);
        if (msgObj !== null) {
          return msgObj;
        }
        // 最大値を上回っていないか
        msgObj = this.validateMaxValue(item.lower, item.max, lowerName);
        if (msgObj !== null) {
          return msgObj;
        }

        /*
          上限値 ≧ 下限値 チェック
         */
        msgObj = this.validateUpperLowerValue(
          item.upper,
          item.lower,
          item.name
        );
        if (msgObj !== null) {
          return msgObj;
        }
      }

      // 血圧自動測定間隔
      const interval = this.devA[190].value.editValue;
      msgObj = this.validateMinValue(
        interval,
        2,
        "血圧自動測定間隔",
        this.hasZeroSetRecord
      );
      if (msgObj !== null) {
        return msgObj;
      }

      // 昇圧値
      const voltageBoostValue = this.voltageBoost.value.editValue;
      const voltageBoostMin = this.isChildCuff ? 80 : 120;
      const voltageBoostMax = this.isChildCuff ? 140 : 220;
      msgObj = this.validateMinValue(
        voltageBoostValue,
        voltageBoostMin,
        "昇圧値",
        false
      );
      if (msgObj !== null) {
        return msgObj;
      }
      msgObj = this.validateMaxValue(
        voltageBoostValue,
        voltageBoostMax,
        "昇圧値"
      );
      if (msgObj !== null) {
        return msgObj;
      }

      return null;
    },

    /**
     * @description 最小値のバリデーション
     * @summary 設定値が最小値を下回るときダイアログを表示
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateMinValue(editValue, minValue, itemName, isZeroSet) {
      // 設定値<最小値 か判定フラグ
      let isValidate = false;

      if (isZeroSet) {
        // 平均血圧上限以外の場合(0許容、0設定可能)
        if (editValue !== 0 && editValue < minValue) isValidate = true;
      } else {
        // 平均血圧上限の場合(0許容しない)
        if (editValue < minValue) isValidate = true;
      }

      // returnのパラメータ作成
      const confirmMessage = isValidate
        ? { messageCd: 50000003, stringParams: [itemName, `${minValue}`] }
        : null;
      return confirmMessage;
    },

    /**
     * @description 最大値のバリデーション
     * @summary 設定値が最大値を上回るときダイアログを表示
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateMaxValue(value, maxValue, itemName) {
      // TODO: FNW外部設計書「ただし、装置マスタに機種「通信共通(V4.0)」の装置が存在する場合のみ、0を設定可能とする。」
      if (value !== 0 && value > maxValue) {
        return {
          messageCd: 50000004,
          stringParams: [itemName, `${maxValue}`]
        };
      }
      return null;
    },

    /**
     * @description 「上限 ≧ 下限」のバリデーション
     * @summary 設定値が「上限 ≧ 下限」でないときダイアログを表示
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateUpperLowerValue(upperValue, lowerValue, itemName) {
      if (upperValue < lowerValue) {
        return {
          messageCd: 50000001,
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
.device-info-content {
  max-height: 630px;
}

@media print {
  .device-input-number >>> .custom-input-number {
    width: 4.5em;
  }
  .device-input-number {
    white-space: nowrap;
  }
  /* 3列以上あるときだけ適用 */
  ons-row > ons-col:first-child:nth-last-child(n+3) {
    flex: 0 0 18%;
  }
  /* 3列以上あるときの残り */
  ons-row > ons-col:first-child:nth-last-child(n+3) ~ ons-col {
    flex: 1 1 0;
  }
}
</style>
