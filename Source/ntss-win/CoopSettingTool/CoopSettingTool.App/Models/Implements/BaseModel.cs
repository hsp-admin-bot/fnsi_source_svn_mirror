// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-19-2021
// ***********************************************************************
// <copyright file="BaseModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using Microsoft.Win32.SafeHandles;
using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class BaseModel.
    /// Implements the <see cref="System.ComponentModel.INotifyPropertyChanged" />
    /// Implements the <see cref="CoopSettingTool.App.Models.IBaseModel" />
    /// </summary>
    /// <seealso cref="System.ComponentModel.INotifyPropertyChanged" />
    /// <seealso cref="CoopSettingTool.App.Models.IBaseModel" />
    public class BaseModel : INotifyPropertyChanged, IBaseModel
    {
        // Flag: Has Dispose already been called?
        /// <summary>
        /// The disposed
        /// </summary>
        private bool disposed = false;

        // Instantiate a SafeHandle instance.
        /// <summary>
        /// The handle
        /// </summary>
        private SafeHandle handle = new SafeFileHandle(IntPtr.Zero, true);

        // Public implementation of Dispose pattern callable by consumers.
        /// <summary>
        /// Disposes this instance.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        // Protected implementation of Dispose pattern.
        /// <summary>
        /// Releases unmanaged and - optionally - managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (disposed)
                return;

            if (disposing)
            {
                handle.Dispose();
                // Free any other managed objects here.
                //
            }

            disposed = true;
        }

        /// <summary>
        /// プロパティ値が変更するときに発生します。
        /// </summary>
        public event PropertyChangedEventHandler PropertyChanged;

        /// <summary>
        /// Notifies the property changed.
        /// </summary>
        /// <param name="propertyName">Name of the property.</param>
        protected void NotifyPropertyChanged([CallerMemberName] string propertyName = "")
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
            }
        }


        /// <summary>
        /// Clears the data.
        /// </summary>
        public virtual void ClearData()
        {

        }
    }
}
