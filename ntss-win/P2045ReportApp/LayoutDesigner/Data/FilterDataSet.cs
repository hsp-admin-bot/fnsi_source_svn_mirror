using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using NKKWebAccessLib;

namespace LayoutDesigner
{
    public class FilterDataSet
    {
        #region メンバ変数定義

        private RldRestResultData<List<FilterObsKindData>> m_FilterObsKindData = null;
        private RldRestResultData<List<FilterMedicineData>> m_FilterMedicineData = null;
        private RldRestResultData<List<FilterEquipData>> m_FilterEquipmentData = null;
        private RldRestResultData<List<FilterDialDiffData>> m_FilterDialDiffData = null;
        private RldRestResultData<List<FilterExamItemData>> m_FilterExamItemData = null;
        private RldRestResultData<List<FilterCategoryData>> m_FilterCategoryData = null;
        private RldRestResultData<List<FilterExamSetData>> m_FilterExamSetData = null;
        private RldRestResultData<List<FilterPatEventData>> m_FilterPatEventData = null;
        private RldRestResultData<List<FilterAdditionData>> m_FilterAdditionData = null;
        private RldRestResultData<List<FilterWaterSurveyPointData>> m_FilterWaterSurveyPointData = null;
        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
        private RldRestResultData<List<FilterInspectionData>> m_FilterInspectioData = null;
        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
        //add #8489 zhu start
        private RldRestResultData<List<FilterDistributionData>> m_FilterDistributionData = null;
        //add #8489 zhu end
        // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
        private RldRestResultData<List<FilterReceiptData>> m_FilterReceiptData = null;
        // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
        // add #12006 感染症がフィルタできない 高 start
        private RldRestResultData<List<FilterAdditionData>> m_FilterInfectionData = null;
        // add #12006 感染症がフィルタできない 高 end
        // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
        private RldRestResultData<List<FilterWaterTestPointData>> m_FilterWQTestPointData = null;
        private RldRestResultData<List<FilterAdditionData>> m_FilterWQTestTypeData = null;
        // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
        #endregion

        #region メンバプロパティ定義

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 観察記録種別フィルタデータの取得を行います。
        /// </summary>
        public async Task<RldRestResultData<List<FilterObsKindData>>> GetFilterObsKindData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if( this.m_FilterObsKindData != null && this.m_FilterObsKindData.IsSuccess ) return this.m_FilterObsKindData;

            this.m_FilterObsKindData = new RldRestResultData<List<FilterObsKindData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_MST_OBSKIND_ALL,
            //    NKKWebAccess.FacilityCd);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_MST_OBSKIND_ALL,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("観察記録種別一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterObsKindData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterObsKindData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if( this.m_FilterObsKindData.IsSuccess )
                this.m_FilterObsKindData.Data = RldJsonDataSerializeHelper<List<FilterObsKindData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterObsKindData;
        }

        /// <summary>
        /// 薬剤フィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterMedicineData>>> GetFilterMedicineData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 高 start
            //if ( this.m_FilterMedicineData != null && this.m_FilterMedicineData.IsSuccess ) return this.m_FilterMedicineData;
            this.m_FilterMedicineData = null;
            // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 高 end

