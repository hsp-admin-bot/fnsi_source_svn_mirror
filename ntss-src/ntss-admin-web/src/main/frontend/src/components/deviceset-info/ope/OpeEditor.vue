<template>
  <div v-if="deviceSetInfo !== null" class="device-info-container">
    <div class="device-info-content">
      <div class="device-info-content-area">
        <!-- ヘッダ -->
        <v-ons-row
          v-if="showButton"
          class="common-style-header device-info-main-title"
        >
          操作範囲
        </v-ons-row>
        <div class="device-info-main-content">
          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            血流量
          </v-ons-row>
          <!-- 項目 -->
          <!-- del MC対象のため、一時コメントアウト 趙 start -->
          <!-- add FNSI-No.ies477 操作範囲に表示項目を追加する 趙 start -->
          <!-- <v-ons-row class="device-info-cell" v-if="isPatRecord || isMstRecord">
            <v-ons-col class="device-info-cell-name">
              {{ devA[476].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <device-radio
                :ref="`radio1`"
                :device-info="devA[476]"
                :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)"
              />
              <br/>
              <br/>
              <device-input-number
                ref="required0"
                :device-info="devA[477]"
                :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)"
              />
            </v-ons-col>
          </v-ons-row> -->
          <!-- add FNSI-No.ies477 操作範囲に表示項目を追加する 趙 end-->
          <!-- del MC対象のため、一時コメントアウト 趙 end -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[179].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required1" -->
              <!--   :device-info="devA[179]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`血流量`)" -->
              <!-- /> -->
              <device-input-number
                ref="required1"
                :device-info="devA[179]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`血流量`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            除水
          </v-ons-row>
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[181].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required2`" -->
              <!--   :device-info="devA[181]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-input-number
                :ref="`required2`"
                :device-info="devA[181]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <!-- ラジオ -->
          <v-ons-row
            v-for="(device, index) in deviceValueRadios"
            :key="`radio1_${index}`"
            class="device-info-cell"
          >
            <v-ons-col class="device-info-cell-name">
              {{ device.formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   :ref="`radio1_${index}`" -->
              <!--   :device-info="device" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-radio
                :ref="`radio1_${index}`"
                :device-info="device"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <!-- ナンバー -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[39].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required3`" -->
              <!--   :device-info="devA[39]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-input-number
                :ref="`required3`"
                :device-info="devA[39]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            透析液
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[182].formLabel }}
            </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- 上限<device-input-number -->
                  <!--   :ref="`required4`" -->
                  <!--   :device-info="devA[182]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  上限<device-input-number
                    :ref="`required4`"
                    :device-info="devA[182]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- 下限<device-input-number -->
                  <!--   :ref="`required5`" -->
                  <!--   :device-info="devA[183]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  下限<device-input-number
                    :ref="`required5`"
                    :device-info="devA[183]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <!-- ラジオ -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[268].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio2" -->
              <!--   :device-info="devA[268]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-radio
                ref="radio2"
                :device-info="devA[268]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <!-- ナンバー -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[269].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required6`" -->
              <!--   :device-info="devA[269]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-input-number
                :ref="`required6`"
                :device-info="devA[269]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            シングルニードル(SN)
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[24].formLabel }}
            </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- 上限<device-input-number -->
                  <!--   :ref="`required7`" -->
                  <!--   :device-info="devA[24]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  上限<device-input-number
                    :ref="`required7`"
                    :device-info="devA[24]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- 下限<device-input-number -->
                  <!--   :ref="`required8`" -->
                  <!--   :device-info="devA[25]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  下限<device-input-number
                    :ref="`required8`"
                    :device-info="devA[25]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>

          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            TMP
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[241].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio3" -->
              <!--   :device-info="devA[241]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-radio
                ref="radio3"
                :device-info="devA[241]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            <v-ons-col class="device-info-cell-name" />
            <v-ons-col class="device-info-cell-value">
              補正警報上限
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              補正警報下限
            </v-ons-col>
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row
            v-for="(device, index) in deviceValue"
            :key="`key1_${index}`"
            class="device-info-cell"
          >
            <v-ons-col class="device-info-cell-name">
              {{ device.formLabel }}
            </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required9_${index}`" -->
                  <!--   :device-info="device.upData" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required9_${index}`"
                    :device-info="device.upData"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required10_${index}`" -->
                  <!--   :device-info="device.lowData" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required10_${index}`"
                    :device-info="device.lowData"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>

          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            補液設定
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              補液量設定値制限<br />(OHDF・OHF用)
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required11`" -->
              <!--   :device-info="devA[383]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-input-number
                :ref="`required11`"
                :device-info="devA[383]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <!-- ラジオ -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[389].formLabel }}<br />(OHDF・OHF用)
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   :key="countFlag" -->
              <!--   ref="radio4" -->
              <!--   :device-info="devA[389]" -->
              <!--   class="radio-area" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-radio
                :key="countFlag"
                ref="radio4"
                :device-info="devA[389]"
                class="radio-area"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <!-- ナンバー -->
          <v-ons-row v-show="isShowReplenisher" class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              補液比率
            </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <v-ons-col class="device-info-cell-value">
                  前補液
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required12`" -->
                  <!--   :device-info="devA[379]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required12`"
                    :device-info="devA[379]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col class="device-info-cell-value">
                  後補液
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required13`" -->
                  <!--   :device-info="devB[39]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required13`"
                    :device-info="devB[39]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[398].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required14`" -->
              <!--   :device-info="devA[398]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-input-number
                :ref="`required14`"
                :device-info="devA[398]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <!-- ラジオ -->
          <v-ons-row v-show="isShowQdQs" class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[369].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio5" -->
              <!--   :device-info="devA[369]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-radio
                ref="radio5"
                :device-info="devA[369]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <!-- ナンバー -->
          <v-ons-row v-show="isShowReplenisherFiltrat" class="device-info-cell">
            <v-ons-col class="device-info-cell-name"> 濾過率 </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <v-ons-col class="device-info-cell-value">
                  前補液
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required15`" -->
                  <!--   :device-info="devA[90]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!--   v-if="devA[90]" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required15`"
                    :device-info="devA[90]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                    v-if="devA[90]"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col class="device-info-cell-value">
                  後補液
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required16`" -->
                  <!--   :device-info="devB[40]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!--   v-if="devB[40]" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required16`"
                    :device-info="devB[40]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                    v-if="devB[40]"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <!-- ヘマトクリット（Ht） -->
