using NKKWeightScaleApp.Models;
using NKKWeightScaleDB.Services;
using System;
using System.Collections.Generic;
using System.Linq;

namespace NKKWeightScaleApp.Services
{
    public class BedController
    {
        private readonly MstBedService mstBedService;

        public BedController()
        {
            this.mstBedService = new MstBedService();
        }

        public List<Bed> GetAll()
        {
            try
            {
                var bedList = this.mstBedService.GetAll().Select(item => new Bed()
                {
                    Selected = false,
                    BedName = item.bed_name,
                    ConnectedDevice = item.machine_no.ToString(),
                    BedID = item.bed_cd.ToString()
                }).ToList();
                return bedList;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return null;
            }
        }

        public Bed GetByID(string bedCd)
        {
            try
            {
                var bedList = this.mstBedService.GetAll().Where(item=>item.bed_cd== bedCd).Select(item => new Bed()
                {
                    Selected = false,
                    BedName = item.bed_name,
                    ConnectedDevice = item.machine_no.ToString(),
                    BedID = item.bed_cd.ToString()
                }).FirstOrDefault();
                return bedList;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return null;
            }
        }
    }
}