module ReportsHelper

  def websites_sub_menu_with_date_filter(website, filters)
    sub_menu = content_tag(:ul, class: 'nav nav-pills navbar-left') do
      sub_menu_li('Overview', overview_website_reports_path(website), /\/reports\/overview/) +
      sub_menu_li('Request durations', request_durations_website_reports_path(website), /\/reports\/request_durations/) +
      sub_menu_li('Database time', db_time_website_reports_path(website), /\/reports\/db_time/) +
      sub_menu_li('View time', view_time_website_reports_path(website), /\/reports\/view_time/) +
      sub_menu_li('Blockers', blockers_website_reports_path(website), /\/reports\/blockers/)
    end
    sub_menu << content_tag(:div, id: 'date-filter-container') do
      content_tag(:button, type: 'button', id: 'daterange', class: 'btn btn-default btn-lg pull-right') do
        glyphicon('calendar') +
        content_tag(:span, daterange_str(filters[:start_date], filters[:end_date]), class: 'daterange-str') +
        empty_span('caret') +
        tag(:input, type: :hidden, id: 'start-date', value: filters[:start_date]) +
        tag(:input, type: :hidden, id: 'end-date', value: filters[:end_date]) +
        tag(:input, type: :hidden, id: 'controller', value: filters[:contr]) +
        tag(:input, type: :hidden, id: 'action', value: filters[:act])
      end +
      content_tag(:label, check_box_tag('compare-periods-checkbox', '1', filters[:compare_periods]) + 'Compare to another period', class: 'pull-right') +
      content_tag(:button, type: 'button', id: 'comparison-daterange', class: 'btn btn-default pull-right') do
        glyphicon('calendar') +
        content_tag(:span, daterange_str(filters[:comparison_start_date], filters[:comparison_end_date]), class: 'daterange-str') +
        empty_span('caret') +
        tag(:input, type: :hidden, id: 'comparison-start-date', value: filters[:comparison_start_date]) +
        tag(:input, type: :hidden, id: 'comparison-end-date', value: filters[:comparison_end_date])
      end
    end
    content_tag :div, class: 'row' do
      content_tag :div, class: 'col-xs-12' do
        sub_menu
      end
    end
  end

  def page_header_with_navbar(website)
    content_tag :div, class: 'page-header page-header-with-navbar' do
      content_tag(:h1, website.name.html_safe + ' ' + (website.url ? content_tag(:small, website.url) : '')) +
      content_tag(:ul, class: 'nav nav-pills navbar-right') do
        sub_menu_li('Reports', overview_website_reports_path(website), /\/reports\//) +
        sub_menu_li('Notes', website_notes_path(website), /\/notes/) +
        sub_menu_li('Website settings', edit_website_path(website), /\/edit/)
      end
    end
  end

  def daterange_str(start_date, end_date)
    "#{l(start_date)} - #{l(end_date)}"
  end

  def chart(chart_id, website)
    content_tag :div, class: 'row' do
      content_tag :div, class: 'col-xs-12 chart-container' do
        chart_without_container(website, id: chart_id)
      end
    end
  end

  def chart_without_container(website, options = {})
    content_tag :div, {class: 'chart', data: {website_id: website.id}}.merge!(options) do
      content_tag :div, 'Loading data...', class: 'text-center text-muted loading-chart-data'
    end
  end

  def filter_link(website_request)
    html = ''.html_safe
    html << link_to(website_request.controller, url_for(safe_params.merge(contr: website_request.controller)))
    html << '#'.html_safe
    html << link_to(website_request.action, url_for(safe_params.merge(act: website_request.action)))
    html
  end

  def show_filters
    filters = session[:query_filters]
    html = ''
    [:contr, :act].each do |filter|
      if filters[filter].present?
        html << link_to(
          filters[filter].html_safe + ' ' + glyphicon('remove'),
          url_for(params.merge(filter => '')),
          class: 'btn btn-success'
        )
      end
    end
    html.html_safe
  end

  def comparison_value(row, attribute, bigger_is_better = false)
    html = ' / '
    if @result_data.comparison_data_hash[row.controller] && @result_data.comparison_data_hash[row.controller][row.action]
      val = row.send(attribute).to_f
      comparable_val = @result_data.comparison_data_hash[row.controller][row.action][attribute]
      html << "#{comparable_val.round.to_s} "
      html << percentage_diff(val, comparable_val, bigger_is_better)
    else
      html << '-'
    end
    content_tag(:small, html.html_safe)
  end

  def percentage_diff(value, comparable_value, bigger_is_better)
    percentage = comparable_value != 0 ? ((value.to_f - comparable_value.to_f) / comparable_value * 100) : 0
    content_tag(:span, '(%s%.1f&#37;)'.html_safe % [percentage <= 0 ? '' : '+', percentage],
      class: percentage >= 0 && bigger_is_better || percentage <= 0 && !bigger_is_better ? 'text-success' : 'text-danger')
  end

  def overview_stat_block(stat_method, pattern, explanation, bigger_is_better)
    comp_tag = if @result_data.filters[:compare_periods]
      content_tag(:small) do
        (' / %s<br>' % pattern % @result_data.comparison.send(stat_method)).html_safe +
        percentage_diff(@result_data.send(stat_method), @result_data.comparison.send(stat_method), bigger_is_better)
      end
    end || ''
    html = content_tag(:span, class: 'overview-stat') do
      (pattern % @result_data.send(stat_method)).html_safe + comp_tag
    end
    content_tag :div, class: 'col-xs-12 col-sm-6 col-lg-4' do
      content_tag :div, class: 'panel panel-default' do
        content_tag :div, class: 'panel-body text-right' do
          html +
          content_tag(:span, explanation, class: 'text-muted')
        end
      end
    end
  end

  def dashboard_stat_block(result_data, stat_method, pattern, explanation)
    content_tag :div, class: 'panel panel-default' do
      content_tag :div, class: 'panel-body text-right' do
        content_tag(:span, pattern % result_data.send(stat_method), class: 'dashboard-stat') +
        content_tag(:span, explanation, class: 'text-muted')
      end
    end
  end

private

  def sub_menu_li(name, path, active_state_reqex)
    content_tag(:li, link_to(name, path), class: (request.path =~ active_state_reqex ? 'active' : nil))
  end

  def empty_span(css_class)
    content_tag(:span, nil, class: css_class)
  end

  def glyphicon(icon_name, *additional_css_classes)
    empty_span "glyphicon glyphicon-#{icon_name} #{additional_css_classes ? additional_css_classes.join(' ') : nil}"
  end

end
