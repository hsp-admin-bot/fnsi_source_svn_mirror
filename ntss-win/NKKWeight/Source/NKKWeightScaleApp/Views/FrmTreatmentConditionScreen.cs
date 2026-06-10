using NKKWeightScaleApp.Commons;
using NKKWeightScaleApp.Controller;
using NKKWeightScaleApp.Models;
using NKKWeightScaleDB.Models;
using NKKWeightScaleDB.Services;
using System;
using System.Windows.Forms;

namespace NKKWeightScaleApp.Views
{
    public partial class FrmTreatmentConditionScreen : Form
    {
        private string oldValue;
        private PatientEx patient;
        private SetInfoEx setInfoEx;
        private Bed bed;
        private ConvertTool convertTool = new ConvertTool();

        public FrmTreatmentConditionScreen(PatientEx getPatient, SetInfoEx getInfoEx, Bed _bed)
        {
            InitializeComponent();

            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKWeight;
            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 end

            patient = getPatient;
            setInfoEx = getInfoEx;
            bed = _bed;
            LoadData();
        }

        private void TextBox_TextChanged(object sender, EventArgs e)
        {
            TextBox textBox = sender as TextBox;
            int positionCursor = textBox.SelectionStart;

            decimal.TryParse(textBox.Text.Trim(), out decimal value);
            if (value > ConfigValue.MAX_VALUE)
            {
                textBox.Text = oldValue;
                textBox.SelectionStart = (positionCursor <= 0) ? 0 : positionCursor - 1;
            }
            oldValue = textBox.Text.Trim();
        }

        private void TextBox_Leave(object sender, EventArgs e)
        {
            TextBox textBox = sender as TextBox;
            if (textBox.Text != string.Empty)
            {
                decimal.TryParse(textBox.Text.Trim(), out decimal value);
                textBox.Text = string.Format(ConfigValue.FORMAT, value);
            }
            else
                textBox.Text = "0";
            if (textBox.Text != string.Empty && (textBox.Name == txtTargetWeight.Name || textBox.Name == txtWaterRemovalRestriction.Name))
            {
                SaveInfoDefault();
            }
        }

        private void TextBox_Enter(object sender, EventArgs e)
        {
            TextBox textBox = sender as TextBox;
            oldValue = textBox.Text.Trim();
        }

        private void TextBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            TextBox textBox = sender as TextBox;
            if (e.KeyChar == (char)13)
            {
                if ((textBox.Name == txtTargetWeight.Name || textBox.Name == txtWaterRemovalRestriction.Name) && textBox.Text == string.Empty)
                {
                    textBox.Text = "0";
                }
                if (textBox.Text != string.Empty && (textBox.Name == txtTargetWeight.Name || textBox.Name == txtWaterRemovalRestriction.Name))
                {
                    SaveInfoDefault();
                }
            }
            if (!char.IsDigit(e.KeyChar) && (e.KeyChar != '.') && (e.KeyChar != (char)Keys.Back))
            {
                e.Handled = true;
            }
            if ((e.KeyChar == '.') && ((sender as TextBox).Text.IndexOf('.') > -1))
            {
                e.Handled = true;
            }
            if (char.IsDigit(e.KeyChar))
            {
                int cursorPosLeft = textBox.SelectionStart;
                int cursorPosRight = textBox.SelectionStart + textBox.SelectionLength;
                string result = textBox.Text.Substring(0, cursorPosLeft) + e.KeyChar + textBox.Text.Substring(cursorPosRight);
                string[] parts = result.Split('.');
                if (parts.Length > 1)
                {
                    if (parts[1].Length > 2)
                    {
                        e.Handled = true;
                    }
                }
            }
        }

        private void btnBack_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void SaveInfoDefault()
        {
            SetInfoController setInfoDefaultController = new SetInfoController();
            decimal.TryParse(txtTargetWeight.Text.Trim(), out decimal targetWeight);
            decimal.TryParse(convertTool.ReplaceValue(txtWaterRemovalRestriction.Text.Trim()), out decimal waterRemovalRestriction);
            if (txtTargetWeight.Text.Trim() != string.Empty)
                setInfoEx.TargetWeight = convertTool.FormatValue(targetWeight);
            else
                setInfoEx.TargetWeight = null;

            if (txtWaterRemovalRestriction.Text.Trim() != string.Empty)
                setInfoEx.WaterRemovalRestriction = convertTool.FormatValue(waterRemovalRestriction);
            else
                setInfoEx.WaterRemovalRestriction = null;
            setInfoDefaultController.SaveData(setInfoEx);
        }

