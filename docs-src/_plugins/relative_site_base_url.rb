module Jekyll
  class RelativeSiteBaseURL < Liquid::Block

    def render(context)
      [
        File.join(['..'] *
        (context['page']['path'].split(/\//).count - 1)),
        super
      ].reject{|item| item.size.zero? }.join('/')
    end
  end
end

Liquid::Template.register_tag('baseurl', Jekyll::RelativeSiteBaseURL)