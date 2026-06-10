// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-14-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-14-2022
// ***********************************************************************
// <copyright file="CoopDistributeSettingController.cs" company="">
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
using System.Text;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class CoopDistributeSettingController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopDistributeSettingView, CoopSettingTool.App.Models.ICoopDistributeSettingModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.ICoopDistributeSettingController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopDistributeSettingView, CoopSettingTool.App.Models.ICoopDistributeSettingModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.ICoopDistributeSettingController" />
    public class CoopDistributeSettingController : BaseController<ICoopDistributeSettingView, ICoopDistributeSettingModel>, ICoopDistributeSettingController
    {
        /// <summary>
        /// The MST coop distribute service
        /// </summary>
        IMstCoopDistributeService mstCoopDistributeService;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopDistributeSettingController" /> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public CoopDistributeSettingController(ICoopDistributeSettingView view, ICoopDistributeSettingModel model) : base(view, model)
        {
            mstCoopDistributeService = CompositionRoot.Resolve<IMstCoopDistributeService>();
        }

        /// <summary>
        /// Loads the coop distributes.
        /// </summary>
        public async void LoadCoopDistributes()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                bool ret = true;
                // APIでMstCoopDistributeを取得する
                var res = mstCoopDistributeService.GetNewestMstCoopDistributeCtlNoList(this.Model.Facility.FacilityCd).Result;
                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    List<MstCoopDistributeEntity> mstCoopDistributeEntities = new List<MstCoopDistributeEntity>();
                    StringBuilder sb = new StringBuilder();
                    foreach (string ctlNo in res.Data)
                    {
                        var res1 = mstCoopDistributeService.GetMstCoopDistributeByCtlNo(ctlNo).Result;
                        if (res1 != null && res1.StatusCode == HttpStatusCode.OK)
                        {
                            mstCoopDistributeEntities.Add(res1.Data);
                        }
                        else
                        {
                            sb.Append(ctlNo + " ");
                        }
                    }

                    if (sb.Length > 0)
                    {
                        this.View.ShowMessage(Resources.WARNING_SOME_DATA_CANNOT_GET + sb.ToString(), Resources.WARNING, Enums.MessageTypeEnum.WARNING);
                    }

                    this.Model.CoopDistributes = mstCoopDistributeEntities;
                }
                else
                {
                    ret = false;
                }

                return ret;
            });

            this.View.HideLoading();

            if (!result)
            {
                if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                {
                    this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
                }
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
                // MstCoopDistributeを保存する
                foreach (MstCoopDistributeEntity distribute in this.Model.CoopDistributes)
                {
                    if (distribute.IsModified)
                    {
                        var res = mstCoopDistributeService.CreateOrUpdateMstCoopDistribute(distribute).Result;
                        if (res == null || res.StatusCode != HttpStatusCode.OK)
                        {
                            return false;
                        }
                    }
                }
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
        /// Sorts by the specified sort field.
        /// </summary>
        /// <param name="sortField">The sort field.</param>
        /// <param name="isReverse">if set to <c>true</c> [is reverse].</param>
        public void Sort(string sortField, bool isReverse)
        {
            // ソートする
            if (!isReverse)
                this.Model.CoopDistributes = this.Model.CoopDistributes.OrderBy(sortField).ToList();
            else
                this.Model.CoopDistributes = this.Model.CoopDistributes.OrderBy(sortField).Reverse().ToList();
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
               // ファイルのすべての行を取り込む
               List<string[]> lines =  File.ReadAllLines(filePath).Skip(1).Select(v => v.Split(','))
                                           .ToList();
                foreach(string[] line in lines)
                {
                    // 行のアイテムが6以上時に取り込む
                    // *CoopCd, CoopCdIndex, Direction, CoopVersion, JsonKey, Value
                    if (line.Length >= 6)
                    {
                        // 合ってる連携配信設定を探す
                        MstCoopDistributeEntity distribute = this.Model.CoopDistributes.FirstOrDefault(x => x.CoopCd == line[0]
                                                                                                    && x.CoopCdIndex == line[1]
                                                                                                    && x.Direction == line[2]
                                                                                                    && x.CoopVersion == line[3]
                                                                                                    && x.IsDel == "0");

                        // ファイルの情報で上書き
                        if(distribute != null)
                        {
                            JObject jsonObject = JObject.Parse(distribute.DistributeSetting);

                            JToken timeoutToken = jsonObject["protocolInfo"][line[4]];

                            if (timeoutToken != null)
                            {
                                timeoutToken.Replace(line[5]);
                            }

                            distribute.DistributeSetting = jsonObject.ToString();
                        }
                    }
                }

            });

            this.View.HideLoading();
        }
    }
}
