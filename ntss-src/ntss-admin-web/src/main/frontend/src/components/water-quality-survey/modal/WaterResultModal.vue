/** * 水質検査結果登録モーダル */
<template>
  <modal-base @onClose="close" class="custom-modal">
    <!-- グラフ -->
    <template #body>
    <div class="result-modal">
      <kendo-tabstrip ref="tabContainer" @select="changeTab">
        <ul>
          <li ref="tabBatch" class="kendoTab">
            <div class="kendoText">一括</div>
          </li>
          <li ref="tabList" class="kendoTab">
            <div class="kendoText">一覧</div>
          </li>
        </ul>
        <!-- add 6374 水質検査結果登録画面レイアウト不備 張 start -->
        <!-- <div> -->
        <div style="padding:0px;height: 100%; overflow: auto;margin-bottom: 10px; min-width: max-content;">
        <!-- add 6374 水質検査結果登録画面レイアウト不備 張 end -->
          <div class="multi-result">
            <div class="result-item inspection-location">
              <label for>検査箇所</label>
              <!-- mod FNSI-水質管理_青田の対応 徐 start -->
              <!-- {{ listItem.length }}箇所&nbsp;&nbsp; -->
              {{ showItem.length }}箇所&nbsp;&nbsp;
              <!-- mod FNSI-水質管理_青田の対応 徐 end -->
              <v-ons-icon icon="fa-question-circle" @click="showPopOver($event)"></v-ons-icon>
            </div>
            <div class="result-item date-time-exam">
              <!-- mod FNSI-水質管理_青田の対応 徐 start -->
              <!-- <label for>検査日時</label> -->
              <label for>検査日</label>
              <!-- mod FNSI-水質管理_青田の対応 徐 end -->
              <!-- mod  FNSI-権限 姜 start -->
              <!-- mod FNSI-redmine4003 徐 start -->
                <!--<input
                class="result-input-date ntss-input-date ntss-custom-input"
                style="padding-right:0px;"
                name="inspectionDay"
                type="date"
                :disabled="controlDisp.isDisableDate || !hasTreatmentRecordAuthority"
                v-model="inspectionDay"
              /> -->
                <date-input
                  v-model="inspectionDay"
                  :classes="'result-input-date ntss-input-date ntss-custom-input date-input-required date-input-focus ' +isEdited('inspectionDay')"
                  name="inspectionDay"
                  :disabled="controlDisp.isDisableDate || !hasTreatmentRecordAuthority"
                  @blur="getListByDate()"
                  isRequired
                />
                <!-- mod FNSI-redmine4003 徐 end -->
              <common-calendar v-model="inspectionDay" :disabled="controlDisp.isDisableDate || !hasTreatmentRecordAuthority" style="margin-right: 20px;"/>
              <!-- mod  FNSI-権限 姜 end -->
            <!-- mod FNSI-水質管理_青田の対応 徐 start -->
            </div>
            <div class="result-item date-time-exam">
              <label for>採取時刻</label>
            <!-- mod FNSI-水質管理_青田の対応 徐 end -->
              <!-- mod  FNSI-権限 姜 start -->
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
              <!-- <v-ons-input
                class="result-input input-time"
                name="collectionTime"
                type="time"
                :id = "'time'"
                @change="changeTime()"
                :disabled="!hasTreatmentRecordAuthority"
                v-rules="'date_format:HH:mm'"
                v-model="collectionTime"
              ></v-ons-input> -->
              <time-input
                :classes="'result-input input-time time-input-focus ' +isEdited('collectionTime')"
                name="collectionTime"
                :id = "'time'"
                :disabled="!hasTreatmentRecordAuthority"
                v-model="collectionTime"
                @handleClearInput="collectionTime = null"
              />
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              <!-- mod  FNSI-権限 姜 end -->
            </div>
            <div class="result-item collector">
              <label for>採取者</label>
              <!-- mod  FNSI-権限 姜 start -->
              <v-ons-select class="result-select"
                  :disabled="!hasTreatmentRecordAuthority"
                  :id = "'pickerCd'"
                  @change="changeSelectedOption($event, 'picker')"
                  v-model="pickerCd" style="background: #fff; width: max-content;">
                <option :value="null"></option>
                <option
                  v-for="user in getUserInfo"
                  :style="user.selectedStyle"
                  :value="user.userId"
                  :key="user.userId"
                >{{ `${user.userLastName}${user.userFirstName}` }}</option>
              </v-ons-select>
              <!-- mod  FNSI-権限 姜 end -->
            </div>
            <div class="result-item inspector">
              <label for>検査者</label>
              <!-- mod  FNSI-権限 姜 start -->
              <v-ons-select class="result-select"
                  :disabled="!hasTreatmentRecordAuthority"
                  :id = "'inspectorCd'"
                  @change="changeSelectedOption($event, 'inspector')"
                  v-model="inspectorCd" style="background: #fff; width: max-content;">
                <option :value="null"></option>
                <option
                  v-for="user in getUserInfo"
                  :style="user.selectedStyle"
                  :value="user.userId"
                  :key="user.userId"
                >{{ `${user.userLastName}${user.userFirstName}` }}</option>
              </v-ons-select>
              <!-- mod  FNSI-権限 姜 end -->
            </div>
            <template v-for="(rec, index) in mstSurveyType">
              <div
                class="result-item result-survey-type"
                :key="index"
                v-if="isDispSurveyType(rec.surveyTypeCd)"
              >
                <label :id="'title-' + rec.surveyTypeCd" for>{{ rec.surveyTypeName }}</label>
                <!--mod FNSI-#3404(起票):初期値が表示 韓 start-->
                <!-- mod  FNSI-権限 姜 start -->
                <!-- mod #5589 2023/04/07 数値IFのスタイル全不正 張博 start -->
                <!-- <v-ons-input
                  :disabled="!hasTreatmentRecordAuthority"
                  inputmode="numeric"
                  :name="'resultValue-' + rec.surveyTypeCd"
                  :id = "'value-' + rec.surveyTypeCd"
                  class="result-input"
                  type="number"
                  v-model="resultValue[rec.surveyTypeCd]"
                  @focus="addInitialValue(rec.surveyTypeCd, rec.initialValue, rec.initialString, index)"
                  :value="null"
                  @change="validateResultValue(rec.surveyTypeCd,$event, index)"
                ></v-ons-input> -->
                <!--mod #11047 数値IF修正【最優先】 張玲 start-->
                <!-- <v-ons-input
                  :disabled="!hasTreatmentRecordAuthority"
                  inputmode="numeric"
                  :name="'resultValue-' + rec.surveyTypeCd"
                  :id = "'value-' + rec.surveyTypeCd"
                  class="result-input"
                  style="width: 8em;"
                  type="number"
                  :step="rec.initialValue"
                  v-model="resultValue[rec.surveyTypeCd]"
                  :value="null"
                  @focus="addInitialValue(rec.surveyTypeCd, rec.initialValue, rec.initialString, index)"
                  @input="adjustInputBox(rec, $event)"
                  @change="validateResultValue(rec,$event)"
                  @mousewheel.prevent="handleMouseWheel(rec,$event,index)"
                  @blur="handleBlur(rec,$event,index)"
                ></v-ons-input> -->
                <!-- mod #5589 2023/04/07 数値IFのスタイル全不正 張博 end -->
                 <custom-input-number-pro
                  :disabled="!hasTreatmentRecordAuthority"
                  :name="'resultValue-' + rec.surveyTypeCd"
                  :id = "'value-' + rec.surveyTypeCd"
                  class="result-input"
                  style="width: 8em;"
                  :step="unitStep(rec.decimalDigits)"
                  :min="handlerMin(rec)"
                  :max="handlerMax(rec)"
                  :value="mstSurveyType[index].initialValue"
                  @handlerInput="(val)=>{
                      if (resultValue.find( rst => rst.index === rec.surveyTypeCd)) {
                          resultValue.map( rst => {
                              if (rst.index === rec.surveyTypeCd) { rst.val = val }
                          })
                      } else {
                          resultValue.push( { 'index': rec.surveyTypeCd, 'val': val })
                      }
                  }"
                  @blur="handleBlur(rec,$event,index)"
                 />
                <!--mod #11047 数値IF修正【最優先】 張玲 end-->
                <!--mod #11047 数値IF修正【最優先】 張玲 end-->
                <!-- mod  FNSI-権限 姜 end -->
                <!--mod FNSI-#3405結果文字列の表示位置がずれる対応 韓 start-->
                <span class="unit">
                  <label :id = "'unit-' + rec.surveyTypeCd" for>{{rec.unit}}</label>
                </span>
                <!--mod FNSI-#3405結果文字列の表示位置がずれる対応 韓 end-->
                <!-- mod  FNSI-権限 姜 start -->
                <v-ons-select
                  v-if="isShowInitialText(rec.surveyTypeCd)"
                  :disabled="!hasTreatmentRecordAuthority"
                  :id = "'text-' + rec.surveyTypeCd"
                  class="result-select select-text"
                  v-model="textValue[index]"
                  style="background: #fff; width: max-content;"
                  @change="changeInitialText(rec.surveyTypeCd)"
                >
                <!-- mod  FNSI-権限 姜 end -->
                <option
                  v-for="(value, index) in getResult(rec.surveyTypeCd, rec.pointCd)"
                  :key="index"
                  :value="value.cd"
                >{{value.text}}</option>
                <!--mod FNSI-#3404(起票):初期値が表示 韓 end-->
                </v-ons-select>
              </div>
            </template>
          </div>
        </div>
        <v-ons-popover
          cancelable
          v-model:visible="popoverVisible"
          :target="popoverTarget"
          :cover-target="false"
          :direction="popoverDirection"
          :class="fontSizeSet"
          @preshow="popoverPreShow"
          @postshow="popoverPostShow"
          @posthide="popoverPosthide"
        >
          <div class="display-area">
            <ol>
              <!-- mod FNSI-水質管理_青田の対応 徐 start -->
              <!-- <li
                v-for="(rec, index) in listItem"
                :key="index"
              >{{ rec.pointName }}&nbsp;({{ rec.surveyTypeName }})</li> -->
              <li
                v-for="(rec, index) in showItem"
                :key="index"
              >{{ rec.pointName }}&nbsp;({{ rec.surveyTypeName }})</li>
              <!-- mod FNSI-水質管理_青田の対応 徐 end -->
            </ol>
          </div>
        </v-ons-popover>
        <!-- add 6374 水質検査結果登録画面レイアウト不備 張 start -->
        <!-- <div> -->
        <div style="padding:0px;height: 100%; overflow: auto; margin-bottom: 10px;">
        <!-- add 6374 水質検査結果登録画面レイアウト不備 張 end -->

          <!-- mod FNSI-バグ 水質管理532 徐 start -->
          <!-- <div class="single-result">
            <div class="single-result-header"> -->
          <div class="single-result" style="padding:0px;height: 100%; overflow: auto;">
            <!-- mod ウィンドウ表示でレイアウトが崩れるに修正する。 孔 start-->
            <!-- <div class="single-result-header" style="height: 7%; overflow: auto;">-->
            <div class="single-result-header" style="height: 45px; overflow: auto;">
            <!-- mod ウィンドウ表示でレイアウトが崩れるに修正する。 孔 end-->
            <!-- mod FNSI-バグ 水質管理532 徐 end -->
              <!--mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start-->
              <!-- <div class="item"> -->
                <!-- <label style="width: 20%">検査日</label> -->
                <!-- <input
                  name="inspectionDay"
                  type="date"
                  style="font-size: 1.05em; padding-right:0px;"
                  class="ntss-input-date ntss-custom-input"
                  v-model="inspectionDay"
                  :disabled="controlDisp.isDisableDate"
                /> -->
              <div class="inspectionday">
                <label style="margin-left: 5px; margin-right: 5px;">検査日</label>
                <!-- mod  FNSI-権限 姜 start -->
                <!-- mod FNSI-redmine4003 徐 start -->
                <!--<input
                  name="inspectionDay"
                  type="date"
                  class="ntss-input-date ntss-custom-input"
                  v-model="inspectionDay"
                  :disabled="controlDisp.isDisableDate || !hasTreatmentRecordAuthority"
                /> -->
                <date-input
                  v-model="inspectionDay"
                  :classes="'ntss-input-date ntss-custom-input date-input-required date-input-focus ' +isEdited('inspectionDay')"
                  name="inspectionDay"
                  :disabled="controlDisp.isDisableDate || !hasTreatmentRecordAuthority"
                  @blur="getListByDate()"
                  isRequired
                />
                <!-- mod FNSI-redmine4003 徐 end -->
              <!--mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end-->
                <!-- mod FutreNetWeb+SI課題管理No6314 趙 start -->
                <!-- <common-calendar v-model="inspectionDay" :disabled="controlDisp.isDisableDate || !hasTreatmentRecordAuthority" /> -->
                <common-calendar v-model="inspectionDay" :disabled="controlDisp.isDisableDate || !hasTreatmentRecordAuthority" @input="getListByDate()"/>
                <!-- mod FutreNetWeb+SI課題管理No6314 趙 end -->
                <!-- mod  FNSI-権限 姜 end -->
              <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start -->
              <!-- </div>
              <div v-if="controlDisp.isDispPlan" class="item">
                <div class="toggle-plan">
                  <label>予定なし</label>
                  <v-ons-switch v-model="toggleShowPlan"></v-ons-switch>
                </div>
                <div class="toggle-result">
                  <label>結果あり</label>
                  <v-ons-switch v-model="toggleShowResult"></v-ons-switch>
                </div>
              </div> -->
              <!-- mod FNSI-水質管理_青田の対応 徐 start -->
              <!-- <div v-if="controlDisp.isDispPlan" class="item">
                  <div class="toggle-plan">
                    <label>予定なし</label>
                    <v-ons-switch v-model="toggleShowPlan"></v-ons-switch>
                  </div>
                  <div class="toggle-result">
                    <label>結果あり</label>
                    <v-ons-switch v-model="toggleShowResult"></v-ons-switch>
                  </div>
                </div> -->
                <div class="item">
                  <div class="toggle-plan">
                    <label>&#8195;&#8195;対象のみ表示</label>
                    <v-ons-switch v-model="toggleShowobject" @click="changeShow()"></v-ons-switch>
                  </div>
                  <div class="toggle-result">
                    <label>予定ありのみ表示</label>
                    <v-ons-switch v-model="toggleShowPred" @click="changeShow()"></v-ons-switch>
                  </div>
                </div>
                <!-- mod FNSI-水質管理_青田の対応 徐 end -->
              </div>
              <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end -->
            </div>
            <!--mod FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 start-->
            <!-- <div> -->
            <!-- mod FNSI-バグ 水質管理532 徐 start -->
            <!-- <div class="main-content-area"> -->
            <div class="main-content-area" style="height: 100%; overflow: auto;">
            <!-- mod FNSI-バグ 水質管理532 徐 end -->
            <!--mod FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 end-->
              <!--add FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 start-->
              <!-- mod FNSI-バグ 水質管理532 徐 start -->
              <!-- <div class="scroll-table"> -->
              <!-- mod ウィンドウ表示でレイアウトが崩れるに修正する。 孔 start-->
              <!--<div class="scroll-table" style="height: 87%; overflow: auto;">-->
              <!-- mod FNSI-改修内容6374修正 xuty start -->
              <!-- <div class="scroll-table" style="height: 85%; overflow: auto;"> -->
              <div class="scroll-table" style="overflow: auto;">
              <!-- mod FNSI-改修内容6374修正 xuty end -->
              <!-- mod ウィンドウ表示でレイアウトが崩れるに修正する。 孔 end-->
              <!-- mod FNSI-バグ 水質管理532 徐 end -->
                <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start -->
                <!-- <div class="fixed-area" style="width: 25%;"> -->
                <div class="fixed-area">
                <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end -->
              <!--add FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 end-->
                  <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start -->
                  <!-- <table class="grid-record-list" style="width: 100%;"> -->
                  <!--mod FNSI-水質管理_青田の対応 徐 start-->
                  <!--<table class="grid-record-list">-->
                  <table class="grid-record-list" id="recordTable" style="width: max-content;">
                  <!--mod FNSI-水質管理_青田の対応 徐 end-->
                  <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end -->
                    <thead>
                      <tr>
                        <!--add FNSI-水質管理_青田の対応 徐 start-->
                        <th class="ntss-list-header-th-sticky headcol sticky-col-checkbox">
                          <!-- mod FNSI-redmine4790 徐 start -->
                          <!-- <v-ons-checkbox :input-id="'select-all'" v-model="selectedAllList" :value="-1" @click="setChecked()"></v-ons-checkbox> -->
                          <v-ons-checkbox :input-id="'select-all'" v-model="selectedAllList" :value="-1" :disabled="!hasTreatmentRecordAuthority" @click="setChecked()"></v-ons-checkbox>
                          <!-- mod FNSI-redmine4790 徐 end -->
                        </th>
                        <!--add FNSI-水質管理_青田の対応 徐 end-->
                        <!--mod FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 start-->
                        <!-- <th class="ntss-list-header-th-sticky" width="10%">装置名</th>
                        <th class="ntss-list-header-th-sticky" width="7%">種別</th>
                        <th class="ntss-list-header-th-sticky" width="7%">検査箇所</th>
                        <th class="ntss-list-header-th-sticky" width="7%">予定</th>
                        <th class="ntss-list-header-th-sticky" width="7%">採取時刻</th>
                        <th class="ntss-list-header-th-sticky" width="13%">採取者</th>
                        <th class="ntss-list-header-th-sticky">結果</th>
                        <th class="ntss-list-header-th-sticky" width="13%">検査者</th> -->
                        <th class="ntss-list-header-th-sticky headcol headcol-fixed manual-width">
                          <span @click="sortBy('machineOrderIndex')" :class="sortedClass('machineOrderIndex')" class="clickable-header-label">装置名</span>
                        </th>
                        <th class="ntss-list-header-th-sticky headcol headcol-fixed manual-width">
                          <span @click="sortBy('waterSurveyTypeOrderIndex')" :class="sortedClass('waterSurveyTypeOrderIndex')" class="clickable-header-label">種別</span>
                        </th>
                        <th class="ntss-list-header-th-sticky headcol headcol-fixed manual-width">
                          <span @click="sortBy('waterSurveyPointOrderIndex')" :class="sortedClass('waterSurveyPointOrderIndex')" class="clickable-header-label">検査箇所名</span>
                        </th>
                        <!--mod FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 end-->
                      </tr>
                    </thead>
                    <tbody>
                      <!--mod FNSI-水質管理_青田の対応 徐 start-->
                      <!--<template v-for="(rec) in listItem">-->
                      <template v-for="(rec, index) in showItemList" :key="rec.cd">
                      <!--mod FNSI-水質管理_青田の対応 徐 end-->
                        <tr valign="middle" v-if="rec.show">
                          <!--add FNSI-水質管理_青田の対応 徐 start-->
                          <td class="check-box sticky-col-checkbox">
                            <!-- mod FNSI-redmine4790 徐 start -->
                            <!-- <v-ons-checkbox
                              :input-id="'select-' + index"
                              v-model="selectedList"
                              :value="index + 1"
                              @click="changeCheck(index + 1)"
                            ></v-ons-checkbox> -->
                             <v-ons-checkbox
                              :input-id="'select-' + index"
                              v-model="selectedList"
                              :value="String(index + 1)"
                              :disabled="!hasTreatmentRecordAuthority"
                            ></v-ons-checkbox>
                            <!-- mod FNSI-redmine4790 徐 end -->
                          </td>
                          <!--add FNSI-水質管理_青田の対応 徐 end-->
                          <td>{{ rec.machineName }}</td>
                          <td>{{ rec.surveyTypeName }}</td>
                          <td>{{ rec.pointName }}</td>
                          <!--del FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 start-->
                          <!-- <td align="center">
                            <label v-if="+rec.surveyData.plan === 1">〇</label>
                            <label v-else></label>
                          </td>
                          <td align="center">
                            <v-ons-input
                              style="width: auto"
                              type="time"
                              v-rules="'date_format:HH:mm'"
                              v-model="rec.surveyData.time"
                            ></v-ons-input>
                          </td>
                          <td align="center">
                            <v-ons-select
                              style="border: 1px solid #cccccc; font-size: 0.7em;  background: #fff"
                              v-model="rec.surveyData.picker"
                            >
                              <option :value="null"></option>
                              <option
                                v-for="user in mstUser"
                                :value="user.userId"
                                :key="user.userId"
                              >{{ `${user.userLastName}${user.userFirstName}` }}</option>
                            </v-ons-select>
                          </td>
                          <td align="center">
                            <div class="group-record">
                              <v-ons-input
                                type="number"
                                inputmode="numeric"
                                style="width: 50%; font-size: 0.7em"
                                v-model="rec.surveyData.value"
                                @change="validateResultValue(rec.surveyTypeCd,$event,index)"
                              ></v-ons-input>
                              <span style="width: 1.6em">{{ getUnitByPointCd(rec.pointCd) }}</span>
                              <v-ons-select
                                style="border: 1px solid #cccccc; font-size: 0.7em; background: #fff"
                                v-model="rec.surveyData.text"
                              >
                                <option :value="0"></option>
                                <option
                                  v-for="(value, index) in getResultText"
                                  :key="index"
                                  :value="value.cd"
                                >{{value.text}}</option>
                              </v-ons-select>
                            </div>
                          </td>
                          <td align="center">
                            <v-ons-select
                              style="border: 1px solid #cccccc; font-size: 0.7em; background: #fff"
                              v-model="rec.surveyData.inspector"
                            >
                              <option :value="null"></option>
                              <option
                                v-for="user in mstUser"
                                :value="user.userId"
                                :key="user.userId"
                              >{{ `${user.userLastName}${user.userFirstName}` }}</option>
                            </v-ons-select>
                          </td> -->
                          <!--del FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 end-->
                        </tr>
                      </template>
                    </tbody>
                  </table>
                <!--add FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 start-->
                </div>
                <!--add FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 end-->
                <!--add FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 start-->
                <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start -->
                <!-- <div class="scroll-area" style="width: 76%;"> -->
                <div class="scroll-area">
                <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end -->
                  <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start -->
                  <!-- <table class="scroll-table-data" style="width: 130%;"> -->
                  <table class="scroll-table-data" style="width: max-content;">
                  <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end -->
                    <thead>
                      <tr>
                        <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start -->
                        <!-- <th class="ntss-list-header-th-sticky" width="4%">予定</th> -->
                        <!-- <th class="ntss-list-header-th-sticky" width="8%">採取時刻</th> -->
                        <!-- <th class="ntss-list-header-th-sticky" width="20%">採取者</th> -->
                        <!-- <th class="ntss-list-header-th-sticky">結果</th> -->
                        <!-- <th class="ntss-list-header-th-sticky" width="20%">検査者</th> -->
                        <!-- add FNSI-水質検査結果登録で備考欄を追加する 周 start -->
                        <!-- <th class="ntss-list-header-th-sticky" width="8%">備考</th> -->
                        <!-- add FNSI-水質検査結果登録で備考欄を追加する 周 end -->
                        <th class="ntss-list-header-th-sticky" style="min-width: 3.5em;">
                          <div class="resizable-header">
                            <span @click="sortBy('plan')" :class="sortedClass('plan')" class="clickable-header-label">予定</span>
                          </div>
                        </th>
                        <th class="ntss-list-header-th-sticky" style="min-width: 6em;">
                          <div class="resizable-header">
                            採取時刻
                          </div>
                        </th>
                        <th class="ntss-list-header-th-sticky" style="min-width: 8em;">
                          <div class="resizable-header">
                            <div>採取者</div>
                            <div>
                              <v-ons-select
                                :disabled="!hasTreatmentRecordAuthority"
                                id="picker_all"
                                style="font-size: 0.7em;  background: #fff; width: max-content;"
                                @change="updateSelectedOption($event, 'picker'), changeParentSelectedOption($event)"
                              >
                                <option :value="0"></option>
                                <option
                                  v-for="(user, index) in getUserInfo"
                                  :style="user.selectedStyle"
                                  :value="user.userId"
                                  :key="index"
                                >{{ `${user.userLastName}${user.userFirstName}` }}</option>
                              </v-ons-select>
                            </div>
                          </div>
                        </th>
                        <!-- mod FNSI-水質管理_青田の対応 徐 end -->
                        <!-- <th class="ntss-list-header-th-sticky" width="740">結果</th> -->
                        <th class="ntss-list-header-th-sticky" style="min-width: 18em;">
                          <div style="display: flex; align-items: center;" class="resizable-header">
                            <div>結果</div>
                            <div style="margin-left: 5px;">
                              <button
                                :disabled="!hasTreatmentRecordAuthority"
                                id="btnUpdateDefaultValue"
                                class="button btn1-execute"
                                @click="updateDefaultValue"
                              >既定値</button>
                            </div>
                          </div>
                        </th>
                        <!-- mod FNSI-水質管理_青田の対応 徐 end -->
                        <th class="ntss-list-header-th-sticky" style="min-width: 8em;">
                          <div class="resizable-header">
                            <div>検査者</div>
                            <div>
                              <v-ons-select
                                :disabled="!hasTreatmentRecordAuthority"
                                id="inspector_all"
                                style="font-size: 0.7em;  background: #fff; width: max-content;"
                                @change="updateSelectedOption($event, 'inspector'), changeParentSelectedOption($event)"
                              >
                                <option :value="0"></option>
                                <option
                                  v-for="(user, index) in getUserInfo"
                                  :style="user.selectedStyle"
                                  :value="user.userId"
                                  :key="index"
                                >{{ `${user.userLastName}${user.userFirstName}` }}</option>
                              </v-ons-select>
                            </div>
                          </div>
                        </th>
                        <th class="ntss-list-header-th-sticky" style="min-width: 20em;">
                          <div class="resizable-header">
                            備考
                          </div>
                        </th>
                        <!-- mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end -->
                      </tr>
                    </thead>
                    <tbody>
                      <template v-for="(rec, index) in showItemList" :key="rec.pointCd"> <!--mod #11047 数値IF修正 情 start-->
                        <!-- <tr :key="rec.cd" valign="middle" v-if="rec.show">  -->
                        <tr valign="middle" v-if="rec.show">
                          <!--mod #11047 数値IF修正 情 end-->
                          <td align="center">
                            <label v-if="+rec.surveyData.plan === 1">〇</label>
                            <label v-else></label>
                          </td>
                          <td align="center" >
                            <!-- mod  FNSI-権限 姜 start -->
                            <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
                            <!-- <v-ons-input
                              :disabled="!hasTreatmentRecordAuthority"
                              style="width: auto"
                              type="time"
                              v-rules="'date_format:HH:mm'"
                              v-model="rec.surveyData.time"
                              :id="'time_' + index"
                              :class="classObject"
                              @focus="addFocusCssTimeText($event)"
                              @blur="delFocusCssTimeText($event)"
                            > 
                            </v-ons-input>
                            -->
                            <time-input
                              :disabled="!hasTreatmentRecordAuthority"
                              style="width: auto"
                              v-model="rec.surveyData.time"
                              @handleClearInput="rec.surveyData.time = ''"
                              :id="'time_' + index"
                              :classes="'input-time time-input-focus ' +isEditedList(index, 'surveyData.time')"
                            />
                            <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
                            <!-- mod  FNSI-権限 姜 end -->
                          </td>
                          <td align="center">
                            <!--mod FNSI-改修内容766 @change="addFocusCss($event)" 姜 start -->
                            <!-- mod  FNSI-権限 姜 start -->
                            <v-ons-select
                              :disabled="!hasTreatmentRecordAuthority"
                              style="font-size: 0.7em;  background: #fff; width: max-content;"
                              v-model="rec.surveyData.picker"
                              :id="'picker_' + index"
                              @change="changeChildenSelectedOption(rec, $event, index, 'picker')"
                            >
                            <!-- mod  FNSI-権限 姜 end -->
                            <!--mod FNSI-改修内容766 @change="addFocusCss($event)" end -->
                              <option :value="0"></option>
                              <option
                                v-for="(user, index) in getUserInfoList(rec.surveyData.picker)"
                                :style="user.selectedStyle"
                                :value="user.userId"
                                :key="index"
                              >{{ `${user.userLastName}${user.userFirstName}` }}</option>
                            </v-ons-select>
                          </td>
                          <td align="center">
                            <div class="group-record">
                              <!--mod FNSI-改修内容766 @focus="addFocusCssNumberText($event)"
                                                      @blur="delFocusCssNumberText($event)"  姜 start -->
                              <!-- mod  FNSI-権限 姜 start -->
                              <!-- mod #5589 2023/04/07 数値IFのスタイル全不正 張博 start -->
                              <!-- <v-ons-input
                                :disabled="!hasTreatmentRecordAuthority"
                                type="number"
                                inputmode="numeric"
                                style="width: 60%; font-size: 0.7em"
                                :id="'value_' + index"
                                v-model="rec.surveyData.value"
                                @focus="addFocusCssNumberText(rec.surveyTypeCd,$event,index)"
                                @blur="delFocusCssNumberText($event,index)"
                                @change="validateResultValue(rec.surveyTypeCd,$event,index)"
                              > -->
                              <!--mod #11047 数値IF修正【最優先】 張玲 start-->
                              <!-- <v-ons-input
                                :disabled="!hasTreatmentRecordAuthority"
                                type="number"
                                class="result-value"
                                inputmode="numeric"
                                style="width: 8em; font-size: 0.7em"
                                :id="'value_' + index"
                                v-model="rec.surveyData.value"
                                :step="0.001"
                                @focus="addFocusCssNumberText(rec.surveyTypeCd,$event, index)"
                                @input="adjustInputBoxList($event, 'value')"
                                @blur="delFocusCssNumberText($event,index,rec, index); setDefaultTime(rec)"
                                @change="validateResultValue(rec,$event)"
                                @mousewheel.prevent="handleMouseWheels(rec,$event, index)"
                              /> -->
                              <!-- mod #5589 2023/04/07 数値IFのスタイル全不正 張博 end -->
                              <!-- mod  FNSI-権限 姜 end -->
                              <!--mod FNSI-改修内容766 @focus="addFocusCssNumberText($event)"
                                                      @blur="delFocusCssNumberText($event)"  姜 end -->
                              <custom-input-number-pro
                               :disabled="!hasTreatmentRecordAuthority"
                               class="result-value"
                               style="width: 8em;"
                               :id="'value_' + index"
                               :value="rec.surveyData.value"
                               :step="handlerStep(rec)"
                               :min="handlerMin(rec)"
                               :max="handlerMax(rec)"
                               @handlerInput="(val) =>{rec.surveyData.value = val}"
                              />
                              <!--mod #11047 数値IF修正【最優先】 張玲 end-->
                              <!--mod FNSI-redmine3999 徐 start-->
                              <!--<span style="width: 1.6em;">{{ getUnitByPointCd(rec.pointCd) }}</span>-->
                              <span style="padding-left: 5px; padding-right: 5px; text-align: left; white-space: nowrap;">{{ getUnitInfo(rec) }}</span>
                              <!--mod FNSI-redmine3999 徐 start-->
                              <div v-if="isShowInitialText(rec.surveyTypeCd)" class="result-text">
                                <v-ons-select
                                  v-model="rec.surveyData.text"
                                  :id="'text_' + index"
                                  :disabled="!hasTreatmentRecordAuthority"
                                  style="width: max-content; "
                                  @change="changeFocusCssList(rec, $event, index)"
                                >
                                  <option
                                    v-for="(value, index) in getResult(rec.surveyTypeCd, rec.pointCd)"
                                    :key="index"
                                    :value="value.cd"
                                  >{{value.text}}</option>
                                </v-ons-select>
                              </div>
                              <div v-if="!isShowInitialText(rec.surveyTypeCd)" class="result-text">
                                <!-- 空行 -->
                              </div>
                            </div>
                          </td>
                          <td align="center">
                            <!--add FNSI-改修内容766 @change="addFocusCss($event)" 姜 start -->
                            <!-- mod  FNSI-権限 姜 start -->
                            <v-ons-select
                              style="font-size: 0.7em; background: #fff; width: max-content;"
                              v-model="rec.surveyData.inspector"
                              :id="'inspector_' + index"
                              :disabled="!hasTreatmentRecordAuthority"
                              @change="changeChildenSelectedOption(rec, $event, index, 'inspector')"
                            >
                            <!-- mod  FNSI-権限 姜 end -->
                            <!--add FNSI-改修内容766 @change="addFocusCss($event)" 姜 end -->
                              <option :value="0"></option>
                              <option
                                v-for="(user, index) in getUserInfoList(rec.surveyData.inspector)"
                                :style="user.selectedStyle"
                                :value="user.userId"
                                :key="index"
                              >{{ `${user.userLastName}${user.userFirstName}` }}</option>
                            </v-ons-select>
                          </td>
                          <td align="left" style="width: 100%;">
                            <v-ons-input
                              v-model="rec.surveyData.memo"
                              type="text"
                              class="memo"
                              :id = "'memo_' + index"
                              :disabled="!hasTreatmentRecordAuthority"
                              @focus="addFocusCssText($event)"
                              @blur="delFocusCssText($event, index)"
                            ></v-ons-input>
                          </td>
                        </tr>
                      </template>
                    </tbody>
                  </table>
                </div>
                <!--add FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 end-->
              <!--add FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 start-->
              </div>
              <!--add FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 end-->
            </div>
          </div>
        </div>
      </kendo-tabstrip>
    </div>
    <!-- フッター -->
    </template>
    <template #footer>
      <div class="flex-container flex-container-footer">
      <div class="denial-btn-area" style="background:none">
        <!-- mod FNSI-権限 徐 start -->
        <!-- <button :disabled="!hasTreatmentRecordAuthority" class="button denial-btn" @click="close">キャンセル</button> -->
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button class="button denial-btn" @click="close">キャンセル</button> -->
        <button class="button btn2-cancel" @click="close">キャンセル</button>
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
        <!-- mod FNSI-権限 徐 end -->
        &nbsp;&nbsp;
        <!-- mod  FNSI-権限 姜 start -->
        <!-- mod FNSI-水質管理_青田の対応 徐 start -->
        <!-- <button
          v-if="controlDisp.isDispDel"
           :disabled="!hasTreatmentRecordAuthority"
          class="button registration-btn"
          @click="deleteResult"
        >削除</button> -->
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button
          v-if="controlDisp.isDispDel"
           :disabled="!hasTreatmentRecordAuthority"
          class="button registration-btn"
          @click="deleteResult(1)"
        >全部削除</button> -->
        <button
          v-if="controlDisp.isDispDel"
           :disabled="!hasTreatmentRecordAuthority"
          class="button btn4-alert"
          @click="deleteResult(1)"
        >削除</button>
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
        &nbsp;&nbsp;
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button
          v-if="controlDisp.isDispDel"
           :disabled="!hasTreatmentRecordAuthority"
          class="button registration-btn"
          @click="deleteResult(2)"
        >結果削除</button> -->
        <button
          v-if="controlDisp.isDispDel"
           :disabled="!hasTreatmentRecordAuthority || getPointCd.length == 0"
          class="button btn4-alert"
          @click="deleteResult(2)"
        >結果削除</button>
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
        <!-- mod FNSI-水質管理_青田の対応 徐 end -->
        <!-- mod  FNSI-権限 姜 end -->
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- mod  FNSI-権限 姜 start -->
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button class="button registration-btn" @click="save" :disabled="!disableSave || !hasTreatmentRecordAuthority">保存</button> -->
        <!-- mod FNSI-redmine3998 徐 start -->
        <!-- <button class="registration-btn button btn1-execute" @click="save" :disabled="!disableSave || !hasTreatmentRecordAuthority">保存</button> -->
