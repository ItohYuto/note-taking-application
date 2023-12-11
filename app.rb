# frozen_string_literal: true

require 'sinatra/base'
require 'csv'
require 'pg'

APP_NAME = 'メモアプリ'
SQL = {
  'tbl_check' => 'SELECT table_name FROM information_schema.tables WHERE table_name = $1;',
  'create_tbl' => 'CREATE TABLE notes ( id SERIAL PRIMARY KEY, title TEXT NOT NULL, content TEXT );',
  'get_list' => 'SELECT * FROM notes ORDER BY id;',
  'get_note' => 'SELECT * FROM notes WHERE id = $1;',
  'create_note' => 'INSERT INTO notes (title, content) VALUES ($1, $2);',
  'update_note' => 'UPDATE notes SET title = $1, content = $2 WHERE id = $3;',
  'delete_note' => 'DELETE FROM notes WHERE id = $1'
}.freeze
DB_CONFIG = {
  'host' => 'localhost',
  'db_name' => 'note_app',
  'db_user' => 'postgres'
}.freeze

class NoteTakingApplication < Sinatra::Base
  configure do
    enable :method_override
    set :root, File.join(File.dirname(__FILE__), '')
    set :connection, PG.connect(host: DB_CONFIG['host'], dbname: DB_CONFIG['db_name'], user: DB_CONFIG['db_user'], password: ENV['PASSWORD'])
    settings.connection.exec(SQL['create_tbl']) if settings.connection.exec_params(SQL['tbl_check'], ['notes']).cmd_status != 'SELECT 1'
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

  before do
    @title = APP_NAME
  end

  not_found do
    redirect '/not_found'
  end

  get '/not_found' do
    @sub_title = 'ページが存在しません。'
    erb :not_found
  end

  get '/notes/not_found' do
    @sub_title = 'メモが存在しません。'
    erb :note_not_found
  end

  get '/' do
    @notes = settings.connection.exec(SQL['get_list'])
    @sub_title = '一覧'
    erb :list
  end

  get '/register' do
    @sub_title = '新規登録画面'
    erb :register
  end

  get '/notes/:note_id' do |note_id|
    result = settings.connection.exec_params(SQL['get_note'], [note_id.to_i])
    redirect '/notes/not_found' if result.ntuples.zero?
    @note = result[0]
    @sub_title = @note['title']
    erb :view
  end

  get '/notes/:note_id/edit' do |note_id|
    result = settings.connection.exec_params(SQL['get_note'], [note_id.to_i])
    redirect '/notes/not_found' if result.ntuples.zero?
    @note = result[0]
    @sub_title = "#{@note['title']}の編集画面"
    erb :edit
  end

  post '/notes' do
    settings.connection.exec_params(SQL['create_note'], [params[:title], params[:content]])
    redirect '/'
  end

  patch '/notes/:note_id' do |note_id|
    result = settings.connection.exec_params(SQL['update_note'], [params[:title], params[:content], note_id.to_i])
    redirect '/notes/not_found' if result.cmd_tuples.zero?
    redirect '/'
  end

  delete '/notes/:note_id' do |note_id|
    result = settings.connection.exec_params(SQL['delete_note'], [note_id.to_i])
    redirect '/notes/not_found' if result.cmd_tuples.zero?
    redirect '/'
  end
end
