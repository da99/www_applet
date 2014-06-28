
require 'Bacon_Colored'
require 'www_applet'
require 'pry'
require "differ"
require "sanitize"
require "escape_escape_escape"

Differ.format = :color

def norm ugly
  ugly.split("\n").map { |s|
    strip = s.strip
    if strip.index("<") == 0
      strip
    else
      s
    end
  }.join("\n")
end

def strip_each_line str
  str.split("\n").map(&:strip).join "\n"
end

def to_doc h
  the_css = Sanitize::CSS.stylesheet(
    (h[:style] || ''),
    Escape_Escape_Escape::CONFIG
  )

  the_body = Escape_Escape_Escape.html(h[:body] || '')

  %^
   <!DOCTYPE html><html lang="en"><head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
      <title>[No Title]</title>
      <style type="text/css">#{the_css}</style>
   </head>
   <body>#{the_body}</body></html>
  ^.strip
end

def to_html &blok
  WWW_Applet.new(&blok).to_html
end

def should_equal *args, &blok
  if block_given?
    actual = to_html(&blok)
    target = args.first
  else
    actual = args.first
    target = args.last
  end
  a = norm(actual)
  t = norm(target)
  if a != t
    puts " ======== ACTUAL =========="
    puts a
    puts " ======== TARGET =========="
    puts t
    puts " =========================="
    puts Differ.diff_by_word(a,t)
    fail "No match"
  else
    a.should == t
  end
end

class WWW_Applet_Test

  def initialize applet, output
    @applet = applet
    @err    = nil
    @test   = WWW_Applet.new("__main_test___", output)
    @test.extend Computers
    @test.send :test_applet, @applet
  end

  def run
    begin
      @applet.run
    rescue Object => e
      fail_expected = @test.tokens.detect { |v|
        v.is_a?(String) && WWW_Applet.standard_key(v) == "SHOULD RAISE"
      }
      raise e unless fail_expected
      @test.send :test_err, e
    end
    @test.run
  end

  module Computers

    class << self
      def aliases
        @map ||= {}
      end
    end # === class self

    private
    def test_applet app = :none
      if app != :none
        @test_applet = app
      end
      @test_applet
    end

    def test_err e = :none
      if e != :none
        @test_err = e
      end
      @test_err
    end


    public
    aliases[:value_should_equals_equals] = "value should =="
    def value_should_equals_equals sender, to, args
      name = sender.stack.last
      target = args.last
      @test_applet.get(name).should == target
    end

    def should_raise sender, to, args
      err_name = args.last
      @test_err.message.should.match /#{Regexp.escape err_name}/
      @test_err.message
    end

    def message_should_match sender, to, args
      str_regex = args.last
      msg = sender.stack.last
      msg.should.match /#{Regexp.escape str_regex}/i
    end

    aliases[:stack_should_equal_equal] = "stack should =="
    def stack_should_equal_equal sender, to, args
      @test_applet.stack.should == args
    end

    def should_not_raise sender, to, args
      @err.should == nil
    end

    aliases[:last_console_message_should_equal_equal] = "last console message should =="
    def last_console_message_should_equal_equal sender, to, args
      @test_applet.console.last.should == args.last
    end

    aliases[:console_should_equal_equal] = "console should =="
    def console_should_equal_equal sender, to, args
      @test_applet.console.should == args
    end
  end # === module Computers

end # === class





