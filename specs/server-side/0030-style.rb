
describe ":style block" do

  %w[link visited hover].each { |name|
    it "adds :#{name} pseudo-class" do
      target :style, <<-EOF
        a:#{name} {
          color: #fff;
        }
      EOF

      actual do
        style {
          a {
            send("_#{name}".to_sym) { color '#fff' }
          }
        }
      end
    end # === it
  }

  it "does not render empty style classes: div {  }" do
      target :style, <<-EOF
        div a {
          color: #fff;
        }
      EOF

      actual do
        style {
          div { a { color '#fff' } }
        }
      end
  end

  it "the default selector is the parent of :style" do
    target :style, <<-EOF
      body {
        color: #fff;
      }

      div {
        border: 1px solid #000;
      }
    EOF

    actual {
      style {
        color '#fff'
      }

      div {
        style {
          border '1px solid #000'
        }
      }
    }
  end # === it

  it "does not add elements on default selector" do
    target :style, <<-EOF
      body {
        border: 1px solid #000;
      }

      a:link, a:visited {
        color: #fff;
      }
    EOF

    actual {
      style {
        border '1px solid #000'
        a._link / a._visited {
          color '#fff'
        }
      }
    }
  end # === it does not add elements on default selector

  it "does not add anything to :body" do
    target :body, <<-EOF
      <p>empty</p>
    EOF

    actual do
      style {
        a { _link { color '#fff' } }
      }
      p { 'empty' }
    end
  end # === it does not add anything 

  it "allows multiple use of the same :id" do
    target :style, %^
      #main {
        color: #fff;
      }

      #main {
        background: #fff;
      }
    ^
    actual do
      style {
        div.id(:main) { color '#fff' }
        div.id(:main) { background '#fff' }
      }
      div.id(:main) { 'main' }
    end
  end

  it "renders nested styles" do
    target :style, %^
      #main {
        border: 1px solid grey;
      }

      #main a.high {
         border: 2px solid blue;
      }
    ^

    actual do
      style {
        div.id(:main) {
          border '1px solid grey'
          a.^(:high) {
            border '2px solid blue'
          }
        }
      } # === style
    end
  end # === it renders nested styles

  it "includes parent when rendering" do
    target :style, %^
      div.main #ham {
        color: #cheese;
      }
    ^
    actual do
      div.^(:main) do
        style {
          p.id(:ham) { color '#cheese' }
        }
      end
    end
  end # === it includes parent when rendering

end # === describe "css pseudo"