            this.m_FilterMedicineData = new RldRestResultData<List<FilterMedicineData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_ABS_MEDICINE,
            //    String.Empty);
            // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_ABS_MEDICINE,
            //    LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            String wUri = String.Format("{0}{1}{2}/{3}/{4}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_ABS_MEDICINE,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd,
                RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_EQUIPMENT_LIST ? 1 : 0);
            // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 高 end
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("薬剤フィルタ用データ取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterMedicineData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterMedicineData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if( this.m_FilterMedicineData.IsSuccess )
                this.m_FilterMedicineData.Data = RldJsonDataSerializeHelper<List<FilterMedicineData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterMedicineData;
        }

        /// <summary>
        /// 医材フィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterEquipData>>> GetFilterEquipmentData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if( this.m_FilterEquipmentData != null && this.m_FilterEquipmentData.IsSuccess ) return this.m_FilterEquipmentData;

            this.m_FilterEquipmentData = new RldRestResultData<List<FilterEquipData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_ABS_EQUIP,
            //    //NKKWebAccess.FacilityCd);
            //    String.Empty);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_ABS_EQUIP,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("医療材料フィルタ用データ取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterEquipmentData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterEquipmentData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if( m_FilterEquipmentData.IsSuccess )
                this.m_FilterEquipmentData.Data = RldJsonDataSerializeHelper<List<FilterEquipData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterEquipmentData;
        }

        /// <summary>
        /// 透析困難フィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterDialDiffData>>> GetFilterDialDiffData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if( this.m_FilterDialDiffData != null && this.m_FilterDialDiffData.IsSuccess ) return this.m_FilterDialDiffData;

            this.m_FilterDialDiffData = new RldRestResultData<List<FilterDialDiffData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_ABS_DIAL_DIFF,
            //    //NKKWebAccess.FacilityCd);
            //    String.Empty);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_ABS_DIAL_DIFF,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("透析困難一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterDialDiffData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterDialDiffData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if( m_FilterDialDiffData.IsSuccess )
                this.m_FilterDialDiffData.Data = RldJsonDataSerializeHelper<List<FilterDialDiffData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterDialDiffData;
        }

        /// <summary>
        /// 検査項目フィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterExamItemData>>> GetFilterExamItemData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if( this.m_FilterExamItemData != null && this.m_FilterExamItemData.IsSuccess ) return this.m_FilterExamItemData;

            this.m_FilterExamItemData = new RldRestResultData<List<FilterExamItemData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_MST_EXAM_ITEM,
            //    String.Empty);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_MST_EXAM_ITEM,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("検査項目一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterExamItemData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterExamItemData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if( m_FilterExamItemData.IsSuccess )
                this.m_FilterExamItemData.Data = RldJsonDataSerializeHelper<List<FilterExamItemData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterExamItemData;
        }

        public async Task<RldRestResultData<List<FilterCategoryData>>> GetFilterCategoryData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if (this.m_FilterCategoryData != null && this.m_FilterCategoryData.IsSuccess) return this.m_FilterCategoryData;

            this.m_FilterCategoryData = new RldRestResultData<List<FilterCategoryData>>();

            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_MST_PAT_EVENT_SUB_CATEGORY,
                String.Empty);

            var wRestRet = await NKKWebAccess.Get("検査項目一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterCategoryData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterCategoryData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if (m_FilterCategoryData.IsSuccess)
                this.m_FilterCategoryData.Data = RldJsonDataSerializeHelper<List<FilterCategoryData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterCategoryData;
        }

        /// <summary>
        /// 検査セットフィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterExamSetData>>> GetFilterExamSetData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if( this.m_FilterExamSetData != null && this.m_FilterExamSetData.IsSuccess ) return this.m_FilterExamSetData;

            this.m_FilterExamSetData = new RldRestResultData<List<FilterExamSetData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_MST_EXAM_SET,
            //    String.Empty);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_MST_EXAM_SET,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("検査セット一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterExamSetData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterExamSetData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if( m_FilterExamSetData.IsSuccess )
                this.m_FilterExamSetData.Data = RldJsonDataSerializeHelper<List<FilterExamSetData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterExamSetData;
        }

        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
        /// <summary>
        /// 点検フィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterInspectionData>>> GetFilterInspectionData()
        {
            this.m_FilterInspectioData = new RldRestResultData<List<FilterInspectionData>>();

			// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            //// add #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 高 start
            //if (string.IsNullOrWhiteSpace(RldLib.inspectionLayoutData.LayoutCD))
            //{
            //    this.m_FilterInspectioData.IsSuccess = false;
            //    return m_FilterInspectioData;
            //}
            //// add #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 高 end
			// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            // mod #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 高 start
			// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            //if (string.IsNullOrWhiteSpace(RldLib.inspectionLayoutData.RecordCD))
            //    RldLib.inspectionLayoutData.RecordCD = "0";
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_MST_MAINTE_DETAIL,
            //    RldLib.inspectionLayoutData.LayoutCD);
            //String wUri = String.Format("{0}{1}{2}/{3}/{4}/{5}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_MST_MAINTE_DETAIL,
            //    LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd,
            //    RldLib.inspectionLayoutData.LayoutCD,
            //    RldLib.inspectionLayoutData.RecordCD);
            String wUri = String.Format("{0}{1}{2}/{3}/{4}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_MST_MAINTE_DETAIL,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd,
                RldLib.inspectionLayoutData.UseCD);
			// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            // mod #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 高 end
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("点検詳細品目コード一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterInspectioData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterInspectioData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if (m_FilterInspectioData.IsSuccess)
            {
                // mod #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 高 start
                this.m_FilterInspectioData.Data = RldJsonDataSerializeHelper<List<FilterInspectionData>>.Deserialize(wRestRet.strContent);
                //Dictionary<String, String> json = NKKWebAccess.GetJsonData(wRestRet.strContent);
                //String detailInfo = string.Empty;
                //if ("1".Equals(RldLib.inspectionLayoutData.RecordCD) || "1".Equals(RldLib.inspectionLayoutData.UseCD))
                //{
                //    if (json.ContainsKey("detailInfo1") == true && json["detailInfo1"] != "null")
                //    {
                //        detailInfo = json["detailInfo1"];
                //    }
                //}
                //else
                //{
                //    if (json.ContainsKey("detailInfo2") == true && json["detailInfo2"] != "null")
                //    {
                //        detailInfo = json["detailInfo2"];                        
                //    }
                //}
                //if (!String.IsNullOrEmpty(detailInfo))
                //{
                //    this.m_FilterInspectioData.Data = RldJsonDataSerializeHelper<List<FilterInspectionData>>.Deserialize(detailInfo);
                //}
                //else
                //{
                //    this.m_FilterInspectioData.IsSuccess = false;
                //    this.m_FilterInspectioData.ErrorText = "点検詳細品目コードの取得データがありません。";
                //}
                // mod #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 高 end
            }

            return this.m_FilterInspectioData;
        }
        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end

        /// <summary>
        /// イベントフィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterPatEventData>>> GetFilterPatEventData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if( this.m_FilterPatEventData != null && this.m_FilterPatEventData.IsSuccess ) return this.m_FilterPatEventData;

            this.m_FilterPatEventData = new RldRestResultData<List<FilterPatEventData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_ABS_PAT_EVENT,
            //    String.Empty);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_ABS_PAT_EVENT,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("患者イベント一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterPatEventData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterPatEventData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if( this.m_FilterPatEventData.IsSuccess )
                this.m_FilterPatEventData.Data = RldJsonDataSerializeHelper<List<FilterPatEventData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterPatEventData;
        }

        /// <summary>
        /// 加算フィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterAdditionData>>> GetFilterAdditionData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if( this.m_FilterAdditionData != null && this.m_FilterAdditionData.IsSuccess ) return this.m_FilterAdditionData;

            this.m_FilterAdditionData = new RldRestResultData<List<FilterAdditionData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_ABS_ADDITION,
            //    String.Empty);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_ABS_ADDITION,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("加算一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterAdditionData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterAdditionData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if( m_FilterAdditionData.IsSuccess )
                this.m_FilterAdditionData.Data = RldJsonDataSerializeHelper<List<FilterAdditionData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterAdditionData;
        }

        /// <summary>
        /// 水質調査箇所フィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterWaterSurveyPointData>>> GetFilterWaterSurveyPointData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if( this.m_FilterWaterSurveyPointData != null && this.m_FilterWaterSurveyPointData.IsSuccess ) return this.m_FilterWaterSurveyPointData;

            this.m_FilterWaterSurveyPointData = new RldRestResultData<List<FilterWaterSurveyPointData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_MST_WATER_SURVEY_POINT,
            //    String.Empty);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_MST_WATER_SURVEY_POINT,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("水質調査箇所一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterWaterSurveyPointData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterWaterSurveyPointData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if( m_FilterWaterSurveyPointData.IsSuccess )
                this.m_FilterWaterSurveyPointData.Data = RldJsonDataSerializeHelper<List<FilterWaterSurveyPointData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterWaterSurveyPointData;
        }
        //add #8489 zhu start
        /// <summary>
        ///ダイアライザフィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterDistributionData>>> GetFilterDistributionData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if (this.m_FilterDistributionData != null && this.m_FilterDistributionData.IsSuccess) return this.m_FilterDistributionData;

            this.m_FilterDistributionData = new RldRestResultData<List<FilterDistributionData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_ABS_Distribution,
            //    String.Empty);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_ABS_Distribution,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("ダイアライザフィルタ用データ取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterDistributionData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterDistributionData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if (this.m_FilterDistributionData.IsSuccess)
                this.m_FilterDistributionData.Data = RldJsonDataSerializeHelper<List<FilterDistributionData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterDistributionData;
        }

        /// <summary>
        ///  配布リスト(ベッド)フィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterAdditionData>>> GetFilterAdditionsData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if (this.m_FilterAdditionData != null && this.m_FilterAdditionData.IsSuccess) return this.m_FilterAdditionData;

            this.m_FilterAdditionData = new RldRestResultData<List<FilterAdditionData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_ABS_ADDITION,
            //    String.Empty);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_ABS_ADDITION,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("加算一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterAdditionData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterAdditionData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if (m_FilterAdditionData.IsSuccess)
                this.m_FilterAdditionData.Data = RldJsonDataSerializeHelper<List<FilterAdditionData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterAdditionData;
        }
        //add #8489 zhu end

        // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
        /// <summary>
        /// レセプトフィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterReceiptData>>> GetFilterReceiptData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if (this.m_FilterReceiptData != null && this.m_FilterReceiptData.IsSuccess) return this.m_FilterReceiptData;

            this.m_FilterReceiptData = new RldRestResultData<List<FilterReceiptData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_ABS_RECEIPT,
            //    String.Empty);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_ABS_RECEIPT,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("レセプトフィルタ用データ取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterReceiptData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterReceiptData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if (this.m_FilterReceiptData.IsSuccess)
                this.m_FilterReceiptData.Data = RldJsonDataSerializeHelper<List<FilterReceiptData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterReceiptData;
        }
        // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end

        // add #12006 感染症がフィルタできない 高 start
        /// <summary>
        /// 感染症フィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterAdditionData>>> GetFilterInfectionData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if (this.m_FilterInfectionData != null && this.m_FilterInfectionData.IsSuccess) return this.m_FilterInfectionData;

            this.m_FilterInfectionData = new RldRestResultData<List<FilterAdditionData>>();

            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            //String wUri = String.Format("{0}{1}{2}/{3}",
            //    NKKWebAccess.BaseUri,
            //    RldConst.Uri.WEB_APP,
            //    RldConst.Uri.GET_ABS_INFECTION,
            //    //LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            //    string.Empty);
            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_ABS_INFECTION,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
            // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

            var wRestRet = await NKKWebAccess.Get("感染症一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterInfectionData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterInfectionData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if (m_FilterInfectionData.IsSuccess)
                this.m_FilterInfectionData.Data = RldJsonDataSerializeHelper<List<FilterAdditionData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterInfectionData;
        }
        // add #12006 感染症がフィルタできない 高 end

        // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
        /// <summary>
        /// 水質検査個所フィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterWaterTestPointData>>> GetFilterWQTestPointData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            //if (this.m_FilterWQTestPointData != null && this.m_FilterWQTestPointData.IsSuccess) return this.m_FilterWQTestPointData;

            this.m_FilterWQTestPointData = new RldRestResultData<List<FilterWaterTestPointData>>();

            string MachineTypeCD = "0";

            if (string.IsNullOrEmpty(RldLib.inspectionLayoutData.MachineTypeCD) == false)
                MachineTypeCD = RldLib.inspectionLayoutData.MachineTypeCD;
            String wUri = String.Format("{0}{1}{2}/{3}/{4}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_ABS_WQTESTPOINT,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd,
                MachineTypeCD);

            var wRestRet = await NKKWebAccess.Get("水質検査個所一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterWQTestPointData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterWQTestPointData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if (m_FilterWQTestPointData.IsSuccess)
                this.m_FilterWQTestPointData.Data = RldJsonDataSerializeHelper<List<FilterWaterTestPointData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterWQTestPointData;
        }

        /// <summary>
        /// 水質検査種別フィルタデータの取得を行います。
        /// </summary>
        /// <returns></returns>
        public async Task<RldRestResultData<List<FilterAdditionData>>> GetFilterWQTestTypeData()
        {
            // 取得に成功した結果をキャッシュしている場合はキャッシュを返す
            if (this.m_FilterWQTestTypeData != null && this.m_FilterWQTestTypeData.IsSuccess) return this.m_FilterWQTestTypeData;

            this.m_FilterWQTestTypeData = new RldRestResultData<List<FilterAdditionData>>();

            String wUri = String.Format("{0}{1}{2}/{3}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP,
                RldConst.Uri.GET_ABS_WQTESTTYPE,
                LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);

            var wRestRet = await NKKWebAccess.Get("水質検査種別一覧取得", wUri, NKKWebAccess.SKIP_OTP);

            // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
            this.m_FilterWQTestTypeData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
            // エラーメッセージを更新
            this.m_FilterWQTestTypeData.ErrorText = RldLib.MakeRestResultErrorText(wRestRet);

            // 取得データを戻り値にセット
            if (m_FilterWQTestTypeData.IsSuccess)
                this.m_FilterWQTestTypeData.Data = RldJsonDataSerializeHelper<List<FilterAdditionData>>.Deserialize(wRestRet.strContent);

            return this.m_FilterWQTestTypeData;
        }
        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
        // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end

        // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
        public void ClearFilterData()
        {
            m_FilterObsKindData = null;
            m_FilterMedicineData = null;
            m_FilterEquipmentData = null;
            m_FilterDialDiffData = null;
            m_FilterExamItemData = null;
            m_FilterCategoryData = null;
            m_FilterExamSetData = null;
            m_FilterPatEventData = null;
            m_FilterAdditionData = null;
            m_FilterWaterSurveyPointData = null;
            m_FilterInspectioData = null;
            m_FilterDistributionData = null;
            m_FilterReceiptData = null;
            m_FilterInfectionData = null;
            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
            m_FilterWQTestPointData = null;
            m_FilterWQTestTypeData = null;
            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
        }
        // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

        #endregion
    }
}
