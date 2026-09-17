String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');

String _dataActual() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String _horaActual() {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
}

String _nomFitxer(int n) {
  final now = DateTime.now();
  final d = '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
  final h = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  return '${d}_${h}_Remesa_${n}_Cuaderno_19_14_XML.xml';
}

class DadesRemesa {
  const DadesRemesa({
    required this.nomClub,
    required this.adrecaClub,
    required this.paisClub,
    required this.credId,
    required this.ibanClub,
    required this.socis,
    required this.quota,
  });

  final String nomClub;
  final String adrecaClub;
  final String paisClub;
  final String credId;
  final String ibanClub;
  final List<SociRemesa> socis;
  final num quota;

  bool get valid =>
      nomClub.isNotEmpty &&
      adrecaClub.isNotEmpty &&
      paisClub.isNotEmpty &&
      credId.isNotEmpty &&
      ibanClub.isNotEmpty &&
      socis.isNotEmpty &&
      quota > 0;

  String get importTotal => quota.toStringAsFixed(2);

  String generaXML() {
    final now = DateTime.now();
    final msgId = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${_horaActual()}${now.millisecond.toString().padLeft(3, '0')}';
    final dataColl = _dataActual();
    final nSocis = socis.length;

    final sb = StringBuffer();
    sb.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    sb.writeln('<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02">');
    sb.writeln('  <CstmrDrctDbtInitn>');

    sb.writeln('    <GrpHdr>');
    sb.writeln('      <MsgId>${_esc(msgId)}</MsgId>');
    sb.writeln('      <CreDtTm>${_dataActual()}T${_horaActual()}</CreDtTm>');
    sb.writeln('      <NbOfTxs>$nSocis</NbOfTxs>');
    sb.writeln('      <CtrlSum>${_esc(importTotal)}</CtrlSum>');
    sb.writeln('      <InitgPty>');
    sb.writeln('        <Nm>${_esc(nomClub)}</Nm>');
    sb.writeln('        <Id>');
    sb.writeln('          <OrgId>');
    sb.writeln('            <Othr>');
    sb.writeln('              <Id>${_esc(credId)}</Id>');
    sb.writeln('            </Othr>');
    sb.writeln('          </OrgId>');
    sb.writeln('        </Id>');
    sb.writeln('      </InitgPty>');
    sb.writeln('    </GrpHdr>');

    sb.writeln('    <PmtInf>');
    sb.writeln('      <PmtInfId>${_esc(msgId)}_01</PmtInfId>');
    sb.writeln('      <PmtMtd>DD</PmtMtd>');
    sb.writeln('      <BatchBooking>true</BatchBooking>');
    sb.writeln('      <NumOfTxs>$nSocis</NumOfTxs>');
    sb.writeln('      <CtrlSum>${_esc(importTotal)}</CtrlSum>');
    sb.writeln('      <PmtTpInf>');
    sb.writeln('        <SvcLvl>');
    sb.writeln('          <Cd>SEPA</Cd>');
    sb.writeln('        </SvcLvl>');
    sb.writeln('        <LclInstrm>');
    sb.writeln('          <Cd>CORE</Cd>');
    sb.writeln('        </LclInstrm>');
    sb.writeln('      </PmtTpInf>');
    sb.writeln('      <ReqdColltnDt>$dataColl</ReqdColltnDt>');
    sb.writeln('      <Cdtr>');
    sb.writeln('        <Nm>${_esc(nomClub)}</Nm>');
    sb.writeln('        <PstlAdr>');
    sb.writeln('          <StrtNm>${_esc(adrecaClub)}</StrtNm>');
    sb.writeln('          <Ctry>${_esc(paisClub)}</Ctry>');
    sb.writeln('        </PstlAdr>');
    sb.writeln('      </Cdtr>');
    sb.writeln('      <CdtrAcct>');
    sb.writeln('        <Id>');
    sb.writeln('          <IBAN>${_esc(ibanClub)}</IBAN>');
    sb.writeln('        </Id>');
    sb.writeln('      </CdtrAcct>');
    sb.writeln('      <CdtrAgt>');
    sb.writeln('        <FinInstnId>');
    sb.writeln('          <BIC>NOTPROVIDED</BIC>');
    sb.writeln('        </FinInstnId>');
    sb.writeln('      </CdtrAgt>');
    sb.writeln('      <ChrgBr>SLEV</ChrgBr>');
    sb.writeln('      <DbtrSchmeId>');
    sb.writeln('        <Id>');
    sb.writeln('          <PrvtId>');
    sb.writeln('            <Othr>');
    sb.writeln('              <Id>${_esc(credId)}</Id>');
    sb.writeln('              <Issr>SEPA</Issr>');
    sb.writeln('            </Othr>');
    sb.writeln('          </PrvtId>');
    sb.writeln('        </Id>');
    sb.writeln('      </DbtrSchmeId>');

    for (var i = 0; i < socis.length; i++) {
      final s = socis[i];
      final endToEndId = '${msgId}_${(i + 1).toString().padLeft(3, '0')}';
      sb.writeln('      <DrctDbtTxInf>');
      sb.writeln('        <PmtId>');
      sb.writeln('          <EndToEndId>${_esc(endToEndId)}</EndToEndId>');
      sb.writeln('        </PmtId>');
      sb.writeln('        <InstdAmt Ccy="EUR">${_esc(quota.toStringAsFixed(2))}</InstdAmt>');
      sb.writeln('        <DbtrAgt>');
      sb.writeln('          <FinInstnId>');
      sb.writeln('            <BIC>NOTPROVIDED</BIC>');
      sb.writeln('          </FinInstnId>');
      sb.writeln('        </DbtrAgt>');
      sb.writeln('        <Dbtr>');
      sb.writeln('          <Nm>${_esc(s.nom)}</Nm>');
      sb.writeln('        </Dbtr>');
      sb.writeln('        <DbtrAcct>');
      sb.writeln('          <Id>');
      sb.writeln('            <IBAN>${_esc(s.iban)}</IBAN>');
      sb.writeln('          </Id>');
      sb.writeln('          <Tp>');
      sb.writeln('            <Cd>CACC</Cd>');
      sb.writeln('          </Tp>');
      sb.writeln('        </DbtrAcct>');
      sb.writeln('        <RmtInf>');
      sb.writeln('          <Ustrd>Quota soci ${now.year}</Ustrd>');
      sb.writeln('        </RmtInf>');
      sb.writeln('      </DrctDbtTxInf>');
    }

    sb.writeln('    </PmtInf>');
    sb.writeln('  </CstmrDrctDbtInitn>');
    sb.writeln('</Document>');

    return sb.toString();
  }

  String get nomFitxer => _nomFitxer(socis.length);
}

class SociRemesa {
  const SociRemesa({required this.nom, required this.iban});
  final String nom;
  final String iban;
}
