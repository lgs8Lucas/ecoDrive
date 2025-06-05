import 'dart:ui';
import 'package:ecoDrive/shared/app_styles.dart';
import 'package:flutter/material.dart';

class TermsOfUseDialog extends StatelessWidget {
  const TermsOfUseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Fundo com blur e container com conteúdo
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Termos de Uso',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '''
Bem-vindo ao EcoDrive!

Obrigado por usar nosso aplicativo. Ao instalar e utilizar o EcoDrive, você concorda com os Termos de Uso descritos abaixo. Caso não concorde, recomendamos que não utilize o aplicativo.

1. Descrição do Serviço
   O EcoDrive é um aplicativo que monitora dados do veículo em tempo real por meio de dispositivos OBD-II e fornece feedback para incentivar práticas de direção ecológica.

2. Coleta de Dados  
   - O EcoDrive coleta dados do veículo como velocidade, consumo de combustível e RPM.  
   - O EcoDrive também coleta os dados do sensor de acelerômetro do celular.
   - Todas as informações são armazenadas localmente no dispositivo do usuário e não são compartilhadas com terceiros.

3. Limitação de Responsabilidade  
   - Não nos responsabilizamos por qualquer dano, direto ou indireto, causado pelo uso do aplicativo, incluindo falhas no hardware ou no sistema do veículo.

4. Alterações nos Termos  
   - Reservamo-nos o direito de modificar estes Termos de Uso a qualquer momento.  
   - Alterações significativas serão comunicadas com um alerta na inicialização do aplicativo. É responsabilidade do usuário revisar os termos atualizados.
                        ''',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Botão de fechar
          Positioned(
            right: 10,
            top: 10,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const CircleAvatar(
                backgroundColor: Colors.red,
                radius: 16,
                child: Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
