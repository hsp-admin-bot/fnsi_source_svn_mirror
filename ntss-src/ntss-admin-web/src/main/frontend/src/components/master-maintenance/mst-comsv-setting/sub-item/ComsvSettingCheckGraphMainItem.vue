<!-- グラフ表示タブ -->
<template>
  <div class="check-graph-setting-main-content">
    <div class="tabs-graph">
      <input id="check1" type="radio" name="tab_graph_item" checked />
      <label class="tab_graph_item text-nowrap" for="check1">検査１</label>
      <input id="check2" type="radio" name="tab_graph_item" />
      <label class="tab_graph_item text-nowrap" for="check2">検査２</label>
      <input id="radar" type="radio" name="tab_graph_item" />
      <label class="tab_graph_item text-nowrap" for="radar">レーダーチャート</label>

      <!-- 検査１タブ -->
      <div class="tab_content" id="check1_content">
        <div>
          <div v-for="(item, index) in graph1Model.graph1_item" :key="index">
            <table border="1" style="width:100%">
              <table class="check1setting">
                <th class="check1settinghead" border="0">グラフ {{item.no}}</th>
                <tr>
                  <td>
                    <label>グラフ名：</label>
                  </td>
                  <td>
                    <v-ons-input
                      class="v-ons-input com-sv"
                      type="text"
                      v-model="item.name"
                      v-on:change="graph1OnChange"
                      maxlength="10"
                    ></v-ons-input>
                  </td>
                </tr>
                <tr>
                  <td>
                    <label>検査項目１：</label>
                  </td>
                  <td>
                    <kendo-dropdownlist
                      v-if="isExamDropdownReady"
                      :key="'exam-ddl-g1-' + index + '-1-' + examDropdownRenderKey"
                      :model-value="resolveExamDropdownValue(item.code1)"
                      @update:model-value="onExamDropdownInput(item, 'code1', $event, graph1OnChange)"
                      @select="onExamDropdownSelect(item, 'code1', $event, graph1OnChange)"
                      :data-source="mstExamItemsDataSources"
                      :data-text-field="'name'"
                      :data-value-field="'code'"
                      :filter="'contains'"
                      :auto-select-first-on-empty="false"
                      class="exam-items-select-box"
                    ></kendo-dropdownlist>
                  </td>
                </tr>
                <tr>
                  <td>
                    <label>検査項目２：</label>
                  </td>
                  <td>
                    <kendo-dropdownlist
                      v-if="isExamDropdownReady"
                      :key="'exam-ddl-g1-' + index + '-2-' + examDropdownRenderKey"
                      :model-value="resolveExamDropdownValue(item.code2)"
                      @update:model-value="onExamDropdownInput(item, 'code2', $event, graph1OnChange)"
                      @select="onExamDropdownSelect(item, 'code2', $event, graph1OnChange)"
                      :data-source="mstExamItemsDataSources"
                      :data-text-field="'name'"
                      :data-value-field="'code'"
                      :filter="'contains'"
                      :auto-select-first-on-empty="false"
                      class="exam-items-select-box"
                    ></kendo-dropdownlist>
                  </td>
                </tr>
                <tr>
                  <td>
                    <label>検査項目３：</label>
                  </td>
                  <td>
                    <kendo-dropdownlist
                      v-if="isExamDropdownReady"
                      :key="'exam-ddl-g1-' + index + '-3-' + examDropdownRenderKey"
                      :model-value="resolveExamDropdownValue(item.code3)"
                      @update:model-value="onExamDropdownInput(item, 'code3', $event, graph1OnChange)"
                      @select="onExamDropdownSelect(item, 'code3', $event, graph1OnChange)"
                      :data-source="mstExamItemsDataSources"
                      :data-text-field="'name'"
                      :data-value-field="'code'"
                      :filter="'contains'"
                      :auto-select-first-on-empty="false"
                      class="exam-items-select-box"
                    ></kendo-dropdownlist>
                  </td>
                </tr>
              </table>
            </table>
            <br />
          </div>
        </div>
      </div>
      <!-- 検査２タブ -->
      <div class="tab_content2" id="check2_content">
        <!-- メニュー欄 -->
        <div class="buttonGroupgraph" data-toggle="buttons">
          <input
            type="radio"
            name="radiograph"
            id="radiograph1"
            checked="checked"
            v-on:click="onClickRadiograph(1)"
          />
          <label for="radiograph1" class="menubuttongraph text-nowrap">グラフ１</label>
          <input type="radio" name="radiograph" id="radiograph2" v-on:click="onClickRadiograph(2)" />
          <label for="radiograph2" class="menubuttongraph text-nowrap">グラフ２</label>
          <input type="radio" name="radiograph" id="radiograph3" v-on:click="onClickRadiograph(3)" />
          <label for="radiograph3" class="menubuttongraph text-nowrap">グラフ３</label>
          <input type="radio" name="radiograph" id="radiograph4" v-on:click="onClickRadiograph(4)" />
          <label for="radiograph4" class="menubuttongraph text-nowrap">グラフ４</label>
          <input type="radio" name="radiograph" id="radiograph5" v-on:click="onClickRadiograph(5)" />
          <label for="radiograph5" class="menubuttongraph text-nowrap">グラフ５</label>
        </div>
        <div class="detail_area">
          <div class="detail_content">
            <div v-for="(item, index) in graph2Model.graph2_item" :key="index">
              <table class="check2setting" frame="box" :id="'graph2Id' + item.no">
                <table class="check2graph1" frame="box" style="border:none;">
                  <tr>
                    <table class="pt-2 pb-2">
                      <tr>
                        <td>
                          <label>ページ名：</label>
                        </td>
                        <td>
                          <v-ons-input
                            class="v-ons-input com-sv"
                            type="text"
                            v-model="item.name"
                            v-on:change="graph2OnChange"
                            maxlength="10"
                          ></v-ons-input>
                        </td>
                      </tr>
                    </table>
                  </tr>
                </table>
                <table class="check2graph1" frame="box">
                  <th class="check2graphhead" border="0">グラフ項目１</th>
                  <tr>
					<table>
					  <tr>
					    <td>
						  <label>グラフ名：</label>
						</td>
						<td>
						  <v-ons-input
						    class="v-ons-input com-sv"
						    type="text"
						    v-model="item.graph1_name"
						    v-on:change="graph2OnChange"
						    maxlength="10"
						  ></v-ons-input>
					    </td>
					  </tr>
					</table>
                    <table>
                      <tr>
                        <td class="check2graphtitle">
                          <label>グラフ</label>
                        </td>
                        <td></td>
                      </tr>
                      <tr>
                        <td class="check2graphname">
                          <label>検査項目(前)：</label>
                        </td>
                        <td>
                          <kendo-dropdownlist
                            v-if="isExamDropdownReady"
                            :key="'exam-ddl-g2-' + index + '-bfr1-' + examDropdownRenderKey"
                            :model-value="resolveExamDropdownValue(item.code_bfr1)"
                            @update:model-value="onExamDropdownInput(item, 'code_bfr1', $event, graph2OnChange)"
                            @select="onExamDropdownSelect(item, 'code_bfr1', $event, graph2OnChange)"
                            :data-source="mstExamItemsDataSources"
                            :data-text-field="'name'"
                            :data-value-field="'code'"
                            :filter="'contains'"
                            :auto-select-first-on-empty="false"
                            class="exam-items-select-box"
                          ></kendo-dropdownlist>
                        </td>
                      </tr>
                      <tr>
                        <td class="check2graphname">
                          <label>検査項目(後)：</label>
                        </td>
                        <td>
                          <kendo-dropdownlist
                            v-if="isExamDropdownReady"
                            :key="'exam-ddl-g2-' + index + '-afr1-' + examDropdownRenderKey"
                            :model-value="resolveExamDropdownValue(item.code_afr1)"
                            @update:model-value="onExamDropdownInput(item, 'code_afr1', $event, graph2OnChange)"
                            @select="onExamDropdownSelect(item, 'code_afr1', $event, graph2OnChange)"
                            :data-source="mstExamItemsDataSources"
                            :data-text-field="'name'"
                            :data-value-field="'code'"
                            :filter="'contains'"
                            :auto-select-first-on-empty="false"
                            class="exam-items-select-box"
                          ></kendo-dropdownlist>
                        </td>
                      </tr>
                      <tr>
                        <td class="check2graphtitle">
                          <label>棒グラフ</label>
                        </td>
                        <td></td>
                      </tr>
                      <tr>
                        <td class="check2graphname">
                          <label>検査項目：</label>
                        </td>
                        <td>
                          <kendo-dropdownlist
                            v-if="isExamDropdownReady"
                            :key="'exam-ddl-g2-' + index + '-bar1-' + examDropdownRenderKey"
                            :model-value="resolveExamDropdownValue(item.code_bar1)"
                            @update:model-value="onExamDropdownInput(item, 'code_bar1', $event, graph2OnChange)"
                            @select="onExamDropdownSelect(item, 'code_bar1', $event, graph2OnChange)"
                            :data-source="mstExamItemsDataSources"
                            :data-text-field="'name'"
                            :data-value-field="'code'"
                            :filter="'contains'"
                            :auto-select-first-on-empty="false"
                            class="exam-items-select-box"
                          ></kendo-dropdownlist>
                        </td>
                      </tr>
                    </table>
                  </tr>
                </table>
                <br />
                <table class="check2graph2" frame="box">
                  <th class="check2graphhead" border="0">グラフ項目２</th>
                  <tr>
					<table>
				      <tr>
					    <td>
						  <label>グラフ名：</label>
						</td>
						<td>
						  <v-ons-input
						    class="v-ons-input com-sv"
						    type="text"
						    v-model="item.graph2_name"
						    v-on:change="graph2OnChange"
						    maxlength="10"
						  ></v-ons-input>
						</td>
					  </tr>
					</table>
                    <table>
                      <tr>
                        <td class="check2graphtitle">
                          <label>グラフ</label>
                        </td>
                        <td></td>
                      </tr>
                      <tr>
                        <td class="check2graphname">
                          <label>検査項目(前)：</label>
                        </td>
                        <td>
                          <kendo-dropdownlist
                            v-if="isExamDropdownReady"
                            :key="'exam-ddl-g2-' + index + '-bfr2-' + examDropdownRenderKey"
                            :model-value="resolveExamDropdownValue(item.code_bfr2)"
                            @update:model-value="onExamDropdownInput(item, 'code_bfr2', $event, graph2OnChange)"
                            @select="onExamDropdownSelect(item, 'code_bfr2', $event, graph2OnChange)"
                            :data-source="mstExamItemsDataSources"
                            :data-text-field="'name'"
                            :data-value-field="'code'"
                            :filter="'contains'"
                            :auto-select-first-on-empty="false"
                            class="exam-items-select-box"
                          ></kendo-dropdownlist>
                        </td>
                      </tr>
                      <tr>
                        <td class="check2graphname">
                          <label>検査項目(後)：</label>
                        </td>
                        <td>
                          <kendo-dropdownlist
                            v-if="isExamDropdownReady"
                            :key="'exam-ddl-g2-' + index + '-afr2-' + examDropdownRenderKey"
                            :model-value="resolveExamDropdownValue(item.code_afr2)"
                            @update:model-value="onExamDropdownInput(item, 'code_afr2', $event, graph2OnChange)"
                            @select="onExamDropdownSelect(item, 'code_afr2', $event, graph2OnChange)"
                            :data-source="mstExamItemsDataSources"
                            :data-text-field="'name'"
                            :data-value-field="'code'"
                            :filter="'contains'"
                            :auto-select-first-on-empty="false"
                            class="exam-items-select-box"
                          ></kendo-dropdownlist>
                        </td>
                      </tr>
                      <tr>
                        <td class="check2graphtitle">
                          <label>棒グラフ</label>
                        </td>
                        <td></td>
                      </tr>
                      <tr>
                        <td class="check2graphname">
                          <label>検査項目：</label>
                        </td>
                        <td>
                          <kendo-dropdownlist
                            v-if="isExamDropdownReady"
                            :key="'exam-ddl-g2-' + index + '-bar2-' + examDropdownRenderKey"
                            :model-value="resolveExamDropdownValue(item.code_bar2)"
                            @update:model-value="onExamDropdownInput(item, 'code_bar2', $event, graph2OnChange)"
                            @select="onExamDropdownSelect(item, 'code_bar2', $event, graph2OnChange)"
                            :data-source="mstExamItemsDataSources"
                            :data-text-field="'name'"
                            :data-value-field="'code'"
                            :filter="'contains'"
                            :auto-select-first-on-empty="false"
                            class="exam-items-select-box"
                          ></kendo-dropdownlist>
                        </td>
                      </tr>
                    </table>
                  </tr>
                </table>
              </table>
            </div>
          </div>
        </div>
      </div>
      <!-- レーダーチャートタブ -->
      <div class="tab_content" id="radar_content">
        <div class="tab_content_area3">
          <div v-for="(item, index) in radarModel.radar_item" :key="index">
            <table class="radarchart" frame="box">
              <th class="radarhead" border="0">レーダーチャート {{item.no}}</th>
              <tr>
                <table>
                  <tr>
                    <td class="radarcheckname">
                      <label>検査項目：</label>
                    </td>
                    <td>
                      <kendo-dropdownlist
                        v-if="isExamDropdownReady"
                        :key="'exam-ddl-radar-' + index + '-' + examDropdownRenderKey"
                        :model-value="resolveExamDropdownValue(item.code)"
                        @update:model-value="onExamDropdownInput(item, 'code', $event, radarOnChange)"
                        @select="onExamDropdownSelect(item, 'code', $event, radarOnChange)"
                        :data-source="mstExamItemsDataSources"
                        :data-text-field="'name'"
                        :data-value-field="'code'"
                        :filter="'contains'"
                        :auto-select-first-on-empty="false"
                        class="exam-items-select-box"
                      ></kendo-dropdownlist>
                    </td>
                  </tr>
                </table>
              </tr>
            </table>
            <br />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import {EventBus} from "@/compat/vue/event-bus.js";
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";

