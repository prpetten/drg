require 'ostruct'
require 'set'
require 'bundler'
require 'drg/version'
require 'duck_puncher'
require 'highline/import'

# defines #clone!
DuckPuncher.punch! :Object

module DRG
  autoload :Ruby, 'drg/ruby'
  # autoload :FileReader, 'drg/file_reader'
  # autoload :Scanner, 'drg/scanner'
  # autoload :Judge, 'drg/judge'
  # autoload :FileContext, 'drg/file_context'

  module Tasks
    autoload :Updater, 'drg/tasks/updater'
    autoload :Pinner, 'drg/tasks/pinner'
    autoload :ActivePinnner, 'drg/tasks/active_pinner'
    autoload :Gemfile, 'drg/tasks/gemfile'
    autoload :GemfileLine, 'drg/tasks/gemfile_line'
    autoload :Log, 'drg/tasks/log'
  end
end

load 'tasks/drg.rake'
