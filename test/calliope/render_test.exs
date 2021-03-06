defmodule CalliopeRenderTest do
  use ExUnit.Case

  use Calliope.Render

  @haml ~s{
!!! 5
%section.container{class: "blue"}
  %article
    %h1= title
    / %h1 An important inline comment
    /[if IE]
      %h2 An Elixir Haml Parser
    #main.content
      Welcome to Calliope}

  @html Regex.replace(~r/(^\s*)|(\s+$)|(\n)/m, ~s{
    <!DOCTYPE html>
    <section class="container blue">
      <article>
        <h1>Calliope</h1>
        <!-- <h1>An important inline comment</h1> -->
        <!--[if IE]> <h2>An Elixir Haml Parser</h2> <![endif]-->
        <div id="main" class="content">
          Welcome to Calliope
        </div>
      </article>
    </section>
  }, "")

  @haml_with_args "%a{href: url}= title"

  test :render do
    assert @html == render @haml, [title: "Calliope"]
    assert "<h1>This is Calliope</h1>" == render "%h1 This is \#{title}", [title: "Calliope"]
  end

  test :render_with_params do
    assert "<a href='http://google.com'>Google</a>" ==
      render @haml_with_args, [ url: "http://google.com", title: "Google" ]
  end

  test :render_with_collection do
    file = File.read!("test/fixtures/list_comprehension_example.haml")
    assert "<div>post 1</div><div>post 2</div>" == render file, [posts: [{ 1, "post 1" }, { 2, "post 2" }]]
  end

  test :render_html_safe do
    assert "<div>&lt;script&rt;a bad script&lt;/script&rt;</div>" ==
      render "%div= bad_script", [ bad_script: "<script>a bad script</script>" ]
    assert "<div><script>a good script</script></div>" ==
      render "%div= Safe.script(good_script)", [ good_script: "<script>a good script</script>" ]
  end
end
