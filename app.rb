# frozen_string_literal: true

require 'sinatra/base'
require 'csv'

APP_NAME = 'メモアプリ'
CSV_HEADER = %w[id title content].freeze

class NoteTakingApplication < Sinatra::Base
  configure do
    enable :method_override
    set :root, File.join(File.dirname(__FILE__), '')
    if Dir.children("#{root}data").none? { |file| file == 'memos.csv' }
      CSV.open("#{root}data/memos.csv", 'w') do |csv|
        csv << CSV_HEADER
      end
    end
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  helpers do
    def data_file_path
      File.join(settings.root, 'data/memos.csv')
    end

    def read_notes
      CSV.table(data_file_path, headers: true)
    end

    def h(text)
      Rack::Utils.escape_html(text)
    end

    def writing_into_csv(notes)
      CSV.open(data_file_path, 'w', headers: true) do |csv|
        csv << CSV_HEADER
        notes.each { |note| csv << note }
      end
    end
  end

  before do
    @title = APP_NAME
    @notes = read_notes
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
    @sub_title = '一覧'
    erb :list
  end

  get '/register' do
    @sub_title = '新規登録画面'
    erb :register
  end

  get '/notes/:note_id' do |note_id|
    note = @notes.find { |i| i[:id] == note_id.to_i }
    redirect '/notes/not_found' if note.nil?
    @sub_title = note[:title]
    @note = note
    erb :view
  end

  get '/notes/:note_id/edit' do |note_id|
    note = @notes.find { |i| i[:id] == note_id.to_i }
    redirect '/notes/not_found' if note.nil?
    @sub_title = "#{note[:title]}の編集画面"
    @note = note
    erb :edit
  end

  post '/notes' do
    note_id = if @notes.empty?
                1
              else
                @notes.max_by { |note| note[:id] }[:id] + 1
              end
    CSV.open(data_file_path, 'a') do |csv|
      csv << [note_id.to_i, params[:title], params[:content]]
    end
    redirect '/'
  end

  patch '/notes/:note_id' do |note_id|
    redirect '/notes/not_found' if @notes.none? { |note| note[:id] == note_id.to_i }
    edit_notes = (@notes.delete_if { |note| note[:id] == note_id.to_i } << [note_id.to_i, params[:title], params[:content]]).sort_by { |note| note[:id] }
    writing_into_csv(edit_notes)
    redirect '/'
  end

  delete '/notes/:note_id' do |note_id|
    redirect '/notes/not_found' if @notes.none? { |note| note[:id] == note_id.to_i }
    deleted_notes = @notes.delete_if { |note| note[:id] == note_id.to_i }
    writing_into_csv(deleted_notes)
    redirect '/'
  end
end
