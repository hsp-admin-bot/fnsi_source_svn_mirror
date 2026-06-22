// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-13-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-14-2022
// ***********************************************************************
// <copyright file="CoopFacilitySettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.App.DI;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.App.Views;
using CoopSettingTool.Service;
using CoopSettingTool.Service.Models;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Dynamic;
using System.Net;
using System.Threading;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class CoopFacilitySettingController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopFacilitySettingView, CoopSettingTool.App.Models.ICoopFacilitySettingModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.ICoopFacilitySettingController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopFacilitySettingView, CoopSettingTool.App.Models.ICoopFacilitySettingModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.ICoopFacilitySettingController" />
    public class CoopFacilitySettingController : BaseController<ICoopFacilitySettingView, ICoopFacilitySettingModel>, ICoopFacilitySettingController
    {
        /// <summary>
        /// The MST coop facility service
        /// </summary>
        IMstCoopFacilityService mstCoopFacilityService;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopFacilitySettingController"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public CoopFacilitySettingController(ICoopFacilitySettingView view, ICoopFacilitySettingModel model) : base(view, model)
        {
            mstCoopFacilityService = CompositionRoot.Resolve<IMstCoopFacilityService>();
        }

        /// <summary>
        /// Loads the coop facility.
        /// </summary>
        public async void LoadCoopFacility()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                // リクェストを初期化する
                var param = new GetMstCoopFacilityRequest()
                {
                    FacilityCd = this.Model.Facility.FacilityCd,

                };

                // APIでMstCoopFacilityを取得する
                var res = mstCoopFacilityService.GetMstCoopFacility(param).Result;
                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    this.Model.CoopFacility = res.Data.Content.FirstOrDefault();
                    if (this.Model.CoopFacility == null)
                    {
                        this.View.ShowMessage(Resources.WARNING_COOP_NOT_INSTALLED, Resources.WARNING, Enums.MessageTypeEnum.WARNING);
                    }
                }
                else
                {
                    if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                    {
                        return false;
                    }
                }

                return true;
            });

            this.View.HideLoading();

            if (!result)
            {
                this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
            }
        }

        /// <summary>
        /// Saves this instance.
        /// </summary>
        public async void Save()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                #region MstCoopFacilityにコミットする

                // MstCoopFacilityを保存する
                if (this.Model.CoopFacility.IsModified)
                {
                    var res = mstCoopFacilityService.SubmitMstCoopFacility(this.Model.CoopFacility).Result;
                    if (res == null || res.StatusCode != HttpStatusCode.OK)
                    {
                        return false;
                    }
                }

                #endregion

                return true;
            });

            this.View.HideLoading();

            if (!result)
            {
                if (this.View.ShowAskMessage(Resources.ERROR_DATA_SAVE + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                {
                    this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
                }
            }
            else
            {
                this.View.CloseView(System.Windows.Forms.DialogResult.OK);
            }
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            this.Model.ClearData();
        }

        /// <summary>
        /// ファイルをインポートする
        /// </summary>
        /// <param name="filePath"></param>
        public async void Import(string filePath)
        {
            this.View.ShowLoading();

            await Task.Run(() =>
            {
                JObject jsonObjectEdge = JObject.Parse(this.Model.CoopFacility.IfEdgeSetting);
                JObject jsonObjectCommon = JObject.Parse(this.Model.CoopFacility.CommonSetting);

                // ファイルのすべての行を取り込む
                List<string[]> lines = File.ReadAllLines(filePath).Skip(1).Select(v => v.Split(','))
                                            .ToList();
                foreach (string[] line in lines)
                {
                    // 行のアイテムが6以上時に取り込む
                    // *Setting, Path, Value
                    if (line.Length >= 3)
                    {
                        switch (line[0])
                        {
                            case "if_edge_setting":
                                {
                                    UpdateJsonByPath(jsonObjectEdge, line[1], line[2]);
                                    break;
                                }
                            case "common_setting":
                                {
                                    UpdateJsonByPath(jsonObjectCommon, line[1], line[2]);
                                    break;
                                }
                            default:
                                {
                                    break;
                                }
                        }
                    }
                }

                this.Model.CoopFacility.IfEdgeSetting = jsonObjectEdge.ToString();
                this.Model.CoopFacility.CommonSetting = jsonObjectCommon.ToString();

            });

            this.View.HideLoading();
        }

        /// <summary>
        /// JSONを更新する
        /// </summary>
        /// <param name="jsonObject"></param>
        /// <param name="path"></param>
        /// <param name="value"></param>
        private static void UpdateJsonByPath(JObject jsonObject, string path, string value)
        {
            string[] splitedPath = path.Split(';');

            if(splitedPath.Length >= 1)
            {
                UpdateJsonByPathEx(jsonObject, ref splitedPath, 0, value);
            }
        }

        /// <summary>
        /// JSONを更新する
        /// </summary>
        /// <param name="jsonObject"></param>
        /// <param name="path"></param>
        /// <param name="pathIndex"></param>
        /// <param name="value"></param>
        private static void UpdateJsonByPathEx(JObject jsonObject, ref string[] path, int pathIndex, string value)
        {
            // パスの最後だったら値を設定する
            if (path.Length == pathIndex + 1)
            {
                JToken jToken = jsonObject[path[pathIndex]];

                // Stringなら設定する
                if (jToken.Type == JTokenType.String || jToken.Type == JTokenType.Integer || jToken.Type == JTokenType.Null)
                {
                    jsonObject[path[pathIndex]] = value;
                }
                else if (jToken.Type == JTokenType.Array)
                {
                    // Arrayなら追加する
                    JArray jArray = (JArray)jsonObject[path[pathIndex]];
                    if (!jArray.Contains(value))
                    {
                        jArray.Add(value);
                    }
                }
                else
                {
                }
            }
            else
            {
                string[] pathDetails = path[pathIndex].Split('?');

                JToken jToken = jsonObject[pathDetails[0]];

                if (jToken.Type == JTokenType.Object)
                {
                    // オブジェクトなら条件必要ない
                    UpdateJsonByPathEx((JObject)jToken, ref path, pathIndex + 1, value);
                }
                else if (jToken.Type == JTokenType.Array)
                {
                    foreach (JObject childItem in (JArray)jToken)
                    {
                        // 条件がない場合
                        if (pathDetails.Length == 1)
                        {
                            UpdateJsonByPathEx(childItem, ref path, pathIndex + 1, value);
                        }
                        else
                        {
                            // 条件の場合
                            bool checkCond = true;
                            string[] conds = pathDetails[1].Split('&');

                            // 条件をループ
                            for (int i = 0; i < conds.Length; i++)
                            {
                                string[] cond = conds[i].Split('=');
                                // 条件をチェック
                                if ((string)childItem[cond[0]] != cond[1])
                                {
                                    checkCond = false;
                                    break;
                                }
                            }

                            // 条件全部合ってる場合
                            if (checkCond)
                            {
                                UpdateJsonByPathEx(childItem, ref path, pathIndex + 1, value);
                            }
                        }
                    }
                }
            }

        }
    }
}
