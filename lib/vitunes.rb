#!/usr/bin/env ruby

class ViTunes
  def self.install_vim_plugin
    require 'erb'
    plugin_template = File.read(File.join(File.dirname(__FILE__), 'plugin.erb'))
    vimscript_file = File.join(File.dirname(__FILE__), 'vitunes.vim')
    vitunes_tool_path = File.join(File.dirname(__FILE__), 'vitunes-tool-objc')
    
    plugin_body = ERB.new(plugin_template).result(binding)

    # fix the path to vitunes-tool-objc
    #
    `mkdir -p #{ENV['HOME']}/.vim/plugin`
    File.open("#{ENV['HOME']}/.vim/plugin/vitunes.vim", "w") {|f| f.write plugin_body}
    puts "Installed vitunes.vim into your ~/.vim/plugin directory"
    puts "You should be able to invoke ViTunes in Vim with <Leader>i"
  end

  def self.help
    readme = File.expand_path("../../README.markdown", __FILE__)
    help = "ViTunes help\n\n" + File.read(readme).split("## How to use it")[1].strip
  end
end

if __FILE__ == $0
  ViTunes.install_vim_plugin
end

