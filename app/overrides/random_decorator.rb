module LookupContextDecorator
  def find_all(name, prefixes = [], partial = false, keys = [], options = {})
    name, prefixes = normalize_name(name, prefixes)
    details, details_key = detail_args_for(options)
    @view_paths.find_all(name, prefixes, partial, details, details_key, keys)
  end

  # Fix when prefix is specified as part of the template name
  def normalize_name(name, prefixes)
    name = name.to_s
    idx = name.rindex('/')
    return name, prefixes.presence || [''] unless idx

    path_prefix = name[0, idx]
    path_prefix = path_prefix.from(1) if path_prefix.start_with?('/')
    name = name.from(idx + 1)

    prefixes = if !prefixes || prefixes.empty?
                 [path_prefix]
               else
                 prefixes.map { |p| "#{p}/#{path_prefix}" }
               end

    [name, prefixes]
  end
end

ActionView::LookupContext.prepend(LookupContextDecorator)

module ActionMailerDecorator
  def collect_responses_from_templates(headers)
    templates_path = headers[:template_path] || self.class.mailer_name
    templates_name = headers[:template_name] || action_name
    # raise Exception, templates_path

    each_template(Array(templates_path), templates_name).map do |template|
      format = template.format || formats.first
      {
        body: render(template: template, formats: [format]),
        content_type: Mime[format].to_s
      }
    end
  end

  def each_template(paths, name, &block)
    templates = lookup_context.find_all(name, paths)
    # raise Exception, templates
    if templates.empty?
      raise ActionView::MissingTemplate.new(paths, name, paths, false, 'mailer')
    else
      templates.uniq(&:format).each(&block)
    end
  end
end

ActionMailer::Base.prepend(ActionMailerDecorator)
