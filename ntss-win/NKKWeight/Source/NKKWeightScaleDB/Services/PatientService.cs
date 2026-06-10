namespace NKKWeightScaleDB.Services
{
    using System;
    using NKKWeightScaleDB.Interfaces;
    using NKKWeightScaleDB.Models;

    public class PatientService : BaseService<Patient>, IPatientService
    {
        public Patient AddOrUpdate(Patient patient)
        {
            Patient result = patient;
            var currentData = this.GetAll();
            var index = currentData.FindIndex(item => item.PatientID == patient.PatientID);
            if (index != -1)
            {
                currentData[index].PatientID = patient.PatientID;
                currentData[index].PatientName = patient.PatientName;
                result = this.Update(currentData[index]);
            }
            else
            {
                result = this.Create(patient);
            }
            return result;
        }
    }
}