// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-10-2021
// ***********************************************************************
// <copyright file="BaseEntity.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.Serialization;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class BaseEntity.
    /// </summary>
    public abstract class BaseEntity
    {
        /// <summary>
        /// The original hash
        /// </summary>
        private int OriginalHash = 0;

        /// <summary>
        /// Initializes a new instance of the <see cref="BaseEntity"/> class.
        /// </summary>
        public BaseEntity()
        {
        }

        /// <summary>
        /// Gets or sets the extension data.
        /// </summary>
        /// <value>The extension data.</value>
        [JsonExtensionData]
        [Browsable(false)]
        public Dictionary<string, object> ExtensionData { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this instance is modified.
        /// </summary>
        /// <value><c>true</c> if this instance is modified; otherwise, <c>false</c>.</value>
        [JsonIgnore]
        [Browsable(false)]
        public bool IsModified
        {
            get
            {
                int newHash = this.GetHashCode();
                return newHash != OriginalHash;
            }
        }

        /// <summary>
        /// Makes the original hash.
        /// </summary>
        [OnDeserialized]
        private void OnDeserialized(StreamingContext context)
        {
            this.Initialize();
        }

        /// <summary>
        /// Initialize the instance.
        /// </summary>
        protected virtual void Initialize()
        {
            this.OriginalHash = this.GetHashCode();
        }
    }

    
}
