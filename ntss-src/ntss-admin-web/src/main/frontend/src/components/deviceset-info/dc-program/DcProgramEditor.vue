<template>
  <div class="dc-program"
    v-if="deviceSetInfo !== null"
    :class="showButton ? 'device-info-container' : null"
  >
    <div class="device-info-content" :class="isUnderIndModal">
      <div class="device-info-content-area">
        <!-- ヘッダ -->
        <v-ons-row
          v-if="showButton"
          class="common-style-header device-info-main-title"
        >
          透析液濃度プログラム
        </v-ons-row>
        <v-ons-row v-else class="device-info-main-title" />
        <div>
          <!-- 項目 -->
          <div class="device-area">
            <v-ons-row class="device-info-cell device-info-left">
              <v-ons-col class="device-info-cell-value">
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                <!-- <device-select
                  ref="select1"
                  :device-info="devA[340]"
                  :disabled="isTreatRecord"
                  id="dcSwitch"
                  @change="changeButton(false)"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-select -->
                <!--   ref="select1" -->
                <!--   :device-info="devA[340]" -->
                <!--   :disabled="isTreatRecord" -->
                <!--   id="dcSwitch" -->
                <!-- /> -->
                <device-select
                  ref="select1"
                  :device-info="devA[340]"
                  :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  id="dcSwitch"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                <div>
                  B液濃度プログラム
                </div>
              </v-ons-col>
              <v-ons-col class="device-info-cell-value device-info-cell-rigth">
                ＵＦＲプロ連動
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                <!-- <device-radio
                  ref="radio1"
                  :device-info="devA[368]"
                  :disabled="isTreatRecord"
                  @change="changeButton(false)"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-radio -->
                <!--   ref="radio1" -->
                <!--   :device-info="devA[368]" -->
                <!--   :disabled="isTreatRecord" -->
                <!-- /> -->
                <device-radio
                  ref="radio1"
                  :device-info="devA[368]"
                  :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                <div>
                  コース
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                  <!-- <device-input-number
                    ref="required_number1"
                    :device-info="devA[364]"
                    :disabled="isTreatRecord"
                    @change="changeButton(false)"
                    @input="setInputNumberChange"
                    @wheel.prevent="setInputNumberChange"
                    @keydown.up.prevent="setInputNumberChange"
                    @keydown.down.prevent="setInputNumberChange"
                  /> -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   ref="required_number1" -->
                  <!--   :device-info="devA[364]" -->
                  <!--   :disabled="isTreatRecord" -->
                  <!--   @input="setInputNumberChange" -->
                  <!--   @wheel.prevent="setInputNumberChange" -->
                  <!--   @keydown.up.prevent="setInputNumberChange" -->
                  <!--   @keydown.down.prevent="setInputNumberChange" -->
                  <!-- /> -->
                  <device-input-number
                    ref="required_number1"
                    :device-info="devA[364]"
                    :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                    @input="setInputNumberChange"
                    @wheel.prevent="setInputNumberChange"
                    @keydown.up.prevent="setInputNumberChange"
                    @keydown.down.prevent="setInputNumberChange"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                </div>
              </v-ons-col>
            </v-ons-row>
            <!-- グラフ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col>
                <dc-program-chart
                  :mode="chartDataB.mode"
                  :data="chartDataB"
                  :class="isUnderSubModal"
                  :height="175"
                  :width="610"
                />
              </v-ons-col>
            </v-ons-row>
            <!-- 項目 -->
            <!-- mod FNSI-濃度プログラムの修正 楊 start -->
            <!--<v-ons-row class="device-info-cell device-setting-area">
              <v-ons-col
                v-for="(device, index) in stepUpperValueB"
                :key="`key1_${index}`"
                class="device-info-cell-value"
              >
                <device-input-number
                  :ref="`required1_${index}`"
                  :device-info="device"
                  class="device-input-charts"
                  :disabled="isTreatRecord || devA[340].value.editValue === '3'"
                />
              </v-ons-col>
            </v-ons-row> -->
            <!-- mod FNSI-濃度プログラムの修正 楊 end -->

            <v-ons-row class="device-info-cell device-setting-area">
              <v-ons-col
                v-for="(device, index) in stepLowerValueB"
                :key="`key2_${index}`"
                class="device-info-cell-value"
              >
               <!-- mod FNSI-濃度プログラムの修正 楊 start -->
               <!-- <device-input-number
                  :ref="`required2_${index}`"
                  :device-info="device"
                  class="device-input-charts"
                  :disabled="isTreatRecord || devA[340].value.editValue === '3'"
                /> -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                <!-- <device-input-number
                  :ref="`required2_${index}`"
                  :device-info="device"
                  class="device-input-charts"
                  :disabled="isTreatRecord || devA[340].value.editValue === '3'"
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   :ref="`required2_${index}`" -->
                <!--   :device-info="device" -->
                <!--   class="device-input-charts" -->
                <!--   :disabled="isTreatRecord || devA[340].value.editValue === '3'" -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  :ref="`required2_${index}`"
                  :device-info="device"
                  class="device-input-charts"
                  :disabled="isTreatRecord || devA[340].value.editValue === '3' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                <!-- mod FNSI-濃度プログラムの修正 楊 end -->
              </v-ons-col>
            </v-ons-row>
            <v-ons-row class="device-info-cell device-info-left">
              <v-ons-col class="device-info-cell-value">
                <!-- mod FNSI-濃度プログラムの修正 楊 start -->
                <!-- <device-input-number
                  ref="required_number2"
                  :device-info="devA[365]"
                  :disabled="
                    isTreatRecord ||
                      devA[340].value.editValue === '1' ||
                      devA[340].value.editValue === '2'
                  "
                /> -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                <!-- <device-input-number
                  ref="required_number2"
                  :device-info="devA[365]"
                  :disabled="
                    isTreatRecord ||
                      devA[340].value.editValue === '2'
                  "
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_number2" -->
                <!--   :device-info="devA[365]" -->
                <!--   :disabled=" -->
                <!--     isTreatRecord || -->
                <!--       devA[340].value.editValue === '2' -->
                <!--   " -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  ref="required_number2"
                  :device-info="devA[365]"
                  :disabled="isTreatRecord || devA[340].value.editValue === '2' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                <!-- mod FNSI-濃度プログラムの修正 楊 end -->

                開始
              </v-ons-col>
              <v-ons-col class="device-info-cell-value device-info-cell-rigth">
                終了
                <!-- mod FNSI-濃度プログラムの修正 楊 start -->
                <!--<device-input-number
                  ref="required_number3"
                  :device-info="devA[366]"
                  :disabled="
                    isTreatRecord ||
                      devA[340].value.editValue === '1' ||
                      devA[340].value.editValue === '2'
                  "
                /> -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                <!-- <device-input-number
                  ref="required_number3"
                  :device-info="devA[366]"
                  :disabled="
                    isTreatRecord ||
                      devA[340].value.editValue === '2'
                  "
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_number3" -->
                <!--   :device-info="devA[366]" -->
                <!--   :disabled=" -->
                <!--     isTreatRecord || -->
                <!--       devA[340].value.editValue === '2' -->
                <!--   " -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  ref="required_number3"
                  :device-info="devA[366]"
                  :disabled="isTreatRecord || devA[340].value.editValue === '2' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                <!-- mod FNSI-濃度プログラムの修正 楊 end -->
              </v-ons-col>
            </v-ons-row>
          </div>

          <div class="device-area">
            <v-ons-row class="device-info-cell device-info-left">
              <v-ons-col class="device-info-cell-value">
                <br />
                <div>
                  透析液濃度プログラム
                </div>
              </v-ons-col>
              <v-ons-col class="device-info-cell-value device-info-cell-rigth">
                工程切替時間
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                <!-- <device-input-number
                  ref="required_number4"
                  :device-info="devA[367]"
                  :disabled="isTreatRecord"
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_number4" -->
                <!--   :device-info="devA[367]" -->
                <!--   :disabled="isTreatRecord" -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  ref="required_number4"
                  :device-info="devA[367]"
                  :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                <div>
                  コース
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                  <!-- <device-input-number
                    ref="required_number5"
                    :device-info="devA[361]"
                    :disabled="isTreatRecord"
                    @change="changeButton(false)"
                    @input="setInputNumberChange"
                    @wheel.prevent="setInputNumberChange"
                    @keydown.up.prevent="setInputNumberChange"
                    @keydown.down.prevent="setInputNumberChange"
                  /> -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   ref="required_number5" -->
                  <!--   :device-info="devA[361]" -->
                  <!--   :disabled="isTreatRecord" -->
                  <!--   @input="setInputNumberChange" -->
                  <!--   @wheel.prevent="setInputNumberChange" -->
                  <!--   @keydown.up.prevent="setInputNumberChange" -->
                  <!--   @keydown.down.prevent="setInputNumberChange" -->
                  <!-- /> -->
                  <device-input-number
                    ref="required_number5"
                    :device-info="devA[361]"
                    :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                    @input="setInputNumberChange"
                    @wheel.prevent="setInputNumberChange"
                    @keydown.up.prevent="setInputNumberChange"
                    @keydown.down.prevent="setInputNumberChange"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                </div>
              </v-ons-col>
            </v-ons-row>
            <!-- グラフ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col>
                <dc-program-chart
                  :mode="chartDataA.mode"
                  :data="chartDataA"
                  :class="isUnderSubModal"
                  :height="175"
                  :width="610"
                />
              </v-ons-col>
            </v-ons-row>
            <!-- 項目 -->
            <!-- mod FNSI-濃度プログラムの修正 楊 start -->
            <!--<v-ons-row class="device-info-cell device-setting-area">
              <v-ons-col
                v-for="(device, index) in stepUpperValueA"
                :key="`key3_${index}`"
                class="device-info-cell-value"
              >
                <device-input-number
                  :ref="`required3_${index}`"
                  :device-info="device"
                  class="device-input-charts"
                  :disabled="
                    isTreatRecord ||
                      devA[340].value.editValue === '1' ||
                      devA[340].value.editValue === '3'
                  "
                />
              </v-ons-col>
            </v-ons-row> -->
            <!-- mod FNSI-濃度プログラムの修正 楊 end -->
            <v-ons-row class="device-info-cell device-setting-area">
              <v-ons-col
                v-for="(device, index) in stepLowerValueA"
                :key="`key4_${index}`"
                class="device-info-cell-value"
              >
                <!-- mod FNSI-濃度プログラムの修正 楊 start -->
                <!--<device-input-number
                  :ref="`required4_${index}`"
                  :device-info="device"
                  class="device-input-charts"
                  :disabled="isTreatRecord || devA[340].value.editValue === '3'"
                /> -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                <!-- <device-input-number
                  :ref="`required4_${index}`"
                  :device-info="device"
                  class="device-input-charts"
                  :disabled="isTreatRecord || devA[340].value.editValue === '3'"
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   :ref="`required4_${index}`" -->
                <!--   :device-info="device" -->
                <!--   class="device-input-charts" -->
                <!--   :disabled="isTreatRecord || devA[340].value.editValue === '3'" -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  :ref="`required4_${index}`"
                  :device-info="device"
                  class="device-input-charts"
                  :disabled="isTreatRecord || devA[340].value.editValue === '3' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                <!-- mod FNSI-濃度プログラムの修正 楊 end -->
              </v-ons-col>
            </v-ons-row>
            <v-ons-row class="device-info-cell device-info-left">
              <v-ons-col class="device-info-cell-value">
                <!-- mod FNSI-濃度プログラムの修正 楊 start -->
                <!--<device-input-number
                  ref="required_number6"
                  :device-info="devA[362]"
                  :disabled="
                    isTreatRecord ||
                      devA[340].value.editValue === '1' ||
                      devA[340].value.editValue === '2'
                  "
                /> -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                <!-- <device-input-number
                  ref="required_number6"
                  :device-info="devA[362]"
                  :disabled="
                    isTreatRecord ||
                      devA[340].value.editValue === '2'
                  "
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_number6" -->
                <!--   :device-info="devA[362]" -->
                <!--   :disabled=" -->
                <!--     isTreatRecord || -->
                <!--       devA[340].value.editValue === '2' -->
                <!--   " -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  ref="required_number6"
                  :device-info="devA[362]"
                  :disabled="isTreatRecord || devA[340].value.editValue === '2' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                <!-- mod FNSI-濃度プログラムの修正 楊 end -->
                開始
              </v-ons-col>
              <v-ons-col class="device-info-cell-value device-info-cell-rigth">
                終了
                <!-- mod FNSI-濃度プログラムの修正 楊 start -->
                <!-- <device-input-number
                  ref="required_number7"
                  :device-info="devA[363]"
                  :disabled="
                    isTreatRecord ||
                      devA[340].value.editValue === '1' ||
                      devA[340].value.editValue === '2'
                  "
                /> -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                <!-- <device-input-number
                  ref="required_number7"
                  :device-info="devA[363]"
                  :disabled="
                    isTreatRecord ||
                      devA[340].value.editValue === '2'
                  "
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_number7" -->
                <!--   :device-info="devA[363]" -->
                <!--   :disabled=" -->
                <!--     isTreatRecord || -->
                <!--       devA[340].value.editValue === '2' -->
                <!--   " -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  ref="required_number7"
                  :device-info="devA[363]"
                  :disabled="isTreatRecord || devA[340].value.editValue === '2' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                <!-- mod FNSI-濃度プログラムの修正 楊 end -->
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
            <!--   @click="save()" -->
            <!-- > -->
            <v-ons-button
              v-if="!isTreatRecord"
              class="common-style-ok-button"
              @click="save()"
              :disabled="!getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
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
        @confirm="saveEdit"
      />
      <message-dialog
        :visible.sync="isCancelDialogVisble"
        v-bind="dialogProps"
        type="2"
        @confirm="cancelEdit"
      />
    </div>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import {deepCopy, getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapActions, mapGetters } from "vuex";
