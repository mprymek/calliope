defmodule CalliopeCompilerTest do
  use ExUnit.Case

  import Calliope.Compiler

  @ast [
    [ doctype: "!!! 5" ],
    [ tag: "section", classes: ["container"], children: [
        [ indent: 1, tag: "h1", children: [
            [ indent: 2, script: "arg"]
          ]
        ],
        [ indent: 1, tag: "h1",  comment: "!--", content: "An important inline comment" ],
        [ indent: 1, comment: "!--[if IE]", children: [
            [ indent: 1, tag: "h2", content: "An Elixir Haml Parser"]
          ]
        ],
        [ indent: 1, id: "main", classes: ["content"], children: [
            [ indent: 2, content: "Welcome to Calliope" ],
            [ indent: 2, tag: "br" ]
          ]
        ],
      ],
    ],
    [ tag: "section", classes: ["container"], children: [
        [ indent: 1, tag: "img", attributes: "src='#'"]
      ]
    ]
  ]

  @html Regex.replace(~r/(^\s*)|(\s+$)|(\n)/m, ~s{
    <!DOCTYPE html>
    <section class="container">
      <h1>
        Calliope
      </h1>
      <!-- <h1>An important inline comment</h1> -->
      <!--[if IE]> <h2>An Elixir Haml Parser</h2> <![endif]-->
      <div id="main" class="content">
        Welcome to Calliope
        <br>
      </div>
    </section>
    <section class="container">
      <img src='#'>
    </section>
  }, "")


  @smart [[smart_script: "lc { id, content } inlist posts do", children: [
              [indent: 1, tag: "div", children: [[indent: 2, script: "content"]]]
            ]]]

  @smart_haml_comments [
      [ tag: "p", content: "foo", children: [
          [ indent: 1, smart_script: "# This would", children: [
              [ indent: 2, content: "Not be"],
              [ indent: 2, content: "output"]
            ],
          ]
        ]
      ],
      [ tag: "p", content: "bar"]
    ]

  test :evaluate_content do
    assert "Hello Johnny" == evaluate_content("Hello \#{name}", [name: "Johnny"])
  end

  test :compile_attributes do
    assert " id=\"foo\" class=\"bar baz\"" ==
      compile_attributes([ id: "foo", classes: ["bar", "baz"] ], [])
    assert " class=\"bar\"" ==  compile_attributes([ classes: ["bar"] ], [])
    assert " id=\"foo\"" ==  compile_attributes([ id: "foo"], [])
  end

  test :compile_key do
    assert " class=\"content\"" == compile_key({ :classes, ["content"] })
    assert " id=\"foo\"" == compile_key({ :id, "foo" })
  end

  test :tag do
    refute tag([ foo: "bar" ])
    assert "div" == tag([tag: "div"])
    assert "div" == tag([id: "foo"])
    assert "div" == tag([classes: ["bar"]])
    assert "section" == tag([tag: "section"])
    assert "!!! 5" == tag([doctype: "!!! 5"])
    assert nil == tag([content: "Welcome to Calliope"])
  end

  test :open do
    assert "<div>"     == open("", :div)
    assert "<section>" == open("", :section)
    assert "" == open("", nil)

    assert "<!DOCTYPE html>" == open("", "!!! 5")
    assert "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">" == open("", "!!!")

    assert "<div id=\"foo\" class=\"bar\">" == open(" id=\"foo\" class=\"bar\"", :div)
  end

  test :close do
    assert "</div>" == close("div")
    assert "</section>" == close("section")
    assert "" == close(nil)

    assert "" == close("br")
    assert "" == close("link")
  end

  test :compile do
     assert ~s{<div id="test"></div>} == compile([[id: "test"]])
     assert ~s{<section id="test" class="content"></section>} == compile([[tag: "section", id: "test", classes: ["content"]]])

     children = [[classes: ["nested"]]]
     assert ~s{<div id="test"><div class="nested"></div></div>} == compile([[id: "test", children: children]])

     assert ~s{content} == compile([[content: "content"]])

     assert @html == compile(@ast, [arg: "Calliope"])
  end

  test :evaluate_multi_script do
    children = [[ indent: 1, tag: "h1", children: [[ indent: 2, script: "greet"]]]]
    assert "<h1>Hello</h1><h1>Hi</h1>" ==
      evaluate_smart_script("lc greet inlist greetings do", children, [greetings: ["Hello", "Hi"]])

    children = [[indent: 1, tag: "div", children: [[indent: 2, script: " content"]]]]
    posts = [{1, "post 1"}, {2, "post 2"}]
    assert "<div>post 1</div><div>post 2</div>" == evaluate_smart_script("lc { id, content } inlist posts do", children, [posts: posts])

    assert "<div>post 1</div><div>post 2</div>" == compile(@smart, [posts: posts])
    assert "<p>foo</p><p>bar</p>" == compile(@smart_haml_comments)
  end

end
