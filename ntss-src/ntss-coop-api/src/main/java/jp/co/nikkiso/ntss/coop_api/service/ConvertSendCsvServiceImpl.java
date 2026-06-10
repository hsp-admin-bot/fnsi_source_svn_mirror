package jp.co.nikkiso.ntss.coop_api.service;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.mapping.ProtocolInfoWrapper;
import jp.co.nikkiso.ntss.coop_api.mapping.ProtocolInfoWrapper.ProtocolInfo;
import jp.co.nikkiso.ntss.coop_api.telegram.TelegramFormat;
import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;
import jp.co.nikkiso.ntss.coop_api.telegram.factory.TelegramGeneratorFactory;
import jp.co.nikkiso.ntss.coop_api.telegram.generator.TelegramGenerator;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.SharedSysdateStore;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramHelper;
import jp.co.nikkiso.ntss.coop_api.telegram.model.TelegramDump;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopDistributeDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDetailDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopDistribute;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.xml.Root;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

@Service
public class ConvertSendCsvServiceImpl implements ConvertSendByFormatService {
	/** DI */
	@Autowired
	MstCoopLayoutDao mstCoopLayoutDao;
	@Autowired
	MstCoopLayoutDetailDao mstCoopLayoutDetailDao;
	@Autowired
	SysCoopJournalDao sysCoopJournalDao;
	@Autowired
	MstBedDao mstBedDao;
	@Autowired
	ClockWrapper clockWrapper;
	@Autowired
	ConvertSendCommonService convertSendCommonService;
	@Autowired
	TelegramGeneratorFactory telegramGeneratorFactory;
	@Autowired
	private LogService logService;
	@Autowired
	private ConvertCommonService convertCommonService;
	@Autowired
	private MstCoopDistributeDao mstCoopDistributeDao;
	@Autowired
	private TelegramHelper helper;

	/** バイト長計算に必要な標準文字コード(MS932) */
	private static final String DEFAULT_ENCODE = JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932;

