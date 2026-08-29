import 'dart:async';

import 'package:flutter/material.dart';

import '../../../estils.dart';
import '../../../estat.dart';
import '../../../ginys.dart';

Future<void> pujaFitxer(String? token, String col, String id, String periode, {VoidCallback? onFet}) async {
  if (token == null || token.isEmpty) {
    Estat.i.mostraError(Estat.i.i18n.t('sessioCaducada'));
    return;
  }
  final f = await triaArxiu('.jpg,.jpeg,.png,.pdf');
  if (f == null) return;
  await Estat.i.call('pujarRebut', [token, col, id, periode, f]);
  await Estat.i.recarregaTot();
  Estat.i.mostraOk();
  Estat.i.refres();
  onFet?.call();
}

class IniciSociPantalla extends StatelessWidget {
  const IniciSociPantalla({super.key});

  Future<void> _renova() async {
    final f = await triaArxiu('.jpg,.jpeg,.png,.pdf');
    if (f == null) return;
    await Estat.i.call('renovarQuota', [Estat.i.token, f]);
    await Estat.i.recarregaTot();
    Estat.i.mostraOk();
    Estat.i.refres();
  }

  @override
  Widget build(BuildContext context) {
    final st = Estat.i;
    final t = st.i18n.t;
    final d = st.inici;
    final vigent = d?.quotaVigent ?? false;
    final caducitat = d?.caducitat ?? '';
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: decoCardGran(),
              child: Column(
                children: [
                  const IconaClub(),
                  const SizedBox(height: 12),
                  Text('${t('benvingut')} ${d?.nom ?? ''}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: titol)),
                  const SizedBox(height: 10),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text('${t('quotaAny')} ${d?.any ?? ''}: '),
                      XipQuota(quota: d?.quota ?? ''),
                      if (vigent && caducitat.isNotEmpty)
                        Text('${t('vigentFins')} ${mostraData(caducitat)}',
                            style: const TextStyle(fontSize: 12.5, color: verd)),
                      if (d?.quotaRebut?.url != null)
                        TextButton(
                          onPressed: () {
                            final url = d?.quotaRebut?.url;
                            if (url != null) obrirUrl(url);
                          },
                          child: Text('(${t('veureRebut')})', style: const TextStyle(fontSize: 13)),
                        ),
                    ],
                  ),
                  if (!vigent) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: taronja.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: taronja),
                      ),
                      child: Text(
                        '${t('quotaCaducadaMsg')}${caducitat.isNotEmpty ? ' (${mostraData(caducitat)})' : ''}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13.5, color: titol),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton.icon(
                        onPressed: _renova,
                        icon: const Icon(Icons.upload_file, size: 20),
                        label: Text(t('pujaRebutQuota'),
                            style: const TextStyle(fontSize: 15)),
                        style: FilledButton.styleFrom(
                          backgroundColor: pri,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiBoto)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BotoGran(titol: t('fitxa'), icon: Icons.badge, onTap: vigent ? () => st.go('fitxaInici') : null),
                const SizedBox(width: 16),
                BotoGran(titol: t('classes'), icon: Icons.school, onTap: vigent ? () => st.go('classesInici') : null),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