<!--        mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start-->
<!--        <button class="registration-btn button btn1-execute" @click="save" :disabled="(selectTabId==0 && showItem.length==0) || !changeFlg || !disableSave || !hasTreatmentRecordAuthority">保存</button>-->
        <button class="registration-btn button btn1-execute" @click="save" :disabled="!changeFlg || !disableSave || !hasTreatmentRecordAuthority">保存</button>
<!--        mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end-->
        <!-- mod FNSI-redmine3998 徐 end -->
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
        <!-- mod  FNSI-権限 姜 end -->
      </div>
      </div>
    </template>
  </modal-base>

</template>

<script>
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import ModalBase from "@/components/modals/ModalBase";
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import $ from "@/compat/jquery";

import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import PopoverMixin from "@/components/PopoverMixin";
// add  FNSI-権限 姜 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// add  FNSI-権限 姜 end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// del FNSI-水質管理_青田の対応 徐 start
// const INSPECTION = 2,
//  HAVE_RESULT = 3;
// del FNSI-水質管理_青田の対応 徐 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//#5590 2023/04/19 ×を常に表示するように修正 張博 start
import TimeInput from "@/components/common/TimeInput.vue";
//#5590 2023/04/19 ×を常に表示するように修正 張博 end
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
import store from "@/stores";
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
import DateInput from "@/components/common/DateInput.vue";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";
import BigNumber from "@/compat/number/bignumber";
//add #11047 数値IF修正【最優先】 張玲 start

