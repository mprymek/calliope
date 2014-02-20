defmodule CalliopeParserTest do
  use ExUnit.Case

  import Calliope.Parser

  @tokens [
      ["!!! 5"],
      ["%section", ".container", ".blue"],
      ["\t", "%h1", "Calliope"],
      ["\t", "/", "%h1", "An important inline comment"],
      ["\t", "/[if IE]"],
      ["\t\t", "%h2", "An Elixir Haml Parser"],
      ["\t", "#main", ".content"],
      ["\t\t", "- lc { arg } inlist args do"],
      ["\t\t\t", "= arg"],
      ["\t\t", " Welcome to \#{title}"],
      ["%section", ".container", "(data-a: 'calliope', data-b: 'awesome')"],
      ["\t", "%img", ".one", "{id: 'main_image', class: 'two three', src: url}"],
    ]

  @parsed_tokens [
      [ doctype: "!!! 5" ],
      [ tag: "section", classes: ["container", "blue"] ],
      [ indent: 1, tag: "h1", content: "Calliope" ],
      [ indent: 1, comment: "!--", tag: "h1", content: "An important inline comment" ],
      [ indent: 1, comment: "!--[if IE]" ],
      [ indent: 2, tag: "h2", content: "An Elixir Haml Parser" ],
      [ indent: 1, id: "main", classes: ["content"] ],
      [ indent: 2, smart_script: "lc { arg } inlist args do" ],
      [ indent: 3, script: " arg" ],
      [ indent: 2, content: "Welcome to \#{title}" ],
      [ tag: "section", classes: ["container"], attributes: "data-a='calliope' data-b='awesome'" ],
      [ indent: 1, tag: "img", id: "main_image", classes: ["one", "two", "three"], attributes: "src='\#{url}'" ]
    ]

  @nested_tree [
      [ doctype: "!!! 5" ],
      [ tag: "section", classes: ["container", "blue"], children: [
          [ indent: 1, tag: "h1", content: "Calliope" ],
          [ indent: 1, comment: "!--", tag: "h1", content: "An important inline comment" ],
          [ indent: 1, comment: "!--[if IE]", children: [
              [ indent: 2, tag: "h2",content: "An Elixir Haml Parser"]
            ]
          ],
          [ indent: 1, id: "main", classes: ["content"], children: [
              [ indent: 2, smart_script: "lc { arg } inlist args do", children: [
                  [ indent: 3, script: " arg" ]
                ]
              ],
              [ indent: 2, content: "Welcome to \#{title}" ]
            ]
          ],
        ],
      ],
      [ tag: "section", classes: ["container"], attributes: "data-a='calliope' data-b='awesome'",children: [
          [ indent: 1, tag: "img", id: "main_image", classes: ["one", "two", "three"], attributes: "src='\#{url}'"]
        ]
      ]
    ]

  test :parse_line do
    assert parsed_tokens(0) == parsed_line_tokens(tokens(0))
    assert parsed_tokens(1) == parsed_line_tokens(tokens(1))
    assert parsed_tokens(2) == parsed_line_tokens(tokens(2))
    assert parsed_tokens(3) == parsed_line_tokens(tokens(3))
    assert parsed_tokens(4) == parsed_line_tokens(tokens(4))
    assert parsed_tokens(5) == parsed_line_tokens(tokens(5))
    assert parsed_tokens(6) == parsed_line_tokens(tokens(6))
    assert parsed_tokens(7) == parsed_line_tokens(tokens(7))
    assert parsed_tokens(8) == parsed_line_tokens(tokens(8))
    assert parsed_tokens(9) == parsed_line_tokens(tokens(9))
    assert parsed_tokens(10) == parsed_line_tokens(tokens(10))
  end

  test :build_tree do
    assert @nested_tree == build_tree @parsed_tokens
  end

  test :build_attributes do
    assert "href='http://google.com'" == build_attributes("href: 'http://google.com' }")
    assert "src='\#{url}'" == build_attributes("src: url }")
  end

  defp tokens(n), do: line(@tokens, n)

  defp parsed_tokens(n), do: Enum.sort line(@parsed_tokens, n)

  defp parsed_line_tokens(tokens), do: Enum.sort parse_line(tokens)

  defp line(list, n), do: Enum.fetch!(list, n)

end
