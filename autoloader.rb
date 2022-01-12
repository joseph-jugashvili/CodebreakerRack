require 'bundler'
Bundler.setup(:default)
require 'i18n'
I18n.load_path << Dir[['config', 'locales', '**', '*.yml'].join('/')]
I18n.config.available_locales = :en
require 'delegate'
require 'codebreaker'
require 'rack'
require 'rack/test'
require 'haml'
require 'simplecov'
require_relative 'app/shortcuts'
require_relative 'app/racker/racker'
require_relative 'app/mixins/database_methods'
require_relative 'app/managers/game'
require_relative 'app/racker/game_rack'
require_relative 'app/racker/rules_rack'
require_relative 'app/racker/statistics_rack'
require_relative 'app/app'
