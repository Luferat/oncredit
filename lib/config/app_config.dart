// lib/config/app_config.dart

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  // 'DEV' para tempo de desenvolvimento
  // 'PROD' para criar o build de deploy
  static const String environment = 'PROD'; // ou PROD

  // PERIGO! ATENÇÃO! CUIDADO!
  // Configurações de acesso à API
  static String fixedUid = 'dev_uid_001';
  static String baseUrl = 'https://jsbpad-default-rtdb.firebaseio.com';

  // Configurações de `/settings`
  // Exibe (true) / oculta (false) algumas configurações estratégicas
  static bool showRepositoryLink = false;
  static bool showResetLink = false;

  // Informações "sobre" o aplicativo
  // Usadas principalmente em '/settings'
  static Map<String, String> about = {
    'app': '© 2026 André Luferat / ONCredit',
    'appName': 'ONCredit',
    'supportLink': 'https://lufer.click/contato',
    'codeRepository': 'https://github.com/Luferat/oncredit',
    'licenseName': 'MIT License',
    'licenseText': '''
MIT License

Copyright (c) 2026 André Luferat / ONCredit

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

____ Tradução PT-BR não oficial ____

É concedida permissão, gratuitamente, a qualquer pessoa que obtenha uma cópia deste software e da documentação associada (o "Software"), para lidar com o Software sem restrições, incluindo, sem limitação, os direitos de usar, copiar, modificar, fundir, publicar, distribuir, sublicenciar e/ou vender cópias do Software, e para permitir que as pessoas a quem o Software for fornecido o façam, sujeitas às seguintes condições:

O aviso de direitos autorais acima e este aviso de permissão devem ser incluídos em todas as cópias ou partes substanciais do Software.

O SOFTWARE É FORNECIDO "NO ESTADO EM QUE SE ENCONTRA", SEM GARANTIA DE QUALQUER TIPO, EXPRESSA OU IMPLÍCITA, INCLUINDO, MAS NÃO SE LIMITANDO ÀS GARANTIAS DE COMERCIALIZAÇÃO, ADEQUAÇÃO A UM FIM ESPECÍFICO E NÃO VIOLAÇÃO. EM NENHUMA CIRCUNSTÂNCIA OS AUTORES OU DETENTORES DOS DIREITOS AUTORAIS SERÃO RESPONSÁVEIS POR QUAISQUER REIVINDICAÇÕES, DANOS OU OUTRAS RESPONSABILIDADES, SEJA EM AÇÃO CONTRATUAL, EXTRACONTRATUAL OU DE OUTRA NATUREZA, DECORRENTES DE, OU RELACIONADAS COM, O SOFTWARE OU O USO OU OUTRAS NEGOCIAÇÕES COM O SOFTWARE.
    ''',
  };

  // Não altere nada daqui, a não ser que saiba o que está fazendo
  // Carrega as configurações do usuário do sistema, caso existam
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    fixedUid = prefs.getString('fixedUid') ?? fixedUid;
    baseUrl = prefs.getString('baseUrl') ?? baseUrl;
  }

  // Salva as configurações do usuário no sistema
  static Future<void> save(String uid, String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fixedUid', uid);
    await prefs.setString('baseUrl', url);
    fixedUid = uid;
    baseUrl = url;
  }

  // Verifica se o UID já foi configurado no dispositivo
  static Future<bool> hasUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fixedUid') != null;
  }

  // Verifica se o UID tem acesso válido no Firebase RTDB
  static Future<bool> validateUid(String uid) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/users/$uid.json',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      // Firebase retorna null (não 404) quando o nó não existe
      return response.statusCode == 200 && response.data != null;
    } catch (_) {
      return false;
    }
  }
}
