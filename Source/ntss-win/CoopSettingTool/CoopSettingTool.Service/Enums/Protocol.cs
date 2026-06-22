// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-14-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-14-2021
// ***********************************************************************
// <copyright file="Protocol.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************


namespace CoopSettingTool.Service.Enums
{
    /// <summary>
    /// Enum Protocol
    /// </summary>
    public enum ReceiveProtocol
    {
        /// <summary>
        /// The socket
        /// </summary>
        socket = 0,
        /// <summary>
        /// The file
        /// </summary>
        file = 1,
        /// <summary>
        /// The head socket
        /// </summary>
        headsocket = 2
    }

    /// <summary>
    /// Enum Protocol
    /// </summary>
    public enum SendProtocol
    {
        /// <summary>
        /// The socket
        /// </summary>
        socket = 0,
        /// <summary>
        /// The file
        /// </summary>
        file = 1,
        /// <summary>
        /// The file socket
        /// </summary>
        filesocket = 2
    }
}