	@Override
	public void createTelegram(SysCoopJournal journal) {
		long startMillis = clockWrapper.getClockMillis();
		String facilityCd = journal.getFacilityCd();
		String coopVersion = !StringUtils.hasLength(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
		String direction = journal.getDirection();
		String coopCd = journal.getCoopCd();
		String coopCdIndex = journal.getCoopCdIndex();
		String coopCdSub = convertSendCommonService.getCoopCdSub(journal.getCrud());
		MstCoopLayout layout = convertCommonService.getMstCoopLayoutBySub(facilityCd, direction, coopCd, coopCdIndex,
				coopVersion, coopCdSub);
		/* upd by chamaojia 2026-04-24 [10959] add param coopIni --start */
		List<MstCoopIni> coopIniList = convertCommonService.getMstCoopIniByFacilityCd(facilityCd);
		MstCoopIni coopIni = CollectionUtils.isEmpty(coopIniList) ? null : coopIniList.get(0);

		// 共有システム時刻の初期化
		TelegramContext context = createContext(layout.getCoopSettingRoot(), journal, layout, coopIni);
		helper.initSharedSysdate(context);
		// data-setを利用した出力がある場合に限り、あらかじめdata-setをリクエストしておく
		Map<String, List<Map<String, Object>>> dataSetResultMap = convertSendCommonService
				.createRequestAndRequestByDataSetApi(journal, layout.getCoopExtSetting(), null, coopIni);
		/* upd by chamaojia 2026-04-24 [10959] add param coopIni --end */

		context.addDataSetResultMap(dataSetResultMap);

		// 送信用の電文を作成
		TelegramDump telegramDump = createTelegram(context);
		try {
			String fileName = Optional.ofNullable(telegramDump.getDumpPath())
					.or(() -> Optional.ofNullable(convertSendCommonService.getDumpFileName(layout, journal)))
					.orElseThrow(() -> new IllegalStateException("ファイル名の決定に失敗しました。考えられる原因:\n" +
							"・複数ファイル出力の場合 → getDumpPath() が null（ファイル名生成失敗）\n" +
							"・単一ファイル出力の場合 → layout 内 dumpFileName に設定された SQLCode の結果が null"));
			journal.setDumpPath(fileName);
			journal.setDump(telegramDump.getDumpString().getBytes(DEFAULT_ENCODE));
			long endMillis = clockWrapper.getClockMillis();
			sleepIfNeeded(startMillis, endMillis, context.getSharedSysdateStore().getSleepMillis());
		} catch (UnsupportedEncodingException e) {
			throw new NtssException("電文の生成で例外が発生しました。", e);
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt(); // スレッドの割り込み状態を復元
			throw new NtssException("電文の生成中にスレッドが割り込まれました。", e);
		}

		EventLogMessage eventLogMessage = new EventLogMessage();
		eventLogMessage.setLogMessage("ConvertSendServiceImpl#createTelegram 電文内容 facility_cd:[" + facilityCd
				+ "], coop_cd:[" + journal.getCoopCd() + "], coop_version:[" + coopVersion + "], telegram:["
				+ telegramDump
				+ "]");
		eventLogMessage.setFacilityCd(facilityCd);
		eventLogMessage.setInvokeClass(this.getClass().getName());
		logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
	}

    /* upd by chamaojia 2026-04-24 [10959] add param coopIni --start */
	private TelegramContext createContext(Root root, SysCoopJournal journal, MstCoopLayout mstCoopLayout, MstCoopIni coopIni) {
		final ProtocolInfo protcolInfo = getProtocolInfo(journal);
		return new TelegramContext.Builder()
				.root(root)
				.journal(journal)
				.layout(mstCoopLayout)
				.coopIni(coopIni)
				.format(TelegramFormat.fromString(mstCoopLayout.getCoopFormat()))
				.clock(clockWrapper)
				.fileSplitDelimiterFormat(protcolInfo.getFileSplitDelimiterFormat())
				.fileNameDelimiter(protcolInfo.getFileNameDelimiter())
				.sharedSysdateStore(new SharedSysdateStore())
				.build();

	}
	/* upd by chamaojia 2026-04-24 [10959] add param coopIni --end */

	/**
	 * 指定されたレイアウトおよびジャーナル情報に基づいて送信用電文を生成します。
	 * 
	 * 本メソッドは、{@link TelegramContext} を構築し、適切な {@link TelegramGenerator} を用いて
	 * 電文文字列を作成します。
	 * 
	 * @param root             ルートXML要素。
	 * @param journal          送信対象のジャーナル情報。
	 * @param mstCoopLayout    レイアウト定義情報。
	 * @param dataSetResultMap データセットの結果マップ。
	 * @return 生成された送信用電文文字列。
	 * @throws IOException
	 */
	private TelegramDump createTelegram(TelegramContext context) {
		return telegramGeneratorFactory
				.getGenerator(context.getFormat())
				.generate(context);
	}

	private ProtocolInfoWrapper.ProtocolInfo getProtocolInfo(SysCoopJournal journal) {
		try {
			MstCoopDistribute distribute = Optional.ofNullable(
					mstCoopDistributeDao.selectByFacilityCdAndCoopCd(journal.getFacilityCd(), journal.getCoopCd()))
					.filter(list -> list.size() == 1)
					.map(list -> list.get(0))
					.orElseThrow(() -> new IllegalStateException(
							String.format("配信先設定が0件または複数件存在します [facilityCd=%s, coopCd=%s]",
									journal.getFacilityCd(), journal.getCoopCd())));
			String distributeSetting = distribute.getDistributeSetting();
			ProtocolInfoWrapper protocolInfoWrapper = ObjectMapperUtil.read(distributeSetting,
					ProtocolInfoWrapper.class);
			return protocolInfoWrapper.getProtocolInfo();
		} catch (IOException e) {
			throw new NtssException("配信先設定の読み込みに失敗しました。", e);
		}
	}

	/**
	 * スリープが必要な場合、指定された時間だけスリープします。
	 * 
	 * @param startMillis 処理開始時刻のミリ秒
	 * @param endMillis   処理終了時刻のミリ秒
	 * @param sleepMillis スリープ時間（ミリ秒）
	 * @throws InterruptedException
	 */
	private void sleepIfNeeded(long startMillis, long endMillis, long sleepMillis)
			throws InterruptedException {
		long processMillis = endMillis - startMillis;
		if (processMillis < sleepMillis) {
			// スリープ時間が必要な場合はスリープする
			Thread.sleep(sleepMillis - processMillis);
		}
	}
}