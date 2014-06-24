

require "open3"

def norm ugly
  o = ""
  Open3.popen3('tidy --tidy-mark no -i2 -quiet') do |i, o, e, t|
    i.print ugly
    i.close
    o << o.read
    o << e.read
  end

  o
end

def to_doc s
  norm %^
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>[No Title]</title>
    <style type="text/css">
    </style>
  </head>
  <body>#{s}</body>
</html>
  ^
end

def input json
  d = WWW_Applet.new("__MAIN__", json)
  d.run
  norm d.to_html
end

describe "HTML" do

  it "escapes chars in 'href' attributes" do
    actual = input [
      "a", [
        "href", ["& & &"],
        "home"
      ]
    ]

    target = to_doc(
      %^
        <a href="&amp; &amp; &amp;">home</a>
      ^
    )

    actual.should == target
  end

end # === describe HTML ===



__END__

json = [

  # ====================================
  #           The Main Computer
  # ====================================

  "bg color"         , [ "#ffc"          ],
  "bg image url"     , [ "THE_IMAGE_URL" ],
  "bg image repeat"  , [ "repeat-all"    ],
  "title"            , [ "megaUNI"       ],

  # ====================================
  #               STYLES
  # ====================================

  "link", "styles", [
    "text color"    , ["#ddd"],
    "on hover" , [
      "text color" , ["#fff"],
      "bg color"   , ["#ddd"]
    ]
  ],

  "box title", "styles", [
    "text size" , ["small"],
    "font"      , ["sans-serif", "italic"]
  ],

  "form field title", "styles", [
    "text color" , ["#fff"],
    "text size"  , ["medium"],
    "font"       , ["sans-serif"]
  ],

  "form field note",   "styles", [
    "text color", ["#ccc"]
  ],

  "form button", "styles", [
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

      "one line text box", [
        "max chars" , [ 30 ],
        "title", ["Screen Name:"]
      ],

      "password", [
        "max chars" , [ 200 ],
        "title"     , [ "Password:" ],
        "note"      , [ "(spaces are allowed)" ]
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
      "one line text box", [ "max chars", [30], "title", ["Screen Name:"]],
      "password", [
        "max chars" , [ 200 ],
        "title"      , ["Password"],
        "note"      , ["(for better security, use spaces and words):"]
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