//add #11047 数値IF修正【最優先】 張玲 end
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";

import { getScopedElementById, getScopedSessionStorage } from "@/functions/common/LayoutMeasureHelper";

export default {
    // add  FNSI-権限 姜 start
  mixins: [PopoverMixin, ComponentGuardMixin],
    // add  FNSI-権限 姜 end
  components: {
    "modal-base": ModalBase,
    "common-calendar": commonCalender,
    "time-input": TimeInput,
    "date-input": DateInput,
    //add #11047 数値IF修正【最優先】 張玲 start
    "custom-input-number-pro": CustomInputNumberPro,
    //add #11047 数値IF修正【最優先】 張玲 end
  },
  data() {
    return {
      // add FNSI-水質管理_青田の対応 徐 start
      selectedList: [],
      // mod FutreNetWeb+SI課題管理No5505 趙 start
      selectedAllList: [],
      // mod FutreNetWeb+SI課題管理No5505 趙 end
      toggleShowobject: true,
      toggleShowPred: false,
      setCheckedFlg: true,
      showItem: [],
      intervalId: null,
      listItem: [],
      listItemInitial: [],
      textValue: [],
      // add FNSI-水質管理_青田の対応 徐 end
      isDispDel: true,
      isPlanCkb: true,
      isResultCkb: true,

      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "right",
      backupInspectionDay: null,
      inputModel: [],
      inspectionDay: null,
      collectionTime: null,
      pickerCd: null,
      inspectorCd: null,
      resultValue: [],
      resultText: [],
      toggleShowResult: true,
      toggleShowPlan: true,
      invalidResultValue: false,
      arrValidateResult: [],
      disableSave: true,
      // add FNSI-改修内容766 姜 start
      textTime: null,
      textNumber: [],
      textTimeFlg: true,
      // add FNSI-redmine3998 徐 start
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      // changeFlg: false,
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
      indexNum: 0,
      // add FNSI-redmine3998 徐 end
      // add  FNSI-権限 姜 start
      // 権限を有無する
      hasTreatmentRecordAuthority: false,
      // add  FNSI-権限 姜 end
	  // mod #5589 2023/04/07 数値IFのスタイル全不正 張博 start
      min: 0,
      blurFlg: false,
      focusFlg: [],
	  // mod #5589 2023/04/07 数値IFのスタイル全不正 張博 end
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      initIspectionDay: null,
      initCollectionTime: null,
      initPickerCd: null,
      initInspectorCd: null,
      initTextValue: null,
      initListItem: null,
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
      userId: null,
      isSelectedHeaderOption: false,
      minWidth: 5,
      //add #9558 水質管理一覧のヘッダ部から個別画面に遷移すると、機能帳票の制御が「一覧」のままになる 杜 start
      maList:[],
      //add #9558 水質管理一覧のヘッダ部から個別画面に遷移すると、機能帳票の制御が「一覧」のままになる 杜 end
      sort: {
        key: "",
        isAsc: true
      },
    };
  },

  computed: {
    ...mapGetters("water-quality-survey/list", [
      "selectedSurveyList",
      "mstMachine",
      "mstSurveyPoint",
      "mstSurveyType",
      "mntWaterSurvey",
      "getSelectedList",
      "mstUser",
      "getResultText"
    ]),
    ...mapGetters("water-quality-survey/result", [
      "selectTabId",
      "controlDisp",
      "inspectionDate",
      "surveyRecord",
      // add FNSI-水質検査結果登録で備考欄を追加する 周 start
      "surveyRecordForMemo",
      // add FNSI-水質検査結果登録で備考欄を追加する 周 end
      "getInspectorCd",
      "getPickerCd",
      "surveyRecordDb"
    ]),
    ...mapGetters("user", ["getFacilityCd", "getUserId"]),
    // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
    // isChanged() {
    //   if (this.selectTabId === 0 || this.selectTabId === 1) {
    //     if (
    //       this.inspectionDay !== null ||
    //       this.collectionTime !== null ||
    //       this.pickerCd !== null ||
    //       this.inspectorCd !== null ||
    //       this.type1Value !== null ||
    //       this.type2Value !== null ||
    //       this.type1Text !== null ||
    //       this.type2Text !== null
    //     ) {
    //       return true;
    //     }
    //   }
    //   return false;
    // },
    changeFlg(){
      // 一括
      if(this.selectTabId === 0){
        // mod #11047 数値IF修正【最優先】 zt start
        let that = this;
        let rvArr = that.resultValue.filter(rst=> {
            if (rst && rst.index) {
                // mod #11047 数値IF修正【最優先】 linjunfeng start
                // let tmpMST = that.mstSurveyType.filter( mst => mst.surveyTypeCd === rst.index);
                // return tmpMST[0].initialValue !== rst.val;
                return "" !== rst.val;
                // mod #11047 数値IF修正【最優先】 linjunfeng end
            } else {
                return false;
            }
        });
        // mod #11047 数値IF修正【最優先】 zt end
        return JSON.stringify(this.initIspectionDay) !== JSON.stringify(this.inspectionDay)
        || JSON.stringify(this.initCollectionTime) !== JSON.stringify(this.collectionTime)
        || JSON.stringify(this.initPickerCd) !== JSON.stringify(this.pickerCd)
        || JSON.stringify(this.initInspectorCd) !== JSON.stringify(this.inspectorCd)
        || rvArr.length > 0
        || JSON.stringify(this.initTextValue) !== JSON.stringify(this.textValue)
      }else { // 一覧
        let copyListItem = JSON.parse(JSON.stringify(this.listItem))
        copyListItem && copyListItem.forEach(item => {
          delete item.show
        })
        //mod #11047 数値IF修正【最優先】 張玲 start
        // return JSON.stringify(this.initIspectionDay) !== JSON.stringify(this.inspectionDay)
        //     || JSON.stringify(this.initListItem) !== JSON.stringify(copyListItem)
        return !this.deepEqual(this.initIspectionDay,this.inspectionDay) || !this.deepEqual(this.initListItem,copyListItem)
        //mod #11047 数値IF修正【最優先】 張玲 end
      }
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
    },

    showItemList() {      
      if (!this.listItem.length) return [];
      
      // デフォルトソート順（親画面のソートを継承）でソート
      this.listItem = this.listItem.sort(
        (a, b) =>
          this.mntWaterSurvey.findIndex(x => x.pointCd === a.pointCd) -
          this.mntWaterSurvey.findIndex(x => x.pointCd === b.pointCd)
      );
      
      let { key, isAsc } = this.sort || {};
      if (key) {
        // 共通関数でソート
        this.listItem = this.listItem.sort((a, b) => {
          let aVal = a;
          let bVal = b;
          
          // 予定：昇順：〇（1:あり）＞空欄（0:なし）
          if (key === "plan") {
            aVal = a.surveyData;
            bVal = b.surveyData;
          }
          return sortableCompare(aVal, bVal, key, isAsc, { reverseFields: ["plan"] });
        });      
      }
      
      // this.listItem の並び順に合わせて初期値の配列(用途別で2つ存在する)も並び替え
      this.listItemInitial = this.listItemInitial.sort(
        (a, b) =>
          this.listItem.findIndex(x => x.pointCd === a.pointCd) -
          this.listItem.findIndex(x => x.pointCd === b.pointCd)
      );
      this.initListItem = this.initListItem ? this.initListItem.sort(
        (a, b) =>
          this.listItem.findIndex(x => x.pointCd === a.pointCd) -
          this.listItem.findIndex(x => x.pointCd === b.pointCd)) : null;
      
      return this.listItem;
    },
    // add FutreNetWeb+SI課題管理No5511 趙 start
    getPointCd() {
      const listPointCd = [];

      var list = [];
      this.listItem.forEach(item => {
        if (item.show) {
          list.push(item.surveyData)
        }
      });
      list.forEach(item => {
        if (item.memo != "" || item.text !== "" || item.time != "" || item.value != "" || item.picker != 0 || item.inspector != 0) {
          listPointCd.push(item);
        }

      });
      if (!this.changeFlg) {
        return listPointCd;
      } else {
        return [];
      }
    },
    // add FutreNetWeb+SI課題管理No5511 趙 end
    // (一括)ユーザー候補
    getUserInfo() {
      const userInfo = [];
      const currentUserId = Number(this.userId);
      const defaultUser = this.mstUser.find(item => item.userId === currentUserId);
      userInfo.push({ userId: defaultUser.userId, userLastName: defaultUser.userLastName, userFirstName: defaultUser.userFirstName, selectedStyle: "background-color: #0076ff !important; color: #fff;" });
      this.mstUser.forEach(item => {
        if (item.userId !== defaultUser.userId) {
          userInfo.push({ userId: item.userId, userLastName: item.userLastName, userFirstName: item.userFirstName, selectedStyle: "" });
        }
      });
      return userInfo;
    },
  },

  mounted() {
    this.setActiveTab();
    this.isPlanCkb = this.controlDisp[0];
    this.isResultCkb = this.controlDisp[1];
    this.isDispDel = this.controlDisp[2];
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
    this.copyDataForChanged();
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
    // (一括)タイトル幅調整
    const charSizes = [];
    this.mstSurveyType.forEach(item => {
      if (this.isDispSurveyType(item.surveyTypeCd)) {
        const title = item.surveyTypeName;
        const charSize = this.getCharSize(title);
        charSizes.push(charSize);
      }
    });
    this.mstSurveyType.forEach(item => {
      const targetId = "title-" + item.surveyTypeCd;
      const targetLabel = getScopedElementById(targetId, this);
      if (targetLabel != null) {
        const maxCharSize = Math.max(...charSizes) + 1;
        const val = maxCharSize > this.minWidth ? maxCharSize : this.minWidth;
        targetLabel.style = "width: " + val + "em;"
      }
    });
    // add #11047 数値IF修正【最優先】 linjunfeng start
    this.$nextTick(()=>{
      this.mstSurveyType.forEach((rec, index) => {
        if (this.isDispSurveyType(rec.surveyTypeCd)) {
          this.addInitialValue(rec.surveyTypeCd, rec.initialValue, rec.initialString, index)
        }
      })
    });
    // add #11047 数値IF修正【最優先】 linjunfeng end
  },

  watch: {
    // add FNSI-水質管理_青田の対応 徐 start
    selectedList(value) {
      const normalized = this.normalizeSelectedList(value);
      const raw = Array.isArray(value) ? value : [];
      if (normalized.length !== raw.length || normalized.some((v, i) => v !== String(raw[i]))) {
        this.selectedList = normalized;
        return;
      }
      //add #9558 水質管理一覧のヘッダ部から個別画面に遷移すると、機能帳票の制御が「一覧」のままになる 杜 start
      if (this.selectedAllList.length == 0) {
        let maListNew = [];
        for (var index = 0; index < normalized.length; index++) {
          maListNew[index] = this.listItem[parseInt(normalized[index], 10) - 1];
        }
        this.maList = maListNew;
      }
      EventBus.$emit("getMaList", this.maList);
      //add #9558 水質管理一覧のヘッダ部から個別画面に遷移すると、機能帳票の制御が「一覧」のままになる 杜 end
      this.$nextTick(() => {
        this.changeShow();
      });
    },
    // add FNSI-水質管理_青田の対応 徐 end
    selectTabId() {
      this.setActiveTab();
      if (this.selectTabId === 1) {
        this.$nextTick(() => {
          this.syncSelectedAllList(this.selectedList);
        });
      }
    },
    pickerCd(value) {
      this.setPickerCd(value);
    },
    inspectorCd(value) {
      this.setInspectorCd(value);
    },
    //add #9558 水質管理一覧のヘッダ部から個別画面に遷移すると、機能帳票の制御が「一覧」のままになる 杜 start
    inspectionDay(){
      EventBus.$emit("inspectionDay",this.inspectionDay);
    }
//add #9558 水質管理一覧のヘッダ部から個別画面に遷移すると、機能帳票の制御が「一覧」のままになる 杜 end
  },

  created() {
    // サインインユーザーIDの取得
    this.userId = String(this.getUserId);
    // add  FNSI-権限 姜 start
    this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    // add  FNSI-権限 姜 end
    this.toggleShowobject = this.controlDisp.isToggleShowObject;
    this.toggleShowResult = this.controlDisp.toggleShowResult;
    this.toggleShowPlan = this.controlDisp.toggleShowPlan;
    this.inputModel = JSON.parse(JSON.stringify(this.surveyRecord));
    if (this.selectTabId === 0) {
      if (this.getPickerCd !== -1) {
        this.pickerCd = this.getPickerCd;
      }

      if (this.getInspectorCd !== -1) {
        this.inspectorCd = this.getInspectorCd;
      }
    }

    const date = new Date();
    if (!this.controlDisp.isDisableDate) {
      this.inspectionDay = dayjs(date).format("YYYY-MM-DD");
      const currentTime = dayjs(date.getTime()).format("HH:mm");
      this.collectionTime = currentTime.toString();
    } else {
      this.inspectionDay = dayjs(this.inspectionDate.code).format(
        "YYYY-MM-DD");
    }
    // 検査日を退避
    this.backupInspectionDay = this.inspectionDay;    
    
    // add FNSI-水質管理_青田の対応 徐 start
    this.listItem = this.setList();
    // add FNSI-水質管理_青田の対応 徐 end
    // add FNSI-水質検査結果登録で備考欄を追加する 周 start
    // 水質検査結果備考登録画面が閉じられた時のイベントを登録する.
    // add 性能改善メモリ不足 shan start
    EventBus.$off("applyWaterResultMemoEditSubModal", this.closeWaterResultMemoEditSubModal);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("applyWaterResultMemoEditSubModal", this.closeWaterResultMemoEditSubModal);
    // add FNSI-水質検査結果登録で備考欄を追加する 周 end
    // add FNSI-改修内容6512修正 xuty start
    EventBus.$off("applyWaterResultMemoEditSubModalChange", this.closeWaterResultMemoEditSubModalChange);
    EventBus.$on("applyWaterResultMemoEditSubModalChange", this.closeWaterResultMemoEditSubModalChange);
    // add FNSI-改修内容6512修正 xuty end
  },

  // add FNSI-水質検査結果登録で備考欄を追加する 周 start
  /**
   * 画面を破棄する時の処理
   */
  beforeUnmount() {
    // 水質検査結果備考登録画面が閉じられた時のイベント解除する.
    EventBus.$off("applyWaterResultMemoEditSubModal", this.closeWaterResultMemoEditSubModal);
    EventBus.$off("applyWaterResultMemoEditSubModalChange", this.closeWaterResultMemoEditSubModalChange);
  },
  unmounted() {
    // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
    EventBus.$emit("isCheckResultFunc");
    // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
    // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
    store.dispatch("report/getMstReport", {funcCd: "03201",printFlag: 0});
    // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
  },
  // add FNSI-水質検査結果登録で備考欄を追加する 周 end

  methods: {
    requestViewForceUpdate() {
      if (this.$?.isMounted) {
        this.$forceUpdate();
      }
    },
    getTabContainerWidget() {
      return this.$refs.tabContainer?.kendoWidget?.() || null;
    },
    // 共通ローダー設定
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("water-quality-survey/result", [
      "setSelectTabId",
      "setSurveyRecord",
      "setPickerCd",
      "setInspectorCd",
      "setInspectionDate"
    ]),
    ...mapActions("water-quality-survey/list", ["setSelectedList"]),
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    ...mapMutations("water-quality-survey/result", ["setSurveyResultList"]),
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add  FNSI-権限 姜 start
    getTreatmentRecordAuthority() {
      return this.hasAuthorityByCd(AUTHORITY_CODES.DEV_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.DEV_EDIT);
    },
    // (一覧)ユーザー候補
    getUserInfoList(selectedUserId) {
      const userInfoList = [];
      const currentUserId = Number(this.userId);
      let defaultUser = null;
      if (selectedUserId === 0) {
        defaultUser = this.mstUser.find(item => item.userId === currentUserId);
        userInfoList.push({ userId: defaultUser.userId, userLastName: defaultUser.userLastName, userFirstName: defaultUser.userFirstName, selectedStyle: "background-color: #0076ff !important; color: #fff;" });
      } else {
        defaultUser = this.mstUser.find(item => item.userId === selectedUserId);
        userInfoList.push({ userId: defaultUser.userId, userLastName: defaultUser.userLastName, userFirstName: defaultUser.userFirstName, selectedStyle: "background-color: #0076ff !important; color: #fff;" });
      }
      this.mstUser.forEach(item => {
        if (item.userId !== defaultUser.userId) {
          userInfoList.push({ userId: item.userId, userLastName: item.userLastName, userFirstName: item.userFirstName, selectedStyle: "" });
        }
      });
      return userInfoList;
    },
    // add  FNSI-権限 姜 end
    getTabItemIndex(item) {
      if (!item?.parentNode?.children) {
        return 0;
      }
      return Array.prototype.indexOf.call(item.parentNode.children, item);
    },
    syncTabHeaderState(tabId) {
      const tabs = [this.$refs.tabBatch, this.$refs.tabList];
      tabs.forEach((tab, index) => {
        if (tab) {
          tab.classList.toggle("k-state-active", index === tabId);
        }
      });
    },
    changeTab(e) {
      const tabId = typeof e?.itemIndex === "number" ? e.itemIndex : this.getTabItemIndex(e?.item);
      this.syncTabHeaderState(tabId);
      this.setSelectTabId(tabId);
      if (tabId === 1) {
        this.$nextTick(() => {
          this.syncSelectedAllList(this.selectedList);
        });
      }
    },
    //add #11047 数値IF修正【最優先】 張玲 start
    /**
     * 二つのオブジェクトが深く等しいかどうかを判定する
     * このメソッドは、二つのオブジェクトのすべてのプロパティとその値が完全に一致しているかを比較します、ネストされたオブジェクトも含む
     * @param {any} obj1 - 比較する最初のオブジェクト
     * @param {any} obj2 - 比較するもう一つのオブジェクト
     * @returns {boolean} - オブジェクトが等しければtrueを返す、そうでなければfalseを返す
     */
     deepEqual(obj1, obj2) {
      // 二つのオブジェクトが同じ参照をしていたら、それらは等しい
      if (obj1 == obj2) {
        return true;
      }
      // いずれかのオブジェクトがオブジェクトタイプでないかnullだった場合、それらは等しくない
      if (typeof obj1 !== 'object' || obj1 === null ||
          typeof obj2 !== 'object' || obj2 === null) {
        return false;
      }
      // 二つのオブジェクトのキー名配列を取得
      const keys1 = Object.keys(obj1);
      const keys2 = Object.keys(obj2);

      // もしキーの数が異なるなら、オブジェクトは等しくない
      if (keys1.length !== keys2.length) {
        return false;
      }
      // 最初のオブジェクトのすべてのキーをループ
      for (const key of keys1) {
        // もし二番目のオブジェクトにこのキーが存在しない、またはこのキーに対応する値が二番目のオブジェクトの中の値と等しくないなら、オブジェクトは等しくない
        if (!keys2.includes(key) || !this.deepEqual(obj1[key], obj2[key])) {
          return false;
        }
      }
      // 上記のチェックを経て、もし全てのキーと値が等しかったら、オブジェクトは等しい
      return true;
    },
    //add #11047 数値IF修正【最優先】 張玲 end
    //add #11047 数値IF修正【最優先】 張玲 start
    handlerStep(rec){
      const surveyType = this.mstSurveyType.find(
        i => +i.surveyTypeCd === +rec.surveyTypeCd
      );
      return this.unitStep(surveyType.decimalDigits)
    },
    //小数点の桁数を取得
    unitStep(decPoint) {
      var num = parseInt(decPoint);
      if(isNaN(num)){
        return 1;
      }
      var data = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());
      return data;
    },
    handlerMin(rec){
      const surveyType = this.mstSurveyType.find(
        i => +i.surveyTypeCd === +rec.surveyTypeCd
      );
      let integerDigits = surveyType?.integerDigits;// 整数位
      let decimalDigits = surveyType?.decimalDigits;// 小数位
      return -Math.pow(10, integerDigits) + Number(`0.${'0'.repeat(decimalDigits - 1)}1`);
    },
    handlerMax(rec){
      const surveyType = this.mstSurveyType.find(
        i => +i.surveyTypeCd === +rec.surveyTypeCd
      );
      let integerDigits = surveyType?.integerDigits;// 整数位
      let decimalDigits = surveyType?.decimalDigits;// 小数位
      return Math.pow(10, integerDigits) - Number(`0.${'0'.repeat(decimalDigits - 1)}1`);
    },
    //add #11047 数値IF修正【最優先】 張玲 end
    // add FNSI-水質管理_青田の対応 徐 start
    normalizeSelectedList(value) {
      return [...new Set((Array.isArray(value) ? value : []).map(v => String(v)))];
    },
    getSelectableListIndices() {
      const indices = [];
      this.listItem.forEach((item, k) => {
        if (item.show) {
          indices.push(String(k + 1));
        }
      });
      return indices;
    },
    syncSelectedAllList(selectedList) {
      const normalized = this.normalizeSelectedList(selectedList);
      const selectable = this.getSelectableListIndices();
      const isAllSelected =
        selectable.length > 0 &&
        selectable.length === normalized.length &&
        selectable.every(id => normalized.includes(id));
      this.selectedAllList = isAllSelected ? ["-1"] : [];
    },
    changeShow() {
      this.showListItem(this.listItem, 1);
      // add #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe start
      EventBus.$emit("setToggleShowobject", this.toggleShowobject);
      // add #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe end
    },
    showListItem(list, flg) {
      const valueClassList = [];
      const textClassList = [];
      const timeClassList = [];
      const pickerClassList = [];
      const inspectorClassList = [];
      if (flg == 1) {
        for (var i = 0; i < list.length; i++) {
          if (getScopedElementById('value_' + i, this) != null && getScopedElementById('value_' + i, this).classList.length > 0
            && getScopedElementById('value_' + i, this).classList.contains("custom-input-edited")){
            valueClassList.push("custom-input-edited");
          } else {
            valueClassList.push("");
          }
          if (getScopedElementById('time_' + i, this) != null && getScopedElementById('time_' + i, this).classList.length > 0
            && getScopedElementById('time_' + i, this).classList.contains("custom-input-edited")){
            timeClassList.push("custom-input-edited");
          } else {
            timeClassList.push("");
          }
          if (getScopedElementById('text_' + i, this) != null && getScopedElementById('text_' + i, this).classList.length > 0
            && getScopedElementById('text_' + i, this).classList.contains("custom-select-edited")){
            textClassList.push("custom-select-edited");
          } else {
            textClassList.push("");
          }
          if (getScopedElementById('picker_' + i, this) != null && getScopedElementById('picker_' + i, this).classList.length > 0
            && getScopedElementById('picker_' + i, this).classList.contains("custom-select-edited")){
            pickerClassList.push("custom-select-edited");
          } else {
            pickerClassList.push("");
          }
          if (getScopedElementById('inspector_' + i, this) != null && getScopedElementById('inspector_' + i, this).classList.length > 0
            && getScopedElementById('inspector_' + i, this).classList.contains("custom-select-edited")){
            inspectorClassList.push("custom-select-edited");
          } else {
            inspectorClassList.push("");
          }
        }
      }
      var listIndex = 0;
      this.showItem = [];
      list.forEach(item => {
        listIndex = listIndex + 1;
        // 対象のみ表示
        var showobject = this.selectedList.indexOf(listIndex + "") !== -1;
        var showPred = item.surveyData.plan !== 0;
        if (this.toggleShowobject && this.toggleShowPred) {
          if (showobject || showPred) {
            item["show"] = true;
          } else {
            item["show"] = false;
          }
        } else if (this.toggleShowobject && !this.toggleShowPred) {
          if (showobject) {
            item["show"] = true;
          } else {
            item["show"] = false;
          }
        } else if (!this.toggleShowobject && this.toggleShowPred) {
          if (showPred) {
            item["show"] = true;
          } else {
            item["show"] = false;
          }
        } else {
          item["show"] = true;

        }
        if (item["show"] == false) {
          const itemInitial = this.listItemInitial[listIndex - 1].surveyData;
          item.surveyData.time = itemInitial.time;
          item.surveyData.text = itemInitial.text;
          item.surveyData.value = itemInitial.value;
          item.surveyData.picker = itemInitial.picker;
          item.surveyData.memo = itemInitial.memo;
          item.surveyData.inspector = itemInitial.inspector;
        }
      });
      let showList = this.selectedList;
      var thislist = list;
      setTimeout(() => {
        for (var i = 0; i < thislist.length; i++) {
          if (getScopedElementById('select-' + i, this) != null) {
            if (showList.indexOf(i + 1 + "") !== -1) {
              getScopedElementById('select-' + i, this).checked = true;
              this.showItem.push(list[i]);
            } else {
              getScopedElementById('select-' + i, this).checked = false;
            }
          }
          if (valueClassList.length > 0) {
            if (getScopedElementById('value_' + i, this) != null) {
              getScopedElementById('value_' + i, this).classList.remove("custom-input-edited");
              if (valueClassList[i] != "") {
                getScopedElementById('value_' + i, this)?.classList?.add(valueClassList[i]);
              }
            }
            if (getScopedElementById('time_' + i, this) != null) {
              getScopedElementById('time_' + i, this).classList.remove("custom-input-edited");
              if (timeClassList[i] != "") {
                getScopedElementById('time_' + i, this)?.classList?.add(timeClassList[i]);
              }
            }
            if (getScopedElementById('text_' + i, this) != null) {
              getScopedElementById('text_' + i, this).classList.remove("custom-select-edited");
              if (textClassList[i] != "") {
                getScopedElementById('text_' + i, this)?.classList?.add(textClassList[i]);
              }
            }
            if (getScopedElementById('picker_' + i, this) != null) {
              getScopedElementById('picker_' + i, this).classList.remove("custom-select-edited");
              if (pickerClassList[i] != "") {
                getScopedElementById('picker_' + i, this)?.classList?.add(pickerClassList[i]);
              }
            }
            if (getScopedElementById('inspector_' + i, this) != null) {
              getScopedElementById('inspector_' + i, this).classList.remove("custom-select-edited");
              if (inspectorClassList[i] != "") {
                getScopedElementById('inspector_' + i, this)?.classList?.add(inspectorClassList[i]);
              }
            }
          }
        }
      }, 100)
      getScopedSessionStorage(this.$el || this).setItem('selectedList', JSON.stringify(this.selectedList));
      this.syncSelectedAllList(this.selectedList);
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      this.setSurveyResultList(list);
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      return list;
    },
    setList() {
      let list = JSON.parse(JSON.stringify(this.inputModel));
      this.listItemInitial = JSON.parse(JSON.stringify(this.inputModel));
      for (var j = 0; j < list.length; j++) {
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
        // this.textValue.push("0");
        this.textValue.push(1);
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
      }
      if (this.setCheckedFlg) {
        const initialSelected = [];
        for (var i = 0; i < list.length; i++) {
          if (list[i].surveyData.index === 1) {
            initialSelected.push(String(i + 1));
          }
        }
        this.selectedList = initialSelected;
        this.setCheckedFlg = false;
      }
      list = this.showListItem(list, 0);
      return list;
    },
    setChecked() {
      // ケースチェックボックスすべて選択が選択されています
      if (this.selectedAllList.length > 0) {
        // ケースチェックボックスは選択されていないすべてを選択します
        this.selectedList = [];
      } else {
        // mod FutreNetWeb+SI課題管理No5505 趙 start
        // this.selectedList = Object.keys(this.listItem).map(k =>
        //   (+k + 1).toString()
        // );
        var k = 0;
        this.selectedList = [];
        this.listItem.forEach(item => {
            if(item.show){
              this.selectedList.push((k + 1).toString())
            }
            k = k + 1;
        });
      }
      // mod FutreNetWeb+SI課題管理No5505 趙 end
      this.changeShow();
    },
    /**
     * 水質検査結果備考登録モーダルを閉じた時のイベント
     */
    closeWaterResultMemoEditSubModal() {
      this.listItem[this.surveyRecordForMemo.index].surveyData.memo = this.surveyRecordForMemo.memo;
    },
    // add FNSI-水質検査結果登録で備考欄を追加する 周 end
    // add FNSI-改修内容6512修正 xuty start
    closeWaterResultMemoEditSubModalChange() {
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      // this.changeFlg = true;
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
      this.listItem[this.surveyRecordForMemo.index].surveyData.memo = this.surveyRecordForMemo.memo;
    },
    // add FNSI-改修内容6512修正 xuty end
    setActiveTab(retryCount = 0) {
      const tabContainer = this.getTabContainerWidget();
      const tabList = this.$refs.tabList;
      const tabBatch = this.$refs.tabBatch;
      if (!tabContainer || !tabList || !tabBatch) {
        // Vue3 では KendoTabStrip の jQuery widget 生成が親 mounted より後になる場合があるため、Vue2 と同じ初期タブ反映を widget 準備後に行う。
        if (retryCount < 10) {
          this.$nextTick(() => {
            const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
            ownerWindow.setTimeout(() => {
              if (!this.$?.isUnmounted) {
                this.setActiveTab(retryCount + 1);
              }
            }, 0);
          });
        }
        return;
      }
      if (this.selectTabId === 1) {
        tabContainer.enable(tabList);
        tabContainer.activateTab(tabList);
      } else {
        tabContainer.enable(tabBatch);
        tabContainer.activateTab(tabBatch);
      }
      this.syncTabHeaderState(this.selectTabId);
    },

    isDispSurveyType(cd) {
      let show = false;
      this.inputModel.forEach(rec => {
        if (rec.surveyTypeCd === cd) {
          show = true;
        }
      });
      return show;
    },

    /**
     * 箇所名を吹き出しで全件表示
     */
    showPopOver(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
    },

    getUnitByPointCd(cd) {
      let unit = "";
      const surveyType = this.mstSurveyPoint.find(r => {
        return r.surveyPointCd === cd;
      });
      if (surveyType) {
        const findItem = this.mstSurveyType.find(t => {
          return t.surveyTypeCd == surveyType.surveyTypeCd;
        });
        if (findItem && findItem.unit) {
          unit = findItem.unit;
        }
      }
      return unit;
    },

    // 単位情報の取得
    getUnitInfo(rec) {
      // 初期化処理
      let unit = "";
      // 結果データ ≠ ""の場合
      if (rec.surveyData.value !== "") {
        // 水質データ.単位(過去の登録内容)の取得
        unit = rec.surveyData.unit;
      } else {
        // (最新)水質検査種別マスタ.単位の単位
        unit = this.getUnitByPointCd(rec.pointCd);
      }
      return unit;
    },

    close() {
      // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
      EventBus.$emit("isCheckResultFunc");
      // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
      // mod FNSI-redmine3998 徐 start
      // if (this.isChanged) {
      // if ((this.showItem.length > 0 || this.selectTabId == 1) && this.changeFlg && this.isChanged) {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      // if ((this.showItem.length > 0 || this.selectTabId == 1) && this.changeFlg) {
      if (this.changeFlg) {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
      // mod FNSI-redmine3998 徐 end
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              // add FNSI-水質管理_青田の対応 徐 start
              getScopedSessionStorage(this.$el || this).setItem('breakCheck', JSON.stringify("1"));
              // add FNSI-水質管理_青田の対応 徐 end
              this.hideModal();
            }
          }
        });
        return;
      }
      // add FNSI-水質管理_青田の対応 徐 start
      getScopedSessionStorage(this.$el || this).setItem('breakCheck', JSON.stringify("1"));
      // add FNSI-水質管理_青田の対応 徐 end
      this.hideModal();
    },

    mapData(key, value) {
      this.listItem.forEach(item => {
        // mod FNSI-水質管理_青田の対応 徐 start
        if (item.show) {
        // mod FNSI-水質管理_青田の対応 徐 end
        item.surveyData[key] = value;
        // mod FNSI-水質管理_青田の対応 徐 start
        }
        // mod FNSI-水質管理_青田の対応 徐 end
      });
    },
    // mod FNSI-#3404(起票):初期値が表示 韓 start
    mapDataByTypeCd(key) {
      this.listItem.forEach(item => {
        // mod FNSI-水質管理_青田の対応 徐 start
        /*let result = 0;
          if ("value" === key) {
            result = getScopedElementById('value-' + item.surveyTypeCd, this).value;
          }else if ("text" === key) {
            result = getScopedElementById('text-' + item.surveyTypeCd, this).value;
          }
          item.surveyData[key] = +result;*/

        // mod #11047 数値IF修正【最優先】 zt start
        if (item.show) {
          let result = 0;
          if ("value" === key) {
            result = getScopedElementById('value-' + item.surveyTypeCd, this).value;
            if (result) {
              item.surveyData[key] = result;
            }
          }else if ("text" === key) {
            result = getScopedElementById('text-' + item.surveyTypeCd, this).value;
            if (result && result !== "0") {
              item.surveyData[key] = result;
            }
          }
        }
        // mod #11047 数値IF修正【最優先】 zt end
        // mod FNSI-水質管理_青田の対応 徐 end
      });
    },
    // mod FNSI-#3404(起票):初期値が表示 韓 end
    async updateData(data) {
      let copyList = JSON.parse(JSON.stringify(data));

      let surveyRecordNo = null;
      let surveyData = [];

      let listInspectionDateDb = await this.getSurveyRecordDB(
        dayjs(this.inspectionDay).format("YYYYMMDD"),
        dayjs(this.inspectionDay).format("YYYYMMDD"));
      if (listInspectionDateDb && listInspectionDateDb.length) {
        const existRecord = listInspectionDateDb.find(r => {
          const date = dayjs(r.inspectionDate).format("YYYY-MM-DD");

          return date == this.inspectionDay;
        });
        if (existRecord) {
          surveyRecordNo = existRecord.surveyRecordNo;
          surveyData = JSON.parse(existRecord.surveyData);
        }
      }

      copyList.forEach(d => {
        // del FNSI-バグ 水質管理771 徐 start
        // d.surveyData.plan = 1;
        // del FNSI-バグ 水質管理771 徐 end
        const index = surveyData.findIndex(i => i.point_cd == d.pointCd);
        if (index !== -1) {
          surveyData[index] = d.surveyData;
        } else {
          surveyData = [...surveyData, d.surveyData];
        }
      });
      surveyData.forEach(d => {
        d.inspector = +d.inspector;
        d.picker = +d.picker;
        delete d.inspectionDate;
        delete d.status;
      });
      const dataInsert = [
        {
          surveyRecordNo: surveyRecordNo,
          facilityCd: this.getFacilityCd,
          inspectionDate: dayjs(this.inspectionDay).format(),
          surveyData: surveyData,
          isDisp: "1",
          isDel: "0"
        }
      ];
      try {
        await ApiHelper.post("/waterSurvey/saveMulti", dataInsert);
        EventBus.$emit("filter");
        this.hideModal();
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('WaterResultModal.vue','updateData',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        this.hideModal();
        this.internalServerError(error);
      }
    },
    // (一括)結果初期値の追加
    addInitialValue(cd, value, text, index) {
      const currentInputBox = getScopedElementById("value-" + cd, this);
      const currentDDL = getScopedElementById("text-" + cd, this);
      if (currentInputBox.value === null || currentInputBox.value === "") {
        // -----数値-----
        currentInputBox.value = value;
        // #11047 数値IF修正【最優先】 linjunfeng start
        // currentInputBox?.classList?.add("custom-input-edited");
        if (value) {
          currentInputBox?.classList?.add("custom-input-edited");
        }
        // #11047 数値IF修正【最優先】 linjunfeng end
        //mod #11945 水質管理 結果文字列に関する複数のバグ zrx start
        // if (currentDDL.value === null || currentDDL.value === "" || currentDDL.value === "1") {
        if (currentDDL?.value === null || currentDDL?.value === "" || currentDDL?.value === "1") {
        //mod #11945 水質管理 結果文字列に関する複数のバグ zrx end
          // -----初期文字列-----
          // #11047 数値IF修正【最優先】 linjunfeng start
          // currentDDL.text = this.checkText(text);
          // this._compatSet(this.textValue, index, this.checkText(text));
          // currentDDL?.classList?.add("custom-select-edited");
          currentDDL.text = this.checkText(text) == '' ? 1 : this.checkText(text);
          ((this.textValue)[index] = currentDDL.text);
          if (currentDDL.text != 1) {
            currentDDL?.classList?.add("custom-select-edited");
          }
          // #11047 数値IF修正【最優先】 linjunfeng end
        }
      }
      this.focusFlg[index] = true;
    },
    // (一括)初期文字列の変更
    changeInitialText(cd) {
      const currentDLL = getScopedElementById("text-" + cd, this);
      const currentValue = Number(currentDLL.value);
      const initValue = 1;
      if (initValue !== currentValue) {
        currentDLL?.classList?.add("custom-select-edited");
      } else {
        currentDLL.classList.remove("custom-select-edited");
      }
    },
    // add FNSI-バグ 水質管理779 徐 start
    checkText(text){
      const initialString = JSON.parse(text);
      for (var i = 0; i < initialString.length; i++) {
        if (initialString[i].checked) {
          //mod #11945 水質管理 結果文字列に関する複数のバグ zrx start
          // return i + 1;
          return initialString[i].text;
          //mod #11945 水質管理 結果文字列に関する複数のバグ zrx end
        }
      }
      return "";
    },
    getResult(surveyTypeCd, pointCd) {
      if (this.getResultText.get(surveyTypeCd)) {
        //mod #11945 水質管理 結果文字列に関する複数のバグ zrx start
        // return JSON.parse(this.getResultText.get(surveyTypeCd));
        const resultTextList = JSON.parse(this.getResultText.get(surveyTypeCd));
        var selectedDate = dayjs(this.inspectionDay).format("YYYYMMDD");
        let copyList = JSON.parse(JSON.stringify(this.mntWaterSurvey));
        const filtered = copyList.flatMap(item =>
          item.surveyData.filter(d => {
            const date = dayjs(d.inspectionDate).format("YYYYMMDD");
            return date == selectedDate;
          })
        );
        //マスタの文字列 delete
        if (filtered.length > 0) {
          filtered.forEach(d => {
            if (!d) return;
            const t = d.text;
            if (t === null || t === undefined) return;
            const s = String(t).trim();
            if (s !== "" && s !== "0") {
              const exists = resultTextList.some(entry => String(entry.text).trim() === s);
              if (!exists && pointCd === d.point_cd) {
                resultTextList.push({
                  cd: s,
                  text: s
                });
              }
            }
          });
        }
        return resultTextList;
        //mod #11945 水質管理 結果文字列に関する複数のバグ zrx end
      } else {
        return "";
      }
    },
    // 結果文字列設定の表示有無
    isShowInitialText(surveyTypeCd) {
      return this.getResultText.get(surveyTypeCd) != null ? true : false;
    },
    // add FNSI-水質管理_青田の対応 徐 end
    // mod FNSI-redmine4003 徐 start
    async getListByDate() {
      // 前回リスト検索時と検査日が同じ場合はreturn
      if (this.backupInspectionDay === this.inspectionDay) {
        return;
      }
      // 検査日を退避
      this.backupInspectionDay = this.inspectionDay;

      let listInspectionDateDb = [];
      let response = [];
      var selectedDate = dayjs(this.inspectionDay).format("YYYYMMDD");
      var startDate = selectedDate;
      var endDate = selectedDate;
      const url = `waterSurvey/filter`;
      const postParams = {
        startDate,
        endDate,
        listSurveytypeCd: [],
        listBedGroupCd: []
      };
      try {
        this.setLoadingScreenVisible(true);
        response = await ApiHelper.post(url, postParams);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage('WaterQualitySurveyComponent.vue','getSurveyRecordDB',error);
        this.setLoadingScreenVisible(false);
        this.internalServerError(error);
      }

      if (response && response.data) {
        listInspectionDateDb = response.data;
      }
      let surveyRecordNo = null;
      if (listInspectionDateDb && listInspectionDateDb.length) {
        const existRecord = listInspectionDateDb.find(r => {
          const date = dayjs(r.inspectionDate).format("YYYYMMDD")
          return date == selectedDate;
        });
        if (existRecord) {
          surveyRecordNo = existRecord.surveyRecordNo;
        }
      }

      let copyList = JSON.parse(JSON.stringify(this.mntWaterSurvey));
      copyList.forEach(rec => {
        rec.surveyRecordNo = surveyRecordNo;
        /**
         * 選択した日付に基づいて調査データをフィルタリングする
         */
        const filtered = rec.surveyData.filter(d => {
          const date = dayjs(d.inspectionDate).format("YYYYMMDD");
          return date == selectedDate;
        });
        if (filtered && filtered.length) {
          rec.surveyData = filtered[0];
        } else {
          rec.surveyData = {};
          rec.surveyData.plan = 0;
          rec.surveyData.text = "";
          rec.surveyData.time = "";
          rec.surveyData.unit = this.getUnitByPointCd(rec.pointCd);
          rec.surveyData.value = "";
          rec.surveyData.picker = 0;
          rec.surveyData.point_cd = rec.pointCd;
          rec.surveyData.inspector = 0;
          rec.surveyData.memo = "";
        }
      });
      for (var i = 0; i < copyList.length; i++) {
        var selectindex = 0;
        if (this.selectedList != null && this.selectedList.indexOf(i + 1 + "") != -1) {
          selectindex = 1;
        }
        const surveyItemNew =
          {
            point_cd: copyList[i].surveyData.point_cd,
            plan: copyList[i].surveyData.plan,
            time: copyList[i].surveyData.time,
            picker: copyList[i].surveyData.picker,
            inspector: copyList[i].surveyData.inspector,
            value: copyList[i].surveyData.value,
            text: copyList[i].surveyData.text,
            memo: copyList[i].surveyData.memo,
            unit: copyList[i].surveyData.unit,
            index: selectindex
          };
        copyList[i].surveyData = surveyItemNew;
      }

      // del FNSI-改修内容6314修正 xuty start
      // if (this.getSelectedList && this.getSelectedList.length) {
      //   const arrIndex = this.getSelectedList.map(value => {
      //     return +value - 1;
      //   });
      //   copyList = copyList.filter((v, i) => {
      //     return arrIndex.includes(i);
      //   });
      // }
      // del FNSI-改修内容6314修正 xuty end
      this.listItem = copyList;
      this.changeShow();
    },
    // mod FNSI-redmine4003 徐 end
    // mod FNSI-水質管理_青田の対応 徐 start
    // async deleteResult() {
    async deleteResult(flg) {
    // mod FNSI-水質管理_青田の対応 徐 end
      let titleStr = "";
      let messageStr = "";
      if (flg === 1) {
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // titleStr = "水質検査削除確認";
        titleStr = DIALOG_MESSAGES[13000154].title;
        // messageStr = "選択した水質検査の予定と結果を削除します。<br>削除すると二度と元に戻せません。削除してもよろしいですか？";
        messageStr = messageFormat(DIALOG_MESSAGES[13000154].message);
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
      } else if (flg === 2) {
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // titleStr = "水質検査結果削除確認";
         titleStr = DIALOG_MESSAGES[13000155].title;
        // messageStr = "選択した水質検査の結果のみ削除します。予定は削除しません。<br>削除すると二度と元に戻せません。削除してもよろしいですか？";
        messageStr = messageFormat(DIALOG_MESSAGES[13000155].message);
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
      }
      this.$ons.notification.confirm({
        title: titleStr,
        // mod FNSI-水質管理_青田の対応 徐 start
        // message:
        //   "予定と結果すべてを削除します。削除すると二度と戻せませんがよろしいですか？",
        message: messageStr,
        // mod FNSI-水質管理_青田の対応 徐 end
        callback: async answer => {
          if (answer === 1) {
            if (this.inputModel.length === 0) {
              this.hideModal();
              return;
            }
            let listPointCd = [];
            let surveyRecordNo = null;
            // add FNSI-水質管理_青田の対応 徐 start
            var index = 0;
            // add FNSI-水質管理_青田の対応 徐 end
            this.inputModel.forEach(item => {
              surveyRecordNo = item.surveyRecordNo;
              // del FNSI-バグ 水質管理771 徐 start
              // if (item.surveyData.plan == 1) {
              // del FNSI-バグ 水質管理771 徐 end
              // add FNSI-水質管理_青田の対応 徐 start
              index++;
              if (this.selectedList != null && this.selectedList.indexOf(index + "") !== -1){
              // add FNSI-水質管理_青田の対応 徐 end
              listPointCd.push(item.pointCd);
              // add FNSI-水質管理_青田の対応 徐 start
              }
              // add FNSI-水質管理_青田の対応 徐 end
              // del FNSI-バグ 水質管理771 徐 start
              // }
              // del FNSI-バグ 水質管理771 徐 end
            });
            if (surveyRecordNo == null) {
              this.hideModal();
              return;
            }
            try {
              const params = {
                listPointCd: JSON.stringify(listPointCd)
              };
              // add FNSI-水質管理_青田の対応 徐 start
              getScopedSessionStorage(this.$el || this).setItem('breakCheck', JSON.stringify("1"));
              if (flg == 1) {
              // add FNSI-水質管理_青田の対応 徐 end
              await ApiHelper.post(
                `/waterSurvey/${surveyRecordNo}/removeListSurveyData`,
                params
              );
              // add FNSI-水質管理_青田の対応 徐 start
              } else {
                await ApiHelper.post(
                  `/waterSurvey/${surveyRecordNo}/deleteListSurveyData`,
                  params
                );
              }
              // add FNSI-水質管理_青田の対応 徐 end
              EventBus.$emit("filter");
            } catch (error) {
              //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
              getErrorMessage('WaterResultModal.vue','deleteResult',error);
              //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
              this.internalServerError(error);
            }
            this.hideModal();
          }
        }
      });
    },

    async save() {
      let readyUpdate = true;
      this.arrValidateResult.forEach(obj => {
        if (!obj.valid && obj.tabId === this.selectTabId) {
          readyUpdate = false;
        }
      });
      // mod FNSI-水質管理_青田の対応 徐 start
      if (this.inspectionDay === null || this.inspectionDay === "") {
        this.$ons.notification.alert({
          // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
          // title: "",
          // message: "検査日が無効です",
          title: DIALOG_MESSAGES[12000276].title,
          message: messageFormat(DIALOG_MESSAGES[12000276].message),
          // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // mod FNSI-水質管理_青田の対応 徐 end
      if (this.inputModel.length === 0) {
        this.hideModal();
        return;
      }
      if (this.selectTabId === 0) {
        this.mappingData();
      }
      // mod FNSI-水質管理_青田の対応 徐 start
      // this.updateData(this.listItem);
      const saveItem = [];
      if (this.selectTabId === 1) {
        // -----一覧タブ-----
        for (var i = 0; i < this.listItem.length; i++) {
          if (this.listItem[i].show) {
            saveItem.push(this.listItem[i]);
          }
        }
      } else {
        // -----一括タブ-----
        for (var i0 = 0; i0 < this.listItem.length; i0++) {
          if (this.selectedList.indexOf(i0 + 1 + "") >= 0) {
            // 単位の更新
            const targetId = "unit-" + this.listItem[i0].surveyTypeCd;
            const targetLabel = getScopedElementById(targetId, this);
            if (targetLabel != null) {
              this.listItem[i0].surveyData.unit = targetLabel.innerText;
            }
            saveItem.push(this.listItem[i0]);
          }
        }
      }
      this.updateData(saveItem);
      getScopedSessionStorage(this.$el || this).setItem('breakCheck', JSON.stringify("1"));
      // mod FNSI-水質管理_青田の対応 徐 end
      this.arrValidateResult = [];
    },
    internalServerError(error) {
      console.log(error);
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // this.$ons.notification.alert("システムエラーが発生しました。", {
      //   title: "エラー"
      // });
      this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message), {
        title: DIALOG_MESSAGES['00200002'].title
      });
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
    },

    mappingData() {
      // mod FNSI-水質管理_青田の対応 徐 start
      /*this.mapData("time", this.collectionTime);
      this.mapData("picker", this.pickerCd);
      this.mapData("inspector", this.inspectorCd);
      // mod FNSI-#3404(起票):初期値が表示 韓 start
      this.mapDataByTypeCd("value");
      this.mapDataByTypeCd("text");*/
      // mod FNSI-#3404(起票):初期値が表示 韓 end
      if (this.collectionTime != null && this.collectionTime != "") {
        this.mapData("time", this.collectionTime);
      }
      if (this.pickerCd != null && this.pickerCd != "") {
        this.mapData("picker", this.pickerCd);
      }
      if (this.inspectorCd != null && this.inspectorCd != "") {
        this.mapData("inspector", this.inspectorCd);
      }
      this.mapDataByTypeCd("value");
      this.mapDataByTypeCd("text");
      // mod FNSI-水質管理_青田の対応 徐 end
    },
    // (一括)結果入力幅の調整
    adjustInputBox(rec, event) {
      const inputBoxLengths = this.getInputBoxLengths(rec.surveyTypeCd);
      const inputBoxMaxLength = event.currentTarget.value.length > Math.max(...inputBoxLengths) ? event.currentTarget.value.length : Math.max(...inputBoxLengths);
      this.mstSurveyType.forEach(item => {
        const targetId = "value-" + item.surveyTypeCd;
        const targetInputBox = getScopedElementById(targetId, this);
        if (targetInputBox != null) {
          targetInputBox.style = "width: " + inputBoxMaxLength + "em;"
        }
      });
    },
    // (一覧)結果入力幅の調整
    adjustInputBoxList(event, name) {
      const inputBoxLengthList = this.getInputBoxLengthList(name);
      const inputBoxMaxLength = event.currentTarget.value.length > Math.max(...inputBoxLengthList) ? event.currentTarget.value.length : Math.max(...inputBoxLengthList);
      for (var i = 0; i < this.listItem.length; i++) {
        const targetId = name + "_" + i;
        const targetInputBox = getScopedElementById(targetId, this);
        if (targetInputBox != null) {
          targetInputBox.style = "width: " + inputBoxMaxLength + "em;"
        }
      }
    },
    validateResultValue(rec, $event, cd) {
      const surveyType = this.mstSurveyType.find(
        i => +i.surveyTypeCd === +rec.surveyTypeCd
      );
      const max = [0,9.999,99,999.9];
      if (parseFloat($event.target.value) > max[surveyType.integerDigits]) {
        this.blurFlg = true;
      } else if (parseFloat($event.target.value) < this.min) {
        this.blurFlg = true;
      } else {
        this.blurFlg = false;
      }
      // add FNSI-redmine3998 徐 start
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      // this.changeFlg = true;
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
      // add FNSI-redmine3998 徐 end
      let check = this.validateResult(rec.surveyTypeCd, $event);
      // mod #5589 2023/04/07 数値IFのスタイル全不正 張博 start
      // if (!check) {
      //   this.$ons.notification.alert({
      //     // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
      //     // title: "",
      //     // message: "結果値が無効です",
      //     title: DIALOG_MESSAGES[12000277].title,
      //     message: messageFormat(DIALOG_MESSAGES[12000277].message),
      //     // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
      //   });
      // }
	  // mod #5589 2023/04/07 数値IFのスタイル全不正 張博 end
      const foundIndex = this.arrValidateResult.findIndex(
        item => +item.cd === +cd && item.tabId === this.selectTabId
      );
      if (foundIndex !== -1) {
        this.arrValidateResult[foundIndex].valid = check;
      } else {
        // del 水質管理:不正チェックの結果登録しました 林峻峰 start
        // let objValidate = {
        //   valid: check,
        //   cd: cd,
        //   tabId: this.selectTabId
        // };
        // this.arrValidateResult.push(objValidate);
        // del 水質管理:不正チェックの結果登録しました 林峻峰 end
      }
    },
    // mod #5589 2023/04/13 数値IFのスタイル全不正 林峻峰 start
    handleMouseWheel(rec, e,index) {
      if (!this.focusFlg[index]) {
        return;
      }
      const surveyType = this.mstSurveyType.find(
        i => +i.surveyTypeCd === +rec.surveyTypeCd
      );
      const max = [0,9.999,99,999.9];
      const decimal = [0,3,0,1];
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) || 
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = this.min
      }     
      let value = parseFloat(e.target.value);
      const parameterStep = parseFloat(rec.initialValue);
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (value > max[surveyType.integerDigits]) {
        value = this.min;
      }
      if(value < this.min) {
        value = max[surveyType.integerDigits];
      }
      this.resultValue[rec.surveyTypeCd] = parseFloat(value.toFixed(decimal[surveyType.integerDigits]))
      this.requestViewForceUpdate();
    },
    handleMouseWheels(rec, e, index) {
      if (!this.focusFlg[index]) {
        return;
      }
      const max = 9.999;
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) || 
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = this.min
      }     
      let value = parseFloat(e.target.value);
      const parameterStep = 0.001;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (value > max) {
        value = this.min;
      }
      if(value < this.min) {
        value = max;
      }
      rec.surveyData.value = parseFloat(value.toFixed(3))
      this.requestViewForceUpdate();
    },
    // (一括)結果のフォーカスアウト
    handleBlur(rec, e, index) {
      const initValue = "";
      // del #11047 数値IF修正【最優先】 linjunfeng start
      // const surveyType = this.mstSurveyType.find(
      //   i => +i.surveyTypeCd === +rec.surveyTypeCd
      // );
      // const upperThreshold = surveyType.upperThreshold;
      // const lowerThreshold = surveyType.lowerThreshold;
      // let limitedValue = null;
      // if (parseFloat(e.target.value) > upperThreshold) {
      //   limitedValue = upperThreshold;
      // }else if (parseFloat(e.target.value) < lowerThreshold) {
      //   limitedValue = lowerThreshold;
      // } else {
      //   limitedValue = e.target.value !== "" ? parseFloat(e.target.value) : "";
      // }
      // this.focusFlg[index] = false;
      // this.resultValue[rec.surveyTypeCd] = limitedValue;
      // del #11047 数値IF修正【最優先】 linjunfeng end
      if (initValue !== e.target.value) {
        e.currentTarget?.classList?.add("custom-input-edited");
      } else {
        // add #11047 数値IF修正【最優先】 linjunfeng start
        e.currentTarget.classList.remove("custom-input-number-edited");
        // add #11047 数値IF修正【最優先】 linjunfeng end
        e.currentTarget.classList.remove("custom-input-edited");
      }
      this.requestViewForceUpdate();
      // del #11047 数値IF修正【最優先】 linjunfeng start
      // 結果入力幅の調整処理
      // const inputBoxLengths = this.getInputBoxLengths(rec.surveyTypeCd);
      // const inputBoxMaxLength = String(limitedValue).length > Math.max(...inputBoxLengths) ? String(limitedValue).length : Math.max(...inputBoxLengths);
      // this.mstSurveyType.forEach(item => {
      //   const targetId = "value-" + item.surveyTypeCd;
      //   const targetTextBox = document.getElementById(targetId);
      //   if (targetTextBox != null) {
      //     targetTextBox.style = "width: " + inputBoxMaxLength + "em;"
      //   }
      // });
      // del #11047 数値IF修正【最優先】 linjunfeng end
    },
    // mod #5589 2023/04/13 数値IFのスタイル全不正 林峻峰 start
    validateResult(typeCd, $event) {
      let check;
      const resultValue = $event.target.value.toString();
      const surveyType = this.mstSurveyType.find(
        i => +i.surveyTypeCd === +typeCd
      );
      if (resultValue) {
        const arr = resultValue.split(".");
        if (arr.length > 2) {
          check = false;
        } else {
          const integerDigits = arr[0];
          const decimalDigits = arr[1];
          if (
            (integerDigits &&
              integerDigits.length > surveyType.integerDigits) ||
            (decimalDigits && decimalDigits.length > surveyType.decimalDigits)
          ) {
            check = false;
          } else {
           //mod 検査結果登録画面で、「結果：0」が入力出来ないの対応 田 start
          // del FNSI-水質管理_青田の対応 徐 start
          /*if(resultValue==0){
           check = false;
         }else{*/
          // del FNSI-水質管理_青田の対応 徐 start
           check = true;
           // del FNSI-水質管理_青田の対応 徐 start
           //}
           // del FNSI-水質管理_青田の対応 徐 start
           //mod 検査結果登録画面で、「結果：0」が入力出来ないの対応 田 end
          }
        }
        // add FNSI-改修内容6316修正 xuty start
        if (resultValue.substring(0,1) === "-") {
          check = false;
        }
        // add FNSI-改修内容6316修正 xuty end
      } else {
        check = true;
      }
      return check;
    },

    async getSurveyRecordDB(startDate, endDate) {
      let response;

      const url = `waterSurvey/filter`;
      const postParams = {
        startDate,
        endDate,
        listSurveytypeCd: [],
        listBedGroupCd: []
      };
      try {
        this.setLoadingScreenVisible(true);
        response = await ApiHelper.post(url, postParams);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('WaterResultModal.vue','getSurveyRecordDB',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        this.setLoadingScreenVisible(false);
        this.internalServerError(error);
      }

      if (response && response.data) {
        return response.data;
      }
      return [];
    },
    // add FNSI-改修内容766 姜 start
    addFocusCss(event){
      let element = event;
      element.currentTarget?.classList?.add("custom-select-edited");
      if (this.indexNum === 0) {
        // add FNSI-redmine3998 徐 start
        // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
        // this.changeFlg = true;
        // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
        // add FNSI-redmine3998 徐 end
        this.initNum = this.value;
        this.indexNum = 1;
      }
    },
    // (一覧)文字(ex.備考)のフォーカス
    addFocusCssText(event){
      event.currentTarget?.classList?.add("custom-input-edited");
    },
    // (一覧)数値(ex.結果)のフォーカス
    addFocusCssNumberText(surveyTypeCd, event, index){
      const currentValue = event.currentTarget.value; 
      if (currentValue === null || currentValue === "") {
        const findItem = this.mstSurveyType.find(t => {
          return t.surveyTypeCd == surveyTypeCd;
        });
        // -----結果-----
        this.listItem[index].surveyData.value = findItem.initialValue;
        event.currentTarget?.classList?.add("custom-input-edited");
        // -----初期文字列
        const currentDLL = getScopedElementById("text_" + index, this);
        if (currentDLL.value === null || currentDLL.value === "" || currentDLL.value === "1") {
          this.listItem[index].surveyData.text = this.checkText(findItem.initialString);
          currentDLL?.classList?.add("custom-select-edited");
        }
      }
      this.focusFlg[index] = true;
    },
    // (一覧)リスト(ex.初期文字列)のフォーカス
    changeFocusCssList(rec, event, index) {
      //mod #11945 水質管理 結果文字列に関する複数のバグ zrx start
      // const currentValue = Number(event.currentTarget.value);
      const currentValue = event.currentTarget.value;
      //mod #11945 水質管理 結果文字列に関する複数のバグ zrx end
      rec.surveyData.text = currentValue;
      if (this.initListItem[index].surveyData.text !== currentValue) {
        event.currentTarget?.classList?.add("custom-select-edited");
      } else {
        event.currentTarget.classList.remove("custom-select-edited");
      }
    },
    // (一覧)文字(ex.備考)のフォーカスアウト
    delFocusCssText(event, index) {
      const currentValue = event.currentTarget.value;
      if (this.initListItem[index].surveyData.memo !== currentValue) {
        event.currentTarget?.classList?.add("custom-input-edited");
      } else {
        event.currentTarget.classList.remove("custom-input-edited");
      }
    },
    // (一覧)数値(ex.結果)のフォーカスアウト
    delFocusCssNumberText(event, index, rec){
      const surveyType = this.mstSurveyType.find(
        i => +i.surveyTypeCd === +rec.surveyTypeCd
      );
      const upperThreshold = surveyType.upperThreshold;
      const lowerThreshold = surveyType.lowerThreshold;
      let limitedValue = null;
      if (parseFloat(event.target.value) > upperThreshold) {
        limitedValue = upperThreshold;
      }else if (parseFloat(event.target.value) < lowerThreshold) {
        limitedValue = lowerThreshold;
      } else {
        limitedValue = event.target.value !== "" ? parseFloat(event.target.value) : "";
      }
      this.focusFlg[index] = false;
      rec.surveyData.value = limitedValue === '' ? limitedValue : +limitedValue
      const editedValue = event.target.value !== "" ? parseFloat(event.target.value) : "";
      if (this.initListItem[index].surveyData.value !== editedValue) {
        event.currentTarget?.classList?.add("custom-input-edited");
      } else {
        event.currentTarget.classList.remove("custom-input-edited");
      }
      this.requestViewForceUpdate();
    },
    // (一覧)既定値の一括更新
    updateDefaultValue() {
      // 一括更新処理
      for (var i = 0; i < this.listItem.length; i++) {
        const targetInputBox = getScopedElementById("value_" + i, this);
        const targetDDL = getScopedElementById("text_" + i, this);
        const surveyTypeCd = this.listItem[i].surveyTypeCd;
        const mstSurveyTypeItem = this.mstSurveyType.find(item => item.surveyTypeCd === surveyTypeCd);
        // -----数値-----
        if (targetInputBox != null) {
          // mod #11047 数値IF修正【最優先】 張玲 start
          // const initValue = mstSurveyTypeItem.initialValue !== null && mstSurveyTypeItem.initialValue !== "" ? parseFloat(mstSurveyTypeItem.initialValue) : "";
          const initValue = mstSurveyTypeItem.initialValue;
          // mod #11047 数値IF修正【最優先】 張玲 end
          // mod #11047 数値IF修正【最優先】 張玲 start
          // if (this.initListItem[i].surveyData.value !== initValue) {
          if (this.listItem[i].surveyData.value !== initValue) {
          // mod #11047 数値IF修正【最優先】 張玲 end
            targetInputBox.value = initValue;
            targetInputBox?.classList?.add("custom-input-edited");
            this.listItem[i].surveyData.value = initValue;
            // 結果に値が入力された場合は現在時刻をセット
            this.setDefaultTime(this.listItem[i]);
          }
        }
        // -----区分-----
        // mod #11047 数値IF修正【最優先】 linjunfeng start
        // if (targetDDL != null) {
        if (targetDDL != null && this.listItem[i].surveyData.text !== this.checkText(mstSurveyTypeItem.initialString)) {
        // mod #11047 数値IF修正【最優先】 linjunfeng end
          targetDDL?.classList?.add("custom-select-edited");
          this.listItem[i].surveyData.text = this.checkText(mstSurveyTypeItem.initialString);
        }
      }
    },
    // (一覧)(採取者・検査者)オプションの一括更新
    updateSelectedOption(event, name) {
      // 一括更新処理
      for (var i = 0; i < this.listItem.length; i++) {
        const targetDDL = getScopedElementById(name + "_" + i, this);
        if (targetDDL != null) {
          const currentValue = Number(event.currentTarget.value);
          targetDDL.value = currentValue;
          if (name === "picker") {
            this.listItem[i].surveyData.picker = currentValue;
            if (this.initListItem[i].surveyData.picker !== currentValue) {
              targetDDL?.classList?.add("custom-select-edited");
            } else {
              targetDDL.classList.remove("custom-select-edited");
            }
          } else if (name === "inspector") {
            this.listItem[i].surveyData.inspector = currentValue;
            if (this.initListItem[i].surveyData.inspector !== currentValue) {
              targetDDL?.classList?.add("custom-select-edited");
            } else {
              targetDDL.classList.remove("custom-select-edited");
            }
          }
        }
      }
    },
    // (一括：個別更新用)(採取者・検査者)オプションの変更
    changeSelectedOption(event, name) {
      const optionList = this.getOptionList(event.currentTarget);
      const replaceOptionList = this.replaceOptionList(optionList);
      const options = this.getOptions(replaceOptionList);
      const replaceOptions = this.replaceOptions(options);
      const select = this.getSelect(replaceOptions, event.currentTarget?.ownerDocument);
      // (採取者・検査者)オプションの削除
      while (0 < event.currentTarget.childNodes.length) {
        const childNode = event.currentTarget.childNodes[0];
        event.currentTarget.removeChild(childNode);
      }
      // (採取者・検査者)オプションの追加
      event.currentTarget.appendChild(select);
      const currentValue = event.currentTarget.value !== "" ? Number(event.currentTarget.value) : null;
      // v-modelの更新 / 編集有無の更新
      if (name === "picker") {
        this.pickerCd = currentValue;
        if (this.initPickerCd !== currentValue) {
          event.currentTarget?.classList?.add("custom-select-edited");
        } else {
          event.currentTarget.classList.remove("custom-select-edited");
        }
      } else if (name === "inspector") {
        this.inspectorCd = currentValue;
        if (this.initInspectorCd !== currentValue) {
          event.currentTarget?.classList?.add("custom-select-edited");
        } else {
          event.currentTarget.classList.remove("custom-select-edited");
        }
      }
    },
    // (一覧：一括更新用)(採取者・検査者)オプションの変更
    changeParentSelectedOption(event) {
      const optionList = this.getOptionList(event.currentTarget);
      const options = this.getOptions(optionList);
      const select = this.getSelect(options, event.currentTarget?.ownerDocument);
      // (採取者・検査者)オプションの削除
      while (0 < event.currentTarget.childNodes.length) {
        const childNode = event.currentTarget.childNodes[0];
        event.currentTarget.removeChild(childNode);
      }
      // (採取者・検査者)オプションの追加
      event.currentTarget.appendChild(select);
    },
    // (一覧：個別更新用)(採取者・検査者)オプションの変更
    changeChildenSelectedOption(rec, event, index, name) {
      const optionList = this.getOptionList(event.currentTarget);
      
      const options = this.getOptions(optionList);
      const select = this.getSelect(options, event.currentTarget?.ownerDocument);
      // (採取者・検査者)オプションの削除
      while (0 < event.currentTarget.childNodes.length) {
        const childNode = event.currentTarget.childNodes[0];
        event.currentTarget.removeChild(childNode);
      }
      // (採取者・検査者)オプションの追加
      event.currentTarget.appendChild(select);
      const currentValue = Number(event.currentTarget.value);
      // v-modelの更新 / 編集有無の更新
      if (name === "picker") {
        rec.surveyData.picker = currentValue;
        if (this.initListItem[index].surveyData.picker !== currentValue) {
          event.currentTarget?.classList?.add("custom-select-edited");
        } else {
          event.currentTarget.classList.remove("custom-select-edited");
        }
      } else if (name === "inspector") {
        rec.surveyData.inspector = currentValue;
        if (this.initListItem[index].surveyData.inspector !== currentValue) {
          event.currentTarget?.classList?.add("custom-select-edited");
        } else {
          event.currentTarget.classList.remove("custom-select-edited");
        }
      }
    },
    // (採取者・検査者)オプションの取得
    getOptions(optionList) {
      let mainOptions = [];
      let sortedOptions = [];
      let filterOption = [];
      let selectedOption = optionList.find(item => item.selected === true);
      let headerOption = optionList.find(item => item.value === "0");
      let defautOption = optionList.find(item => item.value === this.userId);
      // (採取者・検査者)オプションの再構成
      if (selectedOption != null) {
        if (selectedOption.value === "0") {
          headerOption.selected = true;
          mainOptions.push(headerOption);
          mainOptions.push(defautOption);
          filterOption = optionList.filter(item => item.value !== "0" && item.value !== this.userId);
        } else {
          selectedOption.selected = true;
          mainOptions.push(headerOption);
          mainOptions.push(selectedOption);
          filterOption = optionList.filter(item => item.value !== "0" && item.value !== selectedOption.value);
        }
      } else {
        headerOption.selected = true;
        mainOptions.push(headerOption);
        mainOptions.push(defautOption);
        filterOption = optionList.filter(item => item.value !== "0" && item.value !== this.userId);
      }
      // マスタ順序
      sortedOptions = filterOption.sort(function(a, b){
        if (Number(a.value) > Number(b.value)) {
          return 1;
        } else if (Number(a.value) < Number(b.value)) {
          return -1;
        } else {
          return 0;
        }
      });
      return mainOptions.concat(sortedOptions);
    },
    // (採取者・検査者)選択肢の取得
    getSelect(options, ownerDocument = null) {
      const targetDocument = ownerDocument || this.$el?.ownerDocument || document;
      const select = targetDocument.createElement("select");
      options.forEach(item => {
        const option = targetDocument.createElement("option");
        option.text = item.text;
        option.value = item.value;
        if (item.value === "0") {
          if (item.selected) {
            option.selected = true;
            this.isSelectedHeaderOption = true;
          }
        } else {
          if (item.selected) {
            option.selected = true;
            option.style = "background-color: #0076ff !important; color: #fff;";
          } else {
            if (this.isSelectedHeaderOption) {
              option.style = "background-color: #0076ff !important; color: #fff;";
              this.isSelectedHeaderOption = false;
            }
          }
        }
        select.appendChild(option);
      });
      return select;
    },
    // add FNSI-改修内容766 姜 end
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
    copyDataForChanged() {
      //検査日
      this.initIspectionDay = JSON.parse(JSON.stringify(this.inspectionDay));
      //採取時刻
      this.initCollectionTime = JSON.parse(JSON.stringify(this.collectionTime));
      //採取者
      this.initPickerCd = JSON.parse(JSON.stringify(this.pickerCd));
      //検査者
      this.initInspectorCd = JSON.parse(JSON.stringify(this.inspectorCd));
      this.initTextValue = JSON.parse(JSON.stringify(this.textValue));
      this.initListItem = JSON.parse(JSON.stringify(this.listItem));
      this.initListItem && this.initListItem.forEach(listItem => {
        delete listItem.show
      })
    },
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
    isEdited(dateField) {
      let beforeVal;
      let afterVal;
      if (dateField === "inspectionDay") {
        beforeVal = this.initIspectionDay;
        afterVal = this.inspectionDay;
      }
      if (dateField === "collectionTime") {
        beforeVal = this.initCollectionTime === "aN:aN" || this.initCollectionTime === "" ? null : this.initCollectionTime;
        afterVal = this.collectionTime === "aN:aN" || this.collectionTime === "" ? null : this.collectionTime;
      }
      if (beforeVal != afterVal) {
        if (dateField === "inspectionDay") {
          return "date-input-edited";
        }
        if (dateField === "collectionTime") {
          return "time-input-edited";
        }
      }
      return "";
    },
    isEditedList(index, dateField) {
      let beforeVal;
      let afterVal;
      if (dateField === "surveyData.time") {
        beforeVal = this.listItemInitial[index] ? this.listItemInitial[index].surveyData.time : null;
        afterVal = this.listItem[index] ? this.listItem[index].surveyData.time : null;
      }
      if (beforeVal != afterVal) {
        if (dateField === "surveyData.time") {
          return "time-input-edited";
        }
      }
      return "";
    },
    // オプションリストの取得
    getOptionList(ddl) {
      const elementChilden = ddl.children[0];
      const optionList = elementChilden != null ? Array.from(elementChilden) : new Array();
      return optionList;
    },
    // オプションリストの置換処理
    replaceOptionList(optionList) {
      const replaceOptionlist = [];
      optionList.forEach(item => {
        if (item.value === "") {
          item.value = "0";
        }
        replaceOptionlist.push(item);
      });
      return replaceOptionlist;
    },
    // オプションの置換処理
    replaceOptions(options) {
      const replaceOptions = [];
      options.forEach(item => {
        if (item.value === "0") {
          item.value = "";
        }
        replaceOptions.push(item);
      });
      return replaceOptions;
    },
    // (一括)入力桁数の取得
    getInputBoxLengths(surveyTypeCd) {
      const inputBoxLengths = [];
      const filterSurveyType = this.mstSurveyType.filter(item => item.surveyTypeCd !== surveyTypeCd);
      filterSurveyType.forEach(item => {
        const targetId = "value-" + item.surveyTypeCd;
        const targetTextBox = getScopedElementById(targetId, this);
        if (targetTextBox != null) {
          const val = targetTextBox.value != null ? targetTextBox.value.length : 0;
          inputBoxLengths.push(val);
        }
      });
      return inputBoxLengths;
    },
    // (一覧)入力桁数の取得
    getInputBoxLengthList(name) {
      const inputBoxLengthList = [];
      for (var i = 0; i < this.listItem.length; i++) {
        const targetId = name + "_" + i;
        const targetTextBox = getScopedElementById(targetId, this);
        if (targetTextBox != null) {
          const val = targetTextBox.value != null ? targetTextBox.value.length : 0;
          inputBoxLengthList.push(val);
        }
      }
      return inputBoxLengthList;
    },
    // 文字サイズの取得
    getCharSize(title) {
      let charSize = 0;
      for (let i = 0; i < title.length; i++) {
        if (title[i].match(/^[A-Za-z0-9]*$/)) {
          // 半角文字
          charSize += 0.5;
        } else {
          // 全角文字
          charSize += 1.0;
        }
      }
      return charSize;
    },
    /**
     * (一覧)結果に値が入力されて採取時刻が空の場合、採取時刻に現在時刻をセット
     * @param listItem
     */
    setDefaultTime(listItem) {
      if (listItem.surveyData.value !== "" && listItem.surveyData.time === "") {
        listItem.surveyData.time = dayjs(new Date().getTime()).format("HH:mm");
      }
    },
    // 昇順/降順のclassを作成
    sortedClass(key) {
      return getSortedClass(key, this.sort);
    },
    // ソートするキーを設定する
    sortBy(key) {
      updateSort(key, this.sort);
    },
  }
};
</script>