import {
  DEVICE_TYPE_DC,
  DATA_SOURCE_TYPE_ORD
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
import DcProgramChart from "@/components/deviceset-info/dc-program/DcProgramChart.vue";
// mod FNSI-濃度プログラムチェックの追加 楊 start
import { EventBus } from "@/eventBus.js";
// mod FNSI-濃度プログラムチェックの追加 楊 end
import { ApiHelper } from "@/apis/AxiosHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";

/**
 * @description 透析液濃度プログラム設定値編集画面
 */
export default {
  components: {
    // highcharts: Chart,
    "dc-program-chart": DcProgramChart
  },

  mixins: [baseEditor],

  props: {
    // add #10359 編集権限の動作不正 dengshen start
    isMst: {
      type: Boolean,
      default: false
    },
    // add #10359 編集権限の動作不正 dengshen end
    // キャンセル・保存ボタン表示用
    showButton: {
      type: Boolean,
      default: true
    }
  },

  data() {
    return {
      deviceType: DEVICE_TYPE_DC,

      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add start
      initModelValueDevA:undefined,
      initModelValueDevB:undefined,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add end
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      devADefault: {},
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    };

  },

  computed: {
    // add FNSI-濃度プログラムチェックの追加 楊 start
    // ...mapGetters("pat-viewer-modal", ["getSettingIndChildData"]),
    ...mapGetters("pat-viewer-modal", ["getSettingIndChildData", "getIsShowDialysateProgramModal"]),
    // add FNSI-濃度プログラムチェックの追加 楊 end
    ...mapGetters("user", ["getFacilityCd"]),

    chartDataB() {
      let mode = 0;

      const stepUpperValueB = this.stepUpperValueB.map(item => {
        return item ? parseFloat(item.value.editValue) : {};
      });
      const stepLowerValueB = this.stepLowerValueB.map(item => {
        return item ? parseFloat(item.value.editValue) : {};
      });
      switch (parseInt(this.devA[340].value.editValue)) {
        case 2:
        // del FNSI-濃度プログラムチェックの追加 楊 start
        // case 2:
          // del FNSI-濃度プログラムチェックの追加 楊 end
          mode = "b-fluid-conc-step";
          break;
        // mod FNSI-濃度プログラムチェックの追加 楊 start
        // case 3:
        case 3:
          // mod FNSI-濃度プログラムチェックの追加 楊 end
          mode = "b-fluid-conc-course";
          break;
        default:
          break;
      }
      //mod FutureNetWeb+Si no.5899 劉全航 start
      if(this.deviceSetInfoRaw.ufr){
        let URFFlag = this.devA[368].value.initValue;
        if(URFFlag === "1"){
          let finalProgram = this.deviceSetInfoRaw.ufr.dev.A["311"];
          let ufrState = this.deviceSetInfoRaw.ufr.dev.A["290"];
          if(ufrState === "1" && finalProgram < 10){
            for(let i = finalProgram; i < 10 ; i ++){
              stepLowerValueB[i] = 0;
            }
          }
        }
      }
      //mod FutureNetWeb+Si no.5899 劉全航 end
      return {
        mode,
        courseValue: this.devA[364].value.editValue,
        courseStartValue: this.devA[365].value.editValue,
        courseEndValue: this.devA[366].value.editValue,
        courseMinValue: this.devA[365].minValue,
        courseMaxValue: this.devA[365].maxValue,
        stepMinValue: this.devA[351].minValue,
        stepMaxValue: this.devA[351].maxValue,
        stepValues: [stepUpperValueB, stepLowerValueB]
      };
    },

    chartDataA() {
      let mode = 0;
      // mod FNSI-濃度プログラムチェックの追加 楊 start
      // グラフタイプ
      // const chartType = this.devA[340].value.editValue;

      // const stepValueB = this.stepUpperValueB.map(item => {
      //   return item ? item.value.editValue : {};
      // });
      // mod FNSI-濃度プログラムチェックの追加 楊 end
      const stepValueA = this.stepUpperValueA.map(item => {
        return item ? parseFloat(item.value.editValue) : {};
      });

      const stepValueC = this.stepLowerValueA.map(item => {
        return item ? parseFloat(item.value.editValue) : {};
      });

      switch (parseInt(this.devA[340].value.editValue)) {
        case 2:
        // del FNSI-濃度プログラムチェックの追加 楊 start
        // case 2:
          // del FNSI-濃度プログラムチェックの追加 楊 end
          mode = "dialysate-conc-step";
          break;
        // mod FNSI-濃度プログラムチェックの追加 楊 start
        // case 3:
        case 3:
          // mod FNSI-濃度プログラムチェックの追加 楊 end
          mode = "dialysate-conc-course";
          break;
        default:
          break;
      }
      //mod FutureNetWeb+Si no.5899 劉全航 start
      if(this.deviceSetInfoRaw.ufr){
        let URFFlag = this.devA[368].value.initValue;
        if(URFFlag === "1"){
          let finalProgram = this.deviceSetInfoRaw.ufr.dev.A["311"];
          let ufrState = this.deviceSetInfoRaw.ufr.dev.A["290"];
          if(ufrState === "1" && finalProgram < 10){
            for(let i = finalProgram; i < 10 ; i ++){
              stepValueC[i] = 0;
            }
          }
        }
      }
      //mod FutureNetWeb+Si no.5899 劉全航 end
      return {
        mode,
        courseValue: this.devA[361].value.editValue,
        courseStartValue: this.devA[362].value.editValue,
        courseEndValue: this.devA[363].value.editValue,
        courseMinValue: this.devA[362].minValue,
        courseMaxValue: this.devA[362].maxValue,
        stepMinValue: this.devA[341].minValue,
        stepMaxValue: this.devA[341].maxValue,
        // mod FNSI-濃度プログラムチェックの追加 楊 start
        // stepValues: [chartType === "1" ? stepValueB : stepValueA, stepValueC]
        stepValues: [stepValueA, stepValueC]
        // mod FNSI-濃度プログラムチェックの追加 楊 end
      };
    },

    stepUpperValueA() {
      return [
        this.devB[20],
        this.devB[21],
        this.devB[22],
        this.devB[23],
        this.devB[24],
        this.devB[25],
        this.devB[26],
        this.devB[27],
        this.devB[28],
        this.devB[29]
      ];
    },

    stepLowerValueA() {
      return [
        this.devA[341],
        this.devA[342],
        this.devA[343],
        this.devA[344],
        this.devA[345],
        this.devA[346],
        this.devA[347],
        this.devA[348],
        this.devA[349],
        this.devA[350]
      ];
    },

    stepUpperValueB() {
      return [
        this.devB[10],
        this.devB[11],
        this.devB[12],
        this.devB[13],
        this.devB[14],
        this.devB[15],
        this.devB[16],
        this.devB[17],
        this.devB[18],
        this.devB[19]
      ];
    },

    stepLowerValueB() {
      return [
        this.devA[351],
        this.devA[352],
        this.devA[353],
        this.devA[354],
        this.devA[355],
        this.devA[356],
        this.devA[357],
        this.devA[358],
        this.devA[359],
        this.devA[360]
      ];
    },

    /**
     * @description グラフ編集値
     * @returns {Array} 入力項目テキストボックスタイプNumber
     */
    deviceInfoGraphList() {
      return [
        this.devA[316],
        this.devA[317],
        this.devA[318],
        this.devA[319],
        this.devA[320],
        this.devA[321],
        this.devA[322],
        this.devA[323],
        this.devA[324],
        this.devA[325]
      ];
    },

    // 患者経過総合ビューアから表示されている場合はclassを付与する
    isUnderIndModal() {
      let indObj = document.getElementsByClassName("indInfo-style-modal-container");
      if (indObj.length > 0) {
        return "ind-style-media-query";
      }
      return "";
    },

    // SubModal上で表示されていた場合にclassを付与する
    isUnderSubModal() {
      let subModalObj = document.getElementsByClassName("sub-modal-body");
      if (subModalObj.length > 0) {
        return "is-under-sub-modal";
      }
      return "";
    }
  },
  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add start
  created() {
    this.setLoadingScreenVisible(true);
    this.$parent.$parent.isDialogType9 = true;
  },
  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add end
  watch: {
    deviceSetInfo() {
      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        // 親のスタイル修正
        if (window.innerWidth <= 1255) {
          this.$parent.styleObj = { "max-width": "665px", width: "100%" };
        } else {
          this.$parent.styleObj = { "max-width": "1270px", width: "100%" };
        }
      }
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add start
      this.initModelValueDevA = JSON.parse(JSON.stringify(this.devA));
      this.initModelValueDevB = JSON.parse(JSON.stringify(this.devB));
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add end
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      this.devADefault = JSON.parse(JSON.stringify(this.devA));
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
    devA : {
      handler(newVal) {
        if (JSON.stringify(this.devADefault) === JSON.stringify(newVal)) {
          this.changeButton(true);
        } else {
          this.changeButton(false);
        }
      },
      deep: true
    }
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
  },

  // add FNSI-濃度プログラムチェックの追加 楊 start
  mounted() {
    // add 性能改善メモリ不足 shan start
    EventBus.$off("afbf-modal")
    // add 性能改善メモリ不足 shan end
    EventBus.$on("afbf-modal", data => {
      if (this.getIsShowDialysateProgramModal && data) {
        // 切りに設定する
        this.setEditValue();
        // disabledを設定する
        const contentTreat = document.getElementsByTagName("select");
        for (let i = 0; i < contentTreat.length; i++) {
          let attr = contentTreat[i].innerText;
          if (null !== attr) {
            if (attr.startsWith("切り") ) {
              contentTreat[i].setAttribute("disabled", "true");
            }
          }
        }
      }
    });
    setTimeout(() => {
      this.decimalModi();
    },500);
    setTimeout(() => {
      this.changeButton(true);
      this.setLoadingScreenVisible(false);
    },500)
  },
  // add FNSI-濃度プログラムチェックの追加 楊 end

  // add FNSI-性能を最適化する 李 start
  beforeDestroy() {
    EventBus.$off("afbf-modal", data => {
      if (this.getIsShowDialysateProgramModal && data) {
        // 切りに設定する
        this.setEditValue();
        // disabledを設定する
        const contentTreat = document.getElementsByTagName("select");
        for (let i = 0; i < contentTreat.length; i++) {
          let attr = contentTreat[i].innerText;
          if (null !== attr) {
            if (attr.startsWith("切り") ) {
              contentTreat[i].setAttribute("disabled", "true");
            }
          }
        }
      }
    })
  },
  // add FNSI-性能を最適化する 李 end

  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * @description 保存前のバリデーション処理
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateBeforeUpdating() {
      return null;
    },

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setInputNumberChange() {
      EventBus.$emit("deviceSetChanged");
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

    /**
     * @description 編集有無確認
     * @returns {Boolean}
     *   成功: モーダル表示
     *   失敗: モーダル非表示
     */
    checkEdit(num) {
      if (num === 1) {
        // キャンセルボタンクリック時チェック
        this.cancelConfirm();
        // cancelConfirm関数(子)でモーダルの表示非表示を行うため、ベース(親)では何も処理しない
        return true;
      }
    },

    /**
     * 更新処理(指示)
     * @description 親からこの関数を呼んで更新処理を行う
     */
    updateIndInfo(structData) {
      console.log("DcProgramEditor.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // 治療情報更新
      if (this.getSettingIndChildData.isAllSave) {
        // 一括更新
        this.save(structData);
      } else {
        this.ordMainAllSave(structData);
      }
      console.log("DcProgramEditor.vue updateIndInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },
    // add FNSI-濃度プログラムチェックの追加 楊 start
    setEditValue() {
      // 濃度プログラムを[切り]を設定する。
      this.devA[340].value.editValue = 0;
      this.devA[340].value.initValue = 0;
    },
    // add FNSI-濃度プログラムチェックの追加 楊 end

    /**
     * @description 未編集通知ダイアログ後保存ボタンを活性へ(指示画面のみ)
     */
    saveEdit() {
      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        this.$parent.$parent.updateDisable = false;
      }
    },

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add start
    async resetComponentIndData(structData){
      if (this.isEdit()) {
        this.$parent.$parent.messageDialogInfo.messageCd = 70000028;
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
        this.$parent.$parent.messageDialogInfo.type = "9";
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        return;
      } else {
        this.getComponentData(structData, 2);
      }
    },
    isEdit() {
      const treatCondItems = this.$refs;
      let editCount = 0;
      Object.keys(treatCondItems).forEach(key => {
        if ((treatCondItems[key] && treatCondItems[key].isEdited)
          || (treatCondItems[key][0] && treatCondItems[key][0].isEdited)) {

          // 変更箇所数格納
          editCount += 1;
        }
      });
      if (0 === editCount) {
        return false;
      }
      return true;
    },
    async getComponentData(structData, answer) {

      if (answer == 1) {
        return;
      }

      let indWeeks = [
        {
          text: "全",
          done: true,
          value: 0
        },
        {
          text: "月",
          done: true,
          value: 1
        },
        {
          text: "火",
          done: true,
          value: 2
        },
        {
          text: "水",
          done: true,
          value: 3
        },
        {
          text: "木",
          done: true,
          value: 4
        },
        {
          text: "金",
          done: true,
          value: 5
        },
        {
          text: "土",
          done: true,
          value: 6
        },
        {
          text: "日",
          done: true,
          value: 7
        }
      ];
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = structData.facilityCd;
      // 患者情報
      paramJson.pat_id = structData.patId;
      // 治療開始日時
      paramJson.start_date = structData.indStartDate;
      // 治療終了日時
      paramJson.end_date = "";
      // クール
      paramJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 治療方法
      paramJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 曜日パターン
      paramJson.weeks = JSON.stringify(indWeeks);

      // 対象日時の治療情報取得(開始日付・治療方法・クールで絞り込み)
      let response = await ApiHelper.post(
        "/mainData/getOrdMainDataInfo",
        paramJson
      ).catch(error => {
        getErrorMessage('IndActionChart.vue', 'resetComponentData', error);
        throw error;
      });
      let ordMainData = response.data[0];
      if (ordMainData.indDeviceSetInfo != null && ordMainData.indDeviceSetInfo != undefined) {
        let tempData = JSON.parse(ordMainData.indDeviceSetInfo);
        if (tempData != null && tempData != undefined) {
          // 初期値保持
          const initData = deepCopy(tempData);
          if (answer == 3) {
            for (let key in this.devA) {
              if (this.devA[key].value.editValue != this.initModelValueDevA[key].value.initValue) {
                tempData.dc.dev.A[key] = this.devA[key].value.editValue;
              }

            }
            for (let key in this.devB) {
              if (this.devB[key].value.editValue != this.initModelValueDevB[key].value.initValue) {
                tempData.dc.dev.B[key] = this.devB[key].value.editValue;
              }

            }
          }
          for (let key in this.devA) {
            this.devA[key].value.initValue = initData.dc.dev.A[key];
            this.devA[key].value.editValue = tempData.dc.dev.A[key];
          }
          for (let key in this.devB) {
            this.devB[key].value.initValue = initData.dc.dev.B[key];
            this.devB[key].value.editValue = tempData.dc.dev.B[key];
          }
        }
      }
      this.initModelValueDevA = JSON.parse(JSON.stringify(this.devA));
      this.initModelValueDevB = JSON.parse(JSON.stringify(this.devB));
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add end
    decimalModi() {
      let textInputs = document.getElementsByClassName("text-input");
      for (let i = 0; i < textInputs.length; i++) {
        if (textInputs[i].value !== "" && textInputs[i].value !== null && textInputs[i].type === "number") {
          let temp = textInputs[i].value + "";
          if (temp.indexOf(".") > -1) {
            let decimal = temp.split(".")[1];
            let num = 1;
            for (let j = 0; j < decimal.length; j++) {
              num /= 10;
            }
            textInputs[i].step = num;
          } else {
            textInputs[i].step = 1;
          }
        }
      }
    },
    changeButton(val) {
      EventBus.$emit( "mstTreatmentSetRegistered", val);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      // if(false === val) {
      //   EventBus.$emit("deviceSetChanged");
      // }
      EventBus.$emit("deviceSetChanged", !val);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
      
    },
    /**
   * @description 該当行が他院情報かどうかを判定
   * @returns {Boolean} true = 他施設のデータは参照のみ
   */
    isOtherFacilityRow() {
      if (!this.getSettingIndChildData) {
        return false
      }
      return this.getSettingIndChildData.facilityCd ? this.getSettingIndChildData.facilityCd !== this.getFacilityCd : false
    },
  }
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>

<style scoped>
/** iPhone X/8/7/6 or Android(M,L) */
/** Device Width:360-480           */
@media only screen and (min-device-width:360px) and (max-device-width:480px) {
  .device-info-main-title {
    height: fit-content;
  }
  .ind-style-media-query {
    overflow-x: auto;
    overflow-y: auto;
    -webkit-overflow-scrolling:auto;
    overscroll-behavior-y: auto;
  }
  .device-info-content-area {
    min-width:500px;
    height:400px;
  }
}

@media only screen and (max-height:530px) {
  .ind-style-media-query {
    overflow-x: auto;
    overflow-y: auto;
    -webkit-overflow-scrolling:auto;
    overscroll-behavior-y: auto;
  }
}

/* SubModal配下では、通常のModalのcssが当たらないので補正する */
.is-under-sub-modal {
  font-size: 1em;
}

.is-under-sub-modal >>> * {
  font-size: inherit !important;
}

.device-info-cell {
  border: none;
}

.device-info-cell-value {
  padding: 0;
  margin: 4px;
}

.device-input-charts >>> .custom-input-number {
  width: 100%;
  padding: 0;
  margin: 0;
}

.device-setting-area {
  text-align: center;
  /* グラフのY軸ラベルに合わせる */
  padding: 3px 20px 3px 68px;
}

.device-info-cell-rigth {
  text-align: right;
}

.device-area {
  display: inline-block;
  border: solid 1px var(--ntss-border-color);
  border-top: none;
  width: 100%;
  box-sizing: border-box;
}

.device-info-left {
  text-align: left;
}

@media screen and (min-width: 1280px) {
  .device-area {
    /* mod FNSI-FutreNetWeb+SI課題管理No.5250 李 start */
    /* width: 50%; */
    width: 100%;
    /* mod FNSI-FutreNetWeb+SI課題管理No.5250 李 end */
  }
}
</style>