// ドロップダウン内「未登録」の内部 code（保存値 "" とは区別、未選択 null とも区別）
const EXAM_UNREGISTERED_CODE = "\u0001";

export default {
  data() {
    return {
      graphDataReady: false,
      // 検査１グラフモデル
      graph1Model: {
        graph1_item: [
          {
            no: 1,
            name: "",
            code1: null,
            code2: null,
            code3: null
          },
          {
            no: 2,
            name: "",
            code1: null,
            code2: null,
            code3: null
          },
          {
            no: 3,
            name: "",
            code1: null,
            code2: null,
            code3: null
          },
          {
            no: 4,
            name: "",
            code1: null,
            code2: null,
            code3: null
          },
          {
            no: 5,
            name: "",
            code1: null,
            code2: null,
            code3: null
          }
        ]
      },
      // 検査２グラフモデル
      graph2Model: {
        graph2_item: [
          {
            no: 1,
            name: "",
            graph1_name: "",
            code_bfr1: null,
            code_afr1: null,
            code_bar1: null,
            graph2_name: "",
            code_bfr2: null,
            code_afr2: null,
            code_bar2: null
          },
          {
            no: 2,
            name: "",
            graph1_name: "",
            code_bfr1: null,
            code_afr1: null,
            code_bar1: null,
            graph2_name: "",
            code_bfr2: null,
            code_afr2: null,
            code_bar2: null
          },
          {
            no: 3,
            name: "",
            graph1_name: "",
            code_bfr1: null,
            code_afr1: null,
            code_bar1: null,
            graph2_name: "",
            code_bfr2: null,
            code_afr2: null,
            code_bar2: null
          },
          {
            no: 4,
            name: "",
            graph1_name: "",
            code_bfr1: null,
            code_afr1: null,
            code_bar1: null,
            graph2_name: "",
            code_bfr2: null,
            code_afr2: null,
            code_bar2: null
          },
          {
            no: 5,
            name: "",
            graph1_name: "",
            code_bfr1: null,
            code_afr1: null,
            code_bar1: null,
            graph2_name: "",
            code_bfr2: null,
            code_afr2: null,
            code_bar2: null
          }
        ]
      },
      // 検査レーダモデル
      radarModel: {
        radar_item: [
          {
            no: 1,
            code: null
          },
          {
            no: 2,
            code: null
          },
          {
            no: 3,
            code: null
          },
          {
            no: 4,
            code: null
          },
          {
            no: 5,
            code: null
          },
          {
            no: 6,
            code: null
          }
        ]
      },
      initGraph1:{},
      initGraph2:{},
      initRader:{},
    };
  },
  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("mst-check-graph", ["mstExamItemsList"]),
    ...mapGetters("master-maintenance", {
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    // 検査項目一覧データソース
    mstExamItemsDataSources() {
      const emptyItem = {
        code: EXAM_UNREGISTERED_CODE,
        name: "未登録"
      };
      const list = Array.isArray(this.mstExamItemsList) ? [...this.mstExamItemsList] : [];
      const realItems = list.filter(
        (e) => !(e.code === "" && e.name === "未登録") && e.code !== EXAM_UNREGISTERED_CODE
      );
      if (realItems.length === 0) {
        return [];
      }
      const hasEmptyItem = list.some(
        (e) => (e.code === "" && e.name === "未登録") || e.code === EXAM_UNREGISTERED_CODE
      );
      if (!hasEmptyItem) {
        return [emptyItem, ...realItems];
      }
      return list.map((e) => {
        if (e.code === "" && e.name === "未登録") {
          return { ...e, code: EXAM_UNREGISTERED_CODE };
        }
        return e;
      });
    },
    examDropdownRenderKey() {
      return `${this.graphDataReady ? 1 : 0}-${this.mstExamItemsDataSources.length}`;
    },
    hasExamItemOptions() {
      return this.mstExamItemsDataSources.length > 0;
    },
    isExamDropdownReady() {
      return this.graphDataReady && this.hasExamItemOptions;
    }
  },
  watch: {
    mstExamItemsDataSources(items) {
      if (items.length > 0) {
        return;
      }
      this.clearUnsetExamCodesWhenNoData();
    }
  },
  methods: {
    ...mapActions("mst-check-graph", ["getMstExamItemsList", "getMstExamItemsListByFacilityCd"]),
    ...mapActions("master-maintenance", ["setEditRecord"]),

    isUnsetExamCode(code) {
      return code === null || code === undefined;
    },
    toStoredExamCode(value) {
      if (value === null || value === undefined) {
        return null;
      }
      if (value === EXAM_UNREGISTERED_CODE) {
        return "";
      }
      return String(value);
    },
    resolveExamDropdownValue(code) {
      if (!this.hasExamItemOptions) {
        return null;
      }
      if (this.isUnsetExamCode(code)) {
        return null;
      }
      if (code === "") {
        return EXAM_UNREGISTERED_CODE;
      }
      return code;
    },
    resolveExamDropdownSelectValue(event) {
      const dataItem = event?.dataItem;
      if (dataItem && typeof dataItem === "object" && dataItem.code !== undefined && dataItem.code !== null) {
        return dataItem.code;
      }
      if (event?.value !== undefined && event?.value !== null) {
        return event.value;
      }
      return event?.sender?.value?.();
    },
    onExamDropdownSelect(item, field, event, onRecordChange) {
      const widgetValue = this.resolveExamDropdownSelectValue(event);
      if (widgetValue === undefined) {
        return;
      }
      this.onExamDropdownInput(item, field, widgetValue, onRecordChange);
    },
    onExamDropdownInput(item, field, value, onRecordChange) {
      item[field] = this.toStoredExamCode(value);
      if (typeof onRecordChange === "function") {
        onRecordChange.call(this);
      }
    },
    clearUnsetExamCodesWhenNoData() {
      const resetFields = (item, fields) => {
        fields.forEach((field) => {
          const code = item[field];
          if (code === "" || this.isUnsetExamCode(code)) {
            item[field] = null;
          }
        });
      };
      const graph1Fields = ["code1", "code2", "code3"];
      const graph2Fields = ["code_bfr1", "code_afr1", "code_bar1", "code_bfr2", "code_afr2", "code_bar2"];
      this.graph1Model.graph1_item.forEach((item) => resetFields(item, graph1Fields));
      this.graph2Model.graph2_item.forEach((item) => resetFields(item, graph2Fields));
      this.radarModel.radar_item.forEach((item) => resetFields(item, ["code"]));
    },
    normalizeLoadedGraphCodes(model, fields) {
      if (!model) {
        return;
      }
      const items = model.graph1_item || model.graph2_item || model.radar_item;
      if (!Array.isArray(items)) {
        return;
      }
      items.forEach((item) => {
        fields.forEach((field) => {
          if (item[field] === undefined) {
            item[field] = null;
          }
        });
      });
    },

    // 編集レコードのlcdGraph1を編集した値で更新
    graph1OnChange() {
      const graph1Json = JSON.stringify(this.graph1Model);
      this.updateEditRecord("lcdGraph1", graph1Json);
    },
    // 編集レコードのlcdGraph2を編集した値で更新
    graph2OnChange() {
      const graph2Json = JSON.stringify(this.graph2Model);
      this.updateEditRecord("lcdGraph2", graph2Json);
    },
    // 編集レコードのlcdRadarを編集した値で更新
    radarOnChange() {
      const radarJson = JSON.stringify(this.radarModel);
      this.updateEditRecord("lcdRadar", radarJson);
    },

    // JSONをObjectに変換
    getValueByField(field) {
      let rtn = null;
      if (this.editRecord[field]) {
        rtn = JSON.parse(this.editRecord[field]);
      }
      return rtn;
    },

    // 編集レコードを更新
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    getRadiographContents() {
      const itemRoot = this.$el || null;
      return [1, 2, 3, 4, 5].map(index => {
        const id = `graph2Id${index}`;
        return getScopedElementById(id, itemRoot) || null;
      });
    },

    // 選択中Radiographにスタイルを付ける
    onClickRadiograph(index) {
      const contents = this.getRadiographContents();
      contents.forEach(content => {
        if (content) {
          content.style.display = "none";
        }
      });
      const activeContent = contents[index - 1];
      if (activeContent) {
        activeContent.style.display = "block";
      }
    }
  },
  mounted() {
    this.onClickRadiograph(1);
    //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
  },
  async created() {
    // 検査項目一覧取得用アクション
    // add マスタ一覧 施設切替を可能とする 王 start
    // await this.getMstExamItemsList();
    await this.getMstExamItemsListByFacilityCd(this.getFacilitySwitch);
    // add マスタ一覧 施設切替を可能とする 王 end
    this.$nextTick(() => {
      for (const columnDefinition of this.columnDefinition) {
        if (columnDefinition.field === "lcdGraph1") {
          this.graph1Model = this.getValueByField(columnDefinition.field)
            ? this.getValueByField(columnDefinition.field)
            : this.graph1Model;
        }
        if (columnDefinition.field === "lcdGraph2") {
          this.graph2Model = this.getValueByField(columnDefinition.field)
            ? this.getValueByField(columnDefinition.field)
            : this.graph2Model;
        }
        if (columnDefinition.field === "lcdRadar") {
          this.radarModel = this.getValueByField(columnDefinition.field)
            ? this.getValueByField(columnDefinition.field)
            : this.radarModel;
        }
      }
      this.normalizeLoadedGraphCodes(this.graph1Model, ["code1", "code2", "code3"]);
      this.normalizeLoadedGraphCodes(this.graph2Model, ["code_bfr1", "code_afr1", "code_bar1", "code_bfr2", "code_afr2", "code_bar2"]);
      this.normalizeLoadedGraphCodes(this.radarModel, ["code"]);
      this.clearUnsetExamCodesWhenNoData();
      this.initGraph1 = JSON.parse(JSON.stringify(this.graph1Model.graph1_item));
      this.initGraph2 = JSON.parse(JSON.stringify(this.graph2Model.graph2_item));
      this.initRader = JSON.parse(JSON.stringify(this.radarModel.radar_item));
      this.graphDataReady = true;
    });
  },
};
</script>
<style scoped>
.check-graph-setting-main-content {
  height: 100%;
  flex: 1;
}

/* [メイン] タブ切り替え全体のスタイル*/
.tabs-graph {
  background-color: var(--ntss-base-background-color);
  margin: 0 auto;
  height: 100%;
  overflow: hidden;
}
/* [メイン] タブのスタイル*/
.tab_graph_item {
  width: calc(100% / 3);
  height: 30px;
  border-bottom: 3px solid #5ab4bd;
  background-color: #d9d9d9;
  line-height: 30px;
  text-align: center;
  color: #565656;
  display: block;
  float: left;
  text-align: center;
  font-weight: bold;
  transition: all 0.2s ease;
}
.tab_graph_item:hover {
  opacity: 0.75;
}
/* [メイン] ラジオボタンを全て消す*/
input[name="tab_graph_item"] {
  display: none;
}
/* [メイン] タブ切り替えの中身のスタイル*/
.tab_content {
  display: none;
  padding-top: 15px;
  clear: both;
  overflow-y: auto;
  height: calc(100% - 49px);
}
/* [メイン] タブ切り替えの中身のスタイル*/
.tab_content2 {
  display: none;
  padding-top: 15px;
  clear: both;
  height: calc(100% - 49px);
}
#graph2Id1,
#graph2Id2,
#graph2Id3,
#graph2Id4,
#graph2Id5 {
  clear: both;
  overflow: hidden;
}

