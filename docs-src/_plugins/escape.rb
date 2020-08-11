module Jekyll
  class EscapeTag < Liquid::Block

    def render(context)
      super.gsub(/\</,'&lt;').gsub(/\>/,'&gt;')
    end

  end
end

Liquid::Template.register_tag('escape', Jekyll::EscapeTag)