delete from "mst_coop_layout_detail" where "ctl_no" in (-704000001,-704000002);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-704000001, 'NEC-iS', 'exam_rst', 'R', '一般検査内容', 'all', 'NEC-iS 検査結果連携', '検査結果連携(受信)', '1', '<GeneralTestContent ID="">
    <CollectionNo/>
    <TotalReportDataStatus/>
    <TotalReportDataStatusName/>
    <ReportAccountStatus/>
    <ReportAccountStatusName/>
    <SendType/>
    <SendTypeName/>
    <ReceptTime/>
    <SpecimenCode>
        <Code/>
        <GenerationNo/>
        <Name/>
        <AbbreviatedName/>
        <DisplaySeq/>
    </SpecimenCode>
    <LACSSpecimenCode/>
    <TestEmargencyType/>
    <TestEmergencyTypeName/>
    <SpecimenCommentContent>
        <SpecimenComments>
            <OrderCommentCode>
                <Code/>
                <Name/>
            </OrderCommentCode>
        </SpecimenComments>
        <SpecimenCommentFree/>
    </SpecimenCommentContent>
    <GeneralTestResultContents>
        <GeneralTestResultContent detail="一般検査結果内容,ID"/>
    </GeneralTestResultContents>
</GeneralTestContent>', '{"key": {"一般検査結果内容": {"_DEFAULT": "all"}}}', '1', '0', -1, '2021-12-16 13:00:00', '2021-12-16 13:00:00');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-704000002, 'NEC-iS', 'exam_rst', 'R', '一般検査結果内容', 'all', 'NEC-iS 検査結果連携', '検査結果連携(受信)', '1', '<GeneralTestResultContent ID="">
    <TestResultItemCode>
        <Code>col:$journal.detail.pat_exam_main.exam_result_info.item_cd</Code>
        <GenerationNo/>
        <Name>col:$journal.detail.pat_exam_main.exam_result_info.item_name</Name>
        <!-- 取得しない -->
        <AbbreviatedName/>
        <UnitCode>
            <Code/>
            <GenerationNo/>
            <Name/>
        </UnitCode>
    </TestResultItemCode>
    <TestResultItemName/>
    <TestResultItemAbbreviatedName/>
    <UnitCode>col:$journal.detail.pat_exam_main.exam_result_info.unit_cd</UnitCode>
    <!-- 取得しない -->
    <UnitName>col:$journal.detail.pat_exam_main.exam_result_info.unit_name</UnitName>
    <!-- 取得しない -->
    <GeneralTestResultItemType/>
    <GeneralTestResultItemTypeName/>
    <IsToleranceDiurnalParent/>
    <TestEmargencyType/>
    <TestEmergencyTypeName/>
    <ToleranceMedicineDosage/>
    <ToleranceTime/>
    <ToleranceTimeSortKey/>
    <TestSystemResultProgressCode>
        <Code/>
        <GenerationNo/>
        <Name/>
    </TestSystemResultProgressCode>
    <OrderTestStatusType/>
    <OrderTestStatusTypeName/>
    <ReportDataStatus/>
    <ReportDataStatusName/>
    <OutOfStandardMarkType/>
    <OutOfStandardMarkTypeName/>
    <PanicMarkType/>
    <PanicMarkTypeName/>
    <NormalityResult/>
    <NormalityLowerLimitResult>col:$journal.detail.pat_exam_main.exam_result_info.lower</NormalityLowerLimitResult>
    <!-- 取得しない -->
    <NormalityHighLimitResult>col:$journal.detail.pat_exam_main.exam_result_info.upper</NormalityHighLimitResult>
    <!-- 取得しない -->
    <TestResult>col:$journal.detail.pat_exam_main.exam_result_info.result_old</TestResult>
    <!-- 取得しない -->
    <AdditionalCommentCodes>
        <AdditionalCommentCode>
            <Code/>
            <GenerationNo/>
            <Name/>
        </AdditionalCommentCode>
    </AdditionalCommentCodes>
    <EditorialResult>col:$journal.detail.pat_exam_main.exam_result_info.result</EditorialResult>
    <TestResultReportOperatorCode/>
    <TestResultReportOperatorName/>
    <JLAC10TestResultItemCode/>
    <LACSResultItemCode/>
    <HasReport/>
    <TestResultReportContents>
        <TestResultReportContent>
            <ReportSeq/>
            <ReportName/>
            <ReportURL/>
        </TestResultReportContent>
    </TestResultReportContents>
</GeneralTestResultContent>', '{}', '1', '0', -1, '2021-12-16 13:00:00', '2021-12-16 13:00:00');
