// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-31-2021
// ***********************************************************************
// <copyright file="CoopSettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.DI;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.App.Views;
using CoopSettingTool.Service;
using CoopSettingTool.Service.Extendsions;
using CoopSettingTool.Service.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Dynamic;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using CoopSettingTool.Service.Utils;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class CoopSettingController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopSettingView, CoopSettingTool.App.Models.ICoopSettingModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.ICoopSettingController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopSettingView, CoopSettingTool.App.Models.ICoopSettingModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.ICoopSettingController" />
    public class CoopSettingController : BaseController<ICoopSettingView, ICoopSettingModel>, ICoopSettingController
    {
        /// <summary>
        /// 連携設定サービス
        /// </summary>
        IMstCoopIniService mstCoopIniService;

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public CoopSettingController(ICoopSettingView view, ICoopSettingModel model) : base(view, model)
        {
            mstCoopIniService = CompositionRoot.Resolve<IMstCoopIniService>();
        }

        /// <summary>
        /// Adds the blank setting.
        /// </summary>
        /// <param name="addIndex">Index of the add.</param>
        public void AddBlankSetting(int addIndex)
        {
            this.Model.AddBlankSetting(addIndex);
        }

        /// <summary>
        /// 連携設定取得
        /// </summary>
        public async void LoadCoopIni()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                var res = mstCoopIniService.GetMstCoopIni(this.Model.Facility.FacilityCd).Result;
                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    this.Model.CoopIni = res.Data.FirstOrDefault();
                }
                else
                {
                    if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                    {
                        return false;
                    }
                }

                if (this.Model.CoopIni == null)
                {
                    this.Model.CoopIni = new MstCoopIniEntity(this.Model.Facility.FacilityCd);
                }
                var coopIniInfos = this.Model.CoopIni.GetCoopIniInfos();
                if (coopIniInfos.Count == 0)
                {
                    coopIniInfos.Add(new CoopIniInfo());
                }
                this.Model.CoopIniInfos = coopIniInfos;

                return true;
            });

            this.View.HideLoading();

            if (!result)
            {
                this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
            }
        }

        /// <summary>
        /// Removes the setting.
        /// </summary>
        /// <param name="removeList">The remove list.</param>
        /// <exception cref="System.NotImplementedException"></exception>
        public void OnOffSetting(List<CoopIniInfo> removeList)
        {
            this.Model.OnOffSetting(removeList);
        }

        /// <summary>
        /// 保存する
        /// </summary>
        public async void Save()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                // nullを捨てる
                this.Model.CoopIniInfos.RemoveAll(x => string.IsNullOrEmpty(x.Key1) && string.IsNullOrEmpty(x.Key2));

                // APIで保存する
                this.Model.CoopIni.SetCoopIniInfos(this.Model.CoopIniInfos);
                if (this.Model.CoopIni.IsModified)
                {
                    var res = mstCoopIniService.SubmitMstCoopIni(this.Model.CoopIni).Result;
                    if (res != null && res.StatusCode == HttpStatusCode.OK)
                    {
                    }
                    else
                    {
                        return false;
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
        /// Exports the coop ini.
        /// </summary>
        /// <param name="fileName">Name of the file.</param>
        public async void ExportCoopIni(string fileName)
        {
            this.View.ShowLoading();

            await Task.Run(() =>
            {
                string strCsv = this.Model.CoopIniInfos.ToCsv();
                // Create a new file     
                using (FileStream fs = File.Create(fileName))
                {
                    // Add some text to file    
                    Byte[] title = new UTF8Encoding(true).GetBytes(strCsv);
                    fs.Write(title, 0, title.Length);
                }
            });

            this.View.HideLoading();
        }

        /// <summary>
        /// Imports the coop ini.
        /// </summary>
        /// <param name="fileName">Name of the file.</param>
        public async void ImportCoopIni(string fileName)
        {
            this.View.ShowLoading();

            await Task.Run(() =>
            {
                List<CoopIniInfo> importedIniList = CsvReader.Read(fileName, Encoding.UTF8)
                                           .Skip(1)
                                           .Select(v => CoopIniInfo.FromCsv(v))
                                           .ToList();

                List<CoopIniInfo> baseIniList = this.Model.CoopIniInfos;
                baseIniList.RemoveAll(x => string.IsNullOrEmpty(x.Key0) && string.IsNullOrEmpty(x.Key1) && string.IsNullOrEmpty(x.Key2));
                foreach (CoopIniInfo ini in importedIniList)
                {
                    CoopIniInfo baseIni = baseIniList.FirstOrDefault(x => x.Key0.Equals(ini.Key0) && x.Key1.Equals(ini.Key1) && x.Key2.Equals(ini.Key2));
                    if (baseIni != null)
                    {
                        baseIni.Value = ini.Value;
                        baseIni.Comment = string.IsNullOrEmpty(ini.Comment) ? baseIni.Comment: ini.Comment;
                        baseIni.DefaultValue = ini.DefaultValue;
                        baseIni.IsEffect = ini.IsEffect;
                    }
                    else
                    {
                        baseIniList.Add(ini);
                    }
                }

                this.Model.CoopIniInfos = baseIniList;
            });

            this.View.HideLoading();
        }

        /// <summary>
        /// Sorts the settings.
        /// </summary>
        /// <param name="sortField">The sort field.</param>
        /// <param name="isReverse">if set to <c>true</c> [is reverse].</param>
        public void SortSettings(string sortField, bool isReverse)
        {
            // ソートする
            if (!isReverse)
                this.Model.CoopIniInfos = this.Model.CoopIniInfos.OrderBy(sortField).ToList();
            else
                this.Model.CoopIniInfos = this.Model.CoopIniInfos.OrderBy(sortField).Reverse().ToList();
        }
    }
}
