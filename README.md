# Calculadora de Sub-rede IP

Aplicativo móvel (Android) de calculadora de sub-rede IPv4 para profissionais de TI responsáveis pela administração de redes. Projeto da disciplina **Hands on Work VIII** (Análise e Desenvolvimento de Sistemas – Univali), desenvolvido com abordagem **orientada a testes (TDD)**.

## Funcionalidades do MVP

| ID | Requisito |
|----|-----------|
| RF01 | Validar endereço IPv4 e máscara (CIDR e decimal pontuada) |
| RF02 | Calcular endereço de rede e broadcast |
| RF03 | Calcular faixa de hosts utilizáveis e quantidade de hosts |
| RF04 | Dividir uma rede em N sub-redes de mesmo tamanho |
| RF05 | Exibir resultados e mensagens de erro na interface |

Exemplo: `192.168.10.37/26` → rede `192.168.10.0`, broadcast `192.168.10.63`, hosts de `192.168.10.1` a `192.168.10.62` (62 hosts).

## Tecnologias

- Flutter e Dart
- `flutter_test` (unitários e de widget) e `integration_test` (integração)
- GitHub Actions (integração contínua)
- Trello (Scrum)

## Como rodar

```bash
flutter pub get
flutter test --coverage     # testes automatizados
flutter run                 # executar em emulador ou celular Android
flutter build apk --release # gerar o APK
```

## Como o TDD é aplicado

Cada requisito segue o ciclo: **escrever o teste (que falha) → implementar o mínimo para passar → refatorar**. O histórico de commits registra os testes antes do código correspondente.

## APK

O APK de cada versão fica na aba **Releases** deste repositório. Ao criar uma tag `vX.Y.Z`, o pipeline gera o APK e o anexa à Release automaticamente.

## Equipe

- Diego Adolfo Padaratz
- João Guilherme Romão
- Paulo César Ramos
- Pedro Henrique Mânica Gomes
- Glauber Lamadrid Moura
