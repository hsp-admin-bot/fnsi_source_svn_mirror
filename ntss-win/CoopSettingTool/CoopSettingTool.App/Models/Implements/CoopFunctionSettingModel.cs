// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-20-2021
// ***********************************************************************
// <copyright file="CoopFunctionSettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class CoopFunctionSettingModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.ICoopFunctionSettingModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.ICoopFunctionSettingModel" />
    public class CoopFunctionSettingModel : BaseModel, ICoopFunctionSettingModel
    {
        /// <summary>
        /// The facility
        /// </summary>
        private MstFacilityEntity facility;

        /// <summary>
        /// The coop facility
        /// </summary>
        private MstCoopFacilityEntity coopFacility;

        /// <summary>
        /// If egde setting
        /// </summary>
        private IfEgdeSetting ifEgdeSetting;

        /// <summary>
        /// The watch infos
        /// </summary>
        private WatchInfo watchInfos;

        /// <summary>
        /// The coop function index
        /// </summary>
        private int coopFunctionIndex;

        /// <summary>
        /// The coop layout list
        /// </summary>
        private List<MstCoopLayoutEntity> coopLayoutList;

        /// <summary>
        /// The coop distribute list
        /// </summary>
        private List<MstCoopDistributeEntity> coopDistributeList;

        /// <summary>
        /// The send protocol
        /// </summary>
        private ProtocolInfo sendProtocol;

        /// <summary>
        /// Gets or sets the facility.
        /// </summary>
        /// <value>The coop facility.</value>
        public MstFacilityEntity Facility
        {
            get
            {
                return facility;
            }
            set
            {
                facility = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Gets or sets the coop facility.
        /// </summary>
        /// <value>The coop facility.</value>
        public MstCoopFacilityEntity CoopFacility
        {
            get
            {
                return coopFacility;
            }
            set
            {
                coopFacility = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Gets or sets if egde setting.
        /// </summary>
        /// <value>If egde setting.</value>
        public IfEgdeSetting IfEgdeSetting
        {
            get
            {
                return ifEgdeSetting;
            }
            set
            {
                ifEgdeSetting = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Gets or sets the watch information.
        /// </summary>
        /// <value>The watch information.</value>
        public WatchInfo WatchInfo
        {
            get
            {
                return watchInfos;
            }
            set
            {
                watchInfos = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Gets or sets the index of the coop function.
        /// </summary>
        /// <value>The index of the coop function.</value>
        public int CoopFunctionIndex
        {
            get
            {
                return coopFunctionIndex;
            }
            set
            {
                coopFunctionIndex = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Gets or sets the coop layout list.
        /// </summary>
        /// <value>The coop layout list.</value>
        public List<MstCoopLayoutEntity> CoopLayoutList
        {
            get
            {
                return coopLayoutList;
            }
            set
            {
                coopLayoutList = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Gets or sets the coop distribute list.
        /// </summary>
        /// <value>The coop distribute list.</value>
        public List<MstCoopDistributeEntity> CoopDistributeList
        {
            get
            {
                return coopDistributeList;
            }
            set
            {
                coopDistributeList = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Gets or sets the send protocol.
        /// </summary>
        /// <value>The send protocol.</value>
        public ProtocolInfo SendProtocol
        {
            get
            {
                return sendProtocol;
            }
            set
            {
                sendProtocol = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            SendProtocol = null;
            CoopDistributeList = null;
            CoopLayoutList = null;
            CoopFunctionIndex = -1;
            WatchInfo = null;
            IfEgdeSetting = null;
            CoopFacility = null;
        }
    }
}
