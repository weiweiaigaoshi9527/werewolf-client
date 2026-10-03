import 'package:flutter_test/flutter_test.dart';
import 'package:werewolf_app/config.dart';

void main() {
  group('服务器地址预设', () {
    test('所有预设都必须是迁移后的 11111 端口（历史上曾长期写死 8080）', () {
      expect(ServerConfig.presets, isNotEmpty);
      for (final p in ServerConfig.presets) {
        expect(p.url, contains(':${ServerConfig.kDefaultPort}'), reason: '预设 ${p.label} 端口未迁移');
        expect(p.url, isNot(contains(':8080')), reason: '预设 ${p.label} 仍是废弃的 8080');
        expect(p.url, startsWith('https://'));
        expect(p.insecure, isTrue, reason: '自签证书场景默认要放行不安全 TLS');
      }
    });
  });

  group('ServerConfig URL 拼装', () {
    test('REST 路径拼接与结尾斜杠归一', () {
      expect(ServerConfig(baseUrl: 'https://a.example.com:11111').api('/api/health').toString(),
          'https://a.example.com:11111/api/health');
      expect(ServerConfig(baseUrl: 'https://a.example.com:11111/').api('/api/health').toString(),
          'https://a.example.com:11111/api/health');
    });

    test('https → wss，http → ws，两个通道路径正确', () {
      final s = ServerConfig(baseUrl: 'https://192.168.1.169:11111');
      final ws = s.wsUri('TK');
      final voice = s.wsUriVoice('TK');
      expect(ws.scheme, 'wss');
      expect(ws.path, '/ws');
      expect(ws.port, 11111);
      expect(ws.queryParameters['token'], 'TK');
      expect(voice.scheme, 'wss');
      expect(voice.path, '/ws/voice');
      expect(voice.queryParameters['token'], 'TK');

      final plain = ServerConfig(baseUrl: 'http://localhost:11111');
      expect(plain.wsUri('T').scheme, 'ws');
      expect(plain.wsUriVoice('T').scheme, 'ws');
    });

    test('configured 只看是否填了地址', () {
      expect(ServerConfig().configured, isFalse);
      expect(ServerConfig(baseUrl: '   ').configured, isFalse);
      expect(ServerConfig(baseUrl: 'https://x:11111').configured, isTrue);
    });
  });
}
