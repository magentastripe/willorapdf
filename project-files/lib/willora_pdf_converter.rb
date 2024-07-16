#
# WilloraPDF
# Charlotte Koch <charlotte@magentastripe.com>
#

# With guidance from:
# - https://docs.asciidoctor.org/pdf-converter/latest/extend/create-converter/
# - https://docs.asciidoctor.org/pdf-converter/latest/extend/use-cases/#custom-thematic-break
class WilloraPDFConverter < Asciidoctor::Converter.for('pdf')
  register_for 'pdf'

  # My custom thematic break, which is just a blank space the size of the main
  # font. (The default thematic break draws a horizontal rule.)
  def convert_thematic_break(node)
    theme_margin(:thematic_break, :top)
    move_down(theme.base_font_size)
    theme_margin(:thematic_break, ((block_next = next_enclosed_block node) ? :bottom : :top), block_next || true)
  end
end