<!--          <v-ons-row v-show="isShowHtTP" class="device-info-cell">-->
          <v-ons-row v-show="isShowHtTP" v-if="devA && devA[91]" class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[91].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 start -->
              <!-- <device-input-number
                :ref="`required17`"
                :device-info="devA[91]"
                :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)"
                @input="setHtExaminationDate()"
                @wheel.prevent="setHtExaminationDate()"
                @keydown.up.prevent="setHtExaminationDate()"
                @keydown.down.prevent="setHtExaminationDate()"
                @change="setDeviceInfoChange(`除水`)"
              /> -->
<!--              <device-input-number-->
<!--                :ref="`required17`"-->
<!--                :device-info="devA[91]"-->
<!--                :disabled="EditedHt.isEditedFlg"-->
<!--                :required="EditedHt.isRequired"-->
<!--                @input="setHtExaminationDate()"-->
<!--                @wheel.prevent="setHtExaminationDate()"-->
<!--                @keydown.up.prevent="setHtExaminationDate()"-->
<!--                @keydown.down.prevent="setHtExaminationDate()"-->
<!--                @change="setDeviceInfoChange(`除水`)"-->
<!--              />-->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--     :ref="`required17`" -->
              <!--     :device-info="devA[91]" -->
              <!--     :required="true" -->
              <!--     @input="setHtExaminationDate()" -->
              <!--     @wheel.prevent="setHtExaminationDate()" -->
              <!--     @keydown.up.prevent="setHtExaminationDate()" -->
              <!--     @keydown.down.prevent="setHtExaminationDate()" -->
              <!--     @change="setDeviceInfoChange(`除水`),changeHtExaminationDate()" -->
              <!-- /> -->
              <device-input-number
                :ref="`required17`"
                :device-info="devA[91]"
                :required="true"
                @input="setHtExaminationDate()"
                @wheel.prevent="setHtExaminationDate()"
                @change="setDeviceInfoChange(`除水`),changeHtExaminationDate()"
                :disabled="!getItemAuthorized('DevicesetInfo', 'default_authority') || getIsOtherFacility"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- mod #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 end -->
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- TODO: 検査日時(ヘマトクリット(Ht))参照：検査結果ＤＢテーブルがないため参照ができない。テーブル構成精査中 -->
              {{ HtExaminationDate }}
            </v-ons-col>
          </v-ons-row>

          <v-ons-row v-show="isShowHtTP" v-if="devA && devA[92]" class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              <!-- TODO: 検査日時(総タンパク(TP))参照：検査結果ＤＢテーブルがないため参照ができない。テーブル構成精査中 -->
              {{ devA[92].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 start -->
              <!-- <device-input-number
                :ref="`required19`"
                :device-info="devA[92]"
                :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)"
                @input="setTPExaminationDate()"
                @wheel.prevent="setTPExaminationDate()"
                @keydown.up.prevent="setTPExaminationDate()"
                @keydown.down.prevent="setTPExaminationDate()"
                @change="setDeviceInfoChange(`除水`)"
              /> -->
<!--              <device-input-number-->
<!--                :ref="`required19`"-->
<!--                :device-info="devA[92]"-->
<!--                :disabled="EditedTP.isEditedFlg"-->
<!--                :required="EditedTP.isRequired"-->
<!--                @input="setTPExaminationDate()"-->
<!--                @wheel.prevent="setTPExaminationDate()"-->
<!--                @keydown.up.prevent="setTPExaminationDate()"-->
<!--                @keydown.down.prevent="setTPExaminationDate()"-->
<!--                @change="setDeviceInfoChange(`除水`)"-->
<!--              />-->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--     :ref="`required19`" -->
              <!--     :device-info="devA[92]" -->
              <!--     :required="true" -->
              <!--     @input="setTPExaminationDate()" -->
              <!--     @wheel.prevent="setTPExaminationDate()" -->
              <!--     @keydown.up.prevent="setTPExaminationDate()" -->
              <!--     @keydown.down.prevent="setTPExaminationDate()" -->
              <!--     @change="setDeviceInfoChange(`除水`),changeTPExaminationDate()" -->
              <!-- /> -->
              <device-input-number
                :ref="`required19`"
                :device-info="devA[92]"
                :required="true"
                @input="setTPExaminationDate()"
                @wheel.prevent="setTPExaminationDate()"
                @change="setDeviceInfoChange(`除水`),changeTPExaminationDate()"
                :disabled="!getItemAuthorized('DevicesetInfo', 'default_authority') || getIsOtherFacility"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- mod #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 end -->
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              {{ TPexaminationDate }}
            </v-ons-col>
          </v-ons-row>
          <!-- タイトル -->
          <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
          <v-ons-row class="common-style-header device-info-cell-title" v-if="devA[472] != undefined || devA[473] != undefined || devA[474] != undefined || devA[475] != undefined">
            <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
            <v-ons-col class="device-info-cell-name">
              TMP補液制御<br />(OHDF・OHF用)
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              速度低下
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              速度復帰
            </v-ons-col>
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
            <v-ons-col class="device-info-cell-name" v-if="devA[472] != undefined || devA[473] != undefined">
              <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
              TMP閾値
            </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   v-if="devA[472] != undefined" -->
                  <!--   :ref="`required28`" -->
                  <!--   :device-info="devA[472]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @blur="validTmpInput(472)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    v-if="devA[472] != undefined"
                    :ref="`required28`"
                    :device-info="devA[472]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @blur="validTmpInput(472)"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
                </v-ons-col>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   v-if="devA[473] != undefined" -->
                  <!--   :ref="`required29`" -->
                  <!--   :device-info="devA[473]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @blur="validTmpInput(473)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    v-if="devA[473] != undefined"
                    :ref="`required29`"
                    :device-info="devA[473]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @blur="validTmpInput(473)"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="device-info-cell">
            <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
            <v-ons-col class="device-info-cell-name" v-if="devA[474] != undefined || devA[475] != undefined">
              <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
              速度変化率
            </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   v-if="devA[474] != undefined" -->
                  <!--   :ref="`required30`" -->
                  <!--   :device-info="devA[474]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    v-if="devA[474] != undefined"
                    :ref="`required30`"
                    :device-info="devA[474]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
                </v-ons-col>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   v-if="devA[475] != undefined" -->
                  <!--   :ref="`required31`" -->
                  <!--   :device-info="devA[475]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    v-if="devA[475] != undefined"
                    :ref="`required31`"
                    :device-info="devA[475]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            緊急補液
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[336].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required21`" -->
              <!--   :device-info="devA[336]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-input-number
                :ref="`required21`"
                :device-info="devA[336]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[337].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required22`" -->
              <!--   :device-info="devA[337]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-input-number
                :ref="`required22`"
                :device-info="devA[337]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            <!-- mod FutreNetWeb+SI課題管理No4183対応 趙 start-->
            <!-- <v-ons-col class="device-info-cell-name" /> -->
            <v-ons-col class="device-info-cell-name">
              補液速度
            </v-ons-col>
            <!-- mod FutreNetWeb+SI課題管理No4183対応 趙 end-->
            <v-ons-col class="device-info-cell-value">
              前補液
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              後補液
            </v-ons-col>
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row
            v-for="(device, index) in deviceMaxValue"
            :key="`key2_${index}`"
            class="device-info-cell"
          >
            <v-ons-col class="device-info-cell-name">
              {{ device.formLabel }}
            </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required23_${index}`" -->
                  <!--   :device-info="device.up" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required23_${index}`"
                    :device-info="device.up"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required24_${index}`" -->
                  <!--   :device-info="device.low" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required24_${index}`"
                    :device-info="device.low"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            AFBF設定
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[384].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio6" -->
              <!--   :device-info="devA[384]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-radio
                ref="radio6"
                :device-info="devA[384]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <!-- ナンバー -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[385].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required25`" -->
              <!--   :device-info="devA[385]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`除水`)" -->
              <!-- /> -->
              <device-input-number
                :ref="`required25`"
                :device-info="devA[385]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`除水`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[386].formLabel }}
            </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod FutreNetWeb+SI課題管理No4181対応 趙 start -->
                  <!-- <device-input-number
                    :ref="`required26`"
                    :device-info="devA[386]"
                    :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)"
                  /> -->
                  上限
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required26`" -->
                  <!--   :device-info="devA[386]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required26`"
                    :device-info="devA[386]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- mod FutreNetWeb+SI課題管理No4181対応 趙 end -->
                </v-ons-col>
                <v-ons-col class="device-info-cell-value">
                  <!-- mod FutreNetWeb+SI課題管理No4181対応 趙 start -->
                  <!-- <device-input-number
                    :ref="`required27`"
                    :device-info="devA[387]"
                    :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)"
                  /> -->
                  下限
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required27`" -->
                  <!--   :device-info="devA[387]" -->
                  <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
                  <!--   @input="setDeviceInfoChange(`血流量`)" -->
                  <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
                  <!--   @change="setDeviceInfoChange(`除水`)" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required27`"
                    :device-info="devA[387]"
                    :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                    @input="setDeviceInfoChange(`血流量`)"
                    @wheel.prevent="setDeviceInfoChange(`血流量`)"
                    @change="setDeviceInfoChange(`除水`)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- mod FutreNetWeb+SI課題管理No4181対応 趙 end -->
                </v-ons-col>
              </v-ons-row>
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
              :disabled="!getItemAuthorized('DevicesetInfo', 'default_authority') || getIsOtherFacility"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              {{ saveButtonLabel }}
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>

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
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
import { DEVICE_TYPE_OPE } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import {
  DATA_SOURCE_TYPE_MST,
  DATA_SOURCE_TYPE_PAT,
  DATA_SOURCE_TYPE_TREAT
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
// add 装置設定デフォルトマスタ DP=Qd+Qs(補液速度加算)、表示非表示設定 start
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import {REPLENISHER_QDQS_SETTING, REPLENISHER_CALCULATION_SETTING, REPLENISHER_FILTRATION_SETTING} from "@/constants/facilitySetting";
// add 装置設定デフォルトマスタ DP=Qd+Qs(補液速度加算)、表示非表示設定 end
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
import { EventBus } from "@/compat/vue/event-bus.js";
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
import dayjs from "@/compat/date/dayjs";
// add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

/**
 * @description 操作範囲設定値編集画面
 */
export default {
  mixins: [baseEditor],

  data() {
    return {
      deviceType: DEVICE_TYPE_OPE,
      // ヘマトクリット編集フラグ
      // isEditedHt: false,
      // 総タンパク編集フラグ
      // isEditedTP: false,
      // DP=Qd+Qs(補液速度加算)表示フラグ
      isShowQdQs: true,
      // 補液比率(前後補液)・補液計算優先項目の補液比率表示フラグ
      isShowReplenisher: true,
      // 補液計算-濾過率から算出有効化設定表示フラグ
      isShowReplenisherFiltrat: true,
      // ヘマトクリット・総タンパク表示フラグ
      isShowHtTP: true,
      // 内部【施設設定マスタ】NO113_装置設定マスタ设定后处理不正 start
      refreshArr: [],
      countFlag: 0
      // 内部【施設設定マスタ】NO113_装置設定マスタ设定后处理不正 start
    };
  },
  computed: {
    /**
     * @description クリップ式気泡検出器切りSW・除水計算選択・除水計算優先項目選択
     */
    deviceValueRadios() {
      return [this.devA[38], this.devA[21], this.devA[22]];
    },

    /**
     * @description 各装置設定
     */
    deviceValue() {
      return [
        {
          // TMP補正警報(HD)
          upData: this.devA[168],
          lowData: this.devA[169],
          formLabel: this.devA[168].formLabel
        },
        {
          // TMP補正警報(ECUM)
          upData: this.devA[171],
          lowData: this.devA[172],
          formLabel: this.devA[171].formLabel
        },
        {
          // TMP補正警報(HDF)
          upData: this.devA[174],
          lowData: this.devA[175],
          formLabel: this.devA[174].formLabel
        },
        {
          // TMP補正警報(HF)
          upData: this.devA[177],
          lowData: this.devA[178],
          formLabel: this.devA[177].formLabel
        },
        {
          // TMP補正警報(HD + 補液)
          upData: this.devB[37],
          lowData: this.devB[38],
          formLabel: this.devB[37].formLabel
        },
        {
          // TMP補正警報(OHDF)
          upData: this.devA[391],
          lowData: this.devA[392],
          formLabel: this.devA[391].formLabel
        },
        {
          // TMP補正警報(OHF)
          upData: this.devA[394],
          lowData: this.devA[395],
          formLabel: this.devA[394].formLabel
        }
      ];
    },

    /**
     * @description 各装置設定
     */
    deviceMaxValue() {
      return [
        {
          // 速度操作範囲上限(HDF)
          up: this.devA[185],
          low: this.devB[31],
          formLabel: this.devA[185].formLabel
        },
        {
          // 速度操作範囲上限(HF)
          up: this.devA[186],
          low: this.devB[32],
          formLabel: this.devA[186].formLabel
        },
        {
          // 速度操作範囲上限(HD+補液)
          up: this.devB[30],
          low: this.devB[33],
          formLabel: this.devB[30].formLabel
        },
        {
          // 速度操作範囲上限(OHDF)
          up: this.devA[396],
          low: this.devB[34],
          formLabel: this.devA[396].formLabel
        },
        {
          // 速度操作範囲上限(OHF)
          up: this.devA[397],
          low: this.devB[35],
          formLabel: this.devA[397].formLabel
        }
      ];
    },
    // add #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 start
    /**
     * @description ヘマトクリット検査日時
     */
    //  EditedHt() {
    //   if (this.devA[91].value.editValue !== undefined && this.devA[91].value.editValue !== null && this.devC[91].value.editValue !== "-") {
    //     return {
    //       // isEditedFlg: true,
    //       isRequired: false
    //     };
    //   } else {
    //     return {
    //       // isEditedFlg: false,
    //       isRequired: true
    //     };
    //   }
    // },

    /**
     * @description 総タンパク検査日時
     */
    // EditedTP() {
    //   if (this.devA[92].value.editValue !== undefined && this.devA[92].value.editValue !== null && this.devC[92].value.editValue !== "-") {
    //     return {
    //       // isEditedFlg: true,
    //       isRequired: false
    //     };
    //   } else {
    //     return {
    //       // isEditedFlg: false,
    //       isRequired: true
    //     };
    //   }
    // },
    // add #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 end
    /**
     * @description ヘマトクリット検査日時
     */
    HtExaminationDate() {
      // TODO: 表示形式： HH:MI
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      // return this.isEditedHt ? "-" : this.devC[91].value.editValue;
      // mod #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
      // return this.isEditedHt ? "-" : dayjs(this.devC[91].value.editValue, "YYYYMMDDHHmmss").format("YYYY/MM/DD HH:mm");
      return this.formatExamDate(this.devC[91]?.value?.editValue);
      // return !!this.devC[91] && this.devC[91].value.editValue === '-' ?
      //     this.devC[91].value.editValue : dayjs(this.devC[91].value.editValue, "YYYYMMDDHHmmss").format("YYYY/MM/DD HH:mm");
      // return this.isEditedHt ? "-" : this.devC[91].value.editValue === '-' ?
      //     this.devC[91].value.editValue : dayjs(this.devC[91].value.editValue, "YYYYMMDDHHmmss").format("YYYY/MM/DD HH:mm");
      // mod #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc emd
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    },

    /**
     * @description 総タンパク検査日時
     */
    TPexaminationDate() {
      // TODO: 表示形式：YYYY/MM/DD HH:MI
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //return this.isEditedTP ? "-" : this.devC[92].value.editValue;
      // mod #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
      // return this.isEditedTP ? "-" : dayjs(this.devC[92].value.editValue, "YYYYMMDDHHmmss").format("YYYY/MM/DD HH:mm");
      // return !!this.devC[92] && this.devC[92].value.editValue === '-' ?
      //     this.devC[92].value.editValue : dayjs(this.devC[92].value.editValue, "YYYYMMDDHHmmss").format("YYYY/MM/DD HH:mm");
      return this.formatExamDate(this.devC[92]?.value?.editValue);
      // return this.isEditedTP ? "-" : this.devC[92].value.editValue === '-' ?
      //     this.devC[92].value.editValue : dayjs(this.devC[92].value.editValue, "YYYYMMDDHHmmss").format("YYYY/MM/DD HH:mm");
      // mod #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    },
    isEditedHt(){
      return this.devA[91].value.initValue !== this.devA[91].value.editValue;
    },
    isEditedTP(){
      return this.devA[92].value.initValue !== this.devA[92].value.editValue;
    }
  },

  watch: {
    /**
     * @description 装置設定値
     * @summary ミックスインのcreatedでdeviceSetInfoに選択された各装置設定データが設定される
     */
    async deviceSetInfo() {
      // TODO: システム設定未実装のため、固定値
      // DP=Qd+Qs(補液速度加算)、表示非表示設定： システム設定ID121値：1「表示」、0「非表示」
      // mod 装置設定デフォルトマスタ DP=Qd+Qs(補液速度加算)、表示非表示設定 start
      // const systemQdQsSetting = 1;
      // this.isShowQdQs = systemQdQsSetting === 1;
      const facilityCd = this.getIsOtherFacility ? this.getOtherFacilityCd : this.facilityCd;
      // 他施設参照時は患者共有認可用に selectedPatId を付与
      const selectedPatId = this.getIsOtherFacility ? this.selectedPatId : undefined;
      await getMstFacilitySettingValue(facilityCd, REPLENISHER_QDQS_SETTING, selectedPatId)
        .then(response => {
          this.isShowQdQs = response.data === 1;
        });
      // mod 装置設定デフォルトマスタ DP=Qd+Qs(補液速度加算)、表示非表示設定 end

      // 補液比率(前後補液)・補液計算優先項目から補液比率、表示非表示設定： システム設定ID122値：1「表示」、0「非表示」
      await getMstFacilitySettingValue(facilityCd, REPLENISHER_CALCULATION_SETTING, selectedPatId)
        .then(response => {
          this.isShowReplenisher = response.data === 1;
        });
      //add補液計算-濾過率から算出有効化設定
      await getMstFacilitySettingValue(facilityCd, REPLENISHER_FILTRATION_SETTING, selectedPatId)
        .then(response => {
          this.isShowReplenisherFiltrat = response.data === 1;
        });
      this.$nextTick(function() {
        const replenisherCalcInfo = this.devA[389];
        // ビュー全体がレンダリングされた後にのみ実行されるコード
        if (!this.isShowReplenisher) {
          const options = replenisherCalcInfo.options.filter(
            item => item.radioValue !== "2");
          // 補液計算優先項目から補液比率のラジオボタンのみ非表示
          replenisherCalcInfo.options = options;
        }
        if (!this.isShowReplenisherFiltrat) {
          const options = replenisherCalcInfo.options.filter(
            item => item.radioValue !== "3");
          // 補液計算優先項目から濾過率から算出のラジオボタンのみ非表示
          replenisherCalcInfo.options = options;
        }
        // 内部【施設設定マスタ】NO113_装置設定マスタ设定后处理不正 start
        if (replenisherCalcInfo.options.length > 0) {
          this.refreshArr = []
          replenisherCalcInfo.options.forEach(element => {
            this.refreshArr.push(element.radioValue)
          });
          if (!this.refreshArr.includes(replenisherCalcInfo.value.editValue)) {
          replenisherCalcInfo.value.editValue = '0'
          replenisherCalcInfo.value.initValue = '0'
        } else {
          this.countFlag++
        }
        }
        // 内部【施設設定マスタ】NO113_装置設定マスタ设定后处理不正 end
      });

      // ヘマトクリット・総タンパク、表示非表示設定： システム設定ID130値：1「表示」、0「非表示」
      // const systemHtTPSetting = 1;
      this.isShowHtTP = this.isShowReplenisherFiltrat;
    }
  },

  methods: {
    formatExamDate(value) {
      if (value === "-" || value === null || value === undefined || value === "") {
        return "-";
      }
      const text = String(value);
      const formats = ["YYYYMMDDHHmmss", "YYYYMMDDHHmm"];
      for (const format of formats) {
        const parsed = dayjs(text, format, true);
        if (parsed.isValid()) {
          return parsed.format("YYYY/MM/DD HH:mm");
        }
      }
      return "-";
    },
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return !this.getIsOtherFacility && getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * @description ヘマトクリット編集されたフラグ設定
     */
    setHtExaminationDate() {
      // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20240312 ztc start
      this.changeHtExaminationDate();
      // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20240312 ztc end
      // this.isEditedHt = true;
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      this.setDeviceInfoChange();
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    },

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setDeviceInfoChange(itemName) {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc start
      // EventBus.$emit("deviceSetChanged");
      EventBus.$emit("deviceSetChanged", this.isEdited());
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc end
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

    /**
     * @description 総タンパク編集されたフラグ設定
     */
    setTPExaminationDate() {
      // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20240312 ztc start
      this.changeTPExaminationDate();
      // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20240312 ztc end
      // this.isEditedTP = true;
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      this.setDeviceInfoChange();
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    },
    /**
     * @description 入力時のバリデーション処理
     * @summary 入力警告時にモーダル表示、そのまま保存も可能
     */
    validTmpInput(key) {
      let fixedUpper = null;
      let fixedLower = null;
      let confUpper = null;
      let confLower = null;
      switch (this.dataSourceType) {
        case DATA_SOURCE_TYPE_MST:
          if (
            this.deviceSetInfoRaw &&
            this.deviceSetInfoRaw.pat &&
            this.deviceSetInfoRaw.pat.war &&
            this.deviceSetInfoRaw.pat.war.dev &&
            this.deviceSetInfoRaw.pat.war.dev.A) {
            const obj = this.deviceSetInfoRaw.pat.war.dev.A;
            fixedUpper = obj[132];
            fixedLower = obj[133];
            confUpper = obj[130];
            confLower = obj[131];
          }
          break;

        case DATA_SOURCE_TYPE_PAT:
          if (
            this.deviceSetInfoRaw &&
            this.deviceSetInfoRaw.war &&
            this.deviceSetInfoRaw.war.dev &&
            this.deviceSetInfoRaw.war.dev.A) {
            const obj = this.deviceSetInfoRaw.war.dev.A;
            fixedUpper = obj[132];
            fixedLower = obj[133];
            confUpper = obj[130];
            confLower = obj[131];
          }
          break;

        case DATA_SOURCE_TYPE_TREAT:
          // NOTE: ここには来ないはず、来た場合の取得元をしらべる
          break;
        default:
          throw new Error("データ取得元の指定が不正です");
      }
      let isShowDialog = false;
      let msg = "";

      // 速度低下
      const valueDown = this.devA[472].value.editValue;
      // 速度復帰
      const valueRepair = this.devA[473].value.editValue;
      if (valueDown < valueRepair) {
        isShowDialog = true;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // msg += "TMP閾値 速度低下の値が速度復帰の値未満です。<br />";
        msg += messageFormat(DIALOG_MESSAGES[12000098].message);
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }

      const value = this.devA[key].value.editValue;
      if (fixedUpper !== null && value > fixedUpper) {
        isShowDialog = true;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // msg += "TMP固定警報上限の範囲外です。<br />";
        msg += messageFormat(DIALOG_MESSAGES[12000099].message);
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (confUpper !== null && value > confUpper) {
        isShowDialog = true;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // msg += "TMP自動設定警報限界上限の範囲外です。<br />";
        msg += messageFormat(DIALOG_MESSAGES[12000100].message);
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (fixedLower !== null && value < fixedLower) {
        isShowDialog = true;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // msg += "TMP固定警報下限の範囲外です。<br />";
        msg += messageFormat(DIALOG_MESSAGES[12000101].message);
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (confLower !== null && value < confLower) {
        isShowDialog = true;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // msg += "TMP自動設定警報限界下限の範囲外です。<br />";
        msg += messageFormat(DIALOG_MESSAGES[12000102].message);
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (isShowDialog) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "設定値エラー",
          // message: msg + "入力を確認してください。"
          title: DIALOG_MESSAGES[12000097].title,
          message: messageFormat(DIALOG_MESSAGES[12000097].message, msg),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
      }
    },

    /**
     * @description 保存前のバリデーション処理
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateBeforeUpdating() {
      const messageCd = 50000002;
      if (this.devA[182].value.editValue < this.devA[183].value.editValue) {
        return {
          messageCd,
          stringParams: [this.devA[182].formName, this.devA[183].formName]
        };
      }
      if (this.devA[24].value.editValue < this.devA[25].value.editValue) {
        return {
          messageCd,
          stringParams: [this.devA[24].formName, this.devA[25].formName]
        };
      }
      // del MC対象のため、一時コメントアウト 趙 start
      // add FNSI-改修内容 操作範囲に表示項目を追加する 趙 start
      // if (this.devA[179].value.editValue < this.devA[477].value.editValue) {
      //   return {
      //     messageCd,
      //     stringParams: [this.devA[179].formName, this.devA[477].formName]
      //   };
      // }
      // add FNSI-改修内容 操作範囲に表示項目を追加する 趙 end
      // del MC対象のため、一時コメントアウト 趙 end
      return null;
    },
    changeHtExaminationDate(){
      if(this.isEditedHt){
        this.devC[91].value.editValue = '-';
      } else{
        this.devC[91].value.editValue = this.devC[91].value.initValue;
      }
    },
    changeTPExaminationDate(){
      if(this.isEditedTP){
        this.devC[92].value.editValue = '-';
      } else{
        this.devC[92].value.editValue = this.devC[92].value.initValue;
      }
    }
  }
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>
<style scoped>
.device-info-cell-name {
  flex: 0 0 45%;
}

.device-info-content {
  max-height: 630px;
  max-width: 580px;
}

.radio-area {
  /* mod FNSI-8034 補液計算優先項目の選択肢の並びが不正 劉 start */
  /* width: 265px; */
  /* mod FNSI-8148 劉全航 start */
  /* width: 18em; */
  display: grid;
  grid-template-columns: 8.6em 9.6em;
  /* mod FNSI-8148 劉全航 end */
  /* mod FNSI-8034補液計算優先項目の選択肢の並びが不正 劉 end */
  /* del FNSI-8148 劉全航 start */
  /* display: block; */
  /* del FNSI-8148 劉全航 end */
}
/* mod FNSI-8148 劉全航 start */
/* @media screen and (max-width: 670px) { */
@media screen and (max-width: 53em) {
  /* mod FNSI-8148 劉全航 end */
  /* スマホ用のCSS */
  .device-info-cell-value :deep(.custom-radio) {
    display: block;
  }
  .radio-area {
    width: 100%;
    /* add FNSI-8148 劉全航 start */
    display: block;
    /* add FNSI-8148 劉全航 end */
  }
}
.device-info-cell-value :deep(.custom-common-number-input-pro) {
  width: 6em;
}
</style>
