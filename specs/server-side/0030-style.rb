
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
        div.*(:main) { color '#fff' }
        div.*(:main) { background '#fff' }
      }
      div.*(:main) { 'main' }
    end
  end

end # === describe "css pseudo"
