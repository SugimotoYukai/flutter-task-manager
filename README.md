# tansu_kanri

・パスワードとメールアドレスで構成される、Firebaseを利用した認証機能を持つ
・以下DB等のバックエンド機能はすべてFirebaseを用いて実装
・遷移画面間の状態管理はriverpodを用いた
・ログイン情報は記録され、ログアウトしなければまたログイン状態でアプリを開くことが出来る
・複数のユーザーが所属するグループを作成することが出来る
・各グループにタスクを追加することができ、作成者や作成日時などを記録
・歯車のボタンからユーザーやグループの情報を見ることが出来る、離脱や名前の変更もここから行うことが出来る
・各タスクにおいて、そのタスクをすると宣言したユーザーがいた場合、手のひらのアイコンと行う人数が表示される
・タスクの詳細画面から、タスクをやることの宣言と、期限の設定を行うことが出来る

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