<style scoped>
.flex-center {
  display: flex;
  align-items: center;
}
.k-widget {
  font-size: inherit !important;
}

.result-modal :deep(.k-content),
.display-area {
  overflow: auto;
  /* del FNSI-改修内容6374修正 xuty start */
  /* min-width: 120em; */
  /* del FNSI-改修内容6374修正 xuty end */
}

.result-modal :deep(.k-tabstrip-content) {
  overflow: auto;
  /* del FNSI-改修内容6374修正 xuty start */
  /* min-width: 120em; */
  /* del FNSI-改修内容6374修正 xuty end */
}

.result-modal {
  height: 100%;
  /* del FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 start */
  /* min-width: 120em; */
  /* del FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 end */
  padding: 0px 10px 0px 10px;
}

/** padding を上書き補正*/
.result-modal :deep(.k-tabstrip > .k-content) {
  padding: 1.5rem;
  /** 一瞬余分なスクロールバーが発生する為 */
  /* del FNSI-改修内容「ヘッダー」を「固定」に変更 江 start */
  /* overflow-y: hidden; */
  /* del FNSI-改修内容「ヘッダー」を「固定」に変更 江 end */
  /* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
  padding-left: 0rem;
  /* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}

.result-modal :deep(.k-tabstrip-content.k-content) {
  /*
   * Vue2 では、この画面のタブ内容 div 自体が k-content になり、
   * template の inline style="padding:0px" が最終表示に効いていた。
   * Vue3/Kendo 2026 では k-tabstrip-content が外側 wrapper になるため、
   * Vue2 の最終 DOM 表示に合わせて、この画面の wrapper padding だけを 0 に戻す。
   */
  padding: 0;
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}

