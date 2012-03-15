module Jekyll
  class SourceCoder < Liquid::Block
    include Liquid::StandardFilters

    # We need a language, but the linenos argument is optional.
    SYNTAX = /(\w+)\s?([\w\s=]+)*/

    def initialize(tag_name, markup, tokens)
      super
      if markup =~ SYNTAX
        @lang = $1
      else
        raise SyntaxError.new("Syntax Error in 'sourcecode' - Valid syntax: sourcecode <lang>")
      end
    end

    def render(context)
      if context.registers[:site].pygments
        render_pygments(context, super)
      else
        render_codehighlighter(context, super)
      end
    end

    def render_pygments(context, code_string)
      liners,source = "",""
      code_array = code_string.strip.split("\n")
      total_lines = code_array.size

      total_lines.times do |ln|
        liners += "<span id=\"L#{ln+1}\" rel=\"#L#{ln+1}\">#{ln+1}</span>\n"
      end

      code_array.each_with_index do |line,i|
        code_line = Albino.new(line, @lang).to_s
        code_line.gsub!(/<div class="highlight"><pre>|\n<\/pre>|\n<\/div>/,'')
        code_line.gsub!(/^([ ])+/){|m| "&nbsp;"*m.size}
        code_line = "<br/>" if code_line.strip==''
        source += "<div class='line' id='LC#{i+1}'>#{code_line}</div>"
      end

      liners_block = <<-LINERS
<td><pre class='line_numbers'>#{liners}</pre></td>
LINERS

      source_block = <<-SOURCE
<td width="100%">
<div class='highlight'><pre>#{source}</pre></div>
</td>
SOURCE

      output = <<-OUTPUT
<div class='data type-#{@lang}'>
<table cellpadding='0' cellspacing='0'>
<tr>#{liners_block}#{source_block}</tr>
</table>
</div>
OUTPUT
    end

    def render_codehighlighter(context, code)
      #The div is required because RDiscount blows ass
      <<-HTML
<!-- basic code highlighter / no pygments -->
<div class="code">
<pre>
<code class='#{@lang}'>#{h(code).strip}</code>
</pre>
</div>
HTML
    end

  end
end

Liquid::Template.register_tag('sourcecode', Jekyll::SourceCoder)
