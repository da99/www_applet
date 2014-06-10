
require "nokogiri"


class String
  def unindent 
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end
end

module HTML
end # === module HTML

module JavaScript
end # === module JavaScrip

module Styles

  class << self

    def raw_args
      @raw_args ||= []
    end

  end # === class self

  def are sender, to, args
    rule_name = sender.grab_stack_tail(1, "a name for the style")
    new_style_rule(
      rule_name,
      args.select { |o| is_a_style?(o) }
    )
  end

  # ===================================================
  #                 Properties
  # ===================================================

  def font sender, to, args
    val = args.map { |o|
      require_arg(
        "font",
        o,
        [:string, "can only be a string"],
        [:not_empty_string, "can't be an empty string"],
        [:matches, /\A[a-z0-9\-\_\ ]{1,100}\Z/i, "only allow 1-100 characters: letters, numbers, spaces, - _"]
      )
    }.join ", "
    new_style to, val
  end

  def bg_color sender, to, args
    val = require_arg(
      "bg color",
      args.last,
      [:string, "must be a string"],
      [:not_empty_string, "can't be an empty string"],
      [:matches, /\A[a-z0-9\#]{1,25}\Z/i, "only allow 1-25 characters: letters, numbers and #"],
      :upcase
    )
    new_style to, val
  end

  def text_color sender, to, args
    val = require_arg(
      "text color",
      args.last,
      [:string, "must be a string"],
      [:not_empty_string, "can't be an empty string"],
      [:matches, /\A[a-z0-9\#]{1,25}\Z/i, "allow 1-25 characters: letters, numbers and #"],
      :upcase
    )
    new_style to, val
  end

  def text_size sender, to, args
    val = require_arg(
      "text size",
      args.last,
      [:string, "must be a string"],
      [:not_empty_string, "can't be an empty string"],
      :upcase,
      [:included, %w{SMALL MEDIUM LARGE X-LARGE}, "can only be: small, medium, large, x-large"]
    )

    new_style to, val
  end

  def bg_image_url sender, to, args
    val = require_arg(
      to,
      args.last,
      [:string, "must be a string"],
      [:not_empty_string, "can't be an empty string"],
      [:max_length, 200, "url needs to be 200 or less chars."],
      [:matches, /\A[a-z0-9\_\-\:\/\?\&\(\)\@\.]{1,200}\Z/i , "url has invalid chars"]
    )
    new_style to, val
  end

  def bg_image_pattern sender, to, args
    opts = ["REPEAT ALL", "REPEAT ACROSS", "REPEAT UP/DOWN"]
    val = require_arg(
      to,
      standard_key(args.last),
      [:string, "must be a string"],
      [:not_empty_string, "can't be an empty string"],
      [:included, opts, "can only be one of these: #{opts.join ', '}"]
    )
    new_style to, val
  end

  def id sender, to, args
    val = require_arg(
      to,
      standard_key(args.last),
      [:string, "must be a string"],
      [:not_empty_string, "can't be an empty string"],
      [:max_length, 100, "url needs to be 100 or less chars."],
      [:matches, /\A[a-z0-9\_\-\ ]{1,100}\Z/i , "id has invalid chars"]
    )
    new_style to, val
  end

  def title sender, to, args
    val = require_arg(
      to, args.last.to_s.strip,
      [:not_empty_string, "can't be empty."]
    )
    new_style to, val
  end

  def notice sender, to, args
    val = require_arg(
      to, args.last.to_s.strip,
      [:not_empty_string, "can't be empty."]
    )
    new_style to, val
  end

  def max_chars sender, to, args
    val = require_arg(to, args.last, :number, [:max, 200], [:min, 1])
    new_style to, val
  end


  # ===================================================
  #                    Events
  # ===================================================

  def on_click sender, to, args
    new_style to, args.last
  end

  def on_hover sender, to, args
    vals = args.select { |o| is_a_style?(o) }
    new_style to, vals
  end

  # ===================================================
  #                    Actions
  # ===================================================

  def submit_form sender, to, args
    new_style to, args.last
  end

  # ===================================================
  #                    Elements
  # ===================================================

  def p sender, to, args
    val = require_arg(
      to, args.last.to_s.strip,
      [:not_empty_string, "can't be empty."]
    )
    new_element sender, to, [val]
  end

  %w{ p box button form one_line_text_input password }.each { |name|
    eval %^
      def #{name} *args
        new_element *args
      end
    ^
  }

  private # ==========================================

  def new_style_rule rule_name, styles
    {"IS"=>["STYLE RULE"], "NAME"=>standard_key(rule_name), "VALUE"=>styles}
  end

  def new_style name, val
    {"IS"=>["STYLE"], "NAME"=>standard_key(name), "VALUE"=>val}
  end

  def new_element sender, to, args
    e = {
      "IS"    => ["ELEMENT"],
      "NAME"  => standard_key(to),
      "VALUE" => args.select { |o| is_stylish?(o) }
    }
  end

  def is_a_style? o
    o.is_a?(Hash) && o["IS"].is_a?(Array) && o["IS"].include?("STYLE")
  end

  def is_a_element? o
    o.is_a?(Hash) && o["IS"].is_a?(Array) && o["IS"].include?("ELEMENT")
  end

  def is_a_style_rule? o
    o.is_a?(Hash) && o["IS"].is_a?(Array) && o["IS"].include?("STYLE RULE")
  end

  def is_stylish? o
    is_a_style?(o) || is_a_element?(o) || is_a_style_rule?(o)
  end

  def require_arg name, raw, *args
    val = raw
    args.each { |o|
      val = case
            when o == :upcase
              fail "Invalid: #{name} must be a string: #{val.inspect}" unless val.is_a?(String)
              val.upcase
            when o == :number
              fail "Invalid: #{name} must be a number: #{val.inspect}" unless val.is_a?(Numeric)
              val
            when o.is_a?(Array)
              cmd = o.first
              msg = "Invalid: #{o.last}: #{val.inspect}"
              case cmd
              when :string
                fail msg if !val.is_a?(String)
              when :not_empty_string
                fail "Invalid: #{name} must be a string: #{val.inspect}" unless val.is_a?(String)
                fail msg if val.empty?
              when :included
                fail msg unless o[1].include?(val)
              when :max_length
                fail "Invalid: #{name} must be a string: #{val.inspect}" unless val.is_a?(String)
                fail msg unless val.length <= 200
              when :max
                fail "Invalid: #{name} must be #{o[1]} or less" unless val <= o[1]
              when :min
                fail "Invalid: #{name} must be #{o[1]} or more" unless val >= o[1]
              when :matches
                regex = o[1]
                fail msg unless regex =~ val
              else
                fail "Invalid: unknown option: #{name.inspect} #{val.inspect} #{args.inspect}"
              end

              val
            else
              fail "Invalid: unknown option: #{o.inspect}"
            end
    }
    val
  end

end # === module Styles

module HTML

  def organize_the_styles o
    meta = {
      "META"     => {},
      "STYLES"   => {},
      "TEXT"     => nil,
      "ELEMENTS" => [],
    }

    if o.last.is_a? String
      meta["TEXT"] = o.last
    end

    o.each { |v|
      case
      when is_a_style?(v)
        meta["META"][v["NAME"]] = v["VALUE"]

      when is_a_style_rule?(v)
        meta["STYLES"][v["NAME"]] ||= {}
        target = meta["STYLES"][v["NAME"]]
        v["VALUE"].each { |rule|
          target[rule["NAME"]] = rule["VALUE"]
        }

      when is_a_element?(v)
        meta["ELEMENTS"].push v

      end
    }

    meta
  end

  def to_html
    require "pp"
    pp organize_the_styles(@stack)
    ""
    # html_doc.to_html
  end

  def html_doc
    @html_doc ||= begin
                    Nokogiri::HTML <<-EOHTML.unindent
                      <!DOCTYPE html>
                      <html lang="en">
                        <head>
                          <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                          <title>My Page</title>
                          <style type="text/css">
                          </style>
                        </head>
                        <body></body>
                      </html>
                    EOHTML
                  end
  end
end # --- module

require "www_applet"

json = [

  # ====================================
  #           The Main Computer
  # ====================================

  "bg color"         , [ "#ffc"          ],
  "bg image url"     , [ "THE_IMAGE_URL" ],
  "bg image pattern" , [ "repeat all"    ],
  "title"            , [ "megaUNI"       ],

  # ====================================
  #               STYLES
  # ====================================

  "link", "are", [
    "text color"    , ["#ddd"],
    "on hover" , [
      "text color" , ["#fff"],
      "bg color"   , ["#ddd"]
    ]
  ],

  "box title", "are", [
    "text size" , ["small"],
    "font"      , ["sans-serif", "italic"]
  ],

  "form field title", "are", [
    "text color" , ["#fff"],
    "text size"  , ["medium"],
    "font"       , ["sans-serif"]
  ],

  "form field notice", "are", [
    "text color", ["#ccc"]
  ],

  "form button", "are", [
    "text size", ["small"]
  ],

  # ====================================
  #             Content
  # ====================================

  "box", [
    "id" , [ "intro" ],
    "p"  , [ "Multi-Life Chat & Publishing." ],
    "p"  , [ "Coming later this year."       ]
  ],

  "box", [
    "title"   , [ "Log-in" ],
    "form", [

      "one line text input", [
        "max chars" , [ 30 ],
        "title", ["Screen Name:"]
      ],

      "password", [
        "max chars" , [ 200 ],
        "title"     , [ "Password:" ],
        "notice"    , [ "(spaces are allowed)" ]
      ],

      "button", [
        "title" , [ "Log-In" ],
        "on click" , [ "submit form", [] ]
      ]
    ] # === form
  ], # === box

  "box", [
    "title" ,  [ "Create a new account" ],
    "form", [
      "one line text input", [ "max chars", [30], "title", ["Screen Name:"]],
      "password", [
        "max chars" , [ 200 ],
        "title"      , ["Password"],
        "notice"    , ["(for better security, use spaces and words):"]
      ],
      "password", [
        "max chars", [200],
        "title", ["Re-type the password:"]
      ],
      "button", [
        "title", ["Create Account"],
        "on click", ["submit form", []]
      ]

    ] # form
  ], # box

  "box", [
    "id", ["footer"],
    "p", ["(c) 2012-2014. megauni.com. Some rights reserved."],
    "p", ["All other copyrights belong to their respective owners."]
  ]

]
# =======================
#     end json
# =======================

d = WWW_Applet.new "__MAIN__", json
d.extend_applet Styles
d.extend HTML
d.run
puts d.to_html

if ARGV.first == "print"
  File.open "/tmp/n.html", "w+" do |io|
    io.write d.to_html
  end
end