.result-modal :deep(.k-tabstrip-content:focus),
.result-modal :deep(.k-tabstrip-content.k-focus),
.result-modal :deep(.k-tabstrip>.k-content:focus),
.result-modal :deep(.k-tabstrip>.k-content.k-focus) {
  outline-color: transparent !important;
}

.result-modal :deep(.k-tabstrip-top>.k-content),
.result-modal :deep(.k-tabstrip-top>.k-tabstrip-content) {
  border-block-start-width: 1px !important;
}
.result-modal :deep(.k-state-active) {
  background-color: var(--ntss-base-background-color) !important;
  border-color: var(--ntss-border-color) !important;
  /* del 6374 水質検査結果登録画面レイアウト不備 張 start  */
  /* border-bottom-color: transparent !important; */
  /* del 6374 水質検査結果登録画面レイアウト不備 張 end */
}

.result-modal :deep(.k-active) {
  background-color: var(--ntss-base-background-color) !important;
  border-color: var(--ntss-border-color) !important;
  /* del 6374 水質検査結果登録画面レイアウト不備 張 start  */
  /* border-bottom-color: transparent !important; */
  /* del 6374 水質検査結果登録画面レイアウト不備 張 end */
}
.result-modal :deep(.k-tabstrip-items) {
  border-color: var(--ntss-border-color) !important;
  font-size: 1.5em;
}