#graph2Id2,
#graph2Id3,
#graph2Id4,
#graph2Id5 {
  display: none;
}

/* [メイン] 選択されているタブのコンテンツのみを表示*/
#check1:checked ~ #check1_content,
#check2:checked ~ #check2_content,
#radar:checked ~ #radar_content {
  display: block;
}
/* [メイン] 選択されているタブのスタイルを変える*/
.tabs-graph input:checked + .tab_graph_item {
  background-color: #2a8bc4;
  color: #fff;
}

/*メニューボタングループ*/
.buttonGroupgraph {
  width: auto;
  height: 40px;
  margin: auto;
  display: flex;
}
/*メニューボタン*/
.buttonGroupgraph input[type="radio"] {
  display: none;
}
.buttonGroupgraph label {
  display: block;
  margin: 5px 5px;
  background-color: #999999;
  display: flex;
  margin: 5px 0px;
  float: left;
  text-align: center;
  width: calc(100% / 3);
  height: 30px;
  border-bottom: 3px solid #5ab4bd;
  background-color: #d9d9d9;
  line-height: 30px;
  color: #565656;
  font-weight: bold;
  -webkit-transition: all 0.2s ease;
  transition: all 0.2s ease;
}

.buttonGroupgraph label:hover {
  opacity: 0.75;
}

