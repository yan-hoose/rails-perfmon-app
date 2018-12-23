module ApplicationHelper

  def show_active_record_errors(object)
    if object.errors.any?
      html = "<h4>Record could not be saved:</h4><ul>"
      object.errors.full_messages.each {|msg| html += "<li>#{msg}</li>" }
      html += "</ul>"
      content_tag :div, html.html_safe, class: 'alert alert-danger'
    end
  end

  def show_flash
    message, css_class = if flash.alert
      [flash.alert, 'alert-danger']
    elsif flash.notice
      [flash.notice, 'alert-info']
    end
    content_tag(:div, message, class: 'alert ' + css_class) if message
  end

  def page_header(heading, subheading = nil)
    content_tag :div, class: 'page-header' do
      content_tag :h1 do
        heading.html_safe + ' ' +
        (subheading ? content_tag(:small, subheading) : '')
      end
    end
  end

  def duration_in_human(milliseconds)
    sec = milliseconds / 1000.0
    min = sec / 60
    sec = (sec % 60).round
    '%dm %ss' % [min, sec]
  end

  def nl2br(str)
    h(str).gsub(/\n/, '<br />').html_safe if str
  end

  def blank_slate(heading, text, link_text, link_path)
    content_tag :div, class: 'well text-center' do
      content_tag :div, class: 'row' do
        content_tag :div, class: 'col-xs-12 col-lg-offset-3 col-lg-6' do
          content_tag(:h4, heading) +
          content_tag(:p, text) +
          link_to(link_text, link_path, class: 'btn btn-primary')
        end
      end
    end
  end

  def back_button
    link_to 'Back', :back, class: 'btn btn-default btn-back'
  end

  def safe_params
    params.except(:host, :port, :protocol).permit!
  end

end