        private void LoadData()
        {
            TreatmentConditionService treatmentConditionService = new TreatmentConditionService();
            Treatment_condition treatment_condition = new Treatment_condition();
            var currentData = treatmentConditionService.GetAll();
            var index = currentData.FindIndex(item => item.patient_id == patient.PatientID);
            if (index > -1)
            {
                treatment_condition = currentData[index];
            }
            if (setInfoEx != null)
            {
                if (!string.IsNullOrEmpty(setInfoEx.TargetWeight))
                {
                    txtTargetWeight.Text = convertTool.FormatValue(decimal.Parse(setInfoEx.TargetWeight));
                }
                if (!string.IsNullOrEmpty(setInfoEx.WaterRemovalRestriction))
                {
                    txtWaterRemovalRestriction.Text = convertTool.FormatValue(decimal.Parse(setInfoEx.WaterRemovalRestriction));
                }
            }
            txtMethodOfTreatment.Text = treatment_condition.method_of_treatment;
            txtCool.Text = treatment_condition.cool;
            txtDialysisStartTime.Text = treatment_condition.dialysis_start_time;
            if (bed != null && !string.IsNullOrEmpty(bed.BedID))
            {
                txtBed.Text = bed.BedName;
            }
            txtTreatmentTime.Text = treatment_condition.treatment_time;
            txtVA.Text = treatment_condition.va;
            txtDialyzer.Text = treatment_condition.dialyzer;
            txtAdsorptionColumn.Text = treatment_condition.adsorption_column;
            txtPrimaryMembrane.Text = treatment_condition.primary_membrane;
            txtSecondaryMembrane.Text = treatment_condition.secondary_membrane;
            txtPunctureNeedleA.Text = treatment_condition.puncture_needle_a;
            txtPunctureNeedleV.Text = treatment_condition.puncture_needle_v;
            txtPunctureNeedleSN.Text = treatment_condition.puncture_needle_sn;
            txtUseSingleNeedle.Text = treatment_condition.use_single_needle;
            txtBloodCircuit.Text = treatment_condition.blood_circuit;
            txtVolumeOfBloodFlow.Text = treatment_condition.volume_of_blood_flow;
            txtDialysate.Text = treatment_condition.dialysate;
            txtDialysateFlowRate.Text = treatment_condition.dialysate_flow_rate;
            txtDialysateVolume.Text = treatment_condition.dialysate_volume;
            txtDialysateTemperature.Text = treatment_condition.dialysate_temperature;
            txtFluidReplacement.Text = treatment_condition.fluid_replacement;
            txtReplacementFluidAmount.Text = treatment_condition.replacement_fluidAmount;
            txtReplacementFluidSelection.Text = treatment_condition.replacement_fluid_selection;
            txtNumberOfReplacementFluids.Text = treatment_condition.number_of_replacement_fluids;
            txtFluidReplacementTemperature.Text = treatment_condition.fluid_replacement_temperature;
            txtFluidReplacementSpeed.Text = treatment_condition.fluid_replacement_speed;
            txtAnticoagulantDrug.Text = treatment_condition.anticoagulant_drug;
            txtAnticoagulantOneShotAmountDrug.Text = treatment_condition.anticoagulant_one_shot_amount_drug;
            txtAnticoagulantSustainedRate.Text = treatment_condition.anticoagulant_sustained_rate;
            txtTotalAmountOfAnticoagulantSustained.Text = treatment_condition.total_amount_of_anticoagulant_sustained;
            txtSelectIP.Text = treatment_condition.select_ip;
            txtIPStart.Text = treatment_condition.ip_start;
            txtIPOneShotAmount.Text = treatment_condition.ip_one_shot_amount;
            txtIPSpeed.Text = treatment_condition.ip_speed;
            txtIPSpeedMaximumValue.Text = treatment_condition.ip_speed_maximum_value;
            txtAutomaticOneShot.Text = treatment_condition.automatic_one_shot;
            txtIPPowerOffAutomatically.Text = treatment_condition.ip_power_off_automatically;
            txtIPPowerOffAutomaticallyTime.Text = treatment_condition.ip_power_off_automatically_time;
            txtTurnOffTheIPPowerSupplyOKMonitor.Text = treatment_condition.turn_off_the_ip_power_supply_ok_monitor;
            txtIPPowerOKMonitorTurnOffTime.Text = treatment_condition.ip_power_ok_monitor_turn_off_time;
            lblPatientID.Text = patient.PatientID;
            lblPatientName.Text = patient.PatientName;
        }

        private void FrmTreatmentConditionScreen_FormClosed(object sender, FormClosedEventArgs e)
        {
            GC.Collect();
            Dispose();
        }
    }
}