/*メニューボタン：クリックしたとき色変える*/
.buttonGroupgraph input[type="radio"]:checked + label {
  background-color: #2a8bc4;
  color: #fff;
}

/*************/
/* 検査１タブ */
/*************/
.check1settinghead {
  text-align: left;
  background-image: none;
}
.check1checkkoumoku {
  width: 130px;
  text-align: right;
}

/*************/
/* 検査２タブ */
/*************/
/* グラフ選択ボタン */
.menubuttongraph {
  width: 100px;
  margin: 10px;
  flex: 1 1 auto;
  align-items: center;
  justify-content: center;
}

/* 外枠 */
.check2setting {
  width: 100%;
  height: 100%;
}

/* 中枠上 */
.check2graph1 {
  width: 99%;
  height: 100%;
  margin-left: auto;
  margin-right: auto;
}

/* 中枠下 */
.check2graph2 {
  width: 99%;
  height: 100%;
  margin-left: auto;
  margin-right: auto;
}

/* メニュー名 */
.check2settinghead {
  width: 100px;
  text-align: left;
  background-image: none;
}

/* ラベル */
.check2graphhead {
  width: 100px;
  text-align: left;
  background-image: none;
}

.check2pagename {
  width: 100px;
  text-align: right;
}

.check2graphtitle {
  width: 100px;
}

.check2graphname {
  width: 150px;
  text-align: right;
}

/**********************/
/* レーダーチャートタブ */
/**********************/
/* 外枠 */
.radarchart {
  width: 100%;
  height: 100%;
}

/* ラベル */
.radarhead {
  width: 100%;
  text-align: left;
  background-image: none;
}

.radarcheckname {
  width: 120px;
  text-align: right;
}

#check1_content :deep(.exam-items-select-box),
#check2_content :deep(.exam-items-select-box),
#radar_content :deep(.exam-items-select-box) {
  margin: 5px 10px;
  width: 250px;
  font-size: 1em;
}

.v-ons-input.com-sv {
  width: 250px;
  margin: 5px 10px;
}

.pt-2 {
  padding-top: 0.5rem;
}

.pb-2 {
  padding-bottom: 0.5rem;
}

.text-nowrap {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.v-ons-input.com-sv :deep(.text-input) {
  font-size: 1em;
}
.tab_content_area3 {
  min-width: 400px;
}
.detail_area {
  overflow: auto;
  height: calc(100% - 40px);
}
.detail_content {
  min-width: 500px;
}
</style>
