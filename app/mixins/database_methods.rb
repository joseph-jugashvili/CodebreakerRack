# frozen_string_literal: true

require 'yaml'

module Database
  DATA_FILE = 'players.yml'
  STORAGE_PATH = './storage/'

  def load
    YAML.load_file(data_path) || []
  rescue Errno::ENOENT
    []
  end

  def save(game)
    create_storage
    games = load
    games << game
    File.open(data_path, 'w+') do |file|
      YAML.dump(games, file)
    end
  end

  def data_path
    STORAGE_PATH + DATA_FILE
  end

  private

  def create_storage
    Dir.mkdir(STORAGE_PATH) unless File.exist?(STORAGE_PATH)
  end
end
