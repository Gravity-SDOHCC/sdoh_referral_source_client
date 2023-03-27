module JsonColorizeHelper
  def colorize_json(json)
    output = ""
    tokens = {
      '{' => 'color: #ffc35f;',
      '}' => 'color: #ffc35f;',
      '[' => 'color: #ffc35f;',
      ']' => 'color: #ffc35f;',
      ',' => 'color: #ffc35f;',
      ':' => 'color: #0069ff;',
      'true' => 'color: green;',
      'false' => 'color: red;',
      'null' => 'color: #baa2cd;'
    }

    json.scan(/(".*?"|{|}|[|]|,|:|true|false|null|-?\d+(\.\d+)?([eE][+-]?\d+)?|\s+)/) do |token|
      color = tokens[token.first] || ('color: #3ea4dc;' if token.first.start_with?('"')) || nil
      if color
        output += "<span style='#{color}'>#{ERB::Util.html_escape(token.first)}</span>"
      else
        output += ERB::Util.html_escape(token.first)
      end
    end

    output.html_safe
  end
end