.result-modal :deep(.k-tabstrip-items li.k-item:first-child) {
  border-right: unset !important;
}

.result-modal :deep(.k-tabstrip-items .k-item) {
  border-radius: unset !important;
  border: 1px solid transparent;
  width: 7em;
  margin-bottom: 0 !important;
  color: var(--ntss-base-color) !important;
  border-color: var(--ntss-border-color) !important;
  border-bottom: unset !important;
}

/* mod 画面スタイル(ボタン)対応 徐 start */
/* li.k-item.k-state-active {
  background-color: #007bff !important;
  color: #ffffff !important;
} */
li.k-item.k-state-active {
  background-color: #1a71cc !important;
  color: #ffffff !important;
}
/* mod 画面スタイル(ボタン)対応 徐 end */

.grid-record-list {
  border-collapse: collapse;
  background-color: var(--ntss-list-background-color);
}

table.grid-record-list,
table.grid-record-list th,
table.grid-record-list td {
  border: 1px solid var(--ntss-border-color);
}
/* add FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 start */
table.scroll-table-data,
table.scroll-table-data th,
table.scroll-table-data td {
  border: 1px solid var(--ntss-border-color);
  border-left: none;
}

table.scroll-table-data td > * {
  vertical-align: middle;
}
/* add FNSI-改修内容「装置名、種別、検査箇所」を「固定」に変更 江 end */

