# note-taking-application
## 前提条件
- rubyのバージョンが3.2.2が使用できること。
  ```
  $ rbenv versions
  ```
- bundlerがインストールされていること。
  下記のコマンドでバージョンが表示される事を確認してください。
  ```
  $ bundler -v
  ```
- Postgresqlがインストールされていること。
  下記のコマンドでバージョンが表示される事を確認してください。
  ```
  $ psql --version
  ```

## 使い方
1. このリポジトリのクローンを任意のディレクトリに作成します。
  ここでは、`$HOME/ruby/note-taking-application`を使用します。
  ```
  $ mkdir -p $HOME/ruby/note-taking-application
  $ git clone https://github.com/ItohYuto/note-taking-application.git "$HOME/ruby/note-taking-application"
  ```
2. カレントディレクトリをクローンを作成したディレクトリに移動します。
```
$ cd $HOME/ruby/note-taking-application
```
3. bundlerで必要なgemをインストールする。
```
$ bundle install
```
※本番環境でのみ使用する場合は下記コマンドでgemをインストールしてください。
この方法でインストールした場合、アプリケーションの起動時に開発環境での起動ができないため、ご注意ください。
```
$ bundle config set --local without 'development'
$ bundle install
```
4. PostgreSQLにpostgresでログイン
```
$ psql -U postgres
```
5. データベースの作成
  下記のコマンドでDBを作成してください。
```
postgres=# CREATE DATABASE note_app WITH OWNER=postgres TEMPLATE=template0 ENCODING='UTF8';
```
下記コマンドでデータベースが作成できているか確認できます。
```
postgres=# \l
```
作成できていることが確認出来たらPostgreSQLからログアウトし、`postgres`からもログアウトします。
6. アプリケーションの起動
- 開発環境(コード変更した際にオートリロードができます。)
'<password>'はご自身のPostgreSQLのpostgresユーザーのパスワードを入力してください。
```
$ PASSWORD=<password> bundle exec rackup config.ru
```
- 本番環境
```
$ APP_ENV=production PASSWORD=<password> bundle exec rackup config.ru
```
7. ブラウザで下記のURLにアクセスする。
```
http://localhost:9292/
```