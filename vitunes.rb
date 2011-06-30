#!/usr/local/bin/macruby
puts RUBY_VERSION
framework 'Foundation'
framework 'ScriptingBridge'
require 'rubygems'
require 'drb'

class SBElementArray
  def [](value)
    self.objectWithName(value)
  end
end

ITunes = SBApplication.applicationWithBundleIdentifier("com.apple.itunes")
load_bridge_support_file 'iTunes.bridgesupport'
ITunes.run

class ViTunes
  def initalize
  end

  def search(query)
    playlist = ITunes.sources["Library"].playlists["Music"]
    @tracks = playlist.searchFor query, :only => ::ITunesESrAAll
    @tracks.map {|track| format(track)}.join("\n")
  end

  def format(track)
    fields = %w(databaseID name album artist composer year genre)
    values = fields.map {|x| track.send(x)}
    format_string = "%s  " * fields.size
    format_string % values
  end

  def play(index=0)
    @tracks[index].playOnce(true)
  end

  def self.start(uri)
    $daemon = ViTunes.new
    DRb.start_service(uri, $daemon)
    # stay in daemon mode
    DRb.thread.join
  end

  def quit
    puts "TEST"
  end

  def self.install_plugin
    require 'erb'
    plugin_template = File.read(File.join(File.dirname(__FILE__), 'plugin.erb'))
    vimscript_file = File.join(File.dirname(__FILE__), 'vitunes.vim')
    plugin_body = ERB.new(plugin_template).result(binding)
    `mkdir -p #{ENV['HOME']}/.vim/plugin`
    File.open("#{ENV['HOME']}/.vim/plugin/vitunes.vim", "w") {|f| f.write plugin_body}
  end
end
if __FILE__ == $0
  vt = ViTunes.new
  puts vt.search(ARGV.first)
  #vt.play 0
end

