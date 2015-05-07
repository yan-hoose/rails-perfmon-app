require 'rails_helper'

RSpec.describe ReportsHelper, :type => :helper do
  before(:all) do
    Struct.new('ResultData', :comparison_data_hash)
    Struct.new('Request', :controller, :action, :value)
  end
  let(:website) { FactoryGirl.create(:website) }

  describe '#websites_sub_menu_with_date_filter' do
    let(:filters) { {
      start_date: Date.civil(2015, 4, 20),
      end_date: Date.civil(2015, 4, 26),
      comparison_start_date: Date.civil(2015, 4, 13),
      comparison_end_date: Date.civil(2015, 4, 19),
      compare_periods: false,
      contr: 'PostsController',
      act: 'index'
    } }

    it 'displays website sub menu' do
      html = helper.websites_sub_menu_with_date_filter(website, filters)
      expect(html).to match /<a href="\/websites\/\d+\/reports\/overview">Overview<\/a>/
      expect(html).to match /<a href="\/websites\/\d+\/reports\/request_durations">Request durations<\/a>/
      expect(html).to match /<a href="\/websites\/\d+\/reports\/db_time">Database time<\/a>/
      expect(html).to match /<a href="\/websites\/\d+\/reports\/view_time">View time<\/a>/
      expect(html).to match /<a href="\/websites\/\d+\/reports\/blockers">Blockers<\/a>/
    end

    context 'daterange selector button' do
      it 'displays the button' do
        html = helper.websites_sub_menu_with_date_filter(website, filters)
        expect(html).to match /<button type="button" id="daterange".+>.+<\/button>/
      end

      it 'displays the daterange' do
        html = helper.websites_sub_menu_with_date_filter(website, filters)
        expect(html).to match /<button.+<span class="daterange-str">2015-04-20 - 2015-04-26<\/span>.+<\/button>/
      end

      it 'has neccessary hidden fields' do
        html = helper.websites_sub_menu_with_date_filter(website, filters)
        expect(html).to include('<input type="hidden" id="start-date" value="2015-04-20" />')
        expect(html).to include('<input type="hidden" id="end-date" value="2015-04-26" />')
        expect(html).to include('<input type="hidden" id="controller" value="PostsController" />')
        expect(html).to include('<input type="hidden" id="action" value="index" />')
      end
    end

    it 'displays daterange comparison checkbox unchecked when not comparing' do
      html = helper.websites_sub_menu_with_date_filter(website, filters)
      expect(html).to have_selector('input[type="checkbox"][id="compare-periods-checkbox"]', count: 1)
      expect(html).to have_selector('input[type="checkbox"][id="compare-periods-checkbox"][checked="checked"]', count: 0)
    end

    it 'displays daterange comparison checkbox checked when comparing' do
      html = helper.websites_sub_menu_with_date_filter(website, filters.merge(compare_periods: true))
      expect(html).to have_selector('input[type="checkbox"][id="compare-periods-checkbox"][checked="checked"]', count: 1)
    end

    context 'comparison daterange selector button' do
      it 'has the button' do
        html = helper.websites_sub_menu_with_date_filter(website, filters)
        expect(html).to have_selector('button[type="button"][id="comparison-daterange"]', count: 1)
      end

      it 'has the daterange string' do
        html = helper.websites_sub_menu_with_date_filter(website, filters)
        expect(html).to match /<button type="button" id="comparison-daterange".+><span class="daterange-str">2015-04-13 - 2015-04-19<\/span>.+<\/button>/
      end

      it 'has neccessary hidden fields' do
        html = helper.websites_sub_menu_with_date_filter(website, filters)
        expect(html).to include('<input type="hidden" id="comparison-start-date" value="2015-04-13" />')
        expect(html).to include('<input type="hidden" id="comparison-end-date" value="2015-04-19" />')
      end
    end
  end

  describe '#page_header_with_navbar' do
    it 'displays heading and website sub menu' do
      site = FactoryGirl.create(:website, name: 'Website name', url: nil)
      expect(helper.page_header_with_navbar(site)).to eq("<div class=\"page-header page-header-with-navbar\"><h1>Website name </h1><ul class=\"nav nav-pills navbar-right\"><li><a href=\"/websites/#{site.id}/reports/overview\">Reports</a></li><li><a href=\"/websites/#{site.id}/notes\">Notes</a></li><li><a href=\"/websites/#{site.id}/edit\">Website settings</a></li></ul></div>")
    end

    it 'displays subheading if set' do
      site = FactoryGirl.create(:website, name: 'Website name', url: 'Subheading!1')
      expect(helper.page_header_with_navbar(site)).to match /<h1>Website name <small>Subheading!1<\/small><\/h1>/
    end
  end

  describe '#filter_link' do
    let(:request_data) { Struct::Request.new('PostsController', 'index') }

    it 'creates a filter link' do
      allow(helper).to receive(:params).and_return({controller: 'reports', action: 'request_durations', website_id: website.id})

      html = helper.filter_link(request_data)
      expect(html).to eq("<a href=\"/websites/#{website.id}/reports/request_durations?contr=PostsController\">PostsController</a>#<a href=\"/websites/#{website.id}/reports/request_durations?act=index\">index</a>")
    end

    it 'merges already set controller filters' do
      allow(helper).to receive(:params).and_return({controller: 'reports', action: 'request_durations', website_id: website.id, contr: 'CommentsController'})

      html = helper.filter_link(request_data)
      expect(html).to eq("<a href=\"/websites/#{website.id}/reports/request_durations?contr=PostsController\">PostsController</a>#<a href=\"/websites/#{website.id}/reports/request_durations?act=index&amp;contr=CommentsController\">index</a>")
    end

    it 'merges already set action filters' do
      allow(helper).to receive(:params).and_return({controller: 'reports', action: 'request_durations', website_id: website.id, act: 'update'})

      html = helper.filter_link(request_data)
      expect(html).to eq("<a href=\"/websites/#{website.id}/reports/request_durations?act=update&amp;contr=PostsController\">PostsController</a>#<a href=\"/websites/#{website.id}/reports/request_durations?act=index\">index</a>")
    end
  end

  describe '#show_filters' do
    it 'creates filter removing links for every filter' do
      allow(helper).to receive(:params).and_return({
        'controller' => 'reports',
        'action' => 'request_durations',
        'website_id' => website.id
      })
      allow(helper).to receive(:session).and_return({query_filters: {
        :contr => 'PostsController',
        :act => 'update'
      }})

      html = helper.show_filters
      expect(html).to eq("<a class=\"btn btn-success\" href=\"/websites/#{website.id}/reports/request_durations?contr=\">PostsController <span class=\"glyphicon glyphicon-remove \"></span></a><a class=\"btn btn-success\" href=\"/websites/#{website.id}/reports/request_durations?act=\">update <span class=\"glyphicon glyphicon-remove \"></span></a>")
    end
  end

  describe '#comparison_value' do
    before(:each) do
      @result_data = Struct::ResultData.new
      allow(@result_data).to receive(:comparison_data_hash).and_return({
        'PostsController' => {'index' => {value: 20}}
      })
    end
    let(:request_row) { Struct::Request.new('PostsController', 'index', 25) }

    it 'shows the comparison value and calls #percentage_diff when bigger_is_better is true' do
      expect(helper).to receive(:percentage_diff).with(25, 20, true).and_call_original
      html = helper.comparison_value(request_row, :value, true)
      expect(html).to include('<small> / 20 <span')
    end

    it 'shows the comparison value and calls #percentage_diff when bigger_is_better is false' do
      request_row.value = 10
      expect(helper).to receive(:percentage_diff).with(10, 20, false).and_call_original
      html = helper.comparison_value(request_row, :value, false)
      expect(html).to include('<small> / 20 <span')
    end

    it 'shows a dash when there is nothing to compare to' do
      request_row.action = 'update'
      html = helper.comparison_value(request_row, :value)
      expect(html).to eq('<small> / -</small>')
    end
  end

  describe '#percentage_diff' do
    it 'shows difference in percentage' do
      html = helper.percentage_diff(25, 20, true)
      expect(html).to eq('<span class="text-success">(+25.0&#37;)</span>')

      html = helper.percentage_diff(10, 20, false)
      expect(html).to eq('<span class="text-success">(-50.0&#37;)</span>')

      html = helper.percentage_diff(20, 20, false)
      expect(html).to eq('<span class="text-success">(0.0&#37;)</span>')
    end

    context 'bigger is better' do
      it 'creates a positive/green value row when value is bigger' do
        html = helper.percentage_diff(25, 20, true)
        expect(html).to eq("<span class=\"text-success\">(+25.0&#37;)</span>")
      end

      it 'creates a negative/red value row when value is smaller' do
        html = helper.percentage_diff(10, 20, true)
        expect(html).to eq("<span class=\"text-danger\">(-50.0&#37;)</span>")
      end

      it 'creates a positive/green value row when no difference' do
        html = helper.percentage_diff(20, 20, true)
        expect(html).to eq("<span class=\"text-success\">(0.0&#37;)</span>")
      end
    end

    context 'smaller is better' do
      it 'creates a positive/green value row when value is smaller' do
        html = helper.percentage_diff(10, 20, false)
        expect(html).to eq("<span class=\"text-success\">(-50.0&#37;)</span>")
      end

      it 'creates a negative/red value row when value is bigger' do
        html = helper.percentage_diff(25, 20, false)
        expect(html).to eq("<span class=\"text-danger\">(+25.0&#37;)</span>")
      end

      it 'creates a positive/green value row when no difference' do
        html = helper.percentage_diff(20, 20, false)
        expect(html).to eq("<span class=\"text-success\">(0.0&#37;)</span>")
      end
    end
  end

  describe '#chart' do
    it 'generates chart html container' do
      expect(helper.chart('request_duration_chart', website)).to eq("<div class=\"row\"><div class=\"col-xs-12 chart-container\"><div class=\"chart\" data-website-id=\"#{website.id}\" id=\"request_duration_chart\"><div class=\"text-center text-muted loading-chart-data\">Loading data...</div></div></div></div>")
    end
  end

  describe '#daterange_str' do
    it 'displays date range' do
      expect(helper.daterange_str(Date.civil(2015, 4, 20), Date.civil(2015, 4, 27))).to eq('2015-04-20 - 2015-04-27')
    end
  end

  describe '#overview_stat_block' do
    it 'generates a overview stat block container' do
      @result_data = ReportsDataGatherer.new(website, {}, {})
      allow(@result_data.instance_variable_get(:@current_period_data)).to receive(:nth_percentile).and_return(57)

      expect(helper.overview_stat_block(:nth_percentile, '%d ms', 'Test text', true)).to eq("<div class=\"col-xs-12 col-sm-6 col-lg-4\"><div class=\"panel panel-default\"><div class=\"panel-body text-right\"><span class=\"overview-stat\">57 ms</span><span class=\"text-muted\">Test text</span></div></div></div>")
    end

    it 'generates container with comparison info when comparing periods' do
      @result_data = ReportsDataGatherer.new(website, {compare_periods: true}, {})
      allow(@result_data.instance_variable_get(:@current_period_data)).to receive(:nth_percentile).and_return(57)
      allow(@result_data.instance_variable_get(:@comparison_period_data)).to receive(:nth_percentile).and_return(87)

      expect(helper.overview_stat_block(:nth_percentile, '%d ms', 'Test text', true)).to eq("<div class=\"col-xs-12 col-sm-6 col-lg-4\"><div class=\"panel panel-default\"><div class=\"panel-body text-right\"><span class=\"overview-stat\">57 ms<small> / 87 ms<br><span class=\"text-danger\">(-34.5&#37;)</span></small></span><span class=\"text-muted\">Test text</span></div></div></div>")
    end
  end

end