table.grid-record-list td > * {
  vertical-align: middle;
}

.ntss-list-header-th-sticky {
  z-index: 1;
  white-space: unset;
   
   
   
   
  top: -1px;
   
}

/* mod FNSI-バグ 水質管理532 徐 start */
/* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
/* top: -25px; */
/* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
/* mod FNSI-バグ 水質管理532 徐 end */
.result-modal :deep(.k-tabstrip-wrapper),
.result-modal :deep(.k-tabstrip.k-widget) {
  height: 100% !important;
}

/*
 * Vue2 の WaterResultModal は kendo-tabstrip-wrapper が body 高さを受け、
 * その中で一括/一覧タブの内容領域が残り高さを使う。
 * Vue3/Kendo 2026 では items/content-wrapper が増えるため、
 * この画面の高さ契約だけを page 側で flex に戻す。
 */
.result-modal :deep(.k-tabstrip.k-widget) {
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.result-modal :deep(.k-tabstrip-items-wrapper),
.result-modal :deep(.k-tabstrip-items) {
  flex: 0 0 auto;
}

.result-modal :deep(.k-tabstrip-content-wrapper),
.result-modal :deep(.k-tabstrip > .k-content) {
  flex: 1 1 auto;
  min-height: 0;
  overflow: auto;
}

.result-modal :deep(.k-tabstrip-content.k-content),
.result-modal :deep(.k-tabstrip > .k-content) {
  height: 100%;
  min-height: 0;
  box-sizing: border-box;
}

.multi-result {
  display: flex;
  height: 100%;
  flex-direction: column;
  /* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
  margin-left: 1.5rem;
  /* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
}

.multi-result .result-item {
  height: 2em;
  padding: 2px;
  display: flex;
  align-items: center;
}

.result-item label {
  /* mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start */
  /* width: 9em; */
  min-width: 5em;
  /* mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end */
}
span.unit {
  width: auto;
  padding-left: 5px;
  padding-right: 5px;
  text-align: left;
  white-space: nowrap;
}
.result-input {
  min-width: 8em;
  font-size: 0.7em;
}
.result-input-date {
  /* mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start */
  /* width: 20em; */
  width: 8em;
  /* mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end */
  font-size: 1.05em;
}
.result-input.input-time {
  margin: 0;
  /* mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start */
  /* width: 12em; */
  width: 8em;
  /* mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end */
  /* del FNSI-水質管理_青田の対応 徐 start */
  /* margin-left: 10px; */
  /* del FNSI-水質管理_青田の対応 徐 end */
}
.result-select {
  /* del FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start */
  /* border: 1px solid #cccccc; */
  /* del FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end */
  width: auto;
  min-width: 8em;
}
.result-select.select-text.select {
  width: 12em;
}
.group-record {
  display: flex;
  justify-content: flex-start;
  align-items: center;
}
.single-result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  /* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
  height: 50px;
  /* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
}
.single-result-header .item {
  /* mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
  /* display: flex; */
  /* align-items: center; */
  /* width: 30%; */
  /* justify-content: space-between; */
  display: inline-flex;
  align-items: center;
  width: auto;
  justify-content: space-between;
  float: right;
  /* mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
}
.toggle-result,
.toggle-plan {
  width: 50%;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  /* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
  margin-right: 15px;
  /* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
}
.toggle-result label,
.toggle-plan label {
  padding-right: 10px;
}

/* mod 画面スタイル(ボタン)対応 徐 start */
/* .kendoTab {
  display: flex;
  justify-content: center;
}
.kendoText {
  width: 50px;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 5px 0;
} */
.kendoTab {
  display: flex;
  justify-content: center;
  background-color: #72a8de;
  border-bottom:solid 3px #4974a0;
}
.kendoText {
  align-items: center;
  padding: 5px 0;
  color: #ffffff;
}
/* mod 画面スタイル(ボタン)対応 徐 end */
/* add FNSI-改修内容「ヘッダー」を「固定」に変更 江 start */
.single-result {
  /* mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
  /* height: 395px; */
  width: auto;
  height: auto;
  /* mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
  /* add ウィンドウ表示でレイアウトが崩れるに修正する。 孔 start*/
  min-width: 750px;
  /* add ウィンドウ表示でレイアウトが崩れるに修正する。 孔 start*/
}
.scroll-table {
  display: flex;
  height: calc(100% - 45px);
}
.fixed-area {
  position: sticky;
  left: 0;
  z-index: 999;
  /* mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
  /* width: auto; */
  /* mod FNSI-水質管理_青田の対応 徐 start */
  /* width: 300px; */
  width: auto;
  /* mod FNSI-水質管理_青田の対応 徐 start */
  /* mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
  white-space: nowrap;
}
.scroll-area {
  overflow-y: visible;
  width: 100%;
}
td {
  /* mod FNSI-水質管理_青田の対応 徐 start */
  /* height: 2.2em; */
  height: 2.4em;
  /* mod FNSI-水質管理_青田の対応 徐 end */
  padding: 0 5px 0 5px;
}
th {
  /* mod FNSI-水質管理_青田の対応 徐 start */
  /* height: 2.2em; */
  height: 3.5em;
  /* mod FNSI-水質管理_青田の対応 徐 end */
}
/* add FNSI-水質管理_青田の対応 徐 start */
.check-box {
  width: 1rem;
  white-space: normal;
  text-align: center;
}
.sticky-col-checkbox {
  width: 2em;
  text-align: center;
}
/* add FNSI-水質管理_青田の対応 徐 end */
.scroll-table-data {
  border-collapse: collapse;
  /* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
  width: 100%;
  /* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
}
.main-content-area {
  position: relative;
  min-width: max-content;
  /* mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
  /* height: 450px; */
  height: 99%;
  overflow-y: hidden !important;
  display: contents;
  /* mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
}
.headcol {
  border-right: 0px none;
}
/* add FNSI-改修内容「ヘッダー」を「固定」に変更 江 end */
.headcol-fixed {
  min-width: 150px;
  width: 150px;
}
/* add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start */
.single-result-header .inspectionday {
  /* mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
  /* position:relative; */
  /* width: 30%; */
  /* mod ウィンドウ表示でレイアウトが崩れるに修正する。 孔 start*/
  /*position: fixed;*/
  /*width: 95%;*/
  width: 100%;
  /* mod ウィンドウ表示でレイアウトが崩れるに修正する。 孔 end*/
  /* mod FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
}
/* add FNSI-改修内容766 姜 start  */
.custom-select-edited {
  color: green;
  font-weight: bold;
}
.custom-input-edited :deep(input) {
  border: 2px #008000 solid !important;
  color: #1f1f21 !important;
  outline: 0 !important;
}
/* add FNSI-改修内容766 姜 end  */
.single-result-header .inspectionday input{
  width: 8em;
  margin-left: 5px;
  font-size: 1.05em;
  padding-right:0px;
}
/* add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end */
/* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 start */
.result-modal :deep(.k-widget.k-header.k-tabstrip.k-floatwrap.k-tabstrip-top) {
  overflow-y: auto;
}
/* add FNSI-保存ボタン上の線との間に隙間がないように修正する。 周 end */
.result-value {
  min-width: 8em;
  text-align: left;
}
.result-text {
  min-width: 8em;
  text-align: left;
}
.memo {
  min-width: 20em;
  text-align: left;
}

@media print {
  /** 横向き印刷時は横幅を収める */
  .modal-mask :deep(.modal-container) {
    width: 99% !important;
  }
  .single-result {
    overflow: hidden !important;
    width: fit-content;
    height: auto !important;
  }
  .result-modal :deep(.k-tabstrip-wrapper) {
    margin-left: -10px;
  }
  .result-modal .k-content {
    height: auto !important;
    padding: 0.5rem !important;
  }
  td {
    padding: 0 3px 0 3px;
  }

  /* 改ページ制御 */
  .fixed-area tr,
  .scroll-area tr {
    break-inside: avoid;
    page-break-inside: avoid;
  }

  /*
   * 固定列
   */
  .fixed-area table th,
  .fixed-area table td {
    text-overflow: ellipsis !important;
    overflow: hidden !important;
  }
  .sticky-col-checkbox {
    width: 1em;
  }
  /* 装置名 */
  .fixed-area table th:nth-child(2),
  .fixed-area table td:nth-child(2) { width: 10em !important; min-width: 10em !important; max-width: 10em !important; }
  /* 種別 */
  .fixed-area table th:nth-child(3),
  .fixed-area table td:nth-child(3) { width: 8em !important; min-width: 8em !important; max-width: 8em !important; }
  /* 検査箇所名 */
  .fixed-area table th:nth-child(4),
  .fixed-area table td:nth-child(4) { width: 8em !important; min-width: 8em !important; max-width: 8em !important; }

  /*
   * スクロール列
   */
  /* 予定 */
  .scroll-area table th:nth-child(1),
  .scroll-area table td:nth-child(1) { width: 2.5em !important; min-width: 2.5em !important; max-width: 2.5em !important; }
  /* 採取時刻 */
  .scroll-area table th:nth-child(2),
  .scroll-area table td:nth-child(2),
  .scroll-area :deep(.time-wrapper) { width: 6em !important; min-width: 6em !important; max-width: 6em !important; }
  /* 採取者 */
  .scroll-area table th:nth-child(3),
  .scroll-area table td:nth-child(3) { width: 7em !important; min-width: 7em !important; max-width: 7em !important; }
  /* 結果 */
  .scroll-area table th:nth-child(4),
  .scroll-area table td:nth-child(4) { width: 19em !important; min-width: 19em !important; max-width: 19em !important; }
  .result-value,
  .result-text { width: 7.5em !important; min-width: 7.5em !important; max-width: 7.5em !important; }
  /* 検査者 */
  .scroll-area table th:nth-child(5),
  .scroll-area table td:nth-child(5) { width: 7em !important; min-width: 7em !important; max-width: 7em !important; }
  /* 備考 */
  .scroll-area table th:nth-child(6),
  .scroll-area table td:nth-child(6),
  .memo { width: 8em !important; min-width: 8em !important; max-width: 8em !important; }

  /* フッターボタン*/
  .flex-container {
    justify-content: unset;
  }
}
:deep(.result-modal .k-tabstrip-items .k-item:not(.k-active):active){
  background-color: #72a8de !important;
  color: #ffffff !important;
}
:deep(.time-input .k-icon.k-i-close) {
  position: absolute !important;
  top: calc(50% + 1px) !important;
  transform: translateY(-50%) !important;
}
@supports (-webkit-touch-callout: none) {
  :deep(.time-input .k-icon.k-i-close.close-btn::before) {
    top: -3px !important;
    -webkit-transform: translateY(-3px) !important;
    transform: translateY(-3px) !important;
  }
}
</style>
/* add FNSI-入力欄の枠表示を修正する。 周 start */
<style>
ons-input .text-input:invalid {
  border: unset;
  border-width: 2px;
  border-style: inset;
  border-image-repeat: stretch;
  border-color: unset;
  background-color: transparent;
  color: #1f1f21;
}
.date-input input {
  padding-left: 5px;
  margin-right: 5px;
}
.manual-width {
  resize: horizontal;
  overflow: hidden;
}
.resizable-header {
  display: inline-block;
  resize: horizontal;
  overflow: hidden;
  height: 100%;
  align-content: center;
  min-width: 100%;
  white-space: nowrap;
  box-sizing: border-box;
  vertical-align: top;
}
.clickable-header-label {
  display: block;
  width: 100%;
  height: 100%;
  align-content: center;
  padding: 0 4px;
  box-sizing: border-box;
  overflow: hidden;
}

</style>
/* add FNSI-入力欄の枠表示を修正する。 周 end */
