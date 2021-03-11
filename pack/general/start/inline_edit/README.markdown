## Problem

Editing javascript within HTML is annoying. To generalize, editing code that's
embedded in some different code is annoying.

## Solution

Given the following example:

``` html
<script type="text/javascript">
  $(document).ready(function() {
    $('#foo').click(function() {
      alert('OK');
    });
  })
</script>
```

Execute `:InlineEdit` within the script tag. A proxy buffer is opened with
*only* the javascript. Saving the proxy buffer updates the original one. You
can reindent, lint, slice and dice as much as you like.

Check the docs for more information, see the `examples` directory for some
example files to try it on.

If you like the plugin, consider rating it on [vim.org](http://www.vim.org/scripts/script.php?script_id=3829).

## What does it work for?

- Javascript and CSS within HTML

  ``` html
  <head>
    <script type="text/javascript">
      $(document).ready(function() {
        $('#foo').click(function() {
          alert('OK');
        });
      })
    </script>

    <style>
      body {
        color: blue;
        background-color: red;
      }
    </style>
  </head>
  ```

- SQL within ruby (matches "<<-SQL")

  ``` ruby
  def some_heavy_query
    execute <<-SQL
      SELECT * FROM users WHERE something = 'other';
    SQL
  end
  ```

- Python multiline strings (tries to guess SQL syntax) (Thanks to [@thalesmello](https://github.com/thalesmello))

  ``` python
  sql_query = """
      SELECT name
      FROM "Students"
      WHERE age > 10
  """

  print("""
  Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
  tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
  veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
  commodo consequat.

  Duis aute irure dolor in reprehenderit in voluptate velit esse cillum
  dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
  proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  """)
  ```

- Code within fenced markdown blocks

  <pre>
    Some text.

    ``` ruby
    def foo
      puts "OK"
    end
    ```

    ``` python
    def foo():
        print("OK")
    ```

    Some other text.
  </pre>

- Django blocks in templates (Thanks to [@Vladimiroff](https://github.com/Vladimiroff))

  ``` htmldjango
  {%  block content %}
  <h1>{{ section.title }}</h1>

  {% for story in story_list %}
  <h2>
    <a href="{{ story.get_absolute_url }}">
      {{ story.headline|upper }}
    </a>
  </h2>
  <p>{{ story.tease|truncatewords:"100" }}</p>
  {% endfor %}
  {% endblock %}
  ```

- Heredocs in shellscript (Thanks to [@fewaffles](https://github.com/fewaffles))

  ```
  cat <<-RUBY
    #! /usr/bin/env ruby

    puts "OK"
  RUBY

  cat <<PYTHON
    #! /usr/bin/env python3

    print("OK")
  PYTHON
  ```

- Vue Single File Components (Thanks to [@fvictorio](https://github.com/fvictorio))

  ```vue
  <template>
    <p>{{ greeting }} World!</p>
  </template>

  <script>
  module.exports = {
    data: function () {
      return {
        greeting: 'Hello'
      }
    }
  }
  </script>

  <style scoped>
  p {
    font-size: 2em;
    text-align: center;
  }
  </style>
  ```

- Visual mode - any area that you mark
