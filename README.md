# ご祝儀袋・香典袋 なぞり書き

ご祝儀袋・香典袋の表書きと名前を、iPhone の画面に実寸の筆文字（縦書き）で表示し、袋の短冊や薄い紙を重ねてなぞり書きするアプリ。表示中は明るさ最大・自動ロック停止。薄墨表示、位置と大きさの微調整、カードでの実寸調整つき。

- Bundle ID: `jp.nazorigaki.app` / 1.0.0+1 / iPhone のみ / 日本語 / ホーム画面名「なぞり書き」
- データは端末内（shared_preferences）だけ。アカウント・サーバーなし。無料時はAdMobバナー（購入後非表示）。解析なし
- アプリ内課金（非消耗型）: `jp.nazorigaki.app.unlock`「全機能アンロック」¥300。サブスクなし
- 無料: 楷書（Yuji Syuku）1書体・名前1名・全用途の表書き
- アンロック: 書体4種追加、連名（3名）、中袋の住所と名前、金額の大字変換（30000 → 金参萬圓）、名前・住所の履歴
- 書体はすべて SIL OFL 1.1（`assets/licenses/`、アプリ内「フォントのライセンス」に表示）

## 構成

```
lib/src/core   用途・袋の大きさ・書体・大字変換・入力中の状態（Draft）
lib/src/store  StoreKit 境界（AppStoreBridge）と買い切りの状態（UnlockService）
lib/src/ui     画面（ホーム・入力・なぞり書き・購入・設定・実寸調整）
lib/src/widgets 縦書きの描画、和紙の背景、金封タイル
```

## 開発

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
flutter pub get
flutter analyze
flutter test
```

## ストア用スクリーンショット

シミュレーター（iPhone 15 Pro、1179×2556）を起動して:

```sh
tool/capture_app_store_screenshots.sh ~/Downloads/nazori-screenshots-raw
```

デバッグビルドだけが `SHOWCASE` の dart-define を読む（リリースでは無視）。購入画面は撮影用の代替ストア（購入しない）で日本の価格を表示する。

## ページ

`docs/` を GitHub Pages で公開: https://cedric1963y-lab.github.io/nazori-gaki/
（サポート / privacy.html / terms.html）

アイコンは `tool/make_icon.py`（水引と、上半分だけ墨が入った「寿」）。
