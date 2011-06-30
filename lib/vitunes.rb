#!/usr/bin/env ruby

class ViTunes
  def self.install_vim_plugin
    require 'erb'
    plugin_template = File.read(File.join(File.dirname(__FILE__), 'plugin.erb'))
    vimscript_file = File.join(File.dirname(__FILE__), 'vitunes.vim')
    plugin_body = ERB.new(plugin_template).result(binding)
    `mkdir -p #{ENV['HOME']}/.vim/plugin`
    File.open("#{ENV['HOME']}/.vim/plugin/vitunes.vim", "w") {|f| f.write plugin_body}
  end
end

if __FILE__ == $0
  ViTunes.install_vim_plugin
